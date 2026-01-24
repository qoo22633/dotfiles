return {
  -- TypeScript and React language support
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.linting.eslint" },
  { import = "lazyvim.plugins.extras.formatting.prettier" },

  -- React development plugins
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact" },
    config = true,
  },

  -- Better JSX/TSX support
  {
    "maxmellon/vim-jsx-pretty",
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  },

  -- Component navigation and creation
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>fc", "<cmd>Telescope find_files search_dirs=src/components/<cr>", desc = "Find components" },
      { "<leader>fh", "<cmd>Telescope find_files search_dirs=src/hooks/<cr>", desc = "Find hooks" },
      { "<leader>fp", "<cmd>Telescope find_files search_dirs=src/pages/<cr>", desc = "Find pages" },
      { "<leader>fu", "<cmd>Telescope find_files search_dirs=src/utils/<cr>", desc = "Find utils" },
      { "<leader>fs", "<cmd>Telescope find_files search_dirs=src/store/<cr>", desc = "Find store files" },
      { "<leader>ft", "<cmd>Telescope find_files search_dirs=src/**/*.test.*<cr>", desc = "Find tests" },
      { "<leader>fS", "<cmd>Telescope find_files search_dirs=src/**/*.stories.*<cr>", desc = "Find stories" },
    },
  },

  -- Enhanced TypeScript support
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "typescript", "typescriptreact" },
    opts = {
      settings = {
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },

  -- React snippets and auto-completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "mlaursen/vim-react-snippets",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
      }))
    end,
  },

  -- TreeSitter enhancements
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "javascript",
        "typescript",
        "tsx",
        "jsx",
        "json",
        "css",
        "scss",
        "html",
      })
    end,
  },

  -- React testing utilities
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "npm test --",
          jestConfigFile = "jest.config.js",
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
        ["neotest-vitest"] = {},
      },
    },
    keys = {
      { "<leader>tr", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run nearest test" },
      { "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "Run current file" },
      { "<leader>td", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = "Debug nearest test" },
      { "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "Toggle test summary" },
      { "<leader>to", "<cmd>lua require('neotest').output.open({ enter = true })<cr>", desc = "Show test output" },
    },
  },

  -- Package.json management
  {
    "vuki656/package-info.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    ft = "json",
    config = true,
    keys = {
      { "<leader>ns", "<cmd>lua require('package-info').show()<cr>", desc = "Show package info" },
      { "<leader>nu", "<cmd>lua require('package-info').update()<cr>", desc = "Update package" },
      { "<leader>nd", "<cmd>lua require('package-info').delete()<cr>", desc = "Delete package" },
      { "<leader>ni", "<cmd>lua require('package-info').install()<cr>", desc = "Install package" },
      { "<leader>nv", "<cmd>lua require('package-info').change_version()<cr>", desc = "Change version" },
    },
  },

  -- Mason tools for React/TS development
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript-language-server",
        "eslint-lsp",
        "prettier",
        "js-debug-adapter",
      })
    end,
  },

  -- React component generation
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>c", group = "Component" },
        { "<leader>cf", "<cmd>!mkdir -p %:h && touch %:h/index.ts<cr>", desc = "Create index file" },
        { "<leader>ct", "<cmd>!touch %:r.test.tsx<cr>", desc = "Create test file" },
        { "<leader>cs", "<cmd>!touch %:r.stories.tsx<cr>", desc = "Create story file" },
        { "<leader>n", group = "NPM" },
        { "<leader>r", group = "React/Run" },
        { "<leader>rr", "<cmd>!npm run dev<cr>", desc = "Start dev server" },
        { "<leader>rb", "<cmd>!npm run build<cr>", desc = "Build project" },
        { "<leader>rt", "<cmd>!npm test<cr>", desc = "Run tests" },
        { "<leader>rl", "<cmd>!npm run lint<cr>", desc = "Run linter" },
        { "<leader>rp", "<cmd>!npm run preview<cr>", desc = "Preview build" },
      },
    },
  },

  -- Enhanced LSP settings for React
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
          },
        },
      },
    },
  },
}