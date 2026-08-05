# Research: Integrating readability-guidance into a custom Claude Code output style

Can the `han-communication:readability-guidance` skill be integrated into a custom Claude Code output style, and if so,
how? Evidence mode: strict (the default). Every claim below carries a source you can check, and the recommendation
rests on corroborated evidence rather than reasoning.

## Summary

You cannot move the skill into an output style, but you can move part of what the skill teaches. The skill does real
work at runtime that a style file cannot do. It reads your configuration files, picks a writing-voice profile you may
have swapped out, asks you a question when that profile is missing, and hands off to an editing agent afterward. An
output style is fixed text added to the system prompt when a session starts, so none of that survives the move.

What does survive is the always-on part of the standard. It says: write for a reader who did not do the work, lead
with the main point, keep sentences short, and avoid the banned words. Put that in a short, hand-written output style
and you get the voice across every turn of a conversation, including the ones where no skill runs. Keep the skill for
everything else.

Two limits are worth knowing before you start. The style will not reach the specialist helpers that Han dispatches to do
its heavy work, because those run their own instructions. Copying the whole standard into a style file would also work
against the way the standard is designed to be applied, in stages rather than all at once.

- **Confidence:** Medium

## Research Results

### An output style is one self-contained file, and nothing documents a way to pull in another

A custom output style is a single markdown file: metadata at the top, then the instructions added to the system prompt
(A1). The metadata section accepts exactly four settings, and none of them points at another file (A1). Anthropic's
documentation for output styles never mentions the file-including mechanisms that exist elsewhere in the product.

Those mechanisms do exist for the neighboring features. Memory files support an `@path` import that expands other files
into context when a session launches, following relative or absolute paths up to four levels deep (A3). Skills support a
shell-command syntax that runs a command and inlines its output before the model reads the text (A5). They also support
a pattern where a skill links to sibling files it reads on demand (A5). Neither is documented for output styles.

Treat this as an absence of documentation, not a proven absence of the feature `[single-source]`. Anthropic's
documentation is complete about the metadata section and silent about the body. Nobody in this research tested whether
an output style body expands a shell command or an import, and the Han repository ships no output style to test against
(A11). The section on validation below names the test that would settle it.

### The plugin path variable does not resolve in output style files

Claude Code gives plugins a variable that stands in for wherever the plugin got installed. A plugin can then point at
its own bundled files without hardcoding a path that changes on every update (A2). The documentation lists which parts
of a plugin expand that variable. Skill and agent text expand it anywhere it appears, hook and monitor commands expand
it anywhere it appears, and several server configuration fields expand it. Output styles are absent from that list
(A2).

The list is organized by plugin component and appears written to cover all of them, which makes the omission meaningful.
It still falls short of a sentence saying the variable does not work there. Read it as no documented support rather than
confirmed absence.

A related limit applies to any plugin file reference. Once a plugin is installed, it cannot reach files outside its own
directory, because those files are never copied into the local cache (A2). There is one documented way around this
inside a single marketplace. A symlink pointing at a sibling plugin in the same marketplace gets followed, and the
target's content is copied into the cache in its place (A2). That makes a file available inside a plugin. It does not
make an output style body include that file.

### The skill is built on the two mechanisms output styles lack

`readability-guidance` uses both of the features an output style has no documented access to. Its opening block runs
shell commands to find your personal configuration directory and read a project configuration file (A7, lines 17-18). Its
body points at the standard and the voice profile through the plugin path variable (A7, lines 55-63). Move the file into
`output-styles/` unchanged and both of those go from working instructions to literal text.

### The skill does runtime work that fixed text cannot do

Beyond the two mechanisms, the skill behaves like a small program (A7):

- It reads a personal and a project configuration file and applies a precedence rule where the project file wins.
- It resolves a `writing-voice` setting that lets you replace Han's built-in voice profile with your own.
- When that configured profile is missing, it warns you, names which configuration file asked for it, and asks whether
  to fall back to the built-in voice or skip the voice entirely for the run.
- After the draft exists, it runs a six-point check over the prose.
- When the calling skill is a synthesis skill, it dispatches the `readability-editor` agent for a rewrite pass.

An output style adds instructions to the system prompt and nothing else (A1). It cannot read a file, branch on what it
finds, ask you a question, or dispatch an agent.

### Output styles do not reach the subagents Han depends on

