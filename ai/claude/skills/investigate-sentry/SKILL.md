---
name: investigate-sentry
description: Investigate a Sentry exception down to root cause and propose a fix. Use whenever the user pastes a Sentry issue URL or short ID (e.g. https://org.sentry.io/issues/123456 or PROJECT-1AB2), mentions a Sentry issue, asks "what is causing this exception", or wants a production error diagnosed. Also use when the user asks to "investigate", "debug", or "root-cause" an error that lives in Sentry, even if they don't say the word Sentry.
---

# Investigate Sentry Exception

Diagnose a production exception from Sentry: pull the full event context, trace it through the local codebase, identify the root cause, and propose a fix. Do not implement the fix; the deliverable is the diagnosis.

## Tools

Use the Sentry MCP tools (`get_sentry_resource`, `search_events`, `search_issues`, `analyze_issue_with_seer`, `find_organizations`). If they appear as deferred tools, load them with ToolSearch first. If no Sentry MCP is connected, stop and tell the user to connect it; do not fall back to guessing.

## Step 1: Fetch the issue

The user gives a Sentry URL or short ID.

- URL: pass it directly to `get_sentry_resource(url=...)`; the type is auto-detected.
- Short ID (e.g. `BACKEND-4K2`): call `get_sentry_resource(resourceType='issue', organizationSlug=..., resourceId=...)`. If the org slug is unknown, get it with `find_organizations` first.

From the response, capture: exception type and message, full stack trace, breadcrumbs, tags (environment, release, browser/runtime), first seen, last seen, event count, user count, and suspect commit if present.

## Step 2: Quantify impact

One `search_events` call to understand scope, since the issue summary alone can hide trends:

- Is it growing, stable, or decaying? (counts over time)
- Concentrated in one release, environment, or user segment? (group by `release`, `environment`)

Skip this step if the issue page already answers these questions.

## Step 3: Trace through the codebase

This is the core of the investigation. The stack trace names files and lines; read them.

1. Map stack frames to local files. Frames from your code matter most; frames from vendored libraries usually just show the call path.
2. Read the failing function and its callers until you can explain how the bad state arrived there, not just where it exploded. The frame that raised is rarely the frame that is wrong.
3. Use breadcrumbs and event tags to reconstruct the request: what endpoint, what input, what user action preceded the error.
4. Check git history of the suspect files around the first-seen date (`git log --since`/`git log -p <file>`). A regression that started with a release almost always maps to a commit in that release.

If the repository for the failing service is not the current working directory, ask the user where it lives before guessing.

## Step 4: Classify - data problem or code defect

A crash site shows a symptom; the cause is either a code defect or bad data, and the fix differs completely. Before proposing anything, trace the offending value back to its origin and decide:

- **Code defect**: the code mishandles a state it should support. Fix the logic.
- **Data problem**: the value violates an invariant the system assumes (corrupt row, broken migration, bad upstream payload, manual edit). The fix is to correct the data and enforce the invariant where the data enters the system (validation at the boundary, DB constraint, schema check), not where it crashed.
- **Both**: bad data exists AND the code should have rejected it earlier. Propose both halves.

Never propose a guard clause at the crash site as the fix. Wrapping the failing line in `if x is not None` silences the symptom and lets the broken data or logic flow further downstream. A guard is only acceptable at a system boundary where rejecting the input is the correct behavior.

For suspected data problems, gather evidence: query the event payload for the offending IDs, check how many records share the bad shape, and find when the data went bad (often matches a deploy or migration date).

## Step 5: If the trace is not enough, grill the user

When the stack trace and code reading leave the root cause ambiguous, the user usually holds the missing context: recent deploys, known data quirks, business rules not visible in code. Invoke the `grill-me` skill and interview them until the picture is complete. Useful angles:

- What changed around the first-seen date (deploys, migrations, config, third-party APIs)?
- Is the failing input expected to exist? Who or what produces it?
- Are there known-bad records, tenants, or legacy data in this area?
- What is the correct behavior for this input: process it, reject it, or can it not exist?

Only after grilling, if the cause is still unclear, call `analyze_issue_with_seer`. Treat its output as a hypothesis to verify against the code, not as a verdict. Do not call Seer as a reflex on every issue; it takes minutes and is unnecessary when the code or the user already explains the failure.

## Step 6: Report

ALWAYS use this structure:

```markdown
## Diagnosis: <exception type> in <component>

**Issue**: <short ID, linked to Sentry>
**Impact**: <events> events, <users> users, <environments>, first seen <date>, trend <growing/stable/decaying>
**Classification**: code defect | data problem | both

### Root cause
<2-5 sentences: the chain from trigger to crash, with file:line references.
For data problems, include where the bad data originated and how many records are affected>

### Evidence
<bullet list: stack frames, breadcrumbs, git commits, data queries, or user answers that support the root cause>

### Proposed fix
<the concrete change, with a code snippet of the relevant diff. For data problems: the data
correction AND the boundary enforcement. Mention alternatives briefly if they exist>

### Open questions
<anything unverifiable from here: missing repo access, ambiguous data. Omit section if none>
```

Confidence matters: if the root cause is a hypothesis rather than a certainty, say so explicitly in the Root cause section and explain what would confirm it.
