# Decision Log: han-core Restructure

This file records every decision settled while specifying the han-core restructure. Behavioral statements live in
[../feature-specification.md](../feature-specification.md); this file captures the history, rationale, evidence, and
rejected alternatives. Evidence IDs (E1-E14) and validation IDs (V1-V6) refer to the investigation report at
[../investigation.md](../investigation.md). Trust class for the investigation is **provided** (user-directed source);
trust class for repo checks made during specification is **codebase**.

## Trivial decisions

- D10: Documentation follows the plugin-first convention — moved skills' long-form docs move into their new plugins'
  `docs/skills/`, indexes stay complete, scent lines link to the new homes, and the marketplace catalog lists both new
  plugins (per the repo's documented documentation conventions in CLAUDE.md and investigation E14, V3, V4). —
  Referenced in spec: Primary Flow.
- D11: No version bumps in this change — no plugin version number changes as part of the restructure (investigation
  directive and standing user instruction; versioning belongs to the release process). — Referenced in spec: Primary
  Flow, Out of Scope.

## Full decisions

### D1: Split han-core along the agents-versus-skills line

- **Question:** How should han-core's footprint be reduced when plugin dependencies are whole-plugin only?
- **Decision:** Keep the shared specialist-agent roster in han-core and move the topical leaf skills out into new
  plugins.
- **Rationale:** The roster is the genuinely shared part: han-planning dispatches 21 of 23 agents and han-coding 17,
  so splitting the roster would duplicate most of it. Six of the seven skills have zero cross-plugin invocations, so
  moving them breaks almost nothing.
- **Evidence:** Investigation E1, E2, E8, E13 (provided; grounded in cited codebase locations).
- **Rejected alternatives:**
  - Split the roster between han-planning and han-coding — rejected because their dispatch sets overlap heavily and
    the union covers nearly every agent (E1, E2).
  - Do nothing — rejected because the user described the footprint pain directly (problem statement in the
    investigation).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D2, D3, D4, D5
- **Referenced in spec:** Outcome

### D2: Two new plugins rather than folding into han-planning

- **Question:** Where do the six moved skills land?
- **Decision:** Create han-documentation (project-documentation, architectural-decision-record, runbook) and
  han-research (research, gap-analysis, issue-triage), each depending on han-communication and han-core.
- **Rationale:** The two groups have distinct scent lines: documentation authoring versus pre-planning knowledge work.
  Folding the knowledge skills into han-planning would stretch its "planning before implementation" scope and cost
  han-coding-only users the issue-triage handoff its refactor skill recommends. The investigation rates this grouping
  Medium confidence as a judgment call; the specification adopts its recommendation.
- **Evidence:** Investigation E8, E11 and its Planned Restructure alternative analysis (provided).
- **Rejected alternatives:**
  - Fold research, gap-analysis, and issue-triage into han-planning — rejected because it stretches han-planning's
    scope statement and breaks the issue-triage handoff for han-coding-only users.
  - One combined new plugin for all six skills — rejected because a single plugin mixing documentation authoring with
    research work has no honest scent line, recreating the mixed-role problem being fixed.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D4, D7, D8
- **Referenced in spec:** Primary Flow

### D3: project-discovery and project-scanner stay in han-core

- **Question:** Does the project-discovery skill move with the other skills?
- **Decision:** project-discovery and its single-consumer project-scanner agent stay in han-core.
- **Rationale:** Its output file is suite bootstrap: 13 skills across three plugins probe the user's repository for
  the file by name. Because consumers never invoke the skill or reference its plugin path, its home is functionally
  free, and han-core is the right home for suite-wide bootstrap.
- **Evidence:** Investigation E9, E10 (provided).
- **Rejected alternatives:**
  - Move it to han-research with the other knowledge skills — rejected because it is bootstrap infrastructure serving
    three plugins, not topical research work.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D4: research-analyst moves, gap-analyzer stays

- **Question:** Which agents move with their skills?
- **Decision:** research-analyst moves to han-research with the research skill; every other agent, including
  gap-analyzer, stays in han-core.
- **Rationale:** research-analyst has exactly one dispatch site, inside the research skill. gap-analyzer initially
  looked single-consumer but validation found conditional dispatches from two han-planning skills, which pin it to the
  shared roster.
- **Evidence:** Investigation E10 and validation V1 (provided).
- **Rejected alternatives:**
  - Move gap-analyzer to han-research with gap-analysis — rejected because han-planning skills dispatch it when a
    source spec exists (V1).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D5: Drop the vestigial han-core dependencies

- **Question:** What happens to dependents that declare han-core but use nothing from it?
- **Decision:** han-reporting, han-feedback, and han-linear each remove han-core from their dependencies, and the
  han-reporting README claim about dispatching shared han-core agents is corrected.
- **Rationale:** Repo-wide searches found zero functional usage in all three: han-reporting has no dispatch site
  behind its README claim, han-feedback's mentions are namespace-parsing examples, and han-linear has no reference at
  all. Validation counter-checks confirmed no hidden dispatches.
- **Evidence:** Investigation E4, E5, E6 and validation V6 (provided).
- **Rejected alternatives:**
  - Keep the dependencies for safety — rejected because each one installs 23 agents and 7 skills for nothing, which is
    the exact pain being fixed.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D6
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States

### D6: han-feedback and han-linear gain no han-communication dependency

- **Question:** When han-core is removed, should han-feedback or han-linear pick up han-communication?
- **Decision:** Neither gains the dependency; both end with no Han dependencies.
- **Rationale:** A search across both plugins' skills and reference files found zero references to the readability
  standard, the readability-guidance skill, or the readability-editor agent. With no usage, the dependency fails the
  YAGNI evidence test and is deferred with a reopen trigger.
- **Evidence:** Codebase — repo-wide grep for "readability" and "han-communication" across `han-feedback/skills/` and
  `han-linear/skills/` returned no matches (specification-time check). This closes the investigation's open question.
- **Rejected alternatives:**
  - Add han-communication to han-feedback because its skill produces reader-facing output — rejected because the skill
    does not source the standard today; adding the dependency without usage is speculative.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Deferred (YAGNI)

### D7: han-atlassian adds han-documentation and keeps direct han-core

- **Question:** How does han-atlassian keep its project-documentation wrapper working, and does it still need direct
  han-core?
- **Decision:** han-atlassian adds han-documentation to its dependencies and updates its wrapper invocation to the new
  namespace; it keeps its direct han-core dependency.
- **Rationale:** The wrapper's invocation is the only cross-plugin skill call into old han-core, so it must follow the
  moved skill. The investigation suggested dropping direct han-core only if the resolver treats transitive
  dependencies as installed; that resolver behavior is unverified (OI-1), so the explicit dependency stays as the safe
  and honest declaration.
- **Evidence:** Investigation E7 (provided); resolver behavior unverified, labeled as a no-evidence state per the
  evidence rule and tracked as OI-1.
- **Rejected alternatives:**
  - Drop direct han-core and rely on transitive resolution through han-planning and han-coding — rejected because the
    resolver's transitive behavior is unverified and the explicit declaration costs nothing.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D8: Both new plugins are bundled by the han meta-plugin

- **Question:** Are han-documentation and han-research bundled or opt-in?
- **Decision:** Both join the han meta-plugin's dependency list.
- **Rationale:** Every moved skill is bundled today through han-core. Leaving the new plugins opt-in would silently
  remove six skills from full-suite users on upgrade, breaking the outcome commitment that meta-plugin users keep
  everything they have.
- **Evidence:** Current meta-plugin dependency list (codebase) and investigation target shape (provided).
- **Rejected alternatives:**
  - Ship the new plugins opt-in like han-atlassian and han-linear — rejected because it removes currently-bundled
    capability on upgrade.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Coordinations

### D9: Names are stable, namespaces change

- **Question:** Do any skills or agents get renamed, and what happens to existing invocation forms?
- **Decision:** Every skill and agent keeps its name. Bare-name invocations and boundary disclaimers keep working; the
  namespaced forms for moved skills change to their new plugin prefix (for example `han-core:research` becomes
  `han-research:research`).
- **Rationale:** A duplicate-name scan across every plugin's skills directory found no collisions, so bare names stay
  unambiguous. The namespace change is unavoidable given the move and is surfaced through release notes (OI-2).
- **Evidence:** Investigation validation V5 (provided; scan result).
- **Rejected alternatives:**
  - Rename moved skills to carry their new plugin identity — rejected because nothing forces a rename and renames
    would break bare-name references that work today.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes
