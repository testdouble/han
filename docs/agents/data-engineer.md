# data-engineer

Operator documentation for the `data-engineer` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`plugin/agents/data-engineer.md`](../../plugin/agents/data-engineer.md).

> See also: [Plugin landing page](../../README.md) · [All agents](./README.md) · [All skills](../skills/README.md) · [YAGNI](../yagni.md)

## TL;DR

- **What it does.** Audits a schema, migration, query, pipeline, or data-access layer against eleven data-engineering protocols.
- **When to dispatch it.** A schema change, migration, or data-access layer needs a principled review before it ships.
- **What you get back.** A data-engineering findings report with location, principle, and data-level impact per finding, plus P0/P1/P2 sequenced remediations.

## Key concepts

- **Signature question: *"What problem does that solve?"*** Applied to every table, column, index, constraint, document shape, stream contract, and ORM choice. Unanswered versions become Open Questions.
- **Eleven protocols.** Model fit, normal-form analysis, Codd's rules, dimensional modeling, ACID/BASE trade-offs, index strategy, named access failures (N+1, write skew, lost update, hot-path scan), migration discipline, engine-fit, transport contracts, code-data boundary, and governance (PII/PHI/PCI, GDPR/HIPAA/SOC 2/PCI).
- **Expand-and-contract sequencing.** Every destructive remediation goes expand → backfill → cut over → contract so teams can ship safely.
- **P0/P1/P2 remediations.** Every blocker carries a next step the team can ship today plus improvements for later sprints and quarters.

## Summary

An adversarial data / database engineer that audits a schema, migration, data pipeline, stream contract, ORM layer, or data-access module and writes a principled data-engineering review. Its default stance is that the current data design is more normalized than the workload needs, more denormalized than it should be, and indexed for a workload that does not exist, until each of its eleven protocols proves otherwise. Every finding is backed by a specific schema, migration, query, document shape, or access-code location, a named data-engineering principle (a normal form, a Codd rule, a dimensional-modeling pattern, an ACID property, an index-strategy rule, a named access failure like N+1 or write skew, a named migration anti-pattern, a named governance failure), and a concrete data-level impact statement. The agent's signature question, *"What problem does that solve?"*, is applied to every table, column, key, index, constraint, document shape, stream contract, and ORM choice in scope, and unanswered versions become first-class Open Questions rather than disguised assumptions. The adversarial stance is paired with pragmatic sequencing: every destructive remediation is sequenced through expand-and-contract, and every blocker-severity finding carries a P0 next step the team can ship today, plus P1/P2 improvements so the agent does not become a bottleneck teams route around.

## When to use it

**Dispatch when:**

- A new schema, migration, or data model is landing and needs a principled review before it is encoded in production data: a review that is not a code review and not a security review.
- A feature or branch introduces new tables, columns, indexes, foreign keys, or destructive migrations (rename, drop, type change, NOT NULL addition) and the team wants expand-and-contract discipline verified explicitly.
- An ORM layer, repository, or hand-rolled query file is showing symptoms (slow endpoints, timeouts, connection-pool pressure, report queries hitting the OLTP primary) and the team wants an access-pattern audit with EXPLAIN-plan grounding.
- A storage-engine choice is being made or questioned (relational vs document, OLTP vs OLAP, cache vs source of truth, search index vs materialized view, event-sourced vs stateful) and the team wants a fit argument that starts from workload, not fashion.
- A data contract at a service or stream boundary needs review: schema registry settings, compatibility mode, field evolution, canonicalization of identifiers, time, and money.
- A regulated data surface (PII / PHI / PCI / GDPR / HIPAA / SOC 2) needs its data-level controls audited: classification, encryption, row-level security, tokenization, retention, right-to-erasure.
- A multi-tenant schema is being built or hardened and cross-tenant isolation needs to be enforced at the database layer, not only at the application.
- A legacy schema is being refactored and the team wants strangler / expand-and-contract sequencing validated against the workload.

