local function open_herdr()
  Snacks.terminal("herdr", {
    cwd = vim.fn.getcwd(),
    win = {
      position = "float",
      width = 0.9,
      height = 0.9,
    },
  })
end

return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>H", open_herdr, desc = "Herdr (agent multiplexer)" },
    {
      "<leader>zf",
      function() require("utils.herdr").send_file_to_agent() end,
      desc = "Send file path to herdr agent",
    },
    {
      "<leader>zl",
      function() require("utils.herdr").send_selection_to_agent() end,
      desc = "Send file path + line range to herdr agent",
      mode = "x",
    },
  },
}
