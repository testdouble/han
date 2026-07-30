# Research: Reducing the Complexity, Time, and Token Cost of the han-planning Skills

What changes to the `han-planning` skills and the agents they dispatch would cut the complexity, wall-clock time, and
token cost of running them? Evidence mode: strict.

## Summary

Cut the number of specialist reviewers the planning skills dispatch, and the number of review rounds they run, before
touching anything else. That is where the cost lives. The largest planning skill sends as many as eight reviewers through
up to three sequential rounds, and each reviewer loads its own multi-hundred-line role definition and reads the plan
again from disk.

Trimming the instruction documents themselves is the change most people reach for first, but it pays less. One
independent test measured that kind of trimming at roughly nine percent savings. In a working agent, tokens go mostly to
file reads, tool calls, and generated output, not to the wording of the instructions.

Three other changes are worth making. Turn the purely mechanical checks into scripts the skill runs, instead of steps it
reads and performs by hand: confirming a file exists on disk, stripping findings that carry an "unverified" marker, and
verifying cross-reference links.

Delete the six-point readability check that three skills run on text a separate editor has already rewritten. A model
reviewing its own fresh output is a documented way to make correct work worse.

Split the three oversized instruction files, but only the parts that a run reads on some paths and skips on others.
Moving content every run reads into a separate file it still reads every run saves nothing.

Two things not to change. Asking the user one question per turn has no evidence against it, and cheaper model routing is
already in place: every dispatched agent already declares which model tier it runs on, and the mechanical ones already
run on the cheapest.

This rests on a mix of corroborated evidence and single sources, and adversarial validation found real errors in the
first draft's own measurements, which is reflected below.

- **Confidence:** Medium

## Research Results

**Agent dispatch, not document length, is where the token cost concentrates.** The largest planning skill runs six to
eight agents across as many as three sequential rounds plus a synthesis dispatch at its largest band (A6). The role
definitions those agents load run from 100 to 565 lines each (A7), and each brief carries plan content on top of that.
Against this, the five instruction documents total 2,693 lines (A1). The independent measurement that settles the
comparison comes from a test of a prose-compression technique across 86 real coding tasks. The claimed 65 percent saving
measured at about 8.5 percent, because most of the token cost in a working agent is file reads, tool calls, and generated
output rather than instructional prose (A38). That test also found no measurable loss in task success, quality, or
latency from the terser wording, so compression is safe but small.

**The evidence on adding agents points the same direction from three independent places.** The best-documented source in
this set built a 14-mode failure taxonomy from more than 1,600 annotated traces across seven multi-agent frameworks. It
found that coordination and architecture, not model capability, dominate multi-agent failure (A20). Anthropic's own
guidance says to start with single agents and add more only for context protection, parallelization, or specialization.
It also reports an internal test where subagents spent more tokens coordinating than working (A13). A vendor with a
commercial interest in the opposite conclusion still recommends the fewest agents possible, measured against a
single-agent baseline (A19).

The cost multiplier for fanning out is roughly an order of magnitude, though the vendor's own two figures disagree: 15
times a chat turn in one post, 3 to 10 times a single agent in another. The baselines differ (A12, A13, conflict
recorded).

**Sequential rounds are the part of the fan-out that pays least.** Parallel dispatch of independent work recovers real
wall-clock time, up to 90 percent on complex research queries (A12). Sequential, dependent work is where multi-agent
structure stops paying. One reported study across 180 configurations found every multi-agent variant degraded
performance by 39 to 70 percent on sequential-reasoning tasks (A18) [single-source]. Anthropic states the same without
numbers: sequential phases of one task share too much context and belong in one agent (A13). The review rounds in
`plan-implementation` and `iterative-plan-review` are sequential by construction, since each round reads the prior
round's findings.

**Three skills run a same-model readability check on text a separate editor agent has already rewritten** (A9).
Ungrounded self-critique is a documented negative result: it can turn correct output wrong. One cited case dropped
accuracy from 98 percent to 57 percent because a step primed to find fault invents problems (A15, corroborated by A16).
The editor agent is the external check that the same evidence says does work. The check that follows it on the same text
is the ungrounded one. The one thing the self-check adds that the editor's own output does not obviously cover is its
sixth criterion, fact preservation, and the editor already returns a fact-preservation ledger.

**Several unconditional gates are mechanical enough to execute rather than narrate.** The completeness gate confirms
files exist on disk, Pass B strips findings carrying an "Unverified:" marker from build-blocking severity, and
`iterative-plan-review` Step 6 verifies cross-reference backlinks and inline decision citations (A9). Executing code
actions instead of narrating a procedure measured up to 20 percent higher task success and about 30 percent fewer steps
across 17 models (A36). The platform's own authoring guidance independently recommends scripts for deterministic
operations (A34). A related finding is that prose gates get narrated as followed without being followed: compliance
measured 0 percent under default conditions and rose to 97 percent only where each step's rationale was observable (A31)
[single-source, paper body not inspected]. A second paper argues the same point from the design side: natural language
policy is "unenforceable by anything." It reports no measurements of its own (A39). This is agreement on the thesis, not
independent confirmation of the numbers.

