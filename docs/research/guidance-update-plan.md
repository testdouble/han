# Guidance Update Plan

Companion to `guidance-currency-review.md`. This is the plain-language plan for updating the contributor guidance under `han.plugin-builder/skills/guidance/references/` so it matches current (June 2026) Claude Code standards. It groups the work into waves by impact, and for each item says what to do, why, and which source backs it. Nothing here is deleted; the changes are additions, citations, and refreshes.

The headline: the guidance is in good shape. Most docs are current. The real work is one new reference doc, a handful of factual refreshes on the plugin/marketplace config docs and the agent docs, and one citation gap that should be closed because it currently presents real research as an unsourced claim.

## Wave 1 — Fix the citation gap (do first, highest trust risk)

**1. Re-ground `multi-agent-economics.md`.** This doc presents a precise efficiency table and three hard numbers (a 45% threshold, 39-70% sequential degradation, ~70% of tasks handled by one agent) attributed to "DeepMind, 2025" with no link. The study is real — *Towards a Science of Scaling Agent Systems* (Google Research / Google DeepMind / MIT, 2025). The fix:
   - Add the real citation with its link.
   - The 45% threshold and the 39-70% degradation figure are confirmed by the study — keep them, now sourced.
   - The exact efficiency table (3 agents = ~4x cost / ~2x quality) is not clearly from the paper. Either verify it against the paper or relabel it as "an illustrative model of the diminishing-returns shape," so it does not read as study data.
   - Flag the "5-agent hard cap" as Han's own heuristic, and note that the official agent-teams doc independently recommends 3-5 teammates, which corroborates the direction.
   - Add a short paragraph distinguishing what Han actually does (parallel dispatch via the `Agent` tool, results summarized back) from the experimental agent-teams feature (separate Claude instances, linear token cost), so readers do not conflate the two.

Why first: this is the one place where the guidance currently makes strong quantitative claims without a source. Closing it protects the credibility of the whole guidance set.

## Wave 2 — Add the missing frontmatter reference (biggest coverage gap)

**2. Create `skill-building-guidance/skill-frontmatter-fields.md`.** No existing doc inventories the SKILL.md frontmatter fields Claude Code now supports. The repo already uses some of them (`paths:`, `context: fork`) without a doc that names them. Write a single reference listing the current field set with one-line semantics each: `name`, `description`, `when_to_use`, `allowed-tools`, `disallowed-tools`, `argument-hint`, `arguments`, `model`, `effort`, `context` (with `fork`), `agent`, `disable-model-invocation`, `user-invocable`, `hooks`, `paths`, `shell`. Cross-link it from `skill-description-frontmatter.md`, `progressive-disclosure.md`, and the skill-building index. Source: official Skills doc.

Why second: it is net-new and unblocks accurate cross-references from several other docs.

## Wave 3 — Refresh the agent docs

