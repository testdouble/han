# han: Project Map

Han is a Claude Code plugin suite for solo (or small-team) product engineers. It packages evidence-based planning, deep code review, investigation, and documentation workflows into deterministic slash commands that dispatch specialist sub-agents to do the judgment-heavy work. The suite ships as a family of plugins: `han-core` (the research, analysis, documentation, and operations skills plus all the agents the rest of the suite dispatches), `han-planning` (the planning skills you reach for before implementation: specifying with `plan-a-feature`, planning the build with `plan-implementation`, sequencing it with `plan-a-phased-build`, breaking it into work with `plan-work-items`, and stress-testing plans with `iterative-plan-review`; depends on `han-core` and is bundled by the `han` meta-plugin), `han-coding` (the coding skills you reach for while working in code: writing it with `tdd` and `refactor`, plus reviewing, overviewing, analyzing, testing, investigating, and standardizing it with `code-review`, `code-overview`, `architectural-analysis`, `test-planning`, `investigate`, and `coding-standard`; depends on `han-core` and is bundled by the `han` meta-plugin), `han-github` (GitHub-facing skills), `han-reporting` (reporting and summary skills), `han` (a meta-plugin that installs `han-core`, `han-planning`, `han-coding`, `han-github`, and `han-reporting` via dependencies), `han-feedback` (an opt-in plugin carrying the post-session feedback skill, which depends on `han-core` but is deliberately *not* bundled by the `han` meta-plugin, so it is installed separately), `han-atlassian` (an opt-in plugin carrying the Atlassian skills — Confluence publishing and work-items-to-Jira — which depends on `han-core`, `han-planning`, and `han-coding` because its wrapper skills run skills from each, requires a configured Atlassian MCP server, and is likewise *not* bundled by the `han` meta-plugin), `han-linear` (an opt-in plugin carrying the work-items-to-Linear skill, which depends on `han-core`, requires a configured Linear MCP server, and is likewise *not* bundled by the `han` meta-plugin), and `han-plugin-builder` (an opt-in plugin carrying the guidance for building skills and plugins, plus the interview-driven `skill-builder` and `agent-builder` skills that author a new skill or agent from scratch and review it against that guidance; it depends on nothing and is also deliberately *not* bundled by the `han` meta-plugin).

## Repository layout

```
/                       # repo root
├── README.md           # End-user landing page
├── CONTRIBUTING.md     # Contributor guide
├── CLAUDE.md           # This file
├── CHANGELOG.md        # Version history
├── .claude-plugin/
│   └── marketplace.json   # Test Double marketplace manifest (lists han, han-core, han-planning, han-coding, han-github, han-reporting, han-feedback, han-atlassian, han-linear, han-plugin-builder)
├── han/                # Meta-plugin: no components of its own; depends on han-core + han-planning + han-coding + han-github + han-reporting
│   └── .claude-plugin/
│       └── plugin.json
├── han-core/           # Core plugin: research, analysis, documentation, operations + all agents
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── agents/         # Agent definitions (.md with frontmatter)
│   ├── skills/         # Skill directories, each with SKILL.md + references/
│   └── references/     # Cross-skill reference files (e.g. yagni-rule.md)
├── han-planning/       # Planning plugin: plan-a-feature, plan-implementation, plan-a-phased-build, plan-work-items, iterative-plan-review (the skills for planning before implementation; depends on han-core; bundled by the han meta-plugin)
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/         # Planning skill directories, each with SKILL.md + references/
│   └── references/     # Cross-skill reference files vendored for han-planning skills (yagni-rule.md, evidence-rule.md)
├── han-coding/         # Coding plugin: tdd, refactor, code-review, architectural-analysis, test-planning, investigate, coding-standard (the skills for working in code; depends on han-core; bundled by the han meta-plugin)
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/         # Coding-facing skill directories, each with SKILL.md + references/ (+ scripts/ where used)
│   └── references/     # Cross-skill reference files vendored for han-coding skills (yagni-rule.md, evidence-rule.md)
├── han-github/         # GitHub plugin: post-code-review-to-pr, update-pr-description, work-items-to-issues
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/         # GitHub-facing skill directories, each with SKILL.md + scripts/
├── han-reporting/      # Reporting plugin: stakeholder-summary, html-summary
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/         # Reporting skill directories, each with SKILL.md + references/ (html-summary adds scripts/ + assets/)
├── han-feedback/       # Opt-in feedback plugin: han-feedback (depends on han-core; NOT bundled by the han meta-plugin)
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/         # Feedback skill directory (han-feedback) with SKILL.md
├── han-atlassian/      # Opt-in Atlassian plugin: markdown-to-confluence, project-documentation-to-confluence, investigate-to-confluence, code-overview-to-confluence, plan-a-feature-to-confluence, work-items-to-jira (depends on han-core, han-planning, han-coding; requires the Atlassian MCP server; NOT bundled by the han meta-plugin)
├── han-linear/         # Opt-in Linear plugin: work-items-to-linear (depends on han-core; requires the Linear MCP server; NOT bundled by the han meta-plugin)
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/         # Linear skill directory, with SKILL.md + references/
├── han-plugin-builder/ # Opt-in plugin-building plugin: guidance, skill-builder, agent-builder (depends on nothing; NOT bundled by the han meta-plugin)
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/         # guidance skill (SKILL.md + assets/ + scripts/ + references/, the authoring guidance by topic); skill-builder and agent-builder (SKILL.md each, the interview-driven builders)
├── docs/               # Operator-facing documentation
│   ├── writing-voice.md   # Voice profile every doc follows
│   ├── concepts.md
│   ├── quickstart.md
│   ├── sizing.md
│   ├── yagni.md
│   ├── agents/         # Long-form docs for all agents, plus README
│   ├── skills/         # Long-form docs for all skills, plus README
│   ├── how-to/         # End-to-end workflow guides (planning, bugs, research)
│   ├── templates/      # Templates and coverage rule for long-form docs
│   ├── plans/          # Plan documents (one folder per plan; nested research lives inside)
│   └── research/       # Standalone research reports not tied to a specific plan
└── images/             # Banner and graphics for README
```