**Three of the five instruction files exceed the size their own platform's guidance recommends, but the fix is narrower
than it first appears.** `plan-implementation` is 759 lines, `plan-a-feature` 707, and `iterative-plan-review` 512,
against a recommended ceiling of 500 (A1, A34). The adherence evidence is real and on point. Agents following long
written procedures with explicit gates passed only 36.2 percent of deterministic checks at best, with "losing rule
details over a long document" named as a failure mode (A30). Adherence also degrades as constraint count rises (A27,
A29), and attention degrades unevenly with input length well before any context limit (A25, A26). The catch is that the
content most obviously repeated across these files sits in the operating principles and in the boundary-confirmation step, both
of which run on every invocation. Moving content a run always reads into a file the run still always reads changes the
entry file's line count without changing the tokens the run consumes.

**Deduplication has a smaller payoff than the first draft claimed.** Validation found that only two of the five cited
duplication sites are genuinely near-identical text: the one-question-per-turn block and the boundary-confirmation step
(A4, corrected). For the rest, the bold header sentence repeats while the sentences under it are skill-specific and would
stay skill-specific after any refactor. Three of the six shared reference files are byte-identical copies of canonical
files in `han-core` (A5), and that duplication is the vendoring convention rather than an accident. No controlled study
was found measuring a canonical reference plus a read against restated inline text for adherence; the practice rests on
platform guidance (A34) and an uncited community wiki (A40, low trust).

**Model tiering is already in place, so the obvious cheap lever has already been pulled.** Every agent in the roster
declares an explicit model tier. The mechanical ones already run on the cheapest: `codebase-explorer`,
`content-auditor`, and `project-scanner` are all `haiku`, and `readability-editor` is `sonnet` (A41). External studies
report 40 to 70 percent cost reduction from classifier-gated routing with small routing overhead (A24), and Anthropic's
own system tiers a large orchestrator over cheaper subagents (A12). The remaining candidates for downtiering are the
judgment agents running on `opus`, including `project-manager`, `junior-developer`, and `information-architect`, and no
evidence in this set speaks to whether their output survives a cheaper tier.

**One-question-per-turn has no evidence against it, and the nearest analog is about something else.** That study measured
accuracy when a task specification is revealed gradually across turns rather than all at once. It found a 39 percent
average drop and no recovery from an early wrong turn (A32) [single-source for this framing]. It does not measure
clarification cadence with a human operator. No study comparing batched to sequential clarification for outcome or cost
was found. The rule was also added deliberately five commits ago (A11).

**Prompt caching is the best-measured lever here and mostly out of the skill author's hands.** Cache reads cost a tenth
of the base input price and require a byte-identical prefix (A22, corroborated on magnitude by A23). Whether a skill's
instruction payload lands in a stable cacheable prefix is a harness decision, not something a `SKILL.md` controls.

**Scripting the mechanical gates costs more to build than it first looks.** No `han-planning` skill currently runs a
script, and none of the five carries a general shell grant; each declares a narrow allowlist such as `Bash(find *)`,
`Bash(mkdir *)`, and `Bash(cp *)` (A42). Adding scripts means authoring them, widening each skill's tool grant, and
writing tests for them under the repo's own test convention.

## Options to Consider

### O1: Cut the top-band agent rosters and round caps

- **What it is:** Reduce the specialist count and the sequential round cap at the larger bands, starting with
  `plan-implementation` (six to eight agents across up to three rounds) and `iterative-plan-review` team mode. Keep the
  parallel first wave, which is the part that buys wall-clock time, and shrink the sequential rounds, which are the part
  that buys least.
- **Trade-offs:** This trades review breadth for cost directly, and the evidence says nothing about which specific
  reviewer's findings change a planning outcome in this repo. Cutting too far removes the perspective diversity that
  makes a review team worth dispatching at all. The honest sequencing is to measure a smaller roster against the current
  one on a real plan before committing to a permanent cap.
- **Rests on:** A6, A7, A12, A13, A18, A19, A20, A38
- **Evidence status:** corroborated

### O2: Turn the mechanical gates into scripts

- **What it is:** Replace the narrated deterministic checks with scripts the skill runs: the completeness gate's
  file-existence check, Pass B's "Unverified:" strip, and the cross-reference verification in `iterative-plan-review`
  Step 6.
- **Trade-offs:** Each script is new code to write, test, and maintain. Each one also widens the tool grant on the skill
  that runs it, which this repo treats as a reviewed decision rather than a drop-in change (A42). The gate logic also has
  to be genuinely deterministic; a check that needs judgment about whether a finding is design-dependent does not
  convert.
