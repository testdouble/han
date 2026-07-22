# han: Project Map

Han is a Claude Code plugin suite for solo (or small-team) product engineers. It packages evidence-based planning, deep
code review, investigation, and documentation workflows into deterministic slash commands that dispatch specialist
sub-agents to do the judgment-heavy work. The suite ships as a family of plugins: `han-communication` (the foundational
plugin beneath every other: it owns the single canonical readability standard and writing-voice profile, the inline
`readability-guidance` skill that surfaces them, the `edit-for-readability` skill, and the `readability-editor` agent;
it depends on nothing and every prose-producing plugin depends on it), `han-core` (the shared foundation: the
specialist agent roster the rest of the suite dispatches — every shared agent except the `readability-editor` and the
`research-analyst` — plus the `project-discovery` skill and the canonical rule files; depends on `han-communication`),
`han-documentation` (the documentation skills: `project-documentation`, `architectural-decision-record`, and `runbook`;
depends on `han-communication` and `han-core` and is bundled by the `han` meta-plugin), `han-research` (the
pre-planning knowledge-work skills — `research`, `gap-analysis`, and `issue-triage` — plus the `research-analyst`
agent; depends on `han-communication` and `han-core` and is bundled by the `han` meta-plugin), `han-planning` (the
planning skills you reach for before
implementation: specifying with `plan-a-feature`, planning the build with `plan-implementation`, sequencing it with
`plan-a-phased-build`, breaking it into work with `plan-work-items`, and stress-testing plans with
`iterative-plan-review`; depends on `han-communication` and `han-core` and is bundled by the `han` meta-plugin),
`han-coding` (the coding skills
you reach for while working in code: writing it with `tdd` and `refactor`, plus reviewing, overviewing, analyzing,
testing, investigating, and standardizing it with `code-review`, `code-overview`, `architectural-analysis`,
`automated-test-planning`, `manual-test-planning`, `investigate`, and `coding-standard`; depends on `han-communication` and `han-core` and is bundled by
the `han` meta-plugin),
`han-github` (GitHub-facing skills), `han-reporting` (reporting and summary skills; depends only on
`han-communication`), `han` (a meta-plugin that installs `han-communication`, `han-core`, `han-documentation`,
`han-research`, `han-planning`, `han-coding`, `han-github`, and `han-reporting` via dependencies),
`han-feedback` (an opt-in plugin carrying the post-session feedback skill, which depends on no other Han plugin and is
deliberately _not_ bundled by the `han` meta-plugin, so it is installed separately), `han-atlassian` (an opt-in plugin
carrying the Atlassian skills — Confluence publishing and work-items-to-Jira — which depends on `han-core`,
`han-documentation`, `han-planning`, and `han-coding` because its wrapper skills run skills from each, requires a
configured Atlassian MCP server, and is likewise _not_ bundled by the `han` meta-plugin), `han-linear` (an opt-in
plugin carrying the work-items-to-Linear skill, which depends on no other Han plugin, requires a configured Linear MCP
server, and is likewise _not_ bundled by the `han` meta-plugin), and `han-plugin-builder` (an opt-in plugin carrying
the guidance for building skills
and plugins, plus the interview-driven `skill-builder` and `agent-builder` skills that author a new skill or agent from
scratch and review it against that guidance; it depends on nothing and is also deliberately _not_ bundled by the `han`
meta-plugin).

## Creating skills, agents, or other plugin aspects

All skill creation, agent definitions, and other plugin assets must use the appropriate
[han-plugin-builder guidance](./han-plugin-builder/skills/guidance/) markdown files, and / or the appropriate
han-plugin-builder skill:

- `/han-plugin-builder:skill-builder` for building skills
- `/han-plugin-builder:agent-builder` for building agents
- `/han-plugin-builder:guidance` for all other plugin aspects

## Repository layout

