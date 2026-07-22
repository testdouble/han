# Implementation Decision Log: han-core Restructure

<!--
This file records every implementation decision committed while planning the han-core restructure.
Behavioral and implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md) —
this file captures the question, rationale, evidence, and rejected alternatives for each decision.
Round-by-round history lives in [implementation-iteration-history.md](implementation-iteration-history.md).
-->

These decisions are the implementation-planning decisions for the restructure. They are numbered D-1, D-2, and so on,
and they are distinct from the specification's D1-D13, which this log cites as "spec D5" and so on. Evidence IDs
(E1-E14, V1-V6) refer to the [investigation report](../investigation.md); claim IDs (S1-S11, R1c-R7c, IA-1 through
IA-scent, JD-1 through JD-7, OQ-1r through JD-6r) refer to the claim ledgers in
[implementation-iteration-history.md](implementation-iteration-history.md).

## Trivial decisions

- D-12: New-plugin scaffold reuses the five-part plugin shape — han-documentation and han-research each get the same
  layout every existing plugin uses (README.md, `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `skills/`,
  `docs/`, and `references/` with vendored rule copies where their skills need them), copied and adapted from the
  han-planning and han-atlassian precedent, so no new abstraction is introduced (S7, investigation E12). — Referenced
  in plan: Implementation Approach, Work Units and Sequencing.
- D-13: New plugins start at version 1.0.0 — han-documentation and han-research each begin at `1.0.0` on both the
  `.claude-plugin` and `.codex-plugin` manifests, matching the suite's most recent new plugin, han-communication
  (OQ-3r; marketplace.json, `han-planning/.codex-plugin/plugin.json:3`). Spec D11's no-version-bump rule governs only
  existing plugins, so this adds no conflict. — Referenced in plan: Constraints and Boundaries.

## Full decisions

### D-1: Single-merge atomicity is the coordination and release unit

- **Question:** What is the unit of "one coordinated change" the spec's precondition requires, given no version bump
  marks the transition?
- **Decision:** The entire restructure lands as one merge to the default branch. That single merge is the atomicity
  unit: every moved skill, every rewritten manifest, every dependency edit, and every reconciled surface co-lands, and
  no intermediate committed state on the default branch is internally inconsistent.
- **Rationale:** The suite catalog resolves from bare relative paths against the default branch, not a pinned tag or
  ref, so the live state users resolve against is exactly the merged state of the default branch. There is no staging
  boundary between merge and release. That makes the merge itself the only place atomicity can be enforced.
- **Evidence:** `.claude-plugin/marketplace.json` sources are bare relative paths with no ref pinning (R1c); marketplace
  is added as `testdouble/han`, confirming default-branch resolution (OQ-1r: `README.md:38`,
  `docs/choosing-a-han-plugin.md:106`, `README.md:71`); JD-3 flagged that unstated commit granularity risks an
  inconsistent committed main state.
- **Rejected alternatives:**
  - Sequence the restructure across several merges (new plugins first, then re-point dependents) — rejected because
    each intermediate default-branch state would advertise or omit plugins inconsistently, violating the spec's
    catalog invariant (spec D13) for every user who resolves between merges.
  - Rely on a version bump to gate the transition — rejected because spec D11 forbids version bumps in this change, so
    no version boundary exists to gate against (spec D11).
- **Specialist owner:** devops-engineer
- **Revisit criterion:** If the suite adopts ref-pinned or tag-pinned marketplace sources, the atomicity unit shifts
  from the merge to the tag and this decision reopens.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (R1c, JD-3), R2 (OQ-1r confirmed)
- **Dependent decisions:** D-5, D-6
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Operational Readiness

### D-2: Entity-name-scoped repo-wide grep drives every namespace rewrite

- **Question:** How are the `han-core:{skill}` and `han-core:{agent}` references rewritten to their new namespaces
  without breaking references to entities that stay in han-core?
- **Decision:** Every namespace rewrite is scoped by the specific moving entity name across a repo-wide search, never by
  a blunt `han-core:` prefix replace and never by a plugin-scoped sweep. Each moved entity gets its own search term, and
  the searches cover the whole repository, not only the surfaces the spec named.
- **Rationale:** A single file mixes moving and staying references, so a prefix-level replace would mis-point staying
  agents. References also live outside the spec's named blast radius, so a plugin-scoped sweep would miss them. Only a
  per-entity, repo-wide search resolves both hazards.
- **Evidence:** `research/SKILL.md` mixes moving `han-core:research-analyst` refs with staying
  `han-core:codebase-explorer` and `han-core:adversarial-validator` refs (S2); `docs/agents/research-analyst.md:54`
  carries a self-reference that also rewrites (S2); the gap-analysis report template frontmatter self-identifies as
  `generated_by: "han-core:gap-analysis"` outside the link sweeps (S3, `gap-analysis/references/gap-analysis-report-template.md:6`);
  han-plugin-builder guidance cites `han-core:project-documentation` outside the named blast radius (S5,
  `skill-composition.md:34`); han-atlassian's wrapper carries about seven prose refs beyond the one E7 invocation line
  plus a stale install sentence and a project-discovery link sharing the moving siblings' path prefix (S4).
- **Rejected alternatives:**
  - Blanket replace `han-core:` prefixes — rejected because it would re-point staying agents in the same files as
    moving ones (S2).
  - Sweep only the spec's named surfaces — rejected because the han-plugin-builder guidance reference proves refs exist
    outside that set (S5).
- **Specialist owner:** structural-analyst
- **Revisit criterion:** If a future move adds an entity whose name is a substring of another entity's name, the search
  terms need word-boundary anchoring and this method reopens.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (S2, S3, S4, S5)
- **Dependent decisions:** D-9
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Testing Strategy

### D-3: Each moved skill is one atomic multi-artifact unit

- **Question:** What exactly moves when a skill moves, and what enforces the pairing?
- **Decision:** Each moved skill is treated as a bundle of two to four artifacts that move together: the skill directory
  (including its `references/`), its long-form doc, and, for the research skill only, the research-analyst agent
  definition plus that agent's long-form doc. Nothing in the repository enforces the pairing automatically, so the plan
  carries it as an explicit move unit.
- **Rationale:** A skill split from its references or its long-form doc is a broken move, and no build step or test
  catches it. Naming the unit per skill makes the completeness of each move checkable by hand.
- **Evidence:** Directory listings confirm each skill carries a `references/` folder (gap-analysis confirmed) and a
  matching long-form doc; research-analyst is the one agent that moves, with its definition and its doc (S1;
  investigation D4/E10).
- **Rejected alternatives:**
  - Move skill directories only and reconcile docs in a later pass — rejected because the long-form docs carry the
    agent links that must be rewritten in the same change (D-7), so splitting them fractures the atomic merge (D-1).
- **Specialist owner:** structural-analyst
- **Revisit criterion:** If an automated move-and-verify script is introduced, the manual per-unit tracking this
  decision commits can be replaced.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (S1)
- **Dependent decisions:** D-7
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing

### D-4: Codex manifests get content re-authoring, not dependency edits

- **Question:** What changes in the `.codex-plugin/plugin.json` manifests, and do dependency drops touch them?
- **Decision:** Codex manifests are re-authored for their prose, keywords, and prompt content wherever they name a
  moving skill, and the two new plugins each get a new codex manifest. No dependency edit touches any codex manifest;
  every dependency change lands only in the `.claude-plugin/plugin.json` manifests.
- **Rationale:** han-core's codex manifest names moving skills in content fields, so the fix is content authoring rather
  than link surgery. Separately, a grep across all nine codex manifests found none carries a `dependencies` field, so
  the dependency drops and additions have no codex surface to mirror.
- **Evidence:** han-core `.codex-plugin` keywords include "documentation" and all three `defaultPrompt` entries name
  moving skills (S11, V3); no codex manifest carries a `dependencies` field (OQ-4r, grep across all nine returned none).
- **Rejected alternatives:**
  - Mirror the dependency edits into the codex manifests for symmetry — rejected because no codex manifest declares
    dependencies, so there is nothing to mirror and the edit would invent a field (OQ-4r).
- **Specialist owner:** structural-analyst
- **Revisit criterion:** If the codex manifest format gains a `dependencies` field, the dependency edits must extend to
  it and this decision reopens.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (S11), R2 (OQ-4r)
- **Dependent decisions:** D-5
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing

### D-5: A single co-land manifest set passes one pre-merge consistency sweep

- **Question:** Which manifests must change together to hold the spec's catalog invariant, and how is that invariant
  checked before merge?
- **Decision:** The manifest changes land as one co-land set and are checked by a single scripted consistency sweep
  before the merge. The set is: two new plugin entries (marketplace plus both manifest platforms), the han-core and
  re-pointed plugin descriptions, the han meta-plugin dependency additions, the han-atlassian dependency addition, and
  the three vestigial dependency drops. The same prose facts that live in each plugin's `plugin.json` description, its
  README, and marketplace.json are edited together, because a jq check catches manifest disagreement but not prose
  drift.
- **Rationale:** The spec's catalog invariant forbids advertising an uninstallable bundled plugin or naming a plugin
  absent from the catalog (spec D13). A one-shot check over the co-land set, run before merge, is the cheapest way to
  prove the invariant holds at the moment of the atomic merge (D-1).
- **Evidence:** Enumerated co-land set and the one-shot jq consistency sweep (R2c); han-atlassian's wrapper invocation
  rewrite must co-land or the atlassian upgrade shape fails OI-1 (R3c, `SKILL.md:50`); bundled-set and han-core-contents
  facts are prose-duplicated across plugin.json description, README, and marketplace.json, and the primary-platform
  manifest descriptions enumerate moving skills too (S8/JD-7, marketplace.json, `han/.claude-plugin/plugin.json`).
- **Rejected alternatives:**
  - Check only the two manifest platforms with jq and leave prose to review — rejected because the same facts live in
    README and marketplace prose that jq does not parse, so drift would survive the check (S8/JD-7).
- **Specialist owner:** devops-engineer
- **Revisit criterion:** If an automated catalog-consistency linter lands in CI, the manual pre-merge sweep is
  superseded.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (R2c, R3c, S8/JD-7)
- **Dependent decisions:** D-6
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Testing Strategy, Operational Readiness
- **Depends on:** D-1, D-4

### D-6: OI-1 verification runs a concrete per-shape install-and-revert procedure

- **Question:** What concrete procedure satisfies the spec's OI-1 release gate, and how is the re-fetch unknown handled?
- **Decision:** OI-1 is verified by a concrete procedure: add a local marketplace pointing at a checkout, install each
  of the four spec shapes, capture the invocable skill and dispatchable agent set, upgrade, and diff the result against
  the spec's commitment for that shape. The first assertion of the procedure tests whether `/plugin update` re-fetches
  content when catalog versions are unchanged. The same run verifies recovery by reverting the merge with
  `git revert -m 1` and confirming the prior working set returns on next resolve.
- **Rationale:** The spec's OI-1 named a pass condition but no runnable procedure. Whether `/plugin update` re-fetches
  on unchanged versions cannot be answered by static inspection, so it becomes the procedure's first assertion rather
  than a separate open question; if it no-ops, effective release happens at the han-release version bump. Because the
  change is pure markdown and JSON, a merge revert is a complete recovery, matching the spec's "on next resolve"
  recovery language.
- **Evidence:** Concrete procedure grounded in the install docs (R4c/JD-1); the re-fetch behavior is unknowable
  statically and folds in as the first assertion (R5c/JD-2, reconciling spec D11 and D13); merge revert is a complete
  recovery for a markdown-and-JSON change, recovery is "on next resolve" (R6c); this stays inside the spec's OI-1
  rather than opening a new item (OQ-2r, `feature-specification.md#open-items`).
- **Rejected alternatives:**
  - Treat re-fetch behavior as a new open question blocking the plan — rejected because it is unknowable statically and
    the spec's OI-1 already exists to verify resolver behavior against a real install (OQ-2r).
  - Verify only the full-`han` upgrade shape — rejected because the standalone han-core and han-atlassian shapes fail
    differently and are the least protected (spec D13, F5).
- **Specialist owner:** devops-engineer
- **Revisit criterion:** If the first assertion shows `/plugin update` does not re-fetch on unchanged versions, the
  release gate moves to the han-release version bump and the procedure's release-timing step reopens.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (R4c/JD-1, R5c/JD-2, R6c), R2 (OQ-2r folded in as first assertion)
- **Dependent decisions:** —
- **Referenced in plan:** Operational Readiness, Definition of Done, Open Items, Risks and Assumptions
- **Depends on:** D-1, D-5

### D-7: Moved-doc agent links are rewritten per-entity, sparing the one link that moves

- **Question:** How many relative agent-doc links break in the moved long-form docs, and which must not be rewritten?
- **Decision:** The six moving long-form docs carry 23 relative `](../agents/...)` links; 22 rewrite to the
  cross-plugin form `../../../han-core/docs/agents/{name}.md`, and one is left relative. The single exception is
  research.md's link to research-analyst, which stays relative because research-analyst moves with the doc into
  han-research.
- **Rationale:** Every link targeting an agent that stays in han-core must become a cross-plugin link once the doc
  leaves han-core, following the pattern han-core's own agent docs already use. The one link whose target moves with the
  doc stays relative, because rewriting it would point a co-located doc out of its own plugin.
- **Evidence:** Per-file recount found 23 links across the six docs (project-documentation 3, architectural-decision-record
  5, runbook 5, research 3, gap-analysis 7, issue-triage 0), 22 rewrite and research.md's research-analyst link stays
  (JD-6r, `grep -c` per file); the original count of "~19" under-counted (JD-6); every rewritten link targets an agent
  the plan keeps in han-core (V2).
- **Rejected alternatives:**
  - Rewrite all 23 links to the cross-plugin form — rejected because research.md's research-analyst link moves with the
    doc and would then point out of its own plugin (JD-6r).
- **Specialist owner:** structural-analyst
- **Revisit criterion:** If more agents move out of han-core alongside their skills in a future pass, the count and the
  set of relative-vs-cross-plugin links must be recomputed.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (JD-6), R2 (JD-6r recount)
- **Dependent decisions:** —
- **Referenced in plan:** Work Units and Sequencing, Testing Strategy
- **Depends on:** D-3

### D-8: Reconciliation corrects stale surfaces, including three false README claims

- **Question:** Which reader-facing surfaces carry claims the split makes false, beyond the additive relinking the spec
  already committed?
- **Decision:** The reconciliation corrects stale statements, not only additions. That includes the false "its skills
  dispatch shared han-core agents" claim on three plugin READMEs (han-reporting, han-linear, han-feedback), the two
  docs/agents index prose lines that assert han-core owns every agent but readability-editor, and the three
  dependency-prose corrections in docs/concepts.md, on top of the surfaces the spec's D10 already names.
- **Rationale:** The spec's D10 committed to correcting stale surfaces but the review found the false-dispatch claim on
  three READMEs, not one, plus two index and three concepts surfaces the spec had not enumerated. A surface that
  contradicts the shipped layout misdirects the exact audience it exists for.
- **Evidence:** The false claim exists on three READMEs (han-reporting:20, han-linear:16, han-feedback:15), while four
  keeper plugins retain the line legitimately (S6/IA-1, grep across READMEs); docs/agents/README.md prose (lines 4, 14)
  asserts han-core owns all agents but readability-editor, false once research-analyst moves, plus a row repoint at
  line 55 (IA-2); docs/concepts.md:217-234 carries three dependency-prose corrections beyond link repoints (IA-3);
  spec D10 and investigation E14/V3/V4 for the named surfaces.
- **Rejected alternatives:**
  - Correct only han-reporting's README claim (the one the spec named) — rejected because the identical false claim sits
    on two more READMEs and would ship false (S6/IA-1).
- **Specialist owner:** information-architect
- **Revisit criterion:** If a later surface audit finds an additional stale layout claim, it joins this reconciliation
  set.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (S6/IA-1, IA-2, IA-3)
- **Dependent decisions:** D-9
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing
- **Depends on:** D-10

### D-9: Five grep sweeps are the acceptance artifact for surface reconciliation

- **Question:** What mechanizes the "indexes stay complete, not counted" convention when no automated link checker
  exists?
- **Decision:** Five repo-wide grep sweeps are the acceptance artifact that proves the reconciliation is complete. They
  provide a canonical, runnable search-term list covering the moved entities, their old namespaces, the stale claim
  lines, and the agent-doc links, so completeness is demonstrated by a passing search rather than by a manual count.
- **Rationale:** CLAUDE.md's convention requires complete indexes but the repo carries no automated link checker or
  manifest validator, so verification is manual. A fixed set of grep sweeps turns "did we get everything" into a
  reproducible check any implementer can run.
- **Evidence:** The five verification grep sweeps mechanize "indexes stay complete, not counted" over the WU-A..WU-F
  surface inventory (IA-inv); the sweep needs a canonical runnable search-term list as an acceptance artifact (JD-4);
  discovery notes confirm no automated link checker or CI manifest validation exists.
- **Rejected alternatives:**
  - Verify reconciliation by manual review of the surface inventory — rejected because a manual pass over dozens of
    file:line targets is exactly the error-prone step the sweeps replace (JD-4).
- **Specialist owner:** information-architect
- **Revisit criterion:** If an automated link checker or manifest validator lands in CI, the manual grep sweeps are
  superseded.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (IA-inv, JD-4)
- **Dependent decisions:** —
- **Referenced in plan:** Testing Strategy, Definition of Done
- **Depends on:** D-2, D-8

### D-10: han-research presents as pre-planning knowledge work across its reader surfaces

- **Question:** How does han-research's naming avoid under-predicting gap-analysis and issue-triage?
- **Decision:** han-research's reader-facing surfaces (README frame, scent line, and marketplace description) present the
  plugin as pre-planning knowledge work, so all three of its skills are predictable from its scent line. The scent lines
  reuse each skill's long-form summary line, and marketplace descriptions are drafted for both new plugins. Nothing is
  renamed.
- **Rationale:** "han-research" names one of its three skills, so a user hunting for triage or gap comparison has no
  scent reason to open it. Framing the plugin by its whole domain restores predictability without a rename, honoring
  spec D9's names-are-stable rule.
- **Evidence:** han-research README frame "pre-planning knowledge work" with scent lines reusing long-form summary lines,
  and drafted marketplace descriptions for both new plugins (IA-scent); spec F7 and spec D2 commit the framing.
- **Rejected alternatives:**
  - Rename the plugin or its skills to advertise all three domains — rejected because spec D9 keeps every name stable
    and renames would break bare-name references (spec D9).
- **Specialist owner:** information-architect
- **Revisit criterion:** If a fourth skill joins han-research whose work is not pre-planning knowledge, the scent frame
  reopens.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (IA-scent)
- **Dependent decisions:** D-8
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing
- **Depends on:** —

### D-11: The release-notes namespace map is handed to han-release

- **Question:** Where does the old-to-new namespace map and per-skill restore step get produced?
- **Decision:** The release-notes deliverable is the old-to-new namespace map plus a restore step per moved skill, and it
  is handed to the han-release skill at release time. It is not a CHANGELOG edit made inside this restructure.
- **Rationale:** Release notes and versioning belong to the release process (spec D11), not the restructure. The
  restructure produces the content han-release needs; han-release publishes it. This keeps the restructure's atomic
  merge free of release-time artifacts.
- **Evidence:** The release-notes deliverable is the old-to-new namespace map plus restore step per moved skill, handed
  to han-release rather than edited here (R7c); spec OI-2 and spec D11 place release notes in the release process.
- **Rejected alternatives:**
  - Write the namespace map into CHANGELOG.md as part of this restructure — rejected because versioning and release
    notes belong to han-release, not this change (spec D11, R7c).
- **Specialist owner:** devops-engineer
- **Revisit criterion:** If the suite stops running releases through han-release, this handoff target reopens.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1 (R7c)
- **Dependent decisions:** —
- **Referenced in plan:** Open Items, Specialist Handoffs for Implementation
