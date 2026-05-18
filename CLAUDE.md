# han: Project Map

Han is a Claude Code plugin: a suite of skills and agents for solo (or small-team) product engineers. It packages evidence-based planning, deep code review, investigation, and documentation workflows into deterministic slash commands that dispatch specialist sub-agents to do the judgment-heavy work.

Current version: **2.2.0** (see [CHANGELOG.md](./CHANGELOG.md)).

## Repository layout

```
/                       # repo root
├── README.md           # End-user landing page
├── CONTRIBUTING.md     # Contributor guide
├── CLAUDE.md           # This file
├── CHANGELOG.md    # Version history
├── .claude-plugin/
│   └── marketplace.json   # Test Double marketplace manifest
├── plugin/             # The actual plugin shipped to Claude Code
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── agents/         # 21 agent definitions (.md with frontmatter)
│   ├── skills/         # 18 skill directories, each with SKILL.md + references/
│   └── references/     # Cross-skill reference files (e.g. yagni-rule.md)
├── docs/               # Operator-facing documentation
│   ├── writing-voice.md   # Voice profile every doc follows
│   ├── concepts.md
│   ├── quickstart.md
│   ├── sizing.md
│   ├── yagni.md
│   ├── agents/         # Long-form docs for all 21 agents, plus README
│   ├── skills/         # Long-form docs for all 18 skills, plus README
│   ├── guidance/       # Contributor-facing authoring guidance
│   └── templates/      # Templates and coverage rule for long-form docs
└── images/             # Banner and graphics for README
```

The plugin is shipped from `plugin/`; documentation lives in `docs/`. Long-form docs in `docs/skills/{name}.md` and `docs/agents/{name}.md` are the canonical operator-facing source for every skill and every agent. The underlying definition (`plugin/skills/{name}/SKILL.md` or `plugin/agents/{name}.md`) is the implementation.

## When to use which doc

### Entry points

- **[README.md](./README.md).** End-user landing page. Use to understand what the plugin is and where to start. Lists install instructions and pointers to every other doc.
- **[CONTRIBUTING.md](./CONTRIBUTING.md).** Contributor guide for adding or editing skills, agents, and documentation. Read before changing any file under `plugin/` or `docs/`.
- **[CHANGELOG.md](./CHANGELOG.md).** Version history. Check when a behavior or skill name in user-supplied context doesn't match what's on disk. May be a pre-2.0 rename or a removed feature.

### Writing voice

- **[docs/writing-voice.md](./docs/writing-voice.md).** Voice profile every doc in the plugin follows. No em-dashes, direct second person, plainspoken mentor tone, named voice violations to avoid.

### Core mental model (`docs/`)

- **[docs/concepts.md](./docs/concepts.md).** The skill-vs-agent model that runs through the whole plugin. Read once before doing anything else. Every other doc assumes this vocabulary.
- **[docs/quickstart.md](./docs/quickstart.md).** Four path-based recipes (plan a feature, investigate a bug, review code, set up a project). Use when picking which skill to run for a specific situation.
- **[docs/sizing.md](./docs/sizing.md).** The small / medium / large dispatch model used by the six swarming skills (`/architectural-analysis`, `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation`). Use when a swarming skill needs to decide team size, or when a user asks what `medium` / `large` mean.
- **[docs/yagni.md](./docs/yagni.md).** The evidence-based "You Aren't Gonna Need It" rule every planning, review, and architecture skill applies before committing items to its artifact. Use when explaining why an item was deferred or rejected from a plan / review / ADR.

### Skill catalog (`docs/skills/`)

