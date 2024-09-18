require './_lsp'
require './_dap'
require './_treesitter'
require './rubocop_disable'
require './_cmp'
require './_chatgpt'
require './_trouble'
require './_test'
require './_profile'

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = {"*.tty", "*.log"},

  callback = function()
    local baleia = require('baleia')

    baleia.setup().once(vim.fn.bufnr('%'))
    vim.api.nvim_buf_set_option(0, 'buftype', 'nowrite')
  end
})

require'nvim-web-devicons'.setup { default = true }
require('tsc').setup()

require("nvim-tree").setup()
require("lsp-file-operations").setup()

require('avante').setup({
  provider = 'openai'
})

require("luasnip.loaders.from_snipmate").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load({paths = {'~/.vim/mysnippets'}})
