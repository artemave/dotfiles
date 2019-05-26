set nocompatible

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync
endif

call plug#begin('~/.vim/plugged')

Plug 'w0rp/ale'
let g:ale_linters_ignore = {'typescript': ['tslint', 'tsserver'], 'ruby': ['solargraph']}

Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
let g:coc_global_extensions = ['coc-tsserver']

let g:molokai_original = 1
Plug 'tomasr/molokai'

Plug 'leafgarland/typescript-vim'

call plug#end()            " required

colorscheme molokai " this has to come after 'filetype plugin indent on'
