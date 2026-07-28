---
name: memento
description: Build today's memory list from the previous working day's Granola meetings and Slack conversations. Reads every Granola note, plus every Slack message the user sent, received, or was mentioned in, over the last 1-2 working days (a Monday run reviews Friday; holidays and out-of-office days found in Google Calendar are skipped), extracts what the user must remember or act on today, and shows up to 5 importance-sorted points in the conversation, flagging the ones that need action from the user. Use whenever the user asks for a memento, what to remember today, a recap or digest of yesterday's meetings or Slack threads, what they committed to or promised yesterday, pending follow-ups from recent meetings or messages, or a morning briefing before the day starts.
---

# Memento

Start the day knowing what yesterday left behind. The skill finds the previous working day (or two), reads every Granola meeting note and every Slack conversation the user took part in over that window, and distills the commitments, follow-ups, and deadlines the user must carry into today. It shows up to 5 points, ordered from most to least important, directly in the conversation.

Meetings and Slack are equal sources. A promise typed in a DM counts the same as one made out loud in a meeting.

The run reads only Granola, Slack, and Google Calendar, and writes nothing, not even a file. There is no output artifact and no outward write; nothing is saved, published, posted, or shared. The Slack connector can send and schedule messages and edit canvases; this skill never uses those tools.

Output language is always English, regardless of the source language.

## Run inputs

The only run-specific input is the date; everything else is resolved by the run:

- `RUN_DATE`: today, ISO-8601.
- `REVIEW_DATES`: the working days under review, resolved in Step 1. Never provided by the user; always derived from `RUN_DATE`, the weekend, and the calendar.
- `USER_ID`: the user's Slack user ID, resolved in Step 2 by calling `slack_read_user_profile` with no `user_id`, which returns the authenticated user. Never typed by hand.

Throughout this skill, values in `{curly braces}` refer to these resolved run inputs.

## Goal

Show the user up to 5 points to remember today, ordered from most to least important, directly in the conversation. Each point names a topic, says what to remember or do and why it matters today, and carries a source tag naming where it comes from: a Granola meeting and its date, or a Slack conversation and its date. Points that require the user to act carry an `[Action]` flag, so the to-dos stand out from the purely informational reminders.

Every point traces to a passage in a Granola note or transcript, or to a Slack message, from the review window. Nothing is inferred from memory, from meetings and messages outside the window, or from Slack traffic the user was never party to.

## Inputs

- **Granola**: every meeting on `{REVIEW_DATES}` in the user's Granola account (the authenticated connector already scopes to their meetings), providing metadata (title, date, participants), the Granola-generated notes, and the transcript on demand.
- **Slack**: the user-centric slice of `{REVIEW_DATES}`, meaning every message the user sent, every message addressed to them, and every message mentioning them, across DMs, group DMs, and private and public channels. Threads are opened on demand. Channel chatter the user was never named in is out of scope.
- **Google Calendar**, the user's primary calendar: used only to resolve the review window; holidays and out-of-office days must not count as working days.

## Process

The whole run is read-only: it queries Granola, Slack, and Google Calendar, and writes nothing.

### Step 0: Preflight, verify every MCP connector (hard gate)

This is the first action of the run. Do not query any source, and do not move to Step 1, until this gate passes. The window resolution needs the calendar and the points need both Granola and Slack; a missing connector partway through strands the run, so confirm all three up front.

Check each connector by loading or listing its tools. A connector that exposes only an `authenticate` tool is connected but not authenticated, which counts as a failure.

| Connector | Needed for | Used in |
|---|---|---|
| Google Calendar | holidays and out-of-office days when resolving the review window | Step 1 |
| Granola | meeting notes and transcripts from the review window | Step 2 |
| Slack | the user's messages, mentions, and threads from the review window | Step 2 |

All three are hard requirements. If any connector is missing or unauthenticated, stop and list every failing connector in one message, each with the `/mcp` action the user must take, so they fix them in a single pass. Do not proceed with a partial set, and do not offer a Granola-only or Slack-only memento as a fallback: a partial sweep looks complete and hides the commitments it never read.

### Step 1: Resolve the review window

Set `RUN_DATE` to today, ISO-8601. Then walk backwards one calendar day at a time, starting from the day before `RUN_DATE`, until one working day is found. A day is skipped, not collected, when either:

