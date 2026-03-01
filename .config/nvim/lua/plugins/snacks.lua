return {
  "folke/snacks.nvim",
  opts = {
    image = {
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
