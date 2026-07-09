---
name: start-feature
description: Start the feature development pipeline
---

Follow this pipeline strictly, stage by stage, without skipping stages. Pause between stages only when the pipeline requires user input or a GO verdict.

Task: $ARGUMENTS

Current branch: !`git rev-parse --git-dir > /dev/null 2>&1 && git branch --show-current || echo "(no git repo)"`
Uncommitted changes: !`git rev-parse --git-dir > /dev/null 2>&1 && git status --short || echo "(no git repo)"`

Additional rules:
- If the task above includes a Jira ticket, pass it along so it lands in the PR description.
- If no `.git` repo is present, skip git/PR stages (worktree, branch creation, commits, PR). Still run Brainstorm, Plan, Grill, Evaluate, Implement, and Verify normally.

## 1. Start a worktree

Work in an isolated worktree so the feature doesn't interfere with the main branch. If the session is not already in one, use the `superpowers:using-git-worktrees` skill to create it.

## 2. Brainstorm

The user describes what they want to build. The `superpowers:brainstorming` skill explores requirements, edge cases, and design before any code is written. Brainstorming is for when the user does not yet know what they want: the model asks, the user discovers.

## 3. Plan

The `superpowers:writing-plans` skill creates a step-by-step implementation plan.

Once the plan looks complete, the `grill-me` skill runs: it interviews the user one question at a time, anchored in the plan's concrete decisions, until reaching shared understanding.

Then dispatch the `plan-evaluator` agent. With fresh context that has no stake in the plan being right, it checks the grilled plan against the actual codebase (simplicity, consistency, security, reversibility) and issues a GO/NO-GO verdict. Implementation only proceeds on GO. On NO-GO, loop back to the plan with the blockers as input, then re-grill only the parts that changed.

## 4. Implement

For small plans, the `superpowers:executing-plans` skill drives implementation with review checkpoints. Each task follows `superpowers:test-driven-development`: a failing test pins the behavior before any implementation code. For independent tasks, `superpowers:dispatching-parallel-agents` runs multiple agents in parallel.

When the plan has 3 or more independent tasks, implement with `superpowers:subagent-driven-development` (preferred): each task goes to a fresh implementer subagent, and a per-task reviewer checks the work before moving on. Each subagent brief names the domain skills relevant to the files it touches (for example `django-patterns`, `python-code-style`). Its scratch files (task briefs, reports, progress ledger) live in a git-ignored `.superpowers/sdd/` directory; `git clean -fdx` deletes the progress ledger permanently, since git-ignored files are never in commit history and cannot be recovered unless backed up elsewhere.

Domain-specific rules load automatically based on the files touched:

| File pattern | Rule loaded | Skill available |
|---|---|---|
| `**/*.py` | `python` | `python-code-style` |
| Django files (views, models, urls, admin, etc.) | `django` | `django-patterns` |
| LangChain/LangGraph files | `langchain` | `langchain-architecture` |
| Test files | `tests` | - |

### Commit discipline

The PR must read as a story when walked commit by commit. A reviewer should follow the chain of thought without ever needing the full diff.

Rules:

- **One logical change per commit.** A commit adds a model, or adds a view, or adds tests for that view, never all three at once.
- **Self-contained.** Each commit compiles, passes its own tests, and makes sense in isolation. No "WIP" or "fixup" commits on the final branch; squash or rebase them away before the PR.
- **Ordered as a narrative.** Foundations first (types, models, schemas), then behavior (services, views), then surface (routes, UI), then tests and docs. A later commit may depend on an earlier one; an earlier commit must not depend on a later one.
- **Never mix refactors with feature work.** A rename, an extraction, or a reformat goes in its own commit before or after the feature change, not folded into it.
- **Message describes intent, not mechanics.** `feat: cache user permissions per request` beats `feat: add LRU dict to middleware`. The subject answers *what changed for the user*; the body answers *why* when the reason is not obvious.

Quick check before opening the PR: read `git log --oneline main..HEAD`. If the sequence does not tell a coherent story, rebase until it does.

## 5. Verify

The `superpowers:verification-before-completion` skill runs before any success claim: run the tests and `pre-commit` hooks and confirm the output. When checks fail, run the `fix-until-green` skill: it loops the project checks and `pre-commit`, dispatching a fixer subagent per failure, capped at 5 iterations, and reports honestly if it cannot converge. When a test fails or behavior surprises, use `superpowers:systematic-debugging` before proposing fixes; the same applies to bugs found in the Review step. Domain pattern skills (`django-patterns`, `python-code-style`, etc.) already applied during implementation via the rules; reviews happen in the next step. Do not run `production-code-audit` here; it rewrites code rather than verifying it.

## 6. Review

Review the branch changes with `/review-branch`, which dispatches the `code-reviewer` agent on the diff against `main`.

For a full audit including security, `/audit` dispatches both the `code-reviewer` and `security-reviewer` agents.

## 7. Create PR

Use the `create-pull-request` skill with `writing-clearly` for the description. The `superpowers:finishing-a-development-branch` skill guides the merge/PR decision.

## 8. Address PR feedback

After the PR is open and reviewers leave comments, the user pastes the PR link (e.g. https://github.com/owner/repo/pull/42). Dispatch the `pr-reviewer` agent.

The agent handles the full cycle: audits the diff, fetches all open review comments (humans and bots like Copilot, CodeRabbit), triages each comment (apply, reject, or defer), commits fixes, pushes, replies to threads, resolves them, verifies CI is green, and outputs a summary report.

## 9. Finish

Run `/end-feature`: switches to `main`, pulls latest, and removes the merged feature branch locally and remotely.

## Quick Reference

```
Brainstorm --> Plan --> Grill --> Evaluate --> Implement --> Verify --> Review --> PR --> Address feedback --> Finish
```

Most steps trigger automatically through the `superpowers` plugin. The manual touchpoints are:

- `/review-branch` to run code review
- `/audit` to run full audit
- `/create-pull-request` to open the PR
- Paste a PR link to dispatch the `pr-reviewer` agent for handling review comments
- `/end-feature` to clean up after merge
