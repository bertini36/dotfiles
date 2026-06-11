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

Ensure you're not on `master`. If so, ask the user to create or switch to a feature branch.

### 2. Find the base branch

```bash
git remote show origin | grep "HEAD branch"
```

This is typically `main` or `master`.

### 3. Analyze recent commits relevant to this PR

```bash
git log origin/master..HEAD --oneline --no-decorate
```

Review these commits to understand:
- What changes are being introduced
- The scope of the PR (single feature/fix or multiple changes)
- Whether commits should be squashed or reorganized

### 4. Review the diff

```bash
git diff origin/master..HEAD --stat
```

This shows which files changed and helps identify the type of change.

## Information Gathering

Before creating the PR, you need the following information. Check if it can be inferred from:
- Commit messages
- Branch name (e.g., `fix/issue-123`, `feature/new-login`)
- Changed files and their content

If any critical information is missing, use `ask_followup_question` to ask the user:

### Required Information

1. **Related Issue Number**: Look for patterns like `#123`, `fixes #123`, or `closes #123` in commit messages
2. **Description**: What problem does this solve? Why were these changes made?
3. **Type of Change**: Bug fix, new feature, breaking change, refactor, cosmetic, documentation, or workflow
4. **Test Procedure**: How was this tested? What could break?

## Git Best Practices

Before creating the PR, consider these best practices:

### Commit Hygiene

1. **Atomic commits**: Each commit should represent a single logical change
2. **Clear commit messages**: Follow conventional commit format when possible
3. **No merge commits**: Prefer rebasing over merging to keep history clean

### Branch Management

1. **Rebase on latest master** (if needed):
   ```bash
   git fetch origin
   git rebase origin/master
   ```

2. **Squash if appropriate**: If there are many small "WIP" commits, consider interactive rebase:
   ```bash
   git rebase -i origin/master
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

When filling out the template:
- Replace `#XXXX` with the actual issue number, or keep as `#XXXX` if no issue exists (for small fixes)
- Fill in all sections with relevant information gathered from commits and context
- Mark the appropriate "Type of Change" checkbox(es)
- Complete the "Pre-flight Checklist" items that apply
- Ask for confirmation of the generated PR_BODY

### Complex Logic — Deeper Descriptions

If the PR introduces non-trivial logic (e.g., algorithmic changes, architectural decisions, subtle bug fixes, or multi-step workflows), the description must go deeper. Apply the `writing-clearly` skill to write a clear, precise explanation that covers:

- **Why**: The problem or motivation behind the change
- **What**: The approach taken and why it was chosen over alternatives
- **How**: Key implementation details a reviewer needs to understand the code

Avoid vague summaries. A reviewer should be able to understand the intent and trade-offs without reading every line of code.

### Create PR with gh CLI
Avoid passing the PR body directly as a command-line argument, as this often fails with complex text (newlines, quotes, etc.). Instead, use a temporary file or a here-doc/heredoc approach.

**Recommended approach (File-based):**
1. Write the PR body to a temporary file (e.g., `pr_body.txt`).
2. Use the `--body-file` flag instead of `--body`.

```bash
# Example
cat > pr_body.txt <<'EOF'
PR_BODY_CONTENT
EOF
gh pr create --title "PR_TITLE" --body-file pr_body.txt --base master --draft --assignee "@me" --reviewer "Copilot"
rm pr_body.txt # Clean up
```

If the project belongs to the Abacum organization (e.g., remote URL contains `abacum`), add `--label "Engine"`:

```bash
cat > pr_body.txt <<'EOF'
PR_BODY_CONTENT
EOF
gh pr create --title "PR_TITLE" --body-file pr_body.txt --base master --draft --assignee "@me" --reviewer "Copilot" --label "Engine"
rm pr_body.txt # Clean up
```

If the `gh pr create` command asks for a project to push the changes, abort and push the branch first

## Post-Creation

After creating the PR:

1. **Display the PR URL** so the user can review it
2. **Remind about CI checks**: Tests and linting will run automatically
3. **Suggest next steps**:
   - Add labels if needed: `gh pr edit --add-label "bug"`

## Error Handling

### Common Issues

1. **No commits ahead of master**: The branch has no changes to submit
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
- [ ] PR description follows the template exactly
- [ ] Appropriate type of change is selected
- [ ] Pre-flight checklist items are addressed
- [ ] PR is created in draft mode (`--draft`)