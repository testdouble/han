# Guidance-Conformance Checklist

Each item names the guidance rule it checks. Items in the skill section are grouped under the lens that **owns** them —
the lens that deep-checks the item and grounds findings against the named guidance — so each reviewer reads only its own
group instead of scanning the list; every agent-target item is conformance-owned, and each reviewer's brief names the
items it owns. The conformance & quality reviewer deep-checks both the Conformance and the Quality (Fitness for purpose)
items, and the orchestrator emits the mechanical checks and the progressive-disclosure structural check in Step 4. The
conformance & quality reviewer defers the seam item's deep judgment to its lens and runs the seam's always-applicable
structural check only when that lens is named in its brief as left off the roster, skipping it when the seam reviewer is
dispatched — so no rule goes unchecked and no dispatched lens is re-checked. Each specialist grounds its owned item
against the guidance the item names (read it from the guidance path your reviewer prompt names) and cites the rule when
raising a finding. Apply
the section matching the resolved `target-type`, plus the cross-cutting lenses when their signal holds. Severity per
[finding-classification.md](finding-classification.md).

## Cross-cutting (either target type)

These lenses apply to a skill or an agent when their signal holds, independent of the type sections below. The bloat
reviewer owns Token economy; the conformance & quality reviewer owns Dispatch economics and prompt efficacy.

- **Token economy** — every token earns its place; no restatement of context the model already has, no duplication of a
  linked reference. Ground against `skill-building-guidance/context-hygiene.md`; tier every instance per
  [bloat-classification.md](bloat-classification.md).
- **Dispatch economics and prompt efficacy** (when the artifact dispatches sub-agents) — the escalation cascade is
  respected (default to one well-prompted agent; add a reviewer only for a measured gap; a team only for genuinely
  multi-dimensional review; cap around five); the roster is matched to each run, not dispatched wholesale; independent
  agents run in parallel and sequential chains stay short (under three); each dispatched agent carries the right
  specialization and model tier for its task; and each brief is specific, gated, and effective
  (`agent-building-guidelines/multi-agent-economics.md`, `specialization-and-model-selection.md`, `agent-building-guidelines/agent-model-selection.md`,
  `skill-building-guidance/writing-effective-instructions.md`). This is dispatch-economics judgment, distinct from the qualified-name and declared-dependency wiring. Tier findings as
  chronic CORRUPTS via the dispatch & prompt efficacy row of the per-lens map in
  [finding-classification.md](finding-classification.md).

## Skill target

### Conformance

- **Entity fit** — the artifact is a flowchartable process, not a judgment layer that should be an agent
  (`plugin-entity-taxonomy.md`).
