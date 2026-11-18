#!/bin/sh
# Optional private skills setup; requires GitHub access to aldinash/agent-skills.
set -eu
skills_repo=${AGENT_SKILLS_DIR:-"$HOME/.agent-skills"}
if [ ! -d "$skills_repo" ]; then
  if command -v gh >/dev/null 2>&1; then
    gh repo clone aldinash/agent-skills "$skills_repo"
  else
    git clone git@github.com:aldinash/agent-skills.git "$skills_repo"
  fi
fi
if [ ! -f "$skills_repo/install.sh" ] || [ ! -d "$skills_repo/skills" ]; then
  echo "Not a skills checkout: $skills_repo" >&2
  exit 1
fi
# Existing checkouts are not pulled automatically; preserve local edits.
exec bash "$skills_repo/install.sh" "$@"
