# dotfiles

### 追加方法

- git管理したいドットファイルをdotfilesに移動
`mv .vimrc dotfiles/`

- シンボリックリンクを貼る
`ln -sf ~/dotfiles/.vimrc ~/.vimrc`

### 反映方法

#### mise
`brew install mise`

#### zsh
`brew install zsh`

`brew install sheldon`

`brew install fzf`

`ln -sf ~/dotfiles/.zshrc ~/.zshrc`

`ln -sf ~/dotfiles/sheldon/plugins.toml ~/.config/sheldon/plugins.toml`

#### tig
`brew install tig`

`ln -sf ~/dotfiles/.tigrc ~/.tigrc`

#### Vim
- neovimを使っている

`brew install neovim`

`ln -sf ~/dotfiles/nvim ~/.config`
