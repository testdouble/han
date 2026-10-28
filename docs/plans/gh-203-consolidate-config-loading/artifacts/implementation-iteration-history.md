# Implementation Iteration History: Consolidate config loading (issue #203)

<!--
This file records how the implementation plan evolved across discussion rounds. Committed decisions live in
[implementation-decision-log.md](implementation-decision-log.md) and the primary plan lives in
[../feature-implementation-plan.md](../feature-implementation-plan.md). Specialist reports are verbatim in
round-1-test-engineer.md, round-1-software-architect.md, and round-1-junior-developer.md beside this file.
Size band: medium (two chosen specialists, round cap 2).
-->

## R1: Parallel specialist review

- **Specialists engaged:** test-engineer (TE-1..TE-9, deferred S1..S4), software-architect (SA-1..SA-12),
  junior-developer (JD-1..JD-12, OQ1..OQ8).
- **New input provided:** issue #203 verbatim (`../issue-203.md`), the maintainer's comment, `.discovery-notes.md`
  (measurements, prior unmerged attempts on `origin/han-config-skill` and `origin/research/plugin-config-discovery`,
  the OI-3 spike harness), and `scope-boundary.md`. No technical notes and no visual material exist for this work.
- **Claim ledger:**

  | #   | Claim (merged by substance)                                                                                                                                                                                                                                                             | Identifiers                               | State                                                                                                                                                                                 |
  | --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | C1  | A Skill-invoked sub-skill re-renders its probes and the 65-word block, so a chain holds several copies.                                                                                                                                                                                 | discovery measurement, JD summary         | Evidenced: observed in this run when `explanation-guidance` was invoked (`.discovery-notes.md` Measurements)                                                                          |
  | C2  | No recorded evidence of an inline data-fetch sub-skill failing; "both forms" has no citation.                                                                                                                                                                                           | JD-8, SA-11, discovery Gaps               | Evidenced (absence verified across guidance, plans, research, and git history); the maintainer may hold unrecorded evidence (OQ-6)                                                   |
  | C3  | The loader should surface raw file content under today's byte-identical labels, not resolved values.                                                                                                                                                                                    | SA-1                                      | Evidenced (config-rule.md precedence levels 1, 4, 5, 6 and the silent-ignore rule are per skill)                                                                                     |
  | C4  | The loader should emit a fixed marker line (`HAN_CONFIG_RESOLVED \| personal=... \| project=...`) plus resolved value lines, so a chained skill can see it already ran.                                                                                                                    | TE-4, JD-5                                | Disputed with C3 (two output shapes). See R2.                                                                                                                                         |
  | C5  | The two chain-target guidance skills live in `han-communication`, which does not depend on `han-core`, so a `han-core:load-han-config` is unreachable from exactly the chain the issue names.                                                                                           | JD-1, TE-7, SA-5, SA-6                    | Evidenced (manifests); SA-5's fallback sentence relies on the Skill tool's response to an uninstalled skill name: Unverified, not reachable with granted tools                          |
  | C6  | Rewire only the ~13 chain targets rather than all 45 skills.                                                                                                                                                                                                                             | JD-2                                      | Disputed with SA-3/SA-9 (35 rewired, 8 keep the block; the block has been swept 4 times since July and one sweep missed `pairing`, commit 0e5f44f). See R2.                           |
  | C7  | "#172's config half becomes one line inside han-config-dir.sh" has been true since #184; it is not a benefit of consolidation.                                                                                                                                                         | JD-3, SA-9                                | Evidenced (every probe already calls the script)                                                                                                                                      |
  | C8  | The issue's `context-hygiene.md:104` quote does not exist; figures 44/47, 24, 8, and "five-skill" are off (measured 45/45, 23, 7, ~13).                                                                                                                                                 | JD-4, SA-11                               | Evidenced (discovery Measurements)                                                                                                                                                    |
  | C9  | "If you have not already this run" is prose only: "run" needs a definition and a marker the model can see.                                                                                                                                                                              | JD-5, SA-4, TE-4, TE-7                    | Evidenced as a gap; SA-4 supplies the definition (a run begins at the person's invocation and includes every skill it invokes) and latest-wins                                       |
  | C10 | The trial has no pass criterion and no failure branch in the issue.                                                                                                                                                                                                                      | JD-7, TE-2, TE-3, SA-10                   | Evidenced as a gap; TE-2 supplies arms, counts, and criteria; SA-10 supplies the gate (stop after Phase A on any failure)                                                              |
  | C11 | `explanation-guidance` uses no config setting, so its block can be deleted outright.                                                                                                                                                                                                    | SA-5                                      | Evidenced (grep for every schema token returns 0 in its body)                                                                                                                         |
  | C12 | Whether `Skill` must be in `allowed-tools` is contradicted by 23 callers that omit it; enforcement is unknown.                                                                                                                                                                           | JD-9, SA-7, TE-3 (INL-NOGRANT arm)        | Anecdotal on enforcement; this run invoked a sub-skill from a caller without the grant and was not prompted, but the session's permission mode is unrecorded. Trial arm settles it.  |
  | C13 | Codex may not support Skill-to-skill calls or probes; rewired skills could lose config under Codex.                                                                                                                                                                                      | JD-9, SA-6, TE-3                          | Unverified: not reachable with granted tools. Mitigating evidence: 23 consumers already depend on a Skill call to `readability-guidance` under Codex today, so no new exposure class.  |
  | C14 | The maintainer's July branch planned the same loader and raised V9, V10, V11; the issue does not cite it.                                                                                                                                                                                | JD-10                                     | Evidenced (branch read); why it stopped is a maintainer question (OQ-8)                                                                                                               |
  | C15 | Definition of done must include: docs/configuration.md:7, CONTRIBUTING.md:181-182, han-config-dir.bats, config-rule.md (canonical + 12 copies), long-form doc + scent line + indexes, CLAUDE.md layout, skill-builder process, version bumps, guidance lag (V15), graceful-degradation.md:102. | JD-11, SA-8, SA-11, SA-12, TE-6           | Evidenced                                                                                                                                                                             |
  | C16 | Widening property 2 must stay bounded: name the config loader as the second validated case, not "values" in general.                                                                                                                                                                    | JD-12, SA-11                              | Evidenced; SA-11's wording ("content many consumers would otherwise duplicate ... leaves interpretation to the caller") is bounded                                                   |
  | C17 | The trial needs the OI-3 subagent harness; Skillwalker evals can host only a post-ship smoke eval.                                                                                                                                                                                      | TE-5                                      | Evidenced (tests.json fields); Unverified: the Skillwalker runner itself could not be inspected (not in package.json)                                                                 |
  | C18 | Sweep hazards: `ddd-analysis` wraps the paragraph differently; `pairing:49` and `project-discovery:112` cite "the probe above"; 0e5f44f shows a hand sweep missing a file.                                                                                                              | SA-3                                      | Evidenced (lines verified after the round)                                                                                                                                            |
  | C19 | All 13 config-rule.md copies stay; retiring them breaks 27 mid-body SKILL.md citations and 7 reference-file citations.                                                                                                                                                                 | SA-8                                      | Evidenced (counts measured by SA)                                                                                                                                                     |
  | C20 | Bats guards after the sweep: exact line once per consumer, old pieces absent from consumers, only the loader (plus old-block skills) carries probes/grant/Read sentence, loader has no `context: fork`.                                                                                  | TE-6, SA-10                               | Evidenced                                                                                                                                                                             |

- **Open Questions raised:**
  - OQ-1: Where does the loader live (`han-core` per the issue, or elsewhere), given C5? (JD OQ1, SA-6, TE-7)
  - OQ-2: Loader output shape: raw content under today's labels (C3) or a marker plus resolved values (C4)?
  - OQ-3: Sweep scope: 45 per the issue's step 4, chain targets only (C6), or 35 + keep (SA-6)?
  - OQ-4: What marker and what definition of "run" make the one-line hint checkable (C9)?
  - OQ-5: Trial pass criteria and the failure branch (C10).
  - OQ-6 (maintainer): is there unrecorded inline-failure evidence behind "both forms", and who reported the original
    failure, on which skill and version? (C2)
  - OQ-7: `Skill` grant enforcement and Codex behavior (C12, C13).
  - OQ-8 (maintainer): why did `origin/han-config-skill` stop? (C14)
  - OQ-9 (maintainer): #172 sequencing preference (issue's own open question; SA-10 gives three options).
- **Spec-maturity tags:** all 20 claims `plan-level`. No `spec-level` findings, no T# notes exist. Gate did not trip.
- **Contract pinning:** N at round end. Unpinned: the loader output shape (OQ-2), the "already resolved" marker
  (OQ-4). Pinned already: the consumer line (issue text, SA-3), the loader body (SA-2 sketch), the completion token
  (TE-1), the Bats assertions (TE-6/SA-10 counts).
- **Resolution source:** see R2 for every OQ.
- **Decisions produced:** D-5, D-7, D-9, D-10, D-11, D-12, D-14, D-15, D-16, D-17, D-18, D-19, D-20 (proposed in the
  R1 reports: SA-2 to SA-12, TE-1 to TE-6, JD-11, JD-12; each was later adjusted in R2 or at synthesis for the loader's
  placement and the counts).
- **Changed in plan:** Implementation Approach (What the loader surfaces, The line each consumer carries, The shared
  config rule and the resolver script, The trial, The guidance edits, The guards that replace the probe checks), Work
  Units and Sequencing, Definition of Done, Testing Strategy, Risks and Assumptions, Deferred (YAGNI), Specialist
  Handoffs for Implementation.
- **Next-step recommendation:** continue iterating. SA-6 named `system-architect` as a handoff for the dependency-graph
  option and Codex; OQ-1 through OQ-5 and OQ-7 are plan-level and unresolved.

## R2: Evidence resolution (no re-dispatch)

- **Specialists engaged:** none dispatched. Every open question was tried against evidence first, per Step 6; none
  needed a junior-developer reframing turn because the junior-developer's R1 report already supplied the plain-language
  framing, and none needed the user.
- **New input provided:** the plugin dependency graph measured after R1 (`.discovery-notes.md`, last section) and the
  line checks on SA-3's hazards.
- **Claim ledger (changes only):**
  - C4 vs C3 resolved: the loader surfaces raw content under today's labels (C3). The marker TE-4 asked for already
    exists without a new shape: the loader's own rendered body (its H1 and hand-back sentence) is in the caller's context
    after the call, and the two probe labels are byte-identical to the old block's, so a chained skill sees either. A
    resolved-values shape goes to Deferred (YAGNI) with TE-4's rationale as the reopen trigger.
  - C5 resolved: the loader lives in `han-communication`. Measured: `han-core` and `han-communication` each depend on
    nothing; 8 plugins (38 skills, including every chain target the issue and discovery name) depend on
    `han-communication`; 7 depend on `han-core` (35 skills, excluding both guidance skills). Placing it in `han-core`
    needs SA-5's unverified fallback sentence inside `readability-guidance`; placing it in `han-communication` needs no
    fallback and no dependency change. This departs from the issue's step 3 wording ("add `load-han-config` to
    `han-core`, beside `project-discovery`") on an implementation placement, with the issue's rationale (precedent for
    machine-written context) weighed against reachability of the exact chain the issue describes. Recorded as a full
    decision with a revisit criterion; surfaced in the closing summary for the user to overturn. Superseded in R3: the
    user chose `han-core` plus five new dependency edges (E1).
  - C6 resolved: rewire every skill that can reach the loader (38 reachable; 37 take the line, because
    `explanation-guidance` drops its block under C11 and carries no line; count corrected at synthesis) and keep the
    old block verbatim in the 7 that cannot
    (`project-discovery`, `pairing`, `han-feedback`, `work-items-to-linear`, `agent-builder`, `guidance`,
    `skill-builder`). The issue's step 4 asks for each consuming skill; SA-9's measured sweep history (4 sweeps, one
    missed file) is the evidence for single-sourcing beyond the chain targets; JD-2's chain-targets-only option is the
    recorded rejected alternative (it leaves two patterns side by side with no rule for new skills). The 7 keep the
    block because `han-plugin-builder`'s skills are vendored standalone by `guidance init` and the other 4 cannot
    reach `han-communication`. Superseded in R3: with the E1 edges, 44 skills carry the line and none keep the block.
  - C9 resolved: "run" pinned in config-rule.md per SA-4; the marker is the loader's rendered body (above); latest wins.
  - C10 resolved: TE-2's arms and criteria, SA-10's gate. Failure branch: Phase A (troubleshooting.md correction) and
    the `explanation-guidance` block deletion (C11) ship regardless; nothing else does.
  - C12: settled by the INL-NOGRANT trial arm in default permission mode (SA-7 pins both branches).
  - C13: stays Unverified, disposition `not reachable with granted tools`; recorded as a non-blocking open item and a
    maintainer question, with the no-new-exposure evidence.
  - The `system-architect` handoff SA-6 named was retired by evidence rather than dispatched: with the loader in
    `han-communication` no dependency edge changes, and the Codex concern is unverifiable from this repository by any
    specialist.
