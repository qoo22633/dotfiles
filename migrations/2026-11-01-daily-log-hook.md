# デイリーノートへの作業ログ自動追記フックの導入

- 日付: 2026-11-01
- 関連: `home/.claude/hooks/daily-log.sh`、postinstall の SessionEnd フック登録

## 背景

Claude Code のセッション終了時に、会話を `claude -p`（haiku）で要約して Obsidian のデイリーノート
`## 🤖 AIメモ` へ1行追記するフックを追加した。

`~/.claude/settings.json` は herdr などが書き換える端末固有のファイルでリンクできないため、
フックの登録は postinstall が jq で冪等に行う。保管庫を置かない端末（会社PCなど）では
`CLAUDE_DAILY_LOG_VAULT` を設定した端末にだけリンクと登録を行う（オプトイン）。会社PCなどでは設定しない。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）で `mise install`（または `mise run link`）実行済みであること
- `jq` と `claude` が使えること
- 記録したい端末では先に `~/.zshrc.local` に `CLAUDE_DAILY_LOG_VAULT` を設定すること（会社PCでは設定しない＝この移行は対象外）（下記）

## 完了チェック

以下がすべて期待どおりなら適用済み。手順は不要。

```bash
test -x ~/.claude/hooks/daily-log.sh && echo linked || echo missing   # 期待: linked
jq -e '[.hooks.SessionEnd[]?.hooks[]? | select(.command | endswith("daily-log.sh"))] | length > 0' ~/.claude/settings.json   # 期待: true
```

## 手順

1. 記録する端末のみ、`~/.zshrc.local` に追記して新しいシェルを開く
   ```bash
   export CLAUDE_DAILY_LOG_VAULT="$HOME/Documents/note"
   ```
2. `mise run link` を実行する（リンクと SessionEnd フックの登録が行われる）

## 確認

```bash
echo "$CLAUDE_DAILY_LOG_VAULT"   # 記録する端末では保管庫のパス、しない端末では空
```

2回以上やり取りしたセッションを終了し、数十秒後にその日のデイリーノートの `## 🤖 AIメモ` に
`- HH:MM [プロジェクト名] 要約 #claude-code` が追記されれば成功。

## 注意点・トラブルシュート

- 今日のデイリーノートが未作成の端末では何もしない（Obsidian 側の作成と競合させないため）
- 要約中の失敗は `${TMPDIR:-/tmp}/daily-log.err` に残る
- ユーザー発話が2回未満の短いセッションと、雑談だけのセッション（要約が `SKIP`）は記録しない
- 会社PCでは `CLAUDE_DAILY_LOG_VAULT` を設定しない。会話内容が個人の保管庫と同期先に残るため
- 設定した端末をやめるときは、変数を消し、`settings.json` の SessionEnd から該当エントリを削除する（postinstall は削除を反映しない）
