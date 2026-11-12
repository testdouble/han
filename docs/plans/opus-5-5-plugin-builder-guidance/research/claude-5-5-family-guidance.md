# Research: Is the plugin-builder guidance current for the Claude 5.5 models?

This report checks whether the `han-plugin-builder` authoring guidance matches what Anthropic now publishes for the
Claude 5.5 models (Opus 5.5, Sonnet 5.5, Haiku 5.5) and for Claude Code's model settings. Evidence mode: strict.

## Summary

The guidance (called "the guide" below) gets Opus 5.5 mostly right. It is out of date in four places, though, and says
nothing about Sonnet 5.5 or Haiku 5.5. The most serious gap is the warning about asking a model to repeat its private
reasoning (the "reasoning-echo warning" below). That warning now covers every current model, not only the two the guide
names. It also covers more prompt shapes, including a
`reasoning` field in an agent's output format. The second gap is advice to cut "check your work" instructions. That
advice is right for Opus and wrong for Sonnet 5.5 and Haiku 5.5 at low effort. Third, Claude Code changed the order it
uses to pick a subagent's model. Fourth, the built-in Explore agent no longer runs on Haiku. The fix is to correct
those four, name the two missing models where a difference changes what an author writes, and point to the live
Claude Code docs for the settings that keep moving.

Anthropic's own pages agree on all of this, and the key pages were re-read in full for this report. No outside source
confirms them, though.

- **Confidence:** Medium
- **Web search:** used

## Research Results

### The reasoning-echo warning covers every current model

The guide says only Fable 5 and Opus 5.5 refuse an instruction to reproduce their own thinking. It also calls the
`reasoning_extraction` category "new for anyone coming from Opus 5" (A18). Both claims are wrong now. The Opus 5
prompting page has its own section on it: prompts, skills, and tool descriptions that ask Opus 5 to write out its
reasoning "may be declined with the `reasoning_extraction` refusal category" (A16). Anthropic's refusals page lists the
classifiers on Fable 5.1, Fable 5, Opus 5.5, Opus 5, Sonnet 5.5, and Haiku 5.5 (A15). The Sonnet 5.5 page names the
category directly and says to remove instructions that ask for reasoning in the response (A8, A10). What is new on Opus
5.5 is the biology safeguard, not this category (A1).

Haiku 5.5 is the one unclear case. Its prompting page lists four refusal categories and leaves `reasoning_extraction`
out (A9). The refusals page puts Haiku 5.5 in scope (A15). Separately, the Haiku page says the model sometimes writes
reasoning-like text into its visible reply, and the fix is adaptive thinking at `medium` effort (A9). Writing as if
the refusal applies is the safe reading.

The trigger is wider than "echo your thinking." Anthropic lists four shapes (A15):

- a `<thinking>`, `<reasoning>`, or scratchpad section the model fills in before it answers
- a `reasoning`, `thinking`, or `trace` field in JSON output or in a tool input
- private notes, or a running log of the model's reasoning
- reasoning asked for verbatim or in full

The page says this wording "can sit in a system prompt, a skill, or a tool description" (A15). An agent output format
with a `reasoning` field is exactly this pattern. A short explanation, the evidence behind a result, or a summary of
actions taken stays fine (A15, A16).

The builders' final review checks for this today, but only for the narrow "reproduce the model's reasoning" wording
(A19). A grep of the Han agents and skills found no `reasoning` field in any output format, so Han itself is not
affected.

### Verification advice splits by model

The biggest difference for an author is whether to tell the model to check its work. Opus 5 checks its own work
unprompted, and Anthropic says explicit verification instructions cause over-verification and should be removed (A16).
The guide carries that advice, scoped to Opus (A18).

Sonnet 5.5 and Haiku 5.5 run the other way at low effort. Sonnet 5.5 "generally checks its work," but at `low` effort
it "sometimes reports a change as done without running a check" (A8). Haiku 5.5 does the same at `low` and `medium`
(A9). Both pages supply a paragraph to add: run a real check (tests, type-checker, build) before reporting a code change
done (A8, A9). Fable 5 also asks for explicit self-verification on long runs, with fresh-context verifier subagents
(A7). The guide has no warning against applying the Opus removal list to these models.

