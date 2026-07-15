# Research: Building Usable Documentation for an Open-Source Project (and Applying It to Han)

## Summary

Build documentation usability in two layers, and treat them as two separate decisions. The **baseline layer** is well-supported and low-risk: keep docs in the repository under code review (docs-as-code), organize them by reader need rather than by internal structure, write each page to stand on its own, give every plugin a short "front door" README that carries links and scent but not duplicated content, and lean on GitHub's native rendering (Mermaid diagrams, auto-generated tables of contents, relative links) instead of a build pipeline. This baseline fully satisfies what issue #115 asks for. The **escalation layer** — standing up a rendered documentation site (MkDocs, Sphinx, Docusaurus) on GitHub Pages or Read the Docs — has no clear winner in the evidence and should be deferred until the plugin-centric reorganization is done, then decided against named criteria.

For Han specifically: the plugin-centric reorganization in issue #115 is defensible and aligns with established practice, provided the per-plugin READMEs carry scent-plus-link only so Han's existing "one canonical source per concept" rule survives intact. Adding Mermaid diagrams is a zero-cost win GitHub renders natively. A rendered docs site is a real option but carries a live risk (the most natural fit for Han, MkDocs + Material, entered maintenance mode in November 2025), so it is a later, separate call.

**Confidence: Medium.** The baseline practices are corroborated across independent primary sources. The escalation layer is genuinely unsettled in the evidence, and two of the load-bearing "apply to Han" judgments are syntheses across differing real-world examples rather than single-source best practices.

---

## Research Results

### Documentation is built in two layers: how it is produced, and how it is organized

The evidence separates cleanly into a production/maintenance concern and an organization concern, and they answer different questions.

**Docs-as-code is the dominant production practice, and its main benefit is anti-rot.** Writing documentation with the same tools as code — plain-text markup in the repo, version-controlled, reviewed in pull requests, built in CI — is documented by two independent practitioner sources on both its definition and its benefits: shared workflow with developers, freshness of authorship, and the ability to gate merges on missing docs (A4, A5). The strongest evidence for *why* this matters is a peer-reviewed study of over 3,000 GitHub projects, which found that most contain at least one documented code reference (a function, file, or class) that no longer exists in the source, and diagnosed the root cause as a workflow gap: nothing in ordinary development signals that a code change has invalidated documentation (A17). Keeping docs in the same repository under the same review gate is the most consistently cited mitigation (A5, A16, A17). The practice has real costs, corroborated by two independently motivated critiques (one non-commercial, one from vendors of competing tools): Git is a poor fit for non-developer writers, conventions drift without enforcement, and reviewing raw markup without a rendered preview degrades review quality (A6, A7). The failure mode is adopting the tooling without the supporting process, not the concept itself (A6).

**For organization, "separate content by reader need" is the recurring principle.** The Diátaxis framework splits a documentation set into four types keyed to distinct reader needs — tutorials (learning), how-to guides (task), reference (facts), and explanation (understanding) — and argues that mixing these within one document degrades usability (A1). GitHub's own developer-documentation guidance endorses the same framework (A32). Real adopters report it helps both authoring and findability, with two important caveats corroborated across independent sources: applying it initially makes an existing doc set *look worse* because gaps become visible, and migration is a multi-year effort, not a quick reorg (A2). There is also an evidentiary gap: an independent practitioner could not find research validating that these *specific four* categories are the correct taxonomy, and the framework author's defense of the split is an assertion rather than a cited study (A3) `[single-source on the taxonomy's optimality]`. A complementary idea, "Every Page is Page One," argues each page must stand on its own because readers arrive by search or deep link, not by reading top-to-bottom (A10). That premise — readers scan and jump rather than read sequentially — is corroborated by independent usability and cognitive-science research showing most readers scan, and that concise, scannable, front-loaded writing measurably improves usability (A13, A14).

### GitHub recognizes a specific "front door" file set, and renders a lot without any build

