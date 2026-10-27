# /reassess-approach

Operator documentation for the `/reassess-approach` skill in the han plugin. This document helps you decide _when_ and
_how_ to use the skill. For what the skill does internally, read the skill definition at
[`han-planning/skills/reassess-approach/SKILL.md`](../../skills/reassess-approach/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [YAGNI](../../../docs/yagni.md)

## TL;DR

- **What it does.** Asks, in a fresh context, whether the approach a plan or a piece of code commits to is still the
  right one, and returns structurally different alternatives, always including "stop doing this" and "continue as is",
  with evidence and one recommendation.
- **When to use it.** When a plan or a piece of code has absorbed round after round of review findings without
  converging, and you want the approach questioned before anyone spends another round polishing it.
- **What you get back.** One options report, `approach-reassessment-{n}.md`, and a decision handed to you. The skill
  changes nothing else.

## Key concepts

- **Fresh context.** The critic that produces the options receives the artifact, the recorded findings, the reason it is
  being asked, and the project's conventions, and nothing else. It never sees the conversation that built the artifact
  or any defense of the current approach, because that context is the thing anchoring the loop.
- **Structurally different.** An option is a different mechanism, a different shape, or a smaller slice. Two candidates
  that differ only in parameters, naming, or ordering count as one, and a list of nearby variants is the failure this
  skill exists to interrupt.
- **Standing options.** "Stop doing this" and "continue as is" are always on the list, with the same fields as every
  other option, so the question stays "does this work still earn its cost" rather than "which way shall we keep going".
- **Rework as evidence.** Each option says which recorded findings it would make moot and which it leaves open, and what
  it adds or removes in owned code paths or plan items. Repeated rework on one mechanism is the case the YAGNI rule
  already names as evidence for a change.

## When to use it

**Invoke when:**

- A review loop has run its rounds and the same section or mechanism keeps drawing findings.
- You have been telling an agent "fix the findings, re-review, repeat" and the cycle is not closing.
- You suspect a hand-written mechanism (a parser, a scheduler, a cache) should be a library, a different shape, or
  nothing at all, and want that argued from the recorded findings rather than from taste.
- You are not sure the work is worth finishing and want the stop option costed alongside the alternatives.

`/iterative-plan-review` and `/plan-implementation` invoke it on their own when a medium or large run reaches its round
cap without converging, so you will also meet it as the closing question of those runs. A small run, capped at one
round, only points you here, because a single pass cannot show that the approach is the problem.

**Do not invoke for:**

- **Reviewing a plan round by round.** Use [`/iterative-plan-review`](./iterative-plan-review.md) instead; it hands off
  to this skill at its cap when it needs to.
- **Planning the restructure an accepted alternative calls for.** Use [`/plan-a-change`](./plan-a-change.md) instead.
- **Surveying options from the open web.** Use [`/research`](../../../han-research/docs/skills/research.md) instead;
  this skill argues from the artifact and its findings, not from prior art.
- **Assessing a module's architecture and stopping at findings.** Use
  [`/architectural-analysis`](../../../han-coding/docs/skills/architectural-analysis.md) instead.
- **Redirecting a loop before it reaches its cap.** Use [`/pairing`](../../../han-core/docs/skills/pairing.md), which
  stops after every round and lets you change or replace the approach by hand.

## How to invoke it

Run `/reassess-approach` in Claude Code.

Give it:

1. **The subject.** A plan file path, or a code path (a file or a directory). The sharper the subject, the sharper the
   options: "the regex parser in `lib/ingest/parser.rb`" beats "the ingest module".
2. **The findings, optional.** A path to the findings file the subject has absorbed: a review-findings file, an
   implementation iteration history, or a code-review report. When you give none, the skill looks beside the subject,
   then falls back to the findings already in the conversation.
3. **Why now, optional.** One line in your own words. "Six review rounds on the parser and the edge cases keep coming"
   tells the critic what the options have to explain.

Example prompts:

- `/reassess-approach docs/plans/ingest-pipeline/plan.md`. _"Three review rounds and section 2 keeps changing. Is the
  streaming design still the right call?"_
- `/reassess-approach lib/ingest/parser.rb docs/code-review-ingest.md`. _"We have fixed review findings on this parser
  six times. Should it be a parser library, or should we stop parsing this format at all?"_

## What you get back

One file, `approach-reassessment-{n}.md`, in the plan's `artifacts/` folder for a plan subject, or in a folder resolved
per the Han configuration for a code subject. It leads with the recommendation, then states why the question was asked,
restates what the current approach commits to and which findings it has absorbed, and lists the options.

Every option, including the two standing ones, carries the same fields: the findings it makes moot, the findings it
leaves open, what it adds and removes in owned code paths or plan items, the recorded decisions or standards it would
reopen, the evidence, and what to run next if it is chosen. A `Deferred (YAGNI)` list holds options considered and set
aside, each with its reopening trigger.

When a loop invoked the skill, the recommendation also lands in that loop's own record: an `approach` finding in
`review-findings.md` for `/iterative-plan-review`, or an `approach` tag in the claim ledger for `/plan-implementation`.
The report path sits in that entry's `Alternatives:` field.

In both cases the decision comes to you as one question, led by the consequence of staying on the current approach,
with the options as named candidates and the recommendation marked. "Continue as is" is a complete answer.

## How to get the most out of it

- **Point it at the findings, not only the artifact.** The options are argued from the recorded findings, so a findings
  file with IDs gives you options you can check line by line.
- **Say why you are asking.** A one-line reason ("the edge-case list doubled since round two") is the difference between
  options that address your stall and options that address a generic one.
- **Answer the question before running anything.** The skill names the skill to run next for each option. Running
  `/plan-a-change` or `/refactor` before you have picked is the polishing loop starting again.
- **Pair with `/pairing` when you want to steer earlier.** This skill fires at a loop's cap. If you want to redirect
  after every round instead, drive the loop with `/pairing`.

## YAGNI

The skill is a YAGNI instrument pointed at a whole approach rather than at single items. It applies the
[YAGNI rule](../../../docs/yagni.md)'s simpler-version gate to each option, measured in owned code paths or plan items,
so a library or a different shape that removes more than it adds is the simpler version. It treats repeated rework on
one mechanism as the "existing structure demonstrably impedes the change" evidence the rule names, and it keeps "stop
doing this" on every list so the evidence test is applied to the work as a whole. Options the critic considered and set
aside land in the report's `Deferred (YAGNI)` section with their reopening trigger. The skill never deletes or defers
anything in the artifact itself; it proposes, and the decision stays with you.

## Cost and latency

One `han-core:software-architect` dispatch is the whole cost and the most expensive step; the skill relaunches it at most
once, when the first return carries no structurally different alternative or lacks a standing option. There is no
fan-out. It is built for infrequent, high-signal runs at a loop's cap or by hand when a cycle stalls, not for tight-loop
use after every round.

## In more detail

The skill exists because Han's review loops can only say "this finding, this fix". A finding has no category for "the
mechanism is the problem", a stop rule reads only the latest round's counts, and every round brief frames the work as
find-and-fix inside the artifact as it stands. A plan or a piece of code that keeps drawing edge-case findings therefore
runs to the cap while being patched, and nothing ever asks whether a different tool or shape would make the whole class
of findings moot.

The repo's own research on this failure, which the literature calls premature convergence, found one mitigation with
independent support: give the question to a context that did not build the artifact. That is why this skill is a
separate dispatch with a deliberately narrow brief, rather than a step inside the loop. It is also why the result is a
decision for you rather than a rewrite. Replacing an approach is the choice that is expensive to walk back, and the
collaborative-stop rule reserves exactly that kind of choice for the person.

The two consuming loops call it at their round cap when their convergence condition still fails. The cap is the
existing deterministic boundary, so no new threshold and no new stop was introduced; the run ends where it ended before,
with a better question. Under `/pairing`, the end of the run is already a stop.

## Sources

The skill's protocols and vocabulary are grounded in three in-repo sources. Each is cited because the skill draws a
specific, named artifact from it.

### Han research: ADHD application to Han, 2026

The report names the failure mode (premature convergence: evaluating while generating and polishing the first
high-probability answer) and finds branch isolation, running the critic in a context with no shared history, to be the
mitigation with independent corroboration. The skill's fresh-context dispatch and its "pass nothing else" rule trace to
that finding. The same report's caution that LLM reframing adds little even with a human deciding is why the skill
measures its options against recorded findings rather than offering them on their own authority.

URL: [docs/research/adhd-application-to-han.md](../../../docs/research/adhd-application-to-han.md)

### Han YAGNI rule

The simpler-version gate, measured here in owned code paths or plan items, and the "refactor when the existing structure
demonstrably impedes the change" carve-out are the footing for treating repeated rework as evidence.

URL: [han-core/references/yagni-rule.md](../../../han-core/references/yagni-rule.md)

### Han collaborative-stop rule

The "expensive to walk back" test is why the skill hands the choice back rather than applying the recommendation.

URL: [han-core/references/collaborative-stop-rule.md](../../../han-core/references/collaborative-stop-rule.md)

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs
  tree.
- [YAGNI](../../../docs/yagni.md). The evidence-based "You Aren't Gonna Need It" rule. The two gates, the
  acceptable-evidence list, the named anti-patterns, and the deferral format.
- [`iterative-plan-review`](./iterative-plan-review.md). Hands off to this skill at its round cap when the plan has not
  converged.
- [`plan-implementation`](./plan-implementation.md). Hands off to this skill at its round cap instead of reporting a
  facilitation plateau.
- [`plan-a-change`](./plan-a-change.md). Where an accepted restructure goes next.
- [`software-architect`](../../../han-core/docs/agents/software-architect.md). The critic this skill dispatches, in the
  same options-before-commitment shape `/design-an-api` uses.
- [Multi-agent economics](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md).
  Why the skill dispatches one agent and no reviewer of it.
