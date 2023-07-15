return {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<C-o>', ':NvimTreeToggle<CR>' },
  },
  config = function()
    require("nvim-tree").setup()
  end
}
