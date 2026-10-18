#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# dotfiles bootstrap.sh
#
# 新しいマシンの初期セットアップ。mise 設定をリンクして `mise install` するだけ。
# あとの処理（各種リンク・Brewfile）は mise の postinstall hook が行う。
# 何度実行しても安全。
# ============================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$DOTFILES_DIR/.config/mise"
DST="$HOME/.config/mise"

if ! command -v mise &>/dev/null; then
    echo "[bootstrap] mise not found. Install via: brew install mise" >&2
    exit 1
fi

mkdir -p "$HOME/.config"
if [[ -L "$DST" ]] && [[ "$(readlink "$DST")" == "$SRC" ]]; then
    echo "[bootstrap] Already linked: $DST"
else
    if [[ -e "$DST" ]] || [[ -L "$DST" ]]; then
        backup="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup"
        mv "$DST" "$backup/mise"
        echo "[bootstrap] Backup: $DST -> $backup/mise"
    fi
    ln -sfn "$SRC" "$DST"
    echo "[bootstrap] Linked: $DST -> $SRC"
fi

mise install
