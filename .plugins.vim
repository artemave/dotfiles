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

" let g:plug_threads=2

Plug 'wincent/terminus'

Plug 'tpope/vim-fugitive' | Plug 'junegunn/gv.vim'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-scriptease'

" Plug 'tpope/vim-haml'
" au BufNewFile,BufRead *.hamlc set filetype=haml

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

let g:obsession_no_bufenter = 1 " aparently faster this way
au VimEnter * if !exists('g:this_obsession') | :Obsess | endif

Plug 'tpope/vim-commentary'
" Bundle 'artemave/slowdown.vim'

Plug 'artemave/vigun'
au FileType ruby,javascript,typescript,cucumber,vader,python nnoremap <leader>t :VigunRun 'all'<cr>
au FileType ruby,javascript,typescript,cucumber,python nnoremap <leader>T :VigunRun 'nearest'<cr>
" au FileType ruby,javascript,typescript,cucumber,python nnoremap <leader>D :VigunRun 'debug-nearest'<cr>
au FileType ruby,javascript,typescript,cucumber,vader,python nnoremap <leader>wt :VigunRun 'watch-all'<cr>
au FileType ruby,javascript,typescript,cucumber,python nnoremap <leader>wT :VigunRun 'watch-nearest'<cr>
au FileType javascript,typescript,typescript nnoremap <Leader>vo :VigunMochaOnly<cr>
au FileType ruby,javascript,typescript,go,python nnoremap <leader>vi :VigunShowSpecIndex<cr>
nnoremap <leader>vt :VigunToggleTestWindowToPane<cr>
" let g:vigun_tmux_pane_orientation = 'horizontal'

Plug 'artemave/vjs'
au FileType {javascript,javascript.jsx,typescript} nmap <leader>vl :VjsListDependents<cr>
au FileType {javascript,javascript.jsx,typescript} nmap <leader>vr :VjsRenameFile<cr>
au FileType {javascript,javascript.jsx,typescript} vmap <leader>vv :VjsExtractVariable<cr>
au FileType {javascript,javascript.jsx,typescript} vmap <leader>vf :VjsExtractFunctionOrMethod<cr>
au FileType {javascript,javascript.jsx,typescript} nmap <leader>vd :VjsExtractDeclarationIntoFile<cr>
au FileType {javascript,javascript.jsx,typescript} nmap <leader>vc :VjsCreateDeclaration<cr>
let g:vjs_es_modules_complete = 1

" autocmd TextChanged * if &ft =~ 'javascript\|typescript' | call luaeval("require'vjs'.to_template_string()") | endif
" autocmd InsertLeave * if &ft =~ 'javascript\|typescript' | call luaeval("require'vjs'.to_template_string()") | endif

autocmd FileType {javascript,typescript} setlocal omnifunc=vjs#ModuleComplete

" Plug 'jgdavey/tslime.vim'
" vmap <C-c><C-c> <Plug>SendSelectionToTmux
" nmap <C-c><C-c> <Plug>NormalModeSendToTmux
" nmap <C-c>r <Plug>SetTmuxVars
" let g:tslime_always_current_session = 1

Plug 'michaeljsmith/vim-indent-object'

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

let g:fzf_layout = { 'left': '100%' }
let g:fzf_preview_window = ['right:60%', 'ctrl-/']

function! OpenOneOrMoreSelectedFiles(files)
  if len(a:files) == 1
    exe 'e' a:files[0]
  else
    let entries = map(a:files, '{ "filename": v:val, "lnum": 1 }')
    call setqflist(entries, 'r')
    copen
  endif
endfunction

let g:fzf_action = {
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit',
  \ '': function("OpenOneOrMoreSelectedFiles")
  \ }

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --hidden --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
" grep hidden files too
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --hidden --color=always --smart-case ".shellescape(<q-args>), 0, {}, <bang>0)
command! -bang -nargs=* RgInCurrentBufferDir call fzf#vim#grep("rg --column --line-number --no-heading --hidden --color=always --smart-case ".shellescape(<q-args>), 0, {'options': '-n 2..', 'dir': expand('%:h')}, <bang>0)
command! -bang -nargs=0 RgDiffMaster call fzf#vim#grep("{ git diff master... & git diff } | diff2vimgrep | sort -u", 0, {}, <bang>0)

