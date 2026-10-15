# Research: Should the Mikado Method be added to the `han-coding:refactor` skill, and how?

The question is whether the refactor skill should take on the Mikado Method, and if so in what form. The Mikado Method
is a technique for large changes in tangled code: try the change, note what breaks, undo it, then fix the blockers
first. Evidence mode: strict.

## Summary

Add a small piece of the Mikado Method to the refactor skill, not the whole method. Today, when a planned refactoring
step turns out bigger than its declared scope, the skill undoes it and stops. The change: before stopping, it writes
down what broke as a list of prerequisite steps, so the person gets a map of what has to happen first instead of a bare
"stopped." The full method, where the agent deliberately breaks the code to discover the plan, conflicts with three
rules the skill is built on and belongs, if anywhere, in the planning skill that already sequences large restructures.
One fix must land first: the skill's current "undo this step" instruction can also undo earlier finished steps, and
Mikado would make that undo happen far more often. The method itself is well described by several independent
practitioners, but nobody has measured whether it helps, with people or with agents, so this rests on practitioner
accounts plus a close read of the skill.

- **Confidence:** Medium
- **Web search:** used

## Research Results

### How the Mikado Method works

The method is a loop for changes too big to make directly. Four independent accounts describe the same steps (A2, A3,
A4, A5):

1. Write down the goal.
2. Try it the simple, direct way and let the compiler and tests show what breaks.
3. Record each break as a prerequisite in a graph pointing at the goal, then undo every edit.
4. Pick a prerequisite with nothing under it (a "leaf") and try it the same way, adding new prerequisites and undoing
   again if it breaks something.
5. When a leaf works with the tests passing, commit it and mark it done.
6. Work back up the graph until the goal itself goes in cleanly.

Ola Ellnestam and Daniel Brolund published it as a book in 2014, after presenting it from 2010 (A1, A3). The authors
call undoing the most important and least intuitive step (A3) [single-source]. The payoff is that the code stays
working and every commit is shippable (A2). The cost is that early rounds produce no committed code, and practitioners
timebox each attempt, to 5-15 or 10 minutes, so undoing stays cheap (A4, A5).

### Where it fits and where its evidence stops

Every source places its use in large changes to tangled code, where a direct change sets off a cascade of breakage
(A1, A2, A4). No source states when not to use it, and a search for criticism turned up none. All of the evidence is
practitioner experience or the authors' own account. There is no study measuring whether it saves time or reduces
defects (A1-A5).

Mikado sequences work; it does not say how to make each change safely. Patterns such as Branch by Abstraction and
Parallel Change, which keep a system working while one part is swapped, can sit inside a Mikado graph as individual
steps (A11, A12). Kent Beck's "make the change easy, then make the easy change" states the same intent as Mikado's
leaf-first order (A13). No source links these ideas to Mikado directly; the comparison is drawn here from their
descriptions.

### What changes when an agent runs it

Two 2026 practitioner posts argue the method suits coding agents: undoing costs an agent almost nothing, and the
written graph gives the agent a long-range plan that outlasts its context window (A6, A7). Both describe a markdown
file kept in version control as the graph, carried between sessions (A6, A7). Several community skills and tools
already package the method for Claude Code (A8, A9). None has published results [single-source each].

The agent-specific risk that has the most evidence is the undo itself. One agent-oriented guide undoes with a hard git
reset (A6). Several independent user reports describe agents that ran a hard reset or similar command and destroyed
hours or days of uncommitted work that could not be recovered (A10). Other risks are named by one source each: agents
editing many files at once, scope leaking into a sibling prerequisite, slow test suites making each attempt expensive,
and tests being edited to pass (A6, A7) [single-source].

The two agent-focused sources disagree on who builds the graph. One has the agent try the goal with no upfront
analysis (A6). The other keeps a person building and owning the graph, and treats it as a working hypothesis (A7).

### How the refactor skill works today

The refactor skill plans before it edits. It writes the whole sequence of named refactorings, each with its evidence
and the files it may touch, before the first change (A14). It treats that list of files as a contract. When a step
needs files outside it, or two planned steps in a row fail and are undone, the skill stops and reports, and the person
re-scopes (A15). The stop report says where things stand. Nothing requires it to record what the failed attempt
revealed (A15).

The skill's description sends planning a multi-module restructure to `plan-a-change`, and says outright that the skill
is "an execution skill, not a document generator" (A17). `plan-a-change` already orders its change units so each leaves
the code working, and records each unit's dependencies, but it works by reading code, never by trying a change and
watching what breaks (A18). The workflow map already routes `plan-a-change` output into `refactor` (A20).

