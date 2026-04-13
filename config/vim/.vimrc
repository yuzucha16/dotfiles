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
" --------------------------------------------------
" vim-plug paths
" --------------------------------------------------
if has('win32') || has('win64')
  let s:plug_path = expand('~/vimfiles/autoload/plug.vim')
  let s:plug_home = expand('~/vimfiles/plugged')
else
  let s:plug_path = expand('~/.vim/autoload/plug.vim')
  let s:plug_home = expand('~/.vim/plugged')
endif

let s:did_bootstrap = v:false

" --------------------------------------------------
" Download vim-plug if needed
" --------------------------------------------------
if empty(glob(s:plug_path))
  let s:plug_dir = fnamemodify(s:plug_path, ':h')

  if !isdirectory(s:plug_dir)
    call mkdir(s:plug_dir, 'p')
  endif

  if executable('curl')
    silent execute '!curl -fLo "' . s:plug_path . '" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  elseif has('win32') || has('win64')
    if executable('pwsh')
      silent execute '!pwsh -NoProfile -Command "Invoke-WebRequest https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -OutFile ''' . substitute(s:plug_path, '''', '''''', 'g') . '''"'
    elseif executable('powershell')
      silent execute '!powershell -NoProfile -Command "Invoke-WebRequest https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -OutFile ''' . substitute(s:plug_path, '''', '''''', 'g') . '''"'
    else
      echoerr 'vim-plug を自動インストールできません: curl / pwsh / powershell が見つかりません'
    endif
  else
    echoerr 'vim-plug を自動インストールできません: curl が見つかりません'
  endif

  if filereadable(s:plug_path)
    let s:did_bootstrap = v:true
  endif
endif

" --------------------------------------------------
" Plugin list
" --------------------------------------------------
if filereadable(s:plug_path)
  call plug#begin(s:plug_home)

  " Theme
  Plug 'cocopon/iceberg.vim'
  Plug 'jonathanfilip/vim-lucius'
  Plug 'jacoborus/tender'
  Plug 'sainnhe/everforest'
  Plug 'mcchrish/zenbones.nvim'
  Plug 'daschw/leaf.nvim'

  " Filer
  Plug 'lambdalisue/fern.vim'
  Plug 'lambdalisue/nerdfont.vim'
  Plug 'lambdalisue/fern-renderer-nerdfont.vim'
  Plug 'lambdalisue/glyph-palette.vim'

  " Git
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'
  Plug 'lambdalisue/fern-git-status.vim'

  " Status bar
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  call plug#end()
else
  echoerr 'plug.vim の配置に失敗しました: ' . s:plug_path
endif

" --------------------------------------------------
" Auto install only when needed
" --------------------------------------------------
augroup vim_plug_bootstrap
  autocmd!
  autocmd VimEnter * call s:plug_bootstrap()
augroup END

function! s:plug_bootstrap() abort
  if !exists('g:plugs')
    return
  endif

  if s:did_bootstrap
    PlugInstall --sync
    source $MYVIMRC
    return
  endif

  let l:missing = filter(values(copy(g:plugs)), '!isdirectory(v:val.dir)')
  if !empty(l:missing)
    PlugInstall --sync
    source $MYVIMRC
  endif
endfunction

""" Filer (Filer)
nmap <C-n> :Fern . -reveal=% -drawer -toggle -width=25<CR> " Ctrl+nでファイルツリーを表示/非表示する
let g:fern#default_hidden = 1
let g:fern#renderer = 'nerdfont' " アイコンに色をつける
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
  autocmd FileType nerdtree,startify call glyph_palette#apply()
augroup END

""" Git
nnoremap g] :GitGutterNextHunk<CR>
nnoremap gh :GitGutterLineHighlightsToggle<CR>	" ghでdiffをハイライトする
nnoremap gp :GitGutterPreviewHunk<CR> 			" gpでカーソル行のdiffを表示する
highlight GitGutterAdd ctermfg=green			" 記号の色を変更する
highlight GitGutterChange ctermfg=blue
highlight GitGutterDelete ctermfg=red
set updatetime=250								" 反映時間を短くする(デフォルトは4000ms)

""" airline (Status bar)
nmap <C-p> <Plug>AirlineSelectPrevTab
nmap <C-@> <Plug>AirlineSelectNextTab
let g:airline_theme = 'wombat'
"let g:airline_theme = 'paper'
"let g:airline_theme = 'google_dark'

""" ステータスラインに表示する項目を変更する
" c: ファイル名
let g:airline#extensions#default#layout = [
  \ [ 'a', 'b' ],
  \ [ 'y', 'z']
  \ ]
"let g:airline_section_c = '%t %M'
let g:airline_section_z = get(g:, 'airline_linecolumn_prefix', '').'%3l:%-2v'
let g:airline#extensions#hunks#non_zero_only = 1	" 変更がなければdiffの行数を表示しない

""" タブラインの表示を変更する
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#tabline#show_close_button = 0

""" Theme
"set t_Co=256
set termguicolors
syntax enable
set background=dark
"colorscheme iceberg
"colorscheme lucius
colorscheme tender
"colorscheme everforest
"colorscheme zenborn
"colorscheme leaf
"syntax on

filetype plugin indent on

""" keybind