- **Rests on:** A9, A34, A36, A42, and A31 with A39 as thesis-level agreement rather than independent confirmation
- **Evidence status:** corroborated on the measured benefit (A34, A36); the enforcement-gap argument is single-source
  (A31)

### O3: Delete the readability self-check where the editor agent already ran

- **What it is:** Drop the six-criterion self-check from `plan-a-feature`, `plan-implementation`, and
  `plan-a-phased-build`, which each dispatch `readability-editor` and then run the check on the text the editor produced.
  Keep the check in `plan-work-items`, which runs no editor.
- **Trade-offs:** The self-check's sixth criterion is fact preservation, and dropping it leaves the editor's own
  fact-preservation ledger as the only guard. That is a real reduction in redundancy, which is the point, but it means
  trusting the editor's ledger. The supporting evidence for external verification being the pattern that works comes from
  a paper about structural correctness in generated diagrams, a different task from prose rewriting (A17).
- **Rests on:** A9, A15, A16
- **Evidence status:** corroborated on the harm from ungrounded self-critique (A15, A16); single-source and
  cross-domain on the positive case for external verification (A17)

### O4: Split the oversized instruction files, conditional content only

- **What it is:** Audit `plan-implementation`, `plan-a-feature`, and `iterative-plan-review` for content a run reads on
  some paths and skips on others, and move only that into flat references one hop from the entry file. Leave the
  unconditional operating principles and the boundary-confirmation step in place.
- **Trade-offs:** The payoff is unquantified until the conditional-versus-unconditional audit is done, and it may turn
  out that little of the 759, 707, and 512 lines is genuinely conditional. The nested form of this pattern backfires. One
  measured study found hierarchical disclosure sometimes collapsed accuracy entirely, and the platform guidance warns
  that files reached through more than one hop get partially read (A34, A35). Moving the scope-boundary rules out of the
  entry file would be the highest-risk version of this change, since that content is both unconditional and the newest
  deliberate addition (A11).
- **Rests on:** A1, A25, A26, A27, A29, A30, A33, A34, A35
- **Evidence status:** the adherence problem is corroborated (A25, A26, A27, A29, A30); the specific 500-line and
  one-hop shape is effectively single-sourced to vendor guidance (A34), with A33 being the same vendor speaking again

### O5: Collapse the genuinely duplicated prose into the owned reference files

- **What it is:** Move the two blocks that are near-identical across skills, the one-question-per-turn block and the
  boundary-confirmation step text, into the owned `han-planning` reference files and cite them.
- **Trade-offs:** The payoff is small, roughly the two blocks rather than the five the first draft counted (A4,
  corrected), and both blocks are unconditional, so the reference gets read every run anyway. The maintenance argument
  (one canonical statement cannot drift out of sync) is stronger than the token argument. No controlled measurement was
  found either way.
- **Rests on:** A4, A34, A40
- **Evidence status:** no direct measurement found; rests on vendor guidance plus a low-trust wiki

### O6: Compress the prose in place

- **What it is:** Tighten the wording across all five instruction files without removing any behavior.
- **Trade-offs:** The one independent replication measured about 8.5 percent savings against a claimed 65 percent, with
  no detectable impact on success, quality, or latency (A38). Safe, small, and a lot of editing for the return. It also
  risks stripping the connective tissue that keeps a procedural document followable, which A38 did not test for.
- **Rests on:** A38
- **Evidence status:** single source, though it is an independent replication of a vendor claim

### O7: Downtier the judgment agents to a cheaper model

- **What it is:** Move some agents currently on `opus` to `sonnet`, starting with the ones dispatched most often across
  the planning skills.
- **Trade-offs:** No evidence in this set speaks to whether these specific agents' judgment survives a cheaper tier. The
  mechanical agents where downtiering is safest are already on the cheapest tier (A41). One candidate stands out as
  worth testing: `plan-a-phased-build` dispatches exactly one agent, `information-architect`, and that agent runs on
  `opus`.
- **Rests on:** A41, A12, A24
- **Evidence status:** the general routing benefit is corroborated on direction (A12, A24); its application to these
  specific agents rests on no evidence

### O8: Leave one-question-per-turn alone

- **What it is:** Make no change to the escalation cadence.
- **Trade-offs:** Turn count is a real cost, and this option accepts it. If a later measurement shows batching does not
  hurt outcomes, this is the option to revisit.
- **Rests on:** A11, A32
- **Evidence status:** no evidence either way for the batching question

## Recommendation

- **Recommendation:** Adopt **O1** (cut the top-band rosters and sequential round caps) as the primary change, then
  **O2** (script the mechanical gates) and **O3** (delete the redundant self-check). Treat **O4** as a scoped follow-up
  that begins with an audit rather than an edit. Treat O5, O6, and O7 as low-payoff or unsupported, and adopt **O8** by
  leaving the escalation cadence alone. This is not a single-winner landscape; the changes compose.

