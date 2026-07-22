# Decision Log: han-core Restructure

This file records every decision settled while specifying the han-core restructure. Behavioral statements live in
[../feature-specification.md](../feature-specification.md); this file captures the history, rationale, evidence, and
rejected alternatives. Evidence IDs (E1-E14) and validation IDs (V1-V6) refer to the investigation report at
[../investigation.md](../investigation.md). Trust class for the investigation is **provided** (user-directed source);
trust class for repo checks made during specification is **codebase**. F# IDs refer to
[team-findings.md](team-findings.md).

## Trivial decisions

- D11: No version bumps in this change — no plugin version number changes as part of the restructure (investigation
  directive and standing user instruction; versioning belongs to the release process). The recovery consequence of
  shipping without a version boundary is handled by D13's catalog-revert commitment. — Referenced in spec: Primary
  Flow, Out of Scope.

## Full decisions

### D1: Split han-core along the agents-versus-skills line

- **Question:** How should han-core's footprint be reduced when plugin dependencies are whole-plugin only?
- **Decision:** Keep the shared specialist-agent roster in han-core and move the topical leaf skills out into new
  plugins.
- **Rationale:** The roster is the genuinely shared part: han-planning and han-coding each dispatch most of it, so
  splitting the roster would duplicate most of it. Six of the seven skills have zero cross-plugin invocations, so
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
  han-research (research, gap-analysis, issue-triage), each depending on han-communication and han-core. han-research
  presents itself as pre-planning knowledge work so all three of its skills are predictable from its scent line.
- **Rationale:** The two groups have distinct scent lines: documentation authoring versus pre-planning knowledge work.
  Folding the knowledge skills into han-planning would stretch its "planning before implementation" scope and cost
  han-coding-only users the issue-triage handoff its refactor skill recommends. Review finding F6 challenged the
  two-plugin grouping as a YAGNI candidate (one plugin is strictly simpler); it survives because purpose-grouped
  plugins with honest scent lines are a documented project convention, not taste — the repository's project map
  describes every plugin by a single coherent purpose. F3 established that the handoff cost cited against the fold
  alternative also applies to the chosen shape for partial installs; that consequence is accepted and surfaced under
  D12 rather than hidden. F7 drove the scent-line framing commitment for han-research.
- **Evidence:** Investigation E8, E11 and its Planned Restructure alternative analysis (provided); the repository
  project map's per-plugin purpose descriptions (codebase).
- **Rejected alternatives:**
  - Fold research, gap-analysis, and issue-triage into han-planning — rejected because it stretches han-planning's
    scope statement and breaks the issue-triage handoff for han-coding-only users.
  - One combined new plugin for all six skills — rejected because a single plugin mixing documentation authoring with
    research work has no honest scent line, recreating the mixed-role problem being fixed; kept on record as the
    strictly simpler fallback if the maintainers overrule the scent-line rationale (F6).
- **Linked technical notes:** —
- **Driven by findings:** F3, F6, F7
- **Dependent decisions:** D4, D7, D8, D12
- **Referenced in spec:** Primary Flow

### D3: project-discovery and project-scanner stay in han-core

- **Question:** Does the project-discovery skill move with the other skills?
- **Decision:** project-discovery and its single-consumer project-scanner agent stay in han-core.
- **Rationale:** Its output file is suite bootstrap: skills across three plugins probe the user's repository for the
  file by name. Because consumers never invoke the skill or reference its plugin path, its home is functionally free,
  and han-core is the right home for suite-wide bootstrap.
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
  - Keep the dependencies for safety — rejected because each one installs the full agent roster and skill set for
    nothing, which is the exact pain being fixed.
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
  moved skill. The direct han-core dependency is not vestigial like D5's three: the skills han-atlassian wraps
  genuinely dispatch han-core's shared agents. The investigation suggested dropping it only if the resolver treats
  transitive dependencies as installed; that resolver behavior is unverified (OI-1), so the explicit dependency stays
  as the safe and honest declaration. F11 drove stating the vestigial-versus-genuine distinction on the spec's face.
