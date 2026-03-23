# init
## zshで補完ができるように設定
fpath=(~/.config/zsh/completion $fpath)
autoload -Uz compinit
compinit

# alias
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

#PATH
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/libxml2/bin:$PATH"
export PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick@6/6.9.9-40/lib/pkgconfig
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export PATH=$(brew --prefix openssl)/bin:$PATH
export PATH="/usr/local/opt/openssl@3/bin:$PATH"

# Rust cargo
export PATH="$HOME/.cargo/bin:$PATH"

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# mise
if [ -x /opt/homebrew/bin/mise ]; then
  eval "$(/opt/homebrew/bin/mise activate zsh)"
fi

# zoxide
if [ -x /opt/homebrew/bin/zoxide ]; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# yazi
if [ -x /opt/homebrew/bin/yazi ]; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

# zsh-abbr: ユーザー略語ファイル（sheldon ロード前に設定必須）
export ABBR_USER_ABBREVIATIONS_FILE="${XDG_CONFIG_HOME}/zsh-abbr/user-abbreviations"

# zeno: ファイルプレビューに bat を使用（sheldon ロード前に設定）
export ZENO_GIT_CAT="bat"
# zeno: DenoがmacOSシステム証明書ストアを使用（SSL inspectionプロキシ対策）
export DENO_TLS_CA_STORE="system"

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

# For local settings
if [ -f ~/.zshrc.local ]; then
    . ~/.zshrc.local
fi