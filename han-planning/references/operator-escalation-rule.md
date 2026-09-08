# Operator Escalation Rule (One Question at a Time)

## Contents

- One question per turn
- Lead with the consequence, in plain language
- The opening confirmation turn is not an escalation
- The single stop
- The escalation register
- Related rules

**Owned by `han-planning`.** This file is authored here and is not a vendored copy of a shared rule. Do not overwrite it
from another plugin's `references/` folder during a re-sync sweep, and do not treat a difference between it and any
similarly-named file elsewhere as drift to correct.

An escalation is a question that survived everything else: you checked the evidence, you reframed the finding, the work
item does not answer it, and you still need the operator's judgment. This file says what that question looks like when it
reaches them.

The rules here govern escalations only. They do not govern the opening confirmation turn, and they do not replace the
habit of grouping findings by the decision they affect, which stays as an ordering.

Consumers: `plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, and `plan-work-items`.

## One question per turn

Ask one question. Wait for the answer. Then ask the next.

State how many questions are pending on the first one, so the operator knows the queue depth they are agreeing to.
Present more than one question in a turn only when the operator asks you to.

Four questions in one turn is the shape that gets rejected outright, and it does not become acceptable by being
well-organized.

## Lead with the consequence, in plain language

Open with the consequence a person who will never read the code would describe. Not the mechanism, not the file, not the
finding's own framing.

Then give named candidate answers, so the operator picks rather than composes.

Then, below the question, put the technical references: paths, identifiers, line numbers, symbol names. Or leave them
out. They never lead.

A worked contrast, on the same question:

```markdown
<!-- Do not write this -->
In `app/models/entry.rb:142`, `validate_amount` runs before the currency coercion in
`EntryForm#normalize`, so the guard sees a String. Should we (a) move the coercion, (b) relax the
validator, or (c) add a second guard?

<!-- Write this -->
Someone types "12.50" into the amount box on a new entry and saves. Right now they get an error saying
the amount is not a number, even though it is. Two ways to fix it:

- Accept what they typed and convert it before checking it. Nothing else changes.
- Leave the check alone and reject anything that is not already a number, so people have to type "1250".

I would take the first one. One question, and it is the only one pending.

Technical detail if you want it: `app/models/entry.rb:142`, `validate_amount` runs ahead of the
coercion in `EntryForm#normalize`.
```

The second version names a thing, a real starting value, what the person does, and the specific wrong result they would
see. That four-part shape is what makes a data-entry question answerable. Where a question has no data entry and no wrong
result, the general property still holds: give a concrete outcome the operator could observe, in words from their own
domain, instead of describing a mechanism.

Never invent shorthand for a concept the operator has not been given. A term counts as unintroduced when it appears in
neither the work item nor this conversation. When you reach for one, you have found the place where a concrete observable
outcome goes instead.

For the fuller treatment of explaining technical work to a reader who will not implement it, invoke
`han-communication:explanation-guidance` before you write the turn.

## The opening confirmation turn is not an escalation

The confirmation turn restates the recorded boundary in the operator's own terms, names any visual material you kept,
and asks the direction-of-travel question. It is the one turn that carries more than one ask, and the one-question rule
does not apply to it.

Ask the direction-of-travel question with its subjects named from the work item you have already read. "Is the entry card
being replaced or deprecated?" is answerable. "Is anything here being deprecated?" asks the operator to recall something
with no cue, and gets a shrug.

## The single stop

Stop exactly once in a run, and only when a missing input is something **only the operator can supply** and its absence
degrades the deliverable. The test: does the input exist outside the codebase, and can the operator hand it over right
now?

Gather every missing input meeting that test and cover them all in the one stop. A second such input joins the stop
rather than causing another one.

The stop is an escalation put as a single question, so every rule above governs it. It names:

1. What is missing.
2. What the delivered artifact will be missing without it, in plain language.
3. The action that would supply it.
4. An offer to continue anyway.

Naming the cost without naming the supply action offers a choice where one branch has no move. And "the work items will
lack design references" satisfies a loose reading of "name the cost" while telling the operator nothing they can weigh.
Say what the artifact will be missing, the way you would say it to the person who has to live with it.

Everything else stays autonomous. A decision with a reasonable default is made, stated, and passed. An input nobody can
supply right now is recorded as a gap, and produces no question at all.

## The escalation register

Keep a register of what you escalated and what came back. Each entry records the question as it was asked, the answer,
and where the answer landed in the artifact.

Where it lives depends on whether the skill has an escalation step to hang it on:

| Skill                 | Where the register lives                                       |
| --------------------- | -------------------------------------------------------------- |
| `plan-a-feature`      | A register of its own, in the escalation step                  |
| `plan-implementation` | A register of its own, in the escalation step                  |
| `plan-a-phased-build` | Attached to the single stop; this skill has no escalation step |
| `plan-work-items`     | Attached to the single stop; this skill has no escalation step |

Do not invent an escalation pass in a skill that has none simply to have somewhere to put the register.

## Related rules

- [`planning-boundary-rule.md`](./planning-boundary-rule.md), for the boundary the confirmation turn restates and the
  visual material the single stop asks for.
- [`scope-justification-rule.md`](./scope-justification-rule.md), for why a scope question is cut and recorded rather
  than escalated.
