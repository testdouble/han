# YAGNI Rule (Evidence-Based)

YAGNI — "You Aren't Gonna Need It" — is the rule this project uses to keep specs, plans, code, and operational machinery from accreting work that isn't needed yet. The rule is evidence-based, not absolute. Items survive when evidence justifies them. Items without evidence get deferred — recorded for later, not silently dropped.

Every line of code, every section of a spec, every runbook, every abstraction, every configuration knob, every observability hook is ongoing maintenance cost — and is also a pattern future agents will treat as load-bearing and copy. The bar for inclusion is "we need this now and have evidence to prove it," not "we might want this someday."

The categories below answer whether evidence exists at all (the inclusion gate). For how strong the evidence is once it exists — trust classes, the corroboration gate for web sources, the no-evidence label — see the companion [`evidence-rule.md`](./evidence-rule.md). The two rules work together; this one gates inclusion, that one characterizes quality.

## The two gates

### Gate 1: The evidence test (gate for inclusion)

Any committed item — feature behavior, spec section, code change, abstraction, configuration option, ADR, coding standard, runbook, observability hook, alert, test, plan step, build phase — must cite **at least one** piece of evidence that it is needed *now*. Acceptable evidence:

1. **A user-described need** in the source artifact (PRD, feature spec, ticket, conversation with the user, stakeholder commitment).
2. **A named direct dependency** — another in-scope item literally cannot work without it. The dependent item must itself pass the evidence test.
3. **An existing production code path or contract that will break without it** — cite the file/path/function or external consumer that depends on the current behavior.
4. **A regulatory or compliance rule that demonstrably applies to this project today** — cite the specific regulation and how it touches the change. "Compliance might require…" is not evidence.
5. **A documented incident, real production alert that has fired, real customer report, or measured metric** showing the problem exists. Hypothetical alerts don't qualify; alerts that have actually fired do.

If no evidence in this list applies, the item is **YAGNI** — defer it. Record the deferral with the trigger that would justify reopening it.

### Gate 2: The simpler-version test (gate for shape)

When evidence justifies an item, ask: **is there a strictly simpler version that satisfies the same evidence?**

- A simpler version uses fewer files, fewer abstractions, fewer configuration surfaces, fewer code paths, fewer tests, fewer phases.
- A single function beats a class. A class beats a class hierarchy. A class hierarchy beats a framework.
- One concrete implementation beats an interface with one implementation.
- A literal value beats a configurable value beats a configurable value with a default.
- An inline check beats a helper beats a middleware beats a framework.
- One end-to-end test beats one end-to-end test plus three integration tests plus twelve unit tests, when the end-to-end test catches every realistic failure mode.

If a simpler version satisfies the same evidence, the simpler version replaces the larger one. The larger version is YAGNI until the simpler one demonstrably falls short.

## Named anti-patterns (auto-flag as YAGNI candidates)

Any of the following, when found in a spec / plan / code change / ADR / runbook, is a YAGNI candidate by default. The evidence test must affirmatively justify keeping it.

- **"We might need…" / "for future flexibility" / "in case we want to…"** — pure speculation.
- **"When we scale" / "at scale" / "for performance"** — scaling work without measured pressure that the change actually addresses.
- **"Best practice says…" / "the standard is…"** — best practices that don't solve a problem this project actually has.
- **Symmetry / completeness** — "we have create, so we should have delete," "we have one endpoint, so we should have all the CRUD verbs," "this enum has three values, so the test should cover all three" when only one is reachable.
- **Single-implementation interfaces / abstract base classes** — abstractions introduced before three concrete uses exist (the Rule of Three).
- **Speculative configuration knobs** — config options no caller sets, env vars no environment overrides, feature flags wrapping a single code path with no rollout plan that uses them.
- **Defensive code at trusted internal boundaries** — null checks, type checks, and validation for inputs that internal callers fully control. Validate at system boundaries (user input, external APIs); trust internal contracts.
- **Speculative observability** — instrumentation, dashboards, or log fields for systems whose telemetry isn't reaching the destination yet, or for failure modes that have never occurred.
- **Runbooks for alerts that have never fired** and have no signal data flowing — the canonical example from this project's history (Sentry runbooks for staging-only Sentry where data isn't reaching production).
- **SLOs and error budgets for traffic the system doesn't yet receive.**
- **Multi-region / HA infrastructure** for a workload that hasn't proven single-region pressure.
- **Indexes for queries that don't run, audit columns nobody reads, denormalization for read patterns that don't exist, partitioning for data volumes the project doesn't have.**
- **Tests for code paths that don't exist yet, or for hypothetical adversaries the change doesn't touch.**
- **ADRs about decisions that don't have a forcing function today.**
- **Coding standards about patterns the project doesn't actually use yet.**
- **Phases of work whose only justification is "completeness of the roadmap."**

## How to apply YAGNI in skills and agents

### When producing artifacts (specs, plans, code recommendations)

For every item you are about to commit:

1. State the evidence that justifies the item, citing the source per the evidence test.
2. If no evidence applies, do not commit the item — record it under the artifact's `## Deferred (YAGNI)` section with the trigger that would justify reopening it.
3. If evidence applies, ask the simpler-version test. Replace with the simpler version when one satisfies the same evidence.

### When reviewing artifacts (review skills, review agents)

For every committed item in the artifact:

1. Run the evidence test. If no evidence is cited, raise a `Category: YAGNI candidate` finding.
2. Resolution paths for a YAGNI candidate finding:
   - **Cite the missing evidence** — the item is justified, finding closes.
   - **Replace with a simpler version** — record the rationale, the larger version moves to deferred.
   - **Move to `## Deferred (YAGNI)`** — record the trigger that would reopen it.
3. Anti-patterns from the named list above force a finding regardless of severity rules.

### Escalation

YAGNI candidates are **never silently dropped**. They surface to the user as deferrals with the reopening trigger named. The user always wins — they may direct an item to be kept against the rule. The rule's job is to make the cost of including the item visible so the choice is conscious.

## Deferred (YAGNI) section format

Every artifact that may produce YAGNI deferrals adds a section with this structure:

```
## Deferred (YAGNI)

### {item name}
**Why deferred:** {which gate failed — evidence test or simpler-version test, with the specific reason}
**Reopen when:** {the concrete trigger that would justify revisiting — a metric, an incident class, a customer commitment, a dependency landing, a regulation taking effect}
**Source:** {where the item was originally proposed — review finding ID, agent name, conversation context}
```

When no items are deferred, the section is omitted entirely (don't write empty stub sections).

## What YAGNI is not

- **Not "never plan ahead."** Plan ahead when planning ahead is the evidence — a regulatory deadline, a customer commitment, a dependency that requires lead time. The evidence test welcomes that.
- **Not "skip security / data integrity / correctness."** Critical-path correctness work passes the evidence test trivially. YAGNI applies to *speculative* security hardening, not to addressing actual exploit paths or actual data corruption.
- **Not "never refactor."** Refactor when the existing structure demonstrably impedes the change being made — that's evidence. Refactor for "cleanliness" alone is YAGNI.
- **Not an excuse to skip user-described requirements.** If the user said they want it, that is evidence. The rule challenges what *agents and skills* add on top of what the user asked for.
