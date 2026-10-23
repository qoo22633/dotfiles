# tig / vimrc の削除

- 日付: 2026-10-23
- 関連: tig と Vim（Neovim に移行済み）を使わなくなったため `home/.tigrc` `home/.vimrc` を削除

## 背景

`home/.tigrc` と `home/.vimrc` をリポジトリから削除した。`postinstall.sh` は削除側を反映しないため、
各端末の `~/.tigrc` `~/.vimrc` は壊れたシンボリックリンクとして残る。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）であること

## 完了チェック

以下がすべて期待どおりなら適用済み。手順は不要。

```bash
[ -e ~/.tigrc ] || [ -L ~/.tigrc ] && echo exists || echo removed   # 期待: removed
[ -e ~/.vimrc ] || [ -L ~/.vimrc ] && echo exists || echo removed   # 期待: removed
```

## 手順

1. `rm ~/.tigrc ~/.vimrc`（リンクのみ。実体ファイルだった場合は中身を確認してから削除）
2. tig を入れていれば `brew uninstall tig`（未インストールならスキップ）

## 確認

```bash
ls -la ~/.tigrc ~/.vimrc   # 期待: No such file or directory
```
