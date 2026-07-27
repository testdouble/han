# Research: Anthropic's New Context Engineering Guidelines and What They Mean for Han's Plugin-Building Guidance

This report answers an open-ended question: what did Anthropic publish as its new context engineering guidance for
Claude 5-generation models, and how should the skill-building and agent-building guidance in `han-plugin-builder` be
updated in response? Evidence mode: strict.

## Summary

Anthropic has published new context engineering guidance for its Claude 5-generation models, and most of it confirms
what Han's plugin-building guidance already teaches. The new guidance names six shifts: write instructions that state a
goal and trust the model's judgment instead of spelling out rigid rules, design tool interfaces so the parameters
explain themselves instead of relying on usage examples, load context progressively instead of up front, remove
instructions that repeat across surfaces, let the model save its own memory instead of maintaining memory files by
hand, and point the model at code, test suites, and rubrics instead of long prose descriptions. Anthropic reports it
cut its own coding assistant's system prompt by more than eighty percent with no measured loss.

Han's guidance already covers progressive disclosure, lean descriptions, context budgets, and single-role agents, so
no restructuring is needed. The recommended update is a small, targeted one: refresh the guidance file that describes
how each Claude model wants its instructions written, because it was last checked four days before the new
announcement and one of its claims now points the opposite direction from the new guidance, and fold the handful of
genuinely new rules into the existing files where each belongs. The finding rests on Anthropic's own announcement,
confirmed in its specifics by independent press coverage, and on a direct inventory of Han's guidance files; the
quantitative claims trace back to Anthropic's own internal measurements only. Overall: well-corroborated on the
direction, single-source on the numbers.

- **Confidence:** Medium-High

## Research Results

### The six shifts Anthropic announced for Claude 5-generation models

Anthropic's announcement (A1) names six changes to how context should be engineered for Claude 5-generation models,
each framed as a before-and-after against prior practice. The six shifts are corroborated by independent secondary
coverage (A11), though all coverage derives from the same original Anthropic disclosure:

1. **Prescriptive rules become judgment-based instructions.** The announcement's own example: the old rule "Never
   write multi-paragraph docstrings" becomes "Write code that reads like the surrounding code: match its comment
   density, naming, and idiom" (A1, quoted verbatim in A11).
2. **Tool usage examples become expressive tool interfaces.** Parameter names and enumerations should themselves hint
   at correct usage, replacing worked examples in tool descriptions (A1).
3. **Upfront context becomes progressive disclosure.** Verification and review guidance moves out of the system prompt
   into Skills the model loads selectively, and tools use deferred loading for non-essential functionality (A1).
4. **Duplicated instructions are removed.** An instruction that appears in both the system prompt and a tool
   description is kept in one place only (A1).
5. **Manual memory files become automatic memory.** The model saves its own memory instead of requiring hand-edited
   CLAUDE.md updates (A1). The specific prior mechanic replaced (a "#" hotkey) is stated only in A1 [single-source].
6. **Markdown specs become richer references.** Code, HTML artifacts, test suites, and rubrics are preferred over
   prose descriptions of desired behavior (A1).

The headline quantitative claim is that Anthropic removed over eighty percent of Claude Code's system prompt with no
measured loss on coding evaluations (A1, restated by A11). Secondary press adds a more specific figure, roughly 800
tokens down to about 164, and reports an incoming `claude doctor` / `/doctor` command for rightsizing CLAUDE.md files
and skills (A11). Because every outlet derives from the same Anthropic disclosure, these figures are convergent
secondary coverage of one source, not independent measurement [single-source].

### The established context-engineering corpus behind the new rules

The new announcement sits on top of a consistent body of Anthropic engineering guidance (A2 through A8) that predates
it. Its core claims, corroborated across several independent Anthropic artifacts:

- **Context is a finite, depleting resource.** Model performance degrades as tokens accumulate ("context rot"), so
  the goal is the smallest set of high-signal tokens that produces the desired outcome (A2, corroborated
  operationally by A3's high-signal tool responses, A6's automatic stale-tool-result clearing, and A8's CLAUDE.md
  pruning test "would removing this line cause a mistake?").