The research that designed the refactor skill found that tightly scoped agents come out ahead and sweeping ones make
code worse, and it rejected a plan-only refactor skill because the suite's gap was execution, not more planning (A19).

### Where Mikado and the skill agree and where they collide

Mikado's leaf execution matches the skill closely: one small named change, tests green, commit, next (A2, A14, A15).
Mikado's trigger also matches the skill's stop rule. Both treat "this change broke things outside what I expected" as
the signal to undo rather than push forward (A5, A6, A15).

Mikado's discovery half collides with three of the skill's rules:

- **Plan before editing.** Mikado discovers its plan by editing (A6, A7); the skill forbids any edit before the plan
  exists (A14).
- **Scope as a contract.** A naive attempt is a deliberately wide change; the skill stops the moment a change spreads
  (A15), and the design research favored conservative scope (A19).
- **Two undone steps means stop.** Mikado undoes constantly by design; the skill treats two in a row as a reason to
  hand back to the person (A15).

### A defect in the skill's undo step

The skill's undo instruction checks the wrong moment. It uses git to restore the touched files whenever the tree was
clean when the run started (A16). Commits during a run are optional, so earlier green steps are often still
uncommitted. If a later step touches a file an earlier green step also changed, restoring that file throws away the
earlier step's finished work too (A16). This is a defect today. Any form of Mikado multiplies the number of undos and
would make it worse, which is the same class of data loss the agent reports describe (A10).

## Options to Consider

### O1: Do not add Mikado

- **What it is:** Leave the skill as it is. Large changes keep stopping at the scope rule, and the person re-scopes by
  hand.
- **Trade-offs:** Adds nothing and risks nothing new. But a stop discards what the failed attempt revealed about why
  the change is bigger than planned, so the person rediscovers it.
- **Rests on:** (A15), (A10)
- **Evidence status:** corroborated for the current behavior (codebase) and the undo hazard; the cost of lost discovery
  is not measured.

### O2: Record prerequisites when a step stops (Mikado-lite escalation)

- **What it is:** Keep the plan-first loop as the default. When a step spreads beyond its declared files or two steps
  in a row are undone, undo safely back to green, then list what broke as prerequisites in the stop report and offer
  them as a re-scoped plan or as input to `plan-a-change`. Nothing is persisted beyond the chat unless the person asks.
- **Trade-offs:** The smallest change that keeps Mikado's most useful move: undo and record instead of undo and forget.
  It adds one branch to the stop rule and keeps every existing gate. It does not let the agent explore beyond one
  failed attempt, so a deep chain of blockers still takes several runs.
- **Rests on:** (A2), (A5), (A6), (A14), (A15), (A16)
- **Evidence status:** the loop and the matching trigger are corroborated across web and codebase sources. That this
  shape improves outcomes is not measured.

### O3: A Mikado mode inside the refactor skill

- **What it is:** An explicit argument that switches the skill into the full loop: naive attempt, undo, graph, work
  leaves, with a graph file kept between sessions.
- **Trade-offs:** Matches how the method is described and how community skills package it (A6, A7, A9). But it
  reverses three rules the skill is built on (plan first, scope as contract, stop after two undos), adds the skill's
  first persisted document, and runs against the design research's finding that sweeping agents do worse.
- **Rests on:** (A6), (A7), (A9), (A14), (A15), (A17), (A19)
- **Evidence status:** single-source per agent claim; the conflicts are codebase-corroborated.

### O4: Mikado-style discovery in `plan-a-change`

- **What it is:** Give `plan-a-change` an optional probe: try the change, record what breaks, undo, and write the
  findings into its existing dependency fields. `refactor` then executes the plan one unit at a time, unchanged.
- **Trade-offs:** Puts discovery where planning already lives and reuses an existing hand-off. But `plan-a-change`
  today reads code and never edits it, so it would gain write access and the same undo hazard. It is also a change to a
  different plugin than the one asked about.
- **Rests on:** (A17), (A18), (A20), (A10)
- **Evidence status:** fit is codebase-corroborated; benefit is not measured.

### O5: A separate Mikado skill

- **What it is:** A new skill that runs the full Mikado loop and hands each leaf to `refactor`.
- **Trade-offs:** Mirrors how community tooling ships it (A8, A9) and keeps `refactor` untouched. But the design
  research already rejected a separate refactoring-planning skill (A19), and the suite would carry two overlapping
  planners.
- **Rests on:** (A8), (A9), (A19)
- **Evidence status:** single-source for the tooling; the prior rejection is codebase-corroborated.

## Recommendation

