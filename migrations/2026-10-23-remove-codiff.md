# codiff の削除

- 日付: 2026-10-23
- 関連: codiff を使わなくなったため Brewfile・abbr から削除

## 背景

`Brewfile` から `codiff`（cask）と `nkzw-tech/tap` を削除した。`brew bundle` は削除側を反映しないため、
すでに入れている端末では手動でアンインストールする。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）であること

## 完了チェック

以下がすべて期待どおりなら適用済み。手順は不要。

```bash
brew list --cask codiff 2>&1 | grep -q "No such" && echo removed   # 期待: removed
brew tap | grep -q nkzw-tech && echo tapped || echo untapped        # 期待: untapped
```

## 手順

1. `brew uninstall --cask codiff`（未インストールならスキップ）
2. `brew untap nkzw-tech/tap`（未 tap ならスキップ）

## 確認

```bash
command -v codiff   # 期待: 何も表示されない
```

## 注意点・トラブルシュート

- 他に `nkzw-tech/tap` のパッケージを入れている場合、`untap` は失敗する。その場合は tap を残してよい
