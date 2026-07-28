---
name: editing-skill
description: "Use when editing a skill or an agent."
allowed-tools: Read, Write, Glob, Grep
---

# What to know when editing a skill

Write efficiently:

1. Make small, surgical edits.
2. Keep prose ters and on-point.
3. Do not over-elaborate what a capable reader can infer themselves.
4. Do not repeat yourself, espetially around references. Keep prose DRY.
6. Do not fill negative space. If you delete or move something, don't leave narration that "something was there,
   now deleted/moved".
7. You're writing for an agent that will execute the skill. Notes about design motivation, implementation
   history, etc. belong in documentation or commit messages, not in the skill.
8. After you finish editing, read the final result back an do a self-review.

## Self-review, what to look for

Search for, and eliminate ruthlessly:

- **Re-explaining a rule stated earlier** — a step restates a constraint the preceding sentence or step
  already set, adding nothing.
- **Duplication of a linked reference** — the body re-states a rule a `references/` file already fully
  specifies, surfacing nothing the linked file omits.
- **Restatement of the obvious** — a self-evident consequence a competent reader already infers.
- **Filler transitions** — "Now let's move on," "With that done, we can proceed" — connective tissue with
  no instructional content.
- **Back-referential meta-commentary** — "as mentioned above," "as we discussed in Step 2," when the
  pointer adds no instruction the reader needs to act on.
- **Audience-mismatched reference** — prose that orients a reader other than the one executing it: a
  dispatched sub-agent's brief describing the orchestrator's own logic, a comparison to a sibling skill, or design
  rationale that belongs in the design docs.
- **Negative-space filling** — a sentence narrating what a step does _not_ do or what moved elsewhere:
  "this step never verifies X — that happens in step Y." Nothing in the step raised X, so the disclaimer answers a
  question no one asked; delete it.

Use the reader-reaction test: if a sentence makes a capable reader think "you just said that," "well, duh,"
"I've never seen that and don't need it," or "nothing raised that," it is bloat and cutting it loses no instruction.
