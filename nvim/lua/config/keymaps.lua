-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Rails development keymaps
if vim.fn.isdirectory("app") == 1 then
  -- Quick file navigation
  map("n", "<leader>em", ":Emodel<space>", { desc = "Edit model" })
  map("n", "<leader>ec", ":Econtroller<space>", { desc = "Edit controller" })
  map("n", "<leader>ev", ":Eview<space>", { desc = "Edit view" })
  map("n", "<leader>eh", ":Ehelper<space>", { desc = "Edit helper" })
  map("n", "<leader>es", ":Espec<space>", { desc = "Edit spec" })
  
  -- Rails console
  map("n", "<leader>rc", ":!rails console<cr>", { desc = "Rails console" })
  map("n", "<leader>rs", ":!rails server<cr>", { desc = "Rails server" })
  map("n", "<leader>rg", ":!rails generate<space>", { desc = "Rails generate" })
  map("n", "<leader>rd", ":!rails destroy<space>", { desc = "Rails destroy" })
  map("n", "<leader>rR", ":!bin/rails routes | grep<space>", { desc = "Search routes" })
  
  -- Database operations
  map("n", "<leader>dm", ":!rails db:migrate<cr>", { desc = "Run migrations" })
  map("n", "<leader>dr", ":!rails db:rollback<cr>", { desc = "Rollback migration" })
  map("n", "<leader>ds", ":!rails db:seed<cr>", { desc = "Seed database" })
  map("n", "<leader>dd", ":!rails db:drop<cr>", { desc = "Drop database" })
  map("n", "<leader>dc", ":!rails db:create<cr>", { desc = "Create database" })
end

-- Ruby development keymaps
map("n", "<leader>rb", ":!bundle install<cr>", { desc = "Bundle install" })
map("n", "<leader>ru", ":!bundle update<cr>", { desc = "Bundle update" })

-- React/TypeScript development keymaps
if vim.fn.isdirectory("src") == 1 or vim.fn.filereadable("package.json") == 1 then
  -- Component navigation
  map("n", "<leader>cc", ":e src/components/", { desc = "Edit component" })
  map("n", "<leader>ch", ":e src/hooks/", { desc = "Edit hook" })
  map("n", "<leader>cp", ":e src/pages/", { desc = "Edit page" })
  map("n", "<leader>cu", ":e src/utils/", { desc = "Edit utility" })
  
  -- TypeScript operations
  map("n", "<leader>to", "<cmd>TypescriptOrganizeImports<cr>", { desc = "Organize imports" })
  map("n", "<leader>tr", "<cmd>TypescriptRenameFile<cr>", { desc = "Rename file" })
  map("n", "<leader>ta", "<cmd>TypescriptAddMissingImports<cr>", { desc = "Add missing imports" })
  map("n", "<leader>tu", "<cmd>TypescriptRemoveUnused<cr>", { desc = "Remove unused imports" })
  
  -- React development shortcuts
  map("n", "<leader>rfc", "i// React Functional Component<cr>import React from 'react';<cr><cr>interface Props {<cr>}<cr><cr>const ComponentName: React.FC<Props> = () => {<cr>return (<cr><div><cr></div><cr>);<cr>};<cr><cr>export default ComponentName;<esc>", { desc = "React FC snippet" })
  
  -- Jest/Testing shortcuts
  map("n", "<leader>jt", "<cmd>!npm test -- --watchAll=false<cr>", { desc = "Run tests once" })
  map("n", "<leader>jw", "<cmd>!npm test<cr>", { desc = "Run tests in watch mode" })
  map("n", "<leader>jc", "<cmd>!npm test -- --coverage<cr>", { desc = "Run tests with coverage" })
  
  -- Development server
  map("n", "<leader>ds", "<cmd>!npm run dev<cr>", { desc = "Start dev server" })
  map("n", "<leader>db", "<cmd>!npm run build<cr>", { desc = "Build project" })
  map("n", "<leader>dl", "<cmd>!npm run lint<cr>", { desc = "Run linter" })
  map("n", "<leader>df", "<cmd>!npm run lint -- --fix<cr>", { desc = "Fix linting errors" })
end

-- Better terminal navigation for Rails
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal left" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal down" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Terminal up" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal right" })
