set nocompatible
filetype off

" Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'scrooloose/nerdtree'
Plugin 'guns/xterm-color-table.vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'jiangmiao/auto-pairs'

call vundle#end()

filetype plugin indent on

set nu
set rnu
set hls
set ai
set tabstop=4
set softtabstop=4
set shiftwidth=4
set scrolloff=10
set expandtab
set cursorline
set showcmd
set wildmenu
set wildmode=longest:full,full
set colorcolumn=90,120

" Key mappings
inoremap jj <ESC>
inoremap jo <ESC>o
inoremap jO <ESC>O
inoremap jl <ESC>la
inoremap jh <ESC>ha
inoremap #re# #region<SPACE><ESC>2o<ESC>a#endregion<ESC>2kA

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <expr> %% getcmdtype() == ":" ? expand('%:h').'/' : '%%'

"noremap <expr> k (v:count == 0 ? 'gk' : 'k')
"noremap <expr> j (v:count == 0 ? 'gj' : 'j')

" Function key mappings
nnoremap <expr> <F3> ":set nu! rnu!\n"
nnoremap <expr> <F4> (v:hlsearch ? ':nohls' : ':set hls')."\n"
map <F5> :NERDTreeToggle<CR>

" Syntax setting
set bg=dark
hi LineNr cterm=bold ctermfg=DarkGrey ctermbg=NONE
hi CursorLineNr cterm=bold ctermfg=Grey ctermbg=NONE
hi String ctermfg=177
hi Comment ctermfg=76
hi Identifier ctermfg=75
hi Number ctermfg=Red
hi Normal ctermfg=White
hi DiffAdd ctermbg=30
hi DiffChange ctermbg=25
hi DiffDelete ctermbg=52
hi DiffText cterm=none ctermbg=33
hi ColorColumn ctermbg=238

" Windows setting
set t_Co=256
scriptencoding utf-8
set encoding=utf-8

" Virtual whitespaces
set list
set listchars=tab:\|·,trail:·
hi Whitespace_leading ctermfg=DarkGrey
hi Whitespace_trailing ctermfg=White ctermbg=Red
match Whitespace_leading /^\s\+/
2match Whitespace_trailing /\s\+$/
au BufWinEnter * match Whitespace_leading /^\s\+/
au BufWinEnter * 2match Whitespace_trailing /\s\+$/

filetype plugin on
filetype indent on

" Python highlight
"au filetype python setlocal noexpandtab
let python_highlight_all=1

" Html tag autocomplete
au BufRead,BufNewFile *.html,*.js,*.xml inoremap <lt>/ </<C-x><C-o><Esc>==gi

