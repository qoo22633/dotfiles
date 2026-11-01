#!/usr/bin/env bash
# SessionEnd フック: セッションを要約し、Obsidian のデイリーノート「🤖 AIメモ」へ1行追記する。
#
# - 会話の内容が保管庫に残るため、CLAUDE_DAILY_LOG_VAULT を明示した端末だけで動く（オプトイン）。
#   未設定、または今日のデイリーノートが無い端末では何もしない。
#   会社PCには設定しない。postinstall もこの変数がある端末にしかフックを登録しない
# - SessionEnd フックは終了直後に打ち切られるため、要約と書き込みはバックグラウンドで行う
set -euo pipefail

SECTION_HEADING="## 🤖 AIメモ"
DAILY_NOTE_TAG="#claude-code"
MIN_USER_PROMPTS=2          # これ未満の短いセッションは記録しない
MAX_TRANSCRIPT_CHARS=20000  # 要約に渡す会話の上限（超えた分は先頭を捨てる）
SUMMARY_MODEL="haiku"

# 要約のために起動する claude -p 自身の SessionEnd で再び走らないようにする
[[ -n "${DAILY_LOG_RUNNING:-}" ]] && exit 0

vault="${CLAUDE_DAILY_LOG_VAULT:-}"
[[ -d "$vault" ]] || exit 0

now_epoch="$(date +%s)"
daily_note="$vault/Diary/Daily/$(date -r "$now_epoch" '+%Y/%m/📰%Y-%m-%d(%a)').md"
[[ -f "$daily_note" ]] || exit 0

input="$(cat)"
transcript_path="$(jq -r '.transcript_path // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
[[ -f "$transcript_path" ]] || exit 0

# 会話本文（ユーザー発話とアシスタントの文章）だけを取り出す。tool_use / tool_result は除く
conversation="$(jq -r '
  select(.type == "user" or .type == "assistant")
  | .type as $role
  | .message.content
  | (if type == "string" then . else map(select(.type == "text") | .text) | join("\n") end)
  | select(length > 0)
  | "[\($role)] \(.)"
' "$transcript_path")"

user_prompt_count="$(grep -c '^\[user\]' <<<"$conversation" || true)"
((user_prompt_count >= MIN_USER_PROMPTS)) || exit 0

project_name="$(basename "${cwd:-unknown}")"
time_label="$(date -r "$now_epoch" '+%H:%M')"

summarize_and_append() {
  local summary
  summary="$(
    cd "${TMPDIR:-/tmp}"
    tail -c "$MAX_TRANSCRIPT_CHARS" <<<"$conversation" |
      DAILY_LOG_RUNNING=1 claude -p --model "$SUMMARY_MODEL" --no-session-persistence \
        "以下は Claude Code の作業セッションの記録です。後から振り返るための作業ログとして、何を調べ・決め・変更したかを日本語1文(100文字以内)で要約してください。
出力は要約の1文だけ。前置き・引用符・改行は不要。
次の情報は要約に含めないでください: 認証情報（パスワード・APIキー・トークン・秘密鍵）、個人情報（氏名・メールアドレス・電話番号・住所など）、顧客名・取引先名・社内の固有情報、その他外部に漏れてはいけない機密。必要なら「認証まわりを修正」のように抽象化して書いてください。
雑談のみ、または機密性が高すぎて抽象化しても書けない場合は SKIP とだけ出力してください。"
  )"
  summary="$(tr -d '\n' <<<"$summary")"
  [[ -n "$summary" && "$summary" != "SKIP" ]] || return 0

  local line="- $time_label [$project_name] $summary $DAILY_NOTE_TAG"
  local tmp_file
  tmp_file="$(mktemp)"
  # AIメモ節の最後の記入行の直後に挿入する。節が無ければ末尾に節ごと足す。
  # 節末尾の空行は保持して挿入行の後ろへ回す（見出し前の空行の前に入れると、記入行との間に空行が挟まるため）
  awk -v heading="$SECTION_HEADING" -v line="$line" '
    function flush_blanks() { for (; blanks > 0; blanks--) print "" }
    function flush_pending() {
      if (in_section && !inserted) { print line; inserted = 1 }
      flush_blanks()
    }
    $0 == heading { in_section = 1; print; next }
    in_section && /^## / { flush_pending(); in_section = 0 }
    in_section && $0 == "" { blanks++; next }
    in_section { flush_blanks() }
    { print }
    END {
      flush_pending()
      if (!inserted) { print ""; print heading; print line }
    }
  ' "$daily_note" >"$tmp_file"
  cat "$tmp_file" >"$daily_note"
  rm -f "$tmp_file"
}

# stdin/stdout を切り離してバックグラウンドへ。失敗はログに残す
log_file="${TMPDIR:-/tmp}/daily-log.err"
( summarize_and_append >/dev/null 2>>"$log_file" </dev/null & )
