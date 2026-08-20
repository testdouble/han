# Team Selection

## Contents

- Size bands and the specialist cap
- The roster
- Domain-scoped briefs

The size bands, the specialist cap, the round cap, and the roster Step 3 draws from.
Step 3 selects using this file; it does not restate it.

## Size bands and the specialist cap

**Default to small.** Start the classification at **small** and only escalate to medium or large when the signals below
clearly require it. When a signal is borderline, stay at the smaller band. Use the spec's coordinations, T# count,
security/PII surface, integration boundaries, and the user's framing:

The cap is counted in **chosen specialists**, not in total seats. Two seats are filled on every team before any
specialist is chosen, so counting seats would make the medium band identical to the small one.

- **Small** _(default)_ — single subsystem, no cross-service integration, no auth/PII/secrets, no data migration.
  **1 chosen specialist** (team of 3: han-core:plan-synthesizer + han-core:junior-developer + 1). Round cap: **1.**
- **Medium** — two to three subsystems, optional integration, may touch UX or rollout, may have a small auth surface.
  **2 chosen specialists** (team of 4). Round cap: **2.**
- **Large** — cross-service, security-sensitive, data ownership shifts, multiple new coordinations, or the user
  explicitly requests full team. **3 to 4 chosen specialists** (team of 5 to 6). Round cap: **3.**