- **System prompts sit at the right altitude.** Specific enough to guide, flexible enough to avoid brittle
  if-else logic, organized with structural markup (A2). The framing is A2's own [single-source], but A1's docstring
  example is a concrete instance of the same shift.
- **Tools avoid overlap and pass a definitiveness test.** A human should be able to tell which tool applies; bloated
  tool sets are a named failure mode (A2, corroborated by A3's consolidation and naming rules and A5's
  prefer-specialized-tools heuristic).
- **Curated canonical examples beat exhaustive edge-case lists** (A2) [single-source].
- **Just-in-time retrieval beats pre-loading, with a hybrid recommended.** Lightweight identifiers loaded at runtime,
  critical data loaded up front (A2, corroborated by A7's three-level skill loading model and A8's split of
  frequently-needed material into CLAUDE.md and occasional material into skills).
- **Compaction and external memory handle long horizons.** Summarize and reinitiate, clear stale tool results first,
  and keep structured notes outside the context window (A2, corroborated by A6's shipped context-editing and memory
  tool features). A6's percentage improvements are Anthropic's internal benchmarks [single-source].
- **Subagents get clean contexts and return condensed summaries.** A lead agent decomposes work; each subagent needs
  an explicit objective, output format, tool guidance, and boundaries, or agents duplicate work (A2, A5, corroborated
  at the product level by A8). A5's figures, including that multi-agent systems use roughly fifteen times the tokens
  for a 90.2 percent quality gain on complex research, are internal single-study numbers [single-source].
- **Skills are the unit of progressive disclosure.** Name and description are the trigger signal; the SKILL.md body
  loads on trigger; supplementary files load only when a sub-scenario needs them; scripts handle deterministic
  operations (A7, corroborated by A8).

Anthropic's harness post (A9) adds three named failure modes for long-running agent work: agentic laziness, declaring
a multi-part job done early; self-preferential bias, favoring one's own output when judging it; and goal drift, losing
the objective across many turns. It also names workflow patterns including adversarial verification, tournament, and
loop-until-done, and advises reserving heavy multi-agent machinery for high-value tasks [single-source]. A companion
post on working with Claude Fable (A10) recommends practices such as a deliberate blind-spot pass, prototypes over
detailed specs for subjective work, and treating source code as the best reference [single-source].

### What Han's guidance corpus already covers

The `han-plugin-builder` guidance corpus (48 files, inventoried at A13) already encodes most of the established
corpus, often with more operational specificity than Anthropic's own posts:

- Three-level progressive disclosure with a 500-line SKILL.md ceiling (A16, matching A7).
- Context-rot rationale, attention competition, lost-in-the-middle position effects, and a 15 to 40 percent
  utilization peak (A15, matching and extending A2).
- Description budgets: a 1024-character target, the Claude Code 1536-character per-entry cap, and the roughly one
  percent listing budget (A16).
- Single-role agents that generate or evaluate, never both (A17), which matches A9's self-preferential-bias failure
  mode from a different angle.
- Multi-agent economics with a 45 percent saturation threshold sourced to a 2025 Google, DeepMind, and MIT study
  (A17), consistent with A5's reserve-for-high-value-tasks advice.
- Scripts for deterministic operations, dispatch namespacing, and just-in-time guidance reading (A13, A18, matching
  A7).

### Where the new guidance and Han's docs diverge

Five deltas surfaced, one of them a direct tension:

1. **A dated per-model claim now points the wrong way.** `per-model-authoring.md` (A14) was last checked against
   Anthropic's published guidance on 2026-07-20, four days before the new announcement. It states that Opus 4.8 and
   Sonnet 5 "follow instructions literally and do not generalize on their own, so they want each behavior spelled out"
   while Fable 5 wants short, goal-based instructions. A1's shift to judgment-based instructions is framed for the
   whole Claude 5 generation, which includes Sonnet 5. This is a codebase-versus-web conflict to resolve by
   re-verification against Anthropic's current per-model guidance, not by silently adopting either side.
