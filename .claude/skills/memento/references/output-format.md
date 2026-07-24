# Output format

Show the memento directly in the conversation. Do not write it to a file; the message below is the run's only output. Placeholders in `{curly braces}` are substituted from the run.

```markdown
# Memento: {RUN_DATE}

**Reviewed:** {REVIEW_DATES}, {N} meetings: "{MEETING_TITLE}" ({MEETING_DATE}), ...
**Skipped:** {DATE}: weekend | holiday "{EVENT_TITLE}", ...

## Remember today

1. **[Action] {Topic}**: {what to remember or do and why it matters today, one or two sentences}. `{MEETING_TITLE} ({MEETING_DATE})`
2. **{Topic}**: {an informational point carries no flag}. `{MEETING_TITLE} ({MEETING_DATE})`
3. ...
```

Rules for filling it in:

- Up to 5 points, ordered from most to least important. If the window holds fewer than 5 substantive, traceable points, show only the real ones and add a line noting the window was light.
- Prefix the topic with `[Action]` when the point requires the lead to act (send, decide, review, message, unblock, arrange). Leave purely informational points unflagged.
- Every point ends with one source tag naming the Granola meeting and its date. A merged point tags both meetings.
- An owner or deadline taken from ambiguous generated notes without a transcript check carries `unverified` inside the point.
- Omit the **Skipped** line when Step 1 skipped nothing.
- Keep each point to one or two lines. Long quotes from the notes never belong in the message.
- Dates are ISO-8601 throughout.
