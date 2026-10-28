# /load-han-config

Operator documentation for the `/load-han-config` skill in the han plugin. This document helps you decide _when_ and
_how_ the skill is used. For what the skill does internally, read the skill definition at
[`han-core/skills/load-han-config/SKILL.md`](../../skills/load-han-config/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [Configuration](../../../docs/configuration.md)

## TL;DR

- **What it does.** Brings this run's Han configuration, the personal and the project `.han/config.md`, into the
  calling skill's own context once per run, so the caller applies it per the shared config rule.
- **When it runs.** Every Han skill's `## Project Context` block carries one line that invokes it. You rarely run it
  directly; the skill you asked for calls it for you, and a skill that another skill invokes skips the call when the
  configuration is already in context.
- **What you get back.** Nothing of its own. It hands control straight back to the caller, which resumes its own
  workflow with both configuration files now in context.

## Key concepts

- **One place reads the configuration.** Before this skill existed, all 45 skills carried the same two probe lines and
  the same 65-word instruction, and a chain of skills loaded the configuration once per skill. Now one skill carries the
  probes and the instruction, and a chain loads once.
- **It surfaces raw content, not resolved settings.** The skill is one load-time probe that runs a script. The script
  prints both files as they are, where each was found, and the config rule that says how to apply them. The calling
  skill still applies the precedence chain, the path resolution, and the degradation rules in
  [`config-rule.md`](../../references/config-rule.md), because which settings apply and when a note is due depend on
  the caller. When neither file exists, the script says so and names the two paths it tried.
- **It is inline, not forked.** The skill runs in the caller's context so what it surfaces stays available to the
  caller. It never sets `context: fork`.
- **Latest copy wins.** When a run ends up loading twice, the newer copy governs. Nothing breaks, and a stale copy is
  never preferred.

## When it is used

**Invoked when:**

- A Han skill starts and its `## Project Context` block says to resolve configuration with
  `han-core:load-han-config`. The skill checks its own context first: when the loader's `# Load Han Configuration`
  heading and the two configuration values are already there, because an earlier skill in the same run loaded them,
  it does not invoke the loader again.
- You run it yourself to see which of the two configuration files this run would apply. With no caller it reports
  which files were found and stops.

**Not used for:**

- **Writing or editing `.han/config.md`.** You author both files by hand; the annotated example in
  [Configuration](../../../docs/configuration.md) is the source to copy from.
- **Discovering the project's languages and tooling.** Use [`/project-discovery`](./project-discovery.md), which writes
  a reference section into AGENTS.md or CLAUDE.md.

## How it works

The skill has no steps. Its one load-time probe runs `scripts/load-han-config.sh`, which resolves the personal
configuration directory (`CLAUDE_CONFIG_DIR`, or `~/.claude`), looks for `.han/config.md` there and in the working
directory, and prints whichever exist, the project file first, each under its own heading and between `BEGIN` and `END` marker
lines, followed by the config rule under a heading of its own, so a heading inside a configuration file is never read
as part of the skill. When the run is inside the
personal configuration directory the two lookups name one file, and it is printed once as the project file. The output
states that these files replace any copy loaded earlier, and that the caller should apply them per the rule and
continue. The probe is guarded, so a script that cannot run degrades to a one-line message rather than aborting the
caller.

A run begins when you invoke a skill and ends when that skill finishes; every skill it invokes is part of the same
run. A skill you invoke later in the same session is a new run and should load again, so an edit you make to a
configuration file between two commands should reach the second one. The trial ran every skill in a fresh context, so
this in-session case is the one path it did not measure; if a later command keeps old values, run it again in a new
session and report it.

## Cost and latency

The skill surfaces the two configuration files and its own short body into context, once per run. A chain of skills
pays that cost once instead of once per skill; a skill invoked on its own pays the same as it did before.

## Troubleshooting

- **A skill ran with no configuration although the file exists.** Check that `han-core` is installed: every Han
  plugin depends on it, so a normal install carries it, but a plugin installed through Codex, which resolves no
  dependencies, needs `han-core` installed beside it.
- **A chained skill reloaded the configuration.** This is harmless, because the latest copy governs. It happens when
  the earlier copy fell out of context, for example after a compaction.
- **A consumer skill stops right after the loader call.** The trial behind this skill ran the values case through
  same-context skill composition, including a worst-case loader that ends on a final-sounding line, with no early
  exits, first through a copy and then through the shipped skill; the records are under
  `docs/plans/gh-203-consolidate-config-loading/artifacts/trial/` and `artifacts/trial2/` in that folder. The one
  trigger they could not induce is a real `api_retry`, a transient infrastructure fault. If you observe a skill ending right after sourcing
  the configuration, re-run it; if it recurs, report it.

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs tree.
- [Configuration](../../../docs/configuration.md). The operator guide to both `.han/config.md` files and the annotated
  example to author from.
- [`config-rule.md`](../../references/config-rule.md). The interpretation contract every calling skill applies to what
  this skill surfaces.
- [`/project-discovery`](./project-discovery.md). The sibling skill that writes machine-discovered project context for
  other skills to consume.
- [`SKILL.md` for /load-han-config](../../skills/load-han-config/SKILL.md). The internal process definition.
