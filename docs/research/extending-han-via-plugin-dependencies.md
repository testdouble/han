# Research: Extending Han via Claude plugin dependencies — how the mechanism works, how Han already uses it, and how to structure the how-to

This report researches GitHub issue #31: how Claude Code plugin dependencies work, how Han already uses them (with `han.github` depending on `han.core` as the in-repo worked example), and how a new "how to extend Han via plugin dependencies" document should be structured and placed. It is the source material for writing that document; it does not write the document itself.

Evidence mode: **strict** (every claim that bears on the conclusion carries a checkable source; uncorroborated claims are labeled inline).

## Summary

Claude Code lets one plugin build on another by listing it in a `dependencies` field in the plugin's configuration. When someone installs the dependent plugin, Claude Code automatically installs and turns on the plugins it depends on, and it will not let you turn off a plugin while something still needs it. Han already works exactly this way: the `han.github` plugin depends on `han.core`, and a small top-level `han` plugin depends on both so that installing it pulls in the whole suite. That makes Han its own working example, so the document this research backs is not speculative.

The clearest way to write the new document is as a task-focused how-to: a goal, what you need first, the steps, and a copy-and-paste example built from Han's own three plugins, plus a short, bounded "why it's built this way" section. It should point readers to the existing configuration reference rather than repeating it. The strongest evidence points to placing the new document next to Han's existing plugin-configuration reference and expanding that reference's thin dependency section at the same time, rather than starting a separate file elsewhere.

One question only the Han maintainers can answer still shapes the framing: is this document for people authoring a new plugin inside the Han suite (the proven case), or for outside third parties building their own plugins on top of Han (a case with no evidence of demand yet)? The recommendation holds for the first audience; treat the second as out of scope until there is evidence for it. Overall: well-corroborated on the mechanism and Han's usage; the placement and audience rest on a mix of strong documentation-design evidence and Han's own conventions, adjusted after validation.

## Research Results

### How the dependency mechanism works

A plugin declares the plugins it needs in a `dependencies` array inside its `.claude-plugin/plugin.json`. Each entry is either a bare plugin name (which floats to whatever version the marketplace provides) or an object with `name`, an optional semver `version` range, and an optional `marketplace` (A1, A2). The same array shape may also appear in the plugin's `marketplace.json` entry (A3).

At install time, Claude Code auto-installs each declared dependency and reports which ones it added (A1). Enabling a plugin transitively enables its dependencies at the same scope, and Claude Code blocks disabling a plugin while another enabled plugin still depends on it, printing a chained command to disable them together (A1). Version constraints resolve against git tags named `{plugin-name}--v{version}`; when multiple plugins constrain the same dependency, the ranges are intersected and the highest satisfying version wins, or the install fails with a `range-conflict` (A1). Dependencies in a different marketplace are refused unless the root marketplace opts in via `allowCrossMarketplaceDependenciesOn` (A1, A3). Auto-installed dependencies that no longer have a requirer can be removed with `plugin prune` (A1).

A plugin with no components of its own — just metadata and a `dependencies` array — is a valid "meta-plugin" whose only job is to pull in a bundle of other plugins. The canonical docs do not name this pattern or give a worked example of a zero-component plugin; it is inferred from the documented install semantics [single-source: A1/A2 describe the semantics, not the named pattern]. Han's own repository is direct evidence the pattern works in practice (A16, A19).

The resolution, enable/disable, pruning, and error-code details above rest on the canonical Claude documentation (A1–A3, trust class web). Han's in-repo configuration reference confirms the `dependencies` field exists and its syntax, but does **not** document any of the resolution semantics (A23) — so those behavioral claims are corroborated only across the three canonical web pages, not by any codebase artifact.

### How Han already uses it

Han is a live, shipped example of dependency-driven composition (A16–A20):

