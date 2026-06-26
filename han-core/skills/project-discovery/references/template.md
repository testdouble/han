<!--
This is the structure for the `## Project Discovery` section that the skill
writes into the project's AGENTS.md or CLAUDE.md. It is a concise reference, not
an exhaustive inventory: the core facts an AI agent needs to find its way around
the repo and run it. Keep it short.

Two hard rules when filling it in:
- Omit any fact already stated elsewhere in the target file. Do not restate it.
- Omit any bullet with no discovered value. Never leave a {placeholder} behind.

For a single-project repo, use the flat list below. For a monorepo, keep the
repository-level bullets (default branch, docs, ADRs, coding standards, layout)
and add one `### {Project}` block per project for its stack and commands.
-->

## Project Discovery

- Default branch: {branch}
- Docs: `{docs-dir}`
- ADRs: `{adr-dir}`
- Coding standards: `{standards-dir}`
- Layout: `{path}` ({what lives here}); `{path}` ({what lives here})
- Language: {language} {version}
- Package manager: {package-manager}
- Frameworks: {framework}, {framework}
- Install: `{command}`
- Test: `{command}`
- Lint: `{command}`
- Build: `{command}`
- Dev: `{command}`

<!--
Monorepo variant: keep the repository-level bullets above (default branch, docs,
ADRs, coding standards, layout), then repeat this block per project. Omit any
line with no discovered value.

### {Project Name}

- Root: `{path}`
- Language: {language} {version}
- Package manager: {package-manager}
- Frameworks: {framework}, {framework}
- Install: `{command}`
- Test: `{command}`
- Lint: `{command}`
- Build: `{command}`
- Dev: `{command}`
-->
