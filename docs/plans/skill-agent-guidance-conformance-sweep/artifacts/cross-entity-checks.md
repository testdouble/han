# Cross-Entity Checks

These checks cannot be answered by reading one skill or one agent file, so they are not in the per-entity checklists.
Each one needs a second file, a whole directory, or a grep across the roster. Run them once across the sweep rather than
once per entity.

Keeping them separate is deliberate. A per-entity checklist is only useful if a reviewer can finish an item with the file
open in front of them. An item that secretly needs four other files gets answered from memory, which is how two reviewers
reach different conclusions about the same skill.

Guidance root for every citation: `han-plugin-builder/skills/guidance/references/`.

## Boundary clauses point both ways

**X1. Does every "does not do X, use Y instead" clause have a matching reverse clause on the named sibling?**

One-way disambiguation leaves a gap the model falls through. This applies to skill descriptions and agent descriptions
alike, and it is the check most likely to break while trimming, because cutting one side of a pair looks safe in
isolation.

Source: `skill-building-guidance/skill-description-frontmatter.md` § Define boundaries, and
`agent-building-guidelines/agent-description-length.md` § Boundaries are bidirectional.

## No unique routing anchor was deleted

**X2. Before deleting a domain term from any description, does that term still appear in another description?**

A term carried by several descriptions is a name-drop and is safe to cut. A term carried by exactly one is the only
always-loaded place a real request can land, and cutting it removes the route silently. Grep every description before
deleting, not after.

Source: `agent-building-guidelines/agent-description-length.md` § Keep unique anchors.

## Plugin naming

**X3. Does each plugin's directory name match the `name` field in its `plugin.json`, and does that name contain no dot?**

A dot breaks Codex entirely and Claude Code partially, because the plugin name doubles as the namespace prefix on its
skills and agents.

Source: `skill-building-guidance/naming-conventions.md` § Plugin directory name, § Never put a dot in a plugin name.

## Every dispatch target resolves

**X4. Does every namespaced dispatch target named in a skill correspond to an agent that actually exists in that plugin?**

A namespace that names a plugin defining no such agent resolves to nothing. Checking this needs the dispatching skill and
the target plugin's `agents/` directory together.

Source: `skill-building-guidance/agent-dispatch-namespacing.md` § Never use a meta-plugin prefix.

## No cross-skill script references

**X5. Does every script a skill invokes live in that same skill's `scripts/` directory?**

Referencing another skill's script creates a hidden dependency that breaks when the other skill changes or is removed.
Answering this needs the invoking skill and the target directory.

Source: `skill-building-guidance/script-execution-instructions.md` § Each Skill Gets Its Own Scripts.

## Vendored reference copies stay identical

**X6. Is each vendored copy of a shared rule byte-identical to its canonical original?**

This is a repository convention rather than a guidance rule, and it constrains the sweep rather than being something the
sweep fixes. The vendored copies of the configuration, YAGNI, and evidence rules are deliberate. Editing one copy in
place breaks the convention.

Source: `CLAUDE.md` § Configuration, § Conventions.

## Documentation surfaces match the definitions

**X7. Does each changed description still match its long-form doc summary, its plugin README mention, and its index entry?**

Every skill and agent has three other surfaces that reuse its summary line. Changing a description without changing them
leaves three places describing something the definition no longer says. Answering this needs the definition and all three
surfaces.

Source: `CLAUDE.md` § Conventions, § Indexes stay complete not counted; `docs/templates/coverage-rule.md`;
`skill-building-guidance/documentation-maintenance.md` § Version documentation with the code it describes.

## Indexes list every entity

**X8. Does each index list every skill and every agent found on disk, and does it state no running total?**

Verify by walking the directories, not by comparing against a count. A stated total is itself a defect under the
repository convention.

Source: `CLAUDE.md` § Indexes stay complete, not counted.

## Consolidation candidates

**X9. Which entities overlap enough with a sibling to be worth consolidating, and why?**

The guidance sets roughly eighty percent overlap as the line between genuine duplication and entities that share a
foundation but serve different purposes. This sweep records candidates and takes no action on any of them, because the
recorded boundary excludes it.

Source: `iterative-plugin-development.md` § Identify overlap and consolidation at each iteration;
`artifacts/scope-boundary.md` § Stated Exclusions.
