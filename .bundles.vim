"vim -u .bundles.vim +BundleInstall +q

set nocompatible
let $GIT_SSL_NO_VERIFY='true'

nnoremap <space> <Nop>
let mapleader=" "

filetype off " required! by vundle

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github
Bundle 'tpope/vim-dispatch'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-rake'
Bundle 'tpope/vim-bundler'
Bundle 'tpope/vim-surround'

Bundle 'tpope/vim-haml'
au BufNewFile,BufRead *.hamlc set filetype=haml

Bundle 'tpope/vim-cucumber'
" cucumber auto outline
inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a
function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

function! MyCloseGdiff()
  if (&diff == 0 || getbufvar('#', '&diff') == 0)
        \ && (bufname('%') !~ '^fugitive:' && bufname('#') !~ '^fugitive:')
    echom "Not in diff view."
    return
  endif

  " close current buffer if alternate is not fugitive but current one is
  if bufname('#') !~ '^fugitive:' && bufname('%') =~ '^fugitive:'
    if bufwinnr("#") == -1
      b #
      bd #
    else
      bd
    endif
  else
    bd #
  endif
endfunction
nnoremap <Leader>D :call MyCloseGdiff()<cr>

Bundle 'tpope/vim-eunuch'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-obsession'
Bundle 'tpope/vim-commentary'
Bundle 'vim-ruby/vim-ruby'
Bundle 'kchmck/vim-coffee-script'
" Bundle 'artemave/slowdown.vim'

Bundle 'jgdavey/tslime.vim'
vmap <C-c><C-c> <Plug>SendSelectionToTmux
nmap <C-c><C-c> <Plug>NormalModeSendToTmux
nmap <C-c>r <Plug>SetTmuxVars

Bundle 'YankRing.vim'
let g:yankring_replace_n_pkey = '<c-n>'
let g:yankring_replace_n_nkey = ''
nnoremap <Leader>re :YRShow<cr>

Bundle 'lucapette/vim-ruby-doc'
let g:ruby_doc_command='open'
let g:ruby_doc_ruby_host='http://apidock.com/ruby/'
let g:ruby_doc_rails_host='http://apidock.com/rails/'


Bundle 'michaeljsmith/vim-indent-object'

Bundle 'AndrewVos/vim-aaa'

Bundle 'sjbach/lusty'
let g:LustyJugglerSuppressRubyWarning = 1

Bundle 'godlygeek/tabular'
nnoremap <Leader>a= :Tabularize /=<CR>
vnoremap <Leader>a= :Tabularize /=<CR>
nnoremap <Leader>a: :Tabularize /:\zs/r0c1l0<CR>
vnoremap <Leader>a: :Tabularize /:\zs/r0c1l0<CR>
nnoremap <Leader>a> :Tabularize /=><CR>
vnoremap <Leader>a> :Tabularize /=><CR>
nnoremap <Leader>ae :Tabularize /==<CR>
vnoremap <Leader>ae :Tabularize /==<CR>

Bundle 'scrooloose/syntastic'
" Enable syntastic syntax checking
let g:syntastic_enable_signs=1
" else syntastic breaks ]l
let g:syntastic_always_populate_loc_list=1


Bundle 'sjl/gundo.vim'
nmap <F6> :GundoToggle<CR>
imap <F6> <ESC>:GundoToggle<CR>

Bundle 'kien/ctrlp.vim'
""let g:agprg = 'agprg.sh'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files']
let g:ctrlp_show_hidden = 1
let g:ctrlp_working_path_mode = 0
let g:ctrlp_extensions = ['tag', 'buffertag', 'dir', 'undo', 'line', 'mixed']
nnoremap <Leader>b :CtrlPBuffer<CR>

Bundle 'Raimondi/delimitMate'
Bundle 'matchit.zip'
Bundle 'The-NERD-tree'
Bundle 'AnsiEsc.vim'
Bundle 'haskell.vim'
Bundle 'keepcase.vim'

Bundle 'Shougo/neocomplete'
Bundle 'Shougo/echodoc.vim'
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#disable_auto_complete = 1
let g:neocomplete#enable_fuzzy_completion = 0
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:echodoc_enable_at_startup = 1
set noshowmode
set completeopt+=menuone
set completeopt-=preview

Plugin 'SirVer/ultisnips'
Bundle 'honza/vim-snippets'
" useful when <Tab> -> <Esc>
" let g:snips_trigger_key='<C-@>' " this is <C-Space> that works

Bundle 'majutsushi/tagbar'
nmap <F8> :TagbarToggle<CR>

Bundle 'ecomba/vim-ruby-refactoring'
Bundle 'featurist/vim-pogoscript'

Bundle 'Lokaltog/vim-powerline'
" PowerLine recommeneded:
set laststatus=2   " Always show the statusline"
set encoding=utf-8 " Necessary to show Unicode glyphs"

Bundle 'mustache/vim-mustache-handlebars'
" mustache/handlebars with m M
let g:surround_109 = "{{\r}}"
let g:surround_77 = "{{{\r}}}"
let g:mustache_abbreviations = 1

Bundle 'fatih/vim-go'
let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1

au FileType go nmap <Leader>s <Plug>(go-implements)
au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc-browser)
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
au FileType go nmap <Leader>re <Plug>(go-rename)

Bundle 'kien/rainbow_parentheses.vim'
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadBraces

let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]


Bundle 'rking/ag.vim'
" Quick grep for word under the cursor in rails app
noremap <Leader>f :Ag <cword><cr>

Bundle 'tomasr/molokai'
let g:molokai_original = 1
colorscheme molokai
set background=dark

Bundle 'pangloss/vim-javascript'
Bundle 'mxw/vim-jsx'
Bundle 'marijnh/tern_for_vim'
Bundle 'PeterRincker/vim-argumentative'

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