Anthropic's documentation states the limit twice, on two different pages. Output styles apply to the main conversation
only, because a subagent runs its own system prompt. A fork is the exception, since it inherits the parent's full
prompt (A1, A4). Han's whole design dispatches specialist subagents to do the judgment-heavy work, so a style you set
would not shape what any of them writes.

Memory files behave differently here. A subagent's startup context includes memory files at every level (A4). That
makes an `@import` in your own memory file the one mechanism in this research that reaches both the main conversation
and its subagents.

### Copying the whole standard in works against how the standard is designed

The readability rule states its own application model. The rule takes effect through three mechanisms a skill wires
in: a template carrying the structural rules, an always-on audience frame shaping the drafting, and a discrete
self-check that runs after the draft exists (A8, lines 12-16). It then says that applying all of it as one stacked
instruction block reproduces the failure it exists to dodge (A8, line 16). The skill repeats the point: the standard
takes effect in stages, never as one stacked instruction block (A7, line 78).

Prior research in this repository reached the same conclusion and gave the reason, which is that model compliance drops
as the number of simultaneous instructions rises (A12).

An output style is a single block of text appended to the system prompt once, at session start (A1). It cannot sequence
"draft first, check afterward." Pasting both reference files into one would deliver every rule at once, which is the
shape the standard tells you to avoid.

The same passage points at what an output style is suited for. Of the three mechanisms, the audience frame is the one
the rule itself calls always-on (A8, lines 14-15). Always-on is what a system prompt does well.

### The two files together are larger than they look

The standard is 153 lines and 11,250 bytes; the voice profile is 352 lines and 22,189 bytes, for 33,439 bytes together
(A8, A9, measured directly). No source in this research establishes that a system prompt of that size degrades output,
so treat the size as a design consideration rather than a measured cost.

### Copying either file into a style would be the first duplicate

The repository states that the readability rule, the voice profile, and the explanation rule are owned by
`han-communication` with no vendored copies elsewhere (A10). Three other shared rule files are deliberately vendored
byte-identical into many plugins, so the distinction is a decision the repository made on purpose, not an oversight
(A10). An output style with the standard pasted in would be the first copy of a file the repository says has none.

### Han ships no output style, hook, or command directory today

A repository-wide search found no `output-styles/`, `hooks/`, or `commands/` directory and no hook or settings JSON file
in any Han plugin (A11). Han ships skills and agents. Twenty-two skill files invoke `readability-guidance`, and none
reads the reference files directly (A11, verified by direct count).

Two practical notes for anyone who builds one. Changes to a plugin's output styles need a plugin reload or a restart,
while skill edits apply live (A2), so iterating is slower.

A style change of any kind also takes effect only after you clear the conversation or start a new session, because the
system prompt is read once at session start (A1, A6).

### The feature is current, though its recent history is easy to misread

Output styles are documented and live as of the retrieval date (A1). What is removed is the standalone `/output-style`
command, dropped in v2.1.91 after being deprecated in v2.1.73. You select a style through `/config` or by setting the
`outputStyle` field directly (A1).

Separately, the feature itself was deprecated in v2.0.30 and reversed days later after community objection. That the
reversal happened is corroborated across a Claude Code team member's public post, two GitHub issues, and the fact that
the feature is documented today (A1, A13, A14, A15). The exact changelog wording for the reversal rests on one blog post
and could not be checked against the public changelog, which does not reach back that far `[single-source]`.

## Options to Consider

### O1: A short output style carrying the always-on layer only

- **What it is:** A hand-written output style holding the audience frame, the drafting properties, and the vocabulary
  blocklist, without the six-point self-check or the editor handoff. Saved personally or per project. The skill keeps
  owning the staged parts.
- **Trade-offs:** You maintain a condensed restatement by hand, so it can drift from the canonical files. It does not
  reach subagents. It covers the always-on mechanism the rule names and deliberately leaves the other two to the skill.
- **Rests on:** (A1, A4, A7, A8)
- **Evidence status:** corroborated

### O2: An output style holding the full standard, generated by a build step

- **What it is:** A script concatenates the readability rule and the voice profile into a style file, so the canonical
  copies stay the single source and the style is a build artifact.
- **Trade-offs:** Delivers all 33,439 bytes as one instruction block, which is the shape the rule tells you to avoid
  (A8, A12). The repository has no build tooling to host the script; its npm scripts run linting and tests only, and its
  own project notes say there is no build. The generated file is still a second copy on disk.
- **Rests on:** (A1, A8, A9, A10, A12)
- **Evidence status:** corroborated

### O3: An output style shipped from han-communication with force-for-plugin

