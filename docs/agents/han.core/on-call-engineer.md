# on-call-engineer

Operator documentation for the `on-call-engineer` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/on-call-engineer.md`](../../../han.core/agents/on-call-engineer.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md) · [YAGNI](../../yagni.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Audits application source code for the named code-level resilience anti-patterns that wake on-call engineers at 3am.
- **When to dispatch it.** A change is about to ship and you want a veteran on-call engineer to read the source for the patterns that reliably cause 3am pages — before the page happens. Conditionally dispatched by `/architectural-analysis`, `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, and `/plan-implementation` when the change touches application-source resilience surface (timeouts, retries, idempotency, backpressure, kill switches, failure-path observability).
- **What you get back.** A code-level resilience report keyed to `file_path:line_number`, naming the anti-pattern, the production failure mode it leads to, and a sequenced remediation (smallest safe step today, next iteration, paved path).

## Key concepts

- **Default stance: *"This will page someone at 3am."*** Every finding cites the source line, names the anti-pattern, names the named production failure mode (cascading failure, retry storm, thundering herd, metastable failure, gray failure, connection pool exhaustion, poison pill, queue runaway, slow memory leak, OOM-kill, thread pool starvation, data corruption, eventual-consistency violation, fan-out amplification), and gives the production-impact statement in concrete terms.
- **Adversarial to the artifact, empathetic to the engineer.** The agent has been the engineer whose code caused the page. The posture is toward the code and the pattern, never toward the human. Findings are written so the author can read them without feeling judged. Four named tone anti-patterns (sugarcoated criticism, thin blame, tourist citation, bibliographic empathy) are auto-checked against the agent's own findings before output.
- **Named code-level anti-pattern vocabulary.** Missing or incomplete timeouts (including DNS/TLS uncovered), retries without backoff and jitter, non-idempotent operations in retry paths, catch-and-swallow exception handling, unbounded queues/buffers/result sets, missing backpressure, blocking I/O in async contexts, missing bulkheads, hardcoded environment assumptions, schema migrations co-deployed with dependent code, missing correlation IDs, assuming dependencies are always available, missing rate limiting on fan-out, eventual-consistency violations, data integrity bugs, kill-switch absence, ODD-gate failure.
- **Metastable-failure detection as primary new contribution.** The Bronson et al. HotOS'21 / OSDI'22 vocabulary (a degraded steady state that persists after the trigger is removed, sustained by a positive feedback loop) is not carried by any other agent in the plugin. This agent makes it citable in code review.
- **Hard boundary against `devops-engineer`.** This agent reads application source files only. Dockerfiles, IaC, Kubernetes manifests, CI/CD pipelines, observability platform configuration, feature-flag platform configuration, alert rules, dashboards, runbooks-as-documents, and secrets management infrastructure all stay with `devops-engineer`.

## Summary

A 20+ year on-call veteran that reads application source code in a change and proves that real, named, file-and-line-located code-level resilience risks exist. Its default stance is that the code will fail in production and the author will not be the one paged for it. Every finding is backed by a `file_path:line_number` reference, the named anti-pattern, the named production failure mode it leads to, and a concrete production-impact statement. Adversarial language is directed at the artifact, never at any human. Every wakes-someone-up severity finding is paired with the smallest safe step the team can ship today, then a sequenced "next iteration" and "paved path next quarter" so the agent does not become a bottleneck. The agent runs a tone-anti-pattern sweep against its own findings (sugarcoating, thin blame, tourist citation, bibliographic empathy) before emitting them.

## When to use it

**Dispatch when:**

