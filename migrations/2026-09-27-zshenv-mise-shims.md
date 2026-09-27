# ~/.zshenv で mise shims を PATH に追加

- 日付: 2026-09-27
- 関連: `home/.zshenv` の追加

## 背景

mise は `.zshrc` の `mise activate` で PATH を通しているが、`.zshrc` は対話シェルでしか読まれない。
そのため Claude Code の Bash ツールなど非対話シェルから `vercel` などの mise 管理ツールが見つからなかった。
非対話シェルでも読まれる `~/.zshenv` を新設し、`~/.local/share/mise/shims` を PATH に追加した。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）であること
- mise がインストール済みであること

## 完了チェック

以下がすべて期待どおりなら適用済み。手順は不要。

```bash
readlink ~/.zshenv   # 期待: <dotfiles>/home/.zshenv
zsh -c 'echo $PATH' | tr ':' '\n' | grep -c 'mise/shims'   # 期待: 1 以上
```

## 手順

1. `./install.sh` を実行して `~/.zshenv` のシンボリックリンクを作成する
   （既存の `~/.zshenv` があれば `~/.dotfiles_backup/` に退避される。中身が必要なら `.zshrc.local` などへ移す）

## 確認

```bash
zsh -c 'command -v mise >/dev/null && ls ~/.local/share/mise/shims | head -1 | xargs -I{} sh -c "command -v {}"'
# 期待: ~/.local/share/mise/shims/<ツール名> が表示される
```

## 注意点・トラブルシュート

- shims ディレクトリが無い端末（mise 未使用）では何もしないようにガードしている
- 対話シェルでは `.zshrc` の `mise activate` が優先されるため挙動は変わらない
