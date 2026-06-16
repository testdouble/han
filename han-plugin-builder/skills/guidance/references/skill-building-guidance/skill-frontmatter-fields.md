---
paths:
  - "**/skills/**/*.md"
---

# Skill Frontmatter Fields

This is the inventory of SKILL.md frontmatter fields Claude Code supports, with one-line semantics for each. A typical skill uses only a handful of them (`name`, `description`, `allowed-tools`, `paths`, occasionally `argument-hint`), but the platform supports more. Use this as the reference for what is available; the dedicated docs cover the high-traffic fields in depth.

The authoritative source is the Claude Code [Skills documentation](https://code.claude.com/docs/en/skills). When this doc and that page disagree, the official page wins; re-verify before relying on a field's exact behavior.

## Identity and triggering

| Field | Required | What it does |
|---|---|---|
| `name` | Recommended | Display label in skill listings. In Claude Code the slash command comes from the skill's directory name, not this field. The one exception is a plugin-root `SKILL.md`, where `name` sets the command. The open standard requires `name` to match the parent directory: lowercase letters, numbers, and hyphens, max 64 characters, no consecutive or leading/trailing hyphens, no reserved words (`claude`, `anthropic`). |
| `description` | Recommended | The primary trigger signal. Always loaded; Claude reads it to decide when to invoke the skill. Max 1,024 characters (open-standard hard cap); Claude Code truncates the combined `description` + `when_to_use` at 1,536 characters in the skill listing. See [Skill Description Frontmatter](./skill-description-frontmatter.md) and [Skill Description Length](./skill-description-length.md). |
| `when_to_use` | No | Extra trigger context appended to `description`. Counts toward the 1,536-character combined listing cap. |
| `argument-hint` | No | Autocomplete hint shown after the slash command, e.g. `[issue-number]`. |
| `arguments` | No | Named positional arguments for `$name` substitution in the skill body. |
| `paths` | No | Glob patterns that scope when the skill auto-activates. Use this on guidance and skill docs to bind them to the directories they govern. |

## Tool permissions

| Field | Required | What it does |
|---|---|---|
| `allowed-tools` | No | Grants tool permissions while the skill is active. Does not restrict the available tool set, it pre-approves use. See [Allowed Tools: Bash Permissions](./allowed-tools-bash-permissions.md) and [Allowed Tools: AskUserQuestion](./allowed-tools-AskUserQuestion.md). |
| `disallowed-tools` | No | Removes tools from the available pool while the skill is active. |

## Invocation control

| Field | Required | What it does |
|---|---|---|
| `disable-model-invocation` | No | `true` stops Claude from auto-loading the skill (and from preloading it into subagents). Default `false`. |
| `user-invocable` | No | `false` hides the skill from the `/` menu. Default `true`. |

## Execution and model

| Field | Required | What it does |
|---|---|---|
| `model` | No | Overrides the model for this skill's turn only; not saved to session settings. |
| `effort` | No | `low`, `medium`, `high`, `xhigh`, or `max`. Overrides the session's effort level for this skill. |
| `context` | No | Set to `fork` to run the skill in an isolated subagent context. See the caveat in [Skill Composition](./skill-composition.md) about forked data-fetch sub-skills. |
| `agent` | No | When `context: fork` is set, names which subagent type runs the skill (`Explore`, `Plan`, `general-purpose`, or a custom subagent). |
| `hooks` | No | Lifecycle hooks scoped to this skill's run. |
| `shell` | No | `bash` (default) or `powershell` for inline command blocks. |

## Portability (open-standard fields)

These come from the cross-tool [Agent Skills specification](https://agentskills.io/specification) and travel to other tools that implement the standard. Claude Code accepts them.

| Field | Required | What it does |
|---|---|---|
| `license` | No | License name or a reference to a bundled license file. |
| `compatibility` | No | Environment requirements; max 500 characters. |
| `metadata` | No | Arbitrary key-value map for additional properties. Must use standard YAML types only (see [Security Restrictions](./security-restrictions.md)). |

## Notes that bite

- **The directory name is the command, not `name`.** A skill at `skills/deploy-staging/SKILL.md` produces `/deploy-staging` regardless of the `name` field. Plugin skills are namespaced, e.g. `example-plugin:code-review`.
- **No XML angle brackets in any frontmatter field.** Frontmatter is injected into the system prompt where `<` and `>` have special meaning. See [Security Restrictions](./security-restrictions.md).
- **`allowed-tools` is marked experimental at the open-standard level** because cross-tool support varies. In Claude Code it is a stable, fully-supported field.

## Summary Checklist

1. `name` matches the directory name; lowercase, hyphens, max 64 chars, no reserved words.
2. `description` is present and under 1,024 characters.
3. Tool fields (`allowed-tools`, `disallowed-tools`) follow the Bash-permission granularity rules.
4. Any invocation-control field (`disable-model-invocation`, `user-invocable`) is set deliberately, not by accident.
5. No XML angle brackets in any frontmatter value.

Cross-references:
- [Skill Description Frontmatter](./skill-description-frontmatter.md) — Writing the `description` field for trigger accuracy.
- [Skill Description Length](./skill-description-length.md) — The two character caps and what to cut first.
- [Allowed Tools: Bash Permissions](./allowed-tools-bash-permissions.md) — Correct `Bash()` permission syntax.
- [Security Restrictions](./security-restrictions.md) — Frontmatter rules that prevent injection and upload failures.
- [Progressive Disclosure](./progressive-disclosure.md) — How frontmatter, body, and references load at different times.
