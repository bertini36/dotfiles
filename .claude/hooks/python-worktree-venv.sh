#!/usr/bin/env bash
# Link shared, gitignored dev files (.venv, .env) from the main repo into a
# Python git worktree so tests and management commands run without re-setup.
set -euo pipefail

# SessionStart passes a JSON payload on stdin whose `cwd` is the session's real
# working directory. With `--worktree` the hook process inherits the launch
# directory (the main checkout), not the worktree, so trust the payload instead.
if [[ ! -t 0 ]]; then
  PAYLOAD=$(cat)
  CWD=$(printf '%s' "$PAYLOAD" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null || true)
  [[ -n "$CWD" && -d "$CWD" ]] && cd "$CWD"
fi

# Must be inside a git repo
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null) || exit 0
GIT_COMMON=$(git rev-parse --git-common-dir 2>/dev/null) || exit 0

GIT_DIR_ABS=$(cd "$GIT_DIR" && pwd -P)
GIT_COMMON_ABS=$(cd "$GIT_COMMON" && pwd -P)

# Not a worktree — nothing to do
[[ "$GIT_DIR_ABS" == "$GIT_COMMON_ABS" ]] && exit 0

# Not a Python project
[[ -f pyproject.toml ]] || [[ -f requirements.txt ]] || exit 0

MAIN_ROOT=$(cd "$GIT_COMMON_ABS/.." && pwd -P)

# Symlink an item from the main repo if the worktree lacks it.
link_shared() {
  local name=$1
  [[ -e "$name" || -L "$name" ]] && return 0       # worktree already has it
  [[ -e "$MAIN_ROOT/$name" ]] || return 0           # main repo lacks it
  ln -s "$MAIN_ROOT/$name" "$name"
  echo "Worktree: linked $name from $MAIN_ROOT"
}

if [[ ! -e .venv && ! -L .venv && ! -d "$MAIN_ROOT/.venv" ]]; then
  echo "Python worktree detected but $MAIN_ROOT/.venv missing. Run 'uv sync' in the main repo first."
fi

link_shared .venv
link_shared .env
link_shared .env.local
