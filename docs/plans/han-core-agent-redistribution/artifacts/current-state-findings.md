# Current State Findings: han-core Agent Redistribution

## Provenance

Produced by this run's own discovery round on 2026-10-15. Nothing in the area had a prior findings report. The research
report `docs/research/cross-plugin-config-discovery.md` is the reason for the change and is cited where it carries a
codebase fact (its A-numbered sources).

- `han-core:structural-analyst` covered the reference map, routing text between agents, roster copies, and the places
  outside skills that hard-code agent namespaces. Its findings were S-1 to S-17.
- `han-core:behavioral-analyst` covered how skills select and dispatch agents, what each dispatch site does when an agent
  is missing, fixed pipelines, and cap counting. Its findings were B-1 to B-22.
- `han-core:concurrency-analyst` was not dispatched. The area is markdown and has no concurrent access.
- The run's own sweep added the project context, the git history of earlier agent moves, the plugin manifests, and a
  correction to S-14 (C-17).

Both specialists worked by grep and excerpt reads. They did not read every one of about 650 hits individually. The
structural pass spot-checked about 12 reference-file classifications.

## Project Context

- **Stack:** Markdown skill, agent, and doc content, plus Bash scripts. npm manages dev tooling only. `npm test` runs Bats
  over every `*.bats` file. `npm run lint` runs prek (Prettier, ShellCheck, file hygiene).
- **Conventions source:** `CLAUDE.md` (project map and `## Project Discovery`), `CONTRIBUTING.md`.
- **ADRs found:** `docs/adr/0001-project-configurable-default-swarm-size.md`, which does not bear on agent placement. The
  placement decision of record is D1 in `docs/plans/han-core-restructure/artifacts/decision-log.md:19-30`, which is a
  plan decision and not an ADR.
- **Coding standards found:** the agent placement rule in `CONTRIBUTING.md:203-211`, the namespacing rule in
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/agent-dispatch-namespacing.md`, and
  `docs/semantic-versioning.md`.
- **Recent churn:** the most-touched agents in `han-core/agents/` over the last 90 days are `test-engineer`,
  `on-call-engineer`, `junior-developer`, and `data-engineer` (6 touches each). The `test-engineer` count includes the
  reverted spike. Commit messages were not classified.

## Gaps

- No ADR records where agents live or why. D1 is a plan decision only.
- No test checks that a dispatched agent name resolves, that the duplicated roster copies agree, or that vendored rule
  copies match (research A33, structural S-11).
- No mechanism exists anywhere for a skill to dispatch a shipped agent conditionally on its being installed (C-9).
- Nothing documents what the Agent tool returns for an unknown agent name (research A7, A8, A9). See Findings No Agent
  Could Audit.

## Findings

### C-1: Every han-core agent except project-scanner is dispatched by two or more plugins

- **Claim:** No `han-core` agent other than `project-scanner` meets the current placement rule's "one plugin dispatches
  it exclusively" test.
- **Location:** dispatch sites across `han-coding/`, `han-planning/`, `han-research/`, `han-documentation/`,
  `han-ddd/`, and `han-github/`. The full table is in C-19.
- **Evidence:** distinct dispatching plugins per agent:
  ```
  1: project-scanner (han-core only)
  2: concurrency-analyst, edge-case-explorer, test-engineer (coding, planning); plan-synthesizer (planning, research)
  3: adversarial-security-analyst, adversarial-validator, data-engineer, devops-engineer,
     evidence-based-investigator, gap-analyzer, observability-engineer, on-call-engineer,
     user-experience-designer (coding, planning, research); behavioral-analyst, structural-analyst
     (coding, planning, ddd); risk-analyst (coding, planning, documentation)
  4: content-auditor, information-architect, software-architect (coding, planning, documentation, research)
  5: codebase-explorer (atlassian-by-wrapper, coding, documentation, planning, research);
     junior-developer (coding, planning, documentation, github, research);
     system-architect (coding, planning, documentation, ddd, research)
  ```
- **Raised by:** structural-analyst S-1, S-2.
- **Confidence:** Verified.
- **Bears on:** —

### C-2: The current placement rule keeps agents in han-core unless one plugin's skill family dispatches them exclusively

- **Claim:** Agents default to `han-core`. Three have moved out under the exclusivity test, and restructure decision D1
  rejected splitting the roster between `han-planning` and `han-coding`.
- **Location:** `CONTRIBUTING.md:203-211`. `docs/plans/han-core-restructure/artifacts/decision-log.md:19-30`.
- **Evidence:**
  ```
  New agents live in `han-core` by default; an agent moves out only when a single skill family in one plugin above
  `han-core` dispatches it exclusively. Today that is the readability-editor, ... the research-analyst, ... and the
  discussion-facilitator, living in `han-planning` with `plan-implementation`.
  ```
  D1: "Split the roster between han-planning and han-coding — rejected because their dispatch sets overlap heavily and
  the union covers nearly every agent (E1, E2)."
- **Raised by:** structural-analyst S-2. Behavioral-analyst B-21. Research A28, A29.
- **Confidence:** Verified. `CONTRIBUTING.md:25` says "four exceptions" while line 205 names three, a small internal
  mismatch.
- **Bears on:** —

### C-3: Every existing cross-plugin agent dispatch is a qualified name backed by a hard dependency

- **Claim:** Every dispatching plugin already declares `han-core`. Nothing in the suite dispatches a shipped agent
  through a role or conditionally on installation.
- **Location:** `*/.claude-plugin/plugin.json`. Dispatch prose, for example
  `han-planning/skills/plan-a-change/SKILL.md:198`.
- **Evidence:**
  ```
  han-coding, han-ddd, han-documentation, han-planning, han-research: [han-communication, han-core]
  han-github: [han-communication, han-core, han-coding]
  han-atlassian: [han-communication, han-core, han-documentation, han-planning, han-coding]
  han-feedback, han-linear, han-plugin-builder, han-communication: []   han-reporting: [han-communication]
  ```
  "Dispatch `han-core:software-architect` with the current-state findings…" (no absence handling nearby).
- **Raised by:** structural-analyst S-1. Behavioral-analyst B-1, B-21.
- **Confidence:** Verified.
- **Bears on:** —

### C-4: Plugins without a han-core dependency only mention agents and never dispatch them

- **Claim:** `han-feedback` parses `subagent_type` strings from session logs as data. `han-plugin-builder` uses agent
  names as illustrative examples (`example-plugin:structural-analyst`). `han-atlassian` names `han-core:codebase-explorer`
  only in prose describing what the `han-coding` skill it wraps does.
- **Location:** `han-feedback/skills/han-feedback/SKILL.md:57,101,193`;
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/agent-dispatch-namespacing.md:20-64`;
  `han-atlassian/skills/code-overview-to-confluence/SKILL.md:74`.
