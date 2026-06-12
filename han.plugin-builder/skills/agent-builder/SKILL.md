---
name: agent-builder
description: >
  Builds a new Claude Code agent (subagent) from scratch through a relentless, evidence-based
  interview that walks the agent's design tree decision-by-decision — entity fit, domain focus and
  vocabulary, role identity, anti-patterns, description, model tier, tools, and self-containment —
  then reviews the finished agent against the plugin-building guidance and applies every fix it
  finds. Use when creating, authoring, scaffolding, designing, or drafting a new agent or
  subagent. Does not build a skill or slash command — use skill-builder. Does not serve, vendor,
  or refresh the authoring guidance itself — use guidance.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(find *), Bash(mkdir *)
---

## Guidance Location

The authoritative agent-authoring guidance ships in this plugin. Read the
specific document a decision needs, when that decision is on the table — never
read them all up front, because that defeats progressive disclosure and burns
context on guidance the current agent does not touch.

- Plugin-building guidance root: `${CLAUDE_PLUGIN_ROOT}/skills/guidance/references/`
- Agent-specific guidance: `${CLAUDE_PLUGIN_ROOT}/skills/guidance/references/agent-building-guidelines/`

Map from decision to governing document (read just-in-time):

| Decision on the table | Read |
|---|---|
| Agent vs. skill vs. hook; one role (generate or evaluate) | `plugin-entity-taxonomy.md`, `agent-building-guidelines/agent-domain-focus.md` |
| Domain focus, vocabulary, role identity, anti-patterns | `agent-building-guidelines/agent-domain-focus.md` |
| The `description` field (four components, boundaries, length) | `agent-building-guidelines/agent-description-length.md`, `skill-building-guidance/skill-description-frontmatter.md` |
| Model tier (`opus` / `sonnet` / `haiku` / `inherit`) | `agent-building-guidelines/agent-model-selection.md`, `specialization-and-model-selection.md` |
| Self-containment — no references, scripts, or context injection | `agent-building-guidelines/agent-external-files.md` |
| Which frontmatter fields are valid (and which plugins ignore) | `agent-building-guidelines/agent-external-files.md` |
| Degraded environments (no git, missing tools) | `agent-building-guidelines/graceful-degradation.md` |
| Whether this agent is justified at all; how it gets dispatched | `agent-building-guidelines/multi-agent-economics.md`, `skill-building-guidance/agent-dispatch-namespacing.md` |
| New plugin needed (plugin.json, marketplace.json) | `claude-marketplace-and-plugin-configuration/` and `templates/` |

## Operating Principles

- **Interview relentlessly, but explore first.** Interview the user relentlessly
  about every aspect of the agent until you reach a shared understanding. Walk
  down each branch of the design tree, resolving dependencies between decisions
  one-by-one. **If a question can be answered by exploring the repository — the
  target plugin's existing agents, sibling descriptions, the skills that would
  dispatch this agent, conventions, the guidance documents above — explore
  instead of asking.** Only surface questions that genuinely require the user's
  judgment.
- **Ask one question at a time.** Never batch questions. Settle one decision,
  let its answer resolve dependent decisions, then ask the next. Later answers
  routinely make earlier questions moot.
- **Recommend, then ask.** For every question surfaced to the user, provide a
  recommended answer with rationale grounded in evidence (existing agents,
  conventions, the guidance, the user's stated goal). The user can accept,
  amend, or redirect.
- **Apply guidance as you go, then verify at the end.** Consult the governing
  document when a decision is on the table (Step 4), and run a full
  guidance-conformance pass over the finished agent at the end (Step 6). The
  interview gets each decision approximately right; the review pass makes the
  artifact correct.
- **An agent is self-contained.** Unlike a skill, an agent is a single flat
  `.md` file. No `references/` folder, no `scripts/` folder, no `` !`command` ``
  context injection. Everything the agent needs is inlined in its body.

# Build an Agent

## Step 1: Capture the Request and Confirm It Is an Agent

Read the user's argument and the conversation to extract what the agent should
do. If the request is too thin to start (for example, just "build an agent"),
ask the user for one or two sentences on the agent's domain and what it produces
— nothing else yet.

**Confirm the entity type before anything else.** Read
`${CLAUDE_PLUGIN_ROOT}/skills/guidance/references/plugin-entity-taxonomy.md` and
apply its decision heuristic. An agent is the thinking layer: it applies
contextual judgment, taste, and discernment ("Does this require reasoning about
context?" → agent). If the work is a deterministic, flowchartable process, it is
a skill — stop and recommend `skill-builder`. If it fires automatically on an
event, it is a hook.

**Confirm the single role.** An agent generates **or** evaluates, never both,
because self-evaluation bias means the reasoning that created a blind spot also
rates it as correct (`agent-domain-focus.md`). If the request bundles generation
and evaluation, recommend splitting it into a generator agent and a separate
evaluator agent. Only proceed once an agent — with one role — is the right
entity.

## Step 2: Discover Before Asking

Locate the target plugin and learn its conventions before asking the user
anything beyond the framing. Use Glob, Grep, and `find` to gather:

- The target plugin directory and its `.claude-plugin/plugin.json`. Confirm the
  plugin actually ships agents (an `agents/` directory) or is the right home for
  the first one. If the user has not said which plugin, infer candidates and
  confirm in Step 4.
- Sibling agents in that plugin (`{plugin}/agents/*.md`) — their descriptions,
  role identities, model tiers, domain vocabulary, and the boundaries they draw.
  A new agent's description must disambiguate against near-sibling agents in
  both directions.
- The skills that would dispatch this agent. An agent is dispatched by a skill
  via the `Agent` tool using the qualified `defining-plugin:agent-name`. Knowing
  the caller tells you what the agent receives and returns.
- Whether any step depends on a tool (git, a CLI) that may be absent at dispatch
  time, which drives graceful-degradation wording.

Record what was found (file paths) and what was not.

## Step 3: Build the Design Tree

Enumerate the decisions the agent needs, in dependency order. Resolve
foundational decisions before dependent ones; never ask a dependent question
before its parent is settled.

1. **Foundational** — Which plugin owns it? What is the single narrow domain?
   Generate or evaluate? What does the agent produce, and who dispatches it?
2. **Identity** — What is the Role Identity, the opening "You are a..." paragraph
   (under 50 tokens, domain + task + perspective, no flattery)? What 15-30
   domain-vocabulary terms pass the 15-year-practitioner test? What 5-10 named
   anti-patterns with detection signals does the agent hunt for?
3. **Triggering** — What does the `description` say across all four components
   (what, when, boundary, breadth), and how does it disambiguate against
   near-sibling agents in both directions, within 1024 characters?
4. **Capabilities** — What model tier fits the cognitive load (`opus` for
   synthesis and judgment, `sonnet` for structured procedures, `haiku` for fast
   lookups, `inherit` only when matching the session is intentional)? What
   `tools` does it need — and never the `Agent` tool, because subagents cannot
   spawn subagents?
5. **Body structure** — What inlined protocol, checklist, and reference content
   does the agent need to do its job, given it cannot use external files? Where
   does graceful-degradation wording belong?

Keep each node a concrete decision with a candidate answer. Do not pre-fill the
tree with content the user has not confirmed.

## Step 4: Interview Loop — One Branch at a Time

For each decision in dependency order:

1. **Try to resolve it from evidence.** Re-check the target plugin, sibling
   agents, calling skills, conventions, and the governing guidance document for
   this decision (see the map above). If the evidence answers it, record the
   decision with its evidence and move on — do not ask.
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

## Step 5: Write the Agent

Write the single self-contained file:

1. Create `{plugin}/agents/` if it does not exist (use `mkdir`), then write
   `{plugin}/agents/{agent-name}.md`. The file is flat — no per-agent
   subdirectory, no companion folders.
2. Frontmatter: `name`, the `description` settled in the interview, `tools`
   (the allowlist — agents use `tools`, not `allowed-tools`), and `model`. Add
   other supported fields (`disallowedTools`, `maxTurns`, `color`, and so on)
   only when a decision called for them. **Do not rely on `hooks`,
   `mcpServers`, or `permissionMode`** — Claude Code ignores all three on plugin
   agents as a security boundary. No XML angle brackets in any frontmatter value.
3. Body, in order: the Role Identity paragraph (under 50 tokens), then the
   `## Domain Vocabulary` section, the `## Anti-Patterns` section, and the
   inlined protocol or checklist the agent follows. Embed reasoning in
   constraints. Add graceful-degradation wording ("If {tool} is not available,
   skip this step and note the limitation") to any tool-dependent step. No
   flattery, superlatives, or motivational framing — let domain vocabulary do
   the routing.
4. If the agent belongs in a brand-new plugin, create the plugin scaffold per
   the `claude-marketplace-and-plugin-configuration/` guidance and `templates/`.

## Step 6: Full Guidance-Conformance Review

This is the review pass the skill commits to. Re-read each governing document
that applies to what you built and verify the finished agent against it,
applying every fix directly. Do not summarize problems for the user without
fixing them. Cover at minimum:

1. **Entity fit and single role** (`plugin-entity-taxonomy.md`,
   `agent-building-guidelines/agent-domain-focus.md`) — the agent is genuinely a
   judgment layer, targets one narrow domain, and only generates or only
   evaluates.
2. **Role Identity** (`agent-domain-focus.md`) — the opening paragraph is under
   50 tokens, states domain + task + perspective, and carries no flattery or
   motivational filler.
3. **Domain vocabulary and anti-patterns** (`agent-domain-focus.md`) — 15-30
   precise terms that pass the 15-year-practitioner test, and 5-10 named
   anti-patterns each with a detection signal, both inlined in the body.
4. **Description** (`agent-description-length.md`,
   `skill-description-frontmatter.md`) — covers what, when, boundary, and trigger
   breadth; names near-sibling agents in boundary clauses; disambiguates in both
   directions (repair the sibling's description if a one-way gap exists); within
   1024 characters, with domain vocabulary and anti-patterns kept in the body,
   not the description.
5. **Model selection** (`agent-model-selection.md`,
   `specialization-and-model-selection.md`) — `model` is set explicitly and
   matches the cognitive load, chosen on capability and not on cost.
6. **Self-containment** (`agent-external-files.md`) — no `references/` or
   `scripts/` folder, no `` !`command` `` context injection; all protocol and
   reference content is inlined; frontmatter uses `tools` (not `allowed-tools`),
   and the file relies on no field plugins ignore.
7. **Tool set** (`agent-dispatch-namespacing.md`, `agent-external-files.md`) —
   the agent does not have the `Agent` tool (subagents cannot spawn subagents),
   and the `tools` allowlist is the minimum the work needs.
8. **Graceful degradation** (`agent-building-guidelines/graceful-degradation.md`)
   — every tool-dependent step checks availability inline and notes the
   limitation when the tool is absent.
9. **Economic justification** (`multi-agent-economics.md`) — the agent clears
   the bar for existing: a single well-prompted agent or an instruction
   improvement to an existing agent would not do the job as well.

Apply the YAGNI discipline throughout: vocabulary terms, anti-patterns, tools,
and frontmatter fields must each earn their place against the agent's actual
job. Cut anything added "for completeness."

## Step 7: Present and Hand Off

Summarize for the user:

- The agent file written (path) and its shape (role, model, tools, vocabulary
  and anti-pattern counts).
- The decisions settled by evidence versus by user input.
- The fixes the Step 6 review applied, citing the guidance document behind each.
- How the agent is dispatched: the qualified `defining-plugin:agent-name` and
  which skill (existing or to-be-built) would call it. If a calling skill is
  needed and does not exist, recommend `skill-builder`.

Note that plugin entities rarely land in one pass: per
`iterative-plugin-development.md`, plan for 3-5 iterations. Ask whether the user
wants to iterate on the agent's domain framing or considers it ready to test.
