local wezterm = require("wezterm")
local config = wezterm.config_builder()

local act = wezterm.action
local mux = wezterm.mux

config.color_scheme = "Catppuccin Mocha"
-- 基本設定
config.font_size = 18.0
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.check_for_updates = true
config.use_ime = true

-- ウィンドウ設定
config.window_background_opacity = 0.7
config.window_decorations = "TITLE | RESIZE"
config.window_close_confirmation = "NeverPrompt"

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
	-- 左のペインに移動
	{
		key = "[",
		mods = "CMD",
		action = act.ActivatePaneDirection("Left"),
	},
	-- 右のペインに移動
	{
		key = "]",
		mods = "CMD",
		action = act.ActivatePaneDirection("Right"),
	},
	-- 上のペインに移動
	{
		key = "UpArrow",
		mods = "CMD|SHIFT",
		action = act.ActivatePaneDirection("Up"),
	},
	-- 下のペインに移動
	{
		key = "DownArrow",
		mods = "CMD|SHIFT",
		action = act.ActivatePaneDirection("Down"),
	},
	-- ペインを閉じる
	{
		key = "w",
		mods = "CMD",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	-- ペインサイズ調整（左方向に拡大）
	{
		key = "LeftArrow",
		mods = "CMD|CTRL",
		action = act.AdjustPaneSize({ "Left", 5 }),
	},
	-- ペインサイズ調整（右方向に拡大）
	{
		key = "RightArrow",
		mods = "CMD|CTRL",
		action = act.AdjustPaneSize({ "Right", 5 }),
	},
	-- ペインサイズ調整（上方向に拡大）
	{
		key = "UpArrow",
		mods = "CMD|CTRL",
		action = act.AdjustPaneSize({ "Up", 5 }),
	},
	-- ペインサイズ調整（下方向に拡大）
	{
		key = "DownArrow",
		mods = "CMD|CTRL",
		action = act.AdjustPaneSize({ "Down", 5 }),
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

	local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

return config