**Community health files are a fixed, documented set with strict placement rules.** GitHub actively checks each public repo for README, LICENSE, CODE_OF_CONDUCT, CONTRIBUTING, SECURITY, SUPPORT, GOVERNANCE, FUNDING, and issue/PR templates, resolving each file by looking in `.github`, then the repo root, then `docs` (A19, A20). opensource.guide converges on the same set and adds the practical rule to link CONTRIBUTING and CODE_OF_CONDUCT from the README so they are discoverable (A21). This is well corroborated across independent primary sources.

**A folder-level README is a free landing page.** GitHub auto-surfaces a README when browsing any folder, not just the repo root (A37). It also auto-generates a clickable outline (table of contents) and heading anchors from markdown headings with no extra syntax, and rewrites relative links per branch — GitHub explicitly recommends relative over absolute links for in-repo references (A38). Since February 2022 it renders Mermaid diagrams natively wherever markdown renders (repos, issues, PRs, wikis), with the raw diagram source staying diffable in the file (A30, A31). Together these give a project navigable, diagram-capable, per-area documentation with zero tooling.

**No source names a threshold for when flat markdown must become a rendered site.** This was an explicit negative result: none of the fetched sources supplied a file-count or word-count rule for when to escalate (A24–A32 searched). What is well-evidenced is the tooling landscape once a project does escalate — covered in the Options below — including one fact that materially changes the calculus: Material for MkDocs, the most common markdown-first choice, entered maintenance mode on 2025-11-05 (critical and security fixes only for at least 12 months, no new features), with its maintainers redirecting new work to a successor tool, Zensical; the underlying MkDocs project has had no release since August 2024 (A25, independently confirmed by A26).

### Multi-package projects split on where docs live, but agree every project needs one front door

Two credible large open-source projects chose opposite structures. Spotify's monorepos (via the open-sourced `mkdocs-monorepo-plugin`) keep a `docs/` folder beside each package's code, merged into one site, explicitly to answer "who owns which documentation" using folder-based ownership like CODEOWNERS (A33) `[single-source for the Spotify-origin claim]`. Kubernetes instead uses one central documentation repository, entirely separate from the many component repos it documents (A34). Both are real and evidenced; they optimize for different things (per-package ownership vs. one coherent cross-project narrative), and neither claims the other is wrong. The one point of agreement across all sources is that every project needs a single discoverable entry point regardless of internal structure (A21).

### Han's current documentation: strong content, flat and centralized structure, only one README

Han already practices docs-as-code and already enforces a one-canonical-source rule, so the reorganization is a structural change, not a philosophy change.

- **The canonical-source convention is codified in two places.** CLAUDE.md and CONTRIBUTING.md both state: the long-form doc is canonical, indexes carry one-sentence scent plus a link, and the README never duplicates long-form content (A40). Any reorganization must preserve this, and issue #115 explicitly worries about breaking it.
- **All skills and agents have complete long-form docs, centralized under repo-root `docs/`.** Every skill has a doc under `docs/skills/{plugin}/{name}.md` and every agent under `docs/agents/han-core/{name}.md`; the indexes are complete (A41).
- **The two indexes are large.** `docs/skills/README.md` (162 lines) and `docs/agents/README.md` (99 lines) together hold every entry across nine plugin sections with internal sub-grouping — the "too large and complex" the issue names (A41).
- **Only the `han/` meta-plugin has a README.** The other plugin directories have none, despite `docs/plugin-readme.md` already carrying five rules for what a per-plugin README should contain — including the rule that skill directories must *not* have their own READMEs and that a plugin README lists its skills with scent, not duplicated long-form content (A42, A43).
- **Mermaid is barely used and there is no site tooling.** Mermaid appears in exactly one plan document today, not in any skill or agent doc; there is no `mkdocs.yml`, Sphinx `conf.py`, Docusaurus config, Read the Docs config, or docs-building CI workflow (A44).
- **The driving request.** Issue #115 asks for a README per plugin (what/how/why plus its components), slimmer alphabetized indexes that link out, a new "plugin index" pointing to the per-plugin READMEs, and *possibly* moving long-form docs into plugin-specific folders (marked as a maybe). The thread adds two live ideas from a contributor and the maintainer: rendering the docs via MkDocs/Sphinx on Read the Docs/Pages, and embedding Mermaid diagrams (A45).

