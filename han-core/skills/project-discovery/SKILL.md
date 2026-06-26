---
name: project-discovery
description: >
  Discovers the core attributes of the current code repository and its projects —
  languages, frameworks, tooling, and where things live — and writes a concise
  reference section directly into the project's AGENTS.md or CLAUDE.md for other
  skills, agents, and hooks to consume. Use when scanning, analyzing, or detecting
  the project's technology stack, build tools, or repository structure. Does not
  create or update project documentation — use project-documentation for writing
  feature or system docs.
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(git symbolic-ref *), Bash(find *)
---

## Project Context

- Default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD`
- AGENTS.md: !`find . -maxdepth 1 -name "AGENTS.md" -type f`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- README: !`find . -maxdepth 1 -name "README*" -type f`

# Project Discovery

This skill discovers the project's core attributes and writes them as a concise
`## Project Discovery` section **directly into the project's AGENTS.md or
CLAUDE.md** — not a separate file. The output is small by design: a few notes on
where things live, the languages and frameworks, and the commands to run, so an
AI agent working in the repo can find its way around. It is not an exhaustive
inventory.

## Step 1: Choose and read the target file

Pick the single file this discovery is written into, by priority:

1. If **AGENTS.md** exists (the label above is non-empty), the target is AGENTS.md.
2. Otherwise, if **CLAUDE.md** exists, the target is CLAUDE.md.
3. If neither exists, the target is a new **CLAUDE.md** at the repository root, which you will create in Step 4.

If the target file already exists, read it in full and build the **deduplication
baseline**: a list of everything the file already documents that this skill would
otherwise write — directory and folder locations, languages, frameworks, package
manager, build/test/lint/dev commands, and the docs, ADR, and coding-standards
directories. Note whether the file already has a `## Project Discovery` section.

If the target is a new CLAUDE.md, there is nothing to deduplicate against.

## Step 2: Discover repository structure

Launch a `han-core:project-scanner` agent to determine whether the repository contains one project or many, and what each project's boundaries are. Wait for the agent to complete.

From the agent's results, build a project list. Each entry has a project name (directory name, or repository name for a root-level project), root path, and dependency manifest path.

## Step 3: Explore project attributes

Launch 3 `han-core:project-scanner` agents in parallel, each with a different focus area. Include the project list from Step 2 in each agent's prompt so they know which roots to explore. Keep each agent on the core facts an AI agent needs to navigate and run the project — not an exhaustive catalog of every config file.

**Agent 1 — Languages and Frameworks:** For each project, read the dependency manifest to identify languages and version constraints. Determine the package manager from the lock file type. From dependencies, identify the structural/architectural frameworks that define how the project is built (web, frontend, test, ORM/database). Ignore utility packages. Note runtime version requirements.

**Agent 2 — Commands:** For each project, find the task runner or build definition and extract the actual commands for installing dependencies, running tests, linting, building, and the dev server. Only record commands that actually exist — no guesses.

**Agent 3 — Layout:** Map where the important things live: the main source directory or directories, the test location, and the documentation, ADR, and coding-standards directories — do not assume names like "docs". Capture only the handful of directories someone needs to know to find their way around the repo; skip incidental files.

After all 3 agents complete, merge their findings, deduplicate across agents, and organize by project. Separate repository-level items (default branch, docs, ADRs, coding standards, layout) from project-level items (language, frameworks, package manager, commands).

## Step 4: Write the discovery into the target file

Build a concise `## Project Discovery` section using the template at [template.md](./references/template.md) as the structural guide.

Apply two filters before writing anything:

- **Deduplicate.** Drop every fact already present in the target file (the Step 1 baseline). Do not restate what the file already says, even in different words.
- **Drop empties.** Omit any line with no discovered value. Never leave a `{placeholder}` behind, and never invent a command or path that was not discovered.

If a discovered fact **contradicts** what the file already states (for example, the file says `make test` but no Makefile was discovered), use `AskUserQuestion` to surface the contradiction and ask which is correct — the existing file or the filesystem discovery. Update the content based on the answer.

Then write the result into the target file:

- **Target exists, no `## Project Discovery` section:** append the section at the end of the file (or another sensible location).
- **Target exists, already has a `## Project Discovery` section:** replace that section's body with the new, deduplicated content. Do not leave the old content alongside the new.
- **Neither AGENTS.md nor CLAUDE.md exists:** create CLAUDE.md at the repository root containing the section.

If, after deduplication, nothing meaningful remains to add, do **not** write an empty section. Tell the user the target file already covers the project's core attributes, and stop.

## Step 5: Verification

Read back the target file's `## Project Discovery` section. Confirm: no `{placeholder}` text remains, every bullet has a real discovered value, and nothing duplicates content stated elsewhere in the file. Spot-check 2-3 discovered paths or directories with Glob to confirm they exist.

Report to the user: the target file written (and whether it was created or updated), the number of projects discovered, and the languages and frameworks found.