- **Evidence:** "`subagent_type` is `han-core:adversarial-security-analyst`, or skill output naming a Han agent it
  launched".
- **Raised by:** structural-analyst S-3. Behavioral-analyst B-20.
- **Confidence:** Verified.
- **Bears on:** —

### C-5: Agents name their siblings by bare name in their descriptions, in two dense clusters

- **Claim:** "Does not X — use Y" routing lives in agent `description:` frontmatter and names siblings without a
  namespace. The architecture sextet and the operations quintet each name nearly every other member.
- **Location:** `han-core/agents/*.md` frontmatter, lines 5-12.
- **Evidence:**
  ```
  Architecture: structural-analyst, behavioral-analyst, concurrency-analyst, risk-analyst,
                software-architect, system-architect
  Operations:   devops-engineer, on-call-engineer, observability-engineer, data-engineer,
                adversarial-security-analyst
  Pairs:        test-engineer <-> edge-case-explorer;
                content-auditor <-> information-architect <-> gap-analyzer;
                user-experience-designer -> information-architect
  ```
  Upward edges that already cross a plugin boundary: `codebase-explorer` and `evidence-based-investigator` say "use
  research-analyst" (`han-research`), and `plan-synthesizer` names `discussion-facilitator` (`han-planning`).
- **Raised by:** structural-analyst S-4.
- **Confidence:** Verified.
- **Bears on:** —

### C-6: Agents cannot dispatch, so routing text is advice to the caller and never fails at runtime

- **Claim:** No agent's `tools:` line includes `Agent`. A sibling name in an agent body is a record entry for the human
  or the calling skill, not a dispatch.
- **Location:** `han-core/agents/plan-synthesizer.md:11`, `han-planning/agents/discussion-facilitator.md:12`, and every
  other agent's frontmatter.
- **Evidence:** `tools: Read, Glob, Grep, Bash(git *), Bash(find *), Write`
- **Raised by:** behavioral-analyst B-18.
- **Confidence:** Verified.
- **Bears on:** —

### C-7: Three agents carry hand-copied roster lists that assume every specialist is present

