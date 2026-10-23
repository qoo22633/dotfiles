# .zshrc の整理（Intel 時代の設定を削除）

- 日付: 2026-10-23
- 関連: `refactor: .zshrc を整理し、未使用の設定を削除`

## 背景

`home/.zshrc` から次を削除した。最初の端末（Apple Silicon・`/usr/local` なし）では全て空振りだったが、
Intel Mac や別構成の端末では必要な可能性がある。

- `/usr/local/bin` `/usr/local/sbin` `/usr/local/opt/libxml2/bin` `/usr/local/opt/openssl@3/bin` の PATH 追加
- `PKG_CONFIG_PATH`（imagemagick@6）と `OBJC_DISABLE_INITIALIZE_FORK_SAFETY`
- `brew --prefix openssl` の PATH 追加
- `fpath` への `~/.config/zsh/completion`（ディレクトリ自体が存在しない）

`y` と `ghq-fzf` は `.config/zsh/functions/` に分離した。`~/.config/zsh` のリンクが無い端末では
関数が読み込まれないため、`mise run link` が必要。

また `wt` の初期化を `wt config shell init zsh` の1本にした（旧 `wt shell-init` は存在しないコマンド）。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）であること

## 完了チェック

以下がすべて期待どおりなら適用済み（または対応不要）。手順は不要。

```bash
[ -L ~/.config/zsh ] && echo linked || echo missing   # 期待: linked
ls /usr/local/opt 2>/dev/null | head -1   # 期待: 何も出ない（/usr/local/opt が無い端末は PATH の復元は不要）
```

## 手順

1. `mise run link` で `~/.config/zsh` をリンクする
2. `/usr/local/opt` が存在する端末だけ、必要な行を `~/.zshrc.local`（git 管理外）に足す。

```zsh
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/libxml2/bin:$PATH"
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick@6/6.9.9-40/lib/pkgconfig
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```

## 確認

```bash
zsh -i -c 'echo $PATH | tr ":" "\n" | head -5'   # 期待: 必要なパスが含まれる
```

## 注意点・トラブルシュート

- 全体を元に戻したいときは、整理コミットを `git revert` する
- 仕事用の設定は dotfiles に入れず、`~/.zshrc.local` に置く
