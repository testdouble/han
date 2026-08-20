# Review Team Roster and Briefs

## Contents

- The roster
- Specialists deliberately excluded from the default roster
- Domain-scoped briefs
- The shared brief every specialist receives

The specialist roster for the spec-stage review round, the domain-scoped brief each specialist receives, and the shared
brief text every one of them gets. Step 6 of the skill selects from this file; it does not restate it.

## The roster

Always include `han-core:junior-developer`, which surfaces hidden inconsistencies, muddied scope, and assumptions.
Select the remaining specialists by matching domain to feature, under the size cap from Step 5.5.

| Specialist                              | Select when the feature touches                                                                                                                                                                                           |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `han-core:user-experience-designer`     | Any user-facing flow, UI, or interaction model.                                                                                                                                                                           |
| `han-core:adversarial-security-analyst` | Authentication, authorization, PII, untrusted input, or secrets, at the behavioral attack-surface level. Deep exploit-path work moves to `plan-implementation`.                                                           |
| `han-core:devops-engineer`              | Rollout, feature flags, observability, SLO behavior, or operational affordances.                                                                                                                                          |
| `han-core:on-call-engineer`             | Resilience commitments the spec must make: idempotency on retried operations, timeout and deadline behavior, graceful degradation when a dependency is down, kill switches, named failure-mode coverage. Spec level only. |
| `han-core:edge-case-explorer`           | Boundary values, input messiness, or state-dependent failures.                                                                                                                                                            |
| `han-core:test-engineer`                | What observable behaviors the spec commits to making testable. Test-double and collaborator-boundary framing is deferred to `plan-implementation`.                                                                        |
| `han-core:gap-analyzer`                 | A PRD or reference spec exists to compare the draft against.                                                                                                                                                              |
| `han-core:risk-analyst`                 | Significant blast radius, where risks need prioritizing.                                                                                                                                                                  |

Extra agents named in the project config's `## Extra Agents` list join this pool and compete under the same
domain-to-feature matching and size cap, per [`config-rule.md`](../../../references/config-rule.md). Select one only
when the feature touches its stated specialty, count it against the cap, brief it with the spec sections relevant to its
domain, and skip an entry that does not resolve to a dispatchable agent with a one-line note.

## Specialists deliberately excluded from the default roster

`han-core:structural-analyst`, `han-core:behavioral-analyst`, `han-core:concurrency-analyst`,
`han-core:software-architect`, and `han-core:system-architect` are not on the spec-stage roster.

The analysts target module boundaries, runtime data flow, and concurrency primitives. The architects synthesize those
findings into intra-codebase or cross-service topology recommendations. All of it belongs to `plan-implementation`.

Include one only if the user explicitly asks. When you do, warn them that the specialist may surface
implementation-level findings the spec will not absorb, and that such findings get deferred to `plan-implementation`
rather than edited into the spec.

## Domain-scoped briefs

Pass each agent only the spec sections relevant to its domain, plus pointers. Do not hand every agent the full artifact
set.

| Specialist                              | Spec sections to include                                                                                                                                  |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `han-core:user-experience-designer`     | Outcome, Primary Flow, User Interactions, Edge Cases (UX-relevant rows only)                                                                              |
| `han-core:adversarial-security-analyst` | Outcome, Coordinations, Edge Cases, any sections touching auth, PII, or secrets                                                                           |
| `han-core:devops-engineer`              | Outcome, Coordinations, Out of Scope, Open Items                                                                                                          |
| `han-core:on-call-engineer`             | Outcome, Primary Flow, Alternate Flows, Edge Cases, Coordinations (sections touching idempotency, retries, timeouts, kill switches, graceful degradation) |
| `han-core:edge-case-explorer`           | Outcome, Primary Flow, Alternate Flows, Edge Cases                                                                                                        |
| `han-core:test-engineer`                | Outcome, Primary Flow, Alternate Flows, Edge Cases                                                                                                        |
| `han-core:gap-analyzer`                 | Source PRD or reference spec, plus the draft spec under review                                                                                            |
| `han-core:risk-analyst`                 | Outcome, Coordinations, Edge Cases (risk-relevant rows only)                                                                                              |
| `han-core:junior-developer`             | Outcome, plus the first paragraph of every section                                                                                                        |

Alongside those sections, every agent gets:

- The file paths to all artifacts, so it can read further on its own: `{folder}/feature-specification.md`,
  `{folder}/artifacts/decision-log.md`, `{folder}/artifacts/team-findings.md`,
  `{folder}/artifacts/scope-boundary.md`, and `{folder}/artifacts/feature-technical-notes.md` when it exists.
- The list of decisions already made, as `D#` titles only rather than full entries.
- A specific question framed for its domain.
- The path to each item in `{folder}/ui-designs/` and the state each one shows, with an instruction to read them. The
  material goes to every reviewer rather than only the design specialist, because which reviewer is most harmed by the
  omission varies by feature. A design specialist reviewing a design-driven feature without the designs is reviewing a
  paraphrase.
- The directive: read additional sections only if your domain needs context not in the excerpts above, and cite what you
  read.
- An instruction to cite sections by filename and heading, so findings cross-reference precisely. For example
  `feature-specification.md#primary-flow`, `D4` in `artifacts/decision-log.md`, or `T3` in
  `artifacts/feature-technical-notes.md`.

## The shared brief every specialist receives

Pass this verbatim, in addition to the domain-specific question.

> Review the spec at the behavioral level only. Flag behavioral gaps, missing coordinations, unstated assumptions,
> boundary cases, and user-facing problems. Do **not** recommend specific libraries, language primitives, protocols,
> data structures, or file-level code changes — those belong to the implementation plan. If you find a section that
> leaks implementation mechanics (language primitives, function names, library mechanics, file/line references), raise
> it as a **"mechanics leaking into spec"** finding regardless of your primary domain.
>
> Apply the YAGNI rule per [yagni-rule.md](../../../references/yagni-rule.md). For every behavior, alternate flow, edge
> case, coordination, or open item the spec commits to, ask: what evidence supports including it now (user-described
> need, named direct dependency, existing code path that breaks, applicable regulation, documented incident or measured
> metric)? If no accepted evidence applies, raise it as a **`Category: YAGNI candidate`** finding. Apply the rule's
> named anti-patterns as auto-flags: "for future flexibility", symmetry or completeness, "when we scale", speculative
> observability, runbooks for never-fired alerts. When evidence does justify an item but a strictly simpler version
> would satisfy the same evidence, recommend the simpler version.
>
> Scope your report to the size of the work being specified. This feature descends from the work item recorded in
> `artifacts/scope-boundary.md`; read it. A report closer to {target} lines than {ten times target} is the right shape
> here. That is a target rather than a cap: if you have more worth saying, say it, but do not pad to fill a section
> list.
>
> Where a finding of yours rests on an input you could not inspect, say so on the finding itself, in the form your own
> definition specifies. A disclosure in an assumptions section below the finding does not travel with it, and this skill
> reads each finding where it stands.

Fill in `{target}` with a rough line count matched to the work item's size, rather than a size word the reviewer has to
interpret. For a one-card ticket, name a report closer to 150 lines than 750. This signal governs how much each reviewer
writes and never how many reviewers you choose; the team cap in Step 5.5 owns that and is unaffected.
