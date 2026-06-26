# /project-discovery

Operator documentation for the `/project-discovery` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-core/skills/project-discovery/SKILL.md`](../../../han-core/skills/project-discovery/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md)

## TL;DR

- **What it does.** Scans the repository for languages, frameworks, tooling, and where things live, then writes a concise `## Project Discovery` section directly into your AGENTS.md or CLAUDE.md.
- **When to use it.** Before using any other han skill on a new project, or after a major stack change (new framework, new build tool, moved docs).
- **What you get back.** A short `## Project Discovery` section added to the project's AGENTS.md (first choice) or CLAUDE.md (created if neither exists), holding only the core facts other skills need.

## Key concepts

- **Writes into the file that matters.** The discovery lands directly in AGENTS.md or CLAUDE.md, not a separate `project-discovery.md`. That is where the information is most useful: in front of every agent and skill that already reads those files.
- **Target priority.** AGENTS.md is the first choice. If there is no AGENTS.md, the skill writes to CLAUDE.md. If neither exists, it creates CLAUDE.md at the repository root.
- **Concise by design.** The output is a few small notes: where the important folders are, the languages and frameworks, and the commands to run. A large repo no longer produces a large discovery. It is a navigation aid, not an exhaustive inventory.
- **No duplication.** The skill reads the target file first and drops any fact the file already states. It will not restate your layout, stack, or commands if they are already documented. If after deduplication nothing new remains, it writes nothing and tells you the file already covers it.
- **Reconciliation.** When the discovery contradicts existing content (for example, the file says `make test` but no Makefile was found), the skill surfaces the contradiction and asks which is correct.
- **Multi-project aware.** Monorepos get repository-level bullets (default branch, docs, ADRs, coding standards, layout) plus one compact per-project block for each project's stack and commands.

## When to use it

**Invoke when:**

- You are setting up a new repo with the han plugin and want every downstream skill to have project context.
- A major stack change landed (new language, new framework, new build tool, new docs root) and the existing Project Discovery section is stale.
- `/code-review` or `/coding-standard` is running without the context you expect. Often the Project Discovery section is missing or stale.
- You want to audit whether your AGENTS.md / CLAUDE.md still matches the filesystem. The reconciliation step surfaces drift explicitly.

**Do not invoke for:**

- **Feature or system documentation.** Use [`/project-documentation`](./project-documentation.md) for describing how a specific feature works.
- **Architectural assessment.** Use [`/architectural-analysis`](../han-coding/architectural-analysis.md) for coupling, data flow, and SOLID.
- **Investigating why a skill found or did not find a config value.** That is a discovery bug. Re-run this skill.

## How to invoke it

Run `/project-discovery` in Claude Code. It takes no arguments. The skill scans the repo and writes the result into the target file it picks by priority: AGENTS.md, then CLAUDE.md, then a new CLAUDE.md if neither exists.

What it does, in order:

1. **Picks and reads the target file.** AGENTS.md first, then CLAUDE.md. It reads whichever exists so it knows what is already documented.
2. **Runs the discovery.** A full scan of boundaries, stack, and layout.
3. **Writes the deduplicated section.** It adds or updates the `## Project Discovery` section, omitting anything the file already says, and asks you about any contradiction it finds.

Example prompts:

- `/project-discovery`. *"Scan this repo and record its core attributes."*
- `/project-discovery`. *"Detect the languages, frameworks, and build commands and put them in AGENTS.md."*

## What you get back

One artifact plus an in-channel summary:

- **A `## Project Discovery` section in AGENTS.md or CLAUDE.md.** A short, scannable reference holding only the core facts an agent needs: where the important directories live (source, tests, docs, ADRs, coding standards), the language and version, the package manager, the structural frameworks, and the install / test / lint / build / dev commands. Anything already documented elsewhere in the file is left out. For monorepos, one compact block per project.
- **In-channel summary.** Whether the target file was created or updated, the number of projects discovered, and the languages and frameworks found.

## How to get the most out of it

- **Run it first, before anything else.** Every other han skill produces better output when the Project Discovery section exists. Treat it as the setup step.
- **Re-run after stack changes.** When a new framework lands or docs move, re-run. The skill is cheap to re-dispatch, and it updates the existing section in place rather than duplicating it.
- **Answer reconciliation questions carefully.** The skill surfaces contradictions between the file and the filesystem. *"Which is correct?"* matters. A wrong answer poisons every downstream skill's discovery.
- **Review the output.** The skill writes into a file other skills trust. Skim the section after it lands; correct anything obviously wrong before relying on it.
- **Pair with `/architectural-decision-record`** when the discovery surfaces an implicit decision (for example, *"we are on PostgreSQL because…"*) that was never recorded.

## Cost and latency

The skill dispatches four `project-scanner` agents: one sequentially (project boundaries), three in parallel (languages and frameworks, commands, layout). `project-scanner` runs on `sonnet`. For a medium-size monorepo, expect a minute or two of fan-out plus merge time. Cheap enough to re-run on every major stack change.

## In more detail

The skill walks a five-step process:

1. **Choose and read the target file.** Pick the file by priority (AGENTS.md, then CLAUDE.md, then a new CLAUDE.md). Read whichever exists to build the deduplication baseline of what is already documented.
2. **Discover repository structure.** A single `project-scanner` determines whether the repo has one project or many, and identifies each project's root and dependency manifest.
3. **Explore project attributes.** Three parallel `project-scanner` agents: one on languages and frameworks, one on commands, one on layout (the directories worth knowing about).
4. **Write the discovery into the target file.** Build a concise `## Project Discovery` section, drop every fact the file already states, ask about any contradiction, then add or update the section in place. If nothing new remains, write nothing.
5. **Verification.** Spot-check a few discovered paths with Glob, confirm no placeholders remain, report results to you.

## Sources

The skill's practice is grounded in modern repository-convention discovery.

### The Twelve-Factor App

The twelve-factor methodology's rules about explicit declaration of dependencies, config, and build/run separation shape what the skill looks for: dependency manifests, explicit commands, environment file patterns. The skill's bias toward "record only what was found" follows twelve-factor's insistence on explicit declaration over implicit assumption.

URL: https://12factor.net/

### Google: Repository Topology Best Practices

Google's engineering-practices documentation on monorepo organization informed the skill's multi-project handling: per-project blocks for project-level items and repository-level blocks for shared resources like docs and CI.

URL: https://research.google/pubs/why-google-stores-billions-of-lines-of-code-in-a-single-repository/

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/project-documentation`](./project-documentation.md). For feature and system docs. Reads the discovery section to find the right directory and language.
- [`/coding-standard`](../han-coding/coding-standard.md). For coding rules. Reads the discovery section to find the standards directory.
- [`/architectural-decision-record`](./architectural-decision-record.md). For architectural decisions. Reads the discovery section to find the ADR directory.
- [`/code-review`](../han-coding/code-review.md). Reads the discovery section for lint/build/test commands and for standards and ADR compliance checks.
- [`project-scanner`](../../agents/han-core/project-scanner.md). The agent this skill dispatches.
- [`SKILL.md` for /project-discovery](../../../han-core/skills/project-discovery/SKILL.md). The internal process definition.
