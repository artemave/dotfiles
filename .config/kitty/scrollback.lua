-- Without this, terminal buffers drop 24-bit colours.
vim.o.termguicolors = true
vim.api.nvim_set_hl(0, 'Normal', {})
vim.o.scrollback = 100000
vim.o.clipboard = 'unnamedplus'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.laststatus = 0
vim.o.ruler = false
vim.o.showmode = false
vim.o.showcmd = false
vim.o.swapfile = false

vim.keymap.set('n', 'q', '<cmd>qa!<cr>')
-- These enter terminal mode, which is a dead end: the terminal has no process behind it.
vim.keymap.set('n', 'i', '<nop>')
vim.keymap.set('n', 'a', '<nop>')
vim.keymap.set('n', 'I', '<nop>')
vim.keymap.set('n', 'A', '<nop>')

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    local stdin_buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(stdin_buf, 0, -1, false)
    while #lines > 0 and lines[#lines]:gsub('\27%[[%d;:]*m', ''):match('^%s*$') do
      lines[#lines] = nil
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_buf_delete(stdin_buf, { force = true })
    local channel = vim.api.nvim_open_term(buf, {})
    vim.api.nvim_chan_send(channel, table.concat(lines, '\r\n'))

    -- The terminal buffer is refreshed on a timer, after chan_send returns.
    local rendered = math.min(#lines, vim.o.scrollback)
    vim.wait(10000, function() return vim.fn.prevnonblank('$') >= rendered end, 1)
    vim.fn.cursor(vim.fn.prevnonblank('$'), 1)
    vim.cmd.normal({ 'zb', bang = true })
  end,
})
