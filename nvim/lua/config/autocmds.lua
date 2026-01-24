-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Rails development autocmds
local rails_group = vim.api.nvim_create_augroup("Rails", { clear = true })

-- Set proper filetype for Rails files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  group = rails_group,
  pattern = {
    "*.rb",
    "*.rake",
    "Gemfile",
    "Rakefile",
    "config.ru",
    "*.gemspec"
  },
  command = "set filetype=ruby"
})

-- Set ERB filetype
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  group = rails_group,
  pattern = "*.erb",
  command = "set filetype=eruby"
})

-- Auto-format Ruby files on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = rails_group,
  pattern = "*.rb",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Highlight Rails keywords
vim.api.nvim_create_autocmd("FileType", {
  group = rails_group,
  pattern = "ruby",
  callback = function()
    vim.cmd([[
      syntax keyword rubyRailsMethod
        \ has_many belongs_to has_one has_and_belongs_to_many
        \ validates validates_presence_of validates_uniqueness_of
        \ before_save after_save before_create after_create
        \ before_destroy after_destroy before_update after_update
        \ scope default_scope where find_by find_by! create! update!
        \ redirect_to render params session flash cookies request response
        \ before_action after_action around_action skip_before_action
        \ protect_from_forgery rescue_from respond_to format
      highlight link rubyRailsMethod Function
    ]])
  end,
})

-- Set proper indentation for Ruby files
vim.api.nvim_create_autocmd("FileType", {
  group = rails_group,
  pattern = {"ruby", "eruby"},
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- React/TypeScript development autocmds
local react_group = vim.api.nvim_create_augroup("React", { clear = true })

-- Auto-format TypeScript/JavaScript files on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = react_group,
  pattern = {"*.ts", "*.tsx", "*.js", "*.jsx"},
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Set proper indentation for JS/TS files
vim.api.nvim_create_autocmd("FileType", {
  group = react_group,
  pattern = {"javascript", "typescript", "javascriptreact", "typescriptreact"},
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Auto-organize imports on save for TypeScript files
vim.api.nvim_create_autocmd("BufWritePre", {
  group = react_group,
  pattern = {"*.ts", "*.tsx"},
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  end,
})

-- Highlight React/TypeScript keywords and hooks
vim.api.nvim_create_autocmd("FileType", {
  group = react_group,
  pattern = {"typescript", "typescriptreact", "javascript", "javascriptreact"},
  callback = function()
    vim.cmd([[
      syntax keyword reactKeywords useState useEffect useContext useReducer useCallback useMemo useRef
      syntax keyword reactKeywords useImperativeHandle useLayoutEffect useDebugValue React ReactDOM
      syntax keyword reactKeywords interface type extends implements export default import from as
      highlight link reactKeywords Function
    ]])
  end,
})

-- Auto-create index.ts when creating new component directories
vim.api.nvim_create_autocmd("BufNewFile", {
  group = react_group,
  pattern = "*/components/*/index.ts",
  callback = function()
    local dir = vim.fn.expand("%:h")
    local component_name = vim.fn.fnamemodify(dir, ":t")
    local content = string.format(
      "export { default } from './%s';\nexport * from './%s';",
      component_name,
      component_name
    )
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n"))
  end,
})
