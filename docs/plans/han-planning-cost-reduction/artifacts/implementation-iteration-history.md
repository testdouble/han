# Implementation Iteration History: Cheaper, Faster Planning Runs

Round-by-round record of the specialists engaged, the claims they made, how each was classified, and what resolved it.
The plan itself is [../feature-implementation-plan.md](../feature-implementation-plan.md); committed decisions are in
[implementation-decision-log.md](implementation-decision-log.md).

Team size: **medium** (round cap 2, team cap 4 to 5). Team: `han-core:project-manager` (synthesis only),
`han-core:junior-developer`, `han-core:adversarial-security-analyst`, `han-core:test-engineer`,
`han-core:software-architect`.

No `feature-technical-notes.md` exists for the source specification, so no `T#` mechanics constrain this plan and the
`T#-contradiction` classification does not apply. The spec-maturity gate therefore reduces to the `spec-level` threshold
alone.

## Coverage note

The run received no visual material, so Pass C had nothing to check against and no finding can rest on uninspected design
material. The boundary record's Visual Material Received section reads `None received`.

Two evidence classes no specialist could audit, both recorded rather than resolved:

1. **How this host expands a skill-directory variable inside a permission prefix, and inside a Bash argument.** Raised
   independently by `adversarial-security-analyst` and `software-architect`. It lives in the host runtime, not this
   repository. Every finding resting on it is labeled `Unverified` and carries no blocking severity.
2. **A real two-folder `plan-work-items` run's pair of boundary records.** No plan folder in this repository exercises the
   split-folder case, so `R1-C7` rests on the rule's text rather than on an observed run.

## R1: Round 1, parallel specialist review

- **Specialists engaged:** `han-core:adversarial-security-analyst` (findings `S-8` to `S-14`),
  `han-core:test-engineer` (findings `T1` to `T11`), `han-core:software-architect` (findings `A1` to `A7`).
  `han-core:junior-developer` was not dispatched this round; see the note at the end of this entry.
- **New input provided:** the source specification, its decision log and findings, the boundary record, and
  `.discovery-notes.md`. Each brief carried its own domain sections inline plus paths for everything else.

### Claim ledger

| ID       | Claim                                                                                                                                                   | Raised by    | State                                            | Spec-maturity |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | ------------------------------------------------ | ------------- |
| `R1-C1`  | The design-image check gets four per-skill copies, not one shared plugin-level copy                                                                     | `A1`         | Evidenced                                        | plan-level    |
| `R1-C2`  | Scripts must be omitted from the permission frontmatter, because a prefix cannot match the expanded absolute path                                       | `A4`         | Evidenced                                        | spec-level    |
| `R1-C3`  | The five permission declarations should be added, naming the script's invocation path                                                                   | `S-13`       | Disputed                                         | spec-level    |
| `R1-C4`  | The four prose instances are not the same check; the differences belong in arguments, not in four script bodies                                         | `A2`         | Evidenced                                        | plan-level    |
| `R1-C5`  | One test file covering the canonical copy plus a drift assertion over the other three, not four duplicated test files                                   | `A5`         | Evidenced                                        | plan-level    |
| `R1-C6`  | The cross-reference check is one copy in one skill, with no shared plumbing, and is materially larger work than its twin                                | `A6`         | Evidenced                                        | plan-level    |
| `R1-C7`  | `plan-work-items`'s this-run-only gate has no representation in the record format, so its check has undefined behavior                                  | `A3`, `S-12` | Evidenced, `Unverified` on the observed-run half | plan-level    |
| `R1-C8`  | A third encoding of the accepted file set is accepted; do not extract a shared constant here                                                            | `A7`         | Evidenced                                        | plan-level    |
| `R1-C9`  | Extraction-by-pattern satisfies the allow-list requirement while making every refusable row invisible, reintroducing the vacuous pass                   | `S-8`        | Evidenced                                        | plan-level    |
| `R1-C10` | The accepted shape must be pinned to the boundary rule's own example, which carries the folder prefix and backticks                                     | `S-9`        | Evidenced                                        | plan-level    |
| `R1-C11` | The hosted-link branch must be a leading-anchored literal match on the recorded marker                                                                  | `S-10`       | Evidenced                                        | plan-level    |
| `R1-C12` | The cross-reference check builds patterns from document text, which is its own injection surface                                                        | `S-11`       | Evidenced                                        | plan-level    |
| `R1-C13` | The sanitizing boundary lives in the script, and the artifact write the skill performs bypasses it                                                      | `S-14`       | Evidenced                                        | plan-level    |
| `R1-C14` | Exit status carries the outcome; prose never does                                                                                                       | `S-14`       | Evidenced                                        | plan-level    |
| `R1-C15` | Eleven of the spec's thirteen edge-case rows are check behavior; two are not testable at all                                                            | `T1`-`T11`   | Evidenced                                        | plan-level    |
| `R1-C16` | The prose-edit majority (expert counts, checklist removal, repeat-count correction) is not observable by any test, and no test should pretend otherwise | `T` §3       | Evidenced                                        | plan-level    |
| `R1-C17` | The permission-declaration line's presence and shape is the one prose edit worth a test, being a structured frontmatter field                           | `T` §3       | Evidenced                                        | plan-level    |

