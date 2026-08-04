# Skill Conformance Checklist

Run this against one `SKILL.md` at a time. Every item is a yes/no question you answer by reading that single file, so
two reviewers checking the same skill reach the same answers. A `no` is a finding to correct.

Items that need a second file to answer are not here. They sit in
[cross-entity-checks.md](./cross-entity-checks.md), which runs once across the whole roster rather than per skill.

Each item cites the guidance file and section it comes from. When an item and its source disagree, the source wins and
this checklist is the thing to fix.

Guidance root for every citation below:
`han-plugin-builder/skills/guidance/references/`. Paths are shortened to `skill-building-guidance/{file}` and
`agent-building-guidelines/{file}`.

## Naming and file identity

| #   | Question                                                                                                                        | Source                                                     |
| --- | ------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| S1  | Is the file named exactly `SKILL.md`, uppercase name and lowercase extension?                                                   | `naming-conventions.md` § SKILL.md is case-sensitive       |
| S2  | Does the frontmatter `name` match the skill's directory name?                                                                   | `naming-conventions.md` § Skill `name` matches directory   |
| S3  | Is `name` lowercase letters, numbers, and hyphens only, at most 64 characters, with no leading, trailing, or doubled hyphen?     | `skill-frontmatter-fields.md` § Identity and triggering    |
| S4  | Is there no `README.md` in this skill's directory?                                                                              | `naming-conventions.md` § No README.md inside skill folders |
| S5  | If the skill requires an external tool or service, does the directory name signal that dependency?                              | `naming-conventions.md` § Skill directory names            |
| S6  | Does the name avoid an implementation verb that implies the wrong artifact type, preferring a gerund or process name?           | `naming-conventions.md` § Avoid names implying wrong type  |

## Frontmatter safety

| #   | Question                                                                                              | Source                                              |
| --- | ------------------------------------------------------------------------------------------------------ | ----------------------------------------------------- |
| S7  | Is every frontmatter field free of `<` and `>`?                                                       | `security-restrictions.md` § No XML angle brackets  |
| S8  | Is `name` free of the reserved words `claude` and `anthropic`?                                        | `security-restrictions.md` § No reserved prefixes   |
| S9  | Does the frontmatter use standard YAML types only, with no custom tags, aliases, or directives?       | `security-restrictions.md` § Safe YAML parsing only |
| S10 | Is any invocation-control field (`disable-model-invocation`, `user-invocable`) set on purpose?        | `skill-frontmatter-fields.md` § Invocation control  |

## Description content

| #   | Question                                                                                                           | Source                                                              |
| --- | -------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| S11 | Does the description say **what** the skill does?                                                                  | `skill-description-frontmatter.md` § Four components                |
| S12 | Does it say **when to use** it, naming user intents or situations?                                                 | `skill-description-frontmatter.md` § Four components                |
| S13 | Does it state a **boundary**, naming what should not trigger it?                                                   | `skill-description-frontmatter.md` § Four components                |
| S14 | Does it carry **trigger breadth**, the synonyms and alternative phrasings a real request would use?                | `skill-description-frontmatter.md` § Four components                |
| S15 | Is it at least three sentences, and not past five or six?                                                          | `skill-description-frontmatter.md` § Four components, Pitfalls      |
| S16 | Is it written in the third person, describing the skill rather than offering help?                                 | `skill-description-frontmatter.md` § Write in third person          |
| S17 | Are trigger words woven into sentences rather than appended as a bare keyword list?                                | `skill-description-frontmatter.md` § Weave trigger words            |
| S18 | Where sibling skills exist, does the boundary name them explicitly rather than gesturing at a scope limit?         | `skill-description-frontmatter.md` § Define boundaries              |
| S19 | If the skill needs an external tool or a precondition that affects which skill should run, does it say so?         | `skill-description-frontmatter.md` § Mention external requirements  |

## Description length

