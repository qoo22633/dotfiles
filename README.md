# dotfiles

### 追加方法

- git管理したいドットファイルをdotfilesに移動
`mv .vimrc dotfiles/`

- シンボリックリンクを貼る
`ln -sf ~/dotfiles/.vimrc ~/.vimrc`

### 反映方法

#### zsh
`brew install zsh`

`brew install zplug`

`ln -sf ~/dotfiles/.zshrc ~/.zshrc`

#### tig
`brew install tig`

`ln -sf ~/dotfiles/.tigrc ~/.tigrc`

#### Vim
- neovimを使っている

`brew install neovim`

`ln -sf ~/dotfiles/nvim ~/.config`

#### peco
`brew install peco`
