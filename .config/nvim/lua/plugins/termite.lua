return {
  "ruicsh/termite.nvim",
  keys = {
    { "<c-/>", "<cmd>Termite toggle<cr>", desc = "Toggle terminal", mode = { "n", "t" } },
  },
  opts = {
    position = "right",
    keymaps = {
      toggle = "<c-/>",  -- snacks と同じキーに統一
      create = "<c-t>",
      next = "<c-n>",
      prev = "<c-p>",
      editor = "<c-e>",
      maximize = "<c-z>",
    },
  },
}
