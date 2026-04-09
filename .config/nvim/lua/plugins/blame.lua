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
  config = function(_, opts)
    require("blame").setup(opts)

    -- git_browser.lua が "origin" をハードコードしているため、
    -- origin → upstream の順でフォールバックするカスタム実装で o を上書きする
    local function build_commit_url(remote_url, hash)
      local host, owner, repo
      for _, pat in ipairs({
        "git@([^:]+):([^/]+)/(.+)%.git",
        "https?://([^/]+)/([^/]+)/(.+)%.git",
        "https?://([^/]+)/([^/]+)/([^/%.]+)",
        "git@([^:]+):([^/]+)/([^/%.]+)",
      }) do
        host, owner, repo = remote_url:match(pat)
        if host then break end
      end
      if not host then return nil end
      if host:match("github%.com") then
        return ("https://github.com/%s/%s/commit/%s"):format(owner, repo, hash)
      elseif host:match("gitlab") then
        return ("https://%s/%s/%s/-/commit/%s"):format(host, owner, repo, hash)
      elseif host:match("bitbucket") then
        return ("https://bitbucket.org/%s/%s/commits/%s"):format(owner, repo, hash)
      else
        return ("https://%s/%s/%s/commit/%s"):format(host, owner, repo, hash)
      end
    end

    local function get_remote_url(cwd, remote, cb, err_cb)
      local data, err_data
      vim.fn.jobstart({ "git", "remote", "get-url", remote }, {
        cwd = cwd,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, d) data = d end,
        on_stderr = function(_, d) err_data = d end,
        on_exit = function(_, code)
          if code == 0 and data and data[1] then cb(data[1]) else err_cb() end
        end,
      })
    end

    local function open_in_browser_smart()
      local view = require("blame").last_opened_view
      if not view or not view.blame_window then return end
      local row = vim.api.nvim_win_get_cursor(view.blame_window)[1]
      local commit = view.blamed_lines[row]
      if not commit then return end
      local hash, cwd = commit.hash, view.cwd

      local function try_remote(remote)
        get_remote_url(cwd, remote, function(url)
          vim.schedule(function()
            local commit_url = build_commit_url(url, hash)
            if commit_url then
              vim.notify("Opening: " .. commit_url)
              vim.fn.jobstart({ "open", commit_url }, { detach = true })
            else
              vim.notify("Could not parse remote URL: " .. url, vim.log.levels.WARN)
            end
          end)
        end, function()
          if remote == "origin" then
            try_remote("upstream")
          else
            vim.schedule(function()
              vim.notify("No origin or upstream remote found", vim.log.levels.ERROR)
            end)
          end
        end)
      end

      try_remote("origin")
    end

    -- setup_keybinds() より後に実行されるよう vim.schedule で遅延させる
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "blame",
      callback = function(args)
        vim.schedule(function()
          vim.keymap.set("n", "o", open_in_browser_smart, {
            buffer = args.buf,
            nowait = true,
            silent = true,
            noremap = true,
            desc = "Open commit in browser (origin → upstream fallback)",
          })
        end)
      end,
    })
  end,
}
