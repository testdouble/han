# Team Findings: code-overview

<!--
Behavioral outcomes live in ../feature-specification.md; decisions the findings affected
live in decision-log.md. feature-technical-notes.md was not created — no load-bearing
mechanic qualified during specification or finding resolution (the codebase-explorer
agent, the sizing model, version-control diff access, the scratch-file output pattern,
and Mermaid are all discoverable from the repo).

Review team (size: small — single new skill, one subsystem, no auth/PII/data surface):
han-core:junior-developer (always) + han-core:information-architect (the deliverable is
a text-first, progressively-disclosed document whose whole value is reader comprehension).
All findings were resolved by evidence during Step 7; none required user escalation. The
partial-coverage decision (F11) is a product judgment the user can override.
-->

## Major findings

### F1: Target resolution order is unspecified for ambiguous strings

- **Agent:** han-core:junior-developer (JD-001)
- **Finding:** Mode is inferred from the target's shape, but no precedence is stated when one string matches more than one shape (a branch named `utils` when a `utils/` directory exists; a short symbol that also matches a filename). The skill could silently pick the wrong mode with no error.
- **Resolution:** Added a target-resolution precedence to D2 and the spec: explicit pull-request reference or URL first, then an existing file or directory path, then a symbol; the current branch's changes only when no target string is given. A string that matches nothing is reported as unresolved (see F-row in edge cases).
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F2: "Minimal technical detail" has no concrete ceiling, and the where-to-start section needs a specificity floor

- **Agent:** han-core:junior-developer (JD-002), han-core:information-architect (IA-6)
- **Finding:** The only quality gate (D5) is "minimal technical depth," with no concrete bound, so two runs on the same target could differ wildly; applied uniformly, it also strips the where-to-start section of the specificity it needs to be actionable.
- **Resolution:** Scoped the minimal-detail constraint to the purpose, flow, and context sections (no function signatures, data-shape definitions, or configuration values there) and gave the where-to-start / what-to-watch sections a specificity floor: they must name the concrete entry points — the specific files or components — the operator would open first.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Primary Flow

### F3: PR-mode "what to pay attention to" straddles the zero-findings boundary

- **Agent:** han-core:junior-developer (JD-003), han-core:information-architect (IA-8)
- **Finding:** A section titled "what to pay attention to when reviewing" is one sentence from risk-flagging, which would collapse the boundary with `code-review` (D1) and make the skill a half-review.
- **Resolution:** Constrained the section to navigational, complexity-topology framing — it names where the change is hardest to follow and why (which areas touch the most other code, which need the most context) — and explicitly forbids quality or risk evaluation. D1's zero-findings claim now holds.
- **Resolved by:** evidence
- **Affected decisions:** D1, D6
- **Affected tech-notes:** —
- **Changed in spec:** PR mode

### F4: The no-target default and the PR-unreachable edge case describe the same git state with conflicting outputs

- **Agent:** han-core:junior-developer (JD-004) — the one blocking finding
- **Finding:** A bare invocation on a branch with local commits but no remote pull request satisfies both the "default to the current branch's changes (PR mode)" flow and the "pull request cannot be reached → offer code mode" edge case, which prescribe opposite behaviors.
- **Resolution:** PR mode runs on the current branch's changes (the local diff); a remote pull request is required only when the operator explicitly names a pull-request reference. Narrowed the edge-case row to two distinct cases: an explicitly named pull request that cannot be reached, and a bare invocation with no changes at all.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** No target named, Edge Cases and Failure Modes

### F5: Git availability is an unstated precondition

- **Agent:** han-core:junior-developer (JD-005)
- **Finding:** PR mode and the branch-diff default both depend on git, but the Preconditions section lists only the target's existence; `code-review` states the dependency and has a no-git fallback.
- **Resolution:** Added git availability to Preconditions and stated the behavior when git is absent: code mode against a named target still runs; PR mode and the bare-invocation default report that they need git.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers, Edge Cases and Failure Modes

### F6: The skill's reliance on the exploration agent for PR-mode synthesis outpaces what that agent does

