source ~/.bundles.vim

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

" suggest correct spelling in CTRL_N/CTRL_P
set complete+=kspell

" copy/paste to clipboard without prepending "*
set clipboard=unnamed

" display incomplete commands
set showcmd

" make tab in v mode ident code
vmap <tab> >gv
vmap <s-tab> <gv

" paste mode - this will avoid unexpected effects when you
" cut or copy some text from one window and paste it in Vim.
set pastetoggle=<F5>

set fileformat=unix

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

set autoread

set hidden

set cryptmethod=blowfish

" command line completion
set wildchar=<Tab> wildmenu wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git*,*.rbc,*.class,.svn,vendor/gems/*,*/tmp/*,*.so,*.swp,*.zip,*/images/*,*/cache/*,scrapers/products/*

set switchbuf=useopen

autocmd User fugitive
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \   nnoremap <buffer> .. :edit %:h<CR> |
  \ endif

autocmd BufReadPost fugitive://* set bufhidden=delete

"" json highlighting
autocmd BufNewFile,BufRead *.json set ft=javascript

"" coffee script autocompile on save
""autocmd BufWritePost *.coffee silent CoffeeMake! | cwindow

" pogo script autocompile on save
autocmd BufWritePost *.pogo silent !pogo -c % &

" Thorfile, Rakefile, Vagrantfile and Gemfile are Ruby
au BufRead,BufNewFile {Gemfile,Rakefile,Capfile,Vagrantfile,Thorfile,config.ru} set ft=ruby

au BufNewFile,BufRead *.hamlc set filetype=haml

" Don't syntax highlight markdown because it's often wrong
autocmd! FileType mkd setlocal syn=off

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

nnoremap <Leader>a= :Tabularize /=<CR>
vnoremap <Leader>a= :Tabularize /=<CR>
nnoremap <Leader>a: :Tabularize /:\zs/r0c1l0<CR>
vnoremap <Leader>a: :Tabularize /:\zs/r0c1l0<CR>
nnoremap <Leader>a> :Tabularize /=><CR>
vnoremap <Leader>a> :Tabularize /=><CR>
nnoremap <Leader>ae :Tabularize /==<CR>
vnoremap <Leader>ae :Tabularize /==<CR>

let g:LustyJugglerSuppressRubyWarning = 1

function! MyCloseGdiff()
  if (&diff == 0 || getbufvar('#', '&diff') == 0)
        \ && (bufname('%') !~ '^fugitive:' && bufname('#') !~ '^fugitive:')
    echom "Not in diff view."
    return
  endif

  " close current buffer if alternate is not fugitive but current one is
  if bufname('#') !~ '^fugitive:' && bufname('%') =~ '^fugitive:'
    if bufwinnr("#") == -1
      b #
      bd #
    else
      bd
    endif
  else
    bd #
  endif
endfunction
nnoremap <Leader>D :call MyCloseGdiff()<cr>

command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
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

function! s:GrepOpenBuffers(search, jump)
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
nnoremap <Leader>S :BufGrep 

" remap 'increase number' since C-a is captured by tmux/screen
" Easier increment/decrement
nnoremap + <C-a>
nnoremap - <C-x>

set relativenumber

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" CTags
"
" $PATH appears different to vim for some reason and hence wrong ctags gets picked
" until then, you need to manually override ctags in /usr/bin/ with those from homebrew
" TODO fix vim path
map <Leader>rt :!ctags --extra=+f -R *<CR><CR>

" Remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

" Enable syntastic syntax checking
let g:syntastic_enable_signs=1
let g:syntastic_quiet_warnings=1

" Gundo configuration
nmap <F6> :GundoToggle<CR>
imap <F6> <ESC>:GundoToggle<CR>

let g:molokai_original = 1
colorscheme molokai
hi Search ctermbg=black

set scrolloff=3 " Keep 3 lines below and above the cursor"

" Store swap files in fixed location, not current directory.
set dir=~/.vimswap//,/var/tmp//,/tmp//,."

nnoremap <CR> :nohls<CR><CR>

" Make Y behave like other capitals
nnoremap Y y$

" Improve up/down movement on wrapped lines
nnoremap j gj
nnoremap k gk

" Use very magic regexes
nnoremap / /\v
vnoremap / /\v

" Better comand-line editing
cnoremap <C-j> <t_kd>
cnoremap <C-k> <t_ku>
cnoremap <C-^> <Home>
cnoremap <C-e> <End>

" Drag Current Line/s Vertically
nnoremap <M-j> :m+<CR>
nnoremap <M-k> :m-2<CR>
inoremap <M-j> <Esc>:m+<CR>
inoremap <M-k> <Esc>:m-2<CR>
vnoremap <M-j> :m'>+<CR>gv

" Disable paste mode when leaving Insert Mode
au InsertLeave * set nopaste

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" Quick grep for word under the cursor in rails app
noremap <Leader>f :Ag <cword><cr>

" Stop messing with my arrow keys
if !has("gui_running")
  let g:AutoClosePreservDotReg = 0
endif

map <leader>y "*y

" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PROMOTE VARIABLE TO RSPEC LET
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! PromoteToLet()
  :normal! dd
  " :exec '?^\s*it\>'
  :normal! P
  :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
  :normal ==
endfunction
:command! PromoteToLet :call PromoteToLet()
:map <leader>p :PromoteToLet<cr>

" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EXTRACT VARIABLE (SKETCHY)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! ExtractVariable()
  let name = input("Variable name: ")
  if name == ''
    return
  endif
  " Enter visual mode (not sure why this is needed since we're already in
  " visual mode anyway)
  normal! gv

  " Replace selected text with the variable name
  exec "normal c" . name
  " Define the variable on the line above
  exec "normal! O" . name . " = "
  " Paste the original selected text to be the variable value
  normal! $p
endfunction
vnoremap <leader>rv :call ExtractVariable()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SWITCH BETWEEN TEST AND PRODUCTION CODE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! OpenTestAlternate()
  let new_file = AlternateForCurrentFile()
  exec ':e ' . new_file
endfunction
function! AlternateForCurrentFile()
  let current_file = expand("%")
  let new_file = current_file
  let in_spec = match(current_file, '^spec/') != -1
  let going_to_spec = !in_spec
  let in_app = match(current_file, '\<controllers\>') != -1 || match(current_file, '\<models\>') != -1 || match(current_file, '\<views\>') != -1
  if going_to_spec
    " if in_app
    "   let new_file = substitute(new_file, '^app/', '', '')
    " end
    let new_file = substitute(new_file, '^\(app\|lib\)/', '', '')
    let new_file = substitute(new_file, '\.rb$', '_spec.rb', '')
    let new_file = 'spec/' . new_file
  else
    let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
    let new_file = substitute(new_file, '^spec/', '', '')
    let root_path = 'lib/'
    if in_app
      let root_path = 'app/'
    end
    let new_file = root_path . new_file
  endif
  return new_file
endfunction
nnoremap <leader>. :call OpenTestAlternate()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ARROW KEYS ARE UNACCEPTABLE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>

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

nnoremap <Leader>b :CtrlPBuffer<CR>
let g:ctrlp_show_hidden = 1

" disable folding
set nofoldenable

" alias backtick to signle quote
map ' `

let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1

" omni completion"
set ofu=syntaxcomplete#Complete

" PowerLine recommeneded:
set laststatus=2   " Always show the statusline"
set encoding=utf-8 " Necessary to show Unicode glyphs"

fun! RangerChooser()
  exec "silent !ranger --choosefile=/tmp/chosenfile " . expand("%:p:h")
  if filereadable('/tmp/chosenfile')
    exec 'edit ' . system('cat /tmp/chosenfile')
    call system('rm /tmp/chosenfile')
  endif
  redraw!
endfun
map <Leader><Leader>r :call RangerChooser()<CR>

""set cursorline

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>t :call RunTestFile()<cr>
map <leader>T :call RunNearestTest()<cr>

function! RunTestFile(...)
  if a:0
    let command_suffix = a:1
  else
    let command_suffix = ""
  endif

  " Run the tests for the previously-marked file.
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
  if in_test_file
    call SetTestFile()
  elseif !exists("t:grb_test_file")
    return
  end
  call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
  let spec_line_number = line('.')
  call RunTestFile(":" . spec_line_number)
endfunction

function! SetTestFile()
  " Set the spec file that tests will be run for.
  let t:grb_test_file=@%
endfunction

function! RunTests(filename)
  :wa
  if match(a:filename, '\.feature') != -1
    let l:command = "zeus cucumber " . a:filename
  else
    let l:command = "zeus rspec -c " . a:filename
  end
  call system("tmux select-window -t " . g:run_tests_in_window)
  call system('tmux set-buffer "' . l:command . "\n\"")
  call system('tmux paste-buffer -d -t ' . g:run_tests_in_window)
endfunction

let g:run_tests_in_window = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS (END)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SHOW SPEC INDEX
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! ShowSpecIndex()
  call setqflist([])

  for line_number in range(1,line('$'))
    if getline(line_number) =~ '^ *\(\<its\?\>\|\<describe\>\|\<context\>\)'
      let expr = printf('%s:%s:%s', expand("%"), line_number, substitute(getline(line_number), ' ', nr2char(160), ''))
      caddexpr expr
    endif
  endfor

  copen

  " hide filename and linenumber
  set conceallevel=2 concealcursor=nc
  syntax match qfFileName /^[^|]*|[^|]*| / transparent conceal
endfunction

nnoremap <Leader>si :call ShowSpecIndex()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SHOW SPEC INDEX (END)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:yankring_replace_n_pkey = '<c-n>'
let g:yankring_replace_n_nkey = ''
nnoremap <Leader>re :YRShow<cr>

" useful when <Tab> -> <Esc>
" let g:snips_trigger_key='<C-@>' " this is <C-Space> that works

" tslime
vmap <C-c><C-c> <Plug>SendSelectionToTmux
nmap <C-c><C-c> <Plug>NormalModeSendToTmux
nmap <C-c>r <Plug>SetTmuxVars

" substitute variable
nnoremap <Leader>sv :%s/<c-r><c-w>/
vnoremap <Leader>sv y <Bar> :%s/<c-r>0/

" mustache with m
let g:surround_109 = "{{\r}}"

function! GoogleSearch()
  normal gv"xy
  let query = 'http://google.com/search?q=' .
        \ system('perl -MURI::Escape -e "print uri_escape(q#'. escape(@x, '#"') .'#)"')
  silent execute "! open " .
        \ shellescape(query, 'yes_please_escape_vim_special_characters_too_thank_you')
endfunction
vnoremap <Leader>s :call GoogleSearch()<cr>

autocmd BufWritePre *.go Fmt
" don't show ^I for go files
aut BufRead,BufNewFile *.go set nolist

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadBraces
