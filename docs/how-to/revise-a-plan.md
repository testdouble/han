# How To: Revise a Plan After the Build Has Started

A walkthrough of how to change a plan once work is already underway, when a later work item needs refining or a decision you made earlier turns out to be wrong, using han's planning skills to update the documents in place rather than rewriting them.

> See also: [How-to index](./README.md) · [Plan a feature, end to end](./plan-a-feature.md) · [Skills](../skills/README.md)

## Before you begin

- You have already planned the work and have the artifacts on disk. A `feature-specification.md`, a `feature-implementation-plan.md`, a `work-items.md`, or some subset of those, produced by the planning skills.
- You have started building. Some work items are done, and now something needs to change: a later item needs refining, or a decision baked into the spec no longer holds.
- You know roughly what needs to change, even if you do not yet know which skill to reach for. That last part is what this guide is for.

If you have not planned the work yet, this is the wrong guide. Start with [Plan a feature, end to end](./plan-a-feature.md) instead.

## What you'll end up with

- The one planning document where the change belongs, revised, with its decision log and team findings carried forward.
- Any downstream documents re-generated from the changed one, so the spec, the implementation plan, and the work items stay consistent with each other.
- Confidence that the change did not leave a contradiction buried three documents deep, because you ran a review pass over what you touched.

## Go back to the planning steps

When a plan needs to change mid-build, the instinct is to edit the code and move on. Go back to the planning steps instead. It sounds counter-intuitive, so here is the short version of why: code is now cheap, and that means plans are more important than ever. When generating the code is the easy part, the plan is the thing that holds the work together, and a plan that has drifted from what you are actually building is worse than no plan at all.

