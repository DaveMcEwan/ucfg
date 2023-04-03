
alias v='vim -p'
alias g="grep -Hn --color"
alias l="ls -l"
alias d='diff -w -U0'
alias p='patch -p0 -i'

alias display="export DISPLAY=cad11:10"

# Start tkdiff without all the warnings on the term.
start_tkdiff() { tkdiff "$@" 2> /dev/null; }
alias t='start_tkdiff'

# Start gvim without all the warnings on the term.
start_gvim() { gvim "$@" 2> /dev/null; }
alias vX="vim -u ~/.vimXrc -x"
alias w='start_gvim'

alias encrypt="openssl enc -e -md sha256 -bf-cbc -a -salt -in"
alias decrypt="openssl enc -d -md sha256 -bf-cbc -a -in"

# Print a specific line from a file.
printline_() { sed -n -e "$1{p;q;}" "$2"; }
alias printline="printline_"

# git shortcuts
alias gitac="git commit -a -m"

