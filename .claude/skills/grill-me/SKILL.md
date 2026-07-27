---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, mentions "grill me", or right after superpowers:writing-plans produces an implementation plan.
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

## Grounding in the plan

If a superpowers implementation plan was produced in this session (from `superpowers:writing-plans`), treat it as the source of truth and read its referenced Spec. Anchor every question in the plan's concrete decisions, not abstractions:

- **Goal and Architecture:** Does the stated approach actually deliver the goal? What does it rule out that it should not, or admit that it should not?
- **File Structure:** Are the boundaries right? Does each file carry one responsibility? What changes together but lives apart, or the reverse?
- **Tasks and ordering:** Does each task stand alone and compile? Does any task depend on a later one? Is each TDD step real, a failing test that pins the behavior, or a formality?
- **Spec coverage:** Map every spec requirement to a task and name any gap. Map every task back to the goal and name any task that serves nothing.
- **Internal consistency:** Do the types, signatures, and names defined in early tasks match their uses in later ones?

Surface the delta between the plan in my head and the plan on the page: unstated assumptions, unhandled edge cases, and internal contradictions, while they are still words instead of code.

## Recording decisions

Write each decision into the plan file as soon as it is resolved, not in a batch at the end. A grilling runs long enough that the conversation holding the answers gets compacted before implementation starts, and an implementer subagent opens with none of this context: it reads the plan file and nothing else.

Append to a `## Decisions` section in the plan produced by `superpowers:writing-plans` (`docs/superpowers/plans/<name>.md`), placed directly after `## Global Constraints` so every task inherits it. If the plan has no `## Global Constraints` header, create `## Decisions` near the top instead, right after the title. One entry per resolved question:

```markdown
### The question, phrased as the decision it settled

**Decided:** what we are doing.
**Because:** the reason, only when it is not obvious from the decision.
**Ruled out:** the alternative and what kills it, only when I rejected a recommendation or we considered a real fork.
```

Rules:

- **Append after each answer.** A decision that lives only in the conversation is lost.
- **Record what was ruled out, not just what was chosen.** Without it an implementer re-proposes the option we already killed.
- **Skip the trivia.** A question answered by reading the codebase produced a fact, not a decision. Facts belong in the task that needs them.
- **Amend in place when a later answer contradicts an earlier one.** The section is the current state of the design, not a transcript.

If no plan file exists, because the grilling is on a design or spec rather than a plan, ask once where to record and default to the document under discussion. Do not create a new file for it.