- **What it is:** The plugin carries `output-styles/`, and the `force-for-plugin` setting applies the style whenever the
  plugin is enabled, with no user selection (A1).
- **Trade-offs:** It overrides whatever output style the user chose, and when several plugins set it, the first one
  loaded wins (A1). It creates the duplicate the repository forbids (A10). The plugin path variable does not resolve in
  style files, so the text must be inlined (A2). It inherits every limit of O2.
- **Rests on:** (A1, A2, A10)
- **Evidence status:** corroborated

### O4: A thin output style that points at the skill

- **What it is:** A few lines in the system prompt naming the standard and telling Claude to invoke
  `han-communication:readability-guidance` before writing prose.
- **Trade-offs:** No duplication, and it inherits the skill's staged process whole. But it depends on the model choosing
  to act on an instruction. One report documents that same pattern failing in a memory file until it was replaced by
  a real import `[single-source]` (A16). Anthropic's own documentation says memory-file instructions carry no guarantee
  of strict compliance (A3). An output style sits in the system prompt, which is stronger placement than a memory file,
  so the reported failure may not transfer.
- **Rests on:** (A1, A3, A16)
- **Evidence status:** single-source on the failure mode (caveated)

### O5: A session-start hook that reads the canonical file

- **What it is:** A hook fires when the session starts and prints the canonical file, whose output is added as context
  Claude can see (A6). The hook command expands the plugin path variable, so it reads the one canonical copy with no
  duplicate (A2, A6).
- **Trade-offs:** The documented mechanism adds context, which is not the same as modifying the system prompt (A6, A7).
  A Claude Code team member described hooks as appending to the system prompt (A13), and the hooks documentation
  describes something narrower, so do not assume they carry equal weight. The subagent startup list does not include
  hook-injected context (A4), which suggests it does not reach subagents either.
- **Rests on:** (A2, A4, A6, A13)
- **Evidence status:** corroborated on mechanism; the subagent limit is inferred from an omission (caveated)

### O6: An @import in your own memory file

- **What it is:** Your personal or project memory file imports the canonical rule with `@path`, which expands the file
  into context when the session launches (A3).
- **Trade-offs:** It is a live include rather than a copy, so no duplicate. It is the only option here that reaches
  subagents, since memory files load at every level of a subagent's startup context (A4). But memory content arrives as
  a user message after the system prompt, with no guarantee of strict compliance (A3). And a plugin cannot ship it: a
  memory file at a plugin root is not loaded as project context (A2). You write the import yourself, pointing at a
  plugin cache path that changes on update (A2).
- **Rests on:** (A2, A3, A4)
- **Evidence status:** corroborated

### O7: Change nothing and keep invoking the skill

- **What it is:** The 22 skill files that invoke `readability-guidance` keep getting the standard through its staged,
  configuration-aware path (A7, A11).
- **Trade-offs:** Costs nothing and loses nothing. It leaves one gap: prose written in the main conversation outside any
  skill run carries no part of the standard. Nothing in this research establishes that gap as a felt problem.
- **Rests on:** (A7, A11)
- **Evidence status:** corroborated

## Recommendation

- **Recommendation:** **O1**, scoped personally or per project. Write a short output style carrying the audience frame,
  the drafting properties, and the vocabulary blocklist, and leave the self-check and the editor pass to the skill. Add
  **O6** alongside it if you need the standard to reach subagents, since an output style will not. Avoid **O3** for the
  Han repository specifically: it would create the first duplicate of a file the repository declares has none (A10).
  It would also override each user's own style choice (A1).

- **Evidence basis:** The recommendation rests on corroborated evidence for every load-bearing claim. Anthropic
  describes the feature as instructions added to the system prompt (A1). Set against the skill's verified behavior
  (A7), that description shows an output style cannot dispatch an agent, read configuration, or ask a question. That it
  will not reach subagents is stated on two separate documentation pages (A1, A4). That the always-on layer is the part
  suited to a system prompt comes from the rule naming the audience frame as always-on while reserving the self-check
  for a discrete later pass (A8). That copying the whole standard in works against the design is stated by the rule
  itself, by the skill, and by prior research in this repository (A7, A8, A12). The file sizes and the call-site count
  were measured directly (A8, A9, A11).

  Two parts carry caveats. That no file-including mechanism exists inside an output style body is an absence of
  documentation rather than a tested result `[single-source]`. The reported failure of pointer-style instructions, which
  is the main argument against O4, rests on one blog post `[single-source]` (A16).

  Splitting the standard the way O1 does was not itself adversarially tested; it was formed in response to the
  validation findings below.

