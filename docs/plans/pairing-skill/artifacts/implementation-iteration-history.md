# Implementation Iteration History: pairing

Round-by-round record of the specialists engaged, what each raised, and how every open question was settled. Decisions
committed from these rounds are in [implementation-decision-log.md](implementation-decision-log.md); the plan itself is
[../feature-implementation-plan.md](../feature-implementation-plan.md).

## R1

**Specialists engaged:** `han-core:structural-analyst`, `han-core:test-engineer`, `han-core:junior-developer`. Launched
in parallel with domain-scoped briefs plus the discovery notes.

**Size:** Medium, two chosen specialists, round cap 2. Three plugins and four manifests put it past small; nothing
crosses a service, touches authentication or personal data, or moves data, so the large-band signals are all absent.

**New input provided:** The feature specification and its three artifacts, the discovery notes, and the recorded scope
boundary.

### Claim ledger

Merged by substance first. Findings raised independently by two specialists carry both identifiers.

| # | Claim | Raised by | Status | Where it landed |
| --- | --- | --- | --- | --- |
| I1 | The flag needs a carrier, and three of the five skills already have the mechanism | S3, S8, JD-002 | Evidenced, verified directly | D-1 |
| I2 | How control returns from a backing skill is the load-bearing unspecified mechanic | JD-001 | Partly unverified; general shape resolved from guidance, mid-run handback left open | D-2, and D-2's known gap |
| I3 | The faster-gear offer outlived the removal of its own premise | JD-017 | Evidenced | Deferred in the specification |
| I4 | The rule file's access mechanism was not settled by the decision that placed it | S4, JD-008, JD-016 | Evidenced | D-4 |
| I5 | Four descriptions must grow under a hard cap, and one has almost no room | T2, T6 | Evidenced, measured directly | D-7 |
| I6 | No precedent exists for detecting whether a sibling plugin is installed | JD-004, T7 | Unverified, resolved by removing the need | D-10 |
| I7 | The prose ladder yields three pieces regardless of size | JD-006 | Escalated | D-11, and plan phase 2 |
| I8 | A review round produces findings, not an artifact, and the stop contract has no shape for that | JD-010 | Evidenced | D-6 |
| I9 | The two highest-churn files in the repository are both flagged skills | S5, JD-015 | Evidenced | D-3 |
| I10 | Verification is entirely manual and was unplanned | JD-013, T8–T11 | Evidenced | D-9, plan verification section |
| I11 | A prose snapshot would fire on churn far more often than on a regression | S1 (deferral), JD-013 | Evidenced | D-9 |
| I12 | Granting the question tool at the parent would silently break every child's questions | JD-002 (secondary) | Evidenced, narrowed at synthesis | D-5 |
| I13 | The manifest format has no optional-dependency mechanism | S2 | Evidenced, verified at synthesis | D-10 |
| I14 | The specification said the flag reaches three plugins; it reaches two | JD-011 | Evidenced, corrected | Specification |
| I15 | Two decision-log entries still described three skills and one plugin | JD-012 | Evidenced, corrected | Specification decision log |
| I16 | Step 8 routed the in-place-fix branch to a pre-build ask on a piece already built | JD-007 | Evidenced, corrected | Specification |
| I17 | Both coding skills already gate when asked to review first, which a pairing invocation may trip | JD-003 | Open, non-blocking | OI-1 |
| I18 | The foundation plugin gains a second kind of responsibility | S6 | Accepted, already decided at specification stage | Plan, phase 6 |
| I19 | Five near-identical flag paragraphs risk drifting apart | S7 | Evidenced | D-2, D-9; plan phases 3 and 4 |
| I20 | The documentation tail is a phase, not a checklist item | JD-014 | Evidenced | Plan, phase 6 |

### Unverified findings

Three findings carried a disclosure that their author could not inspect the input the finding rests on. Under the
unverified rule none of them carries build-blocking severity, whatever their author's own severity rating said.

- **I2**, on how control returns: could not inspect whether a skill can end its turn mid-run and resume with its
  instructions still governing, because no running session exists in this repository.
- **I6**, on plugin detection: could not inspect the runtime plugin-discovery surface, for the same reason.
- **I4**, in part: could not inspect whether a skill in one plugin can read a reference file from another plugin's
  installed tree.

A fourth disclosure was checkable and I checked it. The generalist could not read the chunk-boundary research report and
raised the possibility that it already carries a test for a choice being expensive to walk back. It does not. The
framework there separates reversible from irreversible decisions and prescribes different review depth for each, but
defines no criterion for telling them apart. The report says as much itself, noting that the framework calibrates how
much scrutiny rather than where the boundary falls. The hopeful reading was wrong, so the criterion had to be authored
rather than lifted.

### Open questions and how each resolved

Nine were raised. One reached the operator.

**Resolved from evidence, without reframing:**

- **The flag's carrier.** Verified directly that `design-an-api`, `iterative-plan-review`, and `plan-implementation`
  already declare an `arguments` key, while `tdd` and `refactor` do not. The composition guidance independently
  prescribes forwarding arguments through a sub-skill call. Settled as D-1.
- **How control returns.** The composition guidance documents orchestration composition as supported, tells the caller
  to stay thin, and warns that the moment after a sub-skill call is when the calling model most often stops and treats
  the sub-skill's output as final. That settles the shape: the skill owning the boundary performs the stop, and the
  shared rule file is what makes every stop look alike. Settled as D-2, with the part the guidance does not cover
  recorded as a known gap rather than treated as answered.
