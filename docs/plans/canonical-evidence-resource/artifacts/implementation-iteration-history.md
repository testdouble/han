# Implementation Iteration History: canonical-evidence-resource

## R1: Parallel specialist review (small team)

- **Specialists engaged:** `information-architect`, `junior-developer`. `project-manager` held for synthesis only per skill Step 5 (gate did not trip).
- **New input provided:** Source artifact (`docs/research/evidence-hierarchy.md` — research report standing in for `feature-specification.md`), discovery notes (`artifacts/.discovery-notes.md`), the YAGNI canonical pair (`docs/yagni.md`, `plugin/references/yagni-rule.md`) as the model to mirror, and the existing `/research` primitives (`plugin/skills/research/SKILL.md:108–112`, `plugin/agents/research-analyst.md`) as the source of the language to canonize.
- **Claim ledger:**

  | # | Claim | Source | State |
  |---|-------|--------|-------|
  | C1 | Mirror YAGNI pair structure: long-form doc carries Why and context; rule file carries prescriptive imperative content only | IA, JD | Evidenced (`docs/yagni.md`, `plugin/references/yagni-rule.md`) |
  | C2 | Name the pair `docs/evidence.md` + `plugin/references/evidence-rule.md` (noun, not adjective; not "hierarchy") | IA | Evidenced (Rosenfeld/Morville controlled vocabulary; LATCH labeling) |
  | C3 | Add `CLAUDE.md` index entry alongside YAGNI in `### Core mental model` | IA | Evidenced (`CLAUDE.md:50–56`) |
  | C4 | Cross-link YAGNI pair ↔ evidence pair (one sentence each direction) | IA | Evidenced |
  | C5 | Three structural principles canonized: proximity-to-origin (directional, not strict), corroboration, no-evidence labeling | IA, research O7 | Evidenced (`docs/research/evidence-hierarchy.md#recommendation`) |
  | C6 | Trust classes (codebase / web / provided) copied verbatim from `/research/SKILL.md:108` to keep controlled vocabulary | IA | Evidenced |
  | C7 | Corroboration gate scoped to web sources only; codebase-evidence extension deferred per V9 | IA, JD, research | Evidenced (`docs/research/evidence-hierarchy.md#v9`) |
  | C8 | No strict tier ordering in rule file (V5, V8 risk) | IA, JD | Evidenced |
  | C9 | Rule file ≤80 lines for context hygiene (loaded by 10+ consumer skills) | IA | Evidenced (`han.plugin-builder/skills/guidance/references/skill-building-guidance/context-hygiene.md`, `progressive-disclosure.md`) |
  | C10 | Categorize the 20 "evidence-based" occurrences into behavioral consumers (cite the canonical pair) vs descriptive-only (defer as YAGNI candidate) | JD, IA | Evidenced (YAGNI Gate 2) |
  | C11 | Extract `/research/SKILL.md:108–112` trust-class block to cite the canonical pair (true extraction, not parallel definition) | JD | Evidenced — load-bearing for "canonical" claim to hold |
  | C12 | Rule file explicitly states it supplements YAGNI's inclusion test (Gate 1) and does not replace it; YAGNI answers "is there any evidence?", evidence-rule answers "how confident in it?" | IA, JD | Evidenced (avoids vocabulary collision on "acceptable evidence") |
  | C13 | No-evidence state: defer with reopening trigger named, parallel to YAGNI's defer pattern | JD, research O7 | Evidenced (`docs/yagni.md:113`, `plugin/references/yagni-rule.md:80–93`) |
  | C14 | Citation phrasing matches yagni-rule pattern exactly: `[../../references/evidence-rule.md](../../references/evidence-rule.md)` from skills; `[../references/evidence-rule.md](../references/evidence-rule.md)` from agents | IA | Evidenced |
  | C15 | Writing voice: docs follow `docs/writing-voice.md`; research-report voice shifted to mentor voice | JD, IA | Evidenced (`docs/writing-voice.md`, `CLAUDE.md` voice uniformity rule) |
  | C16 | `behavioral-analyst` dispatch NOT required — the two-rule-file interaction concern is content-design, addressed by C12's explicit relationship statement in the rule file | PM-deterministic | Evidenced — JD's specific scenarios resolve once C12 is implemented |

- **Open Questions raised:**
  - OQ1 — Which of the 20 consumer files use "evidence-based" behaviorally vs descriptively? (JD-Q1/Q6; verdict-changing for retrofit scope) → resolved by codebase inspection during synthesis: see D-11 in `implementation-decision-log.md`.
  - OQ2 — How is the YAGNI-supplements relationship stated in the rule file? (JD-Q4, IA risk 1) → resolved by D-12.
  - OQ3 — Update `/research/SKILL.md:108–112` to cite the canonical pair? (JD-Q5) → resolved Yes, see D-10.
  - OQ4 — Explicit writing-voice review step? (JD-Q7, IA Risk 5) → resolved by D-13.
  - OQ5 — What does an agent do in the no-evidence state? (JD-Q8) → resolved by D-7.
  - OQ6 — Dispatch `behavioral-analyst` for two-rule-file interaction? (JD specialist recommendation) → resolved No, see D-15.

- **Spec-maturity tags:** Plan-level: 6 (all resolvable in plan stage via evidence and synthesis). Spec-level: 0. T#-contradiction: N/A (no `feature-technical-notes.md` exists — T# tagging suppressed per skill Step 1 detection). **Gate did not trip.**

- **Resolution source:** OQ1 = evidence (codebase grep); OQ2 = evidence (IA recommendation + JD reinforcement); OQ3 = evidence (JD argument, no counter); OQ4 = evidence (writing-voice doc exists); OQ5 = evidence (YAGNI's defer pattern is the precedent); OQ6 = reframing (the concern is content-design, addressed by C12).

- **Decisions produced:** D-1 through D-15 (see `implementation-decision-log.md`).

- **Changed in plan:** Source Specification; Outcome; Context; Team Composition and Participation; Implementation Approach (Architecture and Integration Points; Runtime Behavior; External Interfaces); Decomposition and Sequencing; RAID Log; Testing Strategy; Definition of Done; Deferred (YAGNI); Open Items; Summary.

- **Project-manager next-step recommendation:** Go to synthesis. Spec-maturity gate did not trip. All Open Questions resolvable deterministically in plan stage. Single round sufficient at small-team cap.
