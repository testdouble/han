# Scope Justification Rule (Justification, Cut List, and the Scope Gate)

## Contents

- The justification field
- The cut list
- The scope gate
- Related rules

**Owned by `han-planning`.** This file is authored here and is not a vendored copy of a shared rule. Do not overwrite it
from another plugin's `references/` folder during a re-sync sweep, and do not treat a difference between it and any
similarly-named file elsewhere as drift to correct.

Scope creep is easy to miss in a finished plan, because every unit in it reads like work somebody wanted. The three rules
here make it visible instead. Each unit says what it descends from, anything that cannot say it goes to a list the
operator sees, and the same gate runs over commitments the plan inherited rather than authored.

They live in one file because they share a destination. An unjustified unit and a scope-gated commitment both land in the
cut list.

Consumers: `plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, and `plan-work-items`. The justification field
applies to the three that produce work units or work items; `plan-a-feature` produces a specification instead and takes
the cut list only. The scope gate applies to the three that reason about commitments; see "Where the gate attaches"
below.

## The justification field

Every work unit and every work item carries a justification. It is a named field of its own, sitting beside the
references, never a line of summary prose. That keeps it out of the summary, which carries no identifier references.

A justification names exactly one of three things:

1. **The work-item language it descends from.** Quote or name the part of the recorded boundary that asks for this.
2. **The design material the operator attached.** Name the item in the boundary record's Visual Material Received
   section. Material the operator handed over sets scope the same way the work item's text does, because attaching it is
   part of the act of asking. Material you went looking for does not: a linked document, or a folder left over from an
   earlier run, is not scope evidence.
3. **The asked-for work it is a necessity of.** Name the unit or behavior that cannot work without it.

A unit that cannot fill the field is not written into the plan. It moves to the cut list with the reason.

Do not go looking for a different item that would support it. When the item in hand cannot justify a unit, report the
unit as unjustified rather than searching outward for something that does. Building a justification out of a linked or
closed item is how a run ends up confidently citing work that has nothing to do with the request.

Existence comes before packaging. Do not propose sequencing, phasing, or pull-request splits for a unit whose
justification is unrecorded.

## The cut list

The cut list is where cut work stays visible. Every entry names two things:

- **What the unit would have done**, in the same plain language an escalation uses.
- **Why it was cut**, with the citation that supports the cut.

Name the consequence, not only the mechanism. "Cut the image upload subsystem, so a card cannot carry a picture" tells
the operator what they are giving up. "Not in scope" tells them nothing they can weigh, and weighing it is the whole
point of showing them.

Present the cut list in the run's closing summary, alongside the artifact paths. Do not leave it only in a written file.
This change set deliberately closes the escalation path for scope questions, which removes the channel every operator
correction used to travel: they saw a proposal and objected. If the list lives only in a file they have no reason to
open, a wrong cut goes undetected.

The operator may reinstate any entry. Their direction is itself a valid justification, and the reinstated unit records
it as one.

### The cut list is not the deferral section

Two same-shaped lists sit near each other, and conflating them loses information.

- **The cut list** holds work the work item excludes. There is no trigger that would reopen it, because the boundary
  already settled the question.
- **The deferred section** holds work no evidence supports yet, each entry carrying the trigger that would reopen it.

An entry belongs to one list or the other, never both.

## The scope gate

The gate asks one question of every subsystem, integration, and artifact the plan touches, including everything it
inherited from an upstream document: **does the work item ask for this, or exclude it by statement or by silence?**

An inherited commitment no work item supports is cut, with the citation recorded, and it lands in the cut list. A
recorded deprecation from the boundary record's Direction of Travel section is treated the same way a stated exclusion
is treated.

An upstream specification is an artifact, not a scope authority. You may cut a specification commitment for a subsystem,
integration, or artifact the work item never asks for, citing the work item. You may not re-open behavior the work item
covers. The license reaches unrequested subsystems and nothing else.

### The floor: silence never cuts a necessity

The gate cuts subsystems, integrations, and artifacts the work item never asks for. It does **not** cut behavior
required to deliver what the work item does ask for. A short work item does not enumerate its own necessities, and you
do not read that silence as exclusion.

The two failures are not equally loud, which is why the floor matters. An over-scoped plan gets caught by the operator
asking why images are being planned. An over-cut plan ships a card with no error handling, and nobody notices until
somebody implements it.

The line to calibrate against:

- A three-sentence ticket asking for one card, with an image subsystem the ticket never mentioned, is a correct cut.
- The same ticket's silence about validation, focus behavior, error copy, tests, and accessibility on that card is not a
  cut. Those are necessities of the card it did ask for.

### Where the gate attaches

The gate attaches to the YAGNI reasoning each skill already performs. No skill gains a sweep step it does not have.

| Skill                 | Attach point                                                                 |
| --------------------- | ---------------------------------------------------------------------------- |
| `plan-implementation` | The existing YAGNI sweep step                                                |
| `plan-a-feature`      | Finding-resolution path 5a, with cut entries flowing into the synthesis step |
| `plan-a-phased-build` | Candidate evaluation, with cuts flowing to the deferred-phases list          |

In `plan-a-feature` the gate reduces to a work-item check on the skill's own commitments, because that skill drafts from
an interview rather than from an upstream artifact. It has no inherited commitments to sweep.

### A question the work item already answers is never escalated

When the work item settles a question, resolve it and move on. When the work item places the question outside scope, cut
the item and record why. Do not ask the operator to choose between options the boundary already decided between.

That inverse half is the one that bites. Without it, an out-of-scope finding still reaches the operator as a choice, and
the operator spends a turn re-deciding something their own ticket already said.

## Related rules

- [`planning-boundary-rule.md`](./planning-boundary-rule.md), for the boundary record this gate reads and the visual
  material a justification can cite.
- [`operator-escalation-rule.md`](./operator-escalation-rule.md), for the plain language a cut-list entry borrows.
- `yagni-rule.md`, for the evidence and simpler-version gates the scope gate sits beside. A skill applying both loads
  each of them directly from its `SKILL.md`.
