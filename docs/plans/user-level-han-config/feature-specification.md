# Feature Specification: Personal Han Configuration

Han reads settings from two files instead of one: a personal configuration you keep with your Claude Code settings, and
the project's own `.han/config.md`. The personal file gives you defaults that follow you into every project, and the
project file adjusts them for that project.

## Outcome

You write one personal configuration file, and every project you run Han skills in picks up your settings without you
copying a file into it.

Today a setting only takes effect in a project that carries its own `.han/config.md`. Say you want Han's deliverables
saved in `docs/han` and your own writing voice applied everywhere. You have to copy the same file into every repository
you work in, then edit every copy again whenever you change your mind.

After this change, you write those settings once. Any project that wants something different keeps the right to say so
in its own file ([D1](artifacts/decision-log.md#d1-two-configuration-layers-with-the-project-file-on-top)).

One shipped behavior changes along the way, in both files rather than only the new one. Han refuses a full path for
`output-directory` today; after this change, that guard goes away, and a project file that was refused before starts
working ([D8](artifacts/decision-log.md#d8-a-configured-path-may-point-anywhere-in-either-file)). More generally, any
path a configuration names may now point anywhere, including outside the project.

## Actors and Triggers

- **Actors:** a person running a Han skill. No other actor reads or writes these files.
- **Triggers:** every run of a Han skill that reads configuration. Nothing schedules this and nothing else invokes it.
- **Preconditions:** none. Both files are optional, and a run with neither behaves exactly as a run does today.

## Primary Flow

1. A Han skill starts and looks for a personal configuration at `.han/config.md` inside your Claude Code configuration
   directory ([T1](artifacts/feature-technical-notes.md#t1-locating-the-claude-code-configuration-directory)).
2. The skill looks for a project configuration at `.han/config.md` in the directory it is running from. That is the same
   place it looks today, and the search still does not walk up the tree
   ([D2](artifacts/decision-log.md#d2-where-the-personal-configuration-file-lives)).
3. The skill resolves each setting on its own, through a fixed chain of sources. The first source that supplies a usable
   value wins ([D3](artifacts/decision-log.md#d3-settings-merge-one-at-a-time-rather-than-whole-file),
   [D9](artifacts/decision-log.md#d9-the-personal-file-sits-directly-beneath-the-project-file-in-the-chain)):
   1. What you tell the skill directly, or a path a calling skill passes it.
   2. The project's `.han/config.md`.
   3. Your personal `.han/config.md`.
   4. The `## Project Discovery` section of the project's CLAUDE.md.
   5. The project-discovery file.
   6. The skill's own defaults.
4. The `## Extra Agents` list is the exception to step 3. Agents named in either file are all considered, and naming an
   agent in the project file does not drop the ones you named personally
   ([D4](artifacts/decision-log.md#d4-extra-agents-combine-across-both-files)).
5. Any relative path a setting names resolves against the folder holding the file that declared it. So a path you write
   in your personal file points at something beside your personal file
   ([D5](artifacts/decision-log.md#d5-a-relative-path-is-rooted-at-the-file-that-declares-it)).
6. The skill runs with the resolved settings and says nothing about either file when everything applied cleanly.

## Alternate Flows and States

### Only a personal configuration exists

- **Entry condition:** you have a personal configuration file and the project has none.
- **Sequence:** every setting resolves to your personal value, and your value also outranks anything the project's
  CLAUDE.md says about the same setting
  ([D9](artifacts/decision-log.md#d9-the-personal-file-sits-directly-beneath-the-project-file-in-the-chain)).
- **Exit:** the skill runs on your personal settings, with no note
  ([D6](artifacts/decision-log.md#trivial-decisions)).

### Only a project configuration exists

- **Entry condition:** the project has a configuration file and you have no personal one.
- **Sequence:** every setting resolves to the project's value.
- **Exit:** the skill behaves as it does today, with one exception: a full path the project file names is now accepted
  where it used to be refused ([D8](artifacts/decision-log.md#d8-a-configured-path-may-point-anywhere-in-either-file)).

### Both files name the same setting

- **Entry condition:** the same setting appears in both files.
- **Sequence:** the project's value is used and the personal value is passed over for that setting alone. Other settings
  are unaffected.
- **Exit:** the skill runs, with no note. This is the expected way to work, not a conflict to report.

## Edge Cases and Failure Modes

| Condition                                                                | Required Behavior                                                                                                                                                                                                                                                          |
| ------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Neither file exists                                                      | The run behaves exactly as it does with no configuration at all, and says nothing.                                                                                                                                                                                         |
| Your Claude Code configuration directory holds no `.han/config.md`       | Treated as no personal configuration. No note, no folder created.                                                                                                                                                                                                          |
| The configuration directory itself cannot be reached by the run          | Treated as no personal configuration, with no note. A run cannot tell this apart from a person who never wrote the file, and inventing a warning for the second case is worse than staying silent for the first ([D10](artifacts/decision-log.md#d10-an-unreachable-personal-configuration-is-silent)). |
| Either file is malformed or unreadable                                   | The unusable part is ignored, those settings fall through the rest of the chain, and one line names the setting and the file it came from ([D7](artifacts/decision-log.md#d7-every-message-about-configuration-names-which-file-it-came-from)).                             |
| A setting name in either file is not recognized                          | It is ignored with one line naming the setting and the file it came from. Recognized settings in the same file still apply.                                                                                                                                                |
| A recognized setting is blank in the project file                        | The project's blank value is unusable, so the setting falls through to your personal value rather than to the skill's default ([D3](artifacts/decision-log.md#d3-settings-merge-one-at-a-time-rather-than-whole-file)). One line names what was ignored.                    |
| The same setting has a separate problem in each file                     | Two problems get two notes, one per file, because each names a different thing to go and fix ([D7](artifacts/decision-log.md#d7-every-message-about-configuration-names-which-file-it-came-from)).                                                                          |
| Both lookups resolve to the same file, because you are running inside your own configuration directory | The file is read once and treated as the project configuration. Nothing is counted twice, and the extra-agents list is the one list the file holds.                                                                                                       |
| An output directory points somewhere that does not exist                 | The directory is created on first write, wherever it points ([D8](artifacts/decision-log.md#d8-a-configured-path-may-point-anywhere-in-either-file)).                                                                                                                       |
| A writing-voice path names a file that does not exist                    | The run warns you, names the file it looked for and which configuration declared it, and asks whether to use Han's built-in voice or write with no voice profile.                                                                                                           |
| Anything goes wrong with the combined `## Extra Agents` list             | The combined list is treated as one list under the rule already in force. An unresolvable name is skipped with one line naming it. A name appearing twice is one candidate, counted once against the team size cap ([D4](artifacts/decision-log.md#d4-extra-agents-combine-across-both-files)). |

## User Interactions

- **Affordances:** two text files you write by hand. Han does not create either one for you.
- **Feedback:** silence when the configuration applies cleanly. One line naming what was ignored, and which file it came
  from, when content that attempts a recognized setting cannot be used. Where a skill already announces a setting it
  adopted, that announcement names the file the value came from
  ([D7](artifacts/decision-log.md#d7-every-message-about-configuration-names-which-file-it-came-from)).
- **Error states:** a missing writing-voice file is the one problem that stops to ask you what to do, because the wrong
  fallback silently changes the voice of everything the run writes.

## Coordinations

Every skill that reads configuration today gains the personal lookup, and the operator guide is rewritten to describe
both files.

A partial rollout is not a valid outcome: settings that follow you into some skills and not others are harder to reason
about than settings that follow you into none
([D11](artifacts/decision-log.md#d11-the-change-lands-everywhere-configuration-is-read-or-nowhere)).

| Coordinating System                           | Direction | Interaction                                                                             | Ordering / Consistency Requirement                                                                                          |
| --------------------------------------------- | --------- | --------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Every Han skill that reads configuration      | inbound   | Each run reads both files and resolves the settings before it does any other work.       | Both files are read before the first setting is used, so no skill starts on a partly-resolved setting.                       |
| The readability skills and readability-editor | outbound  | Receive the writing-voice path, already rooted against the file that named it. | The path is resolved once, so the editor and the skill that dispatched it apply the same voice profile.                     |
| The operator-facing configuration guide       | outbound  | Describes both files, the full chain, and the removal of the output-directory guard.    | The guide and the interpretation contract describe the same behavior, since the guide is the only place most readers look.   |

## Out of Scope

- **New settings.** The set stays what it is today: `output-directory`, `default-swarm-size`, `writing-voice`, and
  `## Extra Agents`. Both files carry that same set under the same names, so moving a setting from one file to the other
  changes nothing but the file it sits in
  ([D2](artifacts/decision-log.md#d2-where-the-personal-configuration-file-lives)).
- **Searching up the directory tree.** The project file is still found only in the directory the skill runs from. A
  monorepo package without its own file still sees no project configuration, even when a sibling package has one.
- **Sharing a configuration across a team.** The personal file belongs to one person on one machine. A team that wants
  shared settings uses the project file, which travels through version control.

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. Nothing here carries a reopening trigger,
because the recorded boundary already settled it.

### Han creating your personal configuration file for you

- **Why cut:** the recorded scope asks Han to read a personal file, not to write one. `artifacts/scope-boundary.md`
  quotes the whole request as adjusting "the han config file loading."

### A way for a project to turn the personal configuration off

- **Why cut:** the recorded scope gives the project file the power to override settings, and asks for nothing beyond
  that. The direction-of-travel answer confirms both files stay, so neither one is meant to switch the other off.

### Extending the CLAUDE.md pointer to name the personal file

- **Why cut:** the pointer that `/project-discovery` maintains covers the project file, and the recorded scope names
  only how configuration is loaded.

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it.

### A way for a project to ask for Han's built-in writing voice

- **Why deferred:** the evidence test. Once your personal file names a voice profile, a project has no value it can
  write that means "use Han's own voice here." Leaving the setting out falls through to your value, and so does
  leaving it blank. Giving a project that power means adding a reserved value to the schema, and nobody has described
  needing it.
- **Reopen when:** a project reports it cannot get Han's built-in voice back while a contributor has a personal
  writing-voice set.
- **Source:** finding F6, `han-core:edge-case-explorer`.

### Telling you where deliverables landed when the output directory sits outside the project

- **Why deferred:** the evidence test. Nobody has described losing a deliverable this way, and a note on every run would
  fire for a person who set the path on purpose.
- **Reopen when:** someone reports generated plans they could not find because the configured output directory sat
  outside the repository.
- **Source:** conversation context, raised while settling
  [D8](artifacts/decision-log.md#d8-a-configured-path-may-point-anywhere-in-either-file).

## Open Items

- **OI-1:** A personal `default-swarm-size` applies to every project you touch, where the decision record that
  introduced the setting weighed its cost at one project. That record now reads narrower than the shipped behavior.
  - **Resolves when:** someone decides whether to amend the decision record or cover the wider scope in the
    configuration guide.
  - **Blocks implementation:** No. The behavior is settled; what is open is which document records why.

## Summary

- **Outcome delivered:** your Han settings follow you into every project, and any project can still adjust them.
- **Primary actors:** a person running a Han skill.
- **Decisions settled without asking:** 8. See [artifacts/decision-log.md](artifacts/decision-log.md). Two of those
  rest on the operator's own framing of the request rather than a citation from the repository; the other six cite the
  configuration rule or the repository's own documentation.
- **Decisions settled by asking:** 3. See [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** `han-core:junior-developer`, `han-core:edge-case-explorer`. See
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the specification gained the full precedence chain in place of a two-file
  description. The removal of the output-directory guard also moved, from a table cell into the Outcome section, where
  a reader meets it first. See [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
- **Technical notes:** 1. See [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
