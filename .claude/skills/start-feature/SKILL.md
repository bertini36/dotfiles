---
name: start-feature
description: Start the feature development pipeline
---

Follow this pipeline stage by stage, without skipping any. Pause between stages only when the pipeline asks the user something.

Task: $ARGUMENTS

Current branch: !`git rev-parse --git-dir > /dev/null 2>&1 && git branch --show-current || echo "(no git repo)"`
Uncommitted changes: !`git rev-parse --git-dir > /dev/null 2>&1 && git status --short || echo "(no git repo)"`
In a worktree: !`git rev-parse --git-dir 2>/dev/null | grep -q '/worktrees/' && echo "yes" || echo "no"`

Additional rules:
- If the task above includes a Jira ticket, pass it along so it lands in the PR description.
- If no `.git` repo is present, skip the git and PR stages (branch or worktree creation, commits, PR); continue the rest of the pipeline through Verify.

## 1. Start a branch or worktree

If the context above says the session is already in a worktree, say so and move on without asking.

Otherwise ask the user, with `AskUserQuestion`:

- **Yes, use a worktree** (recommended): create it with the `superpowers:using-git-worktrees` skill, then run the rest of the pipeline inside it. It isolates the feature so the current checkout stays usable.
- **No, work here**: create a descriptive branch off `main` (for example `feat/add-user-authentication`) and continue in the current working tree.

Take the answer at face value; do not re-ask later in the pipeline.

## 2. Brainstorm

The user describes what they want to build. The `superpowers:brainstorming` skill explores requirements, edge cases, and design before any code is written. Brainstorming is for when the user does not yet know what they want: the model asks, the user discovers.

## 3. Plan

The `superpowers:writing-plans` skill creates a step-by-step implementation plan.

The plan must name how the work will be proven: which tests pin each behavior, and what has to pass before the change is done. A spec is only as solid as the harness that checks it; without one, the plan states an intention and nothing measures whether the code met it.

Once the plan looks complete, the `grilling` skill runs: it interviews the user in rounds, anchored in the plan's concrete decisions, until every decision is settled. The interview is the gate. Running out of questions does not open it; the user confirming shared understanding does.

## 4. Implement

Implement in this session with `superpowers:executing-plans`. Each task follows `superpowers:test-driven-development`: a failing test pins the behavior before any implementation code.

Subagents are for fan-out, not for relay. Dispatch them with `superpowers:dispatching-parallel-agents` when the work splits into pieces that share no state and depend on no ordering, so each one can be handed a self-contained brief and judged on what it returns:

- Sweeping the repository for every reference to a symbol, pattern, or convention
- Auditing an area against a checklist (security, tests, dependencies)
- Getting oriented in an unfamiliar subsystem before the plan touches it

Do not split a dependent chain across subagents. Explore, then plan, then code, then test is sequential: every handoff summarises away the context the next step needs, and the summary of a test failure is exactly the information required to fix it. A per-task implementer plus a per-task reviewer is that same relay with extra hops. Keep the chain in one session, where the context is already loaded.

Domain-specific rules load automatically based on the files touched:

| File pattern | Rule loaded | Skill available |
|---|---|---|
| `**/*.py` | `python` | `python-code-style` |
| Django files (views, models, urls, admin, etc.) | `django` | `django-patterns` |
| Test files | `tests` | - |

### Commit discipline

The rules live in `CLAUDE.md` and apply to every commit, inside this pipeline and out of it. Follow them here; do not restate them.

## 5. Verify

The `superpowers:verification-before-completion` skill runs before any success claim: run the tests and `pre-commit` hooks and confirm the output. When checks fail, run the `fix-until-green` skill: it loops the project checks and `pre-commit`, capped at 5 iterations, and reports honestly if it cannot converge. When a test fails or behavior surprises, use `superpowers:systematic-debugging` before proposing fixes; the same applies to bugs found in the Review step. Domain pattern skills (`django-patterns`, `python-code-style`, etc.) already applied during implementation via the rules; reviews happen in the next step.

## 6. Review

Dispatch the `code-reviewer` agent on the diff against `main`. It reports; it does not fix. Judge each finding yourself before acting on it.

Review the diff once. The PR feedback stage handles reviewer comments, not a second audit of the same code.

When the change touches authentication, authorization, secrets, user input, or serialization, run `/security-review` as well.

## 7. Create PR

Use the `create-pull-request` skill with `writing-clearly` for the description. The `superpowers:finishing-a-development-branch` skill guides the merge/PR decision.

## 8. Address PR feedback

After the PR is open and reviewers leave comments, the user pastes the PR link (e.g. https://github.com/owner/repo/pull/42). Dispatch the `pr-reviewer` agent.

The agent fetches all open review comments (humans and bots like Copilot, CodeRabbit), triages each one (apply, reject, or defer), commits fixes, pushes, replies to threads, resolves them, verifies CI is green, and reports. It does not re-audit the diff; stage 6 already did.

## 9. Finish

Once the PR is merged: switch to `main`, pull the latest changes, then remove the merged feature branch locally and remotely. If the work ran in a worktree, remove it too (`git worktree remove`).

## Quick Reference

```
Branch or worktree --> Brainstorm --> Plan --> Grill --> Implement --> Verify --> Review --> PR --> Address feedback --> Finish
```

Most steps trigger automatically through the `superpowers` plugin. The manual touchpoints are:

- `/create-pull-request` to open the PR
- Paste a PR link to dispatch the `pr-reviewer` agent for handling review comments