- **Open Questions raised:** none new. Remaining for the user or maintainer: OQ-6, OQ-8, OQ-9 (non-blocking; the plan
  carries them as open items with the recommended answers).
- **Spec-maturity tags:** all plan-level; gate not tripped.
- **Contract pinning:** Y. Loader output shape pinned to the rendered example in SA-1/SA-2; marker pinned to the
  loader's H1 `# Load Han Configuration`; consumer line pinned verbatim; completion token pinned (TE-1); Bats assertions
  pinned as counts (SA-10 gate, adjusted to 37 line carriers, 7 old-block skills, 8 script references; corrected at
  synthesis from 38, since 37 + 7 + `explanation-guidance` = 45).
- **Resolution source:** OQ-1 evidence (manifests); OQ-2 evidence (config-rule.md precedence) ; OQ-3 evidence (issue
  step 4 + sweep history); OQ-4 evidence (SA-4 + loader body); OQ-5 evidence (TE-2, SA-10); OQ-6 deferred to the
  maintainer (non-blocking); OQ-7 trial arm (C12) and Unverified (C13); OQ-8 deferred to the maintainer
  (non-blocking); OQ-9 deferred to the maintainer with SA-10's recommendation (non-blocking). Synthesis corrections,
  resolution source `synthesis (Step 8 evidence)`: the line-carrier count (37, not 38); SA-12's `CONTRIBUTING.md`
  pointer to `edit-for-readability` as the block to copy (it carries the line under D-6, so the doc points at one of
  the 7 old-block skills); SA-9's symlink set (`han-reporting` loses its symlink under D-1); the DEPTH-2 arm's N=6 and
  the `.loads` line grammar `LOADED | TRIAL_ID=<id> | by=<invoking skill name>`, which no report pinned (test-engineer
  confirms at Phase B).
