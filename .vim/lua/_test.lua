require("neotest").setup({
  adapters = {
    require("neotest-python")({
      dap = { justMyCode = false },
    }),
    require('neotest-dart'),
    require('neotest-rspec'),
    require('neotest-minitest'),
    require("neotest-plenary"),
    require("neotest-vim-test")({
      ignore_file_types = { "python", "vim", "lua", "ruby", "dart" },
    }),
  },
})

require("neodev").setup({
  library = { plugins = { "neotest" }, types = true },
})
