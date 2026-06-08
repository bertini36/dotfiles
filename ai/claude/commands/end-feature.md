---
description: Finalize a merged PR by switching to main, pulling, and removing the merged feature branch locally and remotely
---

Finalize work after a feature PR has been merged.

Current branch: !`git branch --show-current`
Default branch: !`git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
Uncommitted changes: !`git status --short`
Worktrees: !`git worktree list`

Steps:

1. **Capture context** - record the current branch name as `FEATURE_BRANCH` and the default branch (usually `main`) as `BASE_BRANCH`. Refuse to continue if they are equal.
2. **Verify merge** - run `gh pr view --json state,mergedAt,headRefName` for the current branch. Abort if `state != MERGED`. Do not delete unmerged work.
3. **Check working tree** - if uncommitted changes exist, stop and ask the user before any destructive step.
4. **Detect worktree** - run `git worktree list --porcelain`. If `$FEATURE_BRANCH` is checked out in a worktree other than the main repo path, record it as `FEATURE_WORKTREE`. If the current session is inside `$FEATURE_WORKTREE`, ask the user to switch to the main repo path first; do not proceed.
5. **Switch and update** - `git checkout $BASE_BRANCH && git pull --ff-only origin $BASE_BRANCH` (run from main repo path, not from `$FEATURE_WORKTREE`).
6. **Remove worktree** - if `$FEATURE_WORKTREE` exists: `git worktree remove $FEATURE_WORKTREE`. If it refuses due to untracked/modified files inside, list them and ask the user before retrying with `--force`.
7. **Delete local branch** - `git branch -d $FEATURE_BRANCH`. If git refuses (not fully merged into base via fast-forward, e.g. squash merge), confirm the PR was merged via step 2 then use `git branch -D $FEATURE_BRANCH`.
8. **Delete remote branch** - first check whether the remote branch still exists with `git ls-remote --exit-code --heads origin $FEATURE_BRANCH`. If it exists, ask the user for explicit confirmation before running `git push origin --delete $FEATURE_BRANCH`. Skip silently if the remote branch was already deleted by GitHub auto-delete.
9. **Prune stale refs** - `git fetch --prune && git worktree prune`.
10. **Report** - confirm: worktree removed (if applicable), branch deleted locally and remotely, on `$BASE_BRANCH` at latest commit.

Rules:
- Never run destructive deletes without confirming PR merge state via `gh`.
- Use `gh` CLI for all GitHub operations.
- Stop and ask the user if any step fails unexpectedly.
