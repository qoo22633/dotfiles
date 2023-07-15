tree = require("nvim-tree")

return {
  tree,
  {
    'neoclide/coc.nvim',
    branch = "release",
    event = "InsertEnter",
    keys = {
    },
    config = function()
      vim.g.coc_global_extensions = {
        "coc-json",
        "coc-css",
        "coc-yaml",
        "coc-sh",
        "coc-prettier",
        "coc-solargraph",
        "coc-rome"
      }
    end
  }
}
