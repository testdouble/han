# devops-engineer

Operator documentation for the `devops-engineer` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`plugin/agents/devops-engineer.md`](../../plugin/agents/devops-engineer.md).

> See also: [Plugin landing page](../../README.md) · [All agents](./README.md) · [All skills](../skills/README.md) · [YAGNI](../yagni.md)

## TL;DR

- **What it does.** Audits a feature, change, service, pipeline, or environment for production readiness.
- **When to dispatch it.** A change is approaching production and needs a principled readiness review covering hosting, observability, rollout, scale, cost, and compliance.
- **What you get back.** A production-readiness report with location, principle, and blast-radius per finding, plus P0/P1/P2 sequenced remediations.

## Key concepts

- **Default stance: *"This will break in production."*** Every finding is backed by a specific location, a named operational principle, and a concrete blast-radius statement.
- **DORA, Twelve-Factor, Four Golden Signals.** The agent calibrates on DORA delivery metrics, Twelve-Factor App parity, and the Four Golden Signals (latency, traffic, errors, saturation) as its citable principles.
- **Named production-only failure modes.** Thundering herd, cache stampede, N+1, connection-pool exhaustion, poison pill, noisy neighbor. The agent flags the specific named mode when it applies, not a generic "performance risk."
- **Progressive delivery and feature-flag hygiene.** Every destructive rollout is sequenced through expand-and-contract, progressive exposure, and a named rollback criterion.
- **Open Questions as first-class output.** Questions the audit could not defensibly answer are listed separately. Findings that depend on them are scoped to the most defensible assumption.

## Summary

An adversarial DevOps / Site Reliability engineer that audits a feature, change, service, pipeline, or environment and writes a production-readiness report. Its default stance is that the current system will break in production. Every finding is backed by a specific location, a named operational principle, and a concrete blast-radius statement. Questioning is a core behavior. The agent generates and logs the hard questions a senior DevOps engineer would ask in a readiness review, and it flags any question it cannot answer as an Open Question so the team can resolve it rather than letting the audit rest on an invented production profile. The adversarial stance is paired with pragmatic sequencing: every blocker-severity finding includes a P0 next step the team can ship today, plus P1/P2 improvements for later sprints and quarters, so the agent does not become a bottleneck teams route around.

## When to use it

**Dispatch when:**

- A feature or branch is approaching production and needs a principled readiness pass (observability, rollback, scale, security, cost, compliance) before ship.
- An infrastructure change (Terraform/Pulumi/CDK, Kubernetes manifests, Dockerfile, CI pipeline) needs a second opinion that is not a code review.
- A service is experiencing recurring production issues and the team wants a structured audit of its operational posture, not a bug investigation.
- A new service is being designed and the team wants the production-readiness checklist *now*, while decisions are still cheap to reverse.
- A migration is being planned (cloud move, database rehost, Kubernetes adoption or exit, observability vendor switch) and the team wants the operational trade-offs made explicit.
- A regulated change (SOC 2, HIPAA, PCI, GDPR scope) needs its DevOps-owned controls surfaced before an audit.

**Do not dispatch for:**

