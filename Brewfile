# Brewfile
# brew bundle install でまとめてインストール可能
# CLI ツールの大半は mise に移行済み（.config/mise/config.toml）。ここには Registry にないものと GUI アプリだけ残す
#
# ⚠️ このファイルは手書きで管理しています。brew bundle dump で上書きしないでください
#    （コメントとセクション構成が失われ、borders が脱落します）

# ============================================================
# Taps
# ============================================================
tap "FelixKratz/formulae"  # borders
tap "nikitabobko/tap"      # aerospace
tap "nkzw-tech/tap"        # codiff

# ============================================================
# Formulae (CLI ツール)
# ============================================================

## mise Registry にないもの（mise 管理のツールは .config/mise/config.toml）
brew "mise"       # ツール・環境変数・タスクの管理（ブートストラップ用に brew で入れる）
brew "git"
brew "herdr"      # エージェントマルチプレクサ（複数のCoding Agentを管理）
brew "worktrunk"  # git worktree マネージャー

## ウィンドウ装飾
brew "borders"  # ウィンドウボーダー（AeroSpace 連携）

# ============================================================
# Casks (GUI アプリ)
# ============================================================
cask "aerospace"   # タイリングウィンドウマネージャー
cask "ghostty"     # ターミナルエミュレータ
cask "codiff"      # ローカル差分ビューア
