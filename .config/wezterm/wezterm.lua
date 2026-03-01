local wezterm = require("wezterm")
local config = wezterm.config_builder()

local act = wezterm.action
local mux = wezterm.mux

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
	-- ペインサイズ調整
	{ key = "=", mods = "CTRL|CMD", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "-", mods = "CTRL|CMD", action = act.AdjustPaneSize({ "Left", 5 }) },
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

	-- カレントディレクトリ名を取得
	local cwd = tab.active_pane.current_working_dir
	local title = tab.active_pane.title

	if cwd then
		local cwd_uri = cwd.file_path or tostring(cwd)
		-- パスからディレクトリ名のみを取得
		title = cwd_uri:match("([^/]+)/?$") or title
	end

	title = "   " .. wezterm.truncate_right(title, max_width - 1) .. "   "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

return config
