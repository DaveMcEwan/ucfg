# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
        . /etc/bash.bashrc
fi

# If not running interactively, do nothing
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# Set prompt to  hostname and basename of pwd.
PS1='\h:\W$ '


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export VISUAL=vim
export EDITOR=vim

PATH="$HOME/bin:/usr/local/bin:/usr/bin:/bin"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/ucfg/usys/bin:$PATH"
PATH="$HOME/dmpvl/tools/bin:$PATH"
export PATH="$PATH"

setup_ust() {
  export WK="/ust/work/damcewan"
  export UST_SW_TREE="$WK/software"

  source /ust/tools/ust/default/bashrc
  module load tmux
  module load vim
  module load binutils
  module load gcc
}

setup_py() {
  module load python3.7
  source $WK/venv3.7/bin/activate
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

  export PATH="$PREFIX:$PREFIX/LSE/$BINARCH:$PATH"
}
