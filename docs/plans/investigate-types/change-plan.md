# Change Plan: Investigation Types

## Why This Change

`/investigate` assumes every investigation is a bug, and most of the operator's investigations are not. In their words:
"a lot of the investigation i do is not centered around bugs, but rather investigation into how the code works and what
options are available for doing work." This is a constraint arriving: a new requirement the current structure cannot
absorb, because the bug framing is written into every step. The source is the operator's own request, recorded word for
word in `artifacts/scope-boundary.md`.

## What Changes, In One Paragraph

After this change, `/investigate` runs one of three investigation types: `bug`, `how-it-works`, or `available-options`.
Each type is a small data file that says how to recognize it, which agents to dispatch, what the analysis produces, how
the validator is briefed, who the report is for, and how the run ends. Each type has its own report template. The skill
keeps the steps every type shares: reading config, gathering numbered evidence, adversarial validation, the readability
passes, and the review loop. With no type named, the skill picks one from the question and says which it picked. With a
type named, it checks the type fits the question, and asks before switching when it does not. The `bug` type produces
the same report the skill produces today.

## Current State

The bug framing runs through every step of `SKILL.md`. The shared parts (config, evidence rule, E-series, validator
mechanics, readability passes) are already type-agnostic, but nothing separates them from the bug-specific parts
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

## Target State