- A change is approaching production and you want a code-level review focused specifically on "what will wake someone up at 3am" — not style, not architecture, not security exploits.
- A new feature path is being added and you want a check that the basics are present in the source: timeouts, idempotency, backpressure, kill switches, correlation IDs, observability of the failure path.
- A team is shipping into a service with prior on-call pain and wants a structured pass over the diff before merging.
- A retry loop, queue handler, fan-out, schema migration, or other classically-load-bearing pattern is being added or modified.
- A junior engineer wants experienced on-call eyes on their change without having to interrupt a senior teammate.
- A code review is being run via `/code-review` and the change touches application code that runs in production.
- A planning or review skill (`/architectural-analysis`, `/plan-a-feature`, `/plan-implementation`, `/iterative-plan-review`, `/gap-analysis`) signals that application-source resilience patterns are in scope. The skill dispatches this agent for you when the focus area or plan touches the named patterns.

**Do not dispatch for:**

- **Infrastructure, pipeline, IaC, deployment, observability platform, or alert configuration review.** Use [`devops-engineer`](./devops-engineer.md) instead. The hard boundary lives at the application source line. If the finding cannot be expressed as a `file_path:line_number` in application source, it belongs to the DevOps engineer.
- **Exploit-path vulnerability analysis.** Use [`adversarial-security-analyst`](./adversarial-security-analyst.md). This agent focuses on operational and resilience patterns, not on exploit paths.
- **Race condition, lock ordering, or deadlock analysis at the critical-section level.** Use [`concurrency-analyst`](./concurrency-analyst.md). This agent flags blocking-I/O-in-async and missing-bulkhead patterns, but it does not analyze locks.
- **Module-boundary data flow or error propagation across modules.** Use [`behavioral-analyst`](./behavioral-analyst.md). This agent operates at the call site, not the module boundary.
- **Schema, index, query, or migration design.** Use [`data-engineer`](./data-engineer.md). This agent flags migrations co-deployed with dependent code as a deployment-safety pattern, but it does not evaluate the schema itself.
- **Risk scoring across architectural findings.** Use [`risk-analyst`](./risk-analyst.md). This agent produces its own severity tied to the named failure mode.
- **Bug triage or root-cause investigation after an incident.** Use [`/investigate`](../../skills/han.core/investigate.md). This agent is for prevention before the page, not diagnosis after.
- **Writing or iterating on the code.** This agent produces a findings report. It does not modify code.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:on-call-engineer`.

Give it:

1. **A focus area.** A branch, a directory, a feature folder, or a specific list of application source files. The narrower the scope, the sharper the findings. Avoid handing it the whole repo.
2. **A failure-mode brief, if you have one.** Even a one-sentence description of the system's most painful prior incident class (queue runaways, retry storms after a downstream slowdown, schema-migration outages, gray failures, OOM-kills) calibrates severity and reduces Open Questions.
3. **An output path, optional.** The agent writes the full report to disk and returns only a summary. Default filename is `on-call-review.md`.

Example prompts:

- *"Review the application source on this branch for code-level resilience patterns. The service runs in the checkout path at ~150 req/s and has had two queue-runaway incidents in the last quarter."*
- *"Audit `src/handlers/payment/` for the named on-call anti-patterns. This code is retryable from the upstream queue; idempotency-key handling is the highest-priority signal."*
- *"Read the source files in this change and flag what would wake on-call up. Prior pain on this service has been retry storms after slow downstream auth responses."*
- *"Run a code-level resilience review on `services/inventory/` before we cut the release. We added a new fan-out to three downstream catalog services this sprint."*

Thin prompts (*"audit the code"*) still work but produce more Open Questions and looser findings.

## What you get back

- A summary in the tool-call response: a 1–3 sentence on-call posture statement that leads with the most likely production failure shape, a severity count table (Wakes someone up / Degrades reliability / On-call friction / Polish / YAGNI candidate), an Open Questions count, and the path to the full report.
- A full report on disk with: scope (and anything explicitly deferred to a sibling agent), failure profile (the most likely production failure shape and its triggering conditions), question log (Answered / Assumed / Open), assumptions, open questions, numbered `OCE-###` findings each tied to a named anti-pattern, a named production failure mode, a `file_path:line_number` location, evidence, production impact, related questions, severity, and three remediations (today / next iteration / paved path next quarter), plus an On-Call Improvement Summary.

