# init
## zshで補完ができるように設定
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

# excecute
eval "$(sheldon source)"
source <(fzf --zsh)

# For local settings
if [ -f ~/.zshrc.local ]; then
    . ~/.zshrc.local
fi