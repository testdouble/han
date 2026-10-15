# observability-engineer

Operator documentation for the `observability-engineer` agent in the han plugin. This document helps you decide _when_
and _how_ to dispatch the agent. For what the agent does internally, read the agent definition at
[`han-core/agents/observability-engineer.md`](../../agents/observability-engineer.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md) · [YAGNI](../../../docs/yagni.md) · [Evidence](../../../docs/evidence.md)

## TL;DR

- **What it does.** Audits telemetry design for the cost, sampling, naming, and pipeline problems that leave a team
  unable to afford its telemetry or missing the request it needs when something breaks.
- **When to dispatch it.** A change, plan, or module adds or alters instrumentation, metrics, spans, log schemas,
  sampling rules, or a telemetry pipeline. Conditionally dispatched by `/architectural-analysis`, `/code-review`,
  `/gap-analysis`, `/iterative-plan-review`, `/plan-a-change`, `/plan-a-feature`, and `/plan-implementation` when the
  work touches telemetry design.
- **What you get back.** A telemetry design report keyed to `file_path:line_number`, naming the anti-pattern, the
  principle it violates, the failure it leads to, and the smallest change that fixes it today.

## Key concepts

- **Default stance: _"This telemetry will fail the team."_** The agent assumes the telemetry will cost too much to keep,
  will not join up across signals, or will have thrown away the request you need. Each finding names the failure it
  leads to: series explosion, ingestion cost spike, dropped error traces, unjoinable signals, sensitive data shipped to
  a vendor, or instrumentation overhead on a hot path.
- **Cardinality is decided where the value originates.** The agent reads callers to trace each metric label back to its
  source, because a label fed from a user ID, request ID, or raw URL path creates a new time series per value.
- **Named telemetry anti-patterns.** Unbounded metric label, value baked into a metric name, wrong instrument type,
  naming drift from semantic conventions, head sampling that drops the errors, unguarded pipeline, sensitive attribute
  shipped unscrubbed, triple-written event, and hot-path instrumentation overhead.
- **Neutral between two schools.** The events-first school (wide structured events, aggregated at read time) and the
  metrics-first school (metrics with tightly bounded labels) are both defensible. When a finding turns on that
  trade-off, the agent names both and recommends the one that fits the stack the codebase already uses.
- **Boundaries on both sides.** SLOs, alert rules, and dashboards stay with `devops-engineer`. Source-line
  debuggability, correlation IDs, and PII in individual log statements stay with `on-call-engineer`. This agent owns the
  design of the telemetry in between: what is emitted, how it is named and labeled, what is sampled, and what the
  pipeline does to it.

## When to use it

**Dispatch when:**

- A change adds or alters metric instruments or labels, span attributes, or log schemas.
- A change touches OpenTelemetry SDK setup: samplers, exporters, views, or resource attributes.
- A change touches telemetry pipeline configuration: an OpenTelemetry Collector, Prometheus scrape or relabel rules, or
  a log shipper such as Fluent Bit or Vector.
- A telemetry bill grew and you want the change or module that drives it reviewed for label cardinality and duplicate
  emission.
- A plan introduces tracing, a new metrics backend, or a sampling strategy and you want the design checked before it is
  built.

**Do not dispatch for:**

- **SLO definitions, error budgets, burn-rate alert rules, alert routing, dashboards, or general production
  readiness.** Use [`devops-engineer`](./devops-engineer.md) instead. When a telemetry design problem would make an SLO
  or alert wrong, this agent reports the telemetry cause and names `devops-engineer` for the alert consequence.
- **Whether a code path is debuggable, whether correlation IDs propagate, whether log statements are structured, or
  whether a single log line leaks PII.** Use [`on-call-engineer`](./on-call-engineer.md) instead. This agent does own
  scrubbing in the pipeline and SDK configuration, and the cardinality of attributes whose sensitivity
  `on-call-engineer` checks.
- **A single new log line or metric on a new code path.** Use [`on-call-engineer`](./on-call-engineer.md). Whether the
  new path is observable at all is a debuggability question, not a telemetry design one.