Every finding is traceable to a question in the log and an anti-pattern in the agent's vocabulary. If something is not traceable, the agent is instructed to drop it.

## How to get the most out of it

- **Scope tightly.** Application source files only, narrowed to a feature or directory. The agent's sharpness comes from the line-by-line altitude; a whole-repo prompt dilutes that.
- **Name the prior incident class.** If the team has been paged repeatedly for a specific failure shape (queue runaways, retry storms, schema migration outages), say so. The agent will calibrate severity and look harder along that vector.
- **Provide the downstream dependency profile, if known.** Which dependencies are flaky? Which are slow but not failing? Which return malformed data sometimes? This shapes the Protocol 1 questions and the production-impact statements.
- **Treat Open Questions as work.** They are not rhetorical. Each one is something the team must answer (by reading a test, dispatching `behavioral-analyst` or `concurrency-analyst` for an adjacent altitude, consulting an ADR, or asking the user) to fully trust the severity of the findings that depend on it.
- **Pair with `devops-engineer` for shippable changes.** This agent reads the source; `devops-engineer` reads the deployment artifacts. A real ship-readiness pass usually wants both. They are scoped to be non-overlapping.
- **Pair with `concurrency-analyst` for async-heavy code.** This agent flags "blocking I/O in async" and "fan-out without concurrency cap" patterns. `concurrency-analyst` goes deeper into races, locks, and deadlock potential.
- **Pair with `adversarial-validator` for a second opinion on the report.** The agent generates findings; it does not evaluate its own output. See [multi-agent-economics.md](../../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md).
- **Re-run after fixes.** Cheap to re-dispatch. Open Questions from the first pass usually become Answered in the second.

## YAGNI

The agent enforces a **Premature Operability Machinery** rule at the code level. Circuit breakers, bulkheads, retry helpers, idempotency tables, feature flags, kill switches, structured-logging middleware, correlation-id wrappers, dead-letter queues, and custom error types are first-class candidates for the evidence test: is there evidence the system needs this artifact *now*? Acceptable evidence: a named upstream finding the artifact resolves, an existing code path that breaks without it, three current concrete uses, a measured incident or workload, an applicable regulation. Recommendations that fail the evidence test are deferred as YAGNI candidates with a named reopening trigger (first real incident class observed, measured throughput crossing a threshold, third concurrent use of the helper, etc.).

This rule deliberately mirrors `devops-engineer`'s Premature Operational Machinery rule but applies it at the application source line rather than at the infrastructure level. The two agents are coordinated: an artifact that fails YAGNI at the code level often fails at the infrastructure level too, and the recommendations point at the same simpler-version alternative.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.

## Cost and latency

The agent runs on `opus`. A single audit is slower and more expensive than a typical lookup agent, which is intentional. The task is multi-dimensional synthesis: the source code, the anti-pattern vocabulary, the named failure-mode catalog, the production-impact reasoning, the tone-anti-pattern sweep on the agent's own findings, and the sequenced remediation. Avoid dispatching it in parallel against the same surface or in tight loops over every file in a large diff. Scope tightly (a feature folder, a handler module, a specific list of source files) and it pays off.

## Sources

The agent's protocols and vocabulary are grounded in published frameworks and research. Each source below is cited because the agent draws specific, named artifacts from it. The evidence-based research backing the agent lives at [`docs/research/on-call-engineer-research.md`](../../research/on-call-engineer-research.md).

### Michael Nygard, *Release It! Second Edition* (Pragmatic Programmers, 2018)

The canonical practitioner reference for production stability. The agent's anti-pattern vocabulary (Integration Points, Chain Reaction, Cascading Failure, Blocked Threads, Slow Responses, Dogpile, Unbounded Result Sets, SLA Inversion, Force Multiplier) and its corresponding stability-pattern vocabulary (Timeout, Circuit Breaker with half-open recovery, Bulkhead, Steady State, Fail Fast, Handshaking, Back Pressure, Shed Load, Governor) come directly from this book.

