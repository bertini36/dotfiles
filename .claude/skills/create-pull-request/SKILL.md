---
name: create-pull-request
description: Create a GitHub pull request following project conventions. Use whenever a pull request is about to be created, whether the user asked directly or another skill or workflow (e.g. superpowers finishing-a-development-branch) reached its PR step. Always takes precedence over inline gh pr create instructions in other skills. Handles commit analysis, branch management, the repo's PULL_REQUEST_TEMPLATE, and PR creation using the gh CLI tool.
effort: low
---

# Create Pull Request

This skill guides you through creating a well-structured GitHub pull request that follows project conventions and best practices.

### 1. Verify clean working directory

```bash
git status
```

If there are uncommitted changes, ask the user whether to:
- Commit them as part of this PR
- Stash them temporarily
- Discard them (with caution)

## Gather Context

### 1. Identify the current branch

```bash
git branch --show-current
```

Ensure you're not on the base branch resolved below. If so, ask the user to create or switch to a feature branch.

### 2. Find the base branch

Resolve it once, then use `$BASE` in every command that follows. Never hardcode `main` or `master`: repos differ, and a wrong `--base` makes `gh pr create` fail.

```bash
BASE=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
```

If `gh` is unavailable, fall back to `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`.

### 3. Analyze recent commits relevant to this PR

```bash
git log "origin/$BASE..HEAD" --oneline --no-decorate
```

Review these commits to understand:
- What changes are being introduced
- The scope of the PR (single feature/fix or multiple changes)
- Whether commits should be squashed or reorganized

### 4. Review the diff

```bash
git diff "origin/$BASE..HEAD" --stat
```

This shows which files changed and helps identify the type of change.

## Information Gathering

Before creating the PR, you need the following information. Check if it can be inferred from:
- Commit messages
- Branch name (e.g., `fix/issue-123`, `feature/new-login`)
- Changed files and their content

If any critical information is missing, use `AskUserQuestion` to ask the user:

### Required Information

1. **Related Issue Number**: Look for patterns like `#123`, `fixes #123`, or `closes #123` in commit messages
2. **Jira Ticket**: If the feature was started with a Jira ticket (e.g. passed to `/start-feature`) or the branch name/commits reference a Jira key (e.g. `ENGN-2900`), the PR description **must** include a link to it. Never omit a ticket that was provided.
3. **Description**: What problem does this solve? Why were these changes made?
4. **Type of Change**: Bug fix, new feature, breaking change, refactor, cosmetic, documentation, or workflow
5. **Test Procedure**: How was this tested? What could break?

## Git Best Practices

Before creating the PR, consider these best practices:

### Commit Hygiene

1. **Atomic commits**: Each commit should represent a single logical change
2. **Clear commit messages**: Follow conventional commit format when possible
3. **No merge commits**: Prefer rebasing over merging to keep history clean

### Branch Management

1. **Rebase on the latest base branch** (if needed):
   ```bash
   git fetch origin
   git rebase "origin/$BASE"
   ```

2. **Squash if appropriate**: If there are many small "WIP" commits, consider interactive rebase:
   ```bash
   git rebase -i "origin/$BASE"
   ```
   Only suggest this if commits appear messy and the user is comfortable with rebasing.

### Push Changes

**IMPORTANT**: Ensure all commits are pushed:
```bash
git push origin HEAD
```

If the branch was rebased, you may need:
```bash
git push origin HEAD --force-with-lease
```

## Create the Pull Request

### 1. Check for a PR template

Before drafting the body, check whether the repo provides a pull request template. GitHub looks in these locations (case-insensitive):

```bash
ls .github/PULL_REQUEST_TEMPLATE.md \
   .github/pull_request_template.md \
   PULL_REQUEST_TEMPLATE.md \
   pull_request_template.md \
   docs/PULL_REQUEST_TEMPLATE.md \
   docs/pull_request_template.md 2>/dev/null
```

If multiple templates exist under `.github/PULL_REQUEST_TEMPLATE/`, list them and ask the user which one to use.

### 2. Build the PR body

If a template exists, read it and use it as the PR body format, the body must **strictly match** the template structure (sections, order, checkboxes, placeholders). Do not drop sections you cannot fill, leave them with a placeholder or empty value as the template intends.

If no template exists, use a sensible default structure with sections for description, type of change, and testing notes.

Never append a "🤖 Generated with Claude Code" footer (or any similar attribution line) to the PR body.

When filling out the template:
- Replace `#XXXX` with the actual issue number, or keep as `#XXXX` if no issue exists (for small fixes)
- Include the Jira ticket link whenever one was provided when the feature started or is referenced in the branch/commits
- Fill in all sections with relevant information gathered from commits and context
- Mark the appropriate "Type of Change" checkbox(es)
- Complete the "Pre-flight Checklist" items that apply
- Ask for confirmation of the generated PR_BODY

### Description Content — Short and Concrete

The description explains what the diff cannot: why the change exists, and any decision a reviewer would otherwise have to reverse-engineer. Everything the reviewer can read in the diff is already written; do not write it twice.

Default shape, and the whole description in most PRs:

1. **Why**: the problem or motivation, one or two sentences
2. **What changed**: at most 3 bullets, one line each, phrased as behavior or outcome, not as code edits

Hard limits:
- The description body stays under 150 words unless a non-obvious decision needs explaining
- One bullet per behavior change, never one per file, commit, function, or class
- Name a file, class, or function only when it is the centerpiece of the change

