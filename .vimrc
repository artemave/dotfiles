hi Search NONE
set t_Co=256
imap <TAB> <C-P>
imap <esc>[Z <s-tab>
imap jj <esc>
" this is provided by language indents (perl, ruby, etc)
" inoremap # X#
" set autoindent|set smartindent
set nowrap
set tabstop=2|set shiftwidth=2|set expandtab|set softtabstop=2
set showmatch

" make tab in v mode ident code
vmap <tab> >gv
vmap <s-tab> <gv

" paste mode - this will avoid unexpected effects when you
" cut or copy some text from one window and paste it in Vim.
set pastetoggle=<F12>

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
syntax on
set incsearch

let perl_fold=1
let perl_fold_blocks=1

hi Comment ctermfg=12
hi Folded ctermbg=0
hi Statement ctermfg=3

" for rails vim to handle ruby indent nicely
filetype plugin indent on

" this is supposed to help cucumber highlighting
set fileencodings=ucs-bom,utf-8,latin1

set autoread