```
/                       # repo root
├── README.md           # End-user landing page
├── CONTRIBUTING.md     # Contributor guide
├── CLAUDE.md           # This file
├── CHANGELOG.md        # Version history
├── .claude-plugin/
│   └── marketplace.json   # Test Double marketplace manifest (lists han, han-communication, han-core, han-documentation, han-research, han-planning, han-coding, han-github, han-reporting, han-feedback, han-atlassian, han-linear, han-plugin-builder)
├── han/                # Meta-plugin: no components of its own; depends on han-communication + han-core + han-documentation + han-research + han-planning + han-coding + han-github + han-reporting
│   ├── README.md       # Light meta-plugin front door (no skills/agents sections)
│   └── .claude-plugin/
│       └── plugin.json
├── han-communication/  # Foundational plugin: readability-guidance + edit-for-readability skills, readability-editor agent, and the canonical readability-rule.md + writing-voice.md (depends on nothing; every prose-producing plugin depends on it)
│   ├── README.md       # Light front door + scent-line skill and agent lists
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── .codex-plugin/
│   │   └── plugin.json
│   ├── agents/         # readability-editor agent definition
│   ├── skills/         # readability-guidance (inline, surfaces the standard) + edit-for-readability
│   ├── docs/           # In-plugin long-form docs: docs/skills/{name}.md + docs/agents/readability-editor.md
│   └── references/     # Canonical readability-rule.md + writing-voice.md (owned here; no vendored copies elsewhere)
├── han-core/           # Core plugin: the shared specialist agent roster (all agents except readability-editor and research-analyst) + project-discovery (depends on han-communication)
│   ├── README.md       # Light front door; skills and agents grouped by purpose
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── agents/         # Agent definitions (.md with frontmatter)
│   ├── skills/         # project-discovery skill directory, with SKILL.md + references/
│   ├── docs/           # In-plugin long-form docs: docs/skills/{name}.md + docs/agents/{name}.md
│   └── references/     # Cross-skill reference files (e.g. yagni-rule.md, evidence-rule.md — canonical copies)
├── han-documentation/  # Documentation plugin: project-documentation, architectural-decision-record, runbook (depends on han-communication and han-core; bundled by the han meta-plugin)
│   ├── README.md       # Light front door + scent-line skills list
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/         # Documentation skill directories, each with SKILL.md + references/
│   ├── docs/           # In-plugin long-form docs: docs/skills/{name}.md
│   └── references/     # Cross-skill reference files vendored for han-documentation skills (yagni-rule.md, evidence-rule.md)
├── han-research/       # Research plugin: research, gap-analysis, issue-triage + the research-analyst agent (depends on han-communication and han-core; bundled by the han meta-plugin)
│   ├── README.md       # Light front door + scent-line skills and agent lists
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── agents/         # research-analyst agent definition
│   ├── skills/         # Research skill directories, each with SKILL.md + references/
│   ├── docs/           # In-plugin long-form docs: docs/skills/{name}.md + docs/agents/research-analyst.md
│   └── references/     # Cross-skill reference files vendored for han-research skills (yagni-rule.md, evidence-rule.md)
├── han-planning/       # Planning plugin: plan-a-feature, plan-implementation, plan-a-phased-build, plan-work-items, iterative-plan-review (the skills for planning before implementation; depends on han-communication and han-core; bundled by the han meta-plugin)
│   ├── README.md       # Light front door + scent-line skills list
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/         # Planning skill directories, each with SKILL.md + references/
│   ├── docs/           # In-plugin long-form docs: docs/skills/{name}.md
│   └── references/     # Cross-skill reference files vendored for han-planning skills (yagni-rule.md, evidence-rule.md)
├── han-coding/         # Coding plugin: tdd, refactor, code-review, code-overview, architectural-analysis, automated-test-planning, manual-test-planning, investigate, coding-standard (the skills for working in code; depends on han-communication and han-core; bundled by the han meta-plugin)
│   ├── README.md       # Light front door + scent-line skills list
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/         # Coding-facing skill directories, each with SKILL.md + references/ (+ scripts/ where used)
│   ├── docs/           # In-plugin long-form docs: docs/skills/{name}.md
│   └── references/     # Cross-skill reference files vendored for han-coding skills (yagni-rule.md, evidence-rule.md)
├── han-github/         # GitHub plugin: post-code-review-to-pr, update-pr-description, work-items-to-issues (depends on han-communication for the readability standard)
│   ├── README.md       # Light front door + scent-line skills list
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/         # GitHub-facing skill directories, each with SKILL.md + scripts/
│   └── docs/           # In-plugin long-form docs: docs/skills/{name}.md
├── han-reporting/      # Reporting plugin: stakeholder-summary, html-summary (depends on han-communication for the readability standard)
│   ├── README.md       # Light front door + scent-line skills list
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/         # Reporting skill directories, each with SKILL.md + references/ (html-summary adds scripts/ + assets/)
│   └── docs/           # In-plugin long-form docs: docs/skills/{name}.md
├── han-feedback/       # Opt-in feedback plugin: han-feedback (depends on no other Han plugin; NOT bundled by the han meta-plugin)
│   ├── README.md       # Light front door + scent-line skills list
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/         # Feedback skill directory (han-feedback) with SKILL.md
│   └── docs/           # In-plugin long-form docs: docs/skills/han-feedback.md
├── han-atlassian/      # Opt-in Atlassian plugin: markdown-to-confluence, project-documentation-to-confluence, investigate-to-confluence, code-overview-to-confluence, plan-a-feature-to-confluence, work-items-to-jira (depends on han-core, han-documentation, han-planning, han-coding; requires the Atlassian MCP server; NOT bundled by the han meta-plugin). Carries README.md + docs/skills/ like the other layers.
├── han-linear/         # Opt-in Linear plugin: work-items-to-linear (depends on no other Han plugin; requires the Linear MCP server; NOT bundled by the han meta-plugin)
│   ├── README.md       # Light front door + scent-line skills list
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/         # Linear skill directory, with SKILL.md + references/
│   └── docs/           # In-plugin long-form docs: docs/skills/work-items-to-linear.md
├── han-plugin-builder/ # Opt-in plugin-building plugin: guidance, skill-builder, agent-builder (depends on nothing; NOT bundled by the han meta-plugin)
│   ├── README.md       # Light front door + scent-line skills list
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/         # guidance skill (SKILL.md + assets/ + scripts/ + references/, the authoring guidance by topic); skill-builder and agent-builder (SKILL.md each, the interview-driven builders)
│   └── docs/           # In-plugin long-form docs: docs/skills/{name}.md
├── docs/               # Operator-facing documentation (cross-plugin surfaces; long-form docs now live in each plugin)
│   ├── concepts.md
│   ├── quickstart.md
│   ├── sizing.md
│   ├── yagni.md
│   ├── workflows.md    # The map of which skills chain together, with mermaid flow diagrams
│   ├── choosing-a-han-plugin.md   # The plugin index (scent + link to each plugin README) and install guide
│   ├── agents/         # Agents index README only (long-form agent docs moved into their plugins)
│   ├── skills/         # Skills index README only (long-form skill docs moved into their plugins)
│   ├── how-to/         # End-to-end workflow guides (planning, bugs, research)
│   ├── templates/      # Templates and coverage rule for long-form docs
│   ├── plans/          # Plan documents (one folder per plan; nested research lives inside)
│   └── research/       # Standalone research reports not tied to a specific plan
└── images/             # Banner and graphics for README
```

