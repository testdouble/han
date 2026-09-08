# Collaborative Stop Rule (Handing Control Back Mid-Run)

## Contents

- Who reads this
- Detecting the flag
- What a stop presents
- Asking before building, and when
- Recording what the person says
- Acting on the answer
- Pace

This rule defines what happens when a skill running collaboratively reaches a unit boundary: how it knows to stop, what
it presents when it stops, and what it does with the answer. It exists so a stop means the same thing whichever skill
performed it.

Six places need to agree on that answer. `pairing` drives the loop, and `tdd`, `refactor`, `design-an-api`,
`iterative-plan-review`, and `plan-implementation` each stop at a boundary they already have. Without one shared
definition, each would describe stopping in its own words and a person would meet six slightly different experiences.
Every vendored copy of this file is byte-identical to the canonical `han-core/references/collaborative-stop-rule.md`.

## Who reads this

Two kinds of reader, needing different parts.

**A skill that gains the collaborative flag** reads "Detecting the flag" and "What a stop presents." Those two sections
are the whole contract for a backing skill. Nothing else here is required reading to add the flag correctly.

**The skill driving the loop** reads all of it, because it also owns the plan, the record, and the sorting of work that
has no backing skill at all.

## Detecting the flag

The collaborative flag arrives as a named argument on the invocation, never as a caller's identity. A skill supporting
it declares the argument in frontmatter and branches on its value at the boundary the skill already has.

Never make a skill test which skill invoked it. A skill that names its caller breaks when the caller is renamed, and it
cannot be driven collaboratively by anything else later. The argument form carries the same information without the
coupling.

Never let the flag change anything except what happens at an existing boundary. It adds no new boundary, skips no step,
and relaxes no gate the skill already enforces. An invocation without the flag behaves exactly as it does today, which
is what makes the flag safe to add to a skill people already rely on.

## What a stop presents

A stop hands the person something to check, not a case for the work. That ordering is the point of the whole
convention: a fluent explanation raises agreement without raising scrutiny, so leading with the reasoning defeats the
review the stop exists to get.

Every stop carries four things, in this order:

1. **Position.** Which piece this is against the plan, and what remains. A person deciding whether they have the
   attention for two more pieces cannot answer that without it.
2. **What was built or found.** The unit that just closed, named in the terms that skill already uses.
3. **What can be checked.** The specific claims the person can verify. For work that produces an artifact, these are
   properties of the artifact. For a review round, the findings themselves are the checkable claims, and the plan edits
   the round made are what changed.
4. **What changed.** Since the previous stop, not since the beginning.

The reasoning behind the choices comes last or not at all. State in one line that it is available for the asking, and
stop there BECAUSE an unannounced affordance in a conversation is the same as no affordance, while a volunteered
rationale is the thing that suppresses scrutiny.

Then end the turn. Nothing further is built until the person responds.

That last instruction is a directive, not a guarantee. Nothing in the platform enforces it. When a run does build past a
stop, the next thing it says names the overrun, states which pieces went unreviewed, and offers to walk back through
them. Never present unreviewed work as though it had been approved.

## Asking before building, and when

For a piece carrying a choice that is expensive to walk back, the ask comes **before** the build, not at the stop
afterward. Committing to your own expectation before the answer exists is the mechanism; an ask arriving once the work
is on disk collects the cost and none of the benefit.

**The test.** A choice is expensive to walk back when later pieces in the plan would have to be redone to undo it. Apply
it against the plan you already proposed, which lists the pieces, so the question is answerable rather than a matter of
taste.

Three consequences follow from that test and are part of it:

- Most plans mark one piece, sometimes two. A piece nothing else depends on is cheap to redo by definition.
- A plan that marks every piece has misapplied the test. Stop and re-derive it rather than asking at every stop, which
  is the outcome this calibration exists to avoid.
- A plan that marks nothing is the normal case for short work with independent pieces. Do not manufacture a marking to
  fill the slot.

This criterion is authored here rather than drawn from a source. The framework behind it separates reversible from
irreversible decisions and prescribes different review depth for each, but supplies no way to tell them apart. Treat the
test as provisional and revisit it once real runs show whether it marks the pieces people find expensive.

**The ask itself** names the dimension the choice turns on and stops there. Do not pose a blank question, and do not
offer candidate answers, BECAUSE named candidates anchor the guess and the point is an independent read.

**Declining is a first-class answer.** "I don't know" and "just show me" advance the piece exactly as a considered
answer does. Never re-prompt, and never require an answer before building.

**After the build, the reveal is an ordinary stop.** It does not restate the person's read, score it, or defend a
divergence from it. A stop that grades you teaches you to answer noncommittally, and a stop that argues with you leads
with the reasoning this convention keeps out of the lead.

## Recording what the person says

Write every piece of feedback into the running record before acting on it. A correction given at the second stop has to
still apply at the seventh, and mid-context material is the least reliably recalled.

The person can read the record whenever they ask. When a recorded entry shapes a later piece, name which entry it was,
so a misrecorded correction surfaces while it is still cheap to fix rather than quietly governing the rest of the
session.

## Acting on the answer

Three routes, by what the feedback touches.

**The piece in hand.** Fix it within that piece and show it again. The re-show names the correction applied and what it
touched before restating the piece. It is a stop like any other, so end the turn and wait rather than moving on.

**What comes next.** Carry it into the next piece.

**Work outside the piece in hand.** Say so before acting: name that the feedback looks like it reaches past this piece,
and what it would change about the plan. Then offer three ways out, never two. The person accepts a revised plan,
changes it, or declines the reopening entirely, in which case the feedback is recorded as scoped to later work and the
agreed plan continues. The third exit is what keeps an offhand remark from silently replacing a plan the person agreed
to.

## Pace

Honor a request for more than one piece as asked, then return to the normal pace at the following stop without being
asked to. Without that middle gear the only choices are full ceremony on every piece or no review at all, and the second
is what the loop exists to prevent.

Add no pressure to comment. A run of silent approvals is a valid response and means nothing in particular; do not
volunteer anything in reply to it.

Ending the loop is the person's call. Nothing here computes a stopping point, because work being built produces no
countable signal to compute over.
