#!/usr/bin/env bash
# Prompt before a git push that could land on main or master.
# Emits no output for any other push, letting normal permission rules decide.
set -uo pipefail

command=$(jq -r '.tool_input.command // ""')
branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "")

if [[ "$branch" =~ ^(main|master)$ ]] ||
   [[ "$command" =~ (^|[[:space:]:])(main|master)([[:space:]]|$) ]]; then
  jq -n --arg b "${branch:-detached HEAD}" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: ("Push may target a protected branch. Current branch: " + $b)
    }
  }'
fi
