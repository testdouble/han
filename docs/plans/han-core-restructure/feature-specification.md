# Feature Specification: han-core Restructure

Splitting han-core into a lean shared-agent plugin plus two new topical plugins, han-documentation and han-research, so
that depending on han-core no longer installs seven skills most dependents never use. Three plugins that depend on
han-core without using it drop the dependency entirely.

## Outcome

Installing any plugin that depends on han-core installs a much smaller han-core: the shared specialist-agent roster,
the project-discovery skill, and the canonical rule files, with nothing else riding along. Users who install the full
`han` suite keep every skill and agent they have today, now organized so each plugin's name matches what it contains
([D1](artifacts/decision-log.md#d1-split-han-core-along-the-agents-versus-skills-line)). Users who install only an
edge plugin such as han-linear or han-feedback no longer receive 23 agents and 7 skills they never invoke
([D5](artifacts/decision-log.md#d5-drop-the-vestigial-han-core-dependencies)).

## Actors and Triggers

- **Actors**
  - **Suite maintainers** carry out the restructure and maintain the resulting plugins.
  - **End users** install, upgrade, and invoke Han plugins through the marketplace and slash commands.
  - **Claude Code sessions** dispatch the shared agents and invoke skills across plugin boundaries at runtime.
- **Triggers** — a user installs or upgrades a Han plugin; a session invokes a skill or dispatches an agent that now
  lives in a different plugin than before.
- **Preconditions** — the restructure lands as one coordinated change: the new plugins exist, the moved skills live in
  their new homes, and every dependency list and documentation surface reflects the new layout before release.

## Primary Flow

The restructure produces this target shape. Each numbered item is a behavior the released suite must exhibit.

1. **han-core** contains the shared specialist-agent roster (22 agents: every current agent except research-analyst),
   the project-discovery skill with its project-scanner agent, and the canonical evidence and YAGNI rule files
   ([D3](artifacts/decision-log.md#d3-project-discovery-and-project-scanner-stay-in-han-core),
   [D4](artifacts/decision-log.md#d4-research-analyst-moves-gap-analyzer-stays)).
2. **han-documentation** (new) contains the project-documentation, architectural-decision-record, and runbook skills,
   and depends on han-communication and han-core
   ([D2](artifacts/decision-log.md#d2-two-new-plugins-rather-than-folding-into-han-planning)).
3. **han-research** (new) contains the research, gap-analysis, and issue-triage skills plus the research-analyst agent,
   and depends on han-communication and han-core ([D2](artifacts/decision-log.md#d2-two-new-plugins-rather-than-folding-into-han-planning),
   [D4](artifacts/decision-log.md#d4-research-analyst-moves-gap-analyzer-stays)).
4. The **han meta-plugin** bundles both new plugins alongside its current six dependencies, so installing `han`
   continues to deliver every skill and agent it delivers today
   ([D8](artifacts/decision-log.md#d8-both-new-plugins-are-bundled-by-the-han-meta-plugin)).
5. **han-reporting, han-feedback, and han-linear** no longer depend on han-core. han-reporting keeps its
   han-communication dependency; han-feedback and han-linear gain no replacement dependency
   ([D5](artifacts/decision-log.md#d5-drop-the-vestigial-han-core-dependencies),
   [D6](artifacts/decision-log.md#d6-han-feedback-and-han-linear-gain-no-han-communication-dependency)).
6. **han-atlassian** depends on han-documentation for its project-documentation wrapper and keeps its direct han-core
   dependency ([D7](artifacts/decision-log.md#d7-han-atlassian-adds-han-documentation-and-keeps-direct-han-core)).
7. **han-github, han-planning, and han-coding** keep their current dependency lists; their installed footprint shrinks
   by the six moved skills.
8. Every skill and agent keeps its current name. Cross-plugin invocations of the moved skills resolve at their new
   namespaced homes, and bare-name references ("use research") keep working because no two plugins share a skill name
   ([D9](artifacts/decision-log.md#d9-names-are-stable-namespaces-change)).
9. Every documentation surface reflects the new layout: each moved skill's long-form doc moves with it into the owning
   plugin, the repo-wide indexes list every skill and agent at its new home, the plugin index and workflows map name
   the new plugins, and the suite's marketplace catalog lists both new plugins
   ([D10](artifacts/decision-log.md#d10-documentation-follows-the-plugin-first-convention)).
10. No plugin version number changes as part of this restructure; versioning happens at release time through the
    release process ([D11](artifacts/decision-log.md#d11-no-version-bumps-in-this-change)).

## Alternate Flows and States

### Fresh install of a single edge plugin

- **Entry condition:** A user installs han-linear, han-feedback, or han-reporting without the meta-plugin.
- **Sequence:** The marketplace installs the requested plugin and only the dependencies its skills use. han-linear and
  han-feedback install standalone; han-reporting brings han-communication.
- **Exit:** The user has a working plugin without the 23 agents and 7 skills the old han-core dependency dragged in.

### Upgrade of an existing full-suite install

- **Entry condition:** A user who already has `han` installed upgrades after the restructure ships.
- **Sequence:** The upgraded meta-plugin's dependency list pulls in han-documentation and han-research; the slimmed
  han-core replaces the old one.
- **Exit:** The user retains every skill and agent they had before the upgrade, under the new plugin homes. How the
  marketplace resolver handles the two new bundled plugin names on upgrade is unverified and tracked as an open item
  (OI-1).

### Invoking a moved skill by its old namespaced name

- **Entry condition:** A user or external document invokes a moved skill with its old namespace, such as
  `han-core:research`.
- **Sequence:** The old namespaced form no longer resolves; the bare form (`/research`) and the new namespaced form
  (`han-research:research`) both work ([D9](artifacts/decision-log.md#d9-names-are-stable-namespaces-change)).
- **Exit:** The release notes call out the namespace changes so users can update saved invocations (OI-2).

## Edge Cases and Failure Modes

| Condition | Required Behavior |
| --------- | ----------------- |
| A skill in another plugin dispatches a shared agent (for example junior-developer) after the split | The dispatch resolves unchanged: every agent dispatched from more than one plugin stays in han-core ([D4](artifacts/decision-log.md#d4-research-analyst-moves-gap-analyzer-stays)). |
| han-atlassian's project-documentation wrapper runs after the split | The wrapper invokes the skill at its new han-documentation home; the only cross-plugin skill invocation into old han-core is updated as part of the restructure ([D7](artifacts/decision-log.md#d7-han-atlassian-adds-han-documentation-and-keeps-direct-han-core)). |
| A skill probes the user's repository for the project-discovery output file | The probe keeps working: consumers find the file by name in the user's repository, not through the plugin that wrote it, so the skill's plugin home does not affect them ([D3](artifacts/decision-log.md#d3-project-discovery-and-project-scanner-stay-in-han-core)). |
| A moved skill's long-form doc links to an agent that stayed in han-core | The link resolves at the agent doc's unchanged home; the moved docs' links are rewritten to the cross-plugin form the suite already uses. |
| A reader follows a boundary disclaimer ("does not do X, use research") from any skill | The bare skill name stays unambiguous; a duplicate-name scan across all plugins confirmed no collision exists and the restructure renames nothing ([D9](artifacts/decision-log.md#d9-names-are-stable-namespaces-change)). |
| An existing `han` install upgrades and the resolver mishandles the new bundled plugin names | Unverified behavior; tracked as OI-1 and checked against a real install before release. |

## Coordinations

The restructure's coordinations are the post-split dependency edges between plugins.

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
| ------------------- | --------- | ----------- | ---------------------------------- |
| han-documentation → han-core | outbound | Its skills dispatch shared agents (codebase-explorer, content-auditor, information-architect, software-architect, system-architect, risk-analyst, junior-developer) | All dispatched agents must remain in han-core |
| han-research → han-core | outbound | Its skills dispatch shared agents (codebase-explorer, adversarial-validator, gap-analyzer, evidence-based-investigator, junior-developer, project-manager) | All dispatched agents except research-analyst must remain in han-core |
| han-documentation and han-research → han-communication | outbound | Their prose-producing skills source the shared readability standard | Direct dependency, matching every other prose-producing plugin |
| han-atlassian → han-documentation | outbound | Its wrapper skill invokes project-documentation | The wrapper's invocation must name the skill's new plugin namespace |
| han meta-plugin → all bundled plugins | outbound | Installing `han` pulls in the full bundled set | The bundle must include both new plugins so no skill disappears on upgrade |

## Out of Scope

- Renaming any skill or agent. Every entity keeps its name; only plugin homes change.
- Bumping any plugin version. Version changes belong to the release process, not this restructure.
- A finer-grained dependency mechanism. Plugin dependencies remain whole-plugin; regrouping entities is the only lever
  this change uses.
- Changing what any skill or agent does. The restructure moves entities without altering their behavior.

## Deferred (YAGNI)

### han-communication dependency for han-feedback

- **Why deferred:** Evidence test failed. han-feedback's skill contains no reference to the readability standard or any
  han-communication component, so there is no usage to support the dependency.
- **Reopen when:** The han-feedback skill starts sourcing the shared readability standard or dispatching the
  readability-editor.
- **Source:** Investigation open question; resolved by a repo-wide search during specification.

### han-communication dependency for han-linear

- **Why deferred:** Evidence test failed. han-linear's skill and reference files contain no han-communication
  reference.
- **Reopen when:** The work-items-to-linear skill starts sourcing the shared readability standard.
- **Source:** Investigation open question; resolved by a repo-wide search during specification.

### Finer-grained roster split by conditional dispatch

- **Why deferred:** Evidence test failed. Some shared agents are dispatched from other plugins only conditionally (for
  example gap-analyzer runs only when a source spec exists), which a future pass could use to shrink footprints
  further, but no current pressure justifies the added plugin complexity.
- **Reopen when:** A measured footprint complaint or install-size constraint makes the conditional-dispatch distinction
  worth acting on.
- **Source:** Investigation validation note V1.

## Open Items

- **OI-1:** Whether the marketplace and plugin resolver cleanly handle upgrades for users who already have `han`
  installed when two new bundled plugin names appear in its dependency list.
  - **Resolves when:** The upgrade path is exercised against a real existing install during implementation or
    pre-release verification.
  - **Blocks implementation:** No — it must be verified before release, but the restructure work can proceed.
- **OI-2:** Whether external user documentation or user muscle memory depends on the old namespaced forms such as
  `han-core:research`.
  - **Resolves when:** The release notes for the restructure name every namespace change, giving users the mapping from
    old to new forms.
  - **Blocks implementation:** No — the bare skill names keep working throughout.

## Summary

- **Outcome delivered:** han-core shrinks to the shared agent roster plus project discovery; six skills move to two new
  bundled plugins (han-documentation, han-research); three vestigial dependencies are removed.
- **Primary actors:** Suite maintainers, end users installing or upgrading plugins, and Claude Code sessions
  dispatching cross-plugin agents and skills.
- **Decisions settled by evidence:** 11 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0 — the user-provided investigation supplied the direction; no decision needed a
  fresh user ruling — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 2
