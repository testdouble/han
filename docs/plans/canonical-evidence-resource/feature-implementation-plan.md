# Feature Implementation Plan: Canonical Evidence-Based Source

Ship a YAGNI-style canonical pair (`docs/evidence.md` + `plugin/references/evidence-rule.md`) defining what "evidence-based" means in Han, extract the trust-class and corroboration-gate primitives currently inline in `/research/SKILL.md` so the canonical pair becomes the single source of truth, cross-link to the YAGNI pair, and retrofit citations across behavioral-consumer skills and agents — all on the `canonical-evidence-resource` branch.

## Source Specification

- **Feature specification:** [../../research/evidence-hierarchy.md](../../research/evidence-hierarchy.md) — the research report stands in for a `feature-specification.md`. No `feature-specification.md` was produced (the user routed straight from research to plan-implementation per the hybrid handoff named in the research report's end-of-skill summary).
- **Issue:** [testdouble/han#19](https://github.com/testdouble/han/issues/19).
- **Equivalent context:** Research recommendation O7 — extract `/research`'s existing trust-class and corroboration primitives into a YAGNI-style canonical pair, frame source-proximity as a directional heuristic (not a strict ladder), defer the corroboration-gate-in-codebase-evidence work.
- **Specification decision log:** N/A (research-report source; the research's Options/Recommendation/Validation sections carry the equivalent decision context).
- **Specification team findings:** N/A.
- **Specification feature-technical-notes:** N/A — no `feature-technical-notes.md` exists. T# tagging suppressed for this plan per skill Step 1 detection.

## Outcome

When this plan ships:

- `docs/evidence.md` exists as the operator-facing canonical definition of "evidence-based" in Han, modeled structurally on `docs/yagni.md`.
- `plugin/references/evidence-rule.md` exists as the runtime-loaded prescriptive rule consumed by skills and agents, modeled on `plugin/references/yagni-rule.md`, capped at 80 lines.
- `CLAUDE.md`'s `### Core mental model` section indexes the new doc alongside `docs/yagni.md`.
- The trust-class and corroboration-gate language currently inline in `plugin/skills/research/SKILL.md:108–112` is replaced by citations to `plugin/references/evidence-rule.md` — true extraction, not parallel definition ([D-10](./artifacts/implementation-decision-log.md#d-10-extract-researchskillmd-trust-class-block-to-cite-the-canonical-pair)).
- The YAGNI pair (`docs/yagni.md` + `plugin/references/yagni-rule.md`) cross-links to the evidence pair with one sentence each direction ([D-8](./artifacts/implementation-decision-log.md#d-8-bidirectional-cross-link-between-the-yagni-pair-and-the-evidence-pair)).
- Behavioral-consumer skills and agents (11 files) cite the new rule file using the established yagni-rule citation form ([D-11](./artifacts/implementation-decision-log.md#d-11-selective-retrofit-behavioral-consumers-cite-descriptive-only-files-defer), [D-12](./artifacts/implementation-decision-log.md#d-12-citation-phrasing-exact-yagni-rule-pattern)).
- Descriptive-only single-occurrence files are not retrofitted; they ship under `## Deferred (YAGNI)` with a reopening trigger.
- All new doc content passes a writing-voice self-review against `docs/writing-voice.md` ([D-13](./artifacts/implementation-decision-log.md#d-13-trivial-decisions)).

## Context

- **Driving constraint:** Issue #19 reporter request. No production incident, no measured metric, no failing alert. The user explicitly named this as the YAGNI thin-ice case in the research (V2); this plan ships at the smaller end of plausible scope as a result.
- **Stakeholders:** Han plugin operators (read the long-form doc to understand what "evidence-based" means across skills and agents); skill and agent authors (load and cite the rule file at runtime); the project itself (gains a single canonical reference where 41 occurrences of "evidence-based" across 20 files currently float without one).
- **Future-state concern:** Whether retrofitted skills produce contradictory verdicts when YAGNI rule and evidence rule are loaded together. Addressed by the explicit supplements-not-replaces statement in the rule file ([D-12](./artifacts/implementation-decision-log.md#d-12-citation-phrasing-exact-yagni-rule-pattern)) and bidirectional cross-links ([D-8](./artifacts/implementation-decision-log.md#d-8-bidirectional-cross-link-between-the-yagni-pair-and-the-evidence-pair)). Track during normal skill use; reopen behavioral-analyst dispatch only if a contradiction surfaces (per [D-15](./artifacts/implementation-decision-log.md#d-15-no-behavioral-analyst-dispatch-concern-is-content-design)).
- **Out-of-scope boundary:** This plan does not import GRADE four-tier labels, does not adopt the Admiralty 6x6 axes, does not commit to a numbered source-tier ordering, does not extend the corroboration gate to codebase evidence, and does not retrofit the 7 descriptive-only single-occurrence files. Each is listed under `## Deferred (YAGNI)`.

## Team Composition and Participation

| Specialist | Status | Key Input |
|------------|--------|-----------|
| `project-manager` | Coordinator | Deterministic aggregation + final synthesis. No per-round facilitation needed (gate did not trip). |
| `junior-developer` | Reframer | Reframed the proposal as "write the pair + extract + selective retrofit"; named the `/research` extraction as load-bearing for "canonical" to hold (resolved by [D-10](./artifacts/implementation-decision-log.md#d-10-extract-researchskillmd-trust-class-block-to-cite-the-canonical-pair)); flagged the 20-file scope as needing YAGNI Gate 2 (resolved by [D-11](./artifacts/implementation-decision-log.md#d-11-selective-retrofit-behavioral-consumers-cite-descriptive-only-files-defer)); raised the no-evidence behavioral instruction (resolved by [D-7](./artifacts/implementation-decision-log.md#d-7-no-evidence-state-defer-with-reopening-trigger-named)); recommended behavioral-analyst dispatch (declined per [D-15](./artifacts/implementation-decision-log.md#d-15-no-behavioral-analyst-dispatch-concern-is-content-design)). |
| `information-architect` | Active | Recommended noun-based naming (`docs/evidence.md`) and rule-file scope ≤80 lines; defined the long-form/rule split ([D-2](./artifacts/implementation-decision-log.md#d-2-long-form--rule-file-content-split)); designed the bidirectional cross-link topology ([D-8](./artifacts/implementation-decision-log.md#d-8-bidirectional-cross-link-between-the-yagni-pair-and-the-evidence-pair)); identified the supplements-not-replaces relationship as load-bearing for vocabulary integrity ([D-12](./artifacts/implementation-decision-log.md#d-12-citation-phrasing-exact-yagni-rule-pattern)). |
| `behavioral-analyst` | Stood down | Considered for the two-rule-file interaction question; resolved as content-design per [D-15](./artifacts/implementation-decision-log.md#d-15-no-behavioral-analyst-dispatch-concern-is-content-design). |

## Implementation Approach

### Architecture and Integration Points

The work touches three layers of the plugin:

- **Operator-facing docs** (`docs/`): one new file (`docs/evidence.md`); two existing files lightly edited for cross-links (`docs/yagni.md`, `CLAUDE.md`).
- **Runtime-loaded references** (`plugin/references/`): one new file (`plugin/references/evidence-rule.md`); one existing file lightly edited for cross-link (`plugin/references/yagni-rule.md`).
- **Consuming skills and agents** (`plugin/skills/*/SKILL.md`, `plugin/agents/*.md`): one file edited for true extraction (`plugin/skills/research/SKILL.md:108–112`); 11 behavioral-consumer files edited to add the citation; 7 descriptive-only files left alone.

The pair mirrors the YAGNI pair's structure exactly ([D-2](./artifacts/implementation-decision-log.md#d-2-long-form--rule-file-content-split)) — long-form doc carries Why and the named conditions where the proximity-to-origin heuristic inverts; rule file carries prescriptive imperative content only.

### Data Model and Persistence

N/A — documentation-only change. No schema, no migration, no storage.

### Runtime Behavior

When a consumer skill or agent loads `plugin/references/evidence-rule.md`, the file provides:

- Three named principles: proximity-to-origin (as a heuristic, not a ranked tier list), corroboration multiplier, and explicit no-evidence labeling ([D-3](./artifacts/implementation-decision-log.md#d-3-three-structural-principles-named-not-numbered), [D-5](./artifacts/implementation-decision-log.md#d-5-proximity-to-origin-framed-as-directional-heuristic-never-as-a-strict-ranked-list)).
- Trust-class vocabulary (codebase = trusted current-state anchor; web = outside the trust boundary; provided = operator-supplied with interested-party scrutiny), copied verbatim from `/research/SKILL.md:108` ([D-4](./artifacts/implementation-decision-log.md#d-4-trust-class-vocabulary-copied-verbatim)).
- The corroboration gate, scoped to web sources only ([D-6](./artifacts/implementation-decision-log.md#d-6-corroboration-gate-scoped-to-web-sources-only)).
- The no-evidence-state instruction: label, defer, name the reopening trigger ([D-7](./artifacts/implementation-decision-log.md#d-7-no-evidence-state-defer-with-reopening-trigger-named)).
- An explicit relationship statement: this rule supplements (does not replace) the YAGNI inclusion test; apply YAGNI Gate 1 first ([D-12](./artifacts/implementation-decision-log.md#d-12-citation-phrasing-exact-yagni-rule-pattern)).

`/research`'s existing behavior is preserved unchanged — the inline trust-class block at `SKILL.md:108–112` is replaced by citations to the new rule file ([D-10](./artifacts/implementation-decision-log.md#d-10-extract-researchskillmd-trust-class-block-to-cite-the-canonical-pair)); the runtime semantics are identical because the rule file content originated from `/research`.

### External Interfaces

N/A — no API, queue, event, or third-party integration.

## Decomposition and Sequencing

| # | Work Unit | Delivers | Depends On | Verification |
|---|-----------|----------|------------|--------------|
| 1 | Write `docs/evidence.md` (long-form, ~120–150 lines, mirrors `docs/yagni.md` structure) | Operator-facing canonical doc. Why-section, the three principles with named inversion conditions, application table, related reading, mentor voice. | — | Self-review against `docs/writing-voice.md`; structural mirror check against `docs/yagni.md`. |
| 2 | Write `plugin/references/evidence-rule.md` (rule file, ≤80 lines, mirrors `plugin/references/yagni-rule.md`) | Runtime-loaded prescriptive rule. Three principle names, trust-class definitions verbatim from `/research/SKILL.md:108`, corroboration gate (web scope), no-evidence instruction, YAGNI-supplement statement, cross-link to YAGNI. | 1 (vocabulary consistency) | Line-count check (≤80); imperative-voice check. |
| 3 | Add `CLAUDE.md` index entry under `### Core mental model` immediately after the YAGNI line | `CLAUDE.md` lines 50–56 contain the new entry; the entry follows the existing `**[docs/FILE.md](./docs/FILE.md).** {scent}. Use when {scenario}.` pattern. | 1 | Manual diff review. |
| 4 | Cross-link YAGNI pair ↔ evidence pair (one sentence each direction in 4 files) | `docs/yagni.md`, `plugin/references/yagni-rule.md`, `docs/evidence.md`, `plugin/references/evidence-rule.md` each carry the supplements-not-replaces cross-reference. | 1, 2 | Manual diff review; each file has exactly one cross-link statement at the documented position. |
| 5 | Extract `/research/SKILL.md:108–112` — replace inline trust-class block with citations to `plugin/references/evidence-rule.md` | `/research` behavior preserved; inline definitions removed; "canonical" claim holds end-to-end. | 2 | Read `/research/SKILL.md` after edit; behavior is unchanged because content was copied verbatim into the rule file in unit 2. |
| 6 | Retrofit behavioral-consumer skills and agents with the canonical-pair citation (11 files) | Files with operational `evidence-based` language carry the citation: `iterative-plan-review/SKILL.md`, `gap-analysis/SKILL.md`, `project-manager.md`, `plan-a-feature/SKILL.md`, `investigate/SKILL.md`, `junior-developer.md`, `evidence-based-investigator.md`, `coding-standard/SKILL.md`, `architectural-decision-record/SKILL.md`, `runbook/SKILL.md`, `gap-analyzer.md`. Citation form per [D-12](./artifacts/implementation-decision-log.md#d-12-citation-phrasing-exact-yagni-rule-pattern). | 2, 5 | Each retrofitted file has the markdown link at the right relative path; existing yagni-rule citations remain unchanged. |
| 7 | Commit and push | All edits land on `canonical-evidence-resource`. | 1–6 | `git status` clean; `git push` succeeds; remote has the new commit(s). |

## RAID Log

### Risks

| ID | Risk | Likelihood | Severity | Blast Radius | Reversibility | Owner | Mitigation |
|----|------|------------|----------|--------------|---------------|-------|------------|
| R1 | A consumer skill loads both YAGNI rule and evidence rule and produces contradictory verdicts | Low | Medium | One skill output per occurrence | Fully reversible (edit rule file wording) | project-manager | The supplements-not-replaces statement in evidence-rule.md ([D-12](./artifacts/implementation-decision-log.md#d-12-citation-phrasing-exact-yagni-rule-pattern)); bidirectional cross-links ([D-8](./artifacts/implementation-decision-log.md#d-8-bidirectional-cross-link-between-the-yagni-pair-and-the-evidence-pair)). Monitor during normal skill use; behavioral-analyst dispatch retroactively if observed (per [D-15](./artifacts/implementation-decision-log.md#d-15-no-behavioral-analyst-dispatch-concern-is-content-design)). |
| R2 | `/research/SKILL.md` extraction inadvertently changes `/research`'s runtime behavior | Low | Medium | `/research` skill outputs | Fully reversible (revert commit) | project-manager | Rule file content is copied verbatim from `/research/SKILL.md:108–112` in unit 2 before unit 5 replaces it; semantics are identical by construction. |
| R3 | New docs ship in research-report voice instead of mentor voice, violating `docs/writing-voice.md` | Low | Low | Reader experience | Fully reversible (rewrite) | information-architect (drafter), project-manager (reviewer) | Self-review against `docs/writing-voice.md` before each write commits ([D-13](./artifacts/implementation-decision-log.md#d-13-trivial-decisions)). |
| R4 | Rule file exceeds 80 lines, eroding context hygiene across 10+ consumer skills | Low | Low | Per-skill load cost | Fully reversible (trim) | information-architect | Line-count gate during unit 2. If draft exceeds 80, move explanatory content to the long-form doc. |

### Assumptions

| ID | Assumption | What Changes If Wrong | Verifier | Status |
|----|------------|-----------------------|----------|--------|
| A1 | The trust-class language in `/research/SKILL.md:108` is the same conceptual primitive the new rule file extracts (no behavioral change from extraction) | Extraction silently changes `/research` behavior; existing `/research` outputs become inconsistent with prior runs | Read `/research/SKILL.md` before and after; confirm rule-file content was copied verbatim | Holds — verified during discovery |
| A2 | Behavioral-consumer files retrofitted with the new citation will not produce contradictory verdicts from YAGNI rule + evidence rule loaded together | Skills produce inconsistent decisions on the same item; user has to choose which rule "wins" | Observe during use post-ship; dispatch behavioral-analyst retroactively if violated | To verify — addressed by R1 mitigation |
| A3 | The 7 descriptive-only single-occurrence files have no operational dependency on a canonical evidence definition | Future skill author adds operational behavior to one of those files without realizing the canonical pair exists | A single-occurrence file is reported as confusing OR a future skill adds operational behavior needing the citation | To verify post-ship — reopening trigger for D-11 |

### Issues

None at plan time.

### Dependencies

None external to this branch.

## Testing Strategy

This is a documentation-only change with no runtime code paths. Verification follows the structure of YAGNI-pair changes:

- **Observable behaviors to test:** none at the code level. The verification is structural and editorial.
- **Test doubles posture:** N/A.
- **Edge cases requiring coverage:**
  - Rule file is under 80 lines.
  - Long-form doc and rule file use the trust-class phrasing verbatim from `/research/SKILL.md:108`.
  - All four cross-link sentences are present (one per file: `docs/yagni.md`, `plugin/references/yagni-rule.md`, `docs/evidence.md`, `plugin/references/evidence-rule.md`).
  - Retrofitted citations use the exact path patterns from [D-12](./artifacts/implementation-decision-log.md#d-12-citation-phrasing-exact-yagni-rule-pattern); no broken link in any of the 11 retrofitted files.
  - `/research/SKILL.md` after extraction: no inline trust-class block; citations to the rule file at the same lines.
- **Test levels:** manual review of every changed file before commit; `grep` checks for citation consistency across the 11 retrofitted files.

## Security Posture

No security surface. The work is documentation and reference-file content. No auth, no PII, no secrets, no input handling. `adversarial-security-analyst` was not dispatched and not needed.

## Operational Readiness

No runtime, no production, no observability surface. No SLO impact. No feature flag (this is documentation; it ships or it doesn't). No rollback procedure beyond `git revert`. `devops-engineer` was not dispatched and not needed.

## On-Call Resilience Posture

N/A — no application-source resilience surface.

## Definition of Done

- [ ] `docs/evidence.md` exists, written in mentor voice per `docs/writing-voice.md`, mirrors `docs/yagni.md` structure, names the three principles, names the inversion conditions for proximity-to-origin, and contains the application table.
- [ ] `plugin/references/evidence-rule.md` exists, is ≤80 lines, mirrors `plugin/references/yagni-rule.md` shape, contains trust-class vocabulary verbatim from `/research/SKILL.md:108`, scopes the corroboration gate to web sources, contains the no-evidence-state instruction, and explicitly states it supplements YAGNI's inclusion test ([D-2](./artifacts/implementation-decision-log.md#d-2-long-form--rule-file-content-split), [D-4](./artifacts/implementation-decision-log.md#d-4-trust-class-vocabulary-copied-verbatim), [D-6](./artifacts/implementation-decision-log.md#d-6-corroboration-gate-scoped-to-web-sources-only), [D-7](./artifacts/implementation-decision-log.md#d-7-no-evidence-state-defer-with-reopening-trigger-named), [D-12](./artifacts/implementation-decision-log.md#d-12-citation-phrasing-exact-yagni-rule-pattern)).
- [ ] `CLAUDE.md` `### Core mental model` index contains the entry for `docs/evidence.md` immediately after the YAGNI entry, in the established format ([D-9](./artifacts/implementation-decision-log.md#d-9-trivial-decisions)).
- [ ] Four cross-link sentences present, one per file: `docs/yagni.md`, `plugin/references/yagni-rule.md`, `docs/evidence.md`, `plugin/references/evidence-rule.md` ([D-8](./artifacts/implementation-decision-log.md#d-8-bidirectional-cross-link-between-the-yagni-pair-and-the-evidence-pair)).
- [ ] `plugin/skills/research/SKILL.md:108–112` no longer contains inline trust-class or corroboration-gate definitions; cites the rule file instead ([D-10](./artifacts/implementation-decision-log.md#d-10-extract-researchskillmd-trust-class-block-to-cite-the-canonical-pair)).
- [ ] 11 behavioral-consumer files contain the canonical-pair citation in the form `[../../references/evidence-rule.md](../../references/evidence-rule.md)` or `[../references/evidence-rule.md](../references/evidence-rule.md)` ([D-11](./artifacts/implementation-decision-log.md#d-11-selective-retrofit-behavioral-consumers-cite-descriptive-only-files-defer), [D-12](./artifacts/implementation-decision-log.md#d-12-citation-phrasing-exact-yagni-rule-pattern)).
- [ ] 7 descriptive-only files (test-planning, stakeholder-summary, plan-implementation, plan-a-phased-build, gh-pr-review, devops-engineer, behavioral-analyst) are NOT retrofitted; status recorded in `## Deferred (YAGNI)` below.
- [ ] Branch pushed; remote tracks `canonical-evidence-resource`.

## Specialist Handoffs for Implementation

- **`information-architect`** — dispatch if the rule file approaches 100 lines during drafting; needs current draft + the long-form doc draft to decide what to move where.
- **`behavioral-analyst`** — dispatch retroactively if a consumer skill is observed producing contradictory verdicts from the two rule files; needs the offending skill output and both rule files.

## Deferred (YAGNI)

### GRADE four-tier verbal labels (High / Moderate / Low / Very Low)
- **Why deferred:** Evidence test failed — `docs/research/evidence-hierarchy.md` artifact A25 (ACM SIGSOFT) explicitly rejects gold-standard hierarchies for software engineering. No Han calibration exists to apply the labels consistently.
- **Reopen when:** a documented case of an agent or skill failing because evidence quality was indistinguishable, AND the team commits to a calibration process for the labels.
- **Source:** Research O1 (not selected); IA Question 1.

### Admiralty Code 6x6 axes (source reliability × information credibility)
- **Why deferred:** Evidence test failed — research artifact A7 documents 87% of real Admiralty ratings cluster on the diagonal (axes not independent in practice). Operationalizing requires training Han users do not have.
- **Reopen when:** N/A — this option is structurally unsuitable for Han's context regardless of evidence accumulation.
- **Source:** Research O2 (not selected).

### Numbered source-tier ordering in the rule file (production > tests > codebase > commits > docs > blogs > LLM)
- **Why deferred:** Evidence test failed — research validators V5 (not flowchartable without judgment rules) and V8 (inverts in formal-methods and spec-compliance contexts) explicitly rejected the strict ordering. Simpler-version test: stating proximity-to-origin as a named heuristic ([D-5](./artifacts/implementation-decision-log.md#d-5-proximity-to-origin-framed-as-directional-heuristic-never-as-a-strict-ranked-list)) satisfies the reporter's intent without the failure modes.
- **Reopen when:** a documented case where the heuristic was unclear AND a concrete tier-boundary decision rule has been specified for each transition.
- **Source:** Research draft recommendation (rewritten via validator V5/V8); IA Question 6 Risk 2.

### Corroboration gate extension to codebase evidence in `/investigate` and adjacent skills
- **Why deferred:** Evidence test failed — research validator V9 found the gate does not transfer cleanly. The adaptation rule has not been specified. Forcing the unadapted gate would either be vacuous or reject valid single-file root-cause findings.
- **Reopen when:** an `/investigate` or `/iterative-plan-review` output produces a bad conclusion attributable to acceptance of a single-source codebase claim that an independent check would have caught.
- **Source:** Research V9; IA Question 6 Risk 3; JD Q3.

### Retrofit of descriptive-only single-occurrence files (7 files)
- **Why deferred:** Simpler-version test — these files use "evidence-based" descriptively (in prose or in an agent name) with no operational dependency on the canonical pair. Adding a citation is symmetry-for-its-own-sake, the named YAGNI anti-pattern at `plugin/references/yagni-rule.md:41–42`. Files: `test-planning/SKILL.md`, `stakeholder-summary/SKILL.md`, `plan-implementation/SKILL.md`, `plan-a-phased-build/SKILL.md`, `gh-pr-review/SKILL.md`, `devops-engineer.md`, `behavioral-analyst.md`.
- **Reopen when:** any one of the 7 files is reported as confusing without a citation, OR a future skill author adds operational behavior to one of those files that depends on the canonical primitives.
- **Source:** JD Q1/Q6; IA Question 4; [D-11](./artifacts/implementation-decision-log.md#d-11-selective-retrofit-behavioral-consumers-cite-descriptive-only-files-defer).

### Tier definitions beyond the three principles named (e.g., what counts as "running code")
- **Why deferred:** Evidence test failed — the research did not commit to specific tier definitions and the canonical pair carries no numbered tiers ([D-3](./artifacts/implementation-decision-log.md#d-3-three-structural-principles-named-not-numbered), [D-5](./artifacts/implementation-decision-log.md#d-5-proximity-to-origin-framed-as-directional-heuristic-never-as-a-strict-ranked-list)). Defining "running code in production" vs "passing test" vs "REPL reproduction" requires either GRADE-style calibration (Deferred above) or accumulated Han-specific failure-mode evidence.
- **Reopen when:** a documented case where ambiguity at a tier boundary caused inconsistent skill outputs, AND a specific tier definition would have prevented it.
- **Source:** Issue #19 open question; JD Q8.

### Behavioral-analyst dispatch for the two-rule-file interaction check
- **Why deferred:** Simpler-version test — the concern is content-design, addressed by the supplements-not-replaces statement in the rule file ([D-12](./artifacts/implementation-decision-log.md#d-12-citation-phrasing-exact-yagni-rule-pattern)) and the bidirectional cross-links ([D-8](./artifacts/implementation-decision-log.md#d-8-bidirectional-cross-link-between-the-yagni-pair-and-the-evidence-pair)). Specialist dispatch is YAGNI without a documented contradiction.
- **Reopen when:** a consumer skill observably produces contradictory verdicts from the two rule files post-ship.
- **Source:** JD specialist recommendation; [D-15](./artifacts/implementation-decision-log.md#d-15-no-behavioral-analyst-dispatch-concern-is-content-design).

## Open Items

None blocking implementation. The plan ships as written.

- **OI-1:** Post-ship validation of A2 (no contradictory verdicts from the two rule files in retrofitted consumer skills).
  - **Resolves when:** normal skill use produces no contradiction reports OR a contradiction surfaces and is addressed via the R1 mitigation path.
  - **Blocks implementation:** No — this is a post-ship monitoring concern, not a precondition.

## Summary

- **Outcome delivered:** Canonical "evidence-based" source for Han, ships on `canonical-evidence-resource`, mirrors the YAGNI pair structurally, extracts `/research`'s existing primitives so the canonical pair is the single source of truth, retrofits behavioral-consumer skills only, defers strict tiering and codebase-evidence gate extension as YAGNI candidates.
- **Team size:** 3 specialists (PM + junior-developer + information-architect) — see [artifacts/implementation-iteration-history.md](./artifacts/implementation-iteration-history.md).
- **Rounds of facilitation:** 1 — see [artifacts/implementation-iteration-history.md](./artifacts/implementation-iteration-history.md).
- **Decisions committed:** 15 (D-1 through D-15) — see [artifacts/implementation-decision-log.md](./artifacts/implementation-decision-log.md).
- **Decisions settled by evidence:** 13 (all but D-13 and D-14 which were trivially settled by codebase convention) — see [artifacts/implementation-decision-log.md](./artifacts/implementation-decision-log.md).
- **Decisions settled by junior-developer reframing:** 0 (the gate did not require reframing; JD-Q1/Q6 raised the verdict-changing categorization which was settled by codebase inspection during synthesis).
- **Decisions settled by user input:** 0 (all resolutions deterministic).
- **Rejected alternatives recorded:** 18 across the 11 full decisions — see [artifacts/implementation-decision-log.md](./artifacts/implementation-decision-log.md).
- **Open items remaining:** 1 (post-ship monitoring, non-blocking).
- **Recommendation:** Ship as planned.
