---
name: review-branch
description: Review current branch changes for quality and security
---

## Changes to Review

Base branch: !`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main`

!`BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'); git diff --name-only "${BASE:-main}...HEAD"`

Review the above changes for:
1. Code quality issues (naming, complexity, duplication)
2. Security vulnerabilities
3. Missing tests for critical paths
4. Adherence to project conventions

Dispatch the `code-reviewer` agent on the changed files. Summarize findings and suggest fixes.
