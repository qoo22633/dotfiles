# init
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

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init - zsh--no-rehash)"

# excecute
eval "$(sheldon source)"
source <(fzf --zsh)

# For local settings
if [ -f ~/.zshrc.local ]; then
    . ~/.zshrc.local
fi