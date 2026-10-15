# Research: Should the Mikado Method be added to the `han-coding:refactor` skill, and how?

The question is whether the refactor skill should take on the Mikado Method, and if so in what form. The Mikado Method
is a technique for large changes in tangled code: try the change, note what breaks, undo it, then fix the blockers
first. Evidence mode: strict.

## Summary

Add only a thin slice of the Mikado Method to the refactor skill, and fix a bug in the skill first. The bug: when a
step fails, the skill's "undo this step" instruction can also throw away earlier steps that had already passed, if they
were never committed. That fix stands on its own and is worth making whether or not Mikado goes in.

The Mikado slice: when the skill stops because a step spread beyond its planned files, it should write down what
blocked the step as a list of prerequisites. It already writes down what it learned when a step fails its tests. The full method,
where the agent deliberately breaks the code to discover its plan, conflicts with three rules the skill is built on and
should not be added. The bug finding is solid. The case for the Mikado slice rests on practitioner accounts of the
method and on this request; nothing in the repo shows people hitting that stop today.

- **Confidence:** Medium
- **Web search:** used

## Research Results

### How the Mikado Method works

The method is a loop for changes too big to make directly. Three independent practitioner write-ups describe the same
steps, consistent with the authors' own account (A2, A4, A5; authors A3):

1. Write down the goal.
2. Try it the simple, direct way and let the compiler and tests show what breaks.
3. Record each break as a prerequisite in a graph pointing at the goal, then undo every edit.
4. Pick a prerequisite with nothing under it (a "leaf") and try it the same way, adding new prerequisites and undoing
   again if it breaks something.
5. When a leaf works with the tests passing, commit it and mark it done.
6. Work back up the graph until the goal itself goes in cleanly.

Ola Ellnestam and Daniel Brolund published it as a book in 2014, after presenting it from 2010 (A1, A3). The authors
call undoing the most important and least intuitive step (A3) [single-source, seen as a search summary]. The payoff is
that the code stays working and every commit is shippable (A2). The cost is that early rounds produce no committed
code, and practitioners timebox each attempt, to 5-15 or 10 minutes, so undoing stays cheap (A4, A5).

### Where it fits and where its evidence stops

Every source places its use in large changes to tangled code, where a direct change sets off a cascade of breakage
(A1, A2, A4). None of the sources found states when not to use it, and a limited search for criticism turned up none.
All of the evidence is practitioner experience or the authors' own account. No study measures whether it saves time or
reduces defects (A1, A2, A3, A4, A5).

Mikado sequences work; it does not say how to make each change safely. Patterns such as Branch by Abstraction and
Parallel Change, which keep a system working while one part is swapped, could sit inside a Mikado graph as individual
steps (A11, A12). Kent Beck's "make the change easy, then make the easy change" states the same intent as Mikado's
leaf-first order (A13). No source links these ideas to Mikado directly; the comparison is drawn here from their
descriptions.

### What changes when an agent runs it

Two 2026 practitioner posts argue the method suits coding agents: undoing costs an agent almost nothing, and the
written graph gives the agent a long-range plan that outlasts its context window (A6, A7). Both describe a markdown
file kept in version control as the graph, carried between sessions (A6, A7). A community tool and an advertised
marketplace skill already package the method for Claude Code (A8, A9). Neither has published results, and both come
from parties promoting their own tooling [single-source each].

The agent-specific risk with the most evidence is the undo itself. One agent-oriented guide undoes with a hard git
reset (A6). User reports against two different agent tools describe a hard reset or similar command destroying
uncommitted work that could not be recovered (A10) [seen as search summaries, not opened]. Other risks are named by
one source each: agents editing many files at once, scope leaking into a sibling prerequisite, slow test suites making
each attempt expensive, and tests being edited to pass (A6, A7) [single-source].

The two agent-focused sources disagree on who builds the graph. One has the agent try the goal with no upfront
analysis (A6). The other keeps a person building and owning the graph, and treats it as a working hypothesis (A7).

### How the refactor skill works today

The refactor skill plans before it edits. It writes the whole sequence of named refactorings, each with its evidence
and the files it may touch, before the first change (A14). It treats that list of files as a contract. When a step
needs files outside it, or two planned steps in a row are undone, the skill stops, reports where things stand, and the
person re-scopes (A15).

