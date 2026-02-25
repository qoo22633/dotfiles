return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    cli = {
      win = {
        layout = "right", -- 右側に配置（"float"|"left"|"bottom"|"top"|"right"）
        split = {
          width = 50, -- ターミナルの幅（カラム数）
        },
      },
    },
  },
  keys = {
    -- NES（Next Edit Suggestions）の操作
    {
      "<tab>",
      function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>"
        end
      end,
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },

    -- ショートカット: Ctrl+.でトグル
    {
      "<c-.>",
      function()
        require("sidekick.cli").toggle({ name = "claude" })
      end,
      desc = "Toggle Claude CLI",
      mode = { "n", "t", "i", "x" },
    },

    -- Claude操作
    {
      "<leader>cc",
      function()
        require("sidekick.cli").toggle({ name = "claude" })
      end,
      desc = "Toggle Claude",
    },
    {
      "<leader>cf",
      function()
        require("sidekick.cli").toggle({ name = "claude", focus = true, open = true })
      end,
      desc = "Focus Claude",
    },
    {
      "<leader>cd",
      function()
        require("sidekick.cli").close()
      end,
      desc = "Close Claude Session",
    },
    {
      "<leader>cb",
      function()
        require("sidekick.cli").send({ msg = "{file}" })
      end,
      desc = "Send Current Buffer",
    },
    {
      "<leader>cs",
      function()
        require("sidekick.cli").send({ msg = "{selection}" })
      end,
      mode = { "x" },
      desc = "Send Selection",
    },
    {
      "<leader>ct",
      function()
        require("sidekick.cli").send({ msg = "{this}" })
      end,
      mode = { "x", "n" },
      desc = "Send This",
    },
    {
      "<leader>cp",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n", "x" },
      desc = "Select Prompt",
    },

    -- which-key用のグループ定義
    { "<leader>c", group = "claude", mode = { "n", "v" } },
  },
  config = function(_, opts)
    require("sidekick").setup(opts)
  end,
}
