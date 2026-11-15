#!/bin/sh
# Symlink every file in this repo into $HOME, so editing ~/.zshrc edits the repo.
# Files already there are moved to ~/.dotfiles-backup/<time>/ first.
# Safe to re-run.
set -eu
repo=$(cd "$(dirname "$0")" && pwd)
backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
cd "$repo"
git submodule update --init --quiet

git ls-files | grep -vxE 'install\.sh|README\.md|Brewfile|\.gitignore|\.gitmodules' |
while IFS= read -r f; do
  src="$repo/$f" dst="$HOME/$f"
  [ "$(readlink "$dst" 2>/dev/null || true)" = "$src" ] && continue
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$(dirname "$backup/$f")"
    mv "$dst" "$backup/$f"
    echo "backed up ~/$f"
  fi
  ln -s "$src" "$dst"
  echo "linked    ~/$f"
done
