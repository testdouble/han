# Research: How should the Mikado Method work as a new Han skill?

The question is how the Mikado Method works and how to build it into a new Han skill that runs the method on a real
codebase. The decision to build a new skill is taken as given; this report covers what the skill should do, how it
should share work with the skills Han already has, and where it should sit. Evidence mode: strict.

## Summary

Build a new skill that owns the Mikado graph and the discovery rounds, and hands each leaf (a step with no prerequisites
of its own) to the `refactor` or `tdd` skill to carry out. The method is well described and stable: try the change the simple way, write
down what breaks, undo the attempt, fix the blockers first, and commit each one only when the tests pass. Han already
has skills that make one small change safely under passing tests, so the new skill should reuse them rather than build a
third way to do that.

The hardest part is undoing a deliberately wide attempt without losing anyone's work. Restoring files from git is the
undo practitioners use. It is only safe under a short list of conditions the skill has to check, and nothing settles
whether a throwaway copy of the code is the better choice.

The loop itself is well-corroborated. The agent-specific design advice comes from a handful of 2026 blog posts and skill listings, and nothing measures whether any of it works.

- **Confidence:** Medium
- **Web search:** used

## Research Results

### How the Mikado Method works

The method is a loop for changes too big or too tangled to make in one step. Ola Ellnestam and Daniel Brolund presented
it from 2010 and published it as a book with Manning in 2014 (A1, A2, A6). The authors' own talk, a news report on it,
and two independent practitioner write-ups describe the same discovery loop (A1, A2, A3, A5):

1. Write down the goal.
2. Try the goal the simple, direct way.
3. Let the compiler, the tests, and any other checks show what breaks.
4. Write each break down as a prerequisite under the goal.
5. Undo the attempt.
6. Treat each prerequisite as a new goal and repeat, until an attempt shows no new prerequisites.
7. Make the changes that have no prerequisites of their own, and work back up toward the goal.

Practitioners add that each finished prerequisite is committed only with the tests passing, so every commit leaves a
working system (A4, A5, A11). The authors call the whole loop a depth-first walk through the change's dependencies (A1).
A prerequisite with nothing under it is a "leaf," and leaves always go first (A2). New obstacles can still show up while
working back up, and they become new branches of the graph (A3).

### The graph is the method's one lasting artifact

The record of goal and prerequisites, called the Mikado graph, is what survives each undo. It is kept outside the code,
on paper, a whiteboard, plain text, or a diagram tool (A3, A7). Finished nodes are marked done, and the graph can be
attached to a pull request so a reviewer sees why the change took the shape it did (A4, A7). The sources define no
formal notation for it (A3).

### Where the sources disagree on the details

The loop's shape is settled, but its mechanics vary from source to source:

- **What counts as broken.** The original names compilers, tests, analysis, and common sense (A1). Others center on
  compile and test failures (A3, A5). A skill has to pick an explicit signal.
- **How to undo.** Sources use a hard git reset (A4), commit the attempt and then revert that commit (A5), or allow a
  stash for a promising partial attempt (A3). The original says only "version control or undo" (A1).
- **Timeboxing.** One practitioner caps each attempt at 10 minutes (A4) [single-source]. The others set no limit.
- **Stopping.** The method has no natural end, so a stop condition is needed (A3). One source fixes a completion check
  at the start, such as a code search that returns no matches (A4) [single-source].

### The method's limits

All of the evidence on limits comes from practitioners. The search found no study that measures the method's results.
Practitioners name these limits:

- Without automated tests, nothing can confirm a change is safe (A3).
- Slow builds and tests make every attempt expensive (A3).
- Throwing away an attempt feels wasteful, and the discipline to undo is the hardest part (A3, A4, A5).
- Early rounds produce no committed code (A4).
- Dependencies that do not show up as compile or test failures are hard to discover by trying (A5).

Uses beyond restructuring code are thin. One source shows removing a library dependency (A5). The search found no source
applying the method to feature work or framework migrations.

### How agents have used it so far

Agent-driven Mikado exists as three 2026 practitioner posts and three community skill listings, and none publishes
measured results (A9, A10, A11, A12, A13, A14). Evidence here is thin. Two of the three posts share an author (A9, A11),
so they count as one voice, and the listings are the skill authors' own descriptions.

