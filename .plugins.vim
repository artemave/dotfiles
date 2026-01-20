set nocompatible

nnoremap <space> <Nop>
let mapleader="\<Space>"

lua require('plugins')

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


let g:obsession_no_bufenter = 1 " aparently faster this way
au VimEnter * if !exists('g:this_obsession') | :Obsess | endif

au FileType ruby,javascript,typescript,cucumber,vader,python,dart nnoremap <leader>t :VigunRun all<cr>
au FileType ruby,javascript,typescript,cucumber,python,dart nnoremap <leader>T :VigunRun nearest<cr>
au FileType ruby,javascript,typescript,cucumber,python nnoremap <leader>D :VigunRun debug-nearest<cr>
au FileType ruby,javascript,typescript,cucumber,vader,python nnoremap <leader>wt :VigunRun watch-all<cr>
au FileType ruby,javascript,typescript,cucumber,python nnoremap <leader>wT :VigunRun watch-nearest<cr>
au FileType javascript,typescript,typescript nnoremap <Leader>vo :VigunMochaOnly<cr>
au FileType ruby,javascript,typescript,go,python nnoremap <leader>vi :VigunShowSpecIndex<cr>
nnoremap <leader>vt :VigunToggleTestWindowToPane<cr>
" let g:vigun_tmux_pane_orientation = 'horizontal'

" au FileType {javascript,javascriptreact,typescript,typescriptreact} nmap <leader>vl :VjsListDependents<cr>
" au FileType {javascript,javascriptreact,typescript,typescriptreact} nmap <leader>vr :VjsRenameFile<cr>
" au FileType {javascript,javascriptreact,typescript,typescriptreact} vmap <leader>vv :VjsExtractVariable<cr>
" au FileType {javascript,javascriptreact,typescript,typescriptreact} vmap <leader>vf :VjsExtractFunctionOrMethod<cr>
" au FileType {javascript,javascriptreact,typescript,typescriptreact} nmap <leader>vd :VjsExtractDeclarationIntoFile<cr>
" au FileType {javascript,javascriptreact,typescript,typescriptreact} nmap <leader>vc :VjsCreateDeclaration<cr>
" let g:vjs_es_modules_complete = 1

" autocmd TextChanged * if &ft =~ 'javascript\|typescript' | call luaeval("require'vjs'.to_template_string()") | endif
" autocmd InsertLeave * if &ft =~ 'javascript\|typescript' | call luaeval("require'vjs'.to_template_string()") | endif

" autocmd FileType {javascript,typescript} setlocal omnifunc=vjs#ModuleComplete

" Plug 'jgdavey/tslime.vim'
" vmap <C-c><C-c> <Plug>SendSelectionToTmux
" nmap <C-c><C-c> <Plug>NormalModeSendToTmux
" nmap <C-c>r <Plug>SetTmuxVars
" let g:tslime_always_current_session = 1


" nnoremap <Leader>a= :Tabularize /=<CR>
" vnoremap <Leader>a= :Tabularize /=<CR>
" nnoremap <Leader>a: :Tabularize /:\zs/r0c1l0<CR>
" vnoremap <Leader>a: :Tabularize /:\zs/r0c1l0<CR>
" nnoremap <Leader>a> :Tabularize /=><CR>
" vnoremap <Leader>a> :Tabularize /=><CR>
" nnoremap <Leader>ae :Tabularize /==<CR>
" vnoremap <Leader>ae :Tabularize /==<CR>

let g:gundo_prefer_python3 = 1
nmap <F6> :GundoToggle<CR>
imap <F6> <ESC>:GundoToggle<CR>

" fzf configuration moved to .vim/lua/plugins.lua

" Plug 'preservim/nerdtree'
nnoremap <silent> <leader><leader>f :lua require('nvim-tree/api').tree.open({ find_file = true })<cr>

let g:delimitMate_expand_cr = 2
let g:delimitMate_expand_space = 1
" let g:delimitMate_jump_expansion = 1

" select words with Ctrl-N (like Ctrl-d in Sublime Text/VS Code)
" create cursors vertically with Ctrl-Down/Ctrl-Up
" select one character at a time with Shift-Arrows
" press n/N to get next/previous occurrence
" press [/] to select next/previous cursor
" press q to skip current and get next occurrence
" press Q to remove current cursor/selection
" start insert mode with i,a,I,A
" Plug 'mg979/vim-visual-multi'

" useful when <Tab> -> <Esc>
" let g:snips_trigger_key='<C-@>' " this is <C-Space> that works

" Disabling due to 'E716: Key not present in Dictionary: F'
" Plug 'majutsushi/tagbar'
" nmap <F8> :TagbarToggle<CR>

" airline is slow apparently
set laststatus=2

" autocmd FileType {javascript,javascriptreact} set errorformat=%+A\ %#%f\ %#(%l\\\,%c):\ %m,%C%m
" autocmd FileType {javascript,javascriptreact} set makeprg=./node_modules/.bin/tsc\ -p\ tsconfig.json
" https://github.com/tpope/vim-dispatch/issues/222
set shellpipe=2>&1\|tee

" Easy text exchange operator for Vim.


" Plug 'roman/golden-ratio'
" let g:golden_ratio_autocommand = 0
" let g:golden_ratio_exclude_nonmodifiable = 1
" let g:golden_ratio_exclude_filetypes = ['NERDtree', 'CHADTree', 'lspinfo']

let g:gitgutter_preview_win_floating = 1

nnoremap <silent> <leader>aw :ArgWrap<CR>

au FileType markdown,json,jsonc,mdx let g:indentLine_setConceal = 0
au FileType markdown,json,jsonc,mdx set conceallevel=0


" disables search highlighting when you are done searching and re-enables it when you search again.
let g:CoolTotalMatches = 1



autocmd FileType html,css,javascript EmmetInstall
" let g:user_emmet_mode='i'
" let g:user_emmet_leader_key='<C-Z>'
let g:user_emmet_settings = {
\  'javascript' : {
\      'extends' : 'jsx',
\  },
\}

" Open a Quickfix item in a window you choose

" press <Tab> to expand or jump in a snippet. These can also be mapped separately
" via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
" -1 for jumping backwards.
inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>


" This one is for NERDtree
" And this one is for trouble.nvim




" This seems to slow things down
" Plug 'hrsh7th/cmp-nvim-lsp'
" Plug 'hrsh7th/cmp-cmdline'



" Plug 'nvim-lua/plenary.nvim'

" set completeopt-=preview
set completeopt=menu,menuone,noselect

" Don't use this - it adds a mapping that starts with 's'
" and that's messing with my fzf mapping
" Plug 'vim-scripts/AnsiEsc.vim'


let g:copilot_filetypes = {
      \ '*': v:false,
      \ }

" Don't use this shit 'bogado/file-line' (it breaks baleia)

" adds support line number in file paths


" Plug 'nvim-lua/plenary.nvim'





" try install vscode-js-debug via mason instead

" qf window with preview



" Plug 'jayp0521/mason-nvim-dap.nvim'


" shows js/ts errors across the entire project in a quickfix

" adds a bunch of null-ls code actions