- **Claim:** `plan-synthesizer`, `junior-developer`, and `discussion-facilitator` each carry a "specialists available on
  this team" list by bare name. Each one tells its reader to record whether each specialist "must still be brought in".
  None of them can tell which specialists are installed. The `plan-synthesizer` list omits `data-engineer`,
  `on-call-engineer`, and `observability-engineer`, all three of which planning dispatches.
- **Location:** `han-core/agents/plan-synthesizer.md:136-159` (repeated as a `Domain:` enum at :354);
  `han-core/agents/junior-developer.md:227-248`; `han-planning/agents/discussion-facilitator.md:135-150`.
- **Evidence:** `**Test planning for observable behavior** → `test-engineer`` (plan-synthesizer :153);
  `**Test planning depth, behavior-focused tests, test doubles** → `test-engineer`` (junior-developer :241).
- **Raised by:** structural-analyst S-5, S-6. Behavioral-analyst B-18, B-22.
- **Confidence:** Verified for the lists. Exact line ranges for `junior-developer` and `discussion-facilitator` came from
  excerpts.
- **Bears on:** —

### C-8: Selection-condition prose for the same agent is duplicated across five consumer files in three plugins

- **Claim:** Each consumer writes its own "select X when…" trigger text, often near-verbatim. Example: the
  `observability-engineer` trigger appears in code-review, plan-a-feature, and gap-analysis.
- **Location:** `han-coding/skills/code-review/references/agent-dispatch.md:28-43`;
  `han-planning/skills/plan-a-feature/references/review-team-briefs.md:18-30`;
  `han-planning/skills/iterative-plan-review/references/team-selection.md:8-96`;
  `han-planning/skills/plan-implementation/references/team-selection.md:22-157`;
  `han-research/skills/gap-analysis/SKILL.md:173-195`.
- **Evidence:** "metric instruments or labels, span attributes, log schemas, OpenTelemetry SDK setup (samplers,
  exporters, resource…" appears at `agent-dispatch.md:39` and `review-team-briefs.md:24`.
- **Raised by:** structural-analyst S-12, S-13.
- **Confidence:** Verified for the cited pair. Not checked across every agent.
- **Bears on:** —

### C-9: The only skip-with-a-note rule covers config-named extra agents, not shipped agents

- **Claim:** `config-rule.md` skips an extra agent that does not resolve, with a one-line note. Its degradation rule
  confines notes to "content that attempts a recognized override", so an unfilled role is not covered as written. The
  extras clause is repeated at 11 call sites.
- **Location:** `han-core/references/config-rule.md:111-139`. The call sites include
  `han-planning/skills/*/references/team-selection.md`, `han-coding/skills/code-review/references/agent-dispatch.md:63-66`,
  `han-coding/skills/{architectural-analysis,investigate,automated-test-planning,design-an-api}/SKILL.md`, and
  `han-research/skills/research/SKILL.md:177-181`.
- **Evidence:**
  ```
  An entry that does not resolve to a dispatchable agent is skipped with the one-line note naming it.
  ...
  Show a one-line note only when content that attempts a recognized override cannot be used; pass over
  everything else silently.
  ```
- **Raised by:** behavioral-analyst B-3. Research A23.
- **Confidence:** Verified.
- **Bears on:** —

### C-10: Some dispatches are required producers and others are optional pool members, and only the second can go unfilled safely

- **Claim:** An agent that a skill always dispatches as the sole producer of a section cannot be an optional role
  without breaking that skill. Pool members chosen by signal under a cap can go unfilled with fewer reviewers as the
  only cost.
- **Location:** the table in C-20.
- **Evidence:** "`han-core:structural-analyst`, `han-core:behavioral-analyst`, `han-core:risk-analyst`, and
  `han-core:software-architect` run at every size BECAUSE structure, runtime behavior, risk-of-inaction, and SOLID
  synthesis are the irreducible core of an architectural read." (`han-coding/skills/architectural-analysis/SKILL.md:39-44`)
- **Raised by:** behavioral-analyst B-2, B-12 to B-15.
- **Confidence:** Verified.
- **Bears on:** —

### C-11: Two "absent agent" precedents already exist, system-architect's deferral note and plan-synthesizer's band skip

- **Claim:** `architectural-analysis` and `plan-a-change` already render a no-`system-architect` state as a one-line
  deferral. `gap-analysis` already consolidates without `plan-synthesizer` at small size. Code-review prints a named
  coverage gap when the security analyst is absent from a typed run, and marks per-agent "Not covered".