The agent sources agree on four points:

- **Undo, then record.** Every source undoes the attempt and keeps only the graph (A9, A11, A13, A14).
- **The graph lives in a file.** Most keep it as a markdown checklist in the repository (A9, A11, A13). One keeps it in
  an uncommitted folder (A12), and one keeps it only in the agent's working memory (A14).
- **Small leaf commits.** Each finished leaf is one commit, made only when the tests pass (A10, A11).
- **The compiler and tests are the signal** (A9, A13).

They name three agent-specific failure modes: agents make sweeping edits across many files, lose track as context grows,
and edit tests to make them pass (A9) [single-source]. One author argues that deciding which failures share a root cause
cannot be handed to the agent (A10) [single-source]. A worked example kept a person confirming the goal and approving
each green commit, which is a different gate (A11).

The sources leave several questions open:

- No source compares reset, stash, and a separate throwaway copy of the code for the undo.
- No source sets a cap on discovery rounds or handles a graph that keeps growing. One adds a script that checks the
  graph for loops (A11) [single-source].
- No source reports how reliably an agent obeys "undo, don't patch forward."

### How the new skill fits Han today

`refactor` and `tdd` are the two Han skills that edit code in a test-gated loop, and both live in the coding plugin
(A17, A18, A19). `refactor` plans every step before its first edit, treats each step's list of files as a contract, and
stops when a step spreads beyond it or two steps in a row fail (A17, A18). Those three rules are the ones Mikado's
discovery half breaks on purpose. That is the case against putting discovery inside `refactor`, and the case for a
separate skill that runs discovery and then hands each leaf to `refactor`, where its rules fit.

`refactor`'s stop rules are also exactly Mikado's signal. A step that spreads past its files, or fails twice, is a step
with prerequisites nobody has found yet (A18). A skill that owns the graph can read that stop as a discovery and add the
blockers as new nodes. One community skill joins the two the same way, falling back to Mikado inside a test-gated
refactor loop (A14) [single-source]. Han's entity taxonomy allows a skill to invoke other skills for fixed sub-steps
(A24).

`plan-a-change` already sequences a restructure so each unit leaves the code working, but it does so by reading code and
never by trying a change (A20). That is the real line between it and a Mikado skill: one predicts the dependencies, the
other discovers them by breaking the build.

### Relationship to the earlier Han report on Mikado

An earlier Han report advised against a separate Mikado skill (A25). It recommended fixing `refactor`'s undo step first,
then recording blockers as prerequisites when `refactor` stops. Its rejected separate-skill option ran the full loop and
handed each leaf to `refactor`, which is close to what this report now recommends. It rejected that option because the
suite would carry two places that order a large restructure, and it judged the agent posts and tools too weak to carry
the decision.

Three things differ now. The undo fix has shipped, which removes the hazard that report cared most about (A18). The
decision to build a new skill is taken, so this report weighs how to build it, not whether. And the overlap cost the
earlier report named still stands; it is managed here by routing text and by reusing `refactor` rather than duplicating
it, not removed. The earlier report lives only on an unmerged branch, so the link to it may break.

### The undo problem

`refactor` forbids restoring files from git, because a restore throws away any earlier passing step that was not yet
committed (A18). Mikado changes that picture: every finished leaf is committed, so the last commit holds every passing
step (A4, A5, A11). A restore to the last commit is safe in that case, but only when every one of these holds. These
conditions are drawn here from git's behavior and the codebase, not stated by any source:

- The project is a git repository, and the run is on a branch where commits are expected.
- The tree is clean before each attempt, tracked and untracked files alike, and nothing has changed since the skill
  last checked. A person's edit during a run is indistinguishable from an attempt's edit, and a restore would wipe it.
- The graph update is committed before the code is restored, or the restore wipes the newly found prerequisites.
- Files the attempt created are removed too, by path, from a before-and-after listing. A plain restore leaves them
  behind, and a blanket `git clean` would also remove files the person left untracked.
- The full suite is re-run after every undo. Ignored and generated state (build output, installed packages, caches) is
  not reverted by a restore and can make the next run pass or fail for the wrong reason.