- **Decisions produced:** D-1, D-2, D-3, D-4, D-6, D-8, D-13 (added); D-5, D-9, D-10, D-11, D-12, D-14, D-18, D-19
  (changed: plugin name, symlink set, counts, arms, phase contents, or doc wording moved to `han-communication`).
  Revised in R3 after E1: D-1 rewritten (loader in `han-core`, the R2 placement kept as its rejected alternative);
  D-21 and D-22 added; D-2, D-5, D-6, D-7, D-9, D-10, D-11, D-12, D-13, D-14, D-17, D-18, D-19, D-20 changed.
- **Changed in plan:** Outcome, User Stories, Constraints and Boundaries, Implementation Approach
  (Where the loader lives, What the loader surfaces, How a chained skill knows the config is already loaded, The line
  each consumer carries, Which skills change, The shared config rule and the resolver script, The trial, The guards
  that replace the probe checks), Work Units and Sequencing, Definition of Done, Risks and Assumptions, Open Items,
  Recommendation, Constraints and Boundaries, Testing Strategy, Deferred (YAGNI), Specialist Handoffs for
  Implementation.
- **Revised in R3:** the last four sections in the list above were added by the R3 revision. In Deferred (YAGNI), the
  entry "A new dependency edge for `han-core`, `han-feedback`, `han-linear`, or `han-plugin-builder`" was deleted,
  because the edges are now being added. OI-5 was removed from Open Items, resolved by E1.
