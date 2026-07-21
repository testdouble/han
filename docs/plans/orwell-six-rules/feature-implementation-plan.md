# Feature Implementation Plan: Orwell's Six Rules Applied to the han-communication Guidance

This plan closes three gaps between George Orwell's six rules of writing and the han-communication readability standard, using four targeted edits to the standard's guidance files and its editor agent. Two edits add general principles the standard lacks (break a rule when it hurts the prose; avoid stale figures and pretentious diction), one names a missing word category, and one carries the new principles into the editor agent so they reach the rewrite pass. The self-check stays at exactly six criteria, on purpose. This is a markdown-only documentation change with no application code, no runtime surface, and no build step.

## Outcome

When this plan is executed, the readability standard states the escape clause Orwell made his most important rule: when following a rule would make the prose read worse, break the rule ([D-1](artifacts/implementation-decision-log.md#d-1-escape-clause-placement-and-scoping)). The writing-voice profile names a general principle against stale figures of speech and pretentious or archaic diction, with a dividing line that keeps the profile's signature physical-world analogies legal ([D-2](artifacts/implementation-decision-log.md#d-2-stale-figures-principle-placement-dividing-line-and-carve-out)), and names the specific foreign, Latinate, and archaic stock phrases the word guidance never called out ([D-3](artifacts/implementation-decision-log.md#d-3-foreign-and-archaic-diction-lands-only-in-the-writing-voice-blocklist)). The readability-editor agent carries the escape clause and the new diction scope inline, so the rewrite pass acts on them ([D-4](artifacts/implementation-decision-log.md#d-4-agent-edit-shape-keeps-the-rubric-at-six)).

The work serves two audiences. Readers of any Han skill's output get prose free of worn figures and pretentious diction. The readability standard's own maintainers get a standard that matches the tempered, exception-bearing form of Orwell's rules that modern evidence supports, without growing the six-point self-check that keeps compliance from decaying.

## User Stories

- **US-1:** As a reader of Han skill output, I want prose free of worn figures of speech and pretentious or archaic diction, so that the writing stays plain and easy to follow.
- **US-2:** As the readability editor, I want license to break a formatting rule when following it would make the prose read worse, so that mechanical compliance never produces clumsy writing.
- **US-3:** As a maintainer of the readability standard, I want the new principles to reach the rewrite pass without growing the six-point self-check, so that the standard gains coverage without the compliance decay a longer checklist would cause.

## Constraints and Boundaries

- **Driving constraint:** The research report is validated and its recommendation is committed. The escape-clause gap in particular leaves an editor following the rules mechanically with no license to break one when the result reads badly, the exact failure Orwell's rule 6 exists to prevent.
- **Out of scope:** Growing the six-point self-check ([D-1](artifacts/implementation-decision-log.md#d-1-escape-clause-placement-and-scoping)); adding a competing word list to `readability-rule.md` ([D-3](artifacts/implementation-decision-log.md#d-3-foreign-and-archaic-diction-lands-only-in-the-writing-voice-blocklist)); editing consuming skills, which read the reference files live ([D-7](artifacts/implementation-decision-log.md#d-7-scoped-doc-consistency-check-and-no-consuming-skill-edits)); copying the escape clause into operator-facing docs (see Deferred).
- **Watch after ship:** Whether the escape clause is used to excuse a blocklisted word or a dropped fact, and whether the stale-figures principle over-flags the profile's signature analogies.

## Implementation Approach

The four edits touch three files, all owned by `han-communication`. Each edit reuses an existing structure in its target file rather than introducing a new one, which keeps the added prose tight, a deliberate constraint because `readability-rule.md` is read in full by every reader-facing skill in the suite.

The escape clause lands in `readability-rule.md` as a new section between "Fidelity wins" and "The standardized self-check" ([D-1](artifacts/implementation-decision-log.md#d-1-escape-clause-placement-and-scoping)). It is scoped: it governs the drafting properties and rewrite moves, and yields to both hard gates, so it never licenses a blocklisted word or a fidelity loss. This mirrors the standard's existing scoped escapes and the pattern mature plain-language guides use.

The stale-figures principle and the foreign, Latinate, and archaic diction land together in the "Avoided words and phrases" section of `writing-voice.md`, principle first and examples second ([D-2](artifacts/implementation-decision-log.md#d-2-stale-figures-principle-placement-dividing-line-and-carve-out), [D-3](artifacts/implementation-decision-log.md#d-3-foreign-and-archaic-diction-lands-only-in-the-writing-voice-blocklist)). The stale-figures principle reuses the section's existing load-bearing-versus-decorative test as its dividing line and points at the physical-world-analogy carve-out, so a fresh signature analogy stays legal while a worn cliche does not.

The agent edit carries the new principles into the rewrite pass ([D-4](artifacts/implementation-decision-log.md#d-4-agent-edit-shape-keeps-the-rubric-at-six)). This step is required because the editor agent runs its own hardcoded rubric and reads only the rule and the draft, never `writing-voice.md`, so edits to the reference files alone would never reach it. The escape clause joins the agent's fidelity principle as a governing principle, and the diction scope folds into the agent's existing criterion 5. The rubric stays at six criteria, so the "six criteria" count stays true on every surface that echoes it.

### Editor-agent rubric integrity

The one shape decision worth naming is that the new principles enter the agent as a governing principle and a criterion-5 amendment, never as a seventh criterion ([D-4](artifacts/implementation-decision-log.md#d-4-agent-edit-shape-keeps-the-rubric-at-six)). Keeping the rubric at six preserves the keep-it-small design and leaves "They are the whole rubric" literally true.

## Work Units and Sequencing

| #   | Work Unit | Story | Delivers | Depends On | Verification |
| --- | --------- | ----- | -------- | ---------- | ------------ |
| 1   | Add the escape-clause section to `readability-rule.md` | US-2, US-3 | The standard states the scoped break-the-rule principle beside "Fidelity wins" ([D-1](artifacts/implementation-decision-log.md#d-1-escape-clause-placement-and-scoping)) | None | The section reads as subordinate to both hard gates; the self-check stays six |
| 2   | Add the stale-figures principle to `writing-voice.md` | US-1 | A general principle against stale figures, with the load-bearing dividing line and the signature-move carve-out ([D-2](artifacts/implementation-decision-log.md#d-2-stale-figures-principle-placement-dividing-line-and-carve-out)) | None | A worn cliche is flagged; a fresh signature analogy is not |
| 3   | Add foreign, Latinate, and archaic diction to `writing-voice.md` | US-1 | The named diction category as examples of the replace-first pattern, in the same blocklist section ([D-3](artifacts/implementation-decision-log.md#d-3-foreign-and-archaic-diction-lands-only-in-the-writing-voice-blocklist)) | None | The words live only in the writing-voice blocklist, not in `readability-rule.md` |
| 4   | Carry the new principles into `readability-editor.md` | US-1, US-2, US-3 | Escape clause beside the fidelity principle; diction scope woven into criterion 5; rubric stays six ([D-4](artifacts/implementation-decision-log.md#d-4-agent-edit-shape-keeps-the-rubric-at-six)) | 1, 2, 3 | "They are the whole rubric" stays true; the rubric still lists six criteria |
| 5   | Run the han-plugin-builder guidance review over the edited agent | US-3 | A review-pass sign-off on `readability-editor.md` ([D-6](artifacts/implementation-decision-log.md#d-6-guidance-review-prerequisite-for-the-agent-edit)) | 4 | The guidance review returns no unresolved findings |
| 6   | Run the manual dry-run acceptance check | US-1, US-2 | The edited agent corrects a stale metaphor, "in lieu of," and an archaic word while preserving a load-bearing signature analogy ([D-5](artifacts/implementation-decision-log.md#d-5-manual-dry-run-acceptance-check)) | 4 | The three targets are corrected; the signature analogy survives unchanged |
| 7   | Run the scoped doc-consistency check | US-3 | Statements the edits make false are corrected; the "six criteria" count claims stay untouched ([D-7](artifacts/implementation-decision-log.md#d-7-scoped-doc-consistency-check-and-no-consuming-skill-edits)) | 4 | No count claim changes; no consuming-skill edits |

## Definition of Done

- [ ] The readability standard states the scoped escape clause between "Fidelity wins" and "The standardized self-check," yielding to both hard gates ([D-1](artifacts/implementation-decision-log.md#d-1-escape-clause-placement-and-scoping)).
- [ ] The writing-voice profile names the stale-figures principle with its dividing line and carve-out ([D-2](artifacts/implementation-decision-log.md#d-2-stale-figures-principle-placement-dividing-line-and-carve-out)) and the foreign, Latinate, and archaic diction category ([D-3](artifacts/implementation-decision-log.md#d-3-foreign-and-archaic-diction-lands-only-in-the-writing-voice-blocklist)).
- [ ] The editor agent carries the escape clause as a governing principle and the diction scope in criterion 5, with the rubric still at six criteria and "They are the whole rubric" still true ([D-4](artifacts/implementation-decision-log.md#d-4-agent-edit-shape-keeps-the-rubric-at-six)).
- [ ] The manual dry run passes: the stale metaphor, "in lieu of," and the archaic word are corrected, and the load-bearing signature analogy survives unchanged ([D-5](artifacts/implementation-decision-log.md#d-5-manual-dry-run-acceptance-check)).
- [ ] The han-plugin-builder guidance review of the edited agent returns no unresolved findings ([D-6](artifacts/implementation-decision-log.md#d-6-guidance-review-prerequisite-for-the-agent-edit)).
- [ ] The scoped doc-consistency check leaves every "six criteria" count claim untouched and true, and no consuming skill is edited ([D-7](artifacts/implementation-decision-log.md#d-7-scoped-doc-consistency-check-and-no-consuming-skill-edits)).

## Testing Strategy

The repo has no automated test runner, so verification is a manual dry run plus a guidance review.

- **Observable behaviors to test:** The edited editor agent, run on a sample document, corrects a stale metaphor, "in lieu of," and an archaic word such as "aforementioned," and leaves a load-bearing signature analogy unchanged ([D-5](artifacts/implementation-decision-log.md#d-5-manual-dry-run-acceptance-check)).
- **Edge cases requiring coverage:** The load-bearing signature analogy is the carve-out case; it must survive to prove the stale-figures principle does not over-flag ([D-2](artifacts/implementation-decision-log.md#d-2-stale-figures-principle-placement-dividing-line-and-carve-out)).
- **Test doubles posture and levels:** None. The dry run exercises the real agent against a real sample document.

## Risks and Assumptions

### Risks

| ID  | Risk | Impact | Mitigation | Owner |
| --- | ---- | ------ | ---------- | ----- |
| R1  | The escape clause is used to excuse a blocklisted word or a dropped fact | The standard's hard gates weaken | Scope the clause to yield to both hard gates and state that scope in the section text ([D-1](artifacts/implementation-decision-log.md#d-1-escape-clause-placement-and-scoping)) | `information-architect` |
| R2  | The stale-figures principle over-flags the profile's signature physical-world analogies | The signature move is suppressed as a cliche | Reuse the load-bearing-versus-decorative dividing line and point at the carve-out ([D-2](artifacts/implementation-decision-log.md#d-2-stale-figures-principle-placement-dividing-line-and-carve-out)); the dry run's carve-out case verifies it ([D-5](artifacts/implementation-decision-log.md#d-5-manual-dry-run-acceptance-check)) | `information-architect` |
| R3  | An edit falsifies a "six criteria" count claim on one of the surfaces that echo it | Cross-surface count claims go stale | Keep the rubric at six ([D-4](artifacts/implementation-decision-log.md#d-4-agent-edit-shape-keeps-the-rubric-at-six)); scope the doc-consistency check to leave count claims untouched ([D-7](artifacts/implementation-decision-log.md#d-7-scoped-doc-consistency-check-and-no-consuming-skill-edits)) | `information-architect` |

### Assumptions

| ID  | Assumption | What Changes If Wrong | Status |
| --- | ---------- | --------------------- | ------ |
| A1  | The line-110 load-bearing-versus-decorative test generalizes from sports metaphors to physical-world analogies | The dividing line needs its own wording for the carve-out rather than a pointer to it | Verified: `writing-voice.md:110` and `:30-33`; the dry-run carve-out case confirms behavior ([D-5](artifacts/implementation-decision-log.md#d-5-manual-dry-run-acceptance-check)) |
| A2  | Consuming skills read the reference files live through readability-guidance, so no consumer edit is needed | Consuming skills would need direct edits to see the new principles | Verified: `han-communication/skills/readability-guidance/SKILL.md:32-40` |
| A3  | The editor agent reads only the rule and the draft, never `writing-voice.md`, so the diction scope must be named inline | The agent edit could inherit the scope from the reference file instead | Verified: `han-communication/agents/readability-editor.md:78` |

## Deferred (YAGNI)

### Escape-clause copy in `docs/readability.md`

- **Why deferred:** Evidence test failed. The cross-plugin summary surface carries a scent line, not copies of the governing principles, and no reader path breaks without the escape clause repeated there.
- **Reopen when:** An operator relies on `docs/readability.md` as the complete governing-principle list and its absence produces confusion.
- **Source:** R1, `information-architect` (F12).

### Escape-clause bullet in `han-communication/docs/agents/readability-editor.md`

- **Why deferred:** Evidence test failed. The operator-facing doc is scoped to dispatch guidance and defers internals to the agent definition, so the escape clause does not need to appear there.
- **Reopen when:** Operators report confusion about the agent overriding a rubric criterion.
- **Source:** R1, `information-architect` (F13).

## Sources and Plan Records

- **Feature specification:** No source specification file exists. The inputs were the validated research report `docs/research/orwell-six-rules-of-writing.md`, whose O2 option and Recommendation section served as the "what" for this plan.
- **Decision rationale and rejected alternatives:** [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Team composition and round-by-round history:** [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)

## Recommendation

Ship as planned. All five open questions were resolved by evidence, no open items block implementation, and the two YAGNI deferrals carry concrete reopen triggers.
