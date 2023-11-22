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
  openai_params = {
    model = "gpt-4-1106-preview",
  },
  openai_edit_params = {
    model = "gpt-4-1106-preview",
  },
})