2. **No explicit de-duplication rule.** The corpus separates description from body content but has no rule stating
   that an instruction must not repeat across surfaces (skill body, agent definition, vendored references), which A1
   names as its own shift.
3. **Code-based references are only partially covered.** The corpus prescribes scripts for deterministic operations,
   but A1's broader preference for test suites, rubrics, and code artifacts over prose specifications has no
   counterpart in the guidance.
4. **Automatic memory and the rightsizing tool are unrepresented.** Neither automatic memory-saving (A1) nor the
   `/doctor` command (A11) [single-source] appears in the guidance. The `/doctor` claim rests on secondary press only
   and is not yet doc-worthy as fact.
5. **Two of three named failure modes are unrepresented.** Self-preferential bias is already encoded as the
   single-role rule; agentic laziness and goal drift (A9) [single-source] are not named anywhere in the corpus.

### Evidence-gathering integrity note

One fetched page (A8) contained directive-style text ahead of its article body instructing the fetcher to retrieve a
documentation index file. Per this skill's rules, that text was recorded as a claim and not acted on, and the
web-facing agents ran with no repository or user context to surrender.

## Options to Consider

### O1: Targeted delta update to the existing guidance files

- **What it is:** Refresh `per-model-authoring.md` against the new announcement, re-verifying the Sonnet 5
  literal-instructions claim; fold each confirmed new rule into the existing decision-scoped file where it belongs
  (judgment-based altitude into the instruction-writing guidance, an explicit de-duplication rule, code-based
  references guidance); cite A1 with its retrieval date; carry single-source items as caveated notes.
- **Trade-offs:** Smallest change and preserves the corpus's decision-scoped structure, but touches several files and
  requires judgment about where each rule lands.
- **Rests on:** (A1, A11) for the shifts; (A13, A14, A15, A16, A17) for what the corpus holds today.
- **Evidence status:** corroborated

### O2: One new dedicated context-engineering reference doc

- **What it is:** Add a single new reference file carrying the Claude 5 shifts, cross-linked from the existing files.
- **Trade-offs:** One clean edit, but the corpus routes authors to guidance by decision point, and a topic-shaped file
  would either duplicate content the decision-scoped files already carry or leave authors two places to look. That
  duplication is exactly what A1's fourth shift warns against, and it breaks the repo's one-canonical-source
  convention.
- **Rests on:** (A1), (A13).
- **Evidence status:** corroborated

### O3: Full corpus restructure around the new framing

- **What it is:** Reorganize the guidance corpus around "thin prompts, thick artifacts" as its central organizing
  idea.
- **Trade-offs:** The cost far exceeds the evidence. Most of the new guidance's substance is already present in the
  corpus, and the strongest justification for radical change, the eighty percent prompt cut, is an uncorroborated
  self-reported figure [single-source].
- **Rests on:** (A1, A11).
- **Evidence status:** single-source (caveated) for the claims that would justify the scale of change

### O4: No change; wait for official documentation

- **What it is:** Treat the blog post as directional and wait for Anthropic's official docs to confirm before editing
  anything.
- **Trade-offs:** Zero effort now, but it knowingly leaves a dated per-model file whose Sonnet 5 claim is in tension
  with corroborated new guidance, and the corpus's own convention is to date-stamp and refresh model-behavior claims.
- **Rests on:** (A14) for the staleness it would leave in place.
- **Evidence status:** corroborated (the staleness is verifiable; the case for waiting is the weakness)

## Recommendation

- **Recommendation:** O1, the targeted delta update. Start with `per-model-authoring.md`: re-verify its Sonnet 5 and
  Opus claims against Anthropic's current published guidance and update its last-checked date, since a guidance file
  that points authors the opposite direction from current upstream guidance is the one live defect found. Then add
  the three genuinely new rules to the files that own those decisions: an explicit de-duplication rule, the
  preference for code-based references (test suites, rubrics) over prose specifications, and the judgment-over-rules
  instruction altitude for Claude 5-generation models. Carry the single-source items (the eighty percent figure, the
  `/doctor` command, the named failure modes, the Fable working-style tips) as caveated, dated notes rather than
  asserted facts.
