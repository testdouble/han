# Implementation Iteration History: han-core Restructure

This file records how the implementation plan for the han-core restructure evolved across discussion rounds.
Committed decisions live in [implementation-decision-log.md](implementation-decision-log.md) and the primary plan
lives in [../feature-implementation-plan.md](../feature-implementation-plan.md). No feature-technical-notes.md
exists for the source spec, so the T#-contradiction classification does not apply to any round.

## R1: Parallel specialist review

- **Specialists engaged:** structural-analyst, devops-engineer, information-architect, junior-developer (parallel,
  domain-scoped briefs; project-manager reserved for synthesis).
- **New input provided:** Initial feature specification, spec decision log and team findings, investigation report,
  and [.discovery-notes.md](.discovery-notes.md).
- **Claim ledger:**

  | # | Claim | Raiser(s) | Category | State |
  | - | ----- | --------- | -------- | ----- |
  | S1 | Each moving skill is a 2-4-artifact atomic unit (skill dir incl. references/, long-form doc; research-analyst adds agent + agent doc); nothing enforces the pairing automatically | structural-analyst | boundaries | Evidenced (dir listings; gap-analysis references/ confirmed) |
  | S2 | Namespace rewrites must be scoped by entity name, not plugin prefix: research/SKILL.md mixes 8 moving `han-core:research-analyst` refs with staying `han-core:codebase-explorer` / `adversarial-validator` refs; docs/agents/research-analyst.md:54 self-reference also rewrites | structural-analyst | mechanic | Evidenced (file:line) |
  | S3 | gap-analysis report template frontmatter self-identifies as `generated_by: "han-core:gap-analysis"` — a rewrite surface outside the link sweeps | structural-analyst | mechanic | Evidenced (gap-analysis/references/gap-analysis-report-template.md:6) |
  | S4 | han-atlassian's wrapper skill + doc carry ~7 prose refs beyond the one E7 invocation line, a stale install sentence (doc line 72), and a project-discovery link sharing the `han-core/docs/skills/` prefix with moving siblings — blunt replace would mis-point it | structural-analyst | mechanic | Evidenced (file:line lists) |
  | S5 | han-plugin-builder guidance cites `han-core:project-documentation` in a composition example — outside the spec's named blast radius; repo-wide grep per moved entity is required, not plugin-scoped sweeps | structural-analyst | edge-case | Evidenced (skill-composition.md:34) |
  | S6/IA-1 | The false "its skills dispatch shared han-core agents" claim exists on THREE READMEs (han-reporting:20, han-linear:16, han-feedback:15), not one; four keeper plugins retain the line | structural-analyst + information-architect (consolidated) | overlap/missed-surface | Evidenced (grep across READMEs) |
  | S7 | New-plugin scaffold has a direct copy-adapt precedent (han-planning/han-atlassian five-part shape); no new abstraction needed | structural-analyst | negative-result | Evidenced |
  | S8/JD-7 | Bundled-set and han-core-contents facts are prose-duplicated across plugin.json description, README, and marketplace.json — must be edited together per plugin; primary-platform manifest descriptions enumerate moving skills too (not just codex) | structural-analyst + junior-developer | overlap | Evidenced (marketplace.json, han/.claude-plugin/plugin.json) |
  | S9 | Index/workflows link repoints are mechanical, but workflows.md sentences need a prose re-read, not blind path swaps | structural-analyst | mechanic | Evidenced (file:line lists) |
  | S10 | Dependency graph stays a clean two-tier DAG; no cycle risk; han-core's outbound edges unchanged | structural-analyst | negative-result | Evidenced |
  | S11 | han-core/.codex-plugin keywords + all three defaultPrompt entries name moving skills; fix is content re-authoring, not link surgery | structural-analyst | mechanic | Evidenced (V3 confirmed) |
  | R1c | Marketplace sources are bare relative paths with no ref pinning; atomicity unit is the merged state of the default branch; single-PR merge satisfies "one coordinated change" | devops-engineer | sequencing | Evidenced (marketplace.json) — confirmed by OQ-1 resolution in R2 |
  | R2c | Enumerated manifest co-land set for the D13 invariant (2 new entries + descriptions + han meta deps + atlassian deps + 3 drops); one-shot jq consistency sweep before merge | devops-engineer | sequencing | Evidenced |
  | R3c | han-atlassian invocation rewrite must co-land or the atlassian upgrade shape fails OI-1 | devops-engineer | sequencing | Evidenced (SKILL.md:50) |
  | R4c/JD-1 | OI-1 needs a concrete procedure: local marketplace add of a checkout, install per shape, capture invocable set, upgrade, diff against spec commitment; recovery check via git revert -m 1 in the same run | devops-engineer + junior-developer | verification | Evidenced (procedure grounded in install docs) |
  | R5c/JD-2 | Whether /plugin update re-fetches on unchanged versions is unknowable statically; fold as the FIRST assertion of the OI-1 procedure; if it no-ops, effective release happens at han-release version bump | devops-engineer + junior-developer | verification | Evidenced (D11/D13 reconciliation) |
  | R6c | git revert of the merge is a complete recovery (pure markdown+JSON change); recovery is "on next resolve", consistent with spec Edge Cases | devops-engineer | recovery | Evidenced |
  | R7c | Release-notes deliverable is the old→new namespace map + restore step per moved skill, handed to han-release — not a CHANGELOG edit here | devops-engineer | scope | Evidenced (OI-2, D11) |
  | IA-2 | docs/agents/README.md prose (lines 4, 14) asserts han-core owns all agents but readability-editor — false once research-analyst moves; plus row repoint (line 55) | information-architect | missed-surface | Evidenced |
  | IA-3 | docs/concepts.md:217-234 carries three dependency-prose corrections beyond link repoints (slimmed han-core, dropped deps, meta bundle list) | information-architect | missed-surface | Evidenced |
  | IA-inv | Complete surface inventory grouped WU-A..WU-F with file:line targets, plus five verification grep sweeps (S1-S5) that mechanize "indexes stay complete, not counted" | information-architect | inventory | Evidenced |
  | IA-scent | han-research README frame "pre-planning knowledge work" with proposed scent lines reusing long-form summary lines; marketplace descriptions drafted for both new plugins | information-architect | content | Evidenced (F7 commitment) |
  | JD-3 | Commit/PR granularity unstated; recommend explicitly single merged change so no committed main state is inconsistent | junior-developer | sequencing | Evidenced — answered by R1c |
  | JD-4 | Sweep needs a canonical, runnable search-term list as an acceptance artifact | junior-developer | verification | Evidenced — answered by IA-inv sweeps |
  | JD-5 | New plugins need an initial version; D11 covers only existing plugins | junior-developer | ambiguity | Evidenced — resolved in R2 |
  | JD-6 | research.md's research-analyst doc link must NOT get the cross-plugin rewrite (it moves with the doc); "~19" link count under-counts | junior-developer | mechanic | Evidenced — recount in R2 |

