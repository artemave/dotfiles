if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync
endif

" let $GIT_SSL_NO_VERIFY='true'

set nocompatible

nnoremap <space> <Nop>
let mapleader="\<Space>"

call plug#begin('~/.vim/plugged')

Plug 'wincent/terminus'

Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive' | Plug 'junegunn/gv.vim'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'

Plug 'tpope/vim-haml'
au BufNewFile,BufRead *.hamlc set filetype=haml

Plug 'tpope/vim-cucumber'
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

Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-commentary'
" Bundle 'artemave/slowdown.vim'

Plug 'artemave/vigun'
au FileType {ruby,javascript,cucumber} nnoremap <leader>t :VigunRunTestFile<cr>
au FileType {ruby,javascript,cucumber} nnoremap <leader>T :VigunRunNearestTest<cr>
au FileType {javascript,cucumber} nnoremap <leader>D :VigunRunNearestTestDebug<cr>
au FileType {javascript,typescript} nnoremap <Leader>o :VigunMochaOnly<cr>
au FileType {ruby,javascript,go} nnoremap <leader>i :VigunShowSpecIndex<cr>

Plug 'artemave/vjs'
au FileType {javascript,javascript.jsx,typescript} nnoremap <Leader>p :VjsLintFix<cr>
au FileType {javascript,javascript.jsx,typescript} nnoremap <leader>R :VjsListRequirers<cr>

Plug 'jgdavey/tslime.vim'
vmap <C-c><C-c> <Plug>SendSelectionToTmux
nmap <C-c><C-c> <Plug>NormalModeSendToTmux
nmap <C-c>r <Plug>SetTmuxVars
let g:tslime_always_current_session = 1

Plug 'michaeljsmith/vim-indent-object'

Plug 'AndrewVos/vim-aaa'

Plug 'godlygeek/tabular'
nnoremap <Leader>a= :Tabularize /=<CR>
vnoremap <Leader>a= :Tabularize /=<CR>
nnoremap <Leader>a: :Tabularize /:\zs/r0c1l0<CR>
vnoremap <Leader>a: :Tabularize /:\zs/r0c1l0<CR>
nnoremap <Leader>a> :Tabularize /=><CR>
vnoremap <Leader>a> :Tabularize /=><CR>
nnoremap <Leader>ae :Tabularize /==<CR>
vnoremap <Leader>ae :Tabularize /==<CR>

let g:gundo_prefer_python3 = 1
Plug 'sjl/gundo.vim'
nmap <F6> :GundoToggle<CR>
imap <F6> <ESC>:GundoToggle<CR>

Plug 'Shougo/neoyank.vim'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'Shougo/unite.vim'
let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-g', '']
nnoremap <Leader>f :Unite -buffer-name=files -no-split -start-insert buffer file_rec/async<cr>
nnoremap <Leader>F :Unite -buffer-name=scoped_files -no-split -start-insert -path=`expand("%:p:h")` file_rec/async<cr>
nnoremap <Leader>b :Unite -buffer-name=buffer -no-split -start-insert buffer<cr>
nnoremap <leader>Y :Unite -no-split -buffer-name=yank history/yank<cr>
nnoremap <Leader>g :Unite -buffer-name=git_status -no-split -start-insert git_status<cr>
nnoremap <leader>u :UniteResume<cr>

au FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
  " Overwrite settings.
  " inoremap <silent><buffer><C-f> <esc>:Unite -buffer-name=files -no-split -start-insert file_rec/async<cr>
  imap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  imap <silent><buffer><expr> <C-s> unite#do_action('split')
  nmap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  nmap <silent><buffer><expr> <C-s> unite#do_action('split')
endfunction

let s:source = {
      \ 'name'  : 'git_status',
      \ 'hooks' : {},
      \ }

function! s:source.gather_candidates(args, context)
  let result = unite#util#system("git status -s | grep -ve '^D ' | cut -c 4-")
  if unite#util#get_last_status() == 0
    let paths = split(result, '\r\n\|\r\|\n')
    let candidates = []
    for path in paths
      let dict = {
            \ 'word'         : path,
            \ 'kind'         : 'file',
            \ 'action__path' : path,
            \ }
      call add(candidates, dict)
    endfor
    return candidates
  else
    call unite#util#print_error('Not in a Git repository.')
    return []
  endif
endfunction

