# /pairing

Operator documentation for the `/pairing` skill in the han plugin. This document helps you decide _when_ and _how_ to
use the skill. For what the skill does internally, read the skill definition at
[`han-core/skills/pairing/SKILL.md`](../../skills/pairing/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) ·
> [All skills](../../../docs/skills/README.md) · [All agents](../../../docs/agents/README.md) ·
> [YAGNI](../../../docs/yagni.md)

## TL;DR

- **What it does.** Builds your work in reviewable pieces and hands each one back before starting the next, so you steer
  while the work happens.
- **When to use it.** You want to collaborate on something rather than hand it off and review the result.
- **What you get back.** The work itself, plus a running record of the feedback you gave along the way.

## Key concepts

- **A concern.** One thing you asked for, with its own deliverable. A request that asks for two things holds two
  concerns, they run one after the other, and no piece spans both.
- **A piece.** One unit of work you review on its own. What counts as one depends on the kind of work, and the skill
  tells you which kind it picked for each concern before it starts.
- **The plan.** A short list of the concerns and the pieces inside each, proposed before any work begins, that you
  accept or change. It also names which pieces carry a choice that is expensive to walk back.
- **A stop.** The end of a turn. You get your position in the plan, what was built, what you can check, and what
  changed. The reasoning does not lead.
- **The pre-build ask.** For a piece the plan marked expensive to walk back, the skill asks what you expect before it
  builds. Declining is a complete answer.
- **The feedback record.** A file holding everything you said, so a correction you gave at the second stop still applies
  at the seventh. You can read it whenever you ask.
- **A backing skill.** An existing skill that does the work while this one handles the pacing. The skills that carry the
  flag are named under "Do not invoke for" below.

## When to use it

**Invoke when:**

- You want to review a build as it happens rather than at the end.
- You are working on something where a wrong turn early is expensive to unwind.
- You want to think out loud and have your remarks shape what gets built next.
- The work is not code. Design decisions and writing are first-class here.

**Do not invoke for:**

- **Being walked through code that already exists.** Use
  [`/code-walkthrough`](../../../han-coding/docs/skills/code-walkthrough.md) instead. That skill explains; this one
  builds while explaining.
- **Understanding something rather than producing it.** Use
  [`/code-overview`](../../../han-coding/docs/skills/code-overview.md) for a written overview, or
  [`/research`](../../../han-research/docs/skills/research.md) for an open question.
- **Running a skill straight through.** Invoke `tdd`, `refactor`, `design-an-api`, `iterative-plan-review`, or
  `plan-implementation` directly. Each runs to completion without pausing unless this skill is driving.

## How to invoke it

Run `/pairing` in Claude Code, or just say it in your own words.

Give it:

1. **What you want to pair on.** The clearer the subject, the better the proposed plan. "Pair with me on the export
   flow" gets a vaguer plan than "pair with me on adding retry handling to the export job."
2. **The discipline, if you have a preference.** Say "pair with me on tdd for this" and it runs the test-driven loop.
   Leave it out and the plan proposes an approach for you to accept or redirect. It never picks silently.
3. **Any context to respect.** A specification, a ticket, a prior decision. The skill reads what you point it at.

Example prompts:

- `/pairing`. _"Pair with me on refactoring the notification dispatcher."_
- `/pairing`. _"Pair with me on designing the API for bulk export."_
- `/pairing`. _"Pair with me on writing a response to this customer escalation."_
- `/pairing`. _"Pair with me on implementing the retry logic — I'd like to sketch the shape before we drive it from
  tests."_

## What you get back

The work itself, wherever it normally lands. A test-driven build produces code and tests; a design pairing produces a
design document; prose work produces the prose.

Alongside it, one file: the running feedback record. It lives under the output base directory your
[configuration](../../../docs/configuration.md) sets, or beside the work under `.han/pairing/` when you have no
configuration. Each run gets its own file, so a second run does not overwrite the first. The skill names the path in the
plan it proposes, and again when the loop ends.

The record holds each piece of feedback you gave and which piece prompted it. When the skill applies a recorded entry to
a later piece, it names which entry, so a misrecorded correction surfaces while it is still cheap to fix.

## How to get the most out of it

- **Redirect the plan before the work starts.** The plan is the cheapest thing to change, and the sort it names
  determines every boundary after it. If the kind of work looks wrong, say so at the first turn.
- **Merge the concerns back when a split is not worth a stop.** The plan names how your request was split. If two of
  them are small enough that you would rather see them together, say so and they run as one.
- **Contest the reversibility markings.** The plan names which pieces it thinks are expensive to walk back. You know
  your codebase better than it does. Adding or removing a marking at plan time costs nothing.