- **Schema, index, or query design.** Use [`data-engineer`](./data-engineer.md).
- **Exploit-path vulnerability analysis.** Use [`adversarial-security-analyst`](./adversarial-security-analyst.md).
- **Writing instrumentation or changing pipeline configuration.** This agent produces a findings report. It does not
  modify code or configuration.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-core:observability-engineer`.

Give it:

1. **A focus area.** A branch, a directory, a set of source files with instrumentation calls, a plan, or telemetry
   configuration files. Include the SDK setup and Collector or shipper configuration on the export path when they
   exist, so the agent can check what leaves the process before anything scrubs it.
2. **A telemetry brief (optional).** The backend in use, how it bills (by volume, by active series, or by tag
   combination), rough request volume, and any cost or missing-trace incidents. These answer the Protocol 1 questions
   and reduce Open Questions most.
3. **An output path (optional).** The agent writes the full report to disk and returns only a summary. The default
   filename is `observability-review.md`.

Example prompts:

- _"Review the telemetry this branch adds to `src/checkout/`. We export OTLP to a Collector, then to Datadog, which
  bills custom metrics per tag combination. Checkout runs at about 50 req/s."_
- _"Audit `otel-collector.yaml` and the SDK setup in `src/telemetry/`. Last month we could not find the trace for a
  failed payment and want to know whether sampling dropped it."_

## What you get back

- A summary in the tool-call response:
  - A one-to-three sentence telemetry posture statement that leads with the most consequential problem.
  - A severity count table (Loses the evidence / Runaway cost / Analysis friction / Polish / YAGNI candidate).
  - An Open Questions count.
  - The path to the full report.
- A full report on disk with:
  - Scope, including anything deferred to a sibling agent.
  - Telemetry profile: the change under review, what it emits, the pipeline and backend, and which school the codebase
    uses.
  - Question log (Answered / Assumed / Open), assumptions, and open questions.
  - Numbered `OBS-###` findings, each with a named anti-pattern, the principle violated, a `file_path:line_number`
    location, the exact line as evidence, the impact, related questions, a severity, and two remediations (the smallest
    safe step today, then the follow-on).
  - An Observability Improvement Summary covering what was found, how to improve, how to prevent it, and premature
    telemetry machinery.

A protocol that finds no issue is still listed, with what the agent examined. A finding that rests on an input the agent
could not inspect carries its own `Unverified:` line on the finding itself, so the disclosure travels with the claim.

## How to get the most out of it

- **Name the backend and its billing model.** The agent will not assume a billing model the codebase does not show. If
  it cannot find one, cost findings stay scoped to conditions and the question goes Open.
- **Give it production volume.** Cardinality and sampling findings depend on how many requests, items, or tenants flow
  through the path. Without a number, the agent flags it Open rather than inventing one.
- **Include the pipeline, not only the instrumentation.** Redaction, sampling, and batching often live in Collector or
  shipper configuration. Scoping to application source alone hides half the picture.
- **Treat Open Questions as work.** Each one names the findings that depend on it and how to resolve it: read a file,
  measure in production, ask the team, or dispatch a sibling agent.
- **Pair with `devops-engineer` when alerts or SLOs depend on the telemetry.** This agent checks that the data is
  sound; `devops-engineer` checks the SLOs and alerts built on it.
- **Pair with `on-call-engineer` for new production code paths.** `on-call-engineer` checks that the path emits enough
  to debug it; this agent checks that what it emits is affordable, consistently named, and kept by the sampler.

## YAGNI

The agent applies Han's canonical YAGNI rule to telemetry machinery. Tail sampling, a Collector gateway tier, retention
tiers, custom semantic-convention registries, and exemplar wiring are YAGNI candidates unless the change shows the
volume, the cost, or the incident that justifies them. Direct export from the SDK is a legitimate design for a small
service, and the agent does not recommend adding a Collector without a reason in the change. Sampling added to a
low-volume service, or where every record must be kept, is flagged as a YAGNI candidate.

