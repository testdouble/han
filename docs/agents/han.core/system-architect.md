# system-architect

Operator documentation for the `system-architect` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/system-architect.md`](../../../han.core/agents/system-architect.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Adversarially synthesizes boundary-crossing findings into cross-service / bounded-context topology recommendations: context-map relationships, integration patterns, data ownership, failure-domain containment, API-contract evolution across service seams. Assumes the current topology is wrong (bounded contexts leak, integrations are sync-by-default, data ownership is contested, failure domains are uncontained) until evidence says otherwise.
- **When to dispatch it.** The work crosses a service boundary, a bounded-context seam, or a trust boundary, and you want recommendations at the altitude where the unit of design is a service or context, not a class or module. Conditionally dispatched by `/architectural-analysis` (large size, when a system-seam signal is present), `/architectural-decision-record`, `/gap-analysis`, `/iterative-plan-review`, and `/plan-implementation` when the work crosses a service or bounded-context boundary. `/plan-a-feature` excludes it from the default roster and includes it only when you explicitly ask.
- **What you get back.** Numbered `SA#` recommendations, each with the seam it crosses, the relationship type (ACL, conformist, partnership, OHS, and so on), integration style (sync, async event, saga, batch), data ownership, failure-domain containment, and rationale. Plus a current context-map sketch.

## Key concepts

- **System altitude, not software altitude.** The unit of design is a service, a bounded context, or a cross-process integration. Class-level and module-level concerns belong to [`software-architect`](./software-architect.md). The agent redirects them explicitly rather than dressing them in system-level vocabulary.
- **Context-map relationships are load-bearing.** Every integration between bounded contexts is classified by name (partnership, customer-supplier, conformist, anti-corruption layer (ACL), shared kernel, open host service (OHS), published language, separate ways) and the choice is justified against the teams' power and collaboration dynamics. *"They call each other's APIs"* is not a relationship.
- **Sync-vs-async is a topology decision, not a convenience.** Synchronous request/reply is appropriate only when the caller cannot proceed without the answer and the latency is acceptable. Other cases benefit from domain events, event-carried state transfer, or sagas. The agent challenges sync-by-default.
- **Data ownership is named.** Each concept crossing a seam has exactly one system of record. The agent refuses to recommend a data flow that leaves ownership ambiguous.
- **Failure domain is always stated.** Every recommendation names the timeout budget, retry posture, circuit-breaker placement, DLQ behavior, and fallback path. A recommendation without a failure-domain statement is incomplete by the agent's own rules.
- **Coordinates with devops-engineer and data-engineer.** Operational readiness belongs to [`devops-engineer`](./devops-engineer.md). Schema/index/query design belongs to [`data-engineer`](./data-engineer.md). The agent cross-references their findings rather than restating them.

## When to use it

**Dispatch when:**

- A feature or change crosses a service boundary, a bounded-context seam, or a trust boundary, and you want recommendations at the topology altitude.
- Upstream analysts (structural, behavioral, concurrency, risk) have produced findings that describe cross-service coupling, shared databases between contexts, sync call chains, or ambiguous data ownership.
- A migration is being planned (splitting a monolith, extracting a service, replacing a shared database with events, introducing an anti-corruption layer between teams) and the topology trade-offs need to be made explicit.
- `/plan-implementation` is planning a feature whose scope spans more than one service, and the implementation plan should include system-architecture recommendations.
- `/architectural-analysis` produced deferred system-level concerns in the `software-architect` summary, and you want those concerns synthesized into recommendations.
- A context map would be useful but nobody has drawn one. The agent produces a current-state sketch as part of its output.

**Do not dispatch for:**

