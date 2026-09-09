# /plan-a-change

Operator documentation for the `/plan-a-change` skill in the han-planning plugin. This document helps you decide _when_
and _how_ to use the skill. For what the skill does internally, read the skill definition at
[`han-planning/skills/plan-a-change/SKILL.md`](../../skills/plan-a-change/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) ·
> [All skills](../../../docs/skills/README.md) · [All agents](../../../docs/agents/README.md) ·
> [YAGNI](../../../docs/yagni.md)

## TL;DR

- **What it does.** Plans an architecture-driven change to code that already exists, naming the types, modules, and
  methods involved and recording what is true of each one after the change.
- **When to use it.** You have looked at some code and concluded the responsibilities are in the wrong places, and you
  want a plan for fixing that before anyone writes a line.
- **What you get back.** A `change-plan.md` you can build from directly, plus a decision log and a record of what the
  code does today.

## Key concepts

- **The recorded reason.** Every run records why a change is being planned before it plans anything. A reported defect
  is one possible reason; a prior analysis report, an arriving constraint, a decision already taken, friction you
  describe, and a deliberate improvement are the others. Nothing is presumed to exist.
- **The surface delta.** The section that answers "what is changing", as a record of the target state rather than as
  migration advice. Every element the change removes, adds, moves, renames, or re-scopes gets an entry, and every entry
  states what is true after the change in its own right.
- **The behavior-preservation gate.** Every delta entry is classified as behavior-preserving, behavior-changing, or
  behavior-unknown. The last two are escalated to you before they are committed.
- **Code-level names are the subject.** Unlike `/plan-a-feature`, which specifies behavior and keeps symbol names out,
  this skill is about the structure an engineer works in. Name the type.

## When to use it

**Invoke when:**

- The responsibilities between several types are wrong and you want the fix planned.
- A module has grown two jobs and you want it split, with the seam between the halves settled up front.
- A public API or library surface needs restructuring, and you need a record of what callers lose and gain.
- You just ran `/architectural-analysis` and want its findings turned into something buildable.
- A new requirement has arrived that the current structure cannot absorb, and the restructure is the prerequisite.

**Do not invoke for:**

- **Assessing an area to find out whether it has problems.** Use
  [`/architectural-analysis`](../../../han-coding/docs/skills/architectural-analysis.md), which produces findings and
  stops there. Its report is a valid input to this skill.
- **Specifying new behavior.** Use [`/plan-a-feature`](./plan-a-feature.md), then
  [`/plan-implementation`](./plan-implementation.md).
- **Finding out why something is broken.** Use [`/investigate`](../../../han-coding/docs/skills/investigate.md). Its
  report is a valid input here when the root cause turns out to be structural.
- **Designing a new interface that does not exist yet.** Use
  [`/design-an-api`](../../../han-coding/docs/skills/design-an-api.md).
- **Carrying out the change.** Use [`/refactor`](../../../han-coding/docs/skills/refactor.md) for a
  behavior-preserving unit, or [`/tdd`](../../../han-coding/docs/skills/tdd.md) to build one test-first.

## How to invoke it

Run `/plan-a-change` in Claude Code.

Give it:

1. **What needs to change, and why.** The skill will ask if you do not say. A sharp version names the area and the
   dissatisfaction: "the four types in `lib/channels/` each know about the config, and adding a fifth means touching
   all of them". A thin version is "clean up the channels".
2. **A source report, if you have one.** An `/architectural-analysis` report, an `/investigate` report, an ADR, or a
   code review. Pass the path and the skill reads it instead of re-running the analysis.
3. **A size, optionally.** `small`, `medium`, `large`, or `dynamic` as the first argument. It scales the review team and
   the round cap. The default is small.

Example prompts:

- `/plan-a-change`. _"Session, Channel, Device and Prompt all reach into the config directly. Plan the fix."_
- `/plan-a-change docs/analysis/channels/architectural-analysis-report.md`. _"Turn these findings into a change plan."_
- `/plan-a-change medium`. _"Split the exporter module — the CSV and the scheduling halves have nothing in common."_

## What you get back

The plan lands at the root of the resolved folder; the companions sit beneath it in `artifacts/`. The folder comes from
your `.han/config.md` `output-directory` setting when you have one, a folder you name, or a proposed kebab-case name
under a discovered documentation root.

- **`change-plan.md`** — the deliverable. Why the change, the target state in one paragraph, the current state, the
  target structure with its contracts pinned, the surface delta, the behavior changes gathered in one place, the
  sequenced change units, risks, YAGNI deferrals, the scope cut list, open items, and review findings.
- **`artifacts/change-decision-log.md`** — every decision as a `D-N` entry with its question, rationale, evidence,
  behavior impact, and rejected alternatives. Trivial decisions get a one-line bullet; anything settling a
  behavior-changing entry is always a full entry.
- **`artifacts/current-state-findings.md`** — what the code does today as numbered `C-N` findings with file paths and
  verbatim code, plus the project context, the gaps the search turned up, and any evidence class no agent could audit.
- **`artifacts/scope-boundary.md`** — the work item this run descends from, its stated scope, and its stated exclusions.

