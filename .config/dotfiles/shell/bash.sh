# shellcheck shell=bash

[[ $- == *i* ]] || return 0

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash)"
fi
if [[ "${TERM:-}" != "dumb" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