A throwaway copy of the code avoids most of those hazards. Running each attempt in a separate git worktree (a second
checkout of the same repository in another folder) leaves the person's working tree untouched, and the undo is deleting
the copy. Its costs are a fresh install of dependencies per copy and a hard requirement on git. No source compares the
two approaches.

### What a new skill must ship with

Han's conventions add required work to any new skill (A22, A23, A26):

- A long-form doc, a plugin README line, and a skills-index entry, in the same change.
- An entry in `pairing`'s list of skills it can drive, plus the collaborative-stop text inside the new skill.
- Routing lines in the descriptions of `refactor` and `plan-a-change` that point to the new skill, so a reader does not
  see three overlapping triggers for a large restructure.

## Options to Consider

### O1: One skill that runs discovery and carries out every leaf itself

- **What it is:** A coding-plugin skill that confirms the goal, runs discovery rounds, keeps a committed markdown graph,
  and makes each leaf change itself under passing tests, committing each one.
- **Trade-offs:** It matches the method as described and keeps the whole loop in one place. But it re-implements
  `refactor`'s change, test, and undo loop, so the suite gains a third place that carries out a restructure step. Every
  undo hazard in the section above falls on this skill alone.
- **Rests on:** (A1), (A3), (A5), (A11), (A18)
- **Evidence status:** loop corroborated. The duplication cost is codebase-corroborated.

### O2: A discovery-only skill that ends with a graph for the person to work through

- **What it is:** The skill runs only the discovery half: try, record, undo. It ends with a graph file. The person then
  runs each leaf through `refactor` (or `tdd` for leaves that change behavior).
- **Trade-offs:** The new skill stays small and execution reuses tested skills. But a leaf can turn up new
  prerequisites while it is built (A3), and nothing carries them back into the graph. The person becomes the go-between
  for every leaf.
- **Rests on:** (A3), (A17), (A18), (A20)
- **Evidence status:** corroborated for the fit. No source runs the method split this way.

### O3: A skill that owns the graph and discovery, and hands each leaf to `refactor` or `tdd`

- **What it is:** The new skill owns the goal, the graph, and the discovery rounds. For each leaf it invokes `refactor`
  (or `tdd` when the leaf changes behavior) with that one leaf as the whole plan. When `refactor` stops because the step
  spread or failed twice, the new skill records the blockers as new nodes and goes back to discovery.
- **Trade-offs:** It reuses `refactor`'s tested undo and `tdd`'s test-first gate rather than duplicating them, and it
  carries new prerequisites back into the graph, which O2 cannot. It depends on `refactor` stopping cleanly with the
  offending step undone and the blockers named. The earlier report found the scope stop does not undo the step today
  (A25), so that has to change or the new skill has to undo it. `tdd`'s refactor step says "revert it" with no
  mechanism (A25), which matters for behavior-changing leaves. The overlap with `plan-a-change` for ordering work remains.
- **Rests on:** (A3), (A14), (A17), (A18), (A20), (A24), (A25)
- **Evidence status:** the fit is codebase-corroborated. The one outside example of joining Mikado to a refactor loop is
  single-source (A14).

### O4: One autonomous skill with a time budget and no human gate

- **What it is:** O1's loop with no stops. A budget per attempt (10 minutes in the source) bounds each round, and fixed
  commit prefixes record discoveries.
- **Trade-offs:** It is the simplest to run and the least work to review. Included for contrast: the budget comes from
  one source and was designed for people, nothing guards against an agent editing tests, and no source caps the number
  of rounds.
- **Rests on:** (A4), (A9), (A13)
- **Evidence status:** single-source for the specifics.

### O5: Add Mikado to `refactor` instead of building a new skill

- **What it is:** The earlier report's recommendation. When `refactor` stops on a scope or repeated-failure rule, it
  records what blocked the step as prerequisites in its stop report (A25).
- **Trade-offs:** It is the smallest change and adds no overlapping skill, and the earlier report recommended it on its
  merits. It never runs discovery on purpose, so a deep chain of blockers takes several runs. It is ruled out here by
  the decision to build a new skill, not by the evidence.
- **Rests on:** (A14), (A18), (A25)
- **Evidence status:** codebase-corroborated for the fit. A14 is single-source.

## Recommendation

