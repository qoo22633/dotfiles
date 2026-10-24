#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# mise postinstall hook（`mise install` の後に自動実行される）
#
# シンボリックリンクを安全に一括作成し、mise Registry にない
# ツールを Homebrew で入れる。実行するたびに冪等。
# 既存ファイル/ディレクトリはバックアップしてから置き換える。
#
# 手動実行: mise run link
# ============================================================

# このファイルは dotfiles/.config/mise/hooks/ にある（~/.config/mise 経由でも実体を辿る）
DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../../.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

log()  { echo "[install] $*"; }
warn() { echo "[warn]    $*" >&2; }

# ============================================================
# シンボリックリンクを安全に作成
# - 既に正しいリンクなら何もしない（冪等）
# - 既存のファイル/ディレクトリ/リンクはバックアップ後に置き換え
# ============================================================
safe_link() {
    local src="$1"
    local dst="$2"

    # ソースが存在しない場合はスキップ
    if [[ ! -e "$src" ]]; then
        warn "Skip (source not found): $src"
        return 0
    fi

    # 既に正しいシンボリックリンクが貼られていれば何もしない
    if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
        log "Already linked: $dst"
        return 0
    fi

    # 既存のファイル/ディレクトリ/シンボリックリンクをバックアップ
    if [[ -e "$dst" ]] || [[ -L "$dst" ]]; then
        mkdir -p "$BACKUP_DIR"
        local backup_name
        backup_name="$(basename "$dst")_$(date +%H%M%S)"
        log "Backup: $dst -> $BACKUP_DIR/$backup_name"
        mv "$dst" "$BACKUP_DIR/$backup_name"
    fi

    # 親ディレクトリを作成してシンボリックリンクを貼る
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    log "Linked: $dst -> $src"
}

# ============================================================
# ~/.config/* のシンボリックリンク
# .config/ 以下のディレクトリを自動検出してリンク
# → 新ツールを dotfiles/.config/<tool>/ に追加するだけでOK
# ============================================================
log "=== ~/.config symlinks ==="
mkdir -p "$HOME/.config"

for src_dir in "$DOTFILES_DIR/.config"/*/; do
    [[ -d "$src_dir" ]] || continue
    tool_name="$(basename "$src_dir")"
    [[ "$tool_name" == "herdr" ]] && continue  # herdr はファイル単位で管理
    safe_link "$src_dir" "$HOME/.config/$tool_name"
done

# ============================================================
# ~/* のシンボリックリンク
# home/ 以下のドットファイルをホームディレクトリにリンク
# ============================================================
log "=== Home dotfiles ==="

for src_file in "$DOTFILES_DIR/home"/.*; do
    base="$(basename "$src_file")"
    [[ "$base" == "." || "$base" == ".." ]] && continue
    [[ "$base" == ".config" ]] && continue  # .config は別途 .config/*/ ループで管理
    [[ "$base" == ".claude" ]] && continue  # .claude は別途 Claude Code セクションでファイル単位管理
    safe_link "$src_file" "$HOME/$base"
done

# ============================================================
# Brewfile のシンボリックリンク
# ============================================================
log "=== Brewfile ==="
safe_link "$DOTFILES_DIR/Brewfile" "$HOME/.Brewfile"

# ============================================================
# Claude Code のシンボリックリンク
# ディレクトリごとではなくファイル単位でリンク
# （~/.claude/ には Claude Code 自身のランタイムデータも含まれるため）
# ============================================================
log "=== Claude Code ==="
mkdir -p "$HOME/.claude/commands" "$HOME/.claude/agents"

safe_link "$DOTFILES_DIR/home/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

for f in "$DOTFILES_DIR/.claude/commands"/*.md; do
    [[ -f "$f" ]] && safe_link "$f" "$HOME/.claude/commands/$(basename "$f")"
done

for f in "$DOTFILES_DIR/.claude/agents"/*.md; do
    [[ -f "$f" ]] && safe_link "$f" "$HOME/.claude/agents/$(basename "$f")"
done

# ============================================================
# herdr 設定ファイルのシンボリックリンク
# ランタイムデータ（ソケット・ログ）と同居するためファイル単位で管理
# ============================================================
log "=== herdr config ==="
mkdir -p "$HOME/.config/herdr"
safe_link "$DOTFILES_DIR/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# ============================================================
# herdr インテグレーションのインストール
# herdr integration install は冪等（既に最新なら何もしない）
# ============================================================
log "=== herdr integrations ==="

if ! command -v herdr &>/dev/null; then
    warn "herdr not found. Skipping. Install via: mise install"
else
    herdr integration install claude
    log "herdr integration: claude installed"
fi

# ============================================================
# Homebrew（mise Registry にないツール・GUI アプリ）
# ============================================================
log "=== Homebrew (Brewfile) ==="

if ! command -v brew &>/dev/null; then
    warn "brew not found. Skipping Brewfile."
else
    brew bundle install --global
fi

# ============================================================
# 完了メッセージ
# ============================================================
log ""
log "=== Install complete ==="
if [[ -d "$BACKUP_DIR" ]]; then
    log "Backups saved to: $BACKUP_DIR"
fi
log ""
log "Next steps:"
log "  1. Open a new terminal to reload zsh config"
log "  2. Verify: ls -la ~/.config/ | grep '->'"
log "  3. Verify: ls -la ~ | grep '->'"
