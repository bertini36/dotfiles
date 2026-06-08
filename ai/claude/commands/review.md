---
description: Review current branch changes for quality and security
---

## Changes to Review

!`git diff --name-only main...HEAD`

Review the above changes for:
1. Code quality issues (naming, complexity, duplication)
2. Security vulnerabilities
3. Missing tests for critical paths
4. Adherence to project conventions

Dispatch the `code-reviewer` agent on the changed files. Summarize findings and suggest fixes.