- **Recommendation:** O3, built with these specific choices.
  1. **Place it in `han-coding`**, beside `refactor` and `tdd`. Discovery is planning-like, since its edits are thrown
     away, but the skill edits code, runs tests, and commits, and those are what the coding plugin holds.
  2. **Hand each leaf to `refactor`, or to `tdd` when the leaf changes behavior.** Treat a `refactor` scope stop or
     double failure as a discovery: record the blockers as new nodes and return to discovery. Make `refactor`'s scope
     stop undo the offending step, or have the new skill undo it.
  3. **Get commit consent at the first stop.** Mikado's safety depends on committing each leaf and each graph update, so
     the skill says so when it confirms the goal and runs on a dedicated branch. It refuses a dirty tree, which is
     stricter than `refactor` on purpose, because its undo is only safe from a clean one.
  4. **Choose the discovery undo deliberately.** Either restore to the last commit under every condition in "The undo
     problem," or run each attempt in a throwaway worktree. No source settles this; the deciding criteria are the cost
     of reinstalling dependencies per attempt against the risk of touching the person's working tree.
  5. **Define "broken" up front** as build, test, and lint failures. Reuse `refactor`'s detection script for those
     commands, ask for the type-check command as `refactor` does, and have the person confirm the commands at the first
     stop.
  6. **Keep the graph in a committed markdown file**, a nested checklist where each node carries an ID and what it
     requires. Name its path, and decide whether Han's output-directory setting applies to it. Mark a node done only
     after its green commit.
  7. **Stop for the person to confirm the goal, its completion check, and the commands.** A stop after each discovery
     round to review how failures were grouped is a reasonable default but rests on one source (A10); under `pairing`,
     add a stop after each leaf commit, as the worked example did (A11).
  8. **Guard against patching forward.** A red attempt is always undone, never patched. Test changes happen only in
     `tdd` leaves; a restructuring leaf changes no tests.
  9. **Cap discovery rounds** with a configurable count and a stop when exceeded. The right number is an open
     assumption; the only stated budget (10 minutes) was designed for people.
- **Evidence basis:** The loop, the graph as the lasting artifact, and commit-per-leaf are corroborated across several
  sources (A1, A2, A3, A4, A5, A11). Handing leaves to `refactor`, the meaning of its stops, the undo hazard, and the
  plugin placement come from the codebase (A17, A18, A19, A24). The precondition list for a safe restore is drawn from
  git's behavior and the codebase, not from any source. The grouping-review stop rests on one source (A10)
  [single-source], and the no-test-edits rule on one source for the risk (A9) [single-source]. The undo choice and the
  round cap are left open because no evidence settles them. Removing any single web source leaves the recommendation
  standing except the grouping-review stop, which falls back to a design choice.

## Validation

### V1: The codebase citations match the files

- **Strategy:** Challenge the Evidence
- **Investigation:** Checked every codebase location (A17 to A26) against the current files and git history.
- **Result:** Confirmed
- **Impact:** All locations hold. Two content problems surfaced elsewhere (V2, V6).

### V2: The detection script was over-credited

- **Strategy:** Challenge the Evidence
- **Investigation:** Searched the detection script for a type-check command.
- **Result:** Partially Refuted
- **Impact:** The script infers test, lint, and build commands only, and its guesses need confirming. The recommendation
  now asks for the type-check command and adds build failure to "broken," since compile breaks are the method's main
  signal.

### V3: Several citations did not support their claims

- **Strategy:** Challenge the Evidence
- **Investigation:** Compared each cited claim against its registry entry.
- **Result:** Partially Refuted
- **Impact:** Corrected: "four independent sources" became the authors' talk, a report on it, and two practitioners;
  commit-on-green moved to the sources that say it; "at least four community skills" became three; absence claims now
  read "the search found none"; several registry entries were widened to carry what the sources said.

### V4: The human-gate evidence was overstated

- **Strategy:** Challenge the Evidence
- **Investigation:** Compared the gate claim in the Recommendation with the two sources cited for it.
- **Result:** Refuted
- **Impact:** Only one source supports a person reviewing how failures are grouped (A10). The other shows a different
  gate, approving each commit (A11). The recommendation now labels the grouping stop single-source.