- **The rule file's access mechanism.** Verified that the three existing shared rules are byte-identical across both
  consuming plugins and that the communication plugin uses the competing pattern with no copies at all. Both patterns
  are real; vendoring won because it matches what the five consuming skills already do. Settled as D-4, with the
  re-sync obligation recorded as a known gap rather than waved off.
- **Description budgets.** Measured all six with the script the description-length guidance ships. Settled as D-7.
- **Plugin detection.** Verified that every availability check in the suite probes for an external binary and that no
  plugin-detection example exists anywhere. Rather than invent one, the need was removed: the mode names its intended
  backing skill in the plan and reports a failed invocation. Settled as D-10.
- **The review-round stop contract.** A finding with its citation is already a checkable claim, which is what the stop
  contract asks for. Settled as D-6.
- **The faster-gear offer.** Synthesis had already struck the claim that a run of approvals means anything; the offer
  built on it survived. Deferred with a reopening trigger.

**Escalated to the operator:**

- **The prose ladder's granularity.** Not resolvable from evidence, because the research supplies no unit for prose at
  either granularity and the specification already rates this the Medium-confidence part of the design. Both failure
  shapes were concrete: three stops on a four-sentence reply, or one unreviewable middle rung on a long document, with
  the operator's own founding example landing on either side. See E-1.

**Left open, non-blocking:**

- **Whether a pairing invocation trips the existing review-first gate** in the two coding skills. Recorded as OI-1. It is
  settled by building the first flag insertion and observing the behavior, and the answer changes one paragraph in two
  skills rather than the design.

### Corrections applied to upstream records

Three errors in the specification and its decision log were found by the round and corrected rather than escalated,
because the underlying decisions were unambiguous and only the prose had gone stale.

- The specification said the flag reaches three plugins. It reaches two: three skills in `han-coding` and two in
  `han-planning`. This error was mine, introduced in the correction pass immediately before this round.
- Two decision-log entries still described three skills and named only `han-coding` as the plugin whose absence matters.
  Both plugins go missing independently, which widens the degradation case.
- The primary flow routed the in-place-fix branch back to the step that asks for a read before building, on a piece
  already built. Split into its two branches with distinct return targets.

### Corrections applied at synthesis

A reconciliation pass after the round re-checked every claim in the ledger against the three cited guidance documents
and against the plan. It changed no decision, and it changed what several of them rest on.

- **D-2 overstated the guidance.** The thin-orchestrator rule was cited as support for the design when the design runs
  against it: this mode carries a plan, a feedback record, and the person's position across every stop. The rule is now
  recorded as a named risk whose mitigation is the specification's written feedback record. The mid-run handback the
  flag depends on is outside anything the guidance covers, and is now a known gap on D-2 and a named paragraph in the
  plan rather than an implicit assumption.
- **D-5 misstated its own rule.** The prohibition on `AskUserQuestion` in `allowed-tools` is universal across every
  skill, not a parent-only concern, and the tool still works when left undeclared. The stacking effect is a second
  consequence rather than the whole reason, and its concrete victim is `design-an-api`, the one backing skill that calls
  the tool today.
- **I13 had no home.** It was recorded as landing in D-4's reasoning, which never carried it. Verified against the
  plugin-manifest reference that `dependencies` has no optional form, and moved it to D-10, where it does work.
- **I19 was mapped to D-2 and D-4 with no treatment of its own.** Its mitigation now appears where it acts: the
  insertion into each flagged skill points at the rule file rather than restating it, in both phase 3 and phase 4, and
  D-9's byte-equality check across the vendored copies is the automated half.
- **The plan had lost a mechanical check.** D-9 commits seven; the plan listed six, having dropped the byte-equality
  check on the vendored copies. Restored, and D-4's known gap corrected, since it claimed content equality was
  unchecked.
- **D-11 was absent from the plan.** The operator's escalation answer was recorded here and in the decision log but
  reached no plan section. It now lands in phase 2, where the mode is written.
- **Description budgets re-measured** with the script the description-length guidance ships. All six figures held.

### Spec-maturity

No technical-notes file exists for this feature, so the contradiction classification does not apply and the gate reduces
to the specification-level threshold alone. One finding qualified as specification-level, I7, and it was escalated and
answered within the round. The gate did not trip, and no facilitation pass was dispatched.

### Next-step recommendation

**Go to synthesis.** The round produced no unresolved blocking finding. Every open question is settled by evidence, by
operator answer, or recorded as non-blocking. The round cap was 2 and one round was used.

## Escalation register

### E-1: How should the prose fidelity ladder scale with the size of the writing?

- **Asked because:** A fixed three-rung ladder means three stops on a four-sentence reply, and on a long document the
  middle rung is one piece the size of the whole job, which is the outcome the mode exists to prevent.
- **Answer:** Per section once the work is long enough. Short work climbs the ladder once, whole. Longer work agrees the
  shape for the whole artifact first, then climbs the remaining rungs section by section, with the plan naming the
  sections up front. The operator chose this over a fixed three stops per artifact and over letting each proposed plan
  decide case by case.
- **Landed in:** [D-11](implementation-decision-log.md#d-11-the-prose-ladder-climbs-per-section-once-the-work-is-long-enough),
  and phase 2 of the plan.
