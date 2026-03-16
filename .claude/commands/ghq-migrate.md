---
description: 既存のローカルgitリポジトリをghq管理下に移行する
allowed-tools: Bash(git *), Bash(ghq *), Bash(find *), Bash(sed *), Bash(mv *), Bash(ls *), Bash(ghq-migrator *), Read
---

# ghq 移行コマンド

ローカルに存在するgitリポジトリをghqの管理ディレクトリ構造へ移行します。

## 実行フロー

### Step 1: 環境確認

```bash
ghq root
ghq --version
```

ghq がインストールされていない場合は `brew install ghq` を案内してください。

### Step 2: 探索対象ディレクトリの確認

ユーザーに以下を確認してください：
- 移行対象のリポジトリが存在するディレクトリ（例: `~/repos`, `~/src`, `~/workspace`, `~/projects`）
- 複数ある場合はすべて列挙してもらう

### Step 3: gitリポジトリの列挙（ドライラン）

指定ディレクトリ内のgitリポジトリを検索し、一覧を表示します：

```bash
# 例: ~/repos 以下を探索（最大深さ3）
find ~/repos -name ".git" -maxdepth 3 -type d | sed 's|/.git$||'
```

以下のリポジトリを除外してください：
- すでに ghq root 配下にあるもの（`ghq list` で確認）
- `.git` ディレクトリが存在しないディレクトリ

移行予定リストをユーザーに提示し、確認を取ってください。

### Step 4: 移行実行

ユーザーの確認後、以下の優先順位で移行します：

#### 方法A: ghq get を使う（推奨）

リモートURLが設定されている場合、`ghq get` で正規ディレクトリに再取得できます：

```bash
# リモートURLを取得
git -C <repo_path> remote get-url origin

# ghq get で取得（既存の作業内容は保持されないため注意）
ghq get <remote_url>
```

#### 方法B: ディレクトリを手動 mv する

リモートURLから移行先パスを構築して mv します：

```bash
# リモートURL例: git@github.com:user/repo.git
# 移行先: $(ghq root)/github.com/user/repo

remote_url=$(git -C <repo_path> remote get-url origin)
# URL解析して ghq root 配下の適切なパスに mv
```

#### 方法C: ghq-migrator を使う（利用可能な場合）

```bash
# ghq-migrator がインストール済みの場合
ghq-migrator --dry-run <探索ディレクトリ>  # ドライラン
ghq-migrator <探索ディレクトリ>            # 本実行
```

### Step 5: 結果の確認

```bash
ghq list
```

移行されたリポジトリ数と一覧を表示してください。

## 注意事項

- 移行前に未コミットの変更がないか確認すること
- 方法Aの `ghq get` は新規取得のため、ローカルの未プッシュコミットは失われる
- 方法Bの mv の場合、元のパスへのシンボリックリンクや参照が壊れる可能性がある
- 大量のリポジトリを移行する場合は小さいバッチで試してから全体を実行する
