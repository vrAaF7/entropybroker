# SVN: $Revision$

include version

-include makefile.inc

PREFIX=/usr/local/entropybroker
BIN=$(PREFIX)/bin
ETC=$(PREFIX)/etc
VAR=$(PREFIX)/var
CACHE=$(VAR)/cache
PID=$(VAR)/run
MAN=$(PREFIX)/share
DOC=$(PREFIX)/doc

CXX=g++
DEBUG= -pg #-DHELGRIND #-DCRYPTO_DEBUG #-D_DEBUG #-fprofile-arcs -ftest-coverage # -pg
LINT=-Wshadow -Wall # -W -Wconversion -Wwrite-strings -Wunused
CXXFLAGS+=-O3 -ggdb -DVERSION=\"${VERSION}\" $(LINT) $(DEBUG) -DCONFIG=\"${ETC}/entropy_broker.conf\" -DCACHE_DIR=\"${CACHE}\" -DPID_DIR=\"${PID}\" -DVAR_DIR=\"${VAR}\" -rdynamic $(PCSC_CFLAGS)
LDFLAGS+=$(DEBUG) -lcrypto -lrt -lz -lutil -rdynamic -lcryptopp

all:
	@echo targets:
	@echo -------
	@echo All targets \(except from 'plot'\) require the Crypto++ libraries.
	@echo
	@echo entropy_broker
	@echo eb_server_audio           requires libasound2-dev, linux only
	@echo eb_server_timers
	@echo eb_server_v4l             requires linux only
	@echo eb_server_stream
	@echo eb_server_egd
	@echo eb_server_push_file
	@echo eb_server_ext_proc
	@echo eb_server_usb             requires libusb-1.0-0-dev
	@echo eb_server_linux_kernel    linux only
	@echo eb_client_linux_kernel    linux only
	@echo eb_client_file
	@echo eb_client_kernel_generic
	@echo eb_client_egd
	@echo eb_server_ComScire_R2000KU  requires libftdi-dev
	@echo eb_proxy_knuth_m
	@echo eb_proxy_knuth_b
	@echo eb_server_cycle_count     linux only
	@echo eb_server_smartcard       requires libpcsclite-dev
	@echo plot                      requires libpng-dev
	@echo
	@echo to build all daemons and processes invoke:
	@echo	make everything
	@echo
	@echo to install all daemons etc. under $(PREFIX) invoke:
	@echo	make install
	@echo
	@echo to install the redhat startup-scripts, invoke:
	@echo   make install_redhat_init
	@echo
	@echo \*\*\*\*\* you need to run ./configure first \*\*\*\*\*
	@echo

BINARIES=entropy_broker eb_server_timers eb_server_v4l eb_server_stream eb_client_linux_kernel eb_server_egd eb_client_egd eb_server_linux_kernel eb_client_file eb_server_push_file eb_server_ext_proc eb_proxy_knuth_m eb_proxy_knuth_b eb_server_cycle_count ${B2}