The skill already does a small piece of what Mikado does. When a step fails its tests, the skill undoes it, diagnoses,
and either retries smaller or defers the item "with what you learned," and the final summary lists deferred items and
stop-rule exits (A15). What it does not do is record why a scope stop happened: that path says only "report where
things stand" (A15).

The skill's description sends planning a multi-module restructure to `plan-a-change`, and says the skill is "an
execution skill, not a document generator" (A17). `plan-a-change` already orders its change units so each leaves the
code working, and records each unit's dependencies, but it works by reading code, never by trying a change and
watching what breaks (A18). The workflow map already routes `plan-a-change` output into `refactor` (A20).

The research that designed the refactor skill favored tightly scoped agents over sweeping ones, citing one
not-yet-reviewed preprint, and it rejected a plan-only refactor skill because the suite's gap was execution, not more
planning (A19).

### Where Mikado and the skill agree and where they collide

Mikado's leaf execution matches the skill closely: one small named change, tests green, commit, next (A2, A14, A15).
Mikado's trigger also matches the skill's scope stop. Both treat "this change broke things outside what I expected" as
the signal to stop and undo rather than push forward (A5, A15).

Mikado's discovery half collides with three of the skill's rules:

- **Plan before editing.** Mikado discovers its plan by editing (A6, A7); the skill forbids any edit before the plan
  exists (A14).
- **Scope as a contract.** A naive attempt is a deliberately wide change; the skill stops the moment a change spreads
  (A15).
- **Two undone steps means stop.** Mikado undoes constantly by design; the skill treats two in a row as a reason to
  hand back to the person (A15).

### A defect in the skill's undo step

The skill's undo instruction can discard finished work. When git is available and the tree was clean at the start of
the run, it restores the touched files with git (A16). Git restores a file to its last commit, not to the state after
the previous step. Commits during a run happen only when the person asks, and even then may be grouped across several
steps, so earlier green steps are often uncommitted. When a later step in the same file goes red, restoring that file
throws away the earlier green step too (A16). That breaks the skill's own promise that "everything already applied is
green and stands" (A15).

This is a defect today, independent of Mikado. Two refactorings in one file, such as two extractions from one module,
are common, so the failure needs no unusual setup. It is also the same class of loss the agent reports describe (A10).

## Options to Consider

### O1: Do nothing

- **What it is:** Leave the skill as it is, undo behavior included.
- **Trade-offs:** No new work. Leaves a live defect that can discard finished refactorings without warning.
- **Rests on:** (A15), (A16)
- **Evidence status:** corroborated (codebase)

### O2: Fix the undo step only

- **What it is:** Change the undo so it removes only the current step's own edits and never runs a hard reset or
  clean. No Mikado.
- **Trade-offs:** Closes the defect with the smallest change. Adds nothing for large changes, which keep ending in a
  bare scope stop.
- **Rests on:** (A16), (A15)
- **Evidence status:** corroborated (codebase)

### O3: Record prerequisites at a scope stop (Mikado slice)

- **What it is:** On top of O2, extend the skill's existing "defer with what you learned" behavior to its scope and
  two-undo stops. The stop undoes the offending step safely, names what blocked it as prerequisites, and lists them in
  the stop report and the summary, where the person can re-scope or take them to `plan-a-change`. Nothing is written to
  a file.
- **Trade-offs:** Keeps Mikado's most useful move, undo and record instead of undo and forget, at the cost of a
  clause or two. It keeps every existing gate. Two parts are new behavior, not a pure extension: the scope stop does not
  undo the offending step today, and the stop gains a prerequisites list. It does not let the agent explore beyond one
  failed attempt, so a deep chain of blockers still takes several runs. Nothing in the repo shows people hitting this
  stop yet; the stated need is this request.
- **Rests on:** (A2), (A4), (A5), (A15), (A16)
- **Evidence status:** the loop is corroborated across web sources and the matching trigger by the codebase. That this
  improves outcomes is not measured.

### O4: A Mikado mode inside the refactor skill

- **What it is:** An explicit argument that switches the skill into the full loop: naive attempt, undo, graph, work
  leaves, with a graph file kept between sessions.
- **Trade-offs:** Matches how the method is described and how agent-oriented posts run it (A6, A7). But it reverses
  three rules the skill is built on (plan first, scope as contract, stop after two undos), adds the skill's first
  persisted document, and multiplies undos.
