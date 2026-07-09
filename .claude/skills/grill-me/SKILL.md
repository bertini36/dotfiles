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
