# /plan-work-items

Operator documentation for the `/plan-work-items` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-planning/skills/plan-work-items/SKILL.md`](../../../han-planning/skills/plan-work-items/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Takes a trusted implementation plan (or other provided context) and divides it into individual, focused, independently-grabbable work items.
- **When to use it.** You have an implementation plan you trust and now you need to break it into work items, determine their dependencies, and hand them to implementers.
- **What you get back.** A single `work-items.md` file in the plan's folder, one section per work item, in dependency order.

## Key concepts

- **Vertical slice.** Each work item is a narrow but complete path through the relevant layers (schema, API, UI, tests). A completed work item is demoable or verifiable on its own: not a layer, not a stub.
- **HITL and AFK.** Every work item is classified as HITL (requires a human sync: an architectural decision, a design review) or AFK (can be implemented and merged without one). The skill prefers AFK and prefers many thin work items over few thick ones.
- **Symbolic ID.** Each work item gets a stable identifier (`W-N`). IDs are for cross-referencing work items within the file and citing them in tickets, threads, and follow-up work. They are stable for the life of the file.
- **One file, no repository awareness.** The output is exactly one `work-items.md`. The skill never splits work by repository, counts repositories, or reasons about cross-repository integration. The breakdown is driven only by the plan or context it is given.
- **Dependencies.** A work item's `Depends on` line names other work items in the same file that must complete first, or `None`. Work items are written in dependency order.
- **Runs autonomously.** After you invoke it, the skill runs end to end without pausing for approval. It makes the reasonable default decision (where the file goes, how the plan divides), states it, prints the breakdown for visibility, and writes the file. It stops for you only when it genuinely cannot continue: there is no plan or context to work from.

## When to use it

**Invoke when:**

- You have a high degree of confidence in a plan and you are ready to start implementing it.
- You want the plan broken into atomic units of work an implementer can pick up one at a time.
- You need the dependency order between those units so you know what can be worked in parallel.

**Do not invoke for:**

- **Thinking about a feature.** Use [`/plan-a-feature`](./plan-a-feature.md) to start a feature from scratch, developing specifications through asking questions.
- **Turning feature specs into an implementation plan.** Use [`/plan-implementation`](./plan-implementation.md) to turn a feature specification into an implementation plan through a project-manager-led team conversation.
- **Reviewing or hardening a plan.** Use [`/iterative-plan-review`](./iterative-plan-review.md) to stress-test an existing plan through multiple codebase-grounded review passes before you trust it.
- **Sequencing work into demoable delivery phases.** Use [`/plan-a-phased-build`](./plan-a-phased-build.md) when the question is *what do we ship first, second, third* and each phase must be independently demoable to a real person. This skill produces grabbable work items, not an ordered phase rollout.
- **Writing the code.** Use [`/tdd`](../han-coding/tdd.md) to implement a work item test-first.
- **Any work where there is no existing implementation plan.** If there is no plan yet, use one of the planning entry points above to create one before dividing it into work items.

## How to invoke it

Run `/plan-work-items` in Claude Code.

Give it:

1. **The feature name or implementation plan, optional.** The default is to look for the plan within the project. If there is no plan file, point it at whatever context describes the work.
2. **The output folder, optional.** Defaults to the plan file's folder. When there is no plan file, the skill writes next to the source context or chooses a best-guess folder, states which folder it picked, and proceeds without waiting.

Example prompts that work well:

- `/plan-work-items docs/features/my-feature/feature-implementation-plan.md`. Divides the plan in `feature-implementation-plan.md` into work items written to `docs/features/my-feature/work-items.md`.
- `/plan-work-items my-feature`. Looks for a plan under `docs/features/my-feature/` to divide into work items.
- `/plan-work-items`. *"Break this context into work items"* with the context described inline. The skill states the folder it chose and proceeds without waiting.

## What you get back

One file on disk plus an in-channel summary:

- **`work-items.md`** in the resolved folder. The stakeholder-readable artifact. It opens with a title line and an intro paragraph that links the parent plan (or names the source context) and explains the `W-N` ID scheme. When a single reference artifact applies to more than one work item, a **Shared reference artifacts** preamble cites it once. Then one section per work item, in dependency order. Each work item carries: `Summary` (with an inline plan reference), `Description`, optional `Design references`, `References`, `Tests`, `Acceptance criteria`, and `Depends on`.
- An **in-channel summary** with the file path, a count of work items by type (HITL / AFK), and the next concrete action.

## How to get the most out of it

- **Be explicit about the feature or context.** The default is a best guess based on which feature plan was most recently worked on. Naming the feature or pointing at the plan file directly removes the ambiguity.
- **Pair with `/plan-implementation` upstream.** This skill depends on there being a plan to break down. `/plan-implementation` produces it.
- **Pair with `/iterative-plan-review` upstream.** A highly-trusted, reviewed-and-battle-tested plan makes dividing it into work items much easier and the breakdown sharper. Do not break down a plan you do not yet trust.
- **Pair with `/plan-a-phased-build` upstream when the work is large.** When the effort is big enough to ship in slices, phase it first, plan the implementation of a single phase, then run this skill against that phase's plan. Each work-items file then covers one phase.
- **Pair with `/tdd` downstream.** Once the breakdown is written, `/tdd` implements a work item test-first. The work item's `Description`, `Tests`, and `Acceptance criteria` become the behavior test list.
- **Pair with `/work-items-to-issues` downstream when you track work on GitHub.** Once the breakdown is written, `/work-items-to-issues` publishes each item as a GitHub issue in its target repo. It needs the `han-github` plugin and the `gh` CLI.

## YAGNI (when applicable)

YAGNI does not gate this skill's output. The work-items file is a structural decomposition of an already-committed implementation plan: the work item boundaries, HITL/AFK classification, and reference artifact links derive from what the plan already decided. This skill does not introduce new behavioral commitments or speculative infrastructure. YAGNI enforcement belongs upstream, in `/plan-implementation` and `/iterative-plan-review`, before the plan reaches this stage.

If the plan you are decomposing has not yet been through a YAGNI sweep, run `/iterative-plan-review` first.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

## Cost and latency

One sub-agent dispatch: `project-manager` for the work item breakdown (Step 5), on its own frontmatter tier (`opus`) since the skill passes no model override. All other work runs in-process: locating and reading the plan, resolving the output location, inventorying reference artifacts, assigning symbolic IDs, printing the breakdown for visibility, and writing the work-items file. The project-manager dispatch is the most expensive step. For a typical feature plan, expect a single dispatch plus a few minutes of in-process work. The skill is designed for a once-per-plan cadence after planning is complete. Re-run it only after the plan has materially changed. For iterating on the plan itself, use `/iterative-plan-review`.

## In more detail

The skill's input is a trusted implementation plan, or whatever context describes the work when no plan file exists. Its output is a single decomposition file. The judgment-heavy work happens in one place: the work item breakdown (Step 5), dispatched to `project-manager`. Everything around it is coordination: locating the plan, resolving where the file goes, inventorying the artifacts an implementer needs, printing the breakdown for visibility, and writing the file incrementally. The skill runs unattended from invocation to the finished file; it stops for you only when there is no plan or context to work from at all.

**Locating the source.** The skill takes the plan from an explicit path, a feature name resolved to `docs/features/<name>/feature-implementation-plan.md`, the most recently updated plan when several exist, or inline context when there is no plan file at all. It reads the plan plus anything the plan links (a feature specification, a contract file, an ADR). The plan content is the union of those sources. It never fetches a plan from a URL or an external issue tracker.

**Resolving the output location.** The skill writes exactly one `work-items.md`. It goes in the user-specified folder, or the plan file's folder, or next to the source context, or, when none of those exist, a best-guess folder of two to four kebab-case words under an existing documentation root. It states which folder it chose and proceeds without waiting for confirmation. If a `work-items.md` already exists in the chosen folder, the skill does not overwrite it and does not stop to ask: it writes to a timestamp-suffixed name and states which file it wrote. The existing file is always preserved.

**The breakdown.** `project-manager` receives the full plan content, the reference artifact inventory, and the skill's Rules verbatim, with a directive to draft vertical slices: each work item a narrow but complete path through the appropriate layers, demoable or verifiable on its own, classified HITL or AFK, preferring AFK and preferring many thin work items over few thick ones. It returns a numbered list and writes no files. The skill returns that list verbatim, assigns `W-N` IDs, prints the breakdown for visibility, and writes the file without waiting for approval.

**Incremental writing.** The skill writes the title and intro first, then appends each work item as it is finalized. Buffering the whole document in conversation memory and writing at the end is explicitly disallowed. If something interrupts the run, the work in progress is preserved on disk.

## Sources

The skill's vocabulary is grounded in established delivery practice. Each source below is cited because the skill draws a specific, named artifact from it.

### Kent Beck: *Extreme Programming Explained* (vertical slicing)

The "vertical slice, not horizontal layer" rule traces to XP and the broader agile-delivery tradition. A unit of work that delivers a thin end-to-end strip of behavior is a deliverable. A unit that delivers "all the database work" is not. The skill's requirement that every work item be demoable or verifiable on its own is a strong reading of the same principle.

URL: https://www.oreilly.com/library/view/extreme-programming-explained/0201616416/

### Andrew Hunt & David Thomas: *The Pragmatic Programmer* (tracer bullets)

The skill describes each work item as a tracer bullet: a thin path through every layer that lets you see the whole trajectory working before you build it out. The tracer-bullet metaphor is why a work item must touch schema through tests rather than stopping at a single layer.

URL: https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/

### Mike Cohn: *User Stories Applied* (INVEST)

Cohn's INVEST criteria (Independent, Negotiable, Valuable, Estimable, Small, Testable) inform the per-work-item shape. Each work item is independent enough to grab on its own, small enough to ship as a unit, and testable through its `Tests` and `Acceptance criteria` fields. The HITL/AFK split is the skill's read of the Independent criterion: an AFK work item can be merged without a human sync.

URL: https://www.mountaingoatsoftware.com/books/user-stories-applied

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule. This skill does not gate on it; enforcement belongs upstream.
- [`project-manager`](../../agents/han-core/project-manager.md). Dispatched in Step 5 to draft the work item breakdown.
- [`/plan-implementation`](./plan-implementation.md). Pair upstream to produce the implementation plan this skill breaks down.
- [`/iterative-plan-review`](./iterative-plan-review.md). Pair upstream to harden a plan you do not yet trust before breaking it into work items.
- [`/plan-a-phased-build`](./plan-a-phased-build.md). Pair upstream when the work is large enough to ship in phases. Phase first, plan one phase, then break that phase's plan into work items.
- [`/tdd`](../han-coding/tdd.md). Pair downstream to implement a work item test-first.
- [`/work-items-to-issues`](../han-github/work-items-to-issues.md). Pair downstream to publish the work items as GitHub issues. Part of the `han-github` plugin.
- [Work item template](../../../han-planning/skills/plan-work-items/references/work-item-template.md). The template the skill renders for each work item.
- [Work-items file format](../../../han-planning/skills/plan-work-items/references/work-items-file-format.md). The title, intro, and preamble structure of the output file.
- [Reference artifact inventory](../../../han-planning/skills/plan-work-items/references/reference-artifact-inventory.md). The include list, exclude list, and screenshot-to-work-item mapping rules the skill applies in Step 4.
