# Claude Code を Homebrew cask から native install に移行

- 日付: 2026-09-25
- 関連: ブランチ `chore/claude-code-native-install`

## 背景

Homebrew cask の `claude-code` はリリースへの追従が遅いので、公式の native install
（`~/.local/bin/claude`、自動更新あり）に切り替えた。リポジトリ側では次の2つを変更済み。

- `Brewfile` から `cask "claude-code"` を削除
- `home/.zshrc` に `export PATH="$HOME/.local/bin:$PATH"` を追加

ただし `git pull` しても、端末に入っている cask は消えず native 版も入らない。
cask を残したままだと `/opt/homebrew/bin/claude` が優先され、古いバージョンが使われ続ける。

## 前提

- dotfiles リポジトリが最新（`git pull` 済み）で `./install.sh` 実行済みであること
- `~/.zshrc` が dotfiles の `home/.zshrc` へのシンボリックリンクであること

## 完了チェック

以下がすべて期待どおりなら適用済み。手順は不要。

```bash
zsh -lic 'command -v claude'                 # 期待: /Users/<user>/.local/bin/claude
brew list --cask claude-code >/dev/null 2>&1; echo $?   # 期待: 1（cask が入っていない）
```

## 手順

1. `~/.zshrc` に PATH 行が入っていることを確認する（`git pull` で入る）

   ```bash
   grep -n '.local/bin' ~/.zshrc
   ls -la ~/.zshrc   # dotfiles/home/.zshrc へのシンボリックリンクであること
   ```

2. native 版をインストールする

   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   # brew 版の claude が動いているなら `claude install latest` でもよい
   ```

   `~/.local/bin/claude` が作られる（実体は `~/.local/share/claude/versions/` 配下）。

3. `~/.zshrc` が書き換えられていないか確認する

   インストーラや作業中の Claude が `~/.zshrc` に PATH を追記したり、バックアップ
   （`~/.zshrc.bak-*`）を作ったりすることがある。`~/.zshrc` はリポジトリ内ファイルへの
   シンボリックリンクなので、書き換えはそのまま dotfiles の差分になる。

   ```bash
   ls -la ~/.zshrc                          # シンボリックリンクのままか
   git -C <dotfiles> diff home/.zshrc       # 意図しない追記がないか
   ```

   - PATH 行が重複して追記されていたら、その追記だけ取り除く（リポジトリの内容で足りている）
   - `~/.zshrc` が通常ファイルに置き換わっていたら、中身の差分を確認してから `./install.sh` を再実行し、リンクを張り直す

4. cask をアンインストールする

   ```bash
   brew uninstall --cask claude-code
   ```

   `/opt/homebrew/bin/claude` のシンボリックリンクも一緒に削除される。

## 確認

```bash
zsh -lic 'which -a claude'        # 期待: ~/.local/bin/claude のみ（/opt/homebrew/bin/claude がない）
zsh -lic 'claude --version'       # 期待: native 版のバージョン
brew bundle check --global        # 期待: The Brewfile's dependencies are satisfied.
```

## 注意点・トラブルシュート

- **実行中の Claude Code セッションは古いバイナリのまま動き続ける。** ターミナルを開き直して
  `claude` を起動し直すと native 版になる
- 以後は native 版が自動で更新される。手動で上げたいときは `claude update`
- 動作確認が済んだら `~/.zshrc.bak-*` は削除してよい
- `~/.claude/` の設定・メモリはインストール方法に関係なくそのまま使われる（移行不要）