- Exploit-path vulnerability analysis. Use `adversarial-security-analyst`. The devops-engineer focuses on operational posture (rotation, scoping, detection, blast radius, compliance controls) and deliberately does not re-derive exploit paths.
- File-level code review for correctness, style, or maintainability. Use `/code-review`.
- Architectural SOLID / coupling / cohesion review. Use `/architectural-analysis`.
- Bug triage or root-cause investigation. Use `/investigate` or `evidence-based-investigator`.
- Writing or iterating IaC. The agent does not modify infrastructure. It produces a findings report.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han:devops-engineer`. Give it:

1. **A focus area.** A branch, directory, service, pipeline file, IaC module, Dockerfile, or feature. The narrower the scope, the sharper the findings.
2. **A production profile, if you have one.** Even a one-paragraph description of traffic shape, criticality tier, regulated data, and current error-budget status dramatically reduces Open Questions.
3. **An output path, optional.** The agent writes the full report to disk and returns only a summary. Default filename is `devops-readiness.md`.

Example prompts that work well:

- *"Audit the readiness of the `billing-service` branch before we ship. It serves ~200 req/s in the checkout path. PCI data is in scope. We run on EKS in `us-east-1` only."*
- *"Review `infra/terraform/staging-v2/` for drift, secret handling, and IAM least privilege. This module backs the preview environments used by the mobile team."*
- *"Audit the GitHub Actions workflow at `.github/workflows/deploy.yml` for rollback signals, supply-chain integrity, and progressive-delivery posture. This ships to production on merge to main."*
- *"Review `Dockerfile`, `k8s/deployment.yaml`, and `helm/values-prod.yaml` for `users-api`. This is a Sev-1 service. The team is currently blowing its error budget."*

Thin prompts (*"audit the infra"*) still work but produce more Open Questions and looser findings.

## What you get back

- A summary in the tool-call response: a 1–3 sentence readiness posture, a severity count table (Blocks rollout / Degrades reliability / Operational friction / Polish), an Open Questions count, and the path to the full report.
- A full report on disk with: scope, production context, question log (Answered / Assumed / Open), assumptions, open questions, numbered findings tied to operational principles and locations, and a DevOps Improvement Summary that sequences shipping vs. improving with explicit P0/P1/P2 steps.

Every finding is traceable to an operational principle (DORA key, Twelve-Factor factor, Four Golden Signal, SLO policy, AWS Well-Architected practice, SLSA level, or a named failure mode), a concrete location in the repo, and a question in the log. If something is not traceable, the agent is instructed to drop it.

## How to get the most out of it

- **Provide a production profile.** The single biggest lever. A one-paragraph statement of traffic shape, criticality tier, regulated data, and error-budget status collapses whole classes of Open Questions and sharpens severity calls.
- **Name the change class.** Tell the agent whether this is cosmetic, routine, or a schema/auth/payment tier change. The progressive-delivery and risk-stratification protocols calibrate on this.
- **Point at the runbook or ADR, if one exists.** The agent cannot `curl` Confluence or read private wikis, but it can read anything in the repo. Drop a copy of the relevant runbook or decision record into the project and reference it.
- **Say what ships when.** If a deadline is looming, ask the agent to sequence findings strictly into *"must-fix-before-rollout"* vs. *"track-and-improve."* It already does this, but an explicit reminder sharpens the P0/P1/P2 judgment.
- **Treat Open Questions as work.** They are not rhetorical. Each one is something the team must answer (via a capacity plan, an SLO decision, a stakeholder conversation, a runbook write-up, or a metric query) to fully trust the severity of the findings that depend on it.
- **Re-run after changes.** The agent is cheap to re-dispatch once a brief or fix has landed. Open Questions from the first pass become Answered in the second.
- **Pair it with the security analyst on regulated changes.** The agent deliberately does not re-derive exploit paths. For a change touching auth, payments, or PHI/PCI data, dispatch `adversarial-security-analyst` alongside and compare the reports.
- **Pair with a reviewer agent.** The agent generates findings. It does not evaluate its own output. If you want adversarial validation of the readiness report, follow it with `adversarial-validator` or a fresh agent pass. See [multi-agent-economics.md](../guidance/agent-building-guidelines/multi-agent-economics.md) for why self-evaluation is a bad default.

## Cost and latency

The agent runs on `opus`. A single audit is slower and more expensive than a typical lookup agent, which is intentional. The task is multi-dimensional synthesis across delivery performance, observability, security posture, scale, and cost. Avoid dispatching it in parallel for the same surface or in tight loops over every service in a monorepo. Scope tightly and it pays off.

## YAGNI

The agent enforces the **Premature Operational Machinery** rule. Runbooks for alerts that have never fired (the canonical example: Sentry runbooks for staging-only Sentry where data isn't reaching production), SLOs and error budgets for traffic the system doesn't yet receive, multi-region or HA infrastructure for workloads that haven't proven single-region pressure, dashboards for failure modes that have never occurred, and observability instrumentation for telemetry that isn't reaching its destination yet are YAGNI candidates. Acceptable evidence operational machinery is needed now: the alert has fired (cite the incident), the SLO is being measured against real traffic (cite the metric), the failure mode is documented (cite the post-mortem), or the workload has measured single-region pressure (cite the metric). Recommendations that fail the evidence test are deferred with a named *reopen-when* trigger.

See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

## Sources

The agent's protocols and vocabulary are grounded in published frameworks and research. Each source below is cited because the agent draws specific, named artifacts from it.

### DORA: Software Delivery Performance Metrics

The DORA research program (DevOps Research and Assessment, now at Google Cloud) established the four keys (Deployment Frequency, Lead Time for Changes, Change Failure Rate, and Failed Deployment Recovery Time, formerly MTTR) as the industry-standard measurement of software delivery. The agent walks all four as a protocol and uses them as the citable principle on delivery-performance findings. A later refinement added Reliability as a fifth metric.

URL: https://dora.dev/guides/dora-metrics-four-keys/

### Google: Site Reliability Engineering (SRE Book and Workbook)

The two books from Google's SRE organization are the canonical source for error budgets, service level objectives, toil, blameless postmortems, and cascading-failure patterns. The agent cites SLI / SLO / error-budget / burn-rate vocabulary directly from this body of work and uses the "Monitoring Distributed Systems" chapter as the source for the Four Golden Signals (latency, traffic, errors, saturation).

URLs: https://sre.google/sre-book/table-of-contents/ and https://sre.google/workbook/table-of-contents/

### The Twelve-Factor App

Adam Wiggins's 2011 methodology for building SaaS. Factors III (Config), V (Build, release, run), X (Dev/prod parity), and XI (Logs) are load-bearing for the agent's environment-and-parity protocol. The agent uses the factor names as the citable principle on parity and config-management findings.

URL: https://12factor.net/

### OpenTelemetry (CNCF)

OpenTelemetry is the CNCF open standard for instrumentation (SDKs, an agent collector, and the OTLP protocol) that decouples application instrumentation from any single observability backend. The agent treats OTel as the vendor-neutralization play and flags `Vendor-Coupled Observability` when instrumentation is hardwired to a specific SaaS SDK.

URL: https://opentelemetry.io/docs/what-is-opentelemetry/

### AWS Well-Architected Framework: Reliability and Operational Excellence Pillars

AWS's Well-Architected Framework is the most widely cited public taxonomy for cloud operational practice. The agent uses the Reliability pillar's named DR tiers (Backup and Restore, Pilot Light, Warm Standby, Multi-Site Active/Active) and their associated RPO/RTO bands as the principle citation on disaster-recovery findings.

URL: https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html

### Martin Fowler: Feature Toggles

Pete Hodgson's canonical guide to feature toggles on Martin Fowler's site defines the five flag types (release, experiment, operational, permission, config) and their expected lifespans. The agent uses these names when auditing flag type, owner, expiration, and flag-debt risk, and pairs the framework with vendor-agnostic cleanup practices.

URL: https://martinfowler.com/articles/feature-toggles.html

### Expand-and-Contract (Parallel Change) Migration Pattern

Danilo Sato's parallel-change pattern, popularized across the database community as expand-and-contract, is the agent's default recommendation for zero-downtime schema changes. The agent enforces the five-step sequence (expand → migrate code → backfill → flip → contract) and refuses to accept schema-destructive change co-deployed with dependent code.

URL: https://martinfowler.com/bliki/ParallelChange.html

### OWASP Top 10 (2025): A03 Software Supply Chain Failures

The 2025 OWASP Top 10 elevated supply-chain failures to A03, reflecting the industry-wide response to incidents such as SolarWinds, `xz-utils`, and the `ctx` / `colors.js` attacks. The agent uses the OWASP framing alongside SLSA as the principle citation on supply-chain findings and pairs SBOM (SPDX / CycloneDX) and Sigstore signing as the minimum-viable mitigation.

URL: https://owasp.org/Top10/2025/A03_2025-Software_Supply_Chain_Failures/

### SLSA: Supply-chain Levels for Software Artifacts

SLSA (from the Open Source Security Foundation) is a tiered framework for build-integrity practices, with levels 0–3 covering provenance, tamper resistance, and hardened build platforms. The agent uses the SLSA level as the citable operational principle when auditing build reproducibility, artifact signing, and admission-policy enforcement of signatures.

URL: https://slsa.dev/

### NIST SSDF: Secure Software Development Framework (SP 800-218)

NIST's Secure Software Development Framework is the higher-level secure-development taxonomy that SLSA implements at the supply-chain layer. The agent references SSDF when a compliance regime (FedRAMP, SOC 2) requires demonstrating secure-development controls beyond build integrity alone.

URL: https://csrc.nist.gov/publications/detail/sp/800-218/final

### Sigstore: Keyless Signing and Transparency Log

Sigstore is the Linux Foundation's keyless artifact-signing platform (Cosign CLI, Fulcio CA, Rekor transparency log). The agent treats `cosign` signature verification at admission as the paved-path baseline for container-image provenance and cites Sigstore directly when the artifact chain has no signing story.

URL: https://www.sigstore.dev/

### Principles of Chaos Engineering

The Netflix-origin principles document formalizes chaos engineering as hypothesis-driven experimentation on production systems: define a steady-state measurement, vary real-world events, minimize blast radius, automate continuously. The agent cites the principles when auditing reliability readiness and flags the absence of game days / chaos drills on Sev-1 services.

URL: https://principlesofchaos.org/

### CNCF Landscape

The CNCF Landscape catalogs the open-source and commercial ecosystem across compute, storage, observability, security, and orchestration. The agent does not enforce a specific tool but references the landscape as the authoritative map when recommending vendor-neutral alternatives (OTel, External Secrets Operator, OPA, Kyverno, Prometheus).

URL: https://landscape.cncf.io/

### Atlassian: Blameless Postmortems

Atlassian's incident management handbook is the most broadly adopted public guide to blameless postmortem practice. The agent cites it alongside the SRE book's postmortem-culture chapter when auditing incident response readiness and flags `Named-Person Root Cause` as a specific anti-pattern.

URL: https://www.atlassian.com/incident-management/postmortem

### Team Topologies: Platform as a Product

Matthew Skelton and Manuel Pais's book reframes internal developer platforms as products with developer customers. The agent leans on the *"paved path must be easier than the shortcut"* framing (explicit in the Team Topologies platform-team pattern) when recommending remediation. This is what keeps the agent from becoming a blocker teams route around.

URL: https://teamtopologies.com/key-concepts-content/what-is-a-thinnest-viable-platform

### Strangler Fig Application (Martin Fowler)

Fowler's 2004 essay, borrowing the metaphor from strangler-fig trees, is the canonical pattern for incremental migration: route a subset of traffic to the new system and shrink the old one over time. The agent recommends strangler-pattern migrations as the default over big-bang rewrites and cites the pattern in P1/P2 remediation sequencing.

URL: https://martinfowler.com/bliki/StranglerFigApplication.html

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this agent applies. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Agents Index](./README.md). All 23 agents, grouped by role.
- [`data-engineer`](./data-engineer.md). Pair on production migrations. This agent covers rollout-level progressive delivery; `data-engineer` covers schema-level expand-and-contract.
- [`adversarial-security-analyst`](./adversarial-security-analyst.md). Pair on changes touching auth, secrets, or regulated surfaces. This agent covers operational readiness; the security analyst covers exploit paths.
- [agent-domain-focus.md](../guidance/agent-building-guidelines/agent-domain-focus.md). Why the agent uses precise domain vocabulary and named anti-patterns.
- [agent-model-selection.md](../guidance/agent-building-guidelines/agent-model-selection.md). Rationale for the `opus` model tier.
- [graceful-degradation.md](../guidance/agent-building-guidelines/graceful-degradation.md). Why the agent handles missing git and missing IaC inline.
- [multi-agent-economics.md](../guidance/agent-building-guidelines/multi-agent-economics.md). Why a separate reviewer pass is recommended rather than asking this agent to evaluate its own output.
