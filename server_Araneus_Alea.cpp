// SVN: $Revision$
#include <arpa/inet.h>
#include <string>
#include <vector>
#include <map>
#include <sys/time.h>
#include <stdio.h>
#include <signal.h>
#include <stddef.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <usb.h>

#define USB_VENDOR_ARANEUS              0x12d8
#define USB_ARANEUS_PRODUCT_ALEA        0x0001
#define TIMEOUT 5000

#include "defines.h"
#include "error.h"
#include "random_source.h"
#include "utils.h"
#include "log.h"
#include "encrypt_stream.h"
#include "hasher.h"
#include "protocol.h"
#include "server_utils.h"
#include "statistics.h"
#include "statistics_global.h"
#include "statistics_user.h"
#include "users.h"
#include "auth.h"

const char *pid_file = PID_DIR "/server_Araneus_Alea.pid";

bool do_exit = false;

void sig_handler(int sig)
{
	fprintf(stderr, "Exit due to signal %d\n", sig);
	do_exit = true;
}

void help(void)
{
	printf("-I host   entropy_broker host to connect to\n");
	printf("          e.g. host\n");
	printf("               host:port\n");
	printf("               [ipv6 literal]:port\n");
	printf("          you can have multiple entries of this\n");
	printf("-o file   file to write entropy data to (mututal exclusive with -i)\n");
        printf("-l file   log to file 'file'\n");
	printf("-L x      log level, 0=nothing, 255=all\n");
        printf("-s        log to syslog\n");
	printf("-S        show bps (mutual exclusive with -n)\n");
        printf("-n        do not fork\n");
	printf("-P file   write pid to file\n");
	printf("-X file   read username+password from file\n");
}

int main(int argc, char *argv[])
{
	unsigned char bytes[4096];
	int c;
	bool do_not_fork = false, log_console = false, log_syslog = false;
	char *log_logfile = NULL;
	char *bytes_file = NULL;
	int verbose = 0;
	char server_type[128];
	bool show_bps = false;
	std::string username, password;
	std::vector<std::string> hosts;
	int log_level = LOG_INFO;

	fprintf(stderr, "eb_server_Araneus_Alea v" VERSION ", (C) 2009-2012 by folkert@vanheusden.com\n");

	while((c = getopt(argc, argv, "I:hSX:P:o:L:l:snv")) != -1)
	{
		switch(c)
		{
			case 'I':
				hosts.push_back(optarg);
				break;

			case 'S':
				show_bps = true;
				break;

			case 'X':
				get_auth_from_file(optarg, username, password);
				break;

			case 'P':
				pid_file = optarg;
				break;

			case 'v':
				verbose++;
				break;

			case 'o':
				bytes_file = optarg;
				break;

			case 's':
				log_syslog = true;
				break;

			case 'L':
				log_level = atoi(optarg);
				break;

			case 'l':
				log_logfile = optarg;
				break;

			case 'n':
				do_not_fork = true;
				log_console = true;
				break;

			case 'h':
				help();
				return 0;

			default:
				help();
				return 1;
		}
	}

	if (!hosts.empty() && (username.length() == 0 || password.length() == 0))
		error_exit("please select a file with authentication parameters (username + password) using the -X switch");

	if (hosts.empty() && !bytes_file)
		error_exit("no host to connect to or file to write to given");

	(void)umask(0177);
	no_core();

	lock_mem(bytes, sizeof bytes);

	set_logging_parameters(log_console, log_logfile, log_syslog, log_level);

	usb_init();
	usb_find_busses();
	usb_find_devices();

	struct usb_bus *bus = NULL;
	struct usb_device *dev = NULL;
	struct usb_dev_handle *handle = NULL;

	for(bus = usb_busses; bus != NULL && handle == NULL; bus = bus->next)
	{
		for(dev = bus->devices; dev != NULL && handle == NULL; dev = dev->next)
		{
			if (dev->descriptor.idVendor == USB_VENDOR_ARANEUS && dev->descriptor.idProduct == USB_ARANEUS_PRODUCT_ALEA)
			{
				handle = usb_open(dev);

				if (usb_claim_interface(handle, 0) < 0)
					error_exit("Unable to claim Alea interface 0");
			}
		}
	}

	if (!handle)
		error_exit("No Alea device found");

	snprintf(server_type, sizeof server_type, "eb_server_Araneus_Alea v" VERSION);

	if (!do_not_fork)
	{
		if (daemon(0, 0) == -1)
			error_exit("fork failed");
	}

	write_pid(pid_file);

	protocol *p = NULL;
	if (!hosts.empty())
		p = new protocol(&hosts, username, password, true, server_type, DEFAULT_COMM_TO);

	signal(SIGPIPE, SIG_IGN);
	signal(SIGTERM, sig_handler);
	signal(SIGINT , sig_handler);
	signal(SIGQUIT, sig_handler);

	init_showbps();
	set_showbps_start_ts();

	for(;!do_exit;)
	{
        	int rc = usb_bulk_read(handle, 1, (char *)bytes, sizeof bytes, TIMEOUT);

		if (rc != sizeof bytes)
			error_exit("Failed to retrieve random bytes from device %x", rc);

		////////

		if (show_bps)
			update_showbps(sizeof bytes);

		if (bytes_file)
			emit_buffer_to_file(bytes_file, bytes, sizeof bytes);

		if (!hosts.empty() && p -> message_transmit_entropy_data(bytes, sizeof bytes, &do_exit) == -1)
		{
			dolog(LOG_INFO, "connection closed");

			p -> drop();
		}

		set_showbps_start_ts();
	}

	delete p;

	memset(bytes, 0x00, sizeof bytes);

	unlink(pid_file);

	return 0;
}
