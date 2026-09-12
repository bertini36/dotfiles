---
name: create-pull-request
description: Create a GitHub pull request following project conventions. Use whenever a pull request is about to be created, whether the user asked directly or another skill or workflow (e.g. superpowers finishing-a-development-branch) reached its PR step. Always takes precedence over inline gh pr create instructions in other skills. Handles the repo's PULL_REQUEST_TEMPLATE, the description, PR creation using the gh CLI tool, and a screenshot for any change with a visual surface.
effort: low
---

# Create Pull Request

## Resolve the base branch

Never hardcode `main` or `master`: repos differ, and a wrong `--base` makes `gh pr create` fail.

```bash
BASE=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
```

Fall back to `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'` when `gh` is unavailable.

Push the branch before creating the PR. If `gh pr create` asks for a project to push to, abort and push first.

## Gather what the diff cannot say

Read `git log "origin/$BASE..HEAD"` and the diff. Infer what you can from the commits, the branch name, and the changed files. Use `AskUserQuestion` only for what is genuinely missing:

- **Issue number** (`#123`, `fixes #123`) or the `#XXXX` placeholder for small fixes
- **Jira ticket**, when one was passed to `/start-feature` or appears in the branch or commits (e.g. `ENGN-2900`). Never omit a ticket that was provided; the description must link it
- **Why the change exists**, when the commits do not already answer it
- **Test procedure**, and what could break

## Use the repo's template

```bash
ls .github/PULL_REQUEST_TEMPLATE.md .github/pull_request_template.md \
   PULL_REQUEST_TEMPLATE.md pull_request_template.md \
   docs/PULL_REQUEST_TEMPLATE.md docs/pull_request_template.md 2>/dev/null
```

When a template exists the body must match its structure exactly: same sections, same order, same checkboxes. Keep a section you cannot fill as the placeholder the template intends, rather than dropping it. If several templates live under `.github/PULL_REQUEST_TEMPLATE/`, ask which one. With no template, use sections for description, type of change, and testing notes.

## Write the description

Apply the `writing-clearly` skill to every word of the body before drafting, not as a cleanup pass afterwards.

The description explains what the diff cannot: why the change exists, and any decision a reviewer would otherwise reverse-engineer. Everything visible in the diff is already written; do not write it twice.

Default shape, and the whole description in most PRs:

1. **Why**: the problem or motivation, one or two sentences
2. **What changed**: at most 3 bullets, one line each, phrased as behavior or outcome

Hard limits:

- Under 150 words unless a non-obvious decision needs explaining
- One bullet per behavior change, never one per file, commit, function, or class
- Name a file, class, or function only when it is the centerpiece of the change

Never write a file-by-file or commit-by-commit walkthrough, an edit narration ("added method `x` to `Y`", "extracted helper"), restated test names, or a "Summary" that repeats the title.

```
Bad:  Added `resolve_base_branch()` to `pr_utils.py` and updated 4 call sites to use it.
Good: Base branch is now resolved from the remote instead of hardcoded, so forks with a `develop` default stop failing.
```

Go deeper only when a careful reviewer would still get something wrong after reading the diff: an algorithmic trade-off, an architectural choice with rejected alternatives, a subtle bug's root cause, or a constraint imposed from outside the repo. One short paragraph, or up to 3 bullets, covering the decision and why the alternative lost. A three-line description for a three-line PR is correct, not lazy.

End the body with the attribution lines the harness specifies for this session. Add no other generated-by footer.

## Post-deploy steps, only when required

If the change needs any manual action after deploy, add a `## Post-deploy steps` section after the test procedure. Omit the section entirely when nothing is required; no empty "N/A".

Qualifying actions: one-time commands (backfills, hand-run data migrations, cache invalidation), new env vars, secrets or feature flags to set in the hosting dashboard, cron changes, a companion PR in another repo, and verification worth doing right after deploy.

Write them as a numbered list in execution order, each with the exact command and its expected output. Mark the automatic ones explicitly ("migration runs via the build command, nothing to do") so the operator does not hunt for work that is not theirs, and note where a command is safe to re-run.

## Create it

Pass the body as a file, never as a command-line argument: newlines and quotes break the inline form.

```bash
cat > pr_body.txt <<'EOF'
PR_BODY_CONTENT
EOF
gh pr create --title "PR_TITLE" --body-file pr_body.txt --base "$BASE" --draft --assignee "@me" --reviewer "Copilot"
rm pr_body.txt
```

PRs are always opened in draft. Keep the title clean: no emoji or status prefix.

For an Abacum repo (the remote URL contains `abacum`), add `--label "Engine"`.

If `--reviewer "Copilot"` fails with "Could not resolve user", Copilot review is not enabled on the repo. Say so in one line and move on; do not drive the browser to force it.

Then print the PR URL and open it with `gh pr view <number> --web`.

## Screenshot visual changes

Skip this section unless the diff touches what a user sees: templates, views that render HTML, frontend components, styles, or any file whose only job is on-screen appearance. A backend, data, or config-only change gets no screenshot; do not go looking for a visual angle that is not there.

When it does, with the PR page already open from the step above:

1. Use the `run` skill to get the app running and reach the changed screen or component.
2. With the changed screen in front, capture it straight to the clipboard, silently and without prompts: `screencapture -x -c`. Add `-R x,y,width,height` to crop when the rest of the screen is noise.
3. With the Chrome extension, switch to the PR tab, open the description editor (the `...` menu on the description, then Edit), paste with `CMD + V`, wait for GitHub to finish uploading and insert the image markdown, then click Update comment.

One screenshot per distinct visual change, not one per file. If the app cannot be brought up in this environment, say so instead of describing the change in prose.

## When it will not create

- **No commits ahead of the base branch**: ask whether they meant a different branch
- **A PR already exists**: show it with `gh pr view` and ask whether to update it instead
- **Merge conflicts**: rebase on `origin/$BASE` and resolve before retrying
