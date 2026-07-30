# Team Findings: Personal Han Configuration

Two reviewers raised eleven findings, and every one is resolved. Behavioral outcomes live in
[../feature-specification.md](../feature-specification.md), the decisions they affected live in
[decision-log.md](decision-log.md), and the one load-bearing mechanic lives in
[feature-technical-notes.md](feature-technical-notes.md).

Reviewers: `han-core:junior-developer` (identifiers `JD-n`) and `han-core:edge-case-explorer` (identifiers `EC-Fn`).

## Major findings

### F1: The personal file's position in the existing precedence chain was unstated

- **Agent:** han-core:junior-developer, han-core:edge-case-explorer
- **Reviewer identifiers:** JD-001, EC-F2
- **Finding:** the draft described the merge as two files overriding each other and never said where the personal file
  sits relative to the CLAUDE.md `## Project Discovery` section and the project-discovery file, which the chain already
  consults. Both reviewers noted this is the common case rather than a corner: most projects carry a CLAUDE.md and few
  carry `.han/config.md`, so the unstated branch is the one most `output-directory` resolutions take. The two-file
  description the finding names comes from D1 and D3; neither changed as a result, because the gap was a missing
  statement rather than a wrong one.
- **Resolution:** escalated to the operator as E3 and settled as D9. The Primary Flow now writes the whole chain out as a
  numbered list in place of the two-file description.
- **Resolved by:** user input
- **Affected decisions:** D9
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Alternate Flows and States

### F2: Removing the output-directory guard also changed shipped project-file behavior, in a table cell

- **Agent:** han-core:junior-developer, han-core:edge-case-explorer
- **Reviewer identifiers:** JD-002, EC-F1, EC-F5
- **Finding:** the draft's edge-case row said an output directory is created "whether it sits inside the project or
  outside it" without naming which file declared the value, so the natural reading relaxed the containment guard for the
  project file too. That contradicted the same draft's claim that a project-only run "behaves exactly as it does today,"
  and it silently invalidated a published sentence in `docs/configuration.md`. The same ambiguity covered `~` and `..`
  acceptance. One reviewer proposed the strictly simpler version: relax the rules for the personal file only.
- **Resolution:** the operator's answer to E2 chose one uniform rule with the cost named, so the uniform reading stands
  and the simpler version is recorded as a rejected alternative on D8. What changed is visibility: the guard removal moved
  from a table cell into the Outcome section, the "behaves exactly as it does today" claim now names its exception, and
  the operator guide is named as part of the work.
- **Resolved by:** evidence
- **Affected decisions:** D8, D11
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Alternate Flows and States, Edge Cases and Failure Modes, Coordinations

### F3: An unreachable configuration directory was folded in with a file nobody wrote

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-003
- **Finding:** the draft specified silence for the not-found case, which covers both a person who never wrote a personal
  file and a run that could not see one that exists. The second is a degradation, and the failure this feature is most
  likely to produce is settings that quietly did not apply.
- **Resolution:** settled as D10. A run cannot tell the two apart, so any warning would fire for everyone with no
  personal file, which is the larger group. The specification now says so out loud instead of leaving it implicit, and a
  file that is present but unreadable still gets its note under the existing rule.
- **Resolved by:** evidence
- **Affected decisions:** D10
- **Affected tech-notes:** T1
- **Changed in spec:** Edge Cases and Failure Modes

### F4: The size-band announcement had no way to say which file supplied the band

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-004
- **Finding:** the draft extended the file label to degradation notes only. The existing rule also requires a skill
  adopting a configured size band to announce it with the configuration named as the source, and that message fires on
  every successful sizing run. With two files sharing a name, it now points at an ambiguous path.
- **Resolution:** D7 widened from "degradation notes" to every message about configuration, on both the success and
  failure paths.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** —
- **Changed in spec:** User Interactions

### F5: Nothing said the change lands in every configuration-reading skill, or that the guide is part of done

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-005
- **Finding:** the Coordinations table named "every Han skill that reads configuration" as a property rather than as
  work, so the specification's definition of done was unfalsifiable. A partial rollout is worse than none, because a
  person cannot predict which run honors their settings. The operator guide currently documents one file and a guard that
  is going away.
- **Unverified:** the reviewer could not inspect what an implementation plan intends for the vendored rule copies or the
  guide, because no implementation plan exists in this folder yet. The spec-completeness half of the finding stands on
  its own; the rollout-sequencing half rests on that uninspected input.
