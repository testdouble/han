### Review Checklist

**YAGNI** (apply [../../../references/yagni-rule.md](../../../references/yagni-rule.md); these become `YAGNI-###` items in the separate YAGNI section, never CRIT/WARN/SUGG)

Apply YAGNI in two passes for every change in the diff. Severity calibration is governed by SKILL.md Step 3.3 (the authoritative home), but YAGNI findings are advisory regardless of size and run at every change size.

1. **Pass 1, evidence test.** For each new abstraction, configuration knob, defensive guard, observability hook, runbook, SLO, index, audit column, feature flag, or speculative addition, ask whether the diff contains evidence of need from one of the acceptable evidence types in [`yagni-rule.md`](../../../references/yagni-rule.md) Gate 1. If yes, do not flag.
2. **Pass 2, anti-pattern check.** Only for items that fail Pass 1, match against the named anti-patterns below. Items that match any anti-pattern become `YAGNI-###` findings. The body of the finding must name (a) the failing evidence type from Pass 1, (b) the matched anti-pattern from this list, and (c) the simpler form considered.

Named anti-patterns to match in Pass 2:

- New abstraction (interface, base class, port, adapter) introduced for code with one current concrete implementation and no churn history
- Configuration knob, env var, or feature flag added with no caller setting a non-default value, no documented rollout strategy, or no expiration criterion
- Defensive guard (null check, type check, validation) added at a trusted internal boundary the caller fully controls
- Runbook added for an alert that has never fired, or where the upstream signal isn't reaching the destination yet (the canonical project example: Sentry runbooks for staging-only Sentry where data isn't reaching production)
- Observability instrumentation, dashboard, log field, or distributed-trace span added for telemetry that isn't reaching the destination, or for failure modes that have never occurred
- SLO, error budget, or burn-rate alert defined for traffic the system doesn't yet receive
- Multi-region, HA, or failover infrastructure added for a workload that hasn't proven single-region pressure
- Index added with no measured slow query or running access pattern that uses it
- Audit column, version column, or change-tracking column added with no consumer (no query, no UI, no report, no compliance pipeline reads it)
- Code or comment justifying its presence with "for future flexibility", "in case we want to…", "when we scale", "best practice says", or symmetry with another feature ("we have create, so we should have delete") with no concrete near-term need
- A strictly simpler form (single function instead of class, inline check instead of helper, literal instead of configurable, single concrete instead of interface) would satisfy the same evidence as the introduced code

**Correctness**
- Does the code accomplish its stated purpose?
- Are edge cases handled (null, empty, boundary values)?
- Is the logic sound and free of off-by-one errors?

**Data Isolation** (when applicable)
- Database queries filter by the appropriate tenant/owner scope
- No cross-tenant data leakage in JOINs or subqueries
- List endpoints scoped to the authenticated user or organization
- Related entity lookups verify ownership before returning data

**Performance**
- No N+1 queries (check loops that call database)
- No unnecessary re-renders or redundant computations in frontend code
- Pagination used for list endpoints where appropriate
- Database queries use appropriate indexes
- Avoid fetching more data than needed

**Error Handling**
- Errors wrapped with context, not swallowed silently
- Errors checked and handled at the appropriate level
- Frontend includes error and loading states. API returns appropriate HTTP status codes.

**Testing**
- Unit tests for business logic and edge cases
- Integration or E2E tests for new endpoints or workflows
- Tests use appropriate test databases or fixtures (not production data)
- Tests clean up created data
- Async operations properly awaited or flushed before assertions
- If no test files exist for the reviewed code, flag as a Warning — detailed coverage analysis is also performed by testing agents in Step 7, but complete absence of tests must be caught here

**API Design**
- RESTful conventions followed
- Resource naming, response structure, and pagination follow project patterns

**Code Maintainability**
- Functions have single responsibility
- No deep nesting (prefer early returns)
- Magic numbers/strings extracted to named constants
- Complex logic broken into smaller, well-named functions
- No dead code or commented-out code

**Code Organization**
- Files placed in the correct package/directory per project structure
- Related code grouped together, naming follows project conventions

**Documentation**
- Complex or non-obvious logic has explanatory comments
- Public API doc comments follow project conventions. README updated for new features or setup changes.

**Code Style & Patterns**
- Matches existing codebase conventions and established project patterns
- Prefers language-idiomatic constructs over manual reimplementations (e.g., built-in iteration/aggregation methods over manual loop-and-accumulate, standard library functions over hand-rolled equivalents)

**Database** (when applicable)
- Migration files follow the project's naming convention
- Schema changes are backward compatible, new columns have appropriate defaults or are nullable
- Frequently queried columns have indexes

**Architecture Decision Records** (when applicable)
- Changes align with accepted decisions in the project's ADR directory
- New patterns don't contradict existing ADRs without proposing a superseding ADR
- ADR violations are design-level issues — default to Warning or Critical severity
