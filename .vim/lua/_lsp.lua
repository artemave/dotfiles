require './_utils'

-- better colors for semantic token highlight
-- see :h lsp-semantic-highlight
vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = {"*.mjs", "*.js", "*.mts", "*.ts", "*.jsx", "*.tsx"},

  callback = function()
    vim.api.nvim_set_hl(0, "@lsp.type.variable", { link = "@variable" })
    vim.api.nvim_set_hl(0, "@lsp.type.property", { link = "@field" })
  end
})

local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = _border
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = _border
  }
)

vim.diagnostic.config({
  underline = false,
  float={border=_border}
})

require('lspconfig.ui.windows').default_options = {
  border = _border
}

local opts = { noremap=true, silent=true }
-- vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[l', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']l', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  -- use CTRL-] to jump to definition
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gT', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gI', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'v', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>o', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local servers = {
  'cssls',
  eslint = {
    nodePath = vim.fn.trim(vim.fn.system('mise where node')) .. '/lib'
  },
  'html',
  'jsonls',
  'sqlls',
  'pyright',
  lua_ls = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {
          'vim',
        },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
  'bashls',
  'vimls',
  'tsserver',
}

local servers_names = map(servers, function(k, v) return type(k) == "number" and v or k end)

require("mason").setup()
require("mason-lspconfig").setup({
  -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
  automatic_installation = true,
  ensure_installed = servers_names,
})
require('mason-tool-installer').setup {

  -- a list of all tools you want to ensure are installed upon
  -- start; they should be the names Mason uses for each tool
  ensure_installed = {
    'shellcheck',
    'shfmt',
    'vint', -- viml linter
    'dart-debug-adapter',
  },

  -- if set to true this will check each tool for updates. If updates
  -- are available the tool will be updated. This setting does not
  -- affect :MasonToolsUpdate or :MasonToolsInstall.
  -- Default: false
  -- auto_update = false,

  -- automatically install / update on startup. If set to false nothing
  -- will happen on startup. You can use :MasonToolsInstall or
  -- :MasonToolsUpdate to install tools and check for updates.
  -- Default: true
  -- run_on_start = true,

  -- set a delay (in ms) before the installation starts. This is only
  -- effective if run_on_start is set to true.
  -- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
  -- Default: 0
  -- start_delay = 3000, -- 3 second delay

  -- Only attempt to install if 'debounce_hours' number of hours has
  -- elapsed since the last time Neovim was started. This stores a
  -- timestamp in a file named stdpath('data')/mason-tool-installer-debounce.
  -- This is only relevant when you are using 'run_on_start'. It has no
  -- effect when running manually via ':MasonToolsInstall' etc....
  -- Default: nil
  -- debounce_hours = 5, -- at least 5 hours between attempts to install/update
}

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require'lspconfig'

for server, server_settings in pairs(servers) do
  if type(server) == 'number' then
    server = server_settings
    server_settings = nil
  end

  lspconfig[server].setup({
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 140,
    },
    root_dir = lspconfig.util.find_git_ancestor,
    settings = server_settings
  })
end

require("flutter-tools").setup {
  lsp = {
    capabilities = capabilities,
    on_attach = on_attach,
  }
}

local null_ls = require'null-ls'

local null_ls_sources = {
  null_ls.builtins.formatting.rubocop,
  null_ls.builtins.diagnostics.rubocop,

  null_ls.builtins.formatting.autopep8,
  null_ls.builtins.formatting.reorder_python_imports,
  null_ls.builtins.diagnostics.flake8,

  null_ls.builtins.code_actions.ts_node_action
}

null_ls.setup({
  sources = null_ls_sources,
  on_attach = on_attach
})

local whats_this_action = {
  method = { null_ls.methods.CODE_ACTION },
  filetypes = {},
  generator = {
    fn = function()
      local diagnostics_under_cursor = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
      if #diagnostics_under_cursor == 0 then
        return
      end

      local gp = require('gp')
      local diagnostic_under_cursor = diagnostics_under_cursor[1]
      local severity_label = vim.diagnostic.severity[diagnostic_under_cursor.severity]

      return {{
        title = "What's this about?",
        action = function()
          local current_line = vim.fn.getline('.')
          -- remove leading spaces from current_line
          current_line = current_line:gsub("^%s+", "")

          local file_type = vim.bo.filetype

          local user_message = {
            "I am editing this line of code:",
            "```".. file_type,
            current_line,
            "```",
            "and I am seeing the following diagnostic issue (severity ".. severity_label ..") reported by the language tooling:",
            "```",
            diagnostic_under_cursor.message,
            "```",
            "How do I fix it?"
          }

          local agent = gp.get_chat_agent()
          local system_prompt = "You are an expert " .. file_type .. " developer."
            .." You are helping me to fix issues reported by language tooling. "
            .. "I am not a junior developer, so be concise, but ask questions if necessary."

          local chat_buffer = gp.cmd.ChatNew({}, agent.model, system_prompt)
          -- append user_message to chat_buffer
          vim.fn.appendbufline(chat_buffer, '$', user_message)
          gp.cmd.ChatRespond({args = ""})
        end
      }}
    end
  }
}

null_ls.register(whats_this_action)

-- vim.lsp.set_log_level("debug")
