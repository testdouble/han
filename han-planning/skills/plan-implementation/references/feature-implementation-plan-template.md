# Feature Implementation Plan: {Feature Name}

<!-- One-to-two-sentence summary of what the feature is and the implementation posture this plan commits to (e.g., "ship behind a feature flag, expand-and-contract migration, two-week slice"). -->

<!--
CROSS-REFERENCING GUIDANCE

This file is the primary implementation plan. Decision records live in
[artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md) and round-by-round
iteration history lives in [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md).

Inline decision references:
- When a claim in this file embodies a non-obvious decision, append a parenthetical
  link to the decision in artifacts/implementation-decision-log.md, e.g.
  "...behind a LaunchDarkly flag ([D-3](artifacts/implementation-decision-log.md#d-3-rollout-strategy))."
- Link only non-obvious claims — not every sentence. "Non-obvious" means a reader
  would reasonably ask "why this and not something else?"
- Do not inline rationale or rejected alternatives — those belong in the decision log.
- Do not record round-by-round history here — that belongs in the iteration history.
-->

## Source Specification

- **Feature specification:** [{filename}]({relative-path-to-feature-specification.md}) <!-- Markdown link to the source spec so readers can jump to it. If no file was provided (e.g., conversational context only), state "No source specification file — inputs were: {one-line summary of what was provided}". -->
- **Specification decision log:** [artifacts/decision-log.md](artifacts/decision-log.md) <!-- Omit if the source spec is not one produced by plan-a-feature or has no companion decision log. -->
- **Specification team findings:** [artifacts/team-findings.md](artifacts/team-findings.md) <!-- Omit if the source spec has no companion findings file. -->
- **Specification decisions this plan inherits:** D1, D2, D3… <!-- IDs from the spec's decision-log.md. Omit the line if no spec decision log existed. -->
- **Specification open items this plan must respect or resolve:** OI-1, OI-2… <!-- IDs from the spec's Open Items. Omit the line if no spec file existed. -->

## Outcome

<!-- Restate, in implementation terms, the outcome the completed work delivers. What will exist in the codebase, the runtime, and the user's hands when this plan is executed. -->

## Context

- **Driving constraint:** <!-- Why now — deadline, incident, customer commitment, strategic bet -->
- **Stakeholders:** <!-- Who cares about the outcome and what success looks like to each -->
- **Future-state concern:** <!-- What must be watched after ship so the system remains operable at scale -->
- **Out-of-scope boundary:** <!-- What this plan deliberately does not do, and why -->

## Team Composition and Participation

<!-- Which specialists contributed to the plan, with one line each on the input they fed into decisions. If a specialist was invited and stood down with "no concerns," record that. Full round-by-round detail lives in artifacts/implementation-iteration-history.md. -->

| Specialist | Status | Key Input |
|------------|--------|-----------|
| `project-manager` | Coordinator | <!-- Facilitated rounds and synthesized final plan --> |
| `junior-developer` | Reframer | <!-- Reframed open questions; noted assumptions --> |
| `{specialist}` | <!-- Active / Stood down --> | <!-- One-line summary with citation --> |

## Implementation Approach

<!-- The shape of the implementation: how the feature fits into the system, what it reuses, what it introduces, where boundaries are drawn. Technical details are welcome here — this is the *how* document. Keep statements grounded in evidence (existing code paths, ADRs, conventions). Append inline `([D-N](artifacts/implementation-decision-log.md#...))` links to non-obvious choices.

ALTITUDE: name and reference config and code artifacts; do not inline their full contents. Inline only the specific values that are themselves decisions (a flag default, a key name, a threshold). A full file block belongs in the file it configures, not in the plan. -->

### Architecture and Integration Points

<!-- Modules, services, or layers the implementation touches. How the feature plugs into existing interfaces. What new interfaces it introduces. Link non-obvious choices to the decision log. -->

### Data Model and Persistence

<!-- Schema changes, migrations, data movement. Expand-and-contract steps if applicable. Reference ADRs that constrain choices. Link non-obvious choices to the decision log. -->

### Runtime Behavior

<!-- How the feature behaves at runtime: call paths, control flow, state transitions, concurrency model. Cite existing patterns the feature follows. Link non-obvious choices to the decision log. -->

### External Interfaces

<!-- APIs, events, queues, third-party integrations the feature calls or exposes. Contract shape and versioning posture. Link non-obvious choices to the decision log. -->

## Decomposition and Sequencing

