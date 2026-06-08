---
description: Fix a GitHub issue by number
---

Fix GitHub issue $ARGUMENTS.

Current branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
Uncommitted changes: !`git status --short`

1. Fetch issue details: !`gh issue view $ARGUMENTS`
2. Analyze the issue and identify affected files
3. Implement the fix following project conventions
4. Run tests and pre-commit hooks
5. Create a commit with a conventional message referencing the issue
