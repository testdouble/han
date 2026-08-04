# Team Findings: Plugin-Centric Documentation Reorganization

This file records every finding raised by the review team, and how each was resolved. Behavioral outcomes live in
[../feature-specification.md](../feature-specification.md); decisions the findings affected live in
[decision-log.md](decision-log.md); load-bearing mechanics live in
[feature-technical-notes.md](feature-technical-notes.md).

Reviewers: `han-core:information-architect`, `han-core:junior-developer`, `han-core:gap-analyzer`. All findings were
resolved by evidence (codebase inspection and the decisions the user had already settled); none required new user input.

## Major findings

### F1: The plugin-README standard and template mandate the heavy README that D3 rejects

- **Agent:** gap-analyzer, junior-developer, information-architect
- **Finding:** `docs/plugin-readme.md:107-146` and the template at
  `han-plugin-builder/.../templates/plugin-readme-template.md:98-125` mandate a per-skill Skills Reference (paragraph,
  files line, example prompts). D3's light front door forbids exactly those blocks, and the initial draft's update scope
  omitted both files. Contributors following the on-disk standard would keep producing heavy READMEs.
- **Resolution:** Added D18 to reconcile the standard and the template to the light front-door model, and named both
  files in the Edge Cases and Coordinations scope. The issue's `docs/plugin-readme.md` is a rules doc, not a plugin
  index; the spec's characterization was correct and is now explicit.
- **Resolved by:** evidence
- **Affected decisions:** D3, D18
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes, Coordinations

### F2: The change scope was a subset of the real blast radius

- **Agent:** junior-developer
- **Finding:** D9's evidence named about nine files. A repository-wide scan of active files referencing the old
  `docs/skills/` and `docs/agents/` paths returns about thirty-seven, including every `docs/how-to/` guide, several
  standalone `docs/` pages, the skill long-form template, and the maintenance skill's `audit-checklist.md` and
  `scope-mapping.md`.
- **Resolution:** Rewrote D9 to require the full active scan (excluding the frozen archives) and to state the real scope,
  and required the scan to be regenerated at implementation time.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations, Edge Cases and Failure Modes

### F3: Relative links inside moved docs break, not only links pointing at them

- **Agent:** junior-developer
- **Finding:** The docs move tree location, so every relative link inside a moved doc (to references, sibling docs, or
  the root) must be recomputed for its new depth. The draft's edge case covered only inbound links.
- **Resolution:** Added D16 and an edge-case row requiring every relative link inside a moved doc to be recomputed.
- **Resolved by:** evidence
- **Affected decisions:** D16
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes, Actors and Triggers (Preconditions)

### F4: The shared-agent dispatch note omitted the readability-editor's home

- **Agent:** junior-developer
- **Finding:** D8's note said a no-agent plugin's skills "dispatch agents that live in `han-core`." The coding and core
  skills also dispatch the `readability-editor`, which lives in `han-communication` (`CLAUDE.md`;
  `han-communication/agents/readability-editor.md`).
- **Resolution:** Reworded D8 and the spec flow to "dispatch shared agents, which live in `han-core` and, for the
  readability-editor, in `han-communication`."
- **Resolved by:** evidence
- **Affected decisions:** D8
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States

### F5: The meta-plugin ships no skills, so the "every plugin has a skills section" edge case is false

- **Agent:** junior-developer
- **Finding:** `han/plugin.json` is dependencies-only; the meta-plugin ships zero skills and zero agents. The draft's
  edge case claimed every plugin has a skills section. The existing `han/README.md` is also stale, describing the old
  `han-core` / `han-github` split, and did not surface in the path scan.
- **Resolution:** Added D17 (meta-plugin README omits skills and agents sections and is rewritten to the current suite),
  fixed the edge-case row, and named `han/README.md` in the D9 scope.
- **Resolved by:** evidence
- **Affected decisions:** D17, D9
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States, Edge Cases and Failure Modes, Coordinations

### F6: Plugin-level purpose had no declared canonical home, and the catalog re-created the duplication

- **Agent:** information-architect, junior-developer, gap-analyzer
- **Finding:** The draft declared a canonical home only for skills and agents. Three surfaces describe each plugin's
  purpose (catalog paragraph, plugin README, root README table), and the catalog also deep-links every skill, so the
  duplication the issue attacks reappears at the plugin tier.
- **Resolution:** D3 now declares the plugin README canonical for plugin purpose; D4 slims the catalog to a one-line
  scent plus a link to each plugin README and drops the per-skill deep-links; an edge-case row enforces it.
- **Resolved by:** evidence
- **Affected decisions:** D3, D4
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### F7: Framing opt-in versus bundled plugins inside a plugin's own README was unaddressed

- **Agent:** gap-analyzer
- **Finding:** Issue #115's Missing Information #4 asks how opt-in plugins are framed versus bundled ones inside a
  plugin's own README. No decision or flow covered it.
- **Resolution:** Added D13: each plugin README states whether the meta-plugin bundles it or it is opt-in, and names its
  dependencies (and any required MCP server).
