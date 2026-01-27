return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewFileHistory",
  },
  keys = {
    {
      "<leader>gd",
      "<cmd>DiffviewOpen<cr>",
      desc = "Open Diffview",
    },
    {
      "<leader>gD",
      "<cmd>DiffviewClose<cr>",
      desc = "Close Diffview",
    },
    {
      "<leader>gh",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "File History (current file)",
    },
    {
      "<leader>gH",
      "<cmd>DiffviewFileHistory<cr>",
      desc = "File History (all)",
    },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = {
        layout = "diff2_horizontal",
      },
      merge_tool = {
        layout = "diff3_horizontal",
      },
    },
    file_panel = {
      listing_style = "tree",
      win_config = {
        width = 35,
      },
    },
  },
}