| #   | Question                                                                                                              | Source                                                    |
| --- | ----------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| S20 | Is the rendered description string under 1024 characters, measured on the string rather than the YAML around it?      | `skill-description-length.md` § The target                |
| S21 | Do the what and the primary triggers lead, with the lower-priority boundary clauses last where truncation costs least? | `skill-description-length.md` § What gets cut first        |
| S22 | Does the description hold no process detail, step list, or caveat that belongs in the body?                           | `skill-description-length.md` § When over the limit       |

## Body size and progressive disclosure

| #   | Question                                                                                                                  | Source                                                        |
| --- | --------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| S23 | Is the SKILL.md body at or under 500 lines?                                                                               | `progressive-disclosure.md` § Level 2                         |
| S24 | Does the body hold process steps rather than domain knowledge, with templates, checklists, rate tables, and decision matrices in `references/`? | `progressive-disclosure.md` § Keep body focused                |
| S25 | Is every rule in the body a judgment call rather than something a linter, formatter, or CI check already enforces?        | `progressive-disclosure.md` § When to remove entirely         |
| S26 | Are deterministic operations, such as JSON construction or format validation, in `scripts/` rather than described in prose? | `progressive-disclosure.md` § Use scripts/                     |
| S27 | Do reference files sit in `references/` rather than at the skill directory root?                                          | `skill-reference-files.md` § The Rule                         |
| S28 | Are files used in output but not needed as context in `assets/` rather than `references/`?                                | `skill-reference-files.md` § The assets/ Directory            |
| S29 | Are all file references one level deep from SKILL.md, with no reference that points at another reference?                 | `cowork-specific-skill-instructions.md` § Progressive patterns |

## Context hygiene

| #   | Question                                                                                                                       | Source                                                   |
| --- | -------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| S30 | Is the body free of filler prose that does not change what the skill produces?                                                 | `context-hygiene.md` § Every token must earn its place   |
| S31 | Are constraints and prerequisites front-loaded, with checklists and validation at the end, and no critical rule buried mid-body? | `context-hygiene.md` § Position critical content          |
| S32 | Does the body avoid restating context the platform already supplies, such as CLAUDE.md content or tool schemas?                | `context-hygiene.md` § Do not restate the platform       |
| S33 | Does every step act from a self-sufficient region, with no mapping the model must hold across several references at once?      | `context-hygiene.md` § Self-sufficient region            |
| S34 | Does every file path, script name, flag, and convention the body names still exist as named?                                   | `documentation-maintenance.md` § Doc-code contradictions |
| S35 | Is the body free of time-sensitive information that will read as wrong later?                                                  | `cowork-specific-skill-instructions.md` § Checklist      |
| S36 | Does the body use one term per concept throughout rather than switching between synonyms?                                      | `cowork-specific-skill-instructions.md` § Checklist      |

## Instruction quality

| #   | Question                                                                                                                | Source                                                            |
| --- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| S37 | Does every instruction say exactly what to do, with no vague directive a reader has to interpret?                       | `writing-effective-instructions.md` § Be specific and actionable  |
| S38 | Does every prohibition or requirement carry its reason, in the always-or-never plus because form?                       | `writing-effective-instructions.md` § Embedded reasoning          |
| S39 | Does every step that can fail say what to do when it does?                                                              | `writing-effective-instructions.md` § Include error handling      |
| S40 | Is every bundled resource referenced by exact path, with a line saying what it contains and how to use it?              | `writing-effective-instructions.md` § Reference bundled resources |
| S41 | Is each convention the skill enforces written as a heading, a one-line rule, and examples, rather than buried in prose? | `writing-effective-instructions.md` § Structure conventions       |
| S42 | Where a step drives several varying items, does each item carry its own resolved inputs rather than a matrix to join?   | `writing-effective-instructions.md` § Resolve variation           |
| S43 | Do the conventions the skill enforces carry two or three canonical examples, with the most representative last?         | `writing-effective-instructions.md` § Canonical examples          |

## Workflow structure

