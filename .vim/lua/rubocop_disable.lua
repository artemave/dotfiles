require './_utils'

local null_ls = require'null-ls'

null_ls.register({
  method = { null_ls.methods.CODE_ACTION },
  filetypes = { 'ruby', 'eruby' },
  generator = {
    fn = function()
      local current_lnum = vim.api.nvim_win_get_cursor(0)[1]
      local current_line = vim.api.nvim_get_current_line()

      local diagnostics = vim.diagnostic.get(0, { lnum = current_lnum - 1 })
      local diagnostic = diagnostics[1]

      local code

      if diagnostic and diagnostic.source == 'rubocop' then
        code = join(map(diagnostics, function(_, v) return v.code end), ', ')
      end

      if diagnostic and diagnostic.source == 'erb-lint' then
        code = join(map(diagnostics, function(_, v) return vim.split(v.message, ':')[1] end), ', ')
      end

      if code then
        local new_text = current_line .. ' # rubocop:disable ' .. code

        return {{
          title = 'Disable rubocop rule(s)',
          action = function()
            vim.api.nvim_set_current_line(new_text)
          end
        }}
      end
    end
  }
})