- **Recommendation:** O2, after fixing the undo defect. First change the undo step so it can only remove the current
  step's own edits, never earlier work, and never runs a hard reset or clean. Then extend the stop rule so a stop
  records what broke as prerequisites and offers them as a re-scoped plan or input to `plan-a-change`. Revisit O4 if
  stops of this kind keep producing multi-level chains that take several runs to clear.
- **Evidence basis:** The method's loop is corroborated by four independent accounts (A2, A3, A4, A5). The match
  between Mikado's undo-and-record trigger and the skill's stop rule is corroborated by web sources (A5, A6) and the
  skill itself (A15). The conflicts that rule out O3 come from the skill's own text and design research (A14, A15, A17,
  A19). The undo hazard is corroborated by several independent user reports (A10) and by the skill's own text (A16).
  Whether any form of Mikado improves an agent's results rests on practitioner accounts only (A6, A7); no measurement
  exists.

## Validation

<!-- V# findings added after adversarial validation. -->

## Sources

| ID  | Source                                                     | Link / location                                                                                     | Retrieved  | Trust class | Summary (one line)                                                                                                   | Evidence status                                     |
| --- | ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | ---------- | ----------- | -------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| A1  | Manning, _The Mikado Method_ book page                     | https://www.manning.com/books/the-mikado-method                                                     | 2026-10-15 | web         | 2014 book by Ellnestam and Brolund for non-trivial improvements to existing systems; publisher description           | corroborated by A2, A3                              |
| A2  | InfoQ, "Mikado Method" (2012)                              | https://www.infoq.com/news/2012/02/mikado-method                                                    | 2026-10-15 | web         | Describes the graph, undo, leaf-first loop; code stays green so small commits can ship                               | corroborated by A3, A4, A5                          |
| A3  | Ellnestam, Øredev 2010 talk and book figure captions       | https://archive.oredev.org/oredev2010/2010/speakers/ola-ellnestam                                   | 2026-10-15 | web         | Authors' "naive approach"; calls undoing the most important step (seen via search snippets; book chapter 403)         | loop corroborated by A2, A4; wording single source  |
| A4  | Vinta Software, "The Mikado Method" (2025)                 | https://www.vintasoftware.com/blog/the-mikado-method                                                | 2026-10-15 | web         | Experience report: 10-minute attempts, hard reset on failure, commit each green leaf; lists pitfalls                 | loop corroborated by A2, A5; pitfalls single source |
| A5  | Understand Legacy Code, safe-changes process               | https://understandlegacycode.com/blog/a-process-to-do-safe-changes-in-a-complex-codebase/           | 2026-10-15 | web         | 5-15 minute naive attempt, undo, graph subgoals, commit leaves; breakage is the trigger to undo                      | corroborated by A2, A6                              |
| A6  | Chaabani, "Taming Agentic Refactoring with Mikado" (2026)  | https://anischaabani.com/en/blog/mikado-method-ai-agents/                                           | 2026-10-15 | web         | Agent loop with `git reset --hard` undo and a versioned `mikado.md`; attempt without upfront analysis                | loop corroborated by A5, A7; details single source  |
| A7  | WellAged.dev, "The Mikado Method in the Age of AI Agents"  | https://wellaged.dev/posts/mikado-method-ai-agents/                                                 | 2026-10-15 | web         | Undo is cheap for agents; graph as hypothesis built by a person; names scope leak, slow suites, green-leaf limits    | loop corroborated by A6; risks single source        |
| A8  | erkantaylan/mikado CLI and agent skill                     | https://github.com/erkantaylan/mikado                                                               | 2026-10-15 | web         | Go CLI keeping a Mikado graph in SQLite, installs a Claude Code skill                                                 | single source                                       |
| A9  | mcpmarket listing, Mikado Method refactoring skill         | https://mcpmarket.com/tools/skills/mikado-method-refactoring-1                                      | 2026-10-15 | web         | Advertises a Claude Code skill with an experiment-graph-undo cycle and exploration/execution modes                   | single source                                       |
| A10 | User reports of agents running destructive git commands    | https://claudeissues.com/issue/33850-agent-destroyed-2-days-of-uncommitted-work-via-destructive-git-operation-in-main; https://forum.cursor.com/t/agent-parallel-subagents-overwrite-dirty-worktree-destructive-git-recovery-wastes-tokens/166666 | 2026-10-15 | web         | Agents ran hard reset or clean on dirty trees and destroyed unrecoverable uncommitted work                           | several independent self-reports (seen as search summaries) |
| A11 | Fowler, "Branch by Abstraction"                            | https://martinfowler.com/bliki/BranchByAbstraction.html                                             | 2026-10-15 | web         | Swap an implementation behind an abstraction while the system keeps building; no mention of Mikado                  | corroborated by A12                                 |
| A12 | Fowler, "Parallel Change"                                  | https://martinfowler.com/bliki/ParallelChange.html                                                  | 2026-10-15 | web         | Expand, migrate, contract to change an interface while it stays working                                              | corroborated by A11                                 |
| A13 | Beck, "Tidy First? example" (2025)                         | https://newsletter.kentbeck.com/p/tidy-first-example                                                | 2026-10-15 | web         | "Make the change easy (warning, this may be hard), then make the easy change"                                       | single source                                       |
| A14 | refactor skill, Step 3                                     | `han-coding/skills/refactor/SKILL.md:110-124`                                                       | n/a        | codebase    | Plans the whole run, each item with evidence and expected files, before the first edit                              | current-state anchor                                |
| A15 | refactor skill, scope contract and stop rules              | `han-coding/skills/refactor/SKILL.md:52-54`, `:147-149`                                              | n/a        | codebase    | Stops when a step needs files outside scope or two steps in a row are undone; report says where things stand        | current-state anchor                                |
| A16 | refactor skill, undo step                                  | `han-coding/skills/refactor/SKILL.md:142-146`, `:93-95`, `:151-152`                                  | n/a        | codebase    | Restores touched files with git when the tree was clean at start; commits are optional, so earlier steps can be lost | current-state anchor                                |
| A17 | refactor skill, description and constraints                | `han-coding/skills/refactor/SKILL.md:3-13`, `:37-38`                                                 | n/a        | codebase    | Sends multi-module restructure planning to plan-a-change; "an execution skill, not a document generator"            | current-state anchor                                |
| A18 | plan-a-change sequencing                                   | `han-planning/skills/plan-a-change/SKILL.md:312-315`; `references/change-plan-template.md:64`        | n/a        | codebase    | Orders units so each leaves code working and records dependencies, by reading code only                             | current-state anchor                                |
| A19 | Refactor skill design research                             | `docs/research/refactor-skill-research.md:26`, `:66-70`                                              | n/a        | codebase    | Conservative agents net positive, aggressive net negative; plan-only refactor skill rejected                        | current-state anchor                                |
| A20 | Workflow map                                               | `docs/workflows.md:88-94`                                                                            | n/a        | codebase    | Shows plan-a-change feeding refactor                                                                                 | current-state anchor                                |

