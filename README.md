# dotfiles

## セットアップ（新しいマシン）

```bash
git clone git@github.com:qoo22633/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh

# Homebrew パッケージを一括インストール
brew bundle install --global
```

`install.sh` が以下を自動で行います（何度実行しても安全）：

- `dotfiles/.config/*` → `~/.config/*` のシンボリックリンク作成（ディレクトリ単位）
- `dotfiles/home/.*` → `~/.*` のシンボリックリンク作成（ファイル単位）
- `dotfiles/Brewfile` → `~/.Brewfile` のシンボリックリンク作成
- `dotfiles/.claude/commands/*.md` → `~/.claude/commands/` のシンボリックリンク作成（ファイル単位）
- 既存ファイルは `~/.dotfiles_backup/<timestamp>/` にバックアップ

## ディレクトリ構成

```
dotfiles/
├── .config/
│   ├── nvim/          # Neovim (LazyVim)
│   ├── wezterm/       # WezTerm ターミナル
│   ├── lazygit/       # lazygit
│   ├── sheldon/       # sheldon (zsh プラグインマネージャー)
│   ├── gh-dash/       # gh-dash (GitHub CLI ダッシュボード)
│   ├── aerospace/     # AeroSpace ウィンドウマネージャー
│   ├── borders/       # borders (アクティブウィンドウのボーダー表示)
│   ├── git/           # git 設定（ignore ファイル等）
│   └── zellij/        # Zellij ターミナルマルチプレクサ
├── home/
│   ├── .zshrc
│   ├── .zsh_aliases
│   ├── .gitconfig
│   ├── .tigrc
│   └── .vimrc
├── .claude/           # Claude Code 設定
│   ├── commands/      # カスタムコマンド（/worklog, /create-pr）
│   └── agents/        # カスタムエージェント
├── Brewfile           # Homebrew パッケージ管理
└── install.sh         # シンボリックリンク一括作成スクリプト
```

## Homebrew パッケージ管理

`Brewfile` でインストールするパッケージを一元管理しています。

```bash
# パッケージ一括インストール
brew bundle install --global

# 現在の環境から Brewfile を更新
brew bundle dump --global --force

# インストール済みかチェック
brew bundle check --global
```

## ローカル固有設定

`~/.zshrc.local` に記述（git 管理外）
