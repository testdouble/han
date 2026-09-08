# bounded-context-critic

Operator documentation for the `bounded-context-critic` agent in the han-ddd plugin. This agent is dispatched
for you by [`/ddd-analysis`](../skills/ddd-analysis.md) after `bounded-context-modeler`; you rarely invoke it
directly. For the agent's internal instructions and output format, read the agent definition at
[`han-ddd/agents/bounded-context-critic.md`](../../agents/bounded-context-critic.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md)

## TL;DR

- **What it does.** Evaluates every BCM# entry from the bounded-context-modeler against the discovery evidence
  that produced it, returning a verdict (strong, plausible, weak, or reject), the strongest supporting and
  counter-evidence, detected failure modes, missing evidence, and domain-expert questions for each proposed
  context, plus a model-level critique covering Context Explosion and God Context. It applies the legitimacy gate
  to every entry, holds LATENT status to a strict bar, and accepts a named DDD strategic relationship only when
  explicit strategic or organizational evidence backs it.
- **When to use it.** Dispatched by `/ddd-analysis` after the bounded-context-modeler completes. Invoke directly
  when you have existing BCM# entries and want an independent evaluation without re-running the full analysis.
- **What you get back.** Numbered BCR# evaluation entries, one per BCM# context, plus a Bounded Context Model
  Critique Summary.

## Key concepts

- **Evaluation only, no redesign.** The critic assigns verdicts and names failure modes. It does not propose
  alternative designs, recommend context splits or merges, or suggest services. When a verdict is weak or reject,
  the critic names what evidence is missing — gathering that evidence or redesigning the model is the team's job.
- **Eighteen named failure modes.** The critic checks every proposed context against a catalog of eighteen
  failure modes grouped by origin: structural (Service Equals Context, Directory Equals Context, Database Equals
  Context, Integration Boundary as Context), entity and noun (Entity Decomposition, Vocabulary Without Semantic
  Difference), technical contamination (Technical Layer Context, Premature Microservice Extraction), capability
  quality (CRUD Capability Bias, Boundary Without Behavioral Evidence, Workflow-Stage Context), scope (Scope
  Overreach), legitimacy (Premature BCM# Classification, LATENT Overreach, DDD Strategic Relationship Overreach),
  model scale (Context Explosion, God Context), and evidence quality (Shared Kernel Reflex). Context Explosion and
  God Context are model-level; the rest are per-context.
- **Positive confirmation matters.** A report that finds only problems is an incomplete evaluation. When a context
  is strongly supported by convergent evidence, the critic says so explicitly.
- **Verdict vocabulary.** Four verdicts: strong (evidence from multiple independent types confirms the boundary),
  plausible (evidence supports the boundary but gaps remain), weak (evidence is thin or largely structural), reject
  (the proposed boundary is not justified by the evidence and exhibits one or more named failure modes).
- **Complementary to bounded-context-modeler.** This agent does not generate bounded contexts — it evaluates them.
  `bounded-context-modeler` constructs proposals from evidence convergence; `bounded-context-critic` challenges
  each proposal to determine how well it holds up.

## When to use it

**Dispatch when:**

- You want an independent evaluation of the BCM# model's quality before taking any of its proposals to a domain
  expert or planning session.
- You are running `/ddd-analysis` — the skill dispatches this agent for you after the bounded-context-modeler
  completes.

**Do not dispatch for:**

- **Generating a bounded context model.** Use [`bounded-context-modeler`](./bounded-context-modeler.md) to
  construct proposals from discovery evidence first.
- **Recommendations for structural change.** Use `han-planning:plan-a-feature` for changes that follow from the
  critique's findings.

## How to invoke it

The `/ddd-analysis` skill dispatches this agent automatically after `bounded-context-modeler`. To invoke it
directly:

```
Agent(subagent_type: "han-ddd:bounded-context-critic", prompt: "...")
```

The brief names the first-pass context model file (`synthesis/context-model-initial.md` inside the run folder) and
the five discovery artifact files (DL#, CAP#, OWN#, S#, and B# findings) by path, instructing the agent to read them
with the Read tool rather than pasting their contents, plus a reminder that this agent evaluates only. It also names
the synthesis artifact path the agent writes its complete output to (`synthesis/critique.md`), so the agent returns
only the path, the BCR# count with verdict distribution, and the critique summary. No calibration directive is
needed; the critic evaluates every BCM# entry regardless of depth.

## What you get back

Numbered BCR# entries, one per BCM# context. Each entry contains:

- **Verdict:** strong | plausible | weak | reject
- **Supporting evidence:** The strongest evidence that justifies the boundary, cited by discovery finding identifier
- **Counter-evidence:** The strongest evidence or absence of evidence that challenges the boundary
- **Failure modes detected:** Any of the 12 named failure modes present, with the triggering evidence
- **Missing evidence:** The specific finding type or code signal that would raise confidence
- **Domain-expert questions:** Questions answerable in a meeting with a domain expert, focused on what would
  change the verdict

After all BCR# entries, a Bounded Context Model Critique Summary: verdict distribution, highest-confidence
contexts, most vulnerable contexts, Context Explosion check, and God Context check.

## Cost and latency

Model tier: Opus. This agent performs high-judgment evaluation of proposals and evidence, comparable in intensity
to the bounded-context-modeler. It runs sequentially after the bounded-context-modeler in a `/ddd-analysis` run.

## Related documentation

- [Plugin README](../../README.md). The han-ddd plugin front door.
- [Repo root README](../../../README.md). The Han suite landing page.
- [`/ddd-analysis`](../skills/ddd-analysis.md). The skill that dispatches this agent.
- [`bounded-context-modeler`](./bounded-context-modeler.md). The agent whose BCM# output this agent evaluates.
- [`domain-language-analyst`](./domain-language-analyst.md). The discovery agent whose DL# findings feed the
  evaluation.
- [`business-capability-analyst`](./business-capability-analyst.md). The discovery agent whose CAP# findings
  feed the evaluation.
- [`domain-ownership-analyst`](./domain-ownership-analyst.md). The discovery agent whose OWN# findings feed
  the evaluation.
- [`structural-analyst`](../../../han-core/docs/agents/structural-analyst.md). The discovery agent whose S#
  findings feed the evaluation.
- [`behavioral-analyst`](../../../han-core/docs/agents/behavioral-analyst.md). The discovery agent whose B#
  findings feed the evaluation.
