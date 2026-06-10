# /project-discovery

Operator documentation for the `/project-discovery` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.core/skills/project-discovery/SKILL.md`](../../../han.core/skills/project-discovery/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md)

## TL;DR

- **What it does.** Scans the repository for languages, frameworks, tooling, and documentation structure, and writes a static reference other skills consume.
- **When to use it.** Before using any other han skill on a new project, or after a major stack change (new framework, new build tool, moved docs).
- **What you get back.** `docs/project-discovery.md` with everything the plugin needs to know about your repo, plus a short `## Project Discovery` section added to `CLAUDE.md`.

## Key concepts

- **Four-agent fan-out.** One `project-scanner` discovers project boundaries; three more run in parallel on Languages/Frameworks, Build/Test/Tooling, and Documentation/Infrastructure.
- **Reconciliation.** When the discovery results contradict existing README / CLAUDE.md / AGENTS.md content, the skill surfaces the contradiction and asks which is correct.
- **Dual output.** A full `docs/project-discovery.md` file plus a summary section in `CLAUDE.md`. Downstream skills (`/code-review`, `/coding-standard`, `/project-documentation`, `/architectural-decision-record`) read from both.
- **Only discovered data.** Empty sections are omitted entirely. No "{framework}" placeholders, no invented build commands. If a command wasn't found, it doesn't appear.
- **Multi-project aware.** Monorepos with multiple projects get one per-project block per project, plus repository-level items (docs, infrastructure) called out separately.

## When to use it

**Invoke when:**

- You are setting up a new repo with the han plugin and want every downstream skill to have project context.
- A major stack change landed (new language, new framework, new build tool, new docs root) and the existing `project-discovery.md` is stale.
- `/code-review` or `/coding-standard` is running without the context you expect. Often the project-discovery reference is missing or stale.
- You want to audit whether the team's README still matches the filesystem. The reconciliation step surfaces drift explicitly.

**Do not invoke for:**

- **Feature or system documentation.** Use [`/project-documentation`](./project-documentation.md) for describing how a specific feature works.
- **Architectural assessment.** Use [`/architectural-analysis`](../han.coding/architectural-analysis.md) for coupling, data flow, and SOLID.
- **Investigating why a skill found or did not find a config value.** That is a discovery bug. Re-run this skill.

## How to invoke it

Run `/project-discovery` in Claude Code. It scans by default. Pass an output path only if you want it somewhere other than `docs/project-discovery.md`.

Give it:

1. **A trigger.** The skill runs a full discovery pass and produces the outputs.
2. **An output file path, optional.** Default is `docs/project-discovery.md`.
3. **Confirmation on the CLAUDE.md summary.** The skill asks before writing the summary section.

Example prompts:

- `/project-discovery`. *"Scan this repo and document its technology stack."*
- `/project-discovery`. *"Detect the languages, frameworks, and build tools used in this project."*
- `/project-discovery docs/meta/repo-discovery.md`. *"Scan the repo and save the reference somewhere other than the default."*

## What you get back

Two artifacts plus an in-channel summary:

- **`docs/project-discovery.md`.** A structured reference with, per project: languages and version constraints, package manager, structural frameworks (web, frontend, test, ORM), runtime version, build/install/test/lint/format/typecheck commands, config file paths, test directories and naming patterns, coverage tool. Repository-level items: documentation directory, ADR directory, coding-standards directory, CI/CD configuration, container config, git-hook config, environment file patterns.
- **`## Project Discovery` in CLAUDE.md.** A short summary section with just the keys downstream skills need most (documentation root, ADR dir, coding-standards dir, test/lint/build commands, language).
- **In-channel summary.** Number of projects discovered, languages and frameworks found, output file locations.

## How to get the most out of it

- **Run it first, before anything else.** Every other han skill produces better output when `project-discovery.md` exists. Treat it as the setup step.
- **Re-run after stack changes.** When a new framework lands or docs move, re-run. The skill is cheap to re-dispatch.
- **Answer reconciliation questions carefully.** The skill surfaces contradictions between README/CLAUDE.md and the filesystem. *"Which is correct?"* matters. A wrong answer poisons every downstream skill's discovery.
- **Review the output.** The skill writes a file other skills trust. Skim it after it lands; correct anything obviously wrong before relying on it.
- **Pair with `/architectural-decision-record`** when the discovery surfaces an implicit decision (for example, *"we are on PostgreSQL because…"*) that was never recorded.

## Cost and latency

The skill dispatches four `project-scanner` agents: one sequentially (project boundaries), three in parallel (languages, tooling, docs/infrastructure). `project-scanner` runs on `sonnet`. For a medium-size monorepo, expect a minute or two of fan-out plus merge time. Cheap enough to re-run on every major stack change.

## In more detail

The skill walks a five-step process:

1. **Discover repository structure.** A single `project-scanner` determines whether the repo has one project or many, and identifies each project's root and dependency manifest.
2. **Explore project attributes.** Three parallel `project-scanner` agents: one on languages/frameworks/dependencies, one on build tooling and commands, one on documentation and infrastructure.
3. **Reconcile against existing documentation.** If README, CLAUDE.md, or AGENTS.md exist, read them. Surface contradictions and ask which is correct.
4. **Write discovery output.** Standalone file (default `docs/project-discovery.md`) plus CLAUDE.md summary.
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
- [`/project-documentation`](./project-documentation.md). For feature and system docs. Reads the discovery reference to find the right directory and language.
- [`/coding-standard`](../han.coding/coding-standard.md). For coding rules. Reads the discovery reference to find the standards directory.
- [`/architectural-decision-record`](./architectural-decision-record.md). For architectural decisions. Reads the discovery reference to find the ADR directory.
- [`/code-review`](../han.coding/code-review.md). Reads the discovery reference for lint/build/test commands and for standards and ADR compliance checks.
- [`project-scanner`](../../agents/han.core/project-scanner.md). The agent this skill dispatches.
- [`SKILL.md` for /project-discovery](../../../han.core/skills/project-discovery/SKILL.md). The internal process definition.
