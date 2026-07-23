# Team Findings: Project-Local Han Configuration

This file records every finding raised by the review team for Project-Local Han Configuration, and how each was
resolved. Behavioral outcomes live in [../feature-specification.md](../feature-specification.md); decisions the
findings affected live in [decision-log.md](decision-log.md); load-bearing mechanics live in
[feature-technical-notes.md](feature-technical-notes.md).

Review team: junior-developer, edge-case-explorer, gap-analyzer (medium-size feature, three specialists).

## Major findings

### F1: Output-directory semantics were undefined

- **Agent:** junior-developer (also raised as "asserted without evidence" by gap-analyzer)
- **Finding:** The spec treated "output directory" as one monolithic value without saying whether it flattens every
  skill's output into one folder or redirects a base that preserves each skill's structure — the feature's core
  override had undefined behavior. The gap-analyzer separately flagged the auto-creation behavior as a commitment with
  no decision-log home.
- **Resolution:** New decision D14: the value is a base directory relative to the project root; skills keep their own
  folder and file structure beneath it; the directory is created on first write. Grounded in the originating need
  ("write all markdown outputs to `.scratch/`") and the suite's structured multi-file deliverables.
- **Resolved by:** evidence
- **Affected decisions:** D14 (new)
- **Affected tech-notes:** T1
- **Changed in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes.

### F2: Spec and tech notes disagreed on global versus per-skill extra agents

- **Agent:** junior-developer
- **Finding:** The Primary Flow read as one global extra-agents list while T1 said "optionally grouped per skill" —
  two different behaviors.
- **Resolution:** One global list in v1; signal-based selection already filters agents irrelevant to a skill's domain.
  Per-skill grouping deferred with a named trigger in the spec's Deferred section. T1 and D5 updated to agree.
- **Resolved by:** evidence (simpler-version test)
- **Affected decisions:** D5
- **Affected tech-notes:** T1
- **Changed in spec:** Primary Flow; User Interactions; Deferred (YAGNI).

### F3: Displacement of default specialists under the cap was an unstated consequence

- **Agent:** junior-developer
- **Finding:** "Compete under the same caps" means a selected extra agent can push a default specialist out of a
  capped team, and the spec never said so.
- **Resolution:** Stated plainly in Primary Flow step 5: displacement is intended and happens without comment. It is
  the meaning of the user's chosen option (capped competition over cap-exempt addition); a per-run displacement notice
  would reintroduce the noise D12 avoids.