`SKILL.md` owns the flow every investigation shares. A type file owns everything that differs by type. A template owns
the type's report layout. The skill reads the type file's sections at fixed steps, and never branches on a type name in
its own prose ([D-1](artifacts/change-decision-log.md#d-1-one-type-file-per-type-read-at-fixed-steps)).

### What `SKILL.md` owns

- The config read, the evidence rule, and the lazy-create rule, as today.
- A `## Investigation Types` section holding the only list of shipped tokens:

  ```markdown
  | Token               | File                                                                     | Purpose                                                         |
  | ------------------- | ------------------------------------------------------------------------ | --------------------------------------------------------------- |
  | `bug`               | [references/types/bug.md](./references/types/bug.md)                     | Find the root cause of a failure and plan the fix               |
  | `how-it-works`      | [references/types/how-it-works.md](./references/types/how-it-works.md)   | Explain how this codebase behaves, with cited evidence          |
  | `available-options` | [references/types/available-options.md](./references/types/available-options.md) | Compare the ways a piece of work could be done in this codebase |
  ```

- Argument parsing and type resolution (Step 1, below).
- Evidence gathering: dispatch what the type's `## Dispatch` names, then compile the E-series.
- The `## Extra Agents` rule, reworded: an extra agent joins when the resolved type and the question match its stated
  specialty.
- Validation mechanics: the verbatim brief, V-N items, Adjustments Made, Confidence Assessment.
- The readability-guidance invocation and the readability-editor pass, with the audience taken from the type file.
- Output location, and the stop.

### The argument grammar

([D-3](artifacts/change-decision-log.md#d-3-the-argument-grammar))

```
args       := [ type-token ] question [ out-path ]
type-token := a Token from ## Investigation Types; only the first whitespace-separated token; case-insensitive; never inside quotes
question   := the remaining text, verbatim, as $question
out-path   := the final token, when it ends in ".md" and starts with "/", "./", "../", or "~/"; removed from $question
```

When `$question` is empty and the conversation names no subject, the run stops with:
`investigate needs a question or symptom. Usage: /investigate [bug | how-it-works | available-options] <question> [./path/report.md]. No investigation ran.`

| Invocation                                                                 | Type                                         | `$question`                                    | Out path                   |
| -------------------------------------------------------------------------- | -------------------------------------------- | ---------------------------------------------- | -------------------------- |
| `/investigate bug checkout returns 500 after the coupon change`            | `bug`, named                                 | `checkout returns 500 after the coupon change` | none                       |
| `/investigate how does the retry queue pick a backoff`                     | `how-it-works`, detected                     | the whole string                               | none                       |
| `/investigate how-it-work retry queue`                                     | not a token; detected                        | the whole string                               | none                       |
| `/investigate bug reports from the importer are dropped`                   | `bug`, named                                 | `reports from the importer are dropped`        | none                       |
| `/investigate available-options add rate limiting ./docs/inv/rate-limit.md` | `available-options`, named                   | `add rate limiting`                            | `./docs/inv/rate-limit.md` |
| `/investigate why does deploy fail on docs/CHANGELOG.md`                   | `bug`, detected                              | the whole string                               | none (no path prefix)      |
| `/investigate how-it-works login throws 500 since Tuesday`                 | `how-it-works`, named; fit check fails; asks | `login throws 500 since Tuesday`               | none                       |

### Type resolution

([D-4](artifacts/change-decision-log.md#d-4-detection-tie-break-and-the-fit-check))

1. **No token.** Match `$question` against each type's `## Detection signals`. When more than one type matches, the
   order is `bug`, then `available-options`, then `how-it-works`: a reported failure outranks everything, and an options
   run already includes a current-state account. When none matches, the type is `how-it-works`, which assumes neither a
   defect nor a planned change. The run proceeds without asking.
2. **Token named.** The fit check fails only when `$question` matches a signal of another type and no signal of the
   named type. On failure, ask once with `AskUserQuestion`:
   `You named {given}, but this reads as {suggested}, because it {the signal that matched}. Which type should this run use?`
   with the options `{suggested} (suggested)` and `{given} (as named)`. Anything short of a clear mismatch keeps the
   operator's choice.

Once settled, the run prints one line before any dispatch:

```
announce := "**Investigation type:** " token ", " source ". " purpose
source   := "named" | "detected from the question" | "switched from " token " at your request"
```

Example: `**Investigation type:** how-it-works, detected from the question. Explain how this codebase behaves, with cited evidence.`

### The type-file contract

([D-2](artifacts/change-decision-log.md#d-2-the-type-file-contract))

Each type file is `references/types/{token}.md`, titled `# Investigation type: {token}`, with exactly these seven `##`
sections in this order, outside any fence. A section with nothing to say holds the literal `none`; `## Dispatch` is
never `none`.

| Section                | Value form                                                                                                                             | Read at          |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| `## Purpose`           | one sentence, identical to the table's Purpose cell                                                                                    | Step 1           |
| `## Detection signals` | three or more bullets, `- {signal}`                                                                                                    | Step 1           |
| `## Dispatch`          | a numbered list, one entry per agent: ``N. `{plugin}:{agent}` ({count}, always \| when {trigger}): "{prompt using {question}}"`` | Step 2           |
| `## Analysis`          | a numbered list of steps run between the evidence summary and validation, each naming the template section it fills                    | Step 3           |
| `## Validation brief`  | exactly three bullets: `- Root cause analysis: {what this type passes}`, `- Planned fix: {what this type passes}`, `- Attack focus: {one sentence}` | Step 4           |
| `## Audience`          | one sentence naming the reader                                                                                                         | Steps 3 and 5    |
| `## Stop`              | one blockquote, the closing message, with `{path}` as its only placeholder                                                             | Step 6           |

A worked example, abridged, for `bug`:

```markdown
# Investigation type: bug

## Purpose

Find the root cause of a failure and plan the fix

## Detection signals

- something fails, errors, crashes, or returns a wrong result
- something stopped working, or regressed after a change
- an error message, stack trace, or failing test is quoted

## Dispatch

1. `han-core:evidence-based-investigator` (2, always): "Investigate from the {angle} angle: {question}. ..."
2. `han-core:concurrency-analyst` (1, when the question involves intermittent failures, races, ordering, or load): "..."

## Analysis

1. Write the Problem Statement.
2. Write the Root Cause Analysis, citing E-items.
3. Resolve coding standards, then write the Coding Standards Reference and the Planned Fix.

## Validation brief

- Root cause analysis: the Root Cause Analysis section
- Planned fix: the Planned Fix section
- Attack focus: break the fix and the causal chain from root cause to symptom

## Audience

The engineer who will implement the fix and may be paged on the bug.

## Stop

> Report written to {path}. Approve the Planned Fix to implement it, or reply with corrections to revise the report.
```

### Per-type rosters

([D-5](artifacts/change-decision-log.md#d-5-per-type-rosters-reuse-existing-agents))

| Type                | Always                                                                 | When relevant                                                                                  |
| ------------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `bug`               | `han-core:evidence-based-investigator` ×2                              | `concurrency-analyst`, `behavioral-analyst`, `data-engineer`, on today's triggers              |
| `how-it-works`      | `han-core:codebase-explorer`, `han-core:behavioral-analyst`            | `structural-analyst` (organization, dependencies, history), `concurrency-analyst`, `data-engineer` |
| `available-options` | `han-core:codebase-explorer`, `han-core:structural-analyst`            | `behavioral-analyst`, `data-engineer`, `concurrency-analyst`                                    |

`evidence-based-investigator` stays with `bug`, because its protocols start from a symptom. `research-analyst` joins no
type: questions that need the open web or prior art go to `/research`, per the agreed split.

### Validation per type

([D-6](artifacts/change-decision-log.md#d-6-validation-maps-inputs-in-the-brief-the-agent-is-unchanged))

`han-core:adversarial-validator` is unchanged. Each type's `## Validation brief` says what it passes in the validator's
three input slots:

| Type                | Root cause analysis slot          | Planned fix slot                                          | Attack focus                                                                   |
| ------------------- | --------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `bug`               | Root Cause Analysis               | Planned Fix                                               | Break the fix and the causal chain                                             |
| `how-it-works`      | the Answer and its flow trace     | the Answer's coverage claim: the entry points and paths it calls complete | Find a caller, path, or input the explanation misses or gets wrong |
| `available-options` | Current State and Constraints     | the recommended option and its change surface             | Break the recommendation; test whether a rejected option rests on a false premise |

### Per-type reports

([D-7](artifacts/change-decision-log.md#d-7-per-type-report-templates-with-a-shared-fragment))

Each type has `references/templates/{token}.md`. The Evidence Summary, Validation Results, Adjustments Made, and
Confidence Assessment live once, in `references/evidence-and-validation.md`. Each template carries exactly one line
`<!-- shared: evidence-and-validation.md -->` where that fragment's sections go.

| Type                | Title                          | Summary fields                                                                         | Sections, in order                                                                                          |
| ------------------- | ------------------------------ | -------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `bug`               | `# Investigation: {title}`     | Root Cause, Fix, Why Correct, Validation Outcome, Remaining Risks                      | Problem Statement, Root Cause Analysis, Planned Fix, shared fragment, Coding Standards Reference             |
| `how-it-works`      | `# How It Works: {subject}`    | Answer, Entry Points, Validation Outcome, Remaining Risks                               | Question, Answer (lead sentence, then a numbered flow walkthrough), Key Components (Component, File, Role), shared fragment |
| `available-options` | `# Available Options: {goal}`  | Recommendation, Options Considered, Deciding Factor, Validation Outcome, Remaining Risks | Goal and Constraints, Current State, Options (one `### Option N: {name}` each), Comparison, Recommendation, shared fragment, Coding Standards Reference |

The `bug` template is today's `template.md` with the shared sections moved into the fragment, so a bug report reads the
same as it does now.

### Output location and the stop

([D-8](artifacts/change-decision-log.md#d-8-output-location-keeps-the-documented-contract))

The report path resolves in config-rule order: an out-path in the argument wins; otherwise a configured
`output-directory`, with the file written directly beneath it; otherwise the skill proposes a path, as the long-form doc
promises today, and writes there. The proposed filename is `investigate-{token}-{slug}.md`, where the slug is two to six
words from `$question` in `[a-z0-9-]`. "The plan file" becomes "the report file" throughout.

The run ends by printing the type's `## Stop`
([D-9](artifacts/change-decision-log.md#d-9-the-stop-per-type)):

- **`bug`:** `Report written to {path}. Approve the Planned Fix to implement it, or reply with corrections to revise the report.`
- **`how-it-works`:** `Report written to {path}. No code was changed. Reply with corrections to revise the report. To change this code next, run /plan-a-change with this report; to build new behavior on it, run /plan-a-feature.`
- **`available-options`:** `Report written to {path}. No code was changed. Reply with corrections to revise the report. To plan the recommended option, run /plan-a-change (restructuring existing code) or /plan-a-feature (new behavior) with this report; to weigh prior art beyond this codebase, run /research.`

`allowed-tools` adds `Write`, `Skill`, and `AskUserQuestion`
([D-10](artifacts/change-decision-log.md#d-10-allowed-tools)).

### The guarding test

`han-coding/skills/investigate/scripts/investigation-types.bats` holds the cross-file agreements
([D-11](artifacts/change-decision-log.md#d-11-a-bats-test-holds-the-token-list-together)):

1. Every `references/types/*.md` has a matching table row, a `references/templates/{token}.md`, and a token in both the
   `argument-hint` and the `description`; every table row names an existing file.
2. Every type file's first line is `# Investigation type: {token}`, its `##` headings outside fences are exactly the
   seven in order, and its `## Validation brief` carries the three pinned bullet prefixes.
3. Every agent in a `## Dispatch` entry resolves to an existing `{plugin}/agents/{agent}.md` in the repo.
4. Every template has exactly one `<!-- shared: evidence-and-validation.md -->` line.

## Surface Delta

### S-1: `references/types/{bug,how-it-works,available-options}.md` — Added

**Target state.** Three type files exist, each following the type-file contract. `bug.md` carries today's inline bug
content: the symptom-first approach, the two-investigator dispatch, the three specialist triggers with `{question}` in
place of `{symptom}`, the root-cause and fix analysis, today's audience, and today's stop.

**Behavior.** Preserving for `bug`: the same agents run on the same triggers and the same sections are written. The two
new types are the requested addition.

**Why.** The bug framing sits in six steps with no seam
([C-1](artifacts/current-state-findings.md#c-1-the-bug-framing-runs-through-every-step-of-skillmd-with-no-seam)).

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-one-type-file-per-type-read-at-fixed-steps),
[D-2](artifacts/change-decision-log.md#d-2-the-type-file-contract),
[D-5](artifacts/change-decision-log.md#d-5-per-type-rosters-reuse-existing-agents)

### S-2: `SKILL.md` `## Investigation Types` — Added

**Target state.** A section in `SKILL.md` holds the three-row token table, the only list of shipped tokens, and the
type-file contract.

**Behavior.** Preserving. It adds a list; it changes no existing step.

**Why.** The token list must agree across the table, type files, templates, `argument-hint`, and `description`
([C-9](artifacts/current-state-findings.md#c-9-the-code-review-type-pattern-and-what-does-not-transfer)).

**Depends on.** S-1.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-one-type-file-per-type-read-at-fixed-steps)

### S-3: `SKILL.md` Step 1, argument parsing and type resolution — Added

**Target state.** Step 1 parses the argument per the grammar, resolves the type by detection or fit check, asks once on
a clear mismatch, and prints the announcement line before any dispatch.

**Behavior.** Changing, as requested: a question with no failure in it now runs as `how-it-works` or
`available-options`. The scope boundary records this requirement word for word, so it is not re-asked. A bug question
with no type token still resolves to `bug`.

**Why.** There is no parsing rule and the classification is held only in context
([C-3](artifacts/current-state-findings.md#c-3-the-argument-is-one-free-text-blob-with-no-parsing-rule),
[C-10](artifacts/current-state-findings.md#c-10-the-type-classification-is-held-only-in-context-with-no-announcement-or-tie-break)).

**Depends on.** S-2.

**Decision.** [D-3](artifacts/change-decision-log.md#d-3-the-argument-grammar),
[D-4](artifacts/change-decision-log.md#d-4-detection-tie-break-and-the-fit-check)

### S-4: `SKILL.md` Steps 2 to 6 — Re-scoped

**Target state.** The steps own only the shared flow. Step 2 dispatches the type's `## Dispatch` entries plus matching
extra agents and compiles the E-series. Step 3 runs the type's `## Analysis` into its template. Step 4 briefs
`adversarial-validator` from `## Validation brief`. Step 5 writes the Summary and runs the readability-editor with the
type's `## Audience`. Step 6 resolves nothing new and prints the type's `## Stop`.

**Behavior.** Preserving for `bug`.

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

**Target state.** One template per type, with the title, Summary fields, and sections in the Per-type reports table,
and one shared-fragment marker each.

**Behavior.** Preserving for `bug`.

**Why.** [C-5](artifacts/current-state-findings.md#c-5-one-template-with-shared-carriers-and-bug-only-sections)

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-per-type-report-templates-with-a-shared-fragment)

### S-7: `references/evidence-and-validation.md` — Added

**Target state.** One file owns the Evidence Summary (E-N), Validation Results (V-N), Adjustments Made, and Confidence
Assessment layouts every type report carries. Its wording names "the findings" rather than "the fix".

**Behavior.** Preserving: the sections a bug report carries are unchanged.

**Why.** [C-5](artifacts/current-state-findings.md#c-5-one-template-with-shared-carriers-and-bug-only-sections)

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-per-type-report-templates-with-a-shared-fragment)

### S-8: Output location and the stop — Re-scoped

**Target state.** The report path resolves as Output location and the stop describes, the filename carries the type,
and the run ends with the type's `## Stop`.

**Behavior.** Preserving for `bug`: the documented path contract (an explicit path wins; otherwise the skill proposes
one) and the approve-to-implement ending are unchanged.

**Why.** [C-4](artifacts/current-state-findings.md#c-4-the-output-files-location-and-name-are-never-specified-and-write-is-not-in-allowed-tools),
[C-11](artifacts/current-state-findings.md#c-11-the-stop-point-says-approval-triggers-implementation-but-nothing-implements)

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-output-location-keeps-the-documented-contract),
[D-9](artifacts/change-decision-log.md#d-9-the-stop-per-type)

### S-9: `SKILL.md` frontmatter — Re-scoped

**Target state.** The `description` says `investigate` investigates this codebase in one of three types, named or
detected, and does not research the open web or prior art (use `research`). The `argument-hint` is
`"[type: bug | how-it-works | available-options] [question or symptom] [optional output path: ./path.md or /abs/path.md]"`.
`allowed-tools` adds `Write`, `Skill`, and `AskUserQuestion`.

**Behavior.** Changing, as requested: the skill now triggers on how-it-works and options questions about the codebase.

**Why.** [C-2](artifacts/current-state-findings.md#c-2-the-description-sends-how-something-works-and-options-to-research),
[C-4](artifacts/current-state-findings.md#c-4-the-output-files-location-and-name-are-never-specified-and-write-is-not-in-allowed-tools)

**Decision.** [D-10](artifacts/change-decision-log.md#d-10-allowed-tools),
[D-12](artifacts/change-decision-log.md#d-12-the-research-boundary)

### S-10: `research` description and docs — Re-scoped

**Target state.** `research` covers the open web and prior art. Its description and long-form doc send questions about
how this codebase works, or which options it supports, to `investigate`.

**Behavior.** Changing, as agreed in the confirmation turn.

**Depends on.** S-9, in the same unit.

**Decision.** [D-12](artifacts/change-decision-log.md#d-12-the-research-boundary)

### S-11: `investigate-to-confluence` — Re-scoped

**Target state.** The wrapper accepts any of the three types, passes a leading type token through first, passes its
`/tmp/investigate-{slug}.md` path as the final token, describes the report as "a single report whose sections follow the
investigation type", and still tells `investigate` to stop after the report.

**Behavior.** Changing, as agreed: non-bug requests are accepted.

**Why.** [C-12](artifacts/current-state-findings.md#c-12-investigate-to-confluence-restates-the-bug-only-shape-and-rejects-non-bug-requests)

**Depends on.** S-3.

**Decision.** [D-13](artifacts/change-decision-log.md#d-13-the-confluence-wrapper)

### S-12: `scripts/investigation-types.bats` — Added

**Target state.** A Bats test asserts the four agreements in The guarding test.

**Behavior.** Preserving.

**Depends on.** S-1, S-2, S-6.

**Decision.** [D-11](artifacts/change-decision-log.md#d-11-a-bats-test-holds-the-token-list-together)

### S-13: `evals/investigate/` — Re-scoped

**Target state.** The existing four evals stay. The bug eval also asserts `**Investigation type:** bug`. New evals cover
a how-it-works prompt, an available-options prompt (each asserting its announcement), and a prior-art prompt that must
not trigger `investigate`.

**Behavior.** Preserving.

**Why.** [C-13](artifacts/current-state-findings.md#c-13-evals-assert-root-cause-and-cover-only-bug-triggering)

**Decision.** [D-14](artifacts/change-decision-log.md#d-14-eval-coverage)

### S-14: Documentation surfaces — Re-scoped

**Target state.** The long-form doc carries the types table, the grammar examples, each type's report, and the
boundaries with `research`, `code-overview`, and `code-walkthrough`. The `han-coding` README scent line, the skills
index, `docs/workflows.md`, `docs/how-to/research-a-decision.md`, and the Confluence wrapper's long-form doc describe
three types.

**Behavior.** Preserving.

**Why.** [C-14](artifacts/current-state-findings.md#c-14-other-surfaces-describe-investigate-as-bug-only)

**Decision.** [D-15](artifacts/change-decision-log.md#d-15-documentation)

## Behavior Changes

Every behavior change here is one the operator asked for:

- **A question about how the code works, or about the ways to do a piece of work, now gets its own kind of report.**
  Today those questions are steered to `/research`, or forced into a bug report. Requested in the operator's own words.
- **A named type that does not fit the question triggers one question before the run starts.** Requested: "validate
  that the specified type is acceptable for the prompt, and suggest an alternative type when needed."
- **`/research` stops claiming codebase questions,** and the Confluence wrapper accepts non-bug questions. Agreed in the
  confirmation turn.

A bug investigation produces the same report, with the same ending, that it does today.

## Change Units

### Unit 1: Extract the `bug` type with no behavior change

**What it does.** Moves the bug-specific content into `references/types/bug.md` and `references/templates/bug.md`,
moves the shared sections into `references/evidence-and-validation.md`, removes `template.md`, adds the one-row table
and the type-file contract, points Steps 2 to 6 at the type file, pins the output path and filename, adds `Write` and
`Skill`, and adds the Bats test. The long-form doc's template link moves with it.

**Delta entries.** S-1 (bug only), S-2, S-4, S-5, S-6 (bug only), S-7, S-8, S-12.

**How you know it worked.** `npm test` and `npm run lint` pass. The existing bug eval still finds "Root Cause".

### Unit 2: Add `how-it-works`, type resolution, and the `research` boundary

**What it does.** Adds the second type file and template, Step 1's grammar, resolution, fit check, and announcement,
`AskUserQuestion`, the new `argument-hint`, and the new `investigate` and `research` descriptions together.

**Delta entries.** S-1, S-3, S-6, S-9, S-10.

**Ordering constraint.** After Unit 1. The two descriptions change in one commit, so the two skills never both claim
"how something works".

**How you know it worked.** `npm test` passes with two types.

### Unit 3: Add `available-options`

**What it does.** Adds the third type file, template, table row, and tokens.

**Delta entries.** S-1, S-6, S-9.

**How you know it worked.** `npm test` passes with three types.

### Unit 4: Update the Confluence wrapper and the docs

**Delta entries.** S-11, S-14.

**How you know it worked.** Lint passes; no doc describes `investigate` as bug-only.

### Unit 5: Add the evals

**Delta entries.** S-13.

**How you know it worked.** `tests.json` parses, and each new eval names a prompt file that exists.

## Risks

- **Detection misroutes.** A question that mentions a failure in passing could resolve to `bug`. The announcement line
  makes the type visible before any work, and the operator can re-run with a token. The evals catch the common shapes.
- **Off-type agents underperform.** Nobody has run `codebase-explorer` or `behavioral-analyst` on a question rather than
  a feature or a focus area
  ([C-7](artifacts/current-state-findings.md#c-7-evidence-based-investigator-is-bug-framed-codebase-explorer-and-behavioral-analyst-are-neutral)).
  A trial run of each type after Unit 3 is the early check.

## Deferred (YAGNI)

- **Investigation types declared in `.han/config.md`, and per-type config agents.** Not requested, and no second source
  of types exists. Reopen when an operator asks for one.
- **A dedicated codebase-options agent.** One caller, no second named. Reopen when trial runs show the explorer and
  structural-analyst pair misses the options space.
- **Correcting near-miss tokens such as `how-it-work`.** Reopen when evals or users show misspellings misrouting
  despite the announcement.
- **A diagram or "where to change" section in the how-it-works report.** Reopen on reader feedback from trial runs.
- **Type aliases such as `options`.** Reopen on measured misses.

## Cut for Scope

- **Rewording `code-overview` and `code-walkthrough` descriptions** to point single-question explanations at
  `investigate how-it-works`. The confirmed area in `artifacts/scope-boundary.md` does not list either skill. Their
  descriptions stay true as written, since both still send bugs to `investigate`. The boundary is stated from
  `investigate`'s side only.

## Open Items

None yet. The review round has not run.

## Review Findings

Not yet run.
