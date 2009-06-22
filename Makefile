VERSION=0.4

DEBUG= -g #-D_DEBUG #-fprofile-arcs -ftest-coverage # -pg -g
CXXFLAGS+=-O0 -DVERSION=\"${VERSION}\" $(DEBUG) -Wall
LDFLAGS+=$(DEBUG) -lstdc++

OBJSeb=client.o config.o error.o fips140.o handle_pool.o kernel_prng_io.o log.o main.o math.o pool.o scc.o signals.o utils.o
OBJSsa=server_audio.o error.o utils.o log.o kernel_prng_io.o protocol.o server_utils.o
OBJSst=server_timers.o log.o utils.o error.o kernel_prng_io.o protocol.o server_utils.o
OBJSsv=server_v4l.o error.o log.o protocol.o utils.o kernel_prng_io.o server_utils.o
OBJSss=server_stream.o error.o log.o protocol.o utils.o kernel_prng_io.o server_utils.o
OBJSclk=client_linux_kernel.o error.o kernel_prng_io.o log.o math.o protocol.o utils.o

all: eb server_audio server_timers server_v4l server_stream client_linux_kernel

eb: $(OBJSeb)
	$(CC) -Wall -W $(OBJSeb) $(LDFLAGS) -lcrypto -lssl -o eb

server_audio: $(OBJSsa)
	$(CC) -Wall -W $(OBJSsa) $(LDFLAGS) -lasound -o server_audio

server_timers: $(OBJSst)
	$(CC) -Wall -W $(OBJSst) $(LDFLAGS) -o server_timers

server_v4l: $(OBJSsv)
	$(CC) -Wall -W $(OBJSsv) $(LDFLAGS) -o server_v4l

server_stream: $(OBJSss)
	$(CC) -Wall -W $(OBJSss) $(LDFLAGS) -o server_stream

client_linux_kernel: $(OBJSclk)
	$(CC) -Wall -W $(OBJSclk) $(LDFLAGS) -o client_linux_kernel

install: eb server_audio server_timers server_v4l server_stream client_linux_kernel
	mkdir -p /usr/local/entropybroker/bin
	cp eb /usr/local/entropybroker/bin
	cp server_audio /usr/local/entropybroker/bin
	cp server_timers /usr/local/entropybroker/bin
	cp server_v4l /usr/local/entropybroker/bin
	cp server_stream /usr/local/entropybroker/bin
	cp client_linux_kernel /usr/local/entropybroker/bin
	echo do not forget to copy entropybroker.conf to /etc

clean:
	rm -f $(OBJSeb) $(OBJSsa) $(OBJSst) $(OBJSsv) $(OBJSclk) eb core *.da *.gcov *.bb* server_audio server_timers server_v4l client_linux_kernel

package: clean
	mkdir eb-$(VERSION)
	cp *.cpp *.h entropybroker.conf Makefile Changes readme.txt license.txt eb-$(VERSION)
	tar czf eb-$(VERSION).tgz eb-$(VERSION)
	rm -rf eb-$(VERSION)