# Consolidation Register

Six consolidation candidates surfaced during the sweep. **Nothing here was acted on.** The repository still holds 40
skills and 24 agents, the same counts it started with.

This register exists because the user asked for it in the recorded boundary: "if there are skills or agents that can be
consolidated, record them and the reasons but take no action on that. it's something to consider late."

The guidance sets roughly 80 percent overlap as the line between genuine duplication and entities that share a
foundation but serve different purposes. Where a candidate below is clearly under that line, it says so, because a
register that lists everything adjacent is no more useful than an empty one.

## 1. The four Confluence wrapper skills

**Entities.** `code-overview-to-confluence`, `investigate-to-confluence`, `project-documentation-to-confluence`, and
`plan-a-feature-to-confluence`, all in `han-atlassian`.

**The overlap.** All four run the same five or six steps in the same order: check the Atlassian server is reachable,
validate inputs, run one wrapped skill to a temporary folder, get the user's publish choice, hand every file to
`markdown-to-confluence`. Three of the four are within 12 lines of each other. What differs is which skill gets wrapped
and which arguments get forwarded.

**Why someone would merge them.** One parameterized publishing skill taking the wrapped skill as an argument would
replace four near-identical bodies, and a change to the orchestration discipline would be made once instead of four
times.

**Why it is not obvious.** Each wrapper's `description` is its own routing surface. A single merged skill needs one
description covering four distinct request shapes, and the length budget that keeps trigger words loaded is the
constraint that would bite. `plan-a-feature-to-confluence` is also visibly the odd one at 213 lines against 118 to 130,
because it forwards a size argument and owns an output-location override.

**Confidence this clears the 80 percent line: high, for three of the four.**

## 2. The three tracker exporters

**Entities.** `work-items-to-issues` (GitHub), `work-items-to-jira`, and `work-items-to-linear`, one per plugin.

**The overlap.** Each reads the same `work-items.md` produced by `plan-work-items`, maps the same fields, and creates
one tracker item per work item with the same parent-child handling. The differences are the target API, the
authentication path, and the field vocabulary.

**Why someone would merge them.** The mapping from a work item to a tracker item is the substance, and it is written
three times.

**Why it is not obvious.** They live in three different plugins on purpose, two of which are opt-in and require a
different MCP server. Merging them would force one plugin to depend on all three integrations, which is the opposite of
what the opt-in split is for. The shared part is the mapping, not the skill.

**Confidence: moderate on the mapping, low on the skills.** The reusable thing here is probably a shared reference file
describing the work-item-to-ticket mapping, not one merged skill.

## 3. The three code analysts

**Entities.** `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`.

**The overlap.** Identical shape: 128 to 144 lines, five or six sections in the same order, the same tool set, the same
output contract of numbered findings with file paths and verbatim code, and boundary clauses that point at each other
and at the same four siblings.

**Why someone would merge them.** From the outside they look like one agent with three modes.

**Why it should not happen.** This is the case the guidance argues against directly. Their domain vocabularies do not
overlap, and combining them is the generalist trap: one agent carrying all three vocabularies activates shallower
knowledge in each. The shape is shared; the expertise is not.

**Confidence: below the line. Recorded so nobody re-proposes it without reading this.**

## 4. `readability-editor` generates and evaluates

**Entity.** `readability-editor`, in `han-communication`.

**The overlap.** Not overlap with a sibling. It is the one-role rule: this agent rewrites a draft and then reports on
whether its own rewrite preserved every fact. The guidance says an agent should generate or evaluate, never both,
because generator bias replicates in evaluation.

**Why someone would split it.** A separate fact-preservation checker would not share the rewriter's blind spots.

**Why it did not happen here.** Splitting creates a new agent, which changes the entity count that the recorded
direction of travel rules out. The self-check was also deliberately kept during the self-verification sweep, because it
is the only fidelity guard on a rewrite.

**Confidence: real, and the cost of the split is a second dispatch on every readability pass.**

## 5. The two inline guidance surfacers

**Entities.** `readability-guidance` (92 lines) and `explanation-guidance` (64 lines), both in `han-communication`.

**The overlap.** Both exist to read a canonical rule file into the caller's context and hand control straight back. Both
open by saying they are inline, both warn the caller not to treat the return as a stopping point, and both end by
telling the caller to resume.

**Why someone would merge them.** One surfacing skill taking the standard's name as an argument would carry that shared
scaffolding once.

**Why it is not obvious.** They are invoked at different moments and the distinction is load-bearing: one governs the
shape of a written deliverable, the other governs what a run says to a person in a turn. Several skills invoke both, at
different steps. A merged skill would need the caller to pass the right argument at the right moment, replacing a
distinction the skill names with one the caller has to remember.

**Confidence: moderate on the scaffolding, low on the skills.**

## 6. `edge-case-explorer` and `test-engineer`

**Entities.** Both in `han-core`.

**The overlap.** Both analyze code to decide what should be tested, and both produce a prioritized plan rather than
tests.

**Why it is under the line.** Their descriptions already disambiguate in both directions, and the split is real:
`test-engineer` plans coverage across observable behaviors, `edge-case-explorer` exhausts boundary conditions on a
narrower target. `test-engineer` dispatches to `edge-case-explorer` rather than duplicating it.

**Confidence: below the line. Listed because the pair comes up, not because it should merge.**

## What is not in this register

Pairs the repository has already split on purpose, with the reasoning recorded elsewhere, are not candidates:
`code-review` and `post-code-review-to-pr`, `project-discovery` and `project-documentation`, `automated-test-planning`
and `manual-test-planning`, and `software-architect` and `system-architect`, which differ by altitude rather than by
duplication.

## Sources

- `han-plugin-builder/skills/guidance/references/iterative-plugin-development.md` § Identify overlap and consolidation
- `han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md` § One Role per Agent
- `docs/plans/skill-agent-guidance-conformance-sweep/artifacts/scope-boundary.md` § Stated Exclusions