- **Next-step recommendation:** go to synthesis.

## R3: User decision applied

- **Specialists engaged:** none dispatched. The plan was revised in place after the user, who wrote issue #203, answered
  the loader-placement question (E1).
- **New input provided:** the user's decision and its evidence: zero references to `han-communication` in
  `han-core/skills` and `han-core/agents`, the install-footprint investigation that cut that edge, plugin sizes
  (`han-communication` 196K, `han-core` 896K with 22 agents), and the doc surfaces that narrate the old dependencies.
  Read during the revision: `init-guidance.sh`, the five front-door READMEs, CLAUDE.md line 84, and the header comment
  of `test/codex-packaging.bats`.
- **Claim ledger (changes only):**
  - C5 re-resolved: the loader lives in `han-core`, and the five plugins without a `han-core` edge gain one, so every
    skill reaches it. The R2 resolution is kept as D-1's rejected alternative.
  - C6 re-resolved: 44 skills carry the line, 0 keep the block.
- **Open Questions raised:** none new. OI-5 is resolved by E1.
- **Spec-maturity tags:** all plan-level; gate not tripped.
- **Contract pinning:** Y. The consumer line is re-pinned to `han-core:load-han-config`; the counts are re-pinned to
  44 / 0 / 1; the dependency check covers every plugin.
