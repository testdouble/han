---
paths:
  - "**/skills/**/*.md"
---

# Skill Composition

Skills can call other skills through the Skill tool. This is a real, supported
capability, and Han uses it in production. It also has sharp edges. Treat it as a
power tool: reach for it deliberately, with the safeguards below, and only when
the alternative is duplicating a whole skill's worth of work.

Two patterns hide under the word "composition," and they behave very differently:

- **Orchestration composition.** A thin calling skill hands the heavy work to a
  called skill that drives the rest of the output, and optionally chains into
  another skill afterward. **Supported. Use it with the discipline below.**
- **Data-fetch composition.** A skill calls another skill just to retrieve a few
  values (config paths, a command, a setting). **Avoid it. Do discovery inline
  instead.** The early-exit failure mode this caused is documented below and has
  not been reliably fixed by any frontmatter or instruction tuning.

Knowing which one you are reaching for is the whole decision. The rest of this
document is the guidance for each.

## Orchestration composition (supported, with care)

In orchestration composition the calling skill is a thin coordinator. It
validates inputs, then invokes a substantial sub-skill that owns a whole artifact
and drives the remaining output, optionally chaining that result into a second
sub-skill. The calling skill does almost no work of its own.

Han ships two live examples, and they run reliably:

- `han-atlassian:plan-a-feature-to-confluence` validates its inputs, runs
  `han-planning:plan-a-feature` to a temporary folder, gets the user's review and
  publish choice, then hands every file to `han-atlassian:markdown-to-confluence`
  to publish.
- `han-atlassian:project-documentation-to-confluence` does the same shape with
  `han-core:project-documentation` feeding `han-atlassian:markdown-to-confluence`.

These work because they follow a disciplined shape. If you compose skills, match
it.

### Keep the orchestrator thin

The calling skill should validate, forward, capture, and report, and almost
nothing else. The more logic the orchestrator carries across a Skill call, the
more likely it is to lose track of its own workflow after the sub-skill returns.
A thin orchestrator has little state to lose. Both Atlassian skills open by
stating plainly that "the steps below are the whole skill" and that they do not
do the called skill's job themselves. Copy that framing.

### Preflight hard requirements before any expensive sub-skill work

Validate everything that can fail cheaply before you spend a long sub-skill run.
The Confluence orchestrators check that the Atlassian MCP server is reachable as
their very first step, so a missing server fails in seconds rather than after a
full planning interview. Put your hard requirements (a connected MCP server, a
required destination, a needed input) ahead of the Skill call, not after it.

### Forward the user's context verbatim

When you invoke the sub-skill, pass the user's request, the `size` argument, known
constraints, and the relevant conversation context through unchanged. Do not
summarize, trim, or reinterpret it. The goal is that the sub-skill runs exactly as
it would if the user had invoked it directly. `plan-a-feature-to-confluence` is
explicit about this: it forwards "all provided context verbatim" so the planning
skill's interview, review team, and synthesis all run normally.

### Give the sub-skill explicit overrides, not silent assumptions

If the orchestration needs the sub-skill to behave differently in one respect,
say so in the invocation. The Confluence orchestrators tell `plan-a-feature` to
write under `/tmp/` rather than into the repo, and not to prompt the user to
choose an output location, because the orchestrator owns that decision. State each
override as one explicit instruction in the Skill call. Do not assume the
sub-skill will infer it.

### Capture the sub-skill's exact outputs

After the sub-skill finishes, record the precise paths or values it produced
before you move on. `plan-a-feature-to-confluence` captures the exact `/tmp/`
paths of every file written, and accounts for the one companion artifact that is
created only conditionally. The next step depends on those exact outputs, so pin
them down rather than reconstructing them.

### Instruct continuation explicitly after the Skill call

A Skill call mid-workflow is the moment the calling model is most likely to stop,
treating the sub-skill's output as its own final answer. Counter it directly: end
the step with an explicit instruction to proceed to the next step. Never rely on
implicit continuation. This is the single most common way an orchestration
silently ends early.

### Declare the Skill tool in `allowed-tools`

A skill that invokes another skill must list `Skill` in its `allowed-tools`
frontmatter (both Atlassian orchestrators do). Without it the Skill call is not
permitted.

## Data-fetch composition (avoid)

Data-fetch composition is calling a sub-skill only to retrieve a few structured
values (a docs directory, a test command, a config setting) for the calling
skill to use immediately. **Do not do this.** Discover the values inline instead.

The failure mode is concrete and has been observed repeatedly. A forked
data-fetch sub-skill (`context: fork`) returns its values, and then an `api_retry`
event can fire and anchor the calling model on the sub-skill's output as if it
were the final answer, bypassing every remaining workflow step. Adding explicit
"proceed immediately, do not stop here" wording and conventional defaults reduces
but does not reliably eliminate it. The same shared config-reading sub-skill broke
multiple calling skills this way. The early-exit risk is not worth the small
amount of discovery logic it saves.

### Prefer inline discovery

Instead of a data-fetch sub-skill, handle discovery and retrieval inside the
skill's own steps:

1. Use context injection to detect config files (CLAUDE.md, project-discovery.md).
2. Read the file directly and extract the values you need in your own step logic.
3. Fall back to conventional defaults when a value is not found.

This eliminates the forked sub-skill entirely, and with it the `api_retry`
interaction and the early-exit risk. See
[Writing Effective Instructions](./writing-effective-instructions.md) for a
before/after example.

### Duplicate small discovery logic rather than sharing it through a skill

If two skills both need to find the docs directory, duplicate that handful of
lines in each. A small amount of duplicated discovery logic is far more reliable
than a shared data-fetch sub-skill. Reserve composition for orchestration, where a
whole substantial workflow, not a few values, is what you would otherwise be
duplicating.

## The `context: fork` field

`context: fork` is a documented Claude Code feature (see the [Skills
documentation](https://code.claude.com/docs/en/skills) and the field inventory in
[Skill Frontmatter Fields](./skill-frontmatter-fields.md)). The guidance here is
not that the field is unsupported. It is that you should not lean on it for
data-fetch sub-skills, because the early-exit failure above shows up repeatedly in
that pattern. Treat avoiding it for data-fetch as a considered choice, not an
oversight.

## Deciding which way to go

Ask what you would be duplicating if you did not compose:

- **A whole user-facing workflow that owns an artifact** (a planning run, a
  documentation pass, a publish step): compose, using the orchestration
  discipline above. Duplicating an entire skill is worse than the cost of a
  careful Skill call.
- **A few values** (paths, commands, settings): stay inline. Duplicate the small
  discovery logic. Do not reach for a sub-skill.

Cross-references:
- [Skill Decomposition](./skill-decomposition.md). When to split skills.
- [Writing Effective Instructions](./writing-effective-instructions.md). Instruction clarity and the inline-discovery before/after.
- [Skill Frontmatter Fields](./skill-frontmatter-fields.md). The `context` field and `allowed-tools`.
