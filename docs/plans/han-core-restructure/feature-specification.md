# Feature Specification: han-core Restructure

Splitting han-core into a lean shared-agent plugin plus two new topical plugins, han-documentation and han-research.
That means depending on han-core no longer installs seven skills most dependents never use. Three plugins that depend
on han-core without using it drop the dependency entirely.

## Outcome

Installing any plugin that depends on han-core installs a much smaller han-core: the shared specialist-agent roster,
the project-discovery skill, and the canonical rule files, with nothing else riding along. Users who install the full
`han` suite keep every skill and agent they have today, now organized so each plugin's name matches what it contains
([D1](artifacts/decision-log.md#d1-split-han-core-along-the-agents-versus-skills-line)). Users who install only an
edge plugin such as han-linear or han-feedback no longer receive the full agent roster and skill set they never invoke
([D5](artifacts/decision-log.md#d5-drop-the-vestigial-han-core-dependencies)). Users on partial installs that relied on
han-core for the moved skills see those skills leave their footprint. That reduction is the feature's purpose. The
release tells them which plugin restores each skill
([D12](artifacts/decision-log.md#d12-partial-installs-accept-reduced-skill-availability-with-release-notes-guidance)).

## Actors and Triggers

- **Actors**
  - **Suite maintainers** carry out the restructure and maintain the resulting plugins.
  - **End users** install, upgrade, and invoke Han plugins through the marketplace and slash commands.
  - **Claude Code sessions** dispatch the shared agents and invoke skills across plugin boundaries at runtime.
- **Triggers**: a user installs or upgrades a Han plugin; a session invokes a skill or dispatches an agent that now
  lives in a different plugin than before.
- **Preconditions**: the restructure lands as one coordinated change. The new plugins exist, the moved skills live in
  their new homes, and every dependency list and documentation surface reflects the new layout before release. The
  same all-or-nothing property must hold for what a user observes. At no point may the suite's catalog advertise a
  bundled plugin that cannot be installed, or a dependency list name a plugin absent from the catalog
  ([D13](artifacts/decision-log.md#d13-the-release-gate-verifies-every-upgrade-shape-and-a-recovery-path)).

## Primary Flow

The restructure produces this target shape. Each numbered item is a behavior the released suite must exhibit.

1. **han-core** contains the shared specialist-agent roster (every current agent except research-analyst), the
   project-discovery skill with its project-scanner agent, and the canonical evidence and YAGNI rule files
   ([D3](artifacts/decision-log.md#d3-project-discovery-and-project-scanner-stay-in-han-core),
   [D4](artifacts/decision-log.md#d4-research-analyst-moves-gap-analyzer-stays)).
2. **han-documentation** (new) contains the project-documentation, architectural-decision-record, and runbook skills,
   and depends on han-communication and han-core
   ([D2](artifacts/decision-log.md#d2-two-new-plugins-rather-than-folding-into-han-planning)).
3. **han-research** (new) contains the research, gap-analysis, and issue-triage skills plus the research-analyst
   agent, and depends on han-communication and han-core. Its reader-facing descriptions frame the plugin as
   pre-planning knowledge work, so all three skills are predictable from its name and scent line
   ([D2](artifacts/decision-log.md#d2-two-new-plugins-rather-than-folding-into-han-planning)).
4. The **han meta-plugin** bundles both new plugins alongside its current six dependencies, so installing `han`
   continues to deliver every skill and agent it delivers today
   ([D8](artifacts/decision-log.md#d8-both-new-plugins-are-bundled-by-the-han-meta-plugin)).
5. **han-reporting, han-feedback, and han-linear** no longer depend on han-core. han-reporting keeps its
   han-communication dependency; han-feedback and han-linear gain no replacement dependency
   ([D5](artifacts/decision-log.md#d5-drop-the-vestigial-han-core-dependencies),
   [D6](artifacts/decision-log.md#d6-han-feedback-and-han-linear-gain-no-han-communication-dependency)).
6. **han-atlassian** depends on han-documentation for its project-documentation wrapper and keeps its direct han-core
   dependency, because the skills it wraps genuinely dispatch han-core's shared agents. That distinguishes it from the
   three dependents whose han-core edges carried no usage at all
   ([D7](artifacts/decision-log.md#d7-han-atlassian-adds-han-documentation-and-keeps-direct-han-core)).
7. **han-github, han-planning, and han-coding** keep their current dependency lists; their installed footprint shrinks
   by the six moved skills. The consequence for partial installs is accepted and surfaced, not hidden: a user with
   only these plugins no longer receives the moved skills
   ([D12](artifacts/decision-log.md#d12-partial-installs-accept-reduced-skill-availability-with-release-notes-guidance)).
8. Every skill and agent keeps its current name. Cross-plugin invocations of the moved skills resolve at their new
   namespaced homes. Bare-name references ("use research") keep resolving to a single skill, because no two
   plugins share a skill name. That uniqueness becomes a standing constraint on future plugin work, since bare-name
   references across the suite depend on it ([D9](artifacts/decision-log.md#d9-names-are-stable-namespaces-change)).
9. Every reader-facing surface is reconciled with the new layout, corrections included, not only additions
   ([D10](artifacts/decision-log.md#d10-documentation-surfaces-are-reconciled-corrections-included)):
   - Each moved skill's long-form doc moves with it, and the repo-wide skill and agent indexes list every entity at
     its new home.
   - Every description of what han-core contains, in the plugin-choosing guide, han-core's own front door, the
     project map, and the suite catalog, describes the slimmed han-core rather than today's contents.
   - Every statement of what a re-pointed plugin depends on matches the new dependency edges.
   - Every link or reference to a moved skill from shared surfaces, including the workflows map, resolves at the
     skill's new home.
   - The project map's statement of which plugins own agents admits han-research as an agent-owning plugin.
   - The plugin manifests for every supported platform describe each plugin's post-split contents, so no manifest
     advertises a skill its plugin no longer carries.
10. No plugin version number changes as part of this restructure; versioning happens at release time through the
    release process ([D11](artifacts/decision-log.md#trivial-decisions)).

## Alternate Flows and States

### Fresh install of a single edge plugin

- **Entry condition:** A user installs han-linear, han-feedback, or han-reporting without the meta-plugin.
- **Sequence:** The marketplace installs the requested plugin and only the dependencies its skills use. han-linear and
  han-feedback install standalone; han-reporting brings han-communication.
- **Exit:** The user has a working plugin without the agents and skills the old han-core dependency dragged in. A
  han-reporting-only install still reads a project-discovery file when the repository already has one, and loses only
  the ability to generate that file itself
  ([D5](artifacts/decision-log.md#d5-drop-the-vestigial-han-core-dependencies)).

### Upgrade of an existing full-suite install

- **Entry condition:** A user who already has `han` installed upgrades after the restructure ships.
- **Sequence:** The upgraded meta-plugin's dependency list pulls in han-documentation and han-research
  ([D8](artifacts/decision-log.md#d8-both-new-plugins-are-bundled-by-the-han-meta-plugin)); the slimmed
  han-core replaces the old one. From the user's perspective the upgrade is all-or-nothing: they hold either the
  complete prior skill set or the complete new one. Any unavoidable in-between state surfaces as a visible signal
  rather than a silently missing skill
  ([D13](artifacts/decision-log.md#d13-the-release-gate-verifies-every-upgrade-shape-and-a-recovery-path)).
- **Exit:** The user retains every skill and agent they had before the upgrade, under the new plugin homes. The
  resolver's handling of the two new bundled plugin names is verified against the pass condition in OI-1 before
  release.

### Upgrade of a partial install that relied on han-core for the moved skills

- **Entry condition:** A user who installed han-core directly, or a plugin that depends on it such as han-coding,
  upgrades after the restructure ships. They used one or more of the six moved skills.
- **Sequence:** The slimmed han-core no longer carries the moved skills, and nothing in a partial install pulls in the
  new plugins. The moved skills leave the user's footprint
  ([D12](artifacts/decision-log.md#d12-partial-installs-accept-reduced-skill-availability-with-release-notes-guidance)).
- **Exit:** The release notes name each moved skill, the plugin that now carries it, and the install step that
  restores it. That makes the loss a documented migration rather than a silent disappearance (OI-2).

### Invoking a moved skill by its old namespaced name

- **Entry condition:** A user or external document invokes a moved skill with its old namespace, such as
  `han-core:research`.
- **Sequence:** The old namespaced form no longer resolves; the bare form (`/research`) and the new namespaced form
  (`han-research:research`) both work for installs that carry the new plugin
  ([D9](artifacts/decision-log.md#d9-names-are-stable-namespaces-change)).
- **Exit:** The release notes map every old namespaced form to its new one so users can update saved invocations
  (OI-2).

## Edge Cases and Failure Modes

| Condition | Required Behavior |
| --------- | ----------------- |
| A skill in another plugin dispatches a shared agent (for example junior-developer) after the split | The dispatch resolves unchanged: every agent dispatched from more than one plugin stays in han-core ([D4](artifacts/decision-log.md#d4-research-analyst-moves-gap-analyzer-stays)). |
| A moved skill dispatches an agent after the move | Every agent dispatch inside a moved skill resolves at its post-split home. Dispatches of agents that stay in han-core keep resolving there, and the research skill's dispatches of research-analyst resolve inside han-research ([D9](artifacts/decision-log.md#d9-names-are-stable-namespaces-change)). |
| han-atlassian's project-documentation wrapper runs after the split | The wrapper invokes the skill at its new han-documentation home; the only cross-plugin skill invocation into old han-core is updated as part of the restructure ([D7](artifacts/decision-log.md#d7-han-atlassian-adds-han-documentation-and-keeps-direct-han-core)). |
| A skill probes the user's repository for the project-discovery output file | The probe keeps working: consumers find the file by name in the user's repository, not through the plugin that wrote it, so the skill's plugin home does not affect them ([D3](artifacts/decision-log.md#d3-project-discovery-and-project-scanner-stay-in-han-core)). |
| A moved skill's long-form doc links to an agent that stayed in han-core | The link resolves at the agent doc's unchanged home after the move. |
| A reader follows a boundary disclaimer ("does not do X, use research") from any skill | The bare skill name resolves to exactly one skill suite-wide. When the named skill's plugin is not installed, the session cannot run it. The plugin-choosing guide and release notes name which plugin carries each skill, so the user can install the right one ([D12](artifacts/decision-log.md#d12-partial-installs-accept-reduced-skill-availability-with-release-notes-guidance)). |
| An existing install upgrades while the catalog and plugin packages could disagree | The catalog never advertises a bundled plugin that cannot be installed, and no dependency list names a plugin absent from the catalog ([D13](artifacts/decision-log.md#d13-the-release-gate-verifies-every-upgrade-shape-and-a-recovery-path)). |
| The restructure ships and an upgrade path turns out broken | Reverting the suite's catalog and layout to the prior release restores existing installs to their pre-restructure working set on their next resolve. This recovery path is verified as part of the OI-1 release gate ([D13](artifacts/decision-log.md#d13-the-release-gate-verifies-every-upgrade-shape-and-a-recovery-path)). |

## Coordinations

The restructure's coordinations are the post-split dependency edges between plugins.

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
| ------------------- | --------- | ----------- | ---------------------------------- |
| han-documentation → han-core | outbound | Its skills dispatch shared specialist agents | Every agent its skills dispatch must remain in han-core |
| han-research → han-core | outbound | Its skills dispatch shared specialist agents | Every agent its skills dispatch must remain in han-core, except research-analyst, which lives in han-research itself |
| han-documentation and han-research → han-communication | outbound | Their prose-producing skills source the shared readability standard | Direct dependency, matching every other prose-producing plugin |
| han-atlassian → han-documentation | outbound | Its wrapper skill invokes project-documentation | The wrapper's invocation must name the skill's new plugin namespace |
| han meta-plugin → all bundled plugins | outbound | Installing `han` pulls in the full bundled set | The bundle must include both new plugins so no skill disappears on a full-suite upgrade |

## Out of Scope

- Renaming any skill or agent. Every entity keeps its name; only plugin homes change.
- Bumping any plugin version. Version changes belong to the release process, not this restructure.
- A finer-grained dependency mechanism. Plugin dependencies remain whole-plugin; regrouping entities is the only lever
  this change uses.
- Changing what any skill or agent does. The restructure moves entities without altering their behavior.
- Preserving the moved skills in partial installs. A user whose install carried the moved skills only through han-core
  keeps them by installing the new plugins. The restructure does not add dependencies to han-planning, han-coding, or
  han-github to compensate
  ([D12](artifacts/decision-log.md#d12-partial-installs-accept-reduced-skill-availability-with-release-notes-guidance)).

## Deferred (YAGNI)

### han-communication dependency for han-feedback

- **Why deferred:** Evidence test failed. han-feedback's skill contains no reference to the readability standard or any
  han-communication component, so there is no usage to support the dependency.
- **Reopen when:** The han-feedback skill starts sourcing the shared readability standard or dispatching the
  readability-editor.
- **Source:** Investigation open question; resolved by a repo-wide search during specification (D6).

### han-communication dependency for han-linear

- **Why deferred:** Evidence test failed. han-linear's skill and reference files contain no han-communication
  reference.
- **Reopen when:** The work-items-to-linear skill starts sourcing the shared readability standard.
- **Source:** Investigation open question; resolved by a repo-wide search during specification (D6).

### Finer-grained roster split by conditional dispatch

- **Why deferred:** Evidence test failed. Some shared agents are dispatched from other plugins only conditionally (for
  example gap-analyzer runs only when a source spec exists), which a future pass could use to shrink footprints
  further, but no current pressure justifies the added plugin complexity.
- **Reopen when:** A measured footprint complaint or install-size constraint makes the conditional-dispatch distinction
  worth acting on.
- **Source:** Investigation validation note V1.

### Forwarding signposts at han-core's old surfaces

- **Why deferred:** Simpler-version test. A "these skills moved" pointer on han-core's front door would help a reader
  who looks for a moved skill at its old home, but the release notes' old-to-new mapping (OI-2) and the complete
  indexes satisfy the same findability need with surfaces the release already commits to.
- **Reopen when:** Users report failing to find a moved skill despite the release notes and indexes.
- **Source:** Review finding F13 (information-architect).

## Open Items

- **OI-1:** Whether plugin dependency resolution behaves correctly for every reachable upgrade shape when the
  restructure ships
  ([D13](artifacts/decision-log.md#d13-the-release-gate-verifies-every-upgrade-shape-and-a-recovery-path)).
  - **Resolves when:** Pre-release verification exercises each shape against a real install. Each shape must pass this
    condition: after upgrading, the set of invocable skills and dispatchable agents matches what the spec commits for
    that shape, with no manual intervention and no silently missing skill. The shapes are:
    - a full `han` install (must retain everything)
    - a standalone han-core install (must end with the slimmed han-core and nothing broken)
    - a partial install such as han-coding-only (must keep working minus the moved skills)
    - a han-atlassian install (its wrapper must resolve project-documentation at its new home)

    The same verification confirms the recovery path: reverting the catalog and layout restores upgraded installs to
    their prior working set on next resolve.
  - **Blocks implementation:** No. The restructure work can proceed, but release is gated on every shape passing.
- **OI-2:** Whether external user documentation or user muscle memory depends on the old namespaced forms such as
  `han-core:research`.
  - **Resolves when:** The release notes name every namespace change, from old form to new form. For each moved
    skill, they also name the plugin that now carries it and the install step that restores it on partial installs.
  - **Blocks implementation:** No. The bare skill names keep working wherever the new plugins are installed.

## Summary

- **Outcome delivered:** han-core shrinks to the shared agent roster plus project discovery; six skills move to two new
  bundled plugins (han-documentation, han-research); three vestigial dependencies are removed; every reader-facing
  surface is reconciled and every upgrade shape is verified before release.
- **Primary actors:** Suite maintainers, end users installing or upgrading plugins, and Claude Code sessions
  dispatching cross-plugin agents and skills.
- **Decisions settled by evidence:** 13. See [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0. The user-provided investigation supplied the direction, so no decision needed
  a fresh user ruling. See [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, gap-analyzer, information-architect, devops-engineer. See
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** The documentation commitment now covers correcting stale surfaces, not only adding
  new ones. The upgrade story now covers partial installs, an explicit release-gate pass condition, and a recovery
  path. See [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 2
