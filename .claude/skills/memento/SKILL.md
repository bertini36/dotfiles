---
name: memento
description: Build today's memory list from the previous working day's Granola meetings. Reads every Granola note from the last 1-2 working days (a Monday run reviews Friday; holidays and out-of-office days found in Google Calendar are skipped), extracts what the lead must remember or act on today, and shows up to 5 importance-sorted points in the conversation, flagging the ones that need action from the lead. Use whenever the lead asks for a memento, what to remember today, a recap or digest of yesterday's meetings, what they committed to or promised yesterday, pending follow-ups from recent meetings, or a morning briefing before the day starts.
---

# Memento

Start the day knowing what yesterday left behind. The skill finds the previous working day (or two), reads every Granola meeting note from that window, and distills the commitments, follow-ups, and deadlines the lead must carry into today. It shows up to 5 points, ordered from most to least important, directly in the conversation.

The run reads only Granola and Google Calendar and writes nothing, not even a file. There is no output artifact and no outward write; nothing is saved, published, posted, or shared.

Output language is always English, regardless of the source language.

## Run inputs

The only run-specific input is the date:

- `RUN_DATE`: today, ISO-8601.
- `REVIEW_DATES`: the working days under review, resolved in Step 1. Never provided by the lead; always derived from `RUN_DATE`, the weekend, and the calendar.

Throughout this skill, values in `{curly braces}` refer to these resolved run inputs.

## Goal

Show the lead up to 5 points to remember today, ordered from most to least important, directly in the conversation. Each point names a topic, says what to remember or do and why it matters today, and carries a source tag naming the Granola meeting and date it comes from. Points that require the lead to act carry an `[Action]` flag, so the to-dos stand out from the purely informational reminders.

Every point traces to a passage in a Granola note or transcript from the review window. Nothing is inferred from memory or from meetings outside the window.

## Inputs

- **Granola**: every meeting on `{REVIEW_DATES}` in the lead's Granola account (the authenticated connector already scopes to their meetings), providing metadata (title, date, participants), the Granola-generated notes, and the transcript on demand.
- **Google Calendar**, the lead's primary calendar: used only to resolve the review window; holidays and out-of-office days must not count as working days.

## Process

The whole run is read-only: it queries Granola and Google Calendar and writes nothing.

### Step 0: Preflight, verify every MCP connector (hard gate)

This is the first action of the run. Do not query Granola or the calendar, and do not move to Step 1, until this gate passes. The window resolution needs the calendar and the points need Granola; a missing connector partway through strands the run, so confirm both up front.

Check each connector by loading or listing its tools. A connector that exposes only an `authenticate` tool is connected but not authenticated, which counts as a failure.

| Connector | Needed for | Used in |
|---|---|---|
| Google Calendar | holidays and out-of-office days when resolving the review window | Step 1 |
| Granola | meeting notes and transcripts from the review window | Step 2 |

If either connector is missing or unauthenticated, stop and list every failing connector in one message, each with the `/mcp` action the lead must take, so they fix them in a single pass. Do not proceed with a partial set.

### Step 1: Resolve the review window

Set `RUN_DATE` to today, ISO-8601. Then walk backwards one calendar day at a time, starting from the day before `RUN_DATE`, until one working day is found. A day is skipped, not collected, when either:

- It is a Saturday or Sunday. This is what makes a Monday run review Friday.
- The lead's primary Google Calendar marks them off that day: an out-of-office event, or an all-day event whose title reads as time off (holiday, PTO, vacation, OOO, day off, festivo, and the like). Query the calendar for each candidate day before counting it.

