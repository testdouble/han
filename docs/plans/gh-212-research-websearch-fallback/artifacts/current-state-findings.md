# Current State Findings: Research without WebSearch (issue #212)

<!--
This file is the single source of truth for what the code does today. Every later
agent in the run reads it first and does not re-grep for what is already here.
The plan cites it with inline ([C-N](artifacts/current-state-findings.md#...)) links
for every claim about the code as it stands.
-->

## Provenance

Produced by this run's own discovery round on 2026-09-11. No prior findings report existed.

- `han-core:structural-analyst`, briefed on the six-file area plus the plugin-authoring guidance under
  `han-plugin-builder/skills/guidance/references/` for tool-declaration semantics. Returned S-1 through S-11.
- `han-core:behavioral-analyst`, briefed on the research run's Step 1 through Step 8 flow, the agent's output format,
  the report template, the evidence rule, and the validator's charter. Returned B-1 through B-6.
- The run's own sweep: the official Claude Code documentation for subagents, skills, the errors reference, the tools
  reference, and the Bedrock, Vertex, and Foundry pages (fetched 2026-09-11); git churn over `han-research/`; the ADR
  folder; and the `mcp__` precedents in `han-linear` and `han-atlassian`.

Every S-N and B-N identifier below names the originating finding. Where a claim came from the official docs, the
citation is the page and the line or heading.

## Project Context

- **Stack:** Markdown skill, agent, and doc content; Bash for scripts. No application build. Lint is
  `npm run lint` (Prettier, ShellCheck, file hygiene); tests are Bats via `npm test`.
- **Conventions source:** `CLAUDE.md` (`## Project Discovery`, `## Conventions`), plus the plugin-authoring guidance in
  `han-plugin-builder/skills/guidance/references/`, which `CLAUDE.md` names as mandatory for any skill or agent change.
- **ADRs found:** one, `docs/adr/0001-project-configurable-default-swarm-size.md`. It does not touch tool declarations
  or platform variance.
- **Coding standards found:** the writing-voice profile and readability rule in `han-communication/references/`, and the
  agent-building guideline `graceful-degradation.md` (see C-10).
- **Recent churn:** over the last 90 days `han-research/skills/research/SKILL.md` changed 15 times, the agent 3 times,
  the report template 2 times, and the long-form docs 4 and 3 times. The most recent research-skill change is
  `691dd52` (feedback issue #194). No commit references issue #212 or WebSearch.

## Gaps

- **No ADR on tool declarations or platform variance.** The one ADR is unrelated.
- **The authoring guidance does not describe the `mcp__server__tool` name form, wildcard entries, or optional tool
  entries** in either `tools:` or `allowed-tools:`. (S-4.) The official docs do; see C-3.
- **No repo record of what a subagent observes when a declared tool is absent.** The closest account is the `Agent`-tool
  precedent in `han-coding/skills/code-review/references/agent-dispatch.md` (C-11). No transcript or fixture from a
  Bedrock or Vertex session exists in the repo.
- **The official docs state the Bedrock limitation only.** The Vertex and Foundry pages say nothing about `WebSearch`
  either way (C-4). The issue's claim that Vertex lacks it is the issue's own observation, not confirmed by the docs.
- **No prior fix, CHANGELOG entry, or plan for this issue.** A grep for `WebSearch` outside this folder found one
  incidental mention in `docs/plans/skills-feedback-issue-36/`, which `docs/plans/CLAUDE.md` rules out as a source.

## Findings

### C-1: The agent declares `WebSearch` and its protocol assumes it is always there

- **Claim:** `research-analyst.md` names `WebSearch` in its `tools:` allowlist and its "Gather from the Open Web"
  protocol uses it unconditionally; nothing in the file says what to do when the tool is not offered.
- **Location:** `han-research/agents/research-analyst.md:9` and `:56-60`
- **Evidence:**

  ```yaml
  tools: Read, Glob, Grep, WebSearch, WebFetch
  ```

  ```markdown
  ### 2. Gather from the Open Web

  Use WebSearch and WebFetch for prior art, options, and external information. For every retrieved claim, record the
  source URL and the retrieval date.
  ```

- **Raised by:** structural-analyst (S-1, S-5)
- **Confidence:** Verified
- **Bears on:** S-1, S-2, D-3, D-4

### C-2: The skill's `allowed-tools:` pre-approves `WebSearch`; it does not gate what the agent can reach

- **Claim:** `SKILL.md` lists `WebSearch` in `allowed-tools:`. Per the repo's own guidance, that field grants permission
  for the invoking turn and does not restrict the tool set. The agent's `tools:` line is the only gate on what the
  dispatched analyst can call, so the two declarations the issue names side by side behave differently.
- **Location:** `han-research/skills/research/SKILL.md:16-18`;
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-frontmatter-fields.md:31`;
  `.../allowed-tools-AskUserQuestion.md:30`
- **Evidence:**

  ```yaml
  allowed-tools:
    Read, Write, Edit, Glob, Grep, Agent, WebSearch, WebFetch, Bash(find *),
    Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
  ```

  ```markdown
  | `allowed-tools` | No | Grants tool permissions while the skill is active. Does not restrict the available tool set, it pre-approves use. |
  ```

  ```markdown
  `allowed-tools` is an auto-approve list, not an allowlist. Tools not listed can still be called — they just require a
  one-time user permission prompt.
  ```

- **Raised by:** structural-analyst (S-3)
- **Confidence:** Verified
- **Bears on:** D-7

### C-3: Official docs: `tools:` is an allowlist, an unmatched entry is dropped silently, and MCP wildcards are accepted

- **Claim:** A subagent's `tools:` field narrows the inherited pool. An entry that matches no tool in the session is
  dropped with no error, unless the whole list resolves to nothing, in which case the launch is refused (since Claude
  Code v2.1.208). Server-level MCP patterns are accepted: `mcp__<server>` or `mcp__<server>__*`. `mcp__*` is accepted
  only in `disallowedTools`. When `tools:` is omitted the agent inherits every tool available to subagents, including
  MCP tools from the main conversation.
- **Location:** `https://code.claude.com/docs/en/sub-agents.md` (frontmatter table row `tools`; "Handling unavailable
  tools"; the second-filter paragraph; "Wildcard patterns"), and `https://code.claude.com/docs/en/errors.md#agent-would-be-spawned-with-zero-tools`, both fetched 2026-09-11
- **Evidence:**

  ```markdown
  | `tools` | No | Tools the subagent can use. Inherits every tool available to subagents if omitted. If no entry in the list resolves to a tool, the subagent usually fails to launch with an error naming the entries. |
  ```

  ```markdown
  When nothing in the `tools` list resolves to a tool, for example because every entry is misspelled or names a tool
  that isn't available to subagents, Claude Code usually refuses to launch the subagent and the Agent tool returns an
  error naming the unresolved entries; ... Before v2.1.208, that subagent launched with no tools and could return an
  empty or confusing result.
  ```

  ```markdown
  Claude Code removes every other built-in tool from a background subagent, whether inherited or listed in the `tools`
  field, so the same definition can resolve to different tools in the foreground and the background. The removal
  reports no error unless it leaves the `tools` list resolving to nothing.
  ```

  ```markdown
  Both fields accept MCP server-level patterns in addition to exact tool names: `mcp__<server>` or `mcp__<server>__*`
  grants or removes every tool from the named server. In `disallowedTools`, `mcp__*` also removes every MCP tool from
  any server.
  ```

  The errors page groups an unresolved entry as "Matched no tools in this session: the entry is valid but no tool in the
  current session matches it right now, such as `mcp__github__*` with no GitHub MCP server connected."

- **Raised by:** the run's own sweep (the `claude-code-guide` agent's answer was checked against the fetched pages; its
  claim that a partial mismatch errors was wrong and is not carried)
- **Confidence:** Verified for the "whole list" case. The partial-mismatch case (some entries resolve, one does not) is
  stated positively only for the background filter; for an unmatched entry it follows from the "nothing in the list"
  wording and matches the issue's own observation on 2.1.263 that the agent ran.
- **Bears on:** D-3, D-5

### C-4: Official docs: `WebSearch` is absent on Bedrock, the backend is not configurable, and MCP is the named substitute

- **Claim:** The Bedrock page states `WebSearch` is unavailable there. The Vertex and Foundry pages say nothing about it.
  The tools reference says the search backend cannot be changed and that a different provider is reached by adding an
  MCP server that exposes a search tool. `WebFetch` is not reported as absent on any platform.
- **Location:** `https://code.claude.com/docs/en/amazon-bedrock.md:261`;
  `https://code.claude.com/docs/en/tools-reference.md#websearch-tool-behavior` (lines 559-569); fetched 2026-09-11
- **Evidence:**

  ```markdown
  * The WebSearch tool is not available on Amazon Bedrock. See [WebSearch tool behavior](/docs/en/tools-reference#websearch-tool-behavior).
  ```

  ```markdown
  WebSearch runs a query against Anthropic's web search backend and returns result titles and URLs. It doesn't fetch
  the result pages. To read a page Claude finds in search results, it follows up with WebFetch.
  ...
  The search backend is not configurable. To search with a different provider, add an MCP server that exposes a
  search tool.
  ```

- **Raised by:** the run's own sweep
- **Confidence:** Verified for Bedrock. Vertex is the issue's claim only.
- **Bears on:** D-5

### C-5: Plugin subagents cannot carry their own MCP servers

- **Claim:** An agent loaded from a plugin has its `mcpServers`, `hooks`, and `permissionMode` frontmatter ignored. The
  repo's guidance records the same boundary. So the only way for a plugin agent to reach an MCP search tool is for the
  user to have configured the server and for the agent's `tools:` to admit it (or to be omitted).
- **Location:** `https://code.claude.com/docs/en/sub-agents.md:234,300`;
  `han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-external-files.md:117-123`
- **Evidence:**

  ```markdown
  For security reasons, plugin subagents don't support the `hooks`, `mcpServers`, or `permissionMode` frontmatter
  fields. These fields are ignored when loading agents from a plugin. If you need them, copy the agent file into
  `.claude/agents/` or `~/.claude/agents/`.
  ```

  ```markdown
  When an agent is loaded **from a plugin** (which is how every plugin agent ships), Claude Code ignores its `hooks`,
  `mcpServers`, and `permissionMode` frontmatter. This is a documented security boundary, not a bug
  ```

- **Raised by:** structural-analyst (S-11), confirmed by the run's own sweep
- **Confidence:** Verified
- **Bears on:** D-5, D-8

### C-6: No step captures which tools the analyst had, and no output field could carry it

- **Claim:** The agent's output format has four sections (Sources, Research Results, Options, Recommendation), none with
  a field for how discovery happened. Step 5's brief list does not ask for it. Step 6 builds five-field `A#` rows. Step
  7 hands the validator the registry, the mapping, Results, Options, and Recommendation. Step 8 renders only the
  template's fixed fields. The fact "search was unavailable" is never captured at its origin, so it has nowhere to be
  dropped later.
- **Location:** `han-research/agents/research-analyst.md:85-118`; `han-research/skills/research/SKILL.md:198-213`,
  `:217-236`, `:284-286`, `:293-310`; `han-research/skills/research/references/research-report-template.md:16-29`,
  `:103-125`
- **Evidence:**

  ```markdown
  Return an indexed Sources registry first, then Research Results, then Options to Consider (when applicable), then a
  Recommendation.
  ```

  ```markdown
  Then launch `han-core:adversarial-validator` with one `Agent` call. Pass it the full verbatim Sources registry, the
  old-to-new mapping from Step 6, the Research Results, the Options, and the Recommendation.
  ```

  Template Summary section:

  ```markdown
  - **Confidence:** High / Medium / Low
  ```

- **Raised by:** behavioral-analyst (B-1, B-3), structural-analyst (S-6)
- **Confidence:** Verified
- **Bears on:** S-2, S-3, S-4, D-4

### C-7: Every existing "say what did not happen" rule is keyed to evidence, not to a missing tool

- **Claim:** Four rules sound adjacent and none fires when search is absent. "Report what you searched for and did not
  find" covers an empty query, not an unissued one. The `Unverified:` rule covers a finding's input, not a run's
  capability. "Negative results are valuable" covers an unanswerable question, not a degraded method. Evidence-rule
  Principle 3 covers a claim with no evidence, and a fetch-only run's claims still carry web evidence.
- **Location:** `han-research/agents/research-analyst.md:135`, `:138-142`; `han-research/skills/research/SKILL.md:61-64`;
  `han-research/references/evidence-rule.md:62-70`
- **Evidence:**

  ```markdown
  - Report what you searched for and did not find. Negative results are evidence.
  ```

  ```markdown
  - **Put a blind-spot disclosure on the finding itself, not only in an assumptions or limitations section.** When a
    finding rests on an input you could not inspect, append one line to that finding, as its last line, in this form:
    `Unverified: could not inspect {the input}, because {the reason}.`
  ```

  ```markdown
  - **Negative results are valuable.** When a question cannot be answered with available sources, the report says so and
    names what input would make it answerable.
  ```

  ```markdown
  When a claim has no evidence at any tier, label it. Defer the dependent decision. Name the concrete trigger that would
  justify revisiting.
  ```

- **Raised by:** behavioral-analyst (B-2), structural-analyst (S-7)
- **Confidence:** Verified
- **Bears on:** D-4

### C-8: The validator is chartered to catch convenient sources, not a narrow search

- **Claim:** Step 7 asks the validator whether sources are "stale, adversarially constructed, or implausibly
  convenient". Its own Strategy 4 mirrors that. Nothing asks whether the set of sources is only what the prompt already
  named, and the validator is not told what tools the analyst had.
- **Location:** `han-research/skills/research/SKILL.md:284-291`; `han-core/agents/adversarial-validator.md:67-79`
- **Evidence:**

  ```markdown
  — whether any artifact could have been introduced or shaped by external content designed to influence the output,
  whether discounting any single external artifact changes the recommendation, and whether external sources are stale,
  adversarially constructed, or implausibly convenient.
  ```

  ```markdown
  - Probe source provenance and recency: is a source stale, astroturfed, an interested party, or implausibly convenient
    for the conclusion
  ```

- **Raised by:** behavioral-analyst (B-4)
- **Confidence:** Verified
- **Bears on:** S-5, D-6

### C-9: Neither the evidence mode nor the Confidence rating has an input from "search was unavailable"

- **Claim:** Evidence mode has one trigger (the user's opt-out phrase). Confidence is a bare High/Medium/Low. The
  closest slot is "Remaining Risks: ... uncovered scope", which nothing requires to name a missing tool. A fetch-only
  run can render `Confidence: High` with no rule broken.
- **Location:** `han-research/skills/research/SKILL.md:102-105`;
  `han-research/skills/research/references/research-report-template.md:28`, `:97-101`
- **Evidence:**

  ```markdown
  **Detect the evidence mode.** The default is strict: evidence is required. If the user's request explicitly opts out —
  a phrase such as "evidence optional", "allow unsourced", or "exploratory" — bind the mode to exploratory
  ```

  ```markdown
  - **Confidence:** High / Medium / Low
  - **Remaining Risks:** {single sources relied on, staleness, uncovered scope, and — exploratory mode — how much the
    recommendation leans on reasoning}
  ```

- **Raised by:** behavioral-analyst (B-5)
- **Confidence:** Verified
- **Bears on:** S-6, D-6

### C-10: The repo already has a codified idiom for a missing tool, and the research skill uses it for git

- **Claim:** The agent-building guidance names the exact failure (silent incomplete output) and prescribes "check
  availability inline, skip the step, note the limitation". The research skill applies it to git with a probe line, a
  note, and an announcement. `structural-analyst`, `risk-analyst`, and `gap-analyzer` apply it to git; `gap-analyzer`
  applies it to a `WebFetch` failure. No file applies it to `WebSearch`.
- **Location:** `han-plugin-builder/skills/guidance/references/agent-building-guidelines/graceful-degradation.md:16-26`;
  `han-research/skills/research/SKILL.md:23`, `:100`, `:189`; `han-core/agents/structural-analyst.md:72-73`, `:122`;
  `han-core/agents/gap-analyzer.md:285-291`
- **Evidence:**

  ```markdown
  Without this rule, an agent always attempts tool-dependent steps, receives empty or error output, and either fails or
  silently produces incomplete analysis. With no indication to the calling skill or user about what was omitted.

  For any step that depends on a tool (git, a CLI, an external API), check availability inline before attempting the
  step. If the tool is not available, skip the step and note the limitation explicitly in the agent's output.
  ```

  ```markdown
  - git installed: !`which git 2>/dev/null || echo "not installed"`
  ```

  ```markdown
  State git availability if a codebase angle is on the roster and git is absent.
  ```

  ```markdown
  - If WebFetch fails for a URL input, note the limitation and suggest the user provide the content as a local file. Do
    not treat a WebFetch failure as a fatal error — analyze whatever inputs are available and note which inputs could not
    be acquired.
  ```

- **Raised by:** behavioral-analyst (B-6), structural-analyst (S-8, S-9)
- **Confidence:** Verified
- **Bears on:** S-1, D-3

### C-11: How an agent notices a missing tool: the attempt is the detection, and the tool is filtered before launch

- **Claim:** A subagent has no tool-listing tool. The docs say tools outside the set are removed before the agent runs,
  so an unoffered `WebSearch` is absent from the model's tool list rather than present and failing. The repo's one
  documented precedent, for the `Agent` tool in code-review, says not to probe and to treat a failed call as the
  detection. A skill running in the main session can probe with `ToolSearch`; the issue reports that on Bedrock
  `ToolSearch` for `WebSearch` returns "No matching deferred tools found".
- **Location:** `han-coding/skills/code-review/references/agent-dispatch.md:221-230`;
  `https://code.claude.com/docs/en/sub-agents.md:418`; issue #212 "Why it matters"
- **Evidence:**

  ```markdown
  **Detection is by the dispatch mechanism failing at Step 3.5.** Exactly two triggers:

  1. The `Agent` tool is unavailable to the run (not in the session's allowed tools, or absent from the tool list).
  2. A dispatch call is made and denied (a permission refusal, or a tool error saying the call could not be placed).
  ...
  Do not probe for availability before dispatching; the attempt is the detection.
  ```

- **Raised by:** behavioral-analyst (B-6), the run's own sweep
- **Confidence:** Unverified: could not inspect what the model sees inside a Bedrock-backed subagent, because no
  transcript exists in the repo and this run is not on Bedrock. The docs' filtering statement and the issue's
  `ToolSearch` observation are the two sources.
- **Bears on:** S-1, D-3, D-10

### C-12: Five doc surfaces promise open-web reach without distinguishing search from fetch

- **Claim:** The plugin README, both long-form docs, and the two repo-root indexes describe the skill and agent as
  reaching the open web. None says what happens where search is absent. The `plugin.json` descriptions do not mention
  the web.
- **Location:** `han-research/README.md:16,25`; `han-research/docs/skills/research.md:30-32`;
  `han-research/docs/agents/research-analyst.md:12,100`; `docs/skills/README.md:96`; `docs/agents/README.md:81`
- **Evidence:**

  ```markdown
  - **Reaches the open web.** Unlike `/investigate`, `/research` can search and fetch from the open web, read your
    codebase, and use material you provide. That web reach is the whole point
  ```

  ```markdown
  Web search and fetch make it slower than a pure codebase agent.
  ```

- **Raised by:** structural-analyst (S-2, S-10)
- **Confidence:** Verified
- **Bears on:** S-7, D-8

### C-13: Two opt-in plugins already name MCP tools in `allowed-tools:` and handle their absence in prose

- **Claim:** `han-linear` and `han-atlassian` list `mcp__plugin_linear_linear__*` and `mcp__claude_ai_Atlassian__*`
  tools by exact name and tell the run what to do when the tool is unavailable. Both are skills, not agents, and both
  name one known server. No Han file names an MCP tool the user chose.
- **Location:** `han-linear/skills/work-items-to-linear/SKILL.md:15-18`, `:72`;
  `han-atlassian/skills/work-items-to-jira/SKILL.md:13-16`, `:73`
- **Evidence:**

  ```markdown
  `mcp__plugin_linear_linear__list_teams`. If the tool is unavailable, the call errors, or no workspace is accessible,
  ```

- **Raised by:** the run's own sweep
- **Confidence:** Verified
- **Bears on:** D-5

### C-14: The config rule carries an Extra Agents seam and no tool seam

- **Claim:** `.han/config.md` lets a user add agents to a skill's candidate pool. It has no setting that names a tool,
  and a skill cannot pass a tool list into a plugin agent's frontmatter at dispatch time.
- **Location:** `han-research/references/config-rule.md:73-74`, `:112-117`
- **Evidence:**

  ```markdown
  - `## Extra Agents` (section heading): one agent per list line, in qualified `plugin:agent` form or bare-name form.
    Match names case-insensitively against the agents available in the session.
  ```

- **Raised by:** the run's own sweep
- **Confidence:** Verified
- **Bears on:** D-5, D-8

## Findings No Agent Could Audit

- **The model's view inside a Bedrock- or Vertex-backed subagent.** Nobody in this run could launch one. C-11 rests on
  the docs' filtering statement and the issue's report. Closing it takes one run of `/research` on a Bedrock install
  with the change applied.
- **Whether Vertex or Foundry lack `WebSearch`.** The docs are silent; the issue asserts Vertex. Closing it takes a
  Vertex session or a docs update.
