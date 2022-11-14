set nocompatible

" run this in the terminal:
" sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
"       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

set runtimepath=~/.vim,$VIMRUNTIME

call plug#begin('~/.vim/plugged')

Plug 'm00qek/baleia.nvim'

call plug#end()            " required

lua <<EOF
vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = {"*.tty", "*.log"},

  callback = function()
    local baleia = require('baleia')

    baleia.setup().once(vim.fn.bufnr('%'))
    vim.api.nvim_buf_set_option(0, 'buftype', 'nowrite')
  end
})
EOF
