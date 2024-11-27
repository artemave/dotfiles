set nocompatible

lua <<EOF

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim
require("lazy").setup({
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
})

vim.api.nvim_create_autocmd({"User"}, {
  callback = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
      automatic_installation = true,
      ensure_installed = { 'ts_ls' },
    })

    require('lspconfig').ts_ls.setup({})
  end
})
EOF
