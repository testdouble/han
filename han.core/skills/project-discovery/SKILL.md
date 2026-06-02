---
name: project-discovery
description: >
  Discovers key attributes of the current code repository and its projects —
  languages, frameworks, tooling, configuration, documentation structure — and
  writes a static reference for other skills, agents, and hooks to consume. Use
  when scanning, analyzing, or detecting the project's technology stack, build
  tools, or repository structure. Does not create or update project
  documentation — use project-documentation for writing feature or system docs.

argument-hint: [output-file-path]
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(date *), Bash(mkdir *), Bash(git symbolic-ref *), Bash(find *)
---

## Project Context

- Default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- AGENTS.md: !`find . -maxdepth 1 -name "AGENTS.md" -type f`
- README: !`find . -maxdepth 1 -name "README*" -type f`

# Project Discovery

## Step 1: Discover Repository Structure

Launch a `han.core:project-scanner` agent to determine whether the repository contains one project or many, and what each project's boundaries are. Wait for the agent to complete.

From the agent's results, build a project list. Each entry has a project name (directory name, or repository name for root-level projects), root path, and dependency manifest path.

## Step 2: Explore Project Attributes

Launch 3 `han.core:project-scanner` agents in parallel, each with a different focus area. Include the project list from Step 1 in each agent's prompt so they know which roots to explore.

**Agent 1 — Languages, Frameworks, Dependencies:** For each project, read the dependency manifest to identify languages and version constraints. Determine the package manager from the lock file type. From dependencies, identify structural/architectural frameworks (web, frontend, test, ORM/database) — focus on frameworks that define how the project is built, not utility packages. Note runtime version requirements.

**Agent 2 — Build Tooling, Commands, Testing:** For each project, find the task runner or build definition and extract the actual commands for: installing dependencies, running tests, linting, building, dev server, formatting. Only record commands that actually exist. Find build/linter/formatter/type-checker config files. Find test configuration, test directories, and determine the test file naming pattern from existing test files. Find coverage tool configuration if any.

**Agent 3 — Documentation and Infrastructure:** Discover documentation directories — do not assume names like "docs". Find ADR directories, coding standards directories, CI/CD configuration, container configuration, git hook configuration, and environment/configuration file patterns.

After all 3 agents complete, merge their findings into a unified discovery summary. Deduplicate across agents, organize by project, and separate repository-level items (documentation, infrastructure) from project-level items (language, frameworks, tooling, commands, tests).

## Step 3: Reconcile Against Existing Documentation

**Skip this step if none of README, CLAUDE.md, or AGENTS.md exist** (all empty in project context above). Proceed directly to Step 4.

If any exist, read them and compare against the discovery results from Step 2. For each contradiction (e.g., README says `make test` but no Makefile was discovered), use `AskUserQuestion` to present the contradiction and ask which is correct: the existing documentation or the filesystem discovery. Update the discovery results based on the user's answer.

## Step 4: Write Discovery Output

This skill writes two outputs:

1. **Standalone file** — If the user provided an output file path as an argument, use that. Otherwise write to `docs/project-discovery.md` (create `docs/` with `mkdir -p` if needed).
2. **CLAUDE.md summary** — If CLAUDE.md exists, add or update a `## Project Discovery` section. If CLAUDE.md does not exist, skip this output.

Use `AskUserQuestion` to confirm the output locations before writing.

### Standalone File

Use the template at [template.md](references/template.md) as the structural guide. Rules: only include sections where information was actually discovered — omit empty sections entirely. Use `- {item type}: {concise info}` bullet format throughout. Format static assets as backtick-quoted paths relative to the repo root (e.g., `- lint config: \`.eslintrc.json\``). Commands must be actual commands that work in the project, not guesses. For multi-project repos, repeat the per-project section for each project.

### CLAUDE.md Summary

Add a `## Project Discovery` section with only what other skills need most, using the template at [claudemd-summary-template.md](references/claudemd-summary-template.md).

## Step 5: Verification

Read back the standalone output file and spot-check 2-3 discovered paths with Glob to confirm they exist. Verify no placeholder values remain (no `{...}` text), empty sections are omitted, and format follows the template's concise bullet style. If CLAUDE.md was updated, read it back and confirm the summary section is present and accurate.

Report to the user: number of projects discovered, languages and frameworks found, and output file location(s).
