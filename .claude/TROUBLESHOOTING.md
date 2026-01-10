# トラブルシューティング

## 一般的な問題

### セットアップ後にコマンドが見つからない
1. Homebrewでツールがインストールされているか確認
2. シェルを再起動（`exec zsh`）
3. PATHが正しく設定されているか確認

### プラグインが読み込まれない

#### Zsh（sheldon）
```bash
# プラグインを再インストール
sheldon source
```

#### Neovim（LazyVim）
```bash
# Neovim内で
:Lazy sync
```

### Claude Codeが動作しない
1. Claude Codeがインストールされているか確認
2. 依存関係（snacks.nvim）の確認
3. Neovimを再起動

### mise環境が反映されない
```bash
# mise設定確認
mise doctor
mise install  # 必要なツールをインストール
```

### シンボリックリンクの問題
```bash
# 既存ファイルをバックアップ
mv ~/.zshrc ~/.zshrc.backup

# リンクを再作成
ln -sf ~/dotfiles/.zshrc ~/.zshrc
```

## 新しい環境でのセットアップ手順

1. Homebrewをインストール
2. 必要なツールをすべてインストール
3. dotfilesをクローン
4. シンボリックリンクを作成
5. シェルを再起動
6. Neovimを起動してプラグインインストール

## ログ確認

### Zsh
```bash
# zsh起動時のエラー確認
zsh -xvs
```

### Neovim
```bash
# Neovim内で
:messages  # エラーメッセージ確認
:checkhealth  # 健全性チェック
```