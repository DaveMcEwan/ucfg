
# Start tkdiff without all the warnings on the term.
start_tkdiff() { tkdiff "$@" 2> /dev/null; }
alias t='start_tkdiff'

alias v='vim'
alias vX="vim -u ~/.vimXrc -x"

# Start gvim without all the warnings on the term.
start_gvim() { gvim "$@" 2> /dev/null; }
alias w='start_gvim'

alias encrypt="openssl enc -bf-cbc -a -salt -in"
alias decrypt="openssl enc -d -bf-cbc -a -in"

alias g="grep -Hn --color"

# Print a specific line from a file.
printline_() { sed -n -e "$1{p;q;}" "$2"; }
alias printline="printline_"

# git shortcuts
alias gitac="git commit -a -m"