URL: https://pragprog.com/titles/mnee2/release-it-second-edition/

### Marc Brooker / AWS Builders' Library and personal blog

Brooker's writing on retries, timeouts, deadline propagation, idempotency, load shedding, metastable failure, and bistable caches is the agent's resilience-math anchor. Specific cited artifacts: the 243× retry-amplification scenario across five layers with three retries each, the token-bucket adaptive retry combined with circuit breaker recommendation, the deadline propagation formula, the goodput-over-throughput framing for load shedding, the open-loop cache as bistable system. The AWS-Brooker provenance is acknowledged in the agent's vocabulary — the math is sound but the defaults are tuned for AWS service retry behavior, so callers calibrate to the host platform.

URLs:
- https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/
- https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/
- https://aws.amazon.com/builders-library/using-load-shedding-to-avoid-overload/
- https://brooker.co.za/blog/2021/05/24/metastable.html
- https://brooker.co.za/blog/2021/08/27/caches.html
- https://brooker.co.za/blog/2022/02/28/retries.html

### Bronson et al., *Metastable Failures in Distributed Systems* (HotOS'21 / OSDI'22)

The formal academic definition of metastable failure: a degraded state triggered by an external event that persists after the trigger is removed, sustained by a positive feedback loop. Aggressive retry policies, unbounded queue depths, missing circuit breakers, missing load shedding, and tight synchronous coupling are named as the design patterns that predispose systems to metastability. This is the agent's primary new contribution — vocabulary not present in any other han agent.

URL: https://sigops.org/s/conferences/hotos/2021/papers/hotos21-s11-bronson.pdf

### Peng Huang et al., *Gray Failure: The Achilles' Heel of Cloud-Scale Systems* (HotOS 2017)

The differential-observability paper: an application can see degradation that monitoring does not. Heartbeat-based health checks pass while request-level performance fails. Fan-out at cloud scale makes this nearly universal. The agent uses this vocabulary when flagging catch-and-swallow exception handling or ODD-gate failures: the failure mode being prevented is gray failure, where the on-call engineer learns about the problem from a support ticket rather than the dashboard.

URL: https://blog.acolyer.org/2017/06/15/gray-failure-the-achilles-heel-of-cloud-scale-systems/

### Google, *Site Reliability Engineering* (SRE Book and Workbook)

The canonical source for the four golden signals (latency, traffic, errors, saturation), SLI ratios as user-visible-event ratios, multi-window burn-rate alerting, and the cascading-failure resource-exhaustion chain. The agent cites these directly when flagging missing-correlation-id, missing-observability-on-new-path, or assume-dependency-up patterns.

URLs: https://sre.google/sre-book/table-of-contents/ and https://sre.google/workbook/table-of-contents/

### Charity Majors / Honeycomb: Observability-Driven Development

Majors' ODD principle reframes code review to include an operability gate: *"you should never accept a pull-request unless you can answer the question, 'how will I know when this isn't working?'"* The agent embeds this as a Protocol 6 check on every new code path. If the diff does not include a log statement, metric increment, span attribute, or SLI contribution that makes the new path observable in production, the agent flags ODD-gate failure.

URL: https://charity.wtf/category/observability/

### Brendan Gregg, *The USE Method*

For every bounded resource (CPU, memory, disk, network, thread pools, connection pools): check Utilization, Saturation queue length, Errors. Any non-zero saturation is a problem indicator. 70% utilization can hide burst behavior. The agent cites the USE method when flagging missing-bulkhead, unbounded-queue, and connection-pool-exhaustion patterns.

URL: https://www.brendangregg.com/usemethod.html

### Cindy Sridharan, *Distributed Systems Observability*

Health as a spectrum, not binary. Simple ping/liveness checks miss services returning HTTP 200 while queues are full and latency is spiking. Dynamic backpressure communication. The agent uses Sridharan's framing when discussing how application code expresses health and degradation.

