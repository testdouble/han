---
name: investigate
description: >
  Evidence-based investigation of a question about this codebase, run as one investigation type: `bug` finds the root
  cause of a failure and plans the fix, `how-it-works` explains how the code behaves today, and `available-options`
  compares the ways a piece of work could be done. Name a type first, or let the skill detect it from the question. Use
  when you need to debug, troubleshoot, or figure out why something is broken, understand how a flow, an integration,
  or an API call works, or weigh how to make a change. Does not review code for quality or style — use code-review.
  Does not assess architectural health — use architectural-analysis. Does not plan the change a finding calls for — use
  plan-a-change. Does not map bounded contexts — use ddd-analysis. Does not capture feedback on Han's own skills — use
  han-feedback. Does not research the open web or prior art — use research. Does not write an orientation to a whole
  area — use code-overview, or code-walkthrough to be paced through code step by step.
argument-hint: "[type: `bug` | `available-options` | `how-it-works`] [question or symptom] [optional report path ending in .md]"
allowed-tools:
  Read, Glob, Grep, Agent, Write, Skill, Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.

## Investigation Approach

- Every run is one investigation type. The type file says what differs; this file says what every type shares.
- Launch the agents a type dispatches in parallel, in a single message.
- The `han-core:adversarial-validator` agent handles all three validation strategies (challenge evidence, challenge the
  conclusion, challenge assumptions) internally.
- Apply the evidence rule from [../../references/evidence-rule.md](../../references/evidence-rule.md) to every finding.
  Codebase findings (file path, line number, log line, test output) carry the trust-class label "codebase" and stand on
  their citation. Web-source context the operator pastes in (RFCs, vendor docs, Stack Overflow, blog posts) carries the
  trust-class label "web" and is subject to the corroboration gate when it drives a conclusion. When the investigation
  hits a point where no evidence at any tier resolves a question, label the no-evidence state rather than guessing.
- Lazy-create the output sections. Include a section in the report file only when the investigation produced meaningful
  content for it; omit any section that would be empty, and keep the sections that remain in the template's order.
  Never emit a heading with placeholder or "N/A" content.
- Invoke `han-communication:readability-guidance` to source the shared readability standard into your context, then
  apply it as you write the findings, holding the named audience from the type file's `## Audience`. Scope that frame
  per section so the technical specifics the reader needs (function names, exact conditions, file:line citations) are
  preserved, never simplified away.

## Investigation Types

An investigation type names the one kind of question a run answers. Each shipped type is a data file under
`references/types/` with a report template under `references/templates/`, and this table is the only list of shipped
type tokens. Row order is the tie-break order when a question reads as more than one type, and the last row is the type
a question gets when it reads as none.

| Token               | File                                                                             | Purpose                                                         |
| ------------------- | -------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `bug`               | [references/types/bug.md](./references/types/bug.md)                             | Find the root cause of a failure and plan the fix               |
| `available-options` | [references/types/available-options.md](./references/types/available-options.md) | Compare the ways a piece of work could be done in this codebase |
| `how-it-works`      | [references/types/how-it-works.md](./references/types/how-it-works.md)           | Explain how this codebase behaves, with cited evidence          |

Templates: [references/templates/bug.md](./references/templates/bug.md),
[references/templates/available-options.md](./references/templates/available-options.md), and
[references/templates/how-it-works.md](./references/templates/how-it-works.md). Every template carries one line
`<!-- shared: evidence-and-validation.md -->`; write the sections of
[references/evidence-and-validation.md](./references/evidence-and-validation.md) in that line's place.

### The type-file contract

Every type file has a `# Investigation type: {token}` title and these six `##` sections, in this order, outside any
fence. Every section has content. A short lead paragraph may open `## Dispatch` before its numbered list.

| Section                | Value form                                                                                                                                                                                                                                          | Read at       |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| `## Detection signals` | one or more bullets, `- {phrase}`                                                                                                                                                                                                                   | Step 1        |
| `## Dispatch`          | a numbered list, one entry per agent: ``N. `{plugin}:{agent}` ({count}, {when}): "{prompt}"``, where `{count}` is a number or a number followed by `+`, `{when}` is `always` or `when {trigger}`, and `{question}` is the prompt's only placeholder | Step 2        |
| `## Analysis`          | a numbered list of steps run between the evidence summary and validation, each naming in backticks the template heading it fills                                                                                                                    | Step 3        |
| `## Validation brief`  | exactly three bullets, in this order: `- Root cause analysis: {text}`, `- Planned fix: {text}`, `- Attack focus: {text}`                                                                                                                            | Step 4        |
| `## Audience`          | one sentence naming the reader                                                                                                                                                                                                                      | Steps 3 and 5 |
| `## Stop`              | one blockquote line, with `{path}` as its only placeholder                                                                                                                                                                                          | Step 6        |

