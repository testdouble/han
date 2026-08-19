# Implementation Iteration History: The readability standard honors what the reader asked for

Round-by-round record of the specialists engaged, what each raised, and how it was resolved.

- **Plan:** [../feature-implementation-plan.md](../feature-implementation-plan.md)
- **Decisions:** [implementation-decision-log.md](implementation-decision-log.md)
- **Size:** Small. One subsystem, no cross-service work, no auth or data surface. One chosen specialist, one
  round. The file count was considered and rejected as a reason to escalate: twenty-eight text edits inside one
  standard is still one subsystem.
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
| C1 | The obvious completeness search can never return zero, and two legitimate hits sit inside the plugin being swept | JD-001 | Codebase, verified | Accepted → [D-1](implementation-decision-log.md#d-1-the-exclusion-list-is-a-named-artifact-of-the-plan) |
| C2 | Nineteen size-reference sites carry an identical block; the fidelity class has no drafted replacement at all | JD-002 | Codebase, verified | Accepted → [D-2](implementation-decision-log.md#d-2-two-replacement-sentences-are-drafted-once-before-the-sweep) |
| C3 | The fidelity restatement appears in two roles, and one of them stays true | TE-T2, JD-003 | Codebase, verified by the planning run | Accepted → [D-4](implementation-decision-log.md#d-4-the-audience-frame-sentence-is-left-unchanged) |
| C4 | One site carries an overlapping pair that a line-level edit would scar | JD-004 | Codebase, verified | Accepted → [D-5](implementation-decision-log.md#d-5-one-site-takes-a-paragraph-rewrite-rather-than-a-sentence-swap) |
| C5 | The change touches seven plugins, not the nine the discovery notes claimed | JD-005 | Codebase, verified | Accepted; discovery notes corrected |
| C6 | Version bumps land at release, not on feature branches | JD-006 | Commit history + skill description | Accepted, `Unverified` → [D-6](implementation-decision-log.md#d-6-no-version-bump-and-no-changelog-edit-on-this-branch) |
| C7 | The intermediate state is real locally and sets commit order, but justifies no extra machinery | JD-007 | Codebase docs | Accepted → [D-3](implementation-decision-log.md#d-3-the-sweep-lands-before-the-canonical-files) |
| C8 | The standard's own closure sentence has no stated replacement | JD-008 | Codebase | Accepted, resolved without escalation → [D-8](implementation-decision-log.md#d-8-the-source-files-keep-their-own-count-every-quoting-site-drops-it) |
| C9 | A checked-in test for the sweep is machinery this change does not need | TE-S1, JD YAGNI | Repository precedent | Accepted → [D-7](implementation-decision-log.md#d-7-the-branch-scoped-documentation-check-is-kept-the-bats-script-is-not) |
| C10 | The behavior has no code entry point and cannot be tested automatically | TE-T4 | Domain reasoning | Accepted → [D-9](implementation-decision-log.md#d-9-behavior-is-checked-by-a-manual-smoke-pass-not-a-recorded-transcript) |
| C11 | A recorded transcript would break on churn rather than on regression | TE-S2 | Churn measurement | Accepted → deferred under YAGNI |
| C12 | A line-oriented inventory search misses wrapped sentences | TE-T2, planning run | Codebase, reproduced | Accepted → [D-10](implementation-decision-log.md#d-10-every-inventory-search-is-wrap-tolerant) |

### Corrections the round produced

Three numbers in the planning artifacts were wrong and are now fixed.

1. **The fidelity class is twenty skill files, not eighteen.** A line-oriented search missed two files whose
   sentence wraps mid-phrase. The planning run made this error, and both specialists reproduced it
   independently before one of them caught the underlying cause.
2. **The change touches seven plugins, not nine.** The discovery notes carried an unchecked figure.
3. **Eight sites are audience-frame sentences that stay unchanged**, so the sweep is twenty-eight sites rather
   than the thirty-four a naive reading of the inventory would produce.

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

- **Decisions produced:** D-1 through D-10
- **Changed in plan:** every section

## Escalation Register

No question was escalated to the user during implementation planning. Both Open Questions were settled from
evidence already in the repository.

Five escalations were made during the specification stage that preceded this plan, and their register lives in
[team-findings.md](team-findings.md).

## Completeness gate

Recorded here because the next skill in the chain reads this folder rather than the conversation.
