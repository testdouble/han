# han: Project Map

Han is a Claude Code plugin suite for solo (or small-team) product engineers. It packages evidence-based planning, deep code review, investigation, and documentation workflows into deterministic slash commands that dispatch specialist sub-agents to do the judgment-heavy work. The suite ships as a family of plugins: `han.core` (the skills and agents), `han.github` (GitHub-facing skills), `han.reporting` (reporting and summary skills), `han` (a meta-plugin that installs `han.core`, `han.github`, and `han.reporting` via dependencies), `han.feedback` (an opt-in plugin carrying the post-session feedback skill, which depends on `han.core` but is deliberately *not* bundled by the `han` meta-plugin, so it is installed separately), `han.atlassian` (an opt-in plugin carrying the Atlassian skills — Confluence documentation and work-items-to-Jira — which depends on `han.core`, requires a configured Atlassian MCP server, and is likewise *not* bundled by the `han` meta-plugin), `han.linear` (an opt-in plugin carrying the work-items-to-Linear skill, which depends on `han.core`, requires a configured Linear MCP server, and is likewise *not* bundled by the `han` meta-plugin), and `han.plugin-builder` (an opt-in plugin carrying the guidance for building skills and plugins; it depends on nothing and is also deliberately *not* bundled by the `han` meta-plugin).

## Repository layout