- **Evidence basis:** O1 is the recommendation's load-bearing part and is corroborated from four directions. The
  best-documented source in the set, built from more than 1,600 annotated multi-agent traces, finds coordination rather
  than model capability dominates failure (A20). The platform vendor recommends starting with single agents and reports
  its own subagents spending more on coordination than work (A13). An interested vendor with the opposite commercial
  incentive still recommends the fewest agents possible (A19). And an independent replication establishes that agentic
  token cost lives in file reads, tool calls, and output rather than in instruction prose, which is what makes dispatch
  volume the right target and document trimming the wrong first move (A38). The specific claim that sequential rounds pay
  least rests on A18, which is single-source and could not be traced to its primary paper. Anthropic states the same
  without numbers (A13). The repository measurements of roster size and agent-definition size are codebase evidence
  (A6, A7).

  O2 rests on one independent measured source (A36, 17 models, up to 20 percent higher success and about 30 percent fewer
  steps) plus vendor guidance recommending the same (A34). Its enforcement-gap argument is single-source (A31, paper body
  not inspected), and A39 agrees on the thesis without confirming the numbers. Its implementation cost is codebase
  evidence (A42).

  O3 rests on two mutually corroborating sources on the harm from ungrounded self-critique (A15, A16) plus the codebase
  finding that the check runs on text an external editor already produced (A9). The positive case for external verification
  is single-source and from a different task domain (A17), so O3 is recommended on the harm evidence rather than on that.

  O4 is demoted from the first draft's flagship position. Its specific shape, a 500-line ceiling and one-hop references,
  is effectively single-sourced to vendor guidance with no ablation behind it (A34), and A33 is the same vendor rather
  than independent corroboration. The adherence problem it addresses is well corroborated (A25, A26, A27, A29, A30), but
  no evidence shows this particular fix solves it here, and the content driving the size overage is unconditional, so
  moving it saves no per-run tokens.

  What would change this recommendation: a before-and-after token and outcome measurement of one real plan run at the
  current top band against a reduced roster. Nothing in this research measures Han's own skills running, and that
  measurement would settle O1's size, O4's payoff, and O7's safety at once.

## Validation

### V1: The reference-file count for `iterative-plan-review` was wrong

- **Strategy:** Challenge the Evidence
- **Investigation:** Enumerated the directory and re-ran line counts.
- **Result:** Refuted. The directory holds three files totaling 225 lines, not four totaling 295. Every other per-skill
  sub-total in A3 checks out exactly.
- **Impact:** A3 corrected. The error does not favor any option, but it shows A3 was not re-derived from the repository
  at the cited number.

### V2: The duplication evidence was overstated

- **Strategy:** Challenge the Evidence
- **Investigation:** Read all five cited duplication sites.
- **Result:** Partially refuted. Only the bold header sentence repeats in three of the five cited blocks; the sentences
  under each header are skill-specific. One quoted phrase does not appear as quoted: `iterative-plan-review` reads "YAGNI
  is a first-class review pillar," not "first-class operating principle." The "visual material" block is not verbatim
  either, since `plan-a-feature` carries a sentence `plan-implementation` lacks.
- **Impact:** A4 corrected to two genuinely duplicated blocks. O5's expected payoff dropped accordingly, and O5 moved out
  of the recommended set.

### V3: Model tiering already exists and the research never looked

- **Strategy:** Challenge the Options Framing
- **Investigation:** Checked the `model:` frontmatter on every agent in the roster.
- **Result:** Refuted as originally framed. Every agent declares an explicit tier. `codebase-explorer` is already
  `haiku`, so half of the original option's own example was already done. `readability-editor` is `sonnet`.
- **Impact:** The option was rewritten as O7 and demoted to unsupported, and a new artifact (A41) was added. This was the
  cheapest directly checkable lever for the exact question asked, and the codebase pass missed it.

### V4: Splitting the instruction files does not address the size driver

- **Strategy:** Challenge the Recommendation
- **Investigation:** Cross-referenced the duplication sites against the step structure of each skill.
- **Result:** Confirmed as a gap. The content driving the size overage sits in the operating principles and Step 1.5, both
  of which run on every invocation. Moving unconditional content into a reference does not cut per-run tokens; it cuts
  the entry file's line count, which is a different thing.
- **Impact:** The first draft's flagship recommendation was demoted to O4 and rescoped to conditional content only, with
  an audit as the first step and an explicit exclusion for the scope-boundary rules.