### Disputed claim, resolved by evidence

`R1-C3` against `R1-C2`. `adversarial-security-analyst` recommended adding five permission entries naming each script's
invocation path. `software-architect` found a written rule saying such an entry cannot match and must be omitted.

Resolved in favor of `R1-C2`, by evidence the skill verified directly rather than taking on either specialist's word:

- `han-plugin-builder/skills/guidance/references/skill-building-guidance/script-execution-instructions.md:67-75` states
  that `Bash()` patterns are prefix matches, that the runtime command begins with the expanded absolute skill-directory
  path, that "the prefix won't match," and therefore: "omit them from `allowed-tools`. Scripts typically run once per skill
  invocation, so a single user approval is acceptable."
- A survey of every skill in the repository that invokes a script found nine such skills and **none** declaring its own
  script. `han-reporting/skills/html-summary/SKILL.md` runs a script while declaring `allowed-tools: Read, Write`, with no
  Bash permission at all.

`adversarial-security-analyst` did not find this file; its own finding records that no in-repo precedent exists for
declaring a script permission, which is consistent with the rule rather than contradicting it. Its accompanying warning
stands and is kept: whatever the plan does, it must not widen the prefix to `Bash(bash *)`, `Bash(sh *)`, or
`Bash(*.sh *)`, because each auto-approves arbitrary shell for the rest of the run in skills that also hold write access.

### Spec-maturity assessment

- `spec-level` findings: **1** (`R1-C2`), raised by **1** specialist. `R1-C3` is the same subject from the opposite
  direction and is resolved, not carried.
- `T#-contradiction` findings: **0**, and the classification does not apply — no technical-notes file exists.
- **The spec-maturity gate did not trip.** It requires either two `T#`-contradictions from two specialists, or five
  `spec-level` findings from three specialists. Neither threshold is near. `han-core:project-manager` was therefore not
  called in facilitation mode this round, per the skill's rule reserving that call for a gate trip.

`R1-C2` is a genuine contradiction between the specification and the repository's own written guidance, so it routes
through the normal Open Questions path and the operator decides. It is not evidence the specification is immature: the
behavioral decision it rests on (declare narrowly, never grant broad execution) survives either resolution. What is
contradicted is the claim about what the declaration buys.

### Open Questions

| ID     | Question                                                                                                                                                                                                            | Resolution source     |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| `OQ-1` | The specification says declaring the permission prevents a mid-run interruption. The repository's guidance says such a declaration cannot match and must be omitted, accepting one approval per run. Which governs? | escalated to operator |
| `OQ-2` | Does `plan-work-items` write inherited visual-material rows into the record beside its own deliverable, or only rows for material its own run received?                                                             | evidence (see below)  |

`OQ-2` was resolved without escalation. Both specialists that raised it proposed the same resolution independently, and it
is the strictly simpler one: the skill writes only the rows for material its own run received, and names the inherited
record's path in Record Provenance, which `planning-boundary-rule.md:36-37` already requires. That makes the record beside
the deliverable self-consistent, so the whole-record check is correct with no script change and no new column or flag. The
`Unverified` half of `R1-C7` stands: no repository plan folder exercises the split-folder case, so this rests on the rule's
text rather than an observed run.

### Next-step recommendation

`continue iterating` — one Open Question (`OQ-1`) requires operator input. No specialist named another specialist as a
needed handoff, and no plan-level question remains unresolved by evidence.

### Note on the generalist

`han-core:junior-developer` is on the team and was not dispatched in Round 1. The three specialists returned findings that
were overwhelmingly `Evidenced` rather than `Anecdotal`, with one Disputed pair the skill settled from the repository
itself. The generalist's value is reframing a question that evidence cannot settle, and Round 1 produced exactly one such
question, which is a direct contradiction between two documents rather than an ambiguity a reframing would dissolve.
Dispatching it is reserved for Round 2 if the operator's answer to `OQ-1` opens a question evidence cannot close.