```
/                       # repo root
├── README.md           # End-user landing page
├── CONTRIBUTING.md     # Contributor guide
├── CLAUDE.md           # This file
├── CHANGELOG.md        # Version history
├── .claude-plugin/
│   └── marketplace.json   # Test Double marketplace manifest (lists han, han.core, han.github, han.reporting, han.feedback, han.atlassian, han.linear, han.plugin-builder)
├── han/                # Meta-plugin: no components of its own; depends on han.core + han.github + han.reporting
│   └── .claude-plugin/
│       └── plugin.json
├── han.core/           # Core plugin: planning, investigation, review, documentation
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── agents/         # Agent definitions (.md with frontmatter)
│   ├── skills/         # Skill directories, each with SKILL.md + references/
│   └── references/     # Cross-skill reference files (e.g. yagni-rule.md)
├── han.github/         # GitHub plugin: post-code-review-to-pr, update-pr-description, work-items-to-issues
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/         # GitHub-facing skill directories, each with SKILL.md + scripts/
├── han.reporting/      # Reporting plugin: stakeholder-summary, html-summary
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/         # Reporting skill directories, each with SKILL.md + references/ (html-summary adds scripts/ + assets/)
├── han.feedback/       # Opt-in feedback plugin: han-feedback (depends on han.core; NOT bundled by the han meta-plugin)
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/         # Feedback skill directory (han-feedback) with SKILL.md
├── han.atlassian/      # Opt-in Atlassian plugin: markdown-to-confluence, project-documentation-to-confluence, work-items-to-jira (depends on han.core; requires the Atlassian MCP server; NOT bundled by the han meta-plugin)
├── han.linear/         # Opt-in Linear plugin: work-items-to-linear (depends on han.core; requires the Linear MCP server; NOT bundled by the han meta-plugin)
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/         # Atlassian skill directories, each with SKILL.md + references/
├── han.plugin-builder/ # Opt-in plugin-building plugin: the guidance skill (depends on nothing; NOT bundled by the han meta-plugin)
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/         # guidance skill: SKILL.md + assets/ + scripts/ + references/ (the authoring guidance, by topic)
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

The plugins are shipped from `han.core/`, `han.github/`, `han.reporting/`, `han.feedback/`, `han.atlassian/`, `han.linear/`, and `han.plugin-builder/`; the `han/` meta-plugin pulls in `han.core`, `han.github`, and `han.reporting` through its `dependencies`. `han.feedback` and `han.atlassian` depend on `han.core` like the other layers but are deliberately left out of the meta-plugin, so each is opt-in and installed on its own (`han.atlassian` additionally requires a configured Atlassian MCP server). `han.plugin-builder` depends on nothing and is likewise opt-in and installed on its own. The contributor-facing authoring guidance (how to build skills, agents, and plugins) lives inside `han.plugin-builder/skills/guidance/references/`, not under `docs/`; running the `guidance` skill with `init` vendors a copy of that guidance into any repo as a path-scoped rule index. Documentation lives in `docs/` and covers the whole suite. Long-form docs in `docs/skills/{name}.md` and `docs/agents/{name}.md` are the canonical operator-facing source for every skill and every agent. The underlying definition (`han.core/skills/{name}/SKILL.md`, `han.github/skills/{name}/SKILL.md`, `han.reporting/skills/{name}/SKILL.md`, `han.feedback/skills/{name}/SKILL.md`, `han.atlassian/skills/{name}/SKILL.md`, `han.linear/skills/{name}/SKILL.md`, or `han.core/agents/{name}.md`) is the implementation.

## When to use which doc

### Entry points

- **[README.md](./README.md).** End-user landing page. Use to understand what the plugin is and where to start. Lists install instructions and pointers to every other doc.
- **[CONTRIBUTING.md](./CONTRIBUTING.md).** Contributor guide for adding or editing skills, agents, and documentation. Read before changing any file under `han.core/`, `han.github/`, or `docs/`.
- **[CHANGELOG.md](./CHANGELOG.md).** Version history. Check when a behavior or skill name in user-supplied context doesn't match what's on disk. May be a pre-2.0 rename or a removed feature.

### Writing voice

- **[docs/writing-voice.md](./docs/writing-voice.md).** Voice profile every doc in the plugin follows. No em-dashes, direct second person, plainspoken mentor tone, named voice violations to avoid.

### Core mental model (`docs/`)

- **[docs/concepts.md](./docs/concepts.md).** The skill-vs-agent model that runs through the whole plugin. Read once before doing anything else. Every other doc assumes this vocabulary.
- **[docs/quickstart.md](./docs/quickstart.md).** Five path-based recipes (plan a feature, investigate a bug, review code, set up a project, research your options). Use when picking which skill to run for a specific situation. For the full end-to-end recipe for planning, bugs, or research, the quickstart points into the how-to guides below.
- **[docs/choosing-a-han-plugin.md](./docs/choosing-a-han-plugin.md).** Which plugin to install: the bundled `han` suite vs. `han.core` only, the `han.github`-and-`han.reporting`-depend-on-`han.core` dependency (there is no GitHub-only or reporting-only install), the opt-in `han.feedback`, `han.atlassian`, `han.linear`, and `han.plugin-builder` plugins the meta-plugin does not bundle, and a "which one do you need?" guide. Use when an operator is at the install decision point or asks what the plugins are.
- **[docs/how-to/README.md](./docs/how-to/README.md).** End-to-end recipes that walk a whole workflow with specific prompts, decision points, and what to expect at each step. Two kinds live here: workflow guides for using Han (plan a feature, triage and investigate a bug, research a decision, provide feedback on Han) and extension guides for building on Han ([extend Han with plugin dependencies](./docs/how-to/extend-han-with-plugin-dependencies.md), [build a plugin that depends on Han](./docs/how-to/build-a-plugin-that-depends-on-han.md)). Use when the operator wants the full recipe and not just a path-picker. The quickstart is canonical for picking a path; a how-to is canonical for running it. The two extension guides are the canonical answer to "how do I extend Han via plugin dependencies."
- **[docs/sizing.md](./docs/sizing.md).** The small / medium / large dispatch model used by the swarming skills (`/architectural-analysis`, `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation`, `/research`). Use when a swarming skill needs to decide team size, or when a user asks what `medium` / `large` mean.
- **[docs/yagni.md](./docs/yagni.md).** The evidence-based "You Aren't Gonna Need It" rule every planning, review, and architecture skill applies before committing items to its artifact. Use when explaining why an item was deferred or rejected from a plan / review / ADR.
- **[docs/evidence.md](./docs/evidence.md).** The three structural principles (proximity to origin, corroboration, explicit no-evidence labeling) that define what "evidence-based" means in Han, plus the trust-class vocabulary (codebase / web / provided) that grounds the corroboration gate. Use when a skill, agent, or operator asks what counts as valid evidence, how to label uncorroborated claims, or what to do when no evidence exists at all.
- **[docs/why-solo-and-small-teams.md](./docs/why-solo-and-small-teams.md).** Honest fit answer for teams evaluating Han: the plugin is designed for solo product engineers and small teams, not for large teams or enterprise. Use when an operator is evaluating Han against an organization-sized governance or coordination problem, or when explaining what Han is and is not built for.

### Skill catalog (`docs/skills/`)

- **[docs/skills/README.md](./docs/skills/README.md).** Index of all skills grouped by purpose (planning, building, investigation and research, review, discovery, conventions, reporting, operations). Start here when looking for the right slash command.
- **[docs/skills/plan-a-feature.md](./docs/skills/plan-a-feature.md).** Spec a feature from scratch through an evidence-based interview that walks the design tree and dispatches specialist reviewers.
- **[docs/skills/plan-implementation.md](./docs/skills/plan-implementation.md).** Turn a feature specification into an implementation plan through a project-manager-led team conversation.
- **[docs/skills/plan-a-phased-build.md](./docs/skills/plan-a-phased-build.md).** Split a body of context (gap analysis, PRD, design doc) into a numbered sequence of vertical-slice phases, each independently demoable.
- **[docs/skills/stakeholder-summary.md](./docs/skills/stakeholder-summary.md).** Turn a feature specification into a plain-language stakeholder summary with Mermaid diagrams, for non-technical feedback before implementation kicks off.
- **[docs/skills/html-summary.md](./docs/skills/html-summary.md).** Convert a stakeholder summary markdown file into a single self-contained HTML executive report (Test Double-derived palette, inlined Mermaid diagrams). Produces the HTML file only; does not publish it.
- **[docs/skills/iterative-plan-review.md](./docs/skills/iterative-plan-review.md).** Stress-test an existing plan through multiple codebase-grounded review passes. Edits the plan in place and records every finding.
- **[docs/skills/plan-work-items.md](./docs/skills/plan-work-items.md).** Break a trusted implementation plan into independently-grabbable, atomic work items in a single work-items file.
- **[docs/skills/tdd.md](./docs/skills/tdd.md).** Drive a feature or behavior through a BDD-framed red-green-refactor loop with an enforced observed-failure gate. The plugin's only execution skill: it writes code, applying coding standards and ADRs in green and refactor.
- **[docs/skills/issue-triage.md](./docs/skills/issue-triage.md).** Classify a vague issue or bug report, identify missing information, assess severity and reproducibility, and recommend the right next skill.
- **[docs/skills/investigate.md](./docs/skills/investigate.md).** Evidence-based investigation of bugs, failures, and unexpected behavior, with adversarial validation of the proposed fix.
- **[docs/skills/research.md](./docs/skills/research.md).** Research an open-ended question (options, prior art, how something works) across the codebase and the open web, ending at an adversarially-validated recommendation. The question-shaped sibling of investigate.
- **[docs/skills/code-review.md](./docs/skills/code-review.md).** Comprehensive code review of the current branch or specified files. Dispatches a domain-aware roster that scales with sizing.
- **[docs/skills/post-code-review-to-pr.md](./docs/skills/post-code-review-to-pr.md).** Run `/code-review` against a GitHub PR and post the review as comments after a clarity check.
- **[docs/skills/architectural-analysis.md](./docs/skills/architectural-analysis.md).** Deep architectural analysis of a module: coupling, data flow, concurrency, risk, and SOLID alignment.
- **[docs/skills/gap-analysis.md](./docs/skills/gap-analysis.md).** Compare two artifacts (spec vs. implementation, PRD vs. shipped feature) and produce a plain-language report indexed by stable gap IDs.
- **[docs/skills/test-planning.md](./docs/skills/test-planning.md).** Produce a prioritized test plan for a branch or directory.
- **[docs/skills/project-discovery.md](./docs/skills/project-discovery.md).** Scan the repository for languages, frameworks, tooling, and structure. Write a static reference other skills can consume.
- **[docs/skills/project-documentation.md](./docs/skills/project-documentation.md).** Create and maintain documentation for features, systems, and components.
- **[docs/skills/coding-standard.md](./docs/skills/coding-standard.md).** Create and update coding standards from existing patterns or evidence-based research.
- **[docs/skills/architectural-decision-record.md](./docs/skills/architectural-decision-record.md).** Create, extract, or convert architectural decision records (ADRs).
- **[docs/skills/update-pr-description.md](./docs/skills/update-pr-description.md).** Generate a PR description from the current branch's changes.
- **[docs/skills/work-items-to-issues.md](./docs/skills/work-items-to-issues.md).** Publish each item in a `/plan-work-items` work-items file as a GitHub issue in its target repo, with within-repo blockers linked and no label or assignee by default.
- **[docs/skills/runbook.md](./docs/skills/runbook.md).** Create or update a runbook for a single operational scenario (alert that has fired, incident, recurring task, known failure mode). Applies a YAGNI preflight that requires real evidence before writing.
- **[docs/skills/han-feedback.md](./docs/skills/han-feedback.md).** Capture structured post-session feedback on the Han skills and agents used across the whole `han.*` plugin family, and optionally post it as a GitHub issue to testdouble/han.
- **[docs/skills/markdown-to-confluence.md](./docs/skills/markdown-to-confluence.md).** Publish one local Markdown file to a user-specified Confluence page (create or update), defaulting to an unpublished draft (opt-in `han.atlassian` plugin; requires the Atlassian MCP server).
- **[docs/skills/project-documentation-to-confluence.md](./docs/skills/project-documentation-to-confluence.md).** Run `/project-documentation` to write feature documentation to a `/tmp/` file, show it for review, then publish it to a user-specified Confluence location with `/markdown-to-confluence` (opt-in `han.atlassian` plugin; requires the Atlassian MCP server).
- **[docs/skills/work-items-to-jira.md](./docs/skills/work-items-to-jira.md).** Create one Jira ticket per slice from a `/plan-work-items` work-items file, in a single target project, with optional epic, issue type, assignee, and column (opt-in `han.atlassian` plugin; requires the Atlassian MCP server).
- **[docs/skills/work-items-to-linear.md](./docs/skills/work-items-to-linear.md).** Create one Linear issue per slice from a `/plan-work-items` work-items file, in a single target team, resolving the team's real states, labels, Projects, and members and linking within-file dependencies as native Linear "blocked by" relations (opt-in `han.linear` plugin; requires the Linear MCP server).

### Agent catalog (`docs/agents/`)

- **[docs/agents/README.md](./docs/agents/README.md).** Index of all agents grouped by role (planning, adversarial review, investigation, architecture, testing, gap/content). Start here when looking for the right sub-agent to dispatch directly.

Every agent has a long-form doc under `docs/agents/`. The agents:

Planning & facilitation: `project-manager`, `junior-developer`.

Adversarial reviewers: `adversarial-security-analyst`, `adversarial-validator`, `devops-engineer`, `on-call-engineer`, `data-engineer`, `information-architect`, `user-experience-designer`.

Investigation & evidence: `evidence-based-investigator`, `research-analyst`, `codebase-explorer`, `project-scanner`.

Architecture & risk: `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `risk-analyst`, `software-architect`, `system-architect`.

