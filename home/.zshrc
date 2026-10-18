# init
## zshで補完ができるように設定
fpath=(~/.config/zsh/completion $fpath)
autoload -Uz compinit
compinit

#PATH
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/libxml2/bin:$PATH"
export PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick@6/6.9.9-40/lib/pkgconfig
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export PATH=$(brew --prefix openssl)/bin:$PATH
export PATH="/usr/local/opt/openssl@3/bin:$PATH"

# mise（ツール・環境変数・エイリアスは ~/.config/mise/config.toml で管理）
if [ -x /opt/homebrew/bin/mise ]; then
  eval "$(/opt/homebrew/bin/mise activate zsh)"
fi

# zoxide
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh --cmd cd)"
fi

# yazi
if (( $+commands[yazi] )); then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

# zsh-abbr / zeno の環境変数は mise の [env] で設定（sheldon ロード前に mise activate 済み）

# excecute
eval "$(sheldon source)"
source <(fzf --zsh)

# zeno キーバインド（sheldon + fzf ロード後に設定、^r は fzf --zsh を上書き）
if [[ -n $ZENO_LOADED ]]; then
  export ZENO_COMPLETION_FALLBACK="fzf-tab-complete"
  bindkey '^i'  zeno-completion         # Tab: git fuzzy 補完 → fallback fzf-tab
  bindkey '^r'  zeno-history-selection  # Ctrl-R: プレビュー付き履歴検索
  bindkey '^xs' zeno-insert-snippet     # Ctrl-X s: スニペットピッカー
fi

# ghq + fzf によるリポジトリ移動 (Ctrl+G)
if (( $+commands[ghq] && $+commands[fzf] )); then
  function ghq-fzf() {
    local repo
    repo=$(ghq list | fzf --height 40% --reverse \
      --preview "ls -la $(ghq root)/{}" \
      --preview-window=right:40%)
    if [[ -n "$repo" ]]; then
      cd "$(ghq root)/$repo"
    fi
    zle reset-prompt
  }
  zle -N ghq-fzf
  bindkey '^G' ghq-fzf
fi

# worktrunk（git worktree マネージャー）
# wt switch 実行時に自動でディレクトリ移動するシェル統合
# 初回インストール後に `wt config shell install` を実行してセットアップ
if [ -x "$(command -v wt)" ]; then
  source <(wt shell-init zsh 2>/dev/null) 2>/dev/null || true
fi

# For local settings
if [ -f ~/.zshrc.local ]; then
    . ~/.zshrc.local
fi
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
