bin_PROGRAMS = movinga
movinga_SOURCES = main.cc main.h cmdline.c cmdline.h text.cc text.h entity.cc entity.h
EXTRA_DIST = ship.png bomb.png Star1.png Star2.png enemy.png

cmdline.c cmdline.h: args.ggo
	gengetopt < args.ggo
