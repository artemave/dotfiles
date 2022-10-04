local opts = { noremap=true, silent=true }
vim.diagnostic.config({
  underline = false,
})

-- vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[l', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']l', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gT', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>o', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local servers = { 'pyright', 'tsserver', 'dartls' }

for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    }
  }
end

require'lspconfig'.dartls.setup{
  cmd = { "dart", "/home/artem/snap/flutter/common/flutter/bin/cache/dart-sdk/bin/snapshots/analysis_server.dart.snapshot", "--lsp" },
}

require("null-ls").setup({
  sources = {
    require("null-ls").builtins.formatting.rubocop,
    require("null-ls").builtins.diagnostics.rubocop,

    require("null-ls").builtins.diagnostics.eslint,
    require("null-ls").builtins.formatting.eslint,
    require("null-ls").builtins.code_actions.eslint,

    require("null-ls").builtins.formatting.autopep8,
    require("null-ls").builtins.formatting.reorder_python_imports,
    require('null-ls').builtins.diagnostics.flake8
  },
  on_attach = on_attach
})

require'nvim-treesitter.configs'.setup {
  matchup = {
    enable = true,
  },
  ensure_installed = "all",
  ignore_install = { "ledger", "gdscript", "supercollider", "devicetree", "nix", "erlang", "ocamllex" },
  highlight = {
    enable = true,              -- false will disable the whole extension
  },
  indent = {
    enable = false,              -- false will disable the whole extension
  },
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",

        -- Or you can define your own textobjects like this
        -- ["iF"] = {
        --   python = "(function_definition) @function",
        --   cpp = "(function_definition) @function",
        --   c = "(function_definition) @function",
        --   java = "(method_declaration) @function",
        -- },
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
    lsp_interop = {
      enable = true,
      peek_definition_code = {
        ["dm"] = "@function.outer",
        ["dM"] = "@class.outer",
      },
    },
  },
}

RD = RD or {}

function RD.join(tbl, sep)
  local ret = ''
  for i, v in pairs(tbl) do
    ret = ret .. v .. sep
  end
  return ret:sub(1, -#sep - 1)
end

function RD.map(tbl, f)
  local t = {}
  for k,v in pairs(tbl) do
    t[k] = f(v)
  end
  return t
end

function RD.rubocop_disable()
  local current_lnum = vim.api.nvim_win_get_cursor(0)[1]
  local current_line = vim.api.nvim_get_current_line()

  local diagnostics = vim.diagnostic.get(0, { lnum = current_lnum - 1 })
  local diagnostic = diagnostics[1]

  if diagnostic and diagnostic.source == 'rubocop' then
    local code = RD.join(RD.map(diagnostics, function(d) return d.code end), ', ')

    local new_text = current_line .. ' # rubocop:disable ' .. code
    vim.api.nvim_set_current_line(new_text)

    -- if diagnostic.lnum == diagnostic.end_lnum then
    --   local new_text = current_line .. ' # rubocop:disable ' .. code
    --   vim.api.nvim_set_current_line(new_text)
    -- else
    --   local indent = tonumber(vim.call('indent', current_lnum))
    --   local padding = string.rep(' ', indent)

    --   local enable_text = padding .. '# rubocop:enable ' .. code
    --   vim.api.nvim_buf_set_lines(0, diagnostic.end_lnum + 1, diagnostic.end_lnum + 1, false, {enable_text})

    --   local disable_text = padding .. '# rubocop:disable ' .. code
    --   vim.api.nvim_buf_set_lines(0, diagnostic.lnum, diagnostic.lnum, false, {disable_text})
    -- end
  end
end

vim.api.nvim_set_keymap('n', '<space>x', '<cmd>lua RD.rubocop_disable()<CR>', {})

require('refactoring').setup({})
-- Remaps for the refactoring operations currently offered by the plugin
vim.api.nvim_set_keymap("v", "<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<leader>rf", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("v", "<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]], {noremap = true, silent = true, expr = false})

-- Extract block doesn't need visual mode
vim.api.nvim_set_keymap("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], {noremap = true, silent = true, expr = false})
vim.api.nvim_set_keymap("n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]], {noremap = true, silent = true, expr = false})

vim.api.nvim_set_keymap("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})

vim.api.nvim_set_keymap("n", "<leader>rp", ":lua require('refactoring').debug.print_var({ normal = true })<CR>", { noremap = true })
vim.api.nvim_set_keymap("v", "<leader>rp", ":lua require('refactoring').debug.print_var({})<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>rc", ":lua require('refactoring').debug.cleanup({})<CR>", { noremap = true })