- **Decisions produced:** D-1, D-2, D-3, D-4, D-5, D-6, D-7, D-8, D-9, D-10, D-11, D-13, D-14, D-15, D-16, D-17,
  D-18, D-19. `D-12` was raised this round as the disputed pair `R1-C2` / `R1-C3` and was not committed until R2.
- **Changed in plan:** Implementation Approach (all five subsections), Work Units and Sequencing, Definition of Done,
  Testing Strategy, Security Posture, Risks and Assumptions, Deferred (YAGNI), Open Items.

## Escalation register

| Question asked                                                                     | Answer received                                           | Where it landed                                                                                                                                           |
| ---------------------------------------------------------------------------------- | --------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `OQ-1`: does the permission declaration stand, or does the repository rule govern? | "go with recommendation" (follow the repository guidance) | `D10` in [implementation-decision-log.md](implementation-decision-log.md); the specification's `D10`, Preconditions, User Interactions, and Coordinations |

## R2: Resolution round

- **Specialists engaged:** none. This round resolved the one Open Question Round 1 left open and ran the YAGNI and scope
  sweep. No specialist named a handoff, and no new claim entered the ledger.
- **New input provided:** the operator's answer to `OQ-1`.

### Open Question resolved

`OQ-1` is closed by operator input. The operator chose to follow the repository's own authoring guidance: no skill declares
its check in the permission frontmatter, the operator approves the check once per run, and the specification's claim about
what a declaration buys was corrected rather than kept.

That correction reached four places in the specification (Preconditions, the note under the skill table, the User
Interactions error-states entry, and the Coordinations permission row) and rewrote `D10`, which was renamed. The
specification's own findings file records it as `S3` under findings found after the review round closed, so a later reader
can see that a presented-as-finished specification changed at plan stage and why.

### Next-step recommendation

`go to synthesis`. No Open Question remains, no specialist named a handoff, and every plan-level claim is resolved by
evidence. The loop exits after two rounds against a cap of two, without needing the second specialist wave.

- **Decisions produced:** D-12 (committed on the operator's answer, closing the R1 dispute), D-11 (changed: replaced
  with the simpler refusal form), D-18 (changed: the permission-frontmatter test was dropped, because `D-12` removed the
  field it would have asserted). D-2, D-3, D-13, and D-14 were re-tested by the sweep and confirmed unchanged.
- **Changed in plan:** Constraints and Boundaries, Implementation Approach, Security Posture, Testing Strategy,
  Definition of Done, Deferred (YAGNI), Cut for Scope, Risks and Assumptions.

## YAGNI and scope sweep (Step 7.5)

Walked every claim in R1's ledger, every Open Question that proposed adding an artifact, and every specialist
recommendation that survived the loop. Three gates: evidence, simpler-version, and scope.

### Items the sweep changed

| Item                                                                    | Failure                    | Resolution                                                                                                                                                                                                                                                                  | Source                                 |
| ----------------------------------------------------------------------- | -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| A test asserting each skill's permission frontmatter declares the check | Evidence test, now vacuous | **Dropped.** The operator's answer to `OQ-1` removed the declarations this test would assert. It was the one prose edit worth testing precisely because it was a structured field; with no declaration there is no field.                                                   | `R1-C17` (`han-core:test-engineer` §3) |
| Echoing the offending cell's value on every refusal                     | Simpler-version test       | **Replaced with the simpler form** the same specialist proposed as primary: identify a refusal by row number plus the item's name, and echo the value only where the operator needs it, through the bounded transform. Less untrusted text crosses the boundary by default. | `R1-C13` (`S-14`)                      |

### Items the sweep confirmed rather than changed

Each cleared the evidence test with a cited artifact, and each is already the simpler of the alternatives considered.

- **Four per-skill copies of the design-image check** rather than one shared copy: a written rule requires it
  (`script-execution-instructions.md:77-81`), and four copies is the structurally simpler shape.
- **One test file with a drift assertion** rather than four duplicated test files: the specialist cited measured friction,
  and the skill confirmed it. `han-coding/skills/code-review/scripts/detect-review-context.bats` names three copies in its
  own header comment while only two exist, so a sync note has already drifted at two copies in this repository.
- **Two positional arguments** on the design-image check: three of its four call sites already resolve the folder
  differently, and `D13` requires the caller rather than the script to choose which record is read.
