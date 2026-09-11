# Global Instructions

## Code Style

- Favour simplicity, avoid premature abstractions, unnecessary error handling, or over-engineering
- Always delete dead/unused code
- Declare variables as close as possible to where they are used; do not hoist them to the top of a function or block
- Name functions and methods with a verb describing the action they perform (`build_invoice`, `fetch_user`, `is_active`); nouns are for variables and classes
- Use available skills for patterns and best practices:
  - `domain-service-layer`
  - `django-patterns`
  - `python-code-style`
  - `langchain-architecture`

## Docstrings and Comments

- Apply the `writing-clearly` skill to all prose, including code comments and docstrings
- Google-style docstrings for public classes and functions only
- Add docstrings only to public functions, services, and classes whose purpose is not clear from the name alone
- Add comments only for non-obvious *why*, never for *what*
- No `# ---` section dividers; use blank lines instead

## Workflow

Pipeline: Route, Branch or worktree, Brainstorm, Plan, Grill, Implement, Verify, Review, PR, Address feedback, Finish.
Route classifies the task first; Quick Change and Standard Implementation skip straight to Verify, everything else goes through Brainstorm onward.
Full walkthrough in the `start-feature` skill. The `grill-me` interview is the gate on a plan: it asks in rounds, and implementation starts when I confirm no decision in it is still fuzzy.

Rules:
- Conventional commit messages (`feat:`, `fix:`, `docs:`, etc.)
- Use `gh` CLI for all GitHub operations
- Create every pull request through the `create-pull-request` skill, with no exceptions. When another skill or workflow (e.g. `superpowers:finishing-a-development-branch`) reaches a "create PR" step or shows its own `gh pr create` snippet, ignore that snippet and invoke `create-pull-request` instead; it handles the repo's PULL_REQUEST_TEMPLATE
- Run `pre-commit` hooks before claiming a commit is ready

Commit discipline, in the pipeline and out of it. A reviewer walking the PR commit by commit should follow the chain of thought without ever needing the full diff:
- **One logical change per commit.** A commit adds a model, or adds a view, or adds tests for that view, never all three at once.
- **Self-contained.** Each commit compiles, passes its own tests, and makes sense in isolation. No "WIP" or "fixup" commits on the final branch; squash or rebase them away before the PR.
- **Ordered as a narrative.** Foundations first (types, models, schemas), then behavior (services, views), then surface (routes, UI), then tests and docs. A later commit may depend on an earlier one; an earlier commit must not depend on a later one.
- **Never mix refactors with feature work.** A rename, an extraction, or a reformat goes in its own commit before or after the feature change, not folded into it.
- **Message describes intent, not mechanics.** `feat: cache user permissions per request` beats `feat: add LRU dict to middleware`. The subject answers *what changed for the user*; the body answers *why* when the reason is not obvious.

Before opening a PR, read `git log --oneline main..HEAD`. If the sequence does not tell a coherent story, rebase until it does.

### PR Review Handling

When user pastes a PR link and asks to review or address comments, dispatch the `pr-reviewer` agent. It owns the open threads, not a second audit of the diff: it fetches all open review comments (humans and bots), applies or rejects fixes, commits, pushes, replies, resolves threads, verifies CI, and reports a summary.

Reply/resolve policy, binding for the main session and every agent:
- Never reply to or resolve a review thread opened by another human reviewer, even when I instructed the fix. Apply the fix in code, then leave the conversation to me; I answer humans myself.
- Replying and resolving is only allowed on threads opened by me (bertini36) or by bots (Copilot, CodeRabbit, etc.).

## Testing

- Run `pytest` with `-n auto` to parallelise across cores (requires `pytest-xdist`)

## Guardrails

- If 2+ interpretations exist, ask one clarifying question before proceeding
- Read existing patterns from `main` before coding; ask before inventing new variants

## AI Assistance Preferences

- Never use the em dash. Use a comma, semicolon, colon, or period instead
- Be direct and concise: no filler, no preamble
- Lead with the answer or the code, not an explanation of what you are about to do
- For spec-driven development with `superpowers` skills, create a descriptive branch first, e.g. feat/add-user-authentication
- Suggest the minimal change required; do not refactor surrounding code unless asked
- When multiple approaches exist, pick the simplest one and mention alternatives briefly
- Do not add comments, docstrings, or type hints to code you did not change
- Use ASCII art for schemas, diagrams, and tables when it helps clarify a concept or structure

@RTK.md
