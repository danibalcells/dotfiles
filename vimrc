set nocompatible              " be iMproved, required
filetype off                  " required

" Remap mapleader
let mapleader=","

" set the runtime path to include Vundle and initialize
set rtp+=~/.dotfiles/bundle/Vundle.vim
call vundle#begin('~/.dotfiles/bundle/')
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" Airline Vim
Plugin 'vim-airline/vim-airline'

" Fuzzy file search
Plugin 'junegunn/fzf', { 'dir': '~/.dotfiles/fzf', 'do': './install --all' }
Plugin 'junegunn/fzf.vim'

" Intensely orgasmic commenting
Plugin 'scrooloose/nerdcommenter'

" Cool colorscheme
Plugin 'crusoexia/vim-monokai'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" --------- MOVEMENT ----------

" move to the beginning/end of line
nnoremap · ^
nnoremap $ $

" move vertically by visual line and not skipping the 'fake' line when a
" 'real' line is displayed in two lines
nnoremap j gj
nnoremap k gk

" move through the buffer of open files
nnoremap <TAB> :bn<CR>
nnoremap <S-TAB> :bN<CR>

" ---------- UI CONFIG ----------
set number         " show line numbers
set cursorline     " highlight current line

"Noice colorscheme
" colorscheme desert
colorscheme monokai

"Syntax highlighting
syntax on

"Tab width
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab 

"Preserve visual block after indentation
vnoremap > >gv
vnoremap < <gv

"Show at least 15 lines above/below cursor
set scrolloff=15

"Correct PEP8 indentation
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

" Fix backspace issues
set backspace=2

" Remap split pane navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Natural split opening
set splitbelow
set splitright

" ---------- AIRLINE ----------
set laststatus=2
let g:airline_powerline_fonts = 1  " nice fonts
let g:airline#extensions#tabline#enabled = 1

" --------- NERDCOMMENTER -----
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1


" --------- FZF ---------------
map ; :Files<CR>
