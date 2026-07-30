# Implementation Iteration History: Planning Scope Corrections

<!--
This file records how the implementation plan for Planning Scope Corrections evolved across
discussion rounds. Committed decisions live in [implementation-decision-log.md](implementation-decision-log.md)
and the primary plan lives in [../feature-implementation-plan.md](../feature-implementation-plan.md).

This file ALSO consolidates each round's aggregation. No separate facilitation files are
written. The claim ledger, Open Questions, and spec-maturity tags from each round live as
fields on that round's entry below.
-->

## Team composition

Size band: **medium**. Three plugins change (`han-planning`, `han-communication`, `han-feedback`), thirteen
commitments spread unevenly across four skills, and the change introduces a new cross-plugin capability. No
authentication, PII, or data migration surface, so it does not reach large. Team cap 5, round cap 2.

| Specialist                        | Why selected                                                                                                                        |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `han-core:project-manager`        | Coordinator and final synthesizer.                                                                                                  |
| `han-core:junior-developer`       | Generalist stress-test and reframer. Always on the team.                                                                            |
| `han-core:information-architect`  | The deliverable is prose surfaces. Where each new convention and standard lives, and whether a reader finds it, is the central question. |
| `han-core:structural-analyst`     | Coupling between four skills and the shared reference files; single-source versus duplication across three plugins.                  |
| `han-core:test-engineer`          | No automated suite exists in this repo, so how each success criterion gets verified needed a real answer rather than an assumption.  |

## R1: Parallel specialist review

- **Specialists engaged:** `han-core:information-architect`, `han-core:structural-analyst`,
  `han-core:test-engineer`, `han-core:junior-developer`. Launched in parallel with domain-scoped briefs.
- **New input provided:** The feature specification, its three companions as paths, and
  [.discovery-notes.md](.discovery-notes.md) with the directive to read it first and not re-search what it holds.

- **Claim ledger:**

| Claim                                                                                                                                        | Raised by                                    | State                    |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- | ------------------------ |
| No planning skill can copy a file, so visual-material persistence cannot execute                                                             | junior-developer                             | Evidenced (verified)     |
| No planning skill can read a GitHub work item, so the boundary read degrades on every run                                                     | junior-developer                             | Evidenced (verified)     |
| `plan-implementation` uniquely lacks `Bash(mkdir *)`, so it cannot create the visual-material folder                                          | junior-developer                             | Evidenced (verified)     |
| The boundary record, the explanation standard, and the surfacing skill are all committed to but never named                                   | information-architect, junior-developer      | Evidenced                |
| "The three that run a sweep" is true of one skill; `plan-a-feature` and `plan-a-phased-build` contain no sweep step                           | information-architect, structural-analyst    | Evidenced                |
| "The three with an escalation step" is true of two; `plan-a-phased-build` has no escalation step at all                                       | information-architect                        | Evidenced                |
| `plan-work-items`' autonomy principle forbids the stops three commitments now add to it                                                       | information-architect                        | Evidenced                |
| `plan-a-feature` produces no work units, so the justification field has nothing to attach to; only the cut list applies                       | information-architect                        | Evidenced                |
| How many new `han-planning` reference files the shared commitments need: one, three, or five                                                  | information-architect vs. structural-analyst | Disputed                 |
| The missing-artifact rule's canonical home conflicts with its four-skill scope                                                                | junior-developer                             | Disputed (resolved)      |
| The consumer inventories PNGs only, silently dropping any other supplied format                                                               | information-architect                        | Evidenced                |
| Success criterion 3 passes vacuously unless a run is engineered to produce an uninspected-input finding                                       | test-engineer                                | Evidenced                |
| Verification should be a committed acceptance checklist plus manual walkthroughs, not a script                                                | test-engineer, junior-developer              | Evidenced                |
| Ten of the fifteen commitments ship with no stated way to tell whether they landed                                                            | junior-developer                             | Evidenced                |
| A brief may not reliably add a per-finding field to an agent whose definition owns its output format                                          | junior-developer                             | Anecdotal                |
| The new `han-communication` skill fans out to two plugin manifests and one marketplace manifest beyond the documented doc obligations         | information-architect, junior-developer      | Evidenced                |
| No new plugin dependency edge is needed; `han-planning` already depends on `han-communication`                                                | information-architect, structural-analyst    | Evidenced                |
| `han-feedback` needs no dependency edge, and CONTRIBUTING's statement stays accurate                                                          | structural-analyst                           | Evidenced                |
| The vendored-only folder claim lives at `CLAUDE.md:105`, not in CONTRIBUTING, and needs a one-line correction rather than a restated convention | information-architect                        | Evidenced                |
| A single simultaneous rewrite fights the repo's actual churn; the change wants sequenced units                                                | structural-analyst, junior-developer         | Evidenced                |

