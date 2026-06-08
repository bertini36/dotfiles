# Global Instructions

## Code Style

- Favour simplicity, avoid premature abstractions, unnecessary error handling, or over-engineering
- Always delete dead/unused code
- Use available skills for patterns and best practices:
  - `ddd-patterns`
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

Pipeline: Brainstorm, Plan, Evaluate, Implement, Verify, Review, PR, Finish.
Full walkthrough in `workflow.md`. Implementation only proceeds on a GO verdict from the `evaluator` agent.

Rules:
- Conventional commit messages (`feat:`, `fix:`, `docs:`, etc.)
- Use `gh` CLI for all GitHub operations
- Run `pre-commit` hooks before claiming a commit is ready
- One logical change per commit. Commits must be atomic, self-contained, and ordered so the sequence reads as a narrative: a reviewer walking the PR commit by commit should follow the chain of thought without needing the diff as a whole. Split unrelated changes into separate commits; never mix refactors with feature work.

### PR Review Handling

When user pastes a PR link and asks to review or address comments, dispatch the `pr-reviewer` agent. It handles the full cycle: audit the diff, fetch all open review comments (humans and bots), apply or reject fixes, commit, push, reply, resolve threads, verify CI, and report a summary.

## Guardrails

- If 2+ interpretations exist, ask one clarifying question before proceeding
- Read existing patterns from `main` before coding; ask before inventing new variants
- Tool priority: LSP > semantic code search > Grep/Glob

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
