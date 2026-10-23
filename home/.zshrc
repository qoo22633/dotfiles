# 環境変数・PATH・エイリアスは mise の [env] [shell_alias] で管理（~/.config/mise/config.toml）

# ── 補完 ──
autoload -Uz compinit
compinit

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
  function ghq-fzf() {
    local repo
    repo=$(ghq list | fzf --height 40% --reverse \
      --preview "ls -la $(ghq root)/{}" \
      --preview-window=right:40%)
    if [[ -n "$repo" ]]; then
      cd "$(ghq root)/$repo"
    fi
    zle reset-prompt
  }
  zle -N ghq-fzf
  bindkey '^G' ghq-fzf
fi

# ── 関数 ──
# yazi: 終了時にyaziで開いていたディレクトリへ cd する
if (( $+commands[yazi] )); then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

# ── ローカル固有設定（git 管理外） ──
[ -f ~/.zshrc.local ] && . ~/.zshrc.local
