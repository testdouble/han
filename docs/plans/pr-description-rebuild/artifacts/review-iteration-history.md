# Review Iteration History: Verified PR Descriptions

Rounds run by `iterative-plan-review` against [../feature-specification.md](../feature-specification.md). Findings are recorded in [review-findings.md](review-findings.md).

## R1

- **Mode:** team
- **Spec-aware mode:** engaged (the file is named `feature-specification.md` and carries the canonical feature-spec headings)
- **Size:** medium (one skill's surface plus its docs, with a human-in-the-loop gate as a new cross-cutting concern). Round cap: 2.
- **Specialists engaged:** `han-core:junior-developer`, `han-core:adversarial-validator`, `han-core:evidence-based-investigator`, `han-core:user-experience-designer`
- **Findings raised:** F25, F26, F27, F28, F29, F30, F31, F32, F33, F34, F35, F36, F37, F38, F39, F40, F41, F42, F43, F44, F45, F46 (major); F47, F48, F49, F50, F51, F52, F53 (minor)

### What the round found

Three of the four agents independently landed on the same structural hole, which is the strongest signal the round produced. The gate blocks only on claims the skill *reports* as unevidenced, and a fabricated claim typically arrives with a confident pointer at a real hunk rather than with nothing attached. Such a claim was never marked unevidenced, so it landed in the tier the engineer could clear with one keystroke. The bulk-accept affordance had become the "supported" badge that D2 deleted, restated in the only currency the engineer actually feels, which is effort (F25, F26).

The evidence-based investigator verified the spec's "carried forward" claims against `han-github/skills/update-pr-description/` and refuted three of them. The `gh` CLI hard stop is a real guard that D22 never mentions (F29). The conformance rules define a replace-scaffold state the spec's two-state model denies (F30). And the reading-order guide's exemption from the gate rests on a premise the skill's own content rule contradicts, since its bullets are defined as pointers to "a decision, tradeoff, or risk" (F27). It cleared seven other claims, including D3's description of the lean core, D9's threshold, D11's enumeration of the rewrite passes it removes, and the Open Items claim about `AskUserQuestion` under a parent skill, which it verified word for word against the guidance file.

The UX review found that the gate's failure mode is not too little rigor but too much of it in the wrong places: the templated path gave the *smallest* change the *longest* gate (F28), dropping a claim was the cheapest disposition and made the remaining gate shorter (F42), and there was no way out of a started gate except through it (F41).

### Questions put to the user

Four findings could not be resolved from evidence because each overturned or refined a recorded decision:

1. **The bulk-accept hole (F25, F26).** Chose to keep the bulk path and make it honest, and added an adversarial pass that refutes each claim against its evidence before the gate and demotes what it refutes. The pass reads only and may never touch the words, which is what keeps D11 and T1 intact.
2. **The reading-order guide (F27).** Chose to narrow its content to pure navigation, making D9's exemption true by construction rather than by assertion.
3. **The paraphrased intent (F44).** Chose to keep D17 as written. The YAGNI candidate is recorded as kept with the evidence cited.
4. **The template N/A blowup (F28).** Chose set-level disposal for sections the change does not reach.

### Changed in plan

`## Outcome`, `## Actors and Triggers`, `## Primary Flow` (rewritten from six steps to eight; the file-set pass and the adversarial pass are new), `## The Gate` (substantially rewritten), `## Alternate Flows and States`, `## Edge Cases and Failure Modes`, `## User Interactions`, `## Coordinations`, `## Out of Scope`, `## Deferred (YAGNI)`, `## Open Items`, `## Summary`, `## Review History` (added)

### Changed in tech-notes

T2 added: refutation is a separate pass that reads the claims and never touches the words.

### Changed in decision log

D23 through D31 added. D22 annotated with the guard it missed.

### Stability assessment

Not stable. The round produced 22 major findings, well past the stop rule's threshold of two or fewer with zero major. The spec absorbed a new pass, a restructured gate, an escape hatch, and nine new decisions, and none of that has been reviewed by anyone.

### Next step

Run R2 against the rewritten spec. The round should concentrate on what R1 introduced rather than re-reviewing what it fixed: whether the adversarial pass creates a contradiction with T1 or D11 that its own note failed to anticipate, whether the reordered and re-tiered gate is still internally consistent, and whether the escape hatch and the un-assembled claim list interact cleanly with the fail-closed rule. R2 is the last round under the medium cap.
