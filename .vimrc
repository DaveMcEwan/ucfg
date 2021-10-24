" Dave McEwan's Vim Configuration

" {{{ Set Options

set nocompatible    "Don't emulate vi's bugs.

set ff=unix
set ffs=unix,dos    " Default to unix on Windows to prevent git warnings.

set backspace=indent,start,eol

set timeoutlen=250  " Reduce the delay going from INSERT to NORMAL mode.

set autoindent
set expandtab       "Insert spaces when <Tab> is pressed.
set tabstop=2       "Number of spaces that <Tab> counts for.
set shiftwidth=2    "Indent width

set textwidth=79    "Line width to wrap at with the gq command.
set nowrap          "Disable wrapping by default

if exists('+colorcolumn') " Only versions over 7.3 support colorcolumn.
  set colorcolumn=80  "Vertical line at column 80.
endif

set showmatch       "Highlight matching bracket.
set incsearch       "Search as you type.
set hlsearch        "Use *|# search forward|back for the word under the cursor.

set mouse=a         "Use mouse everywhere
set ttymouse=xterm2 "Allow mouse with tmux

set ruler           "Show current position at the bottom.
set number          "Show line numbers.
set showcmd         "Show the command being typed.


set modelines=0
set nomodeline

set cursorline      "Highlight the current line.

set history=1000
set undolevels=1000

set directory=~/.vim/swp/
set noswapfile      "Don't make a swap file

" za  Toggle fold
" zM  Close all folds
" zR  Decrease fold level to zero (Open all folds)
" zr  Decrease fold level by one
" zm  Increase fold level by one
" [z  Move to start of fold
" z]  Move to end of fold
" zf  Fold selected lines, ignoring the folding method.
set fdm=marker      " Use marker folding by default.

let c_no_comment_fold=1 "Don't automatically fold C comments.

if has("gui_running")
  set columns=85 lines=60 "Set GUI size

  set showtabline=2

  set guioptions+=b "Horizontal scrollbar.

  set tabpagemax=20 "Max number of tabs with `gvim -p`.

  set cursorcolumn  "Highlight the current column.
endif

if !has("gui_running") " Uneeded in GUI, title bar shows info.
  set laststatus=2  " Display status line.
endif

"Netrw is the builtin file browser.
let g:netrw_liststyle=3     "Tree view.
let g:netrw_banner=0        "Hide banner in file browser.
let g:netrw_hide=1          "Use hide list above.
let g:netrw_list_hide= '.*\.git/$,.*\.svn/$'

" }}} Set Options

" {{{ Automatic Commands

"Remove trailing spaces and replaces tabs with spaces.
function! TrimWhiteSpace()
    %s/\s\+$//e
    retab
endfunction
autocmd FileWritePre    * :call TrimWhiteSpace()
autocmd FileAppendPre   * :call TrimWhiteSpace()
autocmd FilterWritePre  * :call TrimWhiteSpace()
autocmd BufWritePre     * :call TrimWhiteSpace()

"Edit binary using xxd-format with `vim -b`.
augroup Binary
  autocmd!
  autocmd BufReadPre  *.bin,*.BIN let &bin=1
  autocmd BufReadPost *.bin,*.BIN if &bin | %!xxd
  autocmd BufReadPost *.bin,*.BIN set ft=xxd | endif
  autocmd BufWritePre *.bin,*.BIN if &bin | %!xxd -r
  autocmd BufWritePre *.bin,*.BIN endif
  autocmd BufWritePost *.bin,*.BIN if &bin | %!xxd
  autocmd BufWritePost *.bin,*.BIN set nomod | endif
augroup END

"Recognise some specific file extensions
autocmd BufNewFile,BufReadPost *.v      set filetype=verilog
autocmd BufNewFile,BufReadPost *.vh     set filetype=verilog
autocmd BufNewFile,BufReadPost *.vpp    set filetype=verilog
autocmd BufNewFile,BufReadPost *.svb    set filetype=verilog_systemverilog
autocmd BufNewFile,BufReadPost *.svh    set filetype=verilog_systemverilog
autocmd BufNewFile,BufReadPost *.inc    set filetype=verilog_systemverilog
autocmd BufNewFile,BufReadPost *.vstub  set filetype=verilog
autocmd BufNewFile,BufReadPost SCons*   set filetype=python
autocmd BufNewFile,BufReadPost *.md     set filetype=markdown
autocmd BufNewFile,BufReadPost *.yml    set filetype=yaml
autocmd BufNewFile,BufReadPost *.evc    set filetype=toml
autocmd BufNewFile,BufReadPost *.toml   set filetype=toml

