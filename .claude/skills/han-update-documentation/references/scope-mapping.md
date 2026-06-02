# Scope Mapping: Changed Files to Entities

Maps a changed file path to the documentation entities that must be reviewed for accuracy. Used in **branch mode**, where the skill audits only the entities the branch touched. In **sweep mode**, the skill enumerates the full inventory instead.

A single changed file can pull multiple entities into scope. Always add every entity the path touches.

`{plugin}` below means any of the four skill roots: `han.core`, `han.github`, `han.reporting`, `han.feedback`. Agents live only under `han.core`.

## Mapping table

| Path pattern | Entities pulled into scope |
|--------------|----------------------------|
| `{plugin}/skills/{name}/SKILL.md` | skill `{name}` |
| `{plugin}/skills/{name}/references/**` | skill `{name}` |
| `{plugin}/skills/{name}/scripts/**` | skill `{name}` |
| `han.core/agents/{name}.md` | agent `{name}` |
| `docs/skills/{name}.md` | skill `{name}` |
| `docs/skills/README.md` | skills-index |
| `docs/agents/{name}.md` | agent `{name}` |
| `docs/agents/README.md` | agents-index |
| `docs/concepts.md` | concepts |
| `docs/quickstart.md` | quickstart |
| `docs/sizing.md` | sizing |
| `docs/yagni.md` | yagni |
| `docs/writing-voice.md` | writing-voice |
| `docs/guidance/**/*.md` | the guidance file itself |
| `docs/templates/**/*.md` | the template file itself |
| `README.md` | root-readme |
| `CONTRIBUTING.md` | contributing |
| `CLAUDE.md` | claude-md |
| `CHANGELOG.md` | ignore (out of scope for this skill) |
| `{plugin}/.claude-plugin/plugin.json` | ignore (versioning belongs to /han-release) |
| `.claude-plugin/marketplace.json` | ignore (versioning belongs to /han-release) |
| `.claude/skills/**` | ignore (repo-local maintenance skills, no plugin docs) |
| anything else | ignore |

## Implicit dependencies

Some path changes drag additional entities into scope even when those entities' own files were not edited.

- **A new skill added** under `{plugin}/skills/{name}/`: also audit `docs/skills/README.md` (must list it), `CLAUDE.md` (catalog entry), `README.md`, `docs/concepts.md` (all must reference it without a hardcoded count).
- **A skill removed or renamed** under `{plugin}/skills/`: same as added, plus every other skill or agent doc whose Related Documentation section linked to the old name.
- **A new agent added** under `han.core/agents/`: also audit `docs/agents/README.md`, `CLAUDE.md` (catalog entry), `README.md` (must reference it without a hardcoded count).
- **An agent removed or renamed**: same as added, plus every skill doc that mentions dispatching the agent.
- **A skill description (frontmatter) changed**: also audit `docs/skills/README.md` scent line, the skill's long-form `docs/skills/{name}.md` TL;DR, and the `CLAUDE.md` catalog entry. Sibling skills named in the boundary may need their reverse-boundary statement checked.
- **An agent description (frontmatter) changed**: also audit `docs/agents/README.md` scent line, the agent's long-form `docs/agents/{name}.md` TL;DR.
- **A guidance doc renamed or moved**: every other doc that linked to the old path is in scope.

## Out of scope for this skill

These changes do not pull anything into the documentation update scope. They have their own owners.

- `CHANGELOG.md` — owned by `/han-release`.
- `{plugin}/.claude-plugin/plugin.json` `version` field (any of the five plugins) — owned by `/han-release`.
- `.claude-plugin/marketplace.json` `version` field — owned by `/han-release`.
- `.claude/**` repo-local config and skills — not part of the plugin's user-facing surface.
- `images/**`, binary assets.
- `LICENSE`.