- **A one-sentence convention in `plan-work-items`** rather than a provenance column or a scope flag: resolves `OQ-2` with
  no format change and no configuration knob.
- **A third encoding of the accepted file set with a citing comment** rather than a shared constant: the boundary rule
  prescribes exactly that remedy, and the set has one commit of history.

### Scope gate

No new cut. The specification's own scope gate already produced six cut entries, and every item this plan adds is a
necessity of what the boundary asks for rather than an unrequested subsystem. Three items were tested against the floor
specifically, because each could look like added scope: the drift assertion is a necessity of the four-copies decision, the
stale repeat-count correction is a necessity of committing to the current ceilings, and the `plan-work-items` convention is
a necessity of the check being correct in one of its four callers. None is cut.

### Items the specialists declined on their own, carried forward with triggers

Recorded so the plan's deferred section is complete rather than re-derived: a plugin-level shared scripts directory; a
shared check harness or output-formatting library across the two scripts; a shared Bash constant for the accepted file set;
a `--this-run-only` flag; a shared validation or sanitizing helper; JSON output; a configurable extension allow-list or
strict mode; and an audit trail of refused rows beyond what `D12` already requires. Each carries a reopening trigger in the
plan's deferred section.

## Post-synthesis correction

One specialist recommendation survived the loop and did not reach the plan. `han-core:software-architect` (`A6`) asked
that the shared output shape be "stated once in the plan so both scripts and both test files use the same vocabulary,"
and `han-core:test-engineer` needed that same shape to write assertions against the three-outcome contract. Synthesis
carried the exit-status half of the contract into `D-9` and dropped the printed shape.

Restored to the plan's Implementation Approach as a named convention with the key set spelled out, alongside the note
that it is a convention rather than shared code. No decision changed; `D-9` already owned the outcome contract, and this
is the detail it referenced without stating.

## Open items closed after synthesis

| Item   | Question put to the operator                                               | Answer                                                                                                                                                      | Where it landed                                                                                                                                                                                                                        |
| ------ | -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `OI-1` | Do the derived expert counts for `iterative-plan-review` stand, or change? | "OI-1 is fine as is. mark resolved."                                                                                                                        | Closed in the plan's Open Items, the specification's Open Items, and work unit 2's justification. `D2` is unchanged and is the count to build.                                                                                         |
| `OI-2` | Does the unmeasured plan-quality trade stay open, or defer?                | "OI-2 requires this to be implemented before i can test it. note that and mark as deferred until after implementation. i'll open new work if needed, later" | Deferred in the plan's Open Items, the specification's Open Items, and assumption `A6`. The sequencing constraint is now stated: the comparison needs the reduced counts to exist first. The operator owns opening any follow-up work. |
| `OI-3` | Does the unanswerable host-expansion question stay open?                   | "mark this as resolved by deferral"                                                                                                                         | Closed by deferral in the plan's Open Items and assumption `A3`. The question is recorded as still unanswered, with the reopen condition named: a proposal to replace the four per-skill copies with one shared copy.                  |
| `OI-4` | Does the unobserved two-folder convention stay open?                       | "resolved as deferred until we see the problem"                                                                                                             | Closed by deferral in the plan's Open Items and assumption `A4`. Work unit 8 ships the convention unchanged, with the recognizable symptom named as the reopen condition.                                                              |

## Implementation notes

Built in the order the plan sequenced: the five prose-only units first, then the design-image chain, then the
cross-reference check. Every Definition of Done line was verified rather than assumed. `npm test` runs 61 tests, all
passing; `npm run lint` is clean.

**One deviation from the plan, made simpler rather than larger.** The plan called for four copies "byte-identical except
for a mutual comment naming the other three," following the precedent in `han-coding`. Naming the other copies makes each
file differ from its siblings, so a drift test has to strip the note before comparing. The note is instead written
generically, identical in all four, so the copies are byte-identical with no exclusions and the drift test is a plain
`diff`. That is strictly stronger than what the plan asked for and satisfies the same Definition of Done line.

**Two test-writing corrections caught by running them.** A first attempt to prove the link branch fetches nothing emptied
`PATH`, which broke the script's own tools rather than proving anything; it was replaced with stub fetchers on `PATH`
that leave a marker if called, so "nothing was fetched" is asserted rather than assumed. Shellcheck then flagged literal
markdown backticks as command substitutions in both files, resolved with a scoped directive naming the reason rather than
by rewording the fixtures away from the real record format.
