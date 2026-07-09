# Team Findings: han-communication Plugin

<!--
This file records every finding raised by the review team for the han-communication
plugin, and how each was resolved. Behavioral outcomes live in
[../feature-specification.md](../feature-specification.md); decisions the findings
affected live in [decision-log.md](decision-log.md). No feature-technical-notes.md
exists for this feature — no load-bearing mechanic qualified (the one relevant
mechanic, cross-plugin file-read scoping, is discoverable from the repo's guidance
and is cited on D3 instead).

Review team: han-core:junior-developer, han-core:information-architect,
han-core:gap-analyzer.
-->

## Major findings

### F1: Delegation replaces three inline uses of the standard, not one

- **Agent:** junior-developer
- **Finding:** The readability rule is applied in three inline stages that all read the reference file — an audience frame that shapes drafting (skills apply it "as they write"), a discrete end-of-run self-check, and the editor rewrite dispatch. The draft spec only accounted for the rewrite dispatch, and its Out-of-Scope line claimed behavior was "preserved." Removing the vendored file breaks the drafting-time application in most prose skills and the self-check in ~9 skills.
- **Resolution:** Reframed D4 as full delegation replacing all three inline uses; the user chose full delegation. Updated the spec Outcome, the Alternate Flow, and Out of Scope to state the change honestly.
- **Resolved by:** user input
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Alternate Flows and States, Out of Scope

### F2: Inline self-check breaks in ~9 skills, not the four D4 named

- **Agent:** junior-developer
- **Finding:** The original D4 scoped "skills with a self-check" to only the four that had no rewrite pass. But the rewrite-pass skills (research, code-review, stakeholder-summary, update-pr-description) also run a standardized self-check that reads the rule file inline, and those self-checks break too when the file is removed.
- **Resolution:** D4 now covers every prose-producing consuming skill: all drop the inline self-check and delegate a rewrite pass.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States

### F3: "No middle path" was overstated

- **Agent:** junior-developer
- **Finding:** The original D4 claimed adding a rewrite pass was forced with "no middle path that keeps 'no vendoring.'" A middle path exists: several skills already inline the self-check criteria as skill-native prose (not a vendored rule file), so a lightweight self-check could be retained without a vendored copy. The one gap is criterion 5 (the writing-voice blocklist), which lives in the moved file.
- **Resolution:** Recorded the hybrid as a genuine rejected alternative on D4 and surfaced it to the user, who consciously chose full delegation for a single source of truth. Removed the "forced" framing.
- **Resolved by:** user input
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** —

### F4: Transitive resolution asserted as fact while unverified

- **Agent:** junior-developer
- **Finding:** The Edge Cases table stated the opt-in plugins get `han-communication` transitively "through their dependency on han-core" as settled behavior, while OI-1 flags that same resolution as unconfirmed. The repo guidance documents only one-level dependency auto-install, not transitive resolution. `han-atlassian` genuinely needs the capability (it wraps prose skills), so the risk is real, not formal.
- **Resolution:** Reworded the Edge Cases row to state the requirement behaviorally and mark transitive resolution as unconfirmed, pointing at OI-1; added a caveat to D5 naming the explicit-dependency fallback. Kept OI-1 open (non-blocking; fallback is cheap).
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes, Open Items

### F5: "Behavior is preserved" contradicts D4

- **Agent:** junior-developer
- **Finding:** Out of Scope said "the capability's behavior is preserved," which is true for the editor agent but false for consuming skills, which gain a rewrite dispatch and lose in-voice drafting.
- **Resolution:** Reworded Out of Scope to scope preservation to the editor agent's rewrite behavior and state the consuming-skill change explicitly.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Changed in spec:** Out of Scope

### F6: CONTRIBUTING.md teaches vendoring the move abolishes

- **Agent:** information-architect, gap-analyzer
- **Finding:** CONTRIBUTING.md's "Wiring the readability standard into a skill" section is a step-by-step procedure that instructs contributors to copy the rule byte-for-byte into a plugin's `references/` and read it inline — the exact pattern D3 eliminates. A link repoint leaves the wrong procedure in place; this is confidently wrong guidance, worse than a dead link.
- **Resolution:** D7 expanded to require a content rewrite of this section (and the related "Writing voice" link) to the delegation model, plus the D5 dependency requirement.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** —
- **Changed in spec:** —

### F7: CLAUDE.md asserts vendored copies that will be deleted

- **Agent:** information-architect
- **Finding:** CLAUDE.md's "Writing voice" section states the profile is "vendored byte-identical into han-coding, han-github, han-reporting," the "Voice is uniform" convention links the han-core copy, and the project-map tree describes the vendored reference dirs. All become false after the move.
- **Resolution:** D7 expanded to require rewriting these sections to name a single canonical copy in `han-communication` with no vendored copies, and updating the project-map tree comments.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** —
- **Changed in spec:** —

### F8: Repo-maintenance skills reference the profile by path, outside all prior scope

- **Agent:** gap-analyzer
- **Finding:** `.claude/skills/han-release/references/changelog-rules.md` and `.claude/skills/han-update-documentation` (`SKILL.md` + `scope-mapping.md`) hard-reference `han-core/references/writing-voice.md` by path. These repo-local maintenance skills sit outside D5's plugin inventory and the original D7 doc-scope, and the doc-audit skill's own scope excludes `.claude/skills/**`, so they would break silently.
- **Resolution:** D7 expanded to include the repo-maintenance skills in the update scope.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** —
- **Changed in spec:** —

### F9: D7 under-scoped the stale-pointer inventory

- **Agent:** information-architect, gap-analyzer
- **Finding:** Beyond the two indexes and the project map, the move touches ~17 inbound links to the relocating long-form docs, the docs' own outbound sibling links, `docs/readability.md` (13 pointers; the operator-facing standard hub linked from the README), `docs/concepts.md`, the `han-core:readability-editor` qualified-name strings in ~9 operator docs (a seam between the doc-pointer scope and the invocation-site scope), five skill-internal template files that hardcode the rule's relative path, and `.github/pull_request_template.md`. New `docs/skills/han-communication/` and `docs/agents/han-communication/` directories and index sections are required, and the empty "Editing & readability" subsection under han-core must be removed.
- **Resolution:** D7 expanded into four explicit classes (relocated docs, inbound links, canonical/qualified-name pointers, vendoring instructions and tooling) covering the full inventory; the new directories and index restructuring are named.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** —
- **Changed in spec:** —

### F10: Do not rewrite historical artifacts

- **Agent:** information-architect
- **Finding:** `CHANGELOG.md` and `docs/research/**` reference the old locations as point-in-time state. A blanket grep-and-replace would corrupt the historical record; the changelog would misstate what prior versions shipped and research evidence rows would misrepresent the codebase state at research time.
- **Resolution:** D7 gained an explicit guard excluding CHANGELOG and research docs from the repoint sweep, and a requirement to add a new CHANGELOG entry for the extraction instead.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** —
- **Changed in spec:** —

## Minor edits

- F11: Runtime mechanic (cross-plugin file-read scoping) leaked into the spec's Deferred section; trimmed to the behavioral claim, mechanic kept on D3 — junior-developer — Deferred (YAGNI)
