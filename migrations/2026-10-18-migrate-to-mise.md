# dotfiles 運用を mise に移行

- 日付: 2026-10-18
- 関連: https://zenn.dev/boykush/articles/11cfc3e1abc563

## 背景

CLI ツール（Brewfile）・環境変数/エイリアス（`.zshrc` / `.zsh_aliases`）・npm グローバル（`npm-global-packages`）・
セットアップ（`install.sh`）を mise に集約した。

- `.config/mise/config.toml`: `[tools]` `[env]` `[shell_alias]` `[hooks]`
- `install.sh` は `.config/mise/hooks/postinstall.sh` になり、`mise install` の後に自動実行される
- Brewfile には Registry にないもの（git, herdr, worktrunk, borders）と cask だけ残した

`git pull` だけでは、端末側の brew 版ツールと mise 版が二重に入ったまま・`~/.zsh_aliases` の古いリンクが残る。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）であること
- `mise` が brew で入っていること（`brew install mise`）

## 完了チェック

以下がすべて期待どおりなら適用済み。手順は不要。

```bash
readlink ~/.config/mise                       # 期待: <dotfiles>/.config/mise
mise ls --current fzf 2>/dev/null | grep -c fzf   # 期待: 1（mise 版 fzf が入っている）
ls -d ~/.zsh_aliases >/dev/null 2>&1; echo $?  # 期待: 1（壊れたリンクも含めて無い）
brew list --formula fzf >/dev/null 2>&1; echo $?   # 期待: 1（brew 版が無い）
```

## 手順

1. `./bootstrap.sh` を実行する（`~/.config/mise` をリンクし `mise install`。postinstall hook が残りのリンクと `brew bundle` を行う）
2. 古い `~/.zsh_aliases` のリンクを消す（リンク先が消えて壊れている）: `[ -L ~/.zsh_aliases ] && rm ~/.zsh_aliases`
3. brew 版の重複ツールを削除する（削除前に `mise ls` で mise 側に入っていることを確認）:
   `brew uninstall sheldon deno fzf zoxide atuin yazi bat fd eza ripgrep ghq lazygit gh neovim go`
   （依存で外せないものがあればエラーを見て個別に判断）
4. 新しいターミナルを開く

## 確認

```bash
mise env | grep -E 'EDITOR|XDG_CONFIG_HOME'   # 期待: 値が表示される
zsh -ic 'command -v fzf bat eza nvim'         # 期待: すべて ~/.local/share/mise/ 配下
zsh -ic 'alias ls'                            # 期待: eza --icons --git
difit --version                               # 期待: バージョンが表示される
```

## 注意点・トラブルシュート

- `[hooks]` と `[shell_alias]` は experimental / 新しい機能のため、mise が古いと無視される。`mise self-update` か `brew upgrade mise`
- 一部ツールが Registry の名前と合わずインストールに失敗したら、`mise registry | grep <name>` で名前を確認し `config.toml` を直す
- `npm-global-packages` は廃止（`[tools]` の `"npm:difit"` に移行）