- **Evidence basis:** The six shifts rest on corroborated evidence (A1 confirmed in its specifics by A11, and
  consistent with the independent established corpus A2 through A8). The claim that Han's corpus already encodes the
  established guidance rests on codebase evidence (A13 through A18) cross-checked against the web sources. The
  per-model tension rests on dated codebase evidence (A14) against the corroborated A1 shift. The quantitative
  figures, the `/doctor` command, and the A9 and A10 material are single-source and are recommended only as caveated
  notes, never as the basis of a guidance rule.

## Validation

_Pending: adversarial validation findings will be recorded here._

## Sources

| ID  | Source                                              | Link / location                                                                              | Retrieved  | Trust class | Summary (one line)                                                                       | Evidence status                              |
| --- | --------------------------------------------------- | -------------------------------------------------------------------------------------------- | ---------- | ----------- | ---------------------------------------------------------------------------------------- | -------------------------------------------- |
| A1  | The New Rules of Context Engineering for Claude 5   | <https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models> | 2026-07-27 | web         | Six shifts for Claude 5-generation models; 80% system-prompt cut claim                    | corroborated by A11 (derivative)             |
| A2  | Effective Context Engineering for AI Agents         | <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>           | 2026-07-27 | web         | Context rot; right altitude; JIT retrieval; compaction; note-taking; subagent summaries   | corroborated by A3, A5, A6, A7, A8           |
| A3  | Writing Tools for AI Agents                         | <https://www.anthropic.com/engineering/writing-tools-for-agents>                              | 2026-07-27 | web         | Tool namespacing, consolidation, unambiguous params, actionable errors                    | corroborated by A2, A4, A5                   |
| A4  | Building Effective AI Agents                        | <https://www.anthropic.com/research/building-effective-agents>                                | 2026-07-27 | web         | Workflows vs agents; five composable patterns; start simple; invest in tool design        | corroborated by A3, A5                       |
| A5  | How We Built Our Multi-Agent Research System        | <https://www.anthropic.com/engineering/multi-agent-research-system>                           | 2026-07-27 | web         | Orchestrator/subagent briefs, effort scaling, parallelism; internal 15x/90.2% figures     | corroborated by A2, A8; figures single-source |
| A6  | Context Management on the Claude Developer Platform | <https://claude.com/blog/context-management>                                                  | 2026-07-27 | web         | Shipped context editing and memory tool; internal percentage gains                        | corroborated by A2; figures single-source    |
| A7  | Equipping Agents for the Real World with Skills     | <https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills> | 2026-07-27 | web         | SKILL.md contract; three-level progressive disclosure; scripts for determinism            | corroborated by A2, A8                       |
| A8  | Claude Code Best Practices                          | <https://code.claude.com/docs/en/best-practices>                                              | 2026-07-27 | web         | Minimal CLAUDE.md; skills for occasional context; subagents for investigation and review  | corroborated by A2, A7; contained directive text (recorded, not followed) |
| A9  | Dynamic Workflows in Claude Code                    | <https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code>           | 2026-07-27 | web         | Failure modes (agentic laziness, self-preferential bias, goal drift); workflow patterns   | single source (caveated)                     |
| A10 | A Field Guide to Claude Fable                       | <https://claude.com/blog/a-field-guide-to-claude-fable-finding-your-unknowns>                 | 2026-07-27 | web         | Fable-specific working practices: blind-spot pass, prototypes, source as reference        | single source (caveated)                     |
| A11 | Secondary press coverage of A1                      | <https://aiweekly.co/alerts/anthropic-deletes-80-of-claude-codes-system-prompt-for-claude-5> and others | 2026-07-27 | web | Restates the six shifts, ~800-to-~164-token figure, incoming `claude doctor` command | corroborates A1; derivative of the same disclosure |
| A12 | Prompt Engineering Overview (platform docs)         | <https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/overview>      | 2026-07-27 | web         | Thin routing page; no substantive claims                                                  | single source (thin)                         |
| A13 | Han guidance corpus inventory                       | `han-plugin-builder/skills/guidance/` (48 files)                                              | n/a        | codebase    | Full inventory of skill-building and agent-building guidance                              | codebase anchor                              |
| A14 | Per-model authoring guidance                        | `han-plugin-builder/skills/guidance/references/per-model-authoring.md`                        | n/a        | codebase    | Last checked 2026-07-20; Sonnet 5/Opus 4.8 literal vs Fable 5 goal-based instructions     | in tension with A1                           |
| A15 | Context hygiene guidance                            | `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-hygiene.md`    | n/a        | codebase    | Attention competition, lost-in-the-middle, 15-40% utilization, compaction budget          | consistent with A2                           |
| A16 | Progressive disclosure and description budgets      | `han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md` and `skill-description-length.md` | n/a | codebase | Three loading levels, 500-line body ceiling, 1024/1536-char description budgets | consistent with A7                           |
| A17 | Agent guidance (domain focus, economics)            | `han-plugin-builder/skills/guidance/references/agent-building-guidelines/`                    | n/a        | codebase    | Single-role rule, 50-token role identity, 45% multi-agent threshold                       | consistent with A5, A9                       |
| A18 | Builder skills (interview and review checklists)    | `han-plugin-builder/skills/skill-builder/SKILL.md` and `agent-builder/SKILL.md`               | n/a        | codebase    | Evidence-first interviews; conformance review checklists mapping to guidance files        | codebase anchor                              |

