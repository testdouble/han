# Implementation Decision Log: Per-Model Authoring Guidance

This file records every implementation decision committed while planning the per-model authoring guidance reference. Behavioral and implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md); this file captures the question, rationale, evidence, and rejected alternatives for each decision. Round-by-round history lives in [implementation-iteration-history.md](implementation-iteration-history.md).

The source specification is [../feature-specification.md](../feature-specification.md); its decision log is [decision-log.md](decision-log.md) and is cited below as "spec D#." The source research is [docs/research/model-specific-guidance-for-skills.md](../../../research/model-specific-guidance-for-skills.md), cited as "the research."

## Trivial decisions

_No trivial decisions. Every committed decision below carries at least one rejected alternative and rests on evidence beyond the source framing, so each is recorded in full._

## Full decisions

### D-1: Ship all five edits as one atomic commit

- **Question:** How are the touch points sequenced so no navigation surface ever points at a document that is not yet present?
- **Decision:** Land all five edits together in one atomic commit: (1) the new reference file under `han-plugin-builder/skills/guidance/references/`; (2) the routing bullet in `han-plugin-builder/skills/guidance/SKILL.md`; (3) the routing bullet in `han-plugin-builder/skills/guidance/assets/guidance-portable-SKILL.md`; (4) the entry in `han-plugin-builder/skills/guidance/assets/rule-index-body.md`; (5) the reverse cross-reference in `han-plugin-builder/skills/guidance/references/specialization-and-model-selection.md`. The forward link and source citation ship inside edit (1).
- **Rationale:** Every navigation surface points at the reference and the reference points back, so shipping them together removes any ordering trap and satisfies the spec's Coordinations requirement that the routing entry never point at a missing document. A documentation feature has no build, migration, or deploy ordering, so atomicity is the only sequencing constraint that applies.
- **Evidence:** spec Coordinations table (`../feature-specification.md` lines 51-55); spec D4, D9, D10; R1 claim C2 (junior-developer JD-002 + information-architect Q2); discovery notes touch-point list (`.discovery-notes.md`).
- **Rejected alternatives:**
  - Ship the reference file first and wire the indexes in a follow-up commit — rejected because a vendored refresh between the two commits would copy the reference to disk (`scripts/init-guidance.sh:74` copies `references/` wholesale) while the two curated indexes still carry no scent to it, orphaning it exactly as the spec Coordinations requirement forbids.
- **Specialist owner:** junior-developer / authoring engineer.
- **Revisit criterion:** if review-size constraints ever force the five edits across separate PRs (not expected for five small documentation edits).
- **Dissent (if any):** none known.
- **Driven by rounds:** R1
- **Dependent decisions:** D-2, D-3
- **Referenced in plan:** Implementation Approach, Decomposition and Sequencing, Definition of Done

### D-2: Add the routing bullet to both routing maps, plugin and portable copy

- **Question:** Which routing map or maps receive the new task-distinguishing bullet?
- **Decision:** Add an identically worded, task-distinguishing bullet to both the plugin's own `skills/guidance/SKILL.md` (inserted after the model bullet at lines 36-37 and before the Templates bullet at line 38) and the vendored `assets/guidance-portable-SKILL.md` (after the model bullet at lines 25-26 and before the Templates bullet at line 27).
- **Rationale:** The plugin's own `SKILL.md` is never vendored into other repos; `scripts/init-guidance.sh` vendors the portable copy instead. A bullet placed only in the plugin copy would leave every vendored repo's routing map with no scent to the reference, even though the reference file itself is copied wholesale. Vendored repos are a primary audience per the spec's Actors, so both maps must carry the bullet. This is the load-bearing implementation decision beyond the spec, whose D4 and D9 named a single routing map.
- **Evidence:** `scripts/init-guidance.sh:31` (`PORTABLE_SKILL` resolves to `assets/guidance-portable-SKILL.md`), `:73` (`cp "$PORTABLE_SKILL" .../plugin-guidance/SKILL.md`), `:74` (`cp -R "$SRC_REFERENCES" ...`); `SKILL.md` lines 36-38; `guidance-portable-SKILL.md` lines 25-27; R1 claim C1 (junior-developer JD-001); spec D4, D9.
- **Rejected alternatives:**
  - Update only the plugin's own `SKILL.md` — rejected because vendored repos (a primary audience per spec Actors) would receive the reference on disk with no routing scent, defeating the findability that is the whole feature.
- **Specialist owner:** junior-developer / authoring engineer.
- **Revisit criterion:** if `init-guidance.sh` ever begins vendoring the plugin's own `SKILL.md` rather than the portable copy, collapsing the two maps into one.
- **Dissent (if any):** none known.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Definition of Done

### D-3: Add and task-distinguish the rule-index-body entry

- **Question:** Does the vendored rule index need a curated entry for the new reference, and where does it go?
- **Decision:** Add a third bullet under the `## Plugin development` section of `assets/rule-index-body.md` (after the Specialization and Model Selection entry at lines 161-164), matching the existing `[Title](path) — what it covers + when to read it` pattern and carrying an inline scope disambiguator that distinguishes writing-for-a-model from choosing-a-model-tier.
- **Rationale:** `rule-index-body.md` is hand-enumerated and regenerates the vendored `.claude/rules/plugin-building-guidance.md` index. A reference not listed here is copied to disk but left orphaned in the vendored rule index. The spec's D4 named "one routing entry" and did not name this third surface. The entry sits beside Specialization and Model Selection and fires whenever an author edits a skill or agent file, so it needs the same task-distinguishing scent as the routing bullet.
- **Evidence:** discovery notes item 3 (`.discovery-notes.md`); `rule-index-body.md` lines 154-164; `scripts/init-guidance.sh` rule-index regeneration step (`RULE_BODY` at `:32`); R1 claim C3 (information-architect Q2 flag + junior-developer JD-003); spec D4.
- **Rejected alternatives:**
  - Rely on the wholesale reference copy alone — rejected because copying the reference file does not touch the curated rule index, so omission leaves the doc orphaned in every vendored `.claude/rules` index.
