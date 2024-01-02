# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
#
# Invoked as an interactive non-login shell
# -----------------------------------------
#
# When an interactive shell that is not a login shell is started, Bash reads and
# executes commands from ~/.bashrc, if that file exists. This may be inhibited by
# using the --norc option. The --rcfile file option will force Bash to read and
# execute commands from file instead of ~/.bashrc.
#
# So, typically, your ~/.bash_profile contains the line
#   if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
# after (or before) any login-specific initializations.

#export DBG_THIS=yes # Uncomment this line to show sequence of startup scripts.
export _DBG_SHSTARTUP=${DBG_THIS}${_DBG_SHSTARTUP} # Don't uncomment this line.
[ ! -z "${_DBG_SHSTARTUP}" ] && echo "Entering <ucfg>/.bashrc"

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
  . /etc/bash.bashrc
fi

# If not running interactively, do nothing
case $- in
  *i*) ;;
  *) return;;
esac

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html

# If set, a command name that is the name of a directory is executed as if it
# were the argument to the cd command. This option is only used by interactive
# shells.
shopt -s autocd

# If set, minor errors in the spelling of a directory component in a cd command
# will be corrected. The errors checked for are transposed characters, a
# missing character, and a character too many. If a correction is found, the
# corrected path is printed, and the command proceeds. This option is only used
# by interactive shells.
shopt -s cdspell

# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

# If set, Bash replaces directory names with the results of word expansion when
# performing filename completion. This changes the contents of the readline
# editing buffer. If not set, Bash attempts to preserve what the user typed.
shopt -s direxpand

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Append to the history file, don't overwrite it
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Disable software flow control (XOFF/Ctrl-s, XON/Ctrl-q).
stty -ixon

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# Set prompt to hostname and basename of pwd.
# https://www.gnu.org/software/bash/manual/bash.html#Controlling-the-Prompt
# [blue] <time> <hostname> <basename of $PWD> [yellow] <dollar/hash> [default color]
#PS1='\[\e[0;44m\]\t \h \W\[\e[m\]\[\e[1;32m\]\$\[\e[m\]'
# Hostname is unnecessary on home desktop.
PS1='\[\e[0;44m\]\t \W\[\e[m\]\[\e[1;32m\]\$\[\e[m\]'


# Produce a GUI popup and append the previous command to the desktop area for
# notifications.
# The utility `notify-send` is part of GNOME's libnotify.
#  <https://gitlab.gnome.org/GNOME/libnotify>
# To get a notification at the end of a long-running command:
#   sleep 10; alert
# To get a notification about a non-zero exit code:
#   false || alert
alias alert='notify-send -u low "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/\s*[;&|]\+\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

export VISUAL=vim
export EDITOR=vim

export GIT_EDITOR=vim
export GIT_PAGER=cat

d=~/.dircolors
test -r $d && eval "$(dircolors $d)"

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Enable environment modules.
# This is the same snippet prepended by `/usr/bin/add.modules`.
case "$0" in
  -sh|sh|*/sh)        modules_shell=sh ;;
  -ksh|ksh|*/ksh)     modules_shell=ksh ;;
  -zsh|zsh|*/zsh)     modules_shell=zsh ;;
  -bash|bash|*/bash)  modules_shell=bash ;;
esac
#module() { eval `/usr/bin/tclsh8.6 /usr/lib/x86_64-linux-gnu/modulecmd.tcl $modules_shell $*`; }

setup_codasip() {
  export PATH="/usr/share/Modules/bin:$PATH"

  # https://codasip.atlassian.net/wiki/spaces/WIKI/pages/271974495/Codasip+License+Server+LMX
  export LMX_LICENSE_PATH="license-server.codasip.com%6200"
}
setup_codasip

setup_dmsv() {
  export THIS="${HOME}/dmsv"
  module use "${THIS}/tools/modulefiles"
  module -s unload dmsv
  module -s load dmsv
  alias tclsh='rlwrap tclsh'
}
#setup_dmsv

setup_ust() {
  export WK="/ust/work/damcewan"
  export UST_SW_TREE="$WK/software"

  source /ust/tools/ust/default/bashrc
  module load tmux
  module load vim
  module load binutils
  module load gcc
}

setup_no() {
  export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

  module load gnutools/gcc6.3.0
  export LD_LIBRARY_PATH="/cad/gnu/gcc/6.3.0/lib64:$LD_LIBRARY_PATH"
  export VERILATOR_ROOT="$HOME/verilator"
}
#setup_no

setup_py() {
  #module load python3.7
  #source $WK/venv3.7/bin/activate
  source $HOME/dmppl/venv3.7/bin/activate
}
#setup_py

setup_rust() {
  source "$HOME/.cargo/env"
}
#setup_rust

setup_arduino() {
  export PATH="$HOME/local/arduino-1.8.15:$PATH"
}

setup_cuda() {
  export CUDA_HOME="/usr/local/cuda"
  export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
}

setup_vivado_2017_3() {
  source ~/.bashrc
  source /space/xilinx/Vivado/2017.3/settings64.sh
}

setup_vivado_2016_4() {
  source ~/.bashrc
  source /space/xilinx/Vivado/2016.4/settings64.sh
}

setup_diamond_3_11() {
  source ~/.bashrc
  PREFIX="/usr/local/diamond/3.11_x64"
  BINARCH="bin/lin64"

  export TEMP="/tmp"
  export LSC_INI_PATH=""
  export LSC_DIAMOND=true
  export TCL_LIBRARY="$PREFIX/tcltk/lib/tcl8.5"
  export FOUNDRY="$PREFIX/ispfpga"

  export PATH="$FOUNDRY/$BINARCH:$PREFIX/$BINARCH:$PATH"
}

setup_icecube2_2017_08() {
  # https://github.com/SymbiFlow/fpga-tool-perf/blob/master/icecubed.sh
  source ~/.bashrc
  ICECUBEDIR="/space/lattice/lscc/iCEcube2.2017.08"
  BINARCH="bin/lin64"

  export FOUNDRY="$ICECUBEDIR/LSE"
  export SBT_DIR="$ICECUBEDIR/sbt_backend"
  export SYNPLIFY_PATH="$ICECUBEDIR/synpbase"
  export TCL_LIBRARY="$SBT_DIR/bin/linux/lib/tcl8.4"

  export LM_LICENSE_FILE="/space/lattice/license.dat"

  LD_LIBRARY_PATH=""
  export LD_LIBRARY_PATH="$ICECUBEDIR/LSE/bin$BINARCH:$LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH="$SBT_DIR/lib/linux/opt:$LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH="$SBT_DIR/bin/linux/opt/synpwrap:$LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH="$SBT_DIR/bin/linux/opt:$LD_LIBRARY_PATH"

  export PATH="$ICECUBEDIR:$ICECUBEDIR/LSE/$BINARCH:$PATH"
}

[ ! -z "${_DBG_SHSTARTUP}" ] && echo "Exiting <ucfg>/.bashrc"
