# Implementation Iteration History: Personal Han Configuration

How the implementation plan evolved. Committed decisions live in
[implementation-decision-log.md](implementation-decision-log.md) and the primary plan lives in
[../feature-implementation-plan.md](../feature-implementation-plan.md).

One round ran, which is the cap for a small-band feature. Both specialists confirmed the committed mechanic in `T1`, no
contradiction was raised, and the spec-maturity gate could not trip with a two-specialist team.

## R1: Parallel specialist review

- **Specialists engaged:** `han-core:devops-engineer` (identifiers `R#`), `han-core:junior-developer` (identifiers
  `JD-###`). `han-core:project-manager` was not called for facilitation, because the gate did not trip.
- **New input provided:** the feature specification and its four spec-stage artifacts, plus
  [.discovery-notes.md](.discovery-notes.md) carrying the measured surface (40 SKILL.md probes, 12 byte-identical
  vendored rule copies, the operator guide, the one ADR, the lint and test setup, and the documented probe-exit-code
  incident). No visual material exists, per the boundary record.

- **Claim ledger:**

| ID    | Claim                                                                                                                                        | Raised by       | State                                                                                     |
| ----- | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------- | ------------------------------------------------------------------------------------------- |
| CL-1  | No probe in the suite contains a `$`, and the repo's own loader guidance neither blesses nor bans parameter expansion, so the probe shape this feature needs has never been shipped. | R1, JD-001      | Unverified. Both authors recorded that the Claude Code loader's classifier is closed-source and absent from this repository. Cannot be build-blocking. |
| CL-2  | If the loader silently declines to expand the variable, the probe still exits 0 and injects nothing, so the feature does nothing, forever, with no error. | R1              | Evidenced. `D10` deliberately removes the one message that would distinguish "not found" from "never written". |
| CL-3  | Two probe shapes satisfy `T1`: one nested expansion on one line, or three simpler probes plus prose that resolves them. | R2              | Evidenced. `context-injection-commands.md:52` allowlists `echo`; `:106-111` documents the `2>/dev/null \|\| echo ""` guard. |
| CL-4  | A `cat` probe injects file content, but `D5` relative rooting and the same-file edge-case row both need the resolved directory as a value. Nothing produces one. | JD-002          | Evidenced. `feature-specification.md#primary-flow` step 5 and the "Both lookups resolve to the same file" row. |
| CL-5  | Two probe lines both labeled `.han/config.md` would make `D7` unimplementable, so the two reads need distinct labels applied identically across 40 files. | JD-003          | Evidenced. `D7` requires every message to name its file.                                  |
| CL-6  | The fan-out is roughly sixty files, not the two categories the specification names.                                                           | JD-004, R4, R5  | Evidenced. Counts re-verified during discovery; the eight further documents were enumerated by path. |
| CL-7  | Four greps at review time make an incomplete fan-out detectable, and the 12 vendored copies currently share one checksum, so it is a real passing invariant to assert against. | R4              | Evidenced. `md5 -q han-*/references/config-rule.md \| sort -u` returns one hash today.    |
| CL-8  | A grep sweep provably cannot reach the prose copies, because the two writing-voice sentences are worded differently.                          | R5, JD-006      | Evidenced. `readability-guidance/SKILL.md:44` and `edit-for-readability/SKILL.md:75` carry different sentences. |
| CL-9  | The Coordinations row and the two skills describe different designs for who resolves the writing-voice path, and double-rooting is a live failure. | JD-006          | Evidenced. Both texts read and compared.                                                  |
| CL-10 | `config-rule.md` needs six separate edits, including its title and the section `D8` deletes outright, then reproduced byte-identically eleven times. | JD-007          | Evidenced. Sections enumerated from the file.                                             |
| CL-11 | `D11` guarantees everywhere-or-nowhere within one release, but the suite ships as independently-versioned plugins, so a user with a partial upgrade gets the outcome `D11` rejects. | R6, JD-008      | Evidenced. `docs/semantic-versioning.md`; plugin versions currently span 1.0.0 to 5.0.0.  |
| CL-12 | A project already carrying a refused `output-directory` starts writing to that path on upgrade, with no signal at the moment it starts working. | R7              | Evidenced. `han-core/references/config-rule.md` containment section; `D8` removes it.     |
| CL-13 | Across two commits, either landing order is wrong: rules first means skills resolve a file they are never handed, probes first means content arrives with no instruction. | JD-009          | Evidenced. These are content files read at load time.                                     |
| CL-14 | Nothing says what expands `~` in a configured path. Tools do not; shells do; 13 of the 40 skills declare no `Bash`. | JD-010          | Evidenced. `allowed-tools` counted across the 40 skills.                                  |
| CL-15 | Whether a Bats check for fan-out completeness is justified.                                                                                   | JD-005 vs R8    | Disputed. `JD-005` proposes one check on the strength of the documented incident; `R8` argues the same incident would not have been caught by a text-equality test and the greps satisfy the evidence for no new machinery. |
| CL-16 | `han-feedback/skills/han-feedback/SKILL.md` hardcodes `~/.claude/han-feedback/` and hits the exact hazard `T1` describes.                     | R8 (out of scope verdict) | Evidenced, and out of scope. Cited against the recorded boundary, naming no replacement. |

