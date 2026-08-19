# Feature Implementation Plan: The readability standard honors what the reader asked for

Two files change, and twenty-eight quoting sites get corrected so they stop contradicting them. The behavioral
work is small. The care goes into the sweep, which has no test behind it and two neighbouring passages that
must not be touched.

## Outcome

Han's shared readability standard gains a check for the shape a reader asked for, and its fidelity clause stops
outranking a request to simplify. Every file that quotes the old wording is corrected in the same branch, so no
skill instructs a run to apply a rule the standard no longer carries.

## User Stories

- **US-1.** As someone reading a Han skill's output, I state how I want an answer shaped and get it that way on
  the first try, so I stop spending turns restating a constraint I already gave.
- **US-2.** As someone who asked for a shorter answer, I get a shorter answer, and the facts that would change
  what I do next are still in it.
- **US-3.** As a maintainer editing the standard later, I change the criteria without hunting through twenty-one
  skill files for a number that went stale.

## Constraints and Boundaries

- **The behavioral decisions are settled.** Sixteen decisions came out of the specification stage and five were
  settled by the user directly. This plan builds them; it does not reopen them.
- **The readability editor is out of bounds.** Its agent definition and its long-form doc describe its own
  separate rubric, which this change does not touch. Both read almost identically to the passages being swept
  ([D-1](artifacts/implementation-decision-log.md#d-1-the-exclusion-list-is-a-named-artifact-of-the-plan)).
- **No plugin version moves on this branch**
  ([D-6](artifacts/implementation-decision-log.md#d-6-no-version-bump-and-no-changelog-edit-on-this-branch)).
- **The repository convention conflict is not this branch's to resolve.** The specification records it as OI-1.
  This plan adds no step editing the project's own conventions file, because that is a governance decision with
  its own owner.

## Implementation Approach

The work has three parts, and their order matters.

### Draft the two replacement sentences before touching any file

Twenty-eight sites need corrected text, and nineteen of them carry the identical three-sentence block. Drafting
the replacements once and applying them is what separates a clean diff from a find-and-replace scar
([D-2](artifacts/implementation-decision-log.md#d-2-two-replacement-sentences-are-drafted-once-before-the-sweep)).

Two sentences are needed. One replaces the size reference and is mechanical: the existing block already calls it
"its fidelity criterion" without a number, so the fix at those sites is deleting one word. The other replaces
the fidelity guarantee and is not mechanical: it has to carry both the condition that relaxes it and the floor
that bounds it, in one sentence, inside a three-sentence block.

### Sweep the quoting files first, canonical files last

Skills read the standard live, so between commits a local session can hold a rule that lists seven criteria
beside a skill instructing a check of six. Count-free wording is true against the old rule and the new one
alike, which makes it the one ordering with no contradictory window
([D-3](artifacts/implementation-decision-log.md#d-3-the-sweep-lands-before-the-canonical-files)).

This sets commit order inside one branch. It does not justify splitting the work across pull requests, because
nobody outside the author's machine sees an intermediate state.

### Change the two canonical files

Four passages in each: the fidelity clause, the escape clause, the self-check itself, and the closure sentence
that declares the set complete. The two files word the same limits differently, so each takes its own edit
rather than a shared string.

## Work Units and Sequencing

| # | Unit | Story | Justification | Depends on |
| - | ---- | ----- | ------------- | ---------- |
| 1 | Draft the two replacement sentences and record them | US-3 | A necessity of the sweep unit below: nineteen sites take the same text and it has to exist first ([D-2](artifacts/implementation-decision-log.md#d-2-two-replacement-sentences-are-drafted-once-before-the-sweep)) | — |
| 2 | Correct the size reference at every quoting site | US-3 | Work-item proposal 1 makes each of these statements wrong | 1 |
| 3 | Correct the fidelity guarantee at the eighteen self-check sites, leaving the eight audience-frame sites alone | US-2 | Work-item proposal 2 makes the self-check restatement conditionally untrue ([D-4](artifacts/implementation-decision-log.md#d-4-the-audience-frame-sentence-is-left-unchanged)) | 1 |
| 4 | Replace the six positional references with the criterion's name | US-3 | A necessity of unit 2: leaving them makes the count-free claim untrue on the next reordering | 1 |
| 5 | Rewrite the paragraph in the one site where two corrected sentences would repeat each other | US-3 | A necessity of units 2 and 4, which both land in that paragraph ([D-5](artifacts/implementation-decision-log.md#d-5-one-site-takes-a-paragraph-rewrite-rather-than-a-sentence-swap)) | 2, 4 |
| 6 | Change the four passages in the readability standard | US-1, US-2 | Work-item proposals 1 and 2 | 2, 3, 4, 5 |
| 7 | Change the four passages in the readability output style | US-1, US-2 | Work-item proposals 1 and 2; the style is the surface the reported failure actually ran under | 6 |
| 8 | Run the branch-scoped documentation check and the lint pass | US-3 | A necessity of units 2 through 7: it catches a quoting surface the inventory missed ([D-7](artifacts/implementation-decision-log.md#d-7-the-branch-scoped-documentation-check-is-kept-the-bats-script-is-not)) | 7 |

## Definition of Done

A reviewer confirms six things, every one of them readable from the diff.

1. The standard lists seven criteria. Its fidelity section carries the relaxation and the floor. Its escape
   clause no longer claims the banned-word list and the fidelity guarantee can never be overridden.
2. The output style carries the same three changes in its own shorter wording, and its escape-clause limit
   matches the standard's meaning rather than its exact words.
3. A search for the size reference returns hits in exactly four places, and nowhere else: the planning folder,
   the research folder, the changelog, and the two readability-editor files
   ([D-1](artifacts/implementation-decision-log.md#d-1-the-exclusion-list-is-a-named-artifact-of-the-plan)). The
   two canonical files keep their own count, because a count sitting directly above the list it counts cannot go
   stale unseen ([D-8](artifacts/implementation-decision-log.md#d-8-the-source-files-keep-their-own-count-every-quoting-site-drops-it)).
4. The self-check restatement is gone from the eighteen sites that carry it, the eight audience-frame sentences
   are untouched, and each replaced line still reads as a sentence in its paragraph. That last part is a diff
   read, not a search.
5. The positional references name the criterion instead of its number.
6. `npm run lint` passes. Prose wrapping is preserved rather than reflowed, so any line pushed past the column
   limit is rewrapped by hand.

## Testing Strategy

**There is no automated test for any of this, and adding one is not recommended.** The full analysis is in
[artifacts/test-plan.md](artifacts/test-plan.md); the shape of it is below.

The sweep is verified by three cheap checks: a read-through of the two canonical files, a re-run of the
inventory searches against the enumerated file set, and a diff confirming the two readability-editor files are
untouched. Those searches need a person reading the hits, not a pass-or-fail assertion, because the search
pattern produces at least one false positive that must stay unchanged
([D-4](artifacts/implementation-decision-log.md#d-4-the-audience-frame-sentence-is-left-unchanged)).

The behavior itself cannot be tested automatically. It lives in prose an assistant reads while drafting, so
there is no function to call. What the team gets instead is one manual pass before merge, running three
scenarios drawn from the specification: a stated count, a request for less that exercises the floor, and a
register request that collides with the banned-word list. A person reads the results
([D-9](artifacts/implementation-decision-log.md#d-9-behavior-is-checked-by-a-manual-smoke-pass-not-a-recorded-transcript)).

## Security Posture

Nothing changes. The feature touches no authentication, no personal data, no secrets, and no untrusted input.

## Operational Readiness

Nothing changes. There is no deployment path, no flag, no metric, and no rollback beyond reverting the branch.

One user-visible timing note belongs in the merge announcement rather than in code: a session that started
before the merge keeps the old output style until it restarts.

## On-Call Resilience Posture

Not applicable. No runtime code path is added or changed.

## Risks and Assumptions

### Risks

| # | Risk | Consequence | Mitigation |
| - | ---- | ----------- | ---------- |
| R1 | The sweep edits a readability-editor passage that reads almost identically | The editor's own rubric statement becomes false, which is the failure a prior plan bent its design to avoid | The exclusion list is a named artifact and a diff check, not a comment ([D-1](artifacts/implementation-decision-log.md#d-1-the-exclusion-list-is-a-named-artifact-of-the-plan)) |
| R2 | A wrapped line hides a site from the inventory | The sweep ships incomplete and a skill keeps instructing a rule that no longer exists | Already realised once during planning and corrected; the searches run wrap-tolerant ([D-10](artifacts/implementation-decision-log.md#d-10-every-inventory-search-is-wrap-tolerant)) |
| R3 | Replacing a sentence inside a three-sentence block leaves the paragraph reading badly | Twenty-eight small scars in files people read every session | Two sentences drafted once ([D-2](artifacts/implementation-decision-log.md#d-2-two-replacement-sentences-are-drafted-once-before-the-sweep)), and criterion 4 of Done is a diff read |
| R4 | The readability area is among the most-edited in the plugin | The branch meets moving text and conflicts on merge | Land it as one branch rather than several, and rebase rather than hold |

### Assumptions

- **Skills pick up the standard's change with no edit of their own**, because they read it at draft time. The
  specification states this and the sweep exists only to fix stale quotations, not to deliver the behavior.
- **One merge, one visible state.** Intermediate commits are visible only on the author's machine.

## Deferred (YAGNI)

This is work no evidence supports yet. Every entry carries the trigger that would justify revisiting it.

### A checked-in test asserting no count reference survives

- **Why deferred:** The evidence test fails. No incident is recorded, no code path breaks, and the count
  spreading to twenty-five surfaces is history rather than a regression after a count-free rewrite. Every
  script with a test beside it in this repository backs a script a skill runs; this would back a one-time
  migration. The search pattern also produces a false positive that must stay, so a pass-or-fail assertion
  would misfire on correct text.
- **Reopen when:** A count reference to the self-check reappears in a shipped file after this ships.
- **Source:** Considered and rejected by both specialists this round, on the same grounds.

### A recorded-transcript test for the behavior

- **Why deferred:** The evidence test fails, and the simpler-version test rules it out too. The readability
  area took thirty-plus commits across six files in ninety days, so a recorded transcript would break on
  unrelated wording edits rather than on the behavior regressing.
- **Reopen when:** The standard's text stabilises and a behavioral regression ships unnoticed.
- **Source:** Test-engineer finding S2.

### Consolidating the fidelity sentence into one source instead of twenty copies

- **Why deferred:** The evidence test fails. The project's own convention asks for one canonical source per
  concept, and twenty copies of a rule sentence sit awkwardly against it, but the specification commits to none
  of this and it would multiply the diff.
- **Reopen when:** A third change has to sweep the same sites.
- **Source:** Junior-developer YAGNI check.

### A migration note, feature flag, or staged rollout

- **Why deferred:** The evidence test fails outright. Nothing in this repository ships behind a flag, and the
  change lands as one merge.
- **Reopen when:** The suite gains a rollout mechanism for reference-file changes.
- **Source:** Junior-developer YAGNI check.

## Open Items

- **OI-1 (inherited from the specification).** A reader's request now overrides the banned-word list in a
  committed file, which collides with the repository's own convention that every document follows the writing
  voice. **Blocks implementation:** No. This plan deliberately adds no step touching that convention.

## Specialist Handoffs for Implementation

- **`han-core:content-auditor`, once, after unit 3.** Eighteen sites lose a sentence stating a guarantee and
  gain one stating a conditional guarantee. Confirming no skill lost a must-keep-facts instruction it relied on
  is fact-preservation review rather than wording review. Both specialists named this handoff independently.

## Sources and Plan Records

- Specification: [feature-specification.md](feature-specification.md)
- Specification decisions: [artifacts/decision-log.md](artifacts/decision-log.md)
- Specification review findings: [artifacts/team-findings.md](artifacts/team-findings.md)
- Scope boundary: [artifacts/scope-boundary.md](artifacts/scope-boundary.md)
- Discovery, including the verified inventory: [artifacts/.discovery-notes.md](artifacts/.discovery-notes.md)
- Implementation decisions: [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- Round record: [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- Verification analysis: [artifacts/test-plan.md](artifacts/test-plan.md)

## Recommendation

Ship as planned, with the content-auditor handoff after unit 3. One open item, and it blocks nothing.
