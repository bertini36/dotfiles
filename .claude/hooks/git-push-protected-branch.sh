#!/usr/bin/env bash
# Prompt before a git push whose target branch is main or master.
# Emits no output for any other push, letting normal permission rules decide.
set -uo pipefail

[[ -t 0 ]] && exit 0
command=$(jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0

# Positional arguments after `git push` are the remote and its refspecs.
read -ra parts <<<"$command"
args=()
for part in "${parts[@]:2}"; do
  [[ "$part" == -* ]] || args+=("$part")
done

# With no refspec git pushes the current branch; otherwise the last refspec
# wins, and its destination is whatever follows the colon.
if [[ ${#args[@]} -le 1 ]]; then
  target=HEAD
else
  target="${args[-1]}"
  [[ "$target" == *:* ]] && target="${target##*:}"
fi

target="${target#refs/heads/}"
if [[ -z "$target" || "$target" == HEAD ]]; then
  target=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "")
fi

if [[ "$target" =~ ^(main|master)$ ]]; then
  jq -n --arg t "$target" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: ("Push targets protected branch: " + $t)
    }
  }'
fi
