# Implementation Iteration History: Code-Review Skill Guardrails

This file records how the implementation plan for the code-review guardrails evolved across discussion rounds. Committed decisions live in [implementation-decision-log.md](implementation-decision-log.md) and the primary plan lives in [../feature-implementation-plan.md](../feature-implementation-plan.md).

The iteration loop is capped at two rounds for this medium-sized plan. The deterministic next-step recommendation after Round 1 was "go to synthesis" — all Open Questions were resolved via evidence, reframing, or reasonable-call user defaults under the user's "work without stopping" directive — so no Round 2 was needed.

## R1: Parallel specialist review

- **Specialists engaged:** software-architect, behavioral-analyst, test-engineer, junior-developer. Each received a domain-scoped brief plus a path to `artifacts/.discovery-notes.md` and was instructed to read the discovery notes first and only grep further for what the discovery notes did not cover.

- **New input provided:** Initial source spec (`investigation.md`), discovery notes (`artifacts/.discovery-notes.md`), and the three PR evidence bundles plus the behavioral trace. R1 is the initial sweep.

- **Claim ledger:**

| Claim | State | Sources | Spec-maturity |
|---|---|---|---|
| Size-based demotion has no authoritative home — defined in Step 3.3 but contradicted at line 24, in the classification rubric, and in two agent bodies. | Evidenced | SA-1 | plan-level |
| Step 7 needs explicit numbered sub-steps (7.1 read, 7.2 demote, 7.3 reachability, 7.4 rubric) before S2 and S10 are inserted into it. | Evidenced | SA-2 | plan-level |
| S1/S2 interaction rule (when does S2's demotion fire?) is the most contested mechanic in the plan. | Disputed | SA-3 (anchor to Step 3.3 "directly introduced" vocabulary), BA-4 (use reachability phrase list, same as S10), JD-005 (any phrase-match is fragile; needs structured signal) | plan-level |
| S3 and S4 should be scoped as Step 3.5 dispatcher directives, not global agent-body edits, because the four affected agents are dispatched by other skills outside `/code-review`. | Evidenced | SA-4, JD-007, JD-008, JD-014 | plan-level |
| S1 and S13 must ship in the same commit; S2 and the Step 7 sub-step structure must ship in the same commit; S5/S6 and the dispatcher-directive form of S3/S4 must ship in the same commit. | Evidenced | SA-5 | plan-level |
| S12 ("Optional: replace mode flags with explicit defaults") is redundant after S1 + S2 + S13 ship. | Evidenced | SA-6, BA-9, JD-006 | plan-level (YAGNI candidate) |
| `$focus_areas` and `$branch_context` need explicit named bindings; the plan currently relies on LLM context-window retention across Step 1, Step 1.5, Step 3.5. | Evidenced | BA-1, JD-003, JD-004 | plan-level |
| S6's `gh pr view` call requires `Bash(gh *)` in `SKILL.md`'s `allowed-tools` frontmatter, which is not currently listed. | Evidenced | JD-013 (verified by grep — SKILL.md:6 currently reads `allowed-tools: Bash(git *), Bash(make *), Bash(npm *), Read, Grep, Glob, Agent`) | plan-level |
| S6's lookup must declare fail-open behavior explicitly and warn the user when no context could be loaded. | Evidenced | BA-2 | plan-level |
| S6's planning-directory lookup needs a structured CLAUDE.md key + fallback like the existing Step 1 project-config resolution. | Evidenced | BA-8 | plan-level |
| `{size}` is read from one write point (Step 3.1) and consumed by five later sites; the plan must make the single-source-of-truth explicit. | Evidenced | BA-3 | plan-level |
| S2 and S10 both target Step 7 and both demote findings on rationale signals. The cleanest implementation merges them into one Step 7.2 sub-step using the reachability phrase list (BA-4). | Evidenced (resolves the SA-3/BA-4/JD-005 dispute) | BA-4, BA-5 | plan-level |
| S3 alone has no observable severity-reduction effect — Step 7's rubric re-promotes agent self-labeled SUGG to WARN. S3 only matters if S1 ships in the same version. | Evidenced | BA-7 | plan-level |
| S7 must update three YAGNI-bearing locations in SKILL.md, not two (Review Constraints lines 29–41, Step 3.3 calibration directive, review-checklist.md). | Evidenced | JD-010 | plan-level |
| S8 needs an explicit extraction pass producing `{task-id, file-path, line-range, recommended-action-summary}` tuples before pair comparison can run. S8's scope is structural contradictions (overlapping line ranges) only; semantic cross-file contradictions are deferred. | Evidenced | BA-6, JD-015 | plan-level |
| S9's "infer the premise from the standard's examples" fallback is the failure mechanism, not a fix. S9 must require reading at least one architectural file demonstrating the premise before raising the finding. | Evidenced | JD-012 | plan-level |
| Long-form docs in `docs/skills/code-review.md` and the four affected `docs/agents/*.md` must be updated alongside the plugin changes per CLAUDE.md convention. The investigation does not name these as edits; the plan must. | Evidenced | JD-001 | plan-level (scope item) |
| A `CHANGELOG.md` entry and a `plugin.json` version bump are required for this branch per `docs/guidance/semantic-versioning.md`. The investigation does not capture this. | Evidenced | JD-002 | plan-level (scope item) |
| Verbatim text copied from the investigation (which uses em-dashes throughout) into shipped files must have em-dashes stripped per `docs/writing-voice.md`. | Evidenced | JD-009 | plan-level (style constraint) |
| The implementation sequence buried in the investigation's "What the investigation does not cover" section should be promoted into the implementation plan as a first-class section. | Evidenced | JD-011, SA-5 | plan-level |
| Test plan: 5 P0 acceptance tests (PR 299/307/339 outcomes + SEC cross-reference regression + data-isolation regression), 12 P1 per-solution behavior tests, 2 P2 cross-project/Mode-B tests. Manual execution only; automated harness is YAGNI. | Evidenced | TP-1 through TP-21 + TP YAGNI candidates | plan-level |

- **Open Questions raised:**

  - **OQ-1: Are `docs/` mirror updates in scope for this branch?** (JD-001) → Resolution source: user-input via reasonable-call default. Resolved as: yes, in scope. The five long-form docs (`docs/skills/code-review.md`, `docs/agents/structural-analyst.md`, `docs/agents/behavioral-analyst.md`, `docs/agents/junior-developer.md`, `docs/agents/edge-case-explorer.md`) are listed as a work unit in the plan. User may redirect.
  - **OQ-2: Minor or major version bump?** (JD-002) → Resolution source: user-input via reasonable-call default. Resolved as: minor (2.2.0 → 2.3.0). The skill name, argument signature, and output-format structure are unchanged; only behavior is calibrated. CHANGELOG entry required. User may redirect.
  - **OQ-3: How does S2's pre-classification demotion gate fire?** (SA-3 / BA-4 / JD-005 dispute) → Resolution source: junior-developer reframing combined with BA-4's mechanical analysis. Resolved as: merge S2 and S10 into a single Step 7.2 sub-step that demotes on a documented reachability phrase list ("theoretical", "hypothetical", "defense-in-depth", "effectively impossible", "in case the upstream", "could happen", "should never happen", "edge case that does not occur"). This replaces the investigation's "skip when directly introduced" rule. SA-3's vocabulary-anchoring concern is addressed by the merged sub-step also reading Step 3.3's calibration directive for criteria when applicable. JD-005's structured-signal concern is deferred as YAGNI; reopen if phrase-matching proves insufficient in post-ship validation.
  - **OQ-4: Does SKILL.md `allowed-tools` need `Bash(gh *)` added for S6?** (JD-013) → Resolution source: evidence. Confirmed via grep: SKILL.md:6 currently reads `allowed-tools: Bash(git *), Bash(make *), Bash(npm *), Read, Grep, Glob, Agent`. `Bash(gh *)` is not present. S6 must add it. Resolved.
  - **OQ-5: S3/S4 as dispatcher directives or global agent-body edits?** (SA-4 / JD-007 / JD-014 consensus) → Resolution source: specialist consensus across three agents plus evidence (V4 already says outward reads are context-only, not findings; V8 already supports lowered default severity without removing the "include when in doubt" rule). Resolved as: scope all four edits as Step 3.5 dispatch-prompt additions in SKILL.md, not as edits to the four agent definition files. The agent definitions remain general-purpose for use by other skills.
  - **OQ-6: Is S12 redundant after S1+S2 ship?** (SA-6 / BA-9 / JD-006 consensus) → Resolution source: specialist consensus. Resolved as: defer S12 to `## Deferred (YAGNI)` with reopen trigger "post-ship validation against PR 299 still shows severity inflation requiring a SUGG-suppress mode flag."
  - **OQ-7: Does S9's "infer the premise from examples" fallback actually fix C9?** (JD-012) → Resolution source: junior-developer reframing. Resolved as: strengthen S9 to require reading at least one architectural file (entry-point, config, router, navigation surface — whichever is most relevant to the standard's topic) before raising the finding. The "infer from examples" path becomes a fallback that triggers an explicit "premise not verified — finding omitted" note in the agent output, not a forward path.
  - **OQ-8: Is S8's file-path + line-range overlap sufficient detection?** (JD-015) → Resolution source: scope acknowledgment. Resolved as: yes for the WARN-002/WARN-003 contradiction class on overlapping line ranges in a single file. S8's documented limitation: it does not detect semantic contradictions across non-overlapping file regions or across files. Cross-file semantic contradiction detection is deferred as YAGNI; reopen if a real review exhibits this failure mode post-ship.