The plugins are shipped from `han-core/`, `han-planning/`, `han-coding/`, `han-github/`, `han-reporting/`, `han-feedback/`, `han-atlassian/`, `han-linear/`, and `han-plugin-builder/`; the `han/` meta-plugin pulls in `han-core`, `han-planning`, `han-coding`, `han-github`, and `han-reporting` through its `dependencies`. `han-planning` and `han-coding` depend on `han-core` like the GitHub and reporting layers and are bundled by the meta-plugin. `han-feedback`, `han-atlassian`, and `han-linear` depend on `han-core` like the other layers but are deliberately left out of the meta-plugin, so each is opt-in and installed on its own (`han-atlassian` additionally requires a configured Atlassian MCP server, and `han-linear` a configured Linear MCP server). `han-plugin-builder` depends on nothing and is likewise opt-in and installed on its own. The contributor-facing authoring guidance (how to build skills, agents, and plugins) lives inside `han-plugin-builder/skills/guidance/references/`, not under `docs/`; running the `guidance` skill with `init` vendors all three plugin-building skills into any repo's `.claude/skills/` under a `plugin-` prefix (`plugin-guidance`, `plugin-skill-builder`, and `plugin-agent-builder`, so they never collide with this plugin's own slash commands), plus a path-scoped rule index, so the skills run and the guidance surfaces with no dependency on the plugin being installed. The same plugin also ships those two interview-driven builder skills, `skill-builder` and `agent-builder`, that walk the design tree for a new skill or agent decision-by-decision and then review the finished artifact against that guidance. Documentation lives in `docs/` and covers the whole suite. Long-form docs in `docs/skills/{plugin}/{name}.md` and `docs/agents/han-core/{name}.md` are the canonical operator-facing source for every skill and every agent. The underlying definition (`han-core/skills/{name}/SKILL.md`, `han-planning/skills/{name}/SKILL.md`, `han-coding/skills/{name}/SKILL.md`, `han-github/skills/{name}/SKILL.md`, `han-reporting/skills/{name}/SKILL.md`, `han-feedback/skills/{name}/SKILL.md`, `han-atlassian/skills/{name}/SKILL.md`, `han-linear/skills/{name}/SKILL.md`, or `han-core/agents/{name}.md`) is the implementation.

## When to use which doc

This section does not need to list docs for all the skills, agents, etc. Only docs that are relevant to using an agent such as Claude, shnould be referenced here.

### Entry points

- **[README.md](./README.md).** End-user landing page. Use to understand what the plugin is and where to start. Lists install instructions and pointers to every other doc.
- **[CONTRIBUTING.md](./CONTRIBUTING.md).** Contributor guide for adding or editing skills, agents, and documentation. Read before changing any file under `han-core/`, `han-github/`, or `docs/`.
- **[CHANGELOG.md](./CHANGELOG.md).** Version history. Check when a behavior or skill name in user-supplied context doesn't match what's on disk. May be a pre-2.0 rename or a removed feature.

### Writing voice

- **[docs/writing-voice.md](./docs/writing-voice.md).** Voice profile every doc in the plugin follows. No em-dashes, direct second person, plainspoken mentor tone, named voice violations to avoid.

### Templates (`docs/templates/`)

- **[docs/templates/skill-long-form-template.md](./docs/templates/skill-long-form-template.md).** Template for a new skill's long-form doc.
- **[docs/templates/agent-long-form-template.md](./docs/templates/agent-long-form-template.md).** Template for a new agent's long-form doc.
- **[docs/templates/coverage-rule.md](./docs/templates/coverage-rule.md).** The rule: every skill and every agent gets a long-form doc.

## Conventions

- **One canonical source per concept.** The long-form doc in `docs/skills/` or `docs/agents/` is canonical for that skill or agent. Index entries carry one-sentence scent plus a link. The README never duplicates long-form content.
- **Every long-form doc links up.** The first bullet of the "Related Documentation" section always points back to the README at the repo root.
- **Voice is uniform.** Every doc follows [docs/writing-voice.md](./docs/writing-voice.md). No em-dashes, direct second person, no flattery or hype.
- **YAGNI applies to docs too.** Don't add speculative sections, for-future-flexibility warnings, or examples for behavior the skill doesn't have. The same evidence rule that gates plan steps gates docs.
- **Indexes stay complete, not counted.** Every skill in `han-core/skills/`, `han-planning/skills/`, `han-coding/skills/`, `han-github/skills/`, `han-reporting/skills/`, `han-feedback/skills/`, `han-atlassian/skills/`, `han-linear/skills/`, and `han-plugin-builder/skills/` has a long-form doc in `docs/skills/` and an entry in the skills index; same for agents in `han-core/agents/` and `docs/agents/`. Verify the indexes list every entity when editing them, rather than tracking a running total.