### V5: The 500-line recommendation is one vendor speaking twice

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Traced each source cited as corroborating the file-splitting recommendation.
- **Result:** Confirmed. Two of the three cited sources share one vendor's provenance (A33, A34), and A33 carries no
  measurements. The one independent measured source (A35) measures retrieval accuracy on document navigation, not
  authoring-guideline adherence for gated procedures.
- **Impact:** O4's evidence status downgraded to effectively single-source for its specific shape. The first draft's claim
  that it was "corroborated by two or more independent sources" was removed.

### V6: The enforcement-gap citation was laundered into corroboration

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Compared what A31 and A39 each report.
- **Result:** Refuted as stated. A39 is a design proposal sharing A31's thesis, not an empirical replication, and reports
  no compliance figures. Labeling it corroboration turned a single-source, abstract-only numeric claim into a
  corroborated one.
- **Impact:** O2's evidence basis restated. Its measured support is A36 plus A34; the enforcement-gap argument is carried
  as single-source.

### V7: The verifier evidence for dropping the self-check crosses a domain gap

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Examined what A17 measures.
- **Result:** Confirmed as a gap. A17 measures a verifier catching structural correctness errors in generated diagrams, a
  formally checkable artifact. It says little about whether a prose-rewriting editor works as an external verifier.
- **Impact:** O3 now rests on the harm-from-self-critique evidence (A15, A16) rather than on A17's positive case, which is
  carried with its caveat.

### V8: Scripting the gates has an unstated implementation and permission cost

- **Strategy:** Challenge the Recommendation
- **Investigation:** Searched for script directories and read the tool grants on all five skills.
- **Result:** Confirmed. No `han-planning` skill runs a script, and each declares a narrow allowlist rather than a general
  shell grant.
- **Impact:** A42 added. O2's trade-offs now name the authoring, testing, and tool-grant cost, and the recommendation no
  longer treats it as a drop-in change.

### V9: The gate counts could not be independently confirmed

- **Strategy:** Challenge the Evidence
- **Investigation:** Attempted to verify the per-skill gate counts by text search.
- **Result:** Inconclusive. Text mentions are not a reliable proxy for distinct gates, and a full structural enumeration
  was out of scope for the validation pass.
- **Impact:** Carried as a remaining risk. If the gate counts are inflated the way A3's file count was, O2's scope
  shrinks.

### Adjustments Made

Validation changed both the results and the recommendation. Two codebase measurements were corrected (A3's file count,
A4's duplication claim). One new artifact was added after validation found the research had never inspected it (A41,
model tiering), and one more was added for implementation cost (A42). The first draft recommended splitting the
oversized instruction files as its load-bearing change. That recommendation was demoted to O4, rescoped to conditional
content only, and its evidence status downgraded. V4 showed it does not address the measured size driver, and V5 showed
its specific shape rests on one vendor. Cutting agent dispatch volume was promoted from the first draft's
lower-confidence group to the primary recommendation. It has the strongest corroboration in the set, and A38 shows
document trimming targets the wrong cost. The model-routing option was refuted as framed and rewritten as unsupported.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** No measurement of Han's own skills running exists anywhere in this research, so every cost claim
  about them is structural rather than observed. The per-skill gate counts in A9 were not independently re-derived, and
  one comparable count in the same evidence pass turned out wrong (V1, V9). Five web sources were reported as not
  directly inspected or not traceable to a primary source (A17, A18, A21, A31, A35), and one is an uncited community wiki
  (A40). Of these, A18 and A31 bear on the recommendation and are carried with explicit single-source caveats. Several
  supporting sources come from vendors with a commercial interest in the conclusion drawn from them (A12, A13, A19, A22,
  A33, A34, A37). The two vendor figures for the fan-out cost multiplier disagree and were not reconciled (A12, A13).
  Whether the duplicated-prose and oversized-file patterns are a suite-wide Han convention rather than a planning-specific
  problem was not checked, which matters for whether O4 and O5 should be scoped to `han-planning` at all.

## Sources

