# Investigation: tdd writes error characterization tests backwards (asserts the error is raised instead of the desired behavior)

Investigation report for [issue #74](https://github.com/testdouble/han/issues/74). Read the Summary, then approve the Planned Fix or push back.

## Summary

- **Root Cause:** The `tdd` skill has no concept of a bug-fix / regression / characterization case anywhere in its decision flow, so when its input is an existing defect the skill describes the behavior it currently observes — the error being raised — instead of the desired correct behavior that the fix will produce (E1, E2, E3, E8).
- **Fix:** Add explicit bug-fix framing at the three load-bearing points — the test-list step, the Red phase / observed-failure gate, and the failure-modes catalog — instructing the author to assert the *desired correct* behavior (red until the bug is fixed) and never the error the bug raises, plus a matching clarification in the BDD framing and the long-form doc.
- **Why Correct:** The strongest evidence is the negative grep (E8): zero occurrences of "characteriz", "regression", or correct-behavior framing across all four skill files, confirming the gap is structural rather than a phrasing slip — so the fix must add the missing distinction, not reword an existing one.
- **Validation Outcome:** Adversarial validation confirmed the root cause but refuted the fix's completeness on three counts — it missed that `tdd-loop.md` holds an independent copy of the gate diagnostic (V2), missed a second backwards-assertion path that passes the gate by failing for the wrong reason (V3), and under-scoped the conditional and the legitimate-exception case (V4, V6); the plan below incorporates all three.
- **Remaining Risks:** See Confidence Assessment under Validation Results (confidence is Medium, not High, pending the wording review the validator flagged).

## Problem Statement

- **Symptoms:** When `/tdd` is asked to build a test for an existing error or bug, it writes a test that asserts the code **raises** the error. That assertion passes while the bug is present, so fixing the code makes the test fail — the test locks the bug in and inverts the red-green cycle.
- **Expected behavior:** An error characterization / regression test should assert the **correct, desired** behavior. It then fails *for the expected reason* (the bug is still present), and fixing the code makes it pass.
- **Conditions:** The input to `/tdd` is an existing defect (a known bug, a reported error, a fix being driven back in after `/investigate`), rather than net-new behavior.
- **Impact:** Every bug fix driven through `/tdd` is at risk of shipping a backwards test that enshrines the defect and breaks the moment the code is corrected. This is the skill's core promise (real red-green-refactor) failing on one of the most common real-world entry points.

## Root Cause Analysis

### Root Cause

The `tdd` skill never recognizes "fix an existing bug" as a distinct input, so at every point where it decides *what to assert* it tells the author to describe an observable behavior without distinguishing the desired-but-absent behavior of a feature from the desired-but-currently-wrong behavior of a buggy code path — and the path of least resistance for a model is to assert what the code observably does today, which for a bug is "raises the error."

### Detailed Analysis

The skill processes every input through the same five steps with no branch for a defect (E1). Step 2 builds the test list as "the most important thing the system **does not yet do**" (E2) — framing that fits net-new features but misdescribes a bug, which is something the system *does wrong*, not something absent. With no instruction to phrase a bug item as "returns the correct result" (red until fixed), the natural phrasing mirrors the observed defect: "raises FooError."

The Red phase then says "assert an observable outcome / assert the observable result" (E3). For a feature, "observable outcome" maps to the desired output; for a bug it is ambiguous between the *current* observable output (the error) and the *desired* one. The BDD reference compounds this: "Then — the expected, observable outcome" (E6) reads equally as "what the code produces now" or "what it should produce," and the BDD failure-mode list never names asserting-the-current-buggy-behavior.

The observed-failure gate is the safety net that *should* catch this, and it half-fires. A test asserting `assertRaises(FooError)` against a live bug does go red the first time only if the error is *not* yet raised — but in the reported case the error is already raised, so the test passes on first run and the gate trips. The trip is then misdiagnosed: the gate offers exactly two explanations, "the test does not exercise the behavior" or "the behavior already exists," and instructs the author to cross the item off if the behavior already exists (E4). For a bug-assertion test, neither diagnosis is right and crossing the item off silently skips the regression test entirely. The failure-modes catalog, the skill's designated home for "ways an agent fakes TDD," has eight entries and none covers asserting the bug instead of the fix (E5). The negative grep across all four skill files plus the long-form doc confirms the concept is absent end to end (E8), and the one operator-facing mention of bugs — "once you have a fix in mind, you can drive it back in through `/tdd`" (E7) — routes the user straight into this gap with no warning about assertion direction.

## Planned Fix

### Approach

Add bug-fix / regression-test framing at the points where the skill decides what to assert and how to read a failure — instructing the author to assert the desired correct behavior (red because the bug is present, green when fixed) and never the error the bug raises — and name the inverse as an explicit failure mode.

### Changes

#### `han-coding/skills/tdd/SKILL.md`

- **Change:** (1) In **Step 1: Resolve Project Config and Confirm Scope**, add the input's nature to the scope report so the bug-fix case is recognized explicitly: name whether the work is net-new behavior or a fix to existing broken behavior. Phrase the trigger on observable signals, not just the word "bug" — "an existing failing or broken behavior," "a fix being driven back in after `/investigate`," or "the code already exhibits the error" — so the guidance fires even when the user says "make it stop throwing the divide-by-zero" without the word "bug" (addresses V4). (2) In **Step 2: Build the BDD Test List**, add a short paragraph: when the work fixes existing broken behavior, the list item names the *desired correct* behavior, not the current broken one ("returns the rounded total for a refund," red until the bug is fixed). The regression test asserts what the code *should* do; it goes red because the bug is present and green when the fix lands. State the boundary explicitly so it does not over-fire: asserting that the code raises is correct when raising **is** the specified desired behavior (raise-on-invalid-input); it is wrong only when the raised error **is the bug being fixed** (addresses V6). (3) In the **Red** phase, make the assertion-direction a check applied before the test is run, not only an after-the-fact diagnostic: for a fix to broken behavior, confirm the assertion targets the desired correct result, so the red you observe is "correct behavior not yet produced," not "error successfully raised" — this covers the path where a backwards assertion goes red for the wrong reason and would otherwise satisfy the gate (addresses V3). (4) In the first-run-pass diagnostic (lines 163-166), add a third branch: if the work fixes broken behavior and the test passed on first run, the test is likely asserting the current broken behavior (locking the bug in) — rewrite it to assert the desired correct behavior rather than crossing the item off.
- **Evidence:** (E1), (E2), (E3), (E4), (E8)
- **Standards:** han writing voice (docs/writing-voice.md — no em-dashes, direct second person); progressive disclosure (SKILL.md stays lean, depth lives in references) per the skill-building guidance; YAGNI — add only the bug-fix distinction the evidence demands, no broader rework.
- **Details:** Additive edits only; no existing step is removed or reordered. Keep the Step 1 and Step 2 additions short and push the worked rationale into failure-modes.md. The Red-phase and gate edits are one or two sentences each, woven into the existing prose so the change reads like the surrounding text.

#### `han-coding/skills/tdd/references/tdd-loop.md`

- **Change:** Update the observed-failure gate's diagnosis sentence (lines 65-72) so it no longer contradicts the patched SKILL.md. It currently reads "Diagnose it: the test does not exercise the behavior, or the behavior already exists" — add the third branch (the test asserts the current broken behavior instead of the desired correct one), or replace the two-branch enumeration with a pointer that defers the diagnosis to SKILL.md Step 3.
- **Evidence:** (E4), (V2)
- **Standards:** han writing voice; this file is the canonical gate reference (`SKILL.md:36` directs agents to pull it), so it must stay consistent with the SKILL.md change rather than carrying a stale two-branch copy.
- **Details:** This file was missed in the first draft of the plan; the validator (V2) caught that an agent following the Constraints-section pointer to `tdd-loop.md` would get the unpatched diagnostic and bypass the fix. Keep the edit minimal — one sentence, matching whichever phrasing lands in SKILL.md so the two do not drift again.

#### `han-coding/skills/tdd/references/failure-modes.md`

- **Change:** Add a new failure mode (a ninth entry) — "Asserting the bug instead of the fix" — with the same Symptom / Why it happens / Discipline shape as the existing eight. Symptom: for a fix to broken behavior the test asserts the error is raised (or the wrong value is returned) and passes on first run, or goes red for a reason other than "correct behavior not produced." Why: the model describes the behavior it observes now. Discipline: a regression test asserts the *desired correct* behavior, fails because the bug is present, and passes when the fix lands; a bug-fix test that is green before the fix is the tell. Include the boundary explicitly so the mode does not chill legitimate tests: asserting that the code raises is the *right* test when raising is the specified desired behavior — the failure mode is asserting the error that **is** the bug (addresses V6).
- **Evidence:** (E5), (E8), (V6)
- **Standards:** Match the existing eight-entry Symptom/Why/Discipline format and voice; the Constraints section of SKILL.md already points here ("the specific ways an agent fakes TDD ... are in references/failure-modes.md"), so no new pointer is needed.
- **Details:** Append it after the existing modes as mode 9. Verified safe (V7): a repo-wide grep found no file that references the failure modes by ordinal number, so appending does not break any cross-reference. Keep the new mode parallel in length to its siblings.

#### `han-coding/skills/tdd/references/bdd-framing.md`

- **Change:** (1) Sharpen the "Then" clause definition (lines 34-37) to say the expected outcome is the behavior the code *should* produce, which for a bug fix is not what it produces today; note that a raised exception is a valid observable output to assert when raising is the desired behavior. (2) Add one bullet to the "BDD-flavored failure modes" list (lines 93-105): asserting the current buggy behavior in the Then (e.g., asserting the error the bug raises) instead of the desired correct outcome — scoped so it does not read as a ban on legitimate raise-on-invalid-input assertions (addresses V6).
- **Evidence:** (E6), (E8)
- **Standards:** han writing voice; keep the bullet parallel to the existing five failure-mode bullets.
- **Details:** Small, surgical edits; do not restructure the Given-When-Then section.

#### `docs/skills/han-coding/tdd.md`

- **Change:** Where the long-form doc says "once you have a fix in mind, you can drive it back in through `/tdd`" (E7, line 34), add a sentence noting that the regression test asserts the desired correct behavior (red until the fix lands), not that the bug's error is raised.
- **Evidence:** (E7), (E8)
- **Standards:** docs/writing-voice.md; CLAUDE.md convention that the long-form doc is canonical operator-facing source and must stay current with the skill. Consider running `/han-update-documentation` on this branch to confirm no other doc cross-reference drifted.
- **Details:** One sentence in the existing bullet (line 34, not the 33-35 range cited in the first draft); no new section.

## Evidence Summary

### E1: No input-classification step — "bug fix" vs "net-new feature" is not a recognized distinction anywhere in the skill

- **Source:** `han-coding/skills/tdd/SKILL.md:62-248` (all five steps)
- **Finding:**
  ```
  ## Step 1: Resolve Project Config and Confirm Scope
  ## Step 2: Build the BDD Test List
  ## Step 3: The Red-Green-Refactor Loop
  ## Step 4: Close the Outer Loop
  ## Step 5: Final Verification and Summary
  ```
- **Relevance:** No step contains a branch or classification for the nature of the input. "bug" appears once in the file, in the frontmatter description at line 13 ("find the root cause of a bug (use investigate)"); the only other related word is "defect" at line 209 ("a refactor that changes behavior is a defect"), which means a bad refactor, not an input type. Feature, behavior sentence, spec, and bug description all flow through identical handling, so a bug fix never forks onto a regression-test path. (Precision note per V5: neither occurrence classifies the input; the structural finding stands.)

### E2: Step 2 frames the test list as behaviors the system does not yet do

- **Source:** `han-coding/skills/tdd/SKILL.md:109-130`
- **Finding:**
  ```
  Turn the requested feature or behavior into a test list ... Each item is one
  observable behavior ...
  Order the list outside-in by user value: the next item is the most important
  thing the system does not yet do.
  ```
- **Relevance:** "The most important thing the system does not yet do" fits net-new features. A bug is something the system *does wrong*, not something absent. The framing gives no guidance on phrasing a bug item as "returns the correct value" (red until fixed) versus "raises the error" (current broken behavior).

### E3: The Red phase says "assert an observable outcome" without distinguishing desired-outcome-with-bug-present from error-assertion

- **Source:** `han-coding/skills/tdd/SKILL.md:149-155`
- **Finding:**
  ```
  Write exactly one test for the chosen behavior. ... Assert an observable
  outcome through the public interface (Given = arrange the state before; When =
  the one action under test; Then = assert the observable result).
  ```
- **Relevance:** For a feature, "observable result" maps to the desired output. For a bug it is ambiguous between the current observable output (the error) and the desired one. The instruction does not resolve the ambiguity, so the obvious test-first reading — assert what happens now — produces "assert the error is raised."

### E4: The observed-failure gate never defines the "intended reason" for a bug case, and its first-run-pass diagnostic offers only two branches, neither catching the assert-the-bug trap

- **Source:** `han-coding/skills/tdd/SKILL.md:163-166`; `han-coding/skills/tdd/references/tdd-loop.md:65-72`
- **Finding:**
  ```
  If the test passes on its first run, the observed-failure gate has tripped.
  Stop. Diagnose: the test is not exercising the behavior, or the behavior
  already exists. If the behavior already exists, cross the item off and pick the
  next one. Do not write production code off an unobserved red.
  ```
  ```
  ... no production-code change is permitted unless a test has been run and
  observed to fail for the intended reason in this loop. ... Diagnose it: the
  test does not exercise the behavior, or the behavior already exists.
  ```
- **Relevance:** A test asserting `assertRaises(FooError)` against a live bug passes on first run, tripping the gate — but neither offered diagnosis fits: the test *does* exercise the behavior and the error *does* already exist, so the author is told to cross the item off, silently skipping the regression test. The gate checks *whether* a test failed, never the *direction* of the assertion.

### E5: failure-modes.md catalogs eight modes, none covering "assert the bug instead of the fix"

- **Source:** `han-coding/skills/tdd/references/failure-modes.md:1-126`
- **Finding:** The eight modes: (1) writing test and code together, (2) never seeing red, (3) whole-feature steps, (4) skipping refactor, (5) asserting on implementation detail, (6) applying standards while going green, (7) keeping no test list, (8) refactoring into speculative abstraction.
- **Relevance:** The anti-pattern at the center of #74 — writing a test that asserts the erroneous behavior so it passes immediately and locks in the bug — is absent. Mode 5 is the nearest but is about over-mocking and coupling, not about asserting the wrong value. This file is the designated home for TDD-faking failure modes, so the gap is clean.

### E6: bdd-framing.md "Then" is ambiguous and its BDD failure-mode list omits asserting the buggy behavior

- **Source:** `han-coding/skills/tdd/references/bdd-framing.md:34-37, 93-105`
- **Finding:**
  ```
  - **Then** — the expected, observable outcome. The assert. It must be on an
    observable output ...
  ```
  (and the five-bullet "BDD-flavored failure modes" list, none of which is "asserting the current buggy behavior")
- **Relevance:** "Expected" reads equally as "what the code produces now" or "what it should produce after the fix." An agent following the rule literally can write `assertRaises(SomeError)` and satisfy "the assert must be on an observable output." No failure-mode bullet warns against it.

### E7: The long-form doc routes bug fixes back through /tdd with no assertion-direction guidance

- **Source:** `docs/skills/han-coding/tdd.md:33-35`
- **Finding:**
  ```
  - **Finding the root cause of a bug.** Use [`/investigate`](...). Once you
    have a fix in mind, you can drive it back in through `/tdd`.
  ```
- **Relevance:** The only operator-facing mention of bugs sends the user straight into the gap: "drive it back in through `/tdd`" implies normal invocation, but the skill has no mode or instruction for "assert the desired correct behavior that currently fails because the bug is present."

### E8: Negative evidence — no "characterization", "regression", or correct-behavior framing anywhere in the skill tree

- **Source:** `han-coding/skills/tdd/SKILL.md`, `references/tdd-loop.md`, `references/bdd-framing.md`, `references/failure-modes.md`, `docs/skills/han-coding/tdd.md`
- **Finding:** A grep for `characteriz`, `regression`, `golden master`, `approval test`, `correct.*behavior`, and `desired.*behavior` returns zero hits across all five files. The only "bug" hits are the "use investigate" pointers.
- **Relevance:** The complete absence confirms the gap is structural, not a phrasing edge case. Every point a bug-fix case would need handling — description, scope step, test-list framing, Red-phase assertion guidance, the gate's "intended reason," and the failure-modes catalog — is silent.

## Validation Results

### Counter-Evidence Investigated

A dedicated adversarial validation pass (`han-core:adversarial-validator`) re-read every load-bearing file and verified each evidence claim. It confirmed the root cause but refuted the fix's completeness on three counts; all three are now folded into the Planned Fix.

#### V1: Does the observed-failure gate already catch the assert-the-bug test, making the fix unnecessary?

- **Hypothesis:** The existing gate ("a test that passes on first run is a stop-and-diagnose signal") already stops the backwards test, so no new guidance is needed.
- **Investigation:** Re-read `SKILL.md:31-37, 163-166` and `tdd-loop.md:65-72`. Traced what happens when `assertRaises(FooError)` is written against a bug that already raises `FooError`.
- **Result:** Confirmed (the gap is real).
- **Impact:** The gate *does* trip, but its two diagnoses ("test does not exercise the behavior" / "behavior already exists") both tell the author to cross the item off and move on — it detects the symptom and prescribes the wrong remedy. The first-run-pass diagnostic (E4) is the highest-leverage insertion point. Supports the fix.

#### V2: Does the fix miss a file that carries the same gate diagnostic?

- **Hypothesis:** Patching only `SKILL.md:163-166` leaves another copy of the two-branch diagnosis intact.
- **Investigation:** Read `tdd-loop.md:65-72` directly and searched the plan for every planned-change file. `tdd-loop.md` was cited only as evidence (E4), never as a change target, yet it independently states "Diagnose it: the test does not exercise the behavior, or the behavior already exists," and `SKILL.md:36` explicitly directs agents to pull `tdd-loop.md` for the canonical gate statement.
- **Result:** Refuted (gap found).
- **Impact:** After the fix, the canonical gate reference would contradict the patched SKILL.md, and an agent following the pointer would get the unpatched two-branch version. **`tdd-loop.md` added to the Planned Fix as a fifth changed file.**

#### V3: Is the first-run-pass path the only way a backwards assertion slips through?

- **Hypothesis:** A backwards assertion always passes on first run, so the first-run-pass diagnostic covers it fully.
- **Investigation:** Traced a second path: a test asserting `assertRaises(FooError)` at a call site where `FooError` is not yet raised fails on first run (wrong reason), satisfies the gate, and then re-fails when the fix removes the error — never a true regression test.
- **Result:** Refuted (incomplete fix scope).
- **Impact:** The Red-phase guidance must be a check applied *before the test is run* (does the assertion target the desired correct result?), not only an after-the-fact first-run-pass diagnostic. **Planned Fix item #3 for SKILL.md strengthened accordingly.**

#### V4: Does the conditional guidance fire without an input-classification step?

- **Hypothesis:** Guidance conditioned on "when the input is a bug" relies on the model self-classifying, with no step that names the input type.
- **Investigation:** Read `SKILL.md:62-106` (Step 1). The scope report says "the behavior or feature to be built" with no classification branch; the only structural mention of bugs routes the user away to `/investigate`.
- **Result:** Partially Refuted.
- **Impact:** The fix should name the input's nature in the Step 1 scope report and phrase the trigger on observable signals (existing broken behavior, a fix being driven back in, code already exhibiting the error), not just the word "bug." **Planned Fix item #1 for SKILL.md added.**

#### V5: Is E1's "bug appears once" claim accurate?

- **Hypothesis:** The evidence overcounts or miscites.
- **Investigation:** Grepped `bug|defect|regression` in `SKILL.md`: line 13 ("bug", frontmatter) and line 209 ("defect", meaning a bad refactor).
- **Result:** Confirmed (with a precision note).
- **Impact:** Neither occurrence classifies the input; the root cause stands. E1 amended for precision.

#### V6: Would the fix wording wrongly forbid legitimate exception-asserting tests?

- **Hypothesis:** "Never assert the error is raised" could ban `assertRaises(ValueError)` for a feature whose specified behavior is to raise on bad input — and an exception is itself a valid observable output (`bdd-framing.md:34-36`).
- **Investigation:** Read the first-draft fix text and `bdd-framing.md:34-36`. The "never raises ArgumentError" example, read in isolation, could generalize into a blanket prohibition.
- **Result:** Partially Refuted.
- **Impact:** The Step 2 text, the new failure mode, and the bdd-framing edits must explicitly affirm that asserting a raise is correct when raising is the *specified desired* behavior; the failure mode is only asserting the error that **is** the bug. **All three fix entries re-scoped.**

#### V7: Does appending a ninth failure mode break a numbered cross-reference?

- **Hypothesis:** Some doc references failure modes 1-8 by number, so appending or reordering would break it.
- **Investigation:** Repo-wide grep for `mode [0-9]` / `failure mode #` / `failure mode [0-9]` excluding `.git/`. Zero hits; cross-references use heading text, not ordinals.
- **Result:** Confirmed (safe to append).
- **Impact:** Appending mode 9 breaks nothing. Recorded in the failure-modes.md fix entry.

#### V8: Did the first draft's self-validation show confirmation bias?

- **Hypothesis:** The first draft's internal validation produced only supportive findings.
- **Investigation:** The validator noted the first-draft validation missed the `tdd-loop.md` omission (V2), the second backwards-assertion path (V3), and the wording precision gap (V6), and rated confidence "High."
- **Result:** Partially Refuted.
- **Impact:** Confidence lowered from High to Medium; the three missed issues are now incorporated.

### Adjustments Made

- **Added `tdd-loop.md:65-72` as a fifth changed file** — triggered by V2; it carries an independent, canonical copy of the gate diagnostic that would otherwise contradict the patched SKILL.md.
- **Strengthened the Red-phase change to a pre-run assertion-direction check** (SKILL.md item #3) — triggered by V3; covers the backwards-assertion path that goes red for the wrong reason.
- **Added a Step 1 scope-report change naming the input's nature, triggered on observable signals not just the word "bug"** (SKILL.md item #1) — triggered by V4.
- **Re-scoped the Step 2 text, the new failure mode, and the bdd-framing edits to affirm legitimate raise-on-invalid-input tests** — triggered by V6.
- **Amended E1 for precision** ("defect" at line 209; "bug" at line 13) — triggered by V5.
- **Confirmed (and recorded) that appending failure mode 9 breaks no cross-reference** — triggered by V7.
- **Corrected the E7 citation** from lines 33-35 to line 34.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:**
  - **`tdd-loop.md` consistency.** The fix now changes both `SKILL.md` and `tdd-loop.md`; the two gate statements must land with matching phrasing so they do not drift again. Review them together before shipping.
  - **Backwards assertion that passes the gate (V3).** Coverage for the wrong-reason-red path rests on the strengthened Red-phase check firing at generation time; it is guidance, not a mechanical gate.
  - **Conditional precision (V6).** Final wording review must confirm a reader following only the new failure mode would not conclude that `pytest.raises(ValueError)` for an invalid-input feature is forbidden.
  - **Effectiveness is unverifiable from the files alone.** All changes are guidance-only; their effect depends on model attention at generation time and cannot be confirmed without exercising `/tdd` against a real bug after the change.

## Coding Standards Reference

| Standard | Source | Applies To |
|----------|--------|------------|
| han writing voice (no em-dashes, direct second person, plainspoken, no hype) | `docs/writing-voice.md` | All four edited files |
| Progressive disclosure — SKILL.md stays lean, depth lives in references | `han-plugin-builder/skills/guidance/references/skill-building-guidance/` | The split between the SKILL.md edits and the failure-modes.md / bdd-framing.md edits |
| YAGNI / evidence rule for docs — add only what evidence demands | `CLAUDE.md` (Conventions), `docs/yagni.md` | Scope of every edit; no speculative sections |
| Long-form doc is canonical operator-facing source and stays current with the skill | `CLAUDE.md` (Conventions) | `docs/skills/han-coding/tdd.md` |