| #   | Question                                                                                                         | Source                                                  |
| --- | ------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------- |
| S44 | Are steps numbered, in dependency order, with the preconditions each one needs stated before it runs?            | `workflow-patterns.md` § Sequential orchestration       |
| S45 | Does every refinement loop carry a maximum pass count?                                                           | `workflow-patterns.md` § Iterative refinement           |
| S46 | Does every branch state its decision criteria and a fallback path when no condition matches?                     | `workflow-patterns.md` § Context-aware tool selection   |
| S47 | Does every pause for user confirmation sit before an irreversible action, with no more than two or three total?  | `workflow-patterns.md` § Human gates                    |
| S48 | Within each step, is the most critical instruction or most representative example last?                          | `workflow-patterns.md` § Recency bias                   |

## Tool permissions

| #   | Question                                                                                                | Source                                           |
| --- | --------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| S49 | Does each Bash command prefix have its own `Bash()` entry rather than several packed into one?          | `allowed-tools-bash-permissions.md` § Syntax     |
| S50 | Is the colon form absent, with a space before every wildcard?                                           | `allowed-tools-bash-permissions.md` § Syntax     |
| S51 | Is each prefix the narrowest one that covers what the skill actually runs?                              | `allowed-tools-bash-permissions.md` § Granularity |
| S52 | Is every `Bash()` entry used by the body, with no leftovers from an earlier draft?                      | `allowed-tools-bash-permissions.md` § Granularity |
| S53 | Is `Bash(find *)` present rather than `Bash(ls *)` where the skill detects files?                       | `allowed-tools-bash-permissions.md` § Prefer find |
| S54 | Is `AskUserQuestion` absent from `allowed-tools`?                                                       | `allowed-tools-AskUserQuestion.md` § The Rule    |
| S55 | Is `Skill` listed when the body invokes another skill, and `Agent` listed when the body dispatches one? | `skill-decomposition.md` § Composition Patterns  |
| S56 | Are script paths absent from `allowed-tools`, since prefix matching cannot resolve the expanded path?   | `script-execution-instructions.md` § Why not     |

## Context injection probes

| #   | Question                                                                                                                             | Source                                                       |
| --- | -------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| S57 | Does every probe sit under `## Pre-requisites` or `## Project Context`?                                                              | `context-injection-commands.md` § Section Placement          |
| S58 | Is each probe unique, with no command repeated across those two sections?                                                            | `context-injection-commands.md` § Section Placement          |
| S59 | Is every command, and every pipe stage or chain part, either an allowlisted read-only form or declared in `allowed-tools`?           | `context-injection-commands.md` § Auto-approvable form       |
| S60 | Is there no command substitution, process substitution, subshell, or background operator anywhere in a probe?                        | `context-injection-commands.md` § Four refused constructs    |
| S61 | Is there no `find` with `-exec`, `-execdir`, `-delete`, `-ok`, or `-fprint`, and no in-place `sed`?                                  | `context-injection-commands.md` § Four refused constructs    |
| S62 | Does every probe read only inside the project working directory, with any outside path resolved by `echo` and read by a Read step?   | `context-injection-commands.md` § Keep probes inside project |
| S63 | Does every command that exits non-zero when its subject is absent carry a trailing redirect-and-sentinel guard?                      | `context-injection-commands.md` § Summary items 3-4          |
| S64 | Is each tool-availability check written as a guarded `which`, rather than as a version flag?                                         | `dynamic-project-discovery.md` § Use which, guarded          |
| S65 | Is `find` used for file and directory detection rather than `ls`?                                                                    | `context-injection-commands.md` § Use find instead of ls     |
| S66 | Is every injected value bounded at the source rather than trimmed afterward, and is nothing trimmed that a step checks for completeness? | `context-injection-commands.md` § Keep each value small       |
| S67 | Is the literal bang-backtick pattern absent from the SKILL.md body prose, including inside code fences?                              | `context-injection-commands.md` § Never in prose             |
| S68 | Does the step logic handle the empty result and the sentinel value for every probe it reads?                                         | `context-injection-commands.md` § Referencing injected context |
| S69 | Are heredocs, JSON construction, and other multi-step operations in a script rather than in a probe?                                 | `context-injection-commands.md` § Use shell scripts          |

## Scripts

