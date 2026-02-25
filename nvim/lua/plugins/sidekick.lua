return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    cli = {
      win = {
        layout = "bottom", -- 下部に配置（"float"|"left"|"bottom"|"top"|"right"）
        split = {
          height = 15, -- ターミナルの高さ（行数）
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

    -- AI CLIターミナルの表示/非表示
    {
      "<c-.>",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Toggle AI CLI",
      mode = { "n", "t", "i", "x" },
    },
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Toggle AI CLI",
    },

    -- CLI選択・操作
    {
      "<leader>as",
      function()
        require("sidekick.cli").select()
      end,
      desc = "Select CLI",
    },
    {
      "<leader>ad",
      function()
        require("sidekick.cli").close()
      end,
      desc = "Detach CLI Session",
    },

    -- コンテキスト送信
    {
      "<leader>at",
      function()
        require("sidekick.cli").send({ msg = "{this}" })
      end,
      mode = { "x", "n" },
      desc = "Send This",
    },
    {
      "<leader>af",
      function()
        require("sidekick.cli").send({ msg = "{file}" })
      end,
      desc = "Send File",
    },

    -- プロンプト選択
    {
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n", "x" },
      desc = "Select Prompt",
    },

    -- Claude専用操作
    {
      "<leader>cc",
      function()
        require("sidekick.cli").toggle({ name = "claude", focus = true })
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
      "<leader>cb",
      function()
        require("sidekick.cli").send({ msg = "{file}" })
      end,
      desc = "Add Current Buffer",
    },
    {
      "<leader>cs",
      function()
        require("sidekick.cli").send({ msg = "{selection}" })
      end,
      mode = { "x" },
      desc = "Send Selection to Claude",
    },

    -- which-key用のグループ定義
    { "<leader>a", group = "ai-sidekick", mode = { "n", "v" } },
    { "<leader>c", group = "claude", mode = { "n", "v" } },
  },
  config = function(_, opts)
    require("sidekick").setup(opts)
  end,
}
