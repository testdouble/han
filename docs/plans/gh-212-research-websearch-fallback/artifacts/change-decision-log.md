# Change Decision Log: Research without WebSearch (issue #212)

<!--
This file records every decision committed while planning the response to issue #212.
The plan itself lives in [../change-plan.md](../change-plan.md). This file captures the
question, rationale, evidence, and rejected alternatives behind each decision.
Evidence about the code as it stands today lives in
[current-state-findings.md](current-state-findings.md) as numbered C-N findings.
-->

## Trivial decisions

- D-1: Reason class and area — The reason is a constraint arriving (a hosting platform with no `WebSearch`), filed as
  issue #212; the area is the research agent, the research skill, its report template, and the two long-form docs, as
  the operator confirmed. — Referenced in plan: Why This Change, Current State.
- D-2: Output folder — `docs/plans/gh-212-research-websearch-fallback/`, following the `gh-201-…` precedent; the operator
  accepted it. — Referenced in plan: none (run bookkeeping).
- D-13: Closing chat message — On a run whose value is anything but `used`, the closing message opens with the report's
  own `**Web search:**` line, verbatim, before the existing list; on a `used` run the chat says nothing about it and the
  report carries it. From review finding UX-005 (the fact was sixth in a nine-item list, and a `used` mention carried no
  information). — Referenced in plan: Surface Delta (S-3).
- D-14: Summary "how solid it is" example — The template comment that asks the Summary prose to close with a phrase on
  how solid the answer is gains one example for a no-search run: "well-corroborated among the pages the question named;
  no web search ran". From review finding UX-004 (the prose and the rating could contradict the line beneath them). —
  Referenced in plan: Surface Delta (S-6).

## Full decisions

### D-3: The analyst detects the missing search tool itself

- **Question:** Who notices that `WebSearch` is not available on this run, and how?
- **Decision:** The research-analyst agent. Its "Gather from the Open Web" protocol opens with a conditional: when
  `WebSearch` is not among the tools offered to it, or a call to it is refused, it gathers with `WebFetch` alone and
  opens its return with the not-available line (D-4). It does not stop and does not probe further. Its fetch-only
  source set is what it is today: the URLs the brief names, pages linked from them, and pages it already knows. Otherwise
  the protocol runs as today.
