" ==========================================================
" Jorge's Vim config (Vim 9.x) - JS/TS/TSX/React/Python/Bash
" ==========================================================

set nocompatible
set encoding=utf-8
scriptencoding utf-8

" --- UI ---
syntax on
filetype plugin indent on

set number
"set relativenumber
set cursorline
set termguicolors
set background=dark
colorscheme elflord

set showcmd
set showmode
set ruler
set laststatus=2
set signcolumn=yes
set wildmenu
set wildmode=longest:full,full
set mouse=a

" --- Editing ---
set hidden
set backspace=indent,eol,start
set undofile
set undodir=~/.vim/undo//
set swapfile
set directory=~/.vim/swap//
set backup
set writebackup
set backupdir=~/.vim/backup//

" Create dirs if missing (safe no-op if they exist)
silent! call mkdir(expand('~/.vim/undo'), 'p')
silent! call mkdir(expand('~/.vim/swap'), 'p')
silent! call mkdir(expand('~/.vim/backup'), 'p')

set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smartindent
set autoindent

set wrap
set linebreak
set breakindent

" --- Search ---
set ignorecase
set smartcase
set incsearch
set hlsearch

" Clear search highlight with <leader><space>
let mapleader=" "
nnoremap <leader><space> :nohlsearch<CR>

" --- Performance/behavior ---
set updatetime=300
set timeoutlen=500
set clipboard=unnamedplus

" --- Filetype specifics ---
" React filetypes
augroup ft_react
  autocmd!
  autocmd BufNewFile,BufRead *.tsx setlocal filetype=typescriptreact
  autocmd BufNewFile,BufRead *.jsx setlocal filetype=javascriptreact
augroup END

" Python: 4 spaces
augroup ft_python
  autocmd!
  autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
augroup END

" Bash: 2 spaces is fine; keep it consistent
augroup ft_shell
  autocmd!
  autocmd FileType sh,bash,zsh setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
augroup END

" --- Convenience mappings ---
" Save / Quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Quick split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ==========================================================
" Plugins via vim-plug
" ==========================================================
" Ensure you have plug.vim installed at:
"   ~/.vim/autoload/plug.vim
"
" Install with:
"   curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" Then run:
"   vim +PlugInstall +qall
" ==========================================================

call plug#begin('~/.vim/plugged')

" Better JS/TS/TSX/React syntax + indent
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'

" Better Python syntax
Plug 'vim-python/python-syntax'

" Sensible defaults for code editing (lightweight)
Plug 'tpope/vim-sensible'

" Comment toggling (gcc / gc)
Plug 'tpope/vim-commentary'

" Git helpers (optional but handy)
Plug 'tpope/vim-fugitive'

" Plugin: Git Change Indicators
" Shows added, modified, and deleted lines using Git diff markers in the margin.
" Plugins: vim-gitgutter and gitsigns (optional, choose one)

" Using vim-gitgutter
Plug 'airblade/vim-gitgutter'

" Alternatively, using gitsigns
" Plug 'lewis6991/gitsigns.nvim'

call plug#end()

" Highlight GitGutter changes for better visibility
highlight GitGutterAdd    guifg=#00FF00  " Bright green for added lines
highlight GitGutterDelete guifg=#FF0000 " Bright red for deleted lines
highlight GitGutterChange guifg=#FFFF00 " Yellow for modified lines

" --- Plugin settings ---
" vim-jsx-typescript: enable JSX highlighting inside TSX
let g:vim_jsx_pretty_colorful_config = 1

" python-syntax: more modern highlighting
let g:python_highlight_all = 1
