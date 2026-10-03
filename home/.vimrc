" ==========================================
" General
" ==========================================
set title
set number
set ruler
set showmatch
set display=lastline

set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set backspace=indent,eol,start

set incsearch
set hlsearch
set wrapscan
set ignorecase
set smartcase

set wildmenu
set wildmode=list,full
set history=1000

set mouse=a
set noswapfile
set nobackup
set nowritebackup
set hidden
set undofile

" clipboard
if has('unnamedplus')
  set clipboard=unnamedplus
elseif has('clipboard')
  set clipboard=unnamed
endif

" ==========================================
" UI / Color
" ==========================================
set background=dark

if has('termguicolors')
  set termguicolors
endif

syntax enable
filetype plugin indent on

"==========================================
" vim-plug (auto-install on start; Windows: ~/vimfiles, WSL/Linux: ~/.vim)
"==========================================
let s:vimdir = (has('win32') || has('win64')) ? '~/vimfiles' : '~/.vim'
let s:plug_path = expand(s:vimdir . '/autoload/plug.vim')
let s:plug_home = expand(s:vimdir . '/plugged')

if empty(glob(s:plug_path))
  if executable('curl')
    silent execute '!curl -fLo "' . s:plug_path . '" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  else
    echoerr 'vim-plug を自動インストールできません: curl が見つかりません'
  endif
endif

if filereadable(s:plug_path)
  call plug#begin(s:plug_home)

  " Theme
  Plug 'jacoborus/tender'

  " Filer
  Plug 'lambdalisue/fern.vim'
  Plug 'lambdalisue/nerdfont.vim'
  Plug 'lambdalisue/fern-renderer-nerdfont.vim'
  Plug 'lambdalisue/glyph-palette.vim'

  call plug#end()

  " 未導入のプラグインがあれば入れて、設定を読み直す（初回起動時もここ）
  augroup vim_plug_bootstrap
    autocmd!
    autocmd VimEnter * if !empty(filter(values(copy(g:plugs)), '!isdirectory(v:val.dir)'))
      \ | PlugInstall --sync | source $MYVIMRC | endif
  augroup END
endif

""" Filer (fern)
" Ctrl+n でファイルツリーを表示/非表示する
nmap <C-n> :Fern . -reveal=% -drawer -toggle -width=25<CR>
let g:fern#default_hidden = 1
" アイコンに色をつける
let g:fern#renderer = 'nerdfont'
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
  autocmd FileType nerdtree,startify call glyph_palette#apply()
augroup END

""" Status line（ファイル名 / 変更 / 文字コード / 改行コード / 位置）
set laststatus=2
set statusline=%f\ %m%r%=%{&fileencoding!=''?&fileencoding:&encoding}%{&bomb?'[BOM]':''}\ %{&ff=='dos'?'CRLF':(&ff=='mac'?'CR':'LF')}\ %y\ %l:%c

""" バッファ切り替え
nnoremap <C-p> :bprevious<CR>
nnoremap <C-@> :bnext<CR>

""" Theme（初回起動でプラグイン導入前は無視）
silent! colorscheme tender
