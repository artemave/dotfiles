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

set hidden
set wildchar=<Tab> wildmenu wildmode=full
set wildcharm=<C-Z>
nnoremap <F10> :b <C-Z>
set switchbuf=useopen
" Mappings to access buffers (don't use "\p" because a
" delay before pressing "p" would accidentally paste).
" \l       : list buffers
" \b \f \g : go back/forward/last-used
" \1 \2 \3 : go to buffer 1/2/3 etc
nnoremap <Leader>l :ls<CR>
nnoremap <Leader>b :bp<CR>
nnoremap <Leader>f :bn<CR>
nnoremap <Leader>g :e#<CR>
nnoremap <Leader>1 :1b<CR>
nnoremap <Leader>2 :2b<CR>
nnoremap <Leader>3 :3b<CR>
nnoremap <Leader>4 :4b<CR>
nnoremap <Leader>5 :5b<CR>
nnoremap <Leader>6 :6b<CR>
nnoremap <Leader>7 :7b<CR>
nnoremap <Leader>8 :8b<CR>
nnoremap <Leader>9 :9b<CR>
nnoremap <Leader>0 :10b<CR>
" It's useful to show the buffer number in the status line.
set laststatus=2 statusline=%02n:%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

call pathogen#runtime_append_all_bundles()
" call pathogen#helptags() " commented out to no get annoying message from dbext help every time vim starts