nnoremap <silent> <Leader><Leader>s :execute 'RG' "\\b" . expand('<cword>') . "\\b"<CR>
nnoremap <Leader>s :RG<CR>
nnoremap <Leader>S :RgInCurrentBufferDir<CR>
nnoremap <Leader>f :Files<cr>
nnoremap <Leader>F :Files <C-R>=expand('%:h')<CR><CR>
nnoremap <Leader>b :Buffers<cr>
nnoremap <Leader>G :GFiles?<cr>
nnoremap <leader>u :Resume<cr>
nnoremap <leader>g :RgDiffMaster<cr>

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

Plug 'preservim/nerdtree'
nnoremap <silent> <leader><leader>f :NERDTreeFind<cr>

let g:delimitMate_expand_cr = 2
let g:delimitMate_expand_space = 1
" let g:delimitMate_jump_expansion = 1
Plug 'Raimondi/delimitMate'

" Plug 'vim-scripts/matchit.zip'
Plug 'andymass/vim-matchup'

" select words with Ctrl-N (like Ctrl-d in Sublime Text/VS Code)
" create cursors vertically with Ctrl-Down/Ctrl-Up
" select one character at a time with Shift-Arrows
" press n/N to get next/previous occurrence
" press [/] to select next/previous cursor
" press q to skip current and get next occurrence
" press Q to remove current cursor/selection
" start insert mode with i,a,I,A
Plug 'mg979/vim-visual-multi'

" useful when <Tab> -> <Esc>
" let g:snips_trigger_key='<C-@>' " this is <C-Space> that works

" Disabling due to 'E716: Key not present in Dictionary: F'
" Plug 'majutsushi/tagbar'
" nmap <F8> :TagbarToggle<CR>

" airline is slow apparently
Plug 'itchyny/lightline.vim'
set laststatus=2

" Plug 'fatih/vim-go'
" let g:go_version_warning = 0
" let g:go_fmt_command = "goimports"
" let g:go_highlight_functions = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_fields = 1
" let g:go_highlight_types = 1
" let g:go_highlight_operators = 1
" let g:go_highlight_build_constraints = 1

au FileType go nmap <leader>gr <Plug>(go-run)
au FileType go nmap <leader>gb <Plug>(go-build)
au FileType go nmap <Leader>gs <Plug>(go-implements)
au FileType go nmap <Leader>gi <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc-browser)
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
au FileType go nmap <leader>gt <Plug>(go-test)
au FileType go nmap <leader>gc <Plug>(go-coverage)
au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
au FileType go nmap <Leader>fe <Plug>(go-rename)

Plug 'navarasu/onedark.nvim'

" autocmd FileType {javascript,javascript.jsx} set errorformat=%+A\ %#%f\ %#(%l\\\,%c):\ %m,%C%m
" autocmd FileType {javascript,javascript.jsx} set makeprg=./node_modules/.bin/tsc\ -p\ tsconfig.json
" https://github.com/tpope/vim-dispatch/issues/222
set shellpipe=2>&1\|tee

" Easy text exchange operator for Vim.
Plug 'tommcdo/vim-exchange'

Plug 'chrisbra/NrrwRgn'

" Plug 'roman/golden-ratio'
" let g:golden_ratio_autocommand = 0
" let g:golden_ratio_exclude_nonmodifiable = 1
" let g:golden_ratio_exclude_filetypes = ['NERDtree', 'CHADTree', 'lspinfo']

Plug 'airblade/vim-gitgutter'
let g:gitgutter_preview_win_floating = 1

Plug 'FooSoft/vim-argwrap'
nnoremap <silent> <leader>aw :ArgWrap<CR>

Plug 'Yggdroot/indentLine'
au FileType markdown,json let g:indentLine_setConceal = 0

Plug 'junegunn/vader.vim'

" disables search highlighting when you are done searching and re-enables it when you search again.
Plug 'romainl/vim-cool'
let g:CoolTotalMatches = 1

Plug 'ap/vim-css-color'

Plug 'vim-scripts/scratch.vim'

Plug 'mattn/emmet-vim'
" let g:user_emmet_mode='i'
" let g:user_emmet_leader_key='<C-Z>'

