# shellcheck shell=sh

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -lah --icons=auto --git --group-directories-first'
  alias la='eza -la --icons=auto --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
else
  alias ll='ls -lah'
  alias la='ls -la'
fi

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status --short --branch'
alias lg='lazygit'