| ID  | Source                                        | Link / location                                                                                                | Retrieved  | Trust class | Summary (one line)                                                                                            | Evidence status                                     |
| --- | --------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ---------- | ----------- | ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| A1  | han-planning SKILL.md sizes                   | `han-planning/skills/*/SKILL.md`                                                                               | n/a        | codebase    | 759, 707, 512, 406, 309 lines; 2,693 total.                                                                    | corroborated (re-run in validation)                 |
| A2  | Shared planning references                    | `han-planning/references/`                                                                                     | n/a        | codebase    | Six files, 768 lines total.                                                                                    | corroborated                                        |
| A3  | Per-skill reference and template files        | `han-planning/skills/*/references/`                                                                            | n/a        | codebase    | 596 / 334 / 337 / 206 / 225 lines. Corrected per V1: iterative-plan-review is 3 files at 225, not 4 at 295.     | corrected by V1                                     |
| A4  | Duplicated operating-principle prose          | `han-planning/skills/plan-a-feature/SKILL.md:71`, `plan-implementation/SKILL.md:38`                            | n/a        | codebase    | Two blocks genuinely near-identical, not five. Corrected per V2.                                               | corrected by V2                                     |
| A5  | Byte-identical vendored references            | `han-planning/references/{config,yagni,evidence}-rule.md`                                                      | n/a        | codebase    | Three files identical to their `han-core` canonical copies, by convention.                                     | corroborated                                        |
| A6  | Agent rosters and round caps                  | `han-planning/skills/*/SKILL.md`                                                                               | n/a        | codebase    | plan-implementation runs 6 to 8 agents over up to 3 sequential rounds at its largest band.                      | corroborated                                        |
| A7  | Agent definition sizes                        | `han-core/agents/*.md`                                                                                         | n/a        | codebase    | Role definitions run 100 to 565 lines each.                                                                    | corroborated                                        |
| A8  | Artifact writes and read-backs                | `han-planning/skills/*/SKILL.md`                                                                               | n/a        | codebase    | Every written artifact is read back by a later step; the lightweight-mode exception was overstated per V3 note. | partially corrected in validation                   |
| A9  | Gate and self-check inventory                 | `han-planning/skills/*/SKILL.md`                                                                               | n/a        | codebase    | Three skills run a self-check on text the editor agent already rewrote; several gates are mechanical.           | counts unverified (V9)                              |
| A10 | Operator turn structure                       | `han-planning/references/operator-escalation-rule.md`                                                          | n/a        | codebase    | One question per turn, no end-of-run batch.                                                                    | corroborated                                        |
| A11 | Recent growth on this branch                  | `git log han-planning/`                                                                                        | n/a        | codebase    | Five commits added about 2,029 lines of scope-boundary machinery.                                              | corroborated                                        |
| A12 | Anthropic multi-agent research system         | https://www.anthropic.com/engineering/multi-agent-research-system                                              | 2026-07-30 | web         | ~15x chat-turn tokens; parallel subagents cut wall-clock up to 90%; Opus lead over Sonnet subagents.            | conflicts with A13 on multiplier                    |
| A13 | Anthropic on when not to use multi-agent      | https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them                                  | 2026-07-30 | web         | 3-10x tokens; start single; sequential phases belong in one agent.                                             | corroborated by A19, A20; conflicts with A12        |
| A14 | Augment Code on summarization cost            | https://www.augmentcode.com/guides/ai-agent-loop-token-cost-context-constraints                                | 2026-07-30 | web         | Summarizing between steps cut per-step tokens but tripled turns, netting 14%.                                  | single source (caveated)                            |
| A15 | Snorkel AI on the self-critique paradox       | https://snorkel.ai/blog/the-self-critique-paradox-why-ai-verification-fails-where-its-needed-most/             | 2026-07-30 | web         | Self-critique dropped one case from 98% to 57% accuracy on already-correct work.                               | corroborated by A16                                 |
| A16 | LLMs cannot self-correct reasoning yet        | https://beancount.io/bean-labs/research-logs/2026/04/28/llms-cannot-self-correct-reasoning-yet                 | 2026-07-30 | web         | Without an external signal, self-review corrupts as often as it fixes.                                         | corroborated by A15                                 |
| A17 | NOMAD verifier agent                          | https://arxiv.org/pdf/2511.22409                                                                               | 2026-07-30 | web         | A separate verifier improved structural correctness by over 27 points in UML generation.                        | single source; cross-domain (V7)                    |
| A18 | Google 180-configuration scaling study        | https://www.infoq.com/news/2026/02/google-agent-scaling-principles/                                            | 2026-07-30 | web         | Multi-agent degraded sequential-reasoning tasks 39-70%; helped parallelizable tasks 80.9%.                      | single source; primary paper not located            |
| A19 | Redis on why multi-agent systems fail         | https://redis.io/blog/why-multi-agent-llm-systems-fail/                                                        | 2026-07-30 | web         | Error compounding, conformity bias, monoculture; use the fewest agents possible.                               | corroborated by A20; interested party               |
| A20 | MAST failure taxonomy                         | https://arxiv.org/abs/2503.13657                                                                               | 2026-07-30 | web         | 14 failure modes from 1,600+ traces; coordination dominates, not model capability.                              | corroborated by A13, A19                            |
| A21 | ZS Associates pharma post-mortem              | https://finance.biggo.com/news/bfe736dd3f2a92b1                                                                | 2026-07-30 | web         | Four-agent pipeline replaced by one agent plus deterministic control plane.                                     | single source; trade press on a self-reported case  |
| A22 | Anthropic prompt caching docs                 | https://platform.claude.com/docs/en/build-with-claude/prompt-caching                                           | 2026-07-30 | web         | Cache reads at 0.1x input price; byte-identical prefix required.                                                | corroborated by A23                                 |
| A23 | Prompt caching in production                  | https://iron-mind.ai/blog/prompt-caching-claude-production                                                     | 2026-07-30 | web         | ~90% cost and up to ~85% latency reduction with high prefix repetition.                                        | corroborated by A22 on magnitude                    |
| A24 | Model routing cost studies                    | https://www.digitalapplied.com/blog/llm-model-routing-2026-cost-quality-optimization-engineering-guide         | 2026-07-30 | web         | Classifier-gated routing cuts 40-70% of cost with small routing overhead.                                      | corroborated on direction, single source per figure |
| A25 | Lost in the Middle                            | https://arxiv.org/abs/2307.03172                                                                               | 2026-07-30 | web         | U-shaped long-context performance; middle content is retrieved worst.                                          | corroborated by A26                                 |
| A26 | Chroma Research on context rot                | https://research.trychroma.com/context-rot                                                                     | 2026-07-30 | web         | Accuracy degrades 30-50% before the documented limit across 18 models.                                         | corroborated by A25                                 |
| A27 | When Instructions Multiply                    | https://arxiv.org/abs/2509.21051                                                                               | 2026-07-30 | web         | Satisfying all instructions degrades as instruction count rises, across 10 models.                             | corroborated by A29                                 |
| A28 | LIFEBench                                     | https://arxiv.org/abs/2505.16234                                                                               | 2026-07-30 | web         | Output-length compliance falls sharply past a threshold; long-context models do no better.                      | single source (adjacent axis)                       |
| A29 | AGENTIF                                       | https://arxiv.org/abs/2505.16944                                                                               | 2026-07-30 | web         | 707 real agentic instructions averaging 11.9 constraints; models perform poorly on dense constraints.           | corroborated by A27, A30                            |
| A30 | HANDBOOK.md long-context SOP benchmark        | https://arxiv.org/abs/2607.25398                                                                               | 2026-07-30 | web         | Best of 30 configurations passed 36.2% of checks on 20-124 page procedures.                                    | corroborated by A25, A29                            |
| A31 | The Compliance Gap                            | https://arxiv.org/abs/2605.01771                                                                               | 2026-07-30 | web         | Compliance was 0% by default and 97% only where each step's rationale was observable.                           | single source; paper body not inspected (V6)        |
| A32 | LLMs get lost in multi-turn conversation      | https://arxiv.org/abs/2505.06120                                                                               | 2026-07-30 | web         | Revealing a task spec across turns cost 39% accuracy; measures spec reveal, not operator cadence.               | single source for this framing                      |
| A33 | Anthropic on effective context engineering    | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents                              | 2026-07-30 | web         | Just-in-time context loading, compaction, notes to files. Guidance, no measurements.                            | same vendor as A34 (V5)                             |
| A34 | Anthropic skill authoring best practices      | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices                               | 2026-07-30 | web         | Entry file under 500 lines, references one hop deep, prefer scripts for deterministic operations.               | vendor guidance, no ablation (V5)                   |
| A35 | Is progressive disclosure all you need        | https://arxiv.org/html/2607.17598v1                                                                            | 2026-07-30 | web         | Flat disclosure scales context; the hierarchical form sometimes collapsed accuracy.                            | measures a different outcome (V5)                   |
| A36 | CodeAct                                       | https://arxiv.org/abs/2402.01030                                                                               | 2026-07-30 | web         | Executed code actions beat narrated ones by up to 20% success and ~30% fewer steps across 17 models.            | corroborated by A34                                 |
| A37 | Letta on filesystem-backed agent memory       | https://www.letta.com/blog/benchmarking-ai-agent-memory/                                                       | 2026-07-30 | web         | File-backed state reached 74% on LoCoMo without specialized retrieval.                                         | single source; interested party                     |
| A38 | JetBrains test of terse prompting             | https://www.infoworld.com/article/4193775/talk-like-a-caveman-prompts-save-tokens-but-far-less-than-promised.html | 2026-07-30 | web       | ~8.5% savings against a claimed 65%, with no detectable quality loss, across 86 real tasks.                     | independent replication of a vendor claim           |
| A39 | Autoformalization of agent instructions       | https://arxiv.org/abs/2606.26649                                                                               | 2026-07-30 | web         | Argues natural-language policy is unenforceable; proposes policy-as-code. No measurements.                      | thesis-level agreement with A31, not corroboration  |
| A40 | LLM agent anti-patterns wiki                  | https://github.com/oxbshw/LLM-Agents-Ecosystem-Handbook/blob/main/prompt_engineering/anti_patterns.md          | 2026-07-30 | web         | Names the long-system-prompt anti-pattern and "once is enough" for repetition.                                  | low trust; uncited, no measurements                 |
| A41 | Agent model tiers already declared            | `han-core/agents/codebase-explorer.md:8`                                                                       | n/a        | codebase    | Every agent declares a model tier; the mechanical ones are already `haiku`.                                     | corroborated (found in validation, V3)              |
| A42 | No scripts and narrow tool grants             | `han-planning/skills/plan-a-feature/SKILL.md:12`                                                                | n/a        | codebase    | No han-planning skill runs a script; each declares a narrow shell allowlist.                                    | corroborated (found in validation, V8)              |

