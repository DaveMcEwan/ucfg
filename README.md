ucfg
====
Userland Configuration management using make and git

There are 3 make rules:
    1. put
    2. unput
    3. get


put - Put configuration files from ucfg repository into `$HOME`
---------------------------------------------------------------
First, copy all affected files/dirs to $BACKUP\_DIR; Then, replace affected
files/dirs with symlinks to the equivilent files/dirs under $UCFG.

When the ucfg repository is updated to get new versions of files/dirs, you may
need to rerun 'make put' to add any new files.

unput - Restore configuration files from a previous `put`
---------------------------------------------------------
When 'make put' is run, affected files are copied to a backup directory,
defaulting to `~/.ucfg.bk` in the original hierarchy.
This copies the files from there back to their original location.

get - Copy existing config files/dirs from `$HOME` to the ucfg repository
-------------------------------------------------------------------------
The list of files/dirs to copy is the same as the equivilent files/dirs in the
repository.

