# Change Plan: Code Review Types

## Why This Change

Code review today picks its depth from the size of the change, and the operator wants it to pick its focus from a named
review type instead. Typing `/han-coding:code-review work-ticket docs/tickets/my-ticket.md` should check whether the
branch resolves that ticket, and typing `testing` or `architecture` should run only the specialists for that concern.
The goal, in the operator's words: "so reviews can be parallelized, focused, and valuable by keeping concerns better
separated." Teams using Han must also be able to add review types of their own, such as a `pii-check` or a
`hipaa-compliance` review, and attach their own agents to any type, through `.han/config.md`.

This is a deliberate improvement to a design the operator already sketched, not a fix for a reported defect. The source
is the operator's own request and the answers given during planning, recorded word for word in
`artifacts/scope-boundary.md` and the decision log.

## What Changes, In One Paragraph

After this change, code review runs one named concern well, instead of scaling one broad review to the size of the
diff. Each review type is a small data file that names its specialists, its share of the manual checklist, its severity
rule, any extra instructions, and any report section it adds. Han ships six types, and a team can declare more in
`.han/config.md` with files of the same shape.

The skill keeps every step that applies to all reviews: finding the change, automated checks, the manual pass, the YAGNI
pass, the independent validation pass, report writing, and the readability rewrite. With no type named, the review runs
a default set of five types together, which reproduces today's review.

Four other things change. One default severity rule replaces the three size bands. Each run writes into its own folder,
so two typed reviews of one branch can run side by side. Every agent returns its findings for the skill to file. The
PR-posting skill passes the type through.

## Current State

