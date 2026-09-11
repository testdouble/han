# Investigation: Feedback Issue #148, automated-test-planning

Investigation report for three corrections raised in
[testdouble/han#148](https://github.com/testdouble/han/issues/148). Read the Summary, then approve the Planned Fix or
push back.

## Summary

- **Root Cause:** Three separate gaps, one per reported finding. `automated-test-planning` carries no size
  classification, so every run dispatches the same agent roster and writes the same nine-section document no matter how
  narrow the question (E1, E3, E4, E5). `test-engineer` and `edge-case-explorer` can justify deferring a test only by
  pointing at coverage that exists somewhere else or at brittleness risk, so neither can answer a user who grants
  reachability and argues symmetry (E6, E7, E8, E9). `readability-editor` verifies only that facts survived its rewrite,
  never that its own new sentences obey the voice blocklist it was applying (E11), and three planning skills are told
  not to check on its behalf (E19).
- **Fix:** Add a size band to `automated-test-planning` that runs a focused single-agent path for a narrow question, add
  a discriminating-power test to both analysis agents so a deferral can be defended on assertion strength, and extend
  the editor's post-rewrite check to cover its own insertions, which is the only place a check holds given that the
  suite disagrees about whether callers should run one (E20).
- **Why Correct:** Each fix copies a mechanism the suite already runs somewhere else. The size band is
  `code-review`'s Step 3.1 classifier plus `iterative-plan-review`'s lightweight mode (E14, E15), and both already
  satisfy the agent-economics guidance this skill currently violates (E16).
- **Validation Outcome:** Validation confirmed every evidence citation and refuted one count, but found three execution
  gaps in the fix as first written (V1, V2, V3) and overstated wording in a fourth (V5). All four are corrected in the
  changes above.
- **Remaining Risks:** The editor's self-check is unvalidated against false positives, and `manual-test-planning` keeps
  an unconditional two-agent pipeline. See Confidence Assessment.

## Problem Statement

A user ran `automated-test-planning` to answer one narrow question and got a full planning engagement back.

**Symptoms.** The user asked whether two proposed RSpec contexts should be added to a money-summing model method. The
run dispatched five subagents, spent roughly 225,000 subagent tokens, produced a multi-section template document, ran
two review agents over it, and ran a rewrite agent after those. The answer it delivered was "no, and here is one test to
write instead."

Two further problems surfaced inside that run. When the user discounted the coverage layers the agents cited and pressed
a symmetry argument, the plan had no answer, and the decisive rebuttal had to be produced by hand afterward. Separately,
the readability editor's own rewrite introduced em-dashes into a heading and two sentences, and the run's final
self-check had to fix all three by hand.

**Expected behavior.** A question answerable in one paragraph gets a proportionate run. A deferral verdict holds up
against a symmetry argument. An editor applying a voice rule obeys that rule in the text it writes.

**Conditions.** The scale problem occurs on every invocation, because no step in the skill inspects how narrow the
request is. The deferral problem occurs whenever a user challenges a YAGNI verdict on symmetry grounds after
reachability is established. The editor problem occurs whenever the editor's rewrite inserts a blocklisted construct.

**Impact.** The reporter scored output accuracy and evidence discipline at 5/5, and scored output length against
decision count at 2/5 and turn efficiency at 3/5. The analysis quality is not in question; the cost and the durability
of the reasoning are.

## Root Cause Analysis

### Root Cause

The three findings have three independent root causes: `automated-test-planning` never classifies the size of the
request, the two analysis agents have no vocabulary for what a proposed test's assertion would catch that an existing
one would not, and `readability-editor` runs no voice check over the sentences it writes.

### Detailed Analysis

**Why every run is a full engagement.** Step 1 of the skill resolves which files to analyze and nothing else (E5). Its
three modes all answer "which files", never "what kind of question is this". Step 2 then dispatches two agents under a
heading that reads "Always dispatch" (E1), and its only conditional gate adds two more specialists on file-content
signals rather than removing the base pair (E2). Step 4 writes nine mandatory sections with no clause allowing any of
them to be omitted for a trivial answer (E3). Step 5 dispatches two reviewers and then the readability editor, with no
skip clause of the kind `code-review` carries (E4). The peak is seven agent dispatches, and nothing anywhere in the
chain can reduce it.

The skill is the only test-planning skill in the suite with this shape and no size control. Ten skills are registered as
sizing-aware and `automated-test-planning` is not among them (E13), even though it dispatches more agents than several
that are.

**Why the deferral did not hold.** `test-engineer` evaluates a candidate test on four axes: value, brittleness risk,
test level, and recency (E6). None of them asks what the candidate's assertion would catch that an existing assertion
would not. Its YAGNI anti-pattern authorizes dismissing a test that "behaves identically to a tested path" (E7), which
is a claim about where coverage sits, not about what an assertion discriminates. Its deferral output field records only
"why the brittleness risk outweighs the value" (E9), so there is no slot in which an assertion-strength argument could
even be recorded.

`edge-case-explorer` has the same shape. Its coverage question is "is this already tested, and is the test correct and
sufficient" (E8), and "sufficient" is defined nowhere in the file. Its own reachability discipline, the part the reporter
praised, counters a symmetry argument only while reachability is still in dispute. Once the user grants that the state
is reachable, the agents have nothing left.

The vocabulary needed for the argument the user wanted is absent from both agent definitions and from the canonical
YAGNI rule (E10). The rule itself is written for committed items generally, with tests as one item type among ADRs,
runbooks, and spec sections (E12), so it supplies no test-specific reasoning either.

**Why the editor introduced violations.** The agent's procedure ends with one post-rewrite step, and that step checks
fact preservation only (E11). Its rubric criterion 5 tells it to remove blocklisted words from the draft it is auditing.
Nothing tells it to run that same criterion over the sentences it just wrote. The rewrite is where new prose enters, so
it is the one place in the chain where a fresh violation can originate, and it is the one place with no voice check.

Whether anything downstream catches that violation depends on which skill dispatched the editor, and the suite does not
agree. `automated-test-planning` and `code-review` run a self-check afterward, which is why the reporter saw the three
em-dashes get fixed by hand rather than shipped (E20). Three planning skills are told in byte-identical language not to
walk the self-check over the editor's output, on the grounds that a same-model pass over fresh output corrupts as often
as it repairs (E19). In those three, an editor-introduced violation reaches the reader with nothing between. One skill,
`edit-for-readability`, runs no independent check and hands the user the editor's own verdict (E20). A check inside the
editor is the only one that holds under all three positions.

The reported em-dash instances are partly stale. The rule the issue quotes, an absolute ban, was live on the issue's
date and was replaced six days later by one legalizing em-dashes in two positions (E17). Under today's wording the two
sentence-internal instances may be legal and the heading instance is still a violation, since a heading is not one of the
two legal positions. The structural gap in E11 is unaffected by that change and remains live.

## Planned Fix

### Approach

Give `automated-test-planning` a size band that runs a single-agent focused path for narrow questions, give both
analysis agents a discriminating-power test they must satisfy before deferring, and make the readability editor check
its own insertions against the voice blocklist.

### Changes

#### `han-coding/skills/automated-test-planning/SKILL.md`

- **Change:** Add a `$size` argument and a size-classification step between Step 1 and Step 2, then thread the resolved
  band through Steps 2, 4, and 5. Add a delegation-policy line to Operating Principles.
- **Evidence:** (E1), (E2), (E3), (E4), (E5), (E13), (E16)
- **Standards:** `multi-agent-economics.md` (start at Level 0, cap counts in the skill body, state the delegation
  policy); `code-review` Step 3.1 as the classifier precedent; `iterative-plan-review` Step 2 as the mode precedent.
- **Details:** Add `[optional: size]` to `argument-hint`. The new step resolves the band in the order the suite already
  uses: an explicit `$size` argument wins, then the config's `default-swarm-size`, then signal classification starting
  at small. Signals: **small** is a question naming specific existing or proposed tests, or one to three files; the band
  defaults to **focused mode**. **Medium** is four to ten files or one cross-cutting concern. **Large** is more than ten
  files or multiple subsystems. Medium and large keep today's behavior exactly.

  In focused mode the skill dispatches `han-core:test-engineer` alone, skips the conditional specialists in Step 2,
  skips both reviewers in Step 5, and answers in prose rather than the nine-section template: the verdict, the reasoning
  behind it, and any test it recommends writing. The readability self-check still runs. The skill states the chosen band
  and its justification in one line before dispatching, as every other sizing-aware skill does.

#### `han-core/agents/test-engineer.md`

- **Change:** Add discriminating power as a fifth evaluation axis, and add a required field carrying it on every
  deferred item.
- **Evidence:** (E6), (E7), (E9), (E10)
- **Standards:** The agent's existing four-axis evaluation block and its S-series output template set the shape; the
  canonical YAGNI rule stays untouched.
- **Details:** The new axis asks what production change the candidate test would catch that existing tests would not.
  The agent answers it by naming a specific weakening of the code under test and checking which existing tests fail
  under it. When at least one existing test already fails under that change, the candidate adds no discriminating power
  and that is the ground for deferring it. When no existing test fails, the candidate is a keep regardless of where
  else the behavior appears to be covered.

  Add to the S-series template:

  ```
  - **Discriminating power:** The production change this test would catch, and the existing test that already fails
    under it (or "none" — which makes this a keep, not a deferral)
  ```

#### `han-core/agents/edge-case-explorer.md`

- **Change:** Define "sufficient" in the existing-coverage evaluation, and carry the same field on dropped items.
- **Evidence:** (E8)
- **Standards:** Matches the `test-engineer` change so the two agents converge on the same test rather than two.
- **Details:** Its coverage question currently asks whether an existing test is "correct and sufficient" without saying
  what sufficient means. Define it: a test is insufficient for an edge case when it still passes under a change that
  breaks that edge case. Add the same discriminating-power line to the Dropped Edge Cases entry format.

#### `han-coding/skills/automated-test-planning/references/template.md`

- **Change:** Add the discriminating-power line to the Deferred Tests and Dropped Edge Cases entry formats.
- **Evidence:** (E6), (E8)
- **Standards:** The template is the skill's contract with the two agents' output; both sections currently carry a bare
  free-text reason.
- **Details:** Each entry gains the field the agents now produce, so the rationale survives into the document a reader
  approves rather than staying inside an agent's return.

#### `han-communication/agents/readability-editor.md`

- **Change:** Extend the post-rewrite step to check the editor's own insertions against the vocabulary blocklist, and
  report the result.
- **Evidence:** (E11), (E17), (E18), (E19), (E20)
- **Standards:** The agent's own rubric criterion 5 already carries the blocklist; this applies it to the agent's output
  rather than only to its input.
- **Details:** Step 3 of "How you work" currently reads that the editor re-reads its result against the original and
  confirms every fact survived. Add a second sentence: re-read every sentence you rewrote or inserted against criterion
  5's blocklist, including the em-dash positional rule, and correct any violation you introduced. Add one line to the
  rubric verdict confirming the pass ran, so the callers that read only the editor's report (E19) get the result they
  currently have no way to see. One file changes and every dispatch site inherits it (E18).

#### Deliberately out of scope: `manual-test-planning`

- **Change:** None.
- **Evidence:** (V10)
- **Details:** It has the same unconditional shape but dispatches two agents rather than five to seven, and already
  declines to write a document when nothing is testable. The issue does not name it. Bringing it under a size gate is a
  reasonable follow-up, recorded here rather than folded into this change.

#### `docs/sizing.md`

- **Change:** Register `automated-test-planning` in the sizing-aware skill list and the at-a-glance table.
- **Evidence:** (E13)
- **Standards:** The repo's completeness convention: an index lists every entity that qualifies.
- **Details:** Add the skill to the sentence naming the sizing-aware skills, and a table row giving what gets sized
  (agent roster and output form) with its three bands.

## Evidence Summary

### E1: Step 2 dispatches two agents unconditionally

- **Source:** `han-coding/skills/automated-test-planning/SKILL.md:92-113`
- **Finding:**
  ```
  ### Always dispatch

  1. **Launch han-core:test-engineer agent** — prompt: "Analyze test coverage for the following files...
  2. **Launch han-core:edge-case-explorer agent** — prompt: "Explore edge cases for the following files...
  ```
- **Relevance:** The heading states the behavior. No branch anywhere skips these two for a narrow question.

### E2: The only conditional gate adds agents, never removes them

- **Source:** `han-coding/skills/automated-test-planning/SKILL.md:114-129`
- **Finding:**
  ```
  ### Conditional dispatch

  Inspect the file list before launching. Skip any that do not apply.

  3. **Launch han-core:concurrency-analyst agent** — only if the file list touches threads, async/await...
  4. **Launch han-core:adversarial-security-analyst agent** — only if the file list touches authentication...
  ```
- **Relevance:** The condition reads file content, not request scope. It can only raise the dispatch count above two.

### E3: Step 4 writes nine mandatory sections with no omission clause

- **Source:** `han-coding/skills/automated-test-planning/SKILL.md:183-233`
- **Finding:** Step 4 is entered unconditionally and its "Fill in all sections" block enumerates Summary, What Needs
  Testing and Why, What Each Test Covers, and six Technical Reference subsections. No clause permits omitting a section
  for a trivial answer.
- **Relevance:** No gate exists between the agent findings and the full template, however few findings survived.

### E4: Step 5 dispatches three more agents unconditionally

- **Source:** `han-coding/skills/automated-test-planning/SKILL.md:235-268`
- **Finding:** Two reviewers dispatch in parallel, then `han-communication:readability-editor` after every actionable
  edit is applied. No line conditions any of the three on plan size or finding count.
- **Relevance:** `code-review` carries an explicit skip for its equivalent steps at `code-review/SKILL.md:336`; this
  skill has no analogue.

### E5: Step 1 resolves file scope only, never question type

- **Source:** `han-coding/skills/automated-test-planning/SKILL.md:51-83`
- **Finding:** All three modes (full git context, uncommitted changes, no git) answer which files become the analysis
  scope. The frontmatter's `argument-hint` accepts file paths, directories, or a description, and offers no size
  argument.
- **Relevance:** The user's question text reaches the agents as focus material at `SKILL.md:88-91`, but nothing reads it
  as a signal about how much work the request warrants.

### E6: test-engineer's evaluation axes never ask what an assertion discriminates

- **Source:** `han-core/agents/test-engineer.md:116-135`
- **Finding:**
  ```
  - **Value** — How important is this behavior to the system's contract. ...
  - **Brittleness risk** — Would a test for this behavior break on routine refactors? ...
  - **Test level** — What level of testing is appropriate? ...
  - **Recency** — If inside a git repository, use `git log` to check if the target code was recently modified...
  - **Priority** — High value + low brittleness = high priority. Low value + high brittleness = skip or defer.
  ```
- **Relevance:** These four axes are the whole prioritization rubric, and none compares a candidate assertion against an
  existing one.

### E7: The YAGNI anti-pattern authorizes dismissal on behavior similarity

- **Source:** `han-core/agents/test-engineer.md:48-58`
- **Finding:**
  ```
  - **Speculative Test (YAGNI)**: Test recommendation for behavior the code does not commit to, code paths that don't
    exist yet, hypothetical adversaries the change does not touch, or symmetry/completeness ("we have a test for create,
    so we should have one for delete" when delete isn't implemented or behaves identically to a tested path).
  ```
- **Relevance:** "Behaves identically to a tested path" is exactly the coverage-location move the reporter says
  collapsed under pressure.

### E8: edge-case-explorer leaves "sufficient" undefined

- **Source:** `han-core/agents/edge-case-explorer.md:188-206` and `:301-302`
- **Finding:**
  ```
  4. **Existing test coverage** — Is this edge case already tested? (From Protocol 1.) If tested, is the test correct and
     sufficient?
  ```
  ```
  - Existing tests are evidence, not constraints — an edge case that is already tested should be noted but does not need a
    new entry unless the existing test is insufficient
  ```
- **Relevance:** "Insufficient" is load-bearing for every drop decision and is defined nowhere in the file.

### E9: The deferral output template has no field for assertion strength

- **Source:** `han-core/agents/test-engineer.md:171-191`
- **Finding:**
  ```
  **S1: [Skipped test title]**
  - **Entry point:** `file/path.ext:line`
  - **Reason:** Why the brittleness risk outweighs the value
  ```
- **Relevance:** The only deferral ground the template can record is brittleness against value. An assertion-strength
  argument has no slot.

### E10: No discriminating-power vocabulary exists in either agent or the YAGNI rule

- **Source:** repo-wide search of `han-core/agents/test-engineer.md`, `han-core/agents/edge-case-explorer.md`, and
  `han-core/references/yagni-rule.md`
- **Finding:** Zero hits for mutation testing, kill set, discriminating power, assertion strength, or overdetermined
  assertions in any of the three files. The repo's only genuine mutation-testing reference sits in
  `docs/research/refactor-skill-research.md:186`, in a different skill's research artifact, and is marked single-source
  there under the evidence rule's corroboration gate.
- **Relevance:** Confirms the reporter's claim that the reasoning was outside the agents' repertoire, not merely
  unused.

### E11: readability-editor's only post-rewrite check is fact preservation

- **Source:** `han-communication/agents/readability-editor.md:136-143`
- **Finding:**
  ```
  ## How you work

  1. Read the readability rule and the draft. Identify the prose regions and the non-prose regions you must not touch.
  2. Rewrite the prose in place against the rubric. ...
  3. After rewriting, re-read your result against the original and confirm every fact survived. If you cannot confirm a
     fact survived, restore the original wording for that sentence.
  ```
- **Relevance:** Step 3 is the whole post-rewrite procedure. Its rubric criterion 5 governs the draft under audit; no
  step turns that criterion on the editor's own new sentences.

### E12: The canonical YAGNI rule is written for committed items generally

- **Source:** `han-core/references/yagni-rule.md:26-45` and `:56-57`
- **Finding:** Gate 1 lists "test" as one committed-item type alongside spec sections, ADRs, runbooks, and alerts. Its
  five evidence categories are user need, named dependency, production contract, regulation, and incident or metric.
  Gate 2's single test-specific line reads "One end-to-end test beats one end-to-end test plus three integration tests
  plus twelve unit tests, when the end-to-end test catches every realistic failure mode."
- **Relevance:** The rule supplies no test-assertion-specific reasoning, which is why the fix belongs in the two agents
  rather than in the rule. All five vendored copies are byte-identical to the canonical file, so leaving it untouched
  keeps the re-sync burden at zero.

### E13: automated-test-planning is absent from the sizing-aware skill list

- **Source:** `docs/sizing.md:6-10` and the at-a-glance table
- **Finding:** The registered sizing-aware skills are `/architectural-analysis`, `/code-overview`, `/code-review`,
  `/code-walkthrough`, `/design-an-api`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`,
  `/plan-implementation`, and `/research`. Neither test-planning skill appears.
- **Relevance:** The suite already treats sizing as the mechanism for this problem and has ten worked examples of it.

### E14: code-review's classifier is the size-band precedent

- **Source:** `han-coding/skills/code-review/SKILL.md:199-226` and `:336`
- **Finding:**
  ```
  **Default to small.** Start the classification at **small** and only escalate to medium or large when the signals below
  clearly require it. When a signal is borderline, stay at the smaller band.
  ```
  ```
  **Skip Steps 7.1–7.3 if no agents were dispatched in Step 3; Step 7.4 still runs whenever the review has produced at
  ```
- **Relevance:** Supplies both halves of the fix: an authoritative band resolved once, and a downstream skip driven by
  it.

### E15: iterative-plan-review's lightweight mode is the focused-mode precedent

- **Source:** `han-planning/skills/iterative-plan-review/SKILL.md:150-187`
- **Finding:**
  ```
  - **Small** _(default)_ — 2–3 files affected, single system, no cross-cutting concerns. Defaults to **lightweight mode**
    (no team review). Iteration cap: **1 round.**
  ```
  ```
  In **lightweight mode**, skip Step 3 and run the checklist-based iteration loop in Step 4 alone. In **team mode**,
  proceed to Step 3 to assemble a team and Step 5 to run team iterations.
  ```
- **Relevance:** A small band that skips an entire step and dispatches no team is precisely the missing middle path
  between a full pipeline and no output.

### E16: The suite's agent guidance already forbids what the skill does

- **Source:** `han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md:38-53`
- **Finding:**
  ```
  - **Do not delegate work the skill can finish in a handful of tool calls.** The dispatch overhead exceeds the work.
  ...
  - **Prefer one agent to several.** If a single agent can complete the track, dispatch one and keep spawn counts low.

  Where the policy needs to be deterministic rather than advisory, cap the count in the skill body instead of describing
  when delegation is appropriate.
  ```
- **Relevance:** The skill states no delegation policy and caps nothing. This is the standard the fix restores it to,
  and it makes the change a conformance repair rather than a new idea.

### E17: The em-dash rule the issue quotes was replaced six days after the issue was filed

- **Source:** commit `864d6af` (2026-07-30, "docs(han-communication): scope the em-dash rule to its two legal
  positions") against `756c5e3` (2026-07-21)
- **Finding:** At `756c5e3`, `writing-voice.md:102` read `- No em-dash, '—', anywhere, ever.` The current file at
  `han-communication/references/writing-voice.md:108-125` legalizes the em-dash in two positions: separating a label
  from its gloss, and setting off an appositive.
- **Relevance:** The issue is dated 2026-07-24, so its quote was accurate when filed and is stale now. A heading is
  neither legal position, so that instance would still be a violation today; the two sentence-internal instances may
  not be. The gap in E11 does not depend on which wording is in force.

### E18: One editor file serves every skill that dispatches it

- **Source:** `grep -rn "readability-editor" --include=SKILL.md .`
- **Finding:** Skills across `han-coding`, `han-communication`, `han-documentation`, `han-ddd`, `han-github`,
  `han-planning`, `han-reporting`, and `han-research` dispatch the agent, and no caller carries a copy of its
  definition.
- **Relevance:** The fix costs one file edit and no caller changes. Callers do not all keep a self-check, though; see
  (E19) and (E20).

### E19: Three planning skills forbid the post-editor self-check outright

- **Source:** `han-planning/skills/plan-a-feature/SKILL.md:414-417`,
  `han-planning/skills/plan-implementation/SKILL.md:405-408`,
  `han-planning/skills/plan-a-phased-build/SKILL.md:391-394`
- **Finding:**
  ```
  Then read the editor's fact-preservation report. **Do not walk the self-check over the text the editor
  produced.** The canonical readability rule says the dedicated editor replaces a skill's own readability pass rather than
  stacking a second one on top, and a same-model pass over the editor's own fresh output is the ungrounded kind of
  self-review that corrupts a correct answer about as often as it fixes a wrong one.
  ```
  The three files carry this language byte-identically. Each then reads only the editor's fact-preservation report, and
  runs the checklist as a fallback solely when no usable report comes back.
- **Relevance:** In these three skills nothing checks the editor's new sentences against the blocklist. The caller is
  told not to, and the editor does not (E11), so an editor-introduced voice violation reaches the reader. The report the
  caller does read covers fact preservation only, which is what the editor's "What you return" section promises. This
  raises the third finding above the repeated-manual-fix cost the reporter experienced.

### E20: The suite holds both positions on the post-editor self-check, with no reconciling note

- **Source:** `han-coding/skills/code-review/references/output-verification.md:80-94`,
  `han-coding/skills/automated-test-planning/SKILL.md:268-278`, `han-communication/skills/edit-for-readability/SKILL.md:125-136`
- **Finding:** `code-review` names the blocklist criterion explicitly in a self-check that runs after the editor's
  rewrite is applied, and `automated-test-planning` runs the standardized self-check over the rewritten plan. Meanwhile
  `edit-for-readability` runs no independent check at all, delivering the editor's own rubric verdict and
  fact-preservation ledger to the user as the result.
- **Relevance:** The same suite treats a post-editor self-check as a required safety net in some skills, as harmful
  same-model review in three others (E19), and as unnecessary in one. That disagreement is why the fix belongs inside
  the editor: a check the editor runs on itself is the only one that holds under all three positions, and it removes the
  duplicated work in the skills that currently repeat it.

## Validation Results

### Counter-Evidence Investigated

#### V1: The size argument needs a frontmatter key the fix did not name

- **Hypothesis:** Adding `argument-hint` alone is enough to make `$size` resolve.
- **Investigation:** Compared the frontmatter of every sizing-aware skill. Each carries a literal `arguments: size` key
  above its `argument-hint`, and `docs/sizing.md` states that every sizing-aware skill declares the positional argument
  in frontmatter.
- **Result:** Confirmed.
- **Impact:** Without that key there is no `$size` to bind and the whole resolution order has nothing to read. The
  change now adds `arguments: size` alongside the hint.

#### V2: Classifying from the resolved file list would misclassify the reported case

- **Hypothesis:** A classifier placed after Step 1 correctly sizes a narrow conversational question.
- **Investigation:** Read Step 1's Mode A branch. When the user names no scope, it falls back to the branch's entire
  changed-files list. A narrow question asked on a busy branch would inherit that list and classify medium or large.
- **Result:** Confirmed.
- **Impact:** This is the reported scenario, so the fix would have missed it. Step 1.5 now classifies from the user's
  request first and the file list only when the request settles nothing.

#### V3: Focused mode did not say whether Step 3's sweeps still run

- **Hypothesis:** Skipping the template is a formatting change with no loss of substantive filtering.
- **Investigation:** Read Step 3. Its behavioral, prerequisite, and YAGNI sweeps decide what may be recommended at all,
  and the prerequisite sweep is what keeps out tests requiring an out-of-scope production change.
- **Result:** Confirmed.
- **Impact:** Read literally, the fix could have shipped a focused answer recommending an unwritable test. Step 1.5 now
  states that Step 3 runs in full in both modes.

#### V4: No downstream consumer parses the nine-section template

- **Hypothesis:** Some skill or doc depends on the template's sections existing.
- **Investigation:** The only downstream chain is to `/tdd`, whose argument hint takes a spec or plan generically and
  which references no test-plan identifier or section name.
- **Result:** Refuted.
- **Impact:** None. Focused mode's format change carries no downstream blast radius.

#### V5: Neither agent can run tests, so the check is a prediction

- **Hypothesis:** The agents can check which existing tests fail under a hypothetical code change.
- **Investigation:** Both agents' tools are `Read, Glob, Grep, Bash(git *), Bash(find *), Write`. Neither has a test
  runner.
- **Result:** Confirmed.
- **Impact:** The wording overstated what the agents can do. Both now say the answer is a prediction from reading
  assertions, and require naming the test and the assertion it came from. The validator noted this is still more
  falsifiable than the coverage-location argument it replaces, because it names a specific behavioral distinction.

#### V6: Moving the voice check inside the editor relocates the same-model concern rather than removing it

- **Hypothesis:** Putting the check inside the agent dodges the objection three planning skills raise against a
  same-model pass over the editor's fresh output.
- **Investigation:** Read the canonical rule's application stages. Its "do not stack a second pass" language governs a
  skill adding its own pass on top of the editor, not the editor's internal procedure. The editor already runs a
  fact-preservation self-check on its own output.
- **Result:** Partially Refuted.
- **Impact:** The placement is defensible on the letter of the rule and consistent with the editor's existing
  self-check, but the epistemic concern is not eliminated by relocation. A guard was added: the pass corrects named
  violations only and changes nothing already compliant, so a legal appositive em-dash survives it. The residual risk
  is recorded below.

#### V7: The em-dash staleness claim holds

- **Hypothesis:** E17's commit dates, wording, and heading-violation conclusion are accurate.
- **Investigation:** Verified both commits and the before-and-after wording, and confirmed a Markdown heading is
  neither of the two legal positions.
- **Result:** Confirmed.
- **Impact:** None.

#### V8: The byte-identical claims hold

- **Hypothesis:** The three planning skills carry identical language, and the YAGNI rule is vendored into five
  byte-identical copies.
- **Investigation:** Compared the three passages word for word, and hashed all six copies of the rule.
- **Result:** Confirmed.
- **Impact:** None. Leaving the canonical rule untouched still costs no re-sync.

#### V9: The dispatch-site count was wrong

- **Hypothesis:** Fourteen skills dispatch the editor.
- **Investigation:** Counted genuine dispatchers, excluding the meta-skill that teaches the dispatch and the
  repo-maintenance skill that only inventories it.
- **Result:** Refuted.
- **Impact:** E18 no longer carries a count, which also brings it in line with the repo's count-free convention. The
  fix mechanism is unaffected.

#### V10: The manual-test-planning exclusion is defensible but was never argued

- **Hypothesis:** `manual-test-planning` shares the same shape and is excluded without reasoning.
- **Investigation:** It dispatches two agents unconditionally, not five to seven, and already declines to write a
  document when nothing is testable.
- **Result:** Partially Refuted.
- **Impact:** The severity gap makes the exclusion reasonable, but it remains a real half-fix: a trivial manual-test
  question still spins up two agents with no size gate. Recorded as a follow-up rather than silently dropped.

#### V11: Leaving the canonical YAGNI rule untouched is well-grounded

- **Hypothesis:** The exclusion is scope evasion.
- **Investigation:** Read both gates. They are written across ADRs, runbooks, specs, and tests, with one test-specific
  line and no assertion-strength vocabulary.
- **Result:** Confirmed.
- **Impact:** None. The reasoning belongs at the test-specific layer, and placing it there avoids a five-file re-sync.

### Adjustments Made

- Added `arguments: size` to the skill's frontmatter (V1).
- Step 1.5 classifies from the user's request first, and from the resolved file list only when the request settles
  nothing (V2).
- Step 1.5 states that Step 3's sweeps run in full in both modes (V3).
- Both agents now describe the discriminating-power answer as a prediction from reading assertions, and require naming
  the test and assertion it came from (V5).
- The editor's new pass corrects named violations only and leaves compliant wording alone (V6).
- E18 dropped its dispatch-site count (V9).
- The `manual-test-planning` exclusion is now stated with its reasoning (V10).

### Confidence Assessment

- **Confidence:** Medium-High. Every evidence citation resolved against the working tree. The four execution gaps the
  validator found were specific and have been corrected in the files themselves.
- **Remaining Risks:**
  - The editor's blocklist pass is unvalidated against false positives. The guard forbids editing compliant text, but
    nothing yet proves the pass leaves a legal appositive em-dash alone. Worth one worked example before relying on it.
  - `manual-test-planning` keeps an unconditional two-agent pipeline with no size gate. Deferred deliberately: the
    issue does not name it, and two dispatches is a materially smaller problem than five to seven.
  - The discriminating-power answer is a prediction, not an executed result. It is more falsifiable than the reasoning
    it replaces, but neither agent can run a test to confirm it.
  - Nobody has replayed the original session from the issue. The classification signals are reconstructed from the
    skill's own scope-resolution logic, not from the recorded run.

## Coding Standards Reference

| Standard                                                                                       | Source                                                                                     | Applies To                                       |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------ |
| Start at Level 0, prefer one agent, cap counts in the skill body, state the delegation policy   | `han-plugin-builder/.../agent-building-guidelines/multi-agent-economics.md`                 | The `automated-test-planning` size band          |
| Default to small, escalate only on a clear signal, resolve the band once as authoritative       | `han-coding/skills/code-review/SKILL.md:199-226`                                            | The new classification step                      |
| A small band may skip a whole step and dispatch no team                                         | `han-planning/skills/iterative-plan-review/SKILL.md:150-187`                                | Focused mode                                     |
| Size resolution order: explicit argument, then config `default-swarm-size`, then classification | `docs/sizing.md`, `docs/adr/0001-project-configurable-default-swarm-size.md`                | The new `$size` argument                         |
| Evidence-based YAGNI: deferrals carry the trigger that would justify revisiting                 | `han-core/references/yagni-rule.md`                                                         | The discriminating-power field on deferred items |
| Indexes stay complete, not counted                                                              | `CLAUDE.md`, Conventions                                                                    | Registering the skill in `docs/sizing.md`        |
| Every skill and agent keeps its long-form doc current                                           | `docs/templates/coverage-rule.md`                                                           | Doc updates accompanying each change             |
