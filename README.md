# dotfiles

Plain files laid out like `$HOME`, symlinked into place. Editing `~/.zshrc`
edits this repo; commit and push as usual.

## New machine

```sh
git clone https://github.com/aldinash/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
brew bundle --file ~/.dotfiles/Brewfile   # macOS, optional
```

`install.sh` backs up anything it replaces to `~/.dotfiles-backup/`.
To add a file: move it into the repo at the same path and re-run `install.sh`.

## Per-machine settings (not in the repo)

- `~/.config/dotfiles/local.sh` — shell aliases, PATH, work env vars
- `~/.config/git/local` — git `user.name` / `user.email`, anything machine-specific

## What's here

zsh/bash (shared bits in `.config/dotfiles/shell/`), git, tmux, starship,
atuin, Ghostty, and Vim with clangd for C/C++.
