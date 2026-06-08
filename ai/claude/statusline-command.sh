#!/bin/sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ANSI color codes
PURPLE='\033[35m'
BLUE='\033[38;5;75m'
LIME='\033[38;5;154m'
ORANGE='\033[38;5;208m'
MUTED='\033[2;37m'
RESET='\033[0m'

# Shorten home directory to ~
home="$HOME"
short_cwd="${cwd/#$home/~}"

# Get git branch, skip optional locks to avoid conflicts
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

if [ -n "$branch" ]; then
    dir_part="${BLUE}${short_cwd}${RESET} [${LIME}${branch}${RESET}]"
else
    dir_part="${BLUE}${short_cwd}${RESET}"
fi

model_part="${ORANGE}${model}${RESET}"

if [ -n "$used" ]; then
    context_part="${MUTED}context: ${used}%${RESET}"
else
    context_part="${MUTED}no msgs${RESET}"
fi

printf '%b' "${PURPLE}🤖${RESET} | ${dir_part} | ${model_part} | ${context_part}"