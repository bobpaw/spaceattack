bin_PROGRAMS = movinga
movinga_SOURCES = main.cc main.h cmdline.c cmdline.h text.cc text.h entity.cc entity.h
EXTRA_DIST = data/ship.png data/bomb.png data/Star1.png data/Star2.png data/enemy.png

cmdline.c cmdline.h: args.ggo
	gengetopt < args.ggo
