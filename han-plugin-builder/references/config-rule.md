# Project Config Rule (`.han/config.md`)

A consuming project may carry one optional file, `.han/config.md`, that adjusts how Han skills behave in that project.
Each participating skill reads the file through the inline probe in its `## Project Context` block; this rule defines
how every skill interprets what that probe returns, so one config file resolves identically across the whole suite.
Every vendored copy of this file is byte-identical to the canonical `han-core/references/config-rule.md`.

## Schema

The file is markdown: optional YAML frontmatter for scalar settings, then named sections for list settings.

- `output-directory` (frontmatter key): a base path, relative to the working directory, under which the skill writes
  its markdown deliverables while keeping its own folder and file structure beneath it. Create the directory on first
  write when it does not exist.
- `default-swarm-size` (frontmatter key): the default size band for skills that classify a swarm or team size before
  dispatching agents. Accepted values, trimmed of surrounding whitespace and matched case-insensitively: `small`,
  `medium`, `large`, `dynamic`. A value of `small`, `medium`, or `large` is adopted exactly as if the user had passed
  it as the skill's size argument: the skill skips its signal-based classification, scales its caps to the band, and
  announces the band with the config named as the source. Specialists are still selected by signal within the band's
  caps. `dynamic`, or an absent setting, leaves the skill classifying the size itself from the work's signals, with no
  mention of the config. Explicit user input outranks the setting per the precedence chain, and `dynamic` is also a
  valid explicit size input that forces signal-based classification for that run. An unrecognized size argument (a
  typo) supplies no explicit value, so the configured band still applies. A skill that dispatches no agent swarm
  ignores the setting silently.
- `writing-voice` (frontmatter key): a file path, relative to the working directory, naming the writing-voice profile
  the readability skills apply in place of the built-in profile at
  `han-communication/references/writing-voice.md`. An absent or blank setting keeps the built-in profile. When a value
  is present, verify the file exists before using it. When it exists, that file is the writing-voice profile for the
  run, including the vocabulary blocklist the readability rule points to. When it does not exist, do not degrade
  silently: warn the user that the configured writing-voice file was not found, and ask whether to use the built-in Han
  voice or skip the writing voice entirely for the run. Skipping means the run applies the readability rule with no
  voice profile and no vocabulary blocklist. A skill that produces no prose deliverable ignores the setting silently.
- `## Extra Agents` (section heading): one agent per list line, in qualified `plugin:agent` form or bare-name form.
  Match names case-insensitively against the agents available in the session.

## Precedence

Resolve each scalar setting through this fixed chain; the first source that supplies a value wins:

1. Explicit user input to the skill, including an explicit output path passed by a calling skill.
2. `.han/config.md`.
3. The CLAUDE.md `## Project Discovery` section.
4. The project-discovery file.
5. The skill's built-in defaults.

The extra-agents list adds rather than replaces: agents the user names explicitly are always considered, and the
config's entries join them as candidates.

## Working directory

Look for `.han/config.md` only in the directory where the skill is running, the same place the CLAUDE.md and
project-discovery probes look. A config elsewhere in the repository does not apply. When the probe returns nothing, no
config is present: behave exactly as the skill does without this rule, with no note.

## Output-directory containment

The `output-directory` value must be a relative path that stays inside the working directory. Refuse an absolute path,
a drive prefix, or any path whose normalized form escapes the working directory through `..` traversal. A refused
value falls back to the skill's default output location with the one-line note. This guards against accidents, not
adversaries.

## Extra agents joining the pool

A skill that selects among candidate agents adds the config's extra agents to its candidate pool. They compete under
the skill's own signal-based selection and size caps; a selected extra agent may take a slot a default specialist
would otherwise have filled, and that displacement happens without comment. An entry that duplicates an agent already
in the pool has no effect: the agent is one candidate, counted once against the caps. An entry that does not resolve
to a dispatchable agent is skipped with the one-line note naming it.

## Degradation and the one-line note

A bad config can never fail a skill run; the worst it can do is be ignored. Show a one-line note only when content
that attempts a recognized override cannot be used; pass over everything else silently. A `writing-voice` value naming
a file that does not exist is the one exception: per its definition above, it asks the user which fallback to take
instead of degrading with a note.

- Malformed frontmatter, or a file unreadable as text: ignore the unusable portion, resolve those settings from the
  rest of the precedence chain, and note what was ignored.
- A setting name the suite does not recognize: ignore it with a note; recognized settings in the same file still
  apply.
- A recognized setting with a blank or unusable value: ignore it with a note and fall through the precedence chain.
- A setting that does not apply to the running skill (it writes no markdown deliverable, or selects no agents): ignore
  it silently.
- A file holding only prose the suite has no use for: behave as if the file were absent, with no note.

The note is one line naming what was ignored and why, shown on each run where the problem is present. When everything
applies cleanly, say nothing about the config.
