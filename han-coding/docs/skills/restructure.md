# /restructure

Operator documentation for the `/restructure` skill in the han plugin. This document helps you decide _when_ and _how_
to use the skill. For what the skill does internally, read the skill definition at
[`han-coding/skills/restructure/SKILL.md`](../../skills/restructure/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) ·
> [All skills](../../../docs/skills/README.md) · [All agents](../../../docs/agents/README.md) ·
> [YAGNI](../../../docs/yagni.md)

## TL;DR

- **What it does.** Restructures a codebase, or a large area of it, toward a target layout or set of boundaries without
  changing behavior. It analyzes the area, plans ordered units, and carries out each unit through `/refactor` or
  `/tdd`, committing each one. When a unit is too tangled to move in one step, it uses the Mikado Method to tease it
  apart.
- **When to use it.** You want code reorganized across many files or modules, such as a new folder layout, a module
  split along a boundary, or the project's documented structure re-applied, and you want to step away while it runs.
- **What you get back.** A series of commits on your current branch, one per step, plus a change-set folder holding a
  change log that justifies every decision, the analysis, the plan, and a Mikado graph for any unit that stalled.

## Key concepts

- **One start gate, then unattended.** The skill stops once, before any code moves, so you can confirm the goal, the
  structure rules it found, the completion check, the commands, the branch, and the output folder. After you confirm,
  it asks nothing more. Every decision it makes from then on is written down as a numbered `D-N` entry for you to review
  when you come back.
- **A coordinator, not a fourth way to edit code.** [`/architectural-analysis`](./architectural-analysis.md) finds what
  makes moving code unsafe, [`/plan-a-change`](../../../han-planning/docs/skills/plan-a-change.md) splits the work into
  ordered units, and [`/refactor`](./refactor.md) or [`/tdd`](./tdd.md) carries out each unit under their own test
  gates. This skill discovers the project, forwards the goal, commits, and logs.
- **Mikado only when needed.** Most units go straight through `/refactor`. A unit _stalls_ when `/refactor` stops
  because the unit reached outside its files or failed twice, when `/tdd` cannot reach green, or when the suite is red
  afterward. A stall means the unit has prerequisites the plan could not see by reading the code. The skill then tries
  the change the simple way, records what breaks as prerequisites in a graph, undoes the attempt, and works the
  prerequisites first. Each finished prerequisite is its own unit and its own commit.
- **Nothing about your project is assumed.** The skill finds your source roots, entry points, test runner, test roots,
  and structure rules in your own files when it runs. It works on any language and any layout.
- **A clean tree, and commits on the current branch only.** Failed units and discovery attempts are undone by restoring
  to the last commit, which is only safe when the tree started clean. The skill never creates or switches branches,
  pushes, or opens a pull request.

## When to use it

**Invoke when:**

- You want to reorganize code across a whole package, service, or repository: by feature, by layer, by component.
- You want a module split along a boundary, and the code is tangled enough that the split will take many steps.
- Your project documents how its code should be laid out, and the code has drifted from it.
- A `/plan-a-change` plan already exists for a restructure and you want it carried out unit by unit with a record of
  every decision.

**Do not invoke for:**

- **One named spot.** Extracting a function, removing duplication in one module, or a refactoring you can name in a
  sentence belongs to [`/refactor`](./refactor.md), which is faster and stops for you when its scope spreads.
- **Planning without executing.** Use [`/plan-a-change`](../../../han-planning/docs/skills/plan-a-change.md) to settle
  the target structure and sequence the units, then decide whether to run them.
- **Finding out what is wrong.** Use [`/architectural-analysis`](./architectural-analysis.md) when you want findings and
  no code changes.
- **Changing behavior.** Fixes and features are follow-ups in the change log, never units. Use
  [`/investigate`](./investigate.md) and [`/tdd`](./tdd.md) for those.
- **A tree with uncommitted work, or no tests.** The skill refuses a dirty tree and a red suite. A unit whose code has
  no test coverage is logged as not done rather than moved blind.

## How to invoke it

Run `/restructure` in Claude Code on the branch where the commits should land. A dedicated branch is best; the skill
warns you at the start gate when you are on the default branch.

Give it:

1. **The goal.** The structure you want, in your own words: _"group each package by feature, then by component"_,
   _"pull the billing code out of the orders module"_, or _"re-apply the layout in our README"_. The skill asks for a
   goal if you give none, and asks nothing else in that turn.
2. **Optionally, the area.** A directory or set of modules. Without one, the skill finds the source roots itself.
3. **Nothing about the test framework.** The skill resolves the test, type-check, lint, and build commands from your
   project and shows them at the start gate for you to confirm.

At the start gate you can also change the discovery round cap (five attempts per stalled unit by default) and the
output folder.

Example prompts:

- `/restructure`. _"Reorganize `services/` so every service is grouped by feature, with shared code in a `shared/`
  folder at the lowest level that covers every user."_
- `/restructure`. _"Split the reporting code out of the accounts module into its own module."_
- `/restructure`. _"Bring the code back in line with the layout section of the README."_

## What you get back

Commits on your branch, in this order: the change-set start, the architectural analysis, the plan, one commit per unit,
one commit per Mikado graph update, the updated layout docs, and the finished change log.

The change-set folder (under your configured `output-directory`, or `docs/changes/restructure-{date}/` by default)
holds:

