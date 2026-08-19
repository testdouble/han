# han-ddd

The strategic Domain-Driven Design analysis layer of the Han suite. Discover domain boundaries, identify bounded
context candidates, find boundary leaks, and produce an evidence-backed domain and context map for an existing
codebase. The entire repository is a valid scope — no module or directory needs to be named first.

**Opt-in.** Not bundled by the `han` meta-plugin. Depends on `han-communication` and `han-core`.

**Getting started:** run [`/ddd-analysis`](docs/skills/ddd-analysis.md) against any repository to produce a domain map.

## Skills

- [`/ddd-analysis`](docs/skills/ddd-analysis.md) — Analyze a codebase through a DDD lens and produce an
  evidence-backed domain and context map that distinguishes strongly expressed boundaries from latent ones,
  speculative hypotheses, and contested ownerships.

## Agents

- [`bounded-context-analyst`](docs/agents/bounded-context-analyst.md) — Read a codebase and classify bounded
  context candidates from naming cohesion, module clustering, data models, API surfaces, and deployment signals.
- [`bounded-context-critic`](docs/agents/bounded-context-critic.md) — Evaluate every BCM# entry from
  bounded-context-modeler against the discovery evidence, returning a verdict and detected failure modes for each
  proposed context.
- [`bounded-context-modeler`](docs/agents/bounded-context-modeler.md) — Read DL#, CAP#, and OWN# discovery
  findings and construct a semantic bounded context model: proposals whose vocabulary, capabilities, rules, and
  ownership cohere around distinct domain concerns, with CURRENT, LATENT, and SPECULATIVE status tiers.
- [`business-capability-analyst`](docs/agents/business-capability-analyst.md) — Read a codebase and surface
  cohesive business capabilities from behavioral evidence: actions, workflows, policies, state transitions,
  commands, and domain events — named as verb phrases rather than entity groupings.
- [`domain-language-analyst`](docs/agents/domain-language-analyst.md) — Read a codebase and surface Domain-Driven
  Design language signals: business terminology, vocabulary clusters, semantic collisions, synonyms, and places
  where technical naming obscures the domain.
- [`domain-ownership-analyst`](docs/agents/domain-ownership-analyst.md) — Read a codebase and surface domain
  ownership evidence: who creates, modifies, and consumes domain concepts; which representation is authoritative;
  where lifecycle begins and ends; and where authority is contested or ambiguous.
- [`domain-map-synthesizer`](docs/agents/domain-map-synthesizer.md) — Synthesize BC#, DL#, CAP#, and OWN#
  findings into a four-tier domain and context map with SE#, LT#, SP#, BL#, and DQ# items.

The other agents the skill dispatches are the shared specialists in `han-core` (and, for the readability-editor,
in `han-communication`).

## Installation

Add the marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add testdouble/han
/plugin install han-ddd@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