| #   | Question                                                                                                        | Source                                                      |
| --- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| S70 | Is every script invocation written as numbered prose with an action verb, rather than inside a fenced code block? | `script-execution-instructions.md` § The Correct Pattern    |
| S71 | Does every script path use the skill-directory variable rather than a bare relative path?                       | `script-execution-instructions.md` § How the variable works |
| S72 | Does the skill call only scripts in its own `scripts/` directory, never another skill's?                        | `script-execution-instructions.md` § Each skill owns its own |
| S73 | Does each step that runs a script describe what it is for rather than re-explaining what the script does?       | `hardening-fuzzy-vs-deterministic.md` § Hardening Process   |
| S74 | Is every deterministic step in a script, and every judgment step in the body?                                   | `hardening-fuzzy-vs-deterministic.md` § The Spectrum        |

## Composition and dispatch

| #   | Question                                                                                                                    | Source                                                  |
| --- | ----------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| S75 | Does the skill address a single concern rather than bundling independent ones?                                              | `skill-decomposition.md` § Single responsibility        |
| S76 | Is the body free of large inline agent definitions that belong in an `agents/` file?                                        | `skill-decomposition.md` § Extract inline agents        |
| S77 | Does the skill avoid calling another skill purely to retrieve a few values, doing that discovery inline instead?            | `skill-composition.md` § Data-fetch composition         |
| S78 | Where the skill invokes another skill, does the step end with an explicit instruction to proceed rather than relying on implicit continuation? | `skill-composition.md` § Instruct continuation           |
| S79 | Where the skill orchestrates another skill, does it stay thin, preflight its hard requirements, forward context verbatim, state overrides explicitly, and capture the exact outputs? | `skill-composition.md` § Orchestration composition       |
| S80 | Where the skill invokes an inline guidance sub-skill, is that sub-skill inline rather than forked?                          | `skill-composition.md` § The one exception              |
| S81 | Is every dispatched agent named with its defining plugin's namespace, in the tables, the prompts, and the prose alike?      | `agent-dispatch-namespacing.md` § Dispatch by namespace |
| S82 | Is no dispatch target prefixed with a meta-plugin that defines no agents?                                                   | `agent-dispatch-namespacing.md` § Never a meta-plugin   |
| S83 | Is every cross-reference to another skill namespaced the same way?                                                          | `agent-dispatch-namespacing.md` § Qualify cross-refs    |

## Delegation economics

| #   | Question                                                                                                       | Source                                             |
| --- | ------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------- |
| S84 | Does the skill state its delegation policy with a bounded count, rather than leaving the number to the model?  | `multi-agent-economics.md` § Say what warrants it  |
| S85 | Is there no dispatch whose purpose is verifying this skill's own work?                                         | `multi-agent-economics.md` § Say what warrants it  |
| S86 | Is any panel capped at about five agents?                                                                      | `multi-agent-economics.md` § Level 2 hard cap      |
| S87 | Are independent agents dispatched together in one message rather than one after another?                       | `multi-agent-economics.md` § Practical implications |
| S88 | Is no sequential chain of agents longer than three?                                                            | `multi-agent-economics.md` § Practical implications |
| S89 | Does the skill pass no model override at dispatch, letting each agent's own tier govern?                       | `agent-model-selection.md` § Scope                 |

## Degradation and discovery

| #   | Question                                                                                                                | Source                                                  |
| --- | ------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| S90 | Is no branch name hardcoded, with the default branch discovered instead?                                                | `dynamic-project-discovery.md` § Never hardcode branches |
| S91 | Is project structure discovered rather than assumed to exist at a conventional path?                                    | `dynamic-project-discovery.md` § Discover dynamically   |
| S92 | Does the Pre-requisites gate inform the user and stop when a hard requirement is missing?                               | `dynamic-project-discovery.md` § Handle missing tools   |
| S93 | Is environment detection done by a script that exits zero on every path, rather than by inline commands in the body?    | `graceful-degradation.md` § Detect with a script        |
| S94 | Are the execution modes named, and does the body route to them by name?                                                 | `graceful-degradation.md` § Named mode pattern          |
| S95 | Is a conventional default directory used only after confirming the directory exists?                                    | `graceful-degradation.md` § Conventional defaults       |
| S96 | For a skill that analyzes code, are all three git modes present: full branch diff, uncommitted work, and no git at all? | `optional-git-repositories.md` § Three modes            |
| S97 | Do user-supplied paths take precedence over git-detected scope?                                                         | `optional-git-repositories.md` § Priority Rule          |