- **`change-log.md`.** Every step in order, with what changed, why, the decisions behind it, and the test counts
  against the baseline. It closes with where things ended up, the decisions to look at first, the units not done, and
  the behavior changes deferred as follow-ups.
- **`change-plan.md`.** The ordered units, each tagged `refactor` or `tdd`, with the files it may touch and the units it
  depends on.
- **`artifacts/change-decision-log.md`.** Every decision as a `D-N` entry with its rationale and the alternatives
  rejected.
- **`artifacts/architectural-analysis.md`.** The analysis that found the risks to moving code.
- **`artifacts/mikado-graph.md`.** Present only when a unit stalled: a nested checklist of each stalled unit's
  prerequisites, with which attempt found each one and which commit finished it.

## How to get the most out of it

- **Write your structure rules down first.** The skill reads your README, CLAUDE.md, ADRs, coding standards, and any
  boundary tests to learn the rules. The clearer they are, the fewer judgment calls end up in the decision log.
- **Read "Decisions to look at first" before anything else.** That section names the closest calls, any departure from
  an earlier change set, and how the skill grouped failures into prerequisites. Grouping is the judgment call the Mikado
  research says a person should check.
- **Review the commits, not the final diff.** Each commit is one unit or one graph update, so a wrong turn can be
  reverted without losing the rest.
- **Watch the round cap.** A unit that hits it is logged as not done with its graph. A graph that keeps growing means
  the unit is bigger than the plan assumed; the graph is a good starting point for a smaller follow-up run.
- **Pair with it when the stakes are high.** Run it through [`/pairing`](../../../han-core/docs/skills/pairing.md) to
  stop after every unit lands.

## YAGNI

`/restructure` does not add structure of its own: every unit must serve the goal or a documented structure rule, and
the planning and refactoring skills it runs apply the [YAGNI](../../../docs/yagni.md) evidence gate to each unit and
each refactoring. A unit with no evidence behind it is not planned. Behavior changes the analysis turns up are recorded
as follow-ups rather than folded in.

## Cost and latency

This is the most expensive skill in `han-coding` to run. It runs `/architectural-analysis` (which dispatches a team of
analyst agents), `/plan-a-change` (which runs its own discovery and review rounds), and then one `/refactor` or `/tdd`
run per unit. Every unit and every Mikado attempt re-runs your full test suite at least once, so your suite's runtime
multiplied by the number of units and attempts dominates the total. Narrowing the area is the main cost lever.

When `han-planning` is not installed, the skill writes the unit plan itself from the analysis, which is cheaper but
skips `/plan-a-change`'s review rounds. The decision log records when that happened.

## In more detail

`/refactor` holds each step to a declared list of files and stops when a step spreads beyond it or two steps fail in a
row. Those rules are what make it safe, and they are exactly what a tangled restructure trips over. A stop there is a
discovery, not a dead end: the step has prerequisites nobody has found yet. This skill reads the stop that way. It
keeps `/refactor`'s rules intact for every committed change, and runs the Mikado Method's discovery loop around them.

The undo is the hardest part of running the method on a real tree. Discovery attempts are deliberately wide and always
thrown away. The skill restores to the last commit with a bundled script that refuses to run if anything was committed
since the attempt began, removes only untracked files (ignored build output and installed packages stay), and leaves
the tree clean. That is safe only because the tree started clean, the graph is committed before each undo, and the full
suite runs after each one. The skill checks all three every time.

The honest limits: the method needs a test suite to tell it what broke, and dependencies that never show up as a build,
type, test, lint, or boundary-check failure cannot be discovered by trying. The default round cap of five is a judgment,
not a measured number. No published study measures whether an agent running the Mikado Method improves outcomes; the
design rests on the method's well-corroborated loop and on Han's existing test-gated skills.

## Sources

### Ola Ellnestam and Daniel Brolund, _The Mikado Method_ (Manning, 2014)

The discovery loop: try the goal the simple way, record what breaks as prerequisites, undo, and work the leaves first.
The graph as the method's one lasting artifact.

URL: https://livebook.manning.com/book/the-mikado-method/chapter-1

### Practitioner write-ups of the method

Commit each finished prerequisite only with the tests green, keep the graph in a file alongside the code, and expect
new obstacles while working back up. Drawn from Matthias Noback's and heise's write-ups of the method.

URL: https://matthiasnoback.nl/2021/02/refactoring-the-mikado-method/

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs
  tree.
- [`/pairing`](../../../han-core/docs/skills/pairing.md). Run this skill collaboratively, stopping after each unit so you
  review it as it lands. Invoking `/restructure` directly runs to completion after the start gate.
- [Skills Index](../../../docs/skills/README.md). All skills, grouped by purpose.
- [`/refactor`](./refactor.md). Carries out each `refactor` unit. Use it directly for one named spot.
- [`/tdd`](./tdd.md). Carries out each `tdd` unit, such as a new shared module a move needs.
- [`/architectural-analysis`](./architectural-analysis.md). The analysis this skill runs first. Use it directly for
  findings without changes.
- [`/plan-a-change`](../../../han-planning/docs/skills/plan-a-change.md). The planning skill this skill runs to split
  the work into units. Use it directly to plan without executing.
- [YAGNI](../../../docs/yagni.md). The evidence gate the planning and refactoring skills apply to each unit.
