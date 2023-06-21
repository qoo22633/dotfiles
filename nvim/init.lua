-- encoding
vim.o.encofing = 'utf-8'
vim.scriptencoding = 'utf-8'

-- visual
vim.o.ambiwidth = 'double'
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true

vim.o.visualbell = true
vim.o.number = true
vim.o.showmatch = true
vim.o.matchtime = 1

-- search
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true

-- manipulation
vim.g.mapleader = ' '
vim.o.ttimeout = true
vim.o.ttimeoutlen = 50


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<C-w>', ':NvimTreeToggle<CR>' },
      { '<C-o>', ':NvimTreeFindFile<CR>' }
    },
    config = function()
      require("nvim-tree").setup()
    end
  },
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
})
