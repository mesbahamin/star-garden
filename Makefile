CC = gcc
CFLAGS = -std=c99 -Wall -Wextra -Wpedantic -Wshadow
LDFLAGS = $(SDL_LDFLAGS) -lm

SDL_CFLAGS := $(shell sdl2-config --cflags)
SDL_LDFLAGS := $(shell sdl2-config --libs)

override CFLAGS += $(SDL_CFLAGS)

SRC = platform_sdl.c star_garden.c star.c barnes_hut.c
EXE = star-garden

DBGDIR = debug
DBGEXE = $(DBGDIR)/$(EXE)
DBGCFLAGS = -g -Og -Werror -pg

RELDIR = release
RELEXE = $(RELDIR)/$(EXE)
RELCFLAGS = -O2 -Os

.PHONY: all clean debug memcheck prep profile release run todo

all: debug release

clean:
	rm -f $(RELDIR)/* $(DBGDIR)/*

debug: prep
	$(CC) $(CFLAGS) $(DBGCFLAGS) $(SRC) -o $(DBGEXE) $(LDFLAGS)

memcheck: debug
	valgrind --track-origins=yes ./$(DBGEXE)

prep:
	@mkdir -p $(DBGDIR) $(RELDIR)

profile: run
	gprof $(DBGEXE) gmon.out > profile_output

release: prep
	$(CC) $(CFLAGS) $(RELCFLAGS) $(SRC) -o $(RELEXE) $(LDFLAGS)

run: debug
	./$(DBGEXE)

todo:
	@grep -FIR --colour=never --ignore-case --line-number todo *.c *.h \
	| sed -re  's/^([^:]+):[[:space:]]*(.*)/\1\x01\2/' \
	| sed -re  's/^([^:]+):[[:space:]]*(.*)/\1\x01\2/' \
	| column -s $$'\x01' -t