- `han.core` v1.0.0 is the base layer and declares no dependencies (A18).
- `han.github` v1.0.0 declares `dependencies: ["han.core"]` and ships the GitHub-facing skills (`gh-pr-review`, `update-pr-description`, `work-items-to-issues`) that build on core skills — for example, `gh-pr-review` runs core's `/code-review` and then posts the result to GitHub (A17, A20).
- `han` v3.0.0 is a meta-plugin with no components of its own; it declares `dependencies: ["han.core", "han.github"]` so installing it pulls in the whole suite (A16).
- All three are listed in a single `marketplace.json` with relative `source` paths, and the marketplace text names `han` as a meta-plugin (A19).

The dependency topology is acyclic: `han` → `{han.core, han.github}`, `han.github` → `han.core`, `han.core` → nothing. This is the worked example issue #31 asks the new document to teach.

### What the documentation-design evidence says

The dominant, independently corroborated framework for technical documentation is Diátaxis (A4), echoed by its predecessor Divio (A5). It separates four modes: tutorials (learning), how-to guides (doing a task), reference (lookup), and explanation (understanding), and treats mixing them as the top cause of confusing docs (A4, A5). A how-to is action-focused and is "done" when the task is done; it should exclude discursive explanation and should link to reference material rather than embed option tables (A6, A11). Explanation belongs in its own bounded space so it does not scatter (A7). Modal verbs ("must" vs. "can") mark which steps are required and therefore where "done" lands (A10).

On whether to split into multiple documents: Diátaxis permits section-level separation within one document as a first step, escalating to separate files when the content has standalone reach (A4). Google's guidance ties the split-vs-combine choice to audience experience and whether readers consume linearly or look things up (A9). Write the Docs' ARID principle ("Accept Repetition In Documentation") allows a short context-setting summary in a how-to that links to fuller explanation, without calling it duplication (A12). For mixed audiences, the literature favors targeted, signposted sections over forking into parallel documents (A13), and Kubernetes' `kubectl` plugin docs are real prior art for serving both operators and authors in one document via headed sections with "before you begin" blocks and verifiable commands (A14).

### Where this could live in Han, and the constraints

Han's documentation has clearly scoped homes (A21–A27). `docs/how-to/` currently holds **end-user** multi-skill workflow recipes (A21). `han.plugin-builder/skills/guidance/references/` holds **contributor** authoring guidance (A22), and `CLAUDE.md` reserves it for authoring guidance, explicitly barring plans and research from it (A25). A field-level reference for the `dependencies` field already exists at `han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md`, but it is thin — a syntax block only, with none of the resolution semantics from A1 (A23). `docs/choosing-a-han-plugin.md` already covers the install-time, end-user view of the three-plugin split, so the new document must not duplicate it (A24). `CONTRIBUTING.md` is the entry point for people working *inside* Han's own plugins, not for separate plugins that depend on Han (A27). `CLAUDE.md` enforces "one canonical source per concept" and a YAGNI-for-docs rule, and adding any document means updating the `CLAUDE.md` doc map (A25). There is no `README` index inside `han.plugin-builder/skills/guidance/references/`; `CLAUDE.md` is that index [validation correction, see V8].

## Options to Consider

These options concern how to structure and place the new document. They are not mutually exclusive in every part (structure and placement compose), but each represents a distinct overall shape.

### O1: Single how-to, procedural only, linking out for the "why"

- **What it is:** One task-focused document — goal, prerequisites, steps, copy-paste example — with no explanation section; any "why" is a one-line aside inside a step, and the document links to the reference and the canonical Claude docs.
- **Trade-offs:** Simplest and most maintainable. But the dependency-resolution model is non-trivial (A1), and omitting it risks leaving readers stranded when a step behaves unexpectedly (A6).
- **Rests on:** A1, A6, A10, A16–A20.
- **Evidence status:** corroborated.

### O2: How-to plus a separate, bounded explanation document

