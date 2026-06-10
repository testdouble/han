# Han Release Notes

## v3.2.0

This release introduces two new opt-in child plugins to the Han suite and patches `han.core`. The parent `han` plugin moves to 3.2.0. `han.core` moves to 1.1.1. Two new plugins join the suite at 1.0.0: `han.atlassian` and `han.plugin-builder`. `han.github` (1.1.0), `han.reporting` (1.0.0), and `han.feedback` (1.1.0) are unchanged.

### han v3.2.0

The contributor authoring guidance moved out of `docs/guidance/` into `han.plugin-builder/skills/guidance/references/`, which is why the docs tree shows large deletions. The Han-specific contributor docs that are not general authoring guidance, such as `docs/semantic-versioning.md`, moved up into `docs/` directly. A full doc sweep synced the `docs/skills/` and `docs/agents/` long-form docs with their sources, and new operator-facing skill docs were added for the new plugins' skills: `docs/skills/markdown-to-confluence.md`, `docs/skills/project-documentation-to-confluence.md`, and `docs/skills/work-items-to-jira.md`, with `docs/skills/README.md` updated to match. Two research reports landed under `docs/research/`: `guidance-currency-review.md` and `guidance-update-plan.md`. Hardcoded plugin, skill, and agent counts were removed from the living docs, including `docs/concepts.md` and the README. `.claude-plugin/marketplace.json` carries the version bumps and the two new plugin entries.

### han.core v1.1.1

Author and reviewer attribution was removed from the output templates of `/architectural-decision-record`, `/coding-standard`, and `/project-documentation`. The generated documents no longer carry `Authors` or `Reviewers` metadata blocks, the skills no longer prompt for author information, and the now-unused `git config user.name` and `whoami` context injection, along with the matching `Bash(git config *)` and `Bash(whoami)` permissions, were dropped from those three `SKILL.md` files. `/iterative-plan-review` got minor tweaks to its reference files `iteration-checklist.md` and `review-iteration-history-template.md`.

### han.atlassian v1.0.0 (new)