- **Open Questions raised:**
  - **OQ-1:** What are the literal names for the boundary record, the explanation standard, and its surfacing skill?
  - **OQ-2:** How many new `han-planning` reference files, and what does each carry?
  - **OQ-3:** Where does the reconciled missing-artifact rule live, given D23 names a home owned by one skill while the
    single-stop rule binds all four?
  - **OQ-4:** Do the four planning skills gain `Bash(cp *)` and a work-item read tool?
  - **OQ-5:** Does the completeness gate fire in `plan-work-items`, which receives no visual material of its own?
  - **OQ-6:** Can a reviewer brief add a required per-finding field to an agent whose definition specifies its output
    format?

- **Spec-maturity tags:** plan-level 20; spec-level 0; T#-contradiction 1 (junior-developer, against T1). The gate did
  **not** trip: it requires two T#-contradictions from two distinct specialists, and the other three specialists
  explicitly recorded no contradiction with T1. The single contradiction routed through the normal Open Questions loop
  and resolved without reopening the spec, because its remedy honors T1's mechanic rather than replacing it.

- **Resolution source:**
  - OQ-1: **PM synthesis (Step 8 evidence).** Settled as an implementation naming decision.
  - OQ-2: **evidence.** Settled by grouping on interlock; see R2.
  - OQ-3: **evidence.** D23 read in full: it scopes to `plan-work-items`' own two contradicting statements, so its
    home stays local. D24 separately rejects cross-skill reference links, confirming the rule is not cited by the other
    three. The conflict dissolved. The erroneous line in `.discovery-notes.md` was corrected in place.
  - OQ-4: **user input.** See R2.
  - OQ-5: **PM synthesis (Step 8 evidence).**
  - OQ-6: **deferred as a stated risk with a named verification step.**

- **Decisions produced:** D-1, D-2, D-3, D-4, D-5, D-6, D-7, D-8, D-9, D-10, D-11, D-12, D-13, D-14, D-15, D-16
- **Changed in plan:** All sections (the plan did not exist before this round).
- **Next-step recommendation:** Continue iterating. At least one plan-level Open Question was unresolved, and OQ-4
  needed user input.

## R2: Evidence verification, reframing, and user escalation

- **Specialists engaged:** `han-core:junior-developer`, in conversational mode, on OQ-4 only.
- **New input provided:** Direct verification of the tool-grant claims against the four skill frontmatters, the
  `han-github` comparison set, and an empirical check of the host's pasted-material cache. Plus the full text of D23,
  D24, and D25.

- **Claim ledger:**

| Claim                                                                                                                                       | Raised by        | State     |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | --------- |
| `Bash(cp *)` has no substitute: `Write` emits text, `Read` renders images without returning bytes, `Glob`/`find` locate without moving        | junior-developer | Evidenced |
| No `han-core` agent carries `cp`, `gh`, or `mkdir`, so the `Agent` grant is not an escape hatch for either capability                        | junior-developer | Evidenced |
| `allowed-tools` scopes by command prefix, not by path, so `Bash(cp *)` is an unscoped copy grant                                             | junior-developer | Evidenced |
| `allowed-tools` is a permission allowlist, not a dependency declaration, so a granted-but-absent binary fails at runtime rather than cleanly | junior-developer | Evidenced |
| The `gh` gap is a convenience gap, not a capability gap: the degraded path is already specified and costs one paste in an existing turn      | junior-developer | Evidenced |
| `gh` would only ever help GitHub-issue repos; Jira and Linear reach work items through opt-in MCP servers regardless                         | junior-developer | Evidenced |
| The `cp` and `gh` grants have different risk profiles and necessity arguments and should be decided separately                               | junior-developer | Evidenced |
| T1's mechanic survives: the host does not cache pasted images as files, which is the fallback branch T1 already names                        | (verification)   | Evidenced |

