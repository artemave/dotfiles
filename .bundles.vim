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
" Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rhubarb'
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

Plugin 'artemave/vigun'
au FileType {ruby,javascript,cucumber} nnoremap <leader>t :VigunRunTestFile<cr>
au FileType {ruby,javascript,cucumber} nnoremap <leader>T :VigunRunNearestTest<cr>
au FileType {javascript,cucumber} nnoremap <leader>D :VigunRunNearestTestDebug<cr>
au FileType javascript nnoremap <Leader>o :VigunMochaOnly<cr>
au FileType {ruby,javascript,go} nnoremap <leader>i :VigunShowSpecIndex<cr>

Plugin 'artemave/js-balls'
au FileType {javascript,javascript.jsx} nnoremap <Leader>p :JsBallsLintFix<cr>
au FileType {javascript,javascript.jsx} nnoremap <leader>R :JsBallsListRequirers<cr>

Plugin 'jgdavey/tslime.vim'
vmap <C-c><C-c> <Plug>SendSelectionToTmux
nmap <C-c><C-c> <Plug>NormalModeSendToTmux
nmap <C-c>r <Plug>SetTmuxVars
let g:tslime_always_current_session = 1

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

highlight SyntasticErrorSign ctermfg=196 guifg=#ff0000
highlight SyntasticWarningSign ctermfg=226 guifg=#ffff00

Plugin 'sjl/gundo.vim'
nmap <F6> :GundoToggle<CR>
imap <F6> <ESC>:GundoToggle<CR>

Plugin 'Shougo/neoyank.vim'
Plugin 'Shougo/vimproc.vim' " after install: cd ~/.vim/bundle/vimproc.vim && make && cd -
Plugin 'Shougo/unite.vim'
let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-g', '']
nnoremap <Leader>f :Unite -buffer-name=files -no-split -start-insert file_rec/async<cr>
nnoremap <Leader>F :Unite -buffer-name=scoped_files -no-split -start-insert -path=`expand("%:p:h")` file_rec/async<cr>
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
Plugin 'haskell.vim'

if has('nvim')
  Plugin 'Shougo/deoplete.nvim'
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#enable_smart_case = 1
  let g:deoplete#disable_auto_complete = 1
  let g:deoplete#enable_fuzzy_completion = 0
  let g:deoplete#sources#syntax#min_keyword_length = 3
else
  Plugin 'Shougo/neocomplete.vim'
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
  let g:neocomplete#disable_auto_complete = 1
  let g:neocomplete#enable_fuzzy_completion = 0
  let g:neocomplete#sources#syntax#min_keyword_length = 3
endif
Plugin 'Shougo/echodoc.vim'
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
let g:echodoc_enable_at_startup = 1
set noshowmode
set completeopt+=menuone
set completeopt-=preview

Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnippets"]
let g:UltiSnipsJumpForwardTrigger = "<Tab>"

" useful when <Tab> -> <Esc>
" let g:snips_trigger_key='<C-@>' " this is <C-Space> that works

" Disabling due to 'E716: Key not present in Dictionary: F'
" Plugin 'majutsushi/tagbar'
" nmap <F8> :TagbarToggle<CR>

Plugin 'ecomba/vim-ruby-refactoring'
Plugin 'featurist/vim-pogoscript'

au FileType pogo nnoremap <Leader>c :PogoCompile<cr>

Plugin 'vim-airline/vim-airline'
set laststatus=2

Plugin 'mustache/vim-mustache-handlebars'
" mustache/handlebars with m M
let g:surround_109 = "{{\r}}"
let g:surround_77 = "{{{\r}}}"
let g:mustache_abbreviations = 1

Plugin 'fatih/vim-go'
let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1


au FileType go nmap <leader>gr <Plug>(go-run)
au FileType go nmap <leader>gb <Plug>(go-build)
au FileType go nmap <Leader>gs <Plug>(go-implements)
au FileType go nmap <Leader>gi <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc-browser)
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
au FileType go nmap <leader>gt <Plug>(go-test)
au FileType go nmap <leader>gc <Plug>(go-coverage)
au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
au FileType go nmap <Leader>re <Plug>(go-rename)

let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }
let g:go_list_type = "quickfix"

" this one works with vim-javascript
Plugin 'bounceme/poppy.vim'
au! cursormoved * call PoppyInit()

let g:molokai_original = 1
Plugin 'tomasr/molokai'

Plugin 'elixir-lang/vim-elixir'

Plugin 'pangloss/vim-javascript'
hi def link jsObjectKey Label
let g:javascript_conceal_function       = "ƒ"
let g:javascript_conceal_this           = "✪"
let g:javascript_conceal_return         = "⇚"
let g:javascript_conceal_undefined      = "¿"
set conceallevel=2
set concealcursor=nc

Plugin 'mxw/vim-jsx'
let g:jsx_no_default_key_mappings = 1

Plugin 'ternjs/tern_for_vim' " don't forget to `npm install` in bundles/tern_for_vim
let g:tern#arguments = ['--persistent'] " so there are less timeouts
au FileType javascript map <buffer> <Leader>ad :TernDef<cr>
au FileType javascript map <buffer> <Leader>ar :TernRefs<cr>
au FileType javascript map <buffer> <Leader>aa :TernRename<cr>
au FileType javascript map <buffer> <Leader>at :TernType<cr>

Plugin 'AndrewRadev/sideways.vim'
nnoremap <c-h> :SidewaysLeft<cr>
nnoremap <c-l> :SidewaysRight<cr>
omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

Plugin 'tommcdo/vim-exchange'

" Plugin 'tmux-plugins/vim-tmux-focus-events'
Plugin 'chrisbra/NrrwRgn'

Plugin 'roman/golden-ratio'
" let g:golden_ratio_exclude_nonmodifiable = 1

Plugin 'terryma/vim-multiple-cursors'

Plugin 'dbext.vim'

Plugin 'airblade/vim-gitgutter'

Plugin 'FooSoft/vim-argwrap'

Plugin 'digitaltoad/vim-pug'

Plugin 'nathanaelkane/vim-indent-guides'
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_default_mapping = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=235

Plugin 'w0rp/ale'
let g:ale_lint_delay = 1000

Plugin 'junegunn/vader.vim'

call vundle#end()            " required
filetype plugin indent on    " required!
