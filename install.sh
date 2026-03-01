#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# dotfiles install.sh
#
# シンボリックリンクを安全に一括作成するスクリプト。
# 実行するたびに冪等（何度実行しても安全）。
# 既存ファイル/ディレクトリはバックアップしてから置き換える。
#
# 使い方:
#   chmod +x ~/dotfiles/install.sh
#   ~/dotfiles/install.sh
# ============================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
    safe_link "$src_file" "$HOME/$base"
done

# ============================================================
# Claude Code のシンボリックリンク
# ディレクトリごとではなくファイル単位でリンク
# （~/.claude/ には Claude Code 自身のランタイムデータも含まれるため）
# ============================================================
log "=== Claude Code ==="
mkdir -p "$HOME/.claude/commands" "$HOME/.claude/agents"

for f in "$DOTFILES_DIR/.claude/commands"/*.md; do
    [[ -f "$f" ]] && safe_link "$f" "$HOME/.claude/commands/$(basename "$f")"
done

for f in "$DOTFILES_DIR/.claude/agents"/*.md; do
    [[ -f "$f" ]] && safe_link "$f" "$HOME/.claude/agents/$(basename "$f")"
done

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
