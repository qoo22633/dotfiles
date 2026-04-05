return {
  "FabijanZulj/blame.nvim",
  cmd = { "BlameToggle" },
  keys = {
    { "<leader>gb", "<cmd>BlameToggle window<cr>", desc = "Git Blame (window)" },
    { "<leader>gv", "<cmd>BlameToggle virtual<cr>", desc = "Git Blame (virtual)" },
  },
  opts = {
    date_format = "%r",
    virtual_style = "right_align",
    focus_blame = false,
    commit_detail_view = "tab",
    blame_options = { "-w" },
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
