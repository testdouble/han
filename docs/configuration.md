# Configuration

Han reads two optional configuration files, and you can use either one or both. A personal `.han/config.md` in your
Claude Code configuration directory carries settings that follow you into every project. A project's own
`.han/config.md` adjusts those settings for that project. Both control where skills write their markdown deliverables,
which extra agents dispatching skills consider, the default swarm size the sizing-aware skills start at, the
writing-voice profile the readability skills apply, and the review types and attached agents `/code-review` adds to
what Han ships. Every Han skill reads both files on every run, so the overrides take
effect without depending on the model remembering to look. Someone with neither file sees no change of any kind.

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [Quickstart](./quickstart.md) ·
> [All skills](./skills/README.md) · [All agents](./agents/README.md)

## TL;DR

- **You write the files; Han cannot.** Han cannot ship or seed either config from the plugin side. You create them by
  hand, and the project one travels through version control like any other file. The annotated example below is the
  canonical source to author from, and both files use it.
- **The personal file is for you; the project file is for the project.** Write a setting once in your personal file and
  every project picks it up. A project that needs something different says so in its own file, and it wins for the
  settings it names and only those.
- **These overrides ship.** `output-directory` sets one base directory for every skill's markdown deliverables.
  `default-swarm-size` sets the size band every sizing-aware skill starts at. `writing-voice` points the readability
  skills at a writing-voice profile of your own in place of the built-in Han voice. `## Extra Agents` names
  project-defined or third-party agents that Han's dispatching skills consider alongside their built-in rosters.
  `## Code Review Types` declares review types of your own for `/code-review`, and `## Code Review Type Agents` attaches
  your own agents to any review type.