- **Rationale:** The analyst is the only party that holds the fact. Claude Code removes an unmatched `tools:` entry
  before the agent launches, so the tool is absent from the model's own list rather than present and failing
  ([C-3](current-state-findings.md#c-3-official-docs-tools-is-an-allowlist-an-unmatched-entry-is-dropped-silently-and-mcp-wildcards-are-accepted),
  [C-11](current-state-findings.md#c-11-how-an-agent-notices-a-missing-tool-the-attempt-is-the-detection-and-the-tool-is-filtered-before-launch)).
  The repo's own guidance for a missing tool is "check inline, skip the step, note the limitation in the agent's
  output"
  ([C-10](current-state-findings.md#c-10-the-repo-already-has-a-codified-idiom-for-a-missing-tool-and-the-research-skill-uses-it-for-git)),
  and the one precedent for a missing harness tool says the attempt is the detection
  ([C-11](current-state-findings.md#c-11-how-an-agent-notices-a-missing-tool-the-attempt-is-the-detection-and-the-tool-is-filtered-before-launch)).
  The second trigger, a refused call, is real on an install that has the tool when a person declines its permission
  prompt (review finding JD Q8); D-10 settles what the analyst does then. The source set is left as it is because
  narrowing it to brief-named URLs would be a behavior change on no-search installs that nothing asked for (review
  finding JD-005).
- **Evidence:** C-1, C-3, C-10, C-11; `graceful-degradation.md:16-26`; `agent-dispatch.md:221-230`; software-architect
  recommendation A1; review findings JD Q8, JD-005.
- **Behavior impact:** Preserving on an install without the tool: the issue's own observation is that today "the agent
  runs, never calls `WebSearch`, and reports as though the sourcing standard was met" (`scope-boundary.md`, Environment),
  and the mechanism behind that is the one unverified input (C-11). Changing for the refused-call trigger, settled by
  D-10.
- **Rejected alternatives:**
  - A skill-side shell probe (a `!`command`` line like the git probe at `SKILL.md:23`) — rejected because a shell
    command cannot see the harness tool registry; the git probe works because git is a CLI (C-10, C-11).
  - A skill-side `ToolSearch` call in Step 1 — rejected because it reports the main session's view and a subagent's
    resolved tool set can differ from the session's (C-3); because whether `WebSearch` is registered as a deferred tool
    on an Anthropic-backed install is not established, so "no matching deferred tools" could be a false negative; and
    because it adds a tool grant and a step for a fact the analyst already has.
  - Probing `CLAUDE_CODE_USE_BEDROCK` — rejected as proxy detection: it detects a platform, not the tool, and the docs
    confirm the limitation for Bedrock only (C-4).
  - Editing the `tools:` line — rejected because it is not a detection mechanism: an unmatched entry is dropped silently
    under every value (C-3). See D-5.
  - Restricting the fetch-only source set to brief-named URLs and pages linked from them — rejected because today's
    protocol has no such restriction and the not-available literal would then over-claim (JD-005).
- **Revisit criterion:** A documented case where the analyst fails to notice the absence but the main session can.
- **Dissent (if any):** None.
- **Settles delta entry:** S-1
- **Dependent decisions:** D-4, D-6, D-10
- **Referenced in plan:** Target State, Surface Delta (S-1), Change Units (Unit 1)

### D-4: The Web search line, pinned end to end and always present

- **Question:** How does the fact "this run had no web search" travel from the analyst to the reader, and does it appear
  on every report or only on no-search ones?
- **Decision:** One labeled line with a fixed grammar, written by the analyst as the first line of its return and copied
  verbatim by the skill as the second bullet of the report's `## Summary`, under Confidence. It is always present.

  Grammar: `**Web search:** <value>`, where `<value>` is exactly one of three literals.

  Written by the analyst, one of two:

  ```markdown
  **Web search:** used
  ```

  ```markdown
  **Web search:** not available. No source was found by searching; anything the question did not name was not looked for.
  ```

  Written by the skill only when an analyst's return carries no line:

  ```markdown
  **Web search:** not reported. The run did not say whether web search was available; read the report as if it was not.
  ```

  Carriage rule the skill applies at Step 6, in order of precedence: if any analyst returned the not-available form,
  carry it; else if any analyst's return has no line, carry `not reported`; else carry `used`. Step 8 renders the carried
  value as `- **Web search:** …` directly under `- **Confidence:** …` in `## Summary`, with no rewording, and D-11
  protects it from the readability pass that follows.

  The operator's answer to the escalation on shape, verbatim: "go with recommended". The label and the value strings
  were changed after that answer on review finding UX-002; the shape the operator chose (always present, fixed values
  written by the analyst) is unchanged.

- **Rationale:** The fact is never captured today because no output field, brief item, or template field can hold it
  ([C-6](current-state-findings.md#c-6-no-step-captures-which-tools-the-analyst-had-and-no-output-field-could-carry-it)),
  and every adjacent "say what did not happen" rule is keyed to evidence, not to a missing tool
  ([C-7](current-state-findings.md#c-7-every-existing-say-what-did-not-happen-rule-is-keyed-to-evidence-not-to-a-missing-tool)).
  Fixed literals let the skill copy rather than interpret, and make the merge across parallel analysts a one-clause
  rule. Always-present makes a missing line a visible defect rather than a run that might or might not have searched.
  The Summary is the one section a non-technical reader is told they need (`research-report-template.md:16-27`), and its
  own comment forbids jargon, so the label is the reader's word ("Web search") rather than the skill's ("Discovery"),
  the `used` value is a plain state, and the two longer values each carry the consequence for the reader in their
  second sentence (UX-002, UX-003). The not-available sentence claims only what is true whatever the analyst fetched: no
  source came from a search, and nothing unnamed was looked for (JD-005). The ordered carriage rule closes the mixed
  case (one analyst with a line, one without) that the first draft left undefined (JD-002, UX-007).
- **Evidence:** C-6, C-7, C-9; contract-pinning rule (a literal worked example pins the form); software-architect
  recommendation A1; operator escalation answer; review findings UX-002, UX-003, JD-002, JD-005, UX-007.
- **Behavior impact:** Changing. Every report reader sees a new Summary line; anyone who dispatches the agent directly
  sees it as the first line of the return. Operator's answer: "go with recommended".
- **Rejected alternatives:**
  - A line present only on no-search runs — rejected because the skill then cannot tell "search ran" from "the analyst
    forgot to say", which is the silent case the issue is about (offered to the operator; not chosen).
  - The first-draft strings `**Discovery:** search and fetch` and `**Discovery:** fetch only. …` — rejected because
    "Discovery" reads as "what the research found" to the Summary's reader and "fetch" is a tool name, in the one
    section whose comment forbids jargon (UX-002).
  - A rule-only change with no fixed line ("note when search is absent") — rejected because Step 8 renders only the
    template's fixed fields, so a free-form note has nowhere to land (C-6).
  - Carrying the fact inside an existing `A#` field — rejected because the registry's five-field shape is shared with
    the evidence rule and the traceability invariant, and a per-source field cannot say something about the run.
  - Two literals only, with a missing line treated as an error — rejected because the skill has no defined error path
    for a malformed analyst return today, and inventing one is larger than one more literal.
- **Revisit criterion:** A third discovery method with a distinct observable (for example an MCP search server the
  plugin can reach) would add a literal; D-5 records why that is not the case today.
- **Dissent (if any):** None.
- **Settles delta entry:** S-2, S-3, S-4, S-6 (Summary)
- **Dependent decisions:** D-6, D-8, D-10, D-11, D-13
- **Referenced in plan:** Target State, Surface Delta (S-2, S-3, S-4, S-6), Behavior Changes, Change Units (Unit 1)

### D-5: The agent's `tools:` line stays as it is

- **Question:** Should `tools: Read, Glob, Grep, WebSearch, WebFetch` change so a user's MCP search server can reach
  the analyst, or so the entry stops being inert on Bedrock?
- **Decision:** No change. The line keeps `WebSearch` because it is the primary discovery tool wherever it exists and
  the operator confirmed it is not being deprecated or replaced (`scope-boundary.md`, Direction of Travel). On Bedrock
  the entry is dropped and the agent launches with four tools, which D-3 and D-4 now disclose.
- **Rationale:** Every shape that reaches a user's MCP server from a plugin agent either couples the plugin to a server
  name it cannot know or widens the analyst's interface to tools its protocols never use. The web-facing angle is the
  one place Han isolates from the repository because fetched content is treated as hostile (`SKILL.md:47-51`; the
  agent's Instruction-Following and Context Leakage anti-patterns), so widening it is the wrong direction.
- **Evidence:** C-3 (patterns accepted; unmatched entries dropped silently), C-4 (the docs name an MCP server as the
  substitute), C-5 (a plugin agent cannot carry its own server), C-13 (both Han precedents name one server whose name
  the plugin knows), C-14 (no tool seam in the config rule); software-architect recommendation A2.
- **Behavior impact:** Preserving. Nothing changes.
- **Rejected alternatives:**
  - Add `mcp__exa`, `mcp__brave`, `mcp__tavily`, `mcp__kagi` alongside `WebSearch` (issue direction 3) — rejected
    because a pattern matches only when the user named the server that way, a match grants every tool the server
    exposes rather than search alone, and there are zero known installs to satisfy the Rule of Three. Deferred (YAGNI)
    with a trigger in the plan.
  - Omit `tools:` so the agent inherits everything — rejected because it then inherits `Bash`, `Write`, `Edit`, and
    every MCP tool in the session (C-3), handing a hostile page a shell and the user's write tools. Pairing it with
    `disallowedTools: mcp__*` removes the search server too, and the plugin cannot enumerate a user's other servers.
  - A `.han/config.md` setting naming a search tool — rejected because a skill cannot pass a tool grant into a plugin
    agent's frontmatter at dispatch time (C-14), so the setting would bind to nothing. Deferred (YAGNI).
  - Remove `WebSearch` from `tools:` so the line is honest on Bedrock — rejected because it would remove the tool from
    every install that has it, against the recorded direction of travel.
- **Revisit criterion:** Claude Code lets a dispatching skill pass a tool grant to a plugin agent at dispatch time, or a
  search server with a vendor-fixed name is documented by Claude Code as a `WebSearch` substitute and three Han users
  report it configured under that name.
- **Dissent (if any):** None.
- **Settles delta entry:** — (a decision to leave an element unchanged)
- **Dependent decisions:** D-8
- **Referenced in plan:** Target State, Deferred (YAGNI), Cut for Scope

### D-6: The validator and the confidence rating take the Web search value as an input

- **Question:** Once the report says search was unavailable, does anything weigh what that cost?
- **Decision:** Two consumers, both triggered when the carried value is anything other than `used` (D-10 extended the
  trigger from the not-available form alone). Step 7 passes the carried value to the validator alongside the registry,
  mapping, Results, Options, and Recommendation, and adds one charter sentence. The template's Confidence Assessment
  gains one member in Remaining Risks. The validator's own definition in `han-core` is untouched.

  The Step 7 pass list, as it reads after the change:

  ```markdown
  Pass it the full verbatim Sources registry, the old-to-new mapping from Step 6, the Web search value held from Step
  6, the Research Results, the Options, and the Recommendation.
  ```

  The charter sentence, added verbatim to the Step 7 brief when the value is anything other than `used`:

  ```markdown
  Web search was not confirmed for this run, so also attack completeness: name any option or source the question did
  not mention that a web search would likely have surfaced, and say whether the recommendation survives its absence.
  ```

  The Remaining Risks member, added verbatim to the template's Confidence Assessment list:

  ```markdown
  on a run without web search: "Web search was not available, so sources and options beyond those the question named
  were not looked for. To close this, rerun where web search is available, or name the candidates you want compared."
  ```

  The operator's answer to the escalation, verbatim: "go with recommendation".

- **Rationale:** The issue's exact complaint is that a reader cannot tell a thorough survey from a fetch of the
  candidates the prompt named. The validator is the party chartered to attack the recommendation, and today nothing in
  its charter tests completeness and it is not told what tools the analyst had
  ([C-8](current-state-findings.md#c-8-the-validator-is-chartered-to-catch-convenient-sources-not-a-narrow-search)).
  Confidence has no input from a missing tool and a no-search run can render High
  ([C-9](current-state-findings.md#c-9-neither-the-evidence-mode-nor-the-confidence-rating-has-an-input-from-search-was-unavailable));
  Remaining Risks is already the slot for uncovered scope, so the gap becomes a required member rather than a new
  field. Step 8 re-evaluates the recommendation against `V#` findings only, so a completeness finding is the one
  route by which the gap can change the recommendation. The charter sentence and the risk member are pinned as exact
  text because the brief writer and the validator's Strategy 4 agree on them independently, and a prose paraphrase
  could be read as the existing "implausibly convenient" check (JD-006; risk-analyst, Contracts). The risk member
  names the two remedies the plan offers, so the reader can act on it (UX-003).
- **Evidence:** C-8, C-9; `adversarial-validator.md:67-79` (Strategy 4 takes a brief clause without a definition
  change); software-architect recommendation A3; operator escalation answer; review findings JD-003, JD-006, UX-003,
  risk-analyst Contracts.
- **Behavior impact:** Changing, on runs whose value is not `used`. The reader can see a validation finding about
  completeness that never appears today, and Remaining Risks names the gap. On a `used` run nothing changes.
  Operator's answer: "go with recommendation"; the extension to `not reported` runs is the operator's D-10 answer.
- **Rejected alternatives:**
  - Cap Confidence at Medium on a no-search run — rejected because a "how does X work" question that names its own
    source is legitimately answered High without search; a cap encodes a rule the evidence does not support.
  - Leave the validator alone and rely on the Summary line — offered to the operator; not chosen. C-8 shows nothing
    would then ever test completeness.
  - Edit `han-core/agents/adversarial-validator.md` to add a completeness strategy — rejected because `han-core` is
    outside the accepted area and Strategy 4 already takes brief-level direction.
  - Trigger on the not-available form only — rejected by D-10: a `not reported` run would then render like a normal
    one with a shrug at the top (JD-003).
- **Revisit criterion:** Three no-search reports whose completeness findings were all "nothing missing", which would
  say the sentence costs a validator pass and returns nothing.
- **Dissent (if any):** None.
- **Settles delta entry:** S-5, S-6 (Confidence Assessment)
- **Dependent decisions:** D-10
- **Referenced in plan:** Target State, Surface Delta (S-5, S-6), Behavior Changes, Change Units (Unit 1)

### D-7: The skill's `allowed-tools:` line stays as it is

- **Question:** The issue names `allowed-tools: … WebSearch …` in `SKILL.md` as an affected declaration. Does it change?
- **Decision:** No change.
- **Rationale:** A skill's `allowed-tools` pre-approves tools for the invoking turn and does not restrict the tool set
  ([C-2](current-state-findings.md#c-2-the-skills-allowed-tools-pre-approves-websearch-it-does-not-gate-what-the-agent-can-reach)).
  The entry is inert where the tool is absent and costs nothing there. The skill itself never searches; the agent
  does, and the agent's `tools:` is the only gate on what it can call.
- **Evidence:** C-2; `skill-frontmatter-fields.md:31`; `allowed-tools-AskUserQuestion.md:30`.
- **Behavior impact:** Preserving.
- **Rejected alternatives:**
  - Remove `WebSearch` from `allowed-tools:` — rejected because it changes nothing on Bedrock and, on an install with
    the tool, would only add a permission prompt if the skill ever called it directly.
- **Revisit criterion:** The skill gains a step that calls `WebSearch` itself.
- **Dissent (if any):** None.
- **Settles delta entry:** —
- **Dependent decisions:** None.
- **Referenced in plan:** Target State

### D-8: The docs say what happens without search, and say plainly that the shipped agent cannot be given another search tool

- **Question:** Which doc sentences change, and what does the plan say to issue direction 2 (a supported extension point
  for an MCP search tool without forking the agent)?
- **Decision:** One paragraph-level addition in each canonical long-form doc; the README scent lines and the two
  repo-root index lines stay unchanged. Direction 2 as asked is not possible on the platform and the agent doc says so:
  there is no way to give the shipped analyst a different search tool; a copy of the agent, with the server's tool added
  to its `tools:` list and its web protocol pointed at that tool, can be dispatched directly, and `/research` always
  dispatches the shipped analyst, so a copy does not replace it there and drifts from upstream on every release.
- **Rationale:** Five doc surfaces promise open-web reach and none says what happens where search is absent
  ([C-12](current-state-findings.md#c-12-five-doc-surfaces-promise-open-web-reach-without-distinguishing-search-from-fetch)).
  The long-form docs are canonical and the scent lines reuse their summary line (`CLAUDE.md`, Conventions), so the
  scent lines, which say "open web" and stay true, do not change. For direction 2: a plugin agent cannot carry its own
  MCP server (C-5), and the two ways to admit a user's server through `tools:` are rejected in D-5, so no extension
  point exists to document. The first draft added a recipe for reaching a copy through `## Extra Agents`
  (C-14); review finding JD-004 showed it would not work as written (the copied protocol keys on `WebSearch` by name,
  so the copy would gather fetch-only and say so) and that even a corrected copy runs beside the shipped analyst, whose
  not-available line then labels the whole report. The simpler, honest statement replaces it, and the recipe is
  deferred with a trigger.
- **Evidence:** C-5, C-12, C-14; `SKILL.md:157`; software-architect recommendation A4; review finding JD-004.
- **Behavior impact:** Preserving. Docs change no run's behavior.
- **Rejected alternatives:**
  - Document an extension point that adds a tool to the shipped agent — rejected because none exists (C-3, C-5, C-14).
  - The `## Extra Agents` recipe (copy, add `mcp__<server>`, list under Extra Agents) — rejected because as written the
    copy would not search, a corrected copy would still be labeled by the shipped analyst's line, and a verification
    run for a route with zero known users is not worth its cost (JD-004). Deferred (YAGNI).
  - Edit the README and index scent lines to mention Bedrock — rejected because the convention forbids a second copy
    of long-form content, and "open web" stays true.
  - Say nothing about copying — rejected because the issue asked for a supported route and the honest answer is that
    the only route is a copy, with its cost named.
- **Revisit criterion:** Claude Code documents a way to extend a plugin agent's tool list without copying it.
- **Dissent (if any):** None.
- **Settles delta entry:** S-7
- **Dependent decisions:** None.
- **Referenced in plan:** Surface Delta (S-7), Change Units (Unit 2), Deferred (YAGNI), Cut for Scope

### D-9: The fallback chain is deferred

- **Question:** Does the analyst get a prose instruction to use `WebFetch` against `api.github.com/search/repositories`,
  `registry.npmjs.org/<pkg>`, and `pypi.org/pypi/<pkg>/json` for discovery when search is unavailable?
- **Decision:** Deferred under YAGNI, with the reopening trigger in the plan's Deferred section.
- **Rationale:** The evidence is one user's report that these endpoints "recover a usable fraction", with nothing
  measuring the fraction; the only caller is the one analyst protocol; and the chain assumes research questions are
  about packages. The middle link (an MCP server) is unreachable from a plugin agent (C-5), so the chain is two links.
  D-4 is the instrument that makes the deferral measurable: once no-search reports say so, a user can record whether
  registry discovery would have changed the recommendation. That measurement depends on the literal surviving
  unchanged, which D-11 secures.
- **Evidence:** Issue #212 "Possible directions", last paragraph; C-5; yagni-rule Gate 1 (no measured workload, one
  caller); software-architect part F.
- **Behavior impact:** Preserving (nothing added).
- **Rejected alternatives:**
  - Add the chain now as a protocol step — rejected on the evidence gate above.
- **Revisit criterion:** A no-search report is followed by a user recording that registry-endpoint discovery would
  have changed the recommendation, or three no-search reports name a missing option that such an endpoint lists.
- **Dissent (if any):** None.
- **Settles delta entry:** —
- **Dependent decisions:** None.
- **Referenced in plan:** Deferred (YAGNI)

### D-10: An unconfirmed search is treated as no search

- **Question:** Two cases the first two escalations did not cover: a person on a search-capable install declines the
  `WebSearch` permission prompt mid-run, and an analyst fails to write the line at all. Does either get the no-search
  treatment?
- **Decision:** Both do. A refused call sends the analyst down the same branch as an absent tool: it continues by fetch
  and writes the not-available line. A `not reported` value triggers the validator's completeness sentence and the
  Remaining Risks member exactly as the not-available value does, and the `not reported` literal tells the reader to
  read the report as if search was not available. In one line: only the `used` value means search ran.

  The operator's answer, verbatim: "got with recommended".

- **Rationale:** Today a declined prompt has no defined outcome in the protocol, so the analyst does whatever it does
  and may label the run `used` (risk-analyst, Behavior-preserving claims; JD Q8). A `not reported` run that skipped the
  completeness check would render like a normal one with a shrug at the top, reproducing the issue's complaint on the
  one defect the line does catch (JD-003). Treating anything short of a confirmed search as no search is the
  error-prevention posture, and it keeps every downstream rule keyed to one condition.
- **Evidence:** Review findings JD-003, JD Q8, risk-analyst "S-1 partially overclaims Preserving"; C-8, C-9; operator
  escalation answer.
- **Behavior impact:** Changing. Observers: a person who declines the `WebSearch` prompt on a search-capable install
  sees the run continue and the report labeled not available; a reader of a `not reported` report sees a completeness
  finding and a risk note. Operator's answer: "got with recommended".
- **Rejected alternatives:**
  - Only a confirmed absence gets the treatment — offered to the operator; not chosen. It leaves the declined-prompt
    case undefined and lets a defective run read as a normal one.
  - Drop the refused-call trigger from S-1 — rejected because the trigger is real (a permission denial) and without it
    the analyst could write `used` on a run where search never ran.
- **Revisit criterion:** A documented case where a refused call is transient and a retry would have succeeded, making
  the not-available label wrong.
- **Dissent (if any):** None.
- **Settles delta entry:** S-1 (refused-call trigger), S-5 and S-6 (trigger condition)
- **Dependent decisions:** None.
- **Referenced in plan:** Surface Delta (S-1, S-5, S-6), Behavior Changes

### D-11: The Web search line is protected from the readability rewrite

- **Question:** Step 8 dispatches `han-communication:readability-editor` over the rendered report and then runs the
  readability self-check; both are told to leave code fences, diagram bodies, and `A#`/`V#` identifiers alone, and
  nothing else. Does the fixed literal survive them?
- **Decision:** Not without saying so. Step 8's editor dispatch and self-check paragraph each gain one clause naming
  the `**Web search:**` Summary bullet as a fixed literal copied from the analyst that survives byte for byte on the
  same terms as `A#`/`V#`. The template comment on the Summary says the same, so a future editor of the template sees
  it. The clause added to the editor dispatch, verbatim:

  ```markdown
  and the Summary's `**Web search:**` bullet, which is a fixed literal copied from the analyst and survives unchanged
  on the same terms as `A#`/`V#`
  ```

- **Rationale:** The editor's own definition protects fences, inline code, diagram bodies, rendered markup, and
  citation identifiers (`readability-editor.md:54-61`); a bold-labeled prose bullet is none of those, and the editor is
  chartered to shorten sentences and gloss coined terms, which is what the not-available sentence looks like. Three
  reviewers raised it independently (JD-001, UX-001, risk-analyst (b)). Without the clause, the contract D-4 pins is
  broken on every run by the skill's own next step, the D-9 reopening trigger stops being countable, and no lint or
  test would notice.
- **Evidence:** `SKILL.md:311-321`; `readability-editor.md:54-61`, `:188`; review findings JD-001, UX-001, risk-analyst
  (b).
- **Behavior impact:** Preserving. It keeps S-3's "no rewording" true; nothing new is observed.
- **Rejected alternatives:**
  - Render the line inside a code span so the editor's existing inline-code exemption covers it — rejected because the
    Summary is the plain-language section and a code span there reads as a symbol, against the template's own comment.
  - Rely on the editor's fact-preservation rule — rejected because the editor preserves facts, not wording, and the
    contract is the wording.
- **Revisit criterion:** The readability editor's definition gains a general "fixed literal" exemption the skill can
  cite instead.
- **Dissent (if any):** None.
- **Settles delta entry:** S-3, S-6 (template comment)
- **Dependent decisions:** None.
- **Referenced in plan:** Target State, Surface Delta (S-3, S-6), Risks

### D-12: The agent, skill, and template ship as one unit

- **Question:** The first draft sequenced the agent alone as Unit 1 and the skill plus template as Unit 2. Is that the
  lowest-risk order?
- **Decision:** No. They ship together as one unit. The docs stay a second unit.
- **Rationale:** The issue's complaint is about the skill-rendered report, so the agent alone satisfies the floor only
  for a caller who dispatches it directly. The two share one pinned contract (D-4) across two files, and splitting them
  across two review cycles risks the drift the first draft's own Risk 2 named (every report rendering `not reported`)
  while buying nothing: both are markdown edits with checks that run in sequence inside one change. The docs stay
  separate because they describe the result and have no contract with it.
- **Evidence:** Risk-analyst, Sequencing; D-4.
- **Behavior impact:** Preserving.
- **Rejected alternatives:**
  - Three units in the architect's order (agent; skill and template; docs) — rejected for the reasons above.
- **Revisit criterion:** None; a sequencing choice.
- **Dissent (if any):** None.
- **Settles delta entry:** —
- **Dependent decisions:** None.
- **Referenced in plan:** Change Units