The plugins are shipped from `han-communication/`, `han-core/`, `han-documentation/`, `han-research/`,
`han-planning/`, `han-coding/`, `han-github/`, `han-reporting/`, `han-feedback/`, `han-atlassian/`, `han-linear/`, and
`han-plugin-builder/`; the `han/` meta-plugin pulls in `han-communication`, `han-core`, `han-documentation`,
`han-research`, `han-planning`, `han-coding`, `han-github`, and `han-reporting` through its `dependencies`.
`han-communication` is the foundational layer beneath every other plugin: it depends on nothing and owns the single
canonical readability standard, and every plugin that produces prose output (`han-core`, `han-documentation`,
`han-research`, `han-planning`, `han-coding`, `han-github`, `han-reporting`, and the opt-in `han-atlassian`) declares a
direct dependency on it. `han-documentation`, `han-research`, `han-planning`, and `han-coding` depend on
`han-communication` and `han-core` and are bundled by the meta-plugin, as are `han-github` and `han-reporting`
(`han-reporting` depends only on `han-communication`). `han-feedback`, `han-atlassian`, and `han-linear` are
deliberately left out of the meta-plugin, so each is opt-in and installed on its own: `han-atlassian` depends on
`han-communication`, `han-core`, `han-documentation`, `han-planning`, and `han-coding` and requires a configured
Atlassian MCP server; `han-feedback` and `han-linear` depend on no other Han plugin, and `han-linear` requires a
configured Linear MCP server. `han-plugin-builder` depends on nothing and is likewise opt-in and installed on its own. The
contributor-facing authoring guidance (how to build skills, agents, and plugins) lives inside
`han-plugin-builder/skills/guidance/references/`, not under `docs/`; running the `guidance` skill with `init` vendors
all three plugin-building skills into any repo's `.claude/skills/` under a `plugin-` prefix (`plugin-guidance`,
`plugin-skill-builder`, and `plugin-agent-builder`, so they never collide with this plugin's own slash commands), plus a
path-scoped rule index, so the skills run and the guidance surfaces with no dependency on the plugin being installed.
The same plugin also ships those two interview-driven builder skills, `skill-builder` and `agent-builder`, that walk the
design tree for a new skill or agent decision-by-decision and then review the finished artifact against that guidance.
Documentation is plugin-first: each plugin carries a light front-door `README.md` and its own long-form docs. Long-form
docs in `{plugin}/docs/skills/{name}.md` and `{plugin}/docs/agents/{name}.md` (agents only in `han-core`,
`han-communication`, and `han-research`) are the canonical operator-facing source for every skill and every agent,
sitting beside that plugin's README. The cross-plugin surfaces stay under repo-root `docs/`: the alphabetized skills
and agents indexes (`docs/skills/README.md`, `docs/agents/README.md`), the plugin index
(`docs/choosing-a-han-plugin.md`), and the workflows composition map (`docs/workflows.md`). The underlying definition
(`han-communication/skills/{name}/SKILL.md`, `han-core/skills/{name}/SKILL.md`,
`han-documentation/skills/{name}/SKILL.md`, `han-research/skills/{name}/SKILL.md`,
`han-planning/skills/{name}/SKILL.md`, `han-coding/skills/{name}/SKILL.md`, `han-github/skills/{name}/SKILL.md`,
`han-reporting/skills/{name}/SKILL.md`, `han-feedback/skills/{name}/SKILL.md`, `han-atlassian/skills/{name}/SKILL.md`,
`han-linear/skills/{name}/SKILL.md`, `han-core/agents/{name}.md`, `han-communication/agents/{name}.md`, or
`han-research/agents/research-analyst.md`) is the implementation.

## When to use which doc

This section does not need to list docs for all the skills, agents, etc. Only docs that are relevant to using an agent
such as Claude, shnould be referenced here.

### Entry points

- **[README.md](./README.md).** End-user landing page. Use to understand what the plugin is and where to start. Lists
  install instructions and pointers to every other doc.
- **[CONTRIBUTING.md](./CONTRIBUTING.md).** Contributor guide for adding or editing skills, agents, and documentation.
  Read before changing any file under `han-core/`, `han-github/`, or `docs/`.
- **[CHANGELOG.md](./CHANGELOG.md).** Version history. Check when a behavior or skill name in user-supplied context
  doesn't match what's on disk. May be a pre-2.0 rename or a removed feature.

### Writing voice

- **[han-communication/references/writing-voice.md](./han-communication/references/writing-voice.md).** Voice profile
  every doc in the plugin follows. No em-dashes, direct second person, plainspoken mentor tone, named voice violations
  to avoid. Single canonical copy in the foundational `han-communication` plugin; no vendored copies. Consuming skills
  source it cross-plugin by invoking `han-communication:readability-guidance`.

### Templates (`docs/templates/`)

- **[docs/templates/skill-long-form-template.md](./docs/templates/skill-long-form-template.md).** Template for a new
  skill's long-form doc.
- **[docs/templates/agent-long-form-template.md](./docs/templates/agent-long-form-template.md).** Template for a new
  agent's long-form doc.
- **[docs/templates/coverage-rule.md](./docs/templates/coverage-rule.md).** The rule: every skill and every agent gets a
  long-form doc.

## Conventions

- **One canonical source per concept.** The long-form doc in `{plugin}/docs/skills/` or `{plugin}/docs/agents/` is
  canonical for that skill or agent, and the plugin's `README.md` is canonical for what the plugin does. The other
  surfaces (plugin README scent line, skills or agents index, plugin index) carry a one-sentence scent plus a link that
  reuses the long-form doc's own summary line, never a second copy of the content.
- **Every long-form doc links up.** The first bullet of the "Related documentation" section points to the doc's adjacent
  plugin README, then the repository root.
- **Voice is uniform.** Every doc follows
  [han-communication/references/writing-voice.md](./han-communication/references/writing-voice.md). No em-dashes, direct
  second person, no flattery or hype.
- **YAGNI applies to docs too.** Don't add speculative sections, for-future-flexibility warnings, or examples for
  behavior the skill doesn't have. The same evidence rule that gates plan steps gates docs.
- **Indexes stay complete, not counted.** Every skill in `han-communication/skills/`, `han-core/skills/`,
  `han-documentation/skills/`, `han-research/skills/`, `han-planning/skills/`, `han-coding/skills/`,
  `han-github/skills/`, `han-reporting/skills/`, `han-feedback/skills/`, `han-atlassian/skills/`, `han-linear/skills/`,
  and `han-plugin-builder/skills/` has a long-form doc in its plugin's `docs/skills/`, a scent line in its plugin's
  `README.md`, and an entry in the skills index (`docs/skills/README.md`); same for agents in `han-core/agents/`,
  `han-communication/agents/`, and `han-research/agents/` (long-form docs in `{plugin}/docs/agents/`, indexed in
  `docs/agents/README.md`). Verify the indexes list every entity when editing them, rather than tracking a running
  total.
