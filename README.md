# dotfiles

## セットアップ（新しいマシン）

```bash
git clone git@github.com:qoo22633/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

`install.sh` が以下を自動で行います：

- `dotfiles/.config/*` → `~/.config/*` のシンボリックリンク作成
- `dotfiles/home/.*` → `~/.*` のシンボリックリンク作成
- Claude Code の commands/agents のシンボリックリンク作成
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

### シェル

```bash
brew install zsh sheldon fzf zoxide atuin mise
```

### エディタ

```bash
brew install neovim
```

### Git 関連

```bash
brew install git lazygit tig git-delta
npm install -g git-cz  # lazygit からのコンベンショナルコミット用
```

### CLI ツール

```bash
brew install eza bat ripgrep fd
brew install yazi ffmpeg sevenzip jq poppler resvg imagemagick
brew install lazysql
```

### GitHub

```bash
brew install gh
gh extension install dlvhdr/gh-dash
```

### ターミナル

```bash
brew install --cask wezterm@nightly
```

### ウィンドウマネージャー

```bash
brew install --cask aerospace
```

### ターミナルマルチプレクサ

```bash
brew install zellij
```

## ツール別メモ

### AeroSpace

キーバインド：

| キー | 動作 |
|------|------|
| `Alt + hjkl` | フォーカス移動 |
| `Alt + Shift + hjkl` | ウィンドウ移動 |
| `Alt + 1-9` | ワークスペース切り替え |
| `Alt + S` | Slack ワークスペース |
| `Alt + M` | Music ワークスペース |
| `Alt + B` | Browser ワークスペース |
| `Alt + F` | フルスクリーン |
| `Alt + Shift + ;` | サービスモード（設定リロード等） |

アプリのワークスペース自動割り当て：Chrome/Firefox/Safari → B、WezTerm → 1、Slack → S、Spotify → M

### lazygit カスタムコマンド

- `x`: マージ済み（master/staging）&リモート削除済みブランチを一括削除
- `C`: git-cz でコンベンショナルコミット（要 `npm install -g git-cz`）

### gh-dash カスタムキーバインド

- `g`: リポジトリで lazygit を起動
- `w`: PR をブラウザで開く

### Claude Code カスタムコマンド

- `/worklog`: 作業ログを Obsidian に記録（要 `OBSIDIAN_VAULT_PATH` 環境変数）
- `/create-pr`: PR 作成

### ローカル固有設定

`~/.zshrc.local` に記述（git 管理外）
