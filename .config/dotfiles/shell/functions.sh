# shellcheck shell=sh

has() {
  command -v "$1" >/dev/null 2>&1
}

mkcd() {
  mkdir -p "$1" && cd "$1" || return
}

cdd() {
  if ! has fzf; then
    printf '%s\n' "fzf is not installed" >&2
    return 127
  fi

  if has fd; then
    directory="$(fd -t d . | fzf --query "$*")" || return
  elif has fdfind; then
    directory="$(fdfind -t d . | fzf --query "$*")" || return
  else
    printf '%s\n' "fd is not installed" >&2
    return 127
  fi
  [ -n "$directory" ] && cd "$directory" || return
}

y() {
  if ! has yazi; then
    printf '%s\n' "yazi is not installed" >&2
    return 127
  fi

  temporary_file="$(mktemp -t yazi-cwd.XXXXXX)" || return
  yazi "$@" --cwd-file="$temporary_file"
  destination="$(command cat -- "$temporary_file")"
  rm -f -- "$temporary_file"
  [ -n "$destination" ] && [ "$destination" != "$PWD" ] && cd "$destination"
}

tunnel() {
  if ! has autossh; then
    printf '%s\n' "autossh is not installed" >&2
    return 127
  fi
  autossh -M 0 -N \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    "$@"
}
