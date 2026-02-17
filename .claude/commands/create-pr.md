---
description: Gitの差分とコンテキストを分析してPRを作成する
argument-hint: [base-branch]
allowed-tools: Bash(git *), Bash(gh *), Read, Glob, AskUserQuestion
---

# PR作成コマンド

以下の手順でPull Requestを作成してください。

## 1. 事前チェック

以下を並列で確認:
- `git status` で未コミットの変更がないか確認。未コミット変更がある場合はユーザーに警告し、続行するか確認する
- `git branch --show-current` で現在のブランチを取得。main/masterブランチ上の場合は警告する
- `git remote -v` でリモートが設定されているか確認
- `gh pr list --head $(git branch --show-current) --state open` で既存のPRがないか確認。既存PRがある場合はそのURLを表示し、新規作成するか確認する

## 2. ベースブランチの決定

以下の優先順位でベースブランチを決定:
1. `$ARGUMENTS` が指定されていればそれを使用
2. `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'` でリポジトリのデフォルトブランチを取得
3. 上記が失敗した場合は `main` をフォールバックとして使用

## 3. 変更内容の分析

以下を実行して変更内容を把握:
- `git log <base-branch>..HEAD --oneline` でコミット一覧を取得
- `git diff <base-branch>...HEAD --stat` で変更ファイルの統計を取得
- `git diff <base-branch>...HEAD` で詳細な差分を取得（大きすぎる場合は `--stat` の結果を中心に分析）

会話コンテキストも参照し、なぜこの変更を行ったかの背景も把握する。

## 4. PRテンプレートの検出

以下の順序でテンプレートを探す:
1. `.github/pull_request_template.md`
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `docs/pull_request_template.md`

テンプレートが見つかった場合はその形式に従う。見つからない場合は以下のデフォルトテンプレートを使用:

```markdown
## 概要

## 変更内容

## テスト方法
```

## 5. 下書きの提示

分析結果をもとにPRのタイトルと本文の下書きを作成し、ユーザーに提示する。

**タイトル**: 70文字以内で変更の要約を記述
**本文**: テンプレートに沿って以下を記述:
- 概要: 変更の目的と背景を1〜3文で
- 変更内容: 主な変更点を箇条書きで
- テスト方法: テストや動作確認の手順

下書きを提示したら、`AskUserQuestion` ツールを使って以下を1つの質問で確認する:
- 選択肢: 「通常のPRとして作成」「ドラフトPRとして作成」「キャンセル」

## 6. PR作成

ユーザーの確認を得たら、`gh pr create` でPRを作成する。

- リモートにプッシュされていない場合は `git push -u origin HEAD` を先に実行
- ドラフトの場合は `--draft` フラグを付与
- タイトルは `--title` で、本文は `--body` でHEREDOCを使って渡す

```bash
gh pr create --base <base-branch> --title "タイトル" --body "$(cat <<'EOF'
本文
EOF
)"
```

## 7. 完了報告

作成されたPRのURLを表示する。

## 8. 作業ログの記録

`AskUserQuestion` ツールを使って以下を確認する:
- 質問: 「作業ログ（/worklog）も記録しますか？」
- 選択肢: 「記録する」「スキップ」

「記録する」を選択された場合は、`/worklog` コマンドを実行する。