- **Intra-codebase refactoring.** Use [`software-architect`](./software-architect.md). Module splits, class decomposition, interface-segregation, extension points inside one codebase.
- **Production readiness.** Use [`devops-engineer`](./devops-engineer.md). Deploy strategy, observability, SLOs, progressive delivery, feature flags. The system-architect names failure-domain mechanisms in its recommendations but does not own operational rollout.
- **Schema / index / query design.** Use [`data-engineer`](./data-engineer.md). The system-architect names data ownership. The data-engineer owns the underlying storage model.
- **Exploit-path analysis.** Use [`adversarial-security-analyst`](./adversarial-security-analyst.md). The system-architect names trust-boundary placement as a topology choice, not a vulnerability claim.
- **Discovering findings.** Use [`structural-analyst`](./structural-analyst.md), [`behavioral-analyst`](./behavioral-analyst.md), or [`concurrency-analyst`](./concurrency-analyst.md). This agent synthesizes. It does not discover.
- **Risk prioritization.** Use [`risk-analyst`](./risk-analyst.md). This agent consumes risk assessments. It does not produce them.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:system-architect`.

Give it:

1. **Upstream analyst findings.** At minimum, `structural-analyst` (`S#`), `behavioral-analyst` (`B#`), `concurrency-analyst` (`C#`), and `risk-analyst` (`R#`) output. The agent examines these findings *at the boundary level*: cross-service dependencies, cross-service error propagation, distributed coordination concerns.
2. **`devops-engineer` and/or `data-engineer` findings (optional, recommended when available).** Operational topology context sharpens failure-domain recommendations. Data-ownership context sharpens system-of-record calls.
3. **The scope.** Which services, contexts, or integrations are in frame. Without scope the agent cannot draw a context map.
4. **Optional framing.** The change under consideration: *"we are splitting Billing from Subscriptions," "we want to replace the shared DB with events," "we need to decide sync vs. async for the new notification flow."*

Example prompts:

- *"The analysts have produced findings on the checkout path, which spans `checkout-service`, `inventory-service`, `payments-service`, and `notifications-service`. Synthesize system-architecture recommendations. The team suspects the sync call chain is the problem."*
- *"/architectural-analysis deferred three findings to system-architect (S3, B7, R4). Here is the verbatim upstream output. Produce recommendations."*
- *"We are about to split the Billing context from the Subscription context. Here are structural and behavioral findings plus a devops-readiness report on the current monolith. Recommend a context-map relationship and integration style."*

## What you get back

- **Numbered `SA#` recommendations**, ordered by impact. Each item includes:
  - **Addresses.** Cross-references to upstream findings (`S#`, `B#`, `C#`, `R#`, and `DOR-###` or data-engineering IDs when provided).
  - **Seam crossed.** The boundary this change touches (service, bounded context, trust boundary). If no seam is crossed, the recommendation is redirected to `software-architect`.
  - **Principle.** Which system-architecture principle this addresses (bounded-context integrity, context-map relationship, ACL, sync-vs-async placement, data ownership, idempotency, failure-domain containment, trust boundary, organizational fit).
  - **Current state.** Brief description of the current topology.
  - **Recommended change.** Boundary, relationship, integration style, or containment mechanism, with pseudocode or context-map sketches.
  - **Relationship type, integration style, data ownership, failure domain.** Structured fields.
  - **Rationale** and **Risk if deferred.**
- **Current Context Map.** A text sketch of the current relationships between the bounded contexts or services involved, with proposed changes marked.
- **System Architecture Recommendations Summary.** Findings addressed, findings deferred to `software-architect` with reasons, findings coordinated with `devops-engineer` / `data-engineer`, key themes, highest-impact recommendations.

## How to get the most out of it

- **Feed it cross-service findings specifically.** The agent shines on boundary-crossing concerns. A focus area inside one codebase produces a thin report. Dispatch `software-architect` instead.
- **Include `devops-engineer` and `data-engineer` findings when available.** Together they give the agent the topology and ownership context it needs to name failure-domain and system-of-record decisions precisely.
- **Name the teams.** Conway's Law is one of the agent's principles. Knowing which teams own which contexts changes which context-map relationship the agent recommends (partnership vs. customer-supplier vs. conformist).
- **Ask for a context map early.** Even without a full recommendation pass, the agent produces a current-state context map. It is often the first time a team sees its integrations named.
- **Pair with [`software-architect`](./software-architect.md)** when a change has both altitudes. The boundary-crossing decisions land in this agent's report. The intra-codebase changes inside each service land in the software-architect's.
- **Pair with [`devops-engineer`](./devops-engineer.md)** when the recommendation changes retry budgets, timeouts, or circuit-breaker placement. The devops-engineer owns the runtime validation of those choices.
- **Pair with [`data-engineer`](./data-engineer.md)** when a data-ownership recommendation implies a schema-ownership change. The data-engineer owns the migration strategy.
- **Pair with [`adversarial-validator`](./adversarial-validator.md)** if you want the recommendations challenged. The agent does not evaluate its own output.

