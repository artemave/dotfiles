# Command search path + environment, set here in .zshenv (sourced by *every*
# zsh) so it reaches non-interactive shells too — claude-code, `ssh host cmd`,
# hop's ssh transport — not just interactive ones. .common_env is output-free
# and tty-agnostic by contract, so sourcing it this early is safe.
#
# Guard on $COMMON_ENV_LOADED (exported by .common_env): a nested shell inherits
# the already-built PATH, so re-running these prepends would duplicate entries.
# The first shell in the tree loads them; children skip and inherit. .zshrc has
# the same guard as a fallback for setups whose login shell skips .zshenv.
if [[ -z $COMMON_ENV_LOADED ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
  [ -f ~/.common_env ] && source ~/.common_env
fi