Findings that fail the evidence test carry the YAGNI candidate severity. The report's Premature Telemetry Machinery
section names each one, the test it fails, and the trigger that would justify reopening it. See
[YAGNI](../../../docs/yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the
deferral format.

## Cost and latency

The agent runs on `opus`. Tracing each label to its origin, estimating cardinality across labels, and reconciling SDK
setup with pipeline configuration is multi-step reasoning, so a single audit is slower and more expensive than a lookup
agent. Scope it to the files and configuration a change touches, and avoid dispatching it in tight loops over every
file in a large diff.

## Sources

The agent's vocabulary, anti-patterns, and boundaries come from the research at
[`docs/research/observability-engineer-research.md`](../../../docs/research/observability-engineer-research.md). The
sources below are the ones the agent draws named artifacts from.

### OpenTelemetry, "Sampling"

Head sampling is cheap but can drop errors; tail sampling keeps errors and slow traces but holds state and can degrade
under load; teams combine the two. This is the basis for the Head sampling that drops the errors anti-pattern and the
Sampling Design Sweep.

URL: https://opentelemetry.io/docs/concepts/sampling/

### Prometheus, "Instrumentation practices"

Each label set is a new time series. Keep a metric's label cardinality under about ten, and rethink past a hundred.
Per-user labels, values in metric names, instrument-type misuse, and hot-path overhead are named anti-patterns. The
agent treats the numeric thresholds as calibration examples, not rules.

URL: https://prometheus.io/docs/practices/instrumentation/

### OpenTelemetry, "Semantic conventions"

The shared naming vocabulary that makes telemetry consistent and correlatable across code, libraries, and platforms.
The basis for the Naming and Semantic Conventions Sweep.

URL: https://opentelemetry.io/docs/concepts/semantic-conventions/

### OpenTelemetry Collector

Receivers, processors, and exporters that batch, retry, and filter telemetry, with direct export noted as fine for
small setups. The basis for the Pipeline Configuration Sweep and the agent's YAGNI stance on adding a Collector.

URL: https://opentelemetry.io/docs/collector/

### OpenTelemetry, "Handling sensitive data"

The team owns what is sensitive. Minimize collection, review attributes that instrumentation libraries emit on their
own, scrub in the Collector, and do not trust hashing to hide identifiers drawn from a small set of values. The basis
for the Sensitive attribute shipped unscrubbed anti-pattern.

URL: https://opentelemetry.io/docs/security/handling-sensitive-data/

### Charity Majors, "Build observable systems" (Honeycomb, 2017)

The events-first position: wide per-request events, high cardinality, and read-time aggregation. The agent cites it as
one of the two schools it stays neutral between. Published by a vendor.

URL: https://honeycomb.io/blog/2017/06/build-observable-systems/

### Google, _Site Reliability Engineering_, "Monitoring Distributed Systems"

The metrics-first position, the Four Golden Signals, and the point that averages hide the tail, which is why the agent
expects latency in a histogram.

URL: https://sre.google/sre-book/monitoring-distributed-systems/

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs
  tree.
- [YAGNI](../../../docs/yagni.md). The evidence-based "You Aren't Gonna Need It" rule this agent applies. The two gates,
  the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Agents Index](../../../docs/agents/README.md). All agents, grouped by role.
- [`devops-engineer`](./devops-engineer.md). The sibling on the alerting side of the line. This agent owns telemetry
  design; `devops-engineer` owns SLOs, alert rules, dashboards, and production readiness.
- [`on-call-engineer`](./on-call-engineer.md). The sibling on the source-line side. This agent owns telemetry design and
  pipeline scrubbing; `on-call-engineer` owns debuggability, correlation IDs, and PII in individual log statements.
- [`data-engineer`](./data-engineer.md). Schema and query design stay there.
- [`/architectural-analysis`](../../../han-coding/docs/skills/architectural-analysis.md). Adds this agent to its roster
  when the module carries telemetry design.
- [`/code-review`](../../../han-coding/docs/skills/code-review.md). Conditionally dispatches this agent when the change
  adds or alters telemetry design.
- [`/gap-analysis`](../../../han-research/docs/skills/gap-analysis.md). Dispatches this agent as a swarm specialist
  when the gaps touch telemetry design.
- [`/iterative-plan-review`](../../../han-planning/docs/skills/iterative-plan-review.md). Conditionally dispatches this
  agent in team mode when the plan touches telemetry design.
- [`/plan-a-change`](../../../han-planning/docs/skills/plan-a-change.md). Dispatches this agent as a signal-selected
  review specialist when the change touches telemetry design.
- [`/plan-a-feature`](../../../han-planning/docs/skills/plan-a-feature.md). Dispatches this agent into the spec-stage
  team on a telemetry signal.
- [`/plan-implementation`](../../../han-planning/docs/skills/plan-implementation.md). Dispatches this agent into the
  implementation team on a telemetry signal.
- [Research backing this agent](../../../docs/research/observability-engineer-research.md). The evidence-based research
  informing the agent's scope, boundaries, and vocabulary.
- [agent-domain-focus.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md).
  Why the agent uses precise domain vocabulary and named anti-patterns.
- [agent-model-selection.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md).
  Rationale for the `opus` model tier.