- It is a Saturday or Sunday. This is what makes a Monday run review Friday.
- The user's primary Google Calendar marks them off that day: an out-of-office event, or an all-day event whose title reads as time off (holiday, PTO, vacation, OOO, day off, festivo, and the like). Query the calendar for each candidate day before counting it.

The collected day becomes `REVIEW_DATES`. Record every skipped day and its reason (weekend, or the holiday event's title); the final message lists them so the user can catch a wrong skip. When it is unclear whether a calendar event means the user was off, ask the user rather than guess.

Stop walking after 14 calendar days. If no working day turns up by then, stop and tell the user.

### Step 2: Fetch the sources

Two read passes over the same window, Granola and Slack. Both run on every execution; a point can come from either.

#### Granola

List every Granola meeting on `{REVIEW_DATES}` in the user's Granola account, and fetch each one's metadata and Granola-generated notes.

#### Slack

Resolve `{USER_ID}` first: call `slack_read_user_profile` with no `user_id`, which returns the authenticated user. Every query below substitutes that ID.

For each day `D` in `{REVIEW_DATES}`, run three searches with `slack_search_public_and_private`, using `sort="timestamp"` and `channel_types="im,mpim,private_channel,public_channel"`:

| Query | Catches |
|---|---|
| `from:<@{USER_ID}> on:D` | what the user promised, sent, or decided |
| `to:<@{USER_ID}> on:D` | asks pointed straight at the user |
| `<@{USER_ID}> on:D` | mentions anywhere, including someone blocked on the user |

The angle brackets around the ID are literal Slack syntax, and `on:` is a modifier inside the query string, not a separate parameter. Leave `include_bots` at its default of false: bot notifications are noise here.

Three rules make the sweep reliable:

- **Paginate.** A page holds at most 20 results. Follow `cursor` until the results run out or three pages per query, whichever comes first. If a query hits the cap, say so in the final message; a silently truncated sweep reads as full coverage.
- **Deduplicate.** The three queries overlap by design. Key every message by channel plus timestamp and keep one copy.
- **Open threads before judging.** When a hit reads as a commitment, an ask, or a decision, open its thread with `slack_read_thread` (channel ID plus the parent timestamp) and read to the end. An ask the user already answered in-thread is closed, and a closed ask is not a point.

Record, for every kept message, its channel (name for a channel, the other person's name for a DM), its date, its author, and its permalink. Step 5 needs them.

#### Before extracting

State what the sweep found: the meeting titles and dates, and the Slack conversation count with the channels and DMs they came from. The user can then catch a missing meeting or a channel that should not be there.

If the window holds no meetings and no Slack messages, extend the window one more working day back (resolved with the same rules as Step 1, once only) and say so. If both sources are still empty, tell the user and end the run. One empty source is not grounds for extending: a day of Slack with no meetings is a normal day.

### Step 3: Extract candidate items

Walk the meeting notes and the kept Slack messages together, and build one working list of things the user must carry into today:

- Commitments the user made: things they said they would do, send, review, or decide.
- Actions others are waiting on: anything where someone is blocked until the user moves.
- Deadlines and dates agreed, nearest first.
- Decisions made that the user must communicate or execute.
- Feedback promised, in either direction, and people-sensitive threads (morale, conflicts, career asks).
- Follow-up meetings or messages the user agreed to arrange.
- Questions put to the user that no one has answered yet.

Each source needs a different kind of care:

- **Granola.** The generated notes are the reading surface; they can misattribute owners or soften wording. When a candidate's owner, deadline, or exact commitment is unclear from the notes, open that meeting's transcript and confirm it there.
- **Slack.** Messages are literal, so wording is not the risk; state is. A message is a candidate only if its thread leaves it open. Read the whole thread before keeping it, and drop anything already answered, delivered, or cancelled later in the conversation. Treat a bare emoji reaction as acknowledgement, not as an answer. Slack also carries throwaway lines ("will look", "nice") that read like commitments; keep one only when it names a deliverable, a person waiting, or a date.

Keep, for every candidate, the passage it comes from and its source (meeting title and date, or channel and date plus permalink). Step 5 needs both.

### Step 4: Rank and select the 5 points

Select up to 5 points from the candidate list, ordered from most to least important. Selection rules:

- Commitments due today, or already overdue, come first.
- Items where someone else is blocked on the user beat items only the user is waiting on.
- People-sensitive items (feedback promised, morale signals) rank above informational recaps.
- Recurrence is a strong signal: a theme raised twice outranks one raised in passing. A theme that surfaces in both a meeting and Slack is the strongest signal of all, since it survived the change of medium.
- At most one point per theme; merge overlapping candidates instead of spending two slots, and tag every source the merged point draws on. Merging across sources is expected, not exceptional: the meeting where a thing was agreed and the DM where it was chased are one point.
- When two candidates rank equally, take the one whose source has fewer points selected so far. Neither medium is inherently more important, and a day of one meeting and heavy DMs should not yield five meeting points.
- Purely informational items (FYIs, status updates with no action) fill remaining slots only.

Flag every selected point that requires the user to act (send, decide, review, message, unblock, arrange) by prefixing its topic with `[Action]`. A point built from someone else's task, or from context the user only needs to know, carries no flag.

If the window holds fewer than 5 substantive, traceable points, show only the real ones and say so. Never pad with generic reminders to reach 5.

### Step 5: Validate against the sources

Before showing the points, re-check every one:

1. Each point resolves to a real passage in the source its tag names, and the passage actually says it. For a Granola tag, that is the notes or transcript of that meeting. For a Slack tag, that is a message in that conversation on that date. Drop or rewrite any that do not.
2. Owners and deadlines confirmed only from generated notes, where the transcript was not checked and the note is ambiguous, are marked `unverified` in the point.
3. Every Slack point's thread was read to its end and is still open. Anything resolved later in the thread is dropped here, however strong it looked in Step 3.
4. Every meeting title and date in the source tags matches the Granola metadata, every channel or DM name matches what Slack returned, and `REVIEW_DATES` plus the skipped-days list match what Step 1 resolved.

Do not use remembered or estimated content. Anything that cannot be traced does not go in the list.

### Step 6: Show the memento

Show the points in the conversation using the template in `references/output-format.md`. Read that file now for the exact structure. Do not write anything to disk; the conversation is the only output.

## Important rules

1. **Preflight is a hard gate.** Step 0 runs first and confirms all three connectors, Google Calendar, Granola, and Slack, are authenticated. Do not fetch anything before it passes, and never substitute a partial sweep for a failing connector.
2. **The window is derived, never guessed.** Weekends and calendar holidays never count as working days; a Monday run reviews Friday. When a calendar event is ambiguous, ask the user.
3. **Both sources, every run.** Granola and Slack are read on every execution and ranked in one list. Neither is a fallback for the other.
4. **Do not invent content.** Every point traces to a passage in a note or transcript, or to a Slack message, from the review window. Anything untraceable is dropped in Step 5.
5. **The transcript settles doubts, the thread settles state.** Owners, deadlines, and exact commitments that the Granola notes leave unclear are confirmed in the transcript or marked `unverified`. A Slack candidate is kept only after its thread is read to the end and found still open.
6. **Slack stays user-centric.** Only messages the user sent, received, or was mentioned in. Do not sweep a channel wholesale because it looks relevant.
7. **Read-only, no artifact.** The run writes nothing to disk and never edits Granola, Slack, or the calendar. Never send, schedule, or draft a Slack message, and never write a canvas, even when a point is an unanswered question the run could obviously reply to. Meeting and message content is sensitive; it appears only in the conversation.
8. **English only.** The output is English regardless of the source language.
9. **Writing quality.** Apply the `writing-clearly` skill to every line: concrete, specific, no filler, no em dashes.

## Do not

- Do not pad the points to reach 5; write only substantive, traceable ones.
- Do not count a weekend or calendar-holiday day as a working day, and do not silently skip a day the calendar does not justify skipping.
- Do not pull meetings or messages from outside `{REVIEW_DATES}`, however relevant they look.
- Do not spend two points on one theme; merge them and tag every source.
- Do not keep a Slack candidate whose thread already answers it, and do not read a thumbs-up reaction as an answer.
- Do not turn Slack small talk into a point; a commitment needs a deliverable, a person waiting, or a date.
- Do not quote long passages; paraphrase, with a short excerpt only when the exact wording matters.
- Do not mark a commitment done unless a source says so.
- Do not post, schedule, or draft anything in Slack, and do not offer to; the run is read-only in every source.
- Do not write the points to a file, even when asked to "save" in passing; confirm first, since this skill deliberately leaves no artifact.

## Style

- Tight bullets over paragraphs.
- Lead each point with the topic, then what to do and why today.
- Use ISO-8601 dates throughout.
- Apply `writing-clearly` to every line of prose.