- **Evidence:** Investigation E7 (provided); resolver behavior unverified, labeled as a no-evidence state per the
  evidence rule and tracked as OI-1.
- **Rejected alternatives:**
  - Drop direct han-core and rely on transitive resolution through han-planning and han-coding — rejected because the
    resolver's transitive behavior is unverified and the explicit declaration costs nothing.
- **Linked technical notes:** —
- **Driven by findings:** F11
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D8: Both new plugins are bundled by the han meta-plugin

- **Question:** Are han-documentation and han-research bundled or opt-in?
- **Decision:** Both join the han meta-plugin's dependency list.
- **Rationale:** Every moved skill is bundled today through han-core. Leaving the new plugins opt-in would silently
  remove six skills from full-suite users on upgrade, breaking the outcome commitment that meta-plugin users keep
  everything they have. F2 established that this bundling protects only meta-plugin users; the standalone-han-core
  upgrade shape is handled separately under D12 and verified under D13.
- **Evidence:** Current meta-plugin dependency list (codebase) and investigation target shape (provided).
- **Rejected alternatives:**
  - Ship the new plugins opt-in like han-atlassian and han-linear — rejected because it removes currently-bundled
    capability on upgrade.
- **Linked technical notes:** —
- **Driven by findings:** F2
- **Dependent decisions:** D12
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Coordinations

### D9: Names are stable, namespaces change

- **Question:** Do any skills or agents get renamed, and what happens to existing invocation forms?
- **Decision:** Every skill and agent keeps its name. Bare-name invocations and boundary disclaimers keep resolving to
  a single skill; the namespaced forms for moved skills change to their new plugin prefix (for example
  `han-core:research` becomes `han-research:research`). Suite-wide skill-name uniqueness becomes a standing constraint
  on future plugin work. Every agent dispatch inside a moved skill must resolve at its post-split home.
- **Rationale:** A duplicate-name scan across every plugin's skills directory found no collisions, so bare names stay
  unambiguous; F12 recorded that this uniqueness is now load-bearing. F4 separated uniqueness from availability: a
  bare name can reference a skill the current install does not carry, which D12's release-notes guidance addresses.
  F10 verified the dispatch forms inside the moving skills: every referenced agent stays in han-core except
  research-analyst, whose references move plugins with the research skill and are re-namespaced during
  implementation. The namespace change is unavoidable given the move and is surfaced through release notes (OI-2).
- **Evidence:** Investigation validation V5 (provided; scan result); specification-time search of the moving skills'
  agent references (codebase).
- **Rejected alternatives:**
  - Rename moved skills to carry their new plugin identity — rejected because nothing forces a rename and renames
    would break bare-name references that work today.
- **Linked technical notes:** —
- **Driven by findings:** F4, F10, F12
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### D10: Documentation surfaces are reconciled, corrections included

- **Question:** What must be true of the suite's reader-facing surfaces when the restructure ships?
- **Decision:** Every reader-facing surface is reconciled with the new layout — corrections of stale statements, not
  just additions. That covers: moved skills' long-form docs at their new homes with complete indexes; every
  description of han-core's contents (plugin-choosing guide, han-core's front door, project map, suite catalog);
  every statement of a re-pointed plugin's dependencies; every shared-surface link to a moved skill, the workflows
  map included; the project map's statement of which plugins own agents; and the plugin manifests for every supported
  platform.
- **Rationale:** The original commitment ("name the new plugins, link the new homes") covered only the additive half.
  Review found six surfaces whose current descriptions the split makes false, and a second platform's manifests that
  advertise moving skills. A reader-facing surface that contradicts the release misdirects the exact audiences the
  documentation exists for.
- **Evidence:** Investigation E14, V3, V4 (provided); information-architect findings F1 citing the stale lines in the
  plugin-choosing guide, workflows map, han-core front door, and project map (codebase); gap-analyzer GAP-001 for the
  platform manifests (codebase).