- **Open Questions raised:** None new. OQ-4 was escalated to the user as two separate questions, per the reframing.

- **Spec-maturity tags:** plan-level 8; spec-level 0; T#-contradiction 0. The R1 contradiction against T1 was retired
  this round: the empirical check confirmed T1's fallback branch is the accurate description of pasted material, and
  the copy branch it commits to remains correct for material the operator already holds as a file. T1 stands unchanged.

- **Resolution source:**
  - OQ-4, work-item read: **user input.** No grant. The operator supplies the work item through the confirmation turn
    the run already takes, and `han-planning` stays filesystem-only.
  - OQ-4, visual-material copy: **user input.** Grant the copy tool, and additionally constrain every copy
    destination to the resolved plan folder in the skill's own prompt text, so the narrow intent is stated rather than
    implied by the permission line.

- **Decisions produced:** D-17, D-18
- **Changed in plan:** Constraints and Boundaries, Implementation Approach (Tool grants), Work Units and Sequencing,
  Definition of Done, Risks and Assumptions, Deferred (YAGNI)
- **Next-step recommendation:** Go to synthesis. Every Open Question is resolved or carried as a stated risk with a
  named verification step, and the round produced no major unresolved findings.

## R3: Post-synthesis scope decision on the disclosure mechanism

This round ran after synthesis, on one question the plan shipped as an open item. It is recorded as a round because it
changed a committed decision, not because the facilitation loop reopened.

- **Specialists engaged:** None dispatched. The question was investigated directly against the agent roster, then put
  to the user.
- **New input provided:** OI-1 as the plan stated it, plus a direct survey of `han-core/agents/` for output-format
  shape, existing assumptions sections, rules-list structure, and the measured set of skills that dispatch these
  agents.

- **Claim ledger:**

| Claim                                                                                                                                  | Raised by      | State     |
| ---------------------------------------------------------------------------------------------------------------------------------------- | -------------- | --------- |
| The reported failure was placement, not disobedience: specification D19 records that the reviewer did disclose, below the finding       | (verification) | Evidenced |
| Six agents already carry a `## Assumptions` section, so the section the failure used already exists                                     | (verification) | Evidenced |
| `structural-analyst` already reports dimensions it could not assess, which is the same idea in a summary rather than on a finding       | (verification) | Evidenced |
| Every agent file ends in a `## Rules` bullet list, so a placement line has a uniform insert point across all twenty-two                 | (verification) | Evidenced |
| Twelve skills across seven plugins dispatch `han-core` agents, which is the measured blast radius of any roster change                  | (verification) | Evidenced |
| Ten agents carry a `## Findings` section with per-finding fields; the rest use numbered items under `## Output Format`                  | (verification) | Evidenced |
| The proportionality signal cannot move to the agent definitions, because a target length is per-dispatch context                        | (verification) | Evidenced |

- **Open Questions raised:**
  - **OQ-7:** Should the blind-spot disclosure stay in the dispatching skills' briefs, or move into the shared agent
    definitions and accept the wider surface?

- **Spec-maturity tags:** plan-level 6; spec-level 1 (OQ-7 changes a boundary the specification's Out of Scope
  settled); T#-contradiction 0. The gate did not trip: it requires five spec-level findings from three distinct
  specialists, and this is one finding from a direct verification pass, resolved by the user rather than by fabricating
  behavior.

- **Resolution source:**
  - OQ-7: **user input.** Move the placement rule into all twenty-two agent definitions, as one line in each rules
    list, chosen for consistency across the roster and for durability against future model changes. The larger variant,
    adding a per-finding field, was rejected as unnecessary because the agents already disclose. The consequence that
    strips blocking severity stays in the two skills' briefs.

- **Decisions produced:** D-19
- **Changed in plan:** Constraints and Boundaries, Implementation Approach, Work Units and Sequencing, Definition of
  Done, Risks and Assumptions, Open Items, Specialist Handoffs for Implementation
- **Next-step recommendation:** Go to synthesis. OI-1 narrowed to the proportionality signal alone, which the
  engineered walkthrough already observes and which specification D28 already carries a designed fallback for.
