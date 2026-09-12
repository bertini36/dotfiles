#!/usr/bin/env bash
# Deny any git command that pushes to main or master, or rewrites their history.
# Silent for everything else, so the permission mode decides. Written for the
# bash 3.2 that ships with macOS: no negative array indices, no mapfile.
set -o pipefail

[[ -t 0 ]] && exit 0
input=$(cat)
command=$(jq -r '.tool_input.command // ""' <<<"$input" 2>/dev/null) || exit 0
[[ "$command" == *git* ]] || exit 0
cwd=$(jq -r '.cwd // ""' <<<"$input" 2>/dev/null)
[[ -d "$cwd" ]] || cwd=$PWD

deny() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

is_protected() {
  local ref=${1#+}
  ref=${ref#refs/heads/}
  [[ "$ref" == main || "$ref" == master ]]
}

branch_in() { git -C "$1" symbolic-ref --quiet --short HEAD 2>/dev/null; }

has_flag() {
  local flag=$1 arg
  shift
  for arg in "$@"; do [[ "$arg" == "$flag" ]] && return 0; done
  return 1
}

resolve_dir() {
  local base=$1 target=${2/#\~/$HOME}
  [[ "$target" == /* ]] || target="$base/$target"
  echo "$target"
}

check_push() {
  local dir=$1 positional=() arg dest i
  shift
  for arg in "$@"; do
    case "$arg" in
      --all | --mirror) deny "git push $arg would update main or master" ;;
      -*) ;;
      *) positional+=("$arg") ;;
    esac
  done
  # With no refspec git pushes the current branch.
  if [[ ${#positional[@]} -le 1 ]]; then
    is_protected "$(branch_in "$dir")" && deny "Push from protected branch $(branch_in "$dir")"
    return
  fi
  for ((i = 1; i < ${#positional[@]}; i++)); do
    dest=${positional[$i]##*:}
    [[ "$dest" == HEAD ]] && dest=$(branch_in "$dir")
    is_protected "$dest" && deny "Push targets protected branch ${dest#refs/heads/}"
  done
}

check_git() {
  local dir=$1 sub=$2 branch arg on_protected=false positional=() skip_next=false prev="" target
  shift 2
  branch=$(branch_in "$dir")
  is_protected "$branch" && on_protected=true

  case "$sub" in
    push) check_push "$dir" "$@" ;;
    filter-repo) deny "git filter-repo rewrites every branch, main and master included" ;;
    filter-branch)
      $on_protected && deny "git filter-branch on $branch"
      for arg in "$@"; do
        [[ "$arg" == --all ]] && deny "git filter-branch --all rewrites main or master"
        is_protected "$arg" && deny "git filter-branch targets $arg"
      done
      ;;
    commit)
      $on_protected && has_flag --amend "$@" && deny "Amending a commit on $branch"
      ;;
    rebase)
      $on_protected && ! has_flag --abort "$@" && deny "Rebasing $branch"
      for arg in "$@"; do
        if $skip_next; then skip_next=false; continue; fi
        case "$arg" in
          --onto | -s | --strategy | -X | --strategy-option | -x | --exec) skip_next=true ;;
          -*) ;;
          *) positional+=("$arg") ;;
        esac
      done
      # `git rebase <upstream> <branch>` checks out and rewrites <branch>.
      if [[ ${#positional[@]} -ge 2 ]]; then
        target=${positional[${#positional[@]} - 1]}
        is_protected "$target" && deny "Rebasing $target"
      fi
      ;;
    reset)
      $on_protected || return
      target=HEAD
      for arg in "$@"; do
        [[ "$arg" == -- ]] && break
        [[ "$arg" == -* ]] && continue
        if git -C "$dir" rev-parse --verify --quiet "$arg^{commit}" >/dev/null; then
          target=$arg
          break
        fi
      done
      # Resetting to the commit HEAD already points at leaves history alone.
      if [[ "$(git -C "$dir" rev-parse "$target" 2>/dev/null)" != "$(git -C "$dir" rev-parse HEAD 2>/dev/null)" ]]; then
        deny "Resetting $branch to $target moves its history"
      fi
      ;;
    pull)
      $on_protected || return
      for arg in "$@"; do
        case "$arg" in
          --rebase=false | --no-rebase) ;;
          --rebase | --rebase=* | -r) deny "git pull --rebase on $branch" ;;
        esac
      done
      ;;
    branch)
      for arg in "$@"; do
        case "$arg" in
          -f | --force | -d | -D | --delete | -m | -M | --move | -c | -C | --copy)
            for arg in "$@"; do is_protected "$arg" && deny "git branch would force, move, or delete $arg"; done
            return
            ;;
        esac
      done
      ;;
    checkout | switch)
      for arg in "$@"; do
        if [[ "$prev" == -B || "$prev" == -C || "$prev" == --force-create ]] && is_protected "$arg"; then
          deny "git $sub $prev would reset $arg"
        fi
        prev=$arg
      done
      ;;
    update-ref)
      for arg in "$@"; do is_protected "$arg" && deny "git update-ref on $arg"; done
      ;;
  esac
}

# Check every simple command in a compound one, following `cd` along the way.
dir=$cwd
while IFS= read -r segment; do
  read -ra words <<<"$segment"
  count=${#words[@]}
  i=0
  while [[ $i -lt $count ]]; do
    w=${words[$i]}
    if [[ "$w" == *=* && "$w" != -* ]] || [[ "$w" == rtk || "$w" == command || "$w" == env ]]; then
      i=$((i + 1))
    else
      break
    fi
  done
  [[ $i -lt $count ]] || continue

  if [[ "${words[$i]}" == cd ]]; then
    target=$(resolve_dir "$dir" "${words[$((i + 1))]:-$HOME}")
    [[ -d "$target" ]] && dir=$target
    continue
  fi
  [[ "${words[$i]}" == git ]] || continue

  i=$((i + 1))
  git_dir=$dir
  while [[ $i -lt $count && "${words[$i]}" == -* ]]; do
    case "${words[$i]}" in
      -C) git_dir=$(resolve_dir "$git_dir" "${words[$((i + 1))]}"); i=$((i + 2)) ;;
      -c | --git-dir | --work-tree | --namespace) i=$((i + 2)) ;;
      *) i=$((i + 1)) ;;
    esac
  done
  [[ $i -lt $count ]] || continue
  check_git "$git_dir" "${words[$i]}" "${words[@]:$((i + 1))}"
done < <(awk '{ gsub(/&&|\|\||;|\|/, "\n"); print }' <<<"$command")
