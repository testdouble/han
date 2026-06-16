**Size-based demotion (applies to every category below).** Size-based demotion is governed by [SKILL.md](../SKILL.md) Step 3.3, the authoritative home for size-based severity rules. The bands in each category define what each severity means; Step 3.3 governs which findings escalate to those bands at the change's size (read from Step 3.1). When uncertain, prefer the lower severity. The per-category bands below do not restate this rule.

### Processing test-engineer results

For each test plan item (T1, T2, ...) from the test-engineer, assign category **[Testing: Coverage Gap]** and classify severity:

- **CRIT**: Coverage gap for code handling security, data integrity, financial calculations, or authentication. Also CRIT when no tests exist at all for a significant new feature or endpoint.
- **WARN**: Coverage gap for business logic, error handling paths, or integration points.
- **SUGG**: Low-priority gap where brittleness risk is high or the code path is unlikely to regress.

### Processing edge-case-explorer results

For each edge case item (EC1, EC2, ...) from the edge-case-explorer, assign category **[Testing: Edge Case]** and classify severity:

- **CRIT**: Critical or High priority edge cases — likely AND severe AND not handled or tested. Especially those involving security, data corruption, or data isolation.
- **WARN**: Medium priority edge cases (plausible with moderate impact, or partially handled but untested).
- **SUGG**: Low priority edge cases (unlikely or low-impact).

### Processing adversarial-security-analyst results

For each security finding (SEC-001, SEC-002, ...) from the agent:
- Retain the SEC-### ID — do not convert to CRIT/WARN/SUGG
- Render one full `SEC-###` block per finding (OWASP category, location, evidence, `EXPLOIT:`, severity) under `## 🔐 Security Vulnerabilities`. This block is the single home for the finding's prose.
- Add one Review Summary table row per finding, with the severity tier shown inline in the Task ID cell (e.g., `SEC-001 (Critical)`) since the SEC-### ID does not encode a tier. Do **not** also add a CRIT-### cross-reference entry under `### 🔴 Critical` — security findings are not duplicated into the Critical section.
- The Review Recommendation reflects the highest severity across all findings including these security severities: a Critical-severity security finding yields a do-not-merge recommendation even though it is not listed under Critical.
- If the security agent found no proven vulnerabilities, the `## 🔐 Security Vulnerabilities` section and the Remediation note are omitted entirely.

Collapse the agent's Security Improvement Summary into a single short **Remediation** note that follows the SEC-### blocks: reference the SEC-### IDs and state the actionable remediation in one or two sentences. Do not restate the finding descriptions and do not carry a generic "how to prevent this going forward" narrative.

Security findings are not subject to the 30-item cap that applies to manual review and other agent findings.

### Processing structural-analyst results

For each structural finding (S1, S2, ...) from the structural-analyst, assign category **[Structure]** and classify severity:

- **CRIT**: Module boundary violation or cyclic dependency introduced by this change that blocks safe future work (e.g., domain code reaching into infrastructure, a new cycle that forces cascading edits).
- **WARN**: New coupling across seams, duplication with an existing utility, a leaky abstraction, or an unjustified interface with one implementation.
- **SUGG**: Cohesion or naming-level structural smells the reader can live with until a broader refactor.

### Processing behavioral-analyst results

For each behavioral finding (B1, B2, ...) from the behavioral-analyst, assign category **[Behavior]** and classify severity:

- **CRIT**: Silent data loss, error swallowed at an integration boundary, state mutation that violates a documented invariant, or data flow that sends incorrect values to an external system.
- **WARN**: Error propagation gap that only surfaces under failure modes, state-management coupling that makes the change brittle, or boundary assumption not matched by the caller.
- **SUGG**: Data-flow clarity issue — the code works, but the pathway is hard to trace.

### Processing concurrency-analyst results (only if dispatched)

For each concurrency finding (C1, C2, ...) from the concurrency-analyst, assign category **[Concurrency]** and classify severity:

- **CRIT**: Race condition on authentication, billing, data isolation, or any path where interleaving produces wrong data. Also CRIT for demonstrable deadlock or lock-ordering reversal.
- **WARN**: Shared-resource contention under realistic load, async error path that swallows failures, or missing cancellation/timeout handling on a long-running task.
- **SUGG**: Concurrency hazard that is theoretically possible but requires implausible interleaving, or an async pattern that should use a stronger primitive.

