"==========================================
"General
"==========================================
set title
set number
set ruler
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set backspace=indent,eol,start
set guioptions+=a
set display=lastline
set showmatch
set noswapfile

set nowritebackup
set nobackup
set clipboard+=unnamed,autoselect
set mouse=a
set ttymouse=xterm2

set noignorecase
set wrapscan
set incsearch
set hlsearch
set wildmenu "
set history=1000
set wildmode=list,full

set nocompatible
filetype plugin indent off

"==========================================
" Vim-plug
"==========================================
" Download & Install if needed
if has('win32') || has('win64')
  if empty(glob('vimfiles\autoload\plug.vim'))
    silent !curl -fLo vimfiles\autoload\plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
else " linux
  if empty(glob('$HOME/.vim/autoload/plug.vim'))
    silent !curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif

" PlugInstall if needed
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Plugin List
call plug#begin()

call plug#end()

"==========================================
"Color
"==========================================
"set t_Co=256
set termguicolors
syntax enable
set background=dark
"syntax on
