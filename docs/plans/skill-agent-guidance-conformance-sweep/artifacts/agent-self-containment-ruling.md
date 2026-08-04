# Ruling: Agent Self-Containment

**The policy: remove the link, state the rule content the agent acts on inline, and name the canonical rule in plain
text.** Apply this to all eleven agents that currently link out to a shared rule file. The user chose it on 2026-07-31,
during the run that produced this sweep's work items.

## What was decided against

Three alternatives were weighed and rejected. Recording them here so a later reader does not reopen the question without
new information.

- **Copying the full rule text into each agent.** The YAGNI rule runs 138 lines and the evidence rule 112. Eleven copies
  of either will drift apart, and nobody owns keeping them in sync. This is the outcome the repository's
  one-canonical-source-per-concept convention exists to prevent.
- **Changing nothing and recording the deviation.** Cheapest, and it leaves eleven agents carrying an instruction
  phrased as though they can open a file they cannot reach.
- **Amending the guidance to permit a plain-text citation.** This changes the standard rather than the agents. The sweep
  measures against that standard while it runs, so moving it mid-run is what the last work item exists to avoid.

## The problem being fixed

Eleven agents contain a sentence of the form "Apply the canonical evidence rule defined in {link}." The link is written
relative to the agent's own file. An agent runs inside the user's project rather than inside the plugin folder, so that
path resolves to nothing and the agent cannot follow it.

Nothing fails today, because the paragraph beside each link already states the part of the rule that agent acts on. The
link is useful to a person maintaining the file and inert to the model reading it.

Two things are wrong with that, and the fix addresses both. The agent-building guidance requires an agent file to be
entirely self-contained, with no external file reference of any kind. And the instruction is phrased as a direction to
open something, which is a direction the agent cannot carry out.

## What to do in each agent

1. **Delete the hyperlink.** No markdown link to a path outside the agent file survives.
2. **Rewrite the sentence so it states an action rather than a lookup.** "Apply the canonical evidence rule defined in
   {link}" becomes a direct statement of what the agent does. The agent should never be told to open a file it cannot
   reach.
3. **Complete the inline content.** Keep the existing paragraph and fill the gap where it states less than this agent
   actually needs. Judge that gap against what the agent does, not against the rule file's table of contents.
4. **Name the canonical rule in plain text.** Write the rule's name so a person maintaining the file can find the
   canonical copy, without a link the model will read as an instruction.

## What "the content the agent acts on" means

Bring across the part of the rule this agent applies. Not the whole rule, and not a summary of it.

The rule files carry material that exists for their own readers: the rationale for each principle, the history of where
the vocabulary came from, cross-references to sibling rules, and sections saying what the rule is not. None of that
changes what an agent does, and copying it is how eleven copies become eleven divergent copies.

A worked test: the evidence rule defines three trust classes, a corroboration gate scoped to web sources, and a
no-evidence labeling response. An agent that cites codebase evidence and occasionally web context needs all three, plus
what each trust class means and the fact that the gate does not apply to codebase claims. It does not need the paragraph
explaining that the proximity-to-origin principle is a heuristic rather than a ranked tier list, unless that agent ranks
sources.

## The drift this accepts

Eleven agents will each state their slice of a shared rule in their own words. Those statements can drift from the
canonical rule as it changes.

That is a real cost and it is the reason this decision needed a person. Two things reduce it. The slices are small and
operative, so there is less surface to drift than a full copy would have. And each agent names the canonical rule in
plain text, so a person changing that rule can find every agent that states part of it with a single search on the
rule's name.

## Sites to convert

Twenty-eight link sites across eleven agents, all under `han-core/agents/`.

| Agent                        | Sites |
| ---------------------------- | ----- |
| `data-engineer`              | 4     |
| `devops-engineer`            | 4     |
| `junior-developer`           | 3     |
| `project-manager`            | 3     |
| `software-architect`         | 3     |
| `system-architect`           | 3     |
| `edge-case-explorer`         | 2     |
| `on-call-engineer`           | 2     |
| `test-engineer`              | 2     |
| `evidence-based-investigator` | 1     |
| `gap-analyzer`               | 1     |

`gap-analyzer` was converted first, as the proving case, because it carries one site.

## Sources

- `han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-external-files.md`, which requires an
  agent file to be self-contained.
- `CLAUDE.md`, for the one-canonical-source-per-concept convention that made this a decision rather than a mechanical
  fix.
- `artifacts/scope-boundary.md`, whose direction-of-travel answer keeps all 24 agents in existence.
