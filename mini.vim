set nocompatible

" run this in the terminal:
" sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
"       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

call plug#begin()

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
set completeopt-=preview
let g:deoplete#enable_at_startup = 1

Plug 'github/copilot.vim'

call plug#end()            " required

call deoplete#custom#option('prev_completion_mode', 'mirror')
