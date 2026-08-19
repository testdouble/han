# bounded-context-modeler

Operator documentation for the `bounded-context-modeler` agent in the han-ddd plugin. This agent is dispatched
for you by [`/ddd-analysis`](../skills/ddd-analysis.md); you rarely invoke it directly. For the agent's internal
instructions and output format, read the agent definition at
[`han-ddd/agents/bounded-context-modeler.md`](../../agents/bounded-context-modeler.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md)

## TL;DR

- **What it does.** Reads DL#, CAP#, OWN#, S#, and B# findings and constructs a semantic bounded context model
  — proposals whose vocabulary, capabilities, rules, and ownership cohere around distinct domain concerns, with a
  CURRENT/LATENT/SPECULATIVE status and explicit named exclusions.
- **When to use it.** Dispatched by `/ddd-analysis` twice: a first pass after all five discovery agents
  complete, and a revision pass after `bounded-context-critic` evaluates the first-pass model. Invoke directly
  when you have existing discovery findings and want a semantic context model without running a full analysis.
- **What you get back.** Numbered BCM# entries, each with a context name, purpose, responsibilities, vocabulary,
  capabilities, what it owns and consumes, explicit exclusions, relationships, supporting evidence, confidence,
  and status; plus a Bounded Context Model Summary.

## Key concepts

- **Convergence over individual signals.** A strong BCM# entry needs evidence from at least two independent types
  (DL#, CAP#, OWN#, S#, or B#). A vocabulary cluster alone, a set of capabilities alone, or an ownership
  pattern alone is at most SPECULATIVE. Evidence that converges across types builds confidence.
- **Semantic boundaries, not technical ones.** Directories, services, databases, schemas, and team boundaries are
  evidence worth weighing — they are not the boundary itself. A bounded context exists where a coherent domain
  model, vocabulary, and set of rules operates consistently, regardless of how the code is organized today.
- **Three status tiers.** CURRENT means vocabulary and ownership both cohere in the evidence. LATENT means
  capabilities cohere but ownership or vocabulary is dispersed across technical structures. SPECULATIVE means the
  evidence is meaningful but a domain expert must validate it before the team acts on it.
- **Entity decomposition is a failure mode.** A noun — Customer, Order, Product — is not a context boundary. A
  context is justified only when a convergence zone around that noun carries distinct vocabulary, a coherent
  capability cluster, and clear ownership that differs from other convergence zones. When that evidence is absent,
  the noun is shared terminology, not a boundary.
- **Paired with bounded-context-critic.** In a `/ddd-analysis` run, this agent produces a first-pass model,
  `bounded-context-critic` evaluates each BCM# entry against the discovery evidence, and this agent runs once
  more to address supported criticism and refuse criticism unsupported by evidence. The final BCM# model is the
  post-revision output.

## When to use it

**Dispatch when:**

- You want a semantic bounded context model derived from language, capability, ownership, structural, and
  behavioral evidence.
- You are running `/ddd-analysis` — the skill dispatches this agent for you twice, before and after the
  `bounded-context-critic` evaluation.

**Do not dispatch for:**

- **Gathering code evidence.** Use the discovery agents — `domain-language-analyst`,
  `business-capability-analyst`, `domain-ownership-analyst`, `han-core:structural-analyst`, and
  `han-core:behavioral-analyst` — first.
- **Recommendations for structural change.** Use `han-planning:plan-a-feature` for changes that follow from
  the model.

## How to invoke it

The `/ddd-analysis` skill dispatches this agent automatically. To invoke it directly:

```
Agent(subagent_type: "han-ddd:bounded-context-modeler", prompt: "...")
```

The brief must include all available discovery findings — the full verbatim DL#, CAP#, OWN#, S#, and B#
findings and their summaries — plus a calibration directive matched to the desired depth (top 3-5 CURRENT
contexts at small depth; all convergence zones supported by at least two evidence types at medium depth;
exhaustive, including all SPECULATIVE candidates with meaningful evidence, at large depth), and a reminder that
this agent produces a semantic context model only.

For the revision pass, the brief must also include the full verbatim BCM# entries and Bounded Context Model
Summary from the first pass, and the full verbatim BCR# entries and Bounded Context Model Critique Summary from
`bounded-context-critic`, with an explicit instruction to address supported criticism and refuse criticism
unsupported by evidence.

## What you get back

Numbered BCM# entries. Each entry contains:

- **Status:** CURRENT | LATENT | SPECULATIVE
- **Confidence:** High | Medium | Low, with one sentence on the evidence quality
- **Purpose:** One sentence describing the domain concern and who it serves
- **Responsibilities:** 2-5 specific responsibilities
- **Vocabulary:** Terms constituting the ubiquitous language inside the context, quoted verbatim from evidence
- **Capabilities:** CAP# references or capability names belonging to this context
- **Owns:** Domain concepts, information, and rules held authoritatively, with OWN# references
- **Consumes:** Domain concepts read from other contexts, with source BCM# when known
- **Does not own:** Concepts that appear near but belong to another context, named explicitly
- **Relationships:** Other BCM# candidates with named DDD relationship types where evidence supports them
- **Evidence:** The specific finding identifiers supporting this proposal

After all BCM# items, the agent produces a Bounded Context Model Summary: total proposed, split by status tier,
confidence distribution, strongest convergence, and evidence gaps.

## Cost and latency

Model tier: Opus. This agent performs high-judgment synthesis across multiple finding types, which makes it one
of the more compute-intensive steps in a `/ddd-analysis` run. It is dispatched twice per run — first after all
five discovery agents complete, and once more after `bounded-context-critic` evaluates the first-pass model.

## Related documentation

- [Plugin README](../../README.md). The han-ddd plugin front door.
- [Repo root README](../../../README.md). The Han suite landing page.
- [`/ddd-analysis`](../skills/ddd-analysis.md). The skill that dispatches this agent twice — first pass and
  revision pass.
- [`bounded-context-critic`](./bounded-context-critic.md). The evaluation agent dispatched between the two
  modeler passes, returning verdicts and detected failure modes per BCM# entry.
- [`domain-language-analyst`](./domain-language-analyst.md). The discovery agent whose DL# findings drive
  vocabulary convergence.
- [`business-capability-analyst`](./business-capability-analyst.md). The discovery agent whose CAP# findings
  drive capability convergence.
- [`domain-ownership-analyst`](./domain-ownership-analyst.md). The discovery agent whose OWN# findings drive
  ownership convergence.
- [`structural-analyst`](../../../han-core/docs/agents/structural-analyst.md). The discovery agent whose S#
  findings provide structural evidence.
- [`behavioral-analyst`](../../../han-core/docs/agents/behavioral-analyst.md). The discovery agent whose B#
  findings provide behavioral evidence.