### V5: "Safe by construction" does not hold for the undo

- **Strategy:** Challenge the Recommendation
- **Investigation:** Traced a restore to the last commit against created files, ignored and generated files, installed
  packages, the graph file, a person editing during the run, an interrupted leaf, and a repository without git.
- **Result:** Refuted as stated
- **Impact:** Replaced the claim with an explicit list of conditions, added the throwaway-worktree alternative, and left
  the choice between them open.

### V6: Committing as it goes conflicts with Han's convention

- **Strategy:** Challenge the Recommendation
- **Investigation:** Compared the design with `refactor`, which commits only on request, and with Han's output-directory
  setting.
- **Result:** Partially Refuted
- **Impact:** The recommendation now gets commit consent at the first stop, runs on a dedicated branch, explains the
  stricter clean-tree rule, and names the graph path as a decision to make.

### V7: Options were missing

- **Strategy:** Challenge the Options Framing
- **Investigation:** Looked for alternatives between the listed options, including a throwaway copy for attempts, a
  hybrid that delegates leaves, and an agent for grouping.
- **Result:** Partially Refuted
- **Impact:** Added the hybrid as O3, which became the recommendation because it reuses `refactor` instead of
  duplicating it. Added the worktree undo. O4 and O5 are now marked as included for contrast, with their real grounds
  for rejection. A grouping agent was not added: the only source on grouping says it belongs to a person.

### V8: The earlier report's argument was handled thinly

- **Strategy:** Challenge the Recommendation
- **Investigation:** Read the earlier report's recommendation and its rejection of a separate skill.
- **Result:** Partially Refuted
- **Impact:** Added a section on how this report relates to it, what has changed since, and the routing edits the
  overlap requires.

### V9: Plugin placement holds, with a gap

- **Strategy:** Challenge the Recommendation
- **Investigation:** Checked placement against how the coding and planning plugins split their skills.
- **Result:** Confirmed
- **Impact:** Added a sentence on why discovery's planning-like nature does not change placement, and listed the work a
  new skill must ship with.

### V10: What `pairing` adds was unstated

- **Strategy:** Challenge the Recommendation
- **Investigation:** Compared the always-on stops with the collaborative-stop rule.
- **Result:** Partially Refuted
- **Impact:** The recommendation now says `pairing` adds a stop after each leaf commit on top of the default stops.

### V11: The web evidence holds up, with one load-bearing single source

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Reviewed authorship and interest for each web source, and removed each in turn to test the
  recommendation.
- **Result:** Partially Refuted
- **Impact:** No directive text was found in any summary. A7 and A12 share an author who builds Mikado tooling, A9 and
  A11 share an author, and A4, A12, A13, and A14 are interested parties; the registry now says so. The recommendation
  survives removing any one source except the grouping stop, which rests on A10 alone.

### V12: Smaller gaps

- **Strategy:** Challenge the Recommendation
- **Investigation:** Checked the test rule against behavior-changing leaves and the round cap against a graph that
  never converges.
- **Result:** Confirmed
- **Impact:** Test changes now happen only in `tdd` leaves. The round cap is now a configurable count with a stop,
  labeled as an assumption.

### Adjustments Made

Validation changed the recommendation from O1 (one skill that carries out every leaf itself) to O3 (a skill that hands
each leaf to `refactor` or `tdd`). It also replaced the undo safety claim with a list of conditions, left the undo
mechanism open between restore and a throwaway worktree, and downgraded the grouping-review stop to single-source.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:**
  - The validator had no web access, so it judged the web sources from their registry summaries only.
  - No source measures whether the method, or an agent running it, improves outcomes.
  - The grouping-review stop rests on one source (A10).
  - O3 depends on changes to `refactor`'s scope stop and on `tdd`'s revert having a mechanism.
  - The undo mechanism and the round cap are open decisions, untested in a real repository.
  - The earlier report (A25) lives only on an unmerged branch.

## Sources

