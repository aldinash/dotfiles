# shellcheck shell=sh

if [ -f "$HOME/.config/dotfiles/shell/path.sh" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.config/dotfiles/shell/path.sh"
fi

case $- in
  *i*)
    if [ -n "${BASH_VERSION:-}" ] && [ -f "$HOME/.bashrc" ]; then
      # shellcheck source=/dev/null
      . "$HOME/.bashrc"
    fi
    ;;
esac