### A20: MAST failure taxonomy (recommendation-bearing)

- **Link / location:** https://arxiv.org/abs/2503.13657
- **Retrieved:** 2026-07-30
- **Trust class:** web (outside the trust boundary)
- **Summary:** Builds a 14-failure-mode taxonomy from more than 1,600 annotated traces across seven multi-agent
  frameworks, with human annotator agreement of 0.88. The taxonomy spans three categories: system design and
  specification, inter-agent misalignment, and task verification and termination. It establishes that coordination and
  architecture, rather than base model capability, dominate multi-agent failure, so a stronger model does not on its own
  fix these failure classes. This is the most rigorously documented source in the set and the strongest support for
  cutting agent count before anything else.
- **Evidence status:** corroborated by A13, A19

### A38: JetBrains test of terse prompting (recommendation-bearing)

- **Link / location:**
  https://www.infoworld.com/article/4193775/talk-like-a-caveman-prompts-save-tokens-but-far-less-than-promised.html
- **Retrieved:** 2026-07-30
- **Trust class:** web (outside the trust boundary)
- **Summary:** An open-source terse-prompting technique claimed about 65 percent output-token reduction. JetBrains tested
  it across 86 real coding tasks. It measured about 30 percent on an early 10-task subset, falling to about 8.5 percent
  across the full set, because most token cost in a working agent comes from file reads, tool calls, and generated code
  rather than conversational padding. They found no detectable impact on task success rate, code quality, or execution
  time. This is the source that reorders the recommendation: it establishes both that prose trimming is safe and that it
  targets the wrong cost.
