return {
  "github/copilot.vim",
  event = "VeryLazy", -- InsertEnterよりも早く読み込んでコマンドを利用可能にする
  cmd = { "Copilot" }, -- コマンドによる遅延読み込みも有効化
  config = function()
    -- Copilotの設定
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_tab_fallback = ""

    -- キーマッピング
    local keymap = vim.keymap.set

    -- Insertモード用のキーマッピング（<leader>coプレフィックス）
    keymap("i", "<leader>coa", 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
      silent = true,
      desc = "Accept suggestion",
    })
    keymap("i", "<leader>cow", "<Plug>(copilot-accept-word)", {
      silent = true,
      desc = "Accept word",
    })
    keymap("i", "<leader>cod", "<Plug>(copilot-dismiss)", {
      silent = true,
      desc = "Dismiss suggestion",
    })
    keymap("i", "<leader>con", "<Plug>(copilot-next)", {
      silent = true,
      desc = "Next suggestion",
    })
    keymap("i", "<leader>cop", "<Plug>(copilot-previous)", {
      silent = true,
      desc = "Previous suggestion",
    })

    -- Normalモード用のキーマッピング（Copilotコマンド操作）
    keymap("n", "<leader>coe", "<cmd>Copilot enable<cr>", {
      silent = true,
      desc = "Enable Copilot",
    })
    keymap("n", "<leader>coD", "<cmd>Copilot disable<cr>", {
      silent = true,
      desc = "Disable Copilot",
    })
    keymap("n", "<leader>cos", "<cmd>Copilot status<cr>", {
      silent = true,
      desc = "Show status",
    })
    keymap("n", "<leader>cop", "<cmd>Copilot panel<cr>", {
      silent = true,
      desc = "Open panel",
    })
  end,
  keys = {
    -- which-key用のグループ定義
    { "<leader>co", group = "copilot", mode = { "n", "i" } },
  },
}