- **A bad config almost never fails a skill run.** Apart from the two cases under
  [When something is wrong](#when-something-is-wrong), the worst it can do is be ignored, with a one-line note naming what was
  ignored and which file it came from. A missing or empty file changes nothing and says nothing.
- **The interpretation contract lives in
  [`han-core/references/config-rule.md`](../han-core/references/config-rule.md).** Every skill applies that one rule
  file (vendored byte-identical into each plugin), so one pair of files resolves identically across the whole suite.
  This page is the operator-facing guide.

## Where each file goes

- **Personal:** `.han/config.md` inside your Claude Code configuration directory. That is `~/.claude` unless you have
  set `CLAUDE_CONFIG_DIR`, in which case it is wherever that points. If you have moved your configuration directory, a
  file left behind in `~/.claude/.han/` does not apply.
- **Project:** `.han/config.md` in the directory you run Han skills from.

Neither lookup walks up the directory tree. In a monorepo, each package can carry its own config; running a skill from a
directory without one behaves as if the project file were absent, even when another directory in the repo has one. Your
personal file still applies in all of them.

## The file, annotated

Every setting is optional, everything unrecognized is ignored, and both files take the same shape.

```markdown
---
# Base directory for Han's markdown deliverables. Each skill keeps its own
# folder and file structure beneath it, and creates the directory on first
# write. A relative path is read from the folder holding this file, so the
# same line means "inside this project" in a project config and "inside my
# Claude Code configuration directory" in a personal one. Full paths and a
# leading ~ are accepted, including paths outside the project.
output-directory: docs/han

# Default size band for the skills that dispatch an agent swarm:
# small | medium | large | dynamic. A band is adopted exactly as if you passed
# it as the skill's size argument, on every sizing-aware run, so it scales
# agent cost across all of them together. "dynamic" (or omitting the line)
# lets each skill classify the size itself. Passing a size on an invocation,
# including "dynamic" to auto-classify one run, always wins over this default.
default-swarm-size: dynamic

# Writing-voice profile for the readability skills, as a file path. When set
# and the file exists, it replaces the built-in Han voice (han-communication's
# writing-voice.md) for the run. When set and the file is missing, the skill
# warns you, names which config declared it, and asks whether to use the
# built-in voice or skip the writing voice entirely. Omit the line to keep the
# built-in voice. Keeping this profile beside your personal config is what
# makes one relative path work in every project.
writing-voice: docs/our-writing-voice.md
---

## Extra Agents

One agent per line. Qualified `plugin:agent` form or bare name, matched
case-insensitively against the agents available in the session.

- my-plugin:payments-domain-expert
- accessibility-reviewer

## Code Review Types

One review type per line: a token, then the path to its type file. A relative path is
read from the folder holding this file, as writing-voice is. /code-review reads the
file only when you invoke its token, as in `/code-review pii-check`.

- pii-check: .han/review-types/pii-check.md
- hipaa-compliance: ~/review-types/hipaa-compliance.md

## Code Review Type Agents

One review type per line: a token, shipped or declared above, then one or more agents.
They run on every /code-review run of that type.

- testing: acme:mutation-tester
- pii-check: acme:pii-scanner
```

## What each override does

### `output-directory`

Skills that write markdown deliverables (plans, reports, documentation) write them under this base directory instead of
their default locations, keeping their own folder structure beneath it. A skill that writes nothing ignores the setting
silently. The directory is created on first write.

The value may point anywhere, including outside the project. Han used to refuse an absolute path or one escaping upward
through `..`; that guard is gone. If you set this to a path outside your repository, deliverables land there and are not
committed with your code, and nothing warns you on each run. That is the trade for being able to keep Han's output out
of the repo on purpose.

### `default-swarm-size`

The seven sizing-aware skills ([`/architectural-analysis`](../han-coding/docs/skills/architectural-analysis.md),
[`/code-overview`](../han-coding/docs/skills/code-overview.md),
[`/gap-analysis`](../han-research/docs/skills/gap-analysis.md),
[`/iterative-plan-review`](../han-planning/docs/skills/iterative-plan-review.md),
[`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md),
[`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md), and
[`/research`](../han-research/docs/skills/research.md)) start at this band instead of classifying the size themselves.
A configured `small`, `medium`, or `large` is forced exactly like an explicit size argument: the skill skips its
signal-based classification, scales its caps to the band, and announces the band naming which file supplied it.
Specialists are still selected by signal within the band's caps. `dynamic`, or omitting the setting, keeps today's
auto-classification. Values are trimmed and matched case-insensitively; anything else degrades with a one-line note and
the skill classifies the size itself.

One configured band applies to all seven skills at once, and their bands scope differently (a `large` feature plan and
a `large` research swarm cost different work), so a global `large` raises agent cost on every sizing-aware run. Setting it
personally raises that cost in every project you touch, so it is the setting most worth leaving at `dynamic` until you
want otherwise. The per-run correction never needs a file edit: passing a size on the invocation always wins, and
passing `dynamic` auto-classifies that run. See [Sizing](./sizing.md) for the bands and per-skill caps.

### `writing-voice`

The readability surfaces in `han-communication` ([`/readability-guidance`](../han-communication/docs/skills/readability-guidance.md),
[`/edit-for-readability`](../han-communication/docs/skills/edit-for-readability.md), and the
[`readability-editor`](../han-communication/docs/agents/readability-editor.md) agent they feed) read their
writing-voice profile from this setting. The value is a file path naming a writing-voice profile of your own. When the
file exists, it replaces the built-in profile at
[`han-communication/references/writing-voice.md`](../han-communication/references/writing-voice.md) wholesale,
including the vocabulary blocklist the readability rule enforces, so every prose-producing Han skill drafts in your
voice instead of Han's.

This is the setting the personal file was made for. Keep the profile beside your personal config, name it with a
relative path, and it applies in every project without a copy in any of them.

When the setting names a file that does not exist, the skill does not degrade silently: it warns you that the file was
not found, names which config declared it, and asks whether to use the built-in Han voice or skip the writing voice
entirely for that run. Skipping applies the readability rule with no voice profile and no vocabulary blocklist. Omitting
the setting keeps the built-in Han voice with no mention of the config.

### `## Extra Agents`

Skills that select among candidate agents (for example [`/code-review`](../han-coding/docs/skills/code-review.md),
[`/research`](../han-research/docs/skills/research.md), or
[`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md)) add these agents to their candidate pool.
Both files' lists are considered together rather than one replacing the other. The extras compete under the same
signal-based selection and the same size caps as the skill's own roster: a selected extra agent can take a slot a
default specialist would otherwise have filled, and that displacement is intended. An entry that duplicates an agent
already in the pool has no effect, whether the duplicate came from the same file or the other one. An entry that does
not resolve to a dispatchable agent (a misspelling, a skill name) is skipped with a one-line note. The override selects
among agents that already exist in the session; it does not define new agents.

`/code-review` considers this list on its default run only, the run with no review type named. A typed run such as
`/code-review testing` stays on its one concern and ignores the list without comment. To add an agent to a typed review,
attach it under `## Code Review Type Agents` instead.

### `## Code Review Types`

Declares review types Han does not ship, for [`/code-review`](../han-coding/docs/skills/code-review.md) to run by name.
A financial institution might add `pii-check`, or a healthcare company `hipaa-compliance`. Every other skill ignores the
section.

Each line names a token and a type file. The token is lowercase letters, digits, and hyphens, starting with a letter. A
shipped type (`security`, `testing`, `architecture`, `data`, `observability`, `resilience`, `release`,
`maintainability`, `docs`, `ux`, `work-ticket`), a retired size
word (`small`, `medium`, `large`, `dynamic`), or `default` is reserved: its line is ignored with a one-line note naming
the file. The path resolves exactly as `writing-voice` does. When both files declare the same token, the project file's
line wins; different tokens from the two files add together.

The type file has the same shape as the types Han ships: a `# Review type: {token}` title and six sections in this
order. A section with nothing to say holds `none`, except `## Severity`, which holds `default`.

| Section                   | What it holds                                                                                                                       |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `## Purpose`              | One sentence, shown when the review starts and in the report's header.                                                              |
| `## Roster`               | `- Always:` agents that always run, and `- When relevant:` agents that run when their signal fires, or `none`.                      |
| `## Checklist categories` | Manual-checklist categories, named exactly as `/code-review`'s checklist bolds them, or `none`.                                     |
| `## Severity`             | `default`, or text that replaces the default severity rule: which severities are reported, and which way an uncertain finding goes. |
| `## Instructions`         | `none`, or one blockquote added to every agent's prompt and applied to the manual pass.                                             |
| `## Report section`       | `none`, or one fenced section layout followed by the rules for filling it.                                                          |

For example, `.han/review-types/pii-check.md`:

```markdown
# Review type: pii-check

## Purpose

Whether the change stores, logs, or sends personal data without the handling our policy requires.

## Roster

- Always: acme:pii-scanner, han-core:adversarial-security-analyst
- When relevant: han-core:data-engineer

## Checklist categories

Data Isolation, Error Handling

## Severity

Critical and Warning findings escalate, and a Suggestion is raised for any personal-data handling the change touches.
When uncertain between two severities, prefer the higher one.

## Instructions

> This is a PII review under the team's data-handling policy. Treat names, emails, account numbers, and government
> identifiers as personal data. Report only findings that touch personal data.

## Report section

none
```

The roster may name any agent in your session. An agent Han's roster already knows keeps its usual signal under
`When relevant`; an agent Han has no roster entry for runs whenever the type runs. A configured type never joins the
default run, and [`/post-code-review-to-pr`](../han-github/docs/skills/post-code-review-to-pr.md) passes its token
through like any shipped one. Its `## Instructions` reach every agent's prompt, so treat the file with the same care as
the config itself.

The file is read only when you invoke its token. When the project file's line points at a missing or incomplete file
and your personal file declares the same token, the personal line is used. When no usable line remains, the review stops
before it starts and says which file declared the token, at which path, and what was wrong.

### `## Code Review Type Agents`

Attaches your own agents to any review type, shipped or declared under `## Code Review Types`. Each line names a token
and one or more comma-separated agents, matched as `## Extra Agents` entries are. Both files' lines add together, and an
agent named twice for one type runs once.

On a run of that type, every attached agent runs, with no signal check: you named it for that type. On the default run,
agents attached to a default-set type (`security`, `testing`, `architecture`, `data`, `observability`, `resilience`,
`release`, `maintainability`) join
under the `## Extra Agents` signal rule, so the default run still dispatches only what the change calls for. A line is
read only when its token runs, so a personal file can attach agents to a type only some of your projects declare,
without a note in the others.

## How the two files combine

Each single-value setting resolves through a fixed chain; the first source that supplies a usable value wins:

1. Explicit input, which is what you tell the skill directly, or an explicit path a wrapper skill passes.
2. The project `.han/config.md`.
3. Your personal `.han/config.md`.
4. The CLAUDE.md `## Project Discovery` section.
5. The project-discovery file.
6. The skill's built-in defaults.

Both config files beat CLAUDE.md, silently.

Resolution happens per setting, not per file. A project file that names one setting leaves your other personal settings
in place, which is what makes it an adjustment rather than a replacement. A setting the project file leaves blank counts
as no value, so it falls through to your personal value rather than to the skill's default.

The extra-agents list adds rather than replaces: agents you name explicitly are always considered, and both files'
entries join them as candidates.

A keyed list resolves per key. When both files declare the same `## Code Review Types` token, the project file's line
wins, and an unusable project line falls through to your personal line for that token. `## Code Review Type Agents`
lines add together across both files.

## When something is wrong

A configuration problem degrades to defaults; apart from the two cases below, it never blocks or fails the run. You hear
about a problem under one rule:
a one-line note appears only when content that attempts a recognized override cannot be used, such as malformed
frontmatter, an unrecognized setting name, a blank value, or an unresolvable agent name. Every such note names which of
the two files held the problem, because they share a name and you would otherwise open both. Two separate problems, one
in each file, produce two notes. Content the suite has no use for (plain prose in the file) is passed over silently, and
when everything applies cleanly the skills say nothing about the config at all.

Two cases are exceptions to the note-and-move-on rule. `writing-voice` naming a missing file asks you whether to use the
built-in Han voice or skip the writing voice, because the wrong fallback would silently change the voice of everything a
run writes. A review type you invoke by name, whose configured file is missing or incomplete, stops that code review
before it starts, because no fallback would still be the review you asked for. The fix is an edit to the file, and a
rerun is the retry.

A personal configuration directory a run cannot reach is treated as no personal config, with no note. A run cannot tell
that apart from someone who never wrote the file.

There is one way the personal file can go quiet while still sitting where you put it. Skills locate your configuration
directory by running a small script that ships inside each plugin. If that script is missing or fails, the lookup falls
back to `~/.claude`, so a personal file at a directory named by `CLAUDE_CONFIG_DIR` stops applying until the script is
restored. Nothing announces this, because the fallback looks the same as never having set the variable. Reinstalling the
plugin restores the script.

## Which version you need

The personal file needs every installed Han plugin at or above the release that introduced it. The suite ships as
independently versioned plugins, so upgrading some and not others gives you settings that apply in some skills and not
others, with no way to tell which. Upgrade the whole suite together.

## Keeping the project file visible

Because the config silently outranks CLAUDE.md, [`/project-discovery`](../han-core/docs/skills/project-discovery.md)
keeps the project file visible: when `.han/config.md` exists it offers to add a one-line pointer to it in your CLAUDE.md,
and when the file is gone but a pointer remains it offers to remove the stale line. Both only with your consent. The
pointer covers the project file only; your personal config is yours and is not advertised in a project's CLAUDE.md.

Keep both files small. Their whole content is read on every skill run, so everything in them costs context on every run.

## Related reading

- [`han-core/references/config-rule.md`](../han-core/references/config-rule.md). The canonical interpretation contract
  every skill applies.
- [Concepts](./concepts.md). How skills, agents, sizing, and the other cross-suite mechanics fit together.
- [Quickstart](./quickstart.md). Which skill to start with, including project setup in Path D.
- [`/project-discovery`](../han-core/docs/skills/project-discovery.md). The skill that keeps the CLAUDE.md pointer to
  the project config honest.