- **What it is:** A pure how-to in one file and a separate explanation file (how resolution and enable/disable work, why the suite is split this way), linked both ways.
- **Trade-offs:** Canonical Diátaxis shape (A4, A6, A7); the explanation gains standalone reuse. But it is the highest maintenance surface and risks being premature if the explanation is only a few paragraphs (A4).
- **Rests on:** A4, A5, A6, A7, A11.
- **Evidence status:** corroborated.

### O3: Single document, bounded concept section plus steps plus worked example

- **What it is:** One document that keeps a short, clearly delineated "how it works / why" section separate from the task steps, with a copy-paste worked example, linking to the existing reference for field-level detail.
- **Trade-offs:** Pragmatic given Han's YAGNI-for-docs rule (A25) and a small concept surface; Diátaxis explicitly allows section-level separation as a first step (A4). Weaker than O2 if the concept section later grows and starts to crowd the task steps.
- **Rests on:** A4, A9, A12, A23, A25.
- **Evidence status:** corroborated.

### O4: Co-locate with the existing config reference, and expand that reference

- **What it is:** Place the new document inside `han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/` next to `plugin-json-options.md`, and at the same time expand that file's thin `dependencies` section so the "link to reference" actually answers the reader's question.
- **Trade-offs:** Lowest blast radius once you accept that the reference needs extending anyway (V4): the how-to sits beside the reference it depends on, reachable by a "see also" link, and the directory's concern (plugin configuration) stays coherent. The cost is that this subdirectory currently holds only schema-reference files, so the new document slightly broadens its character — but no rule restricts it to schema-only (V6).
- **Rests on:** A11, A23, A25; validation findings V4, V6.
- **Evidence status:** corroborated.

### O5: Full how-to + explanation + reference set

- **What it is:** Three linked documents — how-to, explanation, and a new full reference.
- **Trade-offs:** Scales best for mature, large documentation. But a reference for the field already exists (A23), and the concept surface is small, so a brand-new third document is YAGNI-overkill against Han's own rule (A25).
- **Rests on:** A4, A5, A23, A25.
- **Evidence status:** corroborated.

## Recommendation