[scripts/investigation-types.bats](./scripts/investigation-types.bats) holds the table, the type files, the templates,
and the `argument-hint` in agreement. Run `npm test` after editing any of them.

# Investigate

## Step 1: Resolve the Type, the Question, and the Report Path

### Parse the argument

```
args       := [ type-token ] question [ out-path ]
type-token := a Token from ## Investigation Types; only the first whitespace-separated token; case-insensitive;
              one trailing ":" is stripped before matching; never inside quotes
question   := the remaining text, verbatim, as $question
out-path   := the final token, when it ends in ".md" and does not name a file that already exists; removed from $question
```

A first token that is not a type token stays in `$question`. A final `.md` token that names an existing file stays in
`$question` too: it is the subject, and the run never writes over it.

When `$question` is empty, use the problem or question the conversation's earlier messages describe. When there is
none, stop with this message, listing every row of the `## Investigation Types` table as `- {token}: {Purpose}`:

```
investigate needs a question or symptom. No investigation ran.
Usage: /investigate [type] <question> [report path ending in .md]
Types:
- {token}: {Purpose}
```

| Invocation                                                                    | Type                                     | `$question`                                    | Out path                     |
| ----------------------------------------------------------------------------- | ---------------------------------------- | ---------------------------------------------- | ---------------------------- |
| `/investigate bug checkout returns 500 after the coupon change`               | `bug`, named                             | `checkout returns 500 after the coupon change` | none                         |
| `/investigate bug: cart total off by one cent`                                | `bug`, named (colon stripped)            | `cart total off by one cent`                   | none                         |
| `/investigate checkout fails docs/incidents/checkout.md`                      | `bug`, detected                          | `checkout fails`                               | `docs/incidents/checkout.md` |
| `/investigate why does the generator rewrite ./CHANGELOG.md`                  | `bug`, detected                          | the whole string                               | none (the file exists)       |
| `/investigate how does the retry queue pick a backoff`                        | `how-it-works`, detected                 | the whole string                               | none                         |
| `/investigate how-it-work retry queue`                                        | not a token; detected                    | the whole string                               | none                         |
| `/investigate how-it-works login throws 500 since Tuesday`                    | named `how-it-works`; the fit check asks | `login throws 500 since Tuesday`               | none                         |
| `/investigate available-options add a fixed-amount coupon docs/inv/coupon.md` | `available-options`, named               | `add a fixed-amount coupon`                    | `docs/inv/coupon.md`         |
| `/investigate how should we add rate limiting to the API`                     | `available-options`, detected            | the whole string                               | none                         |

### Resolve the type

Detection is a judgment you make against each type's `## Detection signals`. The signals are guidance written as
phrases, not literal strings to match.

1. **No type token.** Decide which types' signals the question meets. When more than one does, the earliest row in the
   table wins. When none does, the last row is the type. Proceed without asking.
2. **Type token named.** Check the named type fits. The check fails only when the question clearly meets another type's
   signals and none of the named type's. Anything short of a clear mismatch keeps the operator's choice. On failure, ask
   once with `AskUserQuestion`:
   - Question: `You named {given}, but "{the operator's words that matched}" reads as {suggested}. Which type should this run use?`
   - Options: `{suggested}`, described by its Purpose cell, and `{given} (as named)`, described by its Purpose cell.
   - When more than one other type matches, `{suggested}` is the earliest such row.
   - A free-text answer naming a token uses that token. Any other answer, or a dismissal, keeps the named type.

Read the resolved type's file, `references/types/{token}.md`, in full. Its sections drive Steps 2 to 6.

### Resolve the report path

Resolve where the report is written, per [config-rule.md](../../references/config-rule.md):

1. The out-path from the argument, when there is one. A calling skill's explicit path arrives this way.
2. Otherwise, the configured `output-directory`, with the file written directly beneath it.
3. Otherwise, `{documentation root}/investigations/`. The documentation root comes from CLAUDE.md's
   `## Project Discovery` section, then `project-discovery.md`, then `docs/` when it exists, then the repository root.

