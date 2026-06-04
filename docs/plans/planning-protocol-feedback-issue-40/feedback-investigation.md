# Investigation: Issue #40 Feedback on plan-a-feature + plan-implementation Protocol Fit

Whether the protocol-overhead feedback in [issue #40](https://github.com/testdouble/han/issues/40) should drive changes in Han, evaluated against the fact that Han is targeted at software engineering.

## Problem Statement

**The feedback.** Mike Jansen used `plan-a-feature` then `plan-implementation` to plan and implement contributing the `/han-feedback` skill (a markdown `SKILL.md` file) to the Han repo, shipped as [PR #39](https://github.com/testdouble/han/pull/39). He rated evidence-first discipline, review-agent signal quality, specialist selection, YAGNI discipline, and round efficiency at 5/5, and praised 16 genuine findings the review agents caught. His complaint is narrower and consistent across both skills:

- **Headline:** "Protocol overhead is sized for software features, not skill contributions." For a markdown instruction file whose behavioral surface fits in roughly 10 steps, both skills produced full-template scaffolding (spec sections plus RAID log, security posture, testing strategy, operational readiness). He rated "Output length vs. decision count" 2/5 and "Protocol fit for documentation contributions" 3/5, and suggested a lighter-weight "contribution spec" mode or reduced-template option for documentation-only changes.
- **Smaller points:** rating dimensions underspecified ("adapt to skill type"), step-numbering drift across three artifacts, and that a pre-flight read of `CONTRIBUTING.md` would have caught checklist items faster than dispatching agents (he flagged the CHANGELOG skill-count finding the same way).

**The question.** The operator asked whether any of this should drive changes in Han, "considering Han is targeted at software engineering." That framing is the gate. The headline complaint is about using Han to plan a *plugin/documentation contribution*, which is not the software-feature work the planning skills are scoped for. The investigation has to separate the part of the feedback that survives that gate (a real in-scope defect the documentation use case happened to expose) from the part that asks Han to optimize for an out-of-band use case.

**Impact.** None on running software. This is a product-direction question about whether to change Han's planning skills, the `han-feedback` skill, or neither.

## Evidence Summary

### E1: The spec template carries roughly nine sections, several already conditional

- **Source:** `han.core/skills/plan-a-feature/references/feature-specification-template.md:101-232`
- **Finding:**
  ```
  ## Outcome / ## Actors and Triggers / ## Primary Flow / ## Alternate Flows and States
  ## Edge Cases and Failure Modes / ## User Interactions / ## Coordinations
  ## Out of Scope / ## Deferred (YAGNI) / ## Open Items / ## Summary
  ```
- **Relevance:** The feedback's list of sections is accurate, but partly overstated. `## User Interactions` carries "Omit this section if the feature has no direct user surface" (line ~158), `## Deferred (YAGNI)` is "LAZILY CREATED" (line ~194), and `## Open Items` is conditional. The spec is not as rigid as the feedback implies, though the core flow and behavior sections always apply. Claim PARTIALLY CONFIRMED.

### E2: Sizing scales team size and round cap only, never template weight

- **Source:** `docs/sizing.md:80-81`; `han.core/skills/plan-a-feature/SKILL.md:160-176`; `han.core/skills/plan-implementation/SKILL.md:88-96, 270-274`
- **Finding:** A "small" classification reduces the review team (plan-a-feature cap 2, plan-implementation cap 3 and 1 round) and how aggressively findings are calibrated. The same full section list is enumerated for the produced document at all sizes (`plan-implementation/SKILL.md:273`). No "lightweight spec" mode or reduced-template output exists anywhere.
- **Relevance:** This is the structural root of the headline complaint. Sizing is the existing dial Han offers, and it does not turn down document weight. Claim CONFIRMED.

### E3: plan-implementation renders several sections as empty stubs for small plans

- **Source:** `han.core/skills/plan-implementation/references/feature-implementation-plan-template.md:83-173`
- **Finding:** `## RAID Log` (four tables) and `## Testing Strategy` have no conditional guard at all. `## Security Posture`, `## Operational Readiness`, and `## On-Call Resilience Posture` each carry an "If `{specialist}` contributed" guard on their *content* but keep their headers and sub-structure unconditionally. Only `## Deferred (YAGNI)` is truly lazy with an explicit "omit the section entirely" instruction (line ~166).
- **Relevance:** A "small" plan (cap 3) usually does not dispatch the security, devops, or on-call specialists, yet all three sections still land as headers with stub content. This produces scaffolding for any small plan, **including a small software feature**, not only a documentation contribution. The template is internally inconsistent: it already has the lazy-creation pattern (`Deferred (YAGNI)`) but applies it to only one section. Claim CONFIRMED, and broader than the feedback framed it.

### E4: Both skills gate entry on software features, and every specialist is a software-system reviewer

- **Source:** `han.core/skills/plan-a-feature/SKILL.md:3-13, 181-191`; `han.core/skills/plan-implementation/SKILL.md:3-26, 100-118`
- **Finding:** plan-a-feature gates on "a new feature, capability, or system behavior before implementation" and produces a spec "focused on system behaviors, coordinations, processes, and user interactions." plan-implementation gates on "implement, build, deliver, or ship a feature." Both rosters are software-system specialists (user-experience-designer, adversarial-security-analyst, devops-engineer, on-call-engineer, structural/behavioral/concurrency analysts, software/system architects, data-engineer).
- **Relevance:** Against a markdown file addition, those specialists have near-zero domain signal to return. The skills are scoped for software engineering by design. Confirms the operator's framing.

### E5: Neither skill's "do not invoke for" list addresses plugin or documentation-file contributions

- **Source:** `docs/skills/plan-a-feature.md:33-42`; `docs/skills/plan-implementation.md:33-43`
- **Finding:** The exclusion lists cover refining plans, investigating bugs, analyzing architecture, documenting already-built features (route to `/project-documentation`), recording ADRs, code review, and researching options. Contributing a new skill, agent, or doc file to a plugin is neither included nor excluded.
- **Relevance:** This silent gap is what made the use case feel in-bounds. The friction is partly a routing problem, not only a template problem.

### E6: CONTRIBUTING.md already prescribes a lighter, non-planning workflow for adding a skill

- **Source:** `CONTRIBUTING.md:41-51`
- **Finding:** "Adding a skill" is a six-step manual checklist: scaffold the folder, write `SKILL.md`, copy the doc template, add to the Skills Index, add to root `CLAUDE.md`, update the marketplace registry if needed. No step routes through `/plan-a-feature` or `/plan-implementation`.
- **Relevance:** A strictly simpler version that satisfies the same goal already exists for exactly the case the feedback describes. This is decisive for the headline recommendation under YAGNI Gate 2.

### E7: Han does support documentation work, and maintainers have run plan-a-feature on a doc-only contribution successfully

- **Source:** `README.md:5` ("full documentation maintenance"); `docs/plans/choosing-a-han-plugin/feature-specification.md:1-3` and `artifacts/team-findings.md`
- **Finding:** The `choosing-a-han-plugin` documentation page was specced with `plan-a-feature` (review team `junior-developer` + `information-architect`, size small; artifact fingerprints confirm it was the skill, not hand-authored). It produced a coherent spec with real actors, navigation flows, and cross-surface coordinations, and 21 substantive findings. README's "full documentation maintenance" capability is delivered by `/project-documentation`, which the planning skills explicitly point to.
- **Relevance:** "Documentation is out of scope" is too broad a claim. Documentation work with genuine behavioral complexity is a legitimate, working use of plan-a-feature. The friction is specific to a contribution whose entire decision surface is "does this file match the contribution conventions."

### E8: han-feedback rating dimensions are underspecified at template time

- **Source:** `han.feedback/skills/han-feedback/SKILL.md:82, 119-125`
- **Finding:**
  ```
  **Rating:** Score across the dimensions used in the reference file from Step 5,
  or adjust dimensions to fit the skill type when no reference file exists.
  ```
  The embedded table uses placeholder `{dimension}` rows. No named default dimensions exist for any skill type.
- **Relevance:** When no prior feedback file exists, the writer invents dimensions, which is the ambiguity that produced finding F8 / decision D9 during the run. This is independent of the software-versus-documentation question. Claim CONFIRMED.

### E9: Numbering namespaces are independent across files with no synchronization

- **Source:** `han.core/skills/plan-a-feature/SKILL.md:61-62`; `han.core/skills/plan-implementation/SKILL.md:44-45`
- **Finding:** The spec uses `D#` / `F#` / `T#`; the implementation plan uses a separate `D-N`; work items add a third sequence downstream. Nothing binds these counters, and inserting an item in one file does not propagate to the others. The skills rely on manual cross-reference maintenance.
- **Relevance:** The step-numbering drift the feedback reports is structurally present, and it is general to the plan chain rather than specific to documentation. Claim PARTIALLY CONFIRMED.

### E10: plan-a-feature Step 2 discovery omits CONTRIBUTING.md and writes no shared notes file

- **Source:** `han.core/skills/plan-a-feature/SKILL.md:63-75`; `han.core/skills/plan-implementation/SKILL.md:84-86, 143`
- **Finding:** plan-a-feature Step 2 reads `CLAUDE.md`, `AGENTS.md`, `project-discovery.md`, ADRs, coding standards, existing specs, and adjacent code, but not `CONTRIBUTING.md`. plan-implementation Step 2 writes a documented `.discovery-notes.md` single-source-of-truth file that every specialist reads first; plan-a-feature has no equivalent shared file and records findings in-context only.
- **Relevance:** The praised `.discovery-notes.md` mechanism is real and standardized in plan-implementation, not ad hoc. The pre-flight gap the feedback describes is masked in the Han repo because `CLAUDE.md` is unusually complete, but the general pattern (Step 2 not reading `CONTRIBUTING.md`) holds for any project that keeps conventions there.

### E11: The evidence base is two documentation-contribution data points, both Han-internal

- **Source:** `docs/plans/` inventory
- **Finding:** Of the four plan folders, only `choosing-a-han-plugin` is a `plan-a-feature` output (documentation-only); `gap-analysis-feedback-issue-34` and `skills-feedback-issue-36` are feedback investigations that did not use the planning skills; `canonical-evidence-resource` has no spec. Combined with Mike's `han-feedback` run, that is two known cases of the planning skills applied to a documentation/plugin contribution, both dogfooding on the Han repo.
- **Relevance:** Demand for a documentation-contribution mode is thin and self-referential. It does not meet the bar for a new mode aimed at the solo-product-engineer audience.

## Root Cause Analysis

### Summary

The friction has two distinct roots that the feedback conflates: (1) a **scope and routing gap**, where the planning skills silently accept a plugin-contribution use case they were never scoped for and that already has a lighter `CONTRIBUTING.md` workflow; and (2) a **genuine in-scope template-weight defect**, where sizing scales the review team but never the produced document, so small plans (software or documentation) carry full-length operational sections even when no specialist filled them.

### Detailed Analysis

The headline complaint is accurate at the surface (E1, E2) but its diagnosis ("sized for software features, not documentation") is only half right. The planning skills are indeed scoped for software engineering by design (E4), and a plugin contribution has its own non-planning workflow in `CONTRIBUTING.md` (E6) that neither skill points to (E5). Running a full software-feature protocol against a `SKILL.md` addition is therefore using the wrong tool, and the over-scaffolding is the predictable result.

But the validator's reading of the templates shows the more important point: the document-weight problem is not caused by documentation (E3). plan-implementation renders `RAID Log`, `Testing Strategy`, `Security Posture`, `Operational Readiness`, and `On-Call Resilience Posture` as headers regardless of whether the corresponding specialist contributed, and only `Deferred (YAGNI)` follows the lazy-creation pattern that would omit an empty section. A genuinely small *software* feature hits the same wall. Sizing (E2) is the dial Han already exposes for proportionality, and it deliberately does not touch document weight. That is the part of the feedback that survives the software-engineering gate, and it is fixable with the template's own existing pattern rather than a new mode.

The smaller points split cleanly. The rating-dimension ambiguity (E8) is a real, scope-independent underspecification in `han-feedback`. The numbering drift (E9) is real and general to the plan chain. The pre-flight `CONTRIBUTING.md` read and the CHANGELOG skill count (E10) are symptoms of planning a Han contribution; the first generalizes weakly to any project that keeps conventions in `CONTRIBUTING.md`, the second does not generalize at all.

## Han Conventions Reference

| Convention | Source | Applies To |
|---|---|---|
| YAGNI two-gate rule (evidence test, then simpler-version test) | `docs/yagni.md`; `han.core/references/yagni-rule.md` | Every recommendation below, especially the decline of a new mode (Gate 2) and the lazy-section change (consistency with the existing `Deferred (YAGNI)` pattern) |
| Sizing scales review depth, not artifact content | `docs/sizing.md` | Confirms template weight is not currently a sizing dial; R1 is the change that would make small plans proportionate |
| Skill scoping via "do not invoke for" lists | `docs/skills/plan-a-feature.md`, `docs/skills/plan-implementation.md` | R3 (narrowly-scoped exclusion entry) |
| Contribution workflow is a manual checklist | `CONTRIBUTING.md:41-51` | The simpler version that satisfies the headline use case |
| Writing voice (no em-dashes, direct second person, no hype, banned vocabulary) | `docs/writing-voice.md` | Any doc or `SKILL.md` text these recommendations change |

## Recommendations

Bucketed by the software-engineering gate. "One sentence summary" first, then the concrete file each change touches.

### Act on

#### R1 (strongest): make plan-implementation's operational sections lazily created, matching the `Deferred (YAGNI)` pattern

- **Change:** In `han.core/skills/plan-implementation/references/feature-implementation-plan-template.md`, give `## Security Posture`, `## Operational Readiness`, `## On-Call Resilience Posture`, and the `## RAID Log` sub-tables the same explicit "write this section only if there is content; otherwise omit it entirely" instruction that `## Deferred (YAGNI)` already carries. Update the `plan-implementation/SKILL.md:270-274` enumeration to mark them lazy alongside `Deferred (YAGNI)`.
- **Evidence:** E2, E3. Sizing already classifies a plan as small but never reduces its document; the template already contains the lazy pattern for one section.
- **Why it passes the gate:** This fixes a small *software* feature plan, not only a documentation one. It is squarely in scope, internally consistent with the template, and aligned with the plan-implementation operating principle that operational machinery shipped before it is needed is YAGNI.
- **YAGNI:** Gate 1 satisfied (two documented runs plus the general small-feature case); Gate 2 satisfied (omit-when-empty is simpler than a new mode and reuses an existing mechanism).

#### R2: name default rating dimensions in han-feedback

- **Change:** In `han.feedback/skills/han-feedback/SKILL.md`, replace "adjust dimensions to fit the skill type" with a named default dimension set (for example: accuracy of output, evidence discipline, signal-to-noise of findings, output length versus decision count, round/turn efficiency), keeping the "adjust when a reference file exists" fallback.
- **Evidence:** E8.
- **Why it passes the gate:** Scope-independent; the ambiguity arises for software-feedback sessions too. Cheap (one section of one file).

#### R3: add a narrowly-scoped "do not invoke for" entry and pointer

- **Change:** In `docs/skills/plan-a-feature.md` and `docs/skills/plan-implementation.md` (and the SKILL.md descriptions if space allows), add an exclusion scoped precisely to plugin contributions: "Adding a new skill, agent, or documentation file to a plugin. Use the repository's CONTRIBUTING.md checklist." Do **not** write "documentation-only contributions" broadly.
- **Evidence:** E5, E6, E7.
- **Why it passes the gate:** Makes the scope boundary explicit so users self-route to the lighter workflow, without breaking the legitimate documentation-with-behavioral-complexity use case that `choosing-a-han-plugin` proves works (E7). The narrow wording is load-bearing here.

### Consider (optional, lower priority)

#### R4: add CONTRIBUTING.md to plan-a-feature Step 2 discovery

- **Change:** Add `CONTRIBUTING.md` to the Step 2 discovery file list in `plan-a-feature/SKILL.md:63-75` (and optionally plan-implementation), as a convention source alongside `CLAUDE.md` and coding standards.
- **Evidence:** E10. The Han-specific symptom is masked by a complete `CLAUDE.md`, but the general gap is real for projects that keep conventions in `CONTRIBUTING.md`.
- **Note:** Marginal value. Worth doing only if touching Step 2 for another reason.

#### R5: add a cross-reference audit reminder for the numbering chain

- **Change:** A one-line note in the synthesis steps of plan-a-feature and plan-implementation that renumbering items in one artifact requires re-checking cross-references in the others.
- **Evidence:** E9.
- **Note:** A shared numbering namespace would be a larger change not justified by the evidence. Recommend the cheap reminder or defer entirely.

### Decline

#### Do not build a dedicated "contribution spec" mode or documentation-only template fork (the headline ask)

- **Reasoning:** Not because documentation is out of scope (E7 shows it is not), but because YAGNI Gate 2 is decisive: `CONTRIBUTING.md` already provides a strictly simpler workflow for exactly this case (E6). The demand is two Han-internal dogfooding runs (E11), below the bar for a new mode aimed at solo product engineers. The genuine friction is the template-weight defect, which R1 fixes for all small plans without forking the protocol.

#### Do not add a CHANGELOG skill-count pre-flight step

- **Reasoning:** This is specific to planning a Han release and is not a planning input for a normal application project. It does not survive the software-engineering gate.

## Validation Results

Validation was performed by the `adversarial-validator` agent against the draft conclusions. Nine findings (V1-V9) below; the four that changed the plan are reflected above.

### Counter-Evidence Investigated

#### V1: Is the over-scaffolding purely a documentation-scope problem, or general?

- **Hypothesis:** The draft treated over-scaffolding as a scope-mismatch specific to documentation.
- **Investigation:** Read both sizing tables and the full implementation-plan template.
- **Result:** Partially Refuted. plan-a-feature's small path is genuinely lean and its spec has conditional sections, but plan-implementation renders RAID/Testing unconditionally and Security/Operational/On-Call as stubs for small plans (E3).
- **Impact:** Reframed the root cause as two-rooted and strengthened R1; the defect affects small software features, making it clearly in scope.

#### V2: Are the implementation-plan sections guarded at population but not at rendering?

- **Hypothesis:** The summary might understate how many sections render unconditionally.
- **Investigation:** Read template lines 83-173.
- **Result:** Confirmed. Five to six sections render as structure even with no content; only `Deferred (YAGNI)` is truly lazy.
- **Impact:** Sharpened R1's exact target list.

#### V3: Does "out of scope for documentation" contradict Han's own positioning?

- **Hypothesis:** README claims "full documentation maintenance," and maintainers ran plan-a-feature on a doc page.
- **Investigation:** Read `README.md:5`, the `choosing-a-han-plugin` spec and team-findings, and `CONTRIBUTING.md`.
- **Result:** Partially Refuted the "out of scope" framing (E7). "Full documentation maintenance" is delivered by `/project-documentation`; plan-a-feature legitimately handles documentation with behavioral complexity.
- **Impact:** Rewrote the headline decline to rest on YAGNI Gate 2 (CONTRIBUTING.md is the simpler version), not on a scope claim. Narrowed R3's wording.

#### V4: Is YAGNI applied correctly to the decline?

- **Hypothesis:** The draft might misuse the evidence gate to block the mode.
- **Investigation:** Read `docs/yagni.md:28-38` and `yagni-rule.md`.
- **Result:** Confirmed with nuance. Mike's feedback IS user-described evidence (Gate 1 passes), so what blocks the mode is Gate 2 (a simpler version exists), and the clarity fix passes YAGNI cleanly.
- **Impact:** Tightened the YAGNI framing in the decline and in R1/R3.

#### V5: Does collapsing small-plan sections violate a stated design principle?

- **Hypothesis:** An ADR or guidance doc might mandate always-present sections as discipline.
- **Investigation:** Searched `han.plugin-builder/skills/guidance/references/`, `docs/sizing.md`, and plan-implementation operating principles.
- **Result:** Confirmed no blocking document exists; the YAGNI operating principle actively supports treating operational sections as conditional machinery.
- **Impact:** R1 survives; no design principle blocks it.

#### V6: Is documentation-contribution planning common enough to matter?

- **Hypothesis:** Many doc-only plans would weaken the single-data-point argument.
- **Investigation:** Inventoried `docs/plans/`.
- **Result:** Confirmed the evidence is thin: two cases, both Han-internal (E11).
- **Impact:** The decline acknowledges two cases rather than one; the conclusion is unchanged.

#### V7: Was the choosing-a-han-plugin spec really produced by plan-a-feature?

- **Hypothesis:** E7's precedent could be hand-authored.
- **Investigation:** Matched artifact structure and team-findings header against the skill's Step 6/Step 9 output format.
- **Result:** Confirmed it is genuine skill output.
- **Impact:** E7 stands as a verified precedent.

#### V8: Would a broad "do not invoke for documentation" entry break a valid use case?

- **Hypothesis:** A broad exclusion would wrongly block documentation work with real behavioral complexity.
- **Investigation:** Read the existing exclusion list and the choosing-a-han-plugin spec's behavioral content.
- **Result:** Partially Refuted the cheap-fix framing. A broad entry would have wrongly excluded the choosing-a-han-plugin work.
- **Impact:** R3 must be scoped narrowly to plugin contribution files (skill/agent/doc), not documentation writ large. Reflected above.

#### V9: Is the pre-flight CONTRIBUTING.md decline correct?

- **Hypothesis:** Step 2 already reads convention files, so omitting CONTRIBUTING.md may be a general gap, not Han-specific.
- **Investigation:** Read plan-a-feature Step 2's discovery list.
- **Result:** Partially Refuted the "Han-specific" framing. The symptom is masked by a complete `CLAUDE.md`, but the general gap is real (E10).
- **Impact:** Added R4 as an optional, low-value discovery-list addition rather than a flat decline.

### Adjustments Made

- Root cause rewritten from single-rooted (scope mismatch) to two-rooted (scope/routing gap plus in-scope template-weight defect), triggered by V1 and V2.
- Headline decline re-grounded on YAGNI Gate 2 rather than a scope claim, triggered by V3 and V4.
- R3 wording narrowed to plugin contribution files, triggered by V8.
- R4 added as optional, triggered by V9.

### Confidence Assessment

- **Confidence:** Medium-High. The structural findings come from direct file reads; the recommendations are graded by the software-engineering gate and YAGNI.
- **Remaining Risks:**
  1. Mike's actual `han-feedback` implementation plan was not inspected directly; the section-stub analysis is from the template, not the produced artifact. If the project-manager synthesis already collapsed empty sections in practice, R1 is lower-value than stated (no lazy rule mandates that collapse, so this is unlikely).
  2. R3's value depends entirely on the narrow wording surviving editing. A future broadening to "documentation contributions" would re-create the V8 problem.
  3. R1 changes a template every plan-implementation run consumes; the lazy-omit instruction must preserve the prompt to *consider* each operational concern even when the section is omitted, so the discipline is not lost with the scaffolding.

## Final Summary

- **Root Cause:** Two roots the feedback conflates: the planning skills silently accept a plugin-contribution use case they are not scoped for and that already has a lighter `CONTRIBUTING.md` workflow (E4, E5, E6), and sizing scales the review team but never the produced document, so small plans carry full-length operational sections as stubs (E2, E3).
- **Fix:** Make plan-implementation's operational sections lazily created like `Deferred (YAGNI)` (R1), name default rating dimensions in `han-feedback` (R2), and add a narrowly-scoped exclusion pointing plugin contributions at `CONTRIBUTING.md` (R3); decline a dedicated documentation-contribution mode and the CHANGELOG pre-flight.
- **Why Correct:** R1 rests on the template's own existing lazy pattern and on sizing's deliberate scope (E2, E3); the decline rests on YAGNI Gate 2, since `CONTRIBUTING.md` is the strictly simpler version that satisfies the headline use case (E6).
- **Validation Outcome:** Validation refuted the "documentation is out of scope" framing (V3), showed the over-scaffolding is a general in-scope defect rather than a documentation problem (V1, V2), and forced the exclusion entry to be scoped narrowly (V8); the core recommendations held.
- **Remaining Risks:** See the Confidence Assessment; the chief one is that the produced artifact, not the template alone, would confirm the stub-section behavior.
