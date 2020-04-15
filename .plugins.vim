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

Plug 'tpope/vim-fugitive' | Plug 'junegunn/gv.vim'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-scriptease'

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
au FileType {javascript,typescript} nnoremap <Leader>vo :VigunMochaOnly<cr>
au FileType {ruby,javascript,go} nnoremap <leader>vi :VigunShowSpecIndex<cr>

Plug 'artemave/vjs'
au FileType {javascript,javascript.jsx,typescript} nnoremap <Leader>vp :VjsLintFix<cr>
au FileType {javascript,javascript.jsx,typescript} nnoremap <leader>vr :VjsListRequirers<cr>
au FileType {javascript,javascript.jsx,typescript} vnoremap <leader>vv :VjsExtractVariable<cr>
au FileType {javascript,javascript.jsx,typescript} vnoremap <leader>vf :VjsExtractFunction<cr>

" Plug 'jgdavey/tslime.vim'
" vmap <C-c><C-c> <Plug>SendSelectionToTmux
" nmap <C-c><C-c> <Plug>NormalModeSendToTmux
" nmap <C-c>r <Plug>SetTmuxVars
" let g:tslime_always_current_session = 1

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

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'artemave/fzf.vim' " my fork adds `Resume` command
" this has moved to .common_env
" let $FZF_DEFAULT_OPTS .= ' --exact --bind ctrl-a:select-all'
let g:fzf_history_dir = '~/.fzf-history'

" grep hidden files too
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --hidden --color=always --smart-case ".shellescape(<q-args>), 1, <bang>0)

nnoremap <silent> <Leader><Leader>s :execute 'Rg' "\\b" . expand('<cword>') . "\\b"<CR>
nnoremap <Leader>s :Rg<CR>
nnoremap <Leader>f :Files<cr>
nnoremap <Leader>F :Files <C-R>=expand('%:h')<CR><CR>
nnoremap <Leader>b :Buffers<cr>
nnoremap <Leader>G :GFiles?<cr>
nnoremap <leader>u :Resume<cr>

nnoremap <leader>v :set operatorfunc=SearchOperator<cr>g@
vnoremap <leader>v :<c-u>call SearchOperator(visualmode())<cr>

function! SearchOperator(type)
  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  else
    return
  endif

  execute "Rg " . @@
endfunction

Plug 'vim-scripts/The-NERD-tree'
nnoremap <silent> <leader><leader>f :NERDTreeFind<cr>
" nnoremap <silent> <leader><leader>f :Vexplore<cr>

let g:delimitMate_expand_cr = 2
let g:delimitMate_expand_space = 1
" let g:delimitMate_jump_expansion = 1
Plug 'Raimondi/delimitMate'

Plug 'vim-scripts/matchit.zip'

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

nnoremap <leader>ll <Plug>(coc-diagnostic-next-error)
nnoremap <leader>ln <Plug>(coc-diagnostic-prev-error)
nnoremap <leader>li <Plug>(coc-diagnostic-info)

nnoremap <leader>gd <Plug>(coc-definition)
nnoremap <leader>gy <Plug>(coc-type-definition)
nnoremap <leader>gi <Plug>(coc-implementation)
nnoremap <leader>gr <Plug>(coc-references)
nnoremap <leader>rn <Plug>(coc-rename)

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
vnoremap <leader>as :CocAction<cr>
" vnoremap <leader>as <Plug>(coc-codeaction-selected)
nnoremap <leader>la <Plug>(coc-codelens-action)
" Remap for do codeAction of current line
nnoremap <leader>ca  <Plug>(coc-codeaction)

nnoremap <leader>wh <Plug>(coc-float-hide)
nnoremap <leader>wj <Plug>(coc-float-hide)

" Fix autofix problem of current line
nnoremap <leader>qf  <Plug>(coc-fix-current)

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

nmap <expr> <silent> <C-d> <SID>select_current_word()
function! s:select_current_word()
  if !get(g:, 'coc_cursors_activated', 0)
    return "\<Plug>(coc-cursors-word)"
  endif
  return "*\<Plug>(coc-cursors-word):nohlsearch\<CR>"
endfunc

" useful when <Tab> -> <Esc>
" let g:snips_trigger_key='<C-@>' " this is <C-Space> that works

" Disabling due to 'E716: Key not present in Dictionary: F'
" Plug 'majutsushi/tagbar'
" nmap <F8> :TagbarToggle<CR>

Plug 'vim-ruby/vim-ruby'

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

autocmd FileType {javascript,javascript.jsx} set errorformat=%+A\ %#%f\ %#(%l\\\,%c):\ %m,%C%m
autocmd FileType {javascript,javascript.jsx} set makeprg=./node_modules/.bin/tsc\ -p\ tsconfig.json
" https://github.com/tpope/vim-dispatch/issues/222
set shellpipe=2>&1\|tee

Plug 'leafgarland/typescript-vim'
Plug 'MaxMEllon/vim-jsx-pretty'

Plug 'tommcdo/vim-exchange'

" Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'chrisbra/NrrwRgn'

Plug 'roman/golden-ratio'
" let g:golden_ratio_exclude_nonmodifiable = 1

Plug 'vim-scripts/dbext.vim'

Plug 'airblade/vim-gitgutter'

Plug 'FooSoft/vim-argwrap'
nnoremap <silent> <leader>aw :ArgWrap<CR>

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

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnippets"]
let g:UltiSnipsJumpForwardTrigger = "<Tab>"

Plug 'AndrewRadev/splitjoin.vim'

call plug#end()            " required