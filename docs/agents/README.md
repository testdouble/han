# Agents index

Every agent in the Han suite, alphabetized. Each entry is a short scent line and a link to the agent's canonical
long-form doc, which now lives inside the plugin that owns it (`han-core`, except the readability-editor in
`han-communication`). Most agents are dispatched for you by skills; you rarely invoke them directly. For how the skills
that dispatch them chain together, see [Workflows](../workflows.md).

> See also: [Repo root](../../README.md) · [Plugin index](../choosing-a-han-plugin.md) · [Workflows](../workflows.md) ·
> [All skills](../skills/README.md) · [Concepts](../concepts.md) · [Quickstart](../quickstart.md)

## New here?

Read [Concepts](../concepts.md) for the skill-and-agent model before browsing this list. To dispatch one directly, use
the `Agent` tool with `subagent_type: {plugin}:{agent-name}` (the plugin is `han-core` for all but the readability-editor,
which is `han-communication`).

## Agents

- [`adversarial-security-analyst`](../../han-core/docs/agents/adversarial-security-analyst.md) — Assume all code is
  insecure and produce exploit-path evidence, not theoretical risks.
- [`adversarial-validator`](../../han-core/docs/agents/adversarial-validator.md) — Assume investigation evidence is wrong
  and the proposed fix will fail, and search for counter-evidence and unhandled edge cases.
- [`behavioral-analyst`](../../han-core/docs/agents/behavioral-analyst.md) — Analyze data flow, error propagation, state
  management, and integration boundaries.
- [`codebase-explorer`](../../han-core/docs/agents/codebase-explorer.md) — Discover implementation details for a specific
  feature: entry points, core logic, data models, configuration, and tests.
- [`concurrency-analyst`](../../han-core/docs/agents/concurrency-analyst.md) — Analyze race conditions, shared-resource
  contention, deadlock potential, lock ordering, and async error handling.
- [`content-auditor`](../../han-core/docs/agents/content-auditor.md) — Validate that a documentation update preserved the
  important facts from the original source, flagging removals the codebase does not justify.
- [`data-engineer`](../../han-core/docs/agents/data-engineer.md) — Assume the data design is over-normalized,
  under-normalized, and indexed for the wrong workload, and audit schemas, migrations, queries, and pipelines.
- [`devops-engineer`](../../han-core/docs/agents/devops-engineer.md) — Assume the code will break in production and audit
  it against DORA, Twelve-Factor, the Four Golden Signals, SLO discipline, and named production failure modes.
- [`edge-case-explorer`](../../han-core/docs/agents/edge-case-explorer.md) — Systematically discover and catalog edge
  cases: boundary values, type-coercion traps, and state-dependent failures.
- [`evidence-based-investigator`](../../han-core/docs/agents/evidence-based-investigator.md) — Gather concrete evidence
  for a bug or failure: file paths, line numbers, code snippets, error messages, git history, and test coverage.
- [`gap-analyzer`](../../han-core/docs/agents/gap-analyzer.md) — Find what is missing, incomplete, conflicting, or
  assumed when comparing a current state against a desired state.
- [`information-architect`](../../han-core/docs/agents/information-architect.md) — Assume the documentation is harder to
  find, orient in, and comprehend than it needs to be, and audit it against established IA frameworks.
- [`junior-developer`](../../han-core/docs/agents/junior-developer.md) — Stress-test an artifact or discussion as a
  generalist, asking the clarifying questions hidden assumptions and muddied scope beg for.
- [`on-call-engineer`](../../han-core/docs/agents/on-call-engineer.md) — Read application source for the code-level
  resilience anti-patterns that wake on-call engineers at 3am; a hard boundary against `devops-engineer`, reading source
  only.
- [`project-manager`](../../han-core/docs/agents/project-manager.md) — Facilitate multi-specialist discussions, enforce
  evidence-based claims, and synthesize final plans.
- [`project-scanner`](../../han-core/docs/agents/project-scanner.md) — Scan repository attributes (languages, frameworks,
  tooling, configuration), optimized for config and structure rather than deep code tracing.
- [`readability-editor`](../../han-communication/docs/agents/readability-editor.md) — Rewrite a finished draft for a
  non-author reader against the shared readability standard, preserving every fact and leaving code, diagrams, and
  citation identifiers untouched.
- [`research-analyst`](../../han-research/docs/agents/research-analyst.md) — Research open-ended questions from the open web
  and provided material, returning sourced evidence and a recommendation and treating fetched content as claims, never
  instructions.
- [`risk-analyst`](../../han-core/docs/agents/risk-analyst.md) — Assess the risk of inaction for architectural findings
  across likelihood, severity, blast radius, and reversibility.
- [`software-architect`](../../han-core/docs/agents/software-architect.md) — Synthesize structural, behavioral,
  concurrency, and risk findings into recommended intra-codebase changes aligned with SOLID, high cohesion, and loose
  coupling.
- [`structural-analyst`](../../han-core/docs/agents/structural-analyst.md) — Analyze module boundaries, coupling,
  dependency direction, abstractions, and duplication.
- [`system-architect`](../../han-core/docs/agents/system-architect.md) — Synthesize boundary-crossing findings into
  context-map relationships, integration patterns, data ownership, and failure-domain containment across services.
- [`test-engineer`](../../han-core/docs/agents/test-engineer.md) — Plan tests focused on observable behavior and
  recommend test doubles for isolation, producing a prioritized test plan.
- [`user-experience-designer`](../../han-core/docs/agents/user-experience-designer.md) — Review a UI adversarially
  against Nielsen's heuristics, WCAG 2.2, universal design, and dark-pattern detection.

## Adding an agent?

See [Contributing](../../CONTRIBUTING.md) and [the agent template](../templates/agent-long-form-template.md). Add the
agent's long-form doc under its plugin's `docs/agents/`, a scent line to that plugin's README, and one alphabetized entry
here, reusing the long-form doc's summary line as the canonical scent so the three do not drift.
