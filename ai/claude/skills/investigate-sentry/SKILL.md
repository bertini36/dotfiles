---
name: investigate-sentry
description: Investigate a Sentry exception down to root cause and propose a fix. Use whenever the user pastes a Sentry issue URL or short ID (e.g. https://org.sentry.io/issues/123456 or PROJECT-1AB2), mentions a Sentry issue, asks "what is causing this exception", or wants a production error diagnosed. Also use when the user asks to "investigate", "debug", or "root-cause" an error that lives in Sentry, even if they don't say the word Sentry.
---

# Investigate Sentry Exception

Diagnose a production exception from Sentry: pull the full event context, trace it through the local codebase, identify the root cause, and propose a fix. The diagnosis is the deliverable. Only implement the fix if the user accepts the offer in Step 8, and reproduce the exception with a failing test before changing any code.

## Tools

Use the Sentry MCP tools (`get_sentry_resource`, `search_events`, `search_issues`, `analyze_issue_with_seer`, `find_organizations`). If they appear as deferred tools, load them with ToolSearch first. If no Sentry MCP is connected, stop and tell the user to connect it; do not fall back to guessing.

Use the Datadog MCP tools (`get_datadog_trace`, `search_datadog_logs`, `search_datadog_spans`) to pull the request behind the exception (Step 3). Per the Datadog MCP instructions, load the relevant skill (`datadog/traces` or `datadog/logs`) before querying. The Datadog step is enrichment, not a hard requirement: if no Datadog MCP is connected, skip it rather than stopping.

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

## Step 3: Correlate the request in Datadog

Sentry shows the exception; Datadog shows the request that produced it. The runtime context Sentry omits, full request payload and response, surrounding log lines, downstream service and database calls, and latency, often decides whether the cause is bad data or bad code. Use it whenever the Datadog MCP is connected.

Correlate using the identifiers captured in Step 1:

1. **Trace first.** If the Sentry event carries a `trace_id`, fetch the full trace with `get_datadog_trace`. The span tree shows the endpoint, the upstream caller, every downstream call, and where the error surfaced.
2. **Otherwise search logs.** Call `search_datadog_logs` scoped to the service, environment, and a tight window around the event timestamp, filtered by whatever identifies the request: endpoint, user id, request id, or release. Read the matching request log and the lines immediately before it.
3. **Inspect the failing operation** with `search_datadog_spans` when you need DB queries, status codes, or timings the logs do not carry.

Capture the real request: input parameters, headers, payload, the offending values, and the sequence of calls. These feed the codebase trace and the data-versus-code classification, and they are the exact input you replay in the reproduction test. If no request can be matched, say so; do not invent one.

## Step 4: Trace through the codebase

This is the core of the investigation. The stack trace names files and lines; read them.

1. Map stack frames to local files. Frames from your code matter most; frames from vendored libraries usually just show the call path.
2. Read the failing function and its callers until you can explain how the bad state arrived there, not just where it exploded. The frame that raised is rarely the frame that is wrong.
3. Use breadcrumbs and event tags to reconstruct the request: what endpoint, what input, what user action preceded the error.
4. Check git history of the suspect files around the first-seen date (`git log --since`/`git log -p <file>`). A regression that started with a release almost always maps to a commit in that release.

If the repository for the failing service is not the current working directory, ask the user where it lives before guessing.

## Step 5: Classify - data problem or code defect

A crash site shows a symptom; the cause is either a code defect or bad data, and the fix differs completely. Before proposing anything, trace the offending value back to its origin and decide:

- **Code defect**: the code mishandles a state it should support. Fix the logic.
- **Data problem**: the value violates an invariant the system assumes (corrupt row, broken migration, bad upstream payload, manual edit). This is not a code bug, and the code is not the thing to change. Expose the data problem to the user: the offending value, where it came from, how many records share the bad shape, and when it appeared. The remedy is to correct the data.
- **Both**: bad data exists AND the code genuinely should reject it at its entry point. Surface the data problem first; raise the code hardening separately, as described below.

When you suspect a data problem, do not propose any code change as the first response, neither a guard clause at the crash site nor validation at the boundary. Expose the data problem and its evidence, then let the user decide whether to correct the data, harden the boundary, or both. A guard clause at the crash site is never the fix: it silences the symptom and lets the bad data flow downstream. Boundary validation, a DB constraint, or a schema check is a reasonable follow-up only after the user has seen the data problem and asked to prevent recurrence; it is never the opening move.

For suspected data problems, gather evidence: query the event payload for the offending IDs, check how many records share the bad shape, and find when the data went bad (often matches a deploy or migration date).

## Step 6: If the trace is not enough, grill the user

When the stack trace and code reading leave the root cause ambiguous, the user usually holds the missing context: recent deploys, known data quirks, business rules not visible in code. Invoke the `grill-me` skill and interview them until the picture is complete. Useful angles:

- What changed around the first-seen date (deploys, migrations, config, third-party APIs)?
- Is the failing input expected to exist? Who or what produces it?
- Are there known-bad records, tenants, or legacy data in this area?
- What is the correct behavior for this input: process it, reject it, or can it not exist?

Only after grilling, if the cause is still unclear, call `analyze_issue_with_seer`. Treat its output as a hypothesis to verify against the code, not as a verdict. Do not call Seer as a reflex on every issue; it takes minutes and is unnecessary when the code or the user already explains the failure.

## Step 7: Report

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
<for a code defect: the concrete change, with a code snippet of the relevant diff.
For a data problem: lead with the data correction (which records, what value); do NOT put a
code change here. Note any boundary hardening separately as an optional follow-up the user
can choose, never bundled as the fix. Mention alternatives briefly if they exist>

### Open questions
<anything unverifiable from here: missing repo access, ambiguous data. Omit section if none>
```

Confidence matters: if the root cause is a hypothesis rather than a certainty, say so explicitly in the Root cause section and explain what would confirm it.

## Step 8: Offer to act on the diagnosis

The diagnosis is the deliverable. After delivering the report, ask the user whether they want you to act on it. Stop here unless they accept. Then follow the path that matches the classification.

### Code defect: reproduce, then fix

1. **Write a failing test first.** Before touching the implementation, write a test that triggers the exact exception from the diagnosis: same input, same code path, same error type. Replay the real request captured in Step 3 as the input where available. Run it and confirm it fails with that exception. A reproduction you cannot trigger means the root cause is still a hypothesis, not a verified cause; return to Step 4 instead of guessing at a fix.
2. **Implement the fix** from the report's Proposed fix section.
3. **Confirm the test now passes** and that no other tests regress.

Follow superpowers:test-driven-development for the RED-GREEN discipline.

### Data problem: correct the data, then verify

The action is to correct the affected records, not to change code; never offer a crash-site guard clause. Apply the data correction from the report, then verify by re-querying that no records still violate the invariant. Harden the boundary (validation, a DB constraint, a schema check) only if the user explicitly asks; that hardening is itself a code change, so reproduce it with a failing test first as above, asserting the boundary now rejects the bad value.
