---
paths:
  - "**/skills/**/*.md"
---

# Skill Composition

Skills should not call other skills via the Skill tool. Sub-skill calls have
proven too inconsistent and unreliable to use in practice.

## The Rules

### Rule: Do not use sub-skill calls

Sub-skill composition (both data-fetch and orchestration patterns) has
exhibited persistent issues that make it unreliable:

- **Data-fetch sub-skills** using `context: fork` cause the calling skill to
  exit early. The forked sub-skill's output anchors the model after an
  `api_retry` event, bypassing all subsequent workflow steps. This failure mode
  has been observed consistently across multiple skills that called a shared
  config-reading sub-skill.
- **Orchestration sub-skills** also suffer from inconsistent behavior, with
  the calling skill losing track of its own workflow after the sub-skill
  returns.

These issues stem from fundamental limitations in how sub-skill context is
handled, not from how individual skills are written. No amount of instruction
tuning or `context: fork` configuration has reliably resolved them.

`context: fork` is a documented Claude Code feature (see the [Skills
documentation](https://code.claude.com/docs/en/skills) and the field inventory
in [Skill Frontmatter Fields](./skill-frontmatter-fields.md)); the guidance here
is not that the feature is unsupported, but that you should avoid it for
data-fetch sub-skills because the early-exit failure mode above shows up
repeatedly in practice. Treat this as a considered choice, not an oversight.

### Rule: Prefer inline discovery

Instead of calling a sub-skill, skills should handle discovery and data
retrieval inline:

1. Use context injection to detect config files (CLAUDE.md, project-discovery.md)
2. Read the file directly and extract needed values in the skill's own step logic
3. Fall back to conventional defaults when values are not found

### Rule: Keep skills self-contained

Each skill should contain all the logic it needs to complete its task. If a
skill needs data that another skill knows how to find, duplicate the discovery
logic rather than calling the other skill. A small amount of duplication is
far more reliable than sub-skill composition.

Cross-references:
- [Skill Decomposition](./skill-decomposition.md). When to split skills.
- [Writing Effective Instructions](./writing-effective-instructions.md). Instruction clarity.