URL: https://copyconstruct.medium.com/health-checks-in-distributed-systems-aa8a0e8c1672

### Richard Cook, *How Complex Systems Fail*

The 18-point paper that grounds the agent's tone calibration. Catastrophes require multiple contributors. Practitioners create safety through normal operations. Post-accident root-cause attribution is fundamentally wrong. Hindsight bias distorts what appeared salient. Blame-focused remedies increase complexity. Safety is a property of systems, not components. The agent treats Cook as the load-bearing source for the "adversarial to artifact, empathetic to engineer" posture.

URL: https://how.complexsystems.fail/

### John Allspaw, Just Culture and the Stella Report

Allspaw operationalizes Cook's framework. Just culture is accountability without blame, distinct from blame-free. The "second story" is the contextual narrative that made the failure look like the right call at the time. The agent treats Allspaw as confirmation of the tone direction; the load-bearing citations are Cook (independently verifiable) and DORA's generative-culture capability.

URL: https://www.etsy.com/codeascraft/blameless-postmortems

### Westrum Organizational Culture Model and DORA Capabilities

The three culture types (pathological, bureaucratic, generative) and the DORA research finding that generative culture predicts both software delivery performance and engineer job satisfaction. The agent's "paved path easier than the shortcut" framing for remediation comes from this body of work.

URLs: https://itrevolution.com/articles/westrums-organizational-model-in-tech-orgs/ and https://dora.dev/capabilities/

### Pete Hodgson, Expand/Contract (Parallel Change)

The four-stage pattern for zero-downtime schema migrations: dual-write, backfill, migrate readers, contract. Each stage is backward-compatible with the previous. The agent cites this when flagging schema-migration-co-deployed-with-dependent-code anti-patterns.

URL: https://blog.thepete.net/blog/2023/12/05/expand/contract-making-a-breaking-change-without-a-big-bang/

### Dan Luu, *Reading Postmortems*

Synthesis of recurring patterns across hundreds of real postmortems. Five categories: error handling bugs, configuration changes, hardware failure with failover that does not work under stress, human process errors, missing or inadequate monitoring. The agent cites the Yuan et al. (OSDI 2014) finding (92% of catastrophic failures from incorrectly handled errors, 35% from empty handlers) with the explicit scope caveat: the study examined distributed data-infrastructure systems (Cassandra, HBase, HDFS, MapReduce, Redis), not web services or microservices broadly. The anti-pattern is universal; the headline percentage is not.

URL: https://danluu.com/postmortem-lessons/

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this agent applies. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Agents Index](../README.md). All agents, grouped by role.
- [`devops-engineer`](./devops-engineer.md). The sibling agent on the infrastructure side of the line. This agent reads application source; `devops-engineer` reads Dockerfiles, IaC, pipelines, manifests, observability platform config, and alert rules. The boundary is hard; the two agents are designed to be dispatched together for any ship-readiness pass.
- [`concurrency-analyst`](./concurrency-analyst.md). Pair on async-heavy code. This agent flags blocking-I/O-in-async; the concurrency analyst goes deeper into races, locks, and deadlocks.
- [`behavioral-analyst`](./behavioral-analyst.md). Pair on changes that cross module boundaries. This agent operates at the call site; behavioral-analyst operates at the module-boundary altitude.
- [`adversarial-validator`](./adversarial-validator.md). Pair for a second opinion on the report.
- [Research backing this agent](../../research/on-call-engineer-research.md). The evidence-based research informing the agent's vocabulary, scope boundary, and tone calibration.
- [agent-domain-focus.md](../../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md). Why the agent uses precise domain vocabulary and named anti-patterns.
- [agent-model-selection.md](../../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md). Rationale for the `opus` model tier.
- [multi-agent-economics.md](../../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md). Why a separate reviewer pass is recommended rather than asking this agent to evaluate its own output.
