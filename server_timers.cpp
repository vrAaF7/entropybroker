#include <string>
#include <map>
#include <sys/time.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <openssl/blowfish.h>

const char *server_type = "server_timers v" VERSION;
const char *pid_file = PID_DIR "/server_timers.pid";

#include "error.h"
#include "utils.h"
#include "log.h"
#include "protocol.h"
#include "server_utils.h"
#include "users.h"
#include "auth.h"

void sig_handler(int sig)
{
	fprintf(stderr, "Exit due to signal %d\n", sig);
	unlink(pid_file);
	exit(0);
}

void help(void)
{
	printf("-i host   entropy_broker-host to connect to\n");
	printf("-o file   file to write entropy data to\n");
	printf("-S        show bps (mutual exclusive with -n)\n");
	printf("-l file   log to file 'file'\n");
	printf("-s        log to syslog\n");
	printf("-n        do not fork\n");
	printf("-P file   write pid to file\n");
	printf("-X file   read username+password from file\n");
}

double gen_entropy_data(void)
{
	double start;

	start = get_ts();

	/* arbitrary value:
	 * not too small so that there's room for noise
	 * not too large so that we don't sleep unnecessary
	 */
	usleep(100);

	return get_ts() - start;
}

int main(int argc, char *argv[])
{
	unsigned char bytes[1249];
	unsigned char byte = 0;
	int bits = 0, index = 0;
	char *host = NULL;
	int port = 55225;
	int c;
	bool do_not_fork = false, log_console = false, log_syslog = false;
	char *log_logfile = NULL;
	char *bytes_file = NULL;
	bool show_bps = false;
	std::string username, password;

	fprintf(stderr, "%s, (C) 2009-2012 by folkert@vanheusden.com\n", server_type);

	while((c = getopt(argc, argv, "hX:P:So:i:l:sn")) != -1)
	{
		switch(c)
		{
			case 'X':
				get_auth_from_file(optarg, username, password);
				break;

			case 'P':
				pid_file = optarg;
				break;

			case 'S':
				show_bps = true;
				break;

			case 'o':
				bytes_file = optarg;
				break;

			case 'i':
				host = optarg;
				break;

			case 's':
				log_syslog = true;
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

	if (username.length() == 0 || password.length() == 0)
		error_exit("username + password cannot be empty");

	if (!host && !bytes_file && !show_bps)
		error_exit("no host to connect to/file to write to given");

	if (chdir("/") == -1)
		error_exit("chdir(/) failed");
	(void)umask(0177);
	no_core();
	lock_mem(bytes, sizeof bytes);

	set_logging_parameters(log_console, log_logfile, log_syslog);

	if (!do_not_fork && !show_bps)
	{
		if (daemon(0, 0) == -1)
			error_exit("fork failed");
	}

	write_pid(pid_file);

	signal(SIGPIPE, SIG_IGN);
	signal(SIGTERM, sig_handler);
	signal(SIGINT , sig_handler);
	signal(SIGQUIT, sig_handler);

	protocol *p = new protocol(host, port, username, password, true, server_type);

	long int total_byte_cnt = 0;
	double cur_start_ts = get_ts();
	for(;;)
	{
		// gather random data
		double t1 = gen_entropy_data(), t2 = gen_entropy_data();

		if (t1 == t2)
			continue;

		byte <<= 1;
		if (t1 > t2)
			byte |= 1;

		if (++bits == 8)
		{
			bytes[index++] = byte;
			bits = 0;

			if (index == sizeof(bytes))
			{
				if (bytes_file)
				{
					emit_buffer_to_file(bytes_file, bytes, index);
				}
				if (host)
				{
					if (p -> message_transmit_entropy_data(bytes, index) == -1)
					{
						dolog(LOG_INFO, "connection closed");

						p -> drop();
					}
				}

				index = 0; // skip header
			}

			if (show_bps)
			{
				double now_ts = get_ts();

				total_byte_cnt++;

				if ((now_ts - cur_start_ts) >= 1.0)
				{
					int diff_t = now_ts - cur_start_ts;

					printf("Total number of bytes: %ld, avg/s: %f\n", total_byte_cnt, (double)total_byte_cnt / diff_t);

					cur_start_ts = now_ts;
					total_byte_cnt = 0;
				}
			}
		}
	}

	memset(bytes, 0x00, sizeof bytes);
	unlink(pid_file);

	delete p;

	return 0;
}
