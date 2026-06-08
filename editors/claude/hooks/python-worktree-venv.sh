#!/usr/bin/env bash
# Symlink .venv from main repo when Claude starts inside a Python git worktree.
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

# .venv already present (real or symlink)
[[ -e .venv ]] && exit 0

MAIN_ROOT=$(cd "$GIT_COMMON_ABS/.." && pwd -P)

if [[ ! -d "$MAIN_ROOT/.venv" ]]; then
  echo "Python worktree detected but $MAIN_ROOT/.venv missing. Run 'uv sync' in the main repo first."
  exit 0
fi

ln -s "$MAIN_ROOT/.venv" .venv
echo "Python worktree: symlinked .venv from $MAIN_ROOT"
