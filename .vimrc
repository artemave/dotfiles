hi Search NONE
set t_Co=256
imap <TAB> <C-P>
imap <esc>[Z <s-tab>
inoremap # X#
set nowrap
set autoindent|set smartindent
set tabstop=2|set shiftwidth=2|set expandtab|set softtabstop=2
set showmatch
" autocmd FileType perl set number

" make tab in v mode ident code
vmap <tab> >gv
vmap <s-tab> <gv

" paste mode - this will avoid unexpected effects when you
" cut or copy some text from one window and paste it in Vim.
set pastetoggle=<F11>

" comment/uncomment blocks of code (in vmode)
vmap _c :s/^/#/gi<Enter>
vmap _C :s/^#//gi<Enter>

" my perl includes pod
let perl_include_pod = 1

" syntax color complex things like @{${"foo"}}
let perl_extended_vars = 1

" Tidy selected lines (or entire file) with _t:
nnoremap <silent> _t :%!perltidy -q<Enter>
vnoremap <silent> _t :!perltidy -q<Enter>


" Deparse obfuscated code
nnoremap <silent> _d :.!perl -MO=Deparse 2>/dev/null<cr>
vnoremap <silent> _d :!perl -MO=Deparse 2>/dev/null<cr>

set backspace=indent,eol,start
set shiftround
"set textwidth=80
set fileformat=unix
"set mouse=a
syntax on
set incsearch

let perl_fold=1
let perl_fold_blocks=1

hi Comment ctermfg=12
hi Folded ctermbg=0
hi Statement ctermfg=3

let g:dbext_default_profile_mysql = 'type=DBI:user=root:passwd=*Xh932iI^:driver=mysql:conn_parms=database=litecast;host=db1'

" for rails vim to handle ruby indent nicely
filetype plugin indent on
