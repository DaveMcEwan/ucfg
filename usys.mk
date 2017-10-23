# usys
# Dave McEwan
#
# Install local versions of applications without root permissions.
#
# All sources are fetched to $UCFG/usys/src and everything is installed to
# the prefix $UCFG/usys.
# This is quite useful in addition to the main ucfg rules for setting up
# consistent environments, or just for remembering how you got your enviroment
# in the first place.
# The string $UCFG/usys/bin will need to be prepended to $PATH.
#
# Run from $UCFG directory like:
#     make -f usys.mk <tool>
#
# Or to build and locally install groups of tools like:
#     make -f usys.mk dev
#     make -f usys.mk python
#     make -f usys.mk silicon

SELF := $(PWD)
SELF_NAME := $(shell basename $(SELF))
USYS_NAME := usys
USYS := $(SELF)/$(USYS_NAME)
USYS_SRC := $(USYS)/src

# Name of file to indicate to make that the repo is already cloned.
# Placed inside .git of repos so it isn't picked up by other tools.
GOTREPO := REPO_EXISTS_NOTOUCH

default: dev

usysdir:
	mkdir -p $(USYS)/bin
	mkdir -p $(USYS_SRC)

# {{{ groups

dev: gcc
dev: git
dev: tmux
#dev: vim
dev: graphviz
dev: meld
#dev: xdu

silicon: iverilog
silicon: verilator
#silicon: yosys

python: cpython2
python: cpython3
python: dreampie

# }}} groups

# {{{ fetch
# Fetch local copy of application repositories.
# These git repos are *not* suitable for upstream development.
# --depth=1 --branch=<version> gets only the tree at that single tag, avoiding
# the waste of disk space and bandwidth of getting the entire repo with history.

fetch_cpython2: $(USYS_SRC)/cpython2/.git/$(GOTREPO)
$(USYS_SRC)/cpython2/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/python/cpython.git cpython2\
			--depth=1 --branch=2.7
	touch $@

fetch_cpython3: $(USYS_SRC)/cpython3/.git/$(GOTREPO)
$(USYS_SRC)/cpython3/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/python/cpython.git cpython3\
			--depth=1 --branch=3.6
	touch $@

fetch_dreampie: $(USYS_SRC)/dreampie/.git/$(GOTREPO)
$(USYS_SRC)/dreampie/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/noamraph/dreampie.git \
			--depth=1 --branch=1.2.1
	touch $@

fetch_ffmpeg: $(USYS_SRC)/ffmpeg/.git/$(GOTREPO)
$(USYS_SRC)/ffmpeg/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg \
			--depth=1 --branch=release/3.4
	touch $@

fetch_gcc: $(USYS_SRC)/gcc/.git/$(GOTREPO)
$(USYS_SRC)/gcc/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/gcc-mirror/gcc.git \
			--depth=1 --branch=gcc-7_2_0-release
	cd $(USYS_SRC)/gcc; ./contrib/download_prerequisites
	touch $@

fetch_git: $(USYS_SRC)/git/.git/$(GOTREPO)
$(USYS_SRC)/git/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/git/git.git \
			--depth=1 --branch=v2.14.0
	touch $@

fetch_graphviz: $(USYS_SRC)/graphviz/.git/$(GOTREPO)
$(USYS_SRC)/graphviz/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://gitlab.com/graphviz/graphviz.git \
			--depth=1 --branch=stable_release_2.40.1
	touch $@

fetch_iverilog: $(USYS_SRC)/iverilog/.git/$(GOTREPO)
$(USYS_SRC)/iverilog/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/steveicarus/iverilog.git \
			--depth=1 --branch=v10_2
	touch $@

fetch_libressl: $(USYS_SRC)/libressl/.git/$(GOTREPO)
	-cd $(USYS_SRC); \
		git clone https://github.com/libressl-portable/portable.git libressl \
			--depth=1 --branch=OPENBSD_6_1
	touch $@

fetch_meld: $(USYS_SRC)/meld/.git/$(GOTREPO)
$(USYS_SRC)/meld/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/Gnome/meld.git \
			--depth=1 --branch=1.8.6
	touch $@

