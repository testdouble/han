# Implementation Iteration History: han-communication Plugin

Round-by-round record of the `plan-implementation` team discussion. Companion files: [feature-implementation-plan.md](../feature-implementation-plan.md), [implementation-decision-log.md](implementation-decision-log.md).

- **Size:** Medium (multiple plugins/subsystems; packaging + rewire + docs coordinations; no security/data/cross-service runtime). Team cap 5, round cap 2.
- **Team:** han-core:project-manager (synthesis), han-core:junior-developer, han-core:structural-analyst, han-core:devops-engineer, han-core:test-engineer.
- **Tech-notes present:** yes (T1). T#-contradiction classification active.

## R1 (parallel specialist review)

- **Specialists engaged:** junior-developer, structural-analyst, devops-engineer, test-engineer.
- **New input provided:** feature spec + decision log + T1 + `.discovery-notes.md` (full current-state inventory).
- **Claim ledger:**
  - *Sequencing (Evidenced, junior-developer + devops-engineer):* the move is safe only in a fixed order — create+populate `han-communication` and both marketplace entries first; declare dependency edges before any rewire; rewire all 13 consumers (rename editor dispatch + drop the rule-path arg per D9); delete vendored copies and the han-core originals LAST, gated on a clean grep. Deleting or `git mv`-ing before the rewire breaks working skills.
  - *Dependency edge list (Evidenced, structural-analyst):* exactly 6 plugins add a direct `han-communication` dependency — han-core (6 consumers + edit-for-readability), han-coding (4), han-github (1), han-reporting (2), han (meta), han-atlassian (wraps 3). 4+6+1+2 = 13. han-planning/han-linear/han-feedback/han-plugin-builder add nothing. Matches D5 and the discovery inventory exactly. No cycle (han-communication efferent coupling = 0).
  - *han-core inversion (Evidenced, junior-developer + structural-analyst):* han-core has no `dependencies` key today (first dependency ever); CONTRIBUTING.md states "han-core depends on nothing" AND "all agents live in han-core" — the move falsifies both, and D7 only commits to re-deriving the first. The agent-home rule is stated in ~4 places, only 1 caught by D7's current grep seeds.
  - *Codex reconciliation (Evidenced, devops-engineer):* RECON-1 — the Codex surface already exists (`.agents/plugins/marketplace.json` + 8 `.codex-plugin/plugin.json`), on an independent version track, incomplete (no han meta, no han-linear). The plan EXTENDS it; D10's deliverables are already correct, but the spec Summary line 98 ("a whole Codex packaging surface was added") reads greenfield and should be reworded to "extended." Do not inherit the pre-existing han-linear/meta Codex gaps.
  - *Consumer break points (Evidenced, junior-developer + test-engineer):* 6 secondary template/reference files also hardcode the rule path (one at a 3-level depth) and are easy to miss; the gap-analysis size-conditional editor dispatch must survive; the 4 draft-and-self-check skills must gain the guidance invocation but NOT an editor dispatch.
  - *Verification without CI (Evidenced, test-engineer + devops-engineer):* static grep/diff checks per phase (V1-V13); a light dynamic smoke (2 real heavy consumers × 2 runs) reusing the spike's artifact-based judging; the full 46-trial spike is NOT re-run (risk retired by T1).
  - *YAGNI (Evidenced, devops-engineer + test-engineer):* no CI/observability/rollout machinery for a static markdown suite (Sentry-on-staging precedent); accept the api_retry residual risk as documented (one troubleshooting sentence), defer API-layer fault injection.
- **Spec-maturity tags:** all findings `plan-level`. Zero `T#`-contradictions. Zero `spec-level` behavioral gaps.
- **Spec-maturity gate:** NOT tripped (0 T#-contradictions; 0 spec-level findings).
- **Open Questions raised:** OQ1 (do any Codex manifests narrate dependencies?); OQ2 (han-core MAJOR vs minor bump); OQ3 (fix han-atlassian's full Codex co-requisite doc gap in this pass?).
- **Next-step recommendation:** continue iterating (resolve plan-level OQs), then synthesis.
- **Decisions produced:** D-1, D-2, D-3, D-4, D-5, D-6, D-7, D-8 — the eight full decisions rest on the R1 specialist findings (edge list → D-1; sequencing → D-2; invocation contract → D-3; Codex RECON-1 → D-4; version posture → D-5; docs sweep + agent-home exception → D-6; module layout → D-7; verification approach → D-8).
- **Changed in plan:** Implementation Approach (Architecture and Integration Points, Runtime Behavior), Decomposition and Sequencing, RAID Log, Testing Strategy, Operational Readiness, Deferred (YAGNI), Definition of Done.

## R2 (resolution)

- **Specialists engaged:** self (deterministic aggregation + evidence resolution); no new specialist launch needed (no handoffs requested).
- **Open Questions resolved:**
  - OQ1 — **evidence.** Grepped all 8 `.codex-plugin/plugin.json` descriptions and `.agents/plugins/marketplace.json`: none narrate dependencies (all generic; Codex catalog carries no descriptions). Result: zero Codex description edits.
  - OQ2 — **deferred to release.** han-core is a MAJOR-bump candidate (the `han-core:readability-editor` and `han-core:edit-for-readability` namespaces disappear, D9), but the actual bump is a `han-release` decision and the standing rule forbids unprompted bumps. The plan lists the bump candidates; it does not apply them.
  - OQ3 — **decision (include).** Fixing han-atlassian's full Codex co-requisite documentation is a one-line adjacent edit on a line Phase 5 already touches; include it while there rather than leave a known gap.
- **Spec-maturity gate:** NOT tripped.
- **Next-step recommendation:** go to synthesis.
- **Decisions produced:** D-9 (OQ3 → the trivial han-atlassian Codex co-requisite doc fix); refined D-4 (OQ1 → zero Codex description edits) and D-5 (OQ2 → version bumps deferred to release, han-core MAJOR candidate).
- **Changed in plan:** Decomposition and Sequencing (Phase 5 han-atlassian Codex fix), Operational Readiness (deferred version bumps), Open Items (OQ2 semver deferred to release).
