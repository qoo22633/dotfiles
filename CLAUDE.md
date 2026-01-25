# Claude Code 設定

## プロジェクト概要

個人的な開発環境設定を管理するdotfilesプロジェクトです。

## 主要コンポーネント

- **Zsh**: シェル環境（mise、sheldon、fzf、zoxide、atuin使用）
- **Neovim**: LazyVimベースの設定 + Claude Code統合
- **WezTerm**: ターミナルエミュレータ
- **Git**: lazygitを使用

## 重要なファイル

- `.zshrc`: Zsh設定（条件付きツール読み込み）
- `nvim/lua/plugins/claudecode.lua`: Claude Code設定
- `.claude/`: 詳細ドキュメント

## 開発フロー

1. 新しいツール追加時はHomebrewでインストール
2. 設定ファイルを適切なディレクトリに配置
3. README.mdにセットアップ手順を追加
4. 必要に応じて`.claude/`配下にドキュメント作成

## テストコマンド

```bash
# Zsh設定確認
source ~/.zshrc

# Neovim起動確認
nvim

# 各ツール動作確認
mise --version
sheldon --version
fzf --version
zoxide --version
atuin --version
```

## 注意点

- 各ツールは条件付きで読み込み（インストール済みの場合のみ）
- シンボリックリンクでファイルを配置
- ローカル固有設定は`~/.zshrc.local`で管理

