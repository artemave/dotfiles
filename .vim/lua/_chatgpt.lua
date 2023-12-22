require("chatgpt").setup({
  popup_layout = {
    center = {
      width = "100%",
      height = "100%",
    },
  },
  actions_paths = {
    '~/.config/chatgpt-nvim.actions.json'
  },
})

require('gp').setup()
