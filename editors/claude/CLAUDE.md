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

### Copilot PR Review Handling

When user pastes PR link and asks to review/address Copilot comments, run full cycle:
1. Fetch PR review comments via `gh api repos/{owner}/{repo}/pulls/{num}/comments` (filter author `copilot-pull-request-reviewer` / `Copilot`)
2. Read each comment with file path, line, suggestion
3. Checkout PR branch (`gh pr checkout <num>`)
4. Apply fixes for each valid comment; skip only with explicit reasoning
5. Commit fixes (conventional message, e.g. `fix: address Copilot review feedback`)
6. Push to PR branch
7. Reply to each comment via `gh api -X POST repos/{owner}/{repo}/pulls/{num}/comments/{comment_id}/replies` explaining fix or rejection
8. Resolve each thread via GraphQL `resolveReviewThread` mutation
9. Report summary: addressed, rejected, pushed commit SHA

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
