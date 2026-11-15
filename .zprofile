if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
[[ -f "$HOME/.config/dotfiles/shell/path.sh" ]] &&
  source "$HOME/.config/dotfiles/shell/path.sh"