**Size override.** If `$size` is non-empty (the user passed `small`, `medium`, `large`, or `dynamic` as the first
argument), use it: a band value is the size and skips the signal-based classification above, while `dynamic` forces the
signal-based classification even when the project config sets a default band. If `$size` is empty and the project
config supplies a band via `default-swarm-size` (per the config rule in
[../../references/config-rule.md](../../../references/config-rule.md)), use that band and skip the signal-based
classification. The specialist cap and round cap still scale to the chosen size. State the chosen size, the recommended team,
and the reason for the size choice to the user in one short message before launching agents (e.g., "Medium: two
subsystems, small auth surface", "Medium: passed via `$size`", or "Medium: from the project `.han/config.md`
`default-swarm-size`", naming whichever of the two files supplied it). If
the user disagrees, accept the override (size, specific specialists, or both) and proceed.

## The roster

The team **always includes**:

- `han-core:plan-synthesizer` — final synthesizer, dispatched once in Step 8 rather than per round.
- `han-core:junior-developer` — generalist stress-tester and reframer.

Select additional specialists up to the specialist cap based on what the feature actually touches. Err toward including a
specialist rather than discovering a gap late. Unless the user specified a team composition, draw from:

- `han-core:user-experience-designer` — any user-facing flow, UI, or interaction model.
- `han-core:adversarial-security-analyst` — authentication, authorization, PII, untrusted input, secrets, supply chain.
- `han-core:devops-engineer` — deployment, observability, rollout, feature flags, scale, SLO impact, cost.
- `han-core:on-call-engineer` — application-source resilience patterns the plan introduces: timeouts and deadline
  propagation, retry logic with backoff and jitter, idempotency-key wiring, queue and buffer handling, async /
  blocking-I/O patterns, bulkhead boundaries, correlation-id propagation, kill-switch wiring,
  observability-of-the-failure-path at the application source line. Hard boundary against `han-core:devops-engineer`:
  infrastructure, IaC, pipelines, and observability platform configuration stay there.
- `han-core:structural-analyst` — module boundaries, coupling, where the implementation fits in the system.
- `han-core:behavioral-analyst` — runtime behavior, data flow, error propagation, state transitions.
- `han-core:concurrency-analyst` — concurrent access, race conditions, async coordination, ordering.
- `han-core:software-architect` — intra-codebase architectural recommendations, module/class/interface sketches,
  SOLID-grounded refactoring paths. Include when the feature is mostly internal to one codebase or one bounded context.
- `han-core:system-architect` — cross-service / bounded-context topology, context-map relationships, integration
  patterns (sync vs. async, saga, ACL, OHS), data ownership across services, failure-domain containment. Include when
  the feature crosses a service boundary, introduces a new integration, changes a context-map relationship, or shifts
  data ownership. Include both when the feature does both.
- `han-core:risk-analyst` — prioritization of architectural and delivery risks.
- `han-core:test-engineer` — observable-behavior test planning and test doubles.
- `han-core:edge-case-explorer` — boundary values, input messiness, state-dependent failures.
- `han-core:data-engineer` — schema changes, migrations, data movement, analytics implications.

Extra agents named in the project config's `## Extra Agents` list join this specialist pool and compete under the same
what-the-feature-touches selection and specialist caps, per
[../../references/config-rule.md](../../../references/config-rule.md): select one only when the feature touches its
stated specialty, count it against the specialist cap, and skip an entry that does not resolve to a dispatchable agent with
a one-line note.

If the user specified which agents to include, honor that. Otherwise, state the proposed team composition to the user
briefly before launching — one line per specialist with the reason they were selected — and proceed.

## Domain-scoped briefs

Pass each selected specialist only the sections relevant to its domain, plus the pointers below.

| Specialist                                                  | Spec sections to include in brief                                                                                                                                                                         |
| ----------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `han-core:user-experience-designer`                         | Outcome, Primary Flow, User Interactions, Edge Cases (UX-relevant rows only)                                                                                                                              |
| `han-core:adversarial-security-analyst`                     | Outcome, Coordinations, Edge Cases, sections touching auth/PII/secrets/supply-chain                                                                                                                       |
| `han-core:devops-engineer`                                  | Outcome, Coordinations, Out of Scope, Open Items                                                                                                                                                          |
| `han-core:on-call-engineer`                                 | Sections naming outbound calls, retry behavior, queue or buffer handling, async work, error handling on failure paths, schema migrations, idempotency, kill switches, and observability of new code paths |
| `han-core:structural-analyst`                               | Sections naming module boundaries, coupling, dependency direction                                                                                                                                         |
| `han-core:behavioral-analyst`                               | Sections describing runtime behavior, data flow, error propagation, state                                                                                                                                 |
| `han-core:concurrency-analyst`                              | Sections touching concurrent access, race conditions, async coordination                                                                                                                                  |
| `han-core:software-architect` / `han-core:system-architect` | Architecture / topology / context-map sections                                                                                                                                                            |
| `han-core:risk-analyst`                                     | Architectural and delivery risks; depends on upstream specialist findings                                                                                                                                 |
| `han-core:test-engineer` / `han-core:edge-case-explorer`    | Outcome, Primary Flow, Alternate Flows, Edge Cases                                                                                                                                                        |
| `han-core:data-engineer`                                    | Sections touching schema, migration, data movement, analytics                                                                                                                                             |
| `han-core:junior-developer`                                 | Outcome + first paragraph of every section (plain-language overview)                                                                                                                                      |

Give each agent:

- The full feature specification path (so it can read further) plus the relevant section excerpts inline in the brief.
  Also pass the spec's `artifacts/decision-log.md`, `artifacts/team-findings.md`, and
  `artifacts/feature-technical-notes.md` paths if they exist (fall back to the spec folder root for legacy layouts) —
  **as paths only, not contents**, so the agent can read on demand.
- The path to `artifacts/.discovery-notes.md` from Step 2, with a directive: **read the discovery notes first; do not
  re-grep for what is already there. Search further only for what your domain specifically needs that the discovery
  notes do not cover.**
- **The path to every item of visual material in `ui-designs/`, and the state each one shows, with a directive to read
  them.** Every dispatched specialist gets this, not only the design specialist: which one is most harmed by the omission
  varies by feature, and a specialist reviewing a design-driven feature without the designs is reviewing a paraphrase.
  Pass the boundary record's path too, so the specialist can see the recorded scope its recommendations must fit inside.
- A directive on report length: **scope your report to the size of the work being planned.** Name a rough target line
  count matched to the work item recorded in `artifacts/scope-boundary.md` rather than a size word the specialist has to
  interpret. For a one-card ticket, name a report closer to 150 lines than 750. It is a target and not a cap, so a
  specialist with more worth saying still says it. This governs how much each specialist writes and never how many
  specialists are chosen; the specialist caps in Step 3 own that and are unaffected.
- A directive on blind spots: **where a finding of yours rests on an input you could not inspect, say so on the finding
  itself, in the form your own definition specifies.** A disclosure in an assumptions section below the finding does not
  travel with it, and this skill reads each finding where it stands.
- A specific question framed for their domain — not "any concerns?" but "what does implementing this feature look like
  from your domain's vantage point, and what evidence grounds your recommendation?" Include the directive: **read
  additional spec sections only if your domain needs context not in the excerpts above. Cite what you read.**
- The evidence-first directive on Open Questions: **before raising an Open Question, re-read the relevant
  feature-specification section; if the spec already answers it, cite the line and do not raise it.** This keeps
  spec-answered questions out of the loop instead of costing a Step 6 pass to retire.
- A directive to return concrete, evidence-cited recommendations for the implementation plan — not behavioral rework of
  the spec.
- A directive to apply the YAGNI rule from [../../references/yagni-rule.md](../../../references/yagni-rule.md) to every
  recommendation: each abstraction, interface, configuration knob, runbook, observability hook, dashboard, alert, SLO,
  feature flag, infrastructure component, schema column, index, partition, audit machinery, retention pipeline, or test
  category recommended must cite evidence per the rule's evidence test (named upstream finding the change resolves,
  existing code path that breaks, three current concrete uses, measured incident or workload, applicable regulation).
  Recommendations failing the evidence test are returned as **`Category: YAGNI candidate`** findings with the reopening
  trigger named. Recommendations whose upstream concern is satisfied by a strictly simpler implementation should propose
  the simpler implementation. The agents most prone to over-engineering — `han-core:software-architect`,
  `han-core:system-architect`, `han-core:devops-engineer`, `han-core:data-engineer`, `han-core:on-call-engineer` —
  already encode this rule in their definitions; honor it.
