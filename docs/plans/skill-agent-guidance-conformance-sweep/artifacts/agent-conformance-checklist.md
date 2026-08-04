# Agent Conformance Checklist

Run this against one agent `.md` file at a time. Every item is a yes/no question you answer by reading that single file.
A `no` is a finding to correct.

Items that need a second file to answer are not here. They sit in
[cross-entity-checks.md](./cross-entity-checks.md), which runs once across the whole roster rather than per agent.

Each item cites the guidance file and section it comes from. When an item and its source disagree, the source wins and
this checklist is the thing to fix.

Guidance root for every citation below:
`han-plugin-builder/skills/guidance/references/`. Paths are shortened to `agent-building-guidelines/{file}` and
`skill-building-guidance/{file}`.

## Self-containment

| #   | Question                                                                                                           | Source                                                |
| --- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| A1  | Does the file contain no link to a path outside itself?                                                            | `agent-external-files.md` § The Rule                  |
| A2  | Is there no `references/` or `scripts/` folder for this agent?                                                     | `agent-external-files.md` § The Rule                  |
| A3  | Is the context-injection bang-backtick syntax absent from the file?                                                | `agent-external-files.md` § The Rule                  |
| A4  | Are all protocols, strategies, and reference material written inline rather than pointed at?                       | `agent-external-files.md` § What to Do Instead        |

## Frontmatter

| #   | Question                                                                                                                | Source                                                     |
| --- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| A5  | Does the agent use `tools` rather than `allowed-tools`, and carry no `argument-hint`?                                   | `agent-external-files.md` § Comparison table               |
| A6  | Does the agent set none of the three fields a plugin agent silently drops: `hooks`, `mcpServers`, `permissionMode`?     | `agent-external-files.md` § Plugin agents ignore three      |
| A7  | Is the `Agent` tool absent, unless this agent's own body dispatches sub-agents?                                         | `agent-external-files.md` § Default to no Agent tool       |
| A8  | Does every tool in the allowlist get used somewhere in the body?                                                        | `agent-external-files.md` § Default to no Agent tool       |
| A9  | Is `model` set explicitly rather than left to the inherit default?                                                      | `agent-model-selection.md` § Summary Checklist             |
| A10 | Is `model` an alias rather than a pinned full model ID?                                                                 | `agent-model-selection.md` § The model Field               |

## Model tier

| #   | Question                                                                                                                             | Source                                                            |
| --- | -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| A11 | Does the tier match the agent's archetype: fast lookup and classification at the smallest, structured protocol work in the middle, open-ended synthesis at the largest? | `agent-model-selection.md` § Evidence from Agent Archetypes        |
| A12 | If the agent works from a named methodology, a fixed rubric, or a named anti-pattern list, has the middle tier been considered rather than assumed too small? | `specialization-and-model-selection.md` § How this shapes choices  |
| A13 | If the agent synthesizes across unbounded input the prompt cannot pre-shape, is it on the largest tier?                              | `specialization-and-model-selection.md` § How this shapes choices  |
| A14 | Was the tier chosen on what the task demands rather than on cost?                                                                    | `agent-model-selection.md` § A Note on Cost                        |

## Description

| #   | Question                                                                                                                    | Source                                                    |
| --- | ----------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| A15 | Is the rendered description under 1024 characters, measured on the string rather than the YAML around it?                   | `agent-description-length.md` § The target                |
| A16 | Is it well under roughly 1500 characters, the point at which a description is carrying body-grade content?                  | `agent-description-length.md` § The target                |
| A17 | Does it say what the agent does and when to invoke it?                                                                      | `agent-domain-focus.md` § Write a Clear Description       |
| A18 | Is domain vocabulary absent from the description, living in the body section instead?                                       | `agent-description-length.md` § What belongs where        |
| A19 | Are named frameworks, methodologies, and author citations absent from the description?                                      | `agent-description-length.md` § What belongs where        |
| A20 | Is the anti-pattern checklist absent from the description, living in the body section instead?                              | `agent-description-length.md` § What belongs where        |
| A21 | Does each boundary clause keep the sibling agent's name and drop the prose restating that sibling's scope?                  | `agent-description-length.md` § The load-bearing unit     |
| A22 | Do the what and the primary trigger survive, whatever else was cut?                                                         | `agent-description-length.md` § The priority ladder       |

