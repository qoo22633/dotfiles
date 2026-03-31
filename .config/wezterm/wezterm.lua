local wezterm = require("wezterm")
local config = wezterm.config_builder()

local act = wezterm.action
local mux = wezterm.mux

-- タブのカスタムタイトルを保持するテーブル
local custom_title = {}

-- wez-cc-viewer バイナリパス解決（mise/go install 対応）
local _bin_cache = nil
local function find_wez_cc_viewer()
	if _bin_cache then
		return _bin_cache
	end
	local ok, stdout = wezterm.run_child_process({
		os.getenv("SHELL") or "/bin/zsh",
		"-lic",
		"which wez-cc-viewer",
	})
	if ok and stdout then
		local path = stdout:gsub("%s+$", "")
		if path ~= "" then
			_bin_cache = path
			return path
		end
	end
	return nil
end

-- 基本設定
config.automatically_reload_config = true
config.check_for_updates = true
config.use_ime = true

-- フォント設定
config.font_size = 18.0
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })

-- ウィンドウ設定
config.window_background_opacity = 0.7
config.window_decorations = "TITLE | RESIZE"

-- タブバー設定
config.tab_max_width = 32

-- LEADER キー設定（CTRL+a, 1秒タイムアウト）
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- キーバインド
config.keys = {
	-- カーソルを一単語後ろに移動
	{
		key = "LeftArrow",
		mods = "CMD",
		action = act.SendKey({
			key = "b",
			mods = "META",
		}),
	},
	-- カーソルを一単語前に移動
	{
		key = "RightArrow",
		mods = "CMD",
		action = act.SendKey({
			key = "f",
			mods = "META",
		}),
	},
	-- カーソルを一単語削除
	{
		key = "Backspace",
		mods = "CMD", --mac用
		action = act.SendKey({
			key = "w",
			mods = "CTRL",
		}),
	},
	-- ペインを縦分割
	{
		key = "d",
		mods = "CMD",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- ペインを横分割
	{
		key = "d",
		mods = "CMD|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	-- ページスクロール（上）
	{
		key = "UpArrow",
		mods = "CMD",
		action = act.ScrollByPage(-1),
	},
	-- ページスクロール（下）
	{
		key = "DownArrow",
		mods = "CMD",
		action = act.ScrollByPage(1),
	},
	-- viewモード（コピーモード）切り替え
	{
		key = "x",
		mods = "CMD|SHIFT",
		action = act.ActivateCopyMode,
	},
	-- ペインを閉じる
	{
		key = "w",
		mods = "CMD",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	-- ペイン移動
	{ key = "h", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Down") },
	-- ペインサイズ調整
	{ key = "=", mods = "CTRL|CMD", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "-", mods = "CTRL|CMD", action = act.AdjustPaneSize({ "Left", 5 }) },
	-- Claude Code TUI ダッシュボード（LEADER+a）
	{
		key = "a",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local bin = find_wez_cc_viewer()
			if not bin then
				wezterm.log_error("wez-cc-viewer not found in PATH")
				window:toast_notification("wezterm", "wez-cc-viewer が見つかりません", nil, 3000)
				return
			end
			local new_pane = pane:split({
				direction = "Bottom",
				args = { bin },
			})
			window:perform_action(act.TogglePaneZoomState, new_pane)
		end),
	},
	-- タブリネーム
	{
		key = ",",
		mods = "CMD|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local tab = pane:tab()
			local tab_id = tab:tab_id()
			local current = custom_title[tab_id] or ""
			window:perform_action(
				act.PromptInputLine({
					description = "(wezterm) Rename tab (empty to reset):",
					initial_value = current,
					action = wezterm.action_callback(function(_, inner_pane, line)
						if line == nil then
							return
						end
						local t = inner_pane:tab()
						if line == "" then
							custom_title[t:tab_id()] = nil
						else
							custom_title[t:tab_id()] = line
						end
					end),
				}),
				pane
			)
		end),
	},
}

-- イベントハンドラ
-- 起動時に画面を最大化
wezterm.on("gui-startup", function()
	local _, _, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#5c6d74"
	local foreground = "#FFFFFF"

	if tab.is_active then
		background = "#ae8b2d"
		foreground = "#FFFFFF"
	end

	-- カスタムタイトルがあれば優先
	local tab_id = tab.tab_id
	if custom_title[tab_id] then
		local title = "   " .. wezterm.truncate_right(custom_title[tab_id], max_width - 1) .. "   "
		return {
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Text = title },
		}
	end

	-- プロセス名のアイコンマッピング
	local process_icons = {
		nvim = " ",
		vim = " ",
		lazygit = " ",
		git = " ",
		ssh = "󰣀 ",
		node = " ",
		python3 = " ",
		python = " ",
		ruby = " ",
		cargo = " ",
		go = " ",
		docker = " ",
		claude = "󰚩 ",
	}

	-- プロセス名を取得
	local process = tab.active_pane.foreground_process_name or ""
	local process_name = process:match("([^/]+)$") or ""
	local icon = process_icons[process_name] or "󰆍 "

	-- カレントディレクトリ名を取得
	local cwd = tab.active_pane.current_working_dir
	local dir = tab.active_pane.title

	if cwd then
		local cwd_uri = cwd.file_path or tostring(cwd)
		dir = cwd_uri:match("([^/]+)/?$") or dir
	end

	local title = icon .. process_name .. "  " .. dir
	title = "  " .. wezterm.truncate_right(title, max_width - 1) .. "  "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

-- ワークスペース切り替え（wez-cc-viewer 連携）
wezterm.on("user-var-changed", function(window, pane, name, value)
	if name == "switch_workspace" then
		window:perform_action(act.SwitchToWorkspace({ name = value }), pane)
	end
end)

-- ps コマンド結果をキャッシュして子プロセス一覧を返す（3秒TTL）
local _ps_cache = nil
local _ps_cache_time = 0

local function get_process_children()
	local now = os.time()
	if _ps_cache and (now - _ps_cache_time) < 3 then
		return _ps_cache
	end
	local ok, stdout = wezterm.run_child_process({ "ps", "-eo", "pid,ppid,comm" })
	if not ok then
		return {}
	end
	local children = {} -- ppid -> list of child names
	for line in stdout:gmatch("[^\n]+") do
		local pid, ppid, comm = line:match("^%s*(%d+)%s+(%d+)%s+(%S+)")
		if pid then
			local pp = tonumber(ppid)
			local name = comm:match("([^/]+)$") or comm
			if not children[pp] then
				children[pp] = {}
			end
			table.insert(children[pp], name)
		end
	end
	_ps_cache = children
	_ps_cache_time = now
	return children
end

-- claude プロセスの直接子に caffeinate があれば running と判定
local function claude_is_running(p)
	local info = p:get_foreground_process_info()
	if not info then
		return false
	end
	local children = get_process_children()
	for _, child_name in ipairs(children[info.pid] or {}) do
		if child_name == "caffeinate" then
			return true
		end
	end
	return false
end

-- 右ステータスバー: Claude Code 稼働状況 + 完了通知
local prev_agents = {} -- pane_id -> { running: bool }

wezterm.on("update-right-status", function(window, pane)
	local current_agents = {}
	local running = 0
	local total = 0

	for _, tab in ipairs(window:mux_window():tabs()) do
		for _, p in ipairs(tab:panes()) do
			local process = p:get_foreground_process_name() or ""
			local name = process:match("([^/]+)$") or ""
			if name == "claude" then
				local pane_id = p:pane_id()
				local is_running = claude_is_running(p)
				total = total + 1
				if is_running then
					running = running + 1
				end
				-- ラベル: カスタムタイトル > cwd名 の優先順位で取得
				local label = custom_title[tab:tab_id()]
				if not label then
					local cwd_uri = p:get_current_working_dir()
					if cwd_uri then
						label = cwd_uri.file_path:match("([^/]+)/?$")
					end
				end
				label = label or ("pane:" .. pane_id)
				current_agents[pane_id] = { running = is_running, label = label }
			end
		end
	end

	-- running → idle への遷移を検出して完了通知
	for pane_id, prev in pairs(prev_agents) do
		if prev.running then
			local curr = current_agents[pane_id]
			if curr == nil or not curr.running then
				wezterm.run_child_process({
					"osascript",
					"-e",
					string.format(
						'display notification %q with title "Claude Code" sound name "Glass"',
						prev.label .. " のタスクが完了しました"
					),
				})
			end
		end
	end
	prev_agents = current_agents

	local status = ""
	if total > 0 then
		status = string.format("󰚩 Claude: %d/%d ", running, total)
	end

	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#89b4fa" } },
		{ Text = status },
	}))
end)

return config