OBJSeb=auth.o pools.o statistics.o hc_protocol.o handle_client.o config.o error.o fips140.o kernel_prng_rw.o log.o protocol.o main.o math.o pool.o scc.o signals.o utils.o my_pty.o kernel_prng_io.o hasher.o stirrer.o hasher_sha512.o stirrer_blowfish.o stirrer_aes.o hasher_md5.o hasher_ripemd160.o stirrer_3des.o stirrer_camellia.o hasher_whirlpool.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o pool_crypto.o
OBJSsa=server_audio.o error.o utils.o kernel_prng_rw.o log.o protocol.o server_utils.o auth.o my_pty.o kernel_prng_io.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSst=server_timers.o log.o utils.o error.o kernel_prng_rw.o protocol.o server_utils.o auth.o my_pty.o kernel_prng_io.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSsv=server_v4l.o error.o log.o protocol.o kernel_prng_rw.o utils.o server_utils.o auth.o my_pty.o kernel_prng_io.o users.o random_source.o  encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSss=server_stream.o error.o log.o protocol.o kernel_prng_rw.o utils.o server_utils.o auth.o my_pty.o kernel_prng_io.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSse=server_egd.o error.o log.o kernel_prng_rw.o protocol.o utils.o server_utils.o auth.o my_pty.o kernel_prng_io.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSclk=client_linux_kernel.o error.o kernel_prng_io.o kernel_prng_rw.o log.o protocol.o utils.o auth.o my_pty.o math.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJScle=client_egd.o error.o log.o kernel_prng_io.o kernel_prng_rw.o math.o protocol.o utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSsk=server_linux_kernel.o utils.o kernel_prng_rw.o kernel_prng_io.o log.o error.o protocol.o server_utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJScf=client_file.o error.o log.o kernel_prng_io.o kernel_prng_rw.o math.o protocol.o utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSpf=server_push_file.o utils.o kernel_prng_rw.o kernel_prng_io.o log.o error.o protocol.o server_utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSep=server_ext_proc.o utils.o kernel_prng_rw.o kernel_prng_io.o log.o error.o protocol.o server_utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSsu=server_usb.o utils.o kernel_prng_rw.o kernel_prng_io.o log.o error.o protocol.o server_utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJScsr2000ku=server_ComScire_R2000KU.o utils.o kernel_prng_rw.o kernel_prng_io.o log.o error.o protocol.o server_utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSpkm=proxy_knuth_m.o utils.o kernel_prng_rw.o kernel_prng_io.o log.o error.o protocol.o server_utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSpkb=proxy_knuth_b.o utils.o kernel_prng_rw.o kernel_prng_io.o log.o error.o protocol.o server_utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSscc=server_cycle_count.o utils.o kernel_prng_rw.o kernel_prng_io.o log.o error.o protocol.o server_utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o
OBJSpicc=server_smartcard.o utils.o kernel_prng_rw.o kernel_prng_io.o log.o error.o protocol.o server_utils.o auth.o my_pty.o users.o random_source.o encrypt_stream.o encrypt_stream_blowfish.o hasher.o hasher_md5.o hasher_ripemd160.o hasher_sha512.o hasher_whirlpool.o encrypt_stream_aes.o encrypt_stream_3des.o encrypt_stream_camellia.o

everything: $(BINARIES)

entropy_broker: $(OBJSeb)
	$(CXX) $(LINT) $(OBJSeb) $(LDFLAGS) -pthread -o entropy_broker

eb_server_audio: $(OBJSsa)
	$(CXX) $(LINT) $(OBJSsa) $(LDFLAGS) -lasound -o eb_server_audio

eb_server_timers: $(OBJSst)
	$(CXX) $(LINT) $(OBJSst) $(LDFLAGS) -o eb_server_timers

eb_server_v4l: $(OBJSsv)
	$(CXX) $(LINT) $(OBJSsv) $(LDFLAGS) -o eb_server_v4l

eb_server_stream: $(OBJSss)
	$(CXX) $(LINT) $(OBJSss) $(LDFLAGS) -o eb_server_stream

eb_server_egd: $(OBJSse)
	$(CXX) $(LINT) $(OBJSse) $(LDFLAGS) -o eb_server_egd

eb_client_egd: $(OBJScle)
	$(CXX) $(LINT) $(OBJScle) $(LDFLAGS) -o eb_client_egd

eb_client_linux_kernel: $(OBJSclk)
	$(CXX) $(LINT) $(OBJSclk) $(LDFLAGS) -o eb_client_linux_kernel

eb_server_linux_kernel: $(OBJSsk)
	$(CXX) $(LINT) $(OBJSsk) $(LDFLAGS) -o eb_server_linux_kernel

eb_client_file: $(OBJScf)
	$(CXX) $(LINT) $(OBJScf) $(LDFLAGS) -o eb_client_file

eb_server_push_file: $(OBJSpf)
	$(CXX) $(LINT) $(OBJSpf) $(LDFLAGS) -o eb_server_push_file

eb_server_ext_proc: $(OBJSep)
	$(CXX) $(LINT) $(OBJSep) $(LDFLAGS) -o eb_server_ext_proc

