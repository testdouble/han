# Investigation: gap-analysis skill — friction surfaced by feedback issue #34

Four "what didn't work" items in [issue #34](https://github.com/testdouble/han/issues/34) trace to four specific places where the `gap-analysis` skill pushes responsibility onto the brief, the analyzer, or a fixed report shape instead of owning it at the synthesis layer; this plan fixes each at its source.

## Problem Statement

- **Symptoms.** Issue #34 is structured feedback from a real `han:gap-analysis` run (the `proposal-roi` skill compared against a `proposals/CLAUDE.md` spec, 13 gaps). The run worked well on analysis quality (5/5, zero false positives), but four frictions were called out under "What didn't work":
  1. **V7 spec-provenance noise.** The validator flagged that the desired-state spec was an uncommitted, same-session artifact and that the analysis was therefore "circular." Technically correct, but this is *always* true when you run a gap analysis against a spec you just wrote — a common, legitimate use case. Surfacing it as a high-confidence validator finding made a workflow reminder feel like a problem.
  2. **Second-round ceremony.** Trigger A (≥ 3 proposed new gaps) fired, so the protocol-required second `gap-analyzer` round ran. It only re-confirmed what the swarm had already described thoroughly. At this gap count and specificity, the second round was ceremony.
  3. **Actor sweep depended on brief quality.** The two actors that produced the highest-value gaps (interactive Mike in full-discovery mode vs. the swag batch runner) were not obvious from the skill file alone. The operator had to name them explicitly in the brief. The skill did not discover the actors itself, so G-011/G-012 quality was a function of brief quality.
  4. **No "top N that block the goal" shortcut.** 13 gaps is a long document. There is no way to ask for "the top 5 that block the redesign" — the output format has no purpose-conditioned prioritized view.
- **Expected behavior.** Workflow reminders read as reminders, not high-confidence gap contradictions. The second analyzer round runs only when it would add information. The skill seeds the actor sweep from the desired-state artifact so quality does not depend on brief wording. The report offers a short, purpose-conditioned "blocking subset" when the operator stated why they are comparing.
- **Conditions.** Surfaces on any medium/large gap-analysis run, most sharply when (a) the desired-state spec is a same-session operator artifact, (b) the swarm proposes ≥ 3 well-specified new gaps, (c) the artifacts imply more than one actor or mode, and (d) the operator stated a purpose for the comparison.
- **Impact.** Signal-to-noise of the validation section (rated 3/5 in the issue), wasted wall-clock on a non-additive second round, brief-quality dependence for the single highest-value part of the analysis, and output-length friction (rated 3/5). None of these are correctness bugs; all are friction that lowers the skill's usefulness as a redesign brief.

## Evidence Summary

### E1: The validator brief gives no class for provenance / same-session-artifact observations

- **Source:** `han.core/skills/gap-analysis/SKILL.md` (Step 5, Validator brief) and `han.core/agents/adversarial-validator.md` (Validation Strategy 4)
- **Finding:**
  ```
  # SKILL.md Step 5 — Validator brief:
  - **Validator** (`adversarial-validator`) — "For each gap below, attempt to
    disprove it. Cite counter-evidence. Return a per-gap verdict: `confirmed`,
    `contradicted`, or `inconclusive`, with reasoning."

  # adversarial-validator.md — Strategy 4 (always applies to gathered evidence):
  - Probe source provenance and recency: is a source stale, astroturfed, an
    interested party, or implausibly convenient for the conclusion
  ```
- **Relevance:** Strategy 4 is correct and generic — the validator is *supposed* to question provenance. The friction is that the gap-analysis skill gives the validator only three verdicts (`confirmed` / `contradicted` / `inconclusive`), all of which are gap-validity verdicts. A provenance observation about a same-session operator spec has nowhere to go except into one of those buckets, so it lands as a per-gap contradiction or a high-confidence finding. The skill never tells the validator that "the operator's own uncommitted spec is the desired state" is a workflow note, not a gap contradiction.

### E2: Section 4 of the report has no channel for process/workflow notes

- **Source:** `han.core/skills/gap-analysis/references/gap-analysis-report-template.md` (Section 4) and `SKILL.md` (Step 6, render rule 7)
- **Finding:**
  ```
  # Template Section 4 has exactly three signal groups + a confidence table:
  ### Confirmations   ### Contradictions   ### Augmentations   ### Confidence summary

  # SKILL.md render rule 7:
  Group entries into Confirmations, Contradictions, and Augmentations using the
  swarm agents' verbatim verdicts.
  ```
- **Relevance:** Even if the validator wanted to label V7 a workflow note, the report has no place to render it. Confirmations/Contradictions/Augmentations are all about gap validity; the confidence table is per-gap. A workflow reminder gets forced into "Contradictions" (reads as a real disagreement) or inflates the confidence noise. This is the rendering half of E1.

### E3: The second-round trigger keys on a raw count, with no escape when the delta is already covered

- **Source:** `han.core/skills/gap-analysis/SKILL.md` (Step 5.5, Conditional Second Round)
- **Finding:**
  ```
  - **Trigger A:** the swarm returned ≥ 3 `proposed_new_gap` entries.
  - **Trigger B:** the swarm returned contradictions on ≥ 20% of the analyzer's
    original gaps.
  ...
  1. Re-dispatch `gap-analyzer` with the new findings ... Return only the delta:
     new gaps the first pass missed ...
  ```
- **Relevance:** Trigger A fires on the *count* of proposed new gaps, not on whether a re-scan would add anything. When the swarm has already specified each new gap with evidence and ≥ 2 agents confirmed it, the re-dispatch can only re-confirm — exactly the ceremony the issue describes. There is no escape clause permitting the skill to skip the round when the delta is already fully characterized.

### E4: Actor enumeration is delegated to the junior-developer brief; the skill never derives actors from the artifact

- **Source:** `han.core/skills/gap-analysis/SKILL.md` (Step 1, Step 5 junior-developer brief) and the Operating Principles bullet on the actor sweep
- **Finding:**
  ```
  # Step 5 junior-developer brief:
  "... Enumerate every actor type the desired state addresses or implies —
  human end users (and sub-roles ...), API callers, AI agents, integration
  partners, batch processes, internal services. ..."

  # Step 1 identifies the two artifacts and the comparison direction only —
  # it does NOT read the desired state for actor/mode signals or pass a
  # candidate actor list into any brief.
  ```
- **Relevance:** The skill tells junior-developer to enumerate actors but never does any enumeration itself, so the quality of the sweep depends on whatever actors the operator happened to name in the brief. The two highest-value gaps (G-011, G-012) came from the swag *batch runner* actor, which is not obvious from the skill file. Nothing in Steps 1–4 reads the desired-state artifact for actor or mode signals and seeds the brief with them.

### E5: There is no purpose-conditioned prioritized view, and prioritization is (correctly) forbidden in the analyzer

- **Source:** `han.core/agents/gap-analyzer.md` (Rules), `han.core/skills/gap-analysis/SKILL.md` (Step 1, Step 6), `gap-analysis-report-template.md` (Section 1)
- **Finding:**
  ```
  # gap-analyzer.md Rules:
  - No prioritization, no impact assessment. Produce an unprioritized gap list.

  # Template Section 1 executive summary: magnitude table (counts by category)
  # + "shape of the gap" themes. No prioritized / blocking subset.

  # SKILL.md Step 1 captures the two artifacts and direction, but never
  # captures WHY the operator is comparing (the purpose/goal).
  ```
- **Relevance:** The analyzer is deliberately neutral — it must not prioritize. So a "top N that block X" view cannot come from the analyzer; it has to be a skill-level synthesis judgment conditioned on the operator's stated purpose. But Step 1 never captures the purpose, and the template has no slot for the view, so there is nowhere for the shortcut to live. The issue's own context ("before a redesign pass") is exactly the kind of purpose that would drive it.

## Root Cause Analysis

### Summary

In four places the skill delegates a synthesis responsibility (classifying process observations, deciding whether re-analysis adds value, discovering actors, prioritizing against a goal) to a downstream brief, the neutral analyzer, or a fixed report shape, instead of owning it at the skill's synthesis layer — so each responsibility is only met when an upstream input happens to carry it.

### Detailed Analysis

The skill is well-factored for its primary job: the analyzer owns neutral gap classification (E5), and the swarm owns adversarial validation and the actor sweep. The four frictions all sit at the seam where the *skill* is supposed to add judgment on top of those neutral inputs, and in each case the seam is missing:

- **V7 noise (E1, E2)** is a *surfacing-granularity* problem, not a missing taxonomy. The validator is correctly probing provenance (Strategy 4), and per `evidence-rule.md` the operator's own uncommitted spec is a **provided** source that genuinely warrants interested-party scrutiny — so the caveat is legitimate and must not be suppressed. The friction is that this is a *single artifact-level caveat* (it applies uniformly to every gap, since they all rest on the same spec), yet it was surfaced *per-gap as a high-confidence finding*, which made one workflow-level reminder read as many gap-level contradictions. The fix is to surface the provided-source caveat **once**, at the artifact level, in its own report channel — not to downgrade or hide it. *(Corrected by validation — see V2.)*

- **Second-round ceremony (E3)** is a *brief-scope* problem, not a gate that should skip. Step 5.5 exists to find *new* gaps in an actor/behavior class the first pass systematically excluded, and to surface recategorizations and withdrawals — all of which issue #34 explicitly praised ("confirmed the three new gaps and rejected one meta-candidate"). The complaint was narrowly that the round *re-confirmed gaps the swarm had already corroborated*. So the fix narrows the round's brief to exclude that redundant re-confirmation while keeping its real work (new gaps + withdrawals) intact — it does not skip the round. *(Corrected by validation — see V3, V5.)*

- **Actor-sweep brief-dependence (E4)** is a responsibility delegated without a seed. The skill asks junior-developer to enumerate actors but no upstream step surfaces the actor/mode signals to seed it, so a non-obvious actor (the batch runner) only enters the sweep if the operator names it. The analyzer already reads the desired state's full surface area in its Steps 2–3, so the fix routes actor discovery through the analyzer's *output* (have it report the actors/modes it already encountered) rather than adding a duplicate skill-level read that could diverge from the analyzer's correspondence map. *(Corrected by validation — see V4, V6.)*

- **No blocking subset (E5)** is a synthesis judgment with no input, no output slot, and — as written — no granting authority. Prioritization cannot live in the analyzer (correctly forbidden), so it must be a skill-level view conditioned on the operator's purpose. But the skill's Operating Principles do not currently grant the skill prioritization authority, and a ranked "blocking" view is impact assessment under another name. So the fix must (a) add an Operating Principle that grants purpose-conditioned synthesis authority, (b) place the view as an explicitly-labeled judgment block distinct from the neutral magnitude summary, and (c) keep it optional and non-load-bearing. *(Corrected by validation — see V1.)*

The common thread holds: these are gaps in the skill's own synthesis layer, not analyzer or agent defects. Most fixes land in `SKILL.md` and the report template. Validation corrected one scope assumption: Fix 3 also makes a small, neutrality-preserving edit to `gap-analyzer.md`'s *output format* (it reports the actors it observed; it still does not classify, prioritize, or assess impact). The `adversarial-validator` and `junior-developer` agents keep their generic behavior — the skill just briefs and renders them better.

## Coding Standards Reference

| Standard | Source | Applies To |
|----------|--------|------------|
| Voice profile: no em-dashes, direct second person, plainspoken mentor tone, no hype | `docs/writing-voice.md` (referenced from `CLAUDE.md`) | All prose added to `SKILL.md` and the template |
| YAGNI / evidence rule: do not add speculative sections; every addition needs evidence | `CLAUDE.md` ("YAGNI applies to docs too"), `han.core/references/evidence-rule.md` | Every new step, trigger clause, and template slot below — each must trace to an E-item |
| Skill authoring: progressive disclosure, context hygiene, deterministic flowchartable steps | `han.plugin-builder/skills/guidance/references/skill-building-guidance/`, `han.plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md` | New Step 1.5, Step 5.5 escape clause, Step 6 render rules |
| Analyzer stays neutral: no prioritization, no impact assessment | `han.core/agents/gap-analyzer.md` (Rules) | Fix 4 must keep prioritization in the skill, never push it into the analyzer |
| One canonical source per concept; long-form doc is canonical | `CLAUDE.md` (Conventions) | `docs/skills/gap-analysis.md` must be updated to match every behavior change below |

## Planned Fix

### Summary

Add the four missing synthesis responsibilities — surface the provided-source caveat once instead of per gap, narrow the second-round brief instead of skipping the round, route actor discovery through the analyzer's output to seed the actor sweep, and add a purpose-conditioned, explicitly-labeled prioritized pointer view — across `SKILL.md`, the report template, a small `gap-analyzer.md` output addition, and the canonical long-form doc, while keeping the analyzer neutral (no classification, prioritization, or impact assessment) and the swarm agents generic.

> **Revised after adversarial validation.** Every fix below reflects the V-findings in the Validation Results section. The original drafts (a `workflow_note` verdict, a second-round skip clause, a duplicate skill-level actor read, and a Section-1 blocking ranking) were each refuted or weakened and have been replaced.

### Changes

#### `han.core/skills/gap-analysis/SKILL.md`

- **Change (Fix 1 — surface the provided-source caveat once, not per gap):** In Step 5's validator brief, keep provenance scrutiny fully intact (the `evidence-rule.md` **provided** trust class requires it). Add a clause: when a provenance concern applies *uniformly to the desired-state artifact as a whole* (e.g., "the desired state is a provided, uncommitted, same-session source"), return it **once** as a single artifact-level `analysis_caveat`, not repeated as a per-gap verdict on every gap that rests on that artifact. Provenance concerns specific to an *individual* gap's evidence still return as that gap's `contradicted`/`inconclusive` verdict. Add one Operating-Principles line: artifact-level analysis caveats are surfaced once and do not feed per-gap confidence (they bear on the whole report equally, so per-gap weighting would double-count one fact).
- **Evidence:** (E1), (E2); corrected by (V2), (V7)
- **Standards:** `evidence-rule.md` "provided" trust class (caveat is preserved, not suppressed); writing voice; YAGNI.
- **Details:** No new per-gap verdict token. `analysis_caveat` is an artifact-level channel, distinct from the per-gap `confirmed`/`contradicted`/`inconclusive` verdicts. Step 6 confidence derivation (render rule 3) reads only the per-gap verdicts, so an `analysis_caveat` neither raises nor lowers any gap's confidence. This removes the "one fact, thirteen high-confidence findings" noise while keeping the scrutiny the evidence rule mandates.

- **Change (Fix 2 — narrow the second-round brief; do not skip the round):** In Step 5.5, leave Triggers A and B and the round itself intact (the round's job — finding new gaps in a systematically-excluded actor/behavior class, plus recategorizations and withdrawals — is praised in issue #34). Edit the re-dispatch brief so it explicitly **excludes redundant re-confirmation**: "Do not re-confirm gaps the swarm already corroborated. Return only (a) new gaps in the actor or behavior classes the proposed gaps reveal were under-covered, (b) gaps needing recategorization, and (c) gaps that should be withdrawn." Add a sentence clarifying that Trigger A's count is a *proxy* for a systematically-excluded class, so the round should re-scan that class for additional gaps rather than re-litigate the ones already surfaced.
- **Evidence:** (E3); corrected by (V3), (V5)
- **Standards:** Preserve praised behavior (the round's withdrawal and new-gap functions stay); YAGNI (cuts only the redundant re-confirmation the feedback named).
- **Details:** No skip clause. The Step 7 in-channel summary keeps reporting "second round ran (trigger / new gaps / recategorizations / withdrawals)"; the change is that the round no longer spends effort re-confirming already-corroborated gaps.

- **Change (Fix 3 — analyzer reports observed actors; skill seeds the sweep):** Have actor discovery flow through the agent that already reads the desired state, not a duplicate skill read. (a) In Step 5's brief to `gap-analyzer` (and the agent's output format — see below), have the analyzer report the **actors and modes it observed** in the desired state (named roles, sub-roles, interactive vs. batch/automated modes, API/agent/integration surfaces) as a neutral observation in its source file. (b) In Step 5, seed the junior-developer brief with that observed-actor list: "candidate actors the analyzer observed in the desired state: [list]; expand it — this is a floor, not a ceiling." If the analyzer observed no actor signal, record that and fall back to the current generic enumeration.
- **Evidence:** (E4); corrected by (V4), (V6)
- **Standards:** No duplicate read (single source of actor truth = the analyzer's correspondence-map pass); analyzer neutrality preserved (reporting observed actors is not classification, prioritization, or impact assessment); junior-developer still owns and expands the sweep.
- **Details:** Near-zero marginal cost — the analyzer already reads the desired state's surface area in its Steps 2–3, so this only surfaces what it already saw. This also defuses the single-run YAGNI concern (V6): the change adds reporting, not a new always-on read step that fails when no actors are present.

- **Change (Fix 4 — capture purpose; grant authority; labeled prioritized pointer view):** (a) In Step 1, capture the **purpose** of the comparison when the operator stated one (e.g., "before a redesign pass"), or offer to capture it in the same one-line confirmation that states the comparison direction. (b) Add an Operating-Principles line granting the skill authority to produce a purpose-conditioned prioritized *pointer* view as a labeled synthesis judgment, explicitly layered on top of — and never replacing — the analyzer's neutral, unprioritized gap list. (c) In Step 6, add a render rule: when a purpose was captured, produce a **Where to start** block — up to five gaps that most block that stated purpose, one plain-language reason each, citing existing `G-NNN` IDs. Omitted entirely when no purpose was given.
- **Evidence:** (E5); corrected by (V1)
- **Standards:** Analyzer stays neutral (prioritization lives only in the skill, as a granted, labeled judgment); optional-sections-not-load-bearing (the block is additive; the neutral magnitude summary and Sections 1–2 still stand alone); consistent with the existing synthesis judgments the skill already makes (thematic clustering in render rule 5, confidence derivation in render rule 3).
- **Details:** The block carries an explicit label — "Where to start (skill judgment for your stated purpose: {purpose})" — so it is never mistaken for the analyzer's neutral output or for the plain-language magnitude summary. It is plain language (IDs + reasons, no file paths), adds no new gaps, and changes no categories or confidence. Placement: a distinctly-titled block in Section 1 after the magnitude table, *not* folded into the neutral "shape of the gap" bullets, and *not* in swarm-gated Section 4 (so it survives the `no swarm` path).

#### `han.core/agents/gap-analyzer.md`

- **Change:** Add one line to the full-analysis output format (a neutral "Actors and modes observed in the desired state" note under Scope or Correspondence) so the analyzer reports the actor/mode signals it already encountered while building the correspondence map. Do **not** touch the Rules (no prioritization, no impact assessment), the gap taxonomy, or the neutral posture.
- **Evidence:** (E4); scope corrected by (V4)
- **Standards:** Analyzer neutrality is explicitly preserved — this reports an observation, it does not classify, rank, or weight; writing voice.
- **Details:** Surfaces what the analyzer's Step 2 surface-area pass already sees, so the skill (Fix 3) can seed junior-developer without a divergent second read.

#### `han.core/skills/gap-analysis/references/gap-analysis-report-template.md`

- **Change:** (a) Add an **Analysis caveats** subsection at the end of Section 4 (after Augmentations, outside the Confidence summary) for artifact-level `analysis_caveat` items — rendered once as plain reminders, explicitly not gap findings. (b) Add an optional **Where to start** block in Section 1 after the magnitude table, shown only when a purpose was captured: a distinctly-titled, purpose-labeled mini-list of the most-blocking gaps with their `G-NNN` IDs and one-line reasons. Mark both as optional in the front-matter `sections_included` guidance and in "How to Read This Report."
- **Evidence:** (E2), (E5); corrected by (V1), (V2)
- **Standards:** Information-architect's layered-report design (the pointer view sits in the two-minute read; caveats sit with the confidence signals); optional-sections-not-load-bearing; writing voice.
- **Details:** Analysis caveats use a one-line italic preface ("These are analysis caveats that apply to the whole report, not gaps."). The "Where to start" block is conditional and purpose-labeled so it never reads as the analyzer prioritizing.

#### `docs/skills/gap-analysis.md`

- **Change:** Update the canonical long-form doc to describe the purpose capture, the analyzer-reported actor seeding, the narrowed second-round brief, the artifact-level analysis-caveat channel, and the purpose-conditioned "Where to start" view, so the doc matches the implementation.
- **Evidence:** (E1)–(E5); `CLAUDE.md` Conventions ("one canonical source per concept")
- **Standards:** Long-form doc is canonical; voice profile.
- **Details:** Prose-only update; no new behaviors beyond those in `SKILL.md` and `gap-analyzer.md`. Verify the skills index entry still scents correctly.

## Validation Results

One `adversarial-validator` agent attacked the full evidence summary, root cause, and the original four fixes. It returned seven findings; four refuted or weakened load-bearing premises and drove the fix revisions above.

### Counter-Evidence Investigated

#### V1: Original Fix 4 smuggled impact assessment into the skill and conflicted with its own Operating Principles

- **Hypothesis:** A skill-level "blocking subset" respects the analyzer's "no prioritization" rule.
- **Investigation:** `SKILL.md` Operating Principle 2 makes Sections 1–2 plain-language and neutral; Operating Principle 1 says the skill "does not classify gaps itself." Ranking gaps by how much they "block" a purpose is impact assessment, and the skill has no principle granting it that authority. The original placement (inside Section 1's neutral summary) compounded the conflict.
- **Result:** Partially Refuted.
- **Impact:** Fix 4 revised — add an explicit Operating Principle granting purpose-conditioned synthesis authority, label the view as judgment ("Where to start"), keep it plain-language, and place it as a distinct block (not inside the neutral magnitude summary, not in swarm-gated Section 4).

#### V2: Original Fix 1 contradicted `evidence-rule.md`'s "provided" trust class

- **Hypothesis:** An operator's own same-session spec deserves less provenance scrutiny than an external source, so it can be routed to a non-confidence note.
- **Investigation:** `evidence-rule.md` defines **provided** sources (operator-supplied material) as warranting "interested-party scrutiny; hold to the same standard as web sources," with no operator-vs-external distinction. `SKILL.md` Operating Principle 4 already invokes this rule for every gap. The validator's provenance flag was the rule working, not noise. An uncommitted spec can change, which genuinely bears on whether the gaps are real.
- **Result:** Refutes the original premise.
- **Impact:** Fix 1 reframed — the caveat is preserved (never suppressed); the only change is to surface it **once** at the artifact level (`analysis_caveat`) instead of per-gap, since one fact about the shared artifact was being repeated as many high-confidence per-gap findings. The operator-vs-external carve-out was dropped entirely.

#### V3: Original Fix 2's skip clause used the wrong condition for the round's purpose

- **Hypothesis:** The second round can be skipped when proposed gaps are already well-evidenced and corroborated.
- **Investigation:** `SKILL.md` Step 5.5 frames the round as detecting that "the analyzer's correspondence map systematically excluded an actor type or behavior class," and its re-dispatch brief asks for "new gaps the first pass missed." Well-specified proposed gaps are a *symptom* of an excluded class, not proof the class is fully mapped. The skip condition ("proposed gaps are well-evidenced") does not imply "re-analysis would find nothing."
- **Result:** Refutes.
- **Impact:** Fix 2 reframed — do not skip the round; narrow its brief to exclude redundant re-confirmation while keeping the new-gap, recategorization, and withdrawal work the round exists to do.

#### V4: Original Fix 3 duplicated work `gap-analyzer` already performs

- **Hypothesis:** A new skill Step 1.5 must read the desired-state artifact for actor signals.
- **Investigation:** `gap-analyzer.md` Steps 2–3 already read both inputs and map the desired state's full surface area (features and behaviors), which includes actor/mode signals. The analyzer just does not *return* them — its summary is gap counts plus a file path. A parallel skill read would re-read the same artifact and could produce an actor list that diverges from the analyzer's actual correspondence map.
- **Result:** Partially Refuted.
- **Impact:** Fix 3 rerouted — have the analyzer report the actors it already observed (small output-format edit to `gap-analyzer.md`, neutrality preserved); the skill seeds junior-developer from that single source instead of reading again.

#### V5: Original Fix 2 would have suppressed a behavior issue #34 praised

- **Hypothesis:** The second round in the issue #34 run was pure ceremony.
- **Investigation:** Issue #34's "What worked well" notes the second round "confirmed the three new gaps and rejected one meta-candidate." The withdrawal (rejecting the meta-candidate) is a documented function of Step 5.5 and was treated as valuable in the issue. The complaint in "What didn't work" was narrowly about *re-confirmation* of already-described gaps, not about the round as a whole.
- **Result:** Refutes the original framing.
- **Impact:** Reinforces the Fix 2 reframe — preserve the round (and its withdrawals); cut only the redundant re-confirmation the feedback actually named.

#### V6: Original Fix 3 risked failing the skill's own YAGNI evidence test

- **Hypothesis:** A permanent always-on Step 1.5 is justified by a single run.
- **Investigation:** The evidence base is one run, and the original Step 1.5 had a fallback ("if no actor signal, fall back to generic enumeration") implying it would frequently read and find nothing — added cost, occasional value.
- **Result:** Partially Refuted.
- **Impact:** Folds into the Fix 3 reroute (V4): surfacing actors the analyzer *already* read is near-zero marginal cost, so the YAGNI concern about a new always-on read step is resolved rather than argued around.

#### V7: The original `workflow_note` token had no defined handling in the validator agent

- **Hypothesis:** Adding a `workflow_note` verdict to the brief is clean.
- **Investigation:** `adversarial-validator.md`'s output format uses `Confirmed | Refuted | Partially Refuted`; the per-gap verdict set is already a skill-brief override. A new token is a skill construct the agent has no internal concept of, and the boundary "does not bear on whether a gap is real" is fuzzy given V2 (provided-source provenance *does* bear on validity).
- **Result:** Confirmed-with-risk.
- **Impact:** Resolved by the Fix 1 reframe — instead of a per-gap token with a fuzzy boundary, use a single artifact-level `analysis_caveat` channel with a precise scope ("a provenance fact about the desired-state artifact as a whole"), rendered once in a defined "Analysis caveats" report subsection.

### Adjustments Made

- **Fix 1** (V2, V7): dropped the `workflow_note` per-gap token and the operator-vs-external carve-out; replaced with a single artifact-level `analysis_caveat` channel that preserves the evidence-rule scrutiny but surfaces it once.
- **Fix 2** (V3, V5): dropped the skip clause; replaced with a narrowed re-dispatch brief that cuts redundant re-confirmation while keeping new-gap discovery and withdrawals.
- **Fix 3** (V4, V6): dropped the duplicate skill-level read (Step 1.5); replaced with a neutral output-format addition to `gap-analyzer.md` plus skill-level seeding of junior-developer from the analyzer's reported actors. Added `gap-analyzer.md` to the changed-files list.
- **Fix 4** (V1): added an Operating Principle granting purpose-conditioned synthesis authority; relabeled the view "Where to start" as explicit skill judgment; moved it out of the neutral magnitude summary and out of swarm-gated Section 4.
- **Root cause detail** updated for all four fixes to reflect the corrected mechanisms.

### Confidence Assessment

- **Confidence:** Medium. The four frictions are real and well-located in the files (E1–E5 stand on direct citations). The fixes have been reworked to survive the validator's strongest objections, and each now respects the skill's existing principles and the evidence rule. Confidence is not High because (a) the fixes are doc/skill-instruction changes whose real-world effect can only be confirmed by running the revised skill on a comparable case, and (b) the evidence base is a single run.
- **Remaining Risks:**
  - **Single-run evidence (V6 residual):** all four frictions come from one `gap-analysis` run. If they do not recur, Fix 4's purpose-capture and Fix 1's caveat channel still cost little, but their value is unproven beyond this case. Reopen trigger: a second feedback run reporting the same friction, or its absence after these changes ship.
  - **Fix 4 determinism (V1 residual):** "which gaps most block the purpose" is a judgment, not a flowchart. Mitigated by requiring a one-line reason per entry, a hard cap, and an explicit judgment label — but two runs could rank differently. Acceptable because the block is an optional pointer, not the gap list.
  - **`proposals/CLAUDE.md` not readable:** the exact desired-state spec from the issue is uncommitted and outside this repo, so we cannot confirm Fix 3 would have surfaced the batch-runner actor in that specific run. Fix 3's value rests on the general claim that the analyzer's surface-area pass sees actor signals when the artifact contains them.

## Final Summary

- **Root Cause:** Four frictions in issue #34 trace to gaps in the `gap-analysis` skill's own synthesis layer — it surfaced an artifact-level provenance caveat per gap (E1, E2), re-confirmed already-corroborated gaps in its second round (E3), never seeded the actor sweep from the artifact (E4), and had no purpose-conditioned prioritized view (E5).
- **Fix:** Surface the provided-source caveat once at the artifact level, narrow the second-round brief to drop redundant re-confirmation, have `gap-analyzer` report the actors it already observed so the skill can seed the sweep, and add a granted, explicitly-labeled "Where to start" pointer view when the operator states a purpose.
- **Why Correct:** Each fix lands on the cited evidence (E1–E5) and now respects the skill's Operating Principles, the analyzer's neutrality, and `evidence-rule.md`'s "provided" trust class — the four points the validator used to refute the original drafts (V1–V5).
- **Validation Outcome:** Adversarial validation refuted or weakened all four original fixes (V1–V6) and confirmed a handling risk (V7); every fix was reworked to preserve the behaviors issue #34 praised (the second-round withdrawal, the actor sweep) while removing the named friction.
- **Remaining Risks:** Single-run evidence base and the inherent non-determinism of the purpose-conditioned pointer view; see the Confidence Assessment.