- **Recommendation:** Write **one** task-focused document structured per **O3** (steps plus a short, bounded "how it works / why" section plus a copy-paste worked example), placed and scoped per **O4** (co-located with `han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md`, with that file's `dependencies` section expanded in the same change). Build the worked example directly from Han's three plugins — `han.core` (no dependencies), `han.github` depending on `han.core`, and the `han` meta-plugin depending on both (A16–A20). Link to the canonical Claude plugin-dependencies documentation (A1) for the resolution and enable/disable semantics, and to the now-expanded in-repo reference (A23) for the field syntax — do not reproduce either table inline (A11). Frame the audience as **someone authoring a new plugin that depends on `han.core`, the way `han.github` does** — that is the proven, in-repo case. Treat outside third-party plugin authors as out of scope until there is evidence of that demand (see V2). Update the `CLAUDE.md` doc map with a use-case entry and a listing for the new file (there is no separate guidance index to update — `CLAUDE.md` is the index; see V8). Done criterion: a reader can stand up a new plugin that depends on `han.core`, add a skill, and confirm both load. Start here; escalate toward **O2** (split out a standalone explanation) only if the concept section later outgrows the task steps.

- **Evidence basis:**
  - *Corroborated (codebase, directly observed):* Han's dependency topology and the worked example — `han.core` has no dependencies, `han.github` depends on `han.core`, `han` depends on both, all shipped through one marketplace (A16–A20). The existing-but-thin reference and the doc-home scoping/constraints (A21–A27).
  - *Corroborated (web, multi-source):* the documentation-structure guidance — separate how-to from explanation, link rather than embed reference, section-level separation as a valid first step, signposted sections for mixed audiences (A4–A14).
  - *Canonical web, single trust-class:* the dependency **resolution, enable/disable, prune, and error semantics** rest on the canonical Claude docs (A1–A3) and are **not** corroborated by any codebase artifact (A23 documents only syntax). The new document should attribute these to the canonical docs and link out, rather than present them as settled in-repo fact (see V1).
  - *Single-source / inference:* the zero-component "meta-plugin" pattern is named nowhere in the canonical docs; it is inferred from install semantics and evidenced in practice only by Han's own `han` plugin (A16, A19). The document should present it as observed practice and link to the canonical docs for current install behavior (see V5).
  - *Open, operator-owned:* the audience question (suite-internal author vs. external third party) cannot be settled from the repository and changes the framing and the YAGNI calculus (see V2).

## Validation

The `adversarial-validator` attacked the evidence, the options framing, the recommendation, and the integrity of evidence-gathering. Eight findings returned; three were full refutations of the original draft recommendation and drove the adjustments recorded below.

### V1: The in-repo reference does not corroborate A1's resolution model

- **Strategy:** Challenge the Evidence
- **Investigation:** Read `plugin-json-options.md:68-77`; grepped all guidance docs for floating/orphan/prune/enable-dependency/defaultEnabled/range-intersect.
- **Result:** Partially Refuted. The field and its syntax are real and current (A23), but the resolution/enable-disable/prune/error semantics rest solely on the canonical web docs (A1) with no codebase corroboration.
- **Impact:** The recommendation now labels those behavioral claims as canonical-web-sourced and instructs the document to link to A1 rather than present them as in-repo fact.

### V2: The "external plugin author" audience is speculative

- **Strategy:** Challenge the Assumptions
- **Investigation:** Searched operational docs for any third-party/external-plugin audience; read `CONTRIBUTING.md`.
- **Result:** Refuted (as originally framed). No evidence of any external plugin depending on `han.core`, and Han's YAGNI-for-docs rule (A25) bars speculative content. The demonstrated case is a *suite-internal* dependent plugin (`han.github`), not an outside third party.
- **Impact:** The recommendation reframes the audience to the proven internal-author case and explicitly scopes out external third parties pending evidence. This is the open question flagged for the maintainers.

### V3: `han.plugin-builder/skills/guidance/references/` placement risks colliding with its stated purpose

- **Strategy:** Challenge the Fix
- **Investigation:** Read `CLAUDE.md:138-143` (guidance reserved for authoring guidance; plans/research barred) and the directory contents.
- **Result:** Partially Refuted. A how-to-shaped usage doc is not obviously "authoring guidance," so a bare top-level `han.plugin-builder/skills/guidance/references/` placement was weakly justified.
- **Impact:** Placement moved to the configuration-reference subdirectory (O4), where a usage companion to the reference is coherent, instead of a top-level guidance file.

### V4: Linking to the existing reference is a dead end

- **Strategy:** Challenge the Fix
- **Investigation:** Confirmed `plugin-json-options.md`'s `dependencies` section is syntax-only.
- **Result:** Confirmed. "Link to the reference for the why" fails because the reference does not contain the why.
- **Impact:** The recommendation now names expanding that reference's `dependencies` section as a prerequisite in the same change, and points resolution-semantics links at the canonical docs (A1).

### V5: The meta-plugin pattern is treated as canonical when it is inferred

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Confirmed `han/.claude-plugin/plugin.json` and `marketplace.json` are real and current.
- **Result:** Partially Refuted. The example is genuine and works; the canonical docs simply do not name the pattern.
- **Impact:** The document should present the zero-component meta-plugin as observed practice and link to the canonical docs for current install semantics.

### V6: O4 was dismissed without real evaluation

- **Strategy:** Challenge the Options Framing
- **Investigation:** Read the configuration-reference directory; found no rule restricting it to schema-only.
- **Result:** Refuted (as framed). Co-location is the lowest-blast-radius option once the reference must be extended anyway.
- **Impact:** O4 is now part of the recommendation rather than a dismissed alternative.

### V7: Web sources lack provenance scrutiny

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Confirmed Diátaxis/Divio share an author (not independent), Google sources are interested-party, dev.to is user-generated.
- **Result:** Partially Refuted. The dev.to source is non-authoritative and load-bears on nothing; the Diátaxis/Divio relationship is acknowledged; discounting any single web source does not change the conclusion.
- **Impact:** The dev.to source is dropped from the registry; conclusions rest on the corroborated remainder.

### V8: The "guidance index" does not exist; the `CLAUDE.md` update is wider than stated

- **Strategy:** Challenge the Fix
- **Investigation:** Confirmed there is no `README` in `han.plugin-builder/skills/guidance/references/`; `CLAUDE.md` is the index, and its "When to use which doc" section has no row for this use case.
- **Result:** Refuted (as framed). There is no separate guidance index to update.
- **Impact:** The recommendation now specifies updating `CLAUDE.md` (both a new use-case entry and the guidance listing) and drops the nonexistent "guidance index."

### Adjustments Made

The original draft recommended a single top-level `han.plugin-builder/skills/guidance/references/` how-to for an audience that included external third parties, linking to the existing reference for the "why." Validation refuted the speculative-audience framing (V2), the link-to-an-incomplete-reference instruction (V4), and the nonexistent-index instruction (V8), and showed the dismissed co-location option (O4) was actually the lowest-blast-radius placement (V6). The recommendation was rewritten to: scope the audience to the proven suite-internal author, place the document beside the configuration reference and expand that reference in the same change (O4), attribute resolution semantics to the canonical docs rather than the thin in-repo reference (V1, V5), and correct the `CLAUDE.md` update scope (V8). The dev.to source was removed (V7). The core direction — a how-to built on Han's own worked example, structured per Diátaxis, linking rather than embedding — survived.

### Confidence Assessment

- **Confidence:** Medium.
- **Remaining Risks:**
  1. **Audience (operator-owned).** Whether there is any real or imminent audience beyond suite-internal authors cannot be answered from the repo. If the answer is "internal only," the recommendation holds cleanly; if "external third parties," the framing and YAGNI calculus change and need fresh evidence.
  2. **A1 accuracy (web-only).** The resolution, enable/disable, prune, and error-code behaviors are canonical-web claims with no in-repo corroboration; if Claude Code's behavior has drifted from A1, a "why" section built on it could mislead. Linking out to the canonical docs (rather than restating) limits but does not erase this risk.
  3. **Prerequisite coupling.** The how-to is only useful once the reference's `dependencies` section is expanded; shipping the how-to first would recreate the dead end V4 found.
  4. **Meta-plugin pattern.** Sound in practice today (A16, A19) but not a named canonical construct; future install-semantics changes could affect zero-component plugins.

## Sources

### A1: Claude Code — Plugin dependencies (canonical)

- **Link / location:** https://code.claude.com/docs/en/plugin-dependencies
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Canonical reference for the `dependencies` mechanism: array syntax (bare string or `{name, version, marketplace}`), auto-install at install time, transitive enable, blocked disable while a dependent is enabled, floating vs. semver resolution against `{plugin-name}--v{version}` git tags, range-conflict intersection, cross-marketplace gating via `allowCrossMarketplaceDependenciesOn`, orphan pruning, and error codes.
- **Evidence status:** corroborated by A2, A3 on schema shape, enable/disable, and cross-marketplace gating; resolution-semantics details are single-trust-class (web) — not corroborated by A23.

### A2: Claude Code — Plugins reference

- **Link / location:** https://code.claude.com/docs/en/plugins-reference
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Full `plugin.json` schema; `dependencies` is a top-level field alongside `skills`/`agents`/`hooks`; a dependency's `defaultEnabled:false` is overridden to enabled when pulled in; symlink-based file sharing between sibling plugins; a plugin's `CLAUDE.md` is not loaded as context.
- **Evidence status:** corroborated by A1, A3.

### A3: Claude Code — Plugin marketplaces

- **Link / location:** https://code.claude.com/docs/en/plugin-marketplaces
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** `marketplace.json` schema, `allowCrossMarketplaceDependenciesOn`, relative-path plugins copied into a local cache on install, symlink dereference at install, and `dependencies` declarable in a marketplace entry with the same shape as `plugin.json`.
- **Evidence status:** corroborated by A1, A2.

### A4: Diátaxis (documentation framework home)

- **Link / location:** https://diataxis.fr
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Four documentation modes (tutorial, how-to, reference, explanation) on two axes; mixing modes is the leading cause of confusing docs; section-level separation is a valid first step before splitting into files.
- **Evidence status:** corroborated by A5–A8, A11; note A5 shares an author and is not independent.

### A5: Divio documentation system

- **Link / location:** https://docs.divio.com/documentation-system/
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Predecessor publication of the same four-quadrant model by the same author; modes must not be mixed; explanation is the most-neglected quadrant.
- **Evidence status:** corroborated by A4 (same framework/author — not independent corroboration).

### A6: Diátaxis — How-to guides

- **Link / location:** https://diataxis.fr/how-to-guides/
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** A how-to is action-only, excludes explanation and reference, and is implicitly done when the task is done.
- **Evidence status:** corroborated by A4, A5.

### A7: Diátaxis — Explanation

- **Link / location:** https://diataxis.fr/explanation/
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Explanation is understanding-oriented and discursive, not instruction; keep it bounded so it does not scatter through other docs.
- **Evidence status:** corroborated by A4, A5.

### A8: Diátaxis — Tutorials

- **Link / location:** https://diataxis.fr/tutorials/
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** A tutorial is learning-oriented (building competence and confidence), distinct from a how-to's task focus.
- **Evidence status:** corroborated by A4, A5.

### A9: Google Technical Writing — Organizing large documents

- **Link / location:** https://developers.google.com/tech-writing/two/large-docs
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Split-vs-combine driven by audience experience level and whether readers consume linearly or look things up; shorter focused docs serve newcomers, longer docs serve experienced linear readers.
- **Evidence status:** corroborated by A10 (same publisher); interested-party source, but its specific structural advice is replicated independently by A4/A13.

### A10: Google — Prescriptive documentation style

- **Link / location:** https://developers.google.com/style/prescriptive-documentation
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Prescriptive docs recommend one way to do a task; modal verbs (must/can) mark required vs. optional steps and the "done" boundary.
- **Evidence status:** corroborated by A9.

### A11: Diátaxis — Reference

- **Link / location:** https://diataxis.fr/reference/
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Reference is information-oriented lookup; how-to guides should link to reference rather than embed option tables, to keep both clear.
- **Evidence status:** corroborated by A4, A5.

### A12: Write the Docs — Documentation principles

- **Link / location:** https://www.writethedocs.org/guide/writing/docs-principles/
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Docs should be skimmable, exemplary, and current; the ARID principle permits deliberate, limited repetition across documents to serve different readers.
- **Evidence status:** single source for ARID; corroborated by A9 on worked-example/exemplary guidance.

### A13: Writing Commons — Audience analysis (primary/secondary/hidden)

- **Link / location:** https://writingcommons.org/article/audience-analysis-primary-secondary-and-hidden-audiences/
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Names primary/secondary/hidden audiences and recommends targeted, signposted in-document sections over forked parallel documents for mixed audiences.
- **Evidence status:** single source for the taxonomy; the targeted-sections strategy is corroborated by A9 and demonstrated by A14.

### A14: Kubernetes — Extend kubectl with plugins

- **Link / location:** https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/
- **Retrieved:** 2026-05-29
- **Trust class:** web
- **Summary:** Real prior art for one document serving both operators and authors via headed sections, "before you begin" prerequisite blocks, and verifiable commands with expected output.
- **Evidence status:** single source as a concrete example; the pattern it shows is corroborated by A13 (strategy), A9 (length/audience), and A6 (how-to structure).

### A16: Han meta-plugin manifest

- **Link / location:** `han/.claude-plugin/plugin.json`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** `han` v3.0.0, `dependencies: ["han.core", "han.github"]`, no components of its own — the meta-plugin that installs the whole suite.
- **Evidence status:** corroborated by A19; directly observed.

### A17: Han.github manifest

- **Link / location:** `han.github/.claude-plugin/plugin.json`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** `han.github` v1.0.0, `dependencies: ["han.core"]`; ships `gh-pr-review`, `update-pr-description`, `work-items-to-issues`.
- **Evidence status:** corroborated by A19, A20; directly observed.

### A18: Han.core manifest

- **Link / location:** `han.core/.claude-plugin/plugin.json`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** `han.core` v1.0.0 with no `dependencies` field — the base layer of the topology.
- **Evidence status:** corroborated by A19; directly observed.

### A19: Marketplace manifest

- **Link / location:** `.claude-plugin/marketplace.json`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Lists all three plugins with relative `source` paths (`./han`, `./han.core`, `./han.github`) and describes `han` as a meta-plugin that pulls in both others.
- **Evidence status:** corroborated by A16–A18; directly observed.

### A20: Han.github skills

- **Link / location:** `han.github/skills/` (`gh-pr-review`, `update-pr-description`, `work-items-to-issues`)
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Concrete extension behavior — e.g., `gh-pr-review` runs core's `/code-review`, then posts the result to GitHub, showing a GitHub layer building on core skills.
- **Evidence status:** corroborated by A17; directly observed.

### A21: How-to directory README

- **Link / location:** `docs/how-to/README.md`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** `docs/how-to/` is scoped to end-user, multi-skill workflow recipes (plan a feature, triage a bug, research a decision); canonical for running a workflow, not for extending the plugin.
- **Evidence status:** directly observed.

### A22: Guidance directory contents

- **Link / location:** `han.plugin-builder/skills/guidance/references/`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Contributor authoring guidance: `plugin-entity-taxonomy.md`, `iterative-plugin-development.md`, `local-development.md`, `semantic-versioning.md`, `skill-building-guidance/`, `agent-building-guidelines/`, and the configuration-reference subdir.
- **Evidence status:** directly observed.

### A23: Plugin configuration reference (dependencies field)

- **Link / location:** `han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md` (lines ~68-77)
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Documents that `dependencies` exists and its syntax (bare name or `{name, version}`), but contains none of the resolution, enable/disable, prune, or error semantics from A1 — a syntax block only.
- **Evidence status:** confirms the field/syntax; does NOT corroborate A1's resolution model (gap identified in V4).

### A24: Choosing a Han plugin

- **Link / location:** `docs/choosing-a-han-plugin.md`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** End-user install guidance for the three-plugin split (which to install; `han.github` pulls `han.core`). Covers the installer's view, not the author's view.
- **Evidence status:** directly observed; bounds what the new doc must not duplicate.

### A25: Project map and conventions

- **Link / location:** `CLAUDE.md`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** "When to use which doc" map; doc-home folder-selection rule; "one canonical source per concept"; YAGNI-for-docs; `han.plugin-builder/skills/guidance/references/` reserved for authoring guidance (plans/research barred). Adding a doc requires updating this map.
- **Evidence status:** directly observed.

### A26: Prior research — how-to docs structure

- **Link / location:** `docs/research/how-to-docs-structure.md`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Prior in-repo evidence-based research that established `docs/how-to/` on Diátaxis grounds; also notes Divio/Diátaxis share an author and are not independent corroboration.
- **Evidence status:** directly observed; precedent for grounding doc-structure decisions in research.

### A27: Contributor guide

- **Link / location:** `CONTRIBUTING.md`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Entry point for contributors working inside Han's own plugins (adding skills/agents to `han.core` or `han.github`); does not address separate plugins that depend on Han.
- **Evidence status:** directly observed; relevant to the audience question in V2.