If you want the longer argument, [The Disposable Blueprint](https://jdforsythe.github.io/10-principles/principles/disposable-blueprint/) makes the case well, and the whole "10 Principles" series around it is worth reading.

The good news is that going back does not mean starting over. You re-run a skill against the document you already have, tell it what changed, and it produces the updated version in the same folder, carrying the decision log and team findings forward. The rest of this guide is how to do that.

## The happy path

The workflow is grouped into three phases. Phase 1 is the only decision you have to make: figure out which document the change belongs in. Phase 2 updates that document. Phase 3 propagates the change to the documents downstream of it.

### Phase 1: Decide where the change belongs

The rule of thumb: change the document closest to the work item that still gets the change right. Do not reopen the spec for something that is really an implementation detail, and do not patch a work item when the behavior underneath it actually moved.

If you planned this a while ago and need a reminder of which document is which: the **feature specification** is the *what* (the behavior), the **implementation plan** is the *how* (the build), and the **work items** are the *chunks* (the grabbable pieces). Match the change to the level it actually lives at, working top-down from behavior toward the work item.

1. **If the behavior of the feature itself needs to change, go back to [`/plan-a-feature`](../skills/han-planning/plan-a-feature.md).** This is the right choice when the change is about *what* the feature does, not how it is built. A new state, a different trigger, a flow you got wrong, a constraint that moved. The specification is the source of truth for behavior, so that is where a behavioral change starts.

2. **If the specified behavior is still correct but the implementation outline needs adjusting, go back to [`/plan-implementation`](../skills/han-planning/plan-implementation.md).** The feature still does what the spec says; the way you planned to build it has changed. A different boundary, a step that needs resequencing, a technical approach that did not survive contact with the code.

3. **If the change is a small detail inside one work item, and the higher-level implementation and behavioral plans are still good, edit `work-items.md` directly.** There is no dedicated skill for this, and you do not need one. Point Claude at the work-items file and describe the change:

    > `update {work items file}: {what you want changed in the item}`

    The file is full of cross-references and back-links to the spec and the implementation plan, and those exist for exactly this reason: they give Claude enough context to understand what the item is for and how it fits without you having to re-explain the whole plan.

### Phase 2: Update that document

1. **Re-run the skill you picked against the existing document.** You do not need to rewrite a plan from scratch. Name the file you want to update and describe the change, and the skill revises the document rather than producing an unrelated one. For a behavioral change, that is `/plan-a-feature`; for an implementation change, `/plan-implementation`. (For the small-work-item case from Phase 1 option 3, you already made the change there, so there is nothing more to do in this phase.)

    > `update {the file you are revising}: {what changed}`

    The decision log and team findings carry forward, so the `D#` and `F#` IDs stay stable and prior references keep pointing where they should.

2. **Expect to be asked how to apply the change.** The skills do not blindly clobber your existing work. `/plan-implementation` asks whether to overwrite the existing plan or append iteration notes before it proceeds, and `/plan-work-items` (which you will reach in Phase 3) writes a date-suffixed file next to the original rather than overwriting it, then tells you which file it wrote. Answer the prompt, and note the filename if a new one was created so you point the next step at the right file.

3. **Read what changed.** Look at the revised document and confirm the change landed the way you meant it. This is also the moment to notice anything the change knocked loose elsewhere in the same document, which Phase 3 will help you catch across documents.

### Phase 3: Re-review and propagate the change

1. **Review the updated document for internal consistency.** A change in one place tends to leave a contradiction somewhere else: a step that now references a flow you removed, an assumption that no longer holds. Run [`/iterative-plan-review`](../skills/han-planning/iterative-plan-review.md) over the document you touched. It is built to find inconsistencies, hidden assumptions, and gaps, which is exactly what a mid-build edit tends to introduce.

    > `/iterative-plan-review {the file you updated}`

2. **Re-generate the documents downstream of the one you changed.** A planning document feeds the next one: the spec feeds the implementation plan, and the implementation plan feeds the work items. When you change a document, every document downstream of it needs to be brought back into line. Work down the chain from wherever you made the change.

    If you changed the feature specification, update the implementation plan from it:

    > `/plan-implementation update {implementation plan doc} with the changes we made to {feature specification file}`

    Then, with the implementation plan updated, bring the work items back into line:

    > `/plan-work-items update {work items file} with the changes made to {implementation plan file}`

    `/plan-work-items` writes the refreshed list to a date-suffixed file next to the original rather than overwriting it, and tells you which file it wrote, so reconcile the two and keep the one you want.

    If you only changed the implementation plan, you skip the first prompt and start from the second. If you only edited a single work item, there is nothing downstream of it, so there is nothing to propagate.

## Variations

- **The change is bigger than you thought.** Sometimes a refinement to a work item turns out to be a behavioral change wearing a disguise. If editing the work-items file makes you reach back into the spec to explain what you are doing, that is the signal: stop, go up a level, and re-run `/plan-a-feature` for that slice instead. Then propagate back down through Phase 3.

- **The feature was built in phases.** If you used [`/plan-a-phased-build`](../skills/han-planning/plan-a-phased-build.md) and have per-phase specs and plans, the same decision tree applies, scoped to the phase you are changing. Update the document inside that phase's folder, then propagate downstream within the phase.

- **Tracking progress in the work-items file.** If you would rather track which items are done inside `work-items.md` than in GitHub Issues or Jira, you can. Point Claude at the file and ask it to add a status to each item. The cross-references that make the file easy to revise also make it a reasonable place to keep a running status as you build.

## What you should expect at each step

- **Going back is normal, not a failure.** Revising a plan mid-build is the planning loop working as intended, not a sign you planned badly the first time. Plans are meant to be updated as you learn.
- **The skills protect your existing work.** They revise the document you point them at rather than silently clobbering it: `/plan-implementation` asks whether to overwrite or append, and `/plan-work-items` writes a date-suffixed file beside the original. Either way, the `D#` and `F#` IDs carry forward so cross-references stay stable.
- **Review is expected to find things.** `/iterative-plan-review` over a freshly changed document usually surfaces a few findings. That is the review catching the contradictions the change introduced, which is the whole point of running it.
- **Propagation is one-directional.** Changes flow down the chain (spec to implementation plan to work items), never up. You re-run the downstream steps, in order, from wherever the change started.

## Where to go next

- [Plan a feature, end to end](./plan-a-feature.md) is the guide for the full loop these documents came from, if you want to see how they fit together the first time through.
- [`/iterative-plan-review`](../skills/han-planning/iterative-plan-review.md) is worth reading on its own, since it is the skill that keeps a revised plan honest.
- The planning skill long-form docs ([plan-a-feature](../skills/han-planning/plan-a-feature.md), [plan-implementation](../skills/han-planning/plan-implementation.md), [plan-work-items](../skills/han-planning/plan-work-items.md)) cover what each step does when you run it to update an existing document, not only when you run it from scratch.
