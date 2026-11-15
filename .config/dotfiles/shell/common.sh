# shellcheck shell=sh

DOTFILES_CONFIG_HOME="${DOTFILES_CONFIG_HOME:-$HOME/.config/dotfiles}"
export DOTFILES_CONFIG_HOME

# shellcheck source=/dev/null
[ -f "$DOTFILES_CONFIG_HOME/shell/path.sh" ] && . "$DOTFILES_CONFIG_HOME/shell/path.sh"
# shellcheck source=/dev/null
[ -f "$DOTFILES_CONFIG_HOME/shell/aliases.sh" ] && . "$DOTFILES_CONFIG_HOME/shell/aliases.sh"
# shellcheck source=/dev/null
[ -f "$DOTFILES_CONFIG_HOME/shell/functions.sh" ] && . "$DOTFILES_CONFIG_HOME/shell/functions.sh"

export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export GIT_EDITOR="${GIT_EDITOR:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"

# git diffs through delta, on machines that have it (settings in ~/.gitconfig)
if command -v delta >/dev/null 2>&1; then
  export GIT_PAGER=delta
fi

# Machine-only aliases, credentials, and work environment variables live here.
# shellcheck source=/dev/null
[ -f "$DOTFILES_CONFIG_HOME/local.sh" ] && . "$DOTFILES_CONFIG_HOME/local.sh"
