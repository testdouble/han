# Per-Entity Audit Checklist

Verification rules applied to every entity in scope. The skill's mode (branch vs. sweep) determines *which* entities are in scope. This checklist determines *what* is checked for each one. Apply every rule that fits the entity's type. Record each finding with the file path and a concrete fix; do not paper over discrepancies.

`{plugin}` below means the skill root the skill came from: one of `han.core`, `han.github`, `han.reporting`, `han.feedback`. Agents live only under `han.core`.

## Skills (`{plugin}/skills/{name}/SKILL.md` + `docs/skills/{name}.md`)

### Skill definition (`{plugin}/skills/{name}/SKILL.md`)

1. **Frontmatter `name` matches directory name.** `name: foo-bar` requires `{plugin}/skills/foo-bar/`.
2. **Frontmatter `description` is current.** Reflects what the steps actually do. If steps changed and the description still names a removed step or omits a new one, update the description.
3. **`allowed-tools` matches actual usage.** Every tool the steps call is listed; tools no longer used are removed. Each Bash command prefix is a separate `Bash()` entry.
4. **Referenced scripts exist.** Every `${CLAUDE_SKILL_DIR}/scripts/...` path resolves to a real file under the skill's `scripts/`.
5. **Referenced files exist.** Every `references/...` or `docs/...` link in the body resolves.
6. **No stale directives.** If the SKILL.md tells the agent to use a renamed flag, a removed script, an abandoned convention, or a deleted sibling skill, fix it.

### Long-form doc (`docs/skills/{name}.md`)

1. **Long-form doc exists.** Every skill across the four skill roots has a matching long-form doc. Missing doc is a hard finding — create it from `docs/templates/skill-long-form-template.md` rather than leaving the gap.
2. **Orientation frame intact.** First line is `# /{name}`; the second paragraph names the audience and links to `{plugin}/skills/{name}/SKILL.md`. The `> See also:` orientation line is present.
3. **TL;DR present.** Three lines: what / when / what-you-get-back. Each one sentence.
4. **Sections follow the template.** Key concepts, When to use it, How to invoke it, What you get back, How to get the most out of it, YAGNI (when applicable), Cost and latency, In more detail (optional), Sources, Related documentation.
5. **TL;DR matches the skill's frontmatter description.** A reader who reads the SKILL.md frontmatter and the long-form TL;DR must come away with the same understanding. Mismatches are a finding.
6. **"Do not invoke for" pointers resolve.** Every sibling skill named in a boundary statement exists. The other direction is bidirectional — see "Cross-references" below.
7. **"How to invoke it" examples reflect actual argument-hint.** If the SKILL.md `argument-hint` changed, examples and prose update with it.
8. **"What you get back" matches what the skill produces.** File names, locations, section structures, and ID schemes match the steps in SKILL.md.
9. **Sources are still cited correctly.** URLs resolve and named artifacts in the skill trace back to them. Removed citations correspond to removed protocols.
10. **Related documentation first bullet links to the plugin landing page** (`../../README.md`), per the convention in CLAUDE.md.
11. **Agent links resolve.** Every `[agent-name](../agents/{name}.md)` in Related documentation resolves to a real long-form agent doc.

### Cross-references

1. **`docs/skills/README.md` lists the skill** with a one-sentence scent line under the right group. If the skill's purpose changed groups, move it.
2. **`docs/skills/README.md` scent matches current behavior.** A scent line that names a removed agent, a removed sub-skill, or an outdated capability is a finding.
3. **CLAUDE.md skill catalog entry is present** and the one-liner matches current behavior.
4. **CLAUDE.md "Indexes stay complete, not counted" convention holds.** The skill has a long-form doc and a skills-index entry, and no removed skill is still listed. Verify completeness, not a count.
5. **Bidirectional boundary statements.** If skill A's frontmatter says "use B instead," skill B's frontmatter mentions A in the reverse direction. Same for long-form `Do not invoke for` sections.
6. **Bidirectional Related documentation links.** If `/foo` pairs with `/bar`, both long-form docs name the pairing.
7. **README.md skill references stay count-free.** The Skills Index links resolve and the surrounding text names no hardcoded skill count.

## Agents (`han.core/agents/{name}.md` + `docs/agents/{name}.md`)

### Agent definition (`han.core/agents/{name}.md`)

1. **Frontmatter `name` matches the file's basename.**
2. **Frontmatter `description` is current.** Reflects what the agent does, when to dispatch it, and what it does not do. Boundary statements name the right sibling agents.
3. **`tools` matches actual usage.**
4. **`model` matches the model selection guidance** in `han.plugin-builder/skills/guidance/references/specialization-and-model-selection.md` for this agent's role.
5. **No stale references.** Sibling agents named in the boundary all exist. Skills named as callers exist.

