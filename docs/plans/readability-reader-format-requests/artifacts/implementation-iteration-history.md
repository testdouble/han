# Implementation Iteration History: The readability standard honors what the reader asked for

Round-by-round record of the specialists engaged, what each raised, and how it was resolved.

- **Plan:** [../feature-implementation-plan.md](../feature-implementation-plan.md)
- **Decisions:** [implementation-decision-log.md](implementation-decision-log.md)
- **Size:** Small. One subsystem, no cross-service work, no auth or data surface. One chosen specialist, one
  round. The file count was considered and rejected as a reason to escalate: a text sweep inside one standard
  is still one subsystem.
- **Rounds run:** 1 of 1

## R1

- **Specialists engaged:** `han-core:test-engineer` (TE, chosen), `han-core:junior-developer` (JD, standing
  seat). `han-core:plan-synthesizer` runs once at synthesis and is not a round participant.
- **New input provided:** The specification, its three companion artifacts, and the discovery notes carrying the
  verified file inventory.

### Verification passes

**Merge by substance.** Both specialists independently reached the versioning question and the
completeness-check question. Both independently recommended against a checked-in test, on the same grounds.
Those are recorded once each.

**Findings resting on an uninspected input.** One. JD-006 discloses that it could not inspect an actual release
run or the maintainer's intent behind the versioning document, because neither is in the repository, and rests
on commit-history precedent plus the release skill's own description. It is labeled `Unverified` and carries no
blocking severity. The planning run corroborated it against a standing instruction that no plugin version is
bumped unless a user or a skill explicitly asks, which points the same way.

**Design-dependent findings.** None. No visual material was supplied to this run.

**Coverage gaps.** None. Every input the specialists needed was in the repository.

### Claim ledger