- **Rests on:** (A6), (A7), (A14), (A15), (A17)
- **Evidence status:** single-source per agent claim; the conflicts are codebase-corroborated.

### O5: Mikado-style discovery in `plan-a-change`

- **What it is:** Give `plan-a-change` an optional probe: try the change, record what breaks, undo, and write the
  findings into its existing dependency fields. `refactor` then executes the plan one unit at a time, unchanged.
- **Trade-offs:** Puts discovery where planning already lives and reuses an existing hand-off. But `plan-a-change`
  today reads code and never edits it, so it would gain write access and the undo hazard. It is a change to a different
  plugin than the one asked about.
- **Rests on:** (A17), (A18), (A20)
- **Evidence status:** fit is codebase-corroborated; benefit is not measured.

### O6: A separate Mikado skill

- **What it is:** A new skill that runs the full Mikado loop and hands each leaf to `refactor`.
- **Trade-offs:** Mirrors how community tooling ships it (A8, A9) and keeps `refactor` untouched. But it overlaps
  `plan-a-change` for sequencing and `refactor` for execution, so the suite would carry two places that order a large
  restructure.
- **Rests on:** (A8), (A9), (A17), (A18)
- **Evidence status:** single-source and promotional for the tooling; the overlap is codebase-corroborated.

## Recommendation

- **Recommendation:** O2 now, then O3 as the Mikado addition.
  1. Fix the undo step (O2) as a standalone bug fix. Snapshot or diff each step before it runs, and undo only that
     step's own edits, including files it created and both paths of a rename. Never hard-reset or clean. The `tdd`
     skill's refactor step also says "revert it" with no mechanism, so check it for the same shared-file problem.
  2. Add the Mikado slice (O3). Extend the existing "defer with what you learned" behavior so scope and two-undo stops
     undo the offending step and list its blockers as prerequisites in the stop report and summary. Keep the stop in
     the shape the collaborative-stop rule sets: where things stand and what was found, with no new question bolted on.
  3. Do not add O4, O5, or O6. Reopen O5 if O3's prerequisite lists keep showing chains several levels deep that take
     several runs to clear.
- **Evidence basis:** The undo defect is corroborated by the skill's own text (A15, A16) and does not depend on any web
  source. The Mikado loop is corroborated by three independent practitioner write-ups that predate agents (A2, A4, A5).
  The match between Mikado's trigger and the skill's scope stop, and the skill's existing record-what-you-learned
  behavior, come from the skill itself (A15). The conflicts that rule out O4 come from the skill's text (A14, A15, A17).
  The agent-specific posts (A6, A7) and tools (A8, A9) motivate the agent angle but carry none of the decision: removing
  all four leaves the recommendation unchanged. Whether O3 improves results is not measured, and the need for it rests
  on this request rather than on observed stops.

## Validation

### V1: The undo defect is real

- **Strategy:** Challenge the Evidence
- **Investigation:** Read the undo, commit, and stop-rule text in the refactor skill and traced a two-step,
  same-file run with no commit between steps.
- **Result:** Confirmed
- **Impact:** Restoring a file resets it to its last commit, so the earlier green step is lost. Grouped commits leave
  the same gap. The fix was split out as a standalone recommendation (O2).

### V2: The codebase citations match the files

- **Strategy:** Challenge the Evidence
- **Investigation:** Checked every codebase line range against the current files and git history.
- **Result:** Partially Refuted
- **Impact:** All locations hold. The design research's "sweeping agents do worse" finding rests on one unreviewed
  preprint, so the report now says so and no longer uses it to rule out an option.

### V3: The skill already records what a failed step taught it

- **Strategy:** Challenge the Options Framing
- **Investigation:** Read the red-step and summary instructions.
- **Result:** Partially Refuted
- **Impact:** The skill already defers a failed item "with what you learned" and lists stop-rule exits. The Mikado
  slice was narrowed to extending that to the scope stop, a smaller change than first described.

### V4: Two options were missing and one was mis-supported

- **Strategy:** Challenge the Options Framing
- **Investigation:** Compared the option set against the minimal alternatives and the prior design research.
- **Result:** Partially Refuted
- **Impact:** Added "fix the undo only" (O2). The separate-skill option no longer claims the design research rejected
  it; that research rejected a plan-only skill, which a Mikado skill is not.

