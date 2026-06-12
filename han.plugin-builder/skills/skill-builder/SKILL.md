---
name: skill-builder
description: >
  Builds a new Claude Code skill from scratch through a relentless, evidence-based interview that
  walks the skill's design tree decision-by-decision — entity fit, use cases, name, description,
  workflow steps, tools, and progressive-disclosure layout — then reviews the finished skill
  against the plugin-building guidance and applies every fix it finds. Use when creating,
  authoring, scaffolding, designing, or drafting a new skill or slash command. Does not build an
  agent or subagent — use agent-builder. Does not serve, vendor, or refresh the authoring
  guidance itself — use guidance.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(find *), Bash(mkdir *)
---

## Guidance Location

The authoritative skill-authoring guidance ships in this plugin. Read the
specific document a decision needs, when that decision is on the table — never
read them all up front, because that defeats progressive disclosure and burns
context on guidance the current skill does not touch.

- Plugin-building guidance root: `${CLAUDE_PLUGIN_ROOT}/skills/guidance/references/`
- Skill-specific guidance: `${CLAUDE_PLUGIN_ROOT}/skills/guidance/references/skill-building-guidance/`

Map from decision to governing document (read just-in-time):

| Decision on the table | Read |
|---|---|
| Skill vs. agent vs. hook | `plugin-entity-taxonomy.md` |
| Use cases, trigger phrases, test cases | `skill-building-guidance/use-case-planning.md` |
| Directory name, file name, dependency prefix | `skill-building-guidance/naming-conventions.md` |
| The `description` field (four components, boundaries) | `skill-building-guidance/skill-description-frontmatter.md`, `skill-building-guidance/skill-description-length.md` |
| Which frontmatter fields to set | `skill-building-guidance/skill-frontmatter-fields.md` |
| Where content lives (body vs. references vs. scripts vs. assets) | `skill-building-guidance/progressive-disclosure.md`, `skill-building-guidance/skill-reference-files.md` |
| Step structure and workflow shape | `skill-building-guidance/workflow-patterns.md`, `skill-building-guidance/writing-effective-instructions.md` |
| `allowed-tools`, Bash permission granularity | `skill-building-guidance/allowed-tools-bash-permissions.md`, `skill-building-guidance/allowed-tools-AskUserQuestion.md` |
| Reading config / runtime data | `skill-building-guidance/context-injection-commands.md`, `skill-building-guidance/dynamic-project-discovery.md` |
| Running scripts | `skill-building-guidance/script-execution-instructions.md` |
| Dispatching agents from the skill | `skill-building-guidance/agent-dispatch-namespacing.md`, plus `agent-building-guidelines/multi-agent-economics.md` |
| Degraded environments (no git, missing tools) | `skill-building-guidance/graceful-degradation.md`, `skill-building-guidance/optional-git-repositories.md` |
| Frontmatter safety (angle brackets, YAML types) | `skill-building-guidance/security-restrictions.md` |
| Hardening fuzzy steps into deterministic ones | `skill-building-guidance/hardening-fuzzy-vs-deterministic.md` |
| Splitting or composing skills | `skill-building-guidance/skill-decomposition.md`, `skill-building-guidance/skill-composition.md` |
| Defining success and tests | `skill-building-guidance/success-criteria-and-testing.md` |
| New plugin needed (plugin.json, marketplace.json) | `claude-marketplace-and-plugin-configuration/` and `templates/` |

## Operating Principles

- **Interview relentlessly, but explore first.** Interview the user relentlessly
  about every aspect of the skill until you reach a shared understanding. Walk
  down each branch of the design tree, resolving dependencies between decisions
  one-by-one. **If a question can be answered by exploring the repository — the
  target plugin's existing skills, sibling descriptions, `plugin.json`,
  conventions, the guidance documents above — explore instead of asking.** Only
  surface questions that genuinely require the user's judgment.
- **Ask one question at a time.** Never batch questions. Settle one decision,
  let its answer resolve dependent decisions, then ask the next. Later answers
  routinely make earlier questions moot.