- **Resolution source:** user (E1) for placement and the edges; evidence (`init-guidance.sh` read) for D-22.
- **Decisions produced:** D-21, D-22 (added); D-1 (rewritten, superseded design kept as a rejected alternative); D-2,
  D-5, D-6, D-7, D-9, D-10, D-11, D-12, D-13, D-14, D-17, D-18, D-19, D-20 (changed).
- **Changed in plan:** Outcome, Constraints and Boundaries, Implementation Approach (Where the loader lives, What the
  loader surfaces, The line each consumer carries, Which skills change, The shared config rule and the resolver script,
  The guards that replace the probe checks), Work Units and Sequencing, Definition of Done, Testing Strategy, Risks and
  Assumptions, Deferred (YAGNI), Open Items, Specialist Handoffs for Implementation, Recommendation.
- **Change notes:** the opening paragraph above `## Outcome` was rewritten. Work Units gained unit 7 for the edges, and
  the later units were renumbered 8 to 15. Risks and Assumptions changed RK-7's count to 44, added RK-8, and updated
  A1.
- **Next-step recommendation:** ship as planned. The dependency edges are the item the maintainer may decline.

## Unaudited evidence classes

- The Skill tool's behavior when a caller omits `Skill` from `allowed-tools` in default permission mode, supporting
  the `allowed-tools` decision. No specialist could run a live session; the trial's INL-NOGRANT arm measures it.
- Codex's support for context-injection probes and Skill-to-skill calls, supporting the Codex open item. No specialist
  could inspect it, because nothing in the repository documents it and no Codex session was available.
- The Skill tool's response to an uninstalled qualified skill name, supporting D-22's "no configuration" outcome for a
  vendored builder copy without `han-core`. No session without the target plugin installed was available.

## Escalation register

The planning run itself was autonomous: the confirmation turn was not taken, and every question was settled by evidence
or recorded as an open item with a recommended answer. One question was answered by the user after the plan was
written.

- **E1: Loader placement**
  - **Question:** Where does the loader live? The plan placed it in `han-communication` (OI-5), departing from the
    issue's step 3, which names `han-core`.
  - **Answer (the user, issue author):** "let's put it into han-core and make it a dependency of all other plugins so
    that we cover all skills. If maintainer declines, we can always refactor."
  - **Landed in:** D-1 and D-21; applied in R3.

## R4: Implementation record

- **Specialists engaged:** none; the plan was executed inline by the run that wrote it.
- **New input provided:** the trial result (`artifacts/trial/trial-report.md`): 99 same-context trials across 15 arms,
  zero early exits, every configured value applied, loader invoked exactly as each arm expected; the no-`Skill`-grant
  arm completed without a prompt or error in this session's auto permission mode (D-8 branch: no grant added).
- **Rulings taken during execution, each recorded in the ledger:** D-22 overruled, so `init-guidance.sh` strips the
  loader line from vendored builder copies and they run with no configuration; the planned SONNET-WORST arm was not
  run because the user directed every sub-agent to run on Opus, so model specificity stays unmeasured; the CFG-P fixture
  left the personal file's relative output path ambiguous in the harness consumer, both readings were accepted for
  that arm and later personal fixtures used an absolute path; the eval files committed in #218 are unformatted on
  `main`, so `npm run lint` rewrites them on every run and they were kept out of this branch.
- **Decisions produced:** D-8 resolved to its no-grant branch; D-22 superseded by the ruling above.
- **Changed in plan:** —
- **Next-step recommendation:** review the branch; the maintainer's answer on the five dependency edges (D-21) decides
  whether the superseded `han-communication` placement returns.

