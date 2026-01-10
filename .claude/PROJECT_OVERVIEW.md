# Dotfiles プロジェクト概要

このプロジェクトは個人的な開発環境設定を管理するためのdotfilesです。

## プロジェクト構造

```
dotfiles/
├── .claude/              # Claude Code設定とドキュメント
├── .git/                 # Git管理
├── .gitconfig           # Git設定
├── .gitignore          # Git無視ファイル
├── .tigrc              # tig設定（Gitクライアント）
├── .vimrc              # Vim設定（レガシー）
├── .zshrc              # Zshシェル設定
├── .zsh_aliases        # Zshエイリアス
├── ghostty/            # Ghostty端末設定
├── nvim/               # Neovim設定（LazyVim）
├── sheldon/            # Sheldon（Zshプラグインマネージャー）設定
└── README.md           # セットアップ手順
```

## 主要コンポーネント

### Shell環境 (Zsh)
- **mise**: 開発環境管理（Rustツールチェインなど）
- **sheldon**: Zshプラグイン管理
- **fzf**: ファジーファインダー
- **zoxide**: ディレクトリジャンプ（cdコマンド拡張）
- **atuin**: シェル履歴管理

### エディタ環境
- **Neovim**: LazyVimベースの設定
- **Claude Code**: AI支援コーディング

### ターミナル
- **Ghostty**: 高性能ターミナルエミュレータ

### Git関連
- **tig**: コマンドラインGitクライアント
- **lazygit**: TUIベースのGitクライアント

### その他CLIツール
- **eza**: lsコマンド拡張
- **bat**: catコマンド拡張
- **ripgrep**: 高速grep
- **fd**: findコマンド拡張

## メンテナンス方針

1. **設定の追加**: 新しいツールの設定は適切なディレクトリに配置
2. **依存関係**: Homebrewでインストール可能なツールを優先
3. **ドキュメント**: 重要な変更は`.claude/`配下にドキュメント化
4. **テスト**: 新環境でのセットアップ手順を定期的にテスト