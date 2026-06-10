# /architectural-analysis

Operator documentation for the `/architectural-analysis` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.core/skills/architectural-analysis/SKILL.md`](../../../han.core/skills/architectural-analysis/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Sizing](../../sizing.md)

## TL;DR

- **What it does.** Deep architectural analysis of a specified module, directory, or feature area: coupling, data flow, concurrency, risk, and SOLID alignment, plus security, data, and operational structure when the focus area touches them.
- **When to use it.** You want to assess the architecture, design quality, coupling, or technical debt of an existing part of the codebase. Before refactoring, during review, or to inform a decision.
- **What you get back.** A unified report. A spine of four agents always runs (structural, behavioral, risk, software-architecture synthesis). Additional specialists join the roster only when the focus area's signals call for them, and the roster scales with the [size](../../sizing.md).

## Key concepts

- **A focus area is required.** The skill must be pointed at a specific module, directory, or feature. *"Analyze the whole codebase"* is not a valid input. The skill asks you to narrow it before proceeding.
- **The synthesis spine always runs.** `structural-analyst` and `behavioral-analyst` analyze the focus area in parallel, `risk-analyst` scores their findings, and `software-architect` synthesizes intra-codebase recommendations. These four run at every size because structure, runtime behavior, risk of inaction, and SOLID synthesis are the irreducible core of an architectural read.
- **Specialists are signal-selected.** `concurrency-analyst` joins when the code uses concurrency primitives. `adversarial-security-analyst`, `data-engineer`, and `devops-engineer` join when the focus area touches auth/PII, schemas/data contracts, or operational surface. `on-call-engineer` joins when application source in the focus area shows on-call resilience signal (outbound calls, retry logic, queue/buffer handling, async/await code, error handling on production paths, idempotency surfaces). `codebase-explorer` joins for large, unfamiliar areas. `system-architect` joins at large size when the focus area crosses a service or bounded-context seam. An agent whose domain the code does not touch is not dispatched, because that only burns tokens and dilutes the report.
- **The roster scales with size.** Small runs the spine plus concurrency. Medium adds one or two of the security, data, DevOps, and on-call specialists by signal. Large adds the rest, the codebase map, and the system architect when a cross-service seam is present. The skill defaults to small and announces the chosen size and roster, with a one-line justification, before dispatching.
- **Numbered findings.** Each analyst returns findings with its own prefix: `S#` structural, `B#` behavioral, `C#` concurrency, `SEC-###` security, `DOR-###` DevOps, `OCE-###` on-call, `R#` risk, `A#` software-architecture, `SA#` system-architecture. Cross-references survive into the recommendations so every proposed change traces to the finding that drove it.
- **Recommendations, not refactors.** The skill does not modify code. `software-architect` (and `system-architect` when dispatched) produce pseudocode sketches for proposed modules, interfaces, and boundaries. Implementation is a separate step.
- **The report is template-driven.** The output structure lives in [`references/architectural-analysis-report-template.md`](../../../han.core/skills/architectural-analysis/references/architectural-analysis-report-template.md). Sections whose agent was not dispatched are removed from the rendered report rather than left empty.

## When to use it

**Invoke when:**

- A module or subsystem has grown organically and you want a principled baseline before refactoring.
- You are about to commit to a significant rewrite and want independent structural, behavioral, and concurrency analysis feeding the decision.
- Coupling, cohesion, or dependency direction feels wrong but you cannot point to the specific finding. The skill surfaces them concretely.
- A suspected concurrency issue exists somewhere in a module and needs multi-angle analysis (data flow plus shared state plus async handling) in one pass.
- You want SOLID-alignment recommendations with pseudocode sketches rather than prose generalities.
- A specialist (`devops-engineer`, `data-engineer`, a security analyst) has flagged an architectural concern but you want the architectural analysis done independently and cross-referenced.

**Do not invoke for:**

- **Investigating a specific bug.** Use [`/investigate`](./investigate.md) for evidence-based root-cause work.
- **File-level correctness review.** Use [`/code-review`](./code-review.md) for per-file correctness, testing, and compliance.
- **Test planning.** Use [`/test-planning`](./test-planning.md) for a coverage-and-edge-case plan.
- **Creating new project structures or scaffolding.** This skill analyzes existing code. It does not design from scratch.
- **Documenting an existing module.** Use [`/project-documentation`](./project-documentation.md).
- **Architectural decision records.** Use [`/architectural-decision-record`](./architectural-decision-record.md) to capture a decision the architectural analysis motivated.
- **Researching options or prior art.** Use [`/research`](./research.md) when the question is "what are the options" or "how does X work", not "is this existing module sound".

