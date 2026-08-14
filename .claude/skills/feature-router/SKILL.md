---
name: feature-router
description: Route a start-feature task to the lightest safe path within the feature pipeline. Invoked by start-feature's Route stage.
---

# Feature Router

Entry gate for `start-feature`. Return one route recommendation. Editing or implementation start only after explicit confirmation.

## Inspect proportionally

Read only enough repository context to route accurately:

- Applicable instruction files.
- The relevant implementation and tests.
- The current git diff and nearby patterns.
- The ticket, specification, or task description supplied by the user.

Find facts in the repository instead of asking for them. Do not perform a broad exploration for an obviously localized task.

Complete this step when all applicable sources above have been checked and any unavailable source is noted.

## Classify

Evaluate:

- **Ambiguity:** Are behavior, scope, and acceptance criteria settled?
- **Scope:** Is the work tiny, contained, or cross-cutting?
- **Risk:** Consider security, authentication, payments, persistent data, migrations, public contracts, concurrency, infrastructure, compatibility, and irreversible effects.

File count is evidence, not a rule. A one-line migration can be high-risk; a broad mechanical rename can be low-risk.

Complete this step when ambiguity, scope, and risk each have an evidence-based assessment.

## Choose one route

### Quick Change

Choose for clear, localized, low-risk work normally confined to one or two files.

After confirmation: make the smallest correct change, adding tests only if the change is non-trivial, following the commit discipline and domain-specific rules from `start-feature`'s Implement stage. Stop there. Do not run your own verification or review; `start-feature`'s Verify and Review stages do that next.

### Standard Implementation

Choose for clear, contained work with low or moderate risk and no unresolved architecture decision.

The routing response is the implementation preview. After confirmation: follow that preview, add meaningful tests, and follow the commit discipline and domain-specific rules from `start-feature`'s Implement stage. Stop there. Do not run your own verification, self-review, or independent review; `start-feature`'s Verify and Review stages do that next.

### Needs Grill/Plan

Choose when scope is large, risk is high, the change crosses subsystems, important product or design decisions belong to the user, or it changes architecture, persistent data, public contracts, security boundaries, or other difficult-to-reverse behavior.

Do not implement anything. Hand off to `start-feature`'s existing Brainstorm stage, which continues through Plan, Grill, and Evaluate.

Complete the routing decision when exactly one route is selected.

## Present the recommendation

Use this compact structure:

```markdown
**Route:** <one route>
**Reason:** <why this is the lightest safe route>
**Scope:** <likely files, symbols, or subsystems>
**Rules:** <applicable repository and personal conventions>
**Tests:** <new behavior to cover, or None>
**Risks and uncertainties:** <material items, or None>

Confirm this route, or tell me which of Quick Change, Standard Implementation, or Needs Grill/Plan you prefer instead.
```

For Quick Change, keep each field to one line. For Standard Implementation, include enough detail to catch scope errors, duplicate tests, and convention mismatches before editing. For Needs Grill/Plan, describe why the lightweight path is unsafe rather than attempting a plan here.

Stop after requesting confirmation. The step is complete when the response contains the recommendation and confirmation request, with no edit or implementation started. If the user selects another route, follow their choice.
