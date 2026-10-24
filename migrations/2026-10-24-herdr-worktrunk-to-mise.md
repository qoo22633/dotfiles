# herdr / worktrunk を Homebrew から mise に移行

- 日付: 2026-10-24
- 関連: herdr と worktrunk が mise Registry にあるため Brewfile から `.config/mise/config.toml` へ移した

## 背景

`herdr` と `worktrunk` は mise Registry にあるため、`Brewfile` の `brew` から `[tools]` に移した。
`brew bundle` は削除側を反映しないため、すでに brew で入れている端末では手動でアンインストールする。
brew 版が残ると PATH の順によってどちらが使われるか不定になる。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）であること

## 完了チェック

以下がすべて期待どおりなら適用済み。手順は不要。

```bash
brew list --formula 2>/dev/null | grep -qxE 'herdr|worktrunk' && echo brew || echo no-brew   # 期待: no-brew
mise ls --installed herdr worktrunk                                                            # 期待: 両方表示される
```

## 手順

1. `mise install`（herdr / worktrunk が入る）
2. `brew uninstall herdr worktrunk`（未インストールならスキップ）
3. 新しいターミナルを開く

## 確認

```bash
command -v herdr wt   # 期待: どちらも ~/.local/share/mise/ 配下
herdr --version
wt --version
```

## 注意点・トラブルシュート

- `brew uninstall` 後も古いパスが使われる場合は `hash -r` を実行するか、新しいターミナルを開く