## How to invoke it

Run `/architectural-analysis` in Claude Code with a focus area.

Give it:

1. **A focus area (required).** A module directory, a specific subsystem, or a set of related files. If you run the skill without a focus area, it asks you to specify one before proceeding.
2. **A size, optional.** Pass `small`, `medium`, or `large` as the first positional argument to override the auto-classification. The skill still selects specialists by signal, so a `large` override does not dispatch agents whose domain the code never touches.
3. **A driving concern, optional.** *"I suspect the auth service's session handling has a race,"* or *"we want to split this module and need to see where the coupling lives first."* The concern biases every dispatched specialist's attention without narrowing their scope.

Example prompts:

- `/architectural-analysis src/auth/`. Auto-classify and analyze the auth module.
- `/architectural-analysis large packages/billing/`. Force a large run before splitting the billing package into two services.
- `/architectural-analysis`. *"Evaluate the coupling and cohesion of the payment processing system."*
- `/architectural-analysis`. *"Check for architectural smells in the notification subsystem, particularly concurrency patterns around the retry queue."*

## Sizing

Size sets how many specialists join the spine and how aggressively each agent calibrates its findings. The skill defaults to small and only escalates when concrete signals require it.

| Size | Scope signals | Roster |
|---|---|---|
| **Small** *(default)* | A single module or directory. No security, data, DevOps, or system-seam signal. Concurrency may or may not be present. | The spine (`structural-analyst`, `behavioral-analyst`, then `risk-analyst`, then `software-architect`) plus `concurrency-analyst` when concurrency primitives are present. 3–4 agents. Analysts escalate only the clearest high-impact findings. |
| **Medium** | Two or three adjacent subsystems, or exactly one cross-cutting concern (one auth surface, one data contract, or one operational surface). | The spine plus one or two of `adversarial-security-analyst` / `data-engineer` / `devops-engineer` whose signals fire, plus `concurrency-analyst` when present. 4–6 agents. Analysts surface high- and medium-impact findings. |
| **Large** | More than roughly a dozen files across multiple subsystems, two or more cross-cutting concerns together, a cross-service or bounded-context seam, or you explicitly request it. | The spine plus every signalled specialist, `codebase-explorer` when the area is large and unfamiliar, and `system-architect` when a system-seam signal is present. 6–9 agents. Analysts surface the full finding set. |

How the size is chosen:

- **Default to small.** Unless the focus area's signals push it into medium or large, the skill stays at small. Borderline signals stay at the smaller band.
- **Signal-selected roster.** A specialist is dispatched only when the focus area actually exercises its domain. Larger sizes do not force agents whose signals are absent. They only raise the cap and widen what each agent escalates.
- **Calibration directive.** Every dispatched agent receives a directive scoped to the size. The smaller the size, the narrower the severity bands the agent escalates, and the more aggressively benign-outcome concerns are dropped.

How to override the size:

- Pass `small`, `medium`, or `large` as the first positional argument: `/architectural-analysis medium src/auth/`.
- When the size is overridden, the skill announces the override and uses the chosen band for the roster cap and the calibration directive. Specialists are still selected by signal.
- Conversational overrides (*"run this as a large analysis"*) work as well and are equivalent.

For the cross-skill sizing model and design principles, see [Sizing](../../sizing.md).

## What you get back

A unified report presented in-channel, rendered from [`references/architectural-analysis-report-template.md`](../../../han.core/skills/architectural-analysis/references/architectural-analysis-report-template.md). Sections whose agent was not dispatched are removed, not left empty. The full set:

