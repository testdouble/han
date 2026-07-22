# Team Findings: han-core Restructure

This file records every finding raised by the review team for the han-core restructure, and how each was resolved.
Behavioral outcomes live in [../feature-specification.md](../feature-specification.md); decisions the findings affected
live in [decision-log.md](decision-log.md). No feature-technical-notes.md exists for this specification; no load-bearing
mechanic qualified for capture.

Review team: han-core:junior-developer, han-core:gap-analyzer, han-core:information-architect,
han-core:devops-engineer. Overlapping findings from multiple agents are merged into one entry naming every raiser.

## Major findings

### F1: The documentation commitment covered additions but not corrections of stale surfaces

- **Agent:** information-architect (with gap-analyzer GAP-003)
- **Finding:** The spec committed to naming the new plugins and relinking moved skills, but six reader-facing surfaces
  describe today's han-core (the plugin-choosing guide's han-core entry and core-only rows, han-core's own front door,
  dependency descriptions for the re-pointed plugins, the workflows map's links into moved skills, and the project
  map's statement of which plugins own agents). Nothing committed to correcting them, so the guide would route a
  "research and documentation skills" installer to a han-core that no longer carries those skills.
- **Resolution:** Primary Flow step 9 rewritten as a reconciliation commitment: every description of han-core's
  contents, every dependency statement, every shared-surface link to a moved skill (workflows map included), and the
  agent-ownership statement in the project map must match the post-split layout. D10 promoted from a trivial
  convention note to a full decision carrying this scope.
- **Resolved by:** evidence
- **Affected decisions:** D10
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F2: A standalone han-core install silently loses the six moved skills on upgrade

- **Agent:** devops-engineer
- **Finding:** han-core is independently installable, and a user who installed it directly for research,
  gap-analysis, issue-triage, project-documentation, architectural-decision-record, or runbook loses those skills on
  upgrade with no signal: no meta-plugin re-bundles them for that user. The spec's bundling argument (D8) protected
  only full-suite users.
- **Resolution:** New alternate flow "Upgrade of a partial install that relied on han-core for the moved skills"; new
  decision D12 accepting the reduction as the feature's purpose while requiring the release notes to name each moved
  skill, its new plugin, and the restoring install step; OI-1 widened to verify the standalone han-core upgrade shape.
- **Resolved by:** evidence
- **Affected decisions:** D12 (new), D8
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Alternate Flows and States, Out of Scope, Open Items

### F3: Partial installs through han-planning or han-coding lose the moved skills, including the issue-triage handoff

- **Agent:** junior-developer (with gap-analyzer GAP-002)
- **Finding:** han-planning and han-coding do not depend on the new plugins, so a han-coding-only user loses all six
  moved skills — including the issue-triage handoff that han-coding's refactor skill recommends, the exact cost D2
  cited when rejecting the fold-into-han-planning alternative. The spec framed the shrink only as a benefit.
- **Resolution:** The reduction is accepted explicitly rather than compensated: adding dependencies from han-planning
  or han-coding to the new plugins would rebuild the footprint the restructure exists to remove. Captured in D12, a
  new Out of Scope entry, Primary Flow step 7, and the release-notes commitment in OI-2. The handoff cost is now on
  the record instead of invisible.
- **Resolved by:** evidence
- **Affected decisions:** D12 (new), D2
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Alternate Flows and States, Out of Scope, Open Items

### F4: Boundary disclaimers can name a skill the current install does not carry

- **Agent:** junior-developer
- **Finding:** The spec's bare-name edge case answered the name-collision question but not availability: after the
  split, "use research" from a han-coding-only install names a skill that is not installed, and the behavior in that
  state was undefined.
- **Resolution:** The edge-case row now separates uniqueness from availability: the bare name resolves to exactly one
  skill suite-wide; when its plugin is not installed the session cannot run it, and the plugin-choosing guide and
  release notes name which plugin carries each skill.
- **Resolved by:** evidence
- **Affected decisions:** D9, D12
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F5: No recovery path, an unfalsifiable release gate, and an atomicity commitment that never reached the user

- **Agent:** devops-engineer (with junior-developer F1/F8)
- **Finding:** Three related transition gaps: (a) OI-1's "verify against a real install" named no pass condition and
  covered only the full-`han` shape; (b) nothing stated what happens if the restructure ships broken, and the
  no-version-bump choice (D11) removes version pinning as a recovery lever; (c) the "one coordinated change"
  precondition constrained the repository, not what an upgrading user observes mid-transition.