A new opt-in, Atlassian-facing plugin from [@mxriverlynn](https://github.com/mxriverlynn) in #49. It depends on `han.core` and requires a configured Atlassian MCP server. The `han` meta-plugin does not bundle it; install it on its own. It ships three skills. `markdown-to-confluence` publishes a local Markdown file to a user-specified Confluence page. `project-documentation-to-confluence` runs the core `/project-documentation` skill and then publishes the result to Confluence. `work-items-to-jira` creates one Jira ticket per slice from a work-items file and supports nesting items under an epic or a story via `--parent`; it ships the reference files `jira-ticket-template.md`, `reference-artifact-inventory.md`, and `work-items-file-format.md`. The two publish skills offer a live, draft, or local-only choice.

### han.plugin-builder v1.0.0 (new)

A new opt-in, dependency-free plugin from [@mxriverlynn](https://github.com/mxriverlynn) in #50 that packages the contributor guidance for building Claude Code skills, agents, and plugins. The `han` meta-plugin does not bundle it; install it on its own. It ships the `guidance` skill, which answers authoring questions and, when run with `init`, vendors the full guidance set into a repo at `.claude/plugin-building-guidance/` and writes a path-scoped rule index at `.claude/rules/plugin-building-guidance.md` so the right guidance surfaces while editing skill and agent files. The guidance body (skill-building guidance, agent-building guidelines, the marketplace and plugin configuration reference, and templates) moved here out of `docs/guidance/` and was generalized to be repo-agnostic.

### Pull requests in this release

- Add han.plugin-builder plugin and skills for plugin building guidance (#50) — [@mxriverlynn](https://github.com/mxriverlynn)
- Create han.atlassian plugin with first skills (#49) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v3.2.0/CHANGELOG.md#v320

## v3.1.0

This release ships behavior and documentation updates across the Han suite, driven by planning-protocol feedback and a fix to how the swarming skills dispatch agents. The parent `han` plugin moves to 3.1.0. Three child plugins change: `han.core` to 1.1.0 (planning, review, and documentation skill updates plus the agent-dispatch namespacing fix), `han.github` to 1.1.0 (`/update-pr-description` template conformance), and `han.feedback` to 1.1.0 (named default rating dimensions). `han.reporting` is unchanged at 1.0.0.

### han v3.1.0

The agent-dispatch namespacing fix from [@mxriverlynn](https://github.com/mxriverlynn) in #44 rippled through the suite documentation. All 29 docs under `docs/agents/`, plus `docs/concepts.md`, the `docs/skills/` long-form docs, and `docs/templates/agent-long-form-template.md`, now show agent invocation examples with the fully-qualified `han.core:` prefix and align with the skill behavior changes in `han.core`.

New contributor guidance was added. `han.plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-length.md` and a note in `skill-description-frontmatter.md` document the skill description length target (#45), and `han.plugin-builder/skills/guidance/references/skill-building-guidance/agent-dispatch-namespacing.md` records the namespacing rule (#44).

Two repo-maintenance skills under `.claude/skills/` changed. `han-release` now leads the release body with the summary and drops the redundant version heading. `han-update-documentation` was corrected for the five-plugin layout, including its audit-checklist and scope-mapping references (#47). Investigation and plan records for issues #40 and #44 were recorded under `docs/plans/`, and `marketplace.json` carries the version bumps.

### han.core v1.1.0

#### Planning-protocol feedback (issue #40)

Feedback from [@mjansen401](https://github.com/mjansen401) in #40 drove three changes. `/plan-implementation` now lazily creates empty operational sections instead of emitting empty scaffolding (R1). The planning skills `/plan-a-feature` and `/plan-implementation` now exclude plugin contributions from scope (R3). The `/plan-implementation` skill also gained a `feature-implementation-plan-template.md`.

#### Documentation and test-planning output

`/project-documentation` output now leads with behavior and demotes technical reference, and uses Mermaid diagrams instead of ASCII block diagrams (#41, #42); the skill received a new `references/template.md` in a large rewrite. `/test-planning` now leads the plan with behavior, adds a review pass, and focuses on public-API tests, with a new `references/template.md` (#43).

#### Agent-dispatch namespacing (issue #44)

The swarming skills now dispatch agents by their fully-qualified `han.core:agent-name`, not a bare `agent-name` or a `han:` prefix (#44, #46). This touched the `code-review`, `gap-analysis`, `iterative-plan-review`, `architectural-analysis`, and `plan-*` skill files. Several skills (`architectural-analysis`, `gap-analysis`, `plan-a-feature`, `plan-a-phased-build`) also gained report or document templates.

#### Skill descriptions

Five skill descriptions were trimmed under the 1024-character target (#45).

### han.github v1.1.0

`/update-pr-description` now conforms to a repository's GitHub pull-request template when one is present, through a new `references/template-conformance.md` reference (#48). `references/formatting-rules.md` was updated alongside it, and `post-code-review-to-pr` received a one-line change.

### han.feedback v1.1.0

`/han-feedback` now names its default rating dimensions instead of leaving them unspecified, from feedback by [@mjansen401](https://github.com/mjansen401) in #40 (R2).

### Issues closed in this release

- Han Feedback: plan-a-feature + plan-implementation (#40). Opened by [@mjansen401](https://github.com/mjansen401); fixed in #41 by [@mxriverlynn](https://github.com/mxriverlynn).
- Agent swarms must dispatch agents by full `namespace:agent-name`, not bare `agent-name` (#44). Opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #46 by [@mxriverlynn](https://github.com/mxriverlynn).

### Pull requests in this release

- #41 Planning protocol feedback (issue #40) ([@mxriverlynn](https://github.com/mxriverlynn))
- #42 Lead /project-documentation output with behavior, demote technical reference ([@mxriverlynn](https://github.com/mxriverlynn))
- #43 Test Planning: Usability and report output updates ([@mxriverlynn](https://github.com/mxriverlynn))
- #45 Skill description guidance ([@mxriverlynn](https://github.com/mxriverlynn))
- #46 Agent Swarm Fix: namespace qualified agent dispatch ([@mxriverlynn](https://github.com/mxriverlynn))
- #47 Correct /han-update-documentation for five-plugin layout, and update all docs ([@mxriverlynn](https://github.com/mxriverlynn))
- #48 Update-pr-description Skill: Conform to repository PR template when present ([@mxriverlynn](https://github.com/mxriverlynn))

Full changelog: https://github.com/testdouble/han/blob/v3.1.0/CHANGELOG.md#v310

## v3.0.0

This release restructures Han from a single plugin into a parent meta-plugin (`han` 3.0.0) that installs its capabilities through child plugins, each versioned on its own. Four child plugins ship at 1.0.0: `han.core` (planning, review, investigation, and documentation), `han.github` (GitHub-facing skills), `han.reporting` (stakeholder and HTML reporting), and the opt-in `han.feedback`. Installing `han` now pulls in `han.core`, `han.github`, and `han.reporting` through dependencies. `han.feedback` is installed separately.

### han v3.0.0

`han` is now a meta-plugin with no skills or agents of its own. It installs `han.core`, `han.github`, and `han.reporting` through its `dependencies`. Anyone who installed the previous single plugin needs to reinstall against the new layout, which is why this is a major release.

Documentation was reworked to match the split. Paths throughout the docs were repointed from the old `plugin/` tree to `han.core` and `han.github`. Added a "Choosing a Han Plugin" page and reorganized the README path-finder into categories. Added how-to guides for extending Han with your own plugin via dependencies, closing the request from [@mxriverlynn](https://github.com/mxriverlynn) in #31. Made `CONTRIBUTING.md` plugin-aware and stopped hardcoding skill and agent counts across the docs so the indexes no longer drift.

### han.core v1.0.0

New plugin at 1.0.0. Packages the core of Han: the planning, building, investigation, review, discovery, and documentation skills, plus the specialist agents that previously shipped under the single `han` plugin. This release also adds a `/runbook` skill for operational scenarios and an `on-call-engineer` agent.

Fixed `/gap-analysis` based on feedback from [@mjansen401](https://github.com/mjansen401) in #34, and documented the resulting behavior changes in its long-form doc. Corrected `/plan-a-feature`, `/plan-implementation`, `/issue-triage`, and `/research` based on feedback from [@mjansen401](https://github.com/mjansen401) in #36: `/plan-a-feature` gained weight-based decision-log triggering and connected-source resolution, `/plan-implementation` gained synthesis-audit parity and an altitude rule, `/issue-triage` added a `/research` route and omits inapplicable fields, and `/research` now right-sizes its report and hands off pure requests.

### han.github v1.0.0

New plugin at 1.0.0. Packages the GitHub-facing skills. Renamed the old `gh-pr-review` skill to `/post-code-review-to-pr` and moved `/update-pr-description` in. Added a new `/work-items-to-issues` skill that publishes each item in a work-items file as a GitHub issue, links within-repo blockers, and leaves the label and assignee optional.

### han.reporting v1.0.0

New plugin at 1.0.0. Packages the reporting skills. Moved `/stakeholder-summary` in and added a new `/html-summary` skill that converts a stakeholder summary into a single self-contained HTML executive report, styled with a Test Double-derived palette and inlined Mermaid diagrams.

### han.feedback v1.0.0

New plugin at 1.0.0. An opt-in plugin packaging the `/han-feedback` skill, which captures structured post-session feedback across the whole `han.*` family and can post it as a GitHub issue to testdouble/han. It depends on `han.core` but is deliberately left out of the `han` meta-plugin, so you install it on its own.

### Issues closed in this release

- How-to for extending Han skills via plugin dependencies (#31). Opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #32 by [@mxriverlynn](https://github.com/mxriverlynn).
- Feedback on `/gap-analysis` (#34). Opened by [@mjansen401](https://github.com/mjansen401); fixed in #37 by [@mxriverlynn](https://github.com/mxriverlynn).
- Feedback on `/issue-triage`, `/research`, `/plan-a-feature`, and `/plan-implementation` (#36). Opened by [@mjansen401](https://github.com/mjansen401); fixed in #38 by [@mxriverlynn](https://github.com/mxriverlynn).

### Pull requests in this release

- #28 docs: stop hardcoding skill/agent counts ([@afrerich](https://github.com/afrerich))
- #29 Han v3.0.0 - Plugin restructure as dependencies ([@mxriverlynn](https://github.com/mxriverlynn))
- #32 How-To: Extending Han with plugin dependencies ([@mxriverlynn](https://github.com/mxriverlynn))
- #33 Rename gh-pr-review skill to post-code-review-to-pr ([@mxriverlynn](https://github.com/mxriverlynn))
- #35 Han reporting ([@mxriverlynn](https://github.com/mxriverlynn))
- #37 Gap analysis correction ([@mxriverlynn](https://github.com/mxriverlynn))
- #38 Issue #36 investigation and corrections plan across four skills ([@mxriverlynn](https://github.com/mxriverlynn))
- #39 Add /han-feedback skill ([@mjansen401](https://github.com/mjansen401))

**Full changelog:** https://github.com/testdouble/han/blob/v3.0.0/CHANGELOG.md#v300

## v2.7.0

This release adds a new operational runbook skill, a new adversarial on-call agent wired into six existing skills, and a canonical evidence rule extracted out of `/research` into a plugin-wide reference that long-form docs and agent prompts now point at. The shipped catalog moves from 20 skills and 22 agents (v2.6.2) to 21 skills and 23 agents. Operators should notice three concrete things: `/runbook` is available for the first time, six review and planning skills (`/code-review`, `/architectural-analysis`, `/plan-a-feature`, `/plan-implementation`, `/iterative-plan-review`, `/gap-analysis`) now include `on-call-engineer` in their swarm rosters, and `/research` reports now end in a single indexed `Sources` registry instead of separate `Artifacts` and `References` sections. The release also lands a new how-to guide set, a "why solo and small teams" intro doc, and a documentation drift sweep across long-form docs.

### New `on-call-engineer` agent

A new adversarial-review agent ships at `plugin/agents/on-call-engineer.md`, modeled on a veteran on-call engineer who has been paged at 3am for the failure modes most reviewers miss: silent retries, partial writes, unbounded queues, missing timeouts, log lines that lie, and recovery paths that have never been exercised. The long-form operator doc lives at `docs/agents/on-call-engineer.md`. The agent is wired into six skills as a swarm member: `/code-review`, `/architectural-analysis`, `/plan-a-feature`, `/plan-implementation`, `/iterative-plan-review`, and `/gap-analysis`. Each of those skills now dispatches `on-call-engineer` alongside its existing roster so code-level resilience and operability concerns are surfaced during review and planning, not after the first incident. Counts in `README.md`, `CLAUDE.md`, `docs/concepts.md`, `docs/agents/README.md`, and `docs/yagni.md` are updated to reflect 23 agents. (PRs #16, #17)

### New `/runbook` skill

A new `/runbook` skill ships at `plugin/skills/runbook/SKILL.md` with a companion `plugin/skills/runbook/references/runbook-template.md`. The skill creates or updates a runbook for a single operational scenario: an alert that has fired, an incident, a recurring scheduled task, or a known failure mode on a live service. It applies a YAGNI preflight before writing: the scenario must be real (the alert has fired, the task recurs, or the failure mode exists on a service that receives traffic) before the skill produces the document. Each invocation produces one runbook. Sibling skill docs gain cross-links to `/runbook` where the handoff is natural, and the long-form operator doc at `docs/skills/runbook.md` describes the YAGNI preflight, the template structure, and how the skill differs from `/project-documentation` and `/architectural-decision-record`. Counts in `README.md`, `CLAUDE.md`, `docs/concepts.md`, `docs/skills/README.md`, and `docs/yagni.md` are updated to reflect 21 skills. (PR #21)

### Canonical evidence rule extracted

A new plugin-wide reference ships at `plugin/references/evidence-rule.md`. It defines the three structural principles every evidence-bearing skill and agent now applies (proximity to origin, corroboration across independent sources, explicit labeling when no evidence exists) and the trust-class vocabulary (codebase, web, provided) that grounds the corroboration gate. The trust-class vocabulary originated inside `/research` and is now extracted so other skills and agents share one source of truth instead of restating it inline. The canonical operator-facing summary lives at `docs/evidence.md`, and the rule is threaded through long-form docs for `/research`, `/investigate`, `/gap-analysis`, `/plan-a-feature`, `/plan-implementation`, `/iterative-plan-review`, `/coding-standard`, `/architectural-decision-record`, and `/runbook`, plus the `evidence-based-investigator`, `gap-analyzer`, `junior-developer`, and `project-manager` agents. The `on-call-engineer` long-form doc also gains the previously-missing Evidence cross-link. (PR #22)

### `/research` output structure: single `Sources` registry

`/research` reports previously ended in two separate sections, `Artifacts` and `References`, which forced the same source to be listed twice when it functioned as both. The two sections are now merged into a single indexed `Sources` registry at the bottom of the report, with stable IDs (A1, A2, ...) and one entry per source carrying link, retrieval date, trust class, plain-language summary, and corroboration status in one place. Implemented in `plugin/skills/research/SKILL.md` and `plugin/skills/research/references/research-report-template.md`. This is an output-shape change in the report `/research` produces; operators reading older research artifacts will still see the old two-section layout, while new runs produce the merged registry. (PR #26)

### End-to-end how-to guides

A new `docs/how-to/` folder ships with four documents: `docs/how-to/README.md`, `docs/how-to/plan-a-feature.md`, `docs/how-to/triage-and-investigate-a-bug.md`, and `docs/how-to/research-a-decision.md`. Each guide walks one complete workflow loop with the specific prompts to run, the decision points along the way, and what to expect from each skill at each step. The quickstart at `docs/quickstart.md` is re-scoped as a path-picker that hands off to the right how-to instead of trying to describe the full workflow itself. `CLAUDE.md` gains a doc-map entry pointing operators at the how-to set when they want the full recipe and not just a path-picker. (PR #24)

### New "why solo and small teams" intro doc

A new introductory document ships at `docs/why-solo-and-small-teams.md`. It gives the honest fit answer for teams evaluating Han: the plugin is built for solo product engineers and small teams, not for large teams or enterprise. The doc is linked from `README.md` and `docs/concepts.md` so a prospective operator can find the fit answer before installing. `CLAUDE.md` gains a doc-map entry for it. (PR #27)

### Documentation drift sweep

A pass across the long-form docs corrects several specific drifts. `docs/skills/update-pr-description.md` is corrected so the description is authored by the `junior-developer` agent in Step 4 rather than reviewed in a separate Step 6 pass, and the step count drops from seven to six. `docs/skills/iterative-plan-review.md` is corrected so iteration caps scale with sizing (small=1, medium=2, large=3) instead of the previously-stated "five iterations for lightweight" claim. `docs/skills/plan-a-feature.md` updates its TL;DR and "What you get back" section to reflect the optional fourth `feature-technical-notes.md` artifact that `/plan-a-feature` already produces. `docs/skills/gap-analysis.md` makes the downstream pairing with `/plan-a-phased-build` explicit so operators know what to run next when the gap analysis is in hand.

Research artifacts backing the changes in this release land in `docs/research/`: `evidence-hierarchy.md`, `runbook-skill-research.md`, `on-call-engineer-research.md`, `artifacts-references-dedupe.md`, `how-to-docs-structure.md`, `enterprise-ai-tooling-integration.md`, `adhd-application-to-han.md`, and `adhd-application-to-han.with-disambiguation.md`.

### Pull requests in this release

- "ADHD" swarm research (#16) — @mxriverlynn
- Add on-call-engineer custom agent, integrated into agent swarm (#17) — @mxriverlynn
- Runbook skill (#21) — @mxriverlynn
- Evidence and hierarchy (issue #19) (#22) — @mxriverlynn
- Add how-to guides for planning, bugs, research (Issue #20) (#24) — @mxriverlynn
- Research skill: Artifacts vs References dedupe (#23) (#26) — @mxriverlynn
- Docs: Why a focus on solo and small teams? (#27) — @mxriverlynn

Full changelog: https://github.com/testdouble/han/blob/v2.7.0/CHANGELOG.md#v270

## v2.6.2

This release bundles three refactors that tighten how shipped skills and the repo's own guidance load context. No new skills or agents ship, none are renamed or removed, and no user-visible skill behavior changes. Operators should notice `/tdd` consuming less context per invocation, `/coding-standard` writing index files instead of symlinks, and the repo's own `.claude/rules/` layout matching the index-file shape the skill now produces.

### `/tdd` token optimization

`plugin/skills/tdd/SKILL.md` is restructured so reference files load lazily at the point they are needed rather than upfront. Step 1 now caps standards and ADR loading by relevance, and the loop prohibits intra-loop file rereads in favor of offset reads after grep. Paste-output directives are constrained to diagnostic content only. The inline YAGNI paraphrase is dropped from the refactor step, deferring to the canonical rule in `plugin/skills/tdd/references/yagni-rule.md`. The Constraints section is trimmed to enforcement, with the canonical red-green-refactor description living in `plugin/skills/tdd/references/tdd-loop.md`. The description loses an internal-behavior sentence, and the allowed-tools list drops long-tail JVM, .NET, and Elixir runners. The net effect is a meaningfully smaller context footprint per `/tdd` invocation without changing the loop itself. (PR #13)

### `/coding-standard` index-file mechanism

`plugin/skills/coding-standard/SKILL.md` is rewritten so the skill produces per-file-type index files instead of symlinking guidance into place. Step 3 groups discovered globs into index-file buckets, Step 6 frames the paths-approval gate as index-file routing, and Step 7 creates or updates the per-file-type index files directly. The symlink-verification step is replaced with index-file checks. A new template lands at `plugin/skills/coding-standard/references/index-file-template.md` to render the index files consistently. Because symlinks are no longer the mechanism, `ln`, `test`, and `readlink` are removed from the skill's allowed-tools list. The long-form operator doc at `docs/skills/coding-standard.md` is updated to describe the new mechanism. (PR #14)

### Repo-local rules realignment under `.claude/rules/`

The per-topic guidance under `.claude/rules/skills/` and `.claude/rules/agents/` previously consisted of symlinks pointing at individual pages in `han.plugin-builder/skills/guidance/references/skill-building-guidance/` and `han.plugin-builder/skills/guidance/references/agent-building-guidelines/`. Those symlinks are deleted and replaced with two canonical index files: `.claude/rules/coding-standards/plugin-skills.md` and `.claude/rules/coding-standards/plugin-agents.md`. Each index lists and links the underlying topic guidance directly rather than mirroring each page as its own symlink. This brings the repo's own `.claude/rules/` layout in line with the index-file template that `/coding-standard` now produces, so Han's internal setup matches the mechanism the shipped skill writes for other projects. (PR #15)

### Pull requests in this release

- TDD skill: token optimization (#13) — @mxriverlynn
- coding-standard skill: add per-file-type index-file template (#14) — @mxriverlynn
- Updating skill / agent rules to be index files (#15) — @mxriverlynn

Full changelog: https://github.com/testdouble/han/blob/v2.6.2/CHANGELOG.md#v262

## v2.6.1

The plugin skill loader is fixed so all 20 shipped skills register correctly again. The pull request template gains explicit instructions for documentation sync and version ownership, and the banner image is refreshed for the white Test Double logo.

### Skill loading fix

`plugin/.claude-plugin/plugin.json` previously declared `"skills": "./skills"`. In newer Claude Code loader versions that field is treated as a directory containing `SKILL.md` directly, so the loader looked for `plugin/skills/SKILL.md`, found nothing, and registered zero skills. Agents were unaffected because the manifest never declared an `agents` field, so default `agents/` auto-discovery ran normally. Removing the redundant `skills` field puts skill loading on the same default auto-discovery footing as agents, and all 20 shipped skills register again. Closes issue #11. (PR #12)

### Pull request template updates

`.github/pull_request_template.md` gains two additions. Contributors are now instructed to run `/han-update-documentation` before opening a PR so documentation stays in sync with branch changes before reviewers see the PR. The template also states explicitly that the plugin version in `plugin/.claude-plugin/plugin.json` and the contents of `CHANGELOG.md` are owned by `/han-release`, not by feature PRs, which prevents pre-bumps and conflicting changelog edits from landing on `main`.

### Banner refresh

`images/han-banner.png` is updated to match the new white Test Double logo.

### Pull requests in this release

- Fix/issue 11 skills not loading (#12) — @mxriverlynn

Full changelog: https://github.com/testdouble/han/blob/v2.6.1/CHANGELOG.md#v261

## v2.6.0

A new `/stakeholder-summary` skill ships, taking the shipped catalog from 19 to 20 skills with agents holding at 22. A repo-local `/han-update-documentation` skill is added under `.claude/skills/` for keeping Han's own documentation in sync with shipped entities, mirroring the internal-only framing of `/han-release`. Completed planning artifacts under `han.plugin-builder/skills/guidance/references/plans/`, `han.plugin-builder/skills/guidance/references/rfcs/`, and `docs/plans/` are removed: roughly 4,470 lines of historical scratch material that has served its purpose.

### New skill

`/stakeholder-summary` turns a feature specification into a plain-language summary intended for non-technical stakeholders to read and react to before implementation kicks off. The output is structured for business and product readers, leans on Mermaid diagrams to communicate flows visually, and is governed by two enforced self-check passes so the resulting document stays grounded in the source specification. The skill ships at `plugin/skills/stakeholder-summary/SKILL.md` with the output structure rendered from `plugin/skills/stakeholder-summary/references/stakeholder-summary-template.md`, and the long-form operator doc lands at `docs/skills/stakeholder-summary.md`. Neighbor routing is wired across the existing long-form skill docs so `/plan-a-feature`, `/plan-implementation`, `/plan-a-phased-build`, `/plan-work-items`, and the rest of the catalog point at `/stakeholder-summary` when a non-technical readout is the right next step. (PR #10)

### Repository tooling

A repo-maintenance skill `/han-update-documentation` is added at `.claude/skills/han-update-documentation/` for keeping Han's documentation current with the shipped skills, agents, indexes, and cross-references. It ships with `SKILL.md`, two reference files (`references/audit-checklist.md` and `references/scope-mapping.md`), and a context-detection script at `scripts/detect-doc-update-context.sh` that scopes the pass to entities the current branch touched on non-default branches and runs a full sweep on the default branch. Like `/han-release`, this skill is internal to this repository and is not one of the 20 shipped plugin skills.

### Documentation

- `docs/skills/README.md` gains the `/stakeholder-summary` entry in the catalog index.
- Long-form skill docs across `docs/skills/` receive cross-reference updates registering `/stakeholder-summary` as a neighbor where the routing applies.
- `docs/quickstart.md` and `docs/concepts.md` are touched to thread `/stakeholder-summary` through the operator-facing mental model.
- `README.md` receives a small touch tied to the new skill.
- The banner image at `images/han-banner.png` is refreshed.
- The "Current version" line is removed from `CLAUDE.md` so the project-map document does not drift against `plugin/.claude-plugin/plugin.json` on every bump.

### Repository cleanup

Completed planning artifacts are deleted from the repo now that the work they tracked has shipped or been superseded:

- `han.plugin-builder/skills/guidance/references/plans/agentic-plugin-support/research.md`
- `han.plugin-builder/skills/guidance/references/plans/han/planning-token-burn-reduction.md`
- `han.plugin-builder/skills/guidance/references/rfcs/rename-plugin-marketplace-dist.md`
- `docs/plans/code-review-guardrails/` (full directory)
- `docs/plans/research-skill/` (full directory)

These were internal scratch material, not operator-facing documentation, and their removal cuts roughly 4,470 lines of stale context from the repository.

### Pull requests in this release

- Add /stakeholder-summary skill (#10) — @afrerich

Full changelog: https://github.com/testdouble/han/blob/v2.6.0/CHANGELOG.md#v260

## v2.5.0

A new `/research` skill and its `research-analyst` agent ship, taking the catalog to 19 skills and 22 agents. `/coding-standard` now writes its output as path-scoped Claude Code rules under `.claude/rules/` rather than a freestanding document, and the same path-scoped-rules pattern is applied repo-wide so contributor guidance under `han.plugin-builder/skills/guidance/references/` reaches Claude Code automatically. A GitHub pull request template lands with a review checklist that hands off to `/update-pr-description`, and the README drops its duplicated skills list in favor of the canonical catalog under `docs/skills/`.

### New skill

`/research` answers open-ended questions (options, prior art, trade-offs, how something works) and produces a durable, evidence-backed, adversarially-validated report that recommends an option without committing the team to any artifact. It reaches the codebase, the open web, and any material the operator provides, and ships with `plugin/skills/research/SKILL.md` and a fixed report structure rendered from `plugin/skills/research/references/research-report-template.md`. The skill operates in an evidence mode that forces every recommendation to carry traceable citations (decision D23), and the report layout is fixed rather than freeform (decision D24). YAGNI is intentionally not applied inside `/research` or `research-analyst`: research surfaces options the operator may or may not pursue, so the deferral rule that gates planning and review skills would cut signal rather than noise. `/research` is the question-shaped sibling of `/investigate`: `/investigate` diagnoses a known failure, `/research` surveys an open question. Neighbor routing is wired bidirectionally across `/architectural-analysis`, `/gap-analysis`, `/investigate`, and `/plan-a-feature`, and the long-form catalog at `docs/skills/research.md` documents when to reach for it. (PR #8)

### New agent

`research-analyst` is the specialist `/research` dispatches for codebase, web, and operator-supplied evidence gathering. It ships at `plugin/agents/research-analyst.md` with a long-form doc at `docs/agents/research-analyst.md`, and is cross-referenced from every neighboring agent's "Related Documentation" section. (PR #8)

### Coding standards as path-scoped rules

`/coding-standard` now writes its output as a path-scoped Claude Code rule under `.claude/rules/` and symlinks the canonical document from `docs/` rather than producing a standalone markdown file. `plugin/skills/coding-standard/SKILL.md` and `plugin/skills/coding-standard/references/template.md` are updated to the new output contract, and `docs/skills/coding-standard.md` documents the canonical-doc + rules-symlink layout in plain language so operators can read the rule in either location. A step-count error in the operator doc is fixed in the same pass. (PR #9)

### Contributor guidance as Claude Code rules

A new `.claude/rules/` directory contains roughly 28 symlinks mirroring `han.plugin-builder/skills/guidance/references/skill-building-guidance/*.md`, `han.plugin-builder/skills/guidance/references/agent-building-guidelines/*.md`, and `han.plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md`. Path-scoped rules let Claude Code load the relevant guidance automatically when an operator edits a skill or agent under `plugin/`, so contributor conventions reach the model without the operator pasting them into context.

### Pull request template

`.github/pull_request_template.md` adds a review checklist for new pull requests against the Han repo and hands off to `/update-pr-description` for generating the body. The template is internal to this repository and does not change plugin behavior.

### Documentation

- `README.md`: the duplicated skills list is removed; the canonical catalog at `docs/skills/README.md` is now the single source.
- `CLAUDE.md`: project map updated for the 19-skill, 22-agent counts and the new `/research` entry.
- `docs/concepts.md`, `docs/quickstart.md`, `docs/sizing.md`: cross-reference updates for `/research`.
- All 22 long-form agent docs under `docs/agents/` and 18 long-form skill docs under `docs/skills/` gain neighbor-routing entries pointing at `/research` and `research-analyst` where the relationship is real.
- `plugin/agents/adversarial-validator.md` is updated alongside the cross-skill cross-referencing pass.

### Pull requests in this release

- Add a /research skill (#8) — @mxriverlynn
- Coding standards skill update: symlink as rules (#9) — @mxriverlynn

Full changelog: https://github.com/testdouble/han/blob/v2.5.0/CHANGELOG.md#v250

## v2.4.0

Three new plugin skills ship, taking the catalog from 15 to 18: `/issue-triage` for turning a vague report into a structured triage document, `/tdd` for a BDD-framed red-green-refactor loop, and `/plan-work-items` for breaking a trusted implementation plan into grabbable work items. `/architectural-analysis` is rebuilt as the sixth sizing-aware swarming skill, and three synthesis agents move to the opus tier so their shipped frontmatter matches the documented design intent.

### New skills

- `/issue-triage` classifies a vague issue or bug report into a structured document covering issue type, missing information, severity, reproducibility, and the recommended next han skill. Single pass, no sub-agents. (PR #5)
- `/tdd` drives a feature or behavior through a BDD-framed red-green-refactor loop with an enforced observed-failure gate. It is the plugin's only execution skill: it writes code, applies coding standards and ADRs during green and refactor, enforces YAGNI during refactor, and ships a `plugin/skills/tdd/scripts/detect-tdd-context.sh` discovery script. It runs autonomously after the initial request. (PR #7)
- `/plan-work-items` breaks a trusted implementation plan into independently-grabbable, atomic work items in a single `work-items.md` file, dispatching `project-manager` once and running autonomously without confirmation gates. (PR #2) The skill was developed under the working name `implementation-plan-to-issues` and renamed to `plan-work-items` before it ever shipped, so there is no breaking rename for v2.3.0 users.

### Architectural analysis rebuild

`/architectural-analysis` is rebuilt as a signal-selected, sizing-aware agent swarm. A synthesis spine (`structural-analyst`, `behavioral-analyst`, `risk-analyst`, `software-architect`) always runs; signal-selected specialists (`concurrency-analyst`, `adversarial-security-analyst`, `data-engineer`, `devops-engineer`, `codebase-explorer`, `system-architect`) are added by signal and size band; and the report is rendered from an extracted `plugin/skills/architectural-analysis/references/architectural-analysis-report-template.md`. This makes it the sixth sizing-aware swarming skill alongside `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, and `/plan-implementation`, and the shared sizing docs are updated to register it. (PR #6)

### Agent model tiers

`junior-developer`, `information-architect`, and `user-experience-designer` move from `model: sonnet` to `model: opus` in their agent frontmatter. All three perform synthesis over unbounded input, and `han.plugin-builder/skills/guidance/references/specialization-and-model-selection.md` already listed them under "Keep opus" with an opus rationale in their long-form docs, but their frontmatter had shipped as `sonnet` since the initial repo extraction. This aligns the implementation with the documented design intent. It is a real behavior and cost change whenever any of these three agents is dispatched.

### Documentation

- [`docs/skills/issue-triage.md`](./docs/skills/han.core/issue-triage.md): output-contract block now mirrors `plugin/skills/issue-triage/references/template.md` (an H1 summary title with H2 section headers), and the cost-and-latency note now reflects that the skill reads both `CLAUDE.md` and `project-discovery.md` to sharpen Suspected Areas.
- [`docs/skills/plan-work-items.md`](./docs/skills/han.core/plan-work-items.md): adds the missing `reference-artifact-inventory.md` link.
- `README.md`: the "Maintenance" heading typo is fixed.
- `plugin/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`: descriptions synced; they now mention planning and issue triage.
- `CLAUDE.md`: the "Current version" line is corrected.

### Repository tooling

- A repo-maintenance skill `/han-release` is added at `.claude/skills/han-release/` for cutting Han releases. It is internal to this repository and is not one of the 18 shipped plugin skills.

### Pull requests in this release

- Add /issue-triage skill (#5) — @spken
- Rebuild architectural-analysis skill: sizing-aware agent swarm (#6) — @mxriverlynn
- Add a /tdd skill (#7) — @mxriverlynn
- Add the plan-work-items skill (#2) — @kadams54

Full changelog: https://github.com/testdouble/han/blob/v2.4.0/CHANGELOG.md#v240

## v2.3.0

The `/code-review` skill is recalibrated so its first pass produces the output the user has been getting only by running a manual second-pass reclassification: severity inflation is removed at the structural level, user-provided focus areas and branch-level context reach every dispatched sub-agent, and contradictory same-file findings are detected internally rather than landing for the human to adjudicate without a flag.

### Calibration

- The agent-finding classification rubric in `plugin/skills/code-review/references/agent-finding-classification.md` no longer carries a "Most findings land here" WARN floor across seven of the nine agent rubrics. The rubric defines each severity; size-based demotion is governed by `SKILL.md` Step 3.3, the new authoritative home.
- `SKILL.md` Step 3.3 is now the single source of truth for size-based demotion. The Review Constraints rule for manual findings (line 24), the Step 7.2 demotion gate for agent findings, the size-aware rubric, and the YAGNI two-pass procedure all reference Step 3.3 by name rather than restating its content.
- `SKILL.md` Step 7 is restructured into three numbered sub-steps. 7.1 reads agent output; 7.2 applies the merged reachability phrase-match demotion gate (CRIT → WARN → SUGG → omitted) when a finding's rationale contains `theoretical`, `hypothetical`, `defense-in-depth`, `effectively impossible`, `in case the upstream`, `could happen`, `should never happen`, or `edge case that does not occur`; 7.3 classifies the surviving findings using the size-aware rubric. Security findings are exempt from the gate because the security agent's evidence standard already requires a demonstrated exploit path.

### Context plumbing

- New `Step 1.5: Load Branch Context` runs after Step 1 (Mode A and Mode B only). It attempts the PR description via `gh pr view`, local `pr-body` files, branch commit messages, and an implementation plan from the planning directory (resolved via the `plans:` key in CLAUDE.md or by Glob fallback). The loaded summary binds to `$branch_context`. When nothing loads, the skill warns once and binds `$branch_context` to `none provided`.
- `$focus_areas` and `$branch_context` are explicit named bindings. Step 1 binds the user's free-form argument to `$focus_areas` (defaulting to `none provided` when empty); Step 1.5 binds the loader output to `$branch_context`. Every Step 3.5 agent prompt includes both bindings verbatim so the agents can deprioritize work the team has already deferred or resolved.
- `Bash(gh *)` is added to the skill's `allowed-tools` frontmatter so Step 1.5 can call `gh pr view`.

### Per-agent dispatcher tailoring at Step 3.5

- `structural-analyst` and `behavioral-analyst` receive a default-SUGG dispatcher directive: every finding starts at SUGG; escalation to WARN or CRIT requires the change to actively introduce or worsen the issue. The agents' general behavior outside `/code-review` is unchanged.
- `junior-developer` receives a file-list scoping directive: outward reads are for context only; findings must concern code on the scoped file list. The agents' general behavior outside `/code-review` is unchanged.
- `edge-case-explorer` receives a narrower file-list directive that preserves Protocol 1's caller-read pattern: callers can be read as evidence, but the failure-mode target of every finding stays on the file list.

### YAGNI two-pass procedure

- `references/review-checklist.md`, the Step 3.3 calibration directive's YAGNI block, and the Review Constraints YAGNI rule are all rewritten to run YAGNI in two passes: Pass 1 evidence test against `yagni-rule.md` Gate 1, then Pass 2 named anti-pattern match. Each YAGNI finding's body names the failing evidence type, the matched anti-pattern, and the simpler form considered. The YAGNI section's verbatim opening statement is preserved.
- In Mode B (uncommitted changes) and Mode C (no git), the YAGNI checklist is skipped unless the user explicitly requests it via `$focus_areas`, since the diff signal that separates introduced code from pre-existing code is absent.

### Self-consistency check

- New `Step 9.0: Self-consistency check` runs before structural verification. An extraction pass collects `{task-id, file-path, line-range, recommended-action-summary}` tuples for every finding, then a comparison pass flags overlapping-line-range pairs whose recommendations prescribe opposite actions on the same code. Both findings are demoted by one severity and each receives a `Tension with {other-task-id}:` note for the human reviewer. Cross-file semantic contradictions are out of scope.

### Premise verification before standards-compliance findings

- Step 5 now requires reading at least one architectural file in the codebase that demonstrates a standard's premise before raising a "violates standard X" finding. When the file does not confirm the premise (e.g., the standard assumes SPA-style company switching but the codebase uses full-page redirects), the finding is omitted with a logged note. The "infer the premise from the standard's own examples" path is now a reason to omit, not a forward path to raise.

### Documentation

- [`docs/skills/code-review.md`](./docs/skills/han.core/code-review.md) is updated to mirror the new step structure (Step 1.5, the Step 7 sub-steps, Step 9.0), the per-agent dispatcher tailoring, the size-based demotion model, the YAGNI two-pass procedure, the full agent task ID format set, and the new YAGNI section in the output description.
- The four affected agent docs ([`docs/agents/structural-analyst.md`](./docs/agents/han.core/structural-analyst.md), [`docs/agents/behavioral-analyst.md`](./docs/agents/han.core/behavioral-analyst.md), [`docs/agents/junior-developer.md`](./docs/agents/han.core/junior-developer.md), [`docs/agents/edge-case-explorer.md`](./docs/agents/han.core/edge-case-explorer.md)) each carry a one-paragraph note explaining the `/code-review` Step 3.5 dispatcher tailoring and confirming the agents' default behavior in other skills is unchanged.
- [`docs/yagni.md`](./docs/yagni.md) `/code-review` table row is updated to reflect the two-pass procedure and the Mode B / Mode C YAGNI skip.
- [`docs/skills/gh-pr-review.md`](./docs/skills/gh-pr-review.md) gains a Key Concept noting that the wrapped `/code-review` Step 1.5 plumbs the PR description into every agent's `$branch_context`.

### Deferred (YAGNI)

- A dedicated S12 mode flag for default-SUGG suppression is deferred. The size-aware rubric (Pair A) plus the merged Step 7.2 demotion gate (Pair B) plus the rewritten Review Constraints rule subsume the workaround the user has been running manually.
- A structured "directly introduced" field in agent output formats is deferred in favor of phrase-matching at Step 7.2.
- Cross-file semantic contradiction detection in Step 9.0 is deferred; only single-file overlapping-line-range contradictions are checked.
- An automated test harness, per-agent unit tests, and Mode C standalone tests are deferred.
- Edits to the four affected agent definition files are deferred; `/code-review`'s tailoring lives in Step 3.5 dispatcher directives so the agents remain general-purpose for other callers.

## v2.2.0

The `/gap-analysis` swarm flips from opt-in to opt-out, `junior-developer` is promoted to a required swarm role at every size to run an explicit actor-perspective sweep, and `project-manager` joins the swarm at medium and large to consolidate Section 4 of the report.

### Default-on swarm

The validator-and-augmenter swarm now runs by default at every size. Reply `no swarm` to opt out and fall back to the lightweight gap-analyzer-only pass; reply `lightweight` to drop to the minimum two required roles without domain specialists.

- **Small** *(default)*: 2–3 agents — `adversarial-validator` and `junior-developer` always, plus `evidence-based-investigator` when the current state is concrete. No PM at small.
- **Medium**: 4–6 agents — the required three plus 1–2 domain specialists plus `project-manager` for Section 4 synthesis.
- **Large**: 6–8 agents — the required three plus 2–4 domain specialists plus `project-manager`.

### Actor-perspective sweep

`junior-developer` is now a required swarm member at every size. Its job in `/gap-analysis` is to enumerate every actor the desired state addresses or implies (human end users and sub-roles, API callers, AI agents, integration partners, batch processes, internal services), check whether each gap holds for every actor type, and surface gaps the analyzer missed because it only considered one actor.

### Conditional second round

When the first-round swarm surfaces ≥ 3 `proposed_new_gap` entries (Trigger A) or contradictions on ≥ 20% of the analyzer's original gaps (Trigger B), the skill runs one additional `gap-analyzer` pass with the new actor context and merges the delta into the source file. Bounded to one extra round.

### Section 4 default-on; augmentations inline into Section 2

Section 4 (Swarm Findings) is now rendered by default and is omitted only when the user passed `no swarm`. Swarm augmentations (added risks, secondary effects, refined framing, actor-perspective notes from `junior-developer`) inline into Section 2 entries as `Additional context (swarm):` lines so they land where the gap lives, while Section 4 retains the audit-trail listing.

### Documentation

- [`docs/skills/gap-analysis.md`](./docs/skills/han.core/gap-analysis.md) — updated TL;DR, key concepts, sizing table, cost-and-latency model, "In more detail" section, and Sources / Related Documentation to reflect the opt-out posture.
- Cross-references updated in [`docs/concepts.md`](./docs/concepts.md), [`docs/quickstart.md`](./docs/quickstart.md), [`docs/sizing.md`](./docs/sizing.md), [`docs/skills/README.md`](./docs/skills/README.md), and the agent docs for `adversarial-validator`, `evidence-based-investigator`, `junior-developer`, `project-manager`, and `gap-analyzer`.

## v2.0.1

The "this codebase is a startup" framing is removed from the YAGNI rule and every skill and agent that inherits it. The evidence-based YAGNI mechanic is unchanged — only the rationale prose is reframed so the rule reads as project-agnostic guidance rather than advice contingent on company stage.

Affected files: `docs/yagni.md`, `references/yagni-rule.md`, the `project-manager` and `junior-developer` agents, and the `iterative-plan-review`, `plan-a-feature`, `plan-a-phased-build`, `plan-implementation`, and `test-planning` skills. Every removal preserves the surrounding "every X is ongoing maintenance and a pattern future agents will copy" sentence that does the actual work.

## v2.0.0

Two skills are renamed and a YAGNI (You Aren't Gonna Need It) discipline is woven through the planning, review, and architecture skills and agents.

### Breaking changes

Two skills have been renamed. Update any scripts, slash-command invocations, agent prompts, or documentation that referenced the old names.

| Old name | New name |
| --- | --- |
| `han:gh-pr-description` | `han:update-pr-description` |
| `han:create-adr` | `han:architectural-decision-record` |

The skill behavior is unchanged — only the names and their on-disk directories. Old names will not resolve; the slash commands are now `/update-pr-description` and `/architectural-decision-record`.

### YAGNI evidence requirements across planning, review, and architecture

Every place where the plugin proposes new code, new tests, new infrastructure, or new abstractions now requires concrete evidence that the work is needed today — not speculation about the future. Added to:

- Planning skills: `/plan-a-feature`, `/plan-implementation`, `/plan-a-phased-build`, `/iterative-plan-review`
- Review and standards: `/code-review` (advisory-only), `/coding-standard`, `/test-planning`, `/architectural-decision-record` (forcing-function requirement)
- Agents: `project-manager`, `junior-developer`, `software-architect`, `system-architect`, `test-engineer`, `edge-case-explorer`, `data-engineer`, `devops-engineer`

Each skill or agent applies the rule to its own surface area — speculative tests, premature operational machinery, speculative data machinery, speculative edge cases, abstractions without a forcing function, and so on. Plans now include a **Deferred** section to capture explicitly-rejected speculative work.

## v1.7.0

Filename naming for `/coding-standard` and `/architectural-decision-record` outputs changes from a timestamp prefix to a discovered, hierarchical prefix so related documents sort together.

### Hierarchical filenames for coding standards and ADRs

Both skills replace the `{YYYYMMDDHHmmss}-{name}.md` pattern with `{top-level}[-{second-level}]-{name}.md`.

- The hierarchy prefix is one or two levels (e.g., `svelte-stores-state-shape.md`, `auth-tokens-rotation.md`).
- The taxonomy is **discovered at runtime**, not hardcoded — both skills parse existing standards/ADRs in the project's directory and read CLAUDE.md / project-discovery.md to identify the project's languages, frameworks, runtimes, subsystems, and bounded contexts as candidate top-level prefixes.
- When existing prefixes fit, they are reused; new top-levels are introduced only when nothing existing applies.
- When the discovered taxonomy offers more than one reasonable placement, the skill asks the user before writing.
- The unused `Bash(date *)` permission has been dropped from both skills' `allowed-tools`.

### Documentation

- [`docs/skills/coding-standard.md`](./docs/skills/han.core/coding-standard.md) and [`docs/skills/architectural-decision-record.md`](./docs/skills/han.core/architectural-decision-record.md) updated to describe the hierarchical filename pattern, the discovery step, and the new shape of the produced filename.

## v1.6.1

Sizing becomes a foundational dispatch lever across the swarming skills.

### Size-aware code-review agent dispatch

`/code-review` now classifies the change as small / medium / large before dispatching agents, defaults to small, and scales the roster proportionally.

- Two agents always run on every review: `junior-developer` and `adversarial-security-analyst`.
- The rest of the roster — `test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, `devops-engineer` — is dispatched conditionally based on what the changed files actually touch.
- Every agent brief carries a calibration directive that requires findings to be either introduced/worsened by the change or critical irrespective of who introduced it. Severity scales with size.
- `data-engineer` and `devops-engineer` join the conditional roster with finding-classification rubrics for data-side and operational concerns.

### Cross-skill `$size` argument

All five sizing-aware skills — `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation` — now declare a positional `size` argument in their frontmatter per the Claude Code skills spec.

- Pass `small`, `medium`, or `large` as the first positional argument to override the auto-classification: `/code-review medium`, `/plan-a-feature large "describe the feature"`, etc.
- When `$size` is non-empty, the skill uses that value as the size and scales its team / swarm caps and finding calibration accordingly.
- Without `$size`, the skill auto-classifies from concrete signals (file count, subsystems touched, security/data/integration surface).

### Default to small across all sizing-aware skills

Every sizing-aware skill now starts the classification at small and only escalates when concrete signals clearly require it. Borderline signals stay at the smaller band — fewer agents producing higher-signal findings is the goal.

### New sizing reference doc

[`docs/sizing.md`](./docs/sizing.md) is the canonical cross-skill sizing reference.

- The three bands (small / medium / large) and what they mean.
- The auto-classification process and the `$size` override.
- A per-skill at-a-glance table covering all five sizing-aware skills.
- Cross-references in every sizing-aware skill's long-form doc back to the reference and vice versa.
- Discoverable from the front-door `README.md`, `docs/concepts.md`, `docs/quickstart.md`, and `docs/skills/README.md`.

### Documentation refreshes

- `docs/skills/code-review.md` — refreshed for the size-aware dispatch model (was still describing the old "six agents always run" shape).
- New **Sizing** section in each of `docs/skills/code-review.md`, `docs/skills/gap-analysis.md`, `docs/skills/iterative-plan-review.md`, `docs/skills/plan-a-feature.md`, `docs/skills/plan-implementation.md`.
- `docs/concepts.md`, `docs/quickstart.md`, `docs/skills/README.md`, and `docs/skills/gh-pr-review.md` updated to reflect the new code-review roster shape.

## v1.6.0

Two new skills land in the `han` plugin, both producing plain-language reports that stakeholders (not just engineers) can read.

### `/gap-analysis` — compare two artifacts and find what's missing

Run a gap analysis between a *current state* and a *desired state* — for example a PRD vs. the shipped feature, a spec vs. its implementation, or any "what's missing from X compared to Y" question.

- Delegates the heavy analysis to the `gap-analyzer` agent, then synthesizes a stakeholder-readable report indexed by stable `G-NNN` gap IDs.
- Default output is plain language only — no file paths, line numbers, or code references in the main sections. Technical detail is opt-in.
- Optionally launches a swarm of validator/augmenter agents to corroborate or enrich findings. Swarm size (small / medium / large) is recommended based on gap count and category mix, but it never runs without the user opting in.
- Ships with a report template (`references/gap-analysis-report-template.md`) designed by the `information-architect` agent.

See [`/gap-analysis` documentation](./docs/skills/han.core/gap-analysis.md).

### `/plan-a-phased-build` — turn context into a sequenced build plan

Take any source of context (a gap analysis, PRD, design doc, feature spec, conversation notes, ADR, etc.) and produce a `build-phase-outline.md` that splits the work into vertical-slice phases.

- Every phase is **demonstrable to a real person** end-to-end — not "we shipped a service" but "you can do X and Y happens".
- Phases sequence for earliest demoable value. Foundational/prerequisite phases only come first when dependencies actually require it.
- Plain-language throughout: product-level subsystem names, user-facing vocabulary, behavioral verbs. A non-technical stakeholder can read it cover to cover.
- Each phase cross-references back to the source artifact for traceability.
- The `information-architect` agent reviews the rendered document for findability and progressive comprehension.

See [`/plan-a-phased-build` documentation](./docs/skills/han.core/plan-a-phased-build.md).

### Documentation

- New skill docs: [`gap-analysis.md`](./docs/skills/han.core/gap-analysis.md), [`plan-a-phased-build.md`](./docs/skills/han.core/plan-a-phased-build.md)
- [Skills Index](./docs/skills/README.md) and [Quickstart](./docs/quickstart.md) updated to surface both
- Minor link/version touch-ups across existing skill docs
