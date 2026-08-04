# Implementation Decision Log: Plugin-Centric Documentation Reorganization

<!--
This file records every implementation decision committed while planning the plugin-centric documentation
reorganization. Behavioral and implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md).
This file captures the question, rationale, evidence, and rejected alternatives for each decision. Round-by-round history
lives in [implementation-iteration-history.md](implementation-iteration-history.md).

These implementation decisions are numbered D-1 through D-8 (with hyphen). They are distinct from the spec's inherited
decisions D1 through D18 (no hyphen), which live in [decision-log.md](decision-log.md). The spec decisions are settled
ground truth for WHAT; the decisions below plan the HOW.
-->

## Trivial decisions

- D-7: Light front-door README skeleton for all 11 READMEs. Every README follows one fixed shape assembled from settled
  spec decisions: an H1 plus a one-paragraph what/how/why ([D3](decision-log.md#d3-per-plugin-readme-is-the-canonical-plugin-front-door)),
  a bundled-vs-opt-in line naming dependencies and any required MCP server ([D13](decision-log.md#d13-plugin-readme-states-bundled-vs-opt-in-and-dependencies)),
  a scent-line skills list reusing each long-form doc's canonical summary line ([D15](decision-log.md#d15-the-long-form-summary-line-is-the-canonical-scent))
  with `han-core` grouped by purpose ([D12](decision-log.md#trivial-decisions)) and the others flat, an owned-agents
  scent list for `han-core` and `han-communication` only with the shared-agent-dispatch note for the other eight
  ([D8](decision-log.md#d8-plugins-without-agents-note-shared-agent-dispatch)), and lateral navigation up to the plugin
  index and root and across to workflows ([D14](decision-log.md#d14-in-plugin-docs-link-up-to-their-plugin-readme)); the
  `han` meta-plugin omits the skills and agents sections ([D17](decision-log.md#d17-the-meta-plugin-readme-omits-skills-and-agents-sections)).
  No alternative is worth discussing, because the shape is the composition of the spec's commitments. Referenced in plan:
  Implementation Approach (README and Index Authoring Model).

## Full decisions

### D-1: Dependency-tiered sequencing

- **Question:** In what order does the work run so the change never passes through a self-inflicted broken-link state?
- **Decision:** Execute the work in dependency tiers, each producing a link target before anything that points at it is
  rewritten. The order is: (1) rewrite the standards that touch no targets, meaning the plugin-README standard and
  template to the light model ([D18](decision-log.md#d18-the-plugin-readme-standard-and-template-move-to-the-light-model))
  and the skill and agent long-form templates plus the coverage rule to the new paths and the new up-link convention
  ([D14](decision-log.md#d14-in-plugin-docs-link-up-to-their-plugin-readme)); (2) move the 62 long-form docs and recompute
  each moved doc's own outbound links in the same step ([D16](decision-log.md#d16-link-integrity-is-the-acceptance-gate));
  (3) author the 10 fresh plugin READMEs and rewrite `han/README.md`; (4) create `docs/workflows.md`; (5) slim the two
  indexes to alphabetized link lists that cross-link workflows and label the plugin index; (6) convert
  `docs/choosing-a-han-plugin.md` to the scent-and-link plugin index ([D4](decision-log.md#d4-the-choosing-doc-becomes-the-plugin-index));
  (7) update the D9 blast radius to the new paths and the workflows and plugin-index labels; (8) run the verification gate
  ([D-4](implementation-decision-log.md#d-4-three-pass-one-time-link-verification-gate)). Tiers 1 and 3 are hard
  prerequisites for tier 2: authoring READMEs against the on-disk heavy standard reproduces the duplication the reorg
  removes, and moving docs before their plugin READMEs exist leaves each moved doc's first up-link
  ([D14](decision-log.md#d14-in-plugin-docs-link-up-to-their-plugin-readme)) pointing at a missing file.
- **Rationale:** The change simultaneously moves 62 docs, creates 11 new link targets, and rewrites roughly 37 referrers.
  A link target must exist at its final path before any referrer is rewritten, and a doc must sit at its new path before
  its canonical scent is copied outward. A tiered order makes that invariant the shape of the work rather than a hope.
- **Evidence:** [D16](decision-log.md#d16-link-integrity-is-the-acceptance-gate) makes zero-unresolved-links the
  acceptance gate; [D9](decision-log.md#d9-layout-descriptions-standards-and-tooling-updated) sizes the referrer set at
  about 37 files; [D15](decision-log.md#d15-the-long-form-summary-line-is-the-canonical-scent) makes the moved doc the
  source of the scent copied outward; finding F3 (team-findings.md) established that outbound relative links break too;
  `docs/plugin-readme.md:107-146` still mandates the heavy Skills Reference that
  [D3](decision-log.md#d3-per-plugin-readme-is-the-canonical-plugin-front-door) and
  [D18](decision-log.md#d18-the-plugin-readme-standard-and-template-move-to-the-light-model) forbid; information-architect
  finding IA-IMPL-1 and junior-developer findings JD-2 and JD-3 (R1).
- **Rejected alternatives:**
  - Rewrite referrers or copy scent lines before the targets exist at their final paths: rejected because it produces
    broken links the D16 gate would then have to chase backward, and the scent copies would drift from a doc that had not
    yet moved.
- **Specialist owner:** information-architect
- **Revisit criterion:** A dependency between tiers is discovered that the ordering above does not honor (for example, a
  standard that itself links a not-yet-moved doc), forcing a re-sequence.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-2, D-3, D-4
- **Referenced in plan:** Implementation Approach (Documentation Layout: From-State to To-State), Decomposition and
  Sequencing

### D-2: Land the reorganization as one atomic change

- **Question:** Can the change ship in per-plugin stages, or must it land as one unit?
- **Decision:** The moves, the full D9 blast-radius link updates, the 11 READMEs the moved docs up-link to, and
  `docs/workflows.md` with its inbound links all land as one atomic change (one PR, or a stack merged together), so the
  default branch never shows a broken-link state.
- **Rationale:** The cross-plugin link web does not decompose per plugin: moving one plugin's docs breaks inbound links
  from other plugins' docs, and there is no link checker in CI to fail a half-done state. Per-plugin staging would leave
  cross-plugin links broken between merges and silently ship them on the default branch. `docs/workflows.md` looks
  additive, but the root README, both indexes, and the plugin index must link into it
  ([D6](decision-log.md#d6-composition-scenarios-and-diagrams-move-to-a-workflows-doc),
  [D-8](implementation-decision-log.md#d-8-workflows-page-gets-four-inbound-links)), so it must exist in the same change
  as those inbound links. The effective smallest safe unit is the whole reorganization.
- **Evidence:** the link-topology mapping table (.discovery-notes.md) showing cross-plugin references; the discovery
  finding that no internal-link checker exists anywhere in the repo (.discovery-notes.md, Tech stack); D6, D8, and finding
  F8 requiring inbound links to workflows; junior-developer finding JD-3 (R1).
- **Rejected alternatives:**
  - Stage the change per plugin across several PRs: rejected because the cross-plugin link web plus the absent CI link
    checker means each intermediate merge ships broken links on the default branch that no build catches.
- **Specialist owner:** information-architect
- **Revisit criterion:** A CI internal-link checker lands that fails the build on any unresolved link, making an
  intermediate broken state visible and blockable; per-plugin staging could then be reconsidered.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Decomposition and Sequencing, RAID Log (Risks)

### D-3: One-time throwaway migration script

- **Question:** How are the roughly 1,500 to 2,500 relative-link edits across 62 moved docs performed safely?
- **Decision:** A one-time migration script owns the full move-map and recomputes every relative link by the mechanic
  resolve-each-link-to-an-absolute-repo-path-then-re-express-it-relative-to-the-doc's-new-location. For each link it
  resolves the target from the doc's old location to an absolute repo path, checks whether that target is itself in the
  moving set and where it lands, and re-expresses the link from the doc's new location. The script's file selection
  excludes the frozen `docs/plans/**` and `docs/research/**` archives ([D10](decision-log.md#trivial-decisions)) and
  `CHANGELOG.md` ([D-5](implementation-decision-log.md#d-5-changelogmd-stays-frozen-and-out-of-the-link-gate)). The
  script is throwaway: it is run and verified, not committed as suite tooling.
- **Rationale:** A naive `git mv` plus a find-and-replace on each doc's own path misses every outbound relative link
  inside the moved file, and it cannot handle a target that also moved. The resolve-to-absolute-then-recompute mechanic
  handles the compounding case where both the doc and its target move. At the measured edit scale hand-editing is
  error-prone and un-reviewable, so the script is load-bearing; it is not permanent tooling, because routine doc moves
  are not a recurring workload.
- **Evidence:** [D16](decision-log.md#d16-link-integrity-is-the-acceptance-gate) rejects naive path substitution because
  it "misses every outbound relative link inside the roughly seventy moved files"; the measured link counts (39 links in
  `docs/skills/han-coding/code-review.md`, 21 in `docs/agents/han-core/project-manager.md`) and the per-category
  recomputation table (.discovery-notes.md); junior-developer finding JD-1 (R1).
- **Rejected alternatives:**
  - Naive `git mv` plus find-and-replace on each doc's own path: rejected because it leaves every outbound relative link
    broken and does not account for targets that also moved ([D16](decision-log.md#d16-link-integrity-is-the-acceptance-gate)).
  - Commit the script as permanent suite tooling: rejected because routine doc moves are not a recurring workload, so a
    maintained tool is not justified by evidence.
- **Specialist owner:** junior-developer
- **Revisit criterion:** Doc-move reorganizations become a routine, recurring operation, justifying a maintained migration
  tool.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-4, D-5
- **Referenced in plan:** Implementation Approach (Link Topology and Recomputation), Decomposition and Sequencing,
  Testing Strategy

### D-4: Three-pass one-time link-verification gate

- **Question:** What verification satisfies the D16 acceptance gate, given no link checker exists in the repo?
- **Decision:** The D16 gate runs as three one-time passes over the active (non-frozen) Markdown set at the end of the
  change: (1) a relative-link resolver confirming every `](path)` resolves to a file that exists; (2) a literal-string
  grep for `docs/skills/` and `docs/agents/` across active files, catching absolute GitHub blob URLs and any missed
  references a relative resolver cannot see; (3) an orphan pass confirming every moved long-form doc is linked from at
  least its plugin README or an index, and that `docs/workflows.md` has its four inbound links
  ([D-8](implementation-decision-log.md#d-8-workflows-page-gets-four-inbound-links)). File selection for all three passes
  excludes the frozen archives ([D10](decision-log.md#trivial-decisions)) and `CHANGELOG.md`
  ([D-5](implementation-decision-log.md#d-5-changelogmd-stays-frozen-and-out-of-the-link-gate)). The gate is a one-time
  acceptance condition, not permanent CI tooling.
- **Rationale:** A relative-link resolver alone proves every relative link points at a real file but cannot detect two
  real failure modes: an absolute GitHub blob URL that is syntactically valid but 404s after the move (the one in the PR
  template), and a moved doc that nothing points at. The literal-string grep catches the first; the orphan pass catches
  the second. D16's wording asks the check to pass once, so a one-time scripted pass satisfies it; a permanent CI checker
  is not justified by cited evidence.
- **Evidence:** [D16](decision-log.md#d16-link-integrity-is-the-acceptance-gate) wording ("complete only when a
  repository-wide internal-link check passes with zero unresolved links"); the no-link-checker gap (.discovery-notes.md,
  Tech stack); the absolute blob URL at `.github/pull_request_template.md:5`; finding F8 (near-orphan risk for the
  workflows page); information-architect findings IA-IMPL-7 and IA-IMPL-9 and junior-developer finding JD-4 (R1).
- **Rejected alternatives:**
  - A relative-link resolver alone: rejected because it misses absolute blob URLs (`.github/pull_request_template.md:5`)
    and orphaned docs.
  - A permanent CI link-checker: rejected under YAGNI because D16 asks the check to pass once and no ongoing link-rot is
    cited; deferred (see the plan's Deferred (YAGNI) section).
- **Specialist owner:** information-architect
- **Revisit criterion:** Recurring broken-link regressions appear after merge, or the maintainers commit to enforcing
  link integrity on every PR or to the deferred documentation site, any of which would justify a permanent CI checker and
  pull in `devops-engineer`.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-5, D-6
- **Referenced in plan:** Testing Strategy, Definition of Done

### D-5: CHANGELOG.md stays frozen and out of the link gate

- **Question:** Is `CHANGELOG.md` in scope for path rewriting, or frozen like the plan and research archives?
- **Decision:** `CHANGELOG.md` is treated as a frozen point-in-time record. Its historical old-path references are left
  as-is, and it is excluded from both the rewrite set and the literal-string link gate, so its expected old-path strings
  are not read as failures.
- **Rationale:** A changelog is a point-in-time record by definition, so the same freeze rationale that keeps the plan and
  research archives unchanged applies to it. Rewriting a historical release entry's paths to files that did not exist at
  that release would falsify the record. The maintenance tooling already treats the changelog as out of scope, so the
  freeze aligns the reorg with the established convention.
- **Evidence:** [D10](decision-log.md#trivial-decisions) freezes point-in-time archives and leaves their stale paths
  unrewritten; the maintenance tooling maps `CHANGELOG.md` to "ignore (out of scope)" at
  `.claude/skills/han-update-documentation/references/scope-mapping.md:36`; the PR template itself records that
  `CHANGELOG.md` is owned by `/han-release`, not by content PRs (`.github/pull_request_template.md:12`); resolved by
  evidence in R1 as OQ-1.
- **Rejected alternatives:**
  - Rewrite `CHANGELOG.md`'s historical old-path references to the new locations: rejected because it falsifies a
    point-in-time record and contradicts the tooling's existing out-of-scope mapping.
  - Leave `CHANGELOG.md` in the link gate but frozen for edits: rejected because its expected old-path strings would trip
    the literal-string grep as false failures.
- **Specialist owner:** junior-developer
- **Revisit criterion:** A maintainer decides the changelog should track live doc paths, or `/han-release` starts
  generating changelog entries with current-path links.
- **Dissent (if any):** None. The user can override this scope call; it is recorded as a decision, not a silent omission.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Implementation Approach (Link Topology and Recomputation), Testing Strategy

### D-6: PR template joins the D9 set and the scan covers .github

- **Question:** Is `.github/pull_request_template.md` in the D9 update set, and does the regenerated blast-radius scan
  reach it?
- **Decision:** `.github/pull_request_template.md` is added explicitly to the D9 update set, and the regenerated
  implementation-time scan must cover `.github/`, not `docs/` alone. The template's live old-path contributor guidance is
  updated to the new in-plugin locations, and its absolute GitHub blob URL is updated to the moved doc's new path.
- **Rationale:** The PR template carries active contributor guidance pointing at the old `docs/skills/{plugin}/{name}.md`
  paths and an absolute blob URL to a moved doc. D9 names about 37 files but does not name the template, and a scan scoped
  to `docs/` would miss it. Naming it explicitly and widening the scan closes that gap.
- **Evidence:** live old-path guidance at `.github/pull_request_template.md:5,20` (the blob URL to
  `docs/skills/han-github/update-pr-description.md` and the coverage-rule checklist naming `docs/skills/{plugin}/{name}.md`);
  [D9](decision-log.md#d9-layout-descriptions-standards-and-tooling-updated) requiring the scan be regenerated at
  implementation time; junior-developer finding JD-5 (R1).
- **Rejected alternatives:**
  - Rely on D9's scan as written to catch the template implicitly: rejected because D9's enumerated evidence never names
    it and a `docs/`-scoped scan would miss a file under `.github/`.
- **Specialist owner:** junior-developer
- **Revisit criterion:** The blast-radius scan is regenerated at implementation time and returns no reference under
  `.github/`, making the explicit inclusion unnecessary.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Implementation Approach (Documentation Layout: From-State to To-State), Testing Strategy

### D-8: Workflows page gets four inbound links

- **Question:** How many surfaces link into `docs/workflows.md`, and does any per-doc linking get added?
- **Decision:** `docs/workflows.md` receives exactly four inbound links: from the root README, the skills index, the
  agents index, and the plugin index. No per-doc "see workflows" links are added to the 62 long-form docs.
- **Rationale:** Four inbound links from the catalog surfaces satisfy the F8 anti-orphan requirement and keep the page
  reachable from every place a reader browses the catalog. Adding a workflows link to all 62 long-form docs is 62 edits
  of ongoing maintenance for no cited findability need, so the simpler four-surface set satisfies the same evidence.
- **Evidence:** finding F8 requiring the root README, both indexes, and the plugin index to link the workflows page;
  [D6](decision-log.md#d6-composition-scenarios-and-diagrams-move-to-a-workflows-doc); information-architect finding
  IA-IMPL-2 (R1).
- **Rejected alternatives:**
  - Add a "see workflows" link to each of the 62 long-form docs: rejected because it fails the YAGNI evidence test, being
    62 ongoing edits with no cited findability need beyond what the four catalog surfaces already provide.
- **Specialist owner:** information-architect
- **Revisit criterion:** A reader-navigation gap surfaces where readers deep in a long-form doc cannot find the
  composition view, justifying additional inbound links.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Implementation Approach (Navigation Invariants), Decomposition and Sequencing
