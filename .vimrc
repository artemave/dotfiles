" https://stackoverflow.com/questions/18321538/vim-error-e474-invalid-argument-listchars-tab-trail
scriptencoding utf-8
set encoding=utf-8

" trick ideavim into skipping this
exec "source ~/.plugins.vim"

colorscheme molokai " this has to come after 'filetype plugin indent on'

set exrc   " enable per-directory .vimrc files
set secure " disable unsafe commands in local .vimrc files

syntax on

set t_Co=256
" inoremap <Tab> <Esc>`^
inoremap kj <Esc>`^
inoremap jj <Esc>`^

set noswapfile

"" Whitespace
set nowrap                      " don't wrap lines
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set softtabstop=2
set expandtab                   " use spaces, not tabs (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode
set shiftround
set showmatch
set colorcolumn=80

" when ':set wrap'
set linebreak
set breakindent

" suggest correct spelling in CTRL_N/CTRL_P
set complete+=kspell

" copy/paste to clipboard without prepending "*
set clipboard=unnamed,unnamedplus

" display incomplete commands
set showcmd

" make tab in v mode ident code
vmap <tab> >gv
vmap <s-tab> <gv

set fileformat=unix

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

set autoread
if has('nvim')
  " https://github.com/neovim/neovim/issues/1936
  au FocusGained * :checktime
endif

set hidden

if !has('nvim')
  set cryptmethod=blowfish2
endif

" command line completion
set wildchar=<Tab> wildmenu wildmode=list:longest,list:full

set switchbuf=useopen

" Thorfile, Rakefile, Vagrantfile and Gemfile are Ruby
au BufRead,BufNewFile {Gemfile,Rakefile,Capfile,Vagrantfile,Thorfile,config.ru} set ft=ruby

au BufRead,BufNewFile *.jsx set ft=javascript.jsx

" Don't syntax highlight markdown because it's often wrong
autocmd! FileType {mkd,md} setlocal syn=off

command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
function s:RunShellCommand(cmdline)
  let isfirst = 1
  let words = []
  for word in split(a:cmdline)
    if isfirst
      let isfirst = 0  " don't change first word (shell command)
    else
      if word[0] =~ '\v[%#<]'
        let word = expand(word)
      endif
      let word = shellescape(word, 1)
    endif
    call add(words, word)
  endfor
  let expanded_cmdline = join(words)
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1, 'You entered:  ' . a:cmdline)
  call setline(2, 'Expanded to:  ' . expanded_cmdline)
  call append(line('$'), substitute(getline(2), '.', '=', 'g'))
  silent execute '$read !'. expanded_cmdline
  1
endfunction

function s:GrepOpenBuffers(search, jump)
  call setqflist([])
  let cur = getpos('.')
  silent! exe 'bufdo vimgrepadd /' . a:search . '/ %'
  let matches = len(getqflist())
  if a:jump && matches > 0
    sil! cfirst
  else
    call setpos('.', cur)
  endif
  echo 'BufGrep:' ((matches) ? matches : 'No') 'matches found'
endfunction
com! -nargs=1 -bang BufGrep call <SID>GrepOpenBuffers('<args>', <bang>0)
nnoremap <Leader>B :BufGrep

" remap 'increase number' since C-a is captured by tmux/screen
" Easier increment/decrement
nnoremap + <C-a>
nnoremap - <C-x>

" trick ideavim into skipping this
exec "set relativenumber"
set number

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" CTags
"
" $PATH appears different to vim for some reason and hence wrong ctags gets picked
" until then, you need to manually override ctags in /usr/bin/ with those from homebrew
" TODO fix vim path
map <Leader>rt :!git ls-files \| ctags --links=no -L-<CR><CR>

" Remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

set scrolloff=3 " Keep 3 lines below and above the cursor"

" Make Y behave like other capitals
nnoremap Y y$

" Improve up/down movement on wrapped lines
nnoremap j gj
nnoremap k gk

" Better comand-line editing
cnoremap <C-j> <t_kd>
cnoremap <C-k> <t_ku>
cnoremap <C-^> <Home>
cnoremap <C-e> <End>

" Stop messing with my arrow keys
if !has("gui_running")
  let g:AutoClosePreservDotReg = 0
endif

nnoremap <leader>y "*y

" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ARROW KEYS ARE UNACCEPTABLE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" map <Left> <Nop>
" map <Right> <Nop>
" map <Up> <Nop>
" map <Down> <Nop>

" Fake '|' as text object
nnoremap di\| T\|d,
nnoremap da\| F\|d,
nnoremap ci\| T\|c,
nnoremap ca\| F\|c,
nnoremap yi\| T\|y,
nnoremap ya\| F\|y,
nnoremap vi\| T\|v,
nnoremap va\| F\|v,

