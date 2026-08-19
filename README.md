# Dotfiles

Cross-platform terminal and development configuration managed by Chezmoi.
The repository is the source of truth; Chezmoi renders it into the home
directory according to the current operating system.

## What is managed

- Bash and Zsh with shared aliases, functions, paths, and guarded tool setup
- Starship prompt and Atuin history
- Git defaults with a machine-local identity file
- tmux configuration shared by macOS and Linux
- Ghostty configuration on macOS only
- AstroNvim v6 configuration shared by macOS and Linux
- Homebrew packages and applications for a Mac workstation

There is deliberately no VS Code configuration. VS Code may be installed by
the Brewfile, but its settings, extensions, login, and sync state remain
outside this repository.

## macOS workstation

Clone the repository and preview the rendered changes:

```sh
git clone https://github.com/<github-user>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh --install-packages
```

Nothing is applied without an explicit flag. Review again and apply with:

```sh
chezmoi --source ~/.dotfiles diff
./setup.sh --apply
```

The package pass installs Homebrew when necessary, applies `Brewfile`, and
installs Chezmoi.

AstroNvim v6 requires Neovim 0.11 or newer. The first `nvim` launch installs the
full distribution and plugins through `lazy.nvim`. The repository tracks the
user configuration and `lazy-lock.json`; downloaded plugins, Mason tools,
caches, and editor state stay machine-local.

macOS preferences are separate and opt-in:

```sh
~/.dotfiles/scripts/macos-defaults
```

Review that script before running it. It changes keyboard repeat, text
substitutions, and Finder visibility settings.

## Linux over SSH

Ghostty keeps running on the local Mac, so its font, rendering, and macOS
keybindings automatically remain available. Ghostty's `ssh-terminfo` and
`ssh-env` integration installs `xterm-ghostty` terminfo remotely when possible
and falls back to `xterm-256color` when necessary.

On the Linux host:

```sh
git clone https://github.com/<github-user>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
./setup.sh --apply
exec zsh
dotfiles-doctor
```

The first command installs only Chezmoi into `~/.local/bin` when needed and
shows the diff. On a managed server without sudo, portable tools such as
Starship, Atuin, mise, zoxide, and uv can be installed under your home:

```sh
./setup.sh --install-user-tools --apply
```

On a personal VM where system package installation is permitted:

```sh
./setup.sh --install-packages --install-user-tools --apply
```

Do not request system packages on a managed server without approval. The shell
configuration checks for optional commands before initializing them, so it
still starts when the server has only a subset of the preferred tools. Bash is
configured as a fallback when Zsh is unavailable or cannot be made the login
shell.

## How platforms differ

Chezmoi exposes the current operating system as `.chezmoi.os`. Templates use
that value for macOS-only Homebrew initialization, and `.chezmoiignore.tmpl`
omits Ghostty files on Linux. The bootstrap dispatches package installation to
Homebrew on macOS and the detected native package manager on Linux. Shell, Git,
tmux, Starship, and Atuin configuration remains shared.

Inspect the rendered configuration at any time:

```sh
chezmoi --source ~/.dotfiles diff
chezmoi --source ~/.dotfiles data
```

## Private and machine-specific state

These files are intentionally created outside the repository:

- `~/.config/git/local`: Git name, email, and optional signing configuration
- `~/.config/dotfiles/local.sh`: work aliases, environment variables, and
  machine-specific paths

The setup script carries forward an existing global Git identity when one is
available. On a new machine, identity can be supplied non-interactively:

```sh
DOTFILES_GIT_NAME="Your Name" \
DOTFILES_GIT_EMAIL="you@example.com" \
./setup.sh --apply
```

SSH keys, tokens, cloud credentials, shell history databases, editor login
state, and Atuin encryption keys must be restored through the relevant service
or a password manager. Atuin history can then be restored with `atuin login`
and `atuin sync`.

## Maintenance

Run repository checks before committing:

```sh
./scripts/doctor
```

Normal update loop:

```sh
chezmoi --source ~/.dotfiles diff
chezmoi --source ~/.dotfiles apply
```

Edit `Brewfile` for Mac packages and `packages/ubuntu.txt` for Ubuntu packages.
Keep credentials and host-specific data in the two local files above.

After updating AstroNvim plugins, capture the resulting lockfile with:

```sh
chezmoi --source ~/.dotfiles re-add ~/.config/nvim/lazy-lock.json
```