---

## Options to Consider

These are grouped by the decision they belong to. The organization and front-door options (O1–O4) are the baseline; the rendered-site options (O5–O8) are the escalation layer.

### Baseline: organization and front door

**O1 — Per-plugin README as a scent-and-link "front door," central long-form docs unchanged.** Each plugin gets a short README describing what/how/why and listing its components as one-line scent plus links into the existing central long-form docs. The indexes slim to alphabetized link lists; a new plugin index points to the per-plugin READMEs. Steelman: matches GitHub's folder-README affordance (A37), gives every plugin a discoverable entry point (A21), and preserves Han's one-canonical-source rule because the README carries links, not duplicated content (A40, A43). Directly delivers issue #115's core asks. Trade-off: requires discipline to keep READMEs from accreting long-form content over time. Rests on: A21, A37, A40, A43, A45.

**O2 — Also move long-form docs into per-plugin folders (the issue's "maybe").** In addition to O1, relocate `docs/skills/{plugin}/` and `docs/agents/` content into each plugin's own directory. Steelman: docs live beside the code they describe, enabling folder-based ownership, the pattern Spotify uses (A33). Trade-off: larger, riskier migration; the evidence is genuinely split, since Kubernetes deliberately does the opposite with a central docs tree (A34), and no source measures which reduces onboarding friction. Rests on: A33, A34.

**O3 — Keep the current flat-central structure, only slim the indexes.** Do the minimum: shrink the two indexes, skip per-plugin READMEs. Steelman: least effort, no migration risk. Trade-off: leaves nine plugins with no front door, contradicting the every-project-needs-an-entry-point principle (A21) and leaving the "wall of flat files" navigation problem the issue names. Rests on: A21, A45.

**O4 — Adopt Mermaid diagrams for flows and structure (independent of O1–O3).** Add diagrams to high-traffic docs (plugin relationships, dispatch flows, decision paths). Steelman: GitHub renders Mermaid natively with zero build, and the source stays diffable in code review (A30, A31); scannable visual structure aids the nonlinear readers the usability research describes (A14). Trade-off: diagrams themselves can rot if not maintained under the same review gate — mitigated by docs-as-code (A17). Rests on: A14, A17, A30, A31, A45.

### Escalation: rendered documentation site (only if the baseline proves insufficient)

**O5 — Stay on native GitHub markdown, no site build.** Steelman: zero tooling overhead; Mermaid, auto-TOC, auto-anchors, relative links, and folder READMEs all work with no pipeline (A30, A31, A37, A38). Trade-off: no full-text search across docs and no versioned docs. Rests on: A30, A31, A37, A38.

**O6 — MkDocs + Material.** Steelman: fastest setup, markdown-first, simple YAML config, large install base (A24). Trade-off: entered maintenance mode 2025-11-05 with a 12-month critical-fix window and no new features; the maintainers themselves point migrators toward Zensical (A25, A26). Choosing it today means planning a migration within roughly a year. Rests on: A24, A25, A26.

**O7 — Docusaurus.** Steelman: built-in versioned docs, i18n, and Algolia-backed search that filters by version (A36); avoids the MkDocs maintenance risk. Trade-off: requires a Node/React toolchain and carries more maintenance overhead than MkDocs per its competitor's own comparison (A24) `[single-source on the overhead comparison]`. Rests on: A24, A36.

**O8 — Sphinx.** Steelman: best-in-class API-reference generation from Python docstrings via autodoc (A24). Trade-off: reStructuredText-first, steeper learning curve, and not evidenced as a strong fit outside Python/API-heavy projects — which Han is not. Rests on: A24.

Hosting, if any of O6–O8 are chosen, is its own sub-decision: GitHub Pages is free and simplest but has no native search, versioning, or PR previews (A28, A29); Read the Docs adds those and is free for open source, though the comparative claim is single-source from the vendor with only the "Pages lacks these" half independently confirmed (A27, A28); a custom host with PR previews (Kubernetes uses Netlify) is proven at scale but needs more setup (A34, A35).

---

## Recommendation

**Baseline (recommended, well-supported): O1 + O4, and treat the reorganization as issue #115's complete answer.**

Give every Han plugin a short README that states what the plugin does, how, and why, and lists its skills and agents as one-line scent plus links into the existing central long-form docs (O1). Slim the two indexes to alphabetized link lists and add a plugin index pointing to the per-plugin READMEs. Add Mermaid diagrams to the highest-traffic orientation docs (O4). This rests on corroborated evidence: GitHub surfaces folder-level READMEs as free landing pages (A37), every project needs one discoverable entry point per unit (A21), GitHub renders Mermaid natively at zero cost (A30, A31), and — critically for Han — routing scent-plus-link through the README rather than duplicating content is exactly what preserves Han's existing one-canonical-source rule (A40, A43). Han already lives docs-as-code, so this stays inside the review gate that keeps docs from rotting (A17).

The single most important constraint: **the per-plugin README must carry scent and links, never duplicated long-form content.** That is what keeps issue #115's reorganization from breaking the convention the issue itself worries about (A40). Han's own `docs/plugin-readme.md` already encodes this rule (A43), so the guidance exists; it just is not implemented for nine of the plugins yet (A42).

**Deferred, no clear winner: whether to move long-form docs into plugin folders (O2 vs. O3's central structure), and whether to stand up a rendered site (O5–O8).** The evidence does not force either. On doc *location*, two credible large projects deliberately chose opposite structures (A33, A34) and no source measures the onboarding difference — so this is a deciding-criteria call, not a best practice: move docs into plugin folders if per-plugin ownership (CODEOWNERS-style) becomes a real need; keep them central if a single coherent narrative matters more. On a *rendered site*, there is no evidenced threshold for when flat markdown becomes insufficient (A24–A32, negative result), and the most natural fit for a markdown-first suite like Han — MkDocs + Material — carries a well-corroborated maintenance risk as of late 2025 (A25, A26). Han is not Python/API-reference-heavy, so Sphinx's main advantage does not apply (A24, A08 context). The defensible sequence is: do the native-markdown reorganization first (it satisfies the issue), then decide the site question separately, weighing search/versioning needs against the MkDocs maintenance clock, Docusaurus's heavier toolchain, or waiting for Zensical to mature.

**Evidence basis.** The baseline recommendation (O1 + O4) rests on corroborated evidence across independent primary sources (GitHub's own docs, opensource.guide, the GitHub Mermaid announcement, and Han's own codebase). The "front door carries scent not content" constraint rests on Han's own codified convention (A40, A43). The deferral of O2 and the rendered-site decision rests on a genuine, documented split in the evidence (A33 vs. A34) and an explicit negative result (no escalation threshold found), not on a single source — which is why they are presented as deciding criteria rather than a pick.

**What would change this recommendation:** an independent controlled study validating Diátaxis's specific four-category split would firm up the organization guidance; a documented threshold (file count, contributor onboarding time) for when flat markdown becomes unusable would let the rendered-site question be answered now rather than deferred; and Zensical reaching a stable release would remove the maintenance risk that currently weakens the MkDocs option.

---

## Validation

_Pending adversarial validation — this section is completed after the validator returns._

---

## Sources

Trust classes follow the canonical evidence rule: **codebase** (verifiable in this repo), **web** (open-web claim, corroboration-gated), **provided** (user- or issue-supplied). Retrieval date for web sources is 2026-07-15.

| ID | Source | Link / location | Trust | Evidence status |
|---|---|---|---|---|
| A1 | Diátaxis — official site | https://diataxis.fr/ | web | Corroborated (A2, A3, A32) on content-type separation; taxonomy optimality single-source |
| A2 | Canonical/Ubuntu — adopting Diátaxis | https://ubuntu.com/blog/diataxis-a-new-foundation-for-canonical-documentation | web | Corroborates A1; independently surfaces migration cost |
| A3 | I'd Rather Be Writing — Diátaxis critique (Tom Johnson) | https://idratherbewriting.com/blog/what-is-diataxis-documentation-framework | web | Independent critique; taxonomy-research gap is a negative result |
| A4 | Write the Docs — Docs as Code | https://www.writethedocs.org/guide/docs-as-code/ | web | Corroborated by A5 |
| A5 | Docs Like Code — Anne Gentle | https://www.docslikecode.com/about/ | web | Corroborates A4 (independent, book-length author) |
| A6 | "Docs as code is a broken promise" | https://thisisimportant.net/posts/docs-as-code-broken-promise/ | web | Independent cost critique; corroborated in direction by A7 |
| A7 | Docs-as-code limits (Document360, ClickHelp) | https://document360.com/blog/docs-like-code-is-it-worth-the-hassle/ | web | Interested-party (competing vendors); corroborates A6 only on Git/tooling friction |
| A8 | Carroll minimalism — InstructionalDesign.org | https://www.instructionaldesign.org/theories/minimalism/ | web | Corroborated by A9 |
| A9 | Minimalist instruction — EduTechWiki (U. Geneva) | https://edutechwiki.unige.ch/en/Minimalist_instruction | web | Corroborates A8 |
| A10 | Every Page is Page One — Mark Baker | https://everypageispageone.com/about/ | web | Single-source framework; premise corroborated by A13, A14 |
| A11 | Google developer style guide — Headings | https://developers.google.com/style/headings | web | Corroborated by A12 |
| A12 | Microsoft Writing Style Guide — Headings | https://learn.microsoft.com/en-us/style-guide/scannable-content/headings | web | Corroborates A11 (independent) |
| A13 | Nielsen Norman Group — scannable web writing | https://www.nngroup.com/articles/concise-scannable-and-objective-how-to-write-for-the-web/ | web | Empirical; corroborated by A14 |
| A14 | Nielsen Norman Group — information foraging | https://www.nngroup.com/articles/information-foraging/ | web | Corroborates A13, A10 (Pirolli & Card lineage) |
| A15 | OASIS DITA — single-sourcing | https://docs.oasis-open.org/dita/dita/v1.3/os/part1-base/archSpec/base/single-sourcing.html | web | Primary standard; mechanism-design claim, not tested outcome |
| A16 | JetBrains Writerside — always-up-to-date docs | https://blog.jetbrains.com/writerside/2022/01/the-holy-grail-of-always-up-to-date-documentation/ | web | Interested-party; corroborated on core problem by A17 |
| A17 | "Detecting Outdated Code Element References…" (Empirical Software Engineering) | https://arxiv.org/abs/2212.01479 | web | Peer-reviewed; strongest anchor for docs-rot claim |
| A18 | Write the Docs — ownership/review-cadence synthesis | https://www.writethedocs.org/ | web | Weak (aggregated community sentiment); directional only |
| A19 | GitHub Docs — community profiles | https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/about-community-profiles-for-public-repositories | web | Corroborated by A20, A21 |
| A20 | GitHub Docs — default community health file | https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file | web | Corroborates A19 |
| A21 | opensource.guide — Starting a Project | https://opensource.guide/starting-a-project/ | web | Corroborates A19, A20; one-entry-point principle |
| A22 | jehna/readme-best-practices | https://github.com/jehna/readme-best-practices | web | Single-source; section order conflicts with A21 |
| A23 | Readme Driven Development — Preston-Werner | https://tom.preston-werner.com/2010/08/23/readme-driven-development | web | Primary; directionally corroborated by secondary commentary |
| A24 | Material for MkDocs — Alternatives | https://squidfunk.github.io/mkdocs-material/alternatives/ | web | Interested-party self-comparison; caveated |
| A25 | Material for MkDocs — maintenance-mode / Zensical | https://squidfunk.github.io/mkdocs-material/blog/2025/11/05/zensical/ | web | Corroborated by A26 (independent) |
| A26 | Docsio.co — Material for MkDocs 2026 review | https://docsio.co/blog/mkdocs-material | web | Independent confirmation of A25 |
| A27 | Read the Docs vs. GitHub Pages | https://about.readthedocs.com/comparisons/github-pages/ | web | Interested-party; only "Pages is bare" half corroborated (A28) |
| A28 | GitHub Docs — About GitHub Pages | https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages | web | Primary; corroborates A27's factual half |
| A29 | GitHub Docs — GitHub Pages limits | https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits | web | Primary (same publisher) |
| A30 | GitHub Blog — Mermaid in Markdown | https://github.blog/developer-skills/github/include-diagrams-markdown-files-mermaid/ | web | Corroborated by A31 |
| A31 | GitHub Docs — Creating diagrams | https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams | web | Corroborates A30 |
| A32 | GitHub Blog — Documentation done right | https://github.blog/developer-skills/documentation-done-right-a-developers-guide/ | web | Single-source; endorses Diátaxis (A1) |
| A33 | Backstage — mkdocs-monorepo-plugin | https://github.com/backstage/mkdocs-monorepo-plugin | web | Single-source for Spotify origin; per-package pattern |
| A34 | kubernetes/website | https://github.com/kubernetes/website/ | web | Primary (observable); central-docs pattern |
| A35 | Netlify PR-preview deploys (Kubernetes docs) | https://app.netlify.com/sites/kubernetes-io-main-staging/deploys | web | Corroborates A27's PR-preview claim independently |
| A36 | Docusaurus — Search | https://docusaurus.io/docs/search | web | Single-source (tool's own docs) |
| A37 | GitHub Docs — About READMEs | https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes | web | Corroborated by A19, A20 (file-resolution) |
| A38 | GitHub Docs — Basic writing and formatting | https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax | web | Corroborates A37 on native affordances |
| A39 | shields.io — badges | https://shields.io/ | web | Single-source for "de facto standard" framing |
| A40 | Han — one-canonical-source convention | `CLAUDE.md` (Conventions), `CONTRIBUTING.md` | codebase | Verifiable; codified in two files |
| A41 | Han — central long-form docs + index sizes | `docs/skills/README.md` (162 lines), `docs/agents/README.md` (99 lines), `docs/skills/{plugin}/`, `docs/agents/han-core/` | codebase | Verifiable current state |
| A42 | Han — only `han/` has a plugin README | `han/README.md`; other plugin dirs lack one | codebase | Verifiable current state |
| A43 | Han — existing per-plugin README guidance | `docs/plugin-readme.md` | codebase | Verifiable; scent-not-content rule already written |
| A44 | Han — Mermaid usage + no site tooling | one plan doc uses Mermaid; no `mkdocs.yml`/`conf.py`/RTD config/docs CI | codebase | Verifiable current state |
| A45 | Issue #115 + thread | https://github.com/testdouble/han/issues/115 | provided | User/issue-supplied requirements and thread ideas |

### Load-bearing source detail

- **A17 (peer-reviewed docs-rot study)** is the strongest single anchor: an analysis of 3,000+ GitHub projects finding most carry at least one outdated code reference, diagnosing the cause as a workflow gap that code-adjacent review gates address. It elevates docs-as-code from preference to evidenced practice.
- **A25/A26 (MkDocs maintenance mode)** is the fact that most changes the rendered-site calculus versus a year ago, and is corroborated across the maintainer's own announcement and an independent review.
- **A40/A43 (Han's canonical-source rule and existing README guidance)** are the constraint the entire baseline recommendation is shaped around: the reorganization is safe precisely because Han already forbids duplicating long-form content and already documents what a plugin README should hold.
- **A33 vs. A34 (Spotify per-package vs. Kubernetes central)** is the documented split that keeps the doc-location question a deciding-criteria call rather than a pick.
