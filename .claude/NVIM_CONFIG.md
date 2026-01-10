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

### GitHub Copilot (`copilot.vim`)
GitHubのAIペアプログラミングツール

#### キーマップ（挿入モード）
- `<leader>coa`: 提案を受け入れ（Accept）
- `<leader>cow`: 単語のみ受け入れ（Word）
- `<leader>cod`: 提案を却下（Dismiss）
- `<leader>con`: 次の提案（Next）
- `<leader>cop`: 前の提案（Previous）

#### キーマップ（ノーマルモード）
- `<leader>coe`: Copilotを有効化（Enable）
- `<leader>coD`: Copilotを無効化（Disable）
- `<leader>cos`: ステータス表示（Status）
- `<leader>cop`: パネルを開く（Panel）

#### 設定内容
- 遅延読み込み: `VeryLazy`イベント
- which-key連携: `<leader>co`プレフィックス
- Tabキーマップ無効化: nvim-cmpとの競合回避

#### 初回セットアップ
```vim
:Copilot setup
```

### CopilotChat (`CopilotChat.nvim`)
Copilotとの対話型AIチャット

#### 主要キーマップ
- `<leader>ce`: コードの説明（Explain）
- `<leader>cr`: コードレビュー（Review）
- `<leader>cf`: コード修正（Fix）
- `<leader>cO`: コード最適化（Optimize）※大文字O
- `<leader>cd`: ドキュメント生成（Docs）
- `<leader>ct`: テスト生成（Tests）
- `<leader>cx`: 診断結果修正（FixDiagnostic）
- `<leader>cco`: コミットメッセージ作成（Commit）
- `<leader>cs`: ステージ済みコミット（CommitStaged）

#### 便利機能
- `<leader>cc`: チャットトグル（注: Claude Codeと重複するため用途で使い分け）
- `<leader>cC`: 質問入力してチャット開始
- `<leader>cq`: クイックチャット（ビジュアルモード）
- `<leader>cb`: バッファ全体について質問（注: Claude Codeと重複）

#### 設定内容
- 全てのプロンプトを日本語化
- `config`関数内でセットアップ（モジュールロードタイミング対策）
- which-key連携
- 依存関係: `copilot.vim`, `plenary.nvim`

#### 重要な実装ノート
`opts`テーブル内で`require('CopilotChat.select')`を呼び出すとプラグインロード前のため失敗します。必ず`config`関数内で`require`を実行してください。

```lua
config = function()
  local chat = require("CopilotChat")
  local select = require("CopilotChat.select")
  chat.setup({ ... })
end
```

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
│       ├── copilot.lua        # GitHub Copilotプラグイン
│       ├── copilot-chat.lua   # CopilotChatプラグイン
│       └── example.lua        # サンプル設定
└── README.md                   # 基本説明
```

## セットアップ
```bash
ln -sf ~/dotfiles/nvim ~/.config
```

初回起動時にLazy.nvimが自動的にプラグインをインストールします。

### GitHub Copilot認証
```vim
:Copilot setup
```
ブラウザでGitHubアカウントと連携してください。

## ベストプラクティス

### プラグイン設定のパターン

#### 基本形式
```lua
return {
  "author/plugin-name",
  event = "VeryLazy",  -- 遅延読み込み
  dependencies = { "other/plugin" },
  opts = { ... },  -- 単純な設定の場合
}
```

#### config関数を使う場合
プラグインのモジュールを`require`する必要がある場合は、`opts`ではなく`config`関数を使用:

```lua
return {
  "author/plugin-name",
  event = "VeryLazy",
  config = function()
    local plugin = require("plugin-name")
    local helper = require("plugin-name.helper")

    plugin.setup({
      -- 設定
      option = helper.something,
    })
  end,
}
```

**理由**: `opts`テーブルはプラグインロード前に評価されるため、`require`が失敗します。

### which-key連携
キーマップには必ず`desc`を設定し、which-keyと連携:

```lua
keys = {
  {
    "<leader>co",
    mode = { "n", "i" },
    desc = "Copilot prefix",
  },
  {
    "<leader>coa",
    function() vim.fn["copilot#Accept"]() end,
    mode = "i",
    desc = "Accept suggestion",
  },
}
```

### キーマップの競合回避
- プレフィックスを体系的に使用（`<leader>co*`, `<leader>c*`など）
- 大文字を活用（`<leader>cO`で最適化、`<leader>coD`で無効化）
- which-keyで確認可能にする

#### 現在の重複キーマップ
以下のキーマップは複数のプラグインで使用されています：

- `<leader>cc`: Claude Codeトグル / CopilotChatトグル
- `<leader>cb`: Claude Codeバッファ追加 / CopilotChatバッファ質問

**推奨**: 用途に応じて使い分けるか、将来的に一方を変更することを検討

### トラブルシューティング
```vim
" プラグイン状態確認
:Lazy

" プラグイン同期（インストール/更新）
:Lazy sync

" キャッシュクリア
:Lazy clean

" ログ確認
:Lazy log <plugin-name>

" メッセージ履歴
:messages
```