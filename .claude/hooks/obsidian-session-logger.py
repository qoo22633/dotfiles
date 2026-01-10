#!/usr/bin/env python3
"""
Obsidian Daily Note Session Logger for Claude Code
会話終了時に自動的にObsidianデイリーノートに要約を記録します。
"""

import json
import sys
import os
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional
import locale

# 曜日マッピング
WEEKDAY_MAP = {
    0: "Mon", 1: "Tue", 2: "Wed", 3: "Thu",
    4: "Fri", 5: "Sat", 6: "Sun"
}

def load_transcript(transcript_path: str) -> List[Dict]:
    """会話履歴を読み込む"""
    if not transcript_path or not Path(transcript_path).exists():
        return []

    transcript = []
    try:
        with open(transcript_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    transcript.append(json.loads(line))
                except json.JSONDecodeError:
                    continue
        return transcript
    except Exception as e:
        print(f"Error loading transcript: {e}", file=sys.stderr)
        return []

def extract_conversation(transcript: List[Dict]) -> str:
    """会話履歴から主要な会話を抽出"""
    conversation_parts = []

    for entry in transcript:
        entry_type = entry.get("type", "")

        if entry_type == "user_message":
            content = entry.get("content", "")
            if isinstance(content, str) and content.strip():
                conversation_parts.append(f"User: {content.strip()}")

        elif entry_type == "assistant_message":
            content = entry.get("content", "")
            if isinstance(content, str) and content.strip():
                # アシスタントメッセージが長すぎる場合は省略
                if len(content) > 500:
                    content = content[:500] + "..."
                conversation_parts.append(f"Assistant: {content.strip()}")

    return "\n\n".join(conversation_parts)

def summarize_conversation(conversation: str) -> str:
    """会話内容を要約（シンプルな抽出ベース）"""
    if not conversation:
        return "会話内容なし"

    lines = conversation.split("\n")
    user_messages = [line for line in lines if line.startswith("User:")]

    if not user_messages:
        return "会話内容なし"

    # 最初のユーザーメッセージと重要なポイントを抽出
    summary_parts = []

    # 最初の3つのユーザーメッセージを取得
    for msg in user_messages[:3]:
        clean_msg = msg.replace("User:", "").strip()
        if clean_msg:
            summary_parts.append(f"- {clean_msg}")

    if len(user_messages) > 3:
        summary_parts.append(f"- ... (他 {len(user_messages) - 3} 件)")

    return "\n".join(summary_parts)

def extract_simple_learning(conversation: str) -> Optional[str]:
    """会話から簡易的に学びを抽出"""
    if not conversation:
        return None

    learning_keywords = [
        "hook", "設定", "API", "CLI", "ツール", "コマンド",
        "方法", "実装", "機能", "パターン", "ベストプラクティス"
    ]

    lines = conversation.split("\n")
    assistant_messages = [line for line in lines if line.startswith("Assistant:")]

    learning_parts = []

    # アシスタントのメッセージから技術的なポイントを抽出
    for msg in assistant_messages[:5]:
        clean_msg = msg.replace("Assistant:", "").strip()
        # キーワードが含まれているメッセージから学びを抽出
        for keyword in learning_keywords:
            if keyword in clean_msg:
                # 文の最初の部分を抽出（最大80文字）
                if len(clean_msg) > 80:
                    clean_msg = clean_msg[:80] + "..."
                learning_parts.append(f"- {clean_msg}")
                break

    if learning_parts:
        # 重複を除去して最大3個まで
        unique_learning = list(dict.fromkeys(learning_parts))[:3]
        return "\n".join(unique_learning)

    return None

def summarize_with_claude_api(conversation: str) -> Optional[Dict[str, str]]:
    """Claude APIを使って会話を要約し、学びを抽出（オプション）"""
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        return None

    try:
        import anthropic

        client = anthropic.Anthropic(api_key=api_key)

        message = client.messages.create(
            model="claude-3-5-haiku-20241022",
            max_tokens=700,
            messages=[{
                "role": "user",
                "content": f"""以下のClaude Codeとの会話から、2つの情報を抽出してください：

1. **要約**: 会話の主要なポイントを箇条書き（3-5個）でまとめる
2. **学び**: この会話から得られた知識、技術的な学び、今後活用できるTipsなどを箇条書き（2-4個）でまとめる

以下の形式で出力してください：
## 要約
- ...
- ...

## 学び
- ...
- ...

会話内容:
{conversation[:4000]}"""
            }]
        )

        if message.content and len(message.content) > 0:
            response_text = message.content[0].text

            # 要約と学びを分割
            summary_parts = []
            learning_parts = []

            current_section = None
            for line in response_text.split("\n"):
                line = line.strip()
                if not line:
                    continue

                if "## 要約" in line or "要約" in line and line.startswith("#"):
                    current_section = "summary"
                elif "## 学び" in line or "学び" in line and line.startswith("#"):
                    current_section = "learning"
                elif line.startswith("-"):
                    if current_section == "summary":
                        summary_parts.append(line)
                    elif current_section == "learning":
                        learning_parts.append(line)

            return {
                "summary": "\n".join(summary_parts) if summary_parts else None,
                "learning": "\n".join(learning_parts) if learning_parts else None
            }

        return None

    except ImportError:
        # anthropicパッケージがない場合はスキップ
        return None
    except Exception as e:
        print(f"Claude API error: {e}", file=sys.stderr)
        return None

def extract_tools_and_files(transcript: List[Dict]) -> Dict[str, any]:
    """使用したツールと変更ファイルを抽出"""
    tools_used = set()
    files_modified = set()

    for entry in transcript:
        entry_type = entry.get("type", "")

        if entry_type == "tool_use":
            tool_name = entry.get("name", "")
            if tool_name:
                tools_used.add(tool_name)

            # ファイル変更を検出
            params = entry.get("input", {})
            if "file_path" in params:
                files_modified.add(params["file_path"])

    return {
        "tools": sorted(list(tools_used)),
        "files": sorted(list(files_modified))
    }

def get_daily_note_path(base_path: Path) -> Path:
    """Obsidianデイリーノートのパスを生成"""
    now = datetime.now()
    year = now.strftime("%Y")
    month = now.strftime("%m")
    date_str = now.strftime("%Y-%m-%d")
    weekday = WEEKDAY_MAP[now.weekday()]

    # パス: /Users/yudai/Documents/note/Diary/Daily/2026/01/📰2026-01-10(Sat).md
    daily_note_path = base_path / "Diary" / "Daily" / year / month / f"📰{date_str}({weekday}).md"

    return daily_note_path

def extract_session_title(conversation: str) -> str:
    """会話から適切なセッションタイトルを抽出"""
    lines = conversation.split("\n")
    for line in lines:
        if line.startswith("User:"):
            title = line.replace("User:", "").strip()
            # タイトルが長すぎる場合は短縮
            if len(title) > 60:
                title = title[:60] + "..."
            return title
    return "セッション"

def format_session_entry(hook_data: Dict, conversation: str, summary: str, learning: str, metadata: Dict) -> str:
    """セッションエントリをフォーマット"""
    timestamp = datetime.now().strftime("%H:%M:%S")
    session_title = extract_session_title(conversation)

    entry = f"\n## 🤖 Claude Code Log\n"
    entry += f"### [{timestamp}] {session_title}\n"

    entry += "**要約**\n"
    entry += f"{summary}\n"

    if learning:
        entry += "**学び**\n"
        entry += f"{learning}\n"

    if metadata["files"]:
        entry += "**変更ファイル**\n"
        for file_path in metadata["files"][:10]:  # 最大10ファイル
            entry += f"- `{file_path}`\n"
        if len(metadata["files"]) > 10:
            entry += f"- ... (他 {len(metadata['files']) - 10} 件)\n"

    entry += "---\n\n"

    return entry

def main():
    # デバッグログ（hookが実行されたことを記録）
    debug_log_path = Path.home() / ".claude" / "obsidian-hook-debug.log"
    with open(debug_log_path, "a", encoding='utf-8') as debug_log:
        debug_log.write(f"\n=== Hook triggered at {datetime.now()} ===\n")

    try:
        # hookデータを読み込む
        hook_data = json.load(sys.stdin)

        # デバッグ：受信したデータを記録
        with open(debug_log_path, "a", encoding='utf-8') as debug_log:
            debug_log.write(f"Hook data: {json.dumps(hook_data, indent=2)}\n")
    except json.JSONDecodeError as e:
        with open(debug_log_path, "a", encoding='utf-8') as debug_log:
            debug_log.write(f"Error parsing hook input: {e}\n")
        print(f"Error parsing hook input: {e}", file=sys.stderr)
        sys.exit(1)

    # clearやresumeでは記録しない
    reason = hook_data.get("reason", "")
    if reason in ["clear", "resume"]:
        with open(debug_log_path, "a", encoding='utf-8') as debug_log:
            debug_log.write(f"Skipping reason: {reason}\n")
        sys.exit(0)

    # Obsidianのベースパスを取得
    obsidian_base = os.getenv("OBSIDIAN_VAULT_PATH", "/Users/yudai/Documents/note")
    obsidian_base_path = Path(obsidian_base)

    if not obsidian_base_path.exists():
        print(f"Obsidian vault not found: {obsidian_base}", file=sys.stderr)
        sys.exit(1)

    # デイリーノートのパスを生成
    daily_note_path = get_daily_note_path(obsidian_base_path)
    daily_note_path.parent.mkdir(parents=True, exist_ok=True)

    # 会話履歴を読み込む
    transcript_path = hook_data.get("transcript_path", "")
    transcript = load_transcript(transcript_path)

    if not transcript:
        # 会話がない場合はスキップ
        with open(debug_log_path, "a", encoding='utf-8') as debug_log:
            debug_log.write(f"No transcript found at: {transcript_path}\n")
        sys.exit(0)

    # 会話を抽出
    conversation = extract_conversation(transcript)

    # 要約と学びを生成（Claude API → フォールバック）
    summary = None
    learning = None

    api_result = summarize_with_claude_api(conversation)
    if api_result:
        summary = api_result.get("summary")
        learning = api_result.get("learning")

    # フォールバック：APIが使えない場合
    if not summary:
        summary = summarize_conversation(conversation)

    if not learning:
        learning = extract_simple_learning(conversation)

    # メタデータを抽出
    metadata = extract_tools_and_files(transcript)

    # エントリをフォーマット
    entry = format_session_entry(hook_data, conversation, summary, learning, metadata)

    # デイリーノートに追記
    try:
        # ファイルが存在しない場合は作成
        if not daily_note_path.exists():
            today = datetime.now().strftime("%Y-%m-%d (%a)")
            header = f"# 📰 Daily Note - {today}\n\n"
            daily_note_path.write_text(header, encoding='utf-8')

        # 追記
        with open(daily_note_path, "a", encoding='utf-8') as f:
            f.write(entry)

        # デバッグ：成功を記録
        with open(debug_log_path, "a", encoding='utf-8') as debug_log:
            debug_log.write(f"✅ Successfully written to: {daily_note_path}\n")

        # 成功メッセージ
        output = {
            "continue": True,
            "suppressOutput": False,
            "systemMessage": f"✅ Session logged to Obsidian: {daily_note_path.name}"
        }
        print(json.dumps(output))
        sys.exit(0)

    except Exception as e:
        # デバッグ：エラーを記録
        with open(debug_log_path, "a", encoding='utf-8') as debug_log:
            debug_log.write(f"❌ Error: {e}\n")
        print(f"Error writing to Obsidian: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