fetch_tmux: $(USYS_SRC)/tmux/.git/$(GOTREPO)
$(USYS_SRC)/tmux/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/libevent/libevent.git \
			--depth=1 --branch=release-2.1.8-stable
	-cd $(USYS_SRC); wget ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz
	-cd $(USYS_SRC); tar xzf ncurses-5.9.tar.gz
	-cd $(USYS_SRC); \
		git clone https://github.com/tmux/tmux.git \
			--depth=1 --branch=2.5
	touch $@

# NOTE: veripool git server only supports dumb protocols so need to clone full.
fetch_verilator: $(USYS_SRC)/verilator/.git/$(GOTREPO)
$(USYS_SRC)/verilator/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone http://git.veripool.org/git/verilator \
			--branch=verilator_3_912
	touch $@

fetch_yosys: $(USYS_SRC)/yosys/.git/$(GOTREPO)
$(USYS_SRC)/yosys/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/cliffordwolf/yosys.git \
			--depth=1 --branch=yosys-0.7
	touch $@

# }}} fetch

# {{{ build
# Compile libraries and applications.

build_cpython2: $(USYS_SRC)/cpython2/.git/$(GOTREPO)
	cd $(USYS_SRC)/cpython2; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/cpython2; make
	cd $(USYS_SRC)/cpython2; make test

build_cpython3: $(USYS_SRC)/cpython3/.git/$(GOTREPO)
	cd $(USYS_SRC)/cpython3; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/cpython3; make
	cd $(USYS_SRC)/cpython3; make test

# TODO: --disable-x86asm cripples exe but nasm/yasm not found.
build_ffmpeg: $(USYS_SRC)/ffmpeg/.git/$(GOTREPO)
	cd $(USYS_SRC)/ffmpeg; ./configure --prefix=$(USYS) --disable-x86asm
	cd $(USYS_SRC)/ffmpeg; make

build_gcc: $(USYS_SRC)/gcc/.git/$(GOTREPO)
	mkdir -p $(USYS_SRC)/gcc-build
	cd $(USYS_SRC)/gcc-build; $(USYS_SRC)/gcc/configure --prefix=$(USYS) \
		--disable-multilib
	cd $(USYS_SRC)/gcc-build; make

build_git: $(USYS_SRC)/git/.git/$(GOTREPO)
	cd $(USYS_SRC)/git; make prefix=$(USYS)

build_graphviz: $(USYS_SRC)/graphviz/.git/$(GOTREPO)
	cd $(USYS_SRC)/graphviz; ./autogen.sh
	cd $(USYS_SRC)/graphviz; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/graphviz; make

build_iverilog: $(USYS_SRC)/iverilog/.git/$(GOTREPO)
	cd $(USYS_SRC)/iverilog; autoconf
	cd $(USYS_SRC)/iverilog; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/iverilog; make

build_libressl: $(USYS_SRC)/libressl/.git/$(GOTREPO)
	cd $(USYS_SRC)/libressl; ./autogen.sh
	cd $(USYS_SRC)/libressl; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/libressl; make

build_tmux: $(USYS_SRC)/tmux/.git/$(GOTREPO)
	cd $(USYS_SRC)/libevent; ./autogen.sh
	cd $(USYS_SRC)/libevent; ./configure --disable-shared --prefix=$(USYS)
	cd $(USYS_SRC)/libevent; make
	cd $(USYS_SRC)/libevent; make install
	cd $(USYS_SRC)/ncurses-5.9; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/ncurses-5.9; make
	cd $(USYS_SRC)/ncurses-5.9; make install
	cd $(USYS_SRC)/tmux; ./autogen.sh
	cd $(USYS_SRC)/tmux; \
		./configure --prefix=$(USYS) \
			CFLAGS="-I$(USYS)/include -I$(USYS)/include/ncurses" \
			LDFLAGS="-L$(USYS)/lib -L$(USYS)/include/ncurses -L$(USYS)/include"
	cd $(USYS_SRC)/tmux; \
		CPPFLAGS="-I$(USYS)/include -I$(USYS)/include/ncurses" \
			LDFLAGS="-static -L$(USYS)/include -L$(USYS)/include/ncurses -L$(USYS)/lib" \
			make

build_verilator: $(USYS_SRC)/verilator/.git/$(GOTREPO)
	cd $(USYS_SRC)/verilator; autoconf
	cd $(USYS_SRC)/verilator; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/verilator; make