- **Open Questions raised:**
  - OQ-1: Does the published marketplace resolve from the default branch or a pinned tag? (devops-engineer; affects atomicity unit)
  - OQ-2: Does `/plugin update` re-fetch content when catalog versions are unchanged? (devops-engineer, junior-developer)
  - OQ-3: What initial version do the new plugins start at? (junior-developer JD-5)
  - OQ-4: Do `.codex-plugin/plugin.json` manifests carry a `dependencies` field that must mirror the drops? (implicit in devops R2c item 5)
- **Spec-maturity tags:** plan-level: all claims and OQ-1/OQ-2/OQ-4; spec-level: OQ-3 only (D11 silent on new-plugin initial versions) — 1 finding from 1 specialist, far below the gate (≥5 from ≥3). T#-contradiction: n/a (no technical notes exist). **Gate did not trip.**
- **Resolution source:** see R2.
- **Decisions produced:** — (backfilled at synthesis)
- **Changed in plan:** — (backfilled at synthesis)
- **Next-step recommendation (deterministic):** Continue iterating — four plan-level Open Questions resolvable by evidence; no specialist re-engagement named.

## R2: Evidence resolution of the four Open Questions

- **Specialists engaged:** None — all four Open Questions were settled by direct codebase evidence in the Step 6
  loop; no junior-developer reframing or user escalation was needed.
- **New input provided:** Repo checks: install-command grep across README/docs, a full `.codex-plugin/plugin.json`
  read (han-planning), a `dependencies`-field grep across all codex manifests, and a per-file recount of
  `](../agents/` links in the six moving long-form docs.
- **Claim ledger (additions/updates only):**

  | # | Claim | Category | State |
  | - | ----- | -------- | ----- |
  | OQ-1r | Marketplace is added as `testdouble/han` (README.md:38, docs/choosing-a-han-plugin.md:106, plus `codex plugin marketplace add testdouble/han` README.md:71) — default-branch resolution; atomicity unit = the single merge to main (confirms R1c) | sequencing | Evidenced |
  | OQ-2r | Not statically answerable; spec OI-1 exists precisely to verify resolver behavior against a real install. Folded in as the first assertion of the OI-1 procedure (R5c). Ships as the spec's own open item, not a new one | verification | Evidenced (spec `feature-specification.md#open-items`) |
  | OQ-3r | New plugins start at `1.0.0` on both platforms: han-communication (the most recent new plugin) is 1.0.0 in marketplace.json and plugin.json, and codex manifests are versioned 1.0.0 across the suite | convention | Evidenced (marketplace.json; han-planning/.codex-plugin/plugin.json:3) |
  | OQ-4r | No codex manifest carries a `dependencies` field (grep across all nine returned none) — dependency edits touch only `.claude-plugin/plugin.json`; codex edits are prose/keywords/prompts only | mechanic | Evidenced (grep result) |
  | JD-6r | Link recount: 23 `](../agents/` links across the six moving docs (3+5+5+3+7+0; gap-analysis has 7, not 6). 22 rewrite to the cross-plugin form; research.md's research-analyst link stays relative and moves with the doc | mechanic | Evidenced (grep -c per file) |

- **Open Questions raised:** None new. OQ-1, OQ-3, OQ-4 resolved; OQ-2 folded into the spec's existing OI-1.
- **Spec-maturity tags:** plan-level: all. Gate did not trip. (OQ-3, tagged spec-level in R1, resolved at plan
  level by suite convention without fabricating behavior — the spec's D11 governs only existing plugins.)
- **Resolution source:** OQ-1: evidence. OQ-2: evidence (spec OI-1 + devops R5c). OQ-3: evidence (precedent).
  OQ-4: evidence.
- **Decisions produced:** — (backfilled at synthesis)
- **Changed in plan:** — (backfilled at synthesis)
- **Next-step recommendation (deterministic):** Go to synthesis — zero unresolved Open Questions, most recent
  round produced no new findings and no major findings.