| # | Claim | Raised by | Evidence class | Status |
| - | ----- | --------- | -------------- | ------ |
| C1 | The obvious completeness search can never return zero, and legitimate hits sit inside the plugin being swept | JD-001 | Codebase, verified | Accepted → [D-1](implementation-decision-log.md#d-1-the-exclusion-list-is-a-named-artifact-of-the-plan); exclusion list widened at synthesis |
| C2 | Most size-reference sites carry an identical block; the fidelity class has no drafted replacement at all | JD-002 | Codebase, verified | Accepted → [D-2](implementation-decision-log.md#d-2-two-replacement-sentences-are-drafted-once-before-the-sweep); count corrected at synthesis from nineteen to sixteen byte-identical plus four variants |
| C3 | The fidelity restatement appears in more than one role, and one of them stays true | TE-T2, JD-003 | Codebase, verified by the planning run | Accepted → [D-4](implementation-decision-log.md#d-4-the-fidelity-restatement-splits-by-grammatical-subject-not-by-block); split criterion corrected at synthesis |
| C4 | One site carries an overlapping pair that a line-level edit would scar | JD-004 | Codebase, verified | Accepted → [D-5](implementation-decision-log.md#d-5-one-site-takes-a-paragraph-rewrite-rather-than-a-sentence-swap) |
| C5 | The change touches seven plugins, not the nine the discovery notes claimed | JD-005 | Codebase, verified | Accepted; discovery notes corrected. Re-verified at synthesis: seven holds |
| C6 | Version bumps land at release, not on feature branches | JD-006 | Commit history + skill description | Accepted, `Unverified` → [D-6](implementation-decision-log.md#d-6-no-version-bump-and-no-changelog-edit-on-this-branch) |
| C7 | The intermediate state is real locally and sets commit order, but justifies no extra machinery | JD-007 | Codebase docs | Accepted → [D-3](implementation-decision-log.md#d-3-the-sweep-lands-before-the-canonical-files) |
| C8 | The standard's own closure sentence has no stated replacement | JD-008 | Codebase | Accepted, resolved without escalation → [D-8](implementation-decision-log.md#d-8-the-source-files-keep-their-own-count-every-quoting-site-drops-it) |
| C9 | A checked-in test for the sweep is machinery this change does not need | TE-S1, JD YAGNI | Repository precedent | Accepted → [D-7](implementation-decision-log.md#d-7-the-branch-scoped-documentation-check-is-kept-the-bats-script-is-not) |
| C10 | The behavior has no code entry point and cannot be tested automatically | TE-T4 | Domain reasoning | Accepted → [D-9](implementation-decision-log.md#d-9-behavior-is-checked-by-a-manual-smoke-pass-not-a-recorded-transcript) |
| C11 | A recorded transcript would break on churn rather than on regression | TE-S2 | Churn measurement | Accepted → deferred under YAGNI |
| C12 | A line-oriented inventory search misses wrapped sentences | TE-T2, planning run | Codebase, reproduced | Accepted → [D-10](implementation-decision-log.md#d-10-every-inventory-search-is-wrap-tolerant) |

### Corrections the round produced

Three numbers in the planning artifacts were wrong and were fixed in this round. Two of the three were
corrected again at synthesis; the third held.

1. **The fidelity class is twenty skill files, not eighteen.** A line-oriented search missed two files whose
   sentence wraps mid-phrase. The planning run made this error, and both specialists reproduced it
   independently before one of them caught the underlying cause. **Corrected again at synthesis:** the round
   then recorded eighteen of those twenty as changing and eight as untouched, which does not add up and does
   not match the corpus. See the synthesis corrections below.
2. **The change touches seven plugins, not nine.** The discovery notes carried an unchecked figure. **Held at
   synthesis.**
3. **The sweep is a subset of the fidelity sites, not all of them**, because one role of the restatement stays
   true. **Corrected again at synthesis:** the role split was recorded against the block a sentence sits in,
   and the corpus splits on the sentence's grammatical subject instead.

### Open Questions raised

| # | Question | Resolution source | Outcome |
| - | -------- | ----------------- | ------- |
| OQ1 | Does the standard's own closure sentence keep a number? | Evidence, from the specification's stated reason for going count-free | [D-8](implementation-decision-log.md#d-8-the-source-files-keep-their-own-count-every-quoting-site-drops-it). Not escalated: the specification's own rationale settles it |
| OQ2 | What replaces the fidelity guarantee sentence? | Plan structure | [D-2](implementation-decision-log.md#d-2-two-replacement-sentences-are-drafted-once-before-the-sweep) makes the drafting the first work unit with a recorded output, rather than leaving it implicit |

### Spec-maturity

No `T#` notes exist, so the contradiction classification does not apply and the gate reduces to the
`spec-level` threshold alone. No specialist raised a `spec-level` finding. Neither specialist proposed reopening
a behavioral decision, and both were told five were settled by the user directly. The gate did not trip, so no
facilitation pass ran.

### Next-step recommendation

**Go to synthesis.** Zero blocking Open Questions remain, both Open Questions resolved without escalation, and
no major finding survived the round.

### Round record

- **Decisions produced:** D-1, D-2, D-3, D-4, D-5, D-6, D-7, D-8, D-9, D-10
- **Changed in plan:** Outcome; User Stories; Constraints and Boundaries; Implementation Approach; Work Units
  and Sequencing; Definition of Done; Testing Strategy; Operational Readiness; Risks and Assumptions; Deferred
  (YAGNI); Open Items; Specialist Handoffs for Implementation; Sources and Plan Records; Recommendation

## Synthesis corrections (Step 8)

The synthesis pass re-verified every count in the plan against the repository with wrap-tolerant searches,
rather than carrying the round's figures forward. Five held, three did not, and two surfaces were missing from
the inventory entirely.

### Counts checked

| Claim in the plan | Verified | Result |
| ----------------- | -------- | ------ |
| 21 size-reference skill files | 21 files, 25 occurrences | Holds |
| 7 plugins touched | `han-coding`, `han-documentation`, `han-github`, `han-planning`, `han-reporting`, `han-research`, `han-communication` | Holds |
| 6 positional references | 6 `SKILL.md` files name criterion 6 | Holds, with a seventh positional reference to criterion 5 found and deliberately excluded → [D-12](implementation-decision-log.md#d-12-only-the-positional-references-that-proposal-2-falsifies-are-replaced) |
| 19 sites carry the identical block | 16 byte-identical, 4 near-identical variants | Corrected in [D-2](implementation-decision-log.md#d-2-two-replacement-sentences-are-drafted-once-before-the-sweep) |
| 18 self-check fidelity sites | 20 sites carry the self-check restatement; 25 sites total name the standard as guarantor | Corrected in [D-4](implementation-decision-log.md#d-4-the-fidelity-restatement-splits-by-grammatical-subject-not-by-block) |
| 8 audience-frame sites left alone | 9 sites name the frame | Corrected in [D-4](implementation-decision-log.md#d-4-the-fidelity-restatement-splits-by-grammatical-subject-not-by-block) |
| 28 correction sites | 63 corrections across 28 quoting files | Corrected throughout the plan; the round's figure was a file count read as a site count |

### Surfaces added to the sweep

| # | Claim | Evidence class | Status |
| - | ----- | -------------- | ------ |
| C13 | Three quoting files outside the skill directories were absent from the inventory (`docs/concepts.md`, `CONTRIBUTING.md`, and a second occurrence in `docs/readability.md`) | Codebase, verified at synthesis | Accepted → [D-11](implementation-decision-log.md#d-11-the-sweep-covers-the-non-skill-quoting-surfaces-the-first-inventory-missed) |
| C14 | One skill enumerates the whole check as its own numbered list of six, so it does not pick the change up by reading the standard | Codebase, verified at synthesis | Accepted → [D-13](implementation-decision-log.md#d-13-the-one-hardcoded-enumeration-of-the-check-gains-the-seventh-criterion) |
| C15 | Work unit 4's justification rested on a future reordering, which is not accepted evidence | YAGNI gate | Accepted; justification restated on the evidence that does hold → [D-12](implementation-decision-log.md#d-12-only-the-positional-references-that-proposal-2-falsifies-are-replaced) |

### Open Questions raised at synthesis

| # | Question | Resolution source | Outcome |
| - | -------- | ----------------- | ------- |
| OQ3 | Do the fidelity restatements sitting in audience-frame paragraphs but naming the standard change or stay? | synthesis (Step 8 evidence) | Change. [D-4](implementation-decision-log.md#d-4-the-fidelity-restatement-splits-by-grammatical-subject-not-by-block) applies its own stated test to them. The specialist's counter-evidence about `readability-guidance` is unaffected and still holds |
| OQ4 | Does the specification's inbound-coordination claim, that no skill needs editing to receive the new check, hold for every skill? | synthesis (Step 8 evidence) | No, for exactly one skill → [D-13](implementation-decision-log.md#d-13-the-one-hardcoded-enumeration-of-the-check-gains-the-seventh-criterion). Recorded as a plan assumption rather than a contradiction, because the specification's claim is about skills that read the standard live and this one does not |

Neither question was escalated. Both were settled from evidence already in the repository, and neither reopens
a behavioral decision the specification settled.

### YAGNI and scope gates

Run over all nine work units, the five deferred items, the manual smoke pass, the branch-scoped documentation
check, and the `han-core:content-auditor` handoff.

- **Evidence gate:** One failure. Work unit 4's justification cited a future reordering. The unit survives on
  different evidence and the surviving fragment (the criterion 5 reference) is deferred with a reopening
  trigger.
- **Simpler-version gate:** No failures. Each committed item is already the smallest form that satisfies its
  evidence; the two candidates for a simpler version, a checked-in test and a recorded transcript, were already
  deferred in the round.
- **Scope gate:** No cuts. Every unit traces to work-item proposal 1 or 2 in
  [scope-boundary.md](scope-boundary.md), or is a necessity of one of them. Nothing inherited from the
  specification exceeds the boundary, and the boundary states no exclusions. The plan therefore carries no
  `## Cut for Scope` section.

### Synthesis record

- **Decisions produced:** D-11, D-12, D-13
- **Changed in plan:** Opening paragraph; User Stories; Constraints and Boundaries; Implementation Approach;
  Work Units and Sequencing; Definition of Done; Testing Strategy; Operational Readiness; Risks and
  Assumptions; Deferred (YAGNI); Open Items; Specialist Handoffs for Implementation; Recommendation; Summary

## Escalation Register

No question was escalated to the user during implementation planning or at synthesis. All four Open Questions
were settled from evidence already in the repository.

Five escalations were made during the specification stage that preceded this plan, and their register lives in
[team-findings.md](team-findings.md).

## Post-synthesis correction

After synthesis, the planning run verified the synthesizer's three new findings and found a fourth phrasing
variant of the fidelity guarantee that no inventory had covered. That made three consecutive inventory
corrections in one planning run, each from a search pattern narrower than the corpus. Rather than build a
fourth count, the plan gained a first work unit that builds the inventory from a documented pattern set and
records both. Recorded as [D-14](implementation-decision-log.md#d-14-the-inventory-is-built-by-the-plan-not-inherited-from-it),
which also supersedes the frozen site counts in work units 2 and 3.

## Completeness gate

Recorded here because the next skill in the chain reads this folder rather than the conversation.

- Every `D#` in [implementation-decision-log.md](implementation-decision-log.md) carries `Driven by rounds:`,
  `Dependent decisions:`, and `Referenced in plan:`.
- Both round entries above carry `Decisions produced:` and `Changed in plan:`.
- Every inline `([D-N](...))` link in the plan resolves to a heading in the decision log, checked at synthesis.
