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

## Private agent skills (optional)

Codex and Claude Code share skills from the separate private
`aldinash/agent-skills` repository. Authenticate to GitHub with an account that
has access, then run:

```sh
~/.dotfiles/install.sh --skills
# Or install only skills:
~/.dotfiles/install-skills.sh
```

This clones into `~/.agent-skills` and links individual skill folders into
`~/.agents/skills` and `~/.claude/skills`. Existing conflicting folders are
preserved by stopping; run `install-skills.sh --backup-conflicts` to back them up
and replace them with links. Plain `install.sh` does not require private repo
access. Set `AGENT_SKILLS_DIR` to use a different checkout location.

Update skills with `git -C ~/.agent-skills pull --ff-only`, then re-run
`~/.dotfiles/install-skills.sh`. Existing checkouts are never pulled automatically.

## Per-machine settings (not in the repo)

- `~/.config/dotfiles/local.sh` — shell aliases, PATH, work env vars
- `~/.config/git/local` — git `user.name` / `user.email`, anything machine-specific

## What's here

zsh/bash (shared bits in `.config/dotfiles/shell/`), git, tmux, starship,
atuin, Ghostty, and Vim with clangd for C/C++.