Under 2 and 3, the filename is `investigate-{slug}.md`, where the slug is two to six words from `$question`, lowercase,
in `[a-z0-9-]`. When that file already exists, append `-2`, `-3`, and so on. Write without asking.

### Announce

Before any dispatch, print this block. `Other types` lists every other table token; omit that line when the table has
one row.

```
**Investigation type:** {token}: {Purpose}
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

## Step 2: Gather Evidence

Dispatch every `## Dispatch` entry whose `{when}` is `always`, at its count, and every entry whose trigger the question
meets. Replace `{question}` with `$question`. When an entry's count ends in `+`, dispatch more than that number when the
question has more distinct angles. Skip any entry that does not apply. Launch all of them in parallel, in one message.

Extra agents named in the project config's `## Extra Agents` list join this pool under the same rule, per
[../../references/config-rule.md](../../references/config-rule.md): dispatch one only when the resolved type and the
question match its stated specialty, and skip an entry that does not resolve to a dispatchable agent with a one-line
note.

After all agents complete, compile an **evidence summary**: a numbered list of concrete findings (E1, E2, E3, ...) that
feeds the analysis. Merge duplicates and resolve conflicting findings while preserving each item's output structure.
Tag a specialist's findings with its domain (e.g., `E3 (concurrency)`).

## Step 3: Analyze and Write the Report

Write to the report file using the type's template, `references/templates/{token}.md`. Fill the sections in the order
the type's `## Analysis` lists, which is deliberately not the template's on-page order: the template leads with the
Summary and places the supporting Evidence Summary and Validation Results near the end for the reader.

Write the Evidence Summary from Step 2 first, then run each `## Analysis` step into the template section it names.

When an `## Analysis` step resolves coding standards, read CLAUDE.md's `## Project Discovery` section for docs, ADR,
and coding-standards directories; fall back to project-discovery.md; fall back to Glob defaults (`docs/`, `docs/adr/`,
`docs/coding-standards/`). Search found directories for relevant standards, ADRs, and docs. Also check `CLAUDE.md`,
`AGENTS.md`, and linter/formatter configs. If none are found, infer conventions from surrounding code.

## Step 4: Validation (CRITICAL)

Launch `han-core:adversarial-validator` agents with a brief in this form, filled from the type's `## Validation brief`:

```
This is a {token} investigation. {Purpose}.

Evidence summary:
{every E-item, verbatim, with code}

Root cause analysis (for this investigation type, this is {Root cause analysis text}):
{that section, verbatim}

Planned fix (for this investigation type, this is {Planned fix text}):
{that section, verbatim}

Attack focus: {Attack focus text}
```

Do not summarize. The validator needs verbatim detail to challenge effectively. Its job is adversarial: it must actively
try to disprove the findings and break the conclusion.

When counter-evidence is found, document it as a validation finding (V1, V2, ...), investigate whether it changes the
analysis, adjust the report's evidence and analysis sections as needed, and fill in the **Adjustments Made** section
listing what changed and which validation finding triggered each change. When counter-evidence is not found, document
what was checked and why it supports the original findings, recording it as a validation finding confirming the
analysis.

After all validation is complete, incorporate the validators' Confidence Assessment and Remaining Risks into the report.

## Step 5: Summary and Readability

Add the **Summary** section at the top of the report file, one sentence for each field the template's Summary lists.
Reference the strongest evidence and the Confidence Assessment where the fields call for them.

Once the write-up draft is complete, dispatch `han-communication:readability-editor` (one Agent call) to audit and
rewrite the findings against the readability standard. This is separate from the Step 4 adversarial-validator pass:
that pass checks the findings are correct (accuracy); this pass checks how the write-up reads. Keep both. Pass the
editor the report file path and the named audience from the type's `## Audience`; the editor reads han-communication's
own canonical rule, so pass no rule path. It must preserve every fact and operate on prose regions only, never inside
code fences, function signatures in code blocks, diagram bodies, or file:line citation identifiers. Apply its rewrite to
the report file.

Then run the readability rule's standardized self-check, which is already in your context from the
`readability-guidance` invocation above, over the write-up's prose regions only. Correct every failure before
presenting. Its fidelity criterion is not optional: the standard governs how the content is said, and drops a required
fact only when the reader asked for less and losing it would not change what they do next.

## Step 6: Present the Report

Print the type's `## Stop` line with `{path}` filled in. When the table has more than one row, follow it with:

```
Wrong kind of report? Re-run as /investigate {other token} <question>, where {other token} is one of: {every other token}.
```
