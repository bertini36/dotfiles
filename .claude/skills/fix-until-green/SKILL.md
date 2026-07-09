---
name: fix-until-green
description: Loop project checks and pre-commit, dispatching a fixer subagent per failure, until everything passes or 5 iterations. Use in the Verify stage or standalone when checks fail.
---

# Fix Until Green

Loop until the project's checks pass. Never claim green without command output.

## Loop

1. Discover the check command: `make check` when the Makefile defines it, otherwise the project's documented equivalent (format + lint + tests).
2. Run the check command, then `pre-commit run --all-files` when configured. Activate the project venv first if the project requires it.
3. All green: report success with the final output and stop.
4. On failure: dispatch a fixer subagent (general-purpose) whose prompt contains only:
   - the failing command and its output, trimmed to the failing sections
   - the paths of the implicated files
   - the instruction: fix the failures with the minimal change; no refactors; do not delete or skip tests to force green (removing a test requires justifying it as redundant under the tests rule)
5. Re-run step 2.
6. Repeat at most 5 iterations. If still failing, stop and report honestly: what passes, what still fails, what was tried.

## Guardrails

- Never weaken assertions or silence failures with `# noqa`, `# type: ignore`, or skip marks; fix causes.
- The loop commits nothing; the caller decides when to commit.
- If the same failure repeats twice with no progress, stop early and switch to `superpowers:systematic-debugging`.