" Fake '/' as text object
nnoremap di/ T/d,
nnoremap da/ F/d,
nnoremap ci/ T/c,
nnoremap ca/ F/c,
nnoremap yi/ T/y,
nnoremap ya/ F/y,
nnoremap vi/ T/v,
nnoremap va/ F/v,

set list listchars=trail:·

" disable folding
set nofoldenable

" alias backtick to signle quote
map ' `

fun RangerChooser()
  exec "silent !ranger --choosefile=/tmp/chosenfile " . expand("%:p:h")
  if filereadable('/tmp/chosenfile')
    exec 'edit ' . system('cat /tmp/chosenfile')
    call system('rm /tmp/chosenfile')
  endif
  redraw!
endfun

function! OpenWithRanger()
  let rangerCallback = { 'name': 'ranger' }
  function! rangerCallback.on_exit(id, code)
    try
      if filereadable('/tmp/chosenfile')
        exec 'edit ' . readfile('/tmp/chosenfile')[0]
        call system('rm /tmp/chosenfile')
      endif
    endtry
  endfunction
  enew
  call termopen('ranger --choosefile=/tmp/chosenfile', rangerCallback)
  startinsert
endfunction
map <Leader><Leader>r :call OpenWithRanger()<CR>

""set cursorline

" substitute variable
nnoremap <Leader>sv :%s/<c-r><c-w>/
vnoremap <Leader>sv y <Bar> :%s/<c-r>0/

function GoogleSearch()
  normal gv"xy
  let query = 'http://google.com/search?q=' .
        \ system('perl -MURI::Escape -e "print uri_escape(q#'. escape(@x, '#"') .'#)"')
  silent execute "! open " .
        \ shellescape(query, 'yes_please_escape_vim_special_characters_too_thank_you')
endfunction
vnoremap <Leader>s :call GoogleSearch()<cr>

" don't show ^I for go files
aut BufRead,BufNewFile *.go set nolist

" nnoremap <C-l> :redraw!<cr>

" My remapping of <C-^>. If there is no alternate file, then switch to
" previous buffer.
function SwitchToPrevBuffer()
  if expand('#')=="" | silent! bprev
  else
    exe "normal! \<c-^>"
  endif
endfu
nnoremap <C-^> :call SwitchToPrevBuffer()<CR>

hi LineNr ctermbg=NONE guibg=NONE ctermfg=14 guifg=#80a0ff
hi MatchParen      ctermfg=208  ctermbg=233 cterm=bold

" select last pasted text
nnoremap gp `[v\`]`

" autocomplete dashes too
set iskeyword+=-

" : is NOT a part of a word
set iskeyword-=:

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

:" The leader defaults to backslash, so (by default) this
:" maps \* and \g* (see :help Leader).
:" These work like * and g*, but do not move the cursor and always set hls.
map <Leader>* :let @/ = '\<'.expand('<cword>').'\>'\|set hlsearch<C-M>
map <Leader>g* :let @/ = expand('<cword>')\|set hlsearch<C-M>

if executable('rg')
  set grepprg=rg\ --vimgrep
  set grepformat=%f:%l:%c:%m
elseif executable('ag')
  set grepprg=ag\ --vimgrep
  set grepformat=%f:%l:%c:%m
endif

" clear search highlight
au BufEnter * nmap <silent> <buffer> <nowait> <Leader>c :nohls<CR>

" select last paste in visual mode
nnoremap <expr> gb '`[' . strpart(getregtype(), 0, 1) . '`]'

" search only within unfolded text
set fdo-=search

" autocmd filetype crontab setlocal nobackup nowritebackup
set nobackup
set nowritebackup

au BufNewFile,BufRead Jenkinsfile setf groovy

" Paste with indentation
nnoremap p p=`]

set ttyfast
set lazyredraw

set noshowmode

hi Visual ctermbg=darkgrey

" paste without loosing copied text
vnoremap <leader>p "_dp

packadd cfilter

" command! Ctags call system('ctags $(git ls-files)')

" also useful:
" - Ctrl-W p - go to the previous window
" - Ctrl-W t - go to top/left window
" - Ctrl-W b - go to bottom/right window
map <c-j> <C-W>j
map <c-k> <C-W>k
map <c-h> <C-W>h
map <c-l> <C-W>l

" auto close quickfix
" aug QFClose
"   au!
"   " au WinEnter * if winnr('$') == 1 && &buftype == "quickfix"|q|endif
"   au WinEnter * if &buftype != "quickfix"|cclose|endif
" aug END