- **Open Questions raised:** OQ-1 (does a probe resolving the configuration directory actually load); OQ-2 (how the
  resolved directory reaches the run as a value); OQ-3 (do the readability skills still resolve the writing-voice path);
  OQ-4 (does done include the eight further documents, plus versions and CHANGELOG); OQ-5 (how anyone observes the
  rollout was complete).
- **Spec-maturity tags:** plan-level 5 (OQ-1 through OQ-5); spec-level 0; `T#`-contradiction 0. Both specialists
  returned an explicit **confirm** verdict on `T1`, each citing the machine where `CLAUDE_CONFIG_DIR` and `~/.claude`
  both exist and point at different places. The gate did not trip and could not: it needs three distinct specialists.
- **Resolution source:**
  - OQ-1: evidence. Not an operator question. It is an empirical check, and the plan makes it the first work unit with
    both outcomes pre-decided, per `R3`.
  - OQ-2: evidence. The resolved directory is injected alongside the file content; `R2`'s shape B already carries the
    line that does it.
  - OQ-3: evidence. The Coordinations row's own consistency requirement settles it. The skill that reads the
    configuration resolves the path and hands an absolute path onward, so the two skills keep resolving and their
    sentences change root rather than moving the responsibility.
  - OQ-4: evidence. Documents the change makes false are a necessity of the asked-for work rather than added scope, and
    this repository already carries a documentation-sweep skill that owns exactly that pass. Versioning belongs to the
    release skill; the plan records the recommended bump rather than making it.
  - OQ-5: evidence, resolving the `CL-15` dispute in `R8`'s favor. The YAGNI evidence test fails for the Bats check:
    the one documented incident was a byte-identical line that was wrong everywhere, which a text-equality check would
    have passed. The greps satisfy the same need with no new machinery.
- **Decisions produced:** D-1 through D-14. Every decision in
  [implementation-decision-log.md](implementation-decision-log.md) came out of this round: the full decisions D-1
  through D-10, and the four trivial decisions D-11 through D-14.
- **Changed in plan:** the whole of [../feature-implementation-plan.md](../feature-implementation-plan.md), which was
  written from this round's output. Outcome, User Stories, Constraints and Boundaries, Implementation Approach, Work
  Units and Sequencing, Definition of Done, Testing Strategy, Operational Readiness, Risks and Assumptions, Cut for
  Scope, Deferred (YAGNI), Open Items, Sources and Plan Records, and Recommendation. Security Posture, On-Call
  Resilience Posture, and Specialist Handoffs for Implementation were confirmed empty and omitted: no specialist
  contributed a threat vector or an application-source resilience measure, and no specialist needs re-engaging during
  implementation.
- **Project-manager next-step recommendation:** Go to synthesis. Every Open Question resolved by evidence, no
  escalation reached the operator, and the small band caps the loop at one round.

## Unaudited evidence classes

- The Claude Code skill loader's command classifier, supporting `D-1` and `D-2`. Neither specialist could inspect it,
  because it is closed-source and not present in this repository. This is why `CL-1` is labeled Unverified and why the
  plan opens with a live check rather than an assumption.
