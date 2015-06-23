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

Plugin 'Shougo/vimproc.vim' " after install: cd ~/.vim/bundle/vimproc.vim && make
Plugin 'Shougo/unite.vim'
let g:unite_source_rec_async_command = 'ag --follow --nocolor --nogroup --hidden -g ""'
nnoremap <Leader>f :Unite -buffer-name=files -no-split -start-insert file_rec/async:!<cr>
nnoremap <Leader>F :Unite -buffer-name=scoped_files -no-split -start-insert -path=`expand("%:p:h")` file_rec/async:!<cr>
nnoremap <Leader>b :Unite -buffer-name=buffer -no-split -start-insert buffer<cr>
nnoremap <leader>y :<C-u>Unite -no-split -buffer-name=yank history/yank<cr>

au FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
  " Overwrite settings.
  imap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  imap <silent><buffer><expr> <C-s> unite#do_action('split')
  nmap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  nmap <silent><buffer><expr> <C-s> unite#do_action('split')
endfunction

let g:molokai_original = 1
Plugin 'tomasr/molokai'

call vundle#end()            " required
filetype plugin indent on     " required! 

colorscheme molokai " this has to come after 'filetype plugin indent on'