- **Recommend, then ask.** For every question surfaced to the user, provide a
  recommended answer with rationale grounded in evidence (existing skills,
  conventions, the guidance, the user's stated goal). The user can accept,
  amend, or redirect.
- **Apply guidance as you go, then verify at the end.** Consult the governing
  document when a decision is on the table (Step 4), and run a full
  guidance-conformance pass over the finished files at the end (Step 6). The
  interview gets each decision approximately right; the review pass makes the
  artifact correct.

# Build a Skill

## Step 1: Capture the Request and Confirm It Is a Skill

Read the user's argument and the conversation to extract what the skill should
do. If the request is too thin to start (for example, just "build a skill"),
ask the user for one or two sentences on what the skill should accomplish and
what triggers it — nothing else yet.

**Confirm the entity type before anything else.** Read
`${CLAUDE_PLUGIN_ROOT}/skills/guidance/references/plugin-entity-taxonomy.md` and
apply its decision heuristic. A skill is a deterministic, flowchartable process
("Can I flowchart every path?" → skill). If the work is really contextual
judgment with no fixed flowchart, it is an agent — stop and recommend
`agent-builder`. If it fires automatically on an event, it is a hook. If the
request bundles a deterministic process *and* a judgment layer, recommend
building them separately and composing them. Only proceed once a skill is the
right entity.

## Step 2: Discover Before Asking

Locate the target plugin and learn its conventions before asking the user
anything beyond the framing. Use Glob, Grep, and `find` to gather:

- The target plugin directory and its `.claude-plugin/plugin.json` (name,
  description, version). If the user has not said which plugin, infer candidates
  from the repository and confirm the target in Step 4.
- Sibling skills in that plugin (`{plugin}/skills/*/SKILL.md`) — their
  descriptions, frontmatter, step structure, and the trigger space they already
  own. New descriptions must disambiguate against these siblings in both
  directions.
- `CLAUDE.md`, `AGENTS.md`, and any `project-discovery.md` — repository
  conventions, the documentation root, and how skills are catalogued.
- Whether the skill needs an external tool (gh, jq, an MCP server). External
  dependencies drive the directory-name prefix and a `description` mention.

Record what was found (file paths) and what was not. A missing convention is
itself a finding that shapes the skill.

## Step 3: Build the Design Tree

Enumerate the decisions the skill needs, in dependency order. Resolve
foundational decisions before dependent ones; never ask a dependent question
before its parent is settled.

1. **Foundational** — Which plugin owns it? What are the 2-3 concrete use cases
   (trigger phrase, workflow, tools, domain knowledge) per
   `use-case-planning.md`? What artifact or outcome does each use case produce?
2. **Identity** — What is the directory name (which becomes the slash command)?
   Does it follow the gerund/process-name and dependency-prefix rules? What does
   the `description` say across all four components (what, when, boundary,
   breadth), and how does it disambiguate against siblings in both directions?
3. **Workflow** — Which workflow pattern fits (sequential, iterative,
   context-aware, domain-specific, or a combination)? What are the numbered
   steps? Where do human gates belong (before irreversible or outward-facing
   actions only)?
4. **Capabilities** — What `allowed-tools` does each step need, at the right
   Bash granularity? Does the skill dispatch agents (and are they available in
   this plugin)? Does it run scripts? Does it read runtime config via context
   injection?
5. **Layout** — What belongs in the SKILL.md body (process), in `references/`
   (templates, checklists, domain knowledge), in `scripts/` (deterministic
   operations), and in `assets/` (output files)? What other frontmatter fields
   apply (`argument-hint`, `arguments`, `model`, `paths`)?

Keep each node a concrete decision with a candidate answer. Do not pre-fill the
tree with content the user has not confirmed.

## Step 4: Interview Loop — One Branch at a Time

For each decision in dependency order:

1. **Try to resolve it from evidence.** Re-check the target plugin, sibling
   skills, conventions, and the governing guidance document for this decision
   (see the map above). If the evidence answers it, record the decision with its
   evidence and move on — do not ask.
2. **If evidence is insufficient, draft a recommended answer** grounded in the
   guidance and the evidence available. Read the governing document first so the
   recommendation is correct, not improvised.
3. **Surface one question to the user**, with the recommendation, the rationale,
   and the alternatives. State what changes depending on the answer. Wait for
   the answer before asking anything else.
4. **Descend.** Once a decision is settled, re-evaluate which dependent
   decisions the new answer resolves, and continue.

Keep the interview moving — do not stall on questions the evidence can answer,
and do not batch.

## Step 5: Write the Skill

Create the skill directory and write the files:

1. Create `{plugin}/skills/{skill-name}/` (use `mkdir`). The directory name is
   the slash command and must match the frontmatter `name`.
2. Write `SKILL.md` with:
   - Frontmatter: `name` (matching the directory), the `description` settled in
     the interview, `allowed-tools`, and any other settled fields. **Never put
     `AskUserQuestion` in `allowed-tools`.** No XML angle brackets in any
     frontmatter value.
   - A body of numbered process steps following the chosen workflow pattern.
     Be specific and actionable, embed reasoning in constraints
     (`Always/Never X BECAUSE Y`), include error handling for tool-dependent
     steps, and reference any bundled resource by exact path.
3. Create `references/`, `scripts/`, or `assets/` and their files only if a use
   case needs them. Domain knowledge (templates, checklists, matrices) goes in
   `references/`; deterministic operations go in `scripts/`; output-only files
   go in `assets/`. Do not create empty or speculative folders.
4. If the skill belongs in a brand-new plugin, create the plugin scaffold
   (`.claude-plugin/plugin.json`, and a marketplace entry if the repo uses one)
   per the `claude-marketplace-and-plugin-configuration/` guidance and the
   `templates/`.

## Step 6: Full Guidance-Conformance Review

This is the review pass the skill commits to. Re-read each governing document
that applies to what you built and verify the finished files against it,
applying every fix directly. Do not summarize problems for the user without
fixing them. Cover at minimum:

1. **Entity fit** (`plugin-entity-taxonomy.md`) — the skill is genuinely a
   flowchartable process, not a judgment layer that should be an agent.
2. **Description** (`skill-description-frontmatter.md`, `skill-description-length.md`)
   — third person; covers what, when, boundary, and trigger breadth; weaves
   trigger words into prose rather than appending a keyword list; names sibling
   skills in boundary clauses; disambiguates in both directions (update the
   sibling's description if a one-way gap exists); within 1024 characters.
3. **Naming** (`naming-conventions.md`) — directory name matches `name`, is a
   process/gerund name when the output is a plan or doc, carries a dependency
   prefix when an external tool is required, no `README.md` in the skill folder,
   `SKILL.md` cased exactly.
4. **Progressive disclosure** (`progressive-disclosure.md`, `skill-reference-files.md`)
   — body is process only and under 500 lines; domain knowledge is in
   `references/`; scripts hold deterministic work; nothing the toolchain already
   enforces is restated.
5. **Instruction quality** (`writing-effective-instructions.md`, `workflow-patterns.md`)
   — steps are specific and actionable; constraints embed reasoning; error
   handling is present; human gates sit only at irreversible actions; the most
   critical item in each list is placed last.
6. **Tools and safety** (`allowed-tools-bash-permissions.md`,
   `allowed-tools-AskUserQuestion.md`, `security-restrictions.md`) — Bash
   permissions are scoped correctly with separate entries; `AskUserQuestion` is
   absent from `allowed-tools`; no angle brackets or non-standard YAML in
   frontmatter.
7. **Discovery and degradation** (`dynamic-project-discovery.md`,
   `graceful-degradation.md`, `optional-git-repositories.md`) — the skill
   discovers project specifics dynamically rather than hardcoding them, and
   degrades gracefully when a tool or git is absent, where relevant.
8. **Dispatch** (`agent-dispatch-namespacing.md`) — if the skill dispatches
   agents, every dispatch uses the qualified `defining-plugin:agent-name`, and
   the agents actually exist in an installed plugin.
9. **Tests** (`success-criteria-and-testing.md`) — each use case maps to a
   triggering and functional test the user can run.

Apply the YAGNI discipline throughout: every step, reference file, tool
permission, and frontmatter field must earn its place against a real use case.
Cut anything added "for completeness" or "for future flexibility."

## Step 7: Present and Hand Off

Summarize for the user:

- The files written (paths), and what each contains.
- The decisions settled by evidence versus by user input.
- The fixes the Step 6 review applied, citing the guidance document behind each.
- The triggering and functional tests derived from the use cases, so the user
  can validate the skill against the model tier it targets.

Note that plugin entities rarely land in one pass: per
`iterative-plugin-development.md`, plan for 3-5 iterations. Ask whether the user
wants to iterate on specific steps or considers the skill ready to test.