<!-- Break the implementation into work units sized to ship. For each unit, name what it delivers, what it depends on, and how it is verified. Append `([D-N](artifacts/implementation-decision-log.md#...))` links where a unit's shape reflects a non-obvious decision. -->

| # | Work Unit | Delivers | Depends On | Verification |
|---|-----------|----------|------------|--------------|
| 1 | <!-- e.g., Schema expand migration --> | <!-- new column, backfill job --> | <!-- — --> | <!-- migration test + staging run --> |
| 2 | <!-- e.g., Write path behind flag --> | <!-- dual-write, flag off --> | 1 | <!-- integration test + flag audit --> |
| 3 | … | … | … | … |

## RAID Log

<!--
LAZILY CREATED — include only the sub-tables that have at least one real entry,
and omit the whole RAID Log section when none of the four do. A small plan with
no tracked risks, assumptions, issues, or dependencies omits this section rather
than rendering empty tables. Confirm each sub-table is genuinely empty before
omitting it — omission records the judgment that nothing qualified, not a
skipped step.
-->

### Risks

| ID | Risk | Likelihood | Severity | Blast Radius | Reversibility | Owner | Mitigation |
|----|------|------------|----------|--------------|---------------|-------|------------|
| R1 | … | … | … | … | … | … | … |

### Assumptions

<!--
Status is exactly one of: `Verified` (a source cite settles it: file:line, ADR,
or standard), `Runtime-only` (cannot be known until it runs), or `Open` (not yet
checked). One status per assumption. If it is confirmed from source, it is
`Verified`. Do not tack on "but unverified at runtime". A separate runtime
unknown gets its own row. Mixing the two hides a settled fact and makes later
steps gate on it for no reason.
-->

| ID | Assumption | What Changes If Wrong | Verifier | Status |
|----|------------|-----------------------|----------|--------|
| A1 | … | … | … | … |

### Issues

| ID | Issue | Owner | Next Step |
|----|-------|-------|-----------|
| I1 | … | … | … |

### Dependencies

| ID | Dependency | Owner | Status |
|----|------------|-------|--------|
| Dep1 | … | … | … |

## Testing Strategy

<!-- Observable-behavior test plan sourced from test-engineer (and edge-case-explorer if engaged). Cover unit, integration, and end-to-end layers as applicable. Cite the specialist findings this section rests on. Append `([D-N](artifacts/implementation-decision-log.md#...))` links where the strategy reflects a non-obvious decision. -->

- **Observable behaviors to test:** …
- **Test doubles posture:** <!-- stubs for queries, mock expectations for commands — or inline what the specialist recommended -->
- **Edge cases requiring coverage:** …
- **Test levels:** <!-- unit / integration / end-to-end mapping -->

## Security Posture

<!-- LAZILY CREATED — write this section only if `adversarial-security-analyst` contributed findings or the plan commits to a concrete security mitigation. If the feature has no threat surface (no authentication, authorization, PII, untrusted input, or secrets), omit the section entirely rather than writing "no security concerns". Confirm there is genuinely no surface before omitting — omission records that judgment, not a skipped step.

If `adversarial-security-analyst` contributed, capture their concrete findings and the mitigations this plan commits to. Name the specific threat vectors addressed; do not paraphrase into vague "we'll be secure" language. Append `([D-N](artifacts/implementation-decision-log.md#...))` links where the posture reflects a non-obvious decision. -->

## Operational Readiness

<!-- LAZILY CREATED — write this section only if `devops-engineer` contributed or the plan commits to a concrete production-readiness step. If the change introduces no new observability, rollout, flag, scale, or cost concern, omit the section entirely rather than rendering empty bullets. Confirm there is genuinely no operational surface before omitting — omission records that judgment, not a skipped step.

If `devops-engineer` contributed, capture the production-readiness requirements this plan commits to: observability signals, SLO touchpoints, feature-flag strategy, rollout and rollback steps, cost posture, compliance controls. Append `([D-N](artifacts/implementation-decision-log.md#...))` links where the posture reflects a non-obvious decision. -->

- **Observability:** <!-- metrics, logs, traces to add; dashboards to touch -->
- **SLO impact:** …
- **Feature flag:** <!-- name, default, widening criteria, rollback criterion -->
- **Rollout:** <!-- stages, gates, who watches what -->
- **Rollback:** <!-- exact procedure and decision criterion -->
- **Cost and scale:** …

## On-Call Resilience Posture

<!-- LAZILY CREATED — write this section only if `on-call-engineer` contributed or the plan commits to a concrete application-source resilience measure. If the change adds no outbound calls, retries, queues, async paths, or other resilience surface, omit the section entirely rather than rendering empty bullets. Confirm there is genuinely no resilience surface before omitting — omission records that judgment, not a skipped step.

