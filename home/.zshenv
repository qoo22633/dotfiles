# 非対話シェル（Claude Code の Bash ツール、スクリプト等）でも読まれる設定
# 対話シェルでは .zshrc の `mise activate` が PATH を上書き管理する

# mise shims（非対話シェルでも mise 管理のツールを使えるようにする）
if [ -d "$HOME/.local/share/mise/shims" ]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi
