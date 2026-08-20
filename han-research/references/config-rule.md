# Config Rule (`.han/config.md`)

## Contents

- The two files, the two probes, and the personal read
- Schema
- How a configured path resolves
- Precedence
- Extra agents joining the pool
- Degradation and the one-line note

Han reads two optional configuration files, and either one may be absent. A person may carry a personal
`.han/config.md` inside their Claude Code configuration directory, and a consuming project may carry its own
`.han/config.md`. The personal file supplies defaults that follow the person into every project; the project file
adjusts them for that project. Each participating skill finds both through its `## Project Context` block; this rule
defines how every skill interprets what that block yields, so one pair of files resolves identically across the whole
suite. Every vendored copy of this file is byte-identical to the canonical `han-core/references/config-rule.md`.

## The two files, the two probes, and the personal read

The `## Project Context` block carries two probe lines and directs one Read-tool call. This rule refers to each by the
label it injects under, or by the file it reads.

- `personal config directory` (probe): the Claude Code configuration directory, resolved for this run. Named by the
  `CLAUDE_CONFIG_DIR` environment variable when that variable is set, and `~/.claude` when it is not. This value is not
  a setting. It is the folder a relative path in the personal file resolves against.
- The personal `.han/config.md` (Read tool): the content of `.han/config.md` inside that directory, or nothing. The
  skill reads this file itself as its first action rather than through a probe. A probe runs at skill load, where it
  cannot prompt and cannot degrade, so a permission decision against it aborts the skill instead of falling back to
  defaults. The personal file is the one lookup that reaches outside the project, so it is the one lookup a probe
  cannot safely carry.
- `project .han/config.md` (probe): the content of `.han/config.md` in the directory the skill is running from, or
  nothing.

The two directories can both exist on one machine and point at different places, so the variable wins whenever it is
set. A personal file sitting in `~/.claude/.han/config.md` does not apply to a person who has pointed
`CLAUDE_CONFIG_DIR` somewhere else.

Neither lookup walks up the directory tree. The project file is found only in the directory the skill runs from, the
same place the CLAUDE.md and project-discovery probes look. A config elsewhere in the repository does not apply. When
neither lookup yields content, no config is present: behave exactly as the skill does without this rule, with no note.

When both lookups resolve to the same file, because the skill is running inside the Claude Code configuration
directory, read it once and treat it as the project configuration. Nothing is counted twice, and its `## Extra Agents`
list is one list.

## Schema

Each file is markdown: optional YAML frontmatter for scalar settings, then named sections for list settings. Both files
carry the same settings under the same names, so moving a setting from one file to the other changes nothing but the
file it sits in.

- `output-directory` (frontmatter key): a base path under which the skill writes its markdown deliverables while
  keeping its own folder and file structure beneath it. Create the directory on first write when it does not exist.
- `default-swarm-size` (frontmatter key): the default size band for skills that classify a swarm or team size before
  dispatching agents. Accepted values, trimmed of surrounding whitespace and matched case-insensitively: `small`,
  `medium`, `large`, `dynamic`. A value of `small`, `medium`, or `large` is adopted exactly as if the user had passed
  it as the skill's size argument: the skill skips its signal-based classification, scales its caps to the band, and
  announces the band naming which file supplied it. Specialists are still selected by signal within the band's caps.
  `dynamic`, or an absent setting, leaves the skill classifying the size itself from the work's signals, with no
  mention of the config. Explicit user input outranks the setting per the precedence chain, and `dynamic` is also a
  valid explicit size input that forces signal-based classification for that run. An unrecognized size argument (a
  typo) supplies no explicit value, so the configured band still applies. A skill that dispatches no agent swarm
  ignores the setting silently.
- `writing-voice` (frontmatter key): a file path naming the writing-voice profile the readability skills apply in place
  of the built-in profile at `han-communication/references/writing-voice.md`. An absent or blank setting keeps the
  built-in profile. When a value is present, verify the file exists before using it. When it exists, that file is the
  writing-voice profile for the run, including the vocabulary blocklist the readability rule points to. When it does
  not exist, do not degrade silently: warn the user that the configured writing-voice file was not found, name which
  file configured it, and ask whether to use the built-in Han voice or skip the writing voice entirely for the run.
  Skipping means the run applies the readability rule with no voice profile and no vocabulary blocklist. A skill that
  produces no prose deliverable ignores the setting silently.