Testing: `test-engineer`, `edge-case-explorer`.

Gap & content: `gap-analyzer`, `content-auditor`.

### Templates (`docs/templates/`)

- **[docs/templates/skill-long-form-template.md](./docs/templates/skill-long-form-template.md).** Template for a new skill's long-form doc.
- **[docs/templates/agent-long-form-template.md](./docs/templates/agent-long-form-template.md).** Template for a new agent's long-form doc.
- **[docs/templates/coverage-rule.md](./docs/templates/coverage-rule.md).** The rule: every skill and every agent gets a long-form doc.

### Authoring guidance (`han.plugin-builder/skills/guidance/references/`)

This is the body of contributor guidance for building skills, agents, and plugins. It lives in the `references/` folder of the `han.plugin-builder:guidance` skill (it used to live under `docs/guidance/`). Running `/guidance init` in a repo vendors a copy of these documents into `.claude/plugin-building-guidance/` and writes a path-scoped rule index at `.claude/rules/plugin-building-guidance.md` so the right document surfaces while editing skill and agent files. Read the documents directly here, or invoke the `guidance` skill.

Top-level guidance documents for contributors writing skills, agents, and configuration:

- **[han.plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md](./han.plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md).** Definitions of skills, agents, and hooks, and which to reach for. Read first when adding a new entity to the plugin.
- **[han.plugin-builder/skills/guidance/references/iterative-plugin-development.md](./han.plugin-builder/skills/guidance/references/iterative-plugin-development.md).** Development workflow for evolving a plugin over time.
- **[han.plugin-builder/skills/guidance/references/specialization-and-model-selection.md](./han.plugin-builder/skills/guidance/references/specialization-and-model-selection.md).** How to pick models for agents based on the work they do.