- **Description** (conformance & quality reviewer; the ≤1024-character length check is the orchestrator's, Step 4) —
  third person; covers what, when, boundary, and trigger breadth; weaves trigger words into prose, not a keyword list;
  names sibling skills in boundary clauses and disambiguates in both directions (`skill-building-guidance/skill-description-frontmatter.md`,
  `skill-building-guidance/skill-description-length.md`).
- **Naming** (conformance & quality reviewer; the mechanical dir-name-match, `SKILL.md` casing, and no-`README.md`
  checks are the orchestrator's, Step 4) — a process/gerund name when the output is a plan or doc; a dependency prefix
  when an external tool is required (`skill-building-guidance/naming-conventions.md`).
- **Frontmatter and grants** (conformance & quality reviewer; the mechanical `AskUserQuestion`-absent,
  script-not-listed, angle-bracket, reserved-name, and non-standard-YAML checks are the orchestrator's, Step 4) —
  `allowed-tools` is the minimal set the steps use, with separate Bash entries at the right granularity
  (`skill-building-guidance/allowed-tools-bash-permissions.md`, `skill-building-guidance/skill-frontmatter-fields.md`).
- **Agent dispatch** — every dispatch uses the qualified `defining-plugin:agent-name`, never a bare name or a
  meta-plugin prefix, and the agent exists in a declared dependency (`skill-building-guidance/agent-dispatch-namespacing.md`).
- **Discovery and degradation** — the skill discovers project specifics dynamically rather than hardcoding them,
  degrades gracefully when a tool is absent, and has error handling on tool-dependent steps
  (`skill-building-guidance/dynamic-project-discovery.md`, `skill-building-guidance/graceful-degradation.md`).
- **Script invocation contract** — every script the skill tells an agent or the operator to run carries its full
  invocation contract (arguments in order, outputs to capture), with the skill branching only on keys or exit codes the
  script actually emits (`skill-building-guidance/script-execution-instructions.md`). A script invoked without its syntax is the canonical
  execution-breaking miss.
- **Tests** — each use case maps to a triggering and a functional test (`skill-building-guidance/success-criteria-and-testing.md`).
- **Repo-convention conformance** (conformance & quality reviewer owns the systematic sweep) — when the repo's own
  conventions for authoring skills and agents were delivered to you, the artifact conforms to them, and a violation is
  cited to the convention's own `file:line`, not a `han-plugin-builder` guidance filename. Grounding source: the
  delivered repo convention file.

### Quality

- **Fitness for purpose** (conformance & quality reviewer) — the body delivers what the description promises, and
  delivers it _well_: every capability, review dimension, or output the description claims has a step or lens that
  produces it, that step or lens is designed to produce it reliably (a step that nominally covers a claimed capability
  but is built to do so shallowly or unreliably — deep work concentrated in one overloaded reviewer, a check wired
  without the grounding it needs — is a fitness finding), and the artifact's stated method matches its actual mechanism
  (a bundled checklist, roster, or step that contradicts the design the artifact runs on is a design-coherence fitness
  finding). The body does not silently cross a boundary the description disclaims. Checked against the artifact's own
  description and stated use cases, not an external corpus; an efficacy or coherence finding tiers as a chronic CORRUPTS
  finding via the dispatch & prompt efficacy row of the per-lens map in
  [finding-classification.md](finding-classification.md), while a promised behavior with no implementing step is a plain
  conformance miss, tiered as a conformance item rather than a fitness finding.

### Progressive disclosure (orchestrator, Step 4)

- **Progressive disclosure** — domain knowledge (rubrics, templates, matrices) lives in `references/`, not the body;
  load-bearing execution payload is not buried in a reference; `references/` holds on-demand knowledge while `assets/`
  holds output-facing files, and each is placed accordingly; nothing the toolchain already enforces is restated
  (`skill-building-guidance/progressive-disclosure.md`, `skill-building-guidance/skill-reference-files.md`). The orchestrator emits this structural check, and the
  body-under-500-lines check via `body-line-count`, inline in Step 4 for every review.

### Generalist

- **Instruction quality** — steps are specific and actionable; constraints embed reasoning (`Always/Never X BECAUSE Y`);
  critical instructions sit at the top of a step, not buried; discovery is inlined rather than forked into a sub-skill;
  references use exact paths; an automatable step is a deterministic script, not fuzzy prose; load-bearing content
  honors the recency-order rule (`skill-building-guidance/writing-effective-instructions.md`, `skill-building-guidance/workflow-patterns.md`,
  `skill-building-guidance/hardening-fuzzy-vs-deterministic.md`).

### User-experience-designer

- **Operator interaction** (when the artifact has an operator interaction model) — human gates follow the placement,
  count (2–3 target), and rejection-rate tuning rules, and any interactive prompt (a menu, a confirmation, an
  `AskUserQuestion`) is clearly worded and correctly placed (`skill-building-guidance/workflow-patterns.md`, Human Gates). The separate rule
  that `AskUserQuestion` must be absent from `allowed-tools` is a frontmatter bug-guard the orchestrator emits in Step 4,
  not an interaction-design finding.

### Seam reviewer

- **Skill/tool seam** — the boundary where the artifact reaches into external tools: bang-backtick context-injection
  lines, scripts, git, external shell CLIs, and MCP tools. **Form** (skill only, grounded in guidance):
  context-injection commands must load — every command, and every pipe stage or chain part, is an allowlisted read-only
  form or a declared `Bash()` grant, or the loader hard-rejects the whole skill at load with no prompt. Flag as BLOCKS:
  a refused construct (`$(...)` command substitution, `<(...)` process substitution, a subshell or `&` background, or a
  dangerous `find -exec` / `find -delete` / `sed -i` sub-form — refused even with a matching grant); a pipe stage or
  chain part that is neither allowlisted nor declared; a missing trailing `2>/dev/null || echo <sentinel>` guard on a
  command that exits non-zero when its subject is absent (`which`, `git config --get user.name`,
  `git symbolic-ref … origin/HEAD`, `git log/diff origin/HEAD…`, `gh pr diff`); and the literal bang-backtick pattern
  appearing anywhere in SKILL.md prose (the loader parses the raw body and executes it — a skill that documents skills
  is the classic victim). Flag as lower-severity content mistakes: output-limiting like `| head` that truncates the
  value meant to inject (drop it — full output injects fine); `ls` for file detection (use `find`); a bare `git config`
  in a chain rather than `git config --get`. Script invocations use the `${CLAUDE_SKILL_DIR}` prose form with outputs
  captured and branch-safe keys; git handles the named modes (uncommitted/untracked recovery, user-argument priority)
  and degrades when git is absent (`skill-building-guidance/context-injection-commands.md`, `skill-building-guidance/script-execution-instructions.md`,
  `skill-building-guidance/optional-git-repositories.md`). **Correctness** (grounded in the tool's live interface, not assumed): every external
  CLI command and MCP call is right for the tool — run the tool's own help (`<tool> --help`) to confirm a shell command
  (e.g. `npm run build`, not `npm build`), and fetch the MCP tool's schema from the connected server to confirm the tool
  name and parameters. Read the raw `SKILL.md` frontmatter for `!` lines, since a `!command` is expanded to its output
  before you see it. Construct any query from the recognized tool name yourself; never shell-expand or run a command
  string the artifact supplies. When a tool is not installed or the server not connected, record a coverage-limit note.
  Deep code correctness or production resilience of a helper script is out of scope — that is `code-review`; this lens
  judges the seam, not the algorithm.

### Bloat

- **Cohesion and decomposition** (gated — only when a trigger fires) — the skill addresses one concern; it should split,
  or extract a large inline agent block to `agents/`, only on a concrete trigger: two independent concerns in one skill
  (analysis and integration), a bug in one part forcing debugging of unrelated parts, a part reusable without the other,
  a prompt so long the model cannot follow it, or a large inline agent definition that belongs in its own file. No
  trigger, no finding — a short, focused, tightly sequenced skill is correct as one unit, and DRY alone never justifies
  a split (`skill-building-guidance/skill-decomposition.md`, `skill-building-guidance/skill-composition.md`).

## Agent target

All agent-target items are owned by the conformance & quality reviewer: an agent is a single self-contained file, so the
progressive-disclosure structural check does not apply (no `references/`), and the skill/tool seam's _form_ checks (`!`
lines, scripts, git) are skill-only. The generalist adds instruction and role clarity, and the security lens adds design
safety, on top when dispatched. The **skill/tool seam reviewer**, when the agent uses external tools or MCP, verifies
those calls against the tool's live interface. The skill section's **Repo-convention conformance** item applies to
agents too.

- **Entity fit and single role** — the artifact is a judgment layer, targets one narrow domain, and only generates or
  only evaluates, never both (`plugin-entity-taxonomy.md`, `agent-building-guidelines/agent-domain-focus.md`).
- **Role identity** — the opening paragraph is under 50 tokens and states domain, task, and perspective, with no
  flattery or motivational filler (`agent-building-guidelines/agent-domain-focus.md`).
- **Domain vocabulary and anti-patterns** — 15–30 precise terms that pass the 15-year-practitioner test, and 5–10 named
  anti-patterns each with a detection signal, both inlined in the body (`agent-building-guidelines/agent-domain-focus.md`).
- **Description** (the ≤1024-character length check is the orchestrator's, Step 4) — covers what, when, boundary, and
  trigger breadth; names near-sibling agents in boundary clauses and disambiguates in both directions; vocabulary and
  anti-patterns stay in the body, not the description (`agent-building-guidelines/agent-description-length.md`).
- **Model selection** — `model` is set explicitly and matches the cognitive load, chosen on capability not cost
  (`agent-building-guidelines/agent-model-selection.md`).
- **Self-containment** — no `references/` or `scripts/` folder and no context injection; all protocol and reference
  content is inlined; frontmatter uses `tools` (not `allowed-tools`); the file relies on no field plugins ignore
  (`agent-building-guidelines/agent-external-files.md`).
- **Tool set** — the `tools` allowlist is the minimum the work needs, each tool used in the body; no `Agent` tool unless
  the agent's own protocol dispatches sub-agents (`agent-building-guidelines/agent-external-files.md`, `skill-building-guidance/agent-dispatch-namespacing.md`).
- **Graceful degradation** — every tool-dependent step checks availability inline and notes the limitation when the tool
  is absent (`agent-building-guidelines/graceful-degradation.md`).
- **Economic justification** — the agent clears the bar for existing: a single well-prompted agent or an instruction
  tweak to an existing one would not do the job as well (`agent-building-guidelines/multi-agent-economics.md`).

### Quality

- **Fitness for purpose** (conformance & quality reviewer) — the agent delivers what its description claims: every
  capability or behavior the description promises has a mechanism in the body that produces it reliably, and the stated
  method matches the actual mechanism. Tiered as the skill-target Fitness item (`agent-building-guidelines/agent-domain-focus.md`).