### V5: The Mikado slice has no recorded user need

- **Strategy:** Challenge the Recommendation
- **Investigation:** Searched the changelog, docs, and research for reports of people hitting the scope or two-undo
  stop, and checked the slice against the YAGNI rule and the collaborative-stop rule.
- **Result:** Partially Refuted
- **Impact:** No such report exists. The report now states that the need rests on this request. O3 was made the
  simplest version (extend an existing clause, no file, no new question in the stop) and flagged that undoing on a
  scope stop is new behavior.

### V6: The bug fix was bundled with the feature

- **Strategy:** Challenge the Recommendation
- **Investigation:** Checked whether the undo fix depends on adopting Mikado.
- **Result:** Partially Refuted
- **Impact:** It does not; the defect fires today. The recommendation now lists the fix first and on its own.

### V7: Some citations overstated their support

- **Strategy:** Challenge the Evidence
- **Investigation:** Checked that every cited source resolves and supports its claim, tracing merged sources back to
  the analysts' output.
- **Result:** Partially Refuted
- **Impact:** All citations resolve. Corrected: the destructive-git reports name a third tool with no cited link, so
  that tool was removed; "four independent accounts" became three plus the authors; the agent guide that undoes with a
  hard reset was removed from the Mikado slice's support; the marketplace listing is marked as advertising.

### V8: No single web source carries the decision

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Checked which web sources are self-published or promotional, looked for directive text, and
  removed each web source in turn to see whether the recommendation moved.
- **Result:** Confirmed
- **Impact:** The 2026 agent posts and the tooling are self-published or promotional, but removing them, the
  destructive-git reports, or the authors' talk leaves the recommendation unchanged. The report now says the web basis
  for O3 is the pre-agent write-ups.

### V9: The undo fix was under-specified

- **Strategy:** Challenge the Recommendation
- **Investigation:** Checked the proposed fix against steps that create files, rename them, fail only the type check,
  or start from a dirty tree, and against the `tdd` skill's own revert.
- **Result:** Partially Refuted
- **Impact:** The recommendation now names a per-step snapshot or diff, covers created and renamed files, and adds an
  audit of the `tdd` revert.

### What validation changed

Validation split the recommendation in two: a standalone undo fix (new O2) and a narrowed Mikado slice (O3) that
extends behavior the skill already has. It also added the "fix the undo only" option and
corrected the separate-skill option's support. It caveated the preprint behind the design research and stated that the
slice's need rests on this request. It fixed four citation overstatements. The recommendation survived in narrower
form.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** No one has observed how an agent reads "touched files" in a live run. Nothing in the repo shows
  people hitting the scope stop, so O3's value is unproven. Whether `plan-a-change` can take a prerequisite list as
  input was not checked. The authors' talk (A3) and the destructive-git reports (A10) were seen only as search
  summaries; neither carries the decision.

## Sources

