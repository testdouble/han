# Decision Log: Project-Local Han Configuration

## Trivial decisions

- D11: Absent or empty config file means today's behavior — a project without `.han/config.md` sees no change and no
  note. — Referenced in spec: Outcome; Alternate Flows and States; Edge Cases and Failure Modes.
- D12: Settings that do not apply to the running skill are ignored without comment (considered a per-skill "setting not
  used here" note; rejected because it would add noise to every run in a configured project). — Referenced in spec:
  Primary Flow.
- D13: The config file is a normal version-controlled file in the consuming project's repository. — Referenced in spec:
  User Interactions.

## Full decisions

### D1: One dedicated markdown file carried by the consuming project

- **Question:** Where does a consuming project's Han configuration live?
- **Decision:** In a single dedicated file, `.han/config.md` — one file inside a `.han/` folder at the project root.
  The project creates and owns it; Han cannot ship or seed it from the plugin side.
- **Rationale:** A dedicated file gives Han full ownership of the schema and keeps the override surface out of the
  team's shared narrative files. The plugin cannot carry it: a CLAUDE.md at a plugin's root is not loaded as project
  context, and the plugin manifest's user-configuration mechanism is user-scoped only, so neither can deliver a
  per-repo, version-controlled override.
- **Evidence:** Research report `docs/research/han-config-extensibility.md` (provided; recommendation O1). The
  cannot-ship constraint is research source A13 (web, single-source, flagged for an empirical check — see spec OI-1,
  sharpened by F13: a negative check result reopens this decision).
- **Rejected alternatives:**
  - A `.claude/rules/han.md` rules file (research O2) — rejected because rules content is ambient guidance with a
    documented soft-compliance ceiling, occupies context in every session, and no skill can verify it loaded.
  - A `## Han Configuration` section in the project's CLAUDE.md (research O3) — rejected as the primary home because it
    grows an always-loaded file Anthropic recommends keeping lean and invites merge friction in a shared narrative
    file; retained as a complement via the pointer in D10.
  - JSON configuration (research O4) — rejected because the overrides are mostly content a model interprets, and the
    surveyed evidence shows JSON degrading into prose stuffed inside strings for that use; see D2.
- **Linked technical notes:** T1
- **Driven by findings:** F13, F14
- **Dependent decisions:** D2, D3, D8, D10, D15
- **Referenced in spec:** Primary Flow; Coordinations; Out of Scope; Open Items.

### D2: Markdown with a structured header block, not JSON

- **Question:** What format does the configuration file use?
- **Decision:** Markdown. A small structured header block at the top carries the simple values (such as the output
  directory); named markdown sections carry the list-shaped overrides (such as extra agents).
- **Rationale:** Two independent vendors converged on exactly this hybrid shape for model-consumed configuration, and
  every surveyed AI coding tool splits machine-enforced settings from model-interpreted instructions along this line.
  The header block still gives the handful of simple values a structured, checkable home.
- **Evidence:** Research sources A2 (Claude Code memory docs) and A3 (Cursor rules docs) — web, corroborating each
  other; format-split pattern corroborated across A2, A5, A6, A7.
- **Rejected alternatives:**
  - Pure JSON (research O4) — rejected because open-ended, model-interpreted overrides degrade into prose inside
    strings, and tolerance for custom keys in `settings.json` is unconfirmed (research A12).
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** D9
- **Referenced in spec:** Primary Flow; User Interactions.

### D3: Skills read the file deterministically, not ambiently

- **Question:** How does the configuration reach a skill on every run?
- **Decision:** Each skill reads the file itself during project-context resolution, before the skill's own work begins.
  The configuration reaches the model on every run of every participating skill, independent of the model's judgment.
- **Rationale:** Ambient instruction files carry a documented soft-compliance ceiling; only a skill-side read
  guarantees the configuration is in context. Han's skills already prove the mechanism: more than fifteen skills load
  project context this way today, and the new file slots into the same resolution step.
- **Evidence:** Codebase — `han-coding/skills/code-review/SKILL.md:16-20` (the probe block) and `:86-89` (the fallback
  chain), corroborated across the suite (research A18, A23). Soft-compliance ceiling: research A2 (web).
- **Rejected alternatives:**
  - Ambient loading via rules files or CLAUDE.md alone — rejected because compliance is not guaranteed and no skill can
    verify the content loaded (research A2, A15).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D4, D6, D15
- **Referenced in spec:** Actors and Triggers; Primary Flow; Coordinations.

### D4: Every Han skill participates

- **Question:** Which skills read the configuration in v1? 26 SKILL.md files carry a `## Project Context` block today;
  15 real skills (Atlassian, Linear, communication, plugin-builder) do not.
- **Decision:** Every Han skill participates. The 15 skills without a project-context resolution step gain one as part
  of this feature.
- **Rationale:** User chose full coverage over the research's narrower proposal. Uniform participation means an
  engineer never has to remember which skills honor the config; combined with D12 (inapplicable settings silently
  ignored), full coverage costs nothing in noise. The review team challenged this as a YAGNI candidate (F10),
  recommending the research's narrower 26-skill scope; the decision stands on the user's explicit choice, made with
  that trade-off presented.
- **Evidence:** User input, overriding the research report's V2 scoping proposal.
- **Rejected alternatives:**
  - Only the 26 skills that already resolve project context (the research's recommendation, re-raised by F10) —
    rejected by the user in favor of a uniform contract.
  - A pilot subset of agent-dispatching skills — rejected by the user; partial coverage makes the feature harder to
    explain and trust.
- **Linked technical notes:** —
- **Driven by findings:** F10
- **Dependent decisions:** D12
- **Referenced in spec:** Primary Flow.

### D5: Extra agents join the candidate pool under existing caps

- **Question:** How do project-supplied extra agents interact with a skill's hardcoded roster, signal-based selection,
  and size-band caps?
- **Decision:** The configuration carries one global list of extra agents. For any dispatching skill, those agents join
  the candidate pool and compete under the same signal-based selection and the same size-band caps as the skill's own
  roster — which means a selected extra agent can displace a default specialist, silently and by design. An entry that
  duplicates an agent already in the pool has no effect (one candidate, counted once). An entry that does not resolve
  to a dispatchable agent — a misspelling, a skill name, the running skill itself — is skipped with a one-line note,
  and dispatch proceeds.
- **Rationale:** Joining the pool covers the stated need (project-defined agents get considered) without changing any
  skill's selection logic or cost profile. A global list is the strictly simpler version of per-skill grouping:
  signal-based selection already filters agents irrelevant to a skill's domain, so grouping is deferred until a real
  mis-selection is reported. Validation is against session availability rather than each skill's own roster — the
  stricter per-roster reading of the research's wording would make project agents impossible by definition, since they
  are never on a built-in roster; the looser reading is the one that serves the feature's purpose, and signal selection
  plus caps supply the discipline the research's validation asked for. Displacement under the cap is the accepted
  meaning of "compete": the user chose capped competition over cap-exempt addition.
- **Evidence:** User input. Roster mechanics: codebase, research A20 (`plan-implementation`, `code-review`, `research`
  SKILL.md roster tables). Validation requirement: research validation finding V9.
- **Rejected alternatives:**
  - Reprioritizing only the skill's own roster — rejected because it does not cover the stated need for
    project-supplied agents.
  - Extra agents exempt from caps, always dispatched — rejected because it changes every configured run's cost and
    undermines the size-band discipline.
  - Per-skill grouping of extra agents (raised by T1's first draft and F2) — deferred as the larger version; see the
    spec's Deferred section.
  - Validating entries against each skill's own hardcoded roster (the strict reading of V9) — rejected because project
    agents are by definition not on any built-in roster; session-availability is the check that can actually pass.
- **Linked technical notes:** T1
- **Driven by findings:** F2, F3, F8, F16
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes; Out of Scope.

### D6: Precedence: explicit input, config file, discovery sources, defaults

- **Question:** When sources disagree, which value wins?
- **Decision:** For single-value settings: explicit user input first, then `.han/config.md`, then CLAUDE.md's
  `## Project Discovery` section, then `project-discovery.md`, then the skill's built-in defaults. Conflicts resolve
  silently in that order. For the list-shaped extra-agents setting, precedence works by addition: agents the user names
  explicitly are always considered, and the configuration's entries join them as candidates rather than being replaced
  by them.
- **Rationale:** A dedicated configuration file the engineer wrote on purpose should beat generic discovery output. The
  known trade-off — a value visible in CLAUDE.md silently outranked by a file the team may forget — is mitigated by the
  CLAUDE.md pointer (D10) and tracked for post-ship validation (OI-2). Replacement semantics make no sense for a list
  whose whole purpose is adding candidates, so the chain applies as written only to single values (F12). The research
  labels this order a design proposal to validate in use, not a derived fact.
- **Evidence:** User input, accepting the research report's proposed order (flagged as a design proposal in validation
  finding V4). Explicit-naming-always-considered matches the suite's existing dispatch convention (research A20).
- **Rejected alternatives:**
  - CLAUDE.md outranks the config file — rejected because it makes the dedicated config unable to override the very
    sources it exists to override.
  - Surfacing every conflict to the user instead of resolving it — rejected because it turns a routine resolution step
    into a recurring interruption.
- **Linked technical notes:** —
- **Driven by findings:** F11, F12
- **Dependent decisions:** D10, D14
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes; Open Items.

### D7: v1 override set: output directory and extra agents only

- **Question:** Which overrides does the file support at launch?
- **Decision:** Exactly two: the base directory for skill-written markdown deliverables, and the extra agents for
  dispatching skills to consider.
- **Rationale:** These are the two user-described needs the research was commissioned against. Every additional
  override class fails the YAGNI evidence test today; the file format (D2) leaves room to add more when evidence
  arrives.
- **Evidence:** User-described needs recorded in the research report's framing question; YAGNI evidence test.
- **Rejected alternatives:**
  - A general free-form per-skill instructions section — rejected under the evidence test and deferred with a named
    reopening trigger (see the spec's Deferred section).
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** D14
- **Referenced in spec:** Outcome.

### D8: One file in v1, not a folder

- **Question:** Is the configuration one file, or several per-concern files inside `.han/`?
- **Decision:** One file, `.han/config.md`, in v1. The `.han/` folder exists only to hold it; "not a folder" means no
  additional per-concern files inside that folder.
- **Rationale:** A deliberate simplification to avoid speculative structure — explicitly not a claim that one file is
  superior on the merits, since the research noted a folder would mirror Han's own per-artifact probe convention more
  closely. Splitting later carries a named migration cost: existing projects' config files would need to be split and
  moved. The reopening trigger is recorded in the spec's Deferred section.
- **Evidence:** Research report recommendation and validation finding V8.
- **Rejected alternatives:**
  - Several per-concern files inside `.han/` — rejected for v1 because there are only two override classes to hold;
    deferred, not discarded.
- **Linked technical notes:** —
- **Driven by findings:** F14, F15
- **Dependent decisions:** —
- **Referenced in spec:** Deferred (YAGNI).

### D9: Graceful degradation: a bad config can never break a skill

- **Question:** What happens when the file is malformed, names unknown settings, carries unusable values, or lists
  agents that do not exist?
- **Decision:** A configuration problem can never fail a skill run. Unusable content — a malformed header, an
  unrecognized setting name, a blank or unusable value, a non-text file — is ignored, the affected settings fall
  through to the rest of the precedence chain, and the user sees a one-line note naming what was ignored. The note
  appears only when content that attempts a recognized override cannot be used; prose the suite has no use for is
  passed over silently, with no note. The note recurs on each run where the problem is present.
- **Rationale:** The config is an optional convenience; letting it block work would make it a liability. The
  attempted-override rule gives a crisp boundary between "broken config the user should fix" (note) and "extra prose"
  (silence). A per-run note is bounded at one line; suppressing repeats would require skills to carry state across
  runs, which is new machinery the simpler version does not need.
- **Evidence:** Research validation finding V9, which required explicit failure-mode handling before recommending the
  design.
- **Rejected alternatives:**
  - Failing fast on a malformed file — rejected because a typo in an optional file should never stop a review or a
    plan.
  - Silent ignoring with no note — rejected because the user would have no way to notice a broken override.
  - Showing the note once per session instead of per run — rejected because skills hold no cross-run state; the
    one-line cost is accepted (F17).
- **Linked technical notes:** —
- **Driven by findings:** F5, F6, F17
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes; User Interactions.

### D10: project-discovery offers a CLAUDE.md pointer

- **Question:** How does a contributor who has never heard of `.han/config.md` find out it exists and is in effect —
  and what happens to that pointer when the file goes away?
- **Decision:** The project-discovery skill, when run in a project that has the file, offers to write a one-line
  pointer to it into the project's CLAUDE.md, beside the Project Discovery section it already maintains. It never adds
  a second pointer when any reference to the file is already present, however the contributor has edited it. When the
  file is gone but a pointer remains, the skill offers to remove the stale pointer. Both the write and the removal
  happen only with user consent.
- **Rationale:** Nothing in Claude Code surfaces a `.han/` folder on its own; the pointer puts the file in the document
  every contributor already reads, and directly mitigates D6's visibility trade-off. A dangling pointer would mislead
  every reader of CLAUDE.md indefinitely, so the pointer needs a removal path with the same consent rule as its
  creation.
- **Evidence:** Research validation finding V3, which found Han's own precedent (project-discovery writes into
  auto-loaded files precisely because they are auto-loaded) and elevated the pointer to part of the recommendation.
  Codebase: `han-core/skills/project-discovery/SKILL.md` (research A21).
- **Rejected alternatives:**
  - No discoverability aid — rejected because a Han-invented convention has zero native discoverability and would
    silently outrank visible CLAUDE.md values (D6).
- **Linked technical notes:** —
- **Driven by findings:** F7
- **Dependent decisions:** —
- **Referenced in spec:** Actors and Triggers; Alternate Flows and States; Edge Cases and Failure Modes; Coordinations.

### D14: The output directory is a base; skills keep their structure beneath it

- **Question:** When the config sets an output directory, does it flatten every skill's output into one folder, or
  redirect a base under which each skill keeps its own structure? And what bounds the value?
- **Decision:** The value is a base directory, resolved relative to the project root the skill runs in. Skills keep
  their own folder and file structure beneath it — a planning skill still writes its plan folder with an artifacts
  subfolder, only rooted under the configured base. The skill creates the directory on first write if it does not
  exist. A value that points outside the project, or that cannot be written, is refused with a one-line note and the
  skill falls back to its default output location; deliverables are never written outside the project.
- **Rationale:** The originating need was "write all markdown outputs to `.scratch/`" — a base to redirect, not a
  request to flatten structured multi-file deliverables into one directory, which would make skills like plan-a-feature
  collide with themselves. Auto-creation follows from D9's never-block rule: an absent directory is the normal state on
  first configured run, and refusing to write would turn the convenience into a failure. Containment inside the
  project is a data-integrity guard against accidents (an absolute path pasted from another machine, a stray leading
  slash), not a security boundary.
- **Evidence:** User-described need in the research report's framing question ("write all markdown outputs to
  `.scratch/`"); existing structured outputs across the suite (research A19: per-skill output paths, including
  multi-file plan folders); D9 (never-block rule).
- **Rejected alternatives:**
  - One flat directory receiving every deliverable — rejected because multi-file deliverables would collide and
    per-skill organization would be lost.
  - Honoring paths outside the project — rejected because a mistaken config could silently scatter or overwrite files
    elsewhere on the machine.
  - Failing the run on an unwritable path — rejected under D9; degradation to the default location keeps work moving.
- **Linked technical notes:** T1
- **Driven by findings:** F1, F5
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes; Out of Scope.

### D15: The config is discovered from the skill's working directory

- **Question:** Where does a skill look for `.han/config.md` — the current working directory, a walk up to a repository
  root, or somewhere else? And what does that mean in a monorepo?
- **Decision:** The skill looks for `.han/config.md` relative to the directory it runs in — the same place it already
  looks for CLAUDE.md and the discovery file. In a monorepo, each package can carry its own config, and a skill run
  from a package directory sees that package's file. A skill run from a directory with no config behaves as if the
  file were absent, even when one exists elsewhere in the repository.
- **Rationale:** This matches how every existing project-context source in the suite is resolved, so the config is
  found exactly where the rest of a skill's context is found — one rule for engineers to learn, and no new search
  behavior to specify or maintain. The limitation (a nested working directory does not see a repo-root config) is the
  same limitation the suite's existing context sources already have, and it is stated in the spec's edge cases rather
  than papered over.
- **Evidence:** Codebase — the existing probe convention resolves from the working directory
  (`han-coding/skills/code-review/SKILL.md:19`, corroborated across the suite per research A18, A23).
- **Rejected alternatives:**
  - Walking up parent directories to a repository root — rejected because it invents a search behavior no other Han
    context source has, and silently answers the monorepo shared-config question the suite has no evidence to answer
    yet.
- **Linked technical notes:** T1
- **Driven by findings:** F4
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Alternate Flows and States; Edge Cases and Failure Modes.