- **Resolution:** New decision D13. OI-1 rewritten with an explicit pass condition applied to four enumerated upgrade
  shapes (full `han`, standalone han-core, partial such as han-coding-only, han-atlassian) plus verification of the
  recovery path: reverting the catalog and layout restores upgraded installs on next resolve. The preconditions and
  edge cases now commit that the catalog never advertises an uninstallable plugin, no dependency list names an absent
  plugin, and a full-suite upgrade is all-or-nothing from the user's perspective or visibly signalled.
- **Resolved by:** evidence
- **Affected decisions:** D13 (new)
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers, Alternate Flows and States, Edge Cases and Failure Modes, Open Items

### F6: YAGNI candidate — one new plugin would satisfy the measured pain instead of two

- **Agent:** junior-developer
- **Finding:** The user-described pain (edge-plugin footprint) is fully resolved by dropping the vestigial
  dependencies; the two-plugin grouping rests on scent-line honesty, which the investigation itself rates a
  Medium-confidence judgment call. A single new plugin is the strictly simpler version.
- **Resolution:** Evidence cited to keep two: purpose-grouped plugins with honest scent lines are a documented
  project convention (the repository's project map describes every plugin by a single coherent purpose), which lifts
  the grouping above taste; the finding itself conceded this counter-evidence. Recorded on D2's rationale and
  rejected alternatives. Surfaced in the final presentation so the maintainers can consciously override.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** —

### F7: han-research's name under-predicts gap-analysis and issue-triage

- **Agent:** information-architect
- **Finding:** Unlike the other layer plugins, which are named by their whole domain, "han-research" names one of its
  three skills, so a user hunting for triage or gap comparison has no scent reason to open it.
- **Resolution:** Primary Flow step 3 now commits han-research's reader-facing descriptions to the "pre-planning
  knowledge work" frame so all three skills are predictable from its scent line, without renaming anything (honoring
  D9).
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F8: Platform manifests beyond the primary one were missing from the spec's commitments

- **Agent:** gap-analyzer (GAP-001)
- **Finding:** The investigation's validation (V3) requires manifests for a second supported platform: both new
  plugins need one, and han-core's currently advertises the moving skills in its keywords and prompts. The spec
  carried no corresponding commitment, risking a platform install that advertises capabilities han-core no longer
  has.
- **Resolution:** Primary Flow step 9 now commits that the plugin manifests for every supported platform describe
  each plugin's post-split contents, so no manifest advertises a skill its plugin no longer carries.
- **Resolved by:** evidence
- **Affected decisions:** D10
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F9: Mechanics leaking into spec — agent inventories, entity counts, and a link-syntax phrase

- **Agent:** devops-engineer and information-architect (with gap-analyzer GAP-004)
- **Finding:** The Coordinations table enumerated per-plugin agent rosters (which were also incomplete for
  gap-analysis's swarm), the Outcome and Primary Flow carried entity counts that will drift, and an edge-case row
  named the cross-plugin link form — all implementation inventory or syntax rather than behavior.
- **Resolution:** Rewritten behaviorally: the coordination contract is "every agent a moved skill dispatches remains
  in han-core, except research-analyst, which lives in han-research"; counts removed in favor of count-free phrasing;
  the link row now states only that links from moved docs resolve at the agents' unchanged homes.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes, Coordinations

### F10: Moved skills' agent dispatches were assumed to resolve after the move without verification

- **Agent:** junior-developer
- **Finding:** The investigation verified doc links but not the dispatch invocations inside the moving skills; a
  dispatch form that assumed co-location with han-core could fail after the move.
- **Resolution:** Verified during finding resolution: the moving skills reference their agents by namespaced form;
  every referenced agent stays in han-core except research-analyst, whose references sit inside the research skill
  and move plugins with it. The spec now carries an edge-case row committing that every agent dispatch inside a moved
  skill resolves at its post-split home; rewriting the research skill's research-analyst namespace is implementation
  work the implementation plan owns.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F11: The spec did not state why han-atlassian's direct han-core dependency is not vestigial

- **Agent:** junior-developer
- **Finding:** D5 removes dependencies for being unused while D7 keeps one whose only direct skill use is leaving;
  the distinction (the skills han-atlassian wraps genuinely dispatch han-core agents) lived in the investigation but
  not on the spec's face, inviting the "isn't that vestigial too?" misreading.
- **Resolution:** Primary Flow step 6 now states the distinction inline.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

## Minor edits

- F12: Record that suite-wide skill-name uniqueness becomes a standing constraint future plugin work must preserve,
  since bare-name references depend on it — junior-developer — Primary Flow
- F13: Forwarding signpost at han-core's old surfaces considered and deferred under the simpler-version test (release
  notes and indexes satisfy the same need) — information-architect — Deferred (YAGNI)