## Validation

### V1: "A straight port is impossible" is an argument from silence

- **Strategy:** Challenge the Evidence
- **Investigation:** Checked whether any source states that an output style body is excluded from shell-command or
  import processing. None does. The claim was built from two absences: an unlisted metadata field and an unlisted table
  row.
- **Result:** Refuted
- **Impact:** The finding was rewritten from "impossible" to "undocumented and untested," and the report now names the
  experiment that would settle it.

### V2: The substitution table omission is suggestive, not conclusive

- **Strategy:** Challenge the Evidence
- **Investigation:** The table mixes configuration fields with content rows, and "skill and agent content" is a content
  row, so the table does cover instructional text. Output styles are a documented plugin component and are still absent.
- **Result:** Partially Refuted
- **Impact:** The finding now reads "no documented support" rather than "confirmed absent," while keeping the point that
  the list appears written to be complete.

### V3: The skill's described behavior matches the file on disk

- **Strategy:** Challenge the Evidence
- **Investigation:** Read the skill file line by line and checked git history. Every cited line matched, and the file was
  last changed one day before this research ran.
- **Result:** Confirmed
- **Impact:** The findings about what the skill does at runtime stand as written.

### V4: The size figure was inflated and its significance was asserted

- **Strategy:** Challenge the Evidence
- **Investigation:** Measured both files. The draft said roughly 36K by rounding each file up before adding. The true
  total is 33,439 bytes. No source establishes that a system prompt of that size degrades output.
- **Result:** Partially Refuted
- **Impact:** Corrected to the measured figure, and the size is now presented as a design consideration rather than an
  evidenced cost.

### V5: The original recommendation contradicted the repository's own prior research

- **Strategy:** Challenge the Recommendation
- **Investigation:** The draft recommended generating the full standard into a style file. The readability rule, the
  skill, and prior research all say the standard must be applied in stages and never as one stacked instruction block.
  An output style is one block appended once at session start.
- **Result:** Confirmed
- **Impact:** This is the finding that changed the outcome. The full-standard option was demoted to O2 and is no longer
  recommended. The recommendation became O1, which carries only the layer the rule itself calls always-on.

### V6: The recommended build step does not exist

- **Strategy:** Challenge the Recommendation
- **Investigation:** Checked the repository's npm scripts, its pre-commit configuration, and its project notes. Linting
  and tests only, and the notes state there is no build. No script anywhere regenerates one file's content from a
  canonical source across plugins.
- **Result:** Confirmed
- **Impact:** O2 now states plainly that it needs tooling that would have to be designed and built first.

### V7: The draft never compared its recommendation against the alternatives

- **Strategy:** Challenge the Options Framing
- **Investigation:** The draft argued against one option in detail and gave no comparative case for its pick over the
  memory-import or pointer options. Both alternatives beat it on avoiding duplication, and one of them reaches
  subagents.
- **Result:** Confirmed
- **Impact:** Every option now carries trade-offs and an evidence status, and the recommendation names when to add O6.

### V8: "Change nothing" was under-argued

- **Strategy:** Challenge the Recommendation
- **Investigation:** An output style cannot replace the skill inside skill runs and cannot reach subagents, so its whole
  gain is prose written in the main conversation outside any skill run. Nothing in the sources establishes that as an
  observed gap.
- **Result:** Confirmed
- **Impact:** O7 is now stated as a live option with its gap named, and the recommendation is scoped to the narrow value
  an output style adds.

### V9: The deprecation history is thinly sourced

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Discounting the single-source blog and the team member's personal post leaves live documentation
  showing the feature exists today, plus two GitHub issues whose comment threads could not be retrieved.
- **Result:** Partially Refuted
- **Impact:** The report now separates "documented and live today" from the reversal history, and marks the changelog
  wording as single-source.

### V10: The hook option borrowed its description from an informal source

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The draft described the hook as appending to the system prompt, which matches a team member's
  informal phrasing. The hooks documentation describes something narrower: output added as context Claude can see.
- **Result:** Confirmed
- **Impact:** O5 now uses the documented wording and flags that added context and a system prompt change may not carry
  equal weight.

### V11: A count in the evidence could not be reproduced

- **Strategy:** Challenge the Evidence
- **Investigation:** The exploration reported about 72 references. A direct count of skill files invoking the skill
  returned 22; the larger number counted every mention across the repository, including changelogs and plan documents.
