"vim -u .bundles.vim +BundleInstall +q

set nocompatible
let $GIT_SSL_NO_VERIFY='true'

nnoremap <space> <Nop>
let mapleader=" "

filetype off " required! by vundle

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

" let Vundle manage Vundle
" required! 
Plugin 'gmarik/Vundle.vim'

" My Bundles here:
"
" original repos on github
Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-abolish'

Plugin 'tpope/vim-haml'
au BufNewFile,BufRead *.hamlc set filetype=haml

Plugin 'tpope/vim-cucumber'
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

Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-obsession'
Plugin 'tpope/vim-commentary'
Plugin 'vim-ruby/vim-ruby'
Plugin 'kana/vim-textobj-user'
Plugin 'rhysd/vim-textobj-ruby'
Plugin 'kchmck/vim-coffee-script'
" Bundle 'artemave/slowdown.vim'

Plugin 'artemave/spec-index.vim'
nnoremap <Leader>si :ShowSpecIndex<cr>

Plugin 'jgdavey/tslime.vim'
vmap <C-c><C-c> <Plug>SendSelectionToTmux
nmap <C-c><C-c> <Plug>NormalModeSendToTmux
nmap <C-c>r <Plug>SetTmuxVars

Plugin 'YankRing.vim'
let g:yankring_replace_n_pkey = '<c-p>'
let g:yankring_replace_n_nkey = ''
nnoremap <Leader>re :YRShow<cr>

Plugin 'michaeljsmith/vim-indent-object'

Plugin 'AndrewVos/vim-aaa'

Plugin 'godlygeek/tabular'
nnoremap <Leader>a= :Tabularize /=<CR>
vnoremap <Leader>a= :Tabularize /=<CR>
nnoremap <Leader>a: :Tabularize /:\zs/r0c1l0<CR>
vnoremap <Leader>a: :Tabularize /:\zs/r0c1l0<CR>
nnoremap <Leader>a> :Tabularize /=><CR>
vnoremap <Leader>a> :Tabularize /=><CR>
nnoremap <Leader>ae :Tabularize /==<CR>
vnoremap <Leader>ae :Tabularize /==<CR>

Plugin 'scrooloose/syntastic'
" Enable syntastic syntax checking
let g:syntastic_enable_signs=1
" else syntastic breaks ]l
let g:syntastic_always_populate_loc_list=1

" npm install -g eslint eslint-plugin-react
let g:syntastic_javascript_checkers = ['eslint']

let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1

let g:syntastic_error_symbol = '✗'
let g:syntastic_style_error_symbol = '✠'
let g:syntastic_warning_symbol = '∆'
let g:syntastic_style_warning_symbol = '≈'

highlight SyntasticErrorSign ctermfg=196 guifg=#ff0000
highlight SyntasticWarningSign ctermfg=226 guifg=#ffff00

Plugin 'sjl/gundo.vim'
nmap <F6> :GundoToggle<CR>
imap <F6> <ESC>:GundoToggle<CR>

Plugin 'Shougo/vimproc.vim' " after install: cd ~/.vim/bundle/vimproc.vim && make && cd -
Plugin 'Shougo/unite.vim'
Plugin 'Shougo/neoyank.vim'
" custom command: ag --follow --nocolor --nogroup --hidden -g ""
let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-g', '']
nnoremap <Leader>f :Unite -buffer-name=files -no-split -start-insert file_rec/async<cr>
nnoremap <Leader>F :Unite -buffer-name=scoped_files -no-split -start-insert -path=`expand("%:p:h")` file_rec/async:!<cr>
nnoremap <Leader>b :Unite -buffer-name=buffer -no-split -start-insert buffer<cr>
nnoremap <leader>Y :Unite -no-split -buffer-name=yank history/yank<cr>

au FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
  " Overwrite settings.
  imap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  imap <silent><buffer><expr> <C-s> unite#do_action('split')
  nmap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  nmap <silent><buffer><expr> <C-s> unite#do_action('split')
