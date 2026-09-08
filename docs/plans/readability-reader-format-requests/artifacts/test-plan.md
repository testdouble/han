# Test Plan: Verifying the reader-format-requests readability feature

## Scope

Analyzed `feature-specification.md` (Outcome, Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes),
`.discovery-notes.md` (both sections), `decision-log.md` (D6 in full, headings of the rest), and the repo's existing
Bats/script pairs for testing conventions. Branch: `gh-177-han-readability-output-style-fixes`. No code entry points
exist for this feature — every touch point is prose in a reference file, an output style, or a `SKILL.md`.

## Summary

Twenty-five files carry stale text with no automated guard on any of it today (`.discovery-notes.md` confirms all
seven existing Bats files test shell scripts, none of them these files). Verification splits into a deterministic
half (did the sweep land completely and only where it should) and an unverifiable half (does an AI assistant actually
honor a stated shape) — the second has no code entry point, so this plan recommends a one-time manual scenario check
in place of an automated test, and recommends against a checked-in sweep-verification script as machinery this
one-time change does not need.

| Priority | Count |
|----------|-------|
| High     | 3     |
| Medium   | 1     |
| Low      | 0     |
| Skipped  | 2     |

Full analysis written to: /Users/riverbailey/dev/testdouble/han/docs/plans/readability-reader-format-requests/artifacts/test-plan.md

## Coverage Assessment

No automated test today touches the readability rule's text, the output style's text, or the 23 skill/doc files that
quote them (`.discovery-notes.md#no-automated-test-covers-what-this-change-edits`). The repository's Unit/Integration/
End-to-end vocabulary does not map cleanly onto a prose standard, so this plan uses two levels instead: **structural
check** (deterministic — diff or literal-string search, run once against the finished branch) and **manual review**
(a person or agent reads a passage or a transcript and judges it against the spec). Both are one-time verification
steps for this change, not regression tests, because nothing in this repo re-runs them on a schedule and no existing
script pattern fits a one-off text migration (see S1).

## Findings

**T1: The two canonical files carry the new criterion, the narrowed exceptions, and the count-free wording**
- **Priority:** High
- **Test level:** Manual review
- **Entry point:** `han-communication/references/readability-rule.md:97-132` (Fidelity wins, the escape clause, the
  standardized self-check) and `han-communication/output-styles/han-readability.md:11,71-97` (the distilled copies),
  per `.discovery-notes.md#touch-points`