- A directive to treat any `T#` entries in `feature-technical-notes.md` as **committed mechanics the plan must honor** —
  not open questions to re-debate. If the specialist disagrees with a `T#` note, they choose one of three verdicts, and the
  third is what keeps a scope objection out of the escalation path:
  - **Confirm** the mechanic.
  - **Contradict** it, raising a **"`T#` contradiction" finding** that cites the specific `T#` ID, describes the behavioral
    conflict, and names the alternative mechanic they recommend.
  - **Declare it out of scope for this work item**, raising an **"out of scope" finding** that cites the recorded boundary
    rather than naming an alternative mechanic. This verdict names no replacement, which is exactly why it needs its own
    kind: the contradiction protocol detects a disagreement by whether an alternative was named, so an unnamed verdict
    would otherwise fall through to the general path and reach the user as a question their own work item already answered.

  The plan routes contradiction findings through the facilitation loop (Step 5) and, if necessary, reopens the spec-stage
  decision. A specialist may not silently override a committed `T#`. An out-of-scope verdict resolves by citing the work
  item, with no escalation, and **does not count toward the spec-maturity threshold** in Step 5: a specification that
  committed to work outside its ticket has drifted, not failed to mature, and pausing spec-stage work is the wrong remedy.
  The same third verdict applies to specification decisions, not only to `T#` notes.

- A directive to cite sections by filename and heading when raising findings — e.g.,
  `feature-specification.md#primary-flow`, or a specific `D#` in the spec's `artifacts/decision-log.md`, or `T3` in the
  spec's `artifacts/feature-technical-notes.md` — so the han-core:plan-synthesizer can cross-reference them precisely
  during synthesis.

Collect every agent's verbatim output. If an agent returns "no concerns from my side," that is a valid answer — record
it.
