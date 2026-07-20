# Team Findings: Per-Model Authoring Guidance

This file records the review-team findings for the per-model authoring guidance reference, and how each was resolved. Behavioral outcomes live in [../feature-specification.md](../feature-specification.md); decisions live in [decision-log.md](decision-log.md).

Reviewers: `han-core:junior-developer` (scope, assumptions, YAGNI) and `han-core:information-architect` (findability and the risk of confusion with the adjacent tier-selection doc).

## Major findings

### F1: The routing-map entry that makes the document findable is unspecified

- **Agent:** information-architect (IA-001), junior-developer (JD-006)
- **Finding:** The spec's Primary Flow and Outcome promise the author "can find" the document, but the decision (D4) committed only to "add one entry" without committing its wording. The bucket it would join is organized by file location, and its only model-related scent today points at the tier-selection doc. Findability is the whole feature for an on-demand document, so an unspecified routing label is the gap between the promised flow and the committed flow.
- **Resolution:** Added [D9](decision-log.md#d9-give-the-routing-entry-its-own-bullet-with-task-distinguishing-scent): the routing map gains its own bullet for per-model authoring, worded to distinguish "how to write instructions for a target model" from the existing "which model tier to run." Primary Flow step 2 and the Coordinations routing row now state the routing keys on that author intent.
- **Resolved by:** evidence
- **Affected decisions:** D9 (new), D4 (amended)
- **Changed in spec:** Primary Flow, Coordinations

### F2: The bidirectional cross-reference is claimed but not tracked as a coordination

- **Agent:** information-architect (IA-003)
- **Finding:** D5 and Edge Cases say each document cross-references the other, and imply the tier doc gains a scope disambiguator, but the Coordinations table (the spec's ledger of what ships together) lists only the routing map and the vendored copy. So the reverse link (tier doc to new doc) and the tier doc's disambiguating note are untracked, and an author who lands on the older, higher-scent tier doc has no path onward.
- **Resolution:** Added [D10](decision-log.md#d10-the-tier-selection-doc-is-a-coordinating-artifact): the tier-selection doc is named as a coordinating artifact that gains the reverse cross-reference and a one-line scope disambiguator, shipping in lockstep. Added a Coordinations row for it.
- **Resolved by:** evidence
- **Affected decisions:** D10 (new), D5 (amended)
- **Changed in spec:** Coordinations, Edge Cases and Failure Modes

### F3: The "model-agnostic default" is undefined exactly where the model families want opposite things

- **Agent:** junior-developer (JD-001, OQ2)
- **Finding:** The headline difference is that Opus 4.8 and Sonnet 5 want each behavior enumerated while Fable 5 degrades on checklists and wants a stated goal. Yet the safe default the doc points authors to, "write model-agnostic," is left undefined at exactly that split, which is the common unknown-target case. The doc's central instruction would give an author nothing concrete to write.
- **Resolution:** Added [D11](decision-log.md#d11-the-concrete-unknown-target-default): the concrete default is to lead with the goal and the reasons, state the load-bearing constraints and scope explicitly, and avoid exhaustive step-by-step micro-checklists. This pragmatic middle serves all three families from the research evidence. Primary Flow step 3 and the unknown-target flow now state it. Flagged to the user as a settled decision they can revisit.
- **Resolved by:** evidence
- **Affected decisions:** D11 (new)
- **Changed in spec:** Primary Flow, Alternate Flows and States

### F4: The refusal warning offers no test for when the pattern "matters"

- **Agent:** junior-developer (JD-002)
- **Finding:** Step 5 tells authors to avoid the reasoning-echo instruction "where it matters" but never says how to recognize when the pattern is present and consequential. The research calls it a common agentic pattern, which raises the stakes of the ambiguity.
- **Resolution:** Added [D12](decision-log.md#d12-a-concrete-test-for-the-refusal-pattern): the warning carries a concrete test. The pattern is present when an instruction tells the model to reproduce its internal thinking into the visible deliverable, which is distinct from asking for a normally-written explanation of a decision. Primary Flow step 5 now states the test.
- **Resolved by:** evidence
- **Affected decisions:** D12 (new)
- **Changed in spec:** Primary Flow

### F5: The single-source status of the refusal warning does not reach the reader

- **Agent:** junior-developer (JD-005)
- **Finding:** The refusal-trap claim is the doc's one functional-failure warning and also its weakest evidence (research A3, single-source, single-vendor). The doc should let a reader weigh the warning knowing that.
- **Resolution:** Amended [D6](decision-log.md#d6-carry-a-currency-marker): the document discloses that the refusal warning rests on single-vendor, single-source evidence, alongside the currency marker. Edge Cases updated.
- **Resolved by:** evidence
- **Affected decisions:** D6 (amended)
- **Changed in spec:** Edge Cases and Failure Modes

## Minor edits

- F6: Supporting notes (thinking mode, effort, subagent eagerness) read as included-for-completeness; reframed to name the authoring decision each one changes rather than listing them for symmetry — junior-developer (JD-003) — Primary Flow; D2 amended.
- F7: The out-of-scope note on the `readability-guidance` per-model note claimed it is "planned on its own" with no pointer; reworded to state it is a separate research item (item 3) not yet planned, tracked out of scope here — junior-developer (JD-004) — Out of Scope.
- F8: No stated acceptance test; added a one-line definition of done to Outcome — junior-developer (JD-008) — Outcome.
- F9: The unknown-target flow conflated two reasons (operator picks the model at run time vs. a skill cannot self-detect its model); separated them — junior-developer (JD-009) — Alternate Flows and States.
- F10: The currency marker implied an unnamed re-check owner and an ambiguous verification source; clarified that it records when the doc was written and against which model pages, and that a reader verifies against those pages and the cited research — junior-developer (JD-010); D6 amended — Edge Cases and Failure Modes.
- F11: Coordinations row 2 leaked install/placement mechanics ("lives with the other references, no separate wiring"); restated behaviorally as "repos that vendor the guidance receive the new reference through the normal refresh, and the routing entry never points at a missing document" — junior-developer (JD-007) — Coordinations.
- F12: Confirmed no existing Han skill or agent uses the reasoning-echo instruction pattern the guidance warns against (grep across all prose-producing plugins, zero hits), so the suite will not contradict its own new guidance; recorded as a resolved open item — junior-developer (OQ3) — Open Items.