### Each 5.5 model has its own early-stop and scope habits

Both new models carry their predecessors' prompts over. Sonnet 5 prompts "should perform well without changes" on
Sonnet 5.5, and Haiku 4.5 prompts on Haiku 5.5 (A8, A9). There is no Haiku 5; the prior Haiku is 4.5 (A14).

Their habits differ enough to matter for a skill that runs long:

- **Sonnet 5.5** adds tests, docs, and small supporting files it was not asked for, at every effort level and more at
  higher effort (A8). At `low` and `medium` on long agentic tasks it stops to check in more often (A8). At `xhigh` and
  `max` it can start its own review rounds, "sometimes with subagents" (A8). Anthropic gives one paragraph for each
  (A8).
- **Haiku 5.5** rarely stops early with a short system prompt. With a long coding-agent prompt at `low` it sometimes
  hands the task back. In Anthropic's testing, moving from `low` to `medium` roughly halved early stops and more than
  doubled output tokens (A9) [single-source].

Anthropic calls Haiku 5.5 built for classification, routing, extraction, and subagent work (A11), and the effort page
lists subagents as a `low`-effort use (A12). It is the first Haiku with effort levels (A9).

Neither 5.5 page says whether the model reads instructions literally. The Sonnet 5 page does: it reads prompts
"literally and explicitly, particularly at lower effort levels" (A13) [single-source]. Carrying that to Sonnet 5.5
rests on the carry-over statement, not on a 5.5 claim.

### Claude Code changed how it picks a subagent's model

The guide's resolution order puts the `CLAUDE_CODE_SUBAGENT_MODEL` environment variable first (A18). Claude Code now
uses this order (A4):

1. The model Claude passes when it starts the subagent.
2. The agent definition's `model` frontmatter, where `inherit` means the main conversation's model.
3. The `CLAUDE_CODE_SUBAGENT_MODEL` environment variable.
4. The main conversation's model.

The page says the environment variable came first before Claude Code v2.1.251 (A4). It now wins over everything only
when `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` is also set, which needs v2.1.257 or later (A4).

Three more Claude Code facts in the guide have drifted:

- **Omitted `model`.** The guide says an omitted `model` defaults to `inherit` (A18). The docs say an omitted `model`
  falls through the order above, so the environment variable applies before the main model (A4). The guide's own
  checklist already tells authors to set `model` explicitly, which limits the harm.
- **Explore.** The guide's built-in agent table says Explore runs on `haiku` (A18). It now runs on the main
  conversation's model; when that model is Fable, it runs on the Opus alias with an Anthropic subscription or Console
  account (A4).
- **Aliases.** The guide's alias table leaves out `fable`, which subagents accept (A4). Aliases also resolve by
  provider: `sonnet` is Sonnet 5.5 on the Anthropic API but Sonnet 4.5 on Bedrock, and `haiku` is Haiku 5.5 only on the
  Anthropic API (A3). The guide's reason to prefer an alias, that "it keeps tracking the current model," holds on the
  Anthropic API and not everywhere.

These Claude Code facts the guide already gets right: a skill's `model` lasts for one turn (A5), and `effort` accepts
`low`, `medium`, `high`, `xhigh`, and `max` in skill and agent frontmatter (A3, A4, A5).

### Thinking and effort differ by model and by surface

In Claude Code, thinking cannot be turned off on Opus 5.5, Sonnet 5.5, Haiku 5.5, or any Fable model (A3). On the API
the picture differs. Sonnet 5.5 rejects `disabled` and offers `between_tools` as its lowest setting, accepted at `high`
effort or below (A10, A8). Haiku 5.5 accepts `disabled` at `high` or below (A9). The guide's thinking bullet names
neither model (A18). Because skills built with this guidance run in Claude Code, the Claude Code rule is the one an
author needs, labeled as such.

Effort defaults also differ by surface. In Claude Code, Opus 5.5, Sonnet 5.5, and Haiku 5.5 all default to `medium`
(A3). On the API, Sonnet 5.5 defaults to `high` (A10, A12). Sonnet 5.5's levels were recalibrated against Sonnet 5, so
the same name gives a different amount of thinking, and Anthropic says to re-run the effort sweep (A8, A10). The
guide's "re-test a pinned effort value" advice covers only the move from Opus 5 to Opus 5.5 (A18).