If `on-call-engineer` contributed, capture the application-source resilience commitments this plan makes. Each row maps to a named anti-pattern the agent flagged. Application source level only; infrastructure and pipeline concerns live in Operational Readiness above. Append `([D-N](artifacts/implementation-decision-log.md#...))` links where the commitment reflects a non-obvious decision. -->

- **Timeouts and deadlines:** <!-- which outbound calls get which timeouts; deadline propagation through the chain -->
- **Retry strategy:** <!-- backoff, jitter, total cap; coordination with retries elsewhere in the chain -->
- **Idempotency:** <!-- which retried side effects are guarded, and by what mechanism (caller-provided key, unique constraint, conditional update) -->
- **Bulkheads and concurrency caps:** <!-- which dependencies get isolated resource pools; what limits fan-out -->
- **Queue and backpressure:** <!-- bounded vs. unbounded; producer slowdown signal; visibility timeout; DLQ -->
- **Kill switches:** <!-- which risky new code paths are flag-gated; operator can flip without a redeploy -->
- **Graceful degradation:** <!-- what happens when each dependency is unavailable -->
- **Observability of failure paths:** <!-- log lines, metrics, spans, and SLI contributions that make new code paths observable per the ODD gate -->
- **Data integrity:** <!-- column lengths, integer types on monetary or rate-counter values, encoding boundaries, partial-write recovery -->
- **Migration safety:** <!-- expand/contract sequencing for any schema change; never co-deployed with dependent code -->


## Definition of Done

<!-- Testable, unambiguous, agreed across specialists. Cite the decisions each criterion satisfies. -->

- [ ] <!-- Behavior X is observable when action Y occurs -->
- [ ] <!-- Test coverage added for decisions ([D-1](artifacts/implementation-decision-log.md#d-1-...), [D-2](artifacts/implementation-decision-log.md#d-2-...)) -->
- [ ] <!-- Feature flag configured per Operational Readiness -->
- [ ] <!-- Observability signals live and dashboards updated -->
- [ ] <!-- Rollback procedure tested in staging -->
- [ ] <!-- Post-ship owner named and notified -->

## Specialist Handoffs for Implementation

<!-- For each specialist whose work will be called during implementation — name the specialist, when they should be dispatched, and what they will need as input. This is the reader's guide for who gets pulled back in. -->

- **`{specialist}`** — dispatch when <!-- condition -->; needs <!-- input artifact -->.

## Deferred (YAGNI)

<!--
Items considered during implementation planning but deferred under the YAGNI rule
([../../references/yagni-rule.md](../../../references/yagni-rule.md)).

LAZILY CREATED — write this section only if at least one item was deferred. If
nothing qualified, omit the section entirely. Do not write an empty stub.

For each deferred item:
- Item — the abstraction, configuration knob, runbook, observability hook,
  alert, dashboard, SLO, feature flag, infrastructure component, schema column,
  index, audit machinery, retention pipeline, test category, or other
  implementation artifact that was considered.
- Why deferred — which gate failed (evidence test or simpler-version test) and
  the specific reason. Cite the named anti-pattern from the rule doc when
  applicable (e.g., "runbook for never-fired alert", "single-implementation
  interface", "index for query that doesn't run").
- Reopen when — the concrete trigger that would justify revisiting (a measured
  metric, a real incident, a third concrete use of an abstraction, a customer
  commitment, a regulation taking effect).
- Source — the round (R#) or specialist that originally proposed the item.
-->

### {item name}
- **Why deferred:** {gate failure with specific reason; named anti-pattern when applicable}
- **Reopen when:** {concrete trigger}
- **Source:** {R#, specialist name}

## Open Items

<!-- Questions or concerns the project-manager could not resolve through evidence, junior-developer reframing, or user input. For each, why the plan is shippable anyway or what specifically is blocking ship. -->

- **OI-1:** <!-- question or concern -->
  - **Resolves when:** …
  - **Blocks implementation:** Yes / No — <!-- reason -->

## Summary

- **Outcome delivered:** <!-- One sentence -->
- **Team size:** <!-- N specialists --> — see [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Rounds of facilitation:** N — see [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Decisions committed:** N — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by evidence:** N — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by junior-developer reframing:** N — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by user input:** N — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Rejected alternatives recorded:** N — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Open items remaining:** N
- **Recommendation:** <!-- Ship as planned | Hold for specialist handoff X | Return to facilitation — open item Y unresolved -->
