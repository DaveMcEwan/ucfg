# Userland Configurator
# Dave McEwan
#
# Easily manage user configurations across unix machines with make and git.
#
# For all make rules the list of paths to apply to is simply ./* excepting
# this Makefile, the .git repository, and the README.md.
# The $UCFG prefix is removed from every path to give a list of relative paths
# which refer the same path under both $HOME and $CFG.
# In other words, if you want something to be picked up by 'make get' from
# $HOME/somewhere then you need a file at $UCFG/somewhere - an empty file will
# be enough.
# This is now referred to as $PATHS.
#
# This directory ($UCFG) should have the same structure as your home directory.
# When running 'make put' all files/directories in $HOME with the same relative
# paths as those in $UCFG are copied to $HOME/.ucfg.bk, then replaced with
# softlinks to the equivilent in $UCFG.
# Running 'make restore' restores the structure under $HOME/.ucfg.bk to $HOME.
#
# When running 'make get' all the files in $HOME/{$PATHS} are copied to
# $UCFG/{$PATHS} - That is all.
# You can then use git to diff/store/manage this however you like.
#
# UCFG should not depend on more then coreutils+git.

# The backup directory name is based on the name of this directory to allow
# forks of this project to work interoperably with minimal effort.
# NOTE: Cannot use with 'make -C'
SELF := $(PWD)
SELF_NAME := $(shell basename $(SELF))
BACKUP_DIR := $(HOME)/.$(SELF_NAME).bk

PRINT_PREFIX := ===

# These files are special to ucfg so are okay to hardcode in.
IGNORE := Makefile
IGNORE += .git
IGNORE += .gitignore
IGNORE += LICENSE
IGNORE += README.md

PATHS := $(shell ls -A $(addprefix --ignore ,$(IGNORE)))
RESTORE_PATHS := $(shell ls -A $(BACKUP_DIR))

.PHONY: list
list:
	@echo $(PRINT_PREFIX) Paths:
	@$(foreach p,$(PATHS),ls -ld $p;)
#	@echo $(PRINT_PREFIX) Ignore:
#	@$(foreach i,$(IGNORE),echo $i;)

.PHONY: backup
backup:
	@echo $(PRINT_PREFIX) Backup: $(BACKUP_DIR)
	rm -rf $(BACKUP_DIR)
	mkdir -p $(BACKUP_DIR)
	-$(foreach p,$(PATHS),cp -r $(HOME)/$p $(BACKUP_DIR)/$p;)

.PHONY: restore
restore:
	@echo $(PRINT_PREFIX) Restore: $(BACKUP_DIR)
	@$(foreach p,$(RESTORE_PATHS),ls -ld $(BACKUP_DIR)/$p; cp -r $(BACKUP_DIR)/$p $(HOME)/$p;)

.PHONY: put
put: list backup
	@echo $(PRINT_PREFIX) Linking: $(SELF)
	cd $(HOME); $(foreach p,$(PATHS),rm -rf $p; ln -s $(SELF)/$p $p;)

.PHONY: get
get:
	@echo $(PRINT_PREFIX) Copying: $(HOME)
	$(foreach p,$(PATHS),ls -ld $(HOME)/$p; cp -r $(shell readlink -e $(HOME)/$p) $(SELF)/$p;)

