---
name: start-feature
description: Start the feature development pipeline from workflow.md
---

Begin the feature development pipeline defined in `workflow.md`.

Task: $ARGUMENTS

Current branch: !`git rev-parse --git-dir > /dev/null 2>&1 && git branch --show-current || echo "(no git repo)"`
Uncommitted changes: !`git rev-parse --git-dir > /dev/null 2>&1 && git status --short || echo "(no git repo)"`

Follow the pipeline strictly. Do not skip stages. Proceed stage-by-stage; pause between stages only when the pipeline requires user input or a GO verdict.

1. **Brainstorm** - invoke `superpowers:brainstorming` to explore requirements, edge cases, and design.
2. **Plan** - invoke `superpowers:writing-plans` to produce a step-by-step implementation plan.
3. **Evaluate** - dispatch the `evaluator` agent to score the plan (correctness, completeness, simplicity, consistency, testability, security, reversibility). Stop on NO-GO. Only proceed on GO.
4. **Implement** - invoke `superpowers:executing-plans`. Use `superpowers:dispatching-parallel-agents` when tasks are independent. Domain rules (`python`, `django`, `langchain`, `tests`) load automatically based on files touched.
5. **Verify** - invoke `superpowers:verification-before-completion`. Run the tests and `pre-commit` hooks before claiming completion.
6. **Review** - run `/review-branch` for code review, or `/audit` for a full code + security review.
7. **PR** - run `/create-pull-request`. Apply `superpowers:finishing-a-development-branch` for the merge/PR decision.

Rules:
- Conventional commit messages (`feat:`, `fix:`, `docs:`, ...).
- Use `gh` CLI for GitHub operations.
- Run `pre-commit` hooks before claiming a commit is ready.
- No implementation before a GO verdict from `evaluator`.
- If no `.git` repo is present, skip git/PR steps (branch creation, commits, PR). Still run Brainstorm, Plan, Evaluate, Implement, and Verify stages normally.