### A1: The New Rules of Context Engineering for Claude 5 Generation Models — recommendation-bearing

- **Link / location:** <https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models>
- **Retrieved:** 2026-07-27
- **Trust class:** web
- **Summary:** Anthropic's announcement of six shifts in context engineering for Claude 5-generation models: judgment-based
  instructions over prescriptive rules, expressive tool interfaces over usage examples, progressive disclosure over
  upfront context, de-duplicated instructions, automatic memory over manual CLAUDE.md edits, and code-based references
  over markdown specs. Reports an over-eighty-percent cut to Claude Code's system prompt with no measured evaluation
  loss, and recommends keeping CLAUDE.md to repository gotchas while moving situational guidance into Skills.
- **Evidence status:** corroborated by A11 on content; the quantitative figures trace to this single Anthropic disclosure

### A11: Secondary press coverage — recommendation-bearing

- **Link / location:** <https://aiweekly.co/alerts/anthropic-deletes-80-of-claude-codes-system-prompt-for-claude-5> (dated
  2026-07-24), plus <https://www.kucoin.com/news/flash/anthropic-cuts-claude-code-s-system-prompt-by-80-without-performance-loss>
  and forum and blog coverage
- **Retrieved:** 2026-07-27
- **Trust class:** web
- **Summary:** Independent outlets restating the six shifts, the docstring example verbatim, the roughly 800-to-164-token
  figure, and an incoming `claude doctor` command for rightsizing CLAUDE.md files and skills. All derive from the same
  Anthropic disclosure, so they confirm the announcement's content without independently verifying its measurements.
- **Evidence status:** corroborates A1; derivative, not independent measurement

### A14: per-model-authoring.md — recommendation-bearing

- **Link / location:** `han-plugin-builder/skills/guidance/references/per-model-authoring.md`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** States it was last checked against Anthropic's published guidance on 2026-07-20 for Sonnet 5, Opus 4.8,
  and Fable 5. Claims Opus 4.8 and Sonnet 5 follow instructions literally and want each behavior spelled out, while
  Fable 5 wants short, goal-based instructions and degrades under exhaustive checklists. The new announcement frames
  judgment-based instructions as a property of the whole Claude 5 generation, putting this file's Sonnet 5 claim in
  tension with current upstream guidance.
- **Evidence status:** codebase anchor; in tension with A1, resolution requires re-verification