- **[docs/skills/README.md](./docs/skills/README.md).** Index of all 18 skills grouped by purpose (planning, building, investigation, review, discovery, conventions, reporting). Start here when looking for the right slash command.
- **[docs/skills/plan-a-feature.md](./docs/skills/plan-a-feature.md).** Spec a feature from scratch through an evidence-based interview that walks the design tree and dispatches specialist reviewers.
- **[docs/skills/plan-implementation.md](./docs/skills/plan-implementation.md).** Turn a feature specification into an implementation plan through a project-manager-led team conversation.
- **[docs/skills/plan-a-phased-build.md](./docs/skills/plan-a-phased-build.md).** Split a body of context (gap analysis, PRD, design doc) into a numbered sequence of vertical-slice phases, each independently demoable.
- **[docs/skills/iterative-plan-review.md](./docs/skills/iterative-plan-review.md).** Stress-test an existing plan through multiple codebase-grounded review passes. Edits the plan in place and records every finding.
- **[docs/skills/plan-work-items.md](./docs/skills/plan-work-items.md).** Break a trusted implementation plan into independently-grabbable, atomic work items in a single work-items file.
- **[docs/skills/tdd.md](./docs/skills/tdd.md).** Drive a feature or behavior through a BDD-framed red-green-refactor loop with an enforced observed-failure gate. The plugin's only execution skill: it writes code, applying coding standards and ADRs in green and refactor.
- **[docs/skills/issue-triage.md](./docs/skills/issue-triage.md).** Classify a vague issue or bug report, identify missing information, assess severity and reproducibility, and recommend the right next skill.
- **[docs/skills/investigate.md](./docs/skills/investigate.md).** Evidence-based investigation of bugs, failures, and unexpected behavior, with adversarial validation of the proposed fix.
- **[docs/skills/code-review.md](./docs/skills/code-review.md).** Comprehensive code review of the current branch or specified files. Dispatches a domain-aware roster that scales with sizing.
- **[docs/skills/gh-pr-review.md](./docs/skills/gh-pr-review.md).** Run `/code-review` against a GitHub PR and post the review as comments after a clarity check.
- **[docs/skills/architectural-analysis.md](./docs/skills/architectural-analysis.md).** Deep architectural analysis of a module: coupling, data flow, concurrency, risk, and SOLID alignment.
- **[docs/skills/gap-analysis.md](./docs/skills/gap-analysis.md).** Compare two artifacts (spec vs. implementation, PRD vs. shipped feature) and produce a plain-language report indexed by stable gap IDs.
- **[docs/skills/test-planning.md](./docs/skills/test-planning.md).** Produce a prioritized test plan for a branch or directory.
- **[docs/skills/project-discovery.md](./docs/skills/project-discovery.md).** Scan the repository for languages, frameworks, tooling, and structure. Write a static reference other skills can consume.
- **[docs/skills/project-documentation.md](./docs/skills/project-documentation.md).** Create and maintain documentation for features, systems, and components.
- **[docs/skills/coding-standard.md](./docs/skills/coding-standard.md).** Create and update coding standards from existing patterns or evidence-based research.
- **[docs/skills/architectural-decision-record.md](./docs/skills/architectural-decision-record.md).** Create, extract, or convert architectural decision records (ADRs).
- **[docs/skills/update-pr-description.md](./docs/skills/update-pr-description.md).** Generate a PR description from the current branch's changes.

### Agent catalog (`docs/agents/`)

- **[docs/agents/README.md](./docs/agents/README.md).** Index of all 21 agents grouped by role (planning, adversarial review, investigation, architecture, testing, gap/content). Start here when looking for the right sub-agent to dispatch directly.

Every agent has a long-form doc under `docs/agents/`. The 21 agents:

Planning & facilitation: `project-manager`, `junior-developer`.

Adversarial reviewers: `adversarial-security-analyst`, `adversarial-validator`, `devops-engineer`, `data-engineer`, `information-architect`, `user-experience-designer`.

Investigation & evidence: `evidence-based-investigator`, `codebase-explorer`, `project-scanner`.

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
- **[docs/guidance/claude-marketplace-and-plugin-configuration/](./docs/guidance/claude-marketplace-and-plugin-configuration/).** Reference for the JSON config formats: `marketplace.json`, `plugin.json`, `monitors.json`, `themes.json`.
- **[docs/guidance/templates/](./docs/guidance/templates/).** Example JSON manifests and a plugin README template.
- **[docs/guidance/rfcs/](./docs/guidance/rfcs/).** Active RFCs for plugin-system changes.
- **[docs/guidance/plans/](./docs/guidance/plans/).** Internal planning documents and research notes. Historical context, not user-facing guidance.

## Conventions

- **One canonical source per concept.** The long-form doc in `docs/skills/` or `docs/agents/` is canonical for that skill or agent. Index entries carry one-sentence scent plus a link. The README never duplicates long-form content.
- **Every long-form doc links up.** The first bullet of the "Related Documentation" section always points back to the README at the repo root.
- **Voice is uniform.** Every doc follows [docs/writing-voice.md](./docs/writing-voice.md). No em-dashes, direct second person, no flattery or hype.
- **YAGNI applies to docs too.** Don't add speculative sections, for-future-flexibility warnings, or examples for behavior the skill doesn't have. The same evidence rule that gates plan steps gates docs.
- **Counts to verify when editing indexes.** 21 agents in `plugin/agents/`; 18 skills in `plugin/skills/`; 21 long-form agent docs in `docs/agents/`; 18 long-form skill docs in `docs/skills/`.
