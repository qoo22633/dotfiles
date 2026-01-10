# Zsh設定詳細

## 概要
効率的な開発環境のためのZsh設定です。

## 主要機能

### プラグイン管理
- **sheldon**: Zshプラグインマネージャー
- 設定ファイル: `sheldon/plugins.toml`

### ディレクトリナビゲーション
- **zoxide**: `cd`コマンドの拡張版
- 使用頻度に基づいて賢くディレクトリジャンプ

### 検索・フィルタリング
- **fzf**: ファジーファインダー
- Ctrl+R: コマンド履歴検索
- その他のfzf連携機能

### 開発環境管理
- **mise**: プログラミング言語のバージョン管理
- Rust、Node.js等のツールチェイン管理

### シェル履歴
- **atuin**: 高機能な履歴管理
- 複数マシン間での履歴同期（要設定）

## エイリアス (`.zsh_aliases`)
カスタムエイリアスは別ファイルで管理されています。

## 条件付き実行
各ツールはHomebrewでインストールされている場合のみ有効化：

```bash
# 例: mise
if [ -x /opt/homebrew/bin/mise ]; then
  eval "$(/opt/homebrew/bin/mise activate zsh)"
fi
```

## ローカル設定
`~/.zshrc.local`が存在する場合、マシン固有の設定を読み込みます。

## PATH設定
- Homebrew: `/opt/homebrew/bin`
- その他の開発ツール用PATH設定