- **Rejected alternatives:**
  - Commit only to naming the new plugins and relinking moved docs — rejected because it leaves false statements on
    the surfaces installers use to choose plugins.
- **Linked technical notes:** —
- **Driven by findings:** F1, F8
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

### D12: Partial installs accept reduced skill availability, with release-notes guidance

- **Question:** What happens to users whose install carried the moved skills only through han-core (standalone
  han-core, or a partial install such as han-coding-only)?
- **Decision:** The reduction is accepted as the feature's purpose, not compensated with new dependencies. The release
  notes name each moved skill, the plugin that now carries it, and the install step that restores it. The
  plugin-choosing guide names which plugin carries each skill so a bare-name reference to an uninstalled skill leads
  the user to the right install.
- **Rationale:** Adding dependencies from han-planning, han-coding, or han-github to the new plugins would rebuild
  the footprint the restructure exists to remove; the user-described goal is a smaller installed surface, and a
  smaller surface means the moved skills are present only where chosen. What the review actually exposed was
  silence: the loss existed in the design but nowhere in the spec. Naming it, and routing affected users through
  release notes and the choosing guide, is the strictly simpler version that satisfies the same evidence.
- **Evidence:** Investigation problem statement (provided; the user-described need is footprint reduction);
  marketplace listing showing han-core independently installable (codebase); devops-engineer F2 and junior-developer
  F3/F4 for the affected install shapes.
- **Rejected alternatives:**
  - Make han-planning and han-coding depend on han-research and han-documentation — rejected because it restores the
    bundled footprint for the largest dependents and negates the restructure's outcome.
  - Leave the consequence unstated — rejected because a silent capability regression on a supported install path is
    the failure mode the review flagged.
- **Linked technical notes:** —
- **Driven by findings:** F2, F3, F4
- **Dependent decisions:** D13
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes, Out of
  Scope

### D13: The release gate verifies every upgrade shape and a recovery path

- **Question:** What makes the restructure safe to release when resolver behavior on upgrade is unverified?
- **Decision:** Release is gated on pre-release verification of every reachable upgrade shape (full `han`, standalone
  han-core, partial such as han-coding-only, and han-atlassian) against an explicit pass condition: after upgrading,
  the invocable skills and dispatchable agents match the spec's commitment for that shape, with no manual
  intervention and no silently missing skill. The same verification confirms the recovery path: reverting the
  suite's catalog and layout to the prior release restores upgraded installs to their pre-restructure working set on
  next resolve. The catalog must never advertise an uninstallable bundled plugin, no dependency list may name a
  plugin absent from the catalog, and a full-suite upgrade is all-or-nothing from the user's perspective or visibly
  signalled.
- **Rationale:** The spec names its own worst failure mode (OI-1: the resolver mishandling the new bundled names) but
  originally committed to a gate with no pass condition, covering one of at least four upgrade shapes, and no stated
  recovery. Because the change ships without version bumps (D11), version pinning is unavailable as a recovery
  lever, so catalog reversibility must be verified, not assumed. All commitments stay at the stated-behavior level;
  no rollout tooling is added, keeping the resolution inside the YAGNI gate.
- **Evidence:** OI-1's own unverified-resolver risk (provided, from the investigation's confidence assessment);
  devops-engineer findings F1/F3/F4/F5 and junior-developer F1/F8 enumerating the uncovered shapes and the missing
  recovery observable.
- **Rejected alternatives:**
  - Ship after verifying only the full-`han` upgrade — rejected because the standalone and han-atlassian shapes fail
    differently and were the least protected.
  - Add rollout tooling (staged release, telemetry) — rejected as YAGNI for a docs-and-manifest change; stated,
    verified behavior is the strictly simpler version.
- **Linked technical notes:** —
- **Driven by findings:** F5
- **Dependent decisions:** —
- **Referenced in spec:** Actors and Triggers, Alternate Flows and States, Edge Cases and Failure Modes, Open Items
