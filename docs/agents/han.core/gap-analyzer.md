# gap-analyzer

Operator documentation for the `gap-analyzer` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/gap-analyzer.md`](../../../han.core/agents/gap-analyzer.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Performs adversarial gap analysis between two artifacts: a current state and a desired state. Finds what's missing, incomplete, conflicting, or assumed. Classifies every finding into the four-category taxonomy: Missing / Partial / Divergent / Implicit.
- **When to dispatch it.** You want a structured comparison of an implementation against a spec, PRD, or design doc, with evidence pairs from both inputs. Always dispatched by `/gap-analysis` for the primary analysis.
- **What you get back.** A structured `gap-analysis-source.md` with `GAP-NNN` entries. Each entry has a category, a `Feature/Behavior` label, and `Current State` / `Desired State` descriptions, each carrying a citation from its input.

## Key concepts

- **Adversarial: gaps exist until proven otherwise.** The agent's default stance is that the current state fails to satisfy the desired state somewhere. The work is to find every gap and back each with evidence from both inputs.
- **Four-category taxonomy.** Missing (no correspondence in current state), Partial (correspondence exists but coverage is incomplete), Divergent (both states address the concern in incompatible ways), Implicit (desired state assumes a capability the current state neither confirms nor denies).
- **Evidence pair per finding.** Every gap requires a citation from the desired state and a citation from the current state (or an explicit *"not found, searched X"*). A finding without a pair is not valid.
- **Canonical evidence rule applies.** The agent reads the canonical [evidence rule](../../evidence.md) at runtime. Each citation in an evidence pair carries a trust class (codebase, web, provided). When a current-state citation is a single web source, the corroboration gate applies before that gap can drive a recommendation. When the desired-state side is silent ("the spec does not address X"), the gap is recorded as Implicit with the no-evidence label rather than inferring intent.
- **Behavior over implementation.** The agent compares features and behaviors. Technology differences are noted but not investigated unless asked. Implementation-level comparisons across mismatched abstraction levels are an anti-pattern.
- **Adversarial self-check before reporting.** For every gap, the agent tries to disprove it by searching for evidence the gap is covered elsewhere. Only findings that survive the challenge are reported.

## When to use it

**Dispatch when:**

- `/gap-analysis` is running. The skill always dispatches this agent for the primary analysis and renders the agent's structured output into a stakeholder-readable report.
- `/iterative-plan-review` is in team mode and you want gaps surfaced as a review pillar.
- `/plan-a-feature` is running and you want a draft spec compared against a PRD or reference spec to surface gaps before the spec is finalized.
- You want a raw structured gap analysis without the IA-designed report rendering. (Usually you want the rendering. Use `/gap-analysis` directly.)

**Do not dispatch for:**

- Documentation preservation audits (before-and-after content audit). Use `content-auditor`.
- Bug investigation. Use `evidence-based-investigator`.
- Code quality or correctness review. Use `/code-review`.
- Architectural assessment. Use `/architectural-analysis`.
- Single-artifact analysis with no comparison target, even implied.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:gap-analyzer`. Give it:

1. **The current state.** A file path, directory, URL, or inline text. The first input is the current state unless otherwise specified.
2. **The desired state.** A file path, directory, URL, or inline text. The second input is the desired state unless otherwise specified.
3. **Scope, optional.** A bounded comparison area (a specific subsystem, feature, or section). Without scope, the agent identifies comparison areas itself.
4. **Direction, optional.** Default is current → desired (what does the implementation lack relative to the spec). Override for reversed or bidirectional analysis.

Example prompts:

- *"Gap-analyze `src/auth/` against `docs/specs/auth.md`. Default direction: current → desired."*
- *"Compare the v2 PRD at `docs/prd-v2.md` against the v3 PRD at `docs/prd-v3.md`. Bidirectional. We need scope creep and dropped requirements."*

## What you get back

- A `gap-analysis-source.md` file on disk with `GAP-NNN` entries. Each entry includes:
  - Category (Missing / Partial / Divergent / Implicit).
  - `Feature/Behavior`: the feature or behavior the gap concerns.
  - `Current State`: what the current state shows, with evidence (file path and line number, document section heading, or URL excerpt).
  - `Desired State`: what the desired state specifies, to the same evidence standard.
- A returned summary with gap counts by category and the file path.

The structured output is designed to be consumed by `/gap-analysis`, which translates each entry into a plain-language `G-NNN` entry in the rendered report.

## How to get the most out of it

- **Be explicit about direction.** Default is current → desired. State *"bidirectional"* or *"reversed"* up front when needed.
- **Scope narrowly when you can.** A bounded comparison area produces sharper gaps than a full-document compare.
- **Provide both artifacts in their canonical form.** A URL plus a code directory works. A summary of either input degrades the agent's evidence pairs.
- **Pair with a validator swarm — the default.** `/gap-analysis` runs `adversarial-validator` and `junior-developer` (actor-perspective sweep) against every gap by default, with `evidence-based-investigator` added when the current state is concrete, plus domain specialists and `project-manager` at medium and large. Opt out with `no swarm` when you want a raw analyzer-only pass for rapid first-pass scoping.

## Cost and latency

The agent runs on `sonnet`. A focused-scope analysis runs in a few minutes. The cost scales with the size of the two inputs and the number of comparison areas.

## Sources

The agent's taxonomy and protocols are grounded in formal specification practice.

### Gojko Adzic: Specification by Example

Adzic's framework of concrete, testable examples informs the agent's insistence on evidence pairs grounded in real artifacts rather than abstract claims.

URL: https://gojko.net/books/specification-by-example/

### Karl Popper: Falsificationism

Popper's argument that claims must be falsifiable shapes the agent's Step 5 (adversarial self-check). Every gap must survive a search for counter-evidence.

URL: https://plato.stanford.edu/entries/popper/

### IEEE 829: Standard for Software and System Test Documentation

IEEE 829's taxonomy of coverage gaps informs the agent's four-category classification scheme.

URL: https://standards.ieee.org/ieee/829/3787/

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [Agents Index](../README.md). All agents, grouped by role.
- [`adversarial-validator`](./adversarial-validator.md). Used by `/gap-analysis` swarms to attack each gap with counter-evidence.
- [`evidence-based-investigator`](./evidence-based-investigator.md). Used by `/gap-analysis` swarms to verify each gap against the current state.
- [`content-auditor`](./content-auditor.md). Sibling for before-and-after content preservation (different problem).
- [`/gap-analysis`](../../skills/han.core/gap-analysis.md). Always dispatches this agent.
- [`/plan-a-feature`](../../skills/han.core/plan-a-feature.md). Dispatches this agent to compare a draft spec against a PRD or reference spec.
- [Evidence](../../evidence.md). The canonical evidence rule the agent reads at runtime. Trust classes for evidence pairs, the corroboration gate for single-source web claims, and the no-evidence label for silent desired-state evidence.
