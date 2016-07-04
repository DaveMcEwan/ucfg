set nocompatible "Don't emulate vi's bugs
set ff=unix
set backspace=indent,start,eol

" Reduce the delay going from INSERT to NORMAL mode.
set timeoutlen=250

" Make it hard to enter Ex mode, which I find annoying.
nnoremap Q <nop>

" Map common keyboard shortcuts
" Save
" Ctrl+S
map  <C-s> :w!<cr>
imap <C-s> <Esc>:w!<cr>

" Copy to system clipboard.
" This can't be Ctrl+C since that is the shortcut for closing a process.
" Ctrl+Y
map  <C-y> "+y
imap <C-y> <esc>"+y

" Paste from system clipboard.
" This can't be Ctrl+V since that is the shortcut for block select.
" Ctrl+P
map  <C-p> "+p
imap <C-p> <esc>"+p


" Open the current directory as a file browser.
" This also disables the annoying help windows from opening.
let g:netrw_liststyle=3     " Use tree view.
let g:netrw_banner=0        " Hide banner in file browser.
let g:netrw_list_hide= '.svn/$'
let g:netrw_hide=1          " Use hide list above.
nnoremap <F1> :tabe %<cr>:E<cr>
nnoremap <F2> :E<cr>

" Go back to the last buffer.
" Useful when you accidentally press <F1>
nnoremap <F3> :b#<cr>

" List buffers and give option to choose.
nnoremap <F5> :buffers<cr>:buffer<space>

" Search for verilog errors.
nnoremap <F6> /*E<cr>

" SVN commands using vcscommand plugin.
nnoremap <F7> :VCSDiff
nnoremap <F8> :VCSVimDiff
nnoremap <F9> :VCSAnnotate

" Search for word under cursor in all files in current directory.
" Uses same button as shift+8 for asterisk which searches current file.
nnoremap <F10> :execute " grep -Hnr --exclude-dir=.svn " . expand("<cword>") . " ." <cr>

set autoindent      "Autoindent
set expandtab       "Use spaces instead of tabs
set tabstop=4       "Use 4-space tabs
set shiftwidth=4    "indent width
set textwidth=80    "Line width to wrap at with the gq command.

" Enable tabs in makefiles
autocmd FileType make setlocal noexpandtab

" Removes trailing spaces and replaces tabs with spaces.
" This is called on write.
function! TrimWhiteSpace()
    %s/\s\+$//e
    retab
endfunction
autocmd FileWritePre    * :call TrimWhiteSpace()
autocmd FileAppendPre   * :call TrimWhiteSpace()
autocmd FilterWritePre  * :call TrimWhiteSpace()
autocmd BufWritePre     * :call TrimWhiteSpace()

set showmatch       "Highlight matching bracket
"Use the % key to jump to matching bracket
noremap % v%
set incsearch       "Search as you type
"Highlight search matches.
" Use '*' or '#' search forward/back for the word under the cursor.
set hls
" Use \hc to count the occurrences of highlighted term.
map <Leader>hc :%s///gn

set ruler           "Always show the current position at the bottom
set mouse=a         "Use mouse everywhere

set number          "Show line numbers
set showcmd         "Show the command being typed

set noswapfile      "Don't make a swap file

" Cursor line and column on by default. Toggle with '\cl' '\cc'.
set cursorline                              "Highlight the current line
if has("gui_running")
    set cursorcolumn                        "Highlight the current column
endif
map <Leader>cl :set cursorline!
map <Leader>cc :set cursorcolumn!

" Disable wrapping by default
set nowrap
map <Leader>w :set nowrap!

" Hex mode editing using the external tool xxd to filter the buffer.
" '\xx' Show/edit file in hex format.
" '\xa' Return file to normal editing mode by using xxd reverse mode to patch
"         the buffer before write.
map <Leader>xx :%!xxd -g1
map <Leader>xa :%!xxd -r

" Syntax highlighting and colourscheme {{{

syntax on           "Highlight syntax
filetype on

" Recognise some specific file extensions
au BufNewFile,BufRead *.vpp set filetype=verilog
au BufNewFile,BufRead *.svb set filetype=verilog_systemverilog
au BufNewFile,BufRead *.svh set filetype=verilog_systemverilog
au BufNewFile,BufRead *.inc set filetype=verilog_systemverilog
au BufNewFile,BufRead *.vstub set filetype=verilog
autocmd FileType verilog setlocal formatoptions-=t
au BufNewFile,BufRead SCons* set filetype=python
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.yml set filetype=yaml

" Enable switching syntax highlighting with quick shortcuts
" '\sv' Verilog
" '\sp' Python
" '\sx' XML
" '\sc' C
" '\st' Toggle syntax highlighting on/off
map <Leader>sv :set syn=verilog_systemverilog
map <Leader>sp :set syn=python
map <Leader>sx :set syn=xml
map <Leader>sc :set syn=c
map <Leader>sm :set syn=markdown
map <Leader>sy :set syn=yaml
map <Leader>st :if exists("g:syntax_on") <Bar> syntax off <Bar>
               \else <Bar> syntax enable <Bar>
               \endif

"" Make it obvious when lines go over 80 columns.
if exists('+colorcolumn')
    " Only versions over 7.3 support colorcolumn.
    set colorcolumn=80
endif

" }}} End of Syntax highlighting and colourscheme

" Folding {{{

" Use marker folding by default. Must be in normal mode.
" 'za'  Toggle fold
" 'zM'  Close all folds
" 'zR'  Decrease fold level to zero (Open all folds)
" 'zr'  Decrease fold level by one
" 'zm'  Increase fold level by one
" '[z'  Move to start of fold
" 'z]'  Move to end of fold
" 'zf'  Fold selected lines. This doesn't care about the folding method.
set fdm=marker

" Enable switching folding method with quick shortcuts
" '\fk' manual
" '\fm' marker
" '\fs' syntax
" '\fi' indent
" '\fn' none
map <Leader>fk :set fdm=manual
map <Leader>fm :set fdm=marker
map <Leader>fs :set fdm=syntax
map <Leader>fi :set fdm=indent
map <Leader>fn :set nofoldenable

" Don't automatically fold C comments.
let c_no_comment_fold = 1

"" Automatically save the folds view
"au BufWinLeave * mkview
"au BufWinEnter * silent loadview

" }}} End of Folding

set history=1000
set undolevels=1000

set directory=~/.vim/swp/

colorscheme elflord
if has("gui_running")
    set columns=85 lines=60
endif

if has("gui_running")
    set showtabline=2

    " Show horizontal scrollbar.
    set guioptions+=b

    "Max number of tabs gvim opens with the -p option.
    set tabpagemax=20
endif

if !has("gui_running")
    " Always display the status line in terminal.
    " This isn't needed in gui since the title bar shows info.
    set laststatus=2
endif