The collected day becomes `REVIEW_DATES`. Record every skipped day and its reason (weekend, or the holiday event's title); the final message lists them so the lead can catch a wrong skip. When it is unclear whether a calendar event means the lead was off, ask the lead rather than guess.

Stop walking after 14 calendar days. If no working day turns up by then, stop and tell the lead.

### Step 2: Fetch the meetings from Granola

List every Granola meeting on `{REVIEW_DATES}` in the lead's Granola account, and fetch each one's metadata and Granola-generated notes. State the list (title and date per meeting) before extracting, so the lead can catch a missing or foreign meeting.

If the window holds no meetings at all, extend the window one more working day back (resolved with the same rules as Step 1, once only) and say so. If there are still none, tell the lead and end the run.

### Step 3: Extract candidate items

Walk the notes of every meeting and build a working list of things the lead must carry into today:

- Commitments the lead made: things they said they would do, send, review, or decide.
- Actions others are waiting on: anything where someone is blocked until the lead moves.
- Deadlines and dates agreed in the meeting, nearest first.
- Decisions made that the lead must communicate or execute.
- Feedback promised, in either direction, and people-sensitive threads (morale, conflicts, career asks).
- Follow-up meetings or messages the lead agreed to arrange.

The Granola-generated notes are the reading surface; they can misattribute owners or soften wording. When a candidate's owner, deadline, or exact commitment is unclear from the notes, open that meeting's transcript and confirm it there. Keep, for every candidate, the passage it comes from and its meeting; Step 5 needs both.

### Step 4: Rank and select the 5 points

Select up to 5 points from the candidate list, ordered from most to least important. Selection rules:

- Commitments due today, or already overdue, come first.
- Items where someone else is blocked on the lead beat items only the lead is waiting on.
- People-sensitive items (feedback promised, morale signals) rank above informational recaps.
- Recurrence is a strong signal: a theme raised in two meetings outranks one raised in passing.
- At most one point per theme; merge overlapping candidates instead of spending two slots, tagging both source meetings.
- Purely informational items (FYIs, status updates with no action) fill remaining slots only.

Flag every selected point that requires the lead to act (send, decide, review, message, unblock, arrange) by prefixing its topic with `[Action]`. A point built from someone else's task, or from context the lead only needs to know, carries no flag.

If the window holds fewer than 5 substantive, traceable points, show only the real ones and say so. Never pad with generic reminders to reach 5.

### Step 5: Validate against the sources

Before showing the points, re-check every one:

1. Each point resolves to a passage in the notes or transcript of the meeting its tag names, and the passage actually says it. Drop or rewrite any that do not.
2. Owners and deadlines confirmed only from generated notes, where the transcript was not checked and the note is ambiguous, are marked `unverified` in the point.
3. Every meeting title and date in the source tags matches the Granola metadata, and `REVIEW_DATES` plus the skipped-days list match what Step 1 resolved.

Do not use remembered or estimated content. Anything that cannot be traced does not go in the list.

### Step 6: Show the memento

Show the points in the conversation using the template in `references/output-format.md`. Read that file now for the exact structure. Do not write anything to disk; the conversation is the only output.

## Important rules

1. **Preflight is a hard gate.** Step 0 runs first and confirms both the Google Calendar and Granola connectors are authenticated. Do not fetch anything before it passes.
2. **The window is derived, never guessed.** Weekends and calendar holidays never count as working days; a Monday run reviews Friday. When a calendar event is ambiguous, ask the lead.
3. **Do not invent content.** Every point traces to a passage in a note or transcript from the review window. Anything untraceable is dropped in Step 5.
4. **The transcript settles doubts.** The generated notes are the reading surface, but owners, deadlines, and exact commitments that the notes leave unclear are confirmed in the transcript or marked `unverified`.
5. **Read-only, no artifact.** The run writes nothing to disk and never edits Granola or the calendar. Meeting content is sensitive; it appears only in the conversation.
6. **English only.** The output is English regardless of the source language.
7. **Writing quality.** Apply the `writing-clearly` skill to every line: concrete, specific, no filler, no em dashes.

## Do not

- Do not pad the points to reach 5; write only substantive, traceable ones.
- Do not count a weekend or calendar-holiday day as a working day, and do not silently skip a day the calendar does not justify skipping.
- Do not pull meetings from outside `{REVIEW_DATES}`, however relevant they look.
- Do not spend two points on one theme; merge them and tag both meetings.
- Do not quote long passages; paraphrase, with a short excerpt only when the exact wording matters.
- Do not mark a commitment done unless a source says so.
- Do not write the points to a file, even when asked to "save" in passing; confirm first, since this skill deliberately leaves no artifact.

## Style

- Tight bullets over paragraphs.
- Lead each point with the topic, then what to do and why today.
- Use ISO-8601 dates throughout.
- Apply `writing-clearly` to every line of prose.