- **Result:** Partially Refuted
- **Impact:** The report uses the verified figure of 22 skill files.

### Adjustments Made

Validation changed the outcome. The original recommendation was to generate the full standard into an output style from
a build step. V5 showed that contradicts the standard's own staged-application design, V6 showed the build tooling does
not exist, and V7 and V8 showed the alternatives were never weighed. That recommendation was withdrawn and demoted to
O2. The replacement, O1, carries only the always-on layer, which is the one part the rule itself designates for
continuous application. Two claims were downgraded from confirmed to undocumented (V1, V2), one figure was corrected
(V4), one count was corrected (V11), and two source-integrity problems were fixed in the text (V9, V10).

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** The crux question was never tested. Nobody confirmed whether an output style body expands a shell
  command or an `@path` import. If a shell command does expand there, the picture changes materially. A style could read
  the canonical file at load time, giving a live include with no duplicate, which would make a fuller integration
  practical. The test is cheap and worth running before you build anything. Write a style file whose body contains a
  shell command printing a recognizable string, select it, start a fresh session, and ask Claude to repeat its
  instructions. Repeat with an `@path` import.

  The split O1 proposes was formed in response to validation and did not go through an adversarial pass of its own.
  Whether a condensed restatement stays faithful to the canonical files over time is a maintenance question this
  research did not test.

  Three claims rest on a single source. They are the changelog wording for the deprecation reversal, the reported
  failure of pointer-style instructions in a memory file, and the observation that stored style files can influence
  what Claude says about output styles. None of the three carries the recommendation on its own. The subagent limit for
  hooks is inferred from an omission in a startup list rather than stated directly.

  All web sources were retrieved on one day, 2026-08-05, from documentation for a product that changed this feature's
  status twice within a week in late 2025. Re-check before acting on it later.

## Sources

| ID  | Source                             | Link / location                                                                     | Retrieved  | Trust class | Summary (one line)                                                                                    | Evidence status                          |
| --- | ---------------------------------- | ----------------------------------------------------------------------------------- | ---------- | ----------- | ----------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| A1  | Output styles documentation        | https://code.claude.com/docs/en/output-styles                                        | 2026-08-05 | web         | Four metadata fields, single-file format, main-conversation-only scope, session-start loading          | corroborated by A2, A4, A6               |
| A2  | Plugins reference                  | https://code.claude.com/docs/en/plugins-reference                                    | 2026-08-05 | web         | Substitution scope by component, path traversal limit, marketplace symlink rule, reload requirement     | corroborated by A1, A5                   |
| A3  | Memory documentation               | https://code.claude.com/docs/en/memory                                               | 2026-08-05 | web         | The `@path` import syntax, four-hop recursion, user-message delivery, no strict compliance guarantee    | corroborated by A1, A4                   |
| A4  | Subagents documentation            | https://code.claude.com/docs/en/sub-agents                                           | 2026-08-05 | web         | What loads at subagent startup; output styles excluded except in a fork; memory files included          | corroborated by A1                       |
| A5  | Skills documentation               | https://code.claude.com/docs/en/skills                                               | 2026-08-05 | web         | Shell-command inlining, supporting-file pattern, skill and project path variables                       | corroborated by A2                       |
| A6  | Hooks documentation                | https://code.claude.com/docs/en/hooks                                                | 2026-08-05 | web         | Session-start matchers; its output is added as context Claude can see                                   | corroborated by A2                       |
| A7  | readability-guidance skill         | `han-communication/skills/readability-guidance/SKILL.md`                             | n/a        | codebase    | Shell probes, config precedence, warn-and-ask fallback, staged application, editor dispatch             | corroborated by A8, verified by validator |
| A8  | The readability rule               | `han-communication/references/readability-rule.md`                                   | n/a        | codebase    | Names template, always-on audience frame, and discrete self-check; 153 lines, 11,250 bytes              | corroborated by A7, A12                  |
| A9  | The writing-voice profile          | `han-communication/references/writing-voice.md`                                      | n/a        | codebase    | Voice, tone, and the authoritative vocabulary blocklist; 352 lines, 22,189 bytes                        | corroborated by A8                       |
| A10 | Repository project map             | `CLAUDE.md`                                                                          | n/a        | codebase    | The three communication rule files are owned by one plugin with no vendored copies                      | corroborated by A11                      |
| A11 | Repository-wide search             | repository scan of `han-*/` plus a direct call-site count                            | n/a        | codebase    | No output style, hook, or command directory in any plugin; 22 skill files invoke the skill              | corroborated by A10                      |
| A12 | Prior readability research         | `docs/research/human-readable-output-standard.md`                                    | n/a        | codebase    | Compliance drops as simultaneous instructions rise, so the rule is never fired as one block             | corroborated by A7, A8                   |
| A13 | Claude Code team member's post     | https://www.threads.com/@boris_cherny/post/DQfooqiD0Qh                               | 2026-08-05 | web         | Announced the 2025 conversion of user output styles to plugins, naming hooks and memory as replacements | single source (caveated)                 |
| A14 | GitHub issues #10671 and #10672    | https://github.com/anthropics/claude-code/issues/10671                               | 2026-08-05 | web         | Community objection to the v2.0.30 deprecation; comment threads not retrievable                         | corroborated by A13                      |
| A15 | Third-party blog on the reversal   | https://claude-blog.setec.rs/blog/output-styles-underrated-feature                   | 2026-08-05 | web         | Claims v2.0.32 reversed the deprecation; exact wording unverifiable against the public changelog        | single source (caveated)                 |
| A16 | Zenn.dev report on import syntax   | https://zenn.dev/rhythmcan/articles/40da82caa3e788                                   | 2026-08-05 | web         | A "read this file" instruction in a memory file went unexecuted until replaced by a real import         | single source (caveated)                 |
| A17 | Anthropic skill-authoring guidance | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices     | 2026-08-05 | web         | Recommends a canonical style-guide file that a skill points at, as a named best practice                | corroborated by A5                       |
| A18 | Community output-style collection  | https://github.com/hesreallyhim/awesome-claude-code-output-styles-that-i-really-like | 2026-08-05 | web         | Published tone and persona styles; warns stored style files can influence Claude's own answers          | single source (caveated)                 |
| A19 | Settings documentation             | https://code.claude.com/docs/en/settings                                             | 2026-08-05 | web         | The `outputStyle` field is part of the system prompt, rebuilt on clear or restart                       | corroborated by A1                       |