- **Resolved by:** evidence (follows from the user's D5 choice)
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow.

### F4: Where the config is discovered was undefined for subdirectory and monorepo runs

- **Agent:** junior-developer and edge-case-explorer (independently)
- **Finding:** "Project root" was never defined behaviorally. The existing probe convention resolves from the working
  directory, so a skill run from a nested package would silently miss a repo-root config while the spec promised
  "every skill honors it."
- **Resolution:** New decision D15: discovery is from the skill's working directory, matching every existing
  project-context source. Monorepo packages carry their own file; the no-config-here-but-one-exists-elsewhere case is
  now an explicit edge-case row (behaves as absent).
- **Resolved by:** evidence (codebase convention)
- **Affected decisions:** D15 (new)
- **Affected tech-notes:** T1
- **Changed in spec:** Primary Flow; Alternate Flows and States; Edge Cases and Failure Modes.

### F5: No containment or usability rule for the output-directory value

- **Agent:** edge-case-explorer (also raised by junior-developer; blank-value case raised separately by
  edge-case-explorer)
- **Finding:** Nothing addressed a value resolving outside the project (absolute path, traversal, stray leading
  slash), an unwritable path, or a recognized key with a blank value — plausible hand-authoring accidents with
  data-integrity consequences.
- **Resolution:** Containment rule in D14: values outside the project or unwritable are refused with a one-line note
  and the skill falls back to its default location; deliverables are never written outside the project. Blank or
  unusable values fall through the precedence chain with a note, per D9. Three edge-case rows added.
- **Resolved by:** evidence
- **Affected decisions:** D14, D9
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes; Out of Scope.

### F6: The boundary between "malformed" (note) and "only prose" (silent) was fuzzy

- **Agent:** junior-developer (non-text content case from edge-case-explorer folded in)
- **Finding:** A file that is all prose has no valid header block — the spec gave no rule deciding whether that gets
  the malformed-content note or the silent only-prose treatment. Non-text file content was likewise unaddressed.
- **Resolution:** Crisp rule added to D9 and the edge-case table's preamble: a note appears only when content that
  attempts a recognized override cannot be used; content the suite has no use for is passed over silently. Non-text
  content degrades the same way as unparseable content.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes.

### F7: The CLAUDE.md pointer had no lifecycle after the config file goes away

- **Agent:** edge-case-explorer (dedup-basis ambiguity from junior-developer folded in)
- **Finding:** A pointer written into CLAUDE.md would dangle forever if `.han/config.md` were later deleted, and the
  dedup rule was undefined against a contributor-edited pointer line.
- **Resolution:** D10 extended: discovery never adds a pointer when any reference to the file is already present,
  however edited, and offers to remove a stale pointer when the file is gone — with the same consent rule as creation.
  The alternate flow was renamed "Discovery keeps the pointer honest" and covers both directions.
- **Resolved by:** evidence
- **Affected decisions:** D10
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States; Coordinations; Edge Cases and Failure Modes.

### F8: Duplicate, skill-named, and self-referencing extra-agent entries were unhandled

- **Agent:** edge-case-explorer
- **Finding:** The edge table only covered names that fail to resolve — not an entry duplicating a roster agent
  (double-counted against the cap?), a name matching only in different casing, a skill name mistaken for an agent, or
  the running skill itself.
- **Resolution:** Two behaviors added to D5 and the edge table: a duplicate has no effect (one candidate, counted
  once), and anything that does not resolve to a dispatchable agent — including skill names and self-references —
  gets the standard skip-with-note. Exact name-matching rules are implementation detail left to plan-implementation.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow; Edge Cases and Failure Modes.

### F9: An oversized config file is read on every run

- **Agent:** edge-case-explorer
- **Finding:** Every skill run reads the whole file, so pasted long notes impose a recurring context cost across the
  entire suite for that project; the spec had no size behavior.
- **Resolution:** Keep-it-small guidance stated in User Interactions ("everything in it is read on every skill run").
  A hard size limit or truncation rule fails the evidence test today and is deferred with a measured-bloat reopening
  trigger.
- **Resolved by:** evidence (YAGNI simpler-version)
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** User Interactions; Deferred (YAGNI).

### F10: All-skills participation challenged as a YAGNI candidate

- **Agent:** junior-developer
- **Finding:** For skills that neither write configurable deliverables nor dispatch agents, the added config read
  delivers no behavior; the research's 26-skill scope was the strictly simpler version, and the reviewer asked for the
  user's choice to be reconfirmed rather than silently kept.
- **Resolution:** The decision stands on the user's explicit choice, made earlier in this session with the trade-off
  presented (the narrower scope was the recommended option and the user chose full coverage). Recorded on D4 rather
  than re-asked; the challenge is surfaced in the final presentation for conscious reconfirmation.
- **Resolved by:** user input (prior, explicit)
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** —

### F11: The precedence order's "validate in use" caveat had no follow-up mechanism

- **Agent:** gap-analyzer
- **Finding:** The research flagged the precedence order as a design proposal to validate in use (V4), and the spec
  gave the equally-flagged A13 constraint an open item (OI-1) but gave V4 nothing.
- **Resolution:** OI-2 added: post-ship validation of the config-beats-CLAUDE.md direction, with a
  surprised-user-report trigger for revisiting D6.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Affected tech-notes:** —
- **Changed in spec:** Open Items.

### F12: Precedence semantics were only meaningful for single-value settings

- **Agent:** junior-developer
- **Finding:** "Explicit user input first" is clear for a scalar like the output directory but undefined for the
  extra-agents list — replace or merge?
- **Resolution:** D6 now scopes the chain to single-value settings; for the list, precedence works by addition —
  explicitly named agents are always considered and config entries join them as candidates, matching the suite's
  existing explicit-naming dispatch convention.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow.

### F13: OI-1 was parked as non-blocking despite guarding the foundational decision

- **Agent:** junior-developer
- **Finding:** The untested single-source constraint (research A13) underpins D1; a check that could invalidate the
  feature's foundational decision was labeled non-blocking with a "simplification" framing.
- **Resolution:** OI-1 sharpened: the check must run during implementation planning before the plan is approved, and a
  negative result reopens D1 rather than merely simplifying.
- **Resolved by:** evidence
- **Affected decisions:** D1
- **Affected tech-notes:** —
- **Changed in spec:** Open Items.

## Minor edits

- F14: ".han/config.md already lives in a folder" — D1/D8 wording tightened so "one file, not a folder" clearly means
  a single file inside `.han/` — junior-developer — Primary Flow; Deferred (YAGNI).
- F15: V8's migration-cost and not-superior-on-the-merits framing restored in D8 and the Deferred entry —
  gap-analyzer — Deferred (YAGNI).
- F16: The looser session-availability reading of V9's roster-validation wording documented on D5 with rationale —
  gap-analyzer — —.
- F17: Per-run note retained over once-per-session (skills hold no cross-run state); recorded as a rejected
  alternative on D9 — junior-developer — —.
- F18: Symlink-shared config across monorepo packages flagged as a completeness-only case; not adopted, no spec
  change — edge-case-explorer — —.
