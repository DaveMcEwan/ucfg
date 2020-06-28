" Vim color file
" Documentation for this file at http://vimdoc.sourceforge.net/htmldoc/syntax.html
" vim: tw=0 ts=4 sw=4
" Maintainer:   dmcewan
" Last Change:  2015-04-27

" TODO
hi clear
set background=dark
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "dmcewan"

" Defaults
hi Normal                           ctermbg=Black       ctermfg=LightGray   guibg=Black     guifg=LightGray

" Major groups
hi Comment                          ctermfg=LightRed                                        guifg=LightRed
hi Constant     term=underline      ctermfg=LightGreen                                      guifg=White         gui=NONE
hi Identifier   term=underline      ctermfg=LightCyan                                       guifg=#00ffff
hi Statement    term=bold           ctermfg=Yellow                                          guifg=#ffff00       gui=NONE
hi PreProc      term=underline      ctermfg=LightBlue                                       guifg=Wheat
hi Type                             ctermfg=LightGreen                                      guifg=Grey          gui=NONE
hi Special      term=bold           ctermfg=LightRed                                        guifg=Magenta
hi Error        term=reverse        ctermfg=White       ctermbg=Red         guibg=Red       guifg=White
hi Todo                             ctermfg=White       ctermbg=LightBlue   guibg=Yellow    guifg=Blue

hi Cursor                           ctermfg=Black       ctermbg=White       guibg=fg        guifg=Orchid
hi Directory    term=bold           ctermfg=LightCyan                                       guifg=Cyan
hi Ignore                           ctermfg=Black                                           guifg=bg
hi IncSearch    term=reverse        cterm=reverse                                                               gui=reverse
hi LineNr       term=underline      ctermfg=Yellow                                          guifg=Yellow
hi MatchParen                       ctermfg=Black       ctermbg=DarkGreen   guibg=DarkGreen guifg=White         gui=NONE
hi ModeMsg      term=bold           cterm=bold                                                                  gui=bold
hi MoreMsg      term=bold           ctermfg=LightGreen                                      guifg=SeaGreen      gui=bold
hi NonText      term=bold           ctermfg=Blue                                            guifg=Blue          gui=bold
hi Question     term=standout       ctermfg=LightGreen                                      guifg=Cyan          gui=bold
hi Visual                           ctermfg=White       ctermbg=DarkGreen   guibg=DarkGreen guifg=White         gui=NONE

" Special characters which are displayed differently from what they really are.
hi SpecialKey   term=bold           ctermfg=LightBlue                                       guifg=Cyan

" Last search pattern highlighting with 'hlsearch'.
hi Search                           ctermfg=White       ctermbg=Blue        guibg=Blue      guifg=White

" Status lines windows, and NC is non-current windows.
hi StatusLine   term=reverse,bold   cterm=reverse                           guibg=DarkBlue  guifg=White         gui=NONE
hi StatusLineNC term=reverse        cterm=reverse                           guibg=#333333   guifg=White         gui=NONE

hi Title        term=bold           ctermfg=LightMagenta                                    guifg=Pink          gui=bold

hi ErrorMsg     term=standout       ctermbg=DarkRed     ctermfg=White       guibg=Red       guifg=White
hi WarningMsg   term=standout       ctermfg=LightRed                                        guifg=Red

