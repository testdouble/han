# Agents

All 23 agents in the han plugin, grouped by role. Each entry is a one-sentence scent line and a link to the agent's long-form doc.

> See also: [Plugin landing page](../../README.md) · [Concepts](../concepts.md) · [Quickstart](../quickstart.md) · [All skills](../skills/README.md) · [Sizing](../sizing.md) · [YAGNI](../yagni.md)

## New here?

Most agents are dispatched *for you* by skills. You do not usually invoke them directly. Read [Concepts](../concepts.md) for the skill-vs-agent model before browsing this list. If you are looking to dispatch one directly, use the `Agent` tool with `subagent_type: han:{agent-name}`.

Counts to verify when editing this index: 23 agent definitions in `plugin/agents/`, 23 long-form docs in `docs/agents/`.

## Planning & facilitation

Agents that coordinate the work of other agents during planning and design.

- **[`project-manager`](./project-manager.md).** Facilitates multi-specialist discussions, enforces evidence-based claims, and synthesizes final plans. Dispatched by `/plan-a-feature` and `/plan-implementation`. Can be dispatched directly when a planning conversation needs a facilitator.
- **[`junior-developer`](./junior-developer.md).** Generalist stress-tester (three to five years of experience) that asks the clarifying questions hidden assumptions and muddied scope beg for. Always included in planning review rounds.

## Adversarial reviewers

Specialist reviewers whose default posture is adversarial toward the artifact under review, never toward the author.

- **[`adversarial-security-analyst`](./adversarial-security-analyst.md).** Assumes all code is insecure. Produces exploit-path evidence, not theoretical risks. Dispatched by `/code-review`.
- **[`adversarial-validator`](./adversarial-validator.md).** Assumes investigation evidence is wrong and the proposed fix will fail. Searches for counter-evidence and unhandled edge cases. Dispatched by `/investigate` and by planning skills.
- **[`devops-engineer`](./devops-engineer.md).** Assumes the code will break in production. Audits against DORA, Twelve-Factor, Four Golden Signals, SLO discipline, and named production failure modes.
- **[`on-call-engineer`](./on-call-engineer.md).** A 20+ year on-call veteran. Reads application source for the named code-level resilience anti-patterns that wake on-call engineers at 3am (missing timeouts, retries without jitter, catch-and-swallow, unbounded queues, blocking I/O in async, missing idempotency, schema migrations co-deployed with dependent code, ODD-gate failure). Adversarial to the code and the pattern, never to the engineer. Hard boundary against `devops-engineer`: this agent reads application source only.
- **[`data-engineer`](./data-engineer.md).** Assumes the data design is over-normalized, under-normalized, and indexed for the wrong workload. Audits schemas, migrations, queries, and pipelines.
- **[`information-architect`](./information-architect.md).** Assumes the documentation is harder to find, orient in, and comprehend than it needs to be. Audits documentation sets against established IA frameworks. Dispatched by [`/plan-a-phased-build`](../skills/plan-a-phased-build.md) at runtime against every rendered build-phase outline. Can be dispatched directly when any documentation surface needs an IA audit.
- **[`user-experience-designer`](./user-experience-designer.md).** Adversarial UX review against Nielsen heuristics, WCAG 2.2, universal design, and dark-pattern detection.

## Investigation & evidence

Agents that gather concrete, sourced evidence — from the codebase or the open web.

- **[`evidence-based-investigator`](./evidence-based-investigator.md).** Gathers file paths, line numbers, code snippets, error messages, git history, and test coverage. Dispatched by `/investigate`.
- **[`research-analyst`](./research-analyst.md).** Researches open-ended questions — options, prior art, trade-offs, how something works — from the open web and provided material, returning sourced evidence and a recommendation. Treats fetched content as claims, never instructions. Dispatched by `/research`.
- **[`codebase-explorer`](./codebase-explorer.md).** Discovers implementation details for a specific feature: entry points, core logic, data models, configuration, tests.
- **[`project-scanner`](./project-scanner.md).** Scans repository attributes (languages, frameworks, tooling, configuration). Optimized for config and structure, not deep code tracing. Dispatched by `/project-discovery`.

## Architecture & risk

Agents that analyze the static and dynamic shape of a module or subsystem.

