# risk-analyst

Operator documentation for the `risk-analyst` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han-core/agents/risk-analyst.md`](../../../han-core/agents/risk-analyst.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md)

## TL;DR

- **What it does.** Assesses the risk of inaction for architectural findings produced by upstream analysts. Evaluates each finding across four dimensions: likelihood, severity, blast radius, and reversibility.
- **When to dispatch it.** The architectural analysts (`structural-analyst`, `behavioral-analyst`, `concurrency-analyst`) have produced findings and you need to prioritize them. Always dispatched by `/architectural-analysis` after the three parallel analysts complete. Conditionally dispatched by `/architectural-decision-record` for ADR risk scoring, and by `/plan-a-feature`, `/plan-implementation`, and `/iterative-plan-review` when the plan carries significant blast radius.
- **What you get back.** Numbered `R#` risk assessments, each cross-referencing upstream findings, with likelihood / severity / blast radius / reversibility ratings and a concrete *what-happens-if-deferred* description.

## Key concepts

- **Receives pre-digested findings.** The agent does not discover new problems. The upstream analysts have already done that work. The agent's job is to evaluate what happens if each finding is not addressed.
- **Four-dimensional assessment.** Likelihood (how likely is it to bite?), severity (what happens when it bites?), blast radius (how much is affected?), reversibility (how hard is it to undo?). All four are required for every assessment.
- **Evidence-based, not speculative.** Likelihood ratings are grounded in git history and usage patterns. Blast radius is grounded in dependency-graph traces. The agent uses `Read`, `Grep`, and `Glob` against the codebase to verify, not merely label.
- **Groups related findings.** When multiple upstream findings describe facets of the same underlying risk, the agent groups them rather than assessing each in isolation.
- **Low-risk results matter.** When an upstream finding carries low risk, the agent says so explicitly. Not everything needs fixing.

## When to use it

**Dispatch when:**

- `/architectural-analysis` has finished its three parallel analysts and you need risk-based prioritization before synthesis. The skill always dispatches this agent.
- `/architectural-decision-record` is running. The skill dispatches this agent to score the chosen option and each rejected alternative.
- You have a manual set of architectural findings (from a non-skill source) and want them prioritized.
- A team needs to decide which architectural debt to address first and wants an evidence-based prioritization.

**Do not dispatch for:**

- Discovering findings. Use `structural-analyst`, `behavioral-analyst`, or `concurrency-analyst`.
- Architectural recommendations. Use `software-architect` or `system-architect`.
- Production-readiness risk (operational, scale, observability). Use `devops-engineer`.
- Security risk. Use `adversarial-security-analyst`.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-core:risk-analyst`. Give it:

1. **The full verbatim output of upstream analysts.** `structural-analyst` findings (`S#`), `behavioral-analyst` findings (`B#`), `concurrency-analyst` findings (`C#`). Without these, the agent has nothing to assess.
2. **Project context, optional.** Production criticality, deadlines, team capacity. The likelihood and severity scales calibrate on the team's risk appetite.

Example prompts:

- *"Assess risk of inaction for these findings: [paste S1-S7, B1-B4, C1-C2]. This is the auth service. Production-critical."*

## What you get back

- Numbered `R#` risk assessments, ordered from highest to lowest overall risk. Each item includes:
  - **Addresses.** Cross-references to upstream `S#`, `B#`, `C#` findings.
  - **Likelihood.** Near certain / Likely / Possible / Unlikely, with evidence.
  - **Severity.** Critical / High / Medium / Low, with a concrete failure scenario.
  - **Blast radius.** System-wide / Multi-module / Single module / Localized, with a dependency count.
  - **Reversibility.** Irreversible / Difficult / Moderate / Easy, with explanation.
  - **Overall risk** band.
  - **What happens if deferred.** A concrete scenario, not a vague warning.
- A **Risk Summary** with counts of Critical, High, Medium, and Low risks, plus findings explicitly assessed as low-risk (which is useful prioritization signal).

## How to get the most out of it

- **Feed it complete upstream output.** Abbreviated findings degrade the assessment. Pass the verbatim `S#`/`B#`/`C#` blocks.
- **Run with git available.** The agent uses git history to ground likelihood ratings (frequent changes in the area = higher likelihood). Without git, the agent says so and falls back to code-structure inference.
- **Read the "what happens if deferred" field.** That is where the agent's judgment lives. If the scenario reads thin, the upstream finding may not warrant the assigned severity.
- **Honor the low-risk results.** Findings the agent rates as Low-risk are explicit prioritization signal. Not every architectural finding needs a fix.

## Cost and latency

The agent runs on `sonnet`. A risk pass over the output of three analysts runs in a couple of minutes. The agent is designed to run once per architectural analysis, not iteratively.

## Sources

The agent's framework is grounded in established risk-assessment practice.

### NIST SP 800-30: Guide for Conducting Risk Assessments

NIST's risk-assessment guide formalizes the likelihood-times-impact framing the agent applies. The four-dimensional decomposition (likelihood, severity, blast radius, reversibility) is the engineering-applied version.

URL: https://csrc.nist.gov/publications/detail/sp/800-30/rev-1/final

### Doug Hubbard: How to Measure Anything

Hubbard's argument that uncertain things can be measured with calibrated evidence underpins the agent's insistence that likelihood and blast radius come from git history and grep output, not opinion.

URL: https://www.howtomeasureanything.com/

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [Agents Index](../README.md). All agents, grouped by role.
- [`structural-analyst`](./structural-analyst.md), [`behavioral-analyst`](./behavioral-analyst.md), [`concurrency-analyst`](./concurrency-analyst.md). The upstream agents whose findings this one consumes.
- [`software-architect`](./software-architect.md). Consumes this agent's risk ratings alongside the upstream findings to produce recommendations.
- [`/architectural-analysis`](../../skills/han-coding/architectural-analysis.md). Always dispatches this agent.
- [`/architectural-decision-record`](../../skills/han-core/architectural-decision-record.md). Dispatches this agent for ADR risk scoring.
- [`/plan-a-feature`](../../skills/han-planning/plan-a-feature.md). Conditionally dispatches this agent when the feature carries significant blast radius.
- [`/plan-implementation`](../../skills/han-planning/plan-implementation.md). Conditionally dispatches this agent when the plan carries significant blast radius.
- [`/iterative-plan-review`](../../skills/han-planning/iterative-plan-review.md). Conditionally dispatches this agent when the plan carries significant blast radius.