- **Resolved by:** evidence
- **Affected decisions:** D13
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Primary Flow

### F8: The workflows page had thin inbound scent, and the indexes lost their compose pointer

- **Agent:** information-architect
- **Finding:** D6 moved the "how skills compose" content out of the indexes with no replacement pointer, and nothing
  required inbound links to the workflows page beyond the root README, risking an near-orphaned page.
- **Resolution:** D5 and D6 now require the root README, both indexes, and the plugin index to link to the workflows
  page, and the indexes to keep a cross-link to it.
- **Resolved by:** evidence
- **Affected decisions:** D5, D6
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Coordinations

### F9: The "workflows" label collides with quickstart, how-to, and concepts

- **Agent:** information-architect
- **Finding:** "Workflows" joins quickstart paths, how-to guides, and the concepts compose-model, all about "how skills
  chain," with nothing differentiating them. A reader guesses among four near-synonymous surfaces.
- **Resolution:** D6 now requires the workflows page to state its distinct job (the map of which skills chain together)
  and how it differs from the other three, with the four cross-linked.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F10: In-plugin docs still linked up only to the far root, and plugin READMEs lacked lateral nav

- **Agent:** information-architect
- **Finding:** After the move the long-form doc sits beside its plugin README, but the "links up" convention still points
  at the root, skipping the natural parent, and plugin READMEs had no path across to the catalog or workflows.
- **Resolution:** Added D14: long-form docs link up to their plugin README then the root; plugin READMEs carry minimal
  lateral nav (up to the plugin index and root, across to workflows).
- **Resolved by:** evidence
- **Affected decisions:** D14
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F11: The plugin index is not parallel to the skills and agents indexes

- **Agent:** information-architect
- **Finding:** Skills and agents each get a `docs/{thing}/README.md`; the plugin index folds into a differently-named,
  differently-shaped doc, contrary to the issue's "mirroring" ask, so a reader hunts for a nonexistent
  `docs/plugins/README.md`.
- **Resolution:** Kept D4's single-doc choice but required the root README and both indexes to label the choosing doc
  explicitly as the plugin index so the three-index mental model resolves.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations

### F12: A Coordinations row stated an authoring format instead of a behavior

- **Agent:** information-architect
- **Finding:** The GitHub-rendering coordination said diagrams "must be authored in the fenced form GitHub renders
  natively" — an implementation mechanic restated as a requirement, which T1 already carries.
- **Resolution:** Reworded the coordination to the behavioral outcome ("the reader sees each diagram on GitHub with no
  build step") and left the fenced-block mechanic to T1.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** T1
- **Changed in spec:** Coordinations

### F13: The docs will now ship inside every installed plugin, which the draft did not state

- **Agent:** junior-developer
- **Finding:** Plugin directories are the install source with no file filtering, so a new `{plugin}/docs/` tree ships to
  end users. Consistent with the README precedent, but the draft framed D1 as pure benefit.
- **Resolution:** D1 now states the docs ship inside the installed plugin, the same way the README does, and are not
  loaded by the plugin system.
- **Resolved by:** evidence
- **Affected decisions:** D1
- **Affected tech-notes:** —
- **Changed in spec:** Out of Scope

### F14: No acceptance check proved that no link broke

- **Agent:** junior-developer
- **Finding:** "Every link resolves" was the core requirement with no named exit gate, no rollback note, and preconditions
  written as description rather than testable criteria.
- **Resolution:** Added D16: the reorganization is complete only when a repository-wide internal-link check passes with
  zero unresolved links, and made it a precondition.
- **Resolved by:** evidence
- **Affected decisions:** D16
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers (Preconditions)

### F15: Alphabetical-only indexes with a one-sentence scent drop browse and disambiguation

- **Agent:** information-architect
- **Finding:** A pure alphabetized list with a hard one-sentence scent serves known-item lookup but strips the
  categorical browse scaffold and the detail that disambiguates near-neighbor skills (for example `code-review` versus
  `architectural-analysis`).
- **Resolution:** D5 now allows the scent to run to a second sentence where it disambiguates, and names the quickstart and
  the per-plugin grouping as the browse-by-task path so categorical browse survives.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F16: Each skill's scent now lives in three hand-maintained places with no canonical copy

- **Agent:** information-architect
- **Finding:** The scent exists in the long-form doc, the plugin README, and the aggregate index, with no rule that they
  match, inviting drift.
- **Resolution:** Added D15: the long-form doc's summary line is the canonical scent, reused by the README and the index.
- **Resolved by:** evidence
- **Affected decisions:** D15
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States

## Minor edits

- F17: Acknowledge that moving docs into ten plugin folders costs the single-directory / bulk-edit reader, and name the
  indexes as the sanctioned cross-plugin entry — information-architect — Out of Scope, D1.
- F18: Soften the diagram commitment from one-per-scenario to diagrams only where a chain branches enough to warrant one
  (YAGNI simpler-version) — information-architect — Primary Flow, D6/D7.