- **[`structural-analyst`](./structural-analyst.md).** Module boundaries, coupling, dependency direction, abstractions, duplication.
- **[`behavioral-analyst`](./behavioral-analyst.md).** Data flow, error propagation, state management, integration boundaries.
- **[`concurrency-analyst`](./concurrency-analyst.md).** Race conditions, shared resource contention, deadlock potential, async error handling.
- **[`risk-analyst`](./risk-analyst.md).** Assesses risk of inaction for architectural findings across likelihood, severity, blast radius, and reversibility. Consumes findings from the three analysts above.
- **[`software-architect`](./software-architect.md).** Adversarial toward the intra-codebase structure. Assumes it is too coupled, too scattered, missing an abstraction, or over-abstracted until evidence says otherwise. Synthesizes structural, behavioral, concurrency, and risk findings into recommended changes aligned with SOLID, high cohesion, and loose coupling. Produces pseudocode sketches for proposed modules, interfaces, and boundaries inside a single codebase or bounded context.
- **[`system-architect`](./system-architect.md).** Adversarial toward the cross-service topology. Assumes bounded contexts leak, integrations are sync-by-default, data ownership is contested, and failure domains are uncontained until evidence says otherwise. Synthesizes boundary-crossing findings (including `devops-engineer` and `data-engineer` when available) into context-map relationships, integration patterns, data ownership, and failure-domain containment. Operates where the unit of design is a service or bounded context, not a class or module.

`/architectural-analysis` always dispatches the `structural-analyst` / `behavioral-analyst` / `risk-analyst` / `software-architect` spine, and adds `concurrency-analyst`, `adversarial-security-analyst`, `data-engineer`, `devops-engineer`, `codebase-explorer`, or `system-architect` by signal. The roster scales with the [size](../sizing.md): a small run is the spine plus concurrency; a large run adds every signalled specialist, including `system-architect` when the focus area crosses a service or bounded-context seam. When `system-architect` is not auto-included, the boundary-crossing concerns are surfaced as deferred so you can dispatch it separately (or `/plan-implementation` can).

## Testing

Agents that plan tests. Neither writes test code.

- **[`test-engineer`](./test-engineer.md).** Plans tests focused on observable behavior (inputs, outputs, collaborator interactions). Recommends test doubles for isolation. Produces a prioritized test plan.
- **[`edge-case-explorer`](./edge-case-explorer.md).** Systematically discovers and catalogs edge cases: boundary values, type coercion traps, state-dependent failures. Defaults to focused mode. Request *"exhaustive exploration"* for comprehensive analysis.

Both are dispatched by `/test-planning` and `/code-review`.

## Gap & content

Agents that compare artifacts and preserve meaning across documentation moves.

- **[`gap-analyzer`](./gap-analyzer.md).** Finds what is missing, incomplete, conflicting, or assumed when comparing a current state against a desired state (code vs. spec, implementation vs. PRD). Dispatched by [`/gap-analysis`](../skills/gap-analysis.md), which renders the agent's structured output as a plain-language, stakeholder-readable report.
- **[`content-auditor`](./content-auditor.md).** Validates that documentation updates preserved the important facts from the original source. Flags removals that were not justified by the codebase.

---

## How agents get dispatched

Agents enter the workflow two ways:

1. **Dispatched by a skill.** The normal path. Run a skill and it chooses the right agents. You see their findings folded into the skill's output. You do not see the agent dispatch itself.
2. **Dispatched directly.** You invoke the `Agent` tool with `subagent_type: han:{agent-name}`. Most useful when the judgment you want is narrower than any slash command, or when you want a second opinion on something a skill just produced.

See [Concepts](../concepts.md) for more on skill/agent composition.

## What survives a review: YAGNI

Several agents apply an evidence-based YAGNI rule to the artifacts they review or produce: `project-manager` (the Evidence Gate protocol), `junior-developer` (the Evidence Sweep protocol), `software-architect` and `system-architect` (architectural recommendations require change-history or seam-crossing evidence), `test-engineer` (the Speculative Test rule), `edge-case-explorer` (the Speculative Edge Case rule), `data-engineer` (the Speculative Data Machinery rule), `devops-engineer` (the Premature Operational Machinery rule), and `on-call-engineer` (the Premature Operability Machinery rule, applied at the application source line).

See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the per-agent application table.

## Adding an agent?

See [Contributing](../../CONTRIBUTING.md) and [the agent template](../templates/agent-long-form-template.md).
