# project-scanner

Operator documentation for the `project-scanner` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/project-scanner.md`](../../../han.core/agents/project-scanner.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md)

## TL;DR

- **What it does.** Scans a code repository to discover project-level attributes: languages, frameworks, tooling, configuration, documentation structure, and infrastructure. Reads config files and directory structure, not source code.
- **When to dispatch it.** A repository needs a stack-and-tooling inventory. Always dispatched by `/project-discovery` (one for project-boundary discovery plus three in parallel for languages/frameworks, tooling/commands, and docs/infrastructure).
- **What you get back.** Numbered `D#` discovery items, each with a category (Language / Framework / Tooling / Command / Test / Documentation / Infrastructure / Configuration), the file path where the discovery was found, and a concise description.

## Key concepts

- **Reads config, not code.** The agent's primary sources are dependency manifests (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Gemfile`, `pom.xml`, `build.gradle`, `*.csproj`, `mix.exs`), lock files, build configs, linter configs, and task-runner definitions. Source-code inference is an anti-pattern.
- **No predefined language list.** The agent adapts to what it finds. A Crystal project, a Zig project, a Pony project all work the same way. The agent reads manifests, not assumptions.
- **Negative results matter.** When a category was searched and nothing was found, the agent says so. *"No CI configuration found"* is real signal.
- **Path per finding.** Every discovery cites the file path it came from. *"This project uses Rust"* is not a finding. *"`Cargo.toml:3` declares Rust edition 2021"* is.
- **Concise.** One-line findings when possible. The agent is optimized for breadth over depth.

## When to use it

**Dispatch when:**

- `/project-discovery` is running. The skill always dispatches four of these in sequence and parallel: one to determine project boundaries, then three more in parallel for languages/frameworks, build/test/tooling, and docs/infrastructure.
- You want a quick stack inventory for an unfamiliar repository.
- A team is auditing whether the project's README still matches the filesystem (the agent's output is the comparison point).

**Do not dispatch for:**

- Feature or system implementation discovery. Use `codebase-explorer`.
- Code-level analysis. Use the architectural analysts.
- Bug investigation. Use `evidence-based-investigator`.
- Writing project documentation. Use `/project-discovery` (which dispatches this agent and writes the output) or `/project-documentation`.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:project-scanner`. Give it:

1. **A project root.** A directory to scan. The agent does not assume the repository root is the project root (a monorepo has many).
2. **A focus area, optional.** *"Languages and frameworks,"* *"build tooling and commands,"* *"documentation and infrastructure."* Lets multiple scanners in parallel divide the work cleanly.

Example prompts:

- *"Scan the project at `apps/web/`. Focus on languages, frameworks, and dependencies."*
- *"Scan the repository root for documentation directories and infrastructure files."*

## What you get back

- Numbered `D#` discovery items, each with: category, file path, and a concise description.
- A **Scan Summary** with total files read, categories covered, categories where nothing was found, and any areas where the project structure was ambiguous.

## How to get the most out of it

- **Use it through `/project-discovery`.** The skill orchestrates four scanners and reconciles their output against existing README / CLAUDE.md / AGENTS.md content. Direct dispatch is reasonable for quick stack lookups but loses the reconciliation step.
- **Split focus areas across parallel dispatches.** Two scanners with the same focus area duplicate work. Three scanners with different focus areas cover more ground per minute.
- **Trust the "nothing found" results.** When the agent reports *"no CI configuration found,"* that is a real attribute of the project, not a search failure.

## Cost and latency

The agent runs on `haiku` (cheap, fast). A focused scan runs in well under a minute. The agent is designed for parallel dispatch and tight-loop re-runs as the project evolves.

## Sources

The agent's discipline is grounded in modern repository-convention discovery.

### The Twelve-Factor App

The methodology's emphasis on explicit declaration of dependencies, config, and build/run separation informs what the agent looks for: dependency manifests, environment file patterns, explicit commands.

URL: https://12factor.net/

### Google: Repository Topology Best Practices

Google's monorepo guidance informs the agent's multi-project handling: scan per project root, plus repository-level resources.

URL: https://research.google/pubs/why-google-stores-billions-of-lines-of-code-in-a-single-repository/

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [Agents Index](../README.md). All agents, grouped by role.
- [`codebase-explorer`](./codebase-explorer.md). Sibling for feature-level implementation discovery.
- [`/project-discovery`](../../skills/han.core/project-discovery.md). Always dispatches four of these agents.