- **Ask for several pieces at once when you are moving fast.** "Show me the next three" is honored as asked, and the
  loop returns to its normal pace afterward without being asked. This is the middle gear between full ceremony and
  turning review off.
- **Answer the pre-build ask honestly, including with "I don't know."** Declining advances the stop exactly as a
  considered answer does. The ask exists to get an independent read, and a manufactured guess is worth less than none.
- **Read the feedback record if a later piece feels subtly wrong.** That is usually a correction recorded in a way you
  did not intend, and it is much easier to spot in the file than to reconstruct from memory.
- **Pair with `/code-review` afterward.** Reviewing as it goes catches direction; a review pass at the end catches
  what a piece-by-piece view cannot see.

## YAGNI

This skill does not gate items the way a planning skill does. It builds what you agreed to in the plan and nothing
beyond it, and the plan is yours to cut.

Two places it applies the rule to itself. It proposes the smallest set of pieces that covers the work rather than
padding the plan for symmetry, and it adds no behavior in response to a run of silent approvals, because nothing
establishes what a run of approvals means. See [YAGNI](../../../docs/yagni.md).

## Cost and latency

Runs on the session model with no dispatch fan-out of its own. The skill itself is thin: the cost is whatever the
backing skill would have cost, plus one turn per stop.

The expensive part is your attention, not tokens. A long session with many stops is the shape this is built for, and the
several-pieces-at-once gear exists so you can spend that attention unevenly. Built for tight-loop iteration, not for a
single high-signal run.

## In more detail

**How it splits a request that asks for more than one thing.** Splitting comes before anything else. Two asks joined by
"and then" are two concerns whenever they produce two things you would check separately, and each concern gets its own
pieces and its own stops. Changing code and answering a question about it are always separate, even in one sentence and
even about the same lines, because checking an edit means reading a diff and checking an answer means reading the
answer. When the split is genuinely unclear the skill splits anyway and names it in the plan, where merging the two back
costs you nothing.

**How it decides what kind of work you brought.** An ordered test per concern, first match wins. Does a flagged skill
cover this? Then it is skill-backed. Does it produce a choice that commits you to something? Decision work. Does it
produce prose someone will read? Prose work. Otherwise the plan supplies the boundaries with no rule behind them. The
order is the tie-break, so drafting a decision record sorts as decision work rather than prose work. Concerns sort
independently, so one request often yields a skill-backed concern and a prose concern side by side.

**Why the reasoning does not lead at a stop.** Controlled studies found that reading an assistant's explanation does not
reliably make a reviewer more careful, and can make them less so. An explanation reads as competence whether or not its
content holds up. What helps is lowering the cost of checking a claim yourself, so a stop hands you things to verify and
keeps the case for the work below them.

**Why the ask comes before the build.** The same research found one intervention that measurably worked: committing to
your own judgment before seeing the assistant's answer. It only works beforehand. An ask arriving once the work is on
disk collects the annoyance and none of the benefit. It fires only where a mistake is expensive to undo, because the
study that measured the benefit also measured a satisfaction cost.

**What the prose ladder does on long work.** Short writing climbs the ladder once, whole: shape, then rough draft, then
language. For longer writing, the shape is agreed for the whole artifact first, then the remaining rungs climb section
by section. Sectioning only the later rungs keeps structural feedback ahead of surface feedback, which is the ordering
the ladder exists for.

**What is not settled.** Stopping where the kind of feedback changes is well evidenced. The specific unit for each kind
is less so, and for open-ended work no source defines one at all, which is why the plan negotiates rather than applying
a rule. The test for a choice being expensive to walk back was authored for this skill rather than drawn from a source.
Treat both as provisional.

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs
  tree.
- [YAGNI](../../../docs/yagni.md). The evidence-based "You Aren't Gonna Need It" rule.
- [`collaborative-stop-rule.md`](../../references/collaborative-stop-rule.md). The shared contract this skill and its
  backing skills follow, defining what a stop presents and what returning control means.
- [`/tdd`](../../../han-coding/docs/skills/tdd.md), [`/refactor`](../../../han-coding/docs/skills/refactor.md), and
  [`/design-an-api`](../../../han-coding/docs/skills/design-an-api.md). The coding skills this one can drive.
- [`/iterative-plan-review`](../../../han-planning/docs/skills/iterative-plan-review.md) and
  [`/plan-implementation`](../../../han-planning/docs/skills/plan-implementation.md). The planning skills this one can
  drive.
- [`/code-walkthrough`](../../../han-coding/docs/skills/code-walkthrough.md). The skill this one is most often confused
  with, and the boundary between them.
- [Configuration](../../../docs/configuration.md). Where the feedback record lands, and how the output base directory is
  resolved.