## Per-model authoring

| #    | Question                                                                                                                | Source                                                     |
| ---- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| S98  | Is there no step that re-checks, double-checks, or verifies output the same run produced?                               | `per-model-authoring.md` § Instructions to leave out       |
| S99  | Is there no rule telling the model not to think or not to reason?                                                       | `per-model-authoring.md` § Instructions to leave out       |
| S100 | Is there no instruction to copy internal reasoning into the deliverable?                                                | `per-model-authoring.md` § Fable 5 and reasoning echo      |
| S101 | Is there no think-step-by-step phrasing and no instruction that assumes thinking can be toggled?                        | `per-model-authoring.md` § Thinking mode                   |
| S102 | Is there no limiting phrase that narrows what the model may notice, in place of reporting fully and filtering after?    | `per-model-authoring.md` § Instruction style               |
| S103 | Does the skill branch on no model identity and ship no per-model variant?                                               | `per-model-authoring.md` § Default to model-agnostic       |
| S104 | If the skill writes a file, does it state the deliverable's length and scope, or cite the shared rule that already does? | `per-model-authoring.md` § Written deliverables            |
| S105 | Does the skill state the progress-narration cadence it wants, where that matters?                                       | `per-model-authoring.md` § Progress narration              |
| S106 | Does the skill state when a correction to an earlier statement is worth narrating, where that matters?                  | `per-model-authoring.md` § Correction narration            |
| S107 | For a narrow task, does the skill constrain scope rather than leaving the model to extend it?                           | `per-model-authoring.md` § Scope                           |

## Entity type

| #    | Question                                                                                                                   | Source                                             |
| ---- | -------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| S108 | Can every path through this entity be flowcharted, making a skill the right entity type for it?                            | `plugin-entity-taxonomy.md` § Decision Heuristic   |
| S109 | Does the skill follow a fixed process, leaving the judgment calls to the agents it dispatches?                             | `plugin-entity-taxonomy.md` § Composition Rules    |
| S110 | Is the skill defined under `skills/{name}/SKILL.md` rather than as a flat file under a `commands/` directory?              | `plugin-entity-taxonomy.md` § Commands (Deprecated) |

## One guidance file with no items of its own

`troubleshooting.md` is organized by symptom rather than by rule, and every rule it states is owned by a file already
cited above: naming and casing by `naming-conventions.md`, reserved prefixes by `security-restrictions.md`, description
problems by `skill-description-frontmatter.md`, verbose and buried and ambiguous instructions by
`writing-effective-instructions.md`, stale content by `documentation-maintenance.md`, Bash entries by
`allowed-tools-bash-permissions.md`, the interactive-prompt bug by `allowed-tools-AskUserQuestion.md`, the classifier
refusal and the literal-syntax-in-prose failure by `context-injection-commands.md`, and lost sub-skill output by
`skill-composition.md`.

It produces no checklist item of its own, and that is not a coverage gap. Reach for it when a skill misbehaves and you
are working backward from the symptom, which is the job it does that a checklist cannot.

## Guidance that is not file-checkable

Three guidance files describe a process rather than a property of a finished file, so they produce no checklist item. A
review pass cannot answer them by reading a `SKILL.md`, and pretending otherwise would produce items nobody can mark.

- `use-case-planning.md` covers what to do before writing a skill: define two or three use cases, each naming the
  trigger, workflow, tools, and domain knowledge.
- `success-criteria-and-testing.md` covers triggering tests, functional tests, and performance comparison, all of which
  need runs rather than reads.
- `iterative-plugin-development.md` covers the three-to-five iteration cycle, the assumption review at each pass, and
  the eighty-percent overlap check that produces consolidation candidates.

The overlap check in that last file is the one thing here that touches this sweep: it is where consolidation candidates
come from, and the sweep records them without acting on them.