endfunction

Plugin 'Raimondi/delimitMate'
Plugin 'matchit.zip'
Plugin 'The-NERD-tree'
Plugin 'AnsiEsc.vim'
Plugin 'haskell.vim'

Plugin 'Shougo/neocomplete'
Plugin 'Shougo/echodoc.vim'
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
Plugin 'honza/vim-snippets'
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnippets"]

" useful when <Tab> -> <Esc>
" let g:snips_trigger_key='<C-@>' " this is <C-Space> that works

Plugin 'majutsushi/tagbar'
nmap <F8> :TagbarToggle<CR>

Plugin 'ecomba/vim-ruby-refactoring'
Plugin 'featurist/vim-pogoscript'

au FileType pogo nnoremap <Leader>c :PogoCompile<cr>

Plugin 'Lokaltog/vim-powerline'
" PowerLine recommeneded:
set laststatus=2   " Always show the statusline"
set encoding=utf-8 " Necessary to show Unicode glyphs"

Plugin 'mustache/vim-mustache-handlebars'
" mustache/handlebars with m M
let g:surround_109 = "{{\r}}"
let g:surround_77 = "{{{\r}}}"
let g:mustache_abbreviations = 1

Plugin 'fatih/vim-go'
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

Plugin 'kien/rainbow_parentheses.vim'
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


Plugin 'rking/ag.vim'
" Quick grep for word under the cursor in rails app
noremap <Leader><Leader>f :Ag <cword><cr>

let g:molokai_original = 1
Plugin 'tomasr/molokai'

Plugin 'pangloss/vim-javascript'

Plugin 'maksimr/vim-jsbeautify'
autocmd FileType javascript noremap <buffer> <Leader>B :call JsBeautify()<cr>
autocmd FileType json noremap <buffer> <Leader>B :call JsonBeautify()<cr>
autocmd FileType jsx noremap <buffer> <Leader>B :call JsxBeautify()<cr>
autocmd FileType html noremap <buffer> <Leader>B :call HtmlBeautify()<cr>
autocmd FileType css noremap <buffer> <Leader>B :call CSSBeautify()<cr>

autocmd FileType javascript vnoremap <buffer> <Leader>B :call RangeJsBeautify()<cr>
autocmd FileType json vnoremap <buffer> <Leader>B :call RangeJsonBeautify()<cr>
autocmd FileType jsx vnoremap <buffer> <Leader>B :call RangeJsxBeautify()<cr>
autocmd FileType html vnoremap <buffer> <Leader>B :call RangeHtmlBeautify()<cr>
autocmd FileType css vnoremap <buffer> <Leader>B :call RangeCSSBeautify()<cr>

"Plugin 'mxw/vim-jsx'
Plugin 'jsx/jsx.vim.git'
let g:jsx_no_default_key_mappings = 1
Plugin 'ternjs/tern_for_vim' " don't forget to `npm install` in bundles/tern_for_vim
au FileType javascript map <buffer> <Leader>td :TernDef<cr>
au FileType javascript map <buffer> <Leader>tr :TernRefs<cr>
au FileType javascript map <buffer> <Leader>ta :TernRename<cr>
au FileType javascript map <buffer> <Leader>tt :TernType<cr>

Plugin 'AndrewRadev/sideways.vim'
nnoremap <c-h> :SidewaysLeft<cr>
nnoremap <c-l> :SidewaysRight<cr>
omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

Plugin 'tommcdo/vim-exchange'

Plugin 'tmux-plugins/vim-tmux-focus-events'
Plugin 'chrisbra/NrrwRgn'

Plugin 'roman/golden-ratio'

Plugin 'terryma/vim-multiple-cursors'

Plugin 'dbext.vim'

Plugin 'airblade/vim-gitgutter'

Plugin 'FooSoft/vim-argwrap'

call vundle#end()            " required
filetype plugin indent on     " required! 