- **Resolution:** settled as D11 and stated in the Coordinations section, with the guide added as an outbound
  coordination. Sequencing and file mechanics stay with `plan-implementation`.
- **Resolved by:** evidence
- **Affected decisions:** D11
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations

### F6: A project cannot ask for Han's built-in writing voice once a personal one is set

- **Agent:** han-core:edge-case-explorer
- **Reviewer identifiers:** EC-F3
- **Finding:** in the single-file world, a blank or absent `writing-voice` means "keep the built-in profile," so blank is
  itself an instruction. Under per-setting merge, omitting the key falls through to the personal value and an explicit
  blank does too, leaving a project no value that means "use Han's own voice here." A shared or open-source project
  wanting stock voice regardless of a contributor's preference has no way to say so.
- **Resolution:** deferred under the YAGNI rule. Giving a project that power means adding a reserved value to the schema,
  and nobody has described needing it. Recorded in the specification's Deferred section with its reopening trigger.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Deferred (YAGNI)

### F7: Two separate problems, one per file, left the note count undefined

- **Agent:** han-core:edge-case-explorer
- **Reviewer identifiers:** EC-F4
- **Finding:** D7 rejected two notes for one problem, but the two-layer model can produce two genuinely separate
  ignorable events for the same setting name in one run, such as a stale value in the personal file and a typo in the
  project file. The draft did not say whether that produces one note or two, leaving the operator unable to find one of
  the two problems.
- **Resolution:** D7 now distinguishes the two cases. One problem gets one note naming its file; two problems get two
  notes, because each names a different thing to fix.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F8: Both lookups can resolve to the same file

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-007
- **Finding:** running a Han skill inside your own Claude Code configuration directory makes both lookups find one
  physical file. Per-setting merge is harmless there, but the additive extra-agents list and its counted-once rule depend
  on the identity of the file rather than of the entry. Low frequency, and exactly the case someone hits while authoring
  or debugging a personal configuration.
- **Resolution:** added an edge-case row. The file is read once and treated as the project configuration.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F9: A personal size band widens the scope of a settled decision record

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-006
- **Finding:** the record that introduced a configurable default swarm size weighed its cost at one project, on the
  strength of a need for a standing project default. A personal setting changes the blast radius to every project a
  person touches, so that record will read narrower than the shipped behavior.
- **Resolution:** recorded as open item OI-1 rather than resolved here. The behavior is settled; what is open is which
  document records why, and that is a documentation call rather than a specification one.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Open Items

### F11: Two edge-case rows restated the extra-agents rule already in force

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-009
- **Finding:** the rows for an unresolvable agent name and for the same agent in both files restated the existing
  contract with "both files" prepended. Neither changes behavior in the two-file world, and both will drift from the
  canonical rule. Raised as a YAGNI candidate under symmetry and completeness.
- **Resolution:** replaced with the simpler version the reviewer recommended, a single row stating that the combined list
  is treated as one list under the rule already in force.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

## Minor edits

- F10: The Summary overstated how evidence-grounded and how settled the specification was, counting decisions by trust
  class rather than by whether the run had to ask, and claiming zero open items before review had run — han-core:junior-developer — Summary

## Escalation register

### E1: Where should a file path in the personal configuration point?

- **Answer:** a relative path is rooted at the personal configuration file's own location, and full paths are accepted,
  including `~` and `..` expansions.
- **Landed in:** [D5](./decision-log.md#d5-a-relative-path-is-rooted-at-the-file-that-declares-it), and the Primary Flow
  section of the specification.

### E2: Does `output-directory` accept a full path as well, or stay inside the project?

- **Answer:** it accepts a full path. The operator overrode the recommendation to keep the containment guard.
- **Landed in:** [D8](./decision-log.md#d8-a-configured-path-may-point-anywhere-in-either-file), the Outcome section, the
  Edge Cases and Failure Modes table, and the Deferred (YAGNI) section.

### E3: Where does the personal file sit relative to the project's CLAUDE.md?

- **Answer:** the personal file wins over CLAUDE.md, sitting directly beneath the project configuration.
- **Landed in:** [D9](./decision-log.md#d9-the-personal-file-sits-directly-beneath-the-project-file-in-the-chain), and
  the Primary Flow and Alternate Flows sections of the specification.