- **Evidence status:** independent replication of a vendor claim, showing the claim was directionally right and
  overstated by roughly seven to eight times

### A36: CodeAct (recommendation-bearing)

- **Link / location:** https://arxiv.org/abs/2402.01030
- **Retrieved:** 2026-07-30
- **Trust class:** web (outside the trust boundary)
- **Summary:** Across 17 language models on API-Bank and a curated benchmark, agents that emit and execute code actions,
  rather than free-text or structured-data actions, produced up to 20 percent higher task success. They also took about
  30 percent fewer steps on complex tasks. This is the measured support for converting the mechanical gates into scripts
  the skill runs rather than steps it narrates.
- **Evidence status:** corroborated by A34, which recommends the same practice from a different angle

### A15: Snorkel AI on the self-critique paradox (recommendation-bearing)

- **Link / location:** https://snorkel.ai/blog/the-self-critique-paradox-why-ai-verification-fails-where-its-needed-most/
- **Retrieved:** 2026-07-30
- **Trust class:** web (outside the trust boundary)
- **Summary:** Reports that self-critique passes are corrosive on work the model already got right. One cited case
  dropped accuracy from 98 percent to 57 percent, because a step primed to find fault invents discrepancies in correct
  answers. Self-critique does help on work the model got wrong. The distinguishing factor reported is external grounding:
  critique reliably helps only when tied to a signal the model cannot fake, such as a tool, a test, or a genuinely
  separate model. This supports deleting the self-check that runs on text an external editor agent has already produced.
- **Evidence status:** corroborated by A16

### A13: Anthropic on when not to use multi-agent systems (recommendation-bearing)

- **Link / location:** https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them
- **Retrieved:** 2026-07-30
- **Trust class:** web (outside the trust boundary; the vendor has a commercial interest in customers using its models,
  which makes advice to use fewer agents a signal against its own short-term interest)
- **Summary:** States that multi-agent implementations typically use three to ten times more tokens than single-agent
  approaches for equivalent tasks, a lower figure than the 15 times in A12 because the baseline differs. Names three
  legitimate reasons to add agents: context protection, parallelization, and specialization. States that sequential
  phases of one task share too much context and should stay in one agent, and that only genuinely independent paths
  justify splitting. Reports an internal test where subagents spent more tokens coordinating than doing the work. The
  stated guidance is to start with single agents and add complexity only for a measurable, specific constraint.
- **Evidence status:** corroborated by A19 and A20 on the direction; conflicts with A12 on the multiplier, recorded and
  not resolved

## Related documentation

- [Han research reports](./README.md) if present, otherwise the [repository root](../../README.md)
- [docs/evidence.md](../evidence.md) for what counts as evidence in Han and how strength is characterized
- [docs/sizing.md](../sizing.md) for how Han skills classify a run's size and roster
