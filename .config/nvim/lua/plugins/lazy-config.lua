return {
  {
    "folke/lazy.nvim",
    opts = {
      rocks = {
        enabled = false,
        hererocks = false,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        yaml = {}, -- prettierによるシングルクォート変換を防ぐ
      },
    },
  },
}