The cross-references run both ways. The plan cites decisions inline as `([D-6](artifacts/change-decision-log.md#...))`
and current-state claims as `([C-3](artifacts/current-state-findings.md#...))`; each decision names the delta entry it
settles and the plan sections that cite it.

Delta entries carry `S-N` identifiers, so a change unit names the entries it lands and a decision names the entry it
settles.

## How to get the most out of it

- **Say why, not just what.** The recorded reason is what the YAGNI gate tests every new abstraction against. A run with
  a sharp reason cuts proposals a run with a vague one waves through.
- **Hand it a report if you have one.** Passing an `/architectural-analysis` report skips the discovery round entirely,
  which is the most expensive part of the run.
- **Read the behavior-changes section first.** It is the part the skill will not let you skip past, and it is where a
  restructure hides the thing that breaks.
- **Argue with the cut list.** Anything the scope boundary excluded is listed with what it would have done. Your saying
  you want it back is itself a valid justification the reinstated entry records.
- **Pair with `/plan-work-items` next.** The change units are already sequenced so each leaves the codebase working, so
  they convert to independently-grabbable items cleanly. Or go straight to `/refactor` for a behavior-preserving unit.

## YAGNI

The skill is enforcing, not advisory. Three gates run at Step 8 over every part the target state introduces: the
evidence test, the simpler-version test, and the scope test.

The evidence test covers each new type, interface, abstraction layer, extension point, configuration seam, and adapter.
**A new abstraction with one implementation and no named second caller fails by default.** That is the signature failure
of this skill's domain: it is the easiest thing to justify from taste and the hardest to remove afterwards. Failures
land in `## Deferred (YAGNI)` with the trigger that would reopen them.

The simpler-version test moves the larger proposal under `Rejected alternatives:` in its decision entry when a strictly
simpler structure satisfies the same evidence. The scope test moves out-of-boundary entries to `## Cut for Scope` with
the citation. An item lands in one section or the other, never both, and never silently disappears. See
[YAGNI](../../../docs/yagni.md).

## Cost and latency

An infrequent high-signal run, not a tight loop. The two expensive steps are the Step 2 discovery round (two or three
analysts in parallel, skipped entirely when you supply a report) and the Step 7 review round, which is bounded by the
size band: small runs one round with one chosen specialist, large runs up to three rounds with four.

The architects at Step 4 run once regardless of size. Every specialist brief carries a report-length target scaled to
the area, which is what keeps a single-module change from returning a plan-sized review.

## In more detail

The skill exists because two neighbours leave a gap between them.
[`/architectural-analysis`](../../../han-coding/docs/skills/architectural-analysis.md) assesses an area and produces
findings; it explicitly stops short of a plan. [`/plan-a-feature`](./plan-a-feature.md) specifies behavior a user
observes, and its content rule keeps symbol names out on purpose. Neither answers "these responsibilities are wrong,
plan the fix", and the work that question implies — dispatching a structural analyst, a behavioral analyst and a
software architect, then reconciling what they say — is orchestration a skill should own rather than something you
assemble by hand each time.

Two design choices follow from what that gap costs in practice.

The first is that the surface delta is a target-state record rather than a migration table. A migration table is written
from the call site inward, so it covers only the elements that happen to have call sites, in only the respects a caller
notices. A responsibility moving between two internal collaborators produces no migration row at all, and vanishes from
a document built that way. Writing the delta as target state means every element carries a statement that would still be
correct and complete if every other entry were deleted, so a removal always says where the responsibility went, or that
it went away and why.

The second is that behavior preservation is a gate rather than an assumption. An architecture-driven change is planned
on the premise that moving responsibility around is safe. That premise is usually true and occasionally expensive, and
the moment it fails is exactly the moment nobody is looking — a return shape that narrows, an error type that changes,
an ordering guarantee that was incidental to the old arrangement. Classifying every entry forces the question to be
asked once per element rather than once per plan, and an entry you cannot classify is escalated rather than assumed
safe.

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs
  tree.
- [YAGNI](../../../docs/yagni.md). The evidence-based rule the Step 8 sweep applies, with the two gates, the
  acceptable-evidence list, and the deferral format.
- [`/architectural-analysis`](../../../han-coding/docs/skills/architectural-analysis.md). The upstream skill whose
  report this one consumes, and the one to reach for when you want findings rather than a plan.
- [`/plan-a-feature`](./plan-a-feature.md). The sibling for new behavior. Its content rule is the deliberate opposite of
  this skill's: it keeps symbol names out, because it specifies what a user observes.
- [`/plan-work-items`](./plan-work-items.md). The usual next step, converting the sequenced change units into
  independently-grabbable work.
- [`software-architect`](../../../han-core/docs/agents/software-architect.md). Proposes the target structure at Step 4,
  under the YAGNI and contract-pinning directives.
- [`junior-developer`](../../../han-core/docs/agents/junior-developer.md). Reframes a question in plain terms before the
  run escalates it, and asks whether the target structure is more structure than the reason justifies.
- [Progressive Disclosure](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md).
  The three-level architecture behind this skill's split between its body and its `references/` files.
