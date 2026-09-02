-- markview.nvim: Neovim 内で markdown をレンダリングするプレビューア。
-- ブラウザや node/deno を使わず、バッファ内描画と縦分割プレビューの両方に対応する。
return {
  {
    "OXY2DEV/markview.nvim",
    -- lazy-load してはいけない。プラグイン側で遅延最適化済みで、かつ highlight group を
    -- カラースキームから動的生成するため、カラースキームより後に読み込む必要がある。
    lazy = false,
    opts = {
      preview = {
        -- mini.icons は LazyVim が既に読み込んでいるので、コードブロックのラベルに流用する
        icon_provider = "mini",

        -- hybrid mode: カーソル周辺だけ生の markdown を表示してリンクやテーブルを編集しやすくする。
        -- 常時 ON だとカーソル移動で表示が揺れるため、起動時は OFF にして <leader>mh で切り替える。
        enable_hybrid_mode = false,
        hybrid_modes = { "n" },
        linewise_hybrid_mode = true,
      },
    },
    config = function(_, opts)
      require("markview").setup(opts)

      -- lazy = false のため lazy.nvim の keys handler は張られない。
      -- markdown 系バッファに入ったときだけ buffer-local にマップする。
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "quarto", "rmd" },
        callback = function(ev)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          map("<leader>mp", "<cmd>Markview splitToggle<cr>", "Split preview")
          map("<leader>mt", "<cmd>Markview toggle<cr>", "Toggle rendering")
          map("<leader>mh", "<cmd>Markview hybridToggle<cr>", "Toggle hybrid mode")
        end,
      })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>m", group = "markview" },
      },
    },
  },
}