build_yosys: $(USYS_SRC)/yosys/.git/$(GOTREPO)
	cd $(USYS_SRC)/yosys; make config-gcc
	cd $(USYS_SRC)/yosys; make PREFIX=$(USYS)

# }}} fetch

# {{{ install
# Install to $UCFG/bin

cpython2: build_cpython2
	cd $(USYS_SRC)/cpython2; make install

cpython3: build_cpython3
	cd $(USYS_SRC)/cpython3; make install

dreampie: $(USYS_SRC)/dreampie/.git/$(GOTREPO)
	rm -f $(USYS)/bin/dreampie
	cd $(USYS)/bin; ln -s $(USYS_SRC)/dreampie/dreampie dreampie

ffmpeg: build_ffmpeg
	cd $(USYS_SRC)/ffmpeg; make install

gcc: build_gcc
	cd $(USYS_SRC)/gcc-build; make install

git: build_git
	cd $(USYS_SRC)/git; make prefix=$(USYS) install

graphviz: build_graphviz
	cd $(USYS_SRC)/graphviz; make install

iverilog: build_iverilog
	cd $(USYS_SRC)/iverilog; make install

libressl: build_libressl
	cd $(USYS_SRC)/libressl; make install DESTDIR=$(USYS)

meld: $(USYS_SRC)/meld/.git/$(GOTREPO)
	rm -f $(USYS)/bin/meld
	cd $(USYS)/bin; ln -s $(USYS_SRC)/meld/bin/meld meld

tmux: build_tmux
	cd $(USYS_SRC)/tmux; make install

verilator: build_verilator
	cd $(USYS_SRC)/verilator; make install

yosys: build_yosys
	cd $(USYS_SRC)/yosys; make install

# }}} install

# {{{ tidy
# NOTE: tidy is not the same as a usual 'make clean'.
# This rule is just to save disk space, not to return to a known state.
# Just the build directories are removed, not the binaries.

tidy_cpython2:
	rm -rf $(USYS_SRC)/cpython2

tidy_cpython3:
	rm -rf $(USYS_SRC)/cpython3

tidy_gcc:
	rm -rf $(USYS_SRC)/gcc
	rm -rf $(USYS_SRC)/gcc-build

tidy_git:
	rm -rf $(USYS_SRC)/git

tidy_graphviz:
	rm -rf $(USYS_SRC)/graphviz

tidy_iverilog:
	rm -rf $(USYS_SRC)/iverilog

tidy_tmux:
	rm -rf $(USYS_SRC)/libevent
	rm -rf $(USYS_SRC)/ncurses*
	rm -rf $(USYS_SRC)/tmux

tidy_verilator:
	rm -rf $(USYS_SRC)/verilator

tidy_yosys:
	rm -rf $(USYS_SRC)/yosys

# }}} tidy

# {{{ remove
# Remove all the installed files.

rm_cpython2:
	-rm -rf $(USYS)/bin/python2*
	-rm -rf $(USYS)/bin/idle
	-rm -rf $(USYS)/include/python2*
	-rm -rf $(USYS)/lib/pkgconfig/python2*
	-rm -rf $(USYS)/share/man/man1/python2*

rm_cpython3:
	-rm -rf $(USYS)/bin/python3*
	-rm -rf $(USYS)/bin/2to3*
	-rm -rf $(USYS)/bin/idle3*
	-rm -rf $(USYS)/include/python3*
	-rm -rf $(USYS)/lib/pkgconfig/python3*
	-rm -rf $(USYS)/share/man/man1/python3*

rm_dreampie:
	-rm -rf $(USYS)/bin/dreampie
	-rm -rf $(USYS_SRC)/dreampie

# TODO: gcc

rm_git:
	-rm -f $(USYS)/bin/git*

rm_graphviz:
	-rm -f $(USYS)/bin/dot*
	-rm -f $(USYS)/bin/neato

rm_iverilog:
	-rm -f $(USYS)/bin/iverilog*

# TODO: libressl

rm_meld:
	-rm -rf $(USYS)/bin/meld
	-rm -rf $(USYS_SRC)/meld

rm_tmux:
	-rm -f $(USYS)/bin/tmux

rm_verilator:
	-rm -rf $(USYS)/bin/verilator*

# TODO: yosys

# }}} remove