Asking any of these models in a prompt to think less does not reliably reduce thinking; lowering effort does (A1, A8,
A9). The guide already says effort, not prompt wording, is the depth lever (A18).

### What still holds for Opus 5.5

The guide's Opus 5.5 claims check out against the full prompting page. Existing Opus 5 prompts carry over unchanged
(A1). Thinking cannot be turned off (A1, A3). The API default effort is `medium`, where Opus 5's was `high`, and
`medium` on Opus 5.5 "matches or exceeds" Opus 5 at `high` on coding and knowledge-work evaluations (A1). Naming the
stops you do and do not want fixes early status-report stops on unattended runs (A1).

One attribution is off. The guide says Anthropic's Opus 5.5 guidance "recommends" the "block the merge" review prompt
(A18). That prompt is in the blog post (A2), not on the prompting page (A1) [single-source].

### Fable 5.1 carries Fable 5 prompts over, and the guide overstates one Fable claim

A Fable 5.1 prompting page now exists. It says Fable 5 prompts carry over unchanged and repeats the reasoning-echo
warning (A6).

The guide says spelling out every step "with a checklist actively degrades its output" (A18). The Fable 5 page, read in
full, never uses the word "checklist." It says you can "steer most behaviors with a brief instruction rather than
enumerating each behavior by name," and that skills written for earlier models "are often too prescriptive" and "can
degrade output quality" (A7).

### Smaller items to check before editing

- `specialization-and-model-selection.md` cites two pages on older documentation hosts and uses the older "thinking
  budget" term (A20). Whether those links still resolve was not checked.
- `success-criteria-and-testing.md` credits Anthropic with an unlinked claim that Haiku may need more explicit
  instructions (A21). No current page found says this. The Haiku 5.5 page says to use `high` effort for strict
  instruction-following (A9), which is a different claim.
- The guide's four-model list and its 2026-09-23 "last checked" date repeat in five files (A18, A20):

  ```
  per-model-authoring.md
  guidance/SKILL.md
  guidance-portable-SKILL.md
  rule-index-body.md
  specialization-and-model-selection.md
  ```

## Options to Consider

The question is mostly "what changed," but one real choice sits inside it: how to handle Claude Code facts that keep
moving. Alias targets, the built-in agents' models, and the resolution order all changed within three weeks of the
guide's last check (A3, A4).

### O1: Pin the current Claude Code facts in the guide

- **What it is:** Rewrite the alias table, the built-in agent table, and the resolution order to match today's docs.
- **Trade-offs:** An author reads the answer in place. The facts go stale again on the next Claude Code release, and
  `guidance init` copies them into other repos, where they age unseen.
- **Rests on:** (A3), (A4)
- **Evidence status:** corroborated (same vendor)

### O2: State the stable rule and link to the live docs

- **What it is:** Keep only what an author acts on (set `model` explicitly; an operator setting can override it;
  aliases resolve by provider), with a version note and a link to the Claude Code page for the current details.
- **Trade-offs:** It stays correct longer. An author has to follow a link for the specifics.
- **Rests on:** (A3), (A4)
- **Evidence status:** corroborated (same vendor)

## Recommendation

