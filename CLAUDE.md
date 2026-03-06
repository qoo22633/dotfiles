# Claude Code 設定

## プロジェクト概要

個人的な開発環境設定を管理するdotfilesプロジェクトです。

## 主要コンポーネント

- **Zsh**: シェル環境（mise、sheldon、fzf、zoxide、atuin使用）
- **Neovim**: LazyVimベースの設定 + Claude Code統合
- **WezTerm**: ターミナルエミュレータ
- **Git**: lazygitを使用

## 重要なファイル

- `home/.zshrc`: Zsh設定（条件付きツール読み込み）
- `.config/nvim/lua/plugins/claudecode.lua`: Claude Code設定
- `install.sh`: シンボリックリンク一括作成スクリプト
- `Brewfile`: Homebrew パッケージ管理（`~/.Brewfile` にリンク）

## Homebrew パッケージ管理（Brewfile）

`Brewfile` でインストールするパッケージを一元管理している。

```bash
# 初回セットアップ・パッケージ追加時
brew bundle install --global

# 現在の環境から Brewfile を更新
brew bundle dump --global --force

# インストール済みチェック
brew bundle check --global
```

`install.sh` が `Brewfile` を `~/.Brewfile` にシンボリックリンクするため、`--global` フラグで参照される。

## install.sh の仕組み

4フェーズでシンボリックリンクを作成する。何度実行しても安全（冪等）。

**Phase 1: `~/.config/*`**
`.config/` 以下のディレクトリを自動検出して `~/.config/<tool>` にリンク。
新ツール追加時は `dotfiles/.config/<tool>/` を作成するだけでOK。

**Phase 2: `~/.*`（home dotfiles）**
`home/` 以下のドットファイルをホームディレクトリにリンク。
`home/.config/` は `[[ "$base" == ".config" ]] && continue` で**明示的にスキップ**（Phase 1 で管理）。

**Phase 3: Brewfile**
`Brewfile` を `~/.Brewfile` にリンク。`brew bundle install --global` で参照される。

**Phase 4: Claude Code ファイル**
`.claude/commands/*.md` と `.claude/agents/*.md` を**ファイル単位**でリンク。
`~/.claude/` はランタイムデータを含むため、ディレクトリ丸ごとはリンクしない。

**safe_link() の動作:**
- 正しいリンクが既に存在 → 何もしない（`Already linked:`）
- 既存ファイル/ディレクトリ/リンクがある → `~/.dotfiles_backup/<timestamp>/` にバックアップして置き換え
- ソースが存在しない → スキップ（警告表示）

## ⚠️ 重大インシデントの教訓（commit ba2c63a）

**経緯**: Claude が `~/.config` 全体をシンボリックリンクしようとし、`~/.config/` 配下のツール別個別リンク群を丸ごと置き換えかけた。

### 絶対にやってはいけない操作

1. **`~/.config/` をディレクトリ丸ごとシンボリックリンクしない**
   - `~/.config/` 配下には各ツールが自動生成したファイルが混在している
   - 管理は常に `~/.config/<tool>/` 単位で行う

2. **`~/.claude/` をディレクトリ丸ごとシンボリックリンクしない**
   - Claude Code のメモリ・プロジェクトキャッシュ・ランタイムデータが含まれる
   - 管理は常にファイル単位（`commands/*.md`, `agents/*.md`）で行う

3. **`~/.config/` 配下で `rm -rf` や `mv` を使った破壊的操作をしない**
   - 既存リンクや他ツールの設定を巻き込む危険がある

### install.sh の防止策（現在のコード）

```bash
# home/ ループで .config を明示的にスキップ（install.sh:81）
[[ "$base" == ".config" ]] && continue  # .config は別途 .config/*/ ループで管理

# .config は個別ツールディレクトリ単位でリンク（install.sh:66-70）
for src_dir in "$DOTFILES_DIR/.config"/*/; do
    safe_link "$src_dir" "$HOME/.config/$tool_name"  # ~/.config 自体はリンクしない
done

# .claude はファイル単位でリンク（install.sh:93-99）
for f in "$DOTFILES_DIR/.claude/commands"/*.md; do
    safe_link "$f" "$HOME/.claude/commands/$(basename "$f")"
done
```

## 開発フロー

### 新しいツールの設定を追加

```bash
mkdir .config/<tool>
# 設定ファイルを配置
./install.sh  # 自動検出してリンク作成
```

### 既存設定の変更

dotfiles リポジトリ内のファイルを直接編集するだけでOK（シンボリックリンクなので即反映）。install.sh の再実行は不要。

### install.sh の再実行

何度実行しても安全。`Already linked:` が表示されれば正常。

## テストコマンド

```bash
# install.sh の冪等動作確認（Already linked: が表示されればOK）
./install.sh

# シンボリックリンク確認
ls -la ~/.config/ | grep '\->'
ls -la ~ | grep '\->'
ls -la ~/.claude/commands/ | grep '\->'

# Brewfile リンク確認
ls -la ~/.Brewfile

# Homebrew パッケージ一括インストール
brew bundle install --global

# Zsh設定確認
source ~/.zshrc

# 各ツール動作確認
mise --version
sheldon --version
fzf --version
zoxide --version
atuin --version
```

## 注意点

- 各ツールは条件付きで読み込み（インストール済みの場合のみ）
- ローカル固有設定は `~/.zshrc.local` で管理（git 管理外）
- `home/.config/` は git 管理外（`gcloud` クレデンシャル等を含む可能性があるため）
