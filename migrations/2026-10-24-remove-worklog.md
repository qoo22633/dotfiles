# worklog コマンドの削除

- 日付: 2026-10-24
- 関連: worklog を使わなくなったため `.claude/commands/worklog.md` と `/create-pr` の作業ログ確認を削除

## 背景

`.claude/commands/worklog.md` を削除した。postinstall は削除側を反映しないため、
すでにリンクしている端末では `~/.claude/commands/worklog.md` が壊れたリンクとして残る。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）であること

## 完了チェック

以下が期待どおりなら適用済み。手順は不要。

```bash
(test -e ~/.claude/commands/worklog.md || test -L ~/.claude/commands/worklog.md) && echo exists || echo removed   # 期待: removed
```

## 手順

1. `rm ~/.claude/commands/worklog.md`（無ければスキップ）

## 確認

```bash
ls ~/.claude/commands/ | grep worklog   # 期待: 何も表示されない
```
