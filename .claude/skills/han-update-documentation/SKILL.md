---
name: han-update-documentation
description: >
  Update Han plugin documentation so every skill, agent, guidance doc, index,
  and cross-reference is current and accurate. On a non-default branch, scopes
  the pass to entities the branch actually touched. On the default branch,
  performs a full documentation sweep across the whole plugin. Use when
  updating, refreshing, syncing, auditing, or verifying Han's docs after
  changing skills, agents, references, or top-level guidance — including
  "update the docs", "doc sweep", "refresh documentation", "audit the docs",
  "make sure the docs are current". This is a repository-maintenance skill for
  the Han repo itself, not a general documentation skill — use
  /project-documentation to document features in arbitrary projects,
  /han-release to cut a release (and update CHANGELOG), and
  /update-pr-description for PR bodies.
argument-hint: "[optional context about what changed]"
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(git *), Bash(find *)
---

## Pre-requisites

- git: !`which git`
- repo root marker: !`find . -maxdepth 3 -name "plugin.json" -path "*/.claude-plugin/*" -type f`
- skill roots: !`find . -maxdepth 2 -type d -name skills -path './han.*/skills' ! -path './han.plugin-builder/skills' 2>/dev/null | sed 's|^\./||' | sort`
- agents directory: !`find . -maxdepth 2 -type d -name agents -path './han.*/agents' 2>/dev/null | sed 's|^\./||' | sort`

**If any of the above are empty:** this skill is intended to run inside the Han plugin repository. Tell the operator which marker is missing and stop. Do not attempt to operate on a different repo.

## Project Context

