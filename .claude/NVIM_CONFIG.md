# Neovim設定詳細

## 概要
LazyVimをベースとしたNeovim設定です。

## カスタムプラグイン

### Claude Code (`claudecode.nvim`)
AI支援コーディング用プラグイン

#### キーマップ
- `<leader>cc`: Claudeをトグル
- `<leader>cf`: Claudeにフォーカス  
- `<leader>cr`: Claudeセッションを再開
- `<leader>cm`: モデルを選択
- `<leader>cb`: 現在のバッファを追加
- `<leader>cs`: 選択したテキストをClaudeに送信（ビジュアルモード）

#### 依存関係
- `folke/snacks.nvim`

## 言語サポート

### Rust
- LazyVimのRustエクストラを有効化
- `{ import = "lazyvim.plugins.extras.lang.rust" }`

## 設定ファイル構造

```
nvim/
├── init.lua                    # エントリーポイント
├── lua/
│   ├── config/
│   │   ├── autocmds.lua       # 自動コマンド
│   │   ├── keymaps.lua        # キーマップ
│   │   ├── lazy.lua           # Lazy.nvim設定
│   │   └── options.lua        # エディタオプション
│   └── plugins/
│       ├── claudecode.lua     # Claude Codeプラグイン
│       └── example.lua        # サンプル設定
└── README.md                   # 基本説明
```

## セットアップ
```bash
ln -sf ~/dotfiles/nvim ~/.config
```

初回起動時にLazy.nvimが自動的にプラグインをインストールします。