- **Recommendation:** Use O1 for the resolution order, which an author needs to reason about frontmatter, with the
  v2.1.251 version note. Use O2 for the alias targets and the built-in agents' models. Then make these changes, most
  consequential first:
  1. Widen the reasoning-echo section in `per-model-authoring.md` to every model on the refusals page, drop the "new
     for anyone coming from Opus 5" line, and list the four trigger shapes. Widen the builders' review check to match,
     in both builder skills and their docs (A15, A16, A8, A19).
  2. Scope the "leave out verification steps" advice to Opus by name. Add that Sonnet 5.5 at `low` effort and Haiku 5.5
     at `low` and `medium` may report a change done without checking, so a skill that runs on them should keep explicit
     verification and keep-working text (A16, A8, A9).
  3. Correct the subagent resolution order and the omitted-`model` wording; add `fable` to the alias table; replace the
     Explore row and the alias-tracking claim with the stable rule and a link (A4, A3).
  4. Add Sonnet 5.5 and Haiku 5.5 to the thinking and effort bullets, labeled for Claude Code: thinking cannot be
     turned off, all 5.5 models default to `medium`, and Sonnet 5.5's effort names were recalibrated (A3, A8, A10).
  5. Add a short note on each 5.5 model's early-stop and scope habits to the length-and-scope section (A8, A9).
  6. Quote the Fable claim as Anthropic words it, note Fable 5.1, correct the "block the merge" attribution, and update
     the model list and "last checked" date everywhere it repeats (A6, A7, A2, A18, A20).
  7. Label the Sonnet literalism claim as inherited from Sonnet 5, and add Haiku 5.5's stated subagent fit to the tier
     guidance (A13, A11, A12).
- **Evidence basis:** Items 1 through 4 and 6 rest on two or more Anthropic pages that agree, re-read in full for this
  report (corroborated, same vendor). Item 5 rests on the Sonnet 5.5 and Haiku 5.5 prompting pages, one each (A8, A9).
  Item 7's literalism point rests on the Sonnet 5 page alone (A13) and is labeled inherited. The Haiku 5.5
  reasoning-echo coverage rests on the refusals page (A15) against the Haiku page's silence (A9), so the guide presents
  it as the safe reading. Out of scope: the older research reports under `docs/research/` that quote the old resolution
  order are historical records and stay as they are.

## Validation

### V1: The report describes the guide accurately

- **Strategy:** Challenge the Evidence
- **Investigation:** Opened every cited repo location and quoted the guide's wording.
- **Result:** Confirmed
- **Impact:** None. The validator noted the guide's "always set `model` explicitly" checklist limits the harm of the
  stale `inherit` default; the report now says so.

### V2: The recommendation names every place the stale facts live

- **Strategy:** Challenge the Fix
- **Investigation:** Grepped the repo for the model list and the old resolution order.
- **Result:** Partially Refuted
- **Impact:** Added `specialization-and-model-selection.md` to the model-list sweep, added the builders' review check to
  item 1, and marked the `docs/research/` copies out of scope.

### V3: Opus 5 being in scope on the refusals page does not prove it emits the category

- **Strategy:** Challenge the Evidence
- **Investigation:** Re-fetched the full Opus 5 prompting page. Its "Reasoning in the response" section names the
  `reasoning_extraction` category for Opus 5 directly (A16).
- **Result:** Refuted; the challenge does not hold
- **Impact:** The "new for anyone coming from Opus 5" line is wrong on direct evidence, not inference. Citations now
  rest on A16.

### V4: The resolution-order specifics were unquoted

- **Strategy:** Challenge the Evidence
- **Investigation:** Re-fetched the subagents page. It states the four-step order, the pre-v2.1.251 behavior, the
  `_FORCE` variable at v2.1.257, the omitted-`model` behavior, and the Explore rule (A4).
- **Result:** Confirmed once quoted
- **Impact:** Moved the version citations from A3 to A4 and added the version note to the recommendation.

### V5: Thinking and effort claims mix surfaces

- **Strategy:** Challenge the Evidence
- **Investigation:** Re-fetched the Sonnet 5.5 "what's new" page; it says `between_tools` "is accepted at `low`,
  `medium`, and `high` effort" (A10).
- **Result:** Partially Refuted
- **Impact:** Labeled every thinking and effort fact by surface and made the Claude Code rule the recommended one.

### V6: The options framing missed a real choice

- **Strategy:** Challenge the Assumptions
- **Investigation:** The guide's own date stamp calls it a snapshot, and three Claude Code facts moved within three
  weeks.
- **Result:** Refuted
- **Impact:** Added O1 and O2 and a split recommendation.

### V7: The recommendation order and some wording over-reached

- **Strategy:** Challenge the Fix
- **Investigation:** Re-fetched the Sonnet 5.5, Haiku 5.5, Fable 5, and Opus 5.5 pages in full.
- **Result:** Partially Refuted
- **Impact:** Reordered so the refusal and verification items lead. Changed "need" to "may report done without
  checking." The Fable "checklist" absence now rests on a full read. Dropped "every" from the Opus 5.5 claim.

### V8: Some citations did not support their claims

- **Strategy:** Challenge the Evidence
- **Investigation:** Checked each citation against its registry line.
- **Result:** Partially Refuted
- **Impact:** Rewrote the registry lines for A1, A4, A8, A9, A16 so each states the facts it backs.

### V9: The blog post may not be first-party, and the findings depend on few pages

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The blog post sits on a different domain from the docs and was fetched as a summary. Removing it
  changes only the attribution note in item 6.
- **Result:** Partially Refuted
- **Impact:** A2 is marked as not confirmed first-party. Items 1 and 3 rest on a few same-vendor pages, so confidence
  stays Medium. No directive text aimed at the reader was found in the pages read in full.

### V10: Two "stale" items were hypotheses

- **Strategy:** Challenge the Evidence
- **Investigation:** Re-read the A20 and A21 claims.
- **Result:** Partially Refuted
- **Impact:** Moved both under "Smaller items to check before editing" and dropped the replacement source for A21.

### Adjustments Made

Validation reordered the recommendation, added the options section, widened the edit list, and replaced several
unquoted claims with direct quotes from re-fetched pages. The recommendation survived with those changes.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** Every source is Anthropic's, with no outside confirmation. No page shows a revision date. The
  subagents and model-config pages were read to about 100,000 characters, not to the end. Whether Haiku 5.5 emits the
  `reasoning_extraction` category is unresolved. Claude Code settings change often, so the pinned resolution order
  needs its version note.

## Sources

| ID  | Source                              | Link / location                                                                                                                                                 | Retrieved  | Trust class | Summary (one line)                                                                                                                                                  | Evidence status                  |
| --- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| A1  | Prompting Claude Opus 5.5           | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5                                                              | 2026-10-15 | web         | Opus 5 prompts carry over; default effort `medium` "matches or exceeds" Opus 5 at `high`; thinking always on; biology safeguard new vs Opus 5; name the stops.      | corroborated by A3, A12, A16     |
| A2  | Getting the most out of Opus 5.5    | https://claude.dev/blog/getting-the-most-out-of-opus-5-5/                                                                                                       | 2026-10-15 | web         | Blog post carrying the "block the merge" review prompt; fetched as a summary; first-party status not confirmed.                                                    | single source (caveated)         |
| A3  | Claude Code model configuration     | https://code.claude.com/docs/en/model-config                                                                                                                    | 2026-10-15 | web         | Aliases resolve by provider; Claude Code defaults all 5.5 models to `medium`; thinking cannot be turned off on 5.5 or Fable models.                                 | corroborated by A4, A12          |
| A4  | Claude Code subagents               | https://code.claude.com/docs/en/sub-agents                                                                                                                      | 2026-10-15 | web         | Model order dispatch → frontmatter → env var → main; env var first before v2.1.251; `_FORCE` at v2.1.257; `fable` valid; Explore on main model.                     | corroborated by A3               |
| A5  | Claude Code skills                  | https://code.claude.com/docs/en/skills                                                                                                                          | 2026-10-15 | web         | Skill `model` lasts one turn; skill `effort` accepts `low` through `max`.                                                                                          | corroborated by A3               |
| A6  | Prompting Claude Fable 5.1          | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1                                                             | 2026-10-15 | web         | Fable 5 prompts carry over to Fable 5.1; repeats the reasoning-echo warning for prompts, skills, and tool descriptions.                                            | corroborated by A7, A15          |
| A7  | Prompting Claude Fable 5            | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5                                                               | 2026-10-15 | web         | Steer with a brief instruction; older skills "often too prescriptive" and "can degrade output quality"; no "checklist" wording; asks for explicit self-verification. | single source (caveated)         |
| A8  | Prompting Claude Sonnet 5.5         | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5                                                            | 2026-10-15 | web         | Sonnet 5 prompts carry over; effort recalibrated; skips checks at `low`; checks in at `low`/`medium`; adds unasked files; reviewer subagents at `xhigh`/`max`.      | corroborated by A10, A12, A15    |
| A9  | Prompting Claude Haiku 5.5          | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-haiku-5-5                                                             | 2026-10-15 | web         | Haiku 4.5 prompts carry over; skips checks at `low`/`medium`; early stops on long prompts at `low`; `disabled` thinking at `high` or below; four refusal categories. | corroborated by A11, A12         |
| A10 | What's new in Claude Sonnet 5.5     | https://platform.claude.com/docs/en/models/sonnet-5-5/whats-new-sonnet-5-5                                                                                      | 2026-10-15 | web         | `disabled` returns 400; `between_tools` accepted at `low`/`medium`/`high`; API default effort `high`; effort recalibrated; names `reasoning_extraction`.            | corroborated by A8, A12          |
| A11 | What's new in Claude Haiku 5.5      | https://platform.claude.com/docs/en/models/haiku-5-5/whats-new-haiku-5-5                                                                                        | 2026-10-15 | web         | Built for classification, routing, extraction, and subagents; 1M context.                                                                                          | corroborated by A9, A12          |
| A12 | Effort                              | https://platform.claude.com/docs/en/build-with-claude/effort                                                                                                    | 2026-10-15 | web         | All five levels on Sonnet 5.5 and Haiku 5.5; API defaults `high` for Sonnet 5.5 and `medium` for Haiku 5.5 and Opus 5.5; `low` suited to subagents.               | corroborated by A3, A8, A9       |
| A13 | Prompting Claude Sonnet 5           | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5                                                              | 2026-10-15 | web         | Sonnet 5 reads prompts literally, especially at low effort; vague review limits cut recall.                                                                        | single source (caveated)         |
| A14 | Models overview                     | https://platform.claude.com/docs/en/models/overview                                                                                                             | 2026-10-15 | web         | Current lineup Fable 5.1, Opus 5.5, Sonnet 5.5, Haiku 5.5; legacy includes Haiku 4.5; no Haiku 5.                                                                  | corroborated by A10, A11         |
| A15 | Refusals and fallback               | https://platform.claude.com/docs/en/build-with-claude/refusals-and-fallback                                                                                     | 2026-10-15 | web         | Classifiers on Fable 5.1/5, Opus 5.5/5, Sonnet 5.5, Haiku 5.5; four `reasoning_extraction` trigger shapes; wording can sit in a skill or tool description.          | corroborated by A6, A8, A16      |
| A16 | Prompting Claude Opus 5             | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5                                                                | 2026-10-15 | web         | Remove verification instructions (over-verification); "Reasoning in the response" section names `reasoning_extraction` for Opus 5.                                 | corroborated by A15              |
| A18 | per-model-authoring.md and siblings | `han-plugin-builder/skills/guidance/references/per-model-authoring.md:18,42,48,58,68-69`; `agent-building-guidelines/agent-model-selection.md:33-38,53-56,152` | n/a        | codebase    | The guide's model list, Fable checklist claim, review-prompt attribution, reasoning-echo scope, thinking/effort bullets, resolution order, alias and agent tables. | current-state anchor             |
| A19 | Builder review checks               | `han-plugin-builder/skills/skill-builder/SKILL.md:195`; `han-plugin-builder/skills/agent-builder/SKILL.md:187`                                                  | n/a        | codebase    | Builders' final review flags only "reproduce the model's reasoning" wording, not the wider trigger shapes.                                                         | current-state anchor             |
| A20 | specialization-and-model-selection  | `han-plugin-builder/skills/guidance/references/specialization-and-model-selection.md:9,81-82,206`                                                               | n/a        | codebase    | Uses "thinking budget" wording, cites older documentation hosts, and repeats the four-model list.                                                                  | current-state anchor             |
| A21 | success-criteria-and-testing.md     | `han-plugin-builder/skills/guidance/references/skill-building-guidance/success-criteria-and-testing.md:24-27`                                                   | n/a        | codebase    | Credits Anthropic with an unlinked "Haiku may need more explicit instructions" claim.                                                                              | current-state anchor             |

A17 (the prompting best-practices index) was dropped in consolidation: nothing in the final report rests on it.
