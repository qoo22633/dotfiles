# Brewfile
# brew bundle install でまとめてインストール可能
# brew bundle dump --force で現在の環境からの更新も可能

# ============================================================
# Taps
# ============================================================
tap "FelixKratz/formulae"  # borders
tap "nikitabobko/tap"      # aerospace

# ============================================================
# Formulae (CLI ツール)
# ============================================================

## シェル・ターミナル環境
brew "sheldon"  # zsh プラグインマネージャー
brew "deno"     # zeno.zsh の必須依存
brew "fzf"      # ファジーファインダー
brew "zoxide"   # 賢い cd コマンド
brew "atuin"    # シェル履歴の強化
brew "yazi"     # ターミナルファイルマネージャー
brew "bat"      # better cat（yazi依存だが明示管理・zeno/fzfプレビューで使用）
brew "fd"       # better find（yazi依存だが明示管理・fzf連携で使用）
brew "ripgrep"  # rg（Neovim grep検索の必須依存）
brew "herdr"    # エージェントマルチプレクサ（複数のCoding Agentを管理）

## バージョン管理
brew "git"
brew "ghq"        # リポジトリ管理ツール
brew "lazygit"    # git TUI クライアント
brew "gh"         # GitHub CLI
brew "worktrunk"  # git worktree マネージャー

## エディタ・開発ツール
brew "neovim"
brew "mise"     # ランタイムバージョンマネージャー（asdf 互換）
brew "go"       # Go 言語（wez-cc-viewer ビルド用）

## ウィンドウ装飾
brew "borders"  # ウィンドウボーダー（AeroSpace 連携）

# ============================================================
# Casks (GUI アプリ)
# ============================================================
cask "aerospace" # タイリングウィンドウマネージャー
cask "wezterm"   # ターミナルエミュレータ
