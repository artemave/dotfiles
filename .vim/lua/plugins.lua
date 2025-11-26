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

local script_path = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
package.path = package.path .. ";" .. script_path .. "?.lua"

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
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>o', '<cmd>lua vim.lsp.buf.format({ timeout_ms = 5000 })<CR>', opts)

  require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
end

-- vim.api.nvim_set_keymap('n', '<space>x', '', {
--   noremap = true,
--   callback = function()
--     for _, client in ipairs(vim.lsp.buf_get_clients()) do
--       require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
--     end
--   end
-- })

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = ""
  }
  vim.lsp.buf.execute_command(params)
end

local servers = {
  'cssls',
  eslint = {
    nodePath = vim.fn.trim(vim.fn.system('mise where node')) .. '/lib'
  },
  'html',
  -- 'rubocop',
  -- 'ruby_lsp',
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
  ts_ls = {
    commands = {
      OrganizeImports = {
        organize_imports,
        description = "Organize Imports"
      }
    }
  },
}

local servers_names = map(servers, function(k, v) return type(k) == "number" and v or k end)

-- This should be moved into lazy "config" functions. Otherwise this might run too late (e.g. after lsp's on_attach functions are collected to be called)
vim.api.nvim_create_autocmd({"User"}, {
  callback = function()
    -- require './_dap'
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
  end,
})


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
  {
    "artemave/vigun",
    -- dir = "~/projects/vigun",
  },
  { "artemave/vjs" },
  { "michaeljsmith/vim-indent-object" },
  { "godlygeek/tabular" },
  { "sjl/gundo.vim" },
  {
    "junegunn/fzf",
    build = ":call fzf#install()",
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local fzf_lua = require("fzf-lua")

      fzf_lua.setup({
        keymap = {
          fzf = {
            ["ctrl-a"] = "select-all",
          },
        },
        winopts = {
          fullscreen = true
        },
        grep = {
          -- add 'hidden' to default options
          rg_opts = '--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
        },
        previewers = {
          git_diff = {
            -- if required, use `{file}` for argument positioning
            -- e.g. `cmd_modified = "git diff --color HEAD {file} | cut -c -30"`
            cmd_deleted     = "git diff --no-ext-diff --color HEAD --",
            cmd_modified    = "git diff --no-ext-diff --color HEAD",
            cmd_untracked   = "git diff --no-ext-diff --color --no-index /dev/null",
            -- git-delta is automatically detected as pager, set `pager=false`
            -- to disable, can also be set under 'git.status.preview_pager'
          },
        }
      })
      vim.keymap.set("n", "<leader>d", function()
        local main_git_branch = vim.fn.trim(vim.fn.system("git rev-parse --abbrev-ref origin/HEAD | sed 's|^origin/||'"))
        local cmd = 'git diff --no-ext-diff "$(git merge-base ' .. main_git_branch .. ' HEAD)" | diff2vimgrep | sort -u'
        fzf_lua.grep {
          raw_cmd = cmd
        }
      end, { desc = "Git diff master" })

      vim.keymap.set('n', '<leader><leader>l', fzf_lua.builtin)

      vim.keymap.set('n', '<leader><leader>s', fzf_lua.grep_cword, { desc = "Grep word under cursor" })
      vim.keymap.set('n', '<leader>s', fzf_lua.live_grep, { desc = "Live grep" })
      vim.keymap.set('n', '<leader>S', fzf_lua.blines, { desc = "Buffer lines" })
      vim.keymap.set('n', '<leader>f', fzf_lua.files, { desc = "Find files" })
      vim.keymap.set('n', '<leader>F', function()
        fzf_lua.files({ cwd = vim.fn.expand('%:h') })
      end, { desc = "Find files in current directory" })
      vim.keymap.set('n', '<leader>b', fzf_lua.buffers, { desc = "Buffers" })
      vim.keymap.set('n', '<leader>B', fzf_lua.lines, { desc = "Lines in loaded buffers" })
      vim.keymap.set('n', '<leader>G', fzf_lua.git_status, { desc = "Git status" })
      vim.keymap.set('n', '<leader>u', fzf_lua.resume, { desc = "Resume last picker" })
      vim.keymap.set('n', '<leader>c', fzf_lua.commands, { desc = "Commands" })
      vim.keymap.set('v', '<leader>v', fzf_lua.grep_visual, { desc = "Grep visual selection" })

      vim.keymap.set(
        { "n", "v", "i" },
        "<C-x><C-f>",
        function() FzfLua.complete_path() end,
        { silent = true, desc = "Fuzzy complete path" }
      )
    end
  },
  { "Raimondi/delimitMate" },
  { "andymass/vim-matchup" },
  { "mg979/vim-visual-multi" },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup()
    end
  },
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
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "honza/vim-snippets",
    },
    version = "v2.*",
    build = "make install_jsregexp",
    config = function()
      require("luasnip.loaders.from_snipmate").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load({paths = {'~/.vim/mysnippets'}})

      local ls = require("luasnip")

      vim.keymap.set({"i"}, "<Tab>", function() ls.expand() end, {silent = true})
      vim.keymap.set({"i", "s"}, "<C-N>", function() ls.jump( 1) end, {silent = true})
      vim.keymap.set({"i", "s"}, "<C-P>", function() ls.jump(-1) end, {silent = true})
    end,
  },
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
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- taken from https://phelipetls.github.io/posts/mdx-syntax-highlight-treesitter-nvim/
      -- this has no effect for some reason. I had to move this to .vimrc
      -- vim.filetype.add({
      --   extension = {
      --     mdx = 'mdx'
      --   }
      -- })
      vim.treesitter.language.register('markdown', 'mdx')

      require'nvim-treesitter.configs'.setup {
        matchup = {
          enable = true,
        },
        ensure_installed = {
          "javascript",
          "typescript",
          "ruby",
          "bash",
          "sql",
          "css",
          "html",
          "dart",
          "go",
          "vim",
          "vimdoc",
          "lua",
          "markdown",
          "python"
        },
        highlight = {
          enable = true,              -- false will disable the whole extension
          -- this fucks up ruby indendations
          disable = { 'vimscript', 'ruby', 'eruby' } -- suddenly it's very slow (vimscript)
        },
        -- this module indents ruby wierdly - e.g. it indents back wnen . is appended to the word
        -- indent = {
        --   enable = true,              -- false will disable the whole extension
        -- },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gmn", -- set to `false` to disable one of the mappings
            node_incremental = "gmr",
            scope_incremental = "gmc",
            node_decremental = "gmm",
          },
        },
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
          },
        }
      }
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require'nvim-treesitter.configs'.setup {
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
              -- Or you can define your own textobjects like this
              -- ["iF"] = {
              --   python = "(function_definition) @function",
              --   cpp = "(function_definition) @function",
              --   c = "(function_definition) @function",
              --   java = "(method_declaration) @function",
              -- },
            },
            include_surrounding_whitespace = true,
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
              ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
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
              ["[s"] = { query = "@scope", query_group = "locals", desc = "Previous scope" },
            },
            goto_next = {
              ["]d"] = "@conditional.outer",
            },
            goto_previous = {
              ["[d"] = "@conditional.outer",
            }
          },
          lsp_interop = {
            enable = true,
            border = 'single',
            peek_definition_code = {
              ["dm"] = "@function.outer",
              ["dM"] = "@class.outer",
            },
          },
        }
      }

      local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

      -- Repeat movement with ; and ,
      -- ensure ; goes forward and , goes backward regardless of the last direction
      -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
      -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

      -- vim way: ; goes to the direction you were moving.
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

      -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
    end
  },
  { "JoosepAlviste/nvim-ts-context-commentstring" },
  { "nvim-lua/plenary.nvim" },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvimtools/none-ls-extras.nvim",
    },
    config = function()
      local null_ls = require'null-ls'

      null_ls.builtins.diagnostics.rubocop._opts.command = 'bundle'
      null_ls.builtins.diagnostics.rubocop._opts.args = { "exec", "rubocop", "-f", "json", "--force-exclusion", "--stdin", "$FILENAME" }

      null_ls.builtins.diagnostics.erb_lint._opts.command = 'bundle'
      null_ls.builtins.diagnostics.erb_lint._opts.args = { "exec", "erb_lint", "--format", "json", "--stdin", "$FILENAME" }

      null_ls.builtins.formatting.rubocop._opts.command = 'bundle'
      null_ls.builtins.formatting.rubocop._opts.args = { "exec", "rubocop", "-a", "--server", "-f", "quiet", "--stderr", "--stdin", "$FILENAME" }

      null_ls.builtins.formatting.erb_lint._opts.command = 'bundle'
      null_ls.builtins.formatting.erb_lint._opts.args = { "exec", "erb_lint", "--autocorrect", "--stdin", "$FILENAME" }

      local null_ls_sources = {
        null_ls.builtins.diagnostics.rubocop,
        null_ls.builtins.formatting.rubocop,

        null_ls.builtins.diagnostics.stylelint,
        null_ls.builtins.formatting.stylelint,

        null_ls.builtins.diagnostics.erb_lint,
        null_ls.builtins.formatting.erb_lint,

        null_ls.builtins.code_actions.ts_node_action,

        require("none-ls.diagnostics.flake8"),
        require("none-ls.formatting.jq"),
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

            local function send_to_claude(prompt)
              vim.fn.system({'tmux', 'select-window', '-t', 'claude'})

              vim.fn.system({'tmux', 'send-keys', 'C-c'})
              vim.fn.system({'tmux', 'send-keys', prompt, 'Enter'})
            end

            return {{
              title = "Just fucking fix it",
              action = function()
                local current_line = vim.fn.getline('.')
                -- remove leading spaces from current_line
                current_line = current_line:gsub("^%s+", "")

                local file_type = vim.bo.filetype
                local line_number = vim.fn.line('.')
                local file_path = vim.fn.expand('%')

                local user_message = {
                  "This code (" .. file_path .. ":" .. line_number .. "):",
                  '',
                  current_line,
                  '',
                  "has the following diagnostic error(s):",
                }
                for _, diagnostic in ipairs(diagnostics_under_cursor) do
                  local severity_label = vim.diagnostic.severity[diagnostic.severity]
                  table.insert(user_message, '- ' .. severity_label .. ': ' .. diagnostic.message)
                end

                table.insert(user_message, '')
                table.insert(user_message, "Fix it.")

                send_to_claude(table.concat(user_message, "\n"))
              end
            }}
          end
        }
      }

      null_ls.register(whats_this_action)
    end
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require('lspconfig.ui.windows').default_options = {
        border = _border
      }

      for server, server_settings in pairs(servers) do
        if type(server) == 'number' then
          server = server_settings
          server_settings = {}
        end

        vim.lsp.config(server,
          vim.tbl_deep_extend(
            'force',
            {
              on_attach = on_attach,
            },
            server_settings
          )
        )
      end
    end
  },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "quangnguyen30192/cmp-nvim-tags" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  { "ray-x/cmp-treesitter" },
  {
    "andersevenrud/cmp-tmux",
    dir = "~/projects/cmp-tmux",
  },
  { "hrsh7th/nvim-cmp" },
  { "dstein64/vim-startuptime" },
  { "MunifTanjim/nui.nvim" },
  { "nvim-telescope/telescope.nvim" },
  { "jackMort/ChatGPT.nvim" },
  {
    "takac/vim-hardtime",
    init = function ()
      vim.g.hardtime_default_on = 1
      vim.g.hardtime_ignore_quickfix = 1
      vim.g.hardtime_ignore_buffer_patterns = { "NERD.*", "fugitive:" }
      vim.g.list_of_normal_keys = { "h", "j", "k", "l" }
      vim.g.list_of_visual_keys = { "h", "j", "k", "l" }
    end
  },
  { "RRethy/vim-illuminate" },
  { "AndrewRadev/linediff.vim" },
  { "AndrewRadev/splitjoin.vim" },
  { "artemave/vim-aaa" },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  -- { "github/copilot.vim" },
  { "copilotlsp-nvim/copilot-lsp" },
  {
    "zbirenbaum/copilot.lua",
    requires = {
      "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
    },
    config = function()
      require("copilot").setup({})
    end
  }, -- for providers='copilot'
  { "wsdjeg/vim-fetch" },
  { "ton/vim-bufsurf" },
  { "stevearc/dressing.nvim" },
  {
    "akinsho/flutter-tools.nvim",
    config = function()
      require("flutter-tools").setup {
        lsp = {
          -- capabilities = capabilities,
          on_attach = on_attach,
        }
      }
    end
  },
  { "m00qek/baleia.nvim" },
  { "direnv/direnv.vim" },
  {
    "nvim-treesitter/playground",
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  { "mfussenegger/nvim-dap" },
  { "nvim-neotest/nvim-nio" },
  { "rcarriga/nvim-dap-ui" },
  { "theHamsta/nvim-dap-virtual-text" },
  { "kevinhwang91/nvim-bqf" },
  { "folke/trouble.nvim" },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
        automatic_installation = true,
        ensure_installed = servers_names,
      })
    end
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require('mason-tool-installer').setup {

        -- a list of all tools you want to ensure are installed upon
        -- start; they should be the names Mason uses for each tool
        ensure_installed = {
          'shellcheck',
          'shfmt',
          'vint', -- viml linter
          'dart-debug-adapter',
          'flake8'
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
    end
  },
  { "RubixDev/mason-update-all" },
  { "wesQ3/vim-windowswap" },
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
  {
    "artemave/workspace-diagnostics.nvim",
    -- dir = "~/projects/workspace-diagnostics.nvim"
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({
        view = {
          merge_tool = {
            layout = "diff3_mixed",
          }
        }
      })
    end
  },
  { "stevearc/profile.nvim" },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        provider = "none", -- no UI actions; server + tools remain available
      },
    },
    config = true,
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
})

vim.api.nvim_create_autocmd({"WinEnter", "BufWinEnter"}, {
  callback = function()
    if vim.bo.buftype == "quickfix" then
      vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':cclose<CR>', { noremap = true, silent = true })
    end
  end,
})

-- vim.lsp.set_log_level("debug")