### Processing data-engineer results (only if dispatched)

For each data-engineer finding (D1, D2, ...), assign category **[Data]** and classify severity:

- **CRIT**: Schema or migration that causes data loss, corruption, or unrecoverable drift; a query that returns wrong rows under realistic concurrent writes; a destructive co-deploy; PII/PHI/PCI stored in plaintext where the project requires encryption; broken referential integrity introduced by this change.
- **WARN**: New N+1, missing covering index on a query the change introduces, expand-only migration that lacks a contract step, isolation-level mismatch with the access pattern, missing constraint on a column the change uses.
- **SUGG**: Naming, normalization-level, or modeling concerns the team can defer.

Reject findings that violate the calibration directive — particularly multi-instance / replay concerns where the storage primitive is naturally idempotent (e.g., flagging `CREATE INDEX IF NOT EXISTS` as a critical concurrent-deploy hazard). When in doubt about whether a finding survives the directive, demote one severity level.

### Processing devops-engineer results (only if dispatched)

For each devops-engineer finding (DV1, DV2, ...), assign category **[DevOps]** and classify severity:

- **CRIT**: Production-readiness gap that the change actively introduces and that has a non-benign worst case — a secret committed to source, a rollout step with no rollback path for a destructive change, an SLO-impacting regression with no observability to catch it, an auth or network policy that exposes a previously private endpoint.
- **WARN**: Missing observability for a new code path, missing feature flag for a behavior that warrants progressive rollout, a CI step that masks a real failure, a Dockerfile change that materially increases image size or attack surface.
- **SUGG**: Operational ergonomics — improved alerting, log-line shape, dashboard coverage — for code paths the change touches.

Reject findings that violate the calibration directive — particularly hypothetical scale problems for workloads the project does not currently have. Demote one severity level when in doubt.

### Processing on-call-engineer results (only if dispatched)

For each on-call-engineer finding (OCE1, OCE2, ...), assign category **[On-Call]** and classify severity:

- **CRIT**: A code-level resilience anti-pattern the change actively introduces that maps to a named production failure mode with a wakes-someone-up production impact — a retryable handler with a non-idempotent side effect and no idempotency key, a missing timeout on an outbound call on a hot path with a slow-prone dependency, catch-and-swallow on a path that produces wrong answers silently (gray failure), an unbounded queue or buffer with no backpressure, a schema migration co-deployed with dependent application code in the same diff, a fan-out loop with no concurrency cap, an integrity bug (truncation, overflow, encoding) on a financial or regulated path.
- **WARN**: Code-level resilience patterns this change introduces or worsens that degrade reliability but are unlikely to produce a wakes-someone-up failure on their own — retry logic without jitter, blocking I/O in an async context on a low-traffic path, missing correlation-id propagation on a new handler, missing kill-switch wiring on a risky new code path, ODD-gate failure on a new code path (no observable signal in the diff), eventual-consistency assumption without a guard.
- **SUGG**: Resilience-pattern polish on code the change touches — named error types over generic strings, structured-field log lines, more specific exception catches, helper extraction for repeated timeout-and-retry patterns.

Reject findings that cross the hard boundary into `devops-engineer` territory (Dockerfile, IaC, manifest, pipeline file, observability platform config, alert rule, dashboard, runbook-as-document). If a finding can only be expressed in those files, it belongs to DV-series, not OCE-series.

Apply the agent's own tone-anti-pattern sweep as a classification check: a finding that reads as sugarcoated criticism, thin blame, tourist citation, or bibliographic empathy should be either rewritten or omitted before being carried into the rollup.

### Processing junior-developer results

For each junior-developer finding (JD1, JD2, ...) from the junior-developer, assign category **[Clarity]** and classify severity:

- **CRIT**: Only when the finding names a direct violation of a documented coding standard, ADR, or CLAUDE.md rule. Clarity-for-clarity's-sake is never CRIT.
- **WARN**: Violation of a convention that the project clearly follows elsewhere, or an assumption baked into the change that a teammate would not spot from context.
- **SUGG**: Unclear naming, confusing control flow, or missing-but-optional comment explaining a non-obvious why.

Do not duplicate a junior-developer finding when another agent has already raised the same issue — prefer the specialist's classification and reference it from the JD finding instead.
