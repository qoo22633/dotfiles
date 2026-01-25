return {
  -- Rails development plugins
  {
    "tpope/vim-rails",
    ft = { "ruby", "eruby" },
    dependencies = {
      "tpope/vim-bundler",
      "tpope/vim-rake",
    },
  },

  -- Better Ruby syntax and indentation
  {
    "vim-ruby/vim-ruby",
    ft = "ruby",
  },

  -- RSpec support
  {
    "thoughtbot/vim-rspec",
    ft = "ruby",
    keys = {
      { "<leader>tf", "<cmd>call RunCurrentSpecFile()<cr>", desc = "Run current spec file" },
      { "<leader>tn", "<cmd>call RunNearestSpec()<cr>", desc = "Run nearest spec" },
      { "<leader>tl", "<cmd>call RunLastSpec()<cr>", desc = "Run last spec" },
      { "<leader>ta", "<cmd>call RunAllSpecs()<cr>", desc = "Run all specs" },
    },
    config = function()
      vim.g.rspec_command = "Dispatch rspec {spec}"
    end,
  },

  -- Test runner
  {
    "tpope/vim-dispatch",
    cmd = { "Dispatch", "Make", "Focus", "Start" },
  },

  -- Database interaction
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Toggle DBUI" },
    },
    config = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
    end,
  },

  -- ERB/HTML template support
  {
    "alvan/vim-closetag",
    ft = { "html", "eruby" },
    config = function()
      vim.g.closetag_filenames = "*.html,*.erb"
      vim.g.closetag_xhtml_filenames = "*.erb"
      vim.g.closetag_filetypes = "html,eruby"
    end,
  },

  -- Better file navigation for Rails
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>fr", "<cmd>Telescope find_files search_dirs=app/<cr>", desc = "Find Rails app files" },
      { "<leader>fm", "<cmd>Telescope find_files search_dirs=app/models/<cr>", desc = "Find models" },
      { "<leader>fc", "<cmd>Telescope find_files search_dirs=app/controllers/<cr>", desc = "Find controllers" },
      { "<leader>fv", "<cmd>Telescope find_files search_dirs=app/views/<cr>", desc = "Find views" },
      { "<leader>ft", "<cmd>Telescope find_files search_dirs=spec/<cr>", desc = "Find test files" },
    },
  },

  -- TreeSitter for Ruby
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "ruby",
        "erb",
        "yaml",
        "sql",
      })
    end,
  },

  -- Mason tools for Ruby/Rails
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "ruby-lsp",
        "rubocop",
        "erb-lint",
        "htmlbeautifier",
      })
    end,
  },

  -- LSP configuration for Ruby
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          mason = true,
          settings = {
            rubyLsp = {
              formatter = "rubocop",
              linters = { "rubocop" },
            },
          },
        },
      },
    },
  },

  -- Auto completion for Rails
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "kristijanhusak/vim-dadbod-completion",
    },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "vim-dadbod-completion" })
    end,
  },

  -- Rails-specific keymaps and commands
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>r", group = "Rails" },
        { "<leader>ra", "<cmd>A<cr>", desc = "Alternate file" },
        { "<leader>rr", "<cmd>R<cr>", desc = "Related file" },
        { "<leader>rm", "<cmd>Emodel<cr>", desc = "Go to model" },
        { "<leader>rc", "<cmd>Econtroller<cr>", desc = "Go to controller" },
        { "<leader>rv", "<cmd>Eview<cr>", desc = "Go to view" },
        { "<leader>rh", "<cmd>Ehelper<cr>", desc = "Go to helper" },
        { "<leader>rs", "<cmd>Espec<cr>", desc = "Go to spec" },
        { "<leader>rt", "<cmd>Etest<cr>", desc = "Go to test" },
      },
    },
  },
}