## R5: Loader reduced to a single probe

- **Specialists engaged:** none; applied inline on the user's direction.
- **New input provided:** the user's question why the personal file was a Read step while the project file was a
  probe, and their vote (E2) for one probe whose script resolves both files, prints them with `config-rule.md`, or
  says neither was found and lists the paths tried, plus trimming `config-rule.md` above `## Schema`.
- **Claim ledger (changes only):** the Read-step rationale in the old config-rule opening (a probe cannot prompt or
  degrade) rested on the probe text naming the path; with the path inside a script and the probe guarded, the refusal
  does not apply and the guard degrades a failed script to a sentinel. Recorded as D-23.
- **Decisions produced:** D-23 (new); D-2 superseded in its mechanism, its surfaced content unchanged; D-10 and D-11
  now name `load-han-config.sh` and `scripts/load-han-config.bats`.
- **Changed in plan:** Implementation Approach (What the loader surfaces), Implementation Approach (The shared config rule and the resolver script).
- **Next-step recommendation:** review the branch.

### E2: Should the loader keep a Read-tool step for the personal file, or be one probe?

- **Round:** R5
- **Answer:** "replace the full skill body with a single call to the probe. The probe resolves two configs. If either
  exists, it prints contents of config-rule.md and contents of configs. Otherwise, it says that when the skill was
  loaded, no project or personal config was found (and lists tried paths). Additionally, I vote to trim everything
  above ## Schema in config-rule"; and "han's call via `bash "${CLAUDE_PLUGIN_ROOT}/..."` works better than what's in
  ai-provision".
- **Landed in:** D-23; `han-core/skills/load-han-config/SKILL.md`; `scripts/load-han-config.sh`; `config-rule.md`.

## R6: Vendored rule copies retired

- **Specialists engaged:** none; applied inline on the user's direction.
- **New input provided:** the user asked why the twelve copies were not symlinks; a grep found 33 citations in 22
  files outside `han-core`, all of them now served by the rule the loader prints, and seven copies cited by nothing.
- **Decisions produced:** D-24 (new); D-9's re-sync step is moot.
- **Changed in plan:** Implementation Approach (The shared config rule and the resolver script).
- **Next-step recommendation:** review the branch.

### E3: Keep the twelve vendored config-rule.md copies, symlink them, or delete them?

- **Round:** R6
- **Answer:** "do it" (delete the copies and rewrite the citations, as recommended).
- **Landed in:** D-24.

## R7: Loader script moved into han-core

- **Specialists engaged:** none; applied inline on the user's direction.
- **New input provided:** the user noted that with the copies gone, the script no longer needs a repo-root home, a
  symlink, or a fallback lookup for the rule.
- **Decisions produced:** D-25 (new).
- **Changed in plan:** Implementation Approach (The shared config rule and the resolver script).
- **Next-step recommendation:** review the branch.

### E4: Keep the repo-root script and symlink, or move the script into han-core?

- **Round:** R7
- **Answer:** "we can stop symlinking the script and move it and its test to han-core, plus remove fallback rule
  lookup."
- **Landed in:** D-25.


## R8: Second trial against the shipped loader

- **Specialists engaged:** none; run inline on the user's direction.
- **New input provided:** the second trial result (`artifacts/trial2/trial-report.md`): 48 same-context trials across
  10 arms against `han-core:load-han-config` as shipped (single probe, installed from a local marketplace, reached by
  its cross-plugin name), zero early exits, every configured value applied, every tester reporting the invocation
  sequence its arm expected. This closes the first trial's stated gap, that the copy ran as a project skill.
- **Rulings taken during execution:** the shipped loader carries no `.loads` side-effect step, so the invocation
  sequence was taken from each tester's self-report rather than a file; three plumbing runs made before the harness
  skills were linked into the main checkout's `.claude/skills/` were discarded and not counted.
- **Decisions produced:** none; D-12's pass criterion applied unchanged.
- **Changed in plan:** —
- **Next-step recommendation:** open the pull request.

### E5: Run a second trial against the shipped loader before opening the pull request?

- **Round:** R8
- **Answer:** "let's run a trial on opus, just to be safe."
- **Landed in:** `artifacts/trial2/`; the trial citations in `skill-composition.md`, `troubleshooting.md`, and
  `han-core/docs/skills/load-han-config.md`.
