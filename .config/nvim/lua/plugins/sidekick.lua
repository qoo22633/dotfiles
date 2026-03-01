-- sidekick://prompt バッファへの入力を送るためのグローバル変数
_G.sidekick_active_terminal = nil

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
        keys = {
          -- <esc><esc> でターミナルモードを抜ける
          stopinsert = { "<esc><esc>", "stopinsert", mode = "t" },
          -- ノーマルモードの q でウィンドウを隠す
          hide_n = { "q", "hide", mode = "n" },
          -- <c-n> で sidekick://prompt バッファを開く
          insert_from_buffer = {
            "<c-n>",
            function(t)
              _G.sidekick_active_terminal = t
              local bufnr = vim.fn.bufnr("sidekick://prompt")
              if bufnr ~= -1 then
                local winid = vim.fn.bufwinid(bufnr)
                if winid ~= -1 then
                  vim.api.nvim_set_current_win(winid)
                else
                  vim.cmd(":drop sidekick://prompt")
                end
              else
                vim.cmd(":10new sidekick://prompt")
              end
            end,
          },
        },
      },
      picker = "telescope",
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

    -- sidekick://prompt: Markdownバッファで複数行プロンプトを編集して送信
    vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
      pattern = { "sidekick://prompt" },
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_option_value("filetype", "markdown", { buf = bufnr })
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
        vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })

        -- q / <c-n> で閉じる、Q で強制終了
        vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd>q<CR>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<c-n>", "<Cmd>q<CR>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(bufnr, "n", "Q", "<Cmd>q!<CR>", { noremap = true, silent = true })

        -- 開いたらすぐ insert モードに入る
        vim.schedule(function()
          vim.cmd("startinsert")
        end)

        -- <CR> でバッファの内容を Sidekick に送信
        vim.keymap.set("n", "<CR>", function()
          local sidekick_t = _G.sidekick_active_terminal
          if not sidekick_t then
            vim.notify("No active Sidekick instance found", vim.log.levels.ERROR)
            return
          end

          local current_win = vim.api.nvim_get_current_win()
          local prompt = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          sidekick_t:send(table.concat(prompt, "\n"))

          if sidekick_t:is_open() then
            sidekick_t:focus()
          end

          vim.defer_fn(function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
            vim.defer_fn(function()
              vim.api.nvim_set_current_win(current_win)
              vim.cmd("bw!")
            end, 100)
          end, 100)
        end, { noremap = true, silent = true, buffer = bufnr })
      end,
    })
  end,
}