- **Gap type:** Untested
- **Test approach:**
  - **Behavior:** Both files state the shape check as a numbered criterion (not a governing principle, per
    [D3](decision-log.md#d3-the-shape-check-is-a-numbered-criterion-not-a-governing-principle)), state that a reader's
    request outranks the banned-word list and the fidelity guarantee
    ([D2](decision-log.md#d2-an-explicit-reader-request-outranks-every-other-criterion)), and preserve exactly two
    exceptions: a fact whose loss changes what the reader does next
    ([D11](decision-log.md#d11-a-fact-stays-when-losing-it-would-change-what-the-reader-does-next)) and a skill's
    required sections. Neither file names a count or a criterion position anymore
    ([D6](decision-log.md#d6-references-to-the-checks-size-stop-naming-a-number)).
  - **Stubs:** None — direct text read.
  - **Input/Action:** Read the four passages in each file side by side against D2, D3, D4, D6, D11, D14.
  - **Expected output:** Each passage is individually correct; the rule and the style do not need to match word for
    word (D6's own record shows the style already phrases its escape clause differently from the rule's), only to
    each state the same rule correctly.
  - **Expected commands:** None — no collaborator, no side effect.
- **Brittleness assessment:** A single read-through of two files with no ongoing assertion; nothing to regress since
  this is the source of truth every other surface quotes.

**T2: The 25 quoting surfaces lose the stale count, positional reference, and fidelity guarantee — and nothing else changes**
- **Priority:** High
- **Test level:** Structural check (literal-string search) plus manual triage of anything the search surfaces outside
  the enumerated set
- **Entry point:** `.discovery-notes.md#the-count-is-echoed-on-25-more-surfaces` and `#touch-points` (21 `SKILL.md`
  files, `docs/readability.md:105`, `han-communication/docs/output-styles/han-readability.md:72`,
  `han-communication/references/explanation-rule.md:17`, and the 6 files naming "criterion 6")
- **Gap type:** Untested
- **Test approach:**
  - **Behavior:** Every file in the enumerated set stops naming a count ("six-point self-check", "six criteria",
    "six-point checklist"), stops naming the fidelity guard by position ("criterion 6"), and stops restating the
    fidelity guarantee as unconditional. The exact restated sentence is recorded in
    [D6](decision-log.md#d6-references-to-the-checks-size-stop-naming-a-number): "the standard governs how the
    content is said, never whether a required fact appears."
  - **Stubs:** None.
  - **Input/Action:** After the edits land, re-run the same literal searches the discovery notes used (`six-point`,
    `six criteria`, `criterion 6`, and the exact fidelity sentence above) against the branch.
  - **Expected output:** Zero hits inside the enumerated 25-file set. Any hit outside that set needs a person to
    classify it before deciding whether it's in scope, per the concrete case below.
  - **Expected commands:** None.
- **Brittleness assessment:** A loose substring search produces false positives. I ran a broader search
  (`whether a required fact appears`, without requiring the full sentence) against the current tree and it matched
  `han-communication/skills/readability-guidance/SKILL.md:73-74`: "The frame governs how a fact is said, never
  whether a required fact appears." That sentence is about the audience frame, not the fidelity criterion — a
  different claim that D6's own accounting correctly excludes from its 18-file fidelity-restatement list — and it
  should stay unchanged. This is the concrete reason a pass/fail assertion on this text is unsafe without a person
  (or the existing `han-update-documentation` skill, run in branch mode, which already scopes itself to what the
  branch touched) applying judgment against the enumerated inventory rather than trusting a substring match alone.

**T3: The sweep leaves the readability editor's own rubric untouched**
- **Priority:** Medium
- **Test level:** Structural check (diff)
- **Entry point:** `han-communication/agents/readability-editor.md:26,27,44,95,142` and
  `han-communication/docs/agents/readability-editor.md:21,72`, per `.discovery-notes.md#the-editor-agent-runs-a-different-six`
  and `#touch-points` ("Left alone deliberately")
- **Gap type:** Untested
- **Test approach:**
  - **Behavior:** The editor's rubric is a different six-item list from the standard's self-check and is explicitly
    out of scope ([D7](decision-log.md#d7-the-readability-editors-rubric-is-left-unchanged)). Its four positional
    mentions of "criterion 5" and its own rubric-size line stay exactly as they are.
  - **Stubs:** None.
  - **Input/Action:** `git diff main -- han-communication/agents/readability-editor.md han-communication/docs/agents/readability-editor.md`
  - **Expected output:** Empty diff.
  - **Expected commands:** None.
- **Brittleness assessment:** Deterministic, single command, no false-positive risk.

**T4: A reader's stated shape is honored, and a dropped fact respects the floor**
- **Priority:** High
- **Test level:** Manual review (a live session, read by a person) — there is no automatable level for this behavior
- **Entry point:** `feature-specification.md#primary-flow` (steps 1-6), `#alternate-flows-and-states` (both
  subsections), `#edge-cases-and-failure-modes` (rows 1, 3, 4)
- **Gap type:** Untested, and not testable in the code sense — there is no function to call. The behavior is an AI
  assistant's compliance with prose it reads at draft time, not a return value.
- **Test approach:**
  - **Behavior:** Three scenarios drawn directly from the spec, each run once in a live session and read by a person
    against the spec's stated rule: (1) state a small count ("three simple sentences") and confirm the count and
    format land on the first draft (Primary Flow steps 3-6); (2) ask for less than a source carries in a
    conversational answer and confirm a fact drops with no note, then reappears in full when asked what was left out
    (Alternate Flow "The reader asks for less"; Edge Cases row 3); (3) state a register request that collides with
    the banned-word list and confirm the banned word is used only where the collision is real (Alternate Flow "The
    stated shape collides with another rule"; Edge Cases row 4).
  - **Stubs:** None — a real session, not a mock.
  - **Input/Action:** Run each scenario once before merge; read the transcript.
  - **Expected output:** Qualitative agreement between the transcript and the spec's stated behavior. No numeric
    pass/fail.
  - **Expected commands:** None.
- **Brittleness assessment:** This is the one gap this plan cannot close with a repeatable test. Model output is
  non-deterministic, and the readability area is among the most-edited in the repo over 90 days
  (`.discovery-notes.md#recent-churn`: 12, 10, 7, 6, 5, and 4 commits across six related files), so a recorded
  transcript would be a brittle snapshot test the moment unrelated wording changes. What the team gets instead of an
  automated regression suite is the same signal that produced the evidence for this feature in the first place
  ([D1](decision-log.md#d1-the-standard-gains-a-check-for-the-shape-the-reader-asked-for)): a real session, read by a
  person, is the durable feedback loop for prose-governed behavior — there is no code path to intercept.

## Deferred / Skipped Tests

**S1: A checked-in Bats script asserting zero stale-count/positional/fidelity-restatement matches**
- **Entry point:** The 25-file sweep set in T2; compare against the shape of existing scripts, e.g.
  `han-planning/skills/iterative-plan-review/scripts/check-cross-references.sh` (with
  `check-cross-references.bats` beside it)
- **Reason:** Every Bats-tested script currently in this repo backs a script a skill invokes at runtime —
  `check-cross-references.sh` runs every time `iterative-plan-review` executes, `detect-test-context.sh` runs every
  time `automated-test-planning` executes, and so on. Each is a recurring operational contract. This sweep is a
  one-time text migration with nothing invoking it at runtime, so there's no operational contract to regression-test.
  The evidence test (gate 1) finds no user-described need, no dependent item, and no production contract that breaks
  without it. Gate 2's simpler version — the ad hoc literal-string search in T2, run once during review — satisfies
  the same verification need, and T2 already demonstrates why a blind pass/fail assertion would misfire (the
  `readability-guidance/SKILL.md` near-miss). A checked-in script would need the same human judgment layered on top
  anyway, at which point it's not saving the review step, only adding a file to maintain.
- **Reopen when:** A second PR reintroduces a numbered count or positional reference to the self-check after this one
  lands. `.discovery-notes.md#a-prior-decision-already-rejected-a-seventh-criterion` records this exact drift
  happening once already (the `orwell-six-rules` plan's D-4, which chose not to add a criterion rather than build
  tooling to catch the resulting staleness). A second real occurrence, not a hypothetical one, is the trigger for a
  lint check or prek hook.

**S2: An automated golden-transcript or snapshot test asserting a live session honors a stated shape**
- **Entry point:** `feature-specification.md#primary-flow`, `#alternate-flows-and-states` (same behavior as T4)
- **Reason:** No code entry point exists to call — the behavior is realized by an LLM reading prose at inference
  time, non-deterministically. `.discovery-notes.md` confirms all seven existing Bats files test shell scripts; none
  runs a model session. A snapshot of a transcript would be a Brittle Snapshot Default against one of the
  highest-churn areas of the repo (`.discovery-notes.md#recent-churn`), breaking on unrelated wording edits rather
  than on the behavior actually regressing.
- **Reopen when:** The project adopts a model-behavior eval harness (a different kind of tool than Bats) as a
  deliberate investment — no evidence that one exists or is planned today.

## Coverage Estimate

After T1-T4, the sweep's completeness and boundaries are verified by deterministic checks (T1-T3) plus one
judgment-dependent search (T2), and the feature's core behavior gets one manual, spec-anchored smoke pass (T4) before
merge. What remains permanently unverified by automation is exactly the part with no code entry point: whether every
future session, indefinitely, keeps honoring a stated shape. That gap is intentional, not deferred — S2 names the
tool that would close it and the evidence this repo does not have yet. The 25-file sweep itself gets no standing
regression guard (S1), on the same reasoning: the tool this repo already uses for scoped, judgment-applying doc
consistency checks (`han-update-documentation`, run in branch mode) exists and costs nothing new to reach for if the
team wants a second pass beyond T2.