## Role identity and body sections

| #   | Question                                                                                                            | Source                                                    |
| --- | ----------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| A23 | Is the opening role paragraph under 50 tokens?                                                                      | `agent-domain-focus.md` § Write a Concise Role Identity   |
| A24 | Does it state domain, task, and perspective, and nothing more?                                                      | `agent-domain-focus.md` § Write a Concise Role Identity   |
| A25 | Is the role paragraph free of flattery, superlatives, and motivational framing?                                     | `agent-domain-focus.md` § Avoid Flattery                  |
| A26 | Is there a `## Domain Vocabulary` section carrying 15 to 30 terms?                                                  | `agent-domain-focus.md` § Include a Domain Vocabulary     |
| A27 | Would a fifteen-year practitioner use each of those terms with a peer, rather than any being generic?               | `agent-domain-focus.md` § Vocabulary Routing              |
| A28 | Is there an `## Anti-Patterns` section carrying 5 to 10 named anti-patterns?                                        | `agent-domain-focus.md` § List Named Anti-Patterns        |
| A29 | Does each anti-pattern carry a detection signal, saying what to look for?                                           | `agent-domain-focus.md` § List Named Anti-Patterns        |
| A30 | Does the agent hold a single role, either producing output or evaluating it, never both?                            | `agent-domain-focus.md` § One Role per Agent              |

## Degradation

| #   | Question                                                                                                       | Source                                                 |
| --- | ------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------- |
| A31 | Does every step depending on an external tool check that the tool is available before attempting it?           | `agent-building-guidelines/graceful-degradation.md`    |
| A32 | Does each such step say to skip and note the limitation, rather than to fail?                                  | `agent-building-guidelines/graceful-degradation.md`    |
| A33 | Does the agent's output format include the note that says which step was skipped and why?                      | `agent-building-guidelines/graceful-degradation.md`    |

## Dispatch

| #   | Question                                                                                                     | Source                                                   |
| --- | ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| A34 | Is every agent name the body references written with its defining plugin's namespace?                        | `agent-dispatch-namespacing.md` § Scope note             |
| A35 | Is the agent not asked to verify the work of the skill that dispatched it?                                   | `multi-agent-economics.md` § Say what warrants delegation |

## Per-model authoring

| #   | Question                                                                                                       | Source                                                |
| --- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| A36 | Is there no step that re-checks, double-checks, or verifies output the same run produced?                      | `per-model-authoring.md` § Instructions to leave out  |
| A37 | Is there no rule telling the model not to think or not to reason?                                              | `per-model-authoring.md` § Instructions to leave out  |
| A38 | Is there no instruction to copy internal reasoning into the deliverable?                                       | `per-model-authoring.md` § Fable 5 and reasoning echo |
| A39 | Is there no limiting phrase that narrows what the agent may notice, in place of reporting fully?               | `per-model-authoring.md` § Instruction style          |
| A40 | If the agent writes a report, does it state the length and scope that report should have?                      | `per-model-authoring.md` § Written deliverables       |

## Entity type

| #   | Question                                                                                                                        | Source                                           |
| --- | --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| A42 | Does this entity require reasoning about context, making an agent the right entity type rather than a skill?                    | `plugin-entity-taxonomy.md` § Decision Heuristic |
| A43 | Does the agent apply judgment rather than walk a fixed flowchart that a skill should own?                                       | `plugin-entity-taxonomy.md` § Composition Rules  |
| A44 | Does the agent leave dispatching to the skills, unless its own protocol genuinely needs to dispatch a worker for a sub-task?    | `plugin-entity-taxonomy.md` § Composition Rules  |

## One rule applied by mechanism rather than by stated scope

The frontmatter injection rule in `security-restrictions.md` scopes itself to `**/skills/**/*.md`, so it does not name
agent files. The mechanism it describes is the same one: frontmatter reaches the system prompt, where angle brackets
carry meaning. Treat the item below as a reasonable extension rather than a stated rule, and note it as such if you act
on it.

| #   | Question                                              | Source                                                     |
| --- | ------------------------------------------------------- | ------------------------------------------------------------ |
| A41 | Is every frontmatter field free of `<` and `>`?       | `security-restrictions.md` § No XML angle brackets, by mechanism |
