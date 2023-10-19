
# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
#
# Invoked as an interactive login shell, or with --login
# ------------------------------------------------------
# When Bash is invoked as an interactive login shell, or as a non-interactive
# shell with the --login option, it first reads and executes commands from the
# file /etc/profile, if that file exists. After reading that file, it looks for
# ~/.bash_profile, ~/.bash_login, and ~/.profile, in that order, and reads and
# executes commands from the first one that exists and is readable. The
# --noprofile option may be used when the shell is started to inhibit this
# behavior.

#export DBG_THIS=yes # Uncomment this line to show sequence of startup scripts.
export _DBG_SHSTARTUP=${DBG_THIS}${_DBG_SHSTARTUP} # Don't uncomment this line.
[ ! -z "${_DBG_SHSTARTUP}" ] && echo "Entering <ucfg>/.bash_profile"

if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

[ ! -z "${_DBG_SHSTARTUP}" ] && echo "Exiting <ucfg>/.bash_profile"
