# Team Findings: Leaner Code-Review Output Document

<!--
This file records every finding raised by the review team for the leaner code-review
output document, and how each was resolved. Behavioral outcomes live in
[../feature-specification.md](../feature-specification.md); decisions the findings
affected live in [decision-log.md](./decision-log.md).

Review team: junior-developer, information-architect (small-feature cap of 2).
Overlapping findings from the two agents are consolidated under a single F# ID with
both sources noted.
-->

## Major findings

### F1: Verification rule mandating the SEC→CRIT cross-reference contradicts the de-duplication

- **Agent:** junior-developer (F1); information-architect (IA-002)
- **Finding:** The skill's structural verification step contains a rule requiring every security finding to carry a critical-severity cross-reference. D3 removes that cross-reference, so the rule would fail every compliant review (or be silently ignored). The spec did not name the verification rules as a change target.
- **Resolution:** Pulled the skill's generation and verification rules into scope as an explicit coordination (D12). The cross-reference mandate is dropped; the spec's Coordinations table now states this rule changes in lockstep with the structure.
- **Resolved by:** evidence
- **Affected decisions:** D3, D12
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations

### F2: Table-completeness verification rule is ambiguous for YAGNI and security findings

- **Agent:** junior-developer (F2)
- **Finding:** The verification rule "the Review Summary table includes every finding and matches the detailed sections" is undefined once YAGNI findings (never in the table) and security findings (prose only in the security block) exist. Read literally it could demand YAGNI rows in the table.
- **Resolution:** D12 scopes the table-completeness rule to corrective and security findings and preserves the existing rule that YAGNI findings stay out of the table.
- **Resolved by:** evidence
- **Affected decisions:** D12
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations

### F3: "Prose appears exactly once" carve-out for the table row was only stated for security findings

- **Agent:** junior-developer (F3); information-architect (IA-004, partial)
- **Finding:** The success criterion is the spec's own definition of done, but the "table row is an index, not prose" carve-out appeared only in the security alternate flow, leaving the common corrective-finding case ambiguous (is the table's brief description a second prose instance?).
- **Resolution:** Added a global carve-out to the Outcome: each finding has a single prose home (the finding block, or the full security block for security findings); the table row and pointer references are not prose.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome

### F4: D4's "recommendation reflects security severity" had no verification backstop once the cross-reference is dropped

- **Agent:** junior-developer (F4)
- **Finding:** D4 keeps the de-duplication safe by folding security severity into the merge recommendation, but no verification rule enforced it. The dropped cross-reference was the old structural signal tying security findings to the recommendation.
- **Resolution:** D12 adds a verification rule that, when any security finding exists, the Review Recommendation reflects the highest security severity — replacing the structural guarantee the cross-reference used to provide.
- **Resolved by:** evidence
- **Affected decisions:** D4, D12
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Coordinations

### F5: Dual-class case (same location as both YAGNI and corrective) was unspecified

- **Agent:** junior-developer (F5)
- **Finding:** With the category label condensed, an implementer could accidentally place a finding in both the YAGNI section and a severity section. The current skill defines YAGNI as categorically non-corrective, but the spec did not restate or rely on that invariant.
- **Resolution:** Primary Flow step 6 and an edge-case row now state explicitly that YAGNI is a categorically non-corrective class — the YAGNI section is its only home, never a severity section or the table — citing D9.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F6: A security finding's severity was not visible in the summary table after dropping the cross-reference

- **Agent:** information-architect (IA-001)
- **Finding:** With the cross-reference gone, the table's Category cell shows an OWASP code (e.g., A01), not a tier. A reader scanning the "single at-a-glance index" could not tell whether a security row is a merge blocker without reading the recommendation or the deep security block.
- **Resolution:** Escalated to the user. The user chose to show the tier inline on security rows only (e.g., `SEC-001 (Critical)`), avoiding a redundant Severity column for corrective rows whose task-ID prefix already encodes the tier (D11).
- **Resolved by:** user input
- **Affected decisions:** D11
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### F7: Dropping [Category] from every finding block weakened orientation for standalone / PR-comment readers

- **Agent:** information-architect (IA-003)
- **Finding:** The PR-posting path renders each finding block as an independent GitHub comment with no summary table in view. ADR and standards categories name the specific violated document (content, not just a tier), so a blanket drop loses information for a random-access reader.
- **Resolution:** Escalated to the user. The user chose to keep content-bearing categories (ADR violations, standards violations, security) on blocks while dropping generic ones (logic, performance, clarity), amending D7.
- **Resolved by:** user input
- **Affected decisions:** D7
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

## Minor edits

- F8: The security remediation note's "names what was found" wording was tightened to "references the SEC-### IDs and states the actionable remediation in one or two sentences, without repeating finding descriptions," foreclosing a second prose instance — junior-developer (F6), information-architect (IA-004) — Primary Flow.
- F9: The collapsed security-improvement text is now a labeled remediation note so a reader can tell it is remediation guidance, not a restated finding — information-architect (IA-005) — Primary Flow.
- F10: Added a fixed section-order invariant (Critical, Warnings, Suggestions, YAGNI, security blocks, remediation note, What's Good) so lazy sections do not produce unpredictable positioning — information-architect (IA-006) — Primary Flow.
- F11: The risk that an absent What's Good section reads as a negative signal was deferred under YAGNI with a reopening trigger, rather than adding standing explanatory prose now — information-architect (IA-008) — Deferred (YAGNI).
- F12: The PR-posting consumer requirement was broadened from "treat What's Good as optional" to "treat every lazy section as optional," covering absent severity sections on a clean review — junior-developer (F7) — Coordinations, Edge Cases and Failure Modes.
- F13: The skill's generation step instruction "include all sections even when empty" was named as an in-scope update via D12, resolving its contradiction with the lazy-section behavior — junior-developer (F8), information-architect (IA-007) — Coordinations.
- F14: The success criterion now states that pointer references (such as a self-consistency tension note citing another finding's task ID) are exempt from the prose-once rule — junior-developer (F10) — Outcome, Edge Cases and Failure Modes.
- F15: D10's long-form-doc coordination now names the affected sections (the "what the review produces" enumeration and the verify-step description) rather than leaving the doc-update scope open — junior-developer (F11) — Coordinations.
- F16: The three questions flagged for the Open Items section were all resolved during finding resolution (table-row carve-out via F3, security-severity verification via F4/D12, consumer lazy-section scope via F12), so no open items remain — junior-developer (F9) — Open Items.