| ID  | Source                                                    | Link / location                                                                                                                                                                                       | Retrieved  | Trust class | Summary (one line)                                                                                                   | Evidence status                                         |
| --- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ----------- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| A1  | Manning, _The Mikado Method_ book page                    | https://www.manning.com/books/the-mikado-method                                                                                                                                                       | 2026-10-15 | web         | 2014 book by Ellnestam and Brolund for non-trivial improvements to existing systems; publisher description           | corroborated by A2, A3                                  |
| A2  | InfoQ, "Mikado Method" (2012)                             | https://www.infoq.com/news/2012/02/mikado-method                                                                                                                                                      | 2026-10-15 | web         | Describes the graph, undo, leaf-first loop; code stays green so small commits can ship                               | corroborated by A4, A5                                  |
| A3  | Ellnestam, Øredev 2010 talk and book figure captions      | https://archive.oredev.org/oredev2010/2010/speakers/ola-ellnestam                                                                                                                                     | 2026-10-15 | web         | Authors' "naive approach"; calls undoing the most important step (seen via search summaries; book chapter 403)       | loop corroborated by A2, A4; wording single source      |
| A4  | Vinta Software, "The Mikado Method" (2025)                | https://www.vintasoftware.com/blog/the-mikado-method                                                                                                                                                  | 2026-10-15 | web         | Experience report: 10-minute attempts, hard reset on failure, commit each green leaf; lists pitfalls                 | loop corroborated by A2, A5; pitfalls single source     |
| A5  | Understand Legacy Code, safe-changes process              | https://understandlegacycode.com/blog/a-process-to-do-safe-changes-in-a-complex-codebase/                                                                                                             | 2026-10-15 | web         | 5-15 minute naive attempt, undo, graph subgoals, commit leaves; breakage is the trigger to undo                      | corroborated by A2, A4                                  |
| A6  | Chaabani, "Taming Agentic Refactoring with Mikado" (2026) | https://anischaabani.com/en/blog/mikado-method-ai-agents/                                                                                                                                             | 2026-10-15 | web         | Agent loop with `git reset --hard` undo and a versioned `mikado.md`; attempt without upfront analysis                | loop corroborated by A5, A7; details single source      |
| A7  | WellAged.dev, "The Mikado Method in the Age of AI Agents" | https://wellaged.dev/posts/mikado-method-ai-agents/                                                                                                                                                   | 2026-10-15 | web         | Undo is cheap for agents; graph as hypothesis built by a person; names scope leak, slow suites, green-leaf limits    | loop corroborated by A6; risks single source            |
| A8  | erkantaylan/mikado CLI and agent skill                    | https://github.com/erkantaylan/mikado                                                                                                                                                                 | 2026-10-15 | web         | Go CLI keeping a Mikado graph in SQLite, installs a Claude Code skill; tool author is an interested party            | single source                                           |
| A9  | mcpmarket listing, Mikado Method refactoring skill        | https://mcpmarket.com/tools/skills/mikado-method-refactoring-1                                                                                                                                        | 2026-10-15 | web         | Marketplace advertisement for a Claude Code skill with an experiment-graph-undo cycle; author unclear                | single source (advertising)                             |
| A10 | User reports of agents running destructive git commands   | https://claudeissues.com/issue/33850-agent-destroyed-2-days-of-uncommitted-work-via-destructive-git-operation-in-main; https://forum.cursor.com/t/agent-parallel-subagents-overwrite-dirty-worktree-destructive-git-recovery-wastes-tokens/166666 | 2026-10-15 | web         | Claude Code and Cursor agents ran hard reset or clean on dirty trees and destroyed unrecoverable uncommitted work    | two self-reports, seen as search summaries              |
| A11 | Fowler, "Branch by Abstraction"                           | https://martinfowler.com/bliki/BranchByAbstraction.html                                                                                                                                               | 2026-10-15 | web         | Swap an implementation behind an abstraction while the system keeps building; no mention of Mikado                  | corroborated by A12                                     |
| A12 | Fowler, "Parallel Change"                                 | https://martinfowler.com/bliki/ParallelChange.html                                                                                                                                                    | 2026-10-15 | web         | Expand, migrate, contract to change an interface while it stays working                                              | corroborated by A11                                     |
| A13 | Beck, "Tidy First? example" (2025)                        | https://newsletter.kentbeck.com/p/tidy-first-example                                                                                                                                                  | 2026-10-15 | web         | "Make the change easy (warning, this may be hard), then make the easy change"                                       | single source                                           |
| A14 | refactor skill, Step 3                                    | `han-coding/skills/refactor/SKILL.md:110-124`                                                                                                                                                         | n/a        | codebase    | Plans the whole run, each item with evidence and expected files, before the first edit                              | current-state anchor                                    |
| A15 | refactor skill, scope contract, red step, and stop rules  | `han-coding/skills/refactor/SKILL.md:52-54`, `:142-149`, `:163-164`                                                                                                                                   | n/a        | codebase    | Defers a failed step "with what you learned"; stops on scope spread or two undos and reports where things stand     | current-state anchor                                    |
| A16 | refactor skill, undo step and commit rule                 | `han-coding/skills/refactor/SKILL.md:142-146`, `:93-95`, `:151-152`                                                                                                                                   | n/a        | codebase    | Restores touched files with git when the tree was clean at start; commits optional, so earlier green steps can be lost | current-state anchor                                  |
| A17 | refactor skill, description and constraints               | `han-coding/skills/refactor/SKILL.md:3-13`, `:37-38`                                                                                                                                                  | n/a        | codebase    | Sends multi-module restructure planning to plan-a-change; "an execution skill, not a document generator"            | current-state anchor                                    |
| A18 | plan-a-change sequencing                                  | `han-planning/skills/plan-a-change/SKILL.md:312-315`; `han-planning/skills/plan-a-change/references/change-plan-template.md:64`                                                                       | n/a        | codebase    | Orders units so each leaves code working and records dependencies, by reading code only                             | current-state anchor                                    |
| A19 | Refactor skill design research                            | `docs/research/refactor-skill-research.md:26`, `:66-70`, `:92`                                                                                                                                        | n/a        | codebase    | Favored conservative agents over sweeping ones on one unreviewed preprint; rejected a plan-only refactor skill      | current-state anchor; preprint finding single source    |
| A20 | Workflow map                                              | `docs/workflows.md:88-94`                                                                                                                                                                             | n/a        | codebase    | Shows plan-a-change feeding refactor                                                                                 | current-state anchor                                    |