" Open a Quickfix item in a window you choose
Plug 'yssl/QFEnter'

Plug 'SirVer/ultisnips'
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnippets"]
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"

" Calling UltiSnips#ExpandSnippetOrJump() from command mode unfucks snippet
" expantion. TODO: investigate further.

" autocmd CursorHold * :call s:fix_tab_mapping()

" fun s:fix_tab_mapping()
"   iunmap <tab>
"   exec "inoremap <silent>" g:UltiSnipsExpandTrigger "<C-R>=UltiSnips#ExpandSnippetOrJump()<cr>"
" endf

Plug 'honza/vim-snippets'

Plug 'ryanoasis/vim-devicons'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

Plug 'nvim-lua/plenary.nvim'
Plug 'jose-elias-alvarez/null-ls.nvim'

Plug 'neovim/nvim-lspconfig'

Plug 'quangnguyen30192/cmp-nvim-ultisnips'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'quangnguyen30192/cmp-nvim-tags'
" Plug 'hrsh7th/cmp-cmdline'

Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

Plug 'ray-x/cmp-treesitter'
Plug 'andersevenrud/cmp-tmux'
Plug 'hrsh7th/nvim-cmp'
Plug 'dstein64/vim-startuptime'

Plug 'MunifTanjim/nui.nvim'
" Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'jackMort/ChatGPT.nvim'

" Plug 'deoplete-plugins/deoplete-lsp'
" " For some reason I had to call UpdateRemotePlugins manually after install
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" let g:deoplete#enable_at_startup = 1

" ino <silent><expr> <Esc>   pumvisible() ? "\<C-e><Esc>" : "\<Esc>"
" ino <silent><expr> <C-c>   pumvisible() ? "\<C-e><C-c>" : "\<C-c>"
" ino <silent><expr> <BS>    pumvisible() ? "\<C-e><BS>"  : "<Plug>delimitMateBS"
" ino <silent><expr> <CR>    pumvisible() ? (complete_info().selected == -1 ? "\<C-e><CR>" : "\<C-y>") : "\<CR>"
" ino <silent><expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"

" set completeopt-=preview
set completeopt=menu,menuone,noselect

Plug 'takac/vim-hardtime'
let g:hardtime_default_on = 1
let g:hardtime_ignore_quickfix = 1
let g:hardtime_ignore_buffer_patterns = [ "NERD.*", "fugitive:" ]
let g:list_of_normal_keys = ["h", "j", "k", "l"]
let g:list_of_visual_keys = ["h", "j", "k", "l"]

" Don't use this - it adds a mapping that starts with 's'
" and that's messing with my fzf mapping
" Plug 'vim-scripts/AnsiEsc.vim'

Plug 'RRethy/vim-illuminate'

Plug 'AndrewRadev/linediff.vim'
Plug 'AndrewRadev/splitjoin.vim'
" Plug 'AndrewRadev/sideways.vim'

Plug 'artemave/vim-aaa'

" Plug 'jxnblk/vim-mdx-js'

Plug 'christoomey/vim-tmux-navigator'

Plug 'github/copilot.vim'
let g:copilot_filetypes = {
      \ '*': v:false,
      \ }

" Don't use this shit 'bogado/file-line' (it breaks baleia)

" adds support line number in file paths
Plug 'wsdjeg/vim-fetch'

Plug 'ton/vim-bufsurf'

Plug 'dart-lang/dart-vim-plugin'
Plug 'thosakwe/vim-flutter'

Plug 'm00qek/baleia.nvim'

Plug 'direnv/direnv.vim'

Plug 'nvim-treesitter/playground'

Plug 'maxmellon/vim-jsx-pretty'

Plug 'microsoft/vscode-js-debug', { 'do': 'npm install && npx gulp vsDebugServerBundle && mv dist out' }
Plug 'mfussenegger/nvim-dap'
Plug 'mxsdev/nvim-dap-vscode-js'
Plug 'rcarriga/nvim-dap-ui'
Plug 'theHamsta/nvim-dap-virtual-text'

" qf window with preview
Plug 'kevinhwang91/nvim-bqf'

Plug 'jose-elias-alvarez/typescript.nvim'

call plug#end()            " required

" some things have to be run after plug#end

lua require('plugins')