- **Location:** `han-coding/skills/architectural-analysis/SKILL.md:270-273`;
  `han-planning/skills/plan-a-change/SKILL.md:203`; `han-research/skills/gap-analysis/SKILL.md:58-61,315`;
  `han-coding/skills/code-review/SKILL.md:131-134`; `han-coding/skills/code-review/references/agent-dispatch.md:275-277`.
- **Evidence:** "If `han-core:plan-synthesizer` is not on the team, skip to Step 6." / "`Security analysis did not run on
  this review.`"
- **Raised by:** behavioral-analyst B-6, B-11, B-12, B-14.
- **Confidence:** Verified.
- **Bears on:** —

### C-12: Skills count team caps in two incompatible ways

- **Claim:** `plan-implementation`, `plan-a-change`, and `iterative-plan-review` count chosen specialists only.
  `plan-a-feature`, `architectural-analysis`, `design-an-api`, `research`, and `gap-analysis` count total seats.
  Code-review has no numeric cap. The spike's "counted once against the team's size cap" presumed a single model.
- **Location:** `han-planning/skills/plan-implementation/references/team-selection.md:18-19`;
  `han-planning/skills/plan-a-feature/SKILL.md:296-302`; `han-coding/skills/architectural-analysis/SKILL.md:158-162`;
  `han-coding/skills/code-review/references/agent-dispatch.md:69`.
- **Evidence:** "The cap is counted in **chosen specialists**, not in total seats." vs. "Small | 2
  (han-core:junior-developer + 1 chosen specialist)".
- **Raised by:** behavioral-analyst B-10.
- **Confidence:** Verified.
- **Bears on:** —

### C-13: Code-review uses the same agent as required in one review type and optional in another

- **Claim:** Each typed review has `Always:` and `When relevant:` agents. A default run always dispatches only
  `junior-developer` and `adversarial-security-analyst`.
- **Location:** `han-coding/skills/code-review/references/types/*.md:9-10`;
  `han-coding/skills/code-review/SKILL.md:116-120`.
- **Evidence:**
  ```
  architecture: Always structural, behavioral | data: Always data-engineer; relevant on-call
  observability: Always observability | release: Always devops; relevant data-engineer
  testing: Always test-engineer, edge-case-explorer | resilience: Always on-call; relevant concurrency
  ux: Always user-experience-designer | maintainability: Always junior-developer
  docs: Always information-architect; relevant content-auditor
  work-ticket: Always gap-analyzer; relevant test-engineer | security: Always adversarial-security-analyst
  ```
- **Raised by:** behavioral-analyst B-7.
- **Confidence:** Verified.
- **Bears on:** —

### C-14: Code-review's manual-only mode might fire for a single missing agent

- **Claim:** Code-review switches the whole run to manual-only when a dispatch call "is made and denied". Whether an
  unknown agent name lands there, or in the per-agent "Not covered" path, is undetermined.
- **Location:** `han-coding/skills/code-review/references/agent-dispatch.md:282-311`.
- **Evidence:** "Do not probe for availability before dispatching; the attempt is the detection."
- **Raised by:** behavioral-analyst B-5.
- **Confidence:** Unverified. The Agent tool's error for an unknown name could not be inspected.
- **Bears on:** —

### C-15: Agent bodies cite no han-core reference files, and long-form docs link to their agent by relative path

- **Claim:** Moving an agent file breaks no reference-file path inside it. Its long-form doc in `han-core/docs/agents/`
  links `../../agents/{name}.md` and has to move with it. `han-research/docs/skills/gap-analysis.md:371` links
  `../../../han-core/agents/gap-analyzer.md` directly.
- **Location:** `han-core/agents/*.md`; `han-core/docs/agents/*.md:5`; `docs/agents/README.md` (23 links).
- **Evidence:** a grep of agent bodies for `references/`, `han-core/`, `evidence-rule`, `yagni`, `config-rule`, and
  `readability` returned no hits.
- **Raised by:** structural-analyst S-10, S-11.
- **Confidence:** Verified.
- **Bears on:** —

### C-16: Tooling and evals hard-code han-core as the agent home

- **Claim:** Three eval suites dispatch agents by `han-core:` name. The repo's own doc-update skill treats
  `han-core/agents` as the single agent root. The plugin-builder guidance teaches `han-core:agent-name` qualified
  dispatch.
- **Location:** `evals/{test-engineer,edge-case-explorer,gap-analyzer}/tests.json` (`"agentFile": "han-core:{name}"`,
  `"plugins": ["han-core"]`); `.claude/skills/han-update-documentation/scripts/detect-doc-update-context.sh:18`, `SKILL.md:89`,
  `references/scope-mapping.md:12,56`, and `references/audit-checklist.md:19,81,93`;
  `han-plugin-builder/skills/guidance/assets/rule-index-body.md:97`.
- **Evidence:** `#   agent-root       the single directory that holds agents (han-core/agents),`
- **Raised by:** structural-analyst S-11. Run sweep (script header read).
- **Confidence:** Verified for the header. Whether the script body already walks more than one agent directory is
  Unverified. Agents already live in four plugins, so it likely misses three today.
- **Bears on:** —

### C-17: CLAUDE.md on disk matches the reverted state, which corrects S-14

- **Claim:** The structural pass reported that CLAUDE.md still describes `agent-roles.md` and a moved `test-engineer`.
  It read the instructions loaded at session start, before the revert. On disk, CLAUDE.md has zero `agent-roles`
  mentions, and the revert's diff against `1de07d0` is empty.
- **Location:** `CLAUDE.md`.
- **Evidence:** `grep -c "agent-roles" CLAUDE.md` → `0`; `git diff 1de07d0 --stat` → no output.
- **Raised by:** run sweep, correcting structural-analyst S-14.
- **Confidence:** Verified.
- **Bears on:** —

### C-18: The reverted spike is the only worked example of the role mechanism

- **Claim:** The spike defined a `han-planning`-owned `agent-roles.md` that holds the claim sentence, a four-step fill
  procedure, and one role. It added a Bats test that checks claim syntax, not runtime fill. It edited only planning
  consumers, so it never exercised the total-seat cap skills or code-review. It moved the long-form doc, rewrote the
  `han-coding` dispatch namespace, rewrote routing text in three agents, and changed 13 eval references.
- **Location:** `git show 24e3ccd:han-planning/references/agent-roles.md`; `git show abdb80a:test/agent-roles.bats`;
  commit stats for `1ea9d0c` and `3e276b8`.
- **Evidence:**
  ```
  Fills the han-planning `test-planning` role.
  ...
  4. If none claims it, skip the role and add one line to the team announcement, for example: "Skipped the
     `test-planning` role: no installed agent fills it." This is not an error, and the run continues.
  ```
- **Raised by:** behavioral-analyst B-10, B-17. Structural-analyst S-14. Run sweep.
- **Confidence:** Verified. It was never run end to end, which is Unverified (B-11).
- **Bears on:** —

### C-19: Per-agent dispatch map

- **Claim:** Where each agent is dispatched. Routing-only and mention-only references are excluded. Details and line
  numbers are in the structural pass's table, preserved in summary here.
- **Location:** see each row.
- **Evidence:**

  | Agent | Dispatching plugins and skills |
  | --- | --- |
  | adversarial-security-analyst | coding: architectural-analysis, automated-test-planning, code-review (default always), design-an-api; planning: iterative-plan-review, plan-a-change, plan-a-feature, plan-implementation; research: gap-analysis |
  | adversarial-validator | coding: code-overview, code-review (7.4), design-an-api, investigate, manual-test-planning; planning: iterative-plan-review; research: gap-analysis, research |
  | behavioral-analyst | coding: architectural-analysis, code-review, design-an-api, investigate; ddd: ddd-analysis; planning: 4 skills |
  | codebase-explorer | coding: architectural-analysis, code-overview, code-walkthrough, coding-standard, design-an-api; documentation: adr, project-documentation; planning: iterative-plan-review; research: gap-analysis, research |
  | concurrency-analyst | coding: architectural-analysis, automated-test-planning, code-review, design-an-api, investigate; planning: 4 skills |
  | content-auditor | coding: code-review (docs, relevant); documentation: project-documentation; planning: iterative-plan-review; research: gap-analysis |
  | data-engineer | coding: architectural-analysis, code-review, design-an-api, investigate; planning: iterative-plan-review, plan-a-change, plan-implementation; research: gap-analysis |
  | devops-engineer | coding: architectural-analysis, code-review; planning: 4 skills; research: gap-analysis |
  | edge-case-explorer | coding: automated-test-planning, code-review; planning: iterative-plan-review, plan-a-feature, plan-implementation |
  | evidence-based-investigator | coding: investigate; planning: iterative-plan-review; research: gap-analysis |
  | gap-analyzer | coding: code-review (work-ticket); planning: iterative-plan-review, plan-a-feature; research: gap-analysis |
  | information-architect | coding: automated-test-planning, code-review, coding-standard; documentation: project-documentation; planning: plan-a-phased-build (plan-work-items names it in a catalog only); research: gap-analysis |
  | junior-developer | coding: automated-test-planning, code-review, coding-standard, design-an-api; documentation: adr; github: post-code-review-to-pr, update-pr-description; planning: 4 skills + round aggregation; research: gap-analysis |
  | observability-engineer | coding: architectural-analysis, code-review; planning: 4 skills; research: gap-analysis |
  | on-call-engineer | coding: architectural-analysis, code-review, code-walkthrough, design-an-api; planning: 4 skills; research: gap-analysis |
  | plan-synthesizer | planning: plan-a-feature, plan-implementation, plan-work-items; research: gap-analysis |
  | project-scanner | core: project-discovery |
  | risk-analyst | coding: architectural-analysis; documentation: adr; planning: 4 skills |
  | software-architect | coding: architectural-analysis, design-an-api; documentation: adr; planning: 4 skills; research: gap-analysis |
  | structural-analyst | coding: architectural-analysis, code-review, design-an-api; ddd: ddd-analysis; planning: 4 skills |
  | system-architect | coding: architectural-analysis, design-an-api; documentation: adr; planning: 4 skills; research: gap-analysis; ddd: named as a next step only |
  | test-engineer | coding: automated-test-planning, code-review; planning: iterative-plan-review, plan-a-change, plan-a-feature, plan-implementation |
  | user-experience-designer | coding: code-review (ux type); planning: 4 skills; research: gap-analysis |

- **Raised by:** structural-analyst S-9, corrected for `research` dispatching `adversarial-validator` and
  `codebase-explorer`.
- **Confidence:** Verified for plugin membership. The skill lists rest on a grep plus spot-checks.
- **Bears on:** —

### C-20: Required versus optional, per plugin, for every agent

- **Claim:** Which plugins *require* each agent, meaning an always-dispatched sole producer or a fixed seat whose absence
  breaks the skill's output. Every other dispatch is optional.
- **Location:** the behavioral pass's table, which follows B-14.
- **Evidence:**

  | Agent | Required in | Optional in |
  | --- | --- | --- |
  | junior-developer | coding, planning, documentation, github, research | — |
  | codebase-explorer | coding, documentation | research (conditional), planning |
  | adversarial-validator | coding, planning (iterative-plan-review), research | — |
  | structural-analyst, behavioral-analyst | coding, planning (plan-a-change discovery), ddd | — |
  | software-architect | coding, planning (plan-a-change), documentation (adr) | research |
  | risk-analyst | coding, documentation (adr) | planning |
  | system-architect | — (conditional with a documented absent state everywhere) | coding, planning, documentation, research |
  | concurrency-analyst | — (conditional everywhere; in architectural-analysis's small band) | coding, planning |
  | information-architect | coding (coding-standard, code-review docs), planning (plan-a-phased-build), documentation | research |
  | gap-analyzer | research (sole analyzer), coding (work-ticket type) | planning |
  | plan-synthesizer | planning (3 skills) | research (medium and large only, with a fallback) |
  | evidence-based-investigator | coding (investigate) | planning (iterative-plan-review, conditionally mandatory), research |
  | test-engineer, edge-case-explorer | coding | planning |
  | adversarial-security-analyst | coding (code-review default run) | planning, research |
  | devops, on-call, observability, data-engineer | coding (typed code-review runs) | planning, research, coding's other skills |
  | user-experience-designer | coding (ux type) | planning, research |
  | content-auditor | documentation (conditional, Step 6 flag) | coding, planning, research |
  | project-scanner | core | — |

- **Raised by:** behavioral-analyst B-2, B-7, B-12 to B-16, synthesized by this run.
- **Confidence:** Verified for the sites the behavioral pass read. The "required" label is this run's synthesis of its
  always/optional table.
- **Bears on:** —

## Findings No Agent Could Audit

- **What the Agent tool returns for an unknown agent name.** This is host runtime, not in the repo, and the research
  sources conflict (A8, A9). Closing it takes a live session that dispatches a non-existent `plugin:agent` name. It
  decides whether a role fill can safely try a dispatch, or must check the session's agent list first.
- **Whether every installed agent's description reaches a skill's context, including after compaction.** Research A7
  documents it, and this session's own agent list shows it directly (A34). Nobody tested it as a contract the model
  reliably matches role claims against. Closing it takes one live run of a planning skill with and without the providing
  plugin installed.
- **Codex.** Whether Codex shows agents and their descriptions to the model is undocumented (A12).