## Cost and latency

The agent runs on `opus` and reads the codebase to verify current integrations, callers, and data flows. A synthesis pass typically finishes in a few minutes when given tight upstream input. It is built for infrequent, high-signal runs (a migration check-in, a service-split decision, a pre-rewrite baseline), not tight-loop iteration. Scope tightly and the recommendations land sharper.

## In more detail

The agent's recommendation process:

1. Read all upstream findings. Identify which findings describe concerns that cross a service boundary, a bounded-context seam, or a trust boundary. Findings inside one deployable unit are out of scope and deferred to `software-architect`.
2. If `devops-engineer` or `data-engineer` findings are provided, incorporate them: operational concerns at integration seams, data-engineering findings at ownership boundaries.
3. Build a current-state context-map sketch enumerating the bounded contexts or services in frame and classifying each existing relationship by name.
4. Cluster related findings that point at the same boundary or relationship.
5. For each cluster, design a recommendation that changes either the boundary placement, the relationship type, the integration style, or the failure-domain containment.
6. Verify recommendations against the codebase. Confirm current integrations, callers, and data flows match the findings, and that the proposed change is compatible.
7. Produce context-map and contract sketches.
8. Name the failure domain for every recommendation.

The agent refuses to:

- Recommend a service split without naming the resulting bounded context or context-map relationship.
- Apply class-level SOLID principles to services.
- Recommend an integration without naming the relationship type.
- Approve a topology that increases synchronous cross-service call depth without a trade-off statement and a lighter alternative.
- Recommend a data flow without naming the system of record.
- Select sync request/reply without a comparison to async alternatives when eventual consistency would suffice.
- Recommend an integration without naming the timeout budget, retry posture, circuit-breaker placement, DLQ behavior, and fallback path.
- Absorb a concern that lives entirely inside one codebase. That is redirected to `software-architect`.

## YAGNI

Cross-service topology recommendations from this agent must cite the seam-crossing evidence that justifies them: a measured data-ownership conflict between bounded contexts, a failure-domain leak surfaced by an actual incident, a synchronous integration shape that has caused cascading failures, or a regulatory rule that forces a specific contract evolution. Speculative service splits, *for-future-flexibility* event topics, multi-region or HA topology for workloads that haven't proven single-region pressure, and *just-in-case* idempotency at every wire-crossing without a documented retry path are YAGNI candidates and are not recommended. Recommendations that cannot pass the evidence test are deferred with a named *reopen-when* trigger (typically a measured contention cost, an incident, or a customer commitment).

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

## Sources

The agent's principles and vocabulary are grounded in established system-architecture practice. Each source below is cited because the agent draws specific, named artifacts from it.

### Eric Evans: *Domain-Driven Design: Tackling Complexity in the Heart of Software* (2003)

Evans's strategic DDD (bounded context, ubiquitous language, context map, and the named relationships: partnership, customer-supplier, conformist, anti-corruption layer, shared kernel, open host service, published language, separate ways, big ball of mud) is the primary citable framework for the agent's recommendations. Every cross-context integration is classified using this vocabulary.

URL: https://www.domainlanguage.com/ddd/

### Vaughn Vernon: *Implementing Domain-Driven Design* (2013)

Vernon's elaboration on context-map integration patterns and strategic design in practice informs the agent's relationship-selection guidance. The agent cites Vernon when recommending an ACL placement or distinguishing customer-supplier from conformist.

URL: https://vaughnvernon.com/?awebooks=implementing-domain-driven-design

### Gregor Hohpe & Bobby Woolf: *Enterprise Integration Patterns* (2003)

