# Contributing to han

This page is for contributors: anyone adding, editing, or restructuring skills, agents, or documentation in the han plugin. If you just want to use the plugin, start with the [Plugin landing page](./README.md) or the [Quickstart](./docs/quickstart.md).

> See also: [Plugin landing page](./README.md) · [Concepts](./docs/concepts.md) · [Sizing](./docs/sizing.md) · [YAGNI](./docs/yagni.md) · [Evidence](./docs/evidence.md)

## TL;DR

- Skills ship from the plugin that matches what they do: [`han.core/skills/`](./han.core/skills/) (planning, investigation, review, documentation), [`han.coding/skills/`](./han.coding/skills/) (code-writing and execution), [`han.github/skills/`](./han.github/skills/) (GitHub-facing), [`han.reporting/skills/`](./han.reporting/skills/) (stakeholder reporting), or [`han.feedback/skills/`](./han.feedback/skills/) (feedback on Han itself); the contributor authoring guidance lives in [`han.plugin-builder/skills/`](./han.plugin-builder/skills/). All agents live in [`han.core/agents/{name}.md`](./han.core/agents/). See [Which plugin does the change belong in?](#which-plugin-does-the-change-belong-in) before you start.
- Long-form docs (for humans deciding *when* and *how* to use a skill or agent) live in `docs/skills/{name}.md` and `docs/agents/{name}.md`.
- **Every skill and every agent gets a long-form doc.** No exceptions. See the [coverage rule](./docs/templates/coverage-rule.md).
- Use the [long-form skill template](./docs/templates/skill-long-form-template.md) or the [agent template](./docs/templates/agent-long-form-template.md).
- The root [CLAUDE.md](./CLAUDE.md) carries the at-a-glance project map for assistants and contributors.

## Before you start

Read these once:

- **[`han.plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md`](./han.plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md).** What a skill is, what an agent is, what a hook is, and which to reach for.
- **[`han.plugin-builder/skills/guidance/references/skill-building-guidance/`](./han.plugin-builder/skills/guidance/references/skill-building-guidance/).** The skill-authoring rules: description frontmatter, progressive disclosure, context hygiene, dynamic project discovery, bash permissions, script execution.
- **[`han.plugin-builder/skills/guidance/references/agent-building-guidelines/`](./han.plugin-builder/skills/guidance/references/agent-building-guidelines/).** The agent-authoring rules: external files, model selection, domain focus, graceful degradation, multi-agent economics.
- **[Root `CLAUDE.md`](./CLAUDE.md).** Repo conventions, doc map, and where each kind of file lives.

## Which plugin does the change belong in?

Han ships as a family of plugins. Most carry components; the `han` meta-plugin bundles the others. Decide where your change goes before you scaffold anything. (For the user-facing version of this map, see [Choosing a Han plugin](./docs/choosing-a-han-plugin.md).)

- **`han.core`** carries the planning, investigation, review, documentation, and convention skills, plus **every agent in the suite**. Agents always go here. A skill goes here when it works against the codebase or a plan and needs no external service.
- **`han.coding`** carries the code-writing and execution skills (`tdd`, `refactor`). A skill goes here when it changes the source tree rather than producing a document, the way `tdd` writes tests and production code and `refactor` restructures existing code. It is bundled by the `han` meta-plugin.
- **`han.github`** carries the GitHub-facing skills (`post-code-review-to-pr`, `update-pr-description`, `work-items-to-issues`). A skill goes here when it reads from or writes to GitHub through the `gh` CLI.
- **`han.reporting`** carries the stakeholder-reporting skills (`stakeholder-summary`, `html-summary`). A skill goes here when its output is a report for a non-technical or executive audience rather than an engineering artifact.
- **`han.feedback`** carries the single `han-feedback` skill. A skill goes here only when it captures feedback on the Han suite itself.
- **`han.plugin-builder`** carries the contributor authoring guidance (the `guidance` skill and its reference set). It is opt-in and depends on nothing. Edit it when you change how skills, agents, or plugins are built; it is not where product-facing skills go.
- **`han`** is the meta-plugin. It has no components of its own; it depends on `han.core`, `han.coding`, `han.github`, and `han.reporting` so one install pulls them all in. `han.feedback`, `han.atlassian`, and `han.plugin-builder` are deliberately left out so they stay opt-in. You add a component to `han` only by adding it to one of the child plugins; you never put a skill or agent directly in `han`.

Two rules keep the dependency direction clean:

- **Every plugin depends on `han.core`,** so a skill in `han.coding`, `han.github`, `han.reporting`, or `han.feedback` may dispatch any `han.core` agent freely. That is why all agents live in `han.core`.
- **`han.core` depends on nothing in the other plugins.** A `han.core` skill must not reach for a skill or agent that ships only in `han.coding`, `han.github`, `han.reporting`, or `han.feedback`. If a core skill needs that capability, the capability belongs in `han.core`.

When a change adds, removes, or moves a skill between plugins, update the marketplace registry at [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) so the plugin's component set stays accurate. Long-form docs always live under `docs/` regardless of which plugin the entity ships in.

## Adding a skill

1. Decide the plugin using [Which plugin does the change belong in?](#which-plugin-does-the-change-belong-in) above, then scaffold the folder under that plugin's `skills/{name}/` directory (`han.core`, `han.coding`, `han.github`, `han.reporting`, or `han.feedback`) and add a `SKILL.md`.
2. Write the `SKILL.md`:
   - Frontmatter with `name`, `description`, `allowed-tools`. See [skill-description-frontmatter.md](./han.plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-frontmatter.md).
   - Body: numbered steps, `${CLAUDE_SKILL_DIR}` paths for script references, extracted references under `references/`.
3. Copy [the skill template](./docs/templates/skill-long-form-template.md) into `docs/skills/{name}.md` and fill it in. Every skill gets a long-form doc.
4. Add the skill to the [Skills Index](./docs/skills/README.md) with a one-sentence scent line and a link.
5. Add the skill to the catalog in [Root CLAUDE.md](./CLAUDE.md). The indexes and concept docs list skills without a running total, so there is no count to bump. If the skill belongs to a new category, add it to the category lists too.
6. Update the marketplace registry at [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) if the new skill ships in a different plugin's component set.

## Adding an agent

1. Create `han.core/agents/{name}.md` with frontmatter (`name`, `description`, `tools`, `model`) and the agent body. See [agent-domain-focus.md](./han.plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md) for how narrow and named the domain vocabulary should be.
2. Copy [the agent template](./docs/templates/agent-long-form-template.md) into `docs/agents/{name}.md` and fill it in. Every agent gets a long-form doc.
3. Add the agent to the [Agents Index](./docs/agents/README.md) under the right role group.

## Editing an existing long-form doc

The docs follow a strict template. Before changing a section's shape, check [`docs/templates/skill-long-form-template.md`](./docs/templates/skill-long-form-template.md) or [`docs/templates/agent-long-form-template.md`](./docs/templates/agent-long-form-template.md) so the change stays consistent across peers.

If you are adding a section that is not in the template but applies to several skills or agents, raise it as a template change first. Drift across peer docs is worse than a missing section.

## Writing voice

All han documentation follows the writing voice profile in [`docs/writing-voice.md`](./docs/writing-voice.md). The most load-bearing rules:

- No em-dashes anywhere. Replace with periods, colons, commas, or parentheses.
- Direct second person (*"you"*), mentor-tone, plainspoken. No flattery, no hype words.
- Avoid *"leverage," "utilize," "showcase," "robust" (as a vague positive), "actually," "just," "It's worth noting," "Importantly,"* and similar AI-slop tells.
- Open with context or history, not a thesis statement.

The full voice profile names the prohibited words, the preferred sentence rhythms, and the structural moves the docs use.

## Documentation conventions

- **One canonical source per concept.** The long-form doc is canonical. The Skills Index and Agents Index carry scent only. One sentence plus a link. The README never duplicates long-form content.
- **Every long-form doc links up.** The Related Documentation section's first bullet points back to [the plugin landing page](./README.md). A reader arriving cold via search must be able to get to the front door in one click.
- **Orientation frame on top.** The first two lines of every long-form doc state what the page is, who it is for, and where the internal definition (`SKILL.md` or agent `.md`) lives.
- **TL;DR before anything else.** Three lines: what / when / what-you-get-back. Scannable for readers doing reference lookup.
- **YAGNI applies to docs too.** Doc sections that fail the [YAGNI](./docs/yagni.md) evidence test (speculative usage notes, *for-future-flexibility* warnings, examples for behavior the skill doesn't have yet) are not added. The same evidence rule that gates plan steps and code recommendations gates documentation.

## Reviewing your own changes

Before opening the PR, run through this checklist:

- [ ] Frontmatter is valid (no XML, no reserved prefixes, description under 1024 characters).
- [ ] `allowed-tools` matches actual usage; Bash permissions are per-prefix, not wildcards.
- [ ] Context injection commands (`` !`command` ``) are simple; complex operations live in scripts.
- [ ] Long-form doc follows the template.
- [ ] The skill or agent appears in the right index, at the right group, with accurate scent.
- [ ] Internal links resolve.
- [ ] No em-dashes anywhere in the doc.
- [ ] No *"actually," "just," "leverage," "utilize," "showcase," "robust" (vague), "It's worth noting," "Importantly,"* or other voice violations.

## Related Documentation

- [Plugin landing page](./README.md). Where end-users start.
- [Root CLAUDE.md](./CLAUDE.md). Project map and doc index for assistants and contributors.
- [Writing voice](./docs/writing-voice.md). The voice profile every doc follows.
- [Skills Index](./docs/skills/README.md). All skills, grouped by purpose.
- [Agents Index](./docs/agents/README.md). All agents, grouped by role.
- [Concepts](./docs/concepts.md). Skill vs. agent mental model.
- [Sizing](./docs/sizing.md). How the swarming skills classify work and scale dispatch.
- [YAGNI](./docs/yagni.md). The evidence-based rule for what survives a review.
- [Evidence](./docs/evidence.md). The three principles, the trust-class vocabulary, and the corroboration gate every evidence-aware skill and agent applies.
- [`han.plugin-builder/skills/guidance/references/skill-building-guidance/`](./han.plugin-builder/skills/guidance/references/skill-building-guidance/). Skill-authoring guidance.
- [`han.plugin-builder/skills/guidance/references/agent-building-guidelines/`](./han.plugin-builder/skills/guidance/references/agent-building-guidelines/). Agent-authoring guidance.
