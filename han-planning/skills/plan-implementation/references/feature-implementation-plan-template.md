# Feature Implementation Plan: {Feature Name}

<!-- Opening paragraph, two to four plain-language sentences: what is being built, the implementation posture this plan commits to (e.g., "ship behind a feature flag, expand-and-contract migration"), and the one thing a reader must know first. A reader who stops here still knows what this plan does. -->

<!--
HOW THIS FILE IS LAYERED. This file is the reader's layer: intention, goals, and sequence in
plain language, ordered by how much a reader needs each section. Deeper layers live one hop away:
decision rationale and rejected alternatives in artifacts/implementation-decision-log.md; team
composition and round-by-round history in artifacts/implementation-iteration-history.md. When a
claim embodies a non-obvious decision, append an inline link, e.g.
"([D-3](artifacts/implementation-decision-log.md#d-3-rollout-strategy))". Link only claims a
reader would ask "why this?" about. Never inline rationale, alternatives, or round history here.

MINIMAL TECHNICAL DETAIL, BELOW THE PLAIN LANGUAGE IT BELONGS TO. Every section leads with
plain-language prose a non-author can follow. Technical detail is minimal references only — a
path, a contract name, a decision-bearing value (a flag default, a key name, a threshold) —
placed below or after the plain language it illustrates, never mixed into it: in prose, the
identifier follows the sentence that explains it; in lists, it nests as a sub-bullet under the
plain-language bullet it supports. Never prescribe line-level changes, inline full file contents,
or enumerate every edit: a non-author must be able to read the plan, plans are executed after
the codebase has moved (so edit lists go stale and mislead), and the implementer — human or
coding agent — reads the current code at build time. When choosing between more plain language
and more technical detail, choose more plain language.
-->

## Outcome

<!-- Plain language: what exists in the codebase, the runtime, and the user's hands when this plan is executed, and who it serves. Two short paragraphs at most. -->

## User Stories

<!-- The intent of the work at a high level, before any mechanics. Derive each story from behavior the specification already commits to — never invent behavior. One story per bullet: "As a {actor}, I want {capability}, so that {benefit}." Give each a US-N ID so work units can name the story they advance. When the feature has no end-user surface, frame stories around the operator or consuming system. Omit the section only when no actor benefits in a describable way. -->

- **US-1:** As a {actor}, I want {capability}, so that {benefit}.

## Constraints and Boundaries

<!-- Only the bullets with real content — omit the rest. -->

- **Driving constraint:** <!-- why now — deadline, incident, commitment -->
- **Out of scope:** <!-- what this plan deliberately does not do, and why -->
- **Watch after ship:** <!-- omit when nothing qualifies -->

## Implementation Approach

<!-- The shape of the implementation in plain prose: how the feature fits into the system, what it reuses, what it introduces, where the boundaries are. Lead with intention; name touch points, not edits. Technical identifiers appear only after the plain-language sentence they illustrate, or as a nested sub-bullet under it. Add a focused subsection ONLY for a surface the plan commits a real decision on (e.g., "Data model changes", "External interfaces") — a few sentences of intention plus its D-N links, not an inventory of changes. Omit every surface with nothing decided. -->

### {decision-bearing surface}

## Work Units and Sequencing

<!-- Work units sized to ship. Keep Delivers at intention altitude ("invite emails send through the existing mailer"), not a file list. Story names the US-N each unit advances (or `—` when none applies; drop the column when the User Stories section was omitted). Link non-obvious shapes to D-N. -->

| #   | Work Unit | Story | Delivers | Depends On | Verification |
| --- | --------- | ----- | -------- | ---------- | ------------ |
| 1   | …         | US-1  | …        | —          | …            |

## Definition of Done

<!-- Testable and unambiguous. Cite the decisions a criterion satisfies. -->

- [ ] <!-- Behavior X is observable when action Y occurs -->
- [ ] <!-- Tests cover ([D-1](artifacts/implementation-decision-log.md#d-1-...)) -->

## Testing Strategy

<!-- Lead with the behaviors that prove the feature works; one line each for mechanics. -->

- **Observable behaviors to test:** …
- **Edge cases requiring coverage:** …
- **Test doubles posture and levels:** <!-- stubs for queries, mocks for commands; unit / integration / e2e mapping -->

## Security Posture

<!-- LAZILY CREATED — only if `adversarial-security-analyst` contributed or the plan commits to a concrete mitigation. No threat surface → omit the section entirely (confirm first; omission records that judgment). Name the specific threat vectors and committed mitigations — never vague "we'll be secure" language. -->

## Operational Readiness

<!-- LAZILY CREATED — only if `devops-engineer` contributed or the plan commits to a concrete production-readiness step; otherwise omit (confirm first). Only the bullets with real commitments: observability signals, SLO touchpoints, feature flag (name, default, widening criteria, rollback criterion), rollout and rollback steps, cost, compliance. -->

## On-Call Resilience Posture

<!-- LAZILY CREATED — only if `on-call-engineer` contributed or the plan commits to a concrete application-source resilience measure; otherwise omit (confirm first). Only the bullets with real commitments: timeouts, retries, idempotency, bulkheads, backpressure, kill switches, degradation, failure-path observability, data integrity, migration safety. Application source only; infrastructure lives in Operational Readiness. -->

## Risks and Assumptions

<!-- LAZILY CREATED — only when at least one real entry exists; omit an empty sub-table, omit the whole section when both are empty (confirm first). -->

### Risks

| ID  | Risk | Impact | Mitigation | Owner |
| --- | ---- | ------ | ---------- | ----- |
| R1  | …    | …      | …          | …     |

### Assumptions

<!-- Status is exactly one of: `Verified` (a source cite settles it: file:line, ADR, standard), `Runtime-only` (unknowable until it runs), or `Open`. One status per assumption; a separate runtime unknown gets its own row. -->

| ID  | Assumption | What Changes If Wrong | Status |
| --- | ---------- | --------------------- | ------ |
| A1  | …          | …                     | …      |

## Deferred (YAGNI)

<!-- LAZILY CREATED — only if at least one item was deferred under the YAGNI rule; never an empty stub. -->

### {item name}

- **Why deferred:** {gate failure; named anti-pattern when applicable}
- **Reopen when:** {concrete trigger}
- **Source:** {R#, specialist name}

## Open Items

<!-- Questions the project-manager could not resolve through evidence, reframing, or user input. -->

- **OI-1:** <!-- question or concern -->
  - **Resolves when:** …
  - **Blocks implementation:** Yes / No — <!-- reason -->

## Specialist Handoffs for Implementation

<!-- LAZILY CREATED — only when at least one specialist should be re-engaged during implementation. -->

- **`{specialist}`** — dispatch when <!-- condition -->; needs <!-- input artifact -->.

## Sources and Plan Records

<!-- Provenance plus where the deeper layers live. This section replaces any team-composition table or statistics summary — those live in the artifacts. Omit any line whose file does not exist. -->

- **Feature specification:** [{filename}]({relative-path})
  <!-- No spec file? State: "No source specification file — inputs were: {one-line summary}". -->
- **Specification companions:** [decision log](artifacts/decision-log.md), [team findings](artifacts/team-findings.md), [technical notes](artifacts/feature-technical-notes.md)
- **Specification decisions inherited / open items to respect:** D1, D2… / OI-1…
- **Decision rationale and rejected alternatives:** [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Team composition and round-by-round history:** [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)

## Recommendation

<!-- One or two sentences: Ship as planned | Hold for specialist handoff X | Blocked — OI-N unresolved — and why. -->
