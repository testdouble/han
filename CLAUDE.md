# han: Project Map

Han is a Claude Code plugin suite for solo (or small-team) product engineers. It packages evidence-based planning, deep code review, investigation, and documentation workflows into deterministic slash commands that dispatch specialist sub-agents to do the judgment-heavy work. The suite ships as three plugins: `han.core` (the skills and agents), `han.github` (GitHub-facing skills), and `han` (a meta-plugin that installs both via dependencies).

## Repository layout

```
/                       # repo root
├── README.md           # End-user landing page
├── CONTRIBUTING.md     # Contributor guide
├── CLAUDE.md           # This file
├── CHANGELOG.md        # Version history
├── .claude-plugin/
│   └── marketplace.json   # Test Double marketplace manifest (lists han, han.core, han.github)
├── han/                # Meta-plugin: no components of its own; depends on han.core + han.github
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
├── docs/               # Operator-facing documentation
│   ├── writing-voice.md   # Voice profile every doc follows
│   ├── concepts.md
│   ├── quickstart.md
│   ├── sizing.md
│   ├── yagni.md
│   ├── agents/         # Long-form docs for all agents, plus README
│   ├── skills/         # Long-form docs for all skills, plus README
│   ├── how-to/         # End-to-end workflow guides (planning, bugs, research)
│   ├── guidance/       # Contributor-facing authoring guidance
│   ├── templates/      # Templates and coverage rule for long-form docs
│   ├── plans/          # Plan documents (one folder per plan; nested research lives inside)
│   └── research/       # Standalone research reports not tied to a specific plan
└── images/             # Banner and graphics for README
```

The plugins are shipped from `han.core/` and `han.github/`; the `han/` meta-plugin pulls in both through its `dependencies`. Documentation lives in `docs/` and covers the whole suite. Long-form docs in `docs/skills/{name}.md` and `docs/agents/{name}.md` are the canonical operator-facing source for every skill and every agent. The underlying definition (`han.core/skills/{name}/SKILL.md`, `han.github/skills/{name}/SKILL.md`, or `han.core/agents/{name}.md`) is the implementation.

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
- **[docs/choosing-a-han-plugin.md](./docs/choosing-a-han-plugin.md).** Which plugin to install: the full `han` suite vs. `han.core` only, the `han.github`-depends-on-`han.core` dependency (there is no GitHub-only install), and a "which one do you need?" guide. Use when an operator is at the install decision point or asks what the three plugins are.
- **[docs/how-to/README.md](./docs/how-to/README.md).** End-to-end recipes that walk a whole workflow with specific prompts, decision points, and what to expect at each step. Two kinds live here: workflow guides for using Han (plan a feature, triage and investigate a bug, research a decision) and extension guides for building on Han ([extend Han with plugin dependencies](./docs/how-to/extend-han-with-plugin-dependencies.md), [build a plugin that depends on Han](./docs/how-to/build-a-plugin-that-depends-on-han.md)). Use when the operator wants the full recipe and not just a path-picker. The quickstart is canonical for picking a path; a how-to is canonical for running it. The two extension guides are the canonical answer to "how do I extend Han via plugin dependencies."
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

### Authoring guidance (`docs/guidance/`)

Top-level guidance documents for contributors writing skills, agents, and configuration:

- **[docs/guidance/plugin-entity-taxonomy.md](./docs/guidance/plugin-entity-taxonomy.md).** Definitions of skills, agents, and hooks, and which to reach for. Read first when adding a new entity to the plugin.
- **[docs/guidance/plugin-readme.md](./docs/guidance/plugin-readme.md).** Guidelines for plugin README structure.
- **[docs/guidance/local-development.md](./docs/guidance/local-development.md).** Local development setup for working on the plugin.
- **[docs/guidance/iterative-plugin-development.md](./docs/guidance/iterative-plugin-development.md).** Development workflow for evolving a plugin over time.
- **[docs/guidance/semantic-versioning.md](./docs/guidance/semantic-versioning.md).** Versioning rules for plugin releases.
- **[docs/guidance/specialization-and-model-selection.md](./docs/guidance/specialization-and-model-selection.md).** How to pick models for agents based on the work they do.

Subdirectories:

- **[docs/guidance/agent-building-guidelines/](./docs/guidance/agent-building-guidelines/).** Agent-authoring rules: domain focus, external files, model selection, graceful degradation, multi-agent economics. Read before creating or significantly editing an agent.
- **[docs/guidance/skill-building-guidance/](./docs/guidance/skill-building-guidance/).** Skill-authoring rules: description frontmatter, progressive disclosure, context hygiene, dynamic project discovery, bash permissions, script execution, naming conventions, troubleshooting, and more. The single largest body of contributor guidance in the repo.
- **[docs/guidance/claude-marketplace-and-plugin-configuration/](./docs/guidance/claude-marketplace-and-plugin-configuration/).** Reference for the JSON config formats: `marketplace.json`, `plugin.json`, `monitors.json`, `themes.json`. The `plugin.json` reference's `dependencies` section links out to the two how-to guides for extending Han via dependencies.
- **[docs/guidance/templates/](./docs/guidance/templates/).** Example JSON manifests and a plugin README template.
- **[docs/guidance/rfcs/](./docs/guidance/rfcs/).** Active RFCs for plugin-system changes.

### Plans and research (`docs/plans/`, `docs/research/`)

- **[docs/plans/](./docs/plans/).** Plan documents for work the team is doing on the plugin itself. One folder per plan, named after the plan. A plan that has its own dedicated research lives inside the plan folder under `docs/plans/{plan-name}/research/`. Use this when writing a plan for something the team is building, not for general standalone research.
- **[docs/research/](./docs/research/).** Standalone research reports that are not tied to a specific plan — for example, evidence-based research backing a new agent, a new pattern, or a contributor decision that does not have its own plan folder yet. Use this when the research has durable value but no parent plan to nest under.

Folder selection rule: if the artifact is the plan, write to `docs/plans/{plan-name}/`. If the artifact is research nested inside a plan, write to `docs/plans/{plan-name}/research/`. If the artifact is standalone research that informs the plugin but does not belong to a plan folder, write to `docs/research/`. Do not invent new top-level folders for these artifacts. Do not write plans or research into `docs/guidance/`; that folder is reserved for authoring guidance, not work-in-progress.

## Conventions

- **One canonical source per concept.** The long-form doc in `docs/skills/` or `docs/agents/` is canonical for that skill or agent. Index entries carry one-sentence scent plus a link. The README never duplicates long-form content.
- **Every long-form doc links up.** The first bullet of the "Related Documentation" section always points back to the README at the repo root.
- **Voice is uniform.** Every doc follows [docs/writing-voice.md](./docs/writing-voice.md). No em-dashes, direct second person, no flattery or hype.
- **YAGNI applies to docs too.** Don't add speculative sections, for-future-flexibility warnings, or examples for behavior the skill doesn't have. The same evidence rule that gates plan steps gates docs.
- **Indexes stay complete, not counted.** Every skill in `han.core/skills/` and `han.github/skills/` has a long-form doc in `docs/skills/` and an entry in the skills index; same for agents in `han.core/agents/` and `docs/agents/`. Verify the indexes list every entity when editing them, rather than tracking a running total.
