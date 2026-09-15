### Review Checklist

## Contents

- YAGNI
- Correctness
- Data Isolation (when applicable)
- Performance
- Error Handling
- Testing
- API Design
- Code Maintainability
- Code Organization
- Documentation
- Code Style & Patterns
- Database (when applicable)
- Packaging (when applicable)
- Architecture Decision Records (when applicable)

**YAGNI** (apply [../../../references/yagni-rule.md](../../../references/yagni-rule.md); these become `YAGNI-###` items
in the separate YAGNI section, never CRIT/WARN/SUGG)

Apply YAGNI in two passes for every change in the diff. Severity calibration is governed by SKILL.md Step 3.3 (the
authoritative home), but YAGNI findings are advisory regardless of size and run at every change size.

1. **Pass 1, evidence test.** For each new abstraction, configuration knob, defensive guard, observability hook,
   runbook, SLO, index, audit column, feature flag, or speculative addition, ask whether the diff contains evidence of
   need from one of the acceptable evidence types in [`yagni-rule.md`](../../../references/yagni-rule.md) Gate 1. If
   yes, do not flag.
2. **Pass 2, anti-pattern check.** Only for items that fail Pass 1, match against the named anti-patterns below. Items
   that match any anti-pattern become `YAGNI-###` findings. The body of the finding must name (a) the failing evidence
   type from Pass 1, (b) the matched anti-pattern from this list, and (c) the simpler form considered.

Named anti-patterns to match in Pass 2:

- New abstraction (interface, base class, port, adapter) introduced for code with one current concrete implementation
  and no churn history
- Configuration knob, env var, or feature flag added with no caller setting a non-default value, no documented rollout
  strategy, or no expiration criterion
- Defensive guard (null check, type check, validation) added at a trusted internal boundary the caller fully controls
- Runbook added for an alert that has never fired, or where the upstream signal isn't reaching the destination yet (the
  canonical project example: Sentry runbooks for staging-only Sentry where data isn't reaching production)
- Observability instrumentation, dashboard, log field, or distributed-trace span added for telemetry that isn't reaching
  the destination, or for failure modes that have never occurred
- SLO, error budget, or burn-rate alert defined for traffic the system doesn't yet receive
- Multi-region, HA, or failover infrastructure added for a workload that hasn't proven single-region pressure
- Index added with no measured slow query or running access pattern that uses it
- Audit column, version column, or change-tracking column added with no consumer (no query, no UI, no report, no
  compliance pipeline reads it)
- Code or comment justifying its presence with "for future flexibility", "in case we want to…", "when we scale", "best
  practice says", or symmetry with another feature ("we have create, so we should have delete") with no concrete
  near-term need
- A strictly simpler form (single function instead of class, inline check instead of helper, literal instead of
  configurable, single concrete instead of interface) would satisfy the same evidence as the introduced code

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
- If no test files exist for the reviewed code, flag as a Warning — detailed coverage analysis is also performed by
  testing agents in Step 7, but complete absence of tests must be caught here

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
- Prefers language-idiomatic constructs over manual reimplementations (e.g., built-in iteration/aggregation methods over
  manual loop-and-accumulate, standard library functions over hand-rolled equivalents)

**Database** (when applicable)

- Migration files follow the project's naming convention
- Schema changes are backward compatible, new columns have appropriate defaults or are nullable
- Frequently queried columns have indexes

**Packaging** (when applicable)

Fires when the diff changes what gets packaged: shading or relocation rules, vendoring, include or exclude patterns,
dependency scope changes, or bundling configuration. **This category does not open the built artifact.** The review
reads source text; it acquires no new command and inspects no jar, wheel, bundle, or image. What the category does is
tell the reader the review has that hole and name what to check by hand.

- Default severity: Warning. The summary-table row's Description cell opens with `Not checked —`, so a triaging reader
  sees a row that reports something unverified rather than something proven.
- **The first sentence is derived from the diff; the rest is fixed.** The first sentence names the specific rule or
  pattern the diff added and the specific symptom it could produce. Sentences two onward are invariant, so a builder who
  pastes the worked example with the path swapped produces one varying sentence and not five identical ones.

Worked example, pinned so two runs write the same thing:

```markdown
**WARN-002** `build.gradle:41` Someone installs the published jar and calls `WidgetFactory.create`, and it fails at
startup with a missing-class error, because the exclude rule added here drops a class that surviving classes still
reference. This review did not open the built artifact and cannot tell you whether that happened: the exclude
patterns say what was removed, not what still points at it. A green build is not evidence either, because a
development run has a wider classpath than the shipped artifact. Check the produced artifact before merging: that
every internal reference resolves inside it, that no third-party package is exported unrelocated, and that the
licence notices the packaging requires are present. **Fix:** by hand.
```

**Mode scope.** This category applies in Mode A only. Step 4's Mode B and Mode C conservative rule admits only
focus-area items, source-file items, and file-boundary items, and without a base-branch diff the run cannot tell what
the change altered about packaging. Same reason the YAGNI checklist is suspended in those modes.

**Architecture Decision Records** (when applicable)

- Changes align with accepted decisions in the project's ADR directory
- New patterns don't contradict existing ADRs without proposing a superseding ADR
- ADR violations are design-level issues — default to Warning or Critical severity
