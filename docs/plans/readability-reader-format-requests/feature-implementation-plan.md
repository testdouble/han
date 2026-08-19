# Feature Implementation Plan: The readability standard honors what the reader asked for

Two files change. Roughly sixty corrections land across the files that quote them, so nothing left
in the repository instructs a run to apply a rule the standard no longer carries. The behavioral work is
small. The care goes into the sweep, which has no test behind it and a set of neighbouring passages that must
not be touched.

## Outcome

Han's shared readability standard gains a check for the shape a reader asked for, and its fidelity clause stops
outranking a request to simplify. Every file that quotes the old wording is corrected in the same branch, so no
skill instructs a run to apply a rule the standard no longer carries.

## User Stories

- **US-1.** As someone reading a Han skill's output, I state how I want an answer shaped and get it that way on
  the first try, so I stop spending turns restating a constraint I already gave.
- **US-2.** As someone who asked for a shorter answer, I get a shorter answer, and the facts that would change
  what I do next are still in it.
- **US-3.** As a maintainer editing the standard later, I change the criteria without hunting through
  twenty-six files for a number that went stale.

## Constraints and Boundaries

- **The behavioral decisions are settled.** Sixteen decisions came out of the specification stage and five were
  settled by the user directly. This plan builds them; it does not reopen them.