- current branch: !`git branch --show-current`
- default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD`

## Step 1: Detect mode and scope

Run `${CLAUDE_SKILL_DIR}/scripts/detect-doc-update-context.sh` and read its output. Branch on the `mode:` line.

The script also emits the **skill roots** (between `skill-roots-start` and `skill-roots-end`) and the **agent root** (the `agent-root:` line), both discovered dynamically from disk. These are the authoritative roots for the rest of this skill — use them wherever the steps below say "the skill roots" or "the agent root," rather than any hardcoded plugin list. A skill root is every `han.*/skills` directory except `han.plugin-builder/skills`, whose `guidance` skill is authoring guidance audited under guidance docs (Step 2, sweep), not a documented product skill. Adding a new product plugin needs no edit to this skill; it shows up in the discovered roots automatically.

**`mode: error`** — stop. Surface the `reason:` line to the operator. Do not proceed.

**`mode: branch`** — branch scope. Set `MODE = branch`. Read the file list between `changed-files-start` and `changed-files-end` (or note that the file list is empty if `changed-files: none` appears instead). If the file list is empty, inform the operator that the branch has no changes against the default branch and stop.

**`mode: sweep`** — full sweep. Set `MODE = sweep`. The skill audits every documentation entity across the plugin suite (every skill root the detect script reported, plus the agent root).

Echo back the mode and the count of in-scope files (branch mode) or "full plugin sweep" (sweep mode) so the operator knows what is about to happen.

## Step 2: Build the entity inventory

The mode determines *which* entities to audit. Always build a deduplicated list of entities before reading anything else, so Step 3 has a fixed plan.

### When `MODE = branch`

Map each changed file to its entities using [references/scope-mapping.md](./references/scope-mapping.md). A single file can pull multiple entities into scope (a changed skill SKILL.md pulls the skill plus, if the description changed, the index and CLAUDE.md catalog). Then apply the **implicit dependencies** section of the mapping reference: skill or agent additions and removals pull the indexes, CLAUDE.md, README, and `docs/concepts.md` into scope; sibling-boundary changes pull the named sibling into scope.

Deduplicate. Produce a single ordered inventory `INV`:

1. Skills, alphabetical.
2. Agents, alphabetical.
3. Indexes (`docs/skills/README.md`, `docs/agents/README.md`).
4. Top-level concept docs (`docs/concepts.md`, `docs/quickstart.md`, `docs/sizing.md`, `docs/yagni.md`, `docs/writing-voice.md`).
5. Guidance docs (specific files only).
6. Templates (specific files only).
7. Root files (`README.md`, `CONTRIBUTING.md`, `CLAUDE.md`).

### Plugin roots

Han ships as several plugins. Skills are spread across several of them; agents live in only one. Long-form docs stay flat under `docs/skills/` and `docs/agents/` no matter which plugin owns the entity.

- **Skill roots:** the list the detect script reported between `skill-roots-start` and `skill-roots-end`. Every `han.*/skills` directory except `han.plugin-builder/skills` (its `guidance` skill is authoring guidance, audited under guidance docs below). Do not hardcode the plugins here; read them from the script so a newly added plugin is covered automatically.
- **Agent root:** the script's `agent-root:` line (`han.core/agents`, the only plugin with agents).
- **Plugin manifests:** `{plugin}/.claude-plugin/plugin.json` for every plugin. Owned by `/han-release`; out of scope here.

Throughout this skill, `{plugin}` means whichever discovered skill root a given skill came from.

### When `MODE = sweep`

Enumerate the full set:

1. **Every skill.** Run `find <skill roots> -mindepth 1 -maxdepth 1 -type d`, passing the skill roots the detect script reported, for the inventory; each entry pulls in `{plugin}/skills/{name}/SKILL.md` (the root the directory came from) and `docs/skills/{name}.md`.
2. **Every agent.** Run `find <agent root> -mindepth 1 -maxdepth 1 -name "*.md" -type f`, passing the script's `agent-root`, for the inventory; each entry pulls in `{agent-root}/{name}.md` and `docs/agents/{name}.md`.
3. **Both indexes** (`docs/skills/README.md`, `docs/agents/README.md`).
4. **All top-level concept docs** in `docs/`.
5. **All guidance docs** under `han.plugin-builder/skills/guidance/references/`.
6. **All templates** under `docs/templates/`.
7. **Root files** (`README.md`, `CONTRIBUTING.md`, `CLAUDE.md`).

Sweep mode always audits that `README.md`, `CLAUDE.md`, and `docs/concepts.md` reference the skills and agents without a hardcoded count, and that every entity found in this step appears in the indexes and the CLAUDE.md catalog.

### Out-of-scope files (both modes)

Treat as ignored: `CHANGELOG.md`, plugin and marketplace `version` fields, `.claude/**`, `LICENSE`, `images/**`. These belong to other skills or are not user-facing documentation.

## Step 3: Per-entity audit

Walk `INV` in order. For each entity, apply every rule in [references/audit-checklist.md](./references/audit-checklist.md) that fits the entity's type. Record findings as you go in a working list with this shape:

```
- {entity-name} ({path})
  - Finding: {one-sentence description}
  - Fix: {concrete edit}
```

**Read the source of truth before checking the doc.** For a skill, read `{plugin}/skills/{name}/SKILL.md` first (the plugin root the skill came from), then read `docs/skills/{name}.md` and check it against the source. For an agent, read `han.core/agents/{name}.md` first, then `docs/agents/{name}.md`. Doc-vs-source contradictions are functional bugs — treat them with the same severity as broken scripts (see `han.plugin-builder/skills/guidance/references/skill-building-guidance/documentation-maintenance.md`).

**Batch agent audits when the inventory is large.** When `INV` has more than ten skills or ten agents to audit, dispatch a `content-auditor` agent per batch of five entities with the entity name, the source-of-truth file, and the long-form doc. Hand each agent the relevant section of [references/audit-checklist.md](./references/audit-checklist.md) inline (do not tell it to read the file). The agent returns findings; merge them into the working list. Do not run more than four such agents in parallel.

**Stop on first hard finding only for missing files.** Missing long-form doc, missing index entry, or missing CLAUDE.md catalog entry blocks the rest of that entity's checks until created. Other findings accumulate; do not bail.

## Step 4: Cross-reference and bidirectional-link audit

After Step 3, look across entities, not just within them.

1. **Bidirectional skill boundaries.** For every skill in `INV` whose frontmatter or long-form "Do not invoke for" section names a sibling, verify the sibling names this skill in the reverse direction. Asymmetric boundaries are findings.
2. **Bidirectional pairings.** For every skill or agent in `INV` whose long-form Related documentation names another, verify the other side links back where the link adds value. One-direction pairings without a reason are findings.
3. **Indexes are consistent with reality.** Use Grep to confirm every skill across the discovered skill roots appears in `docs/skills/README.md` exactly once, and every agent in the agent root appears in `docs/agents/README.md` exactly once. Stray entries pointing at non-existent files are findings.
4. **CLAUDE.md catalog completeness.** Every entity in `INV` (skills and agents) has a one-line entry in the CLAUDE.md doc map. Missing entries are findings.
5. **Count-free references.** Confirm `README.md`, `CLAUDE.md` (the "Indexes stay complete, not counted" line), and `docs/concepts.md` describe the skills and agents without a hardcoded total. A reintroduced count (for example "21 skills" or "23 agents") is a finding. Sweep mode always runs this check; branch mode runs it only if the branch added or removed skills or agents.
6. **The `## How skills compose` block in `docs/skills/README.md`** references current skill names only. References to renamed or removed skills are findings.

Add each finding to the working list with the same shape as Step 3.

## Step 5: Apply updates

Apply every finding from Steps 3 and 4 in place.

**Use Edit, not Write,** for changes that touch part of an existing file. Use Write only when creating a missing long-form doc from a template.

**Creating a missing long-form doc.** Copy `docs/templates/skill-long-form-template.md` (for a skill) or `docs/templates/agent-long-form-template.md` (for an agent) into the target path. Fill in the orientation frame, TL;DR, and Key concepts from the entity's frontmatter description and step body. Leave a `<!-- TODO: human review -->` marker only at sections that require operator judgment (Sources, In more detail, examples). Surface those markers in Step 6's report so the operator can finish them.

**Apply the writing voice.** Every edit follows `docs/writing-voice.md`: no em-dashes, direct second person, no flattery or hype words, no `actually`, `just`, `leverage`, `utilize`, `showcase`, `robust` (as a vague positive), `It's worth noting`, or `Importantly`. When fixing a doc, do not introduce voice violations even if the surrounding doc has them.

**Apply YAGNI to documentation edits.** Do not add speculative sections, *for-future-flexibility* warnings, or examples for behavior the skill does not have. The YAGNI rule that gates plan steps also gates docs (see `docs/yagni.md`).

**Bidirectional fixes go on both sides** in the same pass. If the fix is to add `/foo` to `/bar`'s `Do not invoke for` list, also add `/bar` to `/foo`'s reverse pointer in the same step.

**Findings that need operator judgment** stay unresolved. Surface them in Step 6. Examples: the user-facing category a new skill belongs in, the agent a removed skill's documentation should now point at, the wording for a Source citation that does not yet exist.

## Step 6: Verify and report

Re-read every file that was edited or created. Confirm:

1. **Every finding from Steps 3 and 4 was either applied or surfaced as needing operator judgment.**
2. **No new internal links are broken.** Run a Grep across the edited files for `](../` and `](./` and spot-check a few resolved paths.
3. **`README.md`, `CLAUDE.md`, and `docs/concepts.md` stay count-free** — no hardcoded entity total was introduced during the pass.
4. **No em-dashes were introduced** in any edited file.
5. **No `{placeholder}` braces from templates remain** in any newly-created long-form doc.

Then report to the operator:

- **Mode** (branch or sweep) and the inventory size.
- **Entities audited**, grouped by type (skills audited, agents audited, etc.).
- **Findings applied**, one bullet per fix, with the file path.
- **Findings surfaced for operator judgment**, with the recommended resolution.
- **Files changed**, as a list of paths the operator can pass to `git diff` for review.

Do not commit, push, or open a PR — those decisions are the operator's. The skill stops at this report.
