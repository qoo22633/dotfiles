return {
  "FabijanZulj/blame.nvim",
  cmd = { "BlameToggle" },
  keys = {
    { "<leader>gb", "<cmd>BlameToggle window<cr>", desc = "Git Blame (window)" },
    { "<leader>gv", "<cmd>BlameToggle virtual<cr>", desc = "Git Blame (virtual)" },
  },
  opts = {
    date_format = "%Y/%m/%d",
    virtual_style = "right_align",
    views = {
      window = {
        wintype = "split",
        width = 45,
      },
    },
    merge_consecutive = false,
    max_summary_width = 30,
  },
}