- **The readability editor is out of bounds.** Its agent definition, its long-form doc, and the skill that
  dispatches it describe its own separate rubric, which this change does not touch. All three read almost
  identically to the passages being swept
  ([D-1](artifacts/implementation-decision-log.md#d-1-the-exclusion-list-is-a-named-artifact-of-the-plan)).
- **No plugin version moves on this branch**
  ([D-6](artifacts/implementation-decision-log.md#d-6-no-version-bump-and-no-changelog-edit-on-this-branch)).
- **The repository convention conflict is not this branch's to resolve.** The specification records it as OI-1.
  This plan adds no step editing the project's own conventions file, because that is a governance decision with
  its own owner.

## Implementation Approach

The work has three parts, and their order matters.

### Build the inventory before trusting any count

Three inventories were built during planning and all three were wrong. Each time the cause was the same: a
search pattern narrower than the corpus. Line-oriented searches missed sentences that wrap mid-phrase.
Hyphenated patterns missed the spelled-out form. Patterns written for one phrasing missed three more that say
the same thing in different words. One says "required technical fact." Another says "fidelity outranks
readability" without naming a fact at all.

So this plan carries no site count. The first unit builds the inventory from a documented pattern set, records
both, and every later unit works from that output
([D-14](artifacts/implementation-decision-log.md#d-14-the-inventory-is-built-by-the-plan-not-inherited-from-it)).
The known phrasings and the known exclusions are in the decision log as the starting set, not as the answer.

### Draft the two replacement sentences before touching any file

The last inventory taken during planning found sixty-three corrections across twenty-eight files, and sixteen of those files carry a byte-identical
block with four more carrying a near-identical variant of it. Drafting the replacements once and applying them
is what separates a clean diff from a find-and-replace scar
([D-2](artifacts/implementation-decision-log.md#d-2-two-replacement-sentences-are-drafted-once-before-the-sweep)).

Two sentences are needed. One replaces the size reference and is mechanical: the quoting block already names
the fidelity criterion without a number, so at those sites one word comes out. The other replaces the fidelity
guarantee and is not mechanical. It has to carry both the condition that relaxes the guarantee and the floor
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
| 0 | Build the correction inventory from a documented pattern set, and record it as the unit's output | US-3 | A necessity of every unit below: three successive inventories were each wrong, always because a search pattern was narrower than the corpus ([D-14](artifacts/implementation-decision-log.md#d-14-the-inventory-is-built-by-the-plan-not-inherited-from-it)) | — |
| 1 | Draft the two replacement sentences and record them | US-3 | A necessity of the sweep units below: most corrected files take the same text and it has to exist first ([D-2](artifacts/implementation-decision-log.md#d-2-two-replacement-sentences-are-drafted-once-before-the-sweep)) | 0 |
| 2 | Correct the size reference at every site unit 0 found, including the ones outside the skill directories | US-3 | Work-item proposal 1 makes each of these statements wrong; the specification's Coordinations row names skills, operator-facing documents, and one canonical reference file ([D-11](artifacts/implementation-decision-log.md#d-11-the-sweep-covers-the-non-skill-quoting-surfaces-the-first-inventory-missed)) | 1 |
| 3 | Correct every fidelity restatement whose subject is the standard, leaving every restatement whose subject is the audience frame alone | US-2 | Work-item proposal 2 makes the restatement conditionally untrue wherever it claims the standard never drops a fact ([D-4](artifacts/implementation-decision-log.md#d-4-the-fidelity-restatement-splits-by-grammatical-subject-not-by-block)) | 1 |
| 4 | Replace the six positional references to criterion 6 with the criterion's name | US-3 | A necessity of unit 3: each of those six sentences says criterion 6 is not optional, which proposal 2 makes conditionally untrue. The specification's Coordinations row commits to dropping the position with the number ([D-12](artifacts/implementation-decision-log.md#d-12-only-the-positional-references-that-proposal-2-falsifies-are-replaced)) | 1 |
| 5 | Rewrite the paragraph in the one site where two corrected sentences would repeat each other | US-3 | A necessity of units 2 and 4, which both land in that paragraph ([D-5](artifacts/implementation-decision-log.md#d-5-one-site-takes-a-paragraph-rewrite-rather-than-a-sentence-swap)) | 2, 4 |
| 6 | Add the seventh criterion to the one skill that enumerates the whole check in its own words | US-1 | A necessity of work-item proposal 1: that skill's self-check is a hardcoded list of six, so it would run a six-criterion check against a seven-criterion standard ([D-13](artifacts/implementation-decision-log.md#d-13-the-one-hardcoded-enumeration-of-the-check-gains-the-seventh-criterion)) | 1 |
| 7 | Change the four passages in the readability standard | US-1, US-2 | Work-item proposals 1 and 2 | 2, 3, 4, 5, 6 |
| 8 | Change the four passages in the readability output style | US-1, US-2 | Work-item proposals 1 and 2; the style is the surface the reported failure ran under | 7 |
| 9 | Run the branch-scoped documentation check and the lint pass | US-3 | A necessity of units 2 through 8: the first inventory missed five quoting files. A check that scopes itself to what the branch touched is the remedy that already caught this class once ([D-7](artifacts/implementation-decision-log.md#d-7-the-branch-scoped-documentation-check-is-kept-the-bats-script-is-not)) | 8 |

## Definition of Done

A reviewer confirms eight things, every one of them readable from the diff.

0. Unit 0's inventory is recorded with the patterns that produced it, and re-running those patterns after the
   sweep returns only the exclusion list. A count in this plan is not the check; the recorded pattern set is
   ([D-14](artifacts/implementation-decision-log.md#d-14-the-inventory-is-built-by-the-plan-not-inherited-from-it)).

1. The standard lists seven criteria. Its fidelity section carries the relaxation and the floor. Its escape
   clause no longer claims the banned-word list and the fidelity guarantee can never be overridden.
2. The output style carries the same three changes in its own shorter wording, and its escape-clause limit
   matches the standard's meaning rather than its exact words.
3. A scoped search for the size reference returns hits in exactly five classes, and nowhere else. Those classes
   are the planning folder, the research folder, the changelog, the three files describing the readability
   editor's own rubric, and the two canonical files
   ([D-1](artifacts/implementation-decision-log.md#d-1-the-exclusion-list-is-a-named-artifact-of-the-plan)).
   The search has to be scoped to the phrase, not to the word "six." An unscoped word search returns a dozen
   unrelated matches in this repository, so it cannot serve as the completeness check. The two canonical files
   keep their own count, because a count sitting directly above the list it counts cannot go stale unseen
   ([D-8](artifacts/implementation-decision-log.md#d-8-the-source-files-keep-their-own-count-every-quoting-site-drops-it)).
4. The fidelity restatement is corrected everywhere its subject is the standard, every audience-frame
   sentence is untouched
   ([D-4](artifacts/implementation-decision-log.md#d-4-the-fidelity-restatement-splits-by-grammatical-subject-not-by-block)),
   and each replaced line still reads as a sentence in its paragraph. That last part is a diff read, not a
   search.
5. The six positional references name the criterion instead of its number. The one positional reference to
   criterion 5 is untouched, because criterion 5 does not move and nothing about it became untrue
   ([D-12](artifacts/implementation-decision-log.md#d-12-only-the-positional-references-that-proposal-2-falsifies-are-replaced)).
6. The one skill that enumerates the check in its own words lists seven items
   ([D-13](artifacts/implementation-decision-log.md#d-13-the-one-hardcoded-enumeration-of-the-check-gains-the-seventh-criterion)).
7. `npm run lint` passes. Prose wrapping is preserved rather than reflowed, so any line pushed past the column
   limit is rewrapped by hand.

## Testing Strategy

**There is no automated test for any of this, and adding one is not recommended.** The full analysis is in
[artifacts/test-plan.md](artifacts/test-plan.md); the shape of it is below.

The sweep is verified by three cheap checks. They are a read-through of the two canonical files, a re-run of
the inventory searches against the enumerated file set, and a diff confirming the three readability-editor
files are untouched.

Every one of those searches joins lines before matching, because a sentence in this repository routinely spans
two lines and a line-oriented search silently misses it
([D-10](artifacts/implementation-decision-log.md#d-10-every-inventory-search-is-wrap-tolerant)). The searches
need a person reading the hits, not a pass-or-fail assertion, because the patterns produce false positives
that must stay unchanged
([D-4](artifacts/implementation-decision-log.md#d-4-the-fidelity-restatement-splits-by-grammatical-subject-not-by-block)).

The behavior itself cannot be tested automatically. It lives in prose an assistant reads while drafting, so
there is no function to call.

What the team gets instead is one manual pass before merge. It runs three scenarios drawn from the
specification: a stated count, a request for less that exercises the floor, and a register request that
collides with the banned-word list. A person reads the results
([D-9](artifacts/implementation-decision-log.md#d-9-behavior-is-checked-by-a-manual-smoke-pass-not-a-recorded-transcript)).

## Security Posture

Nothing changes. The feature touches no authentication, no personal data, no secrets, and no untrusted input.

## Operational Readiness

Nothing changes. There is no deployment path, no flag, no metric, and no rollback beyond reverting the branch.

One user-visible timing note belongs in the merge announcement rather than in code: a session that started
before the merge keeps the old output style until it restarts. The specification's Coordinations table records
this under the readability output style.

## Risks and Assumptions

### Risks

| # | Risk | Consequence | Mitigation |
| - | ---- | ----------- | ---------- |
| R1 | The sweep edits a readability-editor passage that reads almost identically | The editor's own rubric statement becomes false, which is the failure a prior plan bent its design to avoid | The exclusion list is a named artifact and a diff check, not a comment ([D-1](artifacts/implementation-decision-log.md#d-1-the-exclusion-list-is-a-named-artifact-of-the-plan)) |
| R2 | A wrapped line or an unquoted phrasing hides a site from the inventory | The sweep ships incomplete and a skill keeps instructing a rule that no longer exists | Realised twice during planning and corrected both times; every search runs wrap-tolerant ([D-10](artifacts/implementation-decision-log.md#d-10-every-inventory-search-is-wrap-tolerant)) and the branch-scoped documentation check is the backstop ([D-7](artifacts/implementation-decision-log.md#d-7-the-branch-scoped-documentation-check-is-kept-the-bats-script-is-not)) |
| R3 | Replacing a sentence inside a three-sentence block leaves the paragraph reading badly | Sixty-three small scars in files people read every session | Two sentences drafted once ([D-2](artifacts/implementation-decision-log.md#d-2-two-replacement-sentences-are-drafted-once-before-the-sweep)), and criterion 4 of Done is a diff read |
| R4 | The readability area is among the most-edited in the plugin: forty-four commits across six files in ninety days | The branch meets moving text and conflicts on merge | Land it as one branch rather than several, and rebase rather than hold |

### Assumptions

- **Most skills pick up the standard's change with no edit of their own**, because they read it at draft time.
  The specification states this. One skill is the exception: it restates the whole check as a hardcoded list
  in its own words, and that list needs the seventh item added
  ([D-13](artifacts/implementation-decision-log.md#d-13-the-one-hardcoded-enumeration-of-the-check-gains-the-seventh-criterion)).
- **One merge, one visible state.** Intermediate commits are visible only on the author's machine.

## Deferred (YAGNI)

This is work no evidence supports yet. Every entry carries the trigger that would justify revisiting it.

### A checked-in test asserting no count reference survives

- **Why deferred:** The evidence test fails. No incident is recorded, no code path breaks, and the count
  spreading across the repository is history rather than a regression after a count-free rewrite. Every
  script with a test beside it in this repository backs a script a skill runs; this would back a one-time
  migration. The search patterns also produce false positives that must stay, so a pass-or-fail assertion
  would misfire on correct text. The branch-scoped documentation check covers the same failure mode
  ([D-7](artifacts/implementation-decision-log.md#d-7-the-branch-scoped-documentation-check-is-kept-the-bats-script-is-not)).
- **Reopen when:** A count reference to the self-check reappears in a shipped file after this ships.
- **Source:** Considered and rejected by both specialists this round, on the same grounds.

### A recorded-transcript test for the behavior

- **Why deferred:** The evidence test fails, and the simpler-version test rules it out too. The readability
  area took forty-four commits across six files in ninety days, so a recorded transcript would break on
  unrelated wording edits rather than on the behavior regressing.
- **Reopen when:** The standard's text stabilises and a behavioral regression ships unnoticed.
- **Source:** Test-engineer finding S2.

### Renumber-proofing the one positional reference to criterion 5

- **Why deferred:** The evidence test fails. The seventh criterion is appended, so criterion 5 keeps its
  position and the sentence naming it stays true. The only argument for touching it is that a future
  reordering would break it, which is future flexibility rather than evidence
  ([D-12](artifacts/implementation-decision-log.md#d-12-only-the-positional-references-that-proposal-2-falsifies-are-replaced)).
- **Reopen when:** A change reorders the self-check criteria.
- **Source:** The planning run's own inventory, surfaced at synthesis.

### Consolidating the fidelity sentence into one source instead of twenty-odd copies

- **Why deferred:** The evidence test fails. The project's own convention asks for one canonical source per
  concept, and twenty-odd copies of a rule sentence sit awkwardly against it. But the specification commits to
  none of this, and it would multiply the diff.
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
- **OI-2.** The inventory has been corrected twice, both times because a search pattern was narrower than the
  corpus. The synthesis pass found five more quoting files and one hardcoded enumeration of the check. There
  is no evidence that a third gap remains, and none that one does not. **Blocks implementation:** No. Work
  unit 9 exists to catch it, and its output is the only thing that closes this item.

## Specialist Handoffs for Implementation

- **`han-core:content-auditor`, once, after unit 3.** Twenty-five sites lose a sentence stating a guarantee and
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

Ship as planned, with the content-auditor handoff after unit 3. Two open items, and neither blocks the work.

## Summary

The synthesis reconciled a one-round record from `han-core:test-engineer` and `han-core:junior-developer`
against the plan. It re-verified every count in the repository with wrap-tolerant searches and found the sweep
larger than the plan recorded: sixty-three corrections across twenty-eight files rather than twenty-eight
sites. The plan is committable today, with the `han-core:content-auditor` handoff after work unit 3; the
post-ship owner is the author of the branch.

| Record | Count |
|---|---|
| Decisions committed / Rejected alternatives recorded | 13 / 23 |
| Risks open / Assumptions unverified / Dependencies | 4 / 2 / 0 |
| Remaining open items | 2 |
| Specialist handoffs for implementation | 1 |

Recommendation: Ship as planned.
