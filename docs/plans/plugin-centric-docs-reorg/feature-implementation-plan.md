# Feature Implementation Plan: Plugin-Centric Documentation Reorganization

This plan moves 62 long-form docs into their plugins, authors 11 plugin READMEs, slims two indexes, converts the
choosing doc into a plugin index, and adds a workflows page. It is documentation-only: no skill or agent behavior
changes. The implementation posture is one atomic change, sequenced in dependency tiers, verified once against a
zero-broken-links gate.

## Source Specification

- **Feature specification:** [feature-specification.md](feature-specification.md)
- **Specification decision log:** [artifacts/decision-log.md](artifacts/decision-log.md)
- **Specification team findings:** [artifacts/team-findings.md](artifacts/team-findings.md)
- **Specification technical notes:** [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
- **Specification decisions this plan inherits:** D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D16,
  D17, D18
- **Specification open items this plan must respect or resolve:** OI-1

## Outcome

When this plan is executed, every Han plugin folder carries a light front-door `README.md`, and every skill and agent
long-form doc sits inside the plugin it describes at `{plugin}/docs/skills/{name}.md` or `{plugin}/docs/agents/{name}.md`
([D1](artifacts/decision-log.md#d1-long-form-docs-move-into-each-plugin-directory)). The skills index and agents index
remain at `docs/skills/README.md` and `docs/agents/README.md` but shrink to alphabetized link lists
([D5](artifacts/decision-log.md#d5-indexes-shrink-to-alphabetized-link-lists)). `docs/choosing-a-han-plugin.md` becomes
the plugin index ([D4](artifacts/decision-log.md#d4-the-choosing-doc-becomes-the-plugin-index)), and a new
`docs/workflows.md` renders its composition diagrams on GitHub with no build step
([D6](artifacts/decision-log.md#d6-composition-scenarios-and-diagrams-move-to-a-workflows-doc),
[T1](artifacts/feature-technical-notes.md#t1-github-renders-mermaid-fenced-blocks-natively)). Every internal link
resolves ([D16](artifacts/decision-log.md#d16-link-integrity-is-the-acceptance-gate)).

## Context

- **Driving constraint:** Issue #115 asks for plugin-first documentation so a reader can start at any plugin folder and
  understand that plugin on its own. The current layout gathers every long-form doc in a central `docs/` tree away from
  the plugins, and three surfaces restate each plugin's purpose.
- **Stakeholders:** Readers browsing the repository on GitHub want plugin-local orientation. Contributors want one
  unambiguous place a new doc goes and one README shape to follow. AI coding agents read the layout description and
  indexes to route work; stale descriptions misroute them.
- **Future-state concern:** After the move, each skill's scent lives in three places (long-form doc, plugin README,
  index). The canonical-scent rule ([D15](artifacts/decision-log.md#d15-the-long-form-summary-line-is-the-canonical-scent))
  keeps them aligned as a behavioral rule with no tooling; watch for scent drift over time.
- **Out-of-scope boundary:** No rendered documentation site
  ([Deferred YAGNI](feature-specification.md#deferred-yagni)), no rewrite of the frozen `docs/plans/` and `docs/research/`
  archives ([D10](artifacts/decision-log.md#trivial-decisions)), and no skill or agent behavior change
  ([D11](artifacts/decision-log.md#trivial-decisions)).

## Team Composition and Participation

| Specialist              | Status      | Key Input                                                                                                                          |
| ----------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `project-manager`       | Coordinator | Reserved for synthesis; the spec-maturity gate did not trip, so no facilitation round ran.                                        |
| `information-architect` | Active      | Create-targets-before-referrers ordering, three-index labeling, README skeleton, navigation invariants, orphan-pass gate (IA-IMPL-1 through 9). |
| `junior-developer`      | Active      | Safe link-recompute mechanic and migration script, README ordering traps, atomic-PR unit, three-pass gate, CHANGELOG and PR-template scope (JD-1 through 5). |

## Implementation Approach

The implementation is a file move plus link recomputation plus README and index authoring. It touches no application
code. The crux is link integrity: moving 62 docs breaks both the links pointing at them and the relative links inside
them, and there is no link checker in the repository to catch a half-done state. The work therefore runs in dependency
tiers and lands as one atomic change ([D-1](artifacts/implementation-decision-log.md#d-1-dependency-tiered-sequencing),
[D-2](artifacts/implementation-decision-log.md#d-2-land-the-reorganization-as-one-atomic-change)).

The template's Data Model, Runtime Behavior, and External Interfaces subsections are omitted below: a docs move has no
schema, no runtime call path, and no external contract. The subsections that follow are the ones this change touches.

### Documentation Layout: From-State to To-State

The from-state gathers 62 long-form docs under the repo-root `docs/` tree: 38 skill docs at
`docs/skills/{plugin}/{name}.md` across 10 plugins and 24 agent docs at `docs/agents/{plugin}/{name}.md` across
`han-core` (23) and `han-communication` (1). The to-state moves each doc to `{plugin}/docs/skills/{name}.md` or
`{plugin}/docs/agents/{name}.md`, beside that plugin's README
([D1](artifacts/decision-log.md#d1-long-form-docs-move-into-each-plugin-directory)). Only `han-core` and
`han-communication` gain a `docs/agents/` subfolder. The moved docs ship inside the installed plugin the same way the
README does and are not loaded by the plugin system.

Two index READMEs stay in place and transform to alphabetized link lists
([D5](artifacts/decision-log.md#d5-indexes-shrink-to-alphabetized-link-lists)). The choosing doc converts to the plugin
index ([D4](artifacts/decision-log.md#d4-the-choosing-doc-becomes-the-plugin-index)). One new page,
`docs/workflows.md`, is created ([D6](artifacts/decision-log.md#d6-composition-scenarios-and-diagrams-move-to-a-workflows-doc)).

The layout descriptions, authoring standards, and tooling that name the old paths are updated across the D9 blast radius
([D9](artifacts/decision-log.md#d9-layout-descriptions-standards-and-tooling-updated)). The scan is regenerated at
implementation time and must cover `.github/`, so `.github/pull_request_template.md` is updated with the rest
([D-6](artifacts/implementation-decision-log.md#d-6-pr-template-joins-the-d9-set-and-the-scan-covers-github)). The exact
update set is enumerated in the discovery notes ([.discovery-notes.md](artifacts/.discovery-notes.md)) and confirmed
against the regenerated scan.

### Link Topology and Recomputation

Each moved doc carries a dense web of relative links whose new form depends on both the doc's new depth and whether the
target also moved. The per-category mapping (old form to new form) is recorded in the discovery notes' link-topology
table ([.discovery-notes.md](artifacts/.discovery-notes.md)); it is the recomputation source and is not restated here.

Recomputation runs through a one-time throwaway migration script using the mechanic
resolve-each-link-to-an-absolute-repo-path-then-re-express-it-relative-to-the-doc's-new-location
([D-3](artifacts/implementation-decision-log.md#d-3-one-time-throwaway-migration-script)). Naive `git mv` plus a
find-and-replace on each doc's own path is unsafe: it misses every outbound relative link and cannot handle a target
that also moved ([D16](artifacts/decision-log.md#d16-link-integrity-is-the-acceptance-gate)). The script's file
selection excludes the frozen `docs/plans/**` and `docs/research/**` archives
([D10](artifacts/decision-log.md#trivial-decisions)) and `CHANGELOG.md`, which stays a frozen point-in-time record
([D-5](artifacts/implementation-decision-log.md#d-5-changelogmd-stays-frozen-and-out-of-the-link-gate)).

### README and Index Authoring Model

All 11 READMEs follow one light front-door skeleton
([D-7](artifacts/implementation-decision-log.md#trivial-decisions)): an H1 and one-paragraph what/how/why, a
bundled-vs-opt-in line naming dependencies and any required MCP server
([D13](artifacts/decision-log.md#d13-plugin-readme-states-bundled-vs-opt-in-and-dependencies)), a scent-line skills list
reusing each long-form doc's canonical summary line
([D15](artifacts/decision-log.md#d15-the-long-form-summary-line-is-the-canonical-scent)), an owned-agents scent list for
`han-core` and `han-communication` only with the shared-agent-dispatch note for the other eight
([D8](artifacts/decision-log.md#d8-plugins-without-agents-note-shared-agent-dispatch)), and lateral navigation. `han-core`
groups its skills by purpose ([D12](artifacts/decision-log.md#trivial-decisions)); the others are flat. The `han`
meta-plugin README omits the skills and agents sections and is a rewrite of the stale `han/README.md`, not a slim
([D17](artifacts/decision-log.md#d17-the-meta-plugin-readme-omits-skills-and-agents-sections)).

Authoring the READMEs depends on the plugin-README standard and template already being rewritten to the light model
([D18](artifacts/decision-log.md#d18-the-plugin-readme-standard-and-template-move-to-the-light-model)); authoring against
the on-disk heavy standard reproduces the duplication the reorg removes
([D-1](artifacts/implementation-decision-log.md#d-1-dependency-tiered-sequencing)).

The two indexes shrink to alphabetized lists whose entries reuse the canonical scent and link to each moved doc. Each
index cross-links the workflows page and labels the choosing doc as the plugin index, so the three-index mental model
resolves ([D4](artifacts/decision-log.md#d4-the-choosing-doc-becomes-the-plugin-index),
[D5](artifacts/decision-log.md#d5-indexes-shrink-to-alphabetized-link-lists)).

### Navigation Invariants

After the move, a long-form doc's first up-link points to its adjacent plugin README, then the repository root
([D14](artifacts/decision-log.md#d14-in-plugin-docs-link-up-to-their-plugin-readme)). Plugin READMEs carry minimal
lateral navigation up to the plugin index and root and across to workflows. The skill and agent long-form templates and
the coverage rule encode the old first-bullet-to-root convention and old paths; they are updated in the standards tier so
future docs do not regress the convention this reorg establishes
([D9](artifacts/decision-log.md#d9-layout-descriptions-standards-and-tooling-updated)).

`docs/workflows.md` receives exactly four inbound links, from the root README and the three indexes, and no per-doc
links from the 62 long-form docs
([D-8](artifacts/implementation-decision-log.md#d-8-workflows-page-gets-four-inbound-links)). It opens by stating its
distinct job (the map of which skills chain together) and how it differs from quickstart, how-to, and concepts, with
those four cross-linked ([D6](artifacts/decision-log.md#d6-composition-scenarios-and-diagrams-move-to-a-workflows-doc)).

## Decomposition and Sequencing

The work runs in eight dependency tiers and lands as one atomic change
([D-1](artifacts/implementation-decision-log.md#d-1-dependency-tiered-sequencing),
[D-2](artifacts/implementation-decision-log.md#d-2-land-the-reorganization-as-one-atomic-change)). Each tier creates a
link target before anything that points at it is rewritten.

| #   | Work Unit                                          | Delivers                                                                                          | Depends On | Verification                                              |
| --- | -------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ---------- | -------------------------------------------------------- |
| 1   | Rewrite standards and templates                    | Light plugin-README standard and template ([D18](artifacts/decision-log.md#d18-the-plugin-readme-standard-and-template-move-to-the-light-model)); skill/agent long-form templates and coverage rule on new paths and new up-link ([D14](artifacts/decision-log.md#d14-in-plugin-docs-link-up-to-their-plugin-readme)) | None       | Standards describe the light shape and new locations     |
| 2   | Move 62 docs and recompute their outbound links    | Docs at `{plugin}/docs/{skills,agents}/{name}.md`; every outbound relative link recomputed         | 1          | Migration script run ([D-3](artifacts/implementation-decision-log.md#d-3-one-time-throwaway-migration-script)); relative-link resolver clean on moved docs |
| 3   | Author 10 plugin READMEs; rewrite `han/README.md`  | Light front doors ([D-7](artifacts/implementation-decision-log.md#trivial-decisions)); meta-plugin README ([D17](artifacts/decision-log.md#d17-the-meta-plugin-readme-omits-skills-and-agents-sections)) | 1, 2       | Each moved doc's up-link resolves to an existing README   |
| 4   | Create `docs/workflows.md`                          | Composition scenarios and mermaid diagrams for branching chains; distinct-job statement              | 2          | Diagrams render on GitHub ([T1](artifacts/feature-technical-notes.md#t1-github-renders-mermaid-fenced-blocks-natively)) |
| 5   | Slim the two indexes                               | Alphabetized link lists; workflows cross-link; plugin-index label ([D5](artifacts/decision-log.md#d5-indexes-shrink-to-alphabetized-link-lists)) | 2, 3, 4    | Every index entry resolves; workflows linked              |
| 6   | Convert choosing doc to plugin index               | Scent-and-link plugin index ([D4](artifacts/decision-log.md#d4-the-choosing-doc-becomes-the-plugin-index))     | 3          | Every plugin-README link resolves; labeled as plugin index |
| 7   | Update D9 blast radius                             | Root README, `CLAUDE.md`, `CONTRIBUTING.md`, how-to guides, standalone `docs/` pages, tooling, PR template ([D-6](artifacts/implementation-decision-log.md#d-6-pr-template-joins-the-d9-set-and-the-scan-covers-github)) | 2, 3, 4    | Regenerated scan (incl. `.github/`) returns no old-path reference |
| 8   | Run the verification gate                          | Zero unresolved links ([D16](artifacts/decision-log.md#d16-link-integrity-is-the-acceptance-gate))             | 1-7        | Three-pass gate ([D-4](artifacts/implementation-decision-log.md#d-4-three-pass-one-time-link-verification-gate)) clean |

## RAID Log

### Risks

| ID  | Risk                                                                    | Likelihood | Severity | Blast Radius                          | Reversibility | Owner                   | Mitigation                                                                                                   |
| --- | ---------------------------------------------------------------------- | ---------- | -------- | ------------------------------------- | ------------- | ----------------------- | ----------------------------------------------------------------------------------------------------------- |
| R1  | Outbound relative link inside a moved doc left un-recomputed            | Medium     | Medium   | Any moved doc's links                 | Reversible    | junior-developer        | Migration script recomputes every link ([D-3](artifacts/implementation-decision-log.md#d-3-one-time-throwaway-migration-script)); resolver pass ([D-4](artifacts/implementation-decision-log.md#d-4-three-pass-one-time-link-verification-gate)) |
| R2  | Orphaned moved doc that nothing links to                               | Low        | Medium   | Findability of one doc                | Reversible    | information-architect   | Orphan pass in the gate ([D-4](artifacts/implementation-decision-log.md#d-4-three-pass-one-time-link-verification-gate)) |
| R3  | Half-done cross-plugin state ships broken links on the default branch   | Medium     | High     | Whole docs tree on GitHub             | Reversible    | information-architect   | Land as one atomic change ([D-2](artifacts/implementation-decision-log.md#d-2-land-the-reorganization-as-one-atomic-change)) |
| R4  | Templates or standard left on the old convention regress every future doc | Medium   | Medium   | All future long-form docs and READMEs | Reversible    | information-architect   | Standards tier updates them first ([D-1](artifacts/implementation-decision-log.md#d-1-dependency-tiered-sequencing), [D18](artifacts/decision-log.md#d18-the-plugin-readme-standard-and-template-move-to-the-light-model)) |
| R5  | Absolute GitHub blob URL 404s after the move, invisible to a relative resolver | Medium | Low   | One external-style link in the PR template | Reversible | junior-developer      | Literal-string grep pass ([D-4](artifacts/implementation-decision-log.md#d-4-three-pass-one-time-link-verification-gate), [D-6](artifacts/implementation-decision-log.md#d-6-pr-template-joins-the-d9-set-and-the-scan-covers-github)) |

### Assumptions

| ID  | Assumption                                                                                          | What Changes If Wrong                                                          | Verifier               | Status   |
| --- | -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- | ---------------------- | -------- |
| A1  | The D9 referrer set is regenerated at implementation time, not read from the ~37-file draft count   | A referencing file is missed and ships a broken or stale-path link            | junior-developer       | Open     |
| A2  | GitHub renders `mermaid` fenced blocks natively, so workflows diagrams need no build step           | The diagrams do not render and the workflows page loses its findability value  | information-architect   | Verified |
| A3  | Only `han/README.md` exists on disk today, so the other 10 READMEs are authored fresh               | The authoring effort is a slim, not a fresh write, changing tier-3 scope       | information-architect   | Verified |

## Testing Strategy

The acceptance gate is the D16 zero-unresolved-links condition
([D16](artifacts/decision-log.md#d16-link-integrity-is-the-acceptance-gate)), run once at the end of the change as three
passes over the active Markdown set
([D-4](artifacts/implementation-decision-log.md#d-4-three-pass-one-time-link-verification-gate)). This is a docs move, so
the "tests" are link and reachability checks, not behavior tests.

- **Observable behaviors to test:** every internal link resolves to a file that exists; every moved doc is reachable
  from at least its plugin README or an index; `docs/workflows.md` has its four inbound links; the workflows diagrams
  render on GitHub.
- **The three passes:**
  1. Relative-link resolver over all active `.md`: every `](path)` resolves.
  2. Literal-string grep for `docs/skills/` and `docs/agents/` across active files, catching absolute blob URLs
     (`.github/pull_request_template.md:5`) and any missed references a relative resolver cannot see.
  3. Orphan pass: every moved long-form doc is linked from at least its plugin README or an index, and workflows has its
     four inbound links.
- **File selection:** all three passes exclude the frozen `docs/plans/**` and `docs/research/**` archives
  ([D10](artifacts/decision-log.md#trivial-decisions)) and `CHANGELOG.md`
  ([D-5](artifacts/implementation-decision-log.md#d-5-changelogmd-stays-frozen-and-out-of-the-link-gate)), whose expected
  old-path strings are not failures.
- **Edge cases requiring coverage:** a link whose target also moved (both endpoints change); an absolute GitHub blob URL
  that is syntactically valid but 404s post-move; the near-orphan risk for the workflows page.

## Definition of Done

- [ ] All 62 long-form docs are moved to `{plugin}/docs/{skills,agents}/{name}.md` with every outbound relative link
      recomputed ([D1](artifacts/decision-log.md#d1-long-form-docs-move-into-each-plugin-directory),
      [D-3](artifacts/implementation-decision-log.md#d-3-one-time-throwaway-migration-script)).
- [ ] 10 plugin READMEs are authored fresh and `han/README.md` is rewritten, all to the light skeleton
      ([D-7](artifacts/implementation-decision-log.md#trivial-decisions),
      [D17](artifacts/decision-log.md#d17-the-meta-plugin-readme-omits-skills-and-agents-sections)).
- [ ] `docs/workflows.md` exists with its distinct-job statement, branching-chain diagrams, and exactly four inbound
      links ([D6](artifacts/decision-log.md#d6-composition-scenarios-and-diagrams-move-to-a-workflows-doc),
      [D-8](artifacts/implementation-decision-log.md#d-8-workflows-page-gets-four-inbound-links)).
- [ ] Both indexes are slimmed to alphabetized link lists that cross-link workflows and label the plugin index
      ([D5](artifacts/decision-log.md#d5-indexes-shrink-to-alphabetized-link-lists)).
- [ ] `docs/choosing-a-han-plugin.md` is the scent-and-link plugin index
      ([D4](artifacts/decision-log.md#d4-the-choosing-doc-becomes-the-plugin-index)).
- [ ] The plugin-README standard and template, the skill/agent long-form templates, the coverage rule, and the
      maintenance tooling are reconciled to the new paths and the light model
      ([D9](artifacts/decision-log.md#d9-layout-descriptions-standards-and-tooling-updated),
      [D18](artifacts/decision-log.md#d18-the-plugin-readme-standard-and-template-move-to-the-light-model)).
- [ ] The regenerated D9 blast-radius scan, covering `.github/`, returns no active old-path reference
      ([D-6](artifacts/implementation-decision-log.md#d-6-pr-template-joins-the-d9-set-and-the-scan-covers-github)).
- [ ] The three-pass verification gate passes with zero unresolved links, frozen archives and `CHANGELOG.md` excluded
      ([D-4](artifacts/implementation-decision-log.md#d-4-three-pass-one-time-link-verification-gate),
      [D16](artifacts/decision-log.md#d16-link-integrity-is-the-acceptance-gate)).
- [ ] The change lands as one atomic unit so the default branch never shows a broken-link state
      ([D-2](artifacts/implementation-decision-log.md#d-2-land-the-reorganization-as-one-atomic-change)).

## Specialist Handoffs for Implementation

- **`information-architect`** dispatch after the `han-core` README is drafted; needs the drafted README to confirm the
  by-purpose grouping (OI-1) reads better than a flat list at `han-core`'s skill count, and to sanity-check that a reader
  landing mid-tree on a moved doc gets enough orientation from the light README and the up-link.
- **`devops-engineer`** conditional; dispatch only if the team chooses to build a permanent CI link-checker instead of
  the one-time gate ([D-4](artifacts/implementation-decision-log.md#d-4-three-pass-one-time-link-verification-gate)). Not
  triggered by this plan.

## Deferred (YAGNI)

### Permanent CI internal-link checker

- **Why deferred:** Evidence test. [D16](artifacts/decision-log.md#d16-link-integrity-is-the-acceptance-gate) asks the
  check to pass once, and no ongoing link-rot is cited. A permanent checker is tooling for a workload that does not exist
  yet. The strictly simpler one-time three-pass gate
  ([D-4](artifacts/implementation-decision-log.md#d-4-three-pass-one-time-link-verification-gate)) satisfies the same
  evidence.
- **Reopen when:** recurring broken-link regressions appear after merge, or the maintainers commit to enforcing link
  integrity on every PR or to the deferred documentation site.
- **Source:** R1, information-architect (IA-IMPL-9) and junior-developer (JD-4).

### Scent-diff linter

- **Why deferred:** Evidence test. [D15](artifacts/decision-log.md#d15-the-long-form-summary-line-is-the-canonical-scent)
  deliberately chose a behavioral reuse-one-canonical-line rule without tooling, and no measured drift exists. Verify the
  three copies match at authoring time instead.
- **Reopen when:** a measured instance of index, README, or long-form scent drift appears after the reorg.
- **Source:** R1, information-architect (IA-IMPL-8).

## Open Items

- **OI-1:** Whether `han-core`'s README groups its skills by purpose or lists them flat.
  - **Resolves when:** the `han-core` README is drafted and the grouping is judged against a flat list at that plugin's
    skill count. Default recorded in [D12](artifacts/decision-log.md#trivial-decisions): group by purpose.
  - **Blocks implementation:** No. A default is recorded; the README author confirms it during tier 3.

## Summary

- **Outcome delivered:** Han documentation is plugin-first, with in-plugin long-form docs, 11 light READMEs, two slimmed
  indexes, a plugin index, and a workflows page, all landing as one atomic change with zero broken links.
- **Team size:** 3 specialists (project-manager, information-architect, junior-developer). See
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Rounds of facilitation:** 1. See
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Decisions committed:** 8. See [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by evidence:** 8. See
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by junior-developer reframing:** 0. See
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by user input:** 0. See
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Rejected alternatives recorded:** 10. See
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Open items remaining:** 1
- **Recommendation:** Ship as planned. The one open item (OI-1) is non-blocking with a recorded default, and the one
  conditional handoff (`devops-engineer`) is not triggered.
