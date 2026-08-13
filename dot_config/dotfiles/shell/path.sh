# shellcheck shell=sh

path_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

path_append() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$PATH:$1" ;;
  esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.atuin/bin"

if [ -n "${PNPM_HOME:-}" ]; then
  path_prepend "$PNPM_HOME"
elif [ -d "$HOME/Library/pnpm" ]; then
  PNPM_HOME="$HOME/Library/pnpm"
  export PNPM_HOME
  path_prepend "$PNPM_HOME"
fi

if [ -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]; then
  path_append "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
fi

export PATH