- `## Extra Agents` (section heading): one agent per list line, in qualified `plugin:agent` form or bare-name form.
  Match names case-insensitively against the agents available in the session.

## How a configured path resolves

Both `output-directory` and `writing-voice` name a path, and both resolve the same way.

- **A relative path resolves against the folder holding the file that declared it.** A relative path in the project
  file resolves against the working directory. A relative path in the personal file resolves against the
  `personal config directory` value the probe supplied. This is what lets one personal writing-voice profile, kept
  beside the personal config, apply in every project.
- **A full path is used as it stands**, including one that points outside the project.
- **A leading `~` expands to the home directory before the value is used.** Resolve it in the run rather than leaving
  it to a shell, because most skills have no shell available to them. The Read tool does expand a leading `~`, but
  always to the home directory, never to a configured directory somewhere else, so a value meant to sit beside the
  personal config must not rely on it. `..` segments are likewise accepted and resolved.

No path is refused for pointing outside the project. A skill that writes deliverables to a configured
`output-directory` outside the working directory does so without comment; the person who configured it chose that.

## Precedence

Resolve each scalar setting through this fixed chain; the first source that supplies a usable value wins:

1. Explicit user input to the skill, including an explicit output path passed by a calling skill.
2. The project `.han/config.md`.
3. The personal `.han/config.md`.
4. The CLAUDE.md `## Project Discovery` section.
5. The project-discovery file.
6. The skill's built-in defaults.

Resolution is per setting, not per file. The project file's value is used only for the settings the project file names,
so a project file naming one setting leaves every other personal setting in place. A recognized setting whose value in
the project file is blank or unusable is not a value, so that setting falls through to the personal file rather than to
the skill's default.

The extra-agents list adds rather than replaces: agents the user names explicitly are always considered, and both
files' entries join them as candidates.

## Extra agents joining the pool

A skill that selects among candidate agents adds both files' extra agents to its candidate pool. They compete under the
skill's own signal-based selection and size caps; a selected extra agent may take a slot a default specialist would
otherwise have filled, and that displacement happens without comment. An entry that duplicates an agent already in the
pool has no effect, whether the duplicate comes from the same file or the other one: the agent is one candidate,
counted once against the caps. An entry that does not resolve to a dispatchable agent is skipped with the one-line note
naming it.

## Degradation and the one-line note

A bad config can never fail a skill run; the worst it can do is be ignored. Show a one-line note only when content that
attempts a recognized override cannot be used; pass over everything else silently. A `writing-voice` value naming a
file that does not exist is the one exception: per its definition above, it asks the user which fallback to take
instead of degrading with a note.

**Every message about configuration names which of the two files it came from**, on the failure path and the success
path alike. That includes the announcement a sizing skill makes when it adopts a configured band. The two files share a
name, so a message that omits which one leaves the reader opening both.

- Malformed frontmatter, or a file unreadable as text: ignore the unusable portion, resolve those settings from the
  rest of the precedence chain, and note what was ignored and which file held it.
- The `personal config directory` probe reporting the home directory when `CLAUDE_CONFIG_DIR` names somewhere else:
  the probe runs a resolver script, and its guard falls back to the home directory if that script is missing or fails.
  Nothing detects this, and no note is shown, because the probe cannot tell a failed resolution from a person who never
  set the variable. The personal file at the configured location stops applying until the script is restored.
- A setting name the suite does not recognize: ignore it with a note; recognized settings in the same file still apply.
- A recognized setting with a blank or unusable value: ignore it with a note and fall through the precedence chain.
- A setting that does not apply to the running skill (it writes no markdown deliverable, or selects no agents): ignore
  it silently.
- A file holding only prose the suite has no use for: behave as if the file were absent, with no note.
- A personal configuration directory the run cannot reach: treat it as no personal configuration, with no note. A run
  cannot tell that apart from a person who never wrote the file, and the second group is far larger.
- A personal `.han/config.md` the Read tool cannot return, whether it is absent, unreachable, or refused: treat it as
  no personal configuration, with no note, for the same reason. This covers the read failing to produce a file at all.
  A file that reads but cannot be used is a different case and keeps the note its own bullet above describes.

One problem gets one note. Two separate problems, one in each file, get two notes, because each names a different thing
to go and fix. The note is one line naming what was ignored, which file it came from, and why, shown on each run where
the problem is present. When everything applies cleanly, say nothing about the config.