Never write:
- A file-by-file or commit-by-commit walkthrough
- "Added method `x` to `Y`", "renamed `a` to `b`", "extracted helper", or any other narration of an edit visible in the diff
- Restated test names, restated type annotations, or a list of touched modules
- Sections padded to look thorough: no "Summary" that repeats the title, no bullets that say nothing a reader could not guess

Write bullets that carry information a reviewer cannot get from the diff:

```
Bad:  Added `resolve_base_branch()` to `pr_utils.py` and updated 4 call sites to use it.
Good: Base branch is now resolved from the remote instead of hardcoded, so forks with a `develop` default stop failing.
```

### Non-obvious Decisions — Add Only What Is Needed

Go deeper only when the change carries something a careful reviewer would still get wrong after reading the diff: an algorithmic trade-off, an architectural choice with rejected alternatives, a subtle bug's root cause, or a constraint imposed from outside the repo.

When that applies, add one short paragraph, or up to 3 bullets, covering the decision and why the alternative was rejected. Apply the `writing-clearly` skill. Stop there: implementation detail belongs in code comments, not in the PR body.

If nothing about the change is non-obvious, skip this entirely. A three-line description for a three-line PR is correct, not lazy.

### Post-deploy Steps — Only When Required

If the change needs ANY manual action after deploy, add a `## Post-deploy steps` section to the PR body (after Test Procedure, before the checklist). Omit the section entirely when nothing is required — do not add an empty "N/A" section.

Actions that qualify:
- One-time commands: seed/backfill management commands, data migrations that must be run by hand, cache invalidation
- New or changed env vars, secrets, or feature flags that must be set in the hosting dashboard
- Cron/scheduled-task additions or changes
- Cross-repo dependencies (e.g. a companion frontend/backend PR that must be merged and deployed for the feature to be visible)
- Manual verification worth doing right after deploy (what to check, and what "looks broken but is expected" behavior to not misread)

Write the steps as a numbered list, in execution order, each with the exact command and its expected output where applicable. Explicitly mark steps that are automatic (e.g. "migration runs via the build command — nothing to do") so the operator doesn't hunt for work that isn't theirs. Note idempotency where a command is safe to re-run.

### Create PR with gh CLI

When the PR is opened in draft mode (`--draft`), prefix the title with `🚧 ` (e.g. `🚧 feat: add user authentication`). Drop the prefix when the PR is marked ready for review.

Avoid passing the PR body directly as a command-line argument, as this often fails with complex text (newlines, quotes, etc.). Instead, use a temporary file or a here-doc/heredoc approach.

**Recommended approach (File-based):**
1. Write the PR body to a temporary file (e.g., `pr_body.txt`).
2. Use the `--body-file` flag instead of `--body`.

```bash
# Example
cat > pr_body.txt <<'EOF'
PR_BODY_CONTENT
EOF
gh pr create --title "🚧 PR_TITLE" --body-file pr_body.txt --base "$BASE" --draft --assignee "@me" --reviewer "Copilot"
rm pr_body.txt # Clean up
```

If the project belongs to the Abacum organization (e.g., remote URL contains `abacum`), add `--label "Engine"`:

```bash
cat > pr_body.txt <<'EOF'
PR_BODY_CONTENT
EOF
gh pr create --title "🚧 PR_TITLE" --body-file pr_body.txt --base "$BASE" --draft --assignee "@me" --reviewer "Copilot" --label "Engine"
rm pr_body.txt # Clean up
```

If the `gh pr create` command asks for a project to push the changes, abort and push the branch first

## Post-Creation

After creating the PR:

1. **Display the PR URL** so the user can review it
2. **Add Copilot as reviewer**, always do this after every PR creation:

   ```bash
   gh pr edit <number> --add-reviewer "Copilot"
   ```

   If it fails with "Could not resolve user", Copilot review is not enabled on the repo. Say so in one line and move on; do not drive the browser to force it.

3. **Open the PR in the browser**:
   ```bash
   gh pr view <number> --web
   ```

4. **Remind about CI checks**: Tests and linting will run automatically
5. **Suggest next steps**:
   - Add labels if needed: `gh pr edit --add-label "bug"`

## Error Handling

### Common Issues

1. **No commits ahead of the base branch**: The branch has no changes to submit
   - Ask if the user meant to work on a different branch

2. **Branch not pushed**: Remote doesn't have the branch
   - Push the branch first: `git push -u origin HEAD`

3. **PR already exists**: A PR for this branch already exists
   - Show the existing PR: `gh pr view`
   - Ask if they want to update it instead

4. **Merge conflicts**: Branch conflicts with base
   - Guide user through resolving conflicts or rebasing

## Summary Checklist

Before finalizing, ensure:
- [ ] Working directory is clean
- [ ] All commits are pushed
- [ ] Branch is up-to-date with base branch
- [ ] Related issue number is identified, or placeholder is used
- [ ] Jira ticket link is included if one was provided when the feature started
- [ ] PR description follows the template exactly
- [ ] Description is under 150 words: why, plus at most 3 outcome bullets
- [ ] No file-by-file, commit-by-commit, or edit-narrating content anywhere in the body
- [ ] Extra explanation present only where a decision is genuinely non-obvious
- [ ] Appropriate type of change is selected
- [ ] Post-deploy steps section included if any manual action is required after deploy (omitted otherwise)
- [ ] Pre-flight checklist items are addressed
- [ ] PR is created in draft mode (`--draft`)
- [ ] Copilot added as reviewer
- [ ] PR opened in the browser