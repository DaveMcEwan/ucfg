
alias v='vim -p'
alias g="grep -Hn --color"
alias l="ls -l"
alias d='diff -w -U0'
alias p='patch -p0 -i'

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

# Webcam snapshot
alias cam="ffmpeg -i /dev/video0 -ss 0:0:1 -frames 1 ~/cam.png -y"

# Lynx Markdown viewer
alias r="pandoc -t html README.md | lynx -stdin"

alias ust_new="svn co https://code.eng.ultrasoc.com/svn/Silicon/trunk/ ."
alias corrdemo0_new="svn co https://code.eng.ultrasoc.com/svn/Silicon/branches/corrdemo0 ."
alias software_new="svn co https://code.eng.ultrasoc.com/svn/software/trunk ."

# SVN status
alias s='svn st `pwd` | grep -P "^\w{1}" | sed "s@$WK@\$WK@"'

# Create a named diff/patch like `mkdiff foo`.
mkdiff() {
  FNAME="$WK/diff/$1.`date +%Y_%m_%d_%H_%M_%S`.diff"
  svn info . > $FNAME
  svn diff . >> $FNAME
}