let g:delimitMate_expand_cr = 2
let g:delimitMate_expand_space = 1
" let g:delimitMate_jump_expansion = 1
Plug 'Raimondi/delimitMate'

Plug 'vim-scripts/matchit.zip'
Plug 'vim-scripts/The-NERD-tree'

" Plug 'Valloric/YouCompleteMe', { 'do': 'python3 install.py --ts-completer' }
" let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
" let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
" let g:ycm_show_diagnostics_ui = 0
" au FileType {javascript,javascript.jsx,typescript} nnoremap <C-]> :YcmCompleter GoTo<cr>
" set completeopt-=preview

" " https://github.com/Valloric/YouCompleteMe/issues/2696#issuecomment-334439999
" imap <silent> <BS> <C-R>=YcmOnDeleteChar()<CR><Plug>delimitMateBS
" function! YcmOnDeleteChar()
"   if pumvisible()
"     return "\<C-y>"
"   endif
"   return "" 
" endfunction

Plug 'w0rp/ale'
" let g:ale_lint_delay = 1000
" let g:ale_linters_explicit = 1
let g:ale_linters_ignore = {'typescript': ['tslint', 'tsserver'], 'ruby': ['solargraph']}

Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-html', 'coc-yaml', 'coc-snippets', 'coc-emmet', 'coc-solargraph']
autocmd FileType unite let b:coc_suggest_disable = 1

inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

nmap <leader>ll <Plug>(coc-diagnostic-next)
nmap <leader>ln <Plug>(coc-diagnostic-prev)
nmap <leader>li <Plug>(coc-diagnostic-info)

nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gy <Plug>(coc-type-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
vmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnippets"]
let g:UltiSnipsJumpForwardTrigger = "<Tab>"

" useful when <Tab> -> <Esc>
" let g:snips_trigger_key='<C-@>' " this is <C-Space> that works

" Disabling due to 'E716: Key not present in Dictionary: F'
" Plug 'majutsushi/tagbar'
" nmap <F8> :TagbarToggle<CR>

Plug 'ecomba/vim-ruby-refactoring'

Plug 'vim-airline/vim-airline'
set laststatus=2
" let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
" let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

Plug 'mustache/vim-mustache-handlebars'
" mustache/handlebars with m M
let g:surround_109 = "{{\r}}"
let g:surround_77 = "{{{\r}}}"
let g:mustache_abbreviations = 1

Plug 'fatih/vim-go'
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

" this one works with vim-javascript
" Plug 'bounceme/poppy.vim'
" au! cursormoved * call PoppyInit()
" https://github.com/bounceme/poppy.vim/issues/7

let g:molokai_original = 1
Plug 'tomasr/molokai'

Plug 'elixir-lang/vim-elixir'

Plug 'pangloss/vim-javascript'
hi def link jsObjectKey Label

autocmd FileType {javascript,jsx} set errorformat=%+A\ %#%f\ %#(%l\\\,%c):\ %m,%C%m
autocmd FileType {javascript,jsx} set makeprg=./node_modules/.bin/tsc\ -p\ tsconfig.json
" https://github.com/tpope/vim-dispatch/issues/222
set shellpipe=2>&1\|tee

Plug 'leafgarland/typescript-vim'
Plug 'MaxMEllon/vim-jsx-pretty'

Plug 'AndrewRadev/sideways.vim'
nnoremap <c-h> :SidewaysLeft<cr>
nnoremap <c-l> :SidewaysRight<cr>
omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

Plug 'tommcdo/vim-exchange'

" Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'chrisbra/NrrwRgn'

Plug 'roman/golden-ratio'
" let g:golden_ratio_exclude_nonmodifiable = 1

Plug 'terryma/vim-multiple-cursors'

Plug 'vim-scripts/dbext.vim'

Plug 'airblade/vim-gitgutter'

Plug 'FooSoft/vim-argwrap'
nnoremap <silent> <leader>a :ArgWrap<CR>

Plug 'Yggdroot/indentLine'

Plug 'junegunn/vader.vim'

Plug '907th/vim-auto-save'
let g:auto_save = 1

Plug 'romainl/vim-cool'
let g:CoolTotalMatches = 1

Plug 'nikvdp/ejs-syntax'

Plug 'ap/vim-css-color'

Plug 'vim-scripts/scratch.vim'

Plug 'mattn/emmet-vim'

Plug 'yssl/QFEnter'

call plug#end()            " required

" this must be after plug#end() for some reason
call unite#define_source(s:source)
