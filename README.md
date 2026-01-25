# dotfiles

## 追加方法

- git管理したいドットファイルをdotfilesに移動
  `mv .vimrc dotfiles/`

- シンボリックリンクを貼る
  `ln -sf ~/dotfiles/.vimrc ~/.vimrc`

## 反映方法

### mise

`brew install mise`

### zsh

`brew install zsh`

`brew install sheldon`

`brew install fzf`

`ln -sf ~/dotfiles/.zshrc ~/.zshrc`

`ln -sf ~/dotfiles/.zsh_aliases ~/.zsh_aliases`

`ln -sf ~/dotfiles/sheldon/plugins.toml ~/.config/sheldon/plugins.toml`

### wezterm

`brew install --cask wezterm@nightly`

`ln -sf ~/dotfiles/wezterm ~/.config`

### Git

`ln -sf ~/dotfiles/.gitconfig ~/.gitconfig`

#### tig

`brew install tig`

`ln -sf ~/dotfiles/.tigrc ~/.tigrc`

#### atuin

`brew install atuin`

#### lazygit

`brew install lazygit`

### Vim

neovimを使っている

`brew install neovim`

`ln -sf ~/dotfiles/nvim ~/.config`

### Claude Code
Claude Codeのhooksとsettingsをシンボリックリンクで設定

`ln -sf ~/dotfiles/.claude/hooks ~/.claude/hooks`

`ln -sf ~/dotfiles/.claude/settings.json ~/.claude/settings.json`

Obsidianのパスが異なる場合は環境変数を設定:
```bash
export OBSIDIAN_VAULT_PATH="/path/to/obsidian/vault"
```

詳細は`.claude/HOOKS.md`を参照

### Other Cli Tools

#### 基本的なCLIツール
`brew install eza bat ripgrep fd zoxide`

#### yazi（ファイルマネージャー）
`brew install yazi ffmpeg sevenzip jq poppler resvg imagemagick font-symbols-only-nerd-font`

※ yaziの依存関係: ffmpeg, sevenzip, jq, poppler, resvg, imagemagick, font-symbols-only-nerd-font
※ ripgrep, fd, zoxide, fzfは上記で既にインストール済み

`y`コマンドでyaziを起動し、終了時に移動したディレクトリに自動的にcdする関数を`.zshrc`で定義しています。
