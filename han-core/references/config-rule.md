### Schema

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
- `## Code Review Types` and `## Code Review Type Agents` (section headings): list settings owned by the code-review
  skill, which defines their line format and how it uses them. Every other skill ignores both silently.

### How a configured path resolves

`output-directory`, `writing-voice`, and each path listed under `## Code Review Types` name a path, and all resolve the same way.

- **A relative path resolves against the folder holding the file that declared it.** A relative path in the project
  file resolves against the working directory. A relative path in the personal file resolves against the
  personal config directory the loader names. This is what lets one personal writing-voice profile, kept
  beside the personal config, apply in every project.
- **A full path is used as it stands**, including one that points outside the project.
- **A leading `~` expands to the home directory before the value is used.** Resolve it in the run rather than leaving
  it to a shell, because most skills have no shell available to them. The Read tool does expand a leading `~`, but
  always to the home directory, never to a configured directory somewhere else, so a value meant to sit beside the
  personal config must not rely on it. `..` segments are likewise accepted and resolved.

No path is refused for pointing outside the project. A skill that writes deliverables to a configured
`output-directory` outside the working directory does so without comment; the person who configured it chose that.

### Precedence

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

A keyed list setting, where each line names a key such as a review type, resolves per key. When both files name the
same key, the project file's line is used; when that line is unusable, the personal file's line for the same key is
used. Lines with different keys are all kept. `## Code Review Type Agents` lines add together across both files, as
`## Extra Agents` entries do.

### Extra agents joining the pool

A skill that selects among candidate agents adds both files' extra agents to its candidate pool. They compete under the
skill's own signal-based selection and size caps; a selected extra agent may take a slot a default specialist would
otherwise have filled, and that displacement happens without comment. An entry that duplicates an agent already in the
pool has no effect, whether the duplicate comes from the same file or the other one: the agent is one candidate,
counted once against the caps. An entry that does not resolve to a dispatchable agent is skipped with the one-line note
naming it. A skill may consider the list on only some of its runs; when it does, its own instructions say which.

### Degradation and the one-line note

A bad config never fails a skill run, with two exceptions. A `writing-voice` value naming a file that does not exist
asks the user which fallback to take, per its definition above. A review type the user invokes by name, whose
configured file is missing or incomplete, stops that code review before it starts, as the code-review skill defines.
Otherwise the worst a bad config can do is be ignored. Show a one-line note only when content that attempts a
recognized override cannot be used; pass over everything else silently.

**Every message about configuration names which of the two files it came from**, on the failure path and the success
path alike. That includes the announcement a sizing skill makes when it adopts a configured band. The two files share a
name, so a message that omits which one leaves the reader opening both.

- Malformed frontmatter, or a file unreadable as text: ignore the unusable portion, resolve those settings from the
  rest of the precedence chain, and note what was ignored and which file held it.
- The loader reporting that it did not run: its probe falls back to a one-line message when the script is missing or
  fails, and the run then behaves as if no configuration exists, with no note.
- A setting name the suite does not recognize: ignore it with a note; recognized settings in the same file still apply.
- A recognized setting with a blank or unusable value: ignore it with a note and fall through the precedence chain.
- A setting that does not apply to the running skill (it writes no markdown deliverable, or selects no agents): ignore
  it silently.
- A file holding only prose the suite has no use for: behave as if the file were absent, with no note.
- A file the loader reports as not found, at either path: no configuration from that file, with no note. The loader
  cannot tell a missing file from a directory it could not reach, and neither is distinguishable from a person who
  never wrote the file, which is by far the commonest case. A file that loaded but cannot be used is a different case
  and keeps the note its own bullet above describes.

One problem gets one note. Two separate problems, one in each file, get two notes, because each names a different thing
to go and fix. The note is one line naming what was ignored, which file it came from, and why, shown on each run where
the problem is present. When everything applies cleanly, say nothing about the config.
