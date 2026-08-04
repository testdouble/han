# /explanation-guidance

Operator documentation for the `/explanation-guidance` skill in the han plugin. This document helps you decide _when_ and
_how_ the skill is used. For what the skill does internally, read the skill definition at
[`han-communication/skills/explanation-guidance/SKILL.md`](../../skills/explanation-guidance/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [Readability](../../../docs/readability.md)

## TL;DR

- **What it does.** Surfaces the shared explanation standard into a calling skill's own context, from
  `han-communication`'s single canonical copy, so the caller writes its questions and stops as a concrete outcome the
  reader could observe instead of as a mechanism.
- **When it runs.** A skill invokes it by qualified name at the point it talks to a person: before an escalation, a
  confirmation turn, or a stop for a missing input. You rarely run it directly.
- **What you get back.** Nothing of its own. It hands control straight back to the caller, which resumes its own
  workflow with the standard now in context.

## Key concepts

- **It governs a turn, not a document.** The
  [explanation standard](../../references/explanation-rule.md) covers what a run says to a person while it is running.
  The readability standard covers the shape of the deliverable that run writes. Most planning skills need both, at
  different moments.
- **Concrete outcome over mechanism.** The standard's central requirement is that an explanation names something the
  reader could observe rather than describing the code that produces it. For a question shaped like data entry, that
  outcome takes four parts: a named thing, a real starting value, what the person enters, and the specific wrong result
  they would see.
- **The unintroduced-term test is checkable.** A term counts as unintroduced when it appears in neither the work item nor
  the conversation. That replaces a guess about what the reader knows with a search over what the run holds.
- **It is inline, not forked.** The skill runs in the caller's context so the content it surfaces stays available to the
  caller after it returns.
- **It carries guidance only.** There is no self-check, so a skill that sources it gains no verification step. Nothing
  observes whether the standard took effect; that is an accepted gap, recorded with the trigger that would reopen it.

## When it is used

**Invoked when:**

- A skill is about to escalate a question to the operator.
- A skill is about to open with a confirmation turn that restates a recorded boundary.
- A skill is about to stop for an input only the operator can supply.
- A skill has to explain a technical consequence to someone who will not open the code.

**Not used for:**

- **Drafting a written deliverable.** Use `han-communication:readability-guidance`, which surfaces the readability
  standard and the writing-voice profile.
- **Rewriting prose that already exists.** Use [`/edit-for-readability`](./edit-for-readability.md).
- **Deciding whether to ask at all.** The planning skills' own rules govern that. A question the work item already
  answers is cut and recorded rather than asked, and the scope rules in `han-planning` cover it.

## How it works

The skill reads the explanation rule from `han-communication`'s own plugin root so its content enters the caller's
context, then tells the caller to hold the reader in mind while writing the turn: name something they could observe, keep
paths and identifiers below the question or leave them out, and check any term against the work item and the conversation
before using it. It closes by telling the caller to return to the workflow that invoked it.

## Cost and latency

The skill reads one reference file into context and returns. Its cost is that file's content, which persists in the
caller's context for the rest of the run. A skill that escalates several times sources it once.

## Troubleshooting

- **Escalations still read as jargon.** The standard carries no self-check, so nothing catches a turn that ignored it.
  That is the documented trigger for reopening a reviewing pass over escalation prose, which was deferred as the larger
  version of this fix. Report it rather than working around it.
- **A consumer skill stops right after the guidance call.** Same residual risk the readability pairing carries: the
  standard is surfaced through same-context skill composition, and a transient infrastructure fault could in principle
  anchor a caller on the guidance output. Re-run the consumer; if it recurs, report it.

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs tree.
- [`explanation-rule.md`](../../references/explanation-rule.md). The canonical standard this skill surfaces.
- [Readability](../../../docs/readability.md). The sibling standard, governing the shape of a written deliverable.
- [`/readability-guidance`](./readability-guidance.md). The skill that surfaces that sibling standard.
- [`SKILL.md` for /explanation-guidance](../../skills/explanation-guidance/SKILL.md). The internal process definition.