"Enable tabs in Makefiles.
autocmd FileType make       setlocal noexpandtab

"Python and Rust indents are recommended as 4 spaces.
autocmd FileType python     setlocal tabstop=4
autocmd FileType rust       setlocal tabstop=4

"Wrap certain formats at textwidth.
autocmd FileType c          setlocal formatoptions+=t
autocmd FileType haskell    setlocal formatoptions+=t
autocmd FileType markdown   setlocal formatoptions+=t
autocmd FileType python     setlocal formatoptions+=t
autocmd FileType rust       setlocal formatoptions+=t
autocmd FileType tex        setlocal formatoptions+=t
autocmd FileType verilog    setlocal formatoptions-=t

""Automatically save the folds view
"autocmd BufWinLeave * mkview
"autocmd BufWinEnter * silent loadview

" }}} Automatic Commands

syntax on
filetype on
colorscheme dmcewan

" {{{ Map Keys (features)

"Copy to system clipboard.
"   Can't be Ctrl+C because that's the shortcut for closing a process.
vnoremap  <C-y> "+y

"Paste from system clipboard.
"   Can't be Ctrl+V because that's the shortcut for block select.
vnoremap  <C-p> "+p

"Open the current directory as a file browser.
"   Also disables the annoying help window.
nnoremap <F1> :tabe %<CR>:E<CR>
nnoremap <F2> :E<CR>

"List buffers and give option to choose.
nnoremap <F3> :buffers<CR>:buffer<Space>

"Git interface in new tab
nnoremap <F4> :tabnew<CR>:MagitOnly<CR>

"SVN commands using vcscommand plugin.
nnoremap <F7> :VCSDiff
nnoremap <F8> :VCSVimDiff
nnoremap <F9> :VCSAnnotate

"Search for word under cursor in all files in current directory.
"   On mcdox keyboard this uses the same button as * (shift+8) which searches
"   current file.
nnoremap <F10> :execute " grep -Hnr --exclude-dir=.git " . expand("<cword>") . " ." <CR>

"Use the % key to jump to matching bracket (Shift+5).
noremap % v%

"Count the occurrences of highlighted term.
nnoremap <Leader>hc :%s///gn

"Cursor line and column toggle.
nnoremap <Leader>cl :set cursorline!
nnoremap <Leader>cc :set cursorcolumn!

"Toggle wrapping.
nnoremap <Leader>w :set nowrap!

"Hex mode editing using the external tool xxd to filter the buffer.
"   '\xx' Show/edit file in hex format.
"   '\xa' Return file to normal editing mode by using xxd reverse mode to patch
"         the buffer before write.
"   g1 - groupsize (bytes)
"   c1 - columns
nnoremap <Leader>xx :%!xxd -g1 -c4
nnoremap <Leader>xa :%!xxd -r -g1 -c4

"Switch syntax highlighting.
nnoremap <Leader>sv :set syn=verilog_systemverilog
nnoremap <Leader>sp :set syn=python
nnoremap <Leader>sx :set syn=xml
nnoremap <Leader>sc :set syn=c
nnoremap <Leader>sm :set syn=markdown
nnoremap <Leader>sy :set syn=yaml
nnoremap <Leader>st :if exists("g:syntax_on") <Bar> syntax off <Bar>
  \else <Bar> syntax enable <Bar>
  \endif

"Switch folding method.
nnoremap <Leader>fk :set fdm=manual
nnoremap <Leader>fm :set fdm=marker
nnoremap <Leader>fs :set fdm=syntax
nnoremap <Leader>fi :set fdm=indent
nnoremap <Leader>fn :set nofoldenable

"Press Space to turn off highlighting and clear any message already displayed.
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" }}} Map Keys (features)

" {{{ Map Keys (workarounds)

"Make it hard to enter Ex mode.
nnoremap Q <Nop>

"Often mistyping :W instead of :w, except this doesn't call TrimWhiteSpace.
command! W noautocmd w

"Unknown keycodes issue with tmux.
noremap <S-Left> <Nop>
"unmap <S-Up>
"unmap <S-Right>
"unmap <S-Down>

" }}} Map Keys (workarounds)

