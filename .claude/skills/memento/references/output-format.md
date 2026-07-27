# Output format

Show the memento directly in the conversation. Do not write it to a file; the message below is the run's only output. Placeholders in `{curly braces}` are substituted from the run.

```markdown
# Memento: {RUN_DATE}

**Reviewed:** {REVIEW_DATES}
**Meetings:** {N}: "{MEETING_TITLE}" ({MEETING_DATE}), ...
**Slack:** {M} conversations: {#channel-name}, {DM with Name}, ...
**Skipped:** {DATE}: weekend | holiday "{EVENT_TITLE}", ...

## Remember today

1. **[Action] {Topic}**: {what to remember or do and why it matters today, one or two sentences}. `{SOURCE_TAG}`
2. **{Topic}**: {an informational point carries no flag}. `{SOURCE_TAG}`
3. ...
```

Rules for filling it in:

- Up to 5 points, ordered from most to least important. If the window holds fewer than 5 substantive, traceable points, show only the real ones and add a line noting the window was light.
- Prefix the topic with `[Action]` when the point requires the lead to act (send, decide, review, message, unblock, arrange). Leave purely informational points unflagged.
- Every point ends with at least one source tag, in one of three forms:
  - Granola: `{MEETING_TITLE} ({MEETING_DATE})`
  - Slack channel: `#{CHANNEL_NAME} ({MESSAGE_DATE})`
  - Slack DM or group DM: `DM with {NAME} ({MESSAGE_DATE})`
- A merged point lists every source it came from, comma-separated inside one tag, whichever sources they are. A point drawn from a meeting and the DM that chased it tags both.
- An owner or deadline taken from ambiguous generated notes without a transcript check carries `unverified` inside the point.
- Omit the **Skipped** line when Step 1 skipped nothing. Keep the **Meetings** and **Slack** lines even at zero, written as `0`, so a quiet source is visible rather than merely absent.
- When a Slack search hit its pagination cap in Step 2, add a **Coverage** line saying which day and query were truncated.
- Keep each point to one or two lines. Long quotes from the notes or from Slack never belong in the message.
- Dates are ISO-8601 throughout.
