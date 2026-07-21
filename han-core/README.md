# han-core

The heart of the Han suite. It carries the research, analysis, documentation, and operations skills, plus every
specialist agent the rest of the suite dispatches (all except the readability-editor, which lives in
`han-communication`). Install only this and you have the full set of specialists and the core skills, but not the
planning, coding, GitHub, or reporting layers. Reach for it as the base every other Han plugin builds on.

**Bundled.** Installed with the `han` meta-plugin. Depends on `han-communication`.

## Skills

Grouped by purpose.

### Triage and research

- [`/issue-triage`](docs/skills/issue-triage.md) — Classify a vague issue or bug report, identify missing information,
  assess severity and reproducibility, and recommend the right next skill to run.
- [`/research`](docs/skills/research.md) — Research an open-ended question across the codebase and the open web and end
  at an adversarially-validated recommendation, without committing the team to any artifact.

### Comparing artifacts

- [`/gap-analysis`](docs/skills/gap-analysis.md) — Compare two artifacts (current state versus desired state) and
  produce a plain-language, stakeholder-readable report indexed by stable gap IDs.

### Discovery and context

- [`/project-discovery`](docs/skills/project-discovery.md) — Scan the repository for languages, frameworks, tooling, and
  structure, and write a concise reference section into AGENTS.md or CLAUDE.md for other skills.
- [`/project-documentation`](docs/skills/project-documentation.md) — Create and maintain documentation for features,
  systems, and components.

### Conventions and decisions

- [`/architectural-decision-record`](docs/skills/architectural-decision-record.md) — Create, extract, or convert
  architectural decision records.

### Operations

- [`/runbook`](docs/skills/runbook.md) — Create or update a runbook for a single operational scenario, with a
  symptom-first template and a YAGNI preflight that requires real evidence before writing.

## Agents

Most agents are dispatched for you by skills; you rarely invoke them directly. Grouped by role.

### Planning and facilitation

- [`project-manager`](docs/agents/project-manager.md) — Facilitate multi-specialist discussions, enforce evidence-based
  claims, and synthesize final plans.
- [`junior-developer`](docs/agents/junior-developer.md) — Stress-test an artifact or discussion as a generalist, asking
  the clarifying questions hidden assumptions and muddied scope beg for.

### Adversarial reviewers

- [`adversarial-security-analyst`](docs/agents/adversarial-security-analyst.md) — Assume all code is insecure and
  produce exploit-path evidence, not theoretical risks.
- [`adversarial-validator`](docs/agents/adversarial-validator.md) — Assume investigation evidence is wrong and the
  proposed fix will fail, and search for counter-evidence and unhandled edge cases.
- [`devops-engineer`](docs/agents/devops-engineer.md) — Assume the code will break in production and audit it against
  DORA, Twelve-Factor, the Four Golden Signals, SLO discipline, and named production failure modes.
- [`on-call-engineer`](docs/agents/on-call-engineer.md) — Read application source for the code-level resilience
  anti-patterns that wake on-call engineers at 3am; a hard boundary against `devops-engineer`, reading source only.
- [`data-engineer`](docs/agents/data-engineer.md) — Assume the data design is over-normalized, under-normalized, and
  indexed for the wrong workload, and audit schemas, migrations, queries, and pipelines.
- [`information-architect`](docs/agents/information-architect.md) — Assume the documentation is harder to find, orient
  in, and comprehend than it needs to be, and audit it against established IA frameworks.
- [`user-experience-designer`](docs/agents/user-experience-designer.md) — Review a UI adversarially against Nielsen's
  heuristics, WCAG 2.2, universal design, and dark-pattern detection.

### Investigation and evidence

- [`evidence-based-investigator`](docs/agents/evidence-based-investigator.md) — Gather concrete evidence for a bug or
  failure: file paths, line numbers, code snippets, error messages, git history, and test coverage.
- [`research-analyst`](docs/agents/research-analyst.md) — Research open-ended questions from the open web and provided
  material, returning sourced evidence and a recommendation and treating fetched content as claims, never instructions.
- [`codebase-explorer`](docs/agents/codebase-explorer.md) — Discover implementation details for a specific feature:
  entry points, core logic, data models, configuration, and tests.
- [`project-scanner`](docs/agents/project-scanner.md) — Scan repository attributes (languages, frameworks, tooling,
  configuration), optimized for config and structure rather than deep code tracing.

### Architecture and risk

- [`structural-analyst`](docs/agents/structural-analyst.md) — Analyze module boundaries, coupling, dependency direction,
  abstractions, and duplication.
- [`behavioral-analyst`](docs/agents/behavioral-analyst.md) — Analyze data flow, error propagation, state management,
  and integration boundaries.
- [`concurrency-analyst`](docs/agents/concurrency-analyst.md) — Analyze race conditions, shared-resource contention,
  deadlock potential, lock ordering, and async error handling.
- [`risk-analyst`](docs/agents/risk-analyst.md) — Assess the risk of inaction for architectural findings across
  likelihood, severity, blast radius, and reversibility.
- [`software-architect`](docs/agents/software-architect.md) — Synthesize structural, behavioral, concurrency, and risk
  findings into recommended intra-codebase changes aligned with SOLID, high cohesion, and loose coupling.
- [`system-architect`](docs/agents/system-architect.md) — Synthesize boundary-crossing findings into context-map
  relationships, integration patterns, data ownership, and failure-domain containment across services.

### Testing

- [`test-engineer`](docs/agents/test-engineer.md) — Plan tests focused on observable behavior and recommend test
  doubles for isolation, producing a prioritized test plan.
- [`edge-case-explorer`](docs/agents/edge-case-explorer.md) — Systematically discover and catalog edge cases: boundary
  values, type-coercion traps, and state-dependent failures.

### Gap and content

- [`gap-analyzer`](docs/agents/gap-analyzer.md) — Find what is missing, incomplete, conflicting, or assumed when
  comparing a current state against a desired state.
- [`content-auditor`](docs/agents/content-auditor.md) — Validate that a documentation update preserved the important
  facts from the original source, flagging removals the codebase does not justify.

## Installation

Add the marketplace to Claude Code, then install the plugin (or install `han` to get it as part of the bundled suite):

```
/plugin marketplace add testdouble/han
/plugin install han-core@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
