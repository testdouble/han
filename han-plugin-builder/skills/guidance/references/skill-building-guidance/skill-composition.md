---
paths:
  - "**/skills/**/*.md"
---

# Skill Composition

## Contents

- Orchestration composition (supported, with care)
- Forked data-fetch composition (avoid)
- The `context: fork` field
- Deciding which way to go

Skills can call other skills through the Skill tool. This is a real, supported capability, and Han uses it in
production. It also has sharp edges. Treat it as a power tool: reach for it deliberately, with the safeguards below, and
only when the alternative is duplicating a whole skill's worth of work.

Two patterns hide under the word "composition," and they behave very differently:

- **Orchestration composition.** A thin calling skill hands the heavy work to a called skill that drives the rest of the
  output, and optionally chains into another skill afterward. **Supported. Use it with the discipline below.**
- **Forked data-fetch composition.** A skill calls another skill under `context: fork` only to retrieve a few values
  (config paths, a command, a setting). **Avoid it. Do discovery inline instead.** The early-exit failure mode this
  caused is documented below and has not been reliably fixed by any frontmatter or instruction tuning. One
  separately-tested exception (an inline sub-skill that surfaces shared content) is carved out at the end of that
  section.

Knowing which one you are reaching for is the whole decision. The rest of this document is the guidance for each.

## Orchestration composition (supported, with care)

In orchestration composition the calling skill is a thin coordinator. It validates inputs, then invokes a substantial
sub-skill that owns a whole artifact and drives the remaining output, optionally chaining that result into a second
sub-skill. The calling skill does almost no work of its own.

Han ships two live examples, and they run reliably:

- `han-atlassian:plan-a-feature-to-confluence` validates its inputs, runs `han-planning:plan-a-feature` to a temporary
  folder, gets the user's review and publish choice, then hands every file to `han-atlassian:markdown-to-confluence` to
  publish.
- `han-atlassian:project-documentation-to-confluence` does the same shape with `han-documentation:project-documentation` feeding
  `han-atlassian:markdown-to-confluence`.

These work because they follow a disciplined shape. If you compose skills, match it.

### Keep the orchestrator thin

The calling skill should validate, forward, capture, and report, and almost nothing else. The more logic the
orchestrator carries across a Skill call, the more likely it is to lose track of its own workflow after the sub-skill
returns. A thin orchestrator has little state to lose. Both Atlassian skills open by stating plainly that "the steps
below are the whole skill" and that they do not do the called skill's job themselves. Copy that framing.

### Preflight hard requirements before any expensive sub-skill work

Validate everything that can fail cheaply before you spend a long sub-skill run. The Confluence orchestrators check that
the Atlassian MCP server is reachable as their very first step, so a missing server fails in seconds rather than after a
full planning interview. Put your hard requirements (a connected MCP server, a required destination, a needed input)
ahead of the Skill call, not after it.

### Forward the user's context verbatim

When you invoke the sub-skill, pass the user's request, the `size` argument, known constraints, and the relevant
conversation context through unchanged. Do not summarize, trim, or reinterpret it. The goal is that the sub-skill runs
exactly as it would if the user had invoked it directly. `plan-a-feature-to-confluence` is explicit about this: it
forwards "all provided context verbatim" so the planning skill's interview, review team, and synthesis all run normally.

### Give the sub-skill explicit overrides, not silent assumptions

If the orchestration needs the sub-skill to behave differently in one respect, say so in the invocation. The Confluence
orchestrators tell `plan-a-feature` to write under `/tmp/` rather than into the repo, and not to prompt the user to
choose an output location, because the orchestrator owns that decision. State each override as one explicit instruction
in the Skill call. Do not assume the sub-skill will infer it.

### Capture the sub-skill's exact outputs

After the sub-skill finishes, record the precise paths or values it produced before you move on.
`plan-a-feature-to-confluence` captures the exact `/tmp/` paths of every file written, and accounts for the one
companion artifact that is created only conditionally. The next step depends on those exact outputs, so pin them down
rather than reconstructing them.

### Instruct continuation explicitly after the Skill call

A Skill call mid-workflow is the moment the calling model is most likely to stop, treating the sub-skill's output as its
own final answer. Counter it directly: end the step with an explicit instruction to proceed to the next step. Never rely
on implicit continuation. This is the single most common way an orchestration silently ends early.

### Declare the Skill tool in `allowed-tools`

A skill that invokes another skill lists `Skill` in its `allowed-tools` frontmatter, as every Han skill that invokes
`han-core:load-han-config` does. `allowed-tools` pre-approves a tool rather than gating it, so a missing entry does not
block the call, but in a permission mode that prompts it can put a prompt in front of the invocation. The grant is
cheap; carry it.

## Forked data-fetch composition (avoid)

Forked data-fetch composition is calling a sub-skill under `context: fork` only to retrieve a few structured values (a
docs directory, a test command, a config setting) for the calling skill to use immediately. **Do not do this.**
Discover the values inline instead, or surface them through an inline sub-skill under the exception below.

The failure mode is concrete and has been observed repeatedly. A forked data-fetch sub-skill (`context: fork`) returns
its values, and then an `api_retry` event can fire and anchor the calling model on the sub-skill's output as if it were
the final answer, bypassing every remaining workflow step. Adding explicit "proceed immediately, do not stop here"
wording and conventional defaults reduces but does not reliably eliminate it. The same shared config-reading sub-skill
broke multiple calling skills this way. The early-exit risk is not worth the small amount of discovery logic it saves.

### Prefer inline discovery

Instead of a data-fetch sub-skill, handle discovery and retrieval inside the skill's own steps:

