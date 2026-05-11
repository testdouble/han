# Contributing to han

This page is for contributors — anyone adding, editing, or restructuring skills, agents, or documentation in the han plugin. If you just want to use the plugin, start with the [Plugin landing page](../README.md) or the [Quickstart](./quickstart.md).

> See also: [Plugin landing page — han](../README.md) · [Concepts](./concepts.md) · [Sizing](./sizing.md) · [YAGNI](./yagni.md)

## TL;DR

- Skills live in [`plugins/han/skills/{name}/SKILL.md`](../skills/). Agents live in [`plugins/han/agents/{name}.md`](../agents/).
- Long-form docs (for humans deciding *when* and *how* to use a skill or agent) live in `plugins/han/docs/skills/{name}.md` and `plugins/han/docs/agents/{name}.md`.
- Follow the [long-form template](./templates/skill-long-form-template.md) or [agent template](./templates/agent-long-form-template.md). Apply the [coverage rule](./templates/coverage-rule.md) to decide whether a long-form doc is needed.
- The root [CLAUDE.md](../../../CLAUDE.md) and [repo-wide docs](../../../docs/) carry the deeper construction guidance.

## Before you start

Read these once:

- **[`docs/plugin-entity-taxonomy.md`](../../../docs/plugin-entity-taxonomy.md)** — What a skill is, what an agent is, what a hook is, and which to reach for.
- **[`docs/skill-building-guidance/`](../../../docs/skill-building-guidance/)** — The skill-authoring rules: description frontmatter, progressive disclosure, context hygiene, dynamic project discovery, bash permissions, script execution.
- **[`docs/agent-building-guidelines/`](../../../docs/agent-building-guidelines/)** — The agent-authoring rules: external files, model selection, domain focus, graceful degradation, multi-agent economics.
- **[Root `CLAUDE.md`](../../../CLAUDE.md)** — Repo conventions for plugin layout, `marketplace.json` regeneration, and the build flow.

## Adding a skill

1. Scaffold: `./new-plugin.sh` creates directories, but for a skill under `plugins/han/skills/`, you can also just create the folder and `SKILL.md` by hand.
2. Write the `SKILL.md`:
   - Frontmatter with `name`, `description`, `allowed-tools`. See [skill-description-frontmatter.md](../../../docs/skill-building-guidance/skill-description-frontmatter.md).
   - Body: numbered steps, `${CLAUDE_SKILL_DIR}` paths for script references, extracted references under `references/`.
3. Apply the [coverage rule](./templates/coverage-rule.md). If the skill qualifies for a long-form doc, copy [the skill template](./templates/skill-long-form-template.md) into `docs/skills/{name}.md` and fill it in.
4. Add the skill to the [Skills Index](./skills/README.md) with a one-sentence scent line and a link.
5. Rebuild the marketplace registry: `scripts/build.sh marketplace`.

## Adding an agent

1. Create `plugins/han/agents/{name}.md` with frontmatter (`name`, `description`, `tools`, `model`) and the agent body. See [agent-domain-focus.md](../../../docs/agent-building-guidelines/agent-domain-focus.md) for how narrow and named the domain vocabulary should be.
2. Apply the [coverage rule](./templates/coverage-rule.md). If the agent qualifies, copy [the agent template](./templates/agent-long-form-template.md) into `docs/agents/{name}.md`.
3. Add the agent to the [Agents Index](./agents/README.md) under the right role group.
4. Rebuild: `scripts/build.sh marketplace`.

## Editing an existing long-form doc

The docs follow a strict template. Before changing a section's shape, check [`docs/templates/skill-long-form-template.md`](./templates/skill-long-form-template.md) or [`docs/templates/agent-long-form-template.md`](./templates/agent-long-form-template.md) so the change stays consistent across peers.

If you are adding a section that is not in the template but applies to several skills or agents, raise it as a template change first — drift across peer docs is worse than a missing section.

## Documentation conventions

- **One canonical source per concept.** The long-form doc is canonical. The Skills Index and Agents Index carry scent only — one sentence plus a link. The README never duplicates long-form content.
- **Every long-form doc links up.** The Related Documentation section's first bullet points back to [the plugin landing page](../README.md). A reader arriving cold via search must be able to get to the front door in one click.
- **Orientation frame on top.** The first two lines of every long-form doc state what the page is, who it is for, and where the internal definition (`SKILL.md` or agent `.md`) lives.
- **TL;DR before anything else.** Three lines: what / when / what-you-get-back. Scannable for readers doing reference lookup.
- **YAGNI applies to docs too.** Doc sections that fail the [YAGNI](./yagni.md) evidence test (speculative usage notes, *for-future-flexibility* warnings, examples for behavior the skill doesn't actually have yet) are not added. The same evidence rule that gates plan steps and code recommendations gates documentation.

See the [IA analysis](./ia-analysis.md) for the rationale behind these conventions.

## Reviewing your own changes

Before opening the PR, run through this checklist:

- [ ] Frontmatter is valid (no XML, no reserved prefixes, description under 1024 characters).
- [ ] `allowed-tools` matches actual usage; Bash permissions are per-prefix, not wildcards.
- [ ] Context injection commands (`` !`command` ``) are simple; complex operations live in scripts.
- [ ] Long-form doc (if added) follows the template.
- [ ] The skill or agent appears in the right index, at the right group, with accurate scent.
- [ ] `scripts/build.sh marketplace` regenerates `marketplace.json` cleanly.
- [ ] Internal links resolve.

## Related Documentation

- [Plugin landing page — han](../README.md) — Where end-users start.
- [Skills Index](./skills/README.md) — All skills, grouped by purpose.
- [Agents Index](./agents/README.md) — All agents, grouped by role.
- [Concepts](./concepts.md) — Skill vs. agent mental model.
- [Sizing](./sizing.md) — How the swarming skills classify work and scale dispatch.
- [YAGNI](./yagni.md) — The evidence-based rule for what survives a review.
- [IA Analysis](./ia-analysis.md) — The information architecture findings that shaped the current doc structure.
- [Root CLAUDE.md](../../../CLAUDE.md) — Repo-wide conventions and build commands.
- [`docs/skill-building-guidance/`](../../../docs/skill-building-guidance/) — Skill-authoring guidance.
- [`docs/agent-building-guidelines/`](../../../docs/agent-building-guidelines/) — Agent-authoring guidance.
