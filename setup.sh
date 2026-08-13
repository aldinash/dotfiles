#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PACKAGES=false
INSTALL_USER_TOOLS=false
APPLY=false

usage() {
  cat <<'EOF'
Usage: ./setup.sh [--install-packages] [--install-user-tools] [--apply]

  --install-packages  Install the workstation or Linux CLI package set.
  --install-user-tools
                      Install portable tools under the current user's home.
  --apply             Apply after showing the Chezmoi diff.

Without --apply, setup installs prerequisites, initializes Chezmoi, and only
shows the proposed changes.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-packages) INSTALL_PACKAGES=true ;;
    --install-user-tools) INSTALL_USER_TOOLS=true ;;
    --apply) APPLY=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

log() {
  printf '==> %s\n' "$1"
}

as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    printf 'sudo is required for: %s\n' "$*" >&2
    return 1
  fi
}

ensure_homebrew() {
  command -v brew >/dev/null 2>&1 && return
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_linux_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    as_root apt-get update
    available=()
    while IFS= read -r package; do
      [[ -z "$package" || "$package" == \#* ]] && continue
      apt-cache show "$package" >/dev/null 2>&1 && available+=("$package")
    done < "$REPO_ROOT/packages/ubuntu.txt"
    ((${#available[@]})) && as_root apt-get install -y "${available[@]}"
  elif command -v dnf >/dev/null 2>&1; then
    as_root dnf install -y zsh git tmux neovim ripgrep fzf fd-find bat direnv jq shellcheck
  elif command -v pacman >/dev/null 2>&1; then
    as_root pacman -S --needed zsh git tmux neovim ripgrep fzf fd bat direnv jq shellcheck
  else
    printf 'Unsupported package manager. Install packages from packages/ubuntu.txt manually.\n' >&2
    return 1
  fi
}

ensure_chezmoi() {
  command -v chezmoi >/dev/null 2>&1 && return
  log "Installing Chezmoi in ~/.local/bin"
  mkdir -p "$HOME/.local/bin"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
}

run_installer() {
  installer="$(mktemp)"
  curl --proto '=https' --tlsv1.2 -fsSL "$1" -o "$installer"
  shift
  sh "$installer" "$@"
  rm -f "$installer"
}

install_user_tools() {
  mkdir -p "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$HOME/.atuin/bin:$PATH"

  if ! command -v uv >/dev/null 2>&1; then
    log "Installing uv"
    UV_INSTALL_DIR="$HOME/.local/bin" run_installer https://astral.sh/uv/install.sh
  fi
  if ! command -v atuin >/dev/null 2>&1; then
    log "Installing Atuin"
    run_installer https://setup.atuin.sh
  fi
  if ! command -v starship >/dev/null 2>&1; then
    log "Installing Starship"
    run_installer https://starship.rs/install.sh --yes --bin-dir "$HOME/.local/bin"
  fi
  if ! command -v mise >/dev/null 2>&1; then
    log "Installing mise"
    MISE_INSTALL_PATH="$HOME/.local/bin/mise" run_installer https://mise.run
  fi
  if ! command -v zoxide >/dev/null 2>&1; then
    log "Installing zoxide"
    run_installer https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh
  fi
}

configure_local_files() {
  mkdir -p "$HOME/.config/git" "$HOME/.config/dotfiles"

  if [[ ! -f "$HOME/.config/git/local" ]]; then
    name="${DOTFILES_GIT_NAME:-$(git config --global user.name 2>/dev/null || true)}"
    email="${DOTFILES_GIT_EMAIL:-$(git config --global user.email 2>/dev/null || true)}"
    if [[ -n "$name" && -n "$email" ]]; then
      printf '[user]\n\tname = %s\n\temail = %s\n' "$name" "$email" > "$HOME/.config/git/local"
      chmod 600 "$HOME/.config/git/local"
    else
      printf 'Git identity is not configured. Set it in ~/.config/git/local after apply.\n'
    fi
  fi

  if [[ ! -e "$HOME/.config/dotfiles/local.sh" ]]; then
    : > "$HOME/.config/dotfiles/local.sh"
    chmod 600 "$HOME/.config/dotfiles/local.sh"
  fi
}

case "$(uname -s)" in
  Darwin)
    if $INSTALL_PACKAGES; then
      ensure_homebrew
      log "Installing macOS packages and applications"
      brew bundle --file "$REPO_ROOT/Brewfile"
    fi
    ;;
  Linux)
    if $INSTALL_PACKAGES; then
      log "Installing Linux packages"
      install_linux_packages
    fi
    ;;
  *)
    printf 'Unsupported operating system: %s\n' "$(uname -s)" >&2
    exit 1
    ;;
esac

$INSTALL_USER_TOOLS && install_user_tools
ensure_chezmoi
configure_local_files

log "Initializing Chezmoi from $REPO_ROOT"
chezmoi init --source "$REPO_ROOT"

log "Reviewing proposed changes"
chezmoi --source "$REPO_ROOT" diff

if $APPLY; then
  log "Applying dotfiles"
  chezmoi --source "$REPO_ROOT" apply
  log "Setup complete. Start a new shell."
else
  printf '\nNothing was applied. Re-run with --apply after reviewing the diff.\n'
fi