- **Agent:** han-core:junior-developer (JD-006)
- **Finding:** The exploration agent's job is discovering implementation details of a feature or system (code-mode language); the spec leaned on it for PR-mode synthesis (grouping changes by intent, charting the change's flow), which it does not natively do.
- **Resolution:** Clarified in D4 and the spec that the skill itself performs the synthesis (the grouping, the charts, the orientation) in both modes; exploration is dispatched only to discover the surrounding code and context the synthesis draws on. No agent extension is required.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, PR mode, Coordinations

### F7: The "bottom line" heading carries no information scent

- **Agent:** han-core:information-architect (IA-1)
- **Finding:** "Bottom line" is internal shorthand; opened cold, the heading does not predict its content, so a scanning reader reads the prose to learn what kind of answer is there.
- **Resolution:** Renamed the lead section to a content-bearing heading — "What it does and why" (code mode) / "What this change does and why" (PR mode).
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, PR mode

### F8: Flow charts have no required scope statement

- **Agent:** han-core:information-architect (IA-2)
- **Finding:** A chart placed early cannot stand alone without saying what it covers — the whole target, one entry point, the happy path — especially for a partially-covered large target.
- **Resolution:** Required each chart to carry a one-line scope label naming what it represents and, for partial coverage, what it intentionally excludes.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, PR mode

### F9: The two modes' output structures are non-parallel without justification

- **Agent:** han-core:information-architect (IA-3), han-core:junior-developer (JD-009)
- **Finding:** The chart sits second in code mode but third in PR mode, and the final actionable-handoff sections carry unrelated labels, so a reader who learns one mode must re-learn the scan pattern for the other.
- **Resolution:** Aligned both modes to a shared grammar — lead purpose section, then grouped/flow detail, then an actionable handoff with parallel labeling. PR mode keeps grouped-changes before the change-flow chart, and D6 now states why (the reviewer must know what changed before the change-flow chart is meaningful); the lead section and the handoff section are parallel across modes.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, PR mode

### F10: "Directly-related context and uses" conflates two distinct reader tasks

- **Agent:** han-core:information-architect (IA-4)
- **Finding:** "Context" (what to understand before touching the code) and "uses" (where it is invoked, the blast radius) answer different questions; bundled, neither is scannable.
- **Resolution:** Named them as distinct sub-components in D6 and the spec — context = what the target depends on and must be understood first; uses = where it is invoked — presented together for small targets and separable for larger ones.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F11: The partial-coverage behavior lacks a wayfinding contract and risks over-building

- **Agent:** han-core:information-architect (IA-5), han-core:junior-developer (JD-007, YAGNI candidate)
- **Finding:** IA: a partial overview gives the reader no document-level signal that the picture is incomplete or where the gaps are. JD: the partial-coverage behavior could be over-built; a simpler "report too large and stop" satisfies the same need.
- **Resolution:** Kept partial output — refusing to produce anything contradicts the job-to-be-done (accelerate understanding) — but applied the simpler-version test to the *disclosure*: a single named coverage note placed immediately after the lead section and before the first chart, present only when coverage is partial, naming what was not covered and the next size up. No partial-coverage scoring algorithm is specified; the skill explores highest-signal-first as the sizing model already implies.
- **Resolved by:** evidence (user may override toward "report too large and stop")
- **Affected decisions:** D4, D6
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F12: "Changes grouped by intent" has no grouping criterion and no degenerate case

- **Agent:** han-core:information-architect (IA-7)
- **Finding:** "Intent" is undefined (functional purpose? change type? affected layer?), risking a category fiction; and for a single-logical-unit change the grouping is noise.
- **Resolution:** Defined intent in D6 as the reader-visible outcome each group of changes delivers (what a reviewer would say changed and why), not by file, layer, or author motivation; and specified the degenerate case — a single logical change is presented as one narrative with no grouping header.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Affected tech-notes:** —
- **Changed in spec:** PR mode

### F13: The overview document has no self-identification frame

- **Agent:** han-core:information-architect (IA-9)
- **Finding:** Opened out of context (a scratch file revisited later, or two overviews from one session), the document cannot say which target and mode it describes.
- **Resolution:** Required a short document header before the lead section naming the target, the mode, and the generation context.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

## Minor edits

- F14: The `/tmp/` path leaked into D3's rationale as if it were the behavioral decision; the behavioral commitment is "a scratch location outside the repository" with the directory left to implementation — softened D3's rationale, spec unchanged (already behavioral). — han-core:information-architect (IA-10) — decision-log.md D3