eb_server_usb: $(OBJSsu)
	$(CXX) $(LINT) $(OBJSsu) $(LDFLAGS) -lusb-1.0 -o eb_server_usb

eb_server_ComScire_R2000KU: $(OBJScsr2000ku)
	$(CXX) $(LINT) $(OBJScsr2000ku) ComScire_R2000KU/qwqng.cpp $(LDFLAGS) -lftdi -o eb_server_ComScire_R2000KU

eb_proxy_knuth_m: $(OBJSpkm)
	$(CXX) $(LINT) $(OBJSpkm) $(LDFLAGS) -pthread -o eb_proxy_knuth_m

eb_proxy_knuth_b: $(OBJSpkb)
	$(CXX) $(LINT) $(OBJSpkb) $(LDFLAGS) -pthread -o eb_proxy_knuth_b

eb_server_cycle_count: $(OBJSscc)
	$(CXX) $(LINT) $(OBJSscc) $(LDFLAGS) -o eb_server_cycle_count

eb_server_smartcard: $(OBJSpicc)
	$(CXX) $(LINT) $(OBJSpicc) $(LDFLAGS) `pkg-config --libs libpcsclite` -o eb_server_smartcard

plot: plot.o
	$(CXX) $(LINT) plot.o $(LDFLAGS) -lpng -o plot

install:
	mkdir -p $(BIN) $(ETC) $(VAR) $(PID) $(CACHE)
	for file in $(BINARIES) ; do \
		test -e $$file && cp $$file $(BIN) ; \
		test -e $$file || echo Skipping $$file which was not build ; \
	done
	test -e $(BIN)/eb_client_file && \
		(test -e $(BIN)/eb_client_kernel_generic || \
		ln $(BIN)/eb_client_file $(BIN)/eb_client_kernel_generic)
	test -e $(ETC)/entropy_broker.conf || cp entropy_broker.conf $(ETC)
	test -e $(ETC)/entropy_broker.conf && cp entropy_broker.conf $(ETC)/entropy_broker.conf.dist
	test -e $(ETC)/users.txt || (cp users.txt $(ETC) ; chmod 600 $(ETC)/users.txt)
	mkdir -p $(MAN)/man/man8
	cp doc/man/* $(MAN)/man/man8
	mkdir -p $(DOC)/entropy_broker
	cp *txt license.* $(DOC)/entropy_broker

install_redhat_init:
	cp redhat/* /etc/init.d

clean:
	rm -rf $(OBJSeb) $(OBJSsa) $(OBJSst) $(OBJSsv) $(OBJSss)$(OBJSse) $(OBJSclk) $(OBJSte) $(OBJSsk) $(OBJScf) $(OBJSpf) $(OBJSep) $(OBJSsu) $(OBJScsr2000ku) $(OBJScle) $(OBJSse) $(OBJSpkm) $(OBJSpkb) $(OBJSscc) $(OBJSpicc) plot.o core *.da *.gcov *.bb* $(BINARIES) cov-int

package:
	mkdir eb-$(VERSION) eb-$(VERSION)/ComScire_R2000KU
	cp *.cpp *.h entropy_broker.conf Makefile bin_to_values.pl do_fft.sh auth.txt network_protocol.txt users.txt readme.txt design.txt interfacing.txt license.* eb-$(VERSION)
	cp ComScire_R2000KU/*.[ch]pp ComScire_R2000KU/LICENSE eb-$(VERSION)/ComScire_R2000KU
	tar cf - doc --exclude=.svn  | tar xvf - -C eb-$(VERSION)
	tar cf - redhat --exclude=.svn  | tar xvf - -C eb-$(VERSION)
	tar czf eb-$(VERSION).tgz eb-$(VERSION)
	rm -rf eb-$(VERSION)
	#
	cp design.txt ~/site/entropybroker/

coverity: clean
	rm -rf cov-int
	cov-build --dir cov-int make everything
	tar vczf ~/site/coverity/EntropyBroker.tgz README cov-int/
	putsite -q
	/home/folkert/.coverity-eb.sh

check:
	cppcheck -v --enable=all --std=c++11 --inconclusive -I. . 2> err.txt
