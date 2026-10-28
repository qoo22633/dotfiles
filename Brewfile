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

# ============================================================
# Formulae (CLI ツール)
# ============================================================

## mise Registry にないもの（mise 管理のツールは .config/mise/config.toml）
brew "mise"       # ツール・環境変数・タスクの管理（ブートストラップ用に brew で入れる）
brew "git"

## mise で入れたバイナリが動的リンクするライブラリ
# sheldon の配布バイナリ（aqua）は /opt/homebrew/opt/openssl@3 にリンクしている。
# Homebrew の既定が openssl@4 になり、依存元がないと autoremove で消されて起動できなくなるため明示する
brew "openssl@3"

## ウィンドウ装飾
brew "borders"  # ウィンドウボーダー（AeroSpace 連携）

# ============================================================
# Casks (GUI アプリ)
# ============================================================
cask "aerospace"   # タイリングウィンドウマネージャー
cask "ghostty"     # ターミナルエミュレータ
