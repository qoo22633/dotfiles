return {
  "folke/snacks.nvim",
  keys = {
    -- termite.nvim に任せるため snacks terminal のキーマップを無効化
    { "<c-/>", false },
    { "<c-_>", false },
  },
  opts = {
    image = {
      enabled = false,
    },
    terminal = {
      enabled = false,
    },
    picker = {
      actions = {
        sidekick_send = function(...)
          return require("sidekick.cli.picker.snacks").send(...)
        end,
      },
      win = {
        input = {
          keys = {
            ["<a-a>"] = { "sidekick_send", mode = { "n", "i" } },
          },
        },
      },
    },
  },
}
