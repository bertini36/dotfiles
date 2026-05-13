# Feature Development Workflow

> Directives live in `CLAUDE.md`. This file is the walkthrough.

Step-by-step guide for building features using the Claude Code configuration in this repo.

## 1. Start a worktree

Open a Claude console in an isolated worktree:

```bash
claude --dangerously-skip-permissions --worktree
```

This creates an isolated copy of the repo so your work doesn't interfere with the main branch.

## 2. Brainstorm

Describe what you want to build. The `superpowers:brainstorming` skill triggers automatically to explore requirements, edge cases, and design before any code is written.

## 3. Plan

The `superpowers:writing-plans` skill creates a step-by-step implementation plan. The `evaluator` agent then scores it on seven criteria (correctness, completeness, simplicity, consistency, testability, security, reversibility) and issues a GO/NO-GO verdict. Implementation only proceeds on GO.

## 4. Implement

The `superpowers:executing-plans` skill drives implementation with review checkpoints. For independent tasks, `superpowers:dispatching-parallel-agents` runs multiple agents in parallel.

Domain-specific rules load automatically based on the files you touch:

| File pattern | Rule loaded | Skill available |
|---|---|---|
| `**/*.py` | `python` | `python-code-style` |
| Django files (views, models, urls, admin, etc.) | `django` | `django-patterns` |
| LangChain/LangGraph files | `langchain` | `langchain-architecture` |
| Test files | `tests` | - |

## 5. Verify

The `superpowers:verification-before-completion` skill runs before any success claim. Additionally, CLAUDE.md requires running three skills before marking a task complete:

- `production-code-audit`
- `django-patterns`
- `python-code-style`

## 6. Review

Review your branch changes:

```
/review
```

This dispatches the `code-reviewer` agent on the diff against `main`.

For a full audit including security:

```
/audit
```

This dispatches both the `code-reviewer` and `security-reviewer` agents.

## 7. Create PR

```
/create-pull-request
```

Uses the `create-pull-request` skill with `writing-clearly` for the description. The `superpowers:finishing-a-development-branch` skill guides the merge/PR decision.

## 8. Address PR feedback

After the PR is open and reviewers leave comments, dispatch the `pr-reviewer` agent:

```
Paste the PR link (e.g. https://github.com/owner/repo/pull/42)
```

The agent handles the full cycle: audits the diff, fetches all open review comments (humans and bots like Copilot, CodeRabbit), triages each comment (apply, reject, or defer), commits fixes, pushes, replies to threads, resolves them, verifies CI is green, and outputs a summary report.

## 9. Finish

```
/end-feature
```

Switches to `main`, pulls latest, and removes the merged feature branch locally and remotely.

## Quick Reference

```
Brainstorm --> Plan --> Evaluate --> Implement --> Verify --> Review --> PR --> Address feedback --> Finish
```

Most steps trigger automatically through the `superpowers` plugin. The manual touchpoints are:

- `/review` to run code review
- `/audit` to run full audit
- `/create-pull-request` to open the PR
- Paste a PR link to dispatch the `pr-reviewer` agent for handling review comments
- `/end-feature` to clean up after merge

## Fixing Issues

To pick up a GitHub issue and fix it directly:

```
/fix-issue 42
```

Fetches the issue, implements the fix, runs tests and pre-commit hooks, and creates a conventional commit referencing the issue.