- **Spec-maturity tags:**
  - `plan-level`: 23 findings (everything raised by all four specialists).
  - `spec-level`: 0 findings. No specialist tagged any claim as "spec is silent" or "undefined behavior in the spec." The investigation already commits to S1–S13 and to the C# causes; all R1 findings concern *how* to implement those commitments.
  - `T#-contradiction`: 0 (no `feature-technical-notes.md` exists for this work — the source is an investigation, not a `plan-a-feature` spec — so the T# concept does not apply).
  - **Spec-maturity gate did NOT trip.** The gate requires ≥ 2 `T#`-contradictions raised by ≥ 2 specialists, or ≥ 5 `spec-level` findings raised by ≥ 3 specialists. Neither condition holds. No PM facilitation-gate-trip pass was made.

- **Resolution source per question:**

| OQ | Resolved by |
|---|---|
| OQ-1 (docs scope) | user-input default — reasonable call under user's "work without stopping" directive |
| OQ-2 (version bump) | user-input default — reasonable call |
| OQ-3 (S2 mechanic) | reframing (junior-developer's restatement of the question) + specialist analysis (BA-4) |
| OQ-4 (allowed-tools) | evidence (`grep -n "allowed-tools" plugin/skills/code-review/SKILL.md` confirmed the gap) |
| OQ-5 (S3/S4 scope) | specialist consensus (SA-4 + JD-007 + JD-014 + corroborating V4/V8 from the source spec) |
| OQ-6 (S12 YAGNI) | specialist consensus (SA-6 + BA-9 + JD-006) + YAGNI Gate 2 simpler-version test |
| OQ-7 (S9 fix) | reframing (junior-developer identified inference-from-examples as the failure mechanism, not a fix) |
| OQ-8 (S8 scope) | scope acknowledgment (the proposed mechanism handles the named PR 339 contradiction class; broader is YAGNI) |

- **Decisions produced:** D-1 through D-21. Full decisions: D-1 (Step 3.3 authoritative home), D-2 (Step 7 sub-step structure), D-3 (merged S2+S10 reachability gate), D-4 (S3/S4 as dispatcher directives), D-5 (atomic shipping pairs and sequencing), D-6 (minor version bump 2.2.0 to 2.3.0), D-7 (docs mirror in scope), D-8 (allowed-tools gh grant), D-9 (S6 fail-open warning), D-10 (planning-directory lookup format), D-11 (S7 three-location rewrite), D-12 (S8 extraction-pass scope), D-13 (S9 architectural-file read), D-14 ($focus_areas and $branch_context named bindings), D-15 ({size} single source of truth at Step 3.1), D-16 (defer S12 as YAGNI), D-17 (em-dash strip policy), D-18 (narrower S4 wording for edge-case-explorer). Trivial decisions: D-19 (commit S1), D-20 (commit S5), D-21 (commit S11).

- **Changed in plan:** All plan sections written for the first time in this round: Source Specification, Outcome, Context, Team Composition and Participation, Implementation Approach (Architecture and Integration Points, Runtime Behavior; Data Model and External Interfaces marked not applicable), Decomposition and Sequencing, RAID Log, Testing Strategy, Security Posture (not applicable), Operational Readiness, Definition of Done, Specialist Handoffs for Implementation, Deferred (YAGNI), Open Items, Summary. R1 is the initial sweep; everything in the plan derives from R1 findings and the deterministic resolution.

- **Project-manager next-step recommendation (deterministic):** **Go to synthesis.** Rationale: spec-maturity gate did not trip; all OQs resolved via evidence, reframing, or user-input default; no specialist named a needed handoff to a specialist not already engaged; the next round would produce no new findings because the dispute (OQ-3) is resolved and no specialist requested re-engagement with new context.
