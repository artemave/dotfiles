require './_utils'

local null_ls = require'null-ls'

null_ls.register({
  method = { null_ls.methods.CODE_ACTION },
  filetypes = { 'ruby' },
  generator = {
    fn = function()
      local current_lnum = vim.api.nvim_win_get_cursor(0)[1]
      local current_line = vim.api.nvim_get_current_line()

      local diagnostics = vim.diagnostic.get(0, { lnum = current_lnum - 1 })
      local diagnostic = diagnostics[1]

      if diagnostic and diagnostic.source == 'rubocop' then
        local code = join(map(diagnostics, function(_, v) return v.code end), ', ')

        local new_text = current_line .. ' # rubocop:disable ' .. code

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