1. Use context injection to detect config files (CLAUDE.md, project-discovery.md).
2. Read the file directly and extract the values you need in your own step logic.
3. Fall back to conventional defaults when a value is not found.

This eliminates the forked sub-skill entirely, and with it the `api_retry` interaction and the early-exit risk. See
[Writing Effective Instructions](./writing-effective-instructions.md) for a before/after example.

### Duplicate small discovery logic rather than sharing it through a skill

If two skills both need to find the docs directory, duplicate that handful of lines in each. A small amount of
duplicated discovery logic is far more reliable than a shared forked sub-skill. Reserve composition for orchestration,
where a whole substantial workflow, not a few values, is what you would otherwise be duplicating.

The duplication has a limit. When one discovery block is copied into many skills and has had to be re-swept, surface
it through an inline sub-skill under the exception below. Han's `.han/config.md` block is the worked example: it was
copied into every skill, swept four times in two months, and one sweep missed a skill and took it down. It is now
surfaced by `han-core:load-han-config`, and each consumer carries one line.

### The one exception: surfacing shared content inline

There is a single shape that looks like data-fetch but is supported, because it was validated on its own rather than
assumed: an **inline** sub-skill that surfaces shared content, a _standard or reference set_ or a _shared lookup's raw
results_, into the caller's context and then hands control straight back for the caller to apply. The motivating case is a guidance skill that reads one canonical
copy of a writing or review standard and surfaces it into whichever skill is about to produce output, so the standard
lives in one place instead of being vendored into every plugin that needs it.

Three properties separate this from the data-fetch pattern you should avoid:

1. **It is inline, never `context: fork`.** The documented early-exit failure is fork-specific: a forked sub-skill
   returns a value, an `api_retry` fires, and the caller anchors on that value as its final answer. An inline sub-skill
   renders into the shared context and never returns a value to anchor on. A dedicated spike ran a heavy consumer skill
   through an inline guidance skill many times, including a worst-case run with every continuation guardrail removed and
   a deliberately final-sounding closing line, and the caller resumed and finished every time with no early exit. The
   forked variant of the same skill was disqualified for a separate reason: the fork isolated the guidance so its
   content never reached the caller.
2. **It surfaces content many consumers would otherwise duplicate, and leaves interpretation to the caller.** A whole
   standard qualifies, and so does a shared lookup's raw result: `han-core:load-han-config` surfaces both
   `.han/config.md` files as they are, and the caller applies the config rule to them. Fetching one value for one skill
   is still inline discovery (above). The test is the same one orchestration uses: would every consumer otherwise carry
   a copy of this?
3. **The caller still owns and finishes its own workflow.** The sub-skill adds content to the context and returns; it
   does not produce the caller's deliverable. Keep an explicit "proceed to the next step" instruction after the
   invocation as cheap insurance, even though the spike completed without it.

One honest limit on that evidence: the spike could not induce a real `api_retry`, which is the specific trigger of the
forked failure. The worst-case run removed the mitigation `api_retry` is said to defeat and still held, so treat this
exception as reliable under adversarial same-context testing, not as proof the failure can never occur. If you reach for
it, keep the sub-skill inline, keep the continuation instruction, and use it only for genuinely shared content.

The values case was then measured on its own. A trial ran a heavy consumer through a project-skill copy of
`han-core:load-han-config` that surfaces `.han/config.md`, and then used every resolved setting: 99 same-context
trials across 15 arms, 93 of which invoked the loader
(inline, a worst-case loader ending on a final-sounding line with no caller-side guardrail, a chain of two inline
sub-skills, a depth-two call, direct invocation, a caller without a `Skill` grant in a permission mode that does not
prompt, and six configuration states), with zero early exits and every value applied as the config rule says. The record is under
`docs/plans/gh-203-consolidate-config-loading/artifacts/trial/`. The loader was then reduced to a single probe whose
script prints both files and the rule, and a second trial ran that shipped skill, installed from a local marketplace
and reached by its cross-plugin name, through 48 trials in 10 arms (the same composition shapes plus five
configuration states), again with zero early exits and every value applied; its record is under
`docs/plans/gh-203-consolidate-config-loading/artifacts/trial2/`. The same limits apply to both: no `api_retry` was
induced and one model was tested.

## The `context: fork` field

`context: fork` is a documented Claude Code feature (see the
[Skills documentation](https://code.claude.com/docs/en/skills) and the field inventory in
[Skill Frontmatter Fields](./skill-frontmatter-fields.md)). The guidance here is not that the field is unsupported. It
is that you should not lean on it for data-fetch sub-skills, because the early-exit failure above shows up repeatedly in
that pattern. Treat avoiding it for data-fetch as a considered choice, not an oversight.

## Deciding which way to go

Ask what you would be duplicating if you did not compose:

- **A whole user-facing workflow that owns an artifact** (a planning run, a documentation pass, a publish step):
  compose, using the orchestration discipline above. Duplicating an entire skill is worse than the cost of a careful
  Skill call.
- **A few values one skill needs** (paths, commands, settings): stay inline. Duplicate the small discovery logic. Do
  not reach for a sub-skill.
- **A shared lookup or standard that every consumer would otherwise carry a copy of**: an inline sub-skill may surface
  it into the caller's context, under the exception above. Keep it inline (never `context: fork`), keep an explicit
  continuation instruction after the call, and leave interpretation of what it surfaces to the caller.

Cross-references:

- [Skill Decomposition](./skill-decomposition.md). When to split skills.
- [Writing Effective Instructions](./writing-effective-instructions.md). Instruction clarity and the inline-discovery
  before/after.
- [Skill Frontmatter Fields](./skill-frontmatter-fields.md). The `context` field and `allowed-tools`.