### Han-specific contributor and maintainer docs (`docs/`)

These are specific to the Han repo and its suite, so they live in `docs/` rather than in the general authoring guidance.

- **[docs/local-development.md](./docs/local-development.md).** How to use a local clone of the Han repo as a marketplace source so branch changes are immediately testable. Read when setting up to develop or test changes to the Han suite locally.
- **[docs/semantic-versioning.md](./docs/semantic-versioning.md).** The Han suite's versioning policy: how the parent `han` plugin and its children version independently, and how releases are tagged. Owned alongside `/han-release`.
- **[docs/plugin-readme.md](./docs/plugin-readme.md).** The README conventions Han plugins follow (root-level README for humans, no READMEs inside skill directories).

Subdirectories:

- **[han.plugin-builder/skills/guidance/references/agent-building-guidelines/](./han.plugin-builder/skills/guidance/references/agent-building-guidelines/).** Agent-authoring rules: domain focus, description length, external files, model selection, graceful degradation, multi-agent economics. Read before creating or significantly editing an agent.
- **[han.plugin-builder/skills/guidance/references/skill-building-guidance/](./han.plugin-builder/skills/guidance/references/skill-building-guidance/).** Skill-authoring rules: description frontmatter, progressive disclosure, context hygiene, dynamic project discovery, bash permissions, script execution, naming conventions, troubleshooting, and more. The single largest body of contributor guidance in the repo.
- **[han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/](./han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/).** Reference for the JSON config formats: `marketplace.json`, `plugin.json`, `monitors.json`, `themes.json`. The `plugin.json` reference's `dependencies` section links out to the two how-to guides for extending Han via dependencies.
- **[han.plugin-builder/skills/guidance/references/templates/](./han.plugin-builder/skills/guidance/references/templates/).** Example JSON manifests and a plugin README template.

