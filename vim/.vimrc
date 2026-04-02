set nocompatible
filetype off

let mapleader=","

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin('~/.vim/bundle/')

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plugin 'junegunn/fzf.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'git://github.com/majutsushi/tagbar'
Plugin 'Vimjas/vim-python-pep8-indent'
Plugin 'git://github.com/skielbasa/vim-material-monokai'
Plugin 'leafgarland/typescript-vim'
Plugin 'peitalin/vim-jsx-typescript'

call vundle#end()
filetype plugin indent on

nnoremap · ^
nnoremap $ $

nnoremap j gj
nnoremap k gk

nnoremap <TAB> :bn<CR>
nnoremap <S-TAB> :bN<CR>

set number
set cursorline

set termguicolors
colorscheme monokai
set background=dark
highlight Normal guibg=black guifg=white

syntax on

set tabstop=4 softtabstop=4 shiftwidth=4 expandtab

vnoremap > >gv
vnoremap < <gv

set scrolloff=15

au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

set foldmethod=indent
set foldlevel=99

nnoremap <space> za

set backspace=2

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set splitbelow
set splitright

au CursorHoldI * stopinsert
au InsertEnter * let updaterestore=&updatetime | set updatetime=15000
au InsertLeave * let &updatetime=updaterestore

set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

let g:NERDSpaceDelims = 1

map ; :Files<CR>

nmap <leader>tt :TagbarToggle<CR>
nmap <leader>tr :TagbarOpen fj<CR>

let @p = 't(ï¿½krï¿½krci('

if &term =~ '256color'
  set t_ut=
endif