Hohpe and Woolf's catalog of integration patterns (request/reply, pub/sub, content-based router, process manager, event-driven consumer, message channel) is the vocabulary the agent uses when recommending an integration-style change. Every integration recommendation names the pattern.

URL: https://www.enterpriseintegrationpatterns.com/

### Simon Brown: *The C4 Model for Visualizing Software Architecture*

Brown's C4 model gives the agent the altitude vocabulary (Context and Container) it uses when sketching current and proposed topologies. Context-map sketches in the agent's output align with C4 Context altitude.

URL: https://c4model.com/

### Eric Brewer, Daniel Abadi: CAP Theorem and PACELC

Brewer's CAP theorem and Abadi's PACELC extension are the citable principles when a recommendation forces a choice between consistency and availability, or when the agent names latency/consistency trade-offs in normal operation.

URL: http://www.julianbrowne.com/article/brewers-cap-theorem

### Pat Helland: *Life Beyond Distributed Transactions: An Apostate's Opinion* (2007)

Helland's argument against distributed transactions (in favor of idempotent messages, outbox patterns, and eventual-consistency across boundaries) underpins the agent's at-least-once / idempotency-key recommendations.

URL: https://www.ics.uci.edu/~cs223/papers/cidr07p15.pdf

### Chris Richardson: *Microservices Patterns* (2018)

Richardson's catalog covers saga (orchestrated and choreographed), CQRS, outbox, transactional messaging, and API-composition patterns. The agent uses these names when recommending distributed coordination approaches.

URL: https://microservices.io/

### Michael Nygard: *Release It!* (2018, 2nd ed.)

Nygard's stability patterns (circuit breaker, bulkhead, timeout, fail-fast, decoupling middleware, handshaking, backpressure) are the agent's vocabulary for failure-domain containment. Every recommendation names the containment mechanism.

URL: https://pragprog.com/titles/mnee2/release-it-second-edition/

### Sam Newman: *Building Microservices* (2021, 2nd ed.)

Newman's work on service boundaries, consumer-driven contract testing, schema evolution across services, and the trade-offs of synchronous vs. asynchronous integration informs the agent's integration-style recommendations and its skepticism about sync-by-default.

URL: https://samnewman.io/books/building_microservices_2nd_edition/

### Matthew Skelton & Manuel Pais: *Team Topologies* (2019)

Skelton and Pais's four team patterns (stream-aligned, platform, enabling, complicated-subsystem) and interaction modes (collaboration, X-as-a-Service, facilitating) give the agent the vocabulary for the Conway's Law alignment principle: whether the integration shape matches the team shape.

URL: https://teamtopologies.com/

### Melvin Conway: *How Do Committees Invent?* (1968)

Conway's original observation, that systems mirror the communication structures of the organizations that build them, is the citable principle when the agent flags a topology that does not match its owning teams.

URL: https://www.melconway.com/Home/Committees_Paper.html

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this agent applies. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [`software-architect`](./software-architect.md). The sibling agent for intra-codebase synthesis.
- [`devops-engineer`](./devops-engineer.md). Production readiness. Pair on failure-domain and retry-budget recommendations.
- [`data-engineer`](./data-engineer.md). Schema and access-pattern design. Pair on data-ownership recommendations.
- [`structural-analyst`](./structural-analyst.md), [`behavioral-analyst`](./behavioral-analyst.md), [`concurrency-analyst`](./concurrency-analyst.md), [`risk-analyst`](./risk-analyst.md). The upstream analysts whose findings this agent synthesizes at the boundary level.
- [`/plan-implementation`](../../skills/han.core/plan-implementation.md). The skill that includes this agent in its roster when a feature crosses a service boundary.
- [`/architectural-analysis`](../../skills/han.core/architectural-analysis.md). Chains to `software-architect`, which defers cross-service concerns. When those deferrals appear, dispatch this agent.
- [agent-domain-focus.md](../../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md). Why the agent uses precise domain vocabulary and named anti-patterns.
- [agent-model-selection.md](../../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md). Rationale for the `opus` model tier.