### A15: refactor skill, scope contract, red step, and stop rules — recommendation-bearing

- **Link / location:** `han-coding/skills/refactor/SKILL.md:52-54`, `:142-149`, `:163-164`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The declared scope bounds every edit, and a step that pulls in files outside it is a stop-and-report.
  When a step fails its tests, the skill undoes it, diagnoses, and retries smaller or defers the item "with what you
  learned." It stops when a step needs files outside its declared set, when the only fix would change behavior, or when
  two consecutive plan items have been undone, and reports where things stand, promising "everything already applied is
  green and stands." The final summary lists deferred items and stop-rule exits. The scope-stop path does not say to
  undo the offending step or record what blocked it. This is the hook O3 extends.
- **Evidence status:** current-state anchor

### A16: refactor skill, undo step and commit rule — recommendation-bearing

- **Link / location:** `han-coding/skills/refactor/SKILL.md:142-146`, `:93-95`, `:151-152`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** On a red suite the skill restores the touched files with `git checkout`/`git restore` when git is
  available and the tree was clean at the start of the run, and undoes edits directly otherwise. Commits happen only if
  the person asked, after each green step or each group of green steps. Git restores a file to its last commit, so in a
  run without a commit between two steps in the same file, undoing the second step also discards the first. The
  condition looks at the start of the run instead of the current step's own edits.
- **Evidence status:** current-state anchor

### A2: InfoQ, "Mikado Method" (2012) — recommendation-bearing

- **Link / location:** https://www.infoq.com/news/2012/02/mikado-method
- **Retrieved:** 2026-10-15
- **Trust class:** web (outside the trust boundary)
- **Summary:** Independent trade-press summary of the method. A change that triggers cascading errors is mapped as a
  graph and undone. Work proceeds one leaf at a time, new problems are added to the graph and undone again, and a node
  is done when its fix causes no new errors. Undoing leaves you with more information than you started with, and the
  code keeps compiling and passing tests, so small increments can go straight to the main branch.
- **Evidence status:** corroborated by A4, A5

### A5: Understand Legacy Code, safe-changes process — recommendation-bearing

- **Link / location:** https://understandlegacycode.com/blog/a-process-to-do-safe-changes-in-a-complex-codebase/
- **Retrieved:** 2026-10-15
- **Trust class:** web (outside the trust boundary)
- **Summary:** A practitioner walkthrough of the Mikado loop from before AI agents: a naive attempt in a 5-15 minute
  timebox, undo, graph what is missing as subgoals, commit each leaf as a checkpoint. Short timeboxes keep undoing
  cheap. It rests on one ORM-upgrade example and gives no effort data.
- **Evidence status:** corroborated by A2, A4

### A4: Vinta Software, "The Mikado Method" (2025) — recommendation-bearing

- **Link / location:** https://www.vintasoftware.com/blog/the-mikado-method
- **Retrieved:** 2026-10-15
- **Trust class:** web (outside the trust boundary)
- **Summary:** A consultancy's experience report. Set a goal with a verifiable completion check, make fixed 10-minute
  attempts, and on failure record the blocker as a prerequisite and undo with a hard reset. Commit each completed
  prerequisite with tests passing. Named pitfalls: analysis paralysis top-down, frustration bottom-up, no committed code
  in early rounds, and drifting into unstructured refactoring when the timer is ignored. Recommends it for complex,
  application-wide changes.
- **Evidence status:** loop corroborated by A2, A5; pitfalls single source
