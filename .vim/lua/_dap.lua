require("dap-vscode-js").setup({
  -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
  debugger_path = vim.api.nvim_call_function('expand', { '~/projects/dotfiles/.vim/plugged/vscode-js-debug' }), -- Path to vscode-js-debug installation.
  -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
  adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
  -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
  -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
  -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
})

-- to debug dap
-- tail -f ~/.cache/nvim/dap.log
for _, language in ipairs({ "typescript", "javascript" }) do
  require("dap").configurations[language] = {
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require'dap.utils'.pick_process,
      cwd = "${workspaceFolder}",
    }
  }
end

require('dap').adapters.dart = {
  type = 'executable',
  command = vim.fn.stdpath('data') .. '/mason/bin/dart-debug-adapter',
  args = {'flutter'}
}
require('dap').configurations.dart = {
  {
    type = 'dart',
    request = 'launch',
    name = 'Launch flutter',
    dartSdkPath = vim.fn.expand('~') .. '/flutter/bin/cache/dart-sdk/',
    flutterSdkPath = vim.fn.expand('~') .. '/flutter',
    program = '${workspaceFolder}/lib/main.dart',
    cwd = '${workspaceFolder}',
  }
}

require("dap").adapters.flutter_test_debug = {
  type = "executable",
  command = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter",
  args = {"flutter_test"}
}

function vigunTestConfig()
  local testName = vim.api.nvim_call_function('vigun#TestTitleWithContext', {})

  if vim.bo.filetype == 'dart' then
    return {
      type = 'flutter_test_debug',
      request = 'launch',
      name = 'Debug flutter test',
      dartSdkPath = vim.fn.expand('~') .. '/flutter/bin/cache/dart-sdk/',
      flutterSdkPath = vim.fn.expand('~') .. '/flutter',
      program = "${file}",
      args = {'--plain-name', testName},
      cwd = "${workspaceFolder}",
    }
  end

  local runtimeArgs = {
    "./node_modules/mocha/bin/mocha.js",
    "--no-parallel",
    "--fgrep",
    testName,
    "${file}",
  }

  return {
    type = "pwa-node",
    request = "launch",
    name = "Debug Mocha Tests",
    -- trace = true, -- include debugger info
    runtimeExecutable = "node",
    runtimeArgs = runtimeArgs,
    rootPath = "${workspaceFolder}",
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
  }
end

vim.keymap.set('n', '<Leader>dt', function() require('dap').run(vigunTestConfig()) end)
vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end)
-- this is also how you attach to running process
vim.keymap.set('n', '<Leader>dc', function() require('dap').continue() end)
vim.keymap.set({'n', 'v'}, '<Leader>de', function()
  require("dapui").eval(nil, { enter = true })
end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.toggle() end)
vim.keymap.set('n', '<Leader>dd', function() require('dap').run_last() end)
vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end)
vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end)

vim.api.nvim_create_user_command('BList',
  function ()
    require('dap').list_breakpoints()
  end,
  {})

vim.api.nvim_create_user_command('BClear',
  function ()
    require('dap').clear_breakpoints()
  end,
  {})

vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })


local dap, dapui = require("dap"), require("dapui")
dapui.setup()
require("nvim-dap-virtual-text").setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
