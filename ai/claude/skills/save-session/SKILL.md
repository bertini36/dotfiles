---
name: save-session
description: Save a high-density summary of the current session to .claude_sessions.md
---

Save this session to the project's session index so it can be resumed later with `claude --resume`.

Optional name: $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Project root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
Resume command: !`SID="${CLAUDE_SESSION_ID:-$(cd "$HOME/.claude/projects/$(pwd|sed 's#[/.]#-#g')" 2>/dev/null && /bin/ls -t *.jsonl 2>/dev/null | head -1 | sed 's/\.jsonl$//')}"; [ -n "$SID" ] && echo "claude --resume $SID" || echo "(session id not found)"`

Steps:

1. **Name** the session in kebab-case (e.g. `stripe-webhook-fix-v1`). Use the name in `$ARGUMENTS` if given; otherwise derive a short, descriptive one from what we worked on. If a name already exists in the file, suffix `-v2`, `-v3`, etc.
2. **Summarize** in exactly 3 dense sentences: the problem, the context/decisions established, and the current state or next step. No filler. Optimize for a future agent re-loading this context cold.
3. **Append** the entry below to `.claude_sessions.md` in the project root, newest first (right under the `## Sessions` header). Create the file from the template if it does not exist. Use the resume command captured above verbatim.

Entry format:

```
### <session-name>
- **Date:** <today>
- **Resume:** `claude --resume <id>`

<3-sentence summary>
```

File template (only when creating):

```
# Claude Sessions

Index of sessions worth resuming. Git-ignored (global).
Resume any entry with its `claude --resume <id>` command from this project root.

## Sessions
```

After writing, print the session name, the resume command, and the 3-sentence summary.