### A15: refactor skill, scope contract and stop rules — recommendation-bearing

- **Link / location:** `han-coding/skills/refactor/SKILL.md:52-54`, `:147-149`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The declared scope bounds every edit, and a step that pulls in files outside it is a stop-and-report. In
  the loop, the skill stops when a step needs files outside its declared set, when the only fix would change behavior,
  or when two consecutive plan items have been undone. The report states where things stand and lets the person
  re-scope; it does not require recording what the failed attempt revealed. This is the hook O2 extends.
- **Evidence status:** current-state anchor

### A16: refactor skill, undo step — recommendation-bearing

- **Link / location:** `han-coding/skills/refactor/SKILL.md:142-146`, `:93-95`, `:151-152`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** On a red suite the skill restores the touched files with `git checkout`/`git restore` when git is
  available and the tree was clean at the start of the run, and undoes edits directly otherwise. Commits happen only if
  the person asked for them. So in a clean-start run without commits, restoring a file a later step shares with an
  earlier green step discards the earlier step's work. The condition looks at the start of the run instead of the
  current step's own edits.
- **Evidence status:** current-state anchor

### A5: Understand Legacy Code, safe-changes process — recommendation-bearing

- **Link / location:** https://understandlegacycode.com/blog/a-process-to-do-safe-changes-in-a-complex-codebase/
- **Retrieved:** 2026-10-15
- **Trust class:** web (outside the trust boundary)
- **Summary:** A practitioner walkthrough of the Mikado loop from before AI agents: a naive attempt in a 5-15 minute
  timebox, undo, graph what is missing as subgoals, commit each leaf as a checkpoint. Short timeboxes keep undoing
  cheap. It rests on one ORM-upgrade example and gives no effort data.
- **Evidence status:** corroborated by A2, A6

### A10: User reports of agents running destructive git commands — recommendation-bearing

- **Link / location:** see table row
- **Retrieved:** 2026-10-15
- **Trust class:** web (outside the trust boundary)
- **Summary:** Separate reports against Claude Code, Cursor, and Copilot describe agents running a hard reset or
  clean-style command on a tree with uncommitted work and destroying it beyond recovery. Suggested mitigations: never
  hard-reset or clean without approval, stop and ask before large edits on a dirty tree. These were read as search
  summaries, not opened; one related report elsewhere was found to be false.
- **Evidence status:** several independent self-reports, uninspected