Size changes less than its name suggests. It never changes which specialists run: two always run and the other nine
join when the changed files touch their area, at every size
([C-2](artifacts/current-state-findings.md#c-2-size-does-not-change-which-agents-run-it-only-changes-severity-calibration)).
What size does change is which severities survive. Small, the default, omits Suggestions; Medium keeps Suggestions the
change introduced; Large keeps everything. That rule is restated in three places, and the manual and agent versions
disagree about which way to break a tie at Large
([C-3](artifacts/current-state-findings.md#c-3-the-severity-ladder-is-restated-in-three-places-and-manual-vs-agent-rules-disagree-at-large)).
Size is read at more than a dozen sites across `SKILL.md` and four reference files
([C-5](artifacts/current-state-findings.md#c-5-full-fan-out-of-size-consumers)).

Everything the skill knows about a specialist is spread over nine tables keyed by agent name, which agree only by
convention. One of them is already stale: `output-verification.md` lists 8 of the 11 agents
([C-11](artifacts/current-state-findings.md#c-11-per-agent-data-is-spread-across-nine-parallel-tables-keyed-by-agent-name)).
Three specialists are told to write a file but have no tool to write one. Separately, an agent added through
`## Extra Agents` is dispatched but its output is never read
([C-23](artifacts/current-state-findings.md#c-23-extra-agents-and-specialists-without-a-write-tool-have-nowhere-reliable-to-put-their-findings)).

Three properties block the operator's goal directly:

- **The first argument has no rule** for telling a size from focus text or a Mode C path, and a type plus a ticket
  needs two positions
  ([C-7](artifacts/current-state-findings.md#c-7-the-first-argument-has-no-disambiguation-rule)).
- **Parallel runs collide.** Every specialist writes to a fixed file name such as `docs/security-analysis.md`, and the
  report name carries no type, so two reviews of one branch overwrite each other and can read each other's files
  ([C-13](artifacts/current-state-findings.md#c-13-agent-output-files-have-fixed-names-so-parallel-reviews-collide-and-stale-files-can-be-read),
  [C-14](artifacts/current-state-findings.md#c-14-the-report-name-is-per-branch-and-a-second-run-replaces-the-first)).
- **There is no way to verify a ticket.** The only work-document intake summarizes to 200 words, fails open, and is
  skipped without git
  ([C-8](artifacts/current-state-findings.md#c-8-step-15-is-the-only-work-document-intake-today-and-it-does-not-fit-a-ticket-to-verify-against),
  [C-10](artifacts/current-state-findings.md#c-10-code-review-cannot-fetch-a-ticket-url-today)). The existing
  `han-core:gap-analyzer` agent already compares an implementation against a requirements document
  ([C-20](artifacts/current-state-findings.md#c-20-han-coregap-analyzer-already-does-spec-vs-implementation-comparison-and-can-fetch-urls)).

The config file has one canonical rule with twelve byte-identical copies, and that rule says a bad config never fails a
run, with one exception today
([C-24](artifacts/current-state-findings.md#c-24-the-config-rule-is-one-canonical-file-with-twelve-byte-identical-copies-and-a-bad-config-never-fails-a-run)).

## Target State

The skill splits into two kinds of thing that change for different reasons. **A review type** says which concerns a
review covers. **A roster entry** says how to brief one specialist and where its output is filed. Types name roster
entries; they never restate them
([D-1](artifacts/change-decision-log.md#d-1-type-files-name-agents-everything-about-briefing-an-agent-stays-shared-and-keyed-by-agent)).

### What `SKILL.md` owns

`SKILL.md` keeps the shared flow and gains a `## Review Types` section, the only list of shipped type tokens and the
only link to each shipped type file
([D-2](artifacts/change-decision-log.md#d-2-skillmd-lists-the-shipped-review-types-type-files-carry-no-links)).
That section also pins the default set
([D-6](artifacts/change-decision-log.md#d-6-no-type-means-one-run-of-the-default-set-with-todays-roster-rule)) and
says that `.han/config.md` may declare more types
([D-20](artifacts/change-decision-log.md#d-20-hanconfigmd-can-declare-review-types-that-han-does-not-ship)):

```
| Token             | File                                                                          | Purpose                                                   |
| `security`        | [references/types/security.md](./references/types/security.md)               | Whether the change opens an exploitable path              |
| `testing`         | [references/types/testing.md](./references/types/testing.md)                 | Test coverage and edge cases of the change                |
| `architecture`    | [references/types/architecture.md](./references/types/architecture.md)       | Module structure, dependency direction, runtime flow      |
| `observability`   | [references/types/observability.md](./references/types/observability.md)     | Telemetry design and whether failures are visible         |
| `maintainability` | [references/types/maintainability.md](./references/types/maintainability.md) | Clarity, naming, and fit with the project's own standards |
| `work-ticket`     | [references/types/work-ticket.md](./references/types/work-ticket.md)         | Whether the change resolves a named work ticket           |

Default (no type token): security, testing, architecture, observability, maintainability
Default always-run agents: han-core:junior-developer, han-core:adversarial-security-analyst
Every other agent in the default set's rosters: dispatched only when its roster signal fires
Also on the default run, under the same signal rule: agents .han/config.md attaches to a default-set type, and ## Extra Agents
More types: declared under ## Code Review Types in .han/config.md; never part of the default run
```

The flow it keeps, with what moves:

1. **Step 1** finds the change (Modes A, B, C unchanged), parses the argument string by the grammar below, reads and
   checks the type file, and prints the review-type announcement.
2. **Step 1.5** loads branch context, unchanged.
3. **Step 1.6** (new) loads the work ticket, for `work-ticket` only, and waits on the operator when it cannot.
4. **Step 2** runs automated checks, unchanged.
5. **Step 3** becomes "Resolve the Review Type and Dispatch Review Agents"
   ([D-17](artifacts/change-decision-log.md#trivial-decisions)): 3.0 names the run and its folder, 3.1 confirms the
   type, 3.2 reads the roster from the type and the config, and 3.3 to 3.5 brief and dispatch, filing each agent's
   returned output.
6. **Step 4** applies the type's checklist categories plus the YAGNI pass, which always runs.
7. **Steps 5 to 10** are unchanged apart from the size wording, the report's type line, the type's report section, and
   Step 10 naming the run folder.

### The type-file contract

Every type file, shipped or configured, has six sections in a fixed order
([D-3](artifacts/change-decision-log.md#d-3-the-type-file-contract-is-six-fixed-sections)):

| Section                   | Value form                                                                          | Read at        |
| ------------------------- | ----------------------------------------------------------------------------------- | -------------- |
| `## Purpose`              | one sentence                                                                        | Steps 1, 8, 10 |
| `## Roster`               | `- Always:` comma-separated agents; `- When relevant:` comma-separated agents or `none` | Step 3.2   |
| `## Checklist categories` | comma-separated names as bolded in `review-checklist.md`, or `none`                 | Step 4         |
| `## Severity`             | `default`, or text replacing both lines of the severity slot                        | Steps 3.3, 4   |
| `## Instructions`         | `none`, or one blockquote appended to every agent prompt and applied to Step 4      | Steps 3.5, 4   |
| `## Report section`       | `none`, or one fenced section layout followed by the rules for filling it           | Step 8         |

A missing section stops the run before Step 2 with `Review type file {path} is missing section "{name}". No review ran.`
A category name `review-checklist.md` does not bold is skipped with a one-line note.

The worked example, `han-coding/skills/code-review/references/types/work-ticket.md`:

````markdown
# Review type: work-ticket

## Purpose

Verify that the change on this branch resolves the named work ticket.

## Roster

- Always: han-core:gap-analyzer
- When relevant: han-core:test-engineer

## Checklist categories

Correctness, Testing

## Severity

default

## Instructions

> This is a work-ticket review. The question is whether the change delivers what the ticket asks. A ticket requirement
> the change does not meet counts as introduced by this change for the calibration directive. Do not raise findings
> unrelated to a ticket requirement unless they are Critical under the directive.

## Report section

```
## Ticket Resolution

**Ticket:** {$ticket_ref} | **Verdict:** {Resolved | Partially resolved | Not resolved | Not verified}

| Ticket requirement | Status | Evidence |
| ------------------ | ------ | -------- |
| {requirement, quoted from the ticket} | {Met | Partial | Not met} | {`file:line`, or the WARN-### that records it} |
```

Rows come from gap-analyzer's Requirement Map, or from Step 4's by-hand sweep in manual-only mode. After Step 7.4, a
row is Not met when a surviving Missing or Divergent finding names it, Partial when a surviving Partial finding names
it, and otherwise keeps the map's status; a row whose gap finding was discarded is Met, with the evidence
"GAP-### discarded at validation". Evidence shows the WARN-### or SUGG-### task ID Step 7 gave a surviving gap.
Verdict: Not verified when there is no Requirement Map and no by-hand sweep, with one line saying why; Not resolved
when any row is Not met; Resolved when every row is Met and the row count equals the map's "Requirements in ticket"
count; Partially resolved otherwise, with the line "{N - rows} of {N} requirements were not checked." when rows are
missing.
````

The other five shipped type files follow the same layout. Their rosters and checklist categories are in
[D-4](artifacts/change-decision-log.md#d-4-the-first-set-of-types); their `Instructions` and `Report section` are
`none`, and their `Severity` is `default`.

### Review types and agents from `.han/config.md`

A team declares its own types, and attaches agents to any type, in either config file
([D-20](artifacts/change-decision-log.md#d-20-hanconfigmd-can-declare-review-types-that-han-does-not-ship),
[D-21](artifacts/change-decision-log.md#d-21-hanconfigmd-can-attach-agents-to-a-review-type-and-extra-agents-stays-with-the-default-run)):

```markdown
## Code Review Types

- pii-check: .han/review-types/pii-check.md
- hipaa-compliance: ~/review-types/hipaa-compliance.md

## Code Review Type Agents

- testing: acme:mutation-tester
- pii-check: acme:pii-scanner
```

A configured type file follows the same six-section contract. For example, `.han/review-types/pii-check.md`:

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

The rules, in short:

- Tokens are lowercase letters, digits, and hyphens, starting with a letter. A shipped token, a retired size word, or
  `default` is reserved: the line is ignored with a one-line note naming the file.
- Paths resolve as `writing-voice` does. When both files declare one token, the project file wins.
- The type file is read only when its token is invoked. A broken project line falls through to the personal file's
  line for the same token. When no usable line remains, the run stops with
  `Review type "{token}" is declared in the {project|personal} .han/config.md as {path}, but {the file was not found | its "{name}" section is missing}. No review ran.`
  It stops rather than asking, because the repair is a file edit and a rerun is the retry.
- An agent with a roster-table row keeps its signal under `When relevant`. An agent without one (D-1's last row) runs
  whenever the type runs. Its output is filed as `{agent name with ":" as "-"}.md`, and its series is
  `X-{agent name with ":" as "-"}`, so two such agents never share an ID.
- Agents attached under `## Code Review Type Agents` run on every run of that type, with no signal gate. On the
  default run, agents attached to a default-set type join under today's `## Extra Agents` signal rule. A line is read
  only when its token runs, so a line naming a type a project does not declare stays silent.
- `## Extra Agents` reaches only the default run, under today's signal rule. Typed runs ignore it silently.
- Configured types never join the default run.

The token form, reserved names, stop message, and attach rules live in code-review's `## Review Types` section and in
`docs/configuration.md`. The config rule, copied into twelve plugins, carries only what every skill needs to read the
file correctly. Its changes, word for word:

- **Schema**, a new bullet after `## Extra Agents`:

  ```
  - `## Code Review Types` and `## Code Review Type Agents` (section headings): list settings owned by the code-review
    skill, which defines their line format and how it uses them. Every other skill ignores both silently.
  ```

- **How a configured path resolves**, the first line becomes:

  ```
  `output-directory`, `writing-voice`, and each path listed under `## Code Review Types` name a path, and all resolve the same way.
  ```

- **Precedence**, a new paragraph after "The extra-agents list adds rather than replaces":

  ```
  A keyed list setting, where each line names a key such as a review type, resolves per key. When both files name the
  same key, the project file's line is used; when that line is unusable, the personal file's line for the same key is
  used. Lines with different keys are all kept. `## Code Review Type Agents` lines add together across both files, as
  `## Extra Agents` entries do.
  ```

- **Extra agents joining the pool**, a new last sentence:

  ```
  A skill may consider the list on only some of its runs; when it does, its own instructions say which.
  ```

- **Degradation**, the opening paragraph becomes:

  ```
  A bad config never fails a skill run, with two exceptions. A `writing-voice` value naming a file that does not exist
  asks the user which fallback to take, per its definition above. A review type the user invokes by name, whose
  configured file is missing or incomplete, stops that code review before it starts, as the code-review skill defines.
  Otherwise the worst a bad config can do is be ignored. Show a one-line note only when content that attempts a
  recognized override cannot be used; pass over everything else silently.
  ```

### The argument grammar

The skill parses the raw argument string itself rather than trusting the harness's `arguments:` binding, which nobody
could inspect, and the frontmatter drops `arguments: size`
([D-7](artifacts/change-decision-log.md#d-7-the-argument-grammar)):

```
argument-hint: "[type: security | testing | architecture | observability | maintainability | work-ticket <ticket> | a type from .han/config.md] [focus areas, or file paths in Mode C]"

args         := [ retired-size ] [ type-clause ] [ rest ]
retired-size := "small" | "medium" | "large" | "dynamic"
                (recognized only as the first token, and only when it is the whole string or the next token is a type token)
type-clause  := type-token | "work-ticket" SP ticket-ref
type-token   := a Token from SKILL.md's ## Review Types table other than work-ticket,
                or a token declared under ## Code Review Types in either .han/config.md
ticket-ref   := the next token as given; a double-quoted token may contain spaces
rest         := the remaining string, verbatim → $focus_areas ("none provided" when empty);
                in Mode C, tokens in rest that resolve as paths or globs also build the file list
matching     := tokens split on whitespace and compare case-insensitively; a quoted first token is never a type token
default      := a first token of "default" selects the default run explicitly and is removed from the focus text
```

The parse uses the config the skill already read at the top of `SKILL.md`, so every configured token is known before
Step 1 reads the first word. A first token that is not a type token stays in the focus text, as it does today. A Mode C
path named like a type is written `./testing`.

A retired size word is dropped with the note `Size options were removed from code review; "{word}" was ignored.`
([D-19](artifacts/change-decision-log.md#trivial-decisions)), but only when it stands alone or comes before a type
token, so "large file uploads" keeps its first word.

Step 1 ends, before Step 2 runs anything, by printing:

```
Review type: {token}: {Purpose}{ (declared in the project .han/config.md | declared in the personal .han/config.md)}
Focus: {$focus_areas}
```

or, with no type token:

```
Review type: default (no type given{; "{first word}" is not a review type, so it is read as focus text})
Available types: {every shipped token}{, every configured token}
Focus: {$focus_areas}
```

`work-ticket` with nothing after it stops with
`work-ticket needs a ticket reference: a file path, a URL, or an ID. Usage: work-ticket <ticket> [focus]. No review ran.`
The decision log carries the full table of worked invocations.

### One default severity rule, which a type may override

Every run uses today's Medium rule unless its type says otherwise: Critical and Warning findings escalate, and a
Suggestion is raised only when this change directly introduces it. Manual and agent findings both prefer the lower
severity when uncertain. The Step 3.3 calibration directive, the single home for severity calibration, carries the rule
as a two-line slot:

```
Severity: Critical and Warning findings escalate; a Suggestion is raised only when this change directly introduces it.
When uncertain between two severities, prefer the lower one.
```

A type file's `## Severity` section holds `default` or text that replaces both lines, so it must say which severities
are reported and which way an uncertain finding goes. Step 3.3 puts it into the slot and Step 4 applies it. All six
shipped types hold `default`, and a run with no type always uses the default
([D-8](artifacts/change-decision-log.md#d-8-one-default-severity-rule-replaces-the-size-ladder-and-a-type-may-override-it)).

The directive's first line becomes `This is a **{type}** review of a change touching {N} files.` Its size-independent
half stays as it is
([C-4](artifacts/current-state-findings.md#c-4-the-size-independent-half-of-the-calibration-directive-is-reusable-shared-flow)).

### Run names, the working folder, and how findings are filed

Each run gets its own folder, named at Step 3.0 before dispatch
([D-10](artifacts/change-decision-log.md#d-10-each-run-gets-its-own-working-folder-and-a-typed-report-name)):

```
{slug}          = today's Step 8.6 slug (the ticket, the branch, or what was reviewed), or for work-ticket the
                  ticket slug; then lowercased, each run of characters outside [a-z0-9] replaced by one "-",
                  and "-" trimmed from both ends; an empty result becomes "review"
{run_name}      = code-review-{slug}              (default run)
                = code-review-{slug}--{type}      (typed run)
{report_directory} = today's Step 8.6 destination: a configured output-directory, else the docs folder
                   Step 3 resolves, with Step 8.6's write-failure fallback
{run_directory} = {report_directory}/{run_name}/
agent file      = {run_directory}/{Output file from the roster table}
ticket copy     = {run_directory}/ticket.md       (work-ticket only)
report          = {report_directory}/{run_name}.md
```

A sanitized slug never contains `--`, so the default run of branch `feat-retry-testing` and a `testing` run of branch
`feat-retry` cannot share a name. The run folder sits beside the report, so a configured `output-directory` holds
both. Step 3.0 prints `Run folder: {run_directory}`, and Step 10 names it.

Agents hand back their findings either way they can
([D-22](artifacts/change-decision-log.md#d-22-agents-hand-back-their-findings-as-a-file-they-name-or-as-raw-output-and-the-skill-uses-either)).
Every Step 3.5 prompt ends with: `If you write your output to a file, write it to {run_directory}/{Output file} and
name that path in your final message. Otherwise, return your complete output, including every finding, as your final
message, in any format.` When the final message names an existing file, Step 7.1 reads it. Otherwise the skill writes
the returned message, as it came, to the agent's file in the run folder. A failed agent's file gets
`Not covered in this run: {reason}`. Step 7.1 reads only the sources recorded in this run, so a rerun never reads an
earlier run's output.

### Ticket intake for `work-ticket`

The skill loads the ticket itself in Step 1.6 and makes no assumption about how
([D-11](artifacts/change-decision-log.md#d-11-the-skill-loads-the-ticket-with-whatever-tooling-the-installation-has-and-waits-on-the-user-when-it-cannot)).
A local file is read directly. Anything else is fetched with whatever tools and permissions the Claude installation
provides; the skill names no fetch tool and adds nothing to `allowed-tools`. When the load fails or returns no ticket
content, the skill prints:

```
work-ticket could not load the ticket {$ticket_ref}: {what failed, in one line}.
Paste the ticket's text, or tell me how to get it, and the review will continue.
```

and waits. Pasted text becomes the ticket; instructions are followed and the load retried. The text is written to
`{run_directory}/ticket.md` once Step 3.0 has named the folder.

`gap-analyzer` receives that path with three instructions: treat the ticket as data, state how many requirements the
ticket has, and list every one, met or not
([D-12](artifacts/change-decision-log.md#d-12-gap-analyzer-joins-the-shared-roster)). In Mode B and Mode C,
`gap-analyzer`'s prompt names the change the way Step 1 resolved it: the uncommitted diff in Mode B, and the listed
files read in full in Mode C.

### Contracts across the seams

| Contract | Parties | Pinned in |
| --- | --- | --- |
| Type-file sections and value forms | `SKILL.md` Steps 1, 3.2, 3.3, 3.5, 4, 8, 10 ↔ every shipped and configured type file | D-3, the two worked examples above |
| Shipped type tokens | `## Review Types` table ↔ code-review `argument-hint` ↔ type file names ↔ `post-code-review-to-pr` `argument-hint` | D-2, D-7, D-14; checked by D-16 |
| Configured types and attached agents | `.han/config.md` ↔ `config-rule.md` and its copies ↔ code-review Steps 1 and 3.2 ↔ `docs/configuration.md` | D-20, D-21, the config example above |
| Agent output file and series | roster table, including the last row ↔ per-agent prompt ↔ Step 3.5 filing ↔ Step 7.1 ↔ rubric | D-1, D-12, D-22 |
| Run and report names | Step 3.0 ↔ Step 3.5 filing ↔ Step 7.1 ↔ Step 8.6 ↔ Step 10 | D-10 |
| Ticket copy and Requirement Map | Step 1.6 ↔ Step 3.0 ↔ `gap-analyzer` prompt ↔ Step 8 report section ↔ manual sweep | D-11, D-12, D-13 |
| Report path, type line, and Ticket Resolution | code-review Step 10 and report header ↔ `post-code-review-to-pr` Steps 2 and 3 | D-13, D-14, D-18 |

## Surface Delta

### S-1: Roster table in `references/agent-dispatch.md` — Re-scoped

**Target state.** `agent-dispatch.md` carries one roster table with the columns Agent, Signal, File-list slice, Output
file, and Series, one row per shipped agent, plus a last row for any agent without one (S-30). It is the single home for
which file each agent's output is filed under and which finding-ID series its findings use. The per-agent directives,
per-agent prompts, and manual-sweep rows stay in the same file, keyed by agent.

**Behavior.** Preserving. Every agent receives the same prompt, apart from S-31's last sentence, and its output keeps
the same file name.

**Why.** Per-agent data agrees across nine tables only by convention, and one list is already stale.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-type-files-name-agents-everything-about-briefing-an-agent-stays-shared-and-keyed-by-agent)

### S-2: Step 7.1 output-file list and `output-verification.md` item 2 — Re-scoped

**Target state.** Step 7.1 reads, for each agent dispatched at Step 3.5, the file Step 3.5 wrote for it in this run.
Item 2 of `references/output-verification.md` checks findings from every dispatched agent by pointing at the roster
table. Neither lists agents.

**Behavior.** Changing (minor). The same files are read; the verification check covers all 11 agents instead of 8, so
findings from three more agents are checked.

**Why.** Removes two duplicate agent lists, one of them stale.

**Depends on.** S-1, S-31.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-type-files-name-agents-everything-about-briefing-an-agent-stays-shared-and-keyed-by-agent)

### S-3: The `size` argument and the `default-swarm-size` read — Removed

**Target state.** Code review has no size argument and reads no size from configuration. A first token of `small`,
`medium`, `large`, or `dynamic` is dropped with a one-line note when it stands alone or before a type token. Which
concerns a review covers is set by the review type alone, and which severities it reports is set by S-4.

**Behavior.** Changing. `/code-review large` no longer widens the review, and `default-swarm-size` no longer affects
code review. Settled by the recorded boundary ("replace the current sizing options for code reviews") and the
confirmation turn.

**Why.** The operator's direction of travel.

**Migration.** Drop the size word. Use a type token to choose a focus.

**Decision.** [D-9](artifacts/change-decision-log.md#d-9-code-review-stops-reading-default-swarm-size), [D-19](artifacts/change-decision-log.md#trivial-decisions)

### S-4: Severity calibration in the Step 3.3 directive — Re-scoped

**Target state.** The Step 3.3 calibration directive carries the type's `## Severity` sentence when it is not
`default`, and otherwise one default rule: Critical and Warning findings escalate, and a Suggestion is raised only when
this change directly introduces it. It remains the single authoritative home for severity calibration. The Review
Constraints preamble, the Mode B and Mode C note, the Step 7.3 heading, the validator brief in `finding-filters.md`, the
YAGNI wording in `review-checklist.md`, and Step 10 point at it without naming a size.

**Behavior.** Changing. Former Small runs gain Suggestions the change introduced. Former Large runs lose pre-existing
Suggestions, and their uncertain Warnings become Suggestions, so a PR review can post `COMMENT` where it posted
`REQUEST_CHANGES`. Manual findings no longer prefer the higher severity at any size. The operator chose this rule and
the per-type override.

**Why.** Size is gone, so one rule has to replace the ladder.

**Depends on.** S-3.

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-one-default-severity-rule-replaces-the-size-ladder-and-a-type-may-override-it)

### S-5: Argument grammar (frontmatter and Step 1 parse) — Re-scoped

**Target state.** The frontmatter has no `arguments:` line and carries the `argument-hint` given in Target State. Step 1
parses the raw argument string by the pinned grammar into the retired-size note, the type, the ticket reference,
`$focus_areas`, and, in Mode C, the file list.

**Behavior.** Preserving for every invocation whose first token is not a type token, and is not a size word standing
alone or before a type token. Size words are covered by S-3; a focus phrase whose first word is a type token is listed
under Risks.

**Why.** One positional slot served three readings with no stated rule.

**Depends on.** S-3.

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-the-argument-grammar)

### S-6: `## Review Types` section in `SKILL.md` — Added

**Target state.** `SKILL.md` has a `## Review Types` section holding the shipped type table (token, link, purpose),
the default set, the default always-run agents, what else joins the default run, and the pointer to configured types.
It is the only list of shipped tokens and the only link to each shipped type file.

**Behavior.** Preserving (new structure).

**Why.** The plugin-builder guidance requires a direct link from `SKILL.md` to every reference file, and the default
run needs a named set.

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-skillmd-lists-the-shipped-review-types-type-files-carry-no-links), [D-6](artifacts/change-decision-log.md#d-6-no-type-means-one-run-of-the-default-set-with-todays-roster-rule)

### S-7: The type-file contract — Added

**Target state.** Every type file, shipped or configured, has a `# Review type: {token}` title and the six sections
Purpose, Roster, Checklist categories, Severity, Instructions, and Report section, in that order, each holding a value of
the pinned form, `none`, or (for Severity) `default`. Step 1 stops before Step 2 when a section is absent.

**Behavior.** Preserving (new structure).

**Why.** `SKILL.md` and every type file, including ones a team writes, must agree on these fields independently.

**Depends on.** S-6.

**Decision.** [D-3](artifacts/change-decision-log.md#d-3-the-type-file-contract-is-six-fixed-sections)

### S-8: `references/types/security.md` — Added

**Target state.** The `security` type always runs `han-core:adversarial-security-analyst`, adds no other agent, and
sweeps Data Isolation, Error Handling, and API Design by hand. It is the only focused shipped type that runs the
security check.

**Behavior.** Changing, as a set with S-9 to S-12: a run with any other type token runs no security check. The operator
decided this ("'security' will be it's own type, and will not automatically run when calling other types").

**Why.** The operator's answer to the security question.

**Depends on.** S-7.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-first-set-of-types), [D-5](artifacts/change-decision-log.md#d-5-security-is-its-own-type-and-no-type-points-at-another)

### S-9: `references/types/testing.md` — Added

**Target state.** The `testing` type always runs `han-core:test-engineer` and `han-core:edge-case-explorer` and sweeps
Testing and Correctness by hand.

**Behavior.** Preserving (new type).

**Why.** One of the operator's named types.

**Depends on.** S-7.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-first-set-of-types)

### S-10: `references/types/architecture.md` — Added

**Target state.** The `architecture` type always runs `han-core:structural-analyst` and `han-core:behavioral-analyst`,
adds `han-core:concurrency-analyst` and `han-core:data-engineer` when their signals fire, and sweeps Code Organization,
API Design, Database, and Performance by hand.

**Behavior.** Preserving (new type).

**Why.** One of the operator's named types.

**Depends on.** S-7.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-first-set-of-types)

### S-11: `references/types/observability.md` — Added

**Target state.** The `observability` type always runs `han-core:observability-engineer`, adds
`han-core:on-call-engineer` and `han-core:devops-engineer` when their signals fire, and sweeps Error Handling by hand.

**Behavior.** Preserving (new type).

**Why.** One of the operator's named types.

**Depends on.** S-7.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-first-set-of-types)

### S-12: `references/types/maintainability.md` — Added

**Target state.** The `maintainability` type always runs `han-core:junior-developer` and sweeps Code Maintainability,
Documentation, Code Style & Patterns, Architecture Decision Records, and Packaging by hand.

**Behavior.** Preserving (new type).

**Why.** Gives the generalist reviewer a home, so the default set covers today's whole roster.

**Depends on.** S-7.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-first-set-of-types)

### S-13: Step 3.2 agent selection — Re-scoped

**Target state.** Step 3.2 builds the roster from the resolved type: every agent on its `Always` line, every agent on
its `When relevant` line whose roster-table signal fires (an agent without a signal runs regardless), and every agent
`.han/config.md` attaches to the type. For the default run it takes the union of the default set's agents under the
default rule in `## Review Types`, plus agents attached to a default-set type, plus `## Extra Agents` under today's
signal rule. A typed run does not consider `## Extra Agents`. Agents the user named explicitly join as they do today.
Step 3.2 no longer carries an always-dispatch list of its own.

**Behavior.** Preserving for the default run. Changing for typed runs, per S-8.

**Why.** Which agents run is now a property of the type and the config.

**Depends on.** S-1, S-6, S-8 to S-12, S-28.

**Decision.** [D-5](artifacts/change-decision-log.md#d-5-security-is-its-own-type-and-no-type-points-at-another), [D-6](artifacts/change-decision-log.md#d-6-no-type-means-one-run-of-the-default-set-with-todays-roster-rule), [D-21](artifacts/change-decision-log.md#d-21-hanconfigmd-can-attach-agents-to-a-review-type-and-extra-agents-stays-with-the-default-run)

### S-14: Step 3 title, Step 3.1, and the review-type announcement — Re-scoped

**Target state.** Step 3 is "Resolve the Review Type and Dispatch Review Agents". The type is resolved, its file read
and checked, and the announcement printed at the end of Step 1, before Step 2. Step 3.1 becomes "Confirm the review
type" and carries the resolved type forward. Steps 3.2 to 3.5 keep their numbers.

**Behavior.** Changing only in what is announced, and when: the run states its type, its purpose, and its focus text
before automated checks run, instead of a size band after them.

**Why.** Step 3.1 was the size classifier, and an announcement after Step 2 came too late to catch a mistyped token.

**Depends on.** S-5, S-7.

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-the-argument-grammar), [D-17](artifacts/change-decision-log.md#trivial-decisions)

### S-15: Run naming, from Step 8.6 to a new Step 3.0 — Moved

**Target state.** Step 3.0 resolves the slug and `{run_name}` before dispatch, by the slug rules Step 8.6 used, the
ticket slug for `work-ticket`, and the sanitizing rule. It prints the run folder and writes `ticket.md` for
`work-ticket`. Step 8.6 writes the report under `{run_name}.md` and no longer derives the slug.

**Behavior.** Preserving for a slug that already uses only lowercase letters, digits, and hyphens. Other characters are
now replaced. The type suffix is S-16's change.

**Why.** The working folder has to be named before agent output is filed into it.

**Decision.** [D-10](artifacts/change-decision-log.md#d-10-each-run-gets-its-own-working-folder-and-a-typed-report-name)

### S-16: Agent working files and the report name — Re-scoped

**Target state.** Every agent's output is filed in `{run_directory}`, a folder named for the run. A typed run's report
is named `code-review-{slug}--{type}.md`; the default run's report keeps `code-review-{slug}.md`.

**Behavior.** Changing. Agent working files move from `docs/{name}.md` into a per-run folder, and typed reports carry a
suffix. Settled by the recorded boundary ("so reviews can be parallelized").

**Why.** Fixed names collide across parallel runs and can be read stale.

**Depends on.** S-1, S-15, S-31.

**Migration.** Look for agent output under `docs/code-review-{slug}[--{type}]/` instead of `docs/`.

**Decision.** [D-10](artifacts/change-decision-log.md#d-10-each-run-gets-its-own-working-folder-and-a-typed-report-name)

### S-17: Step 1.6, ticket loading — Added

**Target state.** Step 1.6 runs only for `work-ticket`, in every git mode, before Step 2. It reads a local file with
`Read` and fetches any other reference with whatever tooling the installation provides, naming no tool. On failure it
prints the pinned message and waits for the operator's ticket text or instructions, then continues. `allowed-tools` is
unchanged.

**Behavior.** Preserving (only `work-ticket` loads a ticket).

**Why.** The type cannot do its job without the ticket, and the operator does not know in advance how each ticket is
fetched.

**Depends on.** S-5, S-15.

**Decision.** [D-11](artifacts/change-decision-log.md#d-11-the-skill-loads-the-ticket-with-whatever-tooling-the-installation-has-and-waits-on-the-user-when-it-cannot)

### S-18: `han-core:gap-analyzer` in the shared roster — Added

**Target state.** `gap-analyzer` has a roster-table row (output `ticket-gap-analysis.md`, series `GAP`), the pinned
prompt asking for a Requirement Map of every requirement, a rubric section, an exemption from the Step 7.2 reachability
gate, and a manual-sweep row.

**Behavior.** Preserving (no existing type dispatches it).

**Why.** It already compares an implementation against a requirements document.

**Depends on.** S-1, S-17.

**Decision.** [D-12](artifacts/change-decision-log.md#d-12-gap-analyzer-joins-the-shared-roster)

### S-19: `references/types/work-ticket.md` — Added

**Target state.** The `work-ticket` type always runs `han-core:gap-analyzer`, adds `han-core:test-engineer` when its
signal fires, sweeps Correctness and Testing by hand, briefs every agent to judge the change against the ticket, and
adds the Ticket Resolution section with its four verdicts. Its full text is the worked example in Target State.

**Behavior.** Preserving (new type).

**Why.** One of the operator's named types, and the one the request opens with.

**Depends on.** S-7, S-17, S-18.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-first-set-of-types), [D-13](artifacts/change-decision-log.md#d-13-work-ticket-adds-a-ticket-resolution-section)

### S-20: `default-swarm-size` docs and ADR 0001 — Re-scoped

**Target state.** `docs/configuration.md` names seven sizing-aware skills and no longer mentions code review in the
`default-swarm-size` section. `docs/sizing.md` no longer lists code review. ADR 0001 carries an appended note that
code review moved to review types; its decision is unchanged. The `default-swarm-size` text in `config-rule.md` is
unchanged; the rule's other changes are S-27 to S-29.

**Behavior.** Preserving (documentation of S-3).

**Why.** Three docs name code review as a consumer of the setting.

**Depends on.** S-3.

**Decision.** [D-9](artifacts/change-decision-log.md#d-9-code-review-stops-reading-default-swarm-size)

### S-21: Report template — Re-scoped

**Target state.** `references/template.md` carries a `**Review type:**` header line and one slot after Review
Recommendation that renders a type's `## Report section` when it is not `none`, wrapped in
`<!-- type-section:start -->` and `<!-- type-section:end -->` so the PR skill can carry it by position. Every other section, and their order,
is unchanged.

**Behavior.** Changing in one line: every report names its type and purpose, or `default`. Settled by D-18; the line
names only the run's own type.

**Why.** Two posted reviews of one PR need to be told apart, and `work-ticket` needs its verdict section.

**Depends on.** S-7.

**Decision.** [D-13](artifacts/change-decision-log.md#d-13-work-ticket-adds-a-ticket-resolution-section), [D-18](artifacts/change-decision-log.md#trivial-decisions)

### S-22: `han-github/skills/post-code-review-to-pr/SKILL.md` — Re-scoped

**Target state.** The PR-posting skill passes its argument string to `/code-review` verbatim, so a leading shipped or
configured type token selects that type. Its `argument-hint` carries the same type clause. Its posted body includes the
report's `**Review type:**` line and, uncut, whatever sits between the report's `<!-- type-section:start -->` and
`<!-- type-section:end -->` markers, which covers Ticket Resolution and any configured type's section. When `/code-review` ends without naming a report
path, it relays the last message and stops without posting.

**Behavior.** Changing for one case: free text that begins with a type token now runs that type. The posted body gains
one type line. Settled by the recorded boundary (Operator-Stated Scope item 1).

**Why.** The operator wants types available when posting to a PR.

**Depends on.** S-5, S-19, S-21.

**Decision.** [D-14](artifacts/change-decision-log.md#d-14-post-code-review-to-pr-passes-the-argument-string-through-and-carries-the-type-and-ticket-resolution)

### S-23: Step 4 manual review scope — Re-scoped

**Target state.** Step 4 applies the type's checklist categories, or the union of the default set's for the default
run, and always runs the YAGNI pass. The type's `## Instructions` and `## Severity` apply to Step 4 as they do to the
agents. Steps 2, 5, and 6 are unchanged.

**Behavior.** Preserving for the default run, whose union covers every category. New behavior for typed runs.

**Why.** A focused review should be focused in its manual pass too.

**Depends on.** S-7.

**Decision.** [D-15](artifacts/change-decision-log.md#d-15-step-4-is-scoped-by-type-steps-2-5-and-6-run-on-every-review)

### S-24: `scripts/review-types.bats` — Added

**Target state.** A Bats file beside `detect-review-context.bats` checks four agreements: every shipped type file
against its table row and its token in both `argument-hint` lines; every shipped type file's title and six sections in
order; every agent in a shipped roster against its roster-table row and prompt; and the default set's checklist union
against the thirteen bold category lines in `review-checklist.md`, matched by the pattern D-16 pins.

**Behavior.** Preserving (test only).

**Why.** These agreements span files and have already drifted once.

**Depends on.** S-1, S-6, S-7, S-8 to S-12, S-22.

**Decision.** [D-16](artifacts/change-decision-log.md#d-16-a-bats-check-holds-the-shipped-type-contract-together)

### S-25: Manual-only mode — Re-scoped

**Target state.** The manual-only disclosure lists the agents Step 3.2 selected by name, and the sweep rows carry no
size:

```
Manual-only mode: agent dispatch unavailable ({verbatim tool error, or "Agent tool not in allowed-tools"}).
Manual review is the primary path. Coverage absent: {every agent Step 3.2 selected, by name}. See the sweep mapping for what substitutes.
```

The absent-coverage list is still whatever Step 3.2 selected. The existing row for `## Extra Agents` ("nothing
substitutes") also covers attached agents and configured types' agents without a roster row.

**Behavior.** Preserving. The disclosure names the same agents, by name rather than as "junior-developer, security, and
every conditional agent".

**Why.** The disclosure text hard-codes today's always-run pair (UX-015).

**Depends on.** S-4, S-13.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-type-files-name-agents-everything-about-briefing-an-agent-stays-shared-and-keyed-by-agent), [D-8](artifacts/change-decision-log.md#d-8-one-default-severity-rule-replaces-the-size-ladder-and-a-type-may-override-it)

### S-26: Operator docs for code review and the PR skill — Re-scoped

**Target state.** `han-coding/docs/skills/code-review.md` documents review types, the default set, the default severity
rule and its per-type override, configured types and attached agents (pointing at `docs/configuration.md` for the
schema), the run folder, and `work-ticket`, and no longer documents sizes. `han-coding/README.md`,
`docs/skills/README.md`, and `docs/choosing-a-han-plugin.md` reuse its new summary line.
`han-github/docs/skills/post-code-review-to-pr.md` no longer describes a size-aware roster. `CHANGELOG.md` records
every Behavior Changes entry.

**Behavior.** Preserving (documentation).

**Why.** Every doc site in C-22 describes sizes.

**Depends on.** S-3 to S-25, S-27 to S-32.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-first-set-of-types), [D-8](artifacts/change-decision-log.md#d-8-one-default-severity-rule-replaces-the-size-ladder-and-a-type-may-override-it), [D-10](artifacts/change-decision-log.md#d-10-each-run-gets-its-own-working-folder-and-a-typed-report-name), [D-20](artifacts/change-decision-log.md#d-20-hanconfigmd-can-declare-review-types-that-han-does-not-ship)

### S-27: `## Code Review Types` in the config schema — Added

**Target state.** `han-core/references/config-rule.md` carries the five changes pinned word for word in Target State:
the Schema bullet, the path-resolution line, the keyed-setting Precedence paragraph, the extra-agents scoping sentence,
and the Degradation opening with its second exception. The twelve vendored copies match it byte for byte. The token
form, reserved names, and stop message live in code-review's `## Review Types` section. code-review's Step 1 reads the
declared file when its token is invoked, falling through to the personal file's line when the project's is unusable.

**Behavior.** Preserving. A config without the section behaves as today, and other skills ignore the section silently.

**Why.** The operator asked that teams be able to add review types Han does not ship.

**Depends on.** S-5, S-7.

**Decision.** [D-20](artifacts/change-decision-log.md#d-20-hanconfigmd-can-declare-review-types-that-han-does-not-ship)

### S-28: `## Code Review Type Agents` in the config schema — Added

**Target state.** `config-rule.md` names `## Code Review Type Agents` in its Schema bullet and says in Precedence
that both files' lines add together. code-review's `## Review Types` section defines the line format. Step 3.2
dispatches every attached agent on runs of that type, and on the default run joins agents attached to a default-set
type under the signal rule. A line whose token does not run is never read.

**Behavior.** Preserving. A config without the section behaves as today.

**Why.** The operator asked that a team be able to include its own agents in specific review types.

**Depends on.** S-13, S-27.

**Decision.** [D-21](artifacts/change-decision-log.md#d-21-hanconfigmd-can-attach-agents-to-a-review-type-and-extra-agents-stays-with-the-default-run)

### S-29: `## Extra Agents` on code review — Re-scoped

**Target state.** Code review considers `## Extra Agents` on the default run only, under today's signal rule. The
config rule's "Extra agents joining the pool" part says a skill may scope the list to some of its runs and must say
which in its own instructions. Every other skill is unchanged.

**Behavior.** Preserving. The default run behaves as today; typed runs are new.

**Why.** A typed report should stay on its one concern; per-type attachment (S-28) is how a team adds an agent to a
focused review.

**Depends on.** S-13, S-28.

**Decision.** [D-21](artifacts/change-decision-log.md#d-21-hanconfigmd-can-attach-agents-to-a-review-type-and-extra-agents-stays-with-the-default-run)

### S-30: Roster row for an agent without its own row — Added

**Target state.** The roster table's last row covers any agent a configured type or a config line names that has no row
of its own: full file list, output file `{agent name with ":" as "-"}.md`, series `X-{agent name with ":" as "-"}`, and
a generic prompt that names the change by the Step 1 mode wording. Step 7
classifies these findings by the calibration directive alone, and the Step 7.2 reachability gate applies.

**Behavior.** Preserving for shipped agents. An agent from `## Extra Agents` on the default run now has its output read
(C-23), which is new behavior on a path that read nothing before.

**Why.** Agents outside Han have no row, and today their output is never read.

**Depends on.** S-1.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-type-files-name-agents-everything-about-briefing-an-agent-stays-shared-and-keyed-by-agent)

### S-31: Agents hand back findings as a named file or raw output; the skill uses either — Re-scoped

**Target state.** Every Step 3.5 prompt ends with the D-22 sentence in place of "Write your output to …". When an
agent's final message names an existing file, Step 7.1 reads that file. Otherwise the skill writes the returned
message, in whatever format, to the agent's file in `{run_directory}`, or `Not covered in this run: {reason}` when the
agent failed. Step 7.1 reads only the sources recorded in this run and extracts findings from whatever format they hold.

**Behavior.** Changing. Findings from the three specialists that cannot write a file, and from extra agents on the
default run, now reliably reach the report. The operator accepted this ("option 1").

**Why.** Three shipped specialists cannot do what their prompt asks, extra agents' output is never read, and a rerun
must not read a stale file.

**Depends on.** S-1, S-15.

**Decision.** [D-22](artifacts/change-decision-log.md#d-22-agents-hand-back-their-findings-as-a-file-they-name-or-as-raw-output-and-the-skill-uses-either)

### S-32: `docs/configuration.md` for review types and attached agents — Re-scoped

**Target state.** `docs/configuration.md` documents `## Code Review Types` and `## Code Review Type Agents` in its
annotated example and its section reference, with the six-section type-file contract and the `pii-check` example, and
says `## Extra Agents` reaches only code review's default run.

**Behavior.** Preserving (documentation).

**Why.** It is the operator guide for the config file and carries the canonical annotated example.

**Depends on.** S-27, S-28, S-29.

**Decision.** [D-20](artifacts/change-decision-log.md#d-20-hanconfigmd-can-declare-review-types-that-han-does-not-ship), [D-21](artifacts/change-decision-log.md#d-21-hanconfigmd-can-attach-agents-to-a-review-type-and-extra-agents-stays-with-the-default-run)

## Behavior Changes

1. **Size words do nothing.** `/code-review large` runs the default review and prints a note that the word was ignored.
   `/code-review large file uploads` now reads all three words as focus text, where today it ran a Large review focused
   on "file uploads". Decided by your request to replace sizing (S-3).
2. **The project's default size setting stops affecting code review.** A project with `default-swarm-size: large` used
   to get every review at Large; now it gets the default rule, silently. Other skills still read the setting. Decided by
   your request and the confirmed scope (S-3, S-20).
3. **Minor suggestions change, and big changes block less often.** A review of one to three files now lists suggestions
   the change introduced, where it used to hide them. A review of more than ten files no longer lists old suggestions
   the change did not cause. A borderline issue on a change of more than ten files used to be a warning and is now a
   suggestion, so a PR review whose only warnings were borderline posts as a comment instead of requesting changes.
   Clear-cut problems still block. You chose this default, and a review type can set its own rule (S-4).
4. **A focused review skips security, without saying so.** `/code-review testing` runs no security check, and its
   report does not mention that. A bare `/code-review` still runs security. You decided this (S-8, S-13).
5. **Agent working files move into a folder per run, and typed reports get a suffix.** For example
   `docs/security-analysis.md` becomes `docs/code-review-my-branch/security-analysis.md`, and a testing review's report
   becomes `docs/code-review-my-branch--testing.md`. A bare review's report keeps its name, unless the old name held
   characters other than lowercase letters, digits, and hyphens. One folder per branch and type stays on disk. Decided by
   your goal of parallel reviews (S-15, S-16).
6. **Every report names its type, and so does the PR it is posted to.** A one-line header says which review type
   produced it (S-21, S-22).
7. **Posting to a PR can start a typed review.** If the text after `/post-code-review-to-pr` begins with a type name,
   such as "testing the retry logic", it now runs a `testing` review. Decided by your confirmed scope (S-22).
8. **The review states its type before it starts work.** The announcement moves to the end of Step 1, before automated
   checks, and shows the type's purpose and your focus text; a bare review lists the available types (S-14).
9. **Findings from every specialist reach the report.** A specialist either saves its findings to a file and says
   where, or hands them back directly, and the review uses whichever it gets. Findings from the three specialists that
   could not save files, and from your extra agents, now appear where they may have been silently missing. You chose
   this (S-31).

## Change Units

Units 2 through 8 should land on one branch before a release, because the docs in Unit 8 describe the finished state.
Each unit still leaves the skill runnable and `npm test` passing.

### Unit 1: Consolidate the roster table and file agent output from the skill

**What it does.** Merges the signal and slice tables into one roster table with output-file and series columns, points
Step 7.1 and the verification check at it, and replaces each prompt's "Write your output to" with the D-22 sentence.

**Delta entries.** S-1, S-2, S-31.

**How you know it worked.** A default review on a sample branch dispatches the same agents as before, and a change
touching module structure produces a filed `structural-analysis.md` with findings; the verification check now names
all 11 agents.

### Unit 2: Remove size and adopt the default severity rule

**What it does.** Deletes the size classifier and every size reading, adds the `retired-size` clause of the grammar
with its note, installs the default severity rule, and updates the sizing and configuration docs and ADR 0001. The
default roster is still today's, selected inside Step 3.2.

**Delta entries.** S-3, S-4, S-20, and the size wording in S-25.

**Ordering constraint.** After Unit 1, so the rewritten Step 3.3 and Step 7.1 land on the consolidated table.

**How you know it worked.** A search for `{size}`, `$size`, and `default-swarm-size` under
`han-coding/skills/code-review/` finds nothing; `/code-review large` prints the note and runs; `/code-review large file
uploads` prints no note and focuses on "large file uploads".

### Unit 3: Give each run its own folder

**What it does.** Moves slug resolution to Step 3.0 with the sanitizing rule, and files agent output into
`code-review-{slug}/`. Reports keep today's name, because no type exists yet.

**Delta entries.** S-15, S-16 (without the type suffix).

**Ordering constraint.** After Unit 1, which owns the output-file column and the filing rule.

**How you know it worked.** Two default reviews of different branches run at once and leave two separate folders; a
rerun where one agent fails shows that agent as not covered rather than reading its earlier file.

### Unit 4: Add the type mechanism and the five default-set types

**What it does.** Adds `## Review Types` with the five default-set rows, the type-file contract, the five type files,
the type clause of the grammar without `work-ticket`, the Step 1 announcement, type-based Step 3.1 and 3.2, the default
set, Step 4 scoping, the report's type line, the `--{type}` suffix, the named manual-only line, and the Bats check.

**Delta entries.** S-5 to S-14, S-16 (type suffix), S-21 (type line), S-23, S-24, S-25.

**Ordering constraint.** After Units 2 and 3. The five types land together because the default set needs all five to
reproduce today's roster, and Bats check 4 fails until they do. `work-ticket` has no row, token, or file yet, so Bats
check 1 passes.

**How you know it worked.** `npm test` passes, including `review-types.bats`. A bare `/code-review` dispatches the same
agents as before Unit 4. `/code-review testing` prints its announcement before Step 2, dispatches only the test and
edge-case agents, and writes `code-review-{slug}--testing.md`.

### Unit 5: Add `work-ticket`

**What it does.** Adds the `work-ticket` row and `argument-hint` token, its grammar clause and stop message, Step 1.6,
the `gap-analyzer` rows, the Step 7.2 exemption, the template's report-section slot, and the `work-ticket` type file.

**Delta entries.** S-17, S-18, S-19, S-21 (report-section slot).

**Ordering constraint.** After Unit 4.

**How you know it worked.** `/code-review work-ticket docs/tickets/x.md` on a branch that meets half the ticket reports
"Partially resolved" with a row for every requirement, met ones included. `/code-review work-ticket missing.md` prints
the pinned message and waits; pasting the ticket's text continues the review. A run where `gap-analyzer` fails reports
"Not verified".

### Unit 6: Configured types and attached agents

**What it does.** Adds `## Code Review Types` and `## Code Review Type Agents` to the canonical config rule and re-syncs
its twelve copies, scopes `## Extra Agents` to code review's default run, adds the roster table's last row and generic
prompt, and teaches Step 1 and Step 3.2 to read both sections.

**Delta entries.** S-27, S-28, S-29, S-30, and the configured-type parts of S-5, S-13, and S-14.

**Ordering constraint.** After Unit 4, which owns the contract and the grammar. Before Unit 7, so the PR skill's hint
can mention configured types.

**How you know it worked.** A project config declaring `pii-check` with the worked example file runs
`/code-review pii-check`, dispatches the attached and rostered agents, applies its severity sentence, and writes
`code-review-{slug}--pii-check.md`. Pointing the token at a missing file stops with the pinned message. A copy check
(`for f in */references/config-rule.md; do cmp han-core/references/config-rule.md "$f"; done`) prints nothing.

### Unit 7: Pass types through `post-code-review-to-pr`

**What it does.** Passes the argument string through verbatim, matches the argument hint, carries the type line and
Ticket Resolution, and stops cleanly when code review ends without a report.

**Delta entries.** S-22.

**Ordering constraint.** After Units 5 and 6. Bats check 1 now covers the PR skill's hint.

**How you know it worked.** `/post-code-review-to-pr testing` drafts a body from a `--testing` report with the type
line; a `work-ticket` run with a bad path waits for the ticket inside the PR skill's run and posts once the review
completes.

### Unit 8: Update the operator docs

**What it does.** Rewrites the long-form code-review doc, the scent lines that reuse its summary, the PR skill's doc,
`docs/configuration.md`, and the CHANGELOG entry listing every Behavior Changes item.

**Delta entries.** S-26, S-32.

**Ordering constraint.** Last.

**How you know it worked.** A search for "size-aware", "size-scaled", and `/code-review medium` across `han-coding/`,
`han-github/`, and `docs/` finds nothing outside `docs/plans/` and `CHANGELOG.md` history.

## Risks

- **A focus word that matches a type.** `/code-review testing the retry path` used to be a broad review focused on
  testing; it becomes a `testing` review. A configured token adds more such words. The announcement shows this before
  Step 2 runs. Blast radius: one run.
- **Parallel runs share automated checks.** Two typed reviews started at once both run Step 2's builds and tests in one
  working tree, which can collide on build output, ports, or test databases and surface failures that are not in the
  change (JD-012, R6). The docs say to expect this; scoping Step 2 by type is deferred.
- **Unit 4 is large.** It touches `SKILL.md`, `agent-dispatch.md`, the template, and six new files at once. The Bats
  check and a before-and-after comparison of the default roster are the early signals.
- **A fetch that returns a sign-in page.** A tracker that requires sign-in can return a login page, and the "no ticket
  content" check is a judgment the model makes. A false pass would verify the change against a login page. The
  `ticket.md` copy in the run folder lets the operator see what was checked, and the Ticket Resolution table lists the
  requirements it found.
- **The ticket copy lands in the output folder.** `ticket.md` sits under `docs/` by default and can be committed with
  the report, carrying ticket text into the repository (R4). Agent working files carry the same exposure today.
- **A configured type's instructions reach every agent prompt.** `.han/config.md` is trusted as config. A project file
  changed on a branch under review changes what a review of that branch is told, but only when that token is invoked.
- **An agent that writes a file elsewhere and returns only a summary.** If it does not name the file, the review uses
  the summary, which may carry fewer findings than the file. The prompt names the path to write to, which is the
  mitigation.
- **The type-file contract is read by a model, not a parser.** A malformed file could be read loosely instead of
  stopping. The Bats check catches structure in shipped files; configured files rely on Step 1's section check, which
  cannot catch a misread value.
- **Silent loss of security on focused runs** is accepted by the operator, and is listed here so a reviewer of the
  plan sees it.

## Deferred (YAGNI)

- **More shipped types (`data`, `resilience`, and others).** Reopen at the operator's planned refinement after the
  first build.
- **An input slot for configured types**, like `work-ticket`'s ticket. No configured type has asked for one. Reopen
  when a team's type needs an input beyond focus text.
- **A type registry or index file.** It would duplicate the `## Review Types` table. Reopen if `SKILL.md` can no longer
  link every shipped type file.
- **Several named types in one invocation.** Parallel runs deliver this, and the default already combines types. Reopen
  when an operator records friction from launching runs separately.
- **A configurable default set.** Not requested. Reopen on request.
- **Scoping Steps 2, 5, and 6 by type.** Reopen when duplicate automated-check or doc findings across parallel typed
  reports are reported as friction, or parallel Step 2 runs are seen to collide.
- **Naming a fetch method per tracker.** The operator asked the skill to assume nothing about fetching. Reopen when
  operators ask for a named method with a second tracker in use.
- **A `help` token that lists types.** The default announcement lists them. Reopen when operators ask how to discover
  types.
- **Cleaning up old run folders.** Reopen when operators ask for it.

## Cut for Scope

- **Hardening the branch-context markers against content that contains the end marker**
  ([C-9](artifacts/current-state-findings.md#c-9-untrusted-content-handling-is-explicit-and-reusable)). It would stop a
  PR body from closing the "untrusted" block early. The recorded scope covers replacing sizing with types, not
  hardening Step 1.5 (`artifacts/scope-boundary.md`, Stated Scope). You can reinstate it.

## Open Items

- **How the harness binds `arguments:`** (non-blocking). The grammar parses the raw string so the plan does not depend
  on it; a probe run during Unit 4 settles it.

## Review Findings

Two review rounds ran, the cap for this team size. Round 1 had the junior developer (JD), the user-experience designer
(UX), and the risk analyst (R). Round 2 had the junior developer (JD2), on the configured-types design added after
round 1. After merging findings that said the same thing, every finding was settled on the evidence or by the
operator; none is left open apart from the Open Items above.

| Finding | What it said | Resolution |
| --- | --- | --- |
| R1 | Three specialists cannot write the file their prompt names | Verified (C-23); escalated; the operator chose a named file or raw output (D-22) |
| JD-001 | A pending marker needs a read before it can be overwritten | Marker dropped; D-22 files output from the skill |
| JD-002, R2 | The ticket verdict says Resolved when nothing checked it | "Not verified" verdict and row-based rule (D-13); Requirement Map of every requirement (D-12) |
| JD-003 | The PR outcome is not unchanged at former Large | Escalated; the operator kept the default and added a per-type override (D-8) |
| JD-004 | `Required input` has one user and two homes | Section removed; ticket intake lives in Step 1.6 (D-3, D-11) |
| JD-005 | Type tokens live in four places | The grammar refers to the table; Bats covers both hints (D-7, D-16) |
| JD-006 | Bats category matching is not pinned | Pattern pinned (D-16) |
| JD-007, UX-011, R7 | Run names can collide, and URL slugs are unsanitized | `--` separator and sanitizing rule (D-10) |
| JD-008 | Extra agents on typed runs are undefined | Escalated; the operator chose per-type agents and configured types (D-20, D-21) |
| JD-009 | Do member types' sections apply on the default run | No; the default run skips them (D-6) |
| JD-010 | S-2 is a behavior change | Relabeled Changing (minor) |
| JD-011, R4 | A general fetch tool widens every run | Escalated; the operator said to assume no fetch method (D-11) |
| JD-012, R6 | Parallel runs share Step 2 | Added to Risks; scoping deferred |
| JD-013 | `arguments: type` is unused | Line removed (D-7) |
| JD-014, R9 | Value forms are inconsistent | Contract table uses one form per section (D-3) |
| UX-001 to UX-003 | The announcement is late and hides a mistyped word | Moved to the end of Step 1, with purpose, focus, and the unmatched word (D-7) |
| UX-004 | The type line does not reach the PR | Carried in the posted body (D-14) |
| UX-005, UX-006 | A size word is stripped from real focus text | Dropped only alone or before a type token; grammar order pinned (D-19, D-7) |
| UX-007 to UX-010 | Stop messages conflict and reject ticket IDs | One stop for a missing reference; any reference is tried; the failure message waits (D-7, D-11) |
| UX-012, UX-013 | The run folder is invisible | Printed at Step 3.0 and named at Step 10 (D-10) |
| UX-014 | Types are hard to discover | The default announcement lists them; a `help` token is deferred |
| UX-015 | The manual-only text is unpinned | Pinned with agent names (S-25) |
| UX-016, R5 | A Mode C path named like a type | Written `./name` (D-7) |
| R3 | The ticket is written before the folder exists | Written at Step 3.0; a failed load leaves no folder (D-11) |
| R8 | Behavior changes are accepted | Listed under Behavior Changes |
| Unit 4/5 sequencing | Unit 4 named `work-ticket` before its file existed | `work-ticket` row, token, and clause moved to Unit 5 |
| Unit 2 parse | The size note needs a parse Unit 4 adds | Unit 2 adds the `retired-size` clause |
| JD2-001 | A `## Severity` sentence that only adds to the rule leaves the rest unspecified | The rule is a pinned two-line slot; a type's text replaces both lines; example rewritten (D-8) |
| JD2-002 | The configured-type stop differs from `writing-voice` and skips fall-through | Kept as a stop, with the reason; a broken project line falls through to the personal file (D-20) |
| JD2-003 | The config rule has no wording for per-key precedence or a third path | Five config-rule changes pinned word for word (Target State) |
| JD2-004 | Code-review details would be copied into twelve plugins | The rule carries only the schema bullet, precedence, and degradation; details live in code-review; a `cmp` loop checks copies (D-20) |
| JD2-005 | An attached-agent note would fire in projects without that type | A line is read only when its token runs (D-21) |
| JD2-006 | Attached agents on the default run: gated or not | Gated by today's `## Extra Agents` signal rule (D-6, D-21) |
| JD2-007 | The generic prompt assumes branch mode; EXT IDs collide | Mode wording reused; per-agent series (D-1) |
| JD2-008 | `{report_directory}` is undefined | Defined; the run folder sits beside the report (D-10) |
| JD2-009 | A configured type's report section never reaches the PR | The type section is wrapped in markers and carried by position (D-14) |
| JD2-010 | D-22 is pending, but other decisions rely on it | Dependents listed; the operator settled D-22 |
| JD2-011 | A partial Requirement Map can say Resolved | The map states a requirement count; fewer rows cannot be Resolved; GAP-to-WARN pinned (D-12, D-13) |
| JD2-012 | Step 1's config dependency and the word `default` | The parse uses the config read at skill start; `default` selects the default run (D-7) |
