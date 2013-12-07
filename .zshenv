# .zshenv is only needed since macvim does not source .zshrc
# https://rvm.io/integration/vim/
#
# Something sources .zshenv file twice; I don't know what
if [ -z "$SHELL_ENV_LOADED" ]; then
  source ~/.common_env
  export SHELL_ENV_LOADED=true
fi
