# Contributing to han

This page is for contributors: anyone adding, editing, or restructuring skills, agents, or documentation in the han plugin. If you just want to use the plugin, start with the [Plugin landing page](./README.md) or the [Quickstart](./docs/quickstart.md).

> See also: [Plugin landing page](./README.md) · [Concepts](./docs/concepts.md) · [Sizing](./docs/sizing.md) · [YAGNI](./docs/yagni.md)

## TL;DR

- Skills live in [`plugin/skills/{name}/SKILL.md`](./plugin/skills/). Agents live in [`plugin/agents/{name}.md`](./plugin/agents/).
- Long-form docs (for humans deciding *when* and *how* to use a skill or agent) live in `docs/skills/{name}.md` and `docs/agents/{name}.md`.
- **Every skill and every agent gets a long-form doc.** No exceptions. See the [coverage rule](./docs/templates/coverage-rule.md).
- Use the [long-form skill template](./docs/templates/skill-long-form-template.md) or the [agent template](./docs/templates/agent-long-form-template.md).
- The root [CLAUDE.md](./CLAUDE.md) carries the at-a-glance project map for assistants and contributors.

## Before you start

Read these once:

- **[`docs/guidance/plugin-entity-taxonomy.md`](./docs/guidance/plugin-entity-taxonomy.md).** What a skill is, what an agent is, what a hook is, and which to reach for.
- **[`docs/guidance/skill-building-guidance/`](./docs/guidance/skill-building-guidance/).** The skill-authoring rules: description frontmatter, progressive disclosure, context hygiene, dynamic project discovery, bash permissions, script execution.
- **[`docs/guidance/agent-building-guidelines/`](./docs/guidance/agent-building-guidelines/).** The agent-authoring rules: external files, model selection, domain focus, graceful degradation, multi-agent economics.
- **[Root `CLAUDE.md`](./CLAUDE.md).** Repo conventions, doc map, and where each kind of file lives.

## Adding a skill

1. Scaffold the folder under `plugin/skills/{name}/` and add a `SKILL.md`.
2. Write the `SKILL.md`:
   - Frontmatter with `name`, `description`, `allowed-tools`. See [skill-description-frontmatter.md](./docs/guidance/skill-building-guidance/skill-description-frontmatter.md).
   - Body: numbered steps, `${CLAUDE_SKILL_DIR}` paths for script references, extracted references under `references/`.
3. Copy [the skill template](./docs/templates/skill-long-form-template.md) into `docs/skills/{name}.md` and fill it in. Every skill gets a long-form doc.
4. Add the skill to the [Skills Index](./docs/skills/README.md) with a one-sentence scent line and a link.
5. Update the skill counts and catalog so they stay accurate: the skill catalog and "Counts to verify when editing indexes" line in [Root CLAUDE.md](./CLAUDE.md), the count in [Concepts](./docs/concepts.md) ("What does the plugin include?"), and the counts in the [README](./README.md). If the skill belongs to a new category, add it to the category lists too.
6. Update the marketplace registry at [`.claude-plugin/marketplace.json`](./.claude-plugin/marketplace.json) if needed.

## Adding an agent

1. Create `plugin/agents/{name}.md` with frontmatter (`name`, `description`, `tools`, `model`) and the agent body. See [agent-domain-focus.md](./docs/guidance/agent-building-guidelines/agent-domain-focus.md) for how narrow and named the domain vocabulary should be.
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
- [`docs/guidance/skill-building-guidance/`](./docs/guidance/skill-building-guidance/). Skill-authoring guidance.
- [`docs/guidance/agent-building-guidelines/`](./docs/guidance/agent-building-guidelines/). Agent-authoring guidance.
