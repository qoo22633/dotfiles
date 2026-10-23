# 環境変数・PATH・エイリアスは mise の [env] [shell_alias] で管理（~/.config/mise/config.toml）

# ── 関数 ──
# ~/.config/zsh/functions/ に 1 関数 1 ファイル。初回呼び出し時に読み込まれる
fpath=(~/.config/zsh/functions $fpath)
autoload -Uz y ghq-fzf

# ── 補完 ──
autoload -Uz compinit
compinit

# ── vi モード ──
# bindkey -v はキーマップを切り替えるため、fzf / zeno などの bindkey より前に置く
bindkey -v
KEYTIMEOUT=10  # Esc 後の待ち時間（0.1 秒）。既定の 0.4 秒だとモード切替が遅い

# ── ツール初期化（上から順に読む。後ろのものが前のものに依存する） ──
# mise: 以降のツールが PATH に載るよう最初に activate する
if [ -x /opt/homebrew/bin/mise ]; then
  eval "$(/opt/homebrew/bin/mise activate zsh)"
fi

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh --cmd cd)"
fi

eval "$(sheldon source)"
source <(fzf --zsh)

# worktrunk: wt switch 時に自動でディレクトリ移動する
# 初回インストール後に `wt config shell install` を実行してセットアップ
if (( $+commands[wt] )); then
  eval "$(command wt config shell init zsh)"
fi

# ── キーバインド ──
# zeno は sheldon と fzf のロード後に設定する（^r は fzf --zsh を上書きする）
if [[ -n $ZENO_LOADED ]]; then
  export ZENO_COMPLETION_FALLBACK="fzf-tab-complete"
  bindkey '^i'  zeno-completion         # Tab: git fuzzy 補完 → fallback fzf-tab
  bindkey '^r'  zeno-history-selection  # Ctrl-R: プレビュー付き履歴検索
  bindkey '^xs' zeno-insert-snippet     # Ctrl-X s: スニペットピッカー
fi

# ghq + fzf によるリポジトリ移動 (Ctrl+G)
if (( $+commands[ghq] && $+commands[fzf] )); then
  zle -N ghq-fzf
  bindkey '^G' ghq-fzf
fi

# ── ローカル固有設定（git 管理外） ──
[ -f ~/.zshrc.local ] && . ~/.zshrc.local
