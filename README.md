ucfg
====
Userland Configuration management using make and git.

There are 3 make rules:

  - put
  - unput
  - get

Using these rules you can easily setup your config files, and using git you can
manage the changes however you like.

put 
---
Put configuration files from ucfg repository into `$HOME`

First, copy all affected files/dirs to `$BACKUP_DIR`; Then, replace affected
files/dirs with symlinks to the equivilent files/dirs in the repository.

When the ucfg repository is updated to get new versions of files/dirs, you may
need to rerun `make put` to add any new files.

unput
-----
Restore configuration files from a previous `put`

When `make put` is run, affected files are copied to a backup directory,
defaulting to `$HOME/.ucfg.bk` in the original hierarchy.
This copies the files from there back to their original location.

get
---
Copy existing config files/dirs from `$HOME` to the ucfg repository

The list of files/dirs to copy is the same as the equivilent files/dirs in the
repository.

