# dotfiles

## セットアップ（新しいマシン）

```bash
git clone git@github.com:qoo22633/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

`install.sh` が以下を自動で行います（何度実行しても安全）：

- `dotfiles/.config/*` → `~/.config/*` のシンボリックリンク作成（ディレクトリ単位）
- `dotfiles/home/.*` → `~/.*` のシンボリックリンク作成（ファイル単位）
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
└── install.sh         # シンボリックリンク一括作成スクリプト
```

## ツールのインストール

```bash
# シェル
brew install zsh sheldon fzf zoxide atuin mise

# エディタ
brew install neovim

# Git 関連
brew install git lazygit tig git-delta
npm install -g git-cz

# CLI ツール
brew install eza bat ripgrep fd
brew install yazi ffmpeg sevenzip jq poppler resvg imagemagick
brew install lazysql

# GitHub
brew install gh
gh extension install dlvhdr/gh-dash

# ターミナル
brew install --cask wezterm@nightly
brew tap manaflow-ai/cmux && brew install --cask cmux

# ウィンドウマネージャー
brew install --cask nikitabobko/tap/aerospace
brew tap FelixKratz/formulae && brew install borders

# ターミナルマルチプレクサ
brew install zellij
```

## ローカル固有設定

`~/.zshrc.local` に記述（git 管理外）
