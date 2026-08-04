# Plugin README

Every plugin needs a `README.md` at its root directory for human readers on GitHub. The README is not loaded by the
plugin system. It exists purely for discoverability and onboarding when someone browses the repository.

The README is a light front door, not a second copy of the docs. It orients the reader and points into the canonical
long-form docs that live beside it under the plugin's own `docs/` folder. The long-form doc stays the single source of
truth for a skill or agent; the README stays the single source of truth for what its plugin does.

## The Rules

### Rule: Every plugin must have a root-level README.md

Place a `README.md` in the plugin's root directory (next to `.claude-plugin/`). This file is for human readers browsing
the repository on GitHub. It is not loaded by the plugin system and has no effect on skill behavior.

Skill directories must NOT have their own README files. All skill documentation belongs in `SKILL.md` and `references/`.
See [Naming Conventions](../han-plugin-builder/skills/guidance/references/skill-building-guidance/naming-conventions.md)
for details.

```
han-coding/
  README.md              # Plugin README. For humans on GitHub.
  .claude-plugin/
    plugin.json
  docs/
    skills/
      code-review.md     # Long-form skill doc. For humans on GitHub.
    agents/              # Only for plugins that own agents.
  skills/
    code-review/
      SKILL.md           # Skill definition. Loaded by plugin system.
      references/
        template.md
```

### Rule: Open with a one-paragraph what/how/why

Start with the plugin's H1, then one paragraph that says what the plugin does, how it does it, and why a reader would
reach for it. Keep it to a paragraph. The per-skill detail belongs in each skill's long-form doc, not here.

### Rule: State bundled-vs-opt-in and dependencies

State whether the `han` meta-plugin bundles this plugin or it is installed on its own, and name its dependencies. An
opt-in plugin that needs an MCP server says so. A reader who lands directly on one plugin README needs to know whether
installing the meta-plugin already brought this plugin in.

```markdown
**Bundled.** Installed with the `han` meta-plugin. Depends on `han-communication` and `han-core`.
```

```markdown
**Opt-in.** Installed on its own, not bundled by the `han` meta-plugin. Depends on `han-core` and requires a configured
Linear MCP server.
```

### Rule: List skills as scent lines that link to the long-form doc

List every skill as a one-line scent that links to that skill's long-form doc under this plugin's `docs/skills/`. Reuse
the long-form doc's own canonical summary line rather than writing a fresh one, so the README, the
[skills index](skills/README.md), and the long-form doc do not drift. The long-form summary line is the canonical scent.

Do not carry a per-skill paragraph, a files line, or example prompts. That detail lives in the long-form doc, and
repeating it here re-creates the duplication a reader has to keep in sync.

```markdown
## Skills

- [`/code-review`](docs/skills/code-review.md) — Run a comprehensive code review on local source files.
- [`/investigate`](docs/skills/investigate.md) — Evidence-based investigation of bugs, integrations, and unexpected
  behavior.
```

A plugin whose skills build on each other's output (one skill writes a reference file a later skill consumes) may add a
short ordered "Getting started" line before the skills list. Skip it when the skills are independent.

### Rule: List owned agents, or note shared-agent dispatch

Only `han-core`, `han-communication`, and `han-research` own agents. Their READMEs add an agents section listing each
owned agent as a scent line linking to its long-form doc under `docs/agents/`.

Every other plugin owns no agents. Its README omits an agents section and instead notes that its skills dispatch shared
agents, which live in `han-core` and, for the readability-editor, in `han-communication`. Do not list the dispatched
agents as if the plugin owned them.

```markdown
Its skills dispatch shared agents that live in `han-core` (and, for the readability-editor, in `han-communication`).
```

### Rule: Carry minimal lateral navigation

Close with a short navigation line up to the plugin index and the repository root, and across to the workflows page.
Keep it to those hops. The reader gets the cross-plugin catalog and the composition view without the README restating
either.

```markdown
[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
```

### Rule: The meta-plugin README omits skills and agents sections

The `han` meta-plugin ships no skills and no agents of its own. Its README describes what installing the meta-plugin
brings in, names the plugins it bundles, and points to the plugin index and the workflows page. It carries neither a
skills section nor an agents section, because it owns neither.

### Rule: Use the template

Follow the structural template at
[`plugin-readme-template.md`](../han-plugin-builder/skills/guidance/references/templates/plugin-readme-template.md). It
lays out the light front-door shape with HTML comments marking the sections a given plugin includes or omits.

## Summary Checklist

1. Every plugin has a root-level `README.md`. No READMEs inside skill directories.
2. Open with the H1 and a one-paragraph what/how/why.
3. State bundled-vs-opt-in and dependencies, including any required MCP server.
4. List skills as scent lines that reuse the long-form doc's summary line and link into `docs/skills/`.
5. List owned agents (`han-core`, `han-communication`, and `han-research` only), or note shared-agent dispatch for every
   other plugin.
6. Close with lateral navigation to the plugin index, the repository root, and the workflows page.
7. The `han` meta-plugin omits the skills and agents sections.
8. Follow the light template at
   [`plugin-readme-template.md`](../han-plugin-builder/skills/guidance/references/templates/plugin-readme-template.md).
