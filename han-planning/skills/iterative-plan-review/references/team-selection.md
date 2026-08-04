# Team Selection

The roster for team-mode review rounds, the signals that select each specialist, and the caps each
size band sets. Step 3 selects using this file; it does not restate it.

**Always include these two** — they are the minimum roster and cannot be omitted:

- `han-core:junior-developer` — reframes the plan in plain terms and surfaces hidden assumptions, unstated
  prerequisites, and standards conflicts a generalist would notice.
- `han-core:adversarial-validator` — attacks the plan's evidence, proposed approach, and assumptions with
  counter-evidence, edge cases, and falsification attempts.

**`han-core:evidence-based-investigator` is conditionally mandatory** — include it whenever the plan contains codebase
claims to verify, and exclude it otherwise. The plan contains codebase claims if any of the following is true:

- the plan body contains a file path matching common source extensions (e.g., `.ts`, `.tsx`, `.js`, `.jsx`, `.svelte`,
  `.go`, `.rb`, `.py`, `.rs`, `.java`, `.kt`, `.swift`, `.cs`, `.php`);
- the plan references `src/`, `app/`, `lib/`, `internal/`, `pkg/`, or another source directory by path;
- the plan contains a line-number reference like `:NNN` or `lines NN–NN`;
- the plan names a function, class, or method in backticks alongside a file path or directory.

Run a quick `grep` over the plan to detect these signals before finalizing the team. If any single match is found,
include `han-core:evidence-based-investigator`. When in doubt, include it.

When `han-core:evidence-based-investigator` is not included, state to the user in one line:
"han-core:evidence-based-investigator is not required because the plan has no codebase claims to verify." If the user
explicitly names the agent, honor the request regardless of the heuristic.

**Select additional specialists up to the specialist cap from Step 2** (medium: 1 chosen specialist, large: 2) based
on what the plan actually touches. Fewer is better — only add an agent if their absence would meaningfully weaken the
review. Draw from:

- `han-core:user-experience-designer` — user-facing flows, UI, interaction models, accessibility.
- `han-core:adversarial-security-analyst` — authentication, authorization, PII, untrusted input, secrets, supply chain.
- `han-core:devops-engineer` — deployment, observability, rollout, feature flags, scale, SLO impact, cost.
- `han-core:on-call-engineer` — application-source resilience patterns named in the plan: timeouts, retry strategy,
  idempotency, backpressure, kill switches, observability of new code paths. Hard boundary against
  `han-core:devops-engineer`: defer infrastructure and pipeline concerns to it.
- `han-core:structural-analyst` — module boundaries, coupling, dependency direction, duplication.
- `han-core:behavioral-analyst` — runtime behavior, data flow, error propagation, state transitions.
- `han-core:concurrency-analyst` — concurrent access, race conditions, async coordination, ordering.
- `han-core:software-architect` — intra-codebase architectural fit, module/class/interface sketches, SOLID-grounded
  refactoring paths.
- `han-core:system-architect` — cross-service / bounded-context topology, context-map relationships, integration
  patterns, data ownership, failure-domain containment.
- `han-core:risk-analyst` — prioritization of architectural and delivery risks.
- `han-core:test-engineer` — observable-behavior test planning, test doubles.
- `han-core:edge-case-explorer` — boundary values, input messiness, state-dependent failures.
- `han-core:data-engineer` — schema changes, migrations, data movement, analytics implications.
- `han-core:gap-analyzer` — spec-vs-implementation gap checks when a source spec exists.
- `han-core:content-auditor` — documentation-preservation review when docs are being updated.
- `han-core:codebase-explorer` — feature discovery when the plan touches unfamiliar code regions.

**Selection rules**:

- Honor any agents the user named explicitly.
- Extra agents named in the project config's `## Extra Agents` list join this specialist pool and compete under the
  same what-the-plan-touches selection and specialist caps, per
  [../../references/config-rule.md](../../../references/config-rule.md): select one only when the plan touches its stated
  specialty, count it against the specialist cap, and skip an entry that does not resolve to a dispatchable agent with a
  one-line note.
- Justify each additional specialist in one line — what in the plan requires them.
- `han-core:risk-analyst`, `han-core:software-architect`, and `han-core:system-architect` consume upstream findings;
  only include them when at least one of `han-core:structural-analyst`, `han-core:behavioral-analyst`, or
  `han-core:concurrency-analyst` is also on the team.
- If `han-core:user-experience-designer`, `han-core:adversarial-security-analyst`, or `han-core:data-engineer` is
  relevant, include them over nice-to-haves — the risks they surface rarely surface elsewhere.

**Spec-aware mode roster rules** (apply only when spec-aware mode was engaged in Step 1):

- Do NOT include `han-core:structural-analyst`, `han-core:behavioral-analyst`, `han-core:concurrency-analyst`,
  `han-core:software-architect`, `han-core:system-architect`, or `han-core:data-engineer` in the default roster. These
  specialists are named after mechanic-level analysis that belongs in `plan-implementation`, not in a behavioral spec
  review.
- If the user explicitly names one of the excluded specialists, honor the request — but issue a one-line warning that
  the specialist may surface implementation-level findings the spec will not absorb. Such findings get deferred to
  `plan-implementation` rather than edited into the spec.
- The required agents are `han-core:junior-developer` and `han-core:adversarial-validator`;
  `han-core:evidence-based-investigator` is conditionally mandatory by the codebase-claims heuristic above. All three
  are generalist and evidence-oriented and serve the spec-review use case without modification.
- Remaining available specialists in spec mode: `han-core:user-experience-designer`,
  `han-core:adversarial-security-analyst`, `han-core:devops-engineer`, `han-core:on-call-engineer` (scoped to spec-level
  resilience commitments — idempotency, retry behavior, kill switches, graceful degradation — not file-and-line
  mechanics), `han-core:edge-case-explorer`, `han-core:test-engineer`, `han-core:gap-analyzer`, `han-core:risk-analyst`
  (no structural/behavioral/concurrency upstream dependency), `han-core:content-auditor`, `han-core:codebase-explorer`.

Present the proposed team to the user briefly — the required agents (and whether `han-core:evidence-based-investigator`
was included or skipped, with the reason) plus the chosen specialists, each with a one-line justification — and proceed.
If the user corrects the composition, adjust and continue.
