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
  { "wincent/terminus" },
  { "tpope/vim-fugitive" },
  { "junegunn/gv.vim" },
  { "tpope/vim-rhubarb" },
  { "tpope/vim-rails" },
  { "tpope/vim-surround" },
  { "tpope/vim-abolish" },
  { "tpope/vim-scriptease" },
  { "tpope/vim-cucumber" },
  { "tpope/vim-eunuch" },
  { "tpope/vim-unimpaired" },
  { "tpope/vim-repeat" },
  { "tpope/vim-obsession" },
  { "tpope/vim-commentary" },
  { "artemave/vigun" },
  { "artemave/vjs" },
  { "michaeljsmith/vim-indent-object" },
  { "godlygeek/tabular" },
  { "sjl/gundo.vim" },
  { "junegunn/fzf", dir = "~/.fzf", build = "./install --all" },
  { "artemave/fzf.vim" },
  { "Raimondi/delimitMate" },
  { "andymass/vim-matchup" },
  { "mg979/vim-visual-multi" },
  { "itchyny/lightline.vim" },
  { "navarasu/onedark.nvim" },
  { "tommcdo/vim-exchange" },
  { "chrisbra/NrrwRgn" },
  { "airblade/vim-gitgutter" },
  { "FooSoft/vim-argwrap" },
  { "Yggdroot/indentLine" },
  { "junegunn/vader.vim" },
  { "romainl/vim-cool" },
  { "ap/vim-css-color" },
  { "vim-scripts/scratch.vim" },
  { "kmoschcau/emmet-vim" },
  { "yssl/QFEnter" },
  { "L3MON4D3/LuaSnip", version = "v2.*", build = "make install_jsregexp" },
  { "honza/vim-snippets" },
  { "ryanoasis/vim-devicons" },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {}
    end,
  },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-treesitter/nvim-treesitter-textobjects" },
  { "JoosepAlviste/nvim-ts-context-commentstring" },
  { "nvim-lua/plenary.nvim" },
  { "jose-elias-alvarez/null-ls.nvim" },
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "quangnguyen30192/cmp-nvim-tags" },
  { "saadparwaiz1/cmp_luasnip" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  { "ray-x/cmp-treesitter" },
  { "andersevenrud/cmp-tmux" },
  { "hrsh7th/nvim-cmp" },
  { "dstein64/vim-startuptime" },
  { "MunifTanjim/nui.nvim" },
  { "nvim-telescope/telescope.nvim" },
  { "jackMort/ChatGPT.nvim" },
  { "takac/vim-hardtime" },
  { "RRethy/vim-illuminate" },
  { "AndrewRadev/linediff.vim" },
  { "AndrewRadev/splitjoin.vim" },
  { "artemave/vim-aaa" },
  { "christoomey/vim-tmux-navigator" },
  { "github/copilot.vim" },
  { "wsdjeg/vim-fetch" },
  { "ton/vim-bufsurf" },
  { "stevearc/dressing.nvim" },
  { "akinsho/flutter-tools.nvim" },
  { "m00qek/baleia.nvim" },
  { "direnv/direnv.vim" },
  { "nvim-treesitter/playground" },
  { "maxmellon/vim-jsx-pretty" },
  { "mfussenegger/nvim-dap" },
  { "nvim-neotest/nvim-nio" },
  { "rcarriga/nvim-dap-ui" },
  { "theHamsta/nvim-dap-virtual-text" },
  { "kevinhwang91/nvim-bqf" },
  { "folke/trouble.nvim" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  { "jayp0521/mason-null-ls.nvim" },
  { "RubixDev/mason-update-all" },
  { "wesQ3/vim-windowswap" },
  { "dmmulroy/tsc.nvim" },
  { "ckolkey/ts-node-action" },
  { "robitx/gp.nvim" },
  { "antoinemadec/FixCursorHold.nvim" },
  { "folke/neodev.nvim" },
  { "nvim-neotest/neotest" },
  { "sidlatau/neotest-dart" },
  { "nvim-neotest/neotest-vim-test" },
  { "nvim-neotest/neotest-plenary" },
  { "nvim-neotest/neotest-python" },
  { "olimorris/neotest-rspec" },
  { "zidhuss/neotest-minitest" },
  { "vim-test/vim-test" },
  { "artemave/workspace-diagnostics.nvim" },
  { "sindrets/diffview.nvim" },
  { "stevearc/profile.nvim" },
  { "metakirby5/codi.vim" },
  { "yetone/avante.nvim" },
})

local script_path = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
package.path = package.path .. ";" .. script_path .. "?.lua"

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
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

    require('avante').setup({
      provider = 'openai'
    })

    require("luasnip.loaders.from_snipmate").lazy_load()
    require("luasnip.loaders.from_snipmate").lazy_load({paths = {'~/.vim/mysnippets'}})
  end,
})
