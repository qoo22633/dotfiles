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
- `dotfiles/home/.claude/statusline-command.sh` → `~/.claude/statusline-command.sh` のシンボリックリンク作成（ファイル単位、全PC共通のステータスライン表示スクリプト）
- `dotfiles/.claude/commands/*.md` → `~/.claude/commands/` のシンボリックリンク作成（ファイル単位）
- `dotfiles/.claude/agents/*.md` → `~/.claude/agents/` のシンボリックリンク作成（ファイル単位）
- `dotfiles/.config/herdr/config.toml` → `~/.config/herdr/config.toml` のシンボリックリンク作成（ファイル単位、ランタイムデータと同居するため）
- `herdr integration install claude` を実行
- 既存ファイルは `~/.dotfiles_backup/<timestamp>/` にバックアップ

## ディレクトリ構成

```
dotfiles/
├── .config/
│   ├── nvim/          # Neovim (LazyVim)
│   ├── wezterm/       # WezTerm ターミナル
│   ├── lazygit/       # lazygit
│   ├── sheldon/       # sheldon (zsh プラグインマネージャー)
│   ├── aerospace/     # AeroSpace ウィンドウマネージャー
│   ├── borders/       # borders (アクティブウィンドウのボーダー表示)
│   ├── git/           # git 設定（ignore ファイル等）
│   ├── zeno/          # zeno.zsh (git fuzzy 補完・履歴検索)
│   ├── zsh-abbr/      # zsh-abbr (略語展開)
│   └── herdr/         # herdr エージェントマルチプレクサ（config.toml のみ管理）
├── home/
│   ├── .zshrc
│   ├── .zsh_aliases
│   ├── .gitconfig
│   ├── .tigrc
│   ├── .vimrc
│   └── .claude/
│       └── statusline-command.sh  # ~/.claude/statusline-command.sh（全PC共通のステータスライン表示スクリプト）
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

- `~/.zshrc.local` に記述（git 管理外）
- `~/.claude/settings.json`: モデル・permissions・pluginsなどのClaude Code設定（マシンごとに個別管理、git 管理外）
- `~/.claude/settings.local.json`: マシン固有・機密情報を含む設定はここに記述（git 管理外）
