"vim -u .bundles.vim +BundleInstall +q

set nocompatible
let $GIT_SSL_NO_VERIFY='true'

filetype off " required! by vundle

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-rake'
Bundle 'tpope/vim-bundler'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-cucumber'
Bundle 'tpope/vim-eunuch'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-obsession'
Bundle 'tpope/vim-commentary'
Bundle 'vim-ruby/vim-ruby'
Bundle 'kchmck/vim-coffee-script'
" Bundle 'artemave/slowdown.vim'
Bundle 'jgdavey/tslime.vim'
Bundle 'YankRing.vim'
Bundle 'lucapette/vim-ruby-doc'

Bundle 'michaeljsmith/vim-indent-object'

Bundle 'AndrewVos/vim-aaa'
Bundle 'sjbach/lusty'
Bundle 'godlygeek/tabular'
Bundle 'scrooloose/syntastic'
Bundle 'sjl/gundo.vim'
" vim-scripts repos
Bundle 'kien/ctrlp.vim'
Bundle 'Raimondi/delimitMate'
Bundle 'matchit.zip'
Bundle 'The-NERD-tree'
Bundle 'AnsiEsc.vim'
Bundle 'haskell.vim'
Bundle 'keepcase.vim'

Bundle 'Shougo/neocomplete'
Bundle 'Shougo/neosnippet'
Bundle 'honza/vim-snippets'

Bundle 'majutsushi/tagbar'

Bundle 'ecomba/vim-ruby-refactoring'
Bundle 'featurist/vim-pogoscript'
Bundle 'Lokaltog/vim-powerline'
Bundle 'mustache/vim-mustache-handlebars'
Bundle 'fatih/vim-go'
Bundle 'kien/rainbow_parentheses.vim'
Bundle 'rking/ag.vim'
Bundle 'tomasr/molokai'
Bundle 'pangloss/vim-javascript'
Bundle 'mxw/vim-jsx'
Bundle 'marijnh/tern_for_vim'

filetype plugin indent on     " required! 
"
" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed.

