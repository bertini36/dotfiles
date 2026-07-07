---
name: start-feature
description: Start the feature development pipeline from workflow.md
---

Read `workflow.md` and follow its pipeline strictly, stage by stage, without skipping stages. Pause between stages only when the pipeline requires user input or a GO verdict.

Task: $ARGUMENTS

Current branch: !`git rev-parse --git-dir > /dev/null 2>&1 && git branch --show-current || echo "(no git repo)"`
Uncommitted changes: !`git rev-parse --git-dir > /dev/null 2>&1 && git status --short || echo "(no git repo)"`

Additional rules:
- If the task above includes a Jira ticket, pass it along so it lands in the PR description.
- If no `.git` repo is present, skip git/PR stages (branch creation, commits, PR). Still run Brainstorm, Plan, Grill, Evaluate, Implement, and Verify normally.
