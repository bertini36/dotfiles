#!/bin/sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
repo=$(echo "$input" | jq -r '.workspace.repo.name // empty')
worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
context=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
quota=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
cost_cents=$(echo "$input" | jq -r '.cost.total_cost_usd // empty | . * 100 | round')

BLUE='\033[38;5;75m'
LIME='\033[38;5;154m'
ORANGE='\033[38;5;208m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
MUTED='\033[2;37m'
RESET='\033[0m'

[ -z "$repo" ] && repo=$(basename "$cwd")

# Green under 50%, yellow under 80%, red above
pct_color() {
    p=${1%.*}
    if [ "$p" -lt 50 ]; then printf '%s' "$GREEN"
    elif [ "$p" -lt 80 ]; then printf '%s' "$YELLOW"
    else printf '%s' "$RED"; fi
}

branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

repo_part="${BLUE}${repo}${RESET}"

git_part=""
if [ -n "$worktree" ]; then
    git_part=" ${LIME}[${worktree}]${RESET}"
elif [ -n "$branch" ]; then
    git_part=" ${LIME}[${branch}]${RESET}"
fi

model_part="${ORANGE}${model}${RESET}"

if [ -n "$context" ]; then
    context_part="🧠 $(pct_color "$context")${context%.*}%${RESET}"
else
    context_part="🧠 ${MUTED}--${RESET}"
fi

if [ -n "$quota" ]; then
    quota_part="⌛ $(pct_color "$quota")${quota%.*}%${RESET}"
else
    quota_part="⌛ ${MUTED}--${RESET}"
fi

if [ -n "$cost_cents" ]; then
    cost_part="${MUTED}(\$$((cost_cents / 100)).$(printf '%02d' $((cost_cents % 100))))${RESET}"
else
    cost_part="${MUTED}(--)${RESET}"
fi

printf '%b' "${repo_part}${git_part} | ${model_part} | ${context_part} | ${quota_part} ${cost_part}"
