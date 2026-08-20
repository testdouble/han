# /code-walkthrough

Operator documentation for the `/code-walkthrough` skill in the han plugin. This document helps you decide _when_ and
_how_ to use the skill. For what the skill does internally, read the skill definition at
[`han-coding/skills/code-walkthrough/SKILL.md`](../../skills/code-walkthrough/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [Sizing](../../../docs/sizing.md)

## TL;DR

- **What it does.** Walks you through a set of code changes one step at a time in conversation, starting at the entry
  point and following the flow that changes, showing a small excerpt per step and explaining it in plain language.
- **When to use it.** You want to learn what a branch does and why, and you want to be paced through it rather than
  handed a document.
- **What you get back.** The conversation itself. The skill writes no file and changes no code.

## Key concepts

- **One step per turn.** The skill presents a single step, then stops and waits for you. It never chains steps or runs
  ahead to finish. The stopping is the point: it is the space where you ask the question that turns reading into
  understanding.
- **A question holds your place.** Ask about the step you just saw and the skill answers at the same plain-language
  level, then re-offers the same next step. The counter does not move. You can interrupt as often as you like without
  losing your position.
- **Full paths, every step.** Every step heading carries the complete repository-root-relative path
  (`han-coding/skills/code-review/SKILL.md`), never a bare filename. You can open the file in one move, and you can
  search for it later.
- **Flow order, not diff order.** The itinerary starts where control enters the changed code and follows one hop per
  step. It is not alphabetical, not the order files appear in the diff, and not grouped by layer.
- **Nothing is silently dropped.** Files off the execution path — tests, docs, index entries, config, mechanical
  renames — are named together in the closing step with one line each on why they changed.
- **Teaching, never judging.** The walkthrough raises no findings, no severities, and no recommended changes. "This is
  the part people find confusing" is navigation and is welcome; "this should have been extracted" is a review, and that
  is `/code-review`'s job.
- **Size-aware.** The skill classifies the target as small / medium / large, defaults to small, and scales how many
  `codebase-explorer` agents it dispatches to trace the flow. See [Sizing](../../../docs/sizing.md).

## When to use it

**Invoke when:**

- You are picking up a branch someone else wrote and want to learn what it does before you touch it.
- You wrote the branch a while ago and need to rebuild your own mental model of it.
- You are onboarding onto an unfamiliar flow and want to be walked from the entry point through to the end.
- You want to understand a change well enough to explain it to someone else.

**Do not invoke for:**

- **A written overview you can keep, share, or paste.** Use [`/code-overview`](./code-overview.md) instead. It produces
  one document; this skill produces a paced conversation.
- **Judging whether the code is any good.** Use [`/code-review`](./code-review.md) instead (or
  [`/post-code-review-to-pr`](../../../han-github/docs/skills/post-code-review-to-pr.md) to post a review to GitHub).
- **Diagnosing a bug or root-causing a failure.** Use [`/investigate`](./investigate.md) instead.
- **Assessing architecture, coupling, or structural risk.** Use [`/architectural-analysis`](./architectural-analysis.md)
  instead.

## How to invoke it

Run `/code-walkthrough` in Claude Code.

Give it:

1. **A target (optional).** With nothing, the skill walks the current branch's changes against the default branch. That
   is the common case. You can also name a file, a directory, a symbol, a pull request reference or URL, or a plan or
   ticket, in which case the skill walks the code from that context's perspective and orders the walk by what that
   context cares about.
2. **A size (optional).** `small`, `medium`, `large`, or `dynamic` as the first positional argument, when you want to
   override the skill's auto-classification. Size sets both the exploration roster and roughly how many steps the walk
   runs.

Example prompts:

- `/code-walkthrough`. _"Walk me through the changes on this branch, one step at a time."_
- `/code-walkthrough #82`. _"Teach me what pull request 82 does before I review it."_
- `/code-walkthrough src/billing/`. _"Show me around the billing module."_
- `/code-walkthrough large`. _"Walk me through this branch in detail; it spans several subsystems."_

Once the walk starts, you drive it. Say `next` to advance. Ask a question to stay put. Say "go deeper" to expand the
current step, name a file to jump there, or say "stop" to end the walk and be told where you left off.

## What you get back

A conversation, not a file. The skill opens with a one-line announcement naming what it is walking, the size band and
why, and how many steps lie ahead, then presents step 1 in that same turn. There is no approval gate before it starts,
because the skill is read-only and re-runnable, and a gate on a reversible operation only teaches you to approve without
reading.

Each step carries four parts:

1. **A heading** with your position in the walk and the full repository-root-relative path, plus the symbol name when
   the step targets one.
2. **A short explanation** — two to four sentences leading with the problem being solved, then what the code does about
   it, written for someone who did not do the work.
3. **A small excerpt** — a few lines up to roughly thirty, trimmed of imports and boilerplate. A diff excerpt for a
   change, so before and after are both visible; a plain fenced excerpt for existing code.
4. **A one-line handoff** naming what the next step covers, then the turn ends.

The walk closes with the off-flow changed files (each by full path, one line each on why it changed), a three-or-four
sentence recap carrying no file paths or symbol names, and one line pointing at whichever sibling skill fits what you
said you wanted the understanding for.

If the code turns out to contradict the itinerary mid-walk, the skill revises the remaining steps, says so in one line,
and carries on rather than walking a step it now knows is wrong. If one file cannot be read, it says what failed, skips
that step, and continues.

## How to get the most out of it

- **Ask the question when it lands.** The pause after each step exists for exactly this. A walkthrough you interrupt
  four times teaches more than one you click through.
- **Say "go deeper" instead of re-running.** Expanding the current step is cheaper and keeps your place.
- **Let the bare invocation carry the branch case.** On a feature branch, `/code-walkthrough` with no argument is
  already pointed at what you want.
- **Pair it with `/code-review` next.** The walkthrough teaches you how the change works; the review tells you whether
  it is any good. Understanding first, judgment second.

## Sizing

| Size                  | Typical target                                                  | Explorers | Steps |
| --------------------- | --------------------------------------------------------------- | --------- | ----- |
| **Small** _(default)_ | One file, one symbol, or a change across a few files            | 1         | 3–5   |
| **Medium**            | A directory or module, or a change across one or two subsystems | 2–3       | 5–8   |
| **Large**             | Several subsystems, or a change spanning many files across them | 3–5       | 8–12  |

Classification defaults to small and stays at the smaller band when a signal is borderline. Where the real flow runs
longer than the band allows, the skill keeps the stops where behavior actually turns and folds pass-through hops into
their neighbors. See [Sizing](../../../docs/sizing.md) for the cross-skill model.

## Cost and latency

The skill runs on the default model tier. The one expensive step is the parallel `han-core:codebase-explorer` wave in
Step 2, which traces the flow before the walk begins; everything after that is conversation. Tracing is dispatched
rather than done inline specifically because this session runs across many turns, and a context exhausted at step 2
cannot finish the walk. There is no synthesis pass, no validation roster, and no output file, so a small walkthrough is
cheap and safe to run often.

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs tree.
- [`/pairing`](../../../han-core/docs/skills/pairing.md). The skill this one is most often confused with, because both
  pace you through work a step at a time. This one explains code that already exists; `/pairing` builds work while
  pacing you through it.
- [`code-overview`](./code-overview.md). The written-document counterpart. Same understanding goal, one artifact
  instead of a paced conversation.
- [`code-review`](./code-review.md). What you run after the walkthrough, when you are ready to judge rather than learn.
- [`codebase-explorer`](../../../han-core/docs/agents/codebase-explorer.md). Traces the flow and entry points the
  itinerary is built from.
- [Sizing](../../../docs/sizing.md). The cross-skill small / medium / large model this skill classifies against.
