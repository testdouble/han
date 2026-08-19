# domain-map-synthesizer

Operator documentation for the `domain-map-synthesizer` agent in the han-ddd plugin. This agent is dispatched for
you by [`/ddd-analysis`](../skills/ddd-analysis.md); you rarely invoke it directly. For the agent's internal
instructions and output format, read the agent definition at
[`han-ddd/agents/domain-map-synthesizer.md`](../../agents/domain-map-synthesizer.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md)

## TL;DR

- **What it does.** Reads BC# findings from the bounded-context-analyst, DL# findings from the
  domain-language-analyst, CAP# findings from the business-capability-analyst, and OWN# findings from the
  domain-ownership-analyst, and synthesizes them into a four-tier domain and context map, organized by evidence
  confidence.
- **When to use it.** Dispatched by `/ddd-analysis` after the bounded-context-analyst completes. Invoke directly
  only when you have BC# findings from a prior run and want to re-synthesize the map.
- **What you get back.** SE#, LT#, SP#, BL#, and DQ# items organized into a structured domain map, plus a plain-text
  context map sketch and a Domain Map Summary.

## Key concepts

- **Five output categories.** The agent organizes BC# findings into: SE# (Strongly Expressed), LT# (Latent), SP#
  (Speculative), BL# (Boundary Leak or Contested Ownership), and DQ# (Domain Question). A single BC# finding may
  contribute to more than one category.
- **Every item traces to a discovery finding.** The agent does not add domain assumptions not present in the BC#,
  DL#, CAP#, or OWN# findings. If a classification requires information the findings do not contain, it surfaces a
  DQ# item rather than inferring an answer.
- **Discovery artifact, not action plan.** The domain map characterizes the current domain shape. It does not
  recommend service splits, migrations, or refactors.
- **Opus model for synthesis quality.** The judgment required to reconcile ambiguous BC# findings across the five
  tiers benefits from the higher-reasoning model.

## When to use it

**Dispatch when:**

- You want to synthesize an existing set of BC#, DL#, and CAP# discovery findings into a structured domain map.
- You are running `/ddd-analysis` — the skill dispatches this agent for you in parallel with
  `bounded-context-modeler` after the discovery agents complete.

**Do not dispatch for:**

- **Gathering code evidence.** Use [`bounded-context-analyst`](./bounded-context-analyst.md) to produce BC#
  findings, [`domain-language-analyst`](./domain-language-analyst.md) to produce DL# findings,
  [`business-capability-analyst`](./business-capability-analyst.md) to produce CAP# findings, and
  [`domain-ownership-analyst`](./domain-ownership-analyst.md) to produce OWN# findings first.
- **Designing integration patterns or context-map relationships.** Use `han-core:system-architect` for
  recommendations that follow from the domain map.
- **Assessing architectural risk.** Use `han-core:risk-analyst` for findings that need risk scoring.

## How to invoke it

The `/ddd-analysis` skill dispatches this agent automatically. To invoke it directly:

```
Agent(subagent_type: "han-ddd:domain-map-synthesizer", prompt: "...")
```

The brief must include the full verbatim BC# findings and Discovery Summary from the bounded-context-analyst, the
full verbatim DL# findings and Language Summary from the domain-language-analyst, the full verbatim CAP# findings
and Capability Summary from the business-capability-analyst, the full verbatim OWN# findings and Ownership Summary
from the domain-ownership-analyst, the scope and depth, and a reminder that this agent produces a domain map only.

## What you get back

Five sections of named map items:

- **SE# (Strongly Expressed):** Each entry names the context, its core domain concepts, its technical boundary
  evidence, and its context relationships (using named DDD relationship types where evidence supports them).
- **LT# (Latent):** Each entry names the context, why it is latent, and what technical change would make it
  strongly expressed.
- **SP# (Speculative):** Each entry frames the hypothesis and the specific domain-expert question needed to confirm
  or refute it.
- **BL# (Boundary Leak or Contested Ownership):** Each entry names the contexts involved, the contested concept, and
  the file-path evidence.
- **DQ# (Domain Question):** Each entry states the question as something a domain expert could answer in a meeting,
  and names which map items depend on the answer.

After the five sections, the agent produces a plain-text domain map sketch and a Domain Map Summary with per-tier
counts and the highest-confidence placements.

## Cost and latency

Model tier: Opus. The agent receives pre-digested BC#, DL#, CAP#, and OWN# findings and performs synthesis rather
than code reading, so its wall-clock time is shorter than the discovery agents'. It runs in parallel with
`bounded-context-modeler` after all four discovery agents complete in a `/ddd-analysis` run.

## Related documentation

- [Plugin README](../../README.md). The han-ddd plugin front door.
- [Repo root README](../../../README.md). The Han suite landing page.
- [`/ddd-analysis`](../skills/ddd-analysis.md). The skill that dispatches this agent.
- [`bounded-context-analyst`](./bounded-context-analyst.md). The discovery agent whose BC# findings this agent
  synthesizes.
- [`business-capability-analyst`](./business-capability-analyst.md). The companion discovery agent whose CAP#
  capability findings this agent synthesizes alongside BC# and DL# findings.
- [`domain-language-analyst`](./domain-language-analyst.md). The companion discovery agent whose DL#
  language-signal findings this agent synthesizes alongside BC# findings.
- [`domain-ownership-analyst`](./domain-ownership-analyst.md). The companion discovery agent whose OWN#
  ownership findings this agent synthesizes alongside BC#, DL#, and CAP# findings.
- [`bounded-context-modeler`](./bounded-context-modeler.md). The complementary synthesis agent that constructs a
  semantic bounded context model from DL#, CAP#, and OWN# evidence convergence.
- [`system-architect`](../../../han-core/docs/agents/system-architect.md). The agent for cross-service integration
  recommendations that follow from the domain map.