- **Executive Summary.** The focus area and chosen size, the three to five most critical findings across dispatched dimensions, the highest-impact recommendations, and an explicit note on any dimension that was clean or any signalled domain the band cap omitted. This is the only synthesized prose.
- **Structural Analysis.** Verbatim `structural-analyst` output. `S#` findings on module boundaries, coupling, dependency direction, abstractions, and duplication.
- **Behavioral Analysis.** Verbatim `behavioral-analyst` output. `B#` findings on data flow, error propagation, state management, and integration boundaries.
- **Concurrency Analysis** *(when concurrency primitives are present).* Verbatim `concurrency-analyst` output. `C#` findings, or its explicit "no concurrency patterns found" statement carried verbatim.
- **Security Analysis** *(when the security signal fires).* Verbatim `adversarial-security-analyst` output. `SEC-###` findings, each with a demonstrated exploit path or CVE reference.
- **Data-Engineering Analysis** *(when the data signal fires).* Verbatim `data-engineer` output on schema, migrations, access patterns, and data contracts.
- **DevOps Readiness** *(when the DevOps signal fires).* Verbatim `devops-engineer` output. `DOR-###` findings on operability, rollout, observability, and scale.
- **Codebase Map** *(large, unfamiliar areas).* Verbatim `codebase-explorer` output: the discovery map the analysts and architects worked from.
- **Risk Assessment.** Verbatim `risk-analyst` output. `R#` items scoring the `S`/`B`/`C` findings by likelihood, severity, blast radius, and reversibility.
- **Software-Architecture Recommendations.** Verbatim `software-architect` output. `A#` recommendations aligned with high cohesion, loose coupling, and SOLID, with pseudocode sketches, each tracing back to the findings that drove it.
- **System-Architecture Recommendations** *(when `system-architect` was dispatched).* Verbatim `system-architect` output. `SA#` cross-service / bounded-context recommendations and a context-map sketch.
- **System-level concerns deferred** *(when `system-architect` was not dispatched).* The boundary-crossing findings `software-architect` flagged as out of its altitude, with a note that you can dispatch `system-architect` separately or re-run at large size.

Every finding is tied to a specific file. Every recommendation traces to one or more findings. If a dimension is genuinely clear (no concurrency in a pure-functional module), the skill reports that. It does not fabricate findings to fill space.

## How to get the most out of it

- **Scope narrowly.** Analyzing a single module pays off. Analyzing "the whole codebase" flattens into shallow findings. If you have a large area, split it and run the skill on each subsystem.
- **Name the driving concern.** *"Concurrency around the retry queue"* focuses every dispatched specialist without constraining their analyses.
- **Trust the default size, override when you know better.** Auto-classification is conservative by design. If you already know the focus area crosses a service seam or carries a security surface, pass `large` so the right specialists join on the first run.
- **Run `/project-discovery` first.** The skill uses project config (CLAUDE.md, project-discovery.md) to resolve conventions. Without discovery, the analysts fall back to surrounding-code inference.
- **Pair with `/architectural-decision-record`.** The recommendations often capture architectural decisions worth recording. Run `/architectural-decision-record` next to capture the rationale, alternatives considered, and the decision made.
- **Pair with `/investigate`** if an analyst finding reveals a concrete runtime bug worth rooting out.
- **Pair with `/iterative-plan-review`** after you draft the refactoring plan. The architectural analysis produces recommendations; the plan review stress-tests the plan that implements them.
- **Re-run after structural changes.** If you split a module or extract a service, re-run the skill against the new boundaries. Coupling and duplication findings frequently migrate, and the signal set that selects the roster may change with them.

## Cost and latency

The skill dispatches a variable roster. A small run is the spine of four agents (`structural-analyst` and `behavioral-analyst` in parallel, then `risk-analyst`, then `software-architect`), plus `concurrency-analyst` when concurrency is present. A large run can reach nine agents. The discovery wave runs in parallel; `risk-analyst` runs next consuming the `S`/`B`/`C` findings; `software-architect` (and `system-architect` when on the roster) run last consuming all upstream output. `software-architect` and `system-architect` run on Opus; the discovery and risk analysts run on Sonnet. For a medium-size module (a few thousand lines), expect a few minutes for the parallel pass plus sequential time for risk and synthesis. The skill is built for infrequent high-signal runs (refactoring decisions, architectural check-ins, pre-rewrite baselines), not for tight-loop iteration. It is a single fan-out / fan-in pass with no iteration round. If a band proves too small, re-run at a larger size.

## In more detail

The skill walks an eight-step process:

1. **Validate the focus area and resolve project context.** Bind `$size` if it was passed. Confirm the focus area resolves to real files and identify its boundary. Read CLAUDE.md / project-discovery.md for conventions. Note git availability. If the focus area does not resolve, stop and ask you to clarify.
2. **Detect signals and classify size.** Grep and Glob the focus area for concurrency, security, data, DevOps, and system-seam signals. Default to small and escalate only on clear higher-band signals. A passed `$size` overrides the classification but not the signal-based specialist selection.
3. **Build the roster and announce it.** Assemble the spine plus the signalled specialists within the band cap, and state the size, roster, and per-specialist justification in one line before dispatching. The analysis is read-only, so there is no blocking gate.
4. **Dispatch the discovery wave in parallel.** `structural-analyst`, `behavioral-analyst`, and any signalled discovery specialists run concurrently, each with a brief carrying the focus area, the driving concern, project conventions, git availability, and a size-scoped calibration directive.
5. **Compile the discovery findings.** Collect verbatim output from every discovery agent, preserving every numbered item and prefix. A "no concurrency patterns found" result is kept verbatim.
6. **Dispatch the risk analyst.** Pass `risk-analyst` the verbatim `S`/`B`/`C` findings (its documented input contract). It produces `R#` items cross-referencing the upstream findings.
7. **Dispatch the synthesis architects.** `software-architect` always runs, consuming all discovery output plus the `R#` items. `system-architect` runs only when it is on the roster, consuming the same plus the DevOps and data findings as its documented optional inputs.
8. **Render and present the report.** Read the template, fill it, drop the sections whose agent was not dispatched, write the Executive Summary last, and present the report in-channel with a short closing summary of size, roster, finding counts, and open items.

## Sources

The skill's protocols are grounded in established architectural analysis and synthesis practice.

### Robert C. Martin: Clean Architecture and SOLID

Martin's SOLID principles (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion) and the dependency rule of Clean Architecture are the citable framework for `software-architect`'s recommendations. Every proposed interface or boundary references the SOLID principle it upholds.

URL: https://cleancoders.com/

### Gregor Hohpe: Enterprise Integration Patterns

Hohpe and Woolf's catalogue of integration patterns (Message Channel, Router, Translator, Endpoint) frames the behavioral-analyst's integration-boundary findings. When the skill recommends an integration change, it names the pattern being introduced or replaced.

URL: https://www.enterpriseintegrationpatterns.com/

### Doug Lea: Concurrent Programming in Java

Lea's *Concurrent Programming in Java* established the taxonomy for shared-state concurrency hazards: races, deadlocks, starvation, live-lock, priority inversion. The concurrency-analyst names the specific hazard class in every finding.

URL: https://gee.cs.oswego.edu/dl/cpj/

### Sam Newman: Building Microservices

Newman's work on service boundaries, bounded contexts, and distributed-system failure modes informs the structural-analyst's module-boundary and coupling findings when the focus area crosses services.

URL: https://samnewman.io/books/building_microservices_2nd_edition/

### Eric Evans: Domain-Driven Design

Evans's ubiquitous-language and bounded-context framings are cited when a structural finding turns on a domain-model boundary. Tactical DDD patterns (aggregate, entity, value object, repository) appear in `software-architect` recommendations inside a single context. Strategic DDD patterns (context maps, integration relationships) appear in `system-architect` recommendations when the focus area crosses a context seam.

URL: https://www.domainlanguage.com/ddd/

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [Sizing](../../sizing.md). The small / medium / large dispatch model this skill shares with the other swarming skills.
- [`structural-analyst`](../../agents/han.core/structural-analyst.md), [`behavioral-analyst`](../../agents/han.core/behavioral-analyst.md), [`concurrency-analyst`](../../agents/han.core/concurrency-analyst.md). The discovery analysts.
- [`adversarial-security-analyst`](../../agents/han.core/adversarial-security-analyst.md), [`data-engineer`](../../agents/han.core/data-engineer.md), [`devops-engineer`](../../agents/han.core/devops-engineer.md), [`on-call-engineer`](../../agents/han.core/on-call-engineer.md), [`codebase-explorer`](../../agents/han.core/codebase-explorer.md). The signal-selected specialists added at medium and large.
- [`risk-analyst`](../../agents/han.core/risk-analyst.md). The agent that scores the analysts' findings by likelihood, severity, blast radius, and reversibility.
- [`software-architect`](../../agents/han.core/software-architect.md). The adversarial synthesis agent that produces intra-codebase recommendations and pseudocode sketches (always dispatched by this skill).
- [`system-architect`](../../agents/han.core/system-architect.md). The adversarial synthesis agent that produces cross-service / bounded-context recommendations (dispatched at large size when a system-seam signal is present; otherwise dispatch separately).
- [`/architectural-decision-record`](./architectural-decision-record.md). Record the architectural decisions the analysis motivates.
- [`/investigate`](./investigate.md). Run when a finding reveals a concrete runtime bug.
- [`/iterative-plan-review`](./iterative-plan-review.md). Stress-test the refactoring plan that implements the recommendations.
- [`SKILL.md` for /architectural-analysis](../../../han.core/skills/architectural-analysis/SKILL.md). The internal process definition.
