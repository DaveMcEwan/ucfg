ucfg
====
Userland Configuration management using make and git.

There are 5 make rules:

  - list
  - backup
  - restore
  - put
  - get

Using these rules you can easily setup your config files, and using git you can
manage the changes however you like.
This makefile should never depend on more than make and coreutils.

list
-----
List affected files.

The list of files/dirs is the same as the equivilent files/dirs in the
repository.

backup
-----
Affected files are copied to a backup directory, defaulting to `$HOME/.ucfg.bk`
in the original hierarchy.

restore
-----
Restore configuration files from a previous `make backup` or `make put` from
the backup directory to `$HOME`
This copies the files from there back to their original location.

put 
---
Put configuration files from ucfg repository into `$HOME`

First, backup all affected files/dirs to `$BACKUP_DIR`; Then, replace affected
files/dirs with symlinks to the equivilent files/dirs in the repository.

When the ucfg repository is updated to get new versions of files/dirs, you may
need to rerun `make put` to add any new files.

get
---
Copy existing config files/dirs from `$HOME` to the ucfg repository.
Git may then be used to track changes.

