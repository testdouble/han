# Change Plan: Investigation Types

## Why This Change

`/investigate` assumes every investigation is a bug, and many of the operator's investigations are not. In their words:
"a lot of the investigation i do is not centered around bugs, but rather investigation into how the code works and what
options are available for doing work." This is a new requirement that the current structure cannot absorb, because the bug
framing is written into most of its steps. The source is the operator's own request, recorded
word for word in `artifacts/scope-boundary.md`.

## What Changes, In One Paragraph

After this change, `/investigate` runs one of three investigation types: `bug`, `how-it-works`, or `available-options`.
Each type is a small data file that says how to recognize it, which agents to dispatch, what the analysis produces, how
the validator is briefed, who the report is for, and how the run ends. Each type has its own report template. The skill
keeps the steps every type shares: reading config, gathering numbered evidence, adversarial validation, the readability
passes, and the review loop. With no type named, the skill picks one from the question and says which it picked and why.
With a type named, it checks the type fits the question, and asks before switching when it clearly does not. A `bug` run
writes the same report sections it writes today.

## Current State

The bug framing runs through most of `SKILL.md`. The shared parts (config, evidence rule, E-series (the numbered evidence items), validator mechanics,
readability passes) are already type-agnostic, but nothing separates them from the bug-specific parts
([C-1](artifacts/current-state-findings.md#c-1-the-bug-framing-runs-through-every-step-of-skillmd-with-no-seam)). The
skill's own description sends "how something works" and "options" to `research`, which claims both
([C-2](artifacts/current-state-findings.md#c-2-the-description-sends-how-something-works-and-options-to-research)).

Three properties block the operator's goal directly:

- **The argument has no parsing rule.** It is one free-text blob, so there is nowhere for a type token to go
  ([C-3](artifacts/current-state-findings.md#c-3-the-argument-is-one-free-text-blob-with-no-parsing-rule)).
- **One template serves one shape.** The Evidence, Validation, and Confidence sections are generic, but the title,
  Summary, Problem Statement, Root Cause Analysis, and Planned Fix are bug-only
  ([C-5](artifacts/current-state-findings.md#c-5-one-template-with-shared-carriers-and-bug-only-sections)).
- **The roster and validator are symptom-keyed.** Specialist prompts carry `{symptom}`
  ([C-6](artifacts/current-state-findings.md#c-6-the-specialist-roster-its-triggers-and-its-prompts-are-inline-and-symptom-keyed)),
  `evidence-based-investigator` runs symptom-first protocols
  ([C-7](artifacts/current-state-findings.md#c-7-evidence-based-investigator-is-bug-framed-codebase-explorer-and-behavioral-analyst-are-neutral)),
  and `adversarial-validator` expects a planned fix
  ([C-8](artifacts/current-state-findings.md#c-8-adversarial-validator-requires-a-planned-fix-and-mandates-challenging-it)).

Around the skill, the Confluence wrapper rejects non-bug requests and restates today's section list
([C-12](artifacts/current-state-findings.md#c-12-investigate-to-confluence-restates-the-bug-only-shape-and-rejects-non-bug-requests)),
the evals cover only bug triggering
([C-13](artifacts/current-state-findings.md#c-13-evals-assert-root-cause-and-cover-only-bug-triggering)), and the docs
describe the skill as bug-only
([C-14](artifacts/current-state-findings.md#c-14-other-surfaces-describe-investigate-as-bug-only)). Nothing
machine-checks any cross-file agreement in the skill today.

One finding needs a correction. C-11 says nothing implements on approval. That holds for the skill's own text, but the
skill runs inline in the operator's session, so an operator who replies "approve" gets the fix built by that same
session. The approve-to-implement ending is real behavior and is kept for `bug`
([D-9](artifacts/change-decision-log.md#d-9-the-stop-per-type)).

## Target State

`SKILL.md` owns the flow every investigation shares. A type file owns everything that differs by type. A template owns
the type's report layout. The skill reads the type file's sections at fixed steps, and the only place it names a type
token is the `## Investigation Types` table
([D-1](artifacts/change-decision-log.md#d-1-one-type-file-per-type-read-at-fixed-steps)).

### What `SKILL.md` owns

- The config read, the evidence rule, and the lazy-create rule, as today.
- A `## Investigation Types` section holding the only list of shipped tokens. Row order is the tie-break order, and the
  last row is the default when nothing matches
  ([D-4](artifacts/change-decision-log.md#d-4-detection-tie-break-and-the-fit-check)):

  ```markdown
  | Token               | File                                                                              | Purpose                                                         |
  | ------------------- | --------------------------------------------------------------------------------- | --------------------------------------------------------------- |
  | `bug`               | [references/types/bug.md](./references/types/bug.md)                              | Find the root cause of a failure and plan the fix               |
  | `available-options` | [references/types/available-options.md](./references/types/available-options.md) | Compare the ways a piece of work could be done in this codebase |
  | `how-it-works`      | [references/types/how-it-works.md](./references/types/how-it-works.md)           | Explain how this codebase behaves, with cited evidence          |
  ```

- Argument parsing, type resolution, and output resolution (Step 1).
- Evidence gathering: dispatch what the type's `## Dispatch` names, then compile the E-series.
- The `## Extra Agents` rule, reworded: an extra agent joins when the resolved type and the question match its stated
  specialty.
- Validation mechanics: the brief form, V-N items, Adjustments Made, Confidence Assessment.
- The readability-guidance invocation and the readability-editor pass, with the audience taken from the type file.
- The stop: the type's `## Stop` text, followed by one shared line generated from the table.

### The argument grammar

([D-3](artifacts/change-decision-log.md#d-3-the-argument-grammar))

```
args       := [ type-token ] question [ out-path ]
type-token := a Token from ## Investigation Types; only the first whitespace-separated token; case-insensitive;
              one trailing ":" is stripped before matching; never inside quotes
question   := the remaining text, verbatim, as $question
out-path   := the final token, when it ends in ".md" and does not name a file that already exists; removed from $question
```

A final `.md` token that names an existing file stays in `$question`: it is the subject, and the run never writes over
it. When `$question` is empty and the conversation holds no earlier message describing a problem or question, the run
stops with the usage message, built from the table at run time:

```
investigate needs a question or symptom. No investigation ran.
Usage: /investigate [type] <question> [report path ending in .md]
Types:
- bug: Find the root cause of a failure and plan the fix
- available-options: Compare the ways a piece of work could be done in this codebase
- how-it-works: Explain how this codebase behaves, with cited evidence
```

| Invocation                                                               | Type                                  | `$question`                                    | Out path                   |
| ------------------------------------------------------------------------ | ------------------------------------- | ---------------------------------------------- | -------------------------- |
| `/investigate bug checkout returns 500 after the coupon change`          | `bug`, named                          | `checkout returns 500 after the coupon change` | none                       |
| `/investigate bug: cart total off by one cent`                           | `bug`, named (colon stripped)         | `cart total off by one cent`                   | none                       |
| `/investigate how does the retry queue pick a backoff`                   | `how-it-works`, detected              | the whole string                               | none                       |
| `/investigate how-it-work retry queue`                                   | not a token; detected `how-it-works`  | the whole string                               | none                       |
| `/investigate available-options add rate limiting docs/inv/rate-limit.md` | `available-options`, named            | `add rate limiting`                            | `docs/inv/rate-limit.md`   |
| `/investigate why does the generator rewrite ./CHANGELOG.md`             | `bug`, detected                       | the whole string                               | none (the file exists)     |
| `/investigate how-it-works login throws 500 since Tuesday`               | named `how-it-works`; fit check asks  | `login throws 500 since Tuesday`               | none                       |

### Type resolution

([D-4](artifacts/change-decision-log.md#d-4-detection-tie-break-and-the-fit-check))

Detection is a judgment the model makes against each type's `## Detection signals`. The signals are guidance written as
phrases, not literal strings to match.

1. **No token.** Decide which types' signals the question meets. When more than one does, the earliest row in the table
   wins. When none does, the last row (`how-it-works`) is the type, because it presumes neither a defect nor a planned
   change. The run proceeds without asking.
2. **Token named.** The fit check fails only when the question clearly meets another type's signals and none of the
   named type's. On failure, ask once with `AskUserQuestion`:
   - Question: `You named {given}, but "{the operator's words that matched}" reads as {suggested}. Which type should this run use?`
   - Options: `{suggested}` with its Purpose cell as the description, and `{given} (as named)` with its Purpose cell.
   - When more than one other type matches, `{suggested}` is the earliest such row.
   - A free-text answer naming a token uses that token. Any other answer, or a dismissal, keeps the named type.

Once the type and the report path are settled, the run prints this block before any dispatch:

```
**Investigation type:** {token}: {Purpose cell}
**Chosen because:** {source}
**Question:** {$question}
**Report:** {path}
Other types: {every other token, comma-separated}. To switch, re-run as /investigate {token} <question>.
```

```
source := "you named it"
        | "detected from \"" {the operator's words that matched} "\""
        | "detected from \"" {words} "\"; it also read as " {runner-up token}
        | "no type signal matched, so it defaulted to the last type"
        | "you switched from " {given} " when asked"
        | "kept as you named it when asked"
```

Example:

```
**Investigation type:** how-it-works: Explain how this codebase behaves, with cited evidence
**Chosen because:** detected from "how does the retry queue pick"
**Question:** how does the retry queue pick a backoff
**Report:** docs/investigations/investigate-retry-queue-backoff.md
Other types: bug, available-options. To switch, re-run as /investigate {token} <question>.
```

### The type-file contract

([D-2](artifacts/change-decision-log.md#d-2-the-type-file-contract))

Each type file is `references/types/{token}.md`, titled `# Investigation type: {token}`, with exactly these six `##`
sections in this order, outside any fence. Every section has content. The type's purpose lives only in the table.

| Section                | Value form                                                                                                                                                  | Read at       |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| `## Detection signals` | one or more bullets, `- {phrase}`                                                                                                                           | Step 1        |
| `## Dispatch`          | a numbered list, one entry per agent: ``N. `{plugin}:{agent}` ({count}, {when}): "{prompt}"``, where `{count}` is a number or a number followed by `+`, `{when}` is `always` or `when {trigger}`, and `{question}` is the prompt's only placeholder | Step 2        |
| `## Analysis`          | a numbered list of steps run between the evidence summary and validation, each naming in backticks the template heading it fills                            | Step 3        |
| `## Validation brief`  | exactly three bullets, in this order: `- Root cause analysis: {text}`, `- Planned fix: {text}`, `- Attack focus: {text}`                                     | Step 4        |
| `## Audience`          | one sentence naming the reader                                                                                                                              | Steps 3 and 5 |
| `## Stop`              | one blockquote line, with `{path}` as its only placeholder                                                                                                  | Step 6        |

A worked example for `bug`, with the prompts abridged:

```markdown
# Investigation type: bug

## Detection signals

- something fails, errors, crashes, hangs, or times out
- something returns a wrong result, or behaves differently from what was expected
- something stopped working, or regressed after a change
- an error message, stack trace, log line, or failing test is quoted

## Dispatch

1. `han-core:evidence-based-investigator` (2+, always): "Investigate this from one angle only, the one you are assigned (the error path, the data flow, or the recent changes): {question}. ..."
2. `han-core:concurrency-analyst` (1, when the question involves intermittent failures, races, deadlocks, ordering, stale reads, timeouts, dropped messages, or load): "Investigate the concurrency and async behavior of the code paths implicated by this: {question}. ..."
3. `han-core:behavioral-analyst` (1, when the question involves data transformed wrong, values lost between modules, swallowed errors, unexpected state, or bad data at an integration boundary): "Trace the data flow for the code paths implicated by this: {question}. ..."
4. `han-core:data-engineer` (1, when the question involves wrong data in the database, slow queries, N+1, lock contention, migrations, unbounded scans, lost data, referential integrity, or isolation levels): "Investigate the schema, queries, migrations, and data-access code implicated by this: {question}. ..."

## Analysis

1. Write `Problem Statement`: symptoms, expected behavior, conditions, impact.
2. Write `Root Cause Analysis`: a one-to-three sentence root cause, then the detailed causal chain citing E-items.
3. Resolve coding standards from CLAUDE.md's Project Discovery section, project-discovery.md, or `docs/`, `docs/adr/`, `docs/coding-standards/`, then write `Coding Standards Reference` and `Planned Fix`.

## Validation brief

- Root cause analysis: the Root Cause Analysis section
- Planned fix: the Planned Fix section, with every file change
- Attack focus: break the fix, and the causal chain from root cause to symptom

## Audience

The engineer who will implement the fix and may be paged on the bug.

## Stop

> Report written to {path}. No code was changed. Reply "approve" to have this session implement the Planned Fix, or reply with corrections to revise the report.
```

### Per-type rosters

([D-5](artifacts/change-decision-log.md#d-5-per-type-rosters-reuse-existing-agents))

| Type                | Always                                                       | When relevant                                                                                        |
| ------------------- | ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------- |
| `bug`               | `han-core:evidence-based-investigator`, two or more          | `concurrency-analyst`, `behavioral-analyst`, `data-engineer`, on today's triggers                    |
| `how-it-works`      | `han-core:codebase-explorer`, `han-core:behavioral-analyst`  | `structural-analyst` (organization, dependencies, history), `concurrency-analyst`, `data-engineer`   |
| `available-options` | `han-core:codebase-explorer`, `han-core:structural-analyst`  | `behavioral-analyst`, `data-engineer`, `concurrency-analyst`                                          |

`evidence-based-investigator` stays with `bug`, because its protocols start from a symptom. `research-analyst` joins no
type: questions that need the open web or prior art go to `/research`, per the agreed split.

### Validation per type

([D-6](artifacts/change-decision-log.md#d-6-validation-maps-inputs-in-the-brief-the-agent-is-unchanged))

`han-core:adversarial-validator` is unchanged. Step 4 builds its brief in this form, so the agent receives its three
named inputs and the type's focus:

```
This is a {token} investigation. {Purpose cell}.

Evidence summary:
{every E-item, verbatim, with code}

Root cause analysis (for this investigation type, this is {Root cause analysis text}):
{that section, verbatim}

Planned fix (for this investigation type, this is {Planned fix text}):
{that section, verbatim}

Attack focus: {Attack focus text}
```

| Type                | Root cause analysis slot      | Planned fix slot                                                         | Attack focus                                                                      |
| ------------------- | ----------------------------- | ------------------------------------------------------------------------ | --------------------------------------------------------------------------------- |
| `bug`               | Root Cause Analysis           | Planned Fix                                                              | Break the fix and the causal chain                                                |
| `how-it-works`      | the Answer and its flow trace | the Answer's coverage claim: the entry points and paths it calls complete | Find a caller, path, or input the explanation misses or gets wrong                |
| `available-options` | Current State and Constraints | the recommended option and its change surface                            | Break the recommendation; test whether a rejected option rests on a false premise |

### Per-type reports

([D-7](artifacts/change-decision-log.md#d-7-per-type-report-templates-with-a-shared-fragment))

Each type has `references/templates/{token}.md`. The Evidence Summary and Validation Results sections (with Validation
Results' `###` subsections Counter-Evidence Investigated, Adjustments Made, and Confidence Assessment) live once, in
`references/evidence-and-validation.md`. Each template carries exactly one line
`<!-- shared: evidence-and-validation.md -->`. When writing the report, the skill writes the fragment's sections in that
line's place, and the lazy-create rule applies to them as to every other section. Every template's second line is
`**Investigation type:** {token}: {Purpose cell}`.

| Type                | Title                         | Summary fields                                                                          | `##` sections, in order                                                                                                    |
| ------------------- | ----------------------------- | --------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `bug`               | `# Investigation: {title}`    | Root Cause, Fix, Why Correct, Validation Outcome, Remaining Risks                       | Summary, Problem Statement, Root Cause Analysis, Planned Fix, shared fragment, Coding Standards Reference                  |
| `how-it-works`      | `# How It Works: {subject}`   | Answer, Entry Points, Validation Outcome, Unverified Paths                              | Summary, Question, Answer, Key Components, shared fragment                                                                 |
| `available-options` | `# Available Options: {goal}` | Recommendation, Options Considered, Deciding Factor, Validation Outcome, Remaining Risks | Summary, Goal and Constraints, Current State, Options, Comparison, Recommendation, shared fragment, Coding Standards Reference |

`{title}`, `{subject}`, and `{goal}` are a short noun phrase the skill writes from `$question`. The `how-it-works`
Answer opens with a one-sentence answer, then a numbered walkthrough of the flow citing E-items. Key Components is a
table with the columns Component, File, and Role. The `available-options` Options section holds one
`### Option N: {name}` block per option, each with How it works, Change surface, Fits existing patterns, and Costs and
risks. Comparison is a table of options against the constraints. Recommendation names what would change the call.

The `bug` template is today's `template.md` with the shared sections moved into the fragment and the type line added,
so a bug report carries the same sections in the same order.

### Output location and the stop

([D-8](artifacts/change-decision-log.md#d-8-output-location-keeps-the-documented-contract))

The report path resolves in config-rule order:

1. An out-path from the argument.
2. A configured `output-directory`, with the file written directly beneath it.
3. Otherwise, as the long-form doc promises today, the skill proposes a path and writes there without asking:
   `{documentation root}/investigations/investigate-{slug}.md`. The documentation root comes from CLAUDE.md's
   `## Project Discovery` section, then `project-discovery.md`, then `docs/` when it exists, then the repository root.

The slug is two to six words from `$question`, lowercase, in `[a-z0-9-]`. When the resolved file already exists, the
skill appends `-2`, `-3`, and so on. The path appears in the announcement, so the operator sees it before any agent
runs. "The plan file" becomes "the report file" throughout.

The run ends by printing the type's `## Stop`, then one shared line built from the table
([D-9](artifacts/change-decision-log.md#d-9-the-stop-per-type)):

- **`bug`:** `Report written to {path}. No code was changed. Reply "approve" to have this session implement the Planned Fix, or reply with corrections to revise the report.`
- **`how-it-works`:** `Report written to {path}. No code was changed. Reply with corrections to revise the report. To change this code next, run /han-planning:plan-a-change with this report; to build new behavior on it, run /han-planning:plan-a-feature.`
- **`available-options`:** `Report written to {path}. No code was changed. Reply with corrections to revise the report. To plan the recommended option, run /han-planning:plan-a-change (restructuring existing code) or /han-planning:plan-a-feature (new behavior) with this report; to weigh prior art beyond this codebase, run /han-research:research.`
- **Shared line:** `Wrong kind of report? Re-run as /investigate {other token} <question>, where {other token} is one of: {every other token}.`

`allowed-tools` adds `Write` and `Skill`. `AskUserQuestion` stays out of it, because listing it makes the question
return empty answers without being shown
([D-10](artifacts/change-decision-log.md#d-10-allowed-tools)).

### The guarding test

`han-coding/skills/investigate/scripts/investigation-types.bats` holds the cross-file agreements
([D-11](artifacts/change-decision-log.md#d-11-a-bats-test-holds-the-token-list-together)). It resolves files from
`$BATS_TEST_DIRNAME/..`, as `review-types.bats` does, and reuses its fence-aware heading reader.

1. **Tokens agree in every direction.** The set of `references/types/*.md` basenames, the set of table tokens, the set
   of `references/templates/*.md` basenames, and the set of backticked tokens in the `argument-hint` are all equal.
   Every table row matches
   ``^\| `{token}` +\| \[references/types/{token}\.md\]\(\./references/types/{token}\.md\) +\|`` with variable spacing.
   Each token appears backticked in the `description`.
2. **Type files follow the contract.** Each file's first line is `# Investigation type: {token}`. Its `##` headings
   outside fences are exactly the six, in order. `## Detection signals` has at least one `- ` line. Every numbered line
   under `## Dispatch` matches ``^[0-9]+\. `[a-z0-9-]+:[a-z0-9-]+` \([0-9]+\+?, (always|when .+)\): ".+"$``, and there is
   at least one. Every backticked heading under `## Analysis` is a `##` heading in `templates/{token}.md`.
   `## Validation brief` has exactly three `- ` lines, starting `- Root cause analysis: `, `- Planned fix: `, and
   `- Attack focus: `, in that order. `## Stop` has exactly one line starting `> `, and its only `{...}` is `{path}`.
3. **Templates carry the shared fragment.** `references/evidence-and-validation.md` exists and has the `##` headings
   Evidence Summary and Validation Results. Every template has exactly one `<!-- shared: evidence-and-validation.md -->`
   line, and its second non-blank line starts `**Investigation type:** {token}: `.
4. **The `bug` report keeps today's shape.** `templates/bug.md`, with the marker replaced by the fragment's headings, has
   this `##` sequence: Summary, Problem Statement, Root Cause Analysis, Planned Fix, Evidence Summary, Validation
   Results, Coding Standards Reference.
5. **The extraction is complete.** `references/template.md` does not exist, and no file under `han-coding/` or
   `han-atlassian/` links to it. `SKILL.md` contains no `{symptom}`. `SKILL.md` names each of the six type-file
   sections.
6. **The research boundary holds.** `han-research/skills/research/SKILL.md`'s description does not contain
   `how something works`.

Classification quality, the grammar, the announcement, and the fit-check wording are not things a Bats test can hold.
Only the evals reach them.

## Surface Delta

`Behavior` below is about what a person running `/investigate` sees. Doc and test entries say `Changing (docs and tests
only)` when they change what a reader reads but not what a run does.

### S-1: `references/types/{bug,how-it-works,available-options}.md` — Added

**Target state.** Three type files exist, each following the type-file contract. `bug.md` carries today's inline bug
content: the symptom-first approach, two or more investigators on distinct angles, the three specialist triggers with
`{question}` in place of `{symptom}`, the root-cause and fix analysis, today's audience, and the approve-to-implement
stop.

**Behavior.** Preserving for `bug`: the same agents run on the same triggers and the same sections are written. The two
new types are the requested addition.

**Why.** The bug framing sits in six steps with no seam
([C-1](artifacts/current-state-findings.md#c-1-the-bug-framing-runs-through-every-step-of-skillmd-with-no-seam)).

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-one-type-file-per-type-read-at-fixed-steps),
[D-2](artifacts/change-decision-log.md#d-2-the-type-file-contract),
[D-5](artifacts/change-decision-log.md#d-5-per-type-rosters-reuse-existing-agents)

### S-2: `SKILL.md` `## Investigation Types` — Added

**Target state.** A section in `SKILL.md` holds the token table, the only list of shipped tokens, whose row order is the
tie-break order and whose last row is the default. It also holds the type-file contract.

**Behavior.** Preserving. It adds a list; it changes no existing step.

**Why.** The token list must agree across the table, type files, templates, `argument-hint`, and `description`
([C-9](artifacts/current-state-findings.md#c-9-the-code-review-type-pattern-and-what-does-not-transfer)).

**Depends on.** S-1.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-one-type-file-per-type-read-at-fixed-steps),
[D-4](artifacts/change-decision-log.md#d-4-detection-tie-break-and-the-fit-check)

### S-3: `SKILL.md` Step 1, parsing, type resolution, and the announcement — Added

**Target state.** Step 1 parses the argument per the grammar, resolves the type by detection or fit check, asks once on
a clear mismatch, resolves the report path, and prints the announcement block before any dispatch.

**Behavior.** Changing, as requested. A question that meets no type's signals now runs as `how-it-works`, where today
it runs as a bug. A leading type token and a trailing new `.md` path are removed from the question the agents see.
Every run, `bug` included, now opens with the announcement block.

**Why.** There is no parsing rule and the classification is held only in context
([C-3](artifacts/current-state-findings.md#c-3-the-argument-is-one-free-text-blob-with-no-parsing-rule),
[C-10](artifacts/current-state-findings.md#c-10-the-type-classification-is-held-only-in-context-with-no-announcement-or-tie-break)).

**Depends on.** S-2.

**Decision.** [D-3](artifacts/change-decision-log.md#d-3-the-argument-grammar),
[D-4](artifacts/change-decision-log.md#d-4-detection-tie-break-and-the-fit-check)

### S-4: `SKILL.md` Steps 2 to 6 — Re-scoped

**Target state.** The steps own only the shared flow. Step 2 dispatches the type's `## Dispatch` entries plus matching
extra agents and compiles the E-series. Step 3 runs the type's `## Analysis` into its template. Step 4 briefs
`adversarial-validator` in the pinned brief form. Step 5 writes the Summary and runs the readability-editor with the
type's `## Audience`. Step 6 prints the type's `## Stop` and the shared line.

**Behavior.** Preserving for `bug`. Extra agents from `## Extra Agents` can now join non-bug runs, which is part of the
requested addition.

**Why.** [C-1](artifacts/current-state-findings.md#c-1-the-bug-framing-runs-through-every-step-of-skillmd-with-no-seam),
[C-6](artifacts/current-state-findings.md#c-6-the-specialist-roster-its-triggers-and-its-prompts-are-inline-and-symptom-keyed).

**Depends on.** S-1, S-3.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-one-type-file-per-type-read-at-fixed-steps),
[D-6](artifacts/change-decision-log.md#d-6-validation-maps-inputs-in-the-brief-the-agent-is-unchanged)

### S-5: `references/template.md` — Removed

**Target state.** `template.md` does not exist. Each type's report layout is `references/templates/{token}.md`, and the
shared Evidence and Validation layout is `references/evidence-and-validation.md`.

**Behavior.** Preserving: the `bug` template keeps today's title, sections, and order.

**Depends on.** S-6, S-7.

**Migration.** The long-form doc's link at `han-coding/docs/skills/investigate.md` L150 points at
`references/templates/bug.md`.

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-per-type-report-templates-with-a-shared-fragment)

### S-6: `references/templates/{bug,how-it-works,available-options}.md` — Added

**Target state.** One template per type, with the title, type line, Summary fields, and sections in the Per-type
reports table, and one shared-fragment marker each.

**Behavior.** Changing for `bug` in one line: a bug report gains the line
`**Investigation type:** bug: Find the root cause of a failure and plan the fix` under its title. Every section is
unchanged.

**Why.** [C-5](artifacts/current-state-findings.md#c-5-one-template-with-shared-carriers-and-bug-only-sections)

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-per-type-report-templates-with-a-shared-fragment)

### S-7: `references/evidence-and-validation.md` — Added

**Target state.** One file owns the Evidence Summary (E-N) and Validation Results (V-N, Adjustments Made, Confidence
Assessment) layouts every type report carries. Its guidance comments speak of "the findings" rather than "the fix".

**Behavior.** Preserving: the headings and fields a bug report carries are unchanged, and the reworded text is guidance
inside HTML comments, which no report contains.

**Why.** [C-5](artifacts/current-state-findings.md#c-5-one-template-with-shared-carriers-and-bug-only-sections)

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-per-type-report-templates-with-a-shared-fragment)

### S-8: Output location and the stop — Re-scoped

**Target state.** The report path resolves as Output location and the stop describes, never overwrites an existing
file, and is shown in the announcement. The run ends with the type's `## Stop` and the shared switch line.

**Behavior.** Changing, in small ways an operator can see. A configured `output-directory` is now honored. When no path
is named, the report lands at a stated location instead of one the model picks each time. The `bug` stop adds "No code
was changed." and the switch line, and keeps the approve-to-implement offer.

**Why.** "The plan file" has no antecedent and the location is unspecified
([C-4](artifacts/current-state-findings.md#c-4-the-output-files-location-and-name-are-never-specified-and-write-is-not-in-allowed-tools)).
This is cleanup beside the main change, justified on its own by C-4: the announcement has to show a path, so the path
has to be determined before dispatch.

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-output-location-keeps-the-documented-contract),
[D-9](artifacts/change-decision-log.md#d-9-the-stop-per-type)

### S-9: `SKILL.md` frontmatter — Re-scoped

**Target state.** The `description` says `investigate` investigates this codebase in one of three types (backticked
`bug`, `how-it-works`, `available-options`), named or detected, and does not research the open web or prior art (use
`research`), write an orientation to a whole area (use `code-overview`), or pace someone through code (use
`code-walkthrough`).

The `argument-hint` is
`"[type: `bug` | `how-it-works` | `available-options`] [question or symptom] [optional report path ending in .md]"`,
listing only the tokens shipped so far. `allowed-tools` adds `Write` and `Skill`; `AskUserQuestion` stays out of it.

**Behavior.** Changing, as requested: the skill now triggers on how-it-works and options questions about the codebase.
The added tools need no new approval from the operator.

**Why.** [C-2](artifacts/current-state-findings.md#c-2-the-description-sends-how-something-works-and-options-to-research),
[C-4](artifacts/current-state-findings.md#c-4-the-output-files-location-and-name-are-never-specified-and-write-is-not-in-allowed-tools)

**Decision.** [D-10](artifacts/change-decision-log.md#d-10-allowed-tools),
[D-12](artifacts/change-decision-log.md#d-12-the-research-and-explanation-boundaries)

### S-10: `research` description and docs — Re-scoped

**Target state.** `research` covers the open web and prior art. Its description and long-form doc send questions about
how this codebase works, or which options it supports, to `investigate`.

**Behavior.** Changing, as agreed in the confirmation turn.

**Depends on.** S-9, in the same unit.

**Decision.** [D-12](artifacts/change-decision-log.md#d-12-the-research-and-explanation-boundaries)

### S-11: `code-overview` and `code-walkthrough` descriptions and docs — Re-scoped

**Target state.** Each description and long-form doc carries one sentence sending a single question about how the code
behaves to `investigate`. `code-overview` still owns an orientation to a whole target; `code-walkthrough` still owns
pacing a person through code.

**Behavior.** Changing, as the operator chose during the run.

**Depends on.** S-9.

**Decision.** [D-12](artifacts/change-decision-log.md#d-12-the-research-and-explanation-boundaries)

### S-12: `investigate-to-confluence` — Re-scoped

**Target state.** The wrapper accepts any of the three types, passes a leading type token through first, passes its
`/tmp/investigate-{slug}.md` path as the final token, describes the report as "a single report whose sections follow the
investigation type", and still tells `investigate` to stop after the report and implement nothing.

**Behavior.** Changing, as agreed: non-bug requests are accepted.

**Why.** [C-12](artifacts/current-state-findings.md#c-12-investigate-to-confluence-restates-the-bug-only-shape-and-rejects-non-bug-requests)

**Depends on.** S-3.

**Decision.** [D-13](artifacts/change-decision-log.md#d-13-the-confluence-wrapper)

### S-13: `scripts/investigation-types.bats` — Added

**Target state.** A Bats test asserts the six agreements in The guarding test.

**Behavior.** Changing (docs and tests only).

**Depends on.** S-1, S-2, S-6, S-7.

**Decision.** [D-11](artifacts/change-decision-log.md#d-11-a-bats-test-holds-the-token-list-together)

### S-14: `evals/investigate/` — Re-scoped

**Target state.** The four existing evals stay. The bug eval also asserts
`{ "result-contains": "**Investigation type:** bug" }`. Three new `skill-prompt` evals exist:

- `prompt-how-it-works.md` on a new `ruby-shop` scaffold: `result-contains` `**Investigation type:** how-it-works`,
  `result-does-not-contain` `Planned Fix`, and `skill-call` `han-coding:investigate` true.
- `prompt-available-options.md` on `ruby-shop`: `result-contains` `**Investigation type:** available-options`, and
  `skill-call` true.
- `prompt-prior-art.md` with no scaffold: `skill-call` `han-coding:investigate` false.

`tests.json`'s `plugins` adds `han-research`, so the prior-art eval tests the split against a real alternative. The
`ruby-shop` scaffold is a small Ruby project with a cart, a pricing module, and two discount implementations that
duplicate a pattern, so how-it-works and options questions have real material and no obvious defect.

**Behavior.** Changing (docs and tests only).

**Why.** [C-13](artifacts/current-state-findings.md#c-13-evals-assert-root-cause-and-cover-only-bug-triggering)

**Decision.** [D-14](artifacts/change-decision-log.md#d-14-eval-coverage)

### S-15: Documentation surfaces — Re-scoped

**Target state.** The long-form doc carries the types table, the grammar examples, each type's report, and the
boundaries with `research`, `code-overview`, and `code-walkthrough`. The `han-coding` README scent line, the skills
index, `docs/workflows.md`, `docs/how-to/research-a-decision.md`, and the Confluence wrapper's long-form doc describe
three types.

**Behavior.** Changing (docs and tests only).

**Why.** [C-14](artifacts/current-state-findings.md#c-14-other-surfaces-describe-investigate-as-bug-only)

**Decision.** [D-15](artifacts/change-decision-log.md#d-15-documentation)

## Behavior Changes

The operator asked for these:

- **A question about how the code works, or about the ways to do a piece of work, gets its own kind of report.** Today
  those questions are sent to `/research`, or forced into a bug report.
- **A named type that clearly does not fit the question triggers one question before the run starts.** The operator can
  switch to the suggested type or keep their own.
- **`/research`, `/code-overview`, and `/code-walkthrough` send single codebase questions to `/investigate`,** and the
  Confluence wrapper accepts non-bug questions.

These follow from the request rather than being asked for by name. Each is listed so nothing changes unannounced:

- **Every run opens with a five-line block** naming the type, why it was chosen, the question as the skill read it,
  where the report will be written, and the other types.
- **A question with no failure, "how", or options wording in it now gets an explanation, not a bug report.** The
  announcement says it defaulted, and the shared stop line shows how to re-run as `bug`.
- **A leading type word is no longer part of the question.** `/investigate bug reports are dropped` investigates
  "reports are dropped" as a bug.
- **A final `.md` path that does not exist yet is the report destination,** and one that exists stays in the question.
- **A configured `output-directory` is now honored,** and with nothing configured or named, reports land in
  `{documentation root}/investigations/`.
- **Bug reports gain one line** naming the type under the title, and the bug stop adds "No code was changed." plus the
  re-run line. Replying "approve" still has the session implement the fix.
- **Configured extra agents can join non-bug runs** when their specialty matches the question.

A bug investigation otherwise runs the same agents and writes the same sections in the same order.

## Change Units

The evals cannot be run from this repository: `tests.json` has no runner in the repo, and `claude plugin eval` reads a
different format ([Open Items](#open-items)). Each unit's check is therefore `npm test` and `npm run lint`, with the
Bats test carrying what structure can prove, and a trial run of each type after Unit 3.

### Unit 1: Extract the `bug` type with no behavior change beyond the visible additions

**What it does.** Moves the bug-specific content into `references/types/bug.md` and `references/templates/bug.md`.
Moves the shared sections into `references/evidence-and-validation.md`, and removes `template.md`. Adds the one-row
table and the type-file contract, and points Steps 2 to 6 at the type file. Adds Step 1's parsing, announcement, and
output resolution. Adds `Write` and `Skill`, sets the `argument-hint` to list `bug`, and adds the Bats test. The
long-form doc's template link moves with it, and the bug eval gains its announcement assertion.

**Delta entries.** S-1 (bug), S-2, S-3 (parsing, announcement), S-4, S-5, S-6 (bug), S-7, S-8, S-9 (hint and tools),
S-13, S-14 (bug assertion).

**How you know it worked.** `npm test` passes, including all six Bats checks with one type. `npm run lint` passes.

### Unit 2: Add `how-it-works`, type resolution, and the boundaries

**What it does.** Adds the second type file and template, and Step 1's detection, tie-break, fit check, and
the fit-check question. Adds `how-it-works` to the `argument-hint`. Changes the `investigate`, `research`, `code-overview`,
and `code-walkthrough` descriptions together. Adds the `ruby-shop` scaffold, the how-it-works eval, and the prior-art
eval.

**Delta entries.** S-1, S-3 (resolution), S-6, S-9, S-10, S-11, S-14.

**Ordering constraint.** After Unit 1. The four descriptions change in one commit, so no two skills claim the same
question at any commit.

**How you know it worked.** `npm test` passes with two types, including Bats check 6. `tests.json` parses with `jq`.

### Unit 3: Add `available-options`

**What it does.** Adds the third type file, template, table row, `argument-hint` token, and the available-options eval.

**Delta entries.** S-1, S-6, S-9, S-14.

**How you know it worked.** `npm test` passes with three types. A trial run of each type in this repo produces a
report with that type's sections, which is the check on the off-type agents and the validator.

### Unit 4: Update the Confluence wrapper and the docs

**Delta entries.** S-12, S-15.

**How you know it worked.** `npm run lint` passes. `grep -rn "bug, failure, or unexpected behavior"` over
`han-coding/README.md`, `docs/skills/README.md`, `han-coding/docs/skills/investigate.md`, and `han-atlassian/` finds
no line describing `investigate` as bug-only.

## Risks

- **Detection misroutes.** A question that mentions a failure in passing could resolve to `bug`, and a neutral symptom
  could resolve to `how-it-works`. The announcement shows the type, the reason, and the runner-up before any agent runs,
  and the stop shows how to re-run. The evals check the common shapes once a runner exists.
- **Off-type agents underperform.** Nobody has run `codebase-explorer` or `behavioral-analyst` on a question rather than
  a feature or a focus area, or briefed `adversarial-validator` with a coverage claim in its fix slot
  ([C-7](artifacts/current-state-findings.md#c-7-evidence-based-investigator-is-bug-framed-codebase-explorer-and-behavioral-analyst-are-neutral),
  [C-8](artifacts/current-state-findings.md#c-8-adversarial-validator-requires-a-planned-fix-and-mandates-challenging-it)).
  The trial run after Unit 3 is the early check.
- **The Confluence wrapper's `/tmp` path.** The wrapper names a path that does not exist yet, which the new grammar
  reads as the out-path. If a stale file sits at that path, the path stays in the question and the report goes to the
  default location instead. The wrapper captures the path `investigate` reports, so it still finds the file.

## Deferred (YAGNI)

- **Investigation types declared in `.han/config.md`, and per-type config agents.** Not requested, and no second source
  of types exists. Reopen when an operator asks for one.
- **A dedicated codebase-options agent.** One caller, no second named. Reopen when trial runs show the explorer and
  structural-analyst pair misses the options space.
- **Correcting near-miss tokens such as `how-it-work`.** The announcement shows the detected type and the other tokens.
  Reopen when evals or users show misspellings misrouting anyway.
- **A diagram or "where to change" section in the how-it-works report.** Reopen on reader feedback from trial runs.
- **Type aliases such as `options`.** Reopen on measured misses.
- **A Bats check that every `## Dispatch` agent exists as a file.** No incident of a missing agent shipping. Reopen when
  one does.
- **A `## Purpose` section in each type file.** The table's Purpose cell is the one copy, and every reader goes through
  the table. Reopen when something reads a type file without the table.
- **An eval for the fit-check question.** How the eval runner handles an `AskUserQuestion` turn is unknown. Reopen once
  a runner exists and handles one.

## Open Items

- **No eval runner in the repository (non-blocking).** `evals/*/tests.json` has no runner in the repo, and
  `claude plugin eval` reads `case.yaml` or `prompt.md` with graders instead. The new evals are written in the existing
  format so they run wherever the current ones do. Settled by the operator naming the runner, or by porting the suites.

## Review Findings

`han-core:junior-developer`, `han-core:test-engineer`, and `han-core:user-experience-designer` reviewed the draft in
one round. The findings that changed the plan:

- **The `bug` run's sameness was overclaimed.** The draft called several visible changes preserving. They are now listed
  under Behavior Changes, and S-3, S-6, and S-8 are classified Changing.
- **The Bats test would have failed at Unit 1** because the `argument-hint` changed only in Unit 2, and it checked
  tokens in one direction only. The hint now changes in each unit with the tokens shipped so far, and check 1 compares
  all four token sets.
- **Unit checks that could not fail.** The eval-based checks had no runner. Each unit now rests on Bats checks that
  can fail, and the plan states the runner gap as an open item.
- **The announcement hid the parse, and a trailing path could overwrite the file being asked about.** The announcement
  now shows the question, the reason, the report path, and the other types, and an existing file is never an out-path.
- **Tokens appeared outside the table.** The tie-break order and the default are now the table's row order, and the
  usage message and shared stop line are built from the table.
- **The `code-overview` and `code-walkthrough` overlap** went to the operator, who chose to add a boundary line to both.
- **Smaller fixes:** the stop pointers name their plugins, the fit-check question quotes the operator's words, the
  how-it-works Summary says Unverified Paths, the filename drops the type, the validator brief form is pinned, and the
  `## Purpose` section and the agent-existence check moved to Deferred.

None of the findings rested on an input a specialist could not inspect, except the eval runner's handling of
`AskUserQuestion`, which is deferred. The decisions are in `artifacts/change-decision-log.md`.