| ID  | Source                                                                       | Link / location                                                                                                   | Retrieved  | Trust class                   | Summary (one line)                                                                                                                                       | Evidence status                                                    |
| --- | ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ---------- | ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| A1  | Øredev 2010 speaker page, Ola Ellnestam (co-author)                          | https://archive.oredev.org/oredev2010/2010/speakers/ola-ellnestam                                                 | 2026-10-27 | web (interested party)        | Co-author's 7-step "Naive Approach," called a depth-first recursion: goal, naive attempt, find breaks via compiler and tests, record, revert, recurse, leaves first. | corroborated by A3, A5                                             |
| A2  | InfoQ, "Large scale refactoring" (2010)                                      | https://www.infoq.com/news/2010/08/large-scale-refactoring                                                        | 2026-10-27 | web                           | Report on the authors' talk: graph built from the goal down; leaves have no prerequisites and go first; do not fear reverting.                           | corroborated by A3; not independent of A1                          |
| A3  | heise, "Update legacy code step by step with the Mikado method"              | https://www.heise.de/en/background/Update-legacy-code-step-by-step-with-the-Mikado-method-11119651.html?seite=all | 2026-10-27 | web                           | Six-step loop, flexible graph tooling, reset or stash to undo; limits: no natural end, needs tests and fast builds, undoing feels wasteful, unwinding finds new obstacles. | loop corroborated by A1, A5; limits single source                  |
| A4  | Vinta Software, "The Mikado Method" (2025)                                   | https://www.vintasoftware.com/blog/the-mikado-method                                                              | 2026-10-27 | web (consultancy)             | 10-minute rounds, hard reset on failure, commit per green node, graph attachable to pull requests, completion check fixed up front, early rounds commit nothing. | commit-per-node corroborated by A5, A11; timebox single source     |
| A5  | Matthias Noback, "Successful refactoring projects: the Mikado Method" (2021) | https://matthiasnoback.nl/2021/02/refactoring-the-mikado-method/                                                  | 2026-10-27 | web                           | Dependency-removal example; each prerequisite committed only when green; reverting feels wasteful; hidden dependencies are hard to find by trying.          | corroborated by A1, A3, A4                                         |
| A6  | Manning / O'Reilly book pages, *The Mikado Method* (2014)                    | https://livebook.manning.com/book/the-mikado-method/chapter-1                                                     | 2026-10-27 | web                           | Confirms authors, publisher, and year; body text was not readable.                                                                                       | single source                                                      |
| A7  | mikado.nvie.com (Vincent Driessen)                                           | https://mikado.nvie.com/                                                                                          | 2026-10-27 | web (interested party)        | Graph is the main artifact, usually drawn on paper; the tool shares graphs, for example on pull requests.                                                | corroborated by A3, A4; same author as A12                         |
| A8  | Martin Fowler, "Parallel Change"                                             | https://martinfowler.com/bliki/ParallelChange.html                                                                | 2026-10-27 | web                           | Expand, migrate, contract keeps code shippable through a change that cannot land in one step.                                                            | single source; not a Mikado source                                 |
| A9  | Anis Chaabani, "Taming Agentic Refactoring with the Mikado Method" (2026)    | https://anischaabani.com/en/blog/mikado-method-ai-agents/                                                         | 2026-10-27 | web                           | Agent failure modes (sweeping edits, scattered context, tests edited to pass); compiler and tests as the signal; hard reset to undo; versioned graph file. | partly corroborated by A10; same author as A11                     |
| A10 | WellAged.dev, "The Mikado Method in the Age of AI Agents" (2026)             | https://wellaged.dev/posts/mikado-method-ai-agents/                                                               | 2026-10-27 | web                           | Graph is what survives each step; commit leaves only on green; grouping failures by root cause cannot be delegated to the agent.                         | revert and graph corroborated by A9; root-cause claim single source |
| A11 | Anis Chaabani, "Mikado Method in Action" (2026)                              | https://anischaabani.com/en/blog/mikado-method-example/                                                           | 2026-10-27 | web                           | Agent example: committed checklist graph with IDs and `requires:`, a loop-check script, graph commit then code revert, one commit per leaf, person approves each. | single source for format; same author as A9                        |
| A12 | nvie/skills "mikado" (skills.sh listing)                                     | https://skills.sh/nvie/skills/mikado                                                                              | 2026-10-27 | web (interested party)        | Community skill keeps one graph per goal in an uncommitted `.mikado/` folder.                                                                            | single source; full skill not visible; same author as A7           |
| A13 | nWave "nw-mikado-method" (OpenSkillIndex listing)                            | https://openskillindex.com/skills/nwave-ai-nwave-nw-mikado-method-474589                                          | 2026-10-27 | web (interested party)        | Community skill: committed checklist graph, compile and test failures as the signal, revert after every attempt, 10-minute attempts, no human gate.        | loop corroborated by A9, A11; specifics single source              |
| A14 | Oma Refactor skill (TypingMind listing)                                      | https://www.typingmind.com/skills/first-fluke-oma-refactor                                                        | 2026-10-27 | web (interested party)        | Mikado as a fallback inside a test-gated refactor loop after repeated failure; refactor commits change no tests; graph held in memory.                    | single source                                                      |
| A15 | Pre-agent Mikado tooling (clokado, mikado_graph_generator, mikado-app)       | https://github.com/ahitrin/clokado                                                                                | 2026-10-27 | web                           | Pre-agent tooling is graph drawers and small web apps; no IDE plugin or CLI found.                                                                       | single search pass (snippets only)                                 |
| A16 | Kent Beck, "make the change easy, then make the easy change"                 | https://tidyfirst.substack.com/p/hinge                                                                            | 2026-10-27 | web                           | States the enabling-change-first rule; no source ties it to Mikado directly.                                                                             | corroborated across two Beck posts                                 |
| A17 | `refactor` skill, plan step                                                  | `han-coding/skills/refactor/SKILL.md:110-124`                                                                     | n/a        | codebase                      | Plans every refactoring, with evidence and a file list, before the first edit.                                                                           | codebase anchor                                                    |
| A18 | `refactor` skill, execute, undo, and stop rules                              | `han-coding/skills/refactor/SKILL.md:128-155`                                                                     | n/a        | codebase                      | One change then the full suite; undo only the step's own edits, never restore from git; stop on scope spread or two failures in a row; commit only on request. | codebase anchor                                                    |
| A19 | `refactor` skill description                                                 | `han-coding/skills/refactor/SKILL.md:3-12`                                                                        | n/a        | codebase                      | Test-gated loop in the coding plugin; routes multi-module restructure planning to `plan-a-change`.                                                       | codebase anchor                                                    |
| A20 | `plan-a-change` skill                                                        | `han-planning/skills/plan-a-change/SKILL.md:3-10`, `:312-315`                                                     | n/a        | codebase                      | Sequences change units so each leaves the code working, by reading code, never by trying a change.                                                       | codebase anchor                                                    |
| A21 | Command detection script                                                     | `han-coding/skills/refactor/scripts/detect-refactor-context.sh:26-94`                                             | n/a        | codebase                      | Infers test, lint, and build commands from the project's manifest as suggestions to confirm; no type-check detection.                                    | codebase anchor                                                    |
| A22 | Collaborative-stop rule                                                      | `han-core/references/collaborative-stop-rule.md`                                                                  | n/a        | codebase                      | Shared contract for how a skill detects the collaborative flag and what a stop presents.                                                                 | codebase anchor                                                    |
| A23 | `pairing` skill, flagged skills                                              | `han-core/skills/pairing/SKILL.md:87-89`                                                                          | n/a        | codebase                      | Lists the skills `pairing` can drive: tdd, refactor, design-an-api, iterative-plan-review, plan-implementation.                                          | codebase anchor                                                    |
| A24 | Entity taxonomy                                                              | `han-plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md`                                         | n/a        | codebase                      | A flowchartable process is a skill and may invoke other skills for fixed sub-steps; contextual judgment is an agent.                                     | codebase anchor                                                    |
| A25 | Earlier Han research on Mikado in `refactor`                                 | `docs/research/mikado-method-refactor.md` on branch `research/mikado-method-refactor`                             | n/a        | codebase (prior research)     | Advised against a separate skill on overlap grounds; recommended the undo fix, then recording blockers at stops; found the scope stop does not undo and `tdd`'s revert has no mechanism. | codebase anchor; unmerged branch                                   |
| A26 | Coverage rule                                                                | `docs/templates/coverage-rule.md`                                                                                 | n/a        | codebase                      | Every new skill needs a long-form doc, a plugin README line, and an index entry in the same change.                                                      | codebase anchor                                                    |
