# Team Findings: `/research` skill

This file records every finding raised by the review team for the `/research`
skill specification, and how each was resolved. Behavioral outcomes live in
[../feature-specification.md](../feature-specification.md); decisions the
findings affected live in [decision-log.md](decision-log.md). No
`feature-technical-notes.md` exists for this feature, so `Affected tech-notes:`
is omitted from finding entries.

Review team (Medium size, 4 agents): `junior-developer`, `gap-analyzer`,
`edge-case-explorer`, `adversarial-security-analyst`. All ran on sonnet with
domain-scoped briefs.

## Major findings

### F1: Research sizing signals undefined

- **Agent:** junior-developer (also edge-case-explorer #8)
- **Finding:** Primary Flow committed to small/medium/large classification but defined no research-specific signals; Han's code-change signals (file count, subsystems) do not translate to "how does X work". Flagged as the single highest-priority, decision-blocking gap.
- **Resolution:** Added D15 defining behavioral sizing signals (number of viable approaches, number of technical domains, breadth of reach) with a pre-dispatch scope statement so a misread is catchable.
- **Resolved by:** evidence
- **Affected decisions:** D15 (new), D5
- **Changed in spec:** Primary Flow, User Interactions, Edge Cases and Failure Modes

### F2: Option-comparison angle undefined for non-comparative questions

- **Agent:** junior-developer (YAGNI symmetry flag; gap-analyzer adjacent)
- **Finding:** "How does X work" is a named trigger but has no discrete options; the unconditional three-angle dispatch was a symmetry/completeness anti-pattern.
- **Resolution:** Made the option-comparison angle conditional — it runs only when the question implies discrete alternatives, skipped otherwise (the simpler version, mirroring the existing pure-external-research conditional).
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Changed in spec:** Primary Flow, Outcome

### F3: `gap-analyzer` reuse rests on an unchecked assumption

- **Agent:** junior-developer
- **Finding:** D4 reused `gap-analyzer` for the option-comparison angle, but `gap-analyzer` is fundamentally a two-artifact current-vs-desired comparator (verified: `plugin/agents/gap-analyzer.md` requires two inputs and declares a comparison direction). "Weigh options A/B/C" is not that shape; the reuse repeats the vocabulary-mismatch risk a new agent was added to avoid.
- **Resolution:** Escalated to the user. User chose to drop `gap-analyzer` from the roster; the new research agent owns option-comparison; `codebase-explorer` and `adversarial-validator` are reused. D4 amended.
- **Resolved by:** user input
- **Affected decisions:** D4
- **Changed in spec:** Primary Flow, Coordinations, Summary

### F4: Indirect prompt injection through fetched web content

- **Agent:** adversarial-security-analyst
- **Finding:** D3 makes arbitrary web content a first-class input; the spec named no trust boundary, so directive language in a fetched page could be followed by sub-agents and shape the recommendation.
- **Resolution:** Added D16 control 1 — fetched web content is treated as claims to evaluate, never as instructions; directive language is recorded as a claim, not acted on.
- **Resolved by:** evidence
- **Affected decisions:** D16 (new)
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes, Coordinations

### F5: Report laundering — D11's "has a URL" test is trivially satisfied

- **Agent:** adversarial-security-analyst
- **Finding:** A crafted page with a valid URL satisfied D11's verifiability test and could launder a false claim into an authoritative-looking recommendation.
- **Resolution:** Strengthened D11 — an external claim bearing on the recommendation must be corroborated by an independent source or codebase evidence; uncorroborated external claims are caveated and cannot be the sole basis.
- **Resolved by:** evidence
- **Affected decisions:** D11
- **Changed in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### F6: Context exfiltration via crafted research queries

- **Agent:** adversarial-security-analyst
- **Finding:** The codebase and web angles run in parallel with no stated context isolation; a fetched page could instruct the agent to include codebase contents, which would surface in the report.
- **Resolution:** Added D16 control 2 — open-web-angle agents receive no codebase or operator context; findings are aggregated by source.
- **Resolved by:** evidence
- **Affected decisions:** D16 (new)
- **Changed in spec:** Primary Flow, Coordinations

### F7: Web reach widens an unacknowledged trust boundary

- **Agent:** adversarial-security-analyst
- **Finding:** Web-sourced evidence was treated structurally identically to codebase evidence; the spec did not classify it as a distinct trust level.
- **Resolution:** Added D16 control 3 — web-sourced and provided third-party evidence is structurally distinguished in the report as a different trust level than codebase-anchored evidence.
- **Resolved by:** evidence
- **Affected decisions:** D16 (new)
- **Changed in spec:** Outcome, Coordinations

### F8: Adversarial validation does not gate on evidence-gathering integrity

- **Agent:** adversarial-security-analyst (also edge-case-explorer #4 adjacent)
- **Finding:** D7 chartered the validator to attack evidence, framing, and recommendation, but not whether the evidence-gathering itself was influenced by malicious external input — downstream of the injection window.
- **Resolution:** Extended D7 — the validator also attacks evidence-gathering integrity (injected/shaped items, single-item sensitivity, stale/adversarial/convenient sources).
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Changed in spec:** Primary Flow, Outcome

### F9: Compound multi-thread question unhandled

- **Agent:** edge-case-explorer
- **Finding:** A question bundling several independent research threads would be merged into one report, silently conflating evidence-to-recommendation alignment across threads (systemic).
- **Resolution:** Added D17 — name the threads, ask which to run first, defer the rest; no merge.
- **Resolved by:** evidence
- **Affected decisions:** D17 (new)
- **Changed in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### F10: Hybrid research-plus-sibling classification rule missing

- **Agent:** edge-case-explorer (also gap-analyzer GAP-2)
- **Finding:** The "request mixes research with a sibling concern" edge case said what to produce but not how to classify the boundary; the same hybrid question would route nondeterministically across runs.
- **Resolution:** Added D18 — if an answerable research question remains once the sibling request is set aside, run research and name the sibling; otherwise redirect entirely.
- **Resolved by:** evidence
- **Affected decisions:** D18 (new)
- **Changed in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### F11: Post-validation recommendation rewrite ambiguous

- **Agent:** edge-case-explorer
- **Finding:** "Reshaped" was ambiguous; an overturned recommendation could be left standing above a contradicting validation section (data corruption — confidently wrong top-line signal).
- **Resolution:** Updated D7 and Primary Flow step 9 — if the recommendation does not survive validation, its section is rewritten into the "no clear winner" form, not annotated in place.
- **Resolved by:** evidence
- **Affected decisions:** D7, D6
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F12: Codebase-vs-web evidence conflict unhandled

- **Agent:** edge-case-explorer
- **Finding:** The conflict rule covered web-vs-web only; codebase-vs-web (the more consequential adoption case) had no behavior.
- **Resolution:** Extended D11 — surface the conflict explicitly; codebase is the current-state anchor and "continue with the current approach" becomes a named option.
- **Resolved by:** evidence
- **Affected decisions:** D11
- **Changed in spec:** Edge Cases and Failure Modes

### F13: Operator-provided material from an interested party

- **Agent:** edge-case-explorer
- **Finding:** Provided material had no precedence rule; a vendor whitepaper could silently override independent evidence, laundering the operator's prior belief.
- **Resolution:** Extended D11 — provided material is held to the same scrutiny as web sources and checked by the validation pass for conflicts with independent sources.
- **Resolved by:** evidence
- **Affected decisions:** D11, D16
- **Changed in spec:** Edge Cases and Failure Modes, Coordinations

### F14: Re-run / output-path overwrite guard missing

- **Agent:** edge-case-explorer
- **Finding:** Re-invocation was unaddressed; a specified output path would silently overwrite a previously accepted report (data corruption).
- **Resolution:** Added D19 — collision guard (ask before overwrite; default location non-colliding). Prior-report diffing deferred under YAGNI (simpler version).
- **Resolved by:** evidence
- **Affected decisions:** D19 (new)
- **Changed in spec:** Primary Flow, User Interactions, Edge Cases and Failure Modes, Deferred (YAGNI)

### F15: Stale web source has no detection signal

- **Agent:** edge-case-explorer
- **Finding:** D11 addressed unverifiability but not staleness; an LLM may treat an outdated page as current with no date signal.
- **Resolution:** Extended D11 — web evidence carries its retrieval date; D7 validator charter includes temporal validity of web claims.
- **Resolved by:** evidence
- **Affected decisions:** D11, D7
- **Changed in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### F16: Disambiguation abort gate dropped

- **Agent:** gap-analyzer (GAP-1)
- **Finding:** The recommendation made poor disambiguation a stop-and-revisit condition; the spec carried only the ordering constraint, not the abort gate.
- **Resolution:** Updated D9 and the Coordinations table — if clean bidirectional disambiguation cannot fit the description budget for all five neighbors, the recommendation requires revisiting before implementation proceeds.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Changed in spec:** Coordinations, Out of Scope

## Minor edits

- F17: Forward the corrected ~14+ file rollout cost figure (recommendation V8) into OI-1 — gap-analyzer (GAP-3) — later settled by user as D20 (rollout plan) — feature-specification.md#open-items, decision-log.md#d20-rollout-plan
- F18: Enumerate the specific count/sizing files (CLAUDE.md, README.md, docs/concepts.md, docs/sizing.md, docs/skills/README.md) in OI-1 — junior-developer (F5/OQ-5) — later settled by user as D20 (rollout plan) — feature-specification.md#open-items, decision-log.md#d20-rollout-plan
- F19: No skills-index category fits cleanly; recommend grouping with `/investigate` under a relabeled "Investigation & research" grouping — junior-developer (F6/OQ-6) — later settled by user as D21 (skills-index grouping) — feature-specification.md#open-items, decision-log.md#d21-skills-index-grouping
- F20: Forward the recommendation's skill-composition vs. skill-decomposition contradiction as OI-3 so implementers do not cite both as co-equal authorities — gap-analyzer (GAP-4) — later resolved by a full `/investigate` run with adversarial validation, settled as D22 (skills calling skills); `/research` complies with the safe pattern, broader contradiction tracked as a separate Han maintenance item — feature-specification.md#open-items, decision-log.md#d22-skills-calling-skills, artifacts/skills-calling-skills-investigation.md
- F21: Reframe Primary Flow step 3 behaviorally (drop the "before dispatching" sequencing mechanic; commit to the visible redirect and non-production of a report) — edge-case-explorer (#9, mechanics-leak) — feature-specification.md#primary-flow
- F22: Soften the "file path / source URL" wording in Outcome to the behavioral "a source the reader can independently check"; keep the E#/V# numbering (Han product vocabulary, consistent with `/investigate`'s user-facing doc and the source recommendation) — junior-developer (F8, mechanics-leak) — feature-specification.md#outcome, decision-log.md#d11