**3. Update `agent-building-guidelines/agent-model-selection.md`:**
   - Refresh the built-in Claude Code agent list to the current set: `Explore` (Haiku), `Plan` (inherit), `general-purpose` (inherit), `statusline-setup` (Sonnet), `claude-code-guide` (Haiku).
   - Add the model-resolution order: `CLAUDE_CODE_SUBAGENT_MODEL` env var → per-invocation choice → frontmatter `model` → main conversation model (the `inherit` default).
   - Add a short note that, for agents shipped in a plugin (all of Han's), the `hooks`, `mcpServers`, and `permissionMode` frontmatter fields are ignored — a documented security boundary. This belongs here or in `agent-external-files.md`.
   - Optionally add a brief mention of the other agent frontmatter fields (`tools`, `disallowedTools`, `maxTurns`, `memory`, `isolation`, `color`, `background`) or a pointer to the official Subagents doc, since Han only documents `model` today.

   Source: official Subagents doc.

**4. Minor touch on `agent-dispatch-namespacing.md`:** where it says "an agent never dispatches another agent directly," note this matches the general platform rule (subagents cannot spawn subagents) rather than presenting it purely as a Han choice. Source: official Subagents doc.

## Wave 4 — Refresh the plugin / marketplace config docs

These are accurate on what they cover but have drifted behind recent Claude Code additions.

**5. Update `claude-marketplace-and-plugin-configuration/plugin-json-options.md`:**
   - Add `displayName` (v2.1.143+) and `defaultEnabled` (v2.1.154+).
   - Add the `CLAUDE_PROJECT_DIR` environment variable alongside the two already listed.
   - State that `monitors` and `themes` are now preferred under the `experimental.*` key; the bare top-level placement still works but `claude plugin validate` warns. This matters for anyone running `claude plugin validate --strict` in CI.

**6. Update `claude-marketplace-and-plugin-configuration/marketplace-json-options.md`:**
   - Complete the reserved-names list — add `anthropic-agent-skills`, `claude-for-legal`, `claude-for-financial-services`, and `financial-services-plugins` (Han lists 8; the official list is 12).
   - Add `displayName` and `defaultEnabled` to the plugin-entry fields.

**7. Update `monitors-json-options.md` and `themes-json-options.md`:** label both as experimental components and note the `experimental.monitors` / `experimental.themes` placement in `plugin.json`.

**8. Update the example manifests in `templates/`** (`plugin-example.json`, `marketplace-example.json`) once items 5-7 land, so the examples show `displayName`, `defaultEnabled`, and the `experimental.*` placement. Keep examples and reference docs in sync (this is a Han convention).

   Source for items 5-8: official Plugins Reference and Plugin Marketplaces docs.

## Wave 5 — Small additions and citations to otherwise-current docs

These are low-effort improvements, not corrections. Batch them.

**9. `naming-conventions.md`:** add the gerund-form naming preference (`processing-pdfs`, with noun/action forms acceptable) — currently it only appears in the Cowork doc, but Anthropic states it as a general convention. Add one sentence clarifying that the directory name drives the slash command and the frontmatter `name` is the display label (except plugin-root SKILL.md). Source: Skill authoring best practices; Skills doc.

**10. `skill-description-frontmatter.md`:** state third-person voice as an explicit rule ("Processes Excel files," not "I can help"). Optionally cite the Anthropic "Writing effective tools for agents" post for the principle that description quality deserves as much attention as the system prompt. Source: best-practices doc; engineering post.

**11. `progressive-disclosure.md`:** state the 500-line SKILL.md ceiling explicitly (all five primary sources agree on it). Source: Skills doc, platform overview, open standard.

**12. `context-hygiene.md`:** add the Claude Code skill-compaction budget (25,000 tokens shared across skills, up to 5,000 per skill, most-recent re-attached first). Source: Skills doc.

**13. `skill-composition.md`:** acknowledge that `context: fork` (and the `agent` field) are now documented Claude Code features, then keep Han's empirical caveat that forked data-fetch sub-skills cause early exit — so the guidance reads as a deliberate choice, not unawareness. Source: Skills doc.

**14. `success-criteria-and-testing.md`:** add a note that smaller models (Haiku) may need more detailed skill instructions than larger ones, so triggering/functional tests should run against the model the skill targets. Source: best-practices doc.

**15. `workflow-patterns.md`:** optionally cite Anthropic's named workflow patterns (prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer) and the human-checkpoint guidance, which align with the patterns and human gates already described. Source: Building effective agents.

**16. `local-development.md`:** add `claude --plugin-dir ./plugin` (single-session, no install) and `/reload-plugins` as quick-iteration alternatives to the local-marketplace workflow already documented. Source: Create Plugins doc.

**17. `semantic-versioning.md`:** optional — note the `{plugin-name}--v{version}` git-tag convention and `claude plugin tag --push` used for dependency version resolution, since Han releases tag the suite. Source: Plugin Dependencies doc.

**18. `plugin-entity-taxonomy.md`:** add one clause noting `commands/` flat files still load (so "merged into skills" is not misread as "removed"), and bump the "Last Updated" date when edited. Source: Skills, Create Plugins docs.

## Consolidation / splitting

- **No splits needed.** The docs are already single-concern.
- **One small consolidation:** gerund-naming guidance currently lives only in the Cowork doc. Move the general statement into `naming-conventions.md` (item 9) and have the Cowork doc reference it, rather than being the sole home of a general rule.
- **No deletions.** Every doc earns its place.

## Re-verification note (not a content change)

`allowed-tools-AskUserQuestion.md` documents a live upstream bug (#29547). Before each release, re-check whether the bug is fixed upstream; if it is, this doc and the related `troubleshooting.md` entry should be revised or retired. This is a standing maintenance item, not part of this pass.

## Suggested commit grouping

To keep changes reviewable, commit in waves: (1) the multi-agent-economics citation fix, (2) the new frontmatter-fields doc, (3) the agent-doc refresh, (4) the plugin/marketplace config refresh plus example manifests, (5) the batch of minor additions. Each wave is independent and can land on its own.
