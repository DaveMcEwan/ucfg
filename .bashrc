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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# Set prompt to  hostname and basename of pwd.
# https://www.gnu.org/software/bash/manual/bash.html#Controlling-the-Prompt
# [blue] <time> <hostname> <basename of $PWD> [yellow] <dollar/hash> [default color]
PS1='\[\e[0;44m\]\t \h \W\[\e[m\]\[\e[1;32m\]\$\[\e[m\]'
# Hostname is unnecessary on home desktop.
#PS1='\[\e[0;44m\]\t \W\[\e[m\]\[\e[1;32m\]\$\[\e[m\]'


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

d=~/.dircolors
test -r $d && eval "$(dircolors $d)"

export PATH="$HOME/bin:/usr/local/bin:/usr/bin:/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH=$HOME/dogit:$PATH

export ModuleFiles2=1
source /cad/gnu/modules/modules-tcl/init/bash
export MODULERCFILE="~/dotfiles/modulerc"
module use /cad/gnu/modules/modulefiles    # FIXME: Remove as soon as all active projects use modulefiles2.0
module load common_setup misctools/grid-engine
module load misctools/anaconda/3-4.3.0
module load misctools/git/2.19.1

setup_rust() {
  #export CARGO_HOME="/work/damc/.cargo"
  #export RUSTUP_HOME="/work/damc/.rustup"
  #export CARGO_HOME="/pro/sag_research/tools/damc/.cargo"
  #export RUSTUP_HOME="/pro/sag_research/tools/damc/.rustup"
  export CARGO_HOME="/pro/sig_research/dddTools/work/damc/cargo"
  export RUSTUP_HOME="/pro/sig_research/dddTools/work/damc/rustup"
  source "$CARGO_HOME/env"
}

setup_py() {
  # NOTE: Direct PATH to interpreter is only required to create venv.
  #export PATH="/work/$USER/cpython-interpreters/bin:$PATH"

  source /work/$USER/cpython-venvs/venv3.10/bin/activate
}

setup_no() {

  module use --append /pro/sig_research/dddTools/modulefiles
  module load DDD


  # Loaded by DDD verilator's module.
  #module load misctools/gcc/gcc8.5.0

  # Older misctools/gcc/ modules didn't update LD_LIBRARY_PATH
  #export LD_LIBRARY_PATH="/cad/gnu/gcc/6.3.0/lib64:$LD_LIBRARY_PATH"

  export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"
  #export LD_RUN_PATH="$HOME/.local/lib:$LD_RUN_PATH"

  # NOTE: Just for building tmux.
  #export PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig

  export DISPLAY="cad11.nordicsemi.no:10"

  export CDPATH="."
  export CDPATH="$CDPATH:/pro/sig_research/dddTools/work/damc/"
  export CDPATH="$CDPATH:/pro/haltium4460/work/damc/"
  export CDPATH="$CDPATH:/pro/moonlight4503/work/damc/"
}

setup_riscv() {
  # https://github.com/riscv-software-src/riscv-isa-sim
  # https://www.embecosm.com/resources/tool-chain-downloads/

  # NOTE: Add other compiler options here.
  #RISCV_COMPILER="riscv32-embecosm-clang-centos7-20211212"
  RISCV_COMPILER="riscv32-embecosm-gcc-centos7-20211212"

  export PATH="/work/$USER/riscv-compilers/$RISCV_COMPILER/bin:$PATH"
  export RISCV="/work/$USER/riscv-compilers/$RISCV_COMPILER"

  # NOTE: Spike relies on DTC.
  export PATH="/work/$USER/dtc/bin:$PATH"
}

setup_rust
#setup_py
#setup_riscv
setup_no
