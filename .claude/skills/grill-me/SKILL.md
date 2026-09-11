---
name: grill-me
description: Interview the user in rounds about a plan or design until every decision is settled, walking the decision tree branch by branch and recording each answer. Use when user wants to stress-test a plan, get grilled on their design, mentions "grill me", or right after superpowers:writing-plans produces an implementation plan.
---

Interview me about this plan until nothing in it is still silently assumed, then stop and ask me to confirm we have reached a shared understanding. Do not start implementing when you run out of questions; running out of questions does not end the session, my confirmation does.

## The tree, the frontier, the round

Model the subject as a **decision tree**: every decision branches into the decisions that hang off it. The **frontier** is the set of decisions whose prerequisites are already settled, and it is the only thing you may ask about yet. A **round** is one frontier, asked in full.

Ask a whole round at once, never one question at a time and never everything at once. Two questions share a round only when neither depends on the other; a question that hinges on an answer still open waits for a later round. My answers settle the frontier, the frontier moves outward, and the next round asks what that unblocked. Thirteen questions should land in about three rounds.

The frontier is your judgement, not a computed graph. When an answer turns out to invalidate another question from the same round, say so and reopen that branch in the next round.

## Question format

Every question in a round arrives in the same shape, so I can answer the round by number:

```markdown
**❓ 1. The decision, titled**

The question, and what hangs on it.

➡️ Your recommended answer, on its own line.
```

Always give the recommendation. When the recommendation argues against the question as worded, say so, otherwise agreeing with you reads as answering "no".

## Facts are yours, decisions are mine

A question the environment can answer is a fact, and finding it out is your job. Read the code, or dispatch a subagent to sweep for it, and keep the round moving: only the questions downstream of a running lookup wait for it.

A question about what we want is a decision, and it is mine. Wait for it. Answering your own decisions is not running this skill.

## Grounding in the plan

If a superpowers implementation plan was produced in this session (from `superpowers:writing-plans`), treat it as the source of truth and read its referenced Spec. Anchor every question in the plan's concrete decisions, not abstractions:

- **Goal and Architecture:** Does the stated approach actually deliver the goal? What does it rule out that it should not, or admit that it should not?
- **File Structure:** Are the boundaries right? Does each file carry one responsibility? What changes together but lives apart, or the reverse?
- **Tasks and ordering:** Does each task stand alone and compile? Does any task depend on a later one? Is each TDD step real, a failing test that pins the behavior, or a formality?
- **Spec coverage:** Map every spec requirement to a task and name any gap. Map every task back to the goal and name any task that serves nothing.
- **Validation:** For each behavior the plan promises, what fails if it breaks? Name the test. A requirement nothing checks is a requirement the implementation is free to miss.
- **Internal consistency:** Do the types, signatures, and names defined in early tasks match their uses in later ones?

Surface the delta between the plan in my head and the plan on the page: unstated assumptions, unhandled edge cases, and internal contradictions, while they are still words instead of code.

## Recording decisions

Write the round's decisions into the plan file as soon as the round closes, not in a batch at the end. A grilling runs long enough that the conversation holding the answers gets compacted before implementation starts, and an implementer subagent opens with none of this context: it reads the plan file and nothing else.

Append to a `## Decisions` section in the plan produced by `superpowers:writing-plans` (`docs/superpowers/plans/<name>.md`), placed directly after `## Global Constraints` so every task inherits it. If the plan has no `## Global Constraints` header, create `## Decisions` near the top instead, right after the title. One entry per resolved question:

```markdown
### The question, phrased as the decision it settled

**Decided:** what we are doing.
**Because:** the reason, only when it is not obvious from the decision.
**Ruled out:** the alternative and what kills it, only when I rejected a recommendation or we considered a real fork.
```

Rules:

- **Append after each round.** A decision that lives only in the conversation is lost.
- **Record what was ruled out, not just what was chosen.** Without it an implementer re-proposes the option we already killed.
- **Skip the trivia.** A question you answered by reading the codebase produced a fact, not a decision. Facts belong in the task that needs them.
- **Amend in place when a later answer contradicts an earlier one.** The section is the current state of the design, not a transcript.

If no plan file exists, because the grilling is on a design or spec rather than a plan, ask once where to record and default to the document under discussion. Do not create a new file for it.

## It is working if

- A round arrives as a numbered list, each question carrying its recommendation on its own `➡️` line, and I can answer it by number.
- Nothing in a round needs another question from the same round answered first.
- Later rounds ask what the first round could not have asked.
- Facts get looked up, not asked.
- Question count stays high while round count stays low.
- It ends by asking me to confirm, not by starting work.

Technique adapted from [mattpocock/skills](https://github.com/mattpocock/skills/blob/main/docs/productivity/grilling.md).