- **Specialist owner:** information-architect.
- **Revisit criterion:** if rule-index generation ever switches from hand-enumeration to auto-enumerating the `references/` directory.
- **Dissent (if any):** none known.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Definition of Done

### D-4: Top-level references/ placement and filename

- **Question:** Where does the new reference file live, and what is it named?
- **Decision:** Place it at top-level `han-plugin-builder/skills/guidance/references/`, alongside `specialization-and-model-selection.md` and `iterative-plugin-development.md`, named `per-model-authoring.md`.
- **Rationale:** The document is cross-cutting to both skill authors and agent authors (spec Actors), like the adjacent tier doc, so top-level placement fits. The entity-scoped subdirectories (`skill-building-guidance/`, `agent-building-guidelines/`) would falsely signal single-entity scope and orphan half the audience, and a new two-file "model" folder is unearned structure that would break scent-adjacency with the tier doc. `per-model-authoring.md` carries clear task scent and matches the plan folder name.
- **Evidence:** R1 claim C4 (information-architect Q3); discovery notes item 1, which names `iterative-plugin-development.md` and `specialization-and-model-selection.md` as the format precedents; spec Actors section (skill authors and agent authors).
- **Rejected alternatives:**
  - Place it under a per-entity subdirectory (`skill-building-guidance/` or `agent-building-guidelines/`) — rejected as Category Fiction that would orphan half the two-actor audience.
  - Create a new `model/` folder — rejected as unearned structure that breaks scent-adjacency with the tier doc.
  - Name it `writing-instructions-per-model.md` — rejected as longer with no added scent over `per-model-authoring.md`.
- **Specialist owner:** information-architect.
- **Revisit criterion:** if a second per-model authoring document is added, which would justify grouping them in a folder.
- **Dissent (if any):** none known.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Definition of Done

### D-5: Source-citation form — external URLs plus named report, no fragile repo-relative path

- **Question:** How does the new document cite its source, given that `references/` is copied wholesale into arbitrary repos?
- **Decision:** Cite the Anthropic per-model page URLs directly and name the research report (`model-specific-guidance-for-skills.md`) without a repo-relative path, matching the tier doc's external-URL Sources convention. Resolves OQ-1 by evidence.
- **Rationale:** `scripts/init-guidance.sh:74` copies `references/` into arbitrary repos, and `docs/research/` lives outside the guidance folder, so a repo-relative link to the research report would 404 in every vendored copy. The adjacent tier doc already cites external URLs only, so this matches an established convention rather than inventing one.
- **Evidence:** R1 claim C5 (junior-developer JD-004, resolved); `scripts/init-guidance.sh:74`; `specialization-and-model-selection.md` Sources section (external URLs only, around lines 79-83); the research Sources table A1-A3 (the Anthropic per-model page URLs); spec D5, D6.
- **Rejected alternatives:**
  - A repo-relative link to `docs/research/model-specific-guidance-for-skills.md` — rejected because the path breaks in every vendored copy, where `references/` is transplanted into a repo that has no `docs/research/` at that location.
- **Specialist owner:** information-architect.
- **Revisit criterion:** if the guidance folder is ever vendored together with `docs/research/`, making a repo-relative link resolvable.
- **Dissent (if any):** none known.
- **Driven by rounds:** R1
- **Dependent decisions:** D-6
- **Referenced in plan:** Implementation Approach, Definition of Done

### D-6: The reference document's own structure and content commitments

- **Question:** What must the new reference document contain for the routed author to get the promised outcome?
- **Decision:** The document opens by stating its own scope (author-time only; shipped skills stay model-agnostic; run-time detection is out of scope and not reliable), then states the model-agnostic default and its concrete unknown-target form (lead with the goal and reasons, state load-bearing constraints and scope explicitly, avoid exhaustive micro-checklists), the opposite-direction instruction-style split (Opus 4.8 and Sonnet 5 read literally and want behaviors spelled out; Fable 5 does better with a stated goal than an enumerated checklist), the Fable 5 reasoning-echo refusal warning with its recognition test and single-source disclosure, the thinking-mode and effort supporting notes each tied to the authoring decision it changes, a forward cross-reference to the tier doc, a source citation in the D-5 form, and a visible currency marker naming the three models and the write date.
- **Rationale:** These content commitments are inherited from the spec and are exactly what Definition of Done tests. Recording them here keeps the document's required content auditable at plan altitude without inlining the prose the author will write.
- **Evidence:** spec Primary Flow and Edge Cases and Failure Modes; spec D2 (high-impact differences), D3 (author-time-only default), D5 (cross-reference and cite source), D6 (currency marker and single-source disclosure), D11 (concrete unknown-target default), D12 (refusal recognition test); the research A1-A3 (per-model behavioral claims), with the Fable 5 refusal category single-source on A3.
- **Rejected alternatives:**
  - Omit the currency marker or the single-source disclosure — rejected at spec stage (D6, finding F5) because the highest-stakes claim on the weakest evidence would otherwise read as the best-established one.
  - State a bare "write model-agnostic" without the concrete unknown-target form — rejected at spec stage (D11, finding F3) because it leaves the document's central instruction undefined at the common unknown-target case.
- **Specialist owner:** information-architect / authoring engineer.
- **Revisit criterion:** if Anthropic revises or archives a named model's prompting page (the currency marker is the reader's signal to re-verify).
- **Dissent (if any):** none known.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Context, Implementation Approach, Definition of Done
