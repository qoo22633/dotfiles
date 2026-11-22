# pi（コーディングエージェント）の導入とフッターのリンク

- 日付: 2026-11-21
- 関連: `.config/mise/config.toml` の `pi`、`home/.pi/agent/extensions/statusline.ts`、postinstall の pi セクション

## 背景

ターミナルのコーディングエージェント pi を mise で入れ、Claude Code のステータスラインと同じ見た目の
フッター（extension）を dotfiles で管理するようにした。

`~/.pi/agent/` には `auth.json`（API キー・OAuth トークン）やセッションが同居するため、
ディレクトリごとではなく `extensions/*.ts` をファイル単位でリンクする。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）であること

## 完了チェック

以下がすべて期待どおりなら適用済み。手順は不要。

```bash
command -v pi >/dev/null && echo installed || echo missing   # 期待: installed
test -L ~/.pi/agent/extensions/statusline.ts && echo linked || echo missing   # 期待: linked
test -L ~/.pi && echo bad || echo ok   # 期待: ok（~/.pi 自体はリンクにしない）
```

## 手順

1. `mise install` を実行する（pi のインストールと、postinstall によるリンク作成が行われる）
2. pi を使う端末では、別のターミナルで `pi` を起動して `/login` でログインする
   （認証情報は `~/.pi/agent/auth.json` に保存され、dotfiles には入らない）

## 確認

```bash
pi --version   # 期待: バージョンが表示される
```

`pi` を起動して、画面下に `📂` `🧠` `🕐` の3行のフッターが出れば成功。

## 注意点・トラブルシュート

- `pi auth login` は対話できる端末が必要なので、Claude Code の `!` からは実行できない
- パッケージ（`pi install npm:...`）とモデルの設定は `~/.pi/agent/settings.json` にあり、まだ dotfiles では管理していない
