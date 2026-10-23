# dotfiles

## セットアップ（新しいマシン）

dotfiles の運用は [mise](https://mise.jdx.dev/) に集約している（ツール / 環境変数 / エイリアス / タスク / セットアップ hook）。

```bash
brew install mise
git clone git@github.com:qoo22633/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh   # ~/.config/mise をリンクして mise install
```

`mise install` 後に postinstall hook（`.config/mise/hooks/postinstall.sh`）が以下を自動で行います（何度実行しても安全）：

- `dotfiles/.config/*` → `~/.config/*` のシンボリックリンク作成（ディレクトリ単位）
- `dotfiles/home/.*` → `~/.*` のシンボリックリンク作成（ファイル単位）
- `dotfiles/Brewfile` → `~/.Brewfile` のシンボリックリンク作成と `brew bundle install --global`
- `dotfiles/home/.claude/statusline-command.sh` → `~/.claude/statusline-command.sh` のシンボリックリンク作成
- `dotfiles/.claude/commands/*.md` / `agents/*.md` → `~/.claude/` のシンボリックリンク作成（ファイル単位）
- `dotfiles/.config/herdr/config.toml` → `~/.config/herdr/config.toml` のシンボリックリンク作成（ランタイムデータと同居するため）
- `herdr integration install claude` を実行
- 既存ファイルは `~/.dotfiles_backup/<timestamp>/` にバックアップ

リンクだけ再適用したいときは `mise run link`。

## ディレクトリ構成

```
dotfiles/
├── .config/
│   ├── nvim/          # Neovim (LazyVim)
│   ├── ghostty/       # Ghostty ターミナル
│   ├── lazygit/       # lazygit
│   ├── sheldon/       # sheldon (zsh プラグインマネージャー)
│   ├── aerospace/     # AeroSpace ウィンドウマネージャー
│   ├── borders/       # borders (アクティブウィンドウのボーダー表示)
│   ├── git/           # git 設定（ignore ファイル等）
│   ├── zeno/          # zeno.zsh (git fuzzy 補完・履歴検索)
│   ├── zsh-abbr/      # zsh-abbr (略語展開)
│   ├── herdr/         # herdr エージェントマルチプレクサ（config.toml のみ管理）
│   └── mise/          # mise（config.toml: tools/env/shell_alias、hooks/、tasks/）
├── home/
│   ├── .zshenv        # 全シェル共通の環境変数（非対話シェルでも読まれる）
│   ├── .zshrc
│   ├── .gitconfig
│   └── .claude/
│       └── statusline-command.sh  # ~/.claude/statusline-command.sh（全PC共通のステータスライン表示スクリプト）
├── .claude/           # Claude Code 設定
│   ├── commands/      # カスタムコマンド（/worklog, /create-pr）
│   └── agents/        # カスタムエージェント
├── Brewfile           # mise Registry にないツールと GUI アプリ
└── bootstrap.sh       # 初期セットアップ（mise 設定のリンク + mise install）
```

## ツール管理

| 対象 | 管理場所 |
| --- | --- |
| CLI ツール（fzf, bat, eza, neovim, gh など）、npm グローバル | `.config/mise/config.toml` の `[tools]` |
| 環境変数 | 同 `[env]` |
| エイリアス | 同 `[shell_alias]` |
| カスタムスクリプト | `.config/mise/tasks/`（`mise run <name>`） |
| mise Registry にないもの・GUI アプリ | `Brewfile`（手書き管理。`brew bundle dump` は使わない） |

ツールを追加するときは `config.toml` を編集して `mise install`。

## ローカル固有設定

- `~/.zshrc.local` に記述（git 管理外）