**Do not dispatch for:**

- Exploit-path vulnerability analysis. Use `adversarial-security-analyst`. The data-engineer focuses on data-level governance (classification, retention, row-level security, tokenization, erasure) and deliberately does not re-derive exploit paths.
- Production-readiness review of the runtime (observability, rollout, scale, cost at the service level). Use `devops-engineer`. The data-engineer cross-references operational concerns but does not duplicate.
- File-level code review for correctness, style, or maintainability. Use `/code-review`.
- Architectural SOLID / coupling / cohesion review at the module level. Use `/architectural-analysis`.
- Bug triage or root-cause investigation (*"why did this write vanish?"*). Use `/investigate` or `evidence-based-investigator`.
- Writing or iterating schemas, migrations, or queries. The agent does not modify data artifacts. It produces a findings report.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han:data-engineer`. Give it:

1. **A focus area.** A branch, directory, schema file, migration set, ORM model layer, repository module, query file, stream contract, or data-pipeline module. The narrower the scope, the sharper the findings.
2. **A workload profile, if you have one.** Even a one-paragraph description of transactional vs analytical mix, read/write ratio, row-count scale, regulated data in scope, and availability / consistency requirements dramatically reduces Open Questions.
3. **An output path, optional.** The agent writes the full report to disk and returns only a summary. Default filename is `data-engineering-review.md`.

Example prompts that work well:

- *"Audit the new `billing-service/db/migrate/` and `billing-service/models/invoice.rb` before we ship. This is PCI data, ~500 rps transactional load on RDS Postgres, reporting queries are already moving to the warehouse."*
- *"Review `svc/orders/repository/*.go` and the generated sqlc queries under `svc/orders/db/query/*.sql`. We are seeing p99 regressions on `/orders/search`. I suspect N+1 or a missing composite index."*
- *"Evaluate whether `events/customer.avsc` and the compatibility mode on the `customer.events` topic are safe to change in a backward-incompatible way. We have three downstream consumers. One of them is a warehouse ingest we do not own."*
- *"Review the `users` schema and its soft-delete strategy. We keep getting duplicate-email bugs when users re-register, and a regulator is asking us to prove right-to-erasure works end to end."*
- *"Audit the data model under `apps/analytics/`. Specifically whether we should keep serving this from the OLTP Postgres primary or move it to a columnar store. Today this dashboard runs five-minute queries during business hours."*

Thin prompts (*"audit the database"*) still work but produce more Open Questions and looser findings. Workload ambiguity is the single largest driver of soft findings.

## What you get back

- A summary in the tool-call response: a 1–3 sentence data-engineering posture, a severity count table (Blocks correctness / Degrades operations / Operational friction / Polish), an Open Questions count, and the path to the full report.
- A full report on disk with: scope, data context, question log (Answered / Assumed / Open), assumptions, open questions, numbered DATA-### findings tied to data-engineering principles and locations, and a Data Engineering Improvement Summary that sequences shipping vs. improving with explicit P0/P1/P2 steps and an expand-and-contract path for every destructive remediation.

Every finding is traceable to a data-engineering principle (a normal form, a Codd rule, a dimensional-modeling pattern, an ACID property, an isolation-level guarantee, an index-strategy rule, a CAP / PACELC trade-off, a named access failure, a named migration anti-pattern, or a named governance failure), a concrete location in the repo, and a question in the log. If something is not traceable, the agent is instructed to drop it.

## How to get the most out of it

- **Provide a workload profile.** The single biggest lever. One paragraph (read/write ratio, row-count projection, transactional vs analytical, regulated data in scope, availability and consistency targets) collapses whole classes of Open Questions and sharpens severity calls.
- **Point at the EXPLAIN plans you already have.** If you have captured `EXPLAIN ANALYZE` output, slow-query log excerpts, `pg_stat_statements` dumps, or APM traces for the hot queries in scope, drop them in the repo (or the prompt). The agent is far more confident about index and query findings when grounded in the plan.
- **Say what access patterns matter.** *"Single-row lookup by PK," "range scan over recent time window," "aggregation across tenants," "full-text search," "point writes with optimistic concurrency"*. Each forces a specific protocol calibration.
- **Name the data classes in scope.** If PII / PHI / PCI / GDPR / HIPAA / SOC 2 apply, say so. Protocol 10 calibrates on regulatory scope and findings get scored accordingly.
- **Point at the runbook, data dictionary, or ADR, if one exists.** The agent cannot `curl` Confluence, but it can read anything in the repo. Drop a copy of the relevant decision record into the project and reference it.
- **Treat Open Questions as work.** They are not rhetorical. Each one is something the team must answer (via a row-count query, an EXPLAIN pull, a production-traffic sample, a stakeholder conversation, a data-classification decision, or an ADR) to fully trust the severity of the findings that depend on it.
- **Re-run after changes.** The agent is cheap to re-dispatch once a migration has been added, an index has been created, or a data contract has landed. Open Questions from the first pass become Answered in the second.
- **Pair it with the security analyst on regulated changes.** The agent deliberately does not re-derive exploit paths. For a change touching auth, payments, or PHI / PCI data, dispatch `adversarial-security-analyst` alongside and compare the reports.
- **Pair it with the devops-engineer on migrations that touch production.** The data-engineer enforces expand-and-contract discipline at the schema level. `devops-engineer` enforces progressive-delivery discipline at the rollout level. Run both for migrations with real blast radius.
- **Pair with a reviewer agent.** The agent generates findings. It does not evaluate its own output. If you want adversarial validation of the review, follow it with `adversarial-validator` or a fresh agent pass. See [multi-agent-economics.md](../guidance/agent-building-guidelines/multi-agent-economics.md) for why self-evaluation is a bad default.

## Cost and latency

The agent runs on `opus`. A single audit is slower and more expensive than a typical lookup agent, which is intentional. The task is multi-dimensional synthesis across model fit, schema design, indexing, transactional semantics, migration discipline, storage-engine boundaries, code-data boundary, transport contracts, and governance. Avoid dispatching it in parallel for the same surface or in tight loops over every table in a large monorepo. Scope tightly to the schema, migration set, or module that changed and the signal-to-noise ratio is high.

## YAGNI

The agent enforces the **Speculative Data Machinery** rule. Indexes for queries that don't run, audit columns nobody reads, denormalization for read patterns that don't exist, partitioning for data volumes the project doesn't have, and event-sourcing or CQRS topology for a single-writer OLTP workload are YAGNI candidates. Acceptable evidence the data machinery is needed now: the query the index supports runs in production today (cite the query and its observed latency), the audit column is read by an active consumer (cite the consumer), the read pattern the denormalization supports is measurable in current traffic, or the partition pressure is measurable in current data volumes. Recommendations that fail the evidence test are deferred with a named *reopen-when* trigger.

See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

## Sources

The agent's protocols and vocabulary are grounded in published data-engineering and database research. Each source below is cited because the agent draws specific, named artifacts from it.

### Codd: A Relational Model of Data for Large Shared Data Banks

Edgar F. Codd's 1970 paper introduced the relational model and the foundations of first, second, and third normal form. The agent uses Codd's normalization rules and Codd's twelve rules for a relational database system as the citable principle on relational schema findings.

URL: https://dl.acm.org/doi/10.1145/362384.362685

### Kimball: The Data Warehouse Toolkit

Ralph Kimball's body of work established dimensional modeling, conformed dimensions, fact tables (transaction / periodic snapshot / accumulating snapshot), slowly changing dimensions (Types 0–6), and the enterprise bus architecture. The agent uses Kimball's dimensional-modeling vocabulary as the citable principle on analytical schema findings and contrasts it against Inmon's enterprise data warehouse and Data Vault where the trade-off is load-bearing.

URL: https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/

### Inmon: Building the Data Warehouse

Bill Inmon's enterprise-data-warehouse approach (a normalized, atomic-grain integration layer feeding Kimball-style marts downstream) is the alternative lineage for analytical modeling. The agent uses Inmon's framing when a team is consciously choosing normalized integration over conformed dimensions.

URL: https://www.wiley.com/en-us/Building+the+Data+Warehouse%2C+4th+Edition-p-9780764599446

### Linstedt: Data Vault 2.0

Dan Linstedt's Data Vault 2.0 (hubs, links, satellites) is the third major modeling lineage, optimized for auditability, parallel load, and schema agility in regulated analytical environments. The agent cites Data Vault when a regulated audit trail argues for it over Kimball dimensional or Inmon normalized approaches.

URL: https://datavaultalliance.com/news/dv/what-is-data-vault-2-0/

### Brewer: CAP Theorem, and Abadi: PACELC

Eric Brewer's 2000 conjecture formalized the trade-off between consistency, availability, and partition tolerance. Daniel Abadi extended it with PACELC to incorporate latency / consistency trade-off under normal operation. The agent uses CAP and PACELC as the citable principle on distributed-consistency findings.

URLs: https://www.cs.berkeley.edu/~brewer/cs262b-2004/PODC-keynote.pdf and https://www.cs.umd.edu/~abadi/papers/abadi-pacelc.pdf

### Bailis et al.: Highly Available Transactions and Isolation Level Semantics

Peter Bailis and colleagues' research on transaction isolation (particularly the formal treatment of read-committed, repeatable-read, snapshot, serializable snapshot isolation (SSI), and the named anomalies: dirty read, non-repeatable read, phantom, write skew, lost update) is the canonical reference the agent draws on for concurrency findings.

URL: https://arxiv.org/abs/1302.0309

### The PostgreSQL Documentation on MVCC, Transaction Isolation, and Index Types

The PostgreSQL project's documentation on MVCC, transaction isolation levels, and index types (B-tree, GIN, GiST, BRIN, hash) is the most widely cited public reference for concrete engine behavior under the relational model. The agent cites it for isolation-level semantics, index-strategy rules, and the specific failure modes (dead tuples, bloat, non-concurrent `ALTER`) that a live relational workload faces.

URL: https://www.postgresql.org/docs/current/mvcc.html

### Evans: Domain-Driven Design: Tackling Complexity in the Heart of Software

Eric Evans's book formalized aggregates, entities, value objects, repositories, and bounded contexts: the model-level boundary that a data-engineering review applies to transactional data. The agent cites DDD when cross-aggregate invariants or bounded-context boundaries are load-bearing for a finding.

URL: https://www.domainlanguage.com/ddd/

### Fowler: Patterns of Enterprise Application Architecture

Martin Fowler's PoEAA catalogues the canonical data-access patterns (Active Record, Data Mapper, Unit of Work, Identity Map, Repository, Query Object, Lazy Load) that ORMs and hand-rolled access layers implement or violate. The agent cites PoEAA patterns when critiquing the code-data boundary.

URL: https://martinfowler.com/books/eaa.html

### Young and Vernon: CQRS and Event Sourcing

Greg Young's CQRS framing and Vaughn Vernon's implementation guidance (in *Implementing Domain-Driven Design*) are the canonical references for command-query responsibility segregation and event sourcing. The agent cites this body of work when evaluating whether an event-sourced design is load-bearing for a domain's temporal or audit requirements, or whether it is overkill.

URL: https://cqrs.files.wordpress.com/2010/11/cqrs_documents.pdf

### Fowler: ParallelChange (Expand and Contract)

Danilo Sato's parallel-change pattern, popularized on martinfowler.com and extended across the data-migration community as expand-and-contract, is the agent's default discipline for destructive schema change. The agent enforces expand → backfill → cut over → contract as the sequence for every non-trivial DDL change.

URL: https://martinfowler.com/bliki/ParallelChange.html

### Sadalage and Fowler: NoSQL Distilled

Pramod Sadalage and Martin Fowler's polyglot-persistence framing catalogues document, key-value, wide-column, and graph stores and their access-pattern fit. The agent cites this work in Protocol 2 (Data Model Fit) when arguing that engine choice should follow workload, not fashion.

URL: https://martinfowler.com/books/nosql.html

### Kleppmann: Designing Data-Intensive Applications

Martin Kleppmann's book is the most widely used contemporary synthesis of replication, partitioning, consistency, streaming, batch processing, and schema evolution. The agent leans on its vocabulary for distributed-data findings, on Chapter 4's schema-evolution framing for data-contract findings, and on Chapter 7's treatment of isolation anomalies alongside the Bailis reference.

URL: https://dataintensive.net/

### Confluent: Schema Registry Compatibility Modes

The Confluent Schema Registry documentation defines the backward / forward / full / none compatibility modes for Avro, Protobuf, and JSON Schema evolution on Kafka topics. The agent cites these modes as the citable principle on data-contract findings at stream boundaries.

URL: https://docs.confluent.io/platform/current/schema-registry/fundamentals/schema-evolution.html

### GDPR Articles 15, 17, and 25: Access, Erasure, Data Protection by Design

The European General Data Protection Regulation's articles on right of access, right to erasure, and data protection by design are the citable standard for regulated-data findings in the agent's Protocol 10. The agent cites specific articles when a finding turns on a GDPR obligation.

URL: https://gdpr-info.eu/

### HIPAA Security Rule: 45 CFR Part 164 Subpart C

The HIPAA Security Rule's administrative, physical, and technical safeguards establish the requirements for protected health information at rest, in transit, and in access. The agent cites the Security Rule on PHI findings and pairs it with column-level encryption and row-level security recommendations.

URL: https://www.hhs.gov/hipaa/for-professionals/security/index.html

### PCI DSS v4.0: Requirements 3 and 7

The PCI Data Security Standard's requirements on protecting stored account data (Requirement 3) and restricting access by business need-to-know (Requirement 7) are the citable standard for payment-card data findings. The agent cites the specific requirement when a finding turns on PCI scope.

URL: https://www.pcisecuritystandards.org/document_library/

### NIST SP 800-53 / SP 800-88: Data Protection and Media Sanitization

NIST's SP 800-53 (controls) and SP 800-88 (media sanitization) are cited when a finding turns on federal data-protection or data-disposal requirements, especially in the right-to-erasure workflow and the extends-to-backups verification.

URLs: https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final and https://csrc.nist.gov/publications/detail/sp/800-88/rev-1/final

### OWASP: SQL Injection Prevention Cheat Sheet

The OWASP guidance on parameterized queries, stored procedures, input validation, and least-privilege database accounts is the citable standard when the code-data boundary audit surfaces injection risk or over-privileged application roles. Exploit-path analysis belongs to `adversarial-security-analyst`. The data-engineer references the guidance to argue for parameterized / generated access layers.

URL: https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this agent applies. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Agents Index](./README.md). All 23 agents, grouped by role.
- [`devops-engineer`](./devops-engineer.md). Pair on production migrations. This agent covers the schema-level expand-and-contract; `devops-engineer` covers the rollout-level progressive delivery.
- [`adversarial-security-analyst`](./adversarial-security-analyst.md). Pair on regulated data changes. This agent covers data-level governance; the security analyst covers exploit paths.
- [agent-domain-focus.md](../guidance/agent-building-guidelines/agent-domain-focus.md). Why the agent uses precise domain vocabulary and named anti-patterns.
- [agent-model-selection.md](../guidance/agent-building-guidelines/agent-model-selection.md). Rationale for the `opus` model tier.
- [graceful-degradation.md](../guidance/agent-building-guidelines/graceful-degradation.md). Why the agent handles missing git and missing migrations inline.
- [multi-agent-economics.md](../guidance/agent-building-guidelines/multi-agent-economics.md). Why a separate reviewer pass is recommended rather than asking this agent to evaluate its own output.
