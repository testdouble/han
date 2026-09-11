# Change Plan: Research without WebSearch (issue #212)

## Why This Change

On a Claude Code install backed by Amazon Bedrock, and per the reporter Google Vertex, the `WebSearch` tool does not
exist. The research-analyst agent declares it. The harness drops the unmatched entry silently, and the agent runs with
`WebFetch` alone: it can read a page the question already named but cannot find one. The report then reads as though a
full survey ran. This is a constraint arriving: a hosting platform the current structure cannot absorb, filed as
[issue #212](https://github.com/testdouble/han/issues/212)
([D-1](artifacts/change-decision-log.md#trivial-decisions)).

The operator confirmed the built-in search is not being deprecated or replaced; the change is about where the plugin is
installed.

## What Changes, In One Paragraph

The research surface becomes answerable for saying whether web search ran. The analyst notices when search is not
offered to it or a call is refused, gathers by fetch alone, and opens its return with one fixed line saying so. The
skill copies that line into the top of every report, protects it from its own readability rewrite, and hands it to the
validator. Whenever the line says anything but `used`, it also asks the validator whether the research is complete and
names the gap under Remaining Risks. The agent's tool list, the skill's tool list, and the report's source registry do
not change. The docs say what happens without search and say plainly that the shipped agent cannot be given a
different search tool.

## Current State

The agent lists `WebSearch` in `tools:` and its "Gather from the Open Web" protocol uses it unconditionally
([C-1](artifacts/current-state-findings.md#c-1-the-agent-declares-websearch-and-its-protocol-assumes-it-is-always-there)).
Claude Code treats `tools:` as an allowlist and drops an entry that matches nothing, with no error unless the whole
list resolves to nothing
([C-3](artifacts/current-state-findings.md#c-3-official-docs-tools-is-an-allowlist-an-unmatched-entry-is-dropped-silently-and-mcp-wildcards-are-accepted)).
The official docs confirm `WebSearch` is absent on Bedrock, say nothing about Vertex or Foundry, and name an MCP search
server as the only substitute
([C-4](artifacts/current-state-findings.md#c-4-official-docs-websearch-is-absent-on-bedrock-the-backend-is-not-configurable-and-mcp-is-the-named-substitute)).
A plugin agent cannot carry its own MCP server
([C-5](artifacts/current-state-findings.md#c-5-plugin-subagents-cannot-carry-their-own-mcp-servers)).

This change addresses a structural gap: a fact with no owner. No output section, brief item, validator input,
or template field can carry "search was unavailable", so the fact is never captured at its origin
([C-6](artifacts/current-state-findings.md#c-6-no-step-captures-which-tools-the-analyst-had-and-no-output-field-could-carry-it)).
Four adjacent rules that say what did not happen are all keyed to evidence, not to a missing tool, so none fires
([C-7](artifacts/current-state-findings.md#c-7-every-existing-say-what-did-not-happen-rule-is-keyed-to-evidence-not-to-a-missing-tool)).
The validator is chartered against stale or convenient sources, not a narrow search, and is not told what tools the
analyst had
([C-8](artifacts/current-state-findings.md#c-8-the-validator-is-chartered-to-catch-convenient-sources-not-a-narrow-search)).
A no-search run can render `Confidence: High` with no rule broken
([C-9](artifacts/current-state-findings.md#c-9-neither-the-evidence-mode-nor-the-confidence-rating-has-an-input-from-search-was-unavailable)).

The repo already has the idiom for this. The agent-building guidance says to check a tool inline, skip the step, and
note the limitation in the output. The research skill already applies that pattern to git, with a probe, a note, and
an announcement
([C-10](artifacts/current-state-findings.md#c-10-the-repo-already-has-a-codified-idiom-for-a-missing-tool-and-the-research-skill-uses-it-for-git)).
The one precedent for a missing harness tool says the attempt is the detection
([C-11](artifacts/current-state-findings.md#c-11-how-an-agent-notices-a-missing-tool-the-attempt-is-the-detection-and-the-tool-is-filtered-before-launch)).

Five doc surfaces promise open-web reach without saying what happens where search is absent
([C-12](artifacts/current-state-findings.md#c-12-five-doc-surfaces-promise-open-web-reach-without-distinguishing-search-from-fetch)).

## Target State

One new fact flows through one existing seam, and three things stay as they are.

**The analyst owns detection and disclosure.** `research-analyst.md` § Protocol 2 gathers by fetch alone when
`WebSearch` is not among its tools or a call to it is refused, without stopping or probing further
([D-3](artifacts/change-decision-log.md#d-3-the-analyst-detects-the-missing-search-tool-itself)). Its Output Format
then opens every return with one Web search line
([D-4](artifacts/change-decision-log.md#d-4-the-web-search-line-pinned-end-to-end-and-always-present)). It is not
answerable for finding a substitute search tool.

**The skill carries the fact and gives it to two consumers.** `research/SKILL.md` Step 5 tells each analyst to open
with the line. Step 6 reads it from every analyst and holds one value. Step 7 passes the value to the validator and,
when it is anything but `used`, adds one completeness sentence to the charter. Step 8 renders the value as the second
Summary bullet, shields it from the readability editor and the self-check, and opens the closing message with it when
it is anything but `used`
([D-4](artifacts/change-decision-log.md#d-4-the-web-search-line-pinned-end-to-end-and-always-present),
[D-6](artifacts/change-decision-log.md#d-6-the-validator-and-the-confidence-rating-take-the-web-search-value-as-an-input),
[D-11](artifacts/change-decision-log.md#d-11-the-web-search-line-is-protected-from-the-readability-rewrite)). The skill
is not answerable for detecting the tool itself.

**The template holds two fixed places for it.** `## Summary` has a `Web search` bullet under `Confidence`. On a run
without search, Confidence Assessment's Remaining Risks carries a fixed member naming the gap and the two remedies.

**The pinned contract.** The analyst writes the line first in its return; the skill copies it without rewording. The
grammar is `**Web search:** <value>` with exactly three literal values
([D-4](artifacts/change-decision-log.md#d-4-the-web-search-line-pinned-end-to-end-and-always-present)):

```markdown
**Web search:** used
```

```markdown
**Web search:** not available. No source was found by searching; anything the question did not name was not looked for.
```

```markdown
**Web search:** not reported. The run did not say whether web search was available; read the report as if it was not.
```

The first two are the analyst's. The third is the skill's alone, written when an analyst's return carries no line.
Across parallel analysts the skill applies one ordered rule: any not-available form wins; else any missing line gives
`not reported`; else `used`. Rendered in the report:

```markdown
- **Confidence:** High / Medium / Low
- **Web search:** used
```

Only `used` means search ran. Every downstream rule keys on that one condition
([D-10](artifacts/change-decision-log.md#d-10-an-unconfirmed-search-is-treated-as-no-search)).

**What stays as it is.** The agent's `tools:` line keeps `WebSearch`
([D-5](artifacts/change-decision-log.md#d-5-the-agents-tools-line-stays-as-it-is)). The skill's `allowed-tools:` line
keeps it too, because that field pre-approves and gates nothing
([C-2](artifacts/current-state-findings.md#c-2-the-skills-allowed-tools-pre-approves-websearch-it-does-not-gate-what-the-agent-can-reach),
[D-7](artifacts/change-decision-log.md#d-7-the-skills-allowed-tools-line-stays-as-it-is)). The `A#` registry shape,
the evidence mode, and `han-core/agents/adversarial-validator.md` are untouched.

## Surface Delta

### S-1: `research-analyst.md` § "2. Gather from the Open Web" — Re-scoped

**Target state.** The protocol is conditional. When `WebSearch` is not among the tools offered to the analyst, or a
call to it is refused, the analyst gathers with `WebFetch` alone. It does not stop or probe further, and it opens its
return with the not-available line. Its fetch-only source set is what it is today: the URLs the brief names, pages
linked from them, and pages it already knows. Otherwise it uses `WebSearch` and `WebFetch` as it does today. The
source-recording and claim-not-instruction rules in the protocol are unchanged.

**Behavior.** Changing for one observer: a person on a search-capable install who declines the `WebSearch` permission
prompt. Today the outcome for that person is undefined; after this change, they see the run continue by fetch and the
report labeled not available. Settled by the operator: "got with recommended"
([D-10](artifacts/change-decision-log.md#d-10-an-unconfirmed-search-is-treated-as-no-search)). On an install without
the tool the analyst already runs fetch-only today (issue #212, Environment); the mechanism behind that is the one
unverified input
([C-11](artifacts/current-state-findings.md#c-11-how-an-agent-notices-a-missing-tool-the-attempt-is-the-detection-and-the-tool-is-filtered-before-launch)).

**Why.** The analyst is the only party that holds the fact
([C-11](artifacts/current-state-findings.md#c-11-how-an-agent-notices-a-missing-tool-the-attempt-is-the-detection-and-the-tool-is-filtered-before-launch)),
and the repo's guidance puts detection and the note in the agent
([C-10](artifacts/current-state-findings.md#c-10-the-repo-already-has-a-codified-idiom-for-a-missing-tool-and-the-research-skill-uses-it-for-git)).

**Decision.** [D-3](artifacts/change-decision-log.md#d-3-the-analyst-detects-the-missing-search-tool-itself),
[D-10](artifacts/change-decision-log.md#d-10-an-unconfirmed-search-is-treated-as-no-search)

### S-2: `research-analyst.md` § "Output Format" — Re-scoped

**Target state.** Every return opens with exactly one Web search line, in one of the two analyst forms pinned in Target
State, before `### Sources`. The four existing sections follow unchanged.

**Behavior.** Changing. The skill, and anyone who dispatches the agent directly, sees a new first line on every return.
Settled by the operator: "go with recommended".

**Why.** The fact has to be captured at its origin or it is never captured
([C-6](artifacts/current-state-findings.md#c-6-no-step-captures-which-tools-the-analyst-had-and-no-output-field-could-carry-it)).

**Depends on.** S-1.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-web-search-line-pinned-end-to-end-and-always-present)

### S-3: `research/SKILL.md` § "Operating Principles" fixed-structure sentence and § "Step 8" — Re-scoped

**Target state.** The fixed report structure names the Web search line as part of the Summary. Step 8 renders the
value held from Step 6 as `- **Web search:** …` directly under the Confidence bullet, with no rewording. The
readability-editor dispatch and the self-check paragraph each name that bullet as a fixed literal that survives
unchanged on the same terms as `A#`/`V#`. The closing chat message opens with the line, verbatim, when the value is
anything but `used`, and says nothing about it otherwise.

**Behavior.** Changing, the same observation as S-2 seen by the report reader: every report's Summary carries a second
labeled line. Settled by the operator: "go with recommended".

**Why.** Step 8 renders only the template's fixed fields, so the line needs a named place in the structure
([C-6](artifacts/current-state-findings.md#c-6-no-step-captures-which-tools-the-analyst-had-and-no-output-field-could-carry-it)).
The editor that runs next also rewrites prose bullets unless told not to
([D-11](artifacts/change-decision-log.md#d-11-the-web-search-line-is-protected-from-the-readability-rewrite)).

**Depends on.** S-4, S-6.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-web-search-line-pinned-end-to-end-and-always-present),
[D-11](artifacts/change-decision-log.md#d-11-the-web-search-line-is-protected-from-the-readability-rewrite),
[D-13](artifacts/change-decision-log.md#trivial-decisions)

### S-4: `research/SKILL.md` § "Step 5" brief list and § "Step 6" opening — Re-scoped

**Target state.** Every analyst brief carries one more item: open the return with the Web search line in one of its two
exact forms, before the Sources registry. Step 6, after collecting verbatim output, reads the line from each analyst's
return and holds one value under the ordered rule in
[D-4](artifacts/change-decision-log.md#d-4-the-web-search-line-pinned-end-to-end-and-always-present). That rule: any
not-available form wins; else any missing line gives `not reported`; else `used`. The registry compile is otherwise
unchanged.

**Behavior.** Preserving. This is carriage between two in-area parts; nothing outside observes it until S-3 renders it.

**Why.** The brief is the skill's contract with the agent
([C-6](artifacts/current-state-findings.md#c-6-no-step-captures-which-tools-the-analyst-had-and-no-output-field-could-carry-it)),
and Step 6 is where every analyst's output is already read once.

**Depends on.** S-2.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-web-search-line-pinned-end-to-end-and-always-present)

### S-5: `research/SKILL.md` § "Step 7" — Re-scoped

**Target state.** The validator dispatch passes the held Web search value with the registry, mapping, Results,
Options, and Recommendation. When the value is anything but `used`, the charter carries the completeness sentence
pinned in
[D-6](artifacts/change-decision-log.md#d-6-the-validator-and-the-confidence-rating-take-the-web-search-value-as-an-input),
verbatim. `han-core/agents/adversarial-validator.md` is unchanged.

**Behavior.** Changing, on runs whose value is not `used`. The reader can see a completeness finding in Validation
that never appears today, and Step 8 re-weighs the recommendation against it. Settled by the operator: "go with
recommendation" for the not-available case and "got with recommended" for the not-reported case.

**Why.** Nothing in the validator's charter tests completeness and it is not told what tools ran
([C-8](artifacts/current-state-findings.md#c-8-the-validator-is-chartered-to-catch-convenient-sources-not-a-narrow-search)).

**Depends on.** S-4.

**Decision.** [D-6](artifacts/change-decision-log.md#d-6-the-validator-and-the-confidence-rating-take-the-web-search-value-as-an-input),
[D-10](artifacts/change-decision-log.md#d-10-an-unconfirmed-search-is-treated-as-no-search)

### S-6: `research-report-template.md` § "Summary" and § "Confidence Assessment" — Re-scoped

**Target state.** `## Summary` carries `- **Web search:** …` as its second labeled bullet, directly under
`- **Confidence:** …`. The Summary comment says the value is copied from the analyst, never reworded, and survives the
readability pass. Its list of "how solid it is" examples gains "well-corroborated among the pages the question
named; no web search ran". Remaining Risks lists the fixed member pinned in
[D-6](artifacts/change-decision-log.md#d-6-the-validator-and-the-confidence-rating-take-the-web-search-value-as-an-input)
for a run without search. Every other section is unchanged.

**Behavior.** Changing, the same observation as S-3 for the Summary line, and the same as S-5 for Remaining Risks.
Settled by the operator: "go with recommended", "go with recommendation", and "got with recommended".

**Why.** The Summary is the one section a non-technical reader is told they need, and Remaining Risks is already the
slot for uncovered scope
([C-9](artifacts/current-state-findings.md#c-9-neither-the-evidence-mode-nor-the-confidence-rating-has-an-input-from-search-was-unavailable)).

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-the-web-search-line-pinned-end-to-end-and-always-present),
[D-6](artifacts/change-decision-log.md#d-6-the-validator-and-the-confidence-rating-take-the-web-search-value-as-an-input),
[D-10](artifacts/change-decision-log.md#d-10-an-unconfirmed-search-is-treated-as-no-search),
[D-11](artifacts/change-decision-log.md#d-11-the-web-search-line-is-protected-from-the-readability-rewrite),
[D-14](artifacts/change-decision-log.md#trivial-decisions)

### S-7: `docs/skills/research.md` and `docs/agents/research-analyst.md` — Re-scoped

**Target state.** The skill doc's "Reaches the open web" bullet says that where Claude Code has no web search (Amazon
Bedrock installs; the official docs are silent on Vertex and Foundry), the analyst gathers by fetch only. The report's
Summary says so on its `Web search` line. The agent doc's paragraph on speed says the same for the agent's return. It
also says there is no way to give the shipped analyst a different search tool: a copy of the agent, with the server's
tool added to its `tools:` list and its web protocol pointed at that tool, can be dispatched directly. But `/research`
always dispatches the shipped analyst, so a copy does not replace it there and drifts from upstream on every release.
The README scent lines and the two repo-root index lines are unchanged.

**Behavior.** Preserving. Docs change no run's behavior.

**Why.** The doc claim "can search and fetch" is false on Bedrock and the docs are where a reader learns the line
exists before seeing one
([C-12](artifacts/current-state-findings.md#c-12-five-doc-surfaces-promise-open-web-reach-without-distinguishing-search-from-fetch)).

**Depends on.** S-1 through S-6, because the docs describe them.

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-the-docs-say-what-happens-without-search-and-say-plainly-that-the-shipped-agent-cannot-be-given-another-search-tool)

## Behavior Changes

Three changes, each accepted by the operator.

**Every research report and every analyst return says whether web search ran** (S-2, S-3, S-6). A reader opening a
report on a normal run sees `Web search: used` under the confidence rating. On a run without search, they see a
sentence saying web search was not available, no source was found by searching, and anything the question did not
name was not looked for. Someone who dispatches the agent directly sees the same line first in its return. The
operator chose the always-present form over a
line that appears only on no-search runs: "go with recommended"
([D-4](artifacts/change-decision-log.md#d-4-the-web-search-line-pinned-end-to-end-and-always-present)). The label and
wording were changed after that answer on a review finding; the shape was not.

**On a run without confirmed search the validator also judges completeness** (S-5, S-6). The Validation section can
carry a finding naming an option or source the question did not mention that a search would likely have surfaced. The
recommendation is then re-weighed against it, and Remaining Risks names the gap and the two remedies. On a `used` run
nothing changes. The operator chose this over leaving the validator alone: "go with recommendation"
([D-6](artifacts/change-decision-log.md#d-6-the-validator-and-the-confidence-rating-take-the-web-search-value-as-an-input)).

**Anything short of a confirmed search is treated as no search** (S-1, S-5, S-6). A person who declines the
`WebSearch` permission prompt mid-run sees the run continue by fetch and the report labeled not available. A report
whose analyst failed to write the line says `not reported` and tells the reader to read it as if search was not
available. It also gets the completeness finding and the risk note. The operator chose this over limiting the
treatment to a confirmed absence: "got with recommended"
([D-10](artifacts/change-decision-log.md#d-10-an-unconfirmed-search-is-treated-as-no-search)).

## Change Units

### Unit 1: The agent, the skill, and the template

**What it does.** It makes the analyst's web protocol conditional and adds the Web search line to its Output Format.
It teaches the skill to ask for, hold, pass on, render, and protect the line. It adds the completeness sentence to the
validator brief and the closing-message rule, and it adds the two template places and the two template comments.
These ship together because they share one contract across three files, and the agent alone satisfies the issue only
for a caller who dispatches it directly
([D-12](artifacts/change-decision-log.md#d-12-the-agent-skill-and-template-ship-as-one-unit)).

**Delta entries.** S-1, S-2, S-3, S-4, S-5, S-6.

**Justification.** Issue #212 direction 1, the floor the operator confirmed (`artifacts/scope-boundary.md`,
Operator-Stated Scope), for S-1 through S-4 and S-6's Summary. The operator's escalation answers for S-5, S-6's
Remaining Risks, and the unconfirmed-search cases, recorded in
[D-6](artifacts/change-decision-log.md#d-6-the-validator-and-the-confidence-rating-take-the-web-search-value-as-an-input)
and [D-10](artifacts/change-decision-log.md#d-10-an-unconfirmed-search-is-treated-as-no-search).

**How you know it worked.** `npm run lint` passes. Dispatching `han-research:research-analyst` directly on this
(Anthropic-backed) install returns `**Web search:** used` as its first line. One `/research small` run on this install
renders `- **Web search:** used` under Confidence, with the line byte-identical after the readability pass. The
closing message says nothing about web search. A dry read of Step 6 with an imagined analyst return that omits the
line yields `not reported`. A dry read of Step 7 with that value includes the completeness sentence. The agent file is
still self-contained with `tools:` unchanged, and the skill stays under the 500-line body limit (it is 342 lines
today).

### Unit 2: The docs

**What it does.** Adds the no-search paragraph to each long-form doc and the plain statement about copying to the
agent doc.

**Delta entries.** S-7.

**Ordering constraint.** After Unit 1, because the docs describe it.

**Justification.** Issue #212 direction 2 and the doc surfaces C-12 names.

**How you know it worked.** `npm run lint` passes, the doc's summary line, which the scent lines reuse, is unchanged,
and the agent doc makes no claim about a copy reaching the `/research` roster.

## Risks

**The analyst does not take the no-search branch on Bedrock.** Nobody in this run could look inside a Bedrock-backed
subagent
([C-11](artifacts/current-state-findings.md#c-11-how-an-agent-notices-a-missing-tool-the-attempt-is-the-detection-and-the-tool-is-filtered-before-launch)).
If it happens, a Bedrock report carries `Web search: used`, which is worse than today's silence because it is an
affirmative wrong claim. The protocol names both triggers (absent from the list, refused on call), so it holds under
either observation. The only proof is a `/research` run on a Bedrock install after Unit 1. No one on this
project has one; see Open Items for who does.

**The readability pass rewords the line.** Named by all three reviewers. Closed by
[D-11](artifacts/change-decision-log.md#d-11-the-web-search-line-is-protected-from-the-readability-rewrite); Unit 1's
check reads the line back after the pass. If a later edit drops the protecting clause, the first `not available`
report on a Bedrock install would show a paraphrase, and nothing automated would notice.

**The validator's completeness sentence produces nothing.** Strategy 4 takes brief-level direction today, and the
sentence is now pinned verbatim so it cannot be read as the existing "implausibly convenient" check. The revisit
criterion in
[D-6](artifacts/change-decision-log.md#d-6-the-validator-and-the-confidence-rating-take-the-web-search-value-as-an-input)
covers the case where it still returns nothing.

## Deferred (YAGNI)

### The fallback chain

**Why deferred:** Evidence test. One user reported that `WebFetch` against `api.github.com/search/repositories`,
`registry.npmjs.org/<pkg>`, and `pypi.org/pypi/<pkg>/json` recovers "a usable fraction" of discovery. Nothing measures
that fraction, there is one caller, and the claim assumes research questions are about packages. The chain's middle
link, an MCP server, is unreachable from a plugin agent
([C-5](artifacts/current-state-findings.md#c-5-plugin-subagents-cannot-carry-their-own-mcp-servers)).
**Reopen when:** A no-search report is followed by a user recording that registry-endpoint discovery would have changed
the recommendation, or three no-search reports name a missing option that such an endpoint lists. The Web search line
is what makes this countable.
**Source:** Issue #212, "Possible directions", last paragraph;
[D-9](artifacts/change-decision-log.md#d-9-the-fallback-chain-is-deferred).

### Named MCP search patterns in `tools:`

**Why deferred:** Evidence test. `mcp__exa`, `mcp__brave`, `mcp__tavily`, or `mcp__kagi` match only when the user
named the server that way, and a match grants every tool the server exposes. There are zero known installs to satisfy
the Rule of Three.
**Reopen when:** A search server with a vendor-fixed name that Claude Code documents as a `WebSearch` substitute
exists and three Han users report it configured under that name.
**Source:** Issue #212 direction 3;
[D-5](artifacts/change-decision-log.md#d-5-the-agents-tools-line-stays-as-it-is).

### A `.han/config.md` setting naming a search tool

**Why deferred:** Evidence test. A skill cannot pass a tool grant into a plugin agent's frontmatter at dispatch time
([C-14](artifacts/current-state-findings.md#c-14-the-config-rule-carries-an-extra-agents-seam-and-no-tool-seam)),
so the setting would bind to nothing.
**Reopen when:** Claude Code lets a dispatching skill pass a tool grant to a plugin agent at dispatch time.
**Source:** Software-architect part C;
[D-5](artifacts/change-decision-log.md#d-5-the-agents-tools-line-stays-as-it-is).

### A documented recipe for reaching a copied analyst through `## Extra Agents`

**Why deferred:** Simpler-version test. The recipe as drafted would not work: the copied protocol keys on `WebSearch`
by name, so the copy would gather fetch-only and say so. A corrected copy would still run beside the shipped analyst,
whose not-available line labels the whole report. And verifying the route costs a `/research` run for zero known
users. The plain statement in S-7 says what is true without it.
**Reopen when:** A user reports having copied the analyst with an MCP search tool and asks how to get it onto the
`/research` roster.
**Source:** Software-architect recommendation A4; review finding JD-004;
[D-8](artifacts/change-decision-log.md#d-8-the-docs-say-what-happens-without-search-and-say-plainly-that-the-shipped-agent-cannot-be-given-another-search-tool).

## Cut for Scope

**An extension point that adds a search tool to the shipped agent without copying it** (issue direction 2 as
worded). It would have let a user with an Exa, Brave, Tavily, or Kagi server point the shipped analyst at it. It is cut
because the platform offers no such point: a plugin agent cannot carry its own MCP server
([C-5](artifacts/current-state-findings.md#c-5-plugin-subagents-cannot-carry-their-own-mcp-servers)). And the two ways
to admit a user's server through `tools:` are rejected in
[D-5](artifacts/change-decision-log.md#d-5-the-agents-tools-line-stays-as-it-is). What remains is stated in S-7: a copy
is the only route, dispatched directly, with its drift cost named. You can reinstate this if you know a route this run
did not find; your saying so is the justification the reinstated entry records.

## Open Items

**What does the model see inside a Bedrock-backed subagent, and does the analyst take the no-search branch there?**
Non-blocking. Nobody on this project has a Bedrock install. The issue's reporter does; the concrete action is to ask
them, on the pull request or the issue, to run `/research small` on the branch and paste the report's Summary. The
protocol is written to hold under either answer, and the risk above says what a wrong answer looks like.

## Review Findings

Three specialists reviewed the draft: `han-core:junior-developer` (seven findings), `han-core:risk-analyst` (scored
every finding and the plan's own risks), and `han-core:user-experience-designer` (seven findings). Merged by substance,
these changed the plan:

- **The fixed line was unprotected from the readability pass** (JD-001, UX-001, risk-analyst (b)). Produced
  [D-11](artifacts/change-decision-log.md#d-11-the-web-search-line-is-protected-from-the-readability-rewrite) and the
  second risk above.
- **The label and values were jargon in the one jargon-free section, and named no consequence for the reader**
  (UX-002, UX-003, UX-004, UX-005). Produced the wording now pinned in
  [D-4](artifacts/change-decision-log.md#d-4-the-web-search-line-pinned-end-to-end-and-always-present) and
  [D-6](artifacts/change-decision-log.md#d-6-the-validator-and-the-confidence-rating-take-the-web-search-value-as-an-input),
  and the two trivial decisions D-13 and D-14.
- **The carriage rule left a mixed case undefined** (JD-002, UX-007). Closed by the ordered rule in D-4.
- **`not reported` and a refused call had no downstream treatment** (JD-003, JD Q8, risk-analyst on S-1). Escalated;
  produced [D-10](artifacts/change-decision-log.md#d-10-an-unconfirmed-search-is-treated-as-no-search).
- **The fork recipe would not work as written** (JD-004). Produced the simpler S-7 and the fourth deferral, recorded in
  [D-8](artifacts/change-decision-log.md#d-8-the-docs-say-what-happens-without-search-and-say-plainly-that-the-shipped-agent-cannot-be-given-another-search-tool).
- **The first draft narrowed the fetch-only source set** (JD-005). Closed in
  [D-3](artifacts/change-decision-log.md#d-3-the-analyst-detects-the-missing-search-tool-itself).
- **The completeness clause was a prose description** (JD-006, risk-analyst Contracts). Pinned verbatim in D-6.
- **Two units shared one contract across a review boundary** (risk-analyst, Sequencing). Produced
  [D-12](artifacts/change-decision-log.md#d-12-the-agent-skill-and-template-ship-as-one-unit).

Findings closed by the current-state findings or the plan's own text, with no change: the skill's size (342 of 500
lines), the agent's self-containment, the one-canonical-source convention on the scent lines, and the always-present
line as noise on normal runs (weighed and decided in D-4; the risk-analyst agreed).

Unverified, and never presented as blocking: every judgment about what a Bedrock-backed subagent sees (UX-006,
risk-analyst's likelihood ratings) rests on the same uninspected input as C-11. It is carried in the first risk and the
open item.
