# sheldon 用に openssl@3 を Homebrew で入れる

- 日付: 2026-10-26
- 関連: Brewfile に `brew "openssl@3"` を追加

## 背景

mise（aqua バックエンド）で入れた sheldon の配布バイナリは `/opt/homebrew/opt/openssl@3` の
`libssl.3.dylib` / `libcrypto.3.dylib` を動的リンクしている。
Homebrew の既定 openssl が `openssl@4` になり、`openssl@3` に依存する formula がなくなると
`brew autoremove` / `brew cleanup` で消され、sheldon が次のエラーで起動できなくなる。

```
dyld: Library not loaded: /opt/homebrew/opt/openssl@3/lib/libssl.3.dylib
```

最初の端末では `brew install openssl@3` で復旧し、消されないよう Brewfile に明示した。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）であること

## 完了チェック

以下がすべて期待どおりなら適用済み。手順は不要。

```bash
brew list --formula 2>/dev/null | grep -qx 'openssl@3' && echo ok || echo missing   # 期待: ok
```

## 手順

1. `brew bundle install --global`（または `mise run link`）で openssl@3 を入れる

## 確認

```bash
sheldon --version   # 期待: dyld エラーが出ずにバージョンが表示される
```

## 注意点・トラブルシュート

- インストール時に `brew link openssl@3` を促すヒントが出るが、リンクは不要（`/opt/homebrew/opt/openssl@3` があれば動く）