### Long-form doc (`docs/agents/{name}.md`)

1. **Long-form doc exists** for every agent in `han.core/agents/`. Missing doc is a hard finding — create it from `docs/templates/agent-long-form-template.md`.
2. **Orientation frame, TL;DR, and template sections present** per `docs/templates/agent-long-form-template.md`.
3. **"Dispatched by" or equivalent section names every skill that uses this agent.** When a skill's dispatch list changed, this section updates.
4. **TL;DR matches the agent's frontmatter description.**
5. **Related documentation first bullet links to the plugin landing page** (`../../README.md`).
6. **Skill links resolve.**

### Cross-references

1. **`docs/agents/README.md` lists the agent** with a one-sentence scent line under the right role group.
2. **Scent line matches current agent behavior.**
3. **CLAUDE.md agent catalog list** (the by-role grouping) includes the agent.
4. **CLAUDE.md "Indexes stay complete, not counted" convention holds.** The agent has a long-form doc and an agents-index entry, and no removed agent is still listed. Verify completeness, not a count.
5. **README.md agent references stay count-free.** The Agents Index links resolve and the surrounding text names no hardcoded agent count.
6. **Skills that dispatch this agent** name it in their long-form Related documentation section.

## Top-level concept docs (`docs/concepts.md`, `docs/quickstart.md`, `docs/sizing.md`, `docs/yagni.md`, `docs/writing-voice.md`)

1. **`docs/concepts.md` stays count-free.** The "What does the plugin include?" bullets reference the skills and agents through their index links, not a hardcoded count.
2. **Named skills/agents still exist** under those names. No mention of removed skills, no missing mention of skills added to relevant categories.
3. **Cross-references resolve.** Every internal link points at a real file.
4. **No stale protocols.** A claim like "the swarming skills are A, B, C, D, E, F, G" must list the actual seven sizing-aware skills.

## Indexes (`docs/skills/README.md`, `docs/agents/README.md`)

1. **Every skill (across the four skill roots) and every agent (in `han.core/agents`) appears in the index** under exactly one group.
2. **No index entry points at a non-existent file.**
3. **Group headings still describe their groups accurately.** When a category was renamed or merged, the heading updates.
4. **Each entry's scent line is current.**
5. **Compositions list reflects current pairings.** The `## How skills compose` block in the skills index lists compositions that still hold; removes those that no longer do.

## Guidance docs (`han.plugin-builder/skills/guidance/references/**`)

1. **References to scripts, file paths, tool flags, and conventions are current.** Doc-code contradictions are functional bugs — see `documentation-maintenance.md`.
2. **Cross-references at the bottom resolve.**
3. **Examples cite current skills or agents.** A guidance doc that uses a removed skill as its canonical example must update the example.

## Templates (`docs/templates/**`)

1. **Templates reflect the current expected shape of long-form docs.** If most long-form docs added a section the template lacks, propose adding it to the template (or treat the new section as drift to remove).
2. **`coverage-rule.md`'s rules are still accurate.** Verify the coverage rule (every skill and agent has a long-form doc) holds; do not track a count.

## Root files (`README.md`, `CONTRIBUTING.md`, `CLAUDE.md`)

### README.md

1. **Install/intro paragraphs stay count-free.** The intro references the skills and agents without a hardcoded count, and the Skills Index and Agents Index links resolve.
2. **Links to docs resolve.**
3. **Maintainer list, license, and install instructions are still correct.**

### CONTRIBUTING.md

1. **The "Adding a skill" / "Adding an agent" checklists still match the current process.**
2. **Linked guidance files exist.**
3. **The Documentation conventions list still matches what the long-form docs do.**

### CLAUDE.md

1. **Repository layout section reflects the actual on-disk structure.**
2. **Doc map ("When to use which doc") lists every skill and agent long-form doc with a one-line description.**
3. **"Indexes stay complete, not counted" convention line is accurate.** It describes the completeness check (every entity has a doc and an index entry), not a running total.
4. **Conventions section matches what the docs actually do.**

## Reporting findings

For each finding, capture:

1. **Location.** Absolute path from repo root.
2. **What is wrong.** One sentence.
3. **The fix.** Concrete edit, not a vague "update this."
4. **Apply the fix in place** before reporting unless the fix requires a judgment only the user can make (a renamed agent's intent, a removed skill's replacement, a category boundary the user has not decided yet). In those cases, surface the finding to the user with a recommended resolution.
