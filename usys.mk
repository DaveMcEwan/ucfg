# usys
# Dave McEwan
#
# Install local versions of applications without root permissions.
#
# All sources are fetched to $UCFG/usys/src and everything is installed to
# the prefix $UCFG/usys.
# This is quite useful in addition to the main ucfg rules for setting up
# consisnent environments, or just for remembering how you got your enviroment
# in the first place.
# The string $UCFG/usys/bin will need to be prepended to $PATH.
#
# Run from $UCFG directory like:
#     make -f usys.mk <tool>
#
# Where tool is one of:
# - dreampie
# - git
# - meld
# - tmux
#
# Or to build and locally install everything like:
#     make -f usys.mk all

SELF := $(PWD)
SELF_NAME := $(shell basename $(SELF))
USYS_NAME := usys
USYS := $(SELF)/$(USYS_NAME)
USYS_SRC := $(USYS)/src

# Name of file to indicate to make that the repo is already cloned.
# Placed inside .git of repos so it isn't picked up by other tools.
GOTREPO := REPO_EXISTS_NOTOUCH

default: all

all: cpython2
all: cpython3
all: dreampie
all: git
all: meld
all: tmux
all: verilator

usysdir:
	mkdir -p $(USYS)/bin
	mkdir -p $(USYS_SRC)

# {{{ fetch
# Fetch local copy of application repositories.
# These git repos are *not* suitable for upstream development.
# --depth=1 --branch=<version> gets only the tree at that single tag, avoiding
# the waste of disk space and bandwidth of getting the entire repo with history.

fetch_all: $(USYS_SRC)/cpython2/.git/$(GOTREPO)
$(USYS_SRC)/cpython2/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/python/cpython.git cpython2\
			--depth=1 --branch=2.7
	touch $@

fetch_all: $(USYS_SRC)/cpython3/.git/$(GOTREPO)
$(USYS_SRC)/cpython3/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/python/cpython.git cpython3\
			--depth=1 --branch=3.6
	touch $@

fetch_all: $(USYS_SRC)/dreampie/.git/$(GOTREPO)
$(USYS_SRC)/dreampie/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/noamraph/dreampie.git \
			--depth=1 --branch=1.2.1
	touch $@

fetch_all: $(USYS_SRC)/git/.git/$(GOTREPO)
$(USYS_SRC)/git/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/git/git.git \
			--depth=1 --branch=v2.14.0
	touch $@

#	--depth=1 --branch=release-2.0.19-stable
fetch_all: $(USYS_SRC)/libevent/.git/$(GOTREPO)
$(USYS_SRC)/libevent/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/libevent/libevent.git \
			--depth=1 --branch=release-2.1.8-stable
	touch $@

fetch_all: $(USYS_SRC)/meld/.git/$(GOTREPO)
$(USYS_SRC)/meld/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/Gnome/meld.git \
			--depth=1 --branch=1.8.6
	touch $@

fetch_all: $(USYS_SRC)/ncurses-5.9.tar.gz
$(USYS_SRC)/ncurses-5.9.tar.gz: usysdir
	rm -f $@
	cd $(USYS_SRC); wget ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz
	cd $(USYS_SRC); tar xzf ncurses-5.9.tar.gz

fetch_all: $(USYS_SRC)/tmux/.git/$(GOTREPO)
$(USYS_SRC)/tmux/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone https://github.com/tmux/tmux.git \
			--depth=1 --branch=2.5
	touch $@

# NOTE: veripool git server only supports dumb protocols so need to clone full.
fetch_all: $(USYS_SRC)/verilator/.git/$(GOTREPO)
$(USYS_SRC)/verilator/.git/$(GOTREPO): usysdir
	-cd $(USYS_SRC); \
		git clone http://git.veripool.org/git/verilator \
			--branch=verilator_3_912
	touch $@

# }}} fetch

# {{{ build
# Compile libraries and applications.

build_all: build_cpython2
build_cpython2: $(USYS_SRC)/cpython2/.git/$(GOTREPO)
	cd $(USYS_SRC)/cpython2; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/cpython2; make
	cd $(USYS_SRC)/cpython2; make test

build_all: build_cpython3
build_cpython3: $(USYS_SRC)/cpython3/.git/$(GOTREPO)
	cd $(USYS_SRC)/cpython3; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/cpython3; make
	cd $(USYS_SRC)/cpython3; make test

build_all: build_git
build_git: $(USYS_SRC)/git/.git/$(GOTREPO)
	cd $(USYS_SRC)/git; make prefix=$(USYS)

build_all: build_libevent
build_libevent: $(USYS_SRC)/libevent/.git/$(GOTREPO)
	cd $(USYS_SRC)/libevent; ./autogen.sh
	cd $(USYS_SRC)/libevent; ./configure --disable-shared --prefix=$(USYS)
	cd $(USYS_SRC)/libevent; make
	cd $(USYS_SRC)/libevent; make install

build_all: build_ncurses
build_ncurses: $(USYS_SRC)/ncurses-5.9.tar.gz
	cd $(USYS_SRC)/ncurses-5.9; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/ncurses-5.9; make
	cd $(USYS_SRC)/ncurses-5.9; make install

build_all: build_tmux
build_tmux: build_libevent build_ncurses $(USYS_SRC)/tmux/.git/$(GOTREPO)
	cd $(USYS_SRC)/tmux; ./autogen.sh
	cd $(USYS_SRC)/tmux; \
		./configure --prefix=$(USYS) \
			CFLAGS="-I$(USYS)/include -I$(USYS)/include/ncurses" \
			LDFLAGS="-L$(USYS)/lib -L$(USYS)/include/ncurses -L$(USYS)/include"
	cd $(USYS_SRC)/tmux; \
		CPPFLAGS="-I$(USYS)/include -I$(USYS)/include/ncurses" \
			LDFLAGS="-static -L$(USYS)/include -L$(USYS)/include/ncurses -L$(USYS)/lib" \
			make

build_all: build_verilator
build_verilator: $(USYS_SRC)/verilator/.git/$(GOTREPO)
	cd $(USYS_SRC)/verilator; autoconf
	cd $(USYS_SRC)/verilator; ./configure --prefix=$(USYS)
	cd $(USYS_SRC)/verilator; make

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

git: build_git
	cd $(USYS_SRC)/git; make prefix=$(USYS) install

meld: $(USYS_SRC)/meld/.git/$(GOTREPO)
	rm -f $(USYS)/bin/meld
	cd $(USYS)/bin; ln -s $(USYS_SRC)/meld/bin/meld meld

tmux: build_tmux
	cd $(USYS_SRC)/tmux; make install

verilator: build_verilator
	cd $(USYS_SRC)/verilator; make install

# }}} install

# NOTE: tidy is not the same as a usual 'make clean'.
# This rule is just to save disk space, not to return to a known state.
# Just the build directories are removed, not the binaries.
all: tidy
tidy:
	rm -rf $(USYS_SRC)/cpython2
	rm -rf $(USYS_SRC)/cpython3
	rm -rf $(USYS_SRC)/git
	rm -rf $(USYS_SRC)/libevent
	rm -rf $(USYS_SRC)/ncurses*
	rm -rf $(USYS_SRC)/tmux
	rm -rf $(USYS_SRC)/verilator