### Plans and research (`docs/plans/`, `docs/research/`)

- **[docs/plans/](./docs/plans/).** Plan documents for work the team is doing on the plugin itself. One folder per plan, named after the plan. A plan that has its own dedicated research lives inside the plan folder under `docs/plans/{plan-name}/research/`. Use this when writing a plan for something the team is building, not for general standalone research.
- **[docs/research/](./docs/research/).** Standalone research reports that are not tied to a specific plan — for example, evidence-based research backing a new agent, a new pattern, or a contributor decision that does not have its own plan folder yet. Use this when the research has durable value but no parent plan to nest under.

Folder selection rule: if the artifact is the plan, write to `docs/plans/{plan-name}/`. If the artifact is research nested inside a plan, write to `docs/plans/{plan-name}/research/`. If the artifact is standalone research that informs the plugin but does not belong to a plan folder, write to `docs/research/`. Do not invent new top-level folders for these artifacts. Do not write plans or research into `han.plugin-builder/skills/guidance/references/`; that folder is reserved for authoring guidance, not work-in-progress.

## Conventions

- **One canonical source per concept.** The long-form doc in `docs/skills/` or `docs/agents/` is canonical for that skill or agent. Index entries carry one-sentence scent plus a link. The README never duplicates long-form content.
- **Every long-form doc links up.** The first bullet of the "Related Documentation" section always points back to the README at the repo root.
- **Voice is uniform.** Every doc follows [docs/writing-voice.md](./docs/writing-voice.md). No em-dashes, direct second person, no flattery or hype.
- **YAGNI applies to docs too.** Don't add speculative sections, for-future-flexibility warnings, or examples for behavior the skill doesn't have. The same evidence rule that gates plan steps gates docs.
- **Indexes stay complete, not counted.** Every skill in `han.core/skills/`, `han.github/skills/`, `han.reporting/skills/`, `han.feedback/skills/`, and `han.atlassian/skills/`, and `han.linear/skills/` has a long-form doc in `docs/skills/` and an entry in the skills index; same for agents in `han.core/agents/` and `docs/agents/`. Verify the indexes list every entity when editing them, rather than tracking a running total.
