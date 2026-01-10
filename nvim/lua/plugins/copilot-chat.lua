return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "canary",
  dependencies = {
    { "github/copilot.vim" }, -- copilot.vimに依存
    { "nvim-lua/plenary.nvim" }, -- 非同期処理に必要
  },
  event = "VeryLazy",
  config = function()
    local chat = require("CopilotChat")
    local select = require("CopilotChat.select")

    -- プラグインがロードされた後にoptsを定義
    local opts = {
      show_help = "yes",
      prompts = {
        Explain = {
          prompt = "/COPILOT_EXPLAIN コードを日本語で説明してください",
          mapping = "<leader>ce",
          description = "コードの説明をお願いする",
        },
        Review = {
          prompt = "/COPILOT_REVIEW コードを日本語でレビューしてください。",
          mapping = "<leader>cr",
          description = "コードのレビューをお願いする",
        },
        Fix = {
          prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードを表示してください。説明は日本語でお願いします。",
          mapping = "<leader>cf",
          description = "コードの修正をお願いする",
        },
        Optimize = {
          prompt = "/COPILOT_REFACTOR 選択したコードを最適化し、パフォーマンスと向上させてください。説明は日本語でお願いします。",
          mapping = "<leader>cO", -- 大文字Oで<leader>coとの競合を回避
          description = "コードの最適化をお願いする",
        },
        Docs = {
          prompt = "/COPILOT_GENERATE 選択したコードに関するドキュメントコメントを日本語で生成してください。",
          mapping = "<leader>cd",
          description = "コードのドキュメント作成をお願いする",
        },
        Tests = {
          prompt = "/COPILOT_TESTS 選択したコードの詳細なユニットテストを書いてください。説明は日本語でお願いします。",
          mapping = "<leader>ct",
          description = "テストコード作成をお願いする",
        },
        FixDiagnostic = {
          prompt = "コードの診断結果に従って問題を修正してください。修正内容の説明は日本語でお願いします。",
          mapping = "<leader>cx", -- diagnosticのxで覚えやすく
          description = "診断結果の修正をお願いする",
          selection = select.diagnostics,
        },
        Commit = {
          prompt = "実装差分に対するコミットメッセージを日本語で記述してください。",
          mapping = "<leader>cco",
          description = "コミットメッセージの作成をお願いする",
          selection = select.gitdiff,
        },
        CommitStaged = {
          prompt = "ステージ済みの変更に対するコミットメッセージを日本語で記述してください。",
          mapping = "<leader>cs",
          description = "ステージ済みのコミットメッセージの作成をお願いする",
          selection = function(source)
            return select.gitdiff(source, true)
          end,
        },
      },
    }

    chat.setup(opts)

    -- CopilotChatを開く/閉じるトグルコマンド
    vim.api.nvim_create_user_command("CopilotChatToggle", function()
      chat.toggle()
    end, {})

    -- 追加のキーマッピング
    local keymap = vim.keymap.set

    -- CopilotChatのトグル
    keymap({ "n", "v" }, "<leader>cc", "<cmd>CopilotChatToggle<cr>", {
      desc = "Toggle CopilotChat",
    })

    -- CopilotChatを開く
    keymap({ "n", "v" }, "<leader>cC", function()
      local input = vim.fn.input("Ask Copilot: ")
      if input ~= "" then
        chat.ask(input, { selection = select.buffer })
      end
    end, {
      desc = "Ask CopilotChat",
    })

    -- 選択範囲についてチャット
    keymap("v", "<leader>cq", function()
      local input = vim.fn.input("Quick Chat: ")
      if input ~= "" then
        chat.ask(input, { selection = select.visual })
      end
    end, {
      desc = "Quick chat with selection",
    })

    -- バッファ全体についてチャット
    keymap("n", "<leader>cb", function()
      local input = vim.fn.input("Ask about buffer: ")
      if input ~= "" then
        chat.ask(input, { selection = select.buffer })
      end
    end, {
      desc = "Chat about buffer",
    })
  end,
  keys = {
    -- which-key用のグループ定義
    { "<leader>c", group = "copilot-chat", mode = { "n", "v" } },
  },
}