### A1: Output styles documentation — recommendation-bearing

- **Link / location:** https://code.claude.com/docs/en/output-styles
- **Retrieved:** 2026-08-05
- **Trust class:** web (outside the trust boundary; fetched directly rather than through a subagent)
- **Summary:** States that a custom output style is a markdown file holding metadata and then the instructions added to
  the system prompt. Also states that Claude Code appends those instructions to the end of the system prompt. Lists exactly four
  metadata fields: the style name, its description, whether to keep the built-in software engineering instructions, and
  a plugin-only field that applies the style automatically and overrides the user's own choice. Documents the four
  locations a style can live, including a plugin's own directory. States that output styles apply to the main
  conversation only, because a subagent runs its own system prompt, with a fork as the exception. States the style is
  read once at session start, so changes take effect after a clear or a new session. Records that the standalone
  selector command was deprecated in v2.1.73 and removed in v2.1.91. The page never mentions imports, shell-command
  inlining, the plugin path variable, or supporting files.
- **Evidence status:** corroborated by A2, A4, A6

### A7: The readability-guidance skill — recommendation-bearing

- **Link / location:** `han-communication/skills/readability-guidance/SKILL.md`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The skill runs shell commands in its opening block to locate the personal configuration directory and read
  a project configuration file. It then resolves which writing-voice profile applies, with the project file winning over
  the personal one. It warns the user and asks how to proceed when a configured profile is missing. It reads the
  standard and the resolved voice profile through the plugin path variable and forbids paraphrasing them in place of
  reading them. It declares itself inline, so what it surfaces stays in the caller's context. It states that the
  standard takes effect in stages and never as one stacked instruction block, and it dispatches the readability-editor
  agent when the caller is a synthesis skill.
- **Evidence status:** corroborated by A8; every cited line independently verified against the file on disk

### A8: The readability rule — recommendation-bearing

- **Link / location:** `han-communication/references/readability-rule.md`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Names the three mechanisms through which the rule takes effect: a template carrying the structural rules,
  an always-on audience frame shaping the drafting, and a discrete self-check running after the draft exists. States
  that applying all of it as one stacked instruction block reproduces the failure the rule exists to dodge. Sets out the
  drafting properties, the length guidance, the pointer to the vocabulary blocklist, the prose-only scope, the fidelity
  requirement, and the six-point self-check. Measured at 153 lines and 11,250 bytes.
- **Evidence status:** corroborated by A7 and A12
