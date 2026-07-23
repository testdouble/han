# Decision Log: Project-Local Han Configuration

## Trivial decisions

- D11: Absent or empty config file means today's behavior — a project without `.han/config.md` sees no change and no
  note. — Referenced in spec: Outcome; Alternate Flows and States.
- D12: Settings that do not apply to the running skill are ignored without comment (considered a per-skill "setting not
  used here" note; rejected because it would add noise to every run in a configured project). — Referenced in spec:
  Primary Flow.
- D13: The config file is a normal version-controlled file in the consuming project's repository. — Referenced in spec:
  User Interactions.

## Full decisions

### D1: One dedicated markdown file at the project root

- **Question:** Where does a consuming project's Han configuration live?
- **Decision:** In a single dedicated file, `.han/config.md`, at the consuming project's root. The project creates and
  owns it; Han cannot ship or seed it from the plugin side.
- **Rationale:** A dedicated file gives Han full ownership of the schema and keeps the override surface out of the
  team's shared narrative files. The plugin cannot carry it: a CLAUDE.md at a plugin's root is not loaded as project
  context, and the plugin manifest's user-configuration mechanism is user-scoped only, so neither can deliver a
  per-repo, version-controlled override.
- **Evidence:** Research report `docs/research/han-config-extensibility.md` (provided; recommendation O1). The
  cannot-ship constraint is research source A13 (web, single-source, flagged for an empirical check — see spec OI-1).
- **Rejected alternatives:**
  - A `.claude/rules/han.md` rules file (research O2) — rejected because rules content is ambient guidance with a
    documented soft-compliance ceiling, occupies context in every session, and no skill can verify it loaded.
  - A `## Han Configuration` section in the project's CLAUDE.md (research O3) — rejected as the primary home because it
    grows an always-loaded file Anthropic recommends keeping lean and invites merge friction in a shared narrative
    file; retained as a complement via the pointer in D10.
  - JSON configuration (research O4) — rejected because the overrides are mostly content a model interprets, and the
    surveyed evidence shows JSON degrading into prose stuffed inside strings for that use; see D2.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** D2, D3, D8, D10
- **Referenced in spec:** Primary Flow; Coordinations; Out of Scope.

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
- **Dependent decisions:** D4, D6
- **Referenced in spec:** Actors and Triggers; Primary Flow; Coordinations.

### D4: Every Han skill participates

- **Question:** Which skills read the configuration in v1? 26 SKILL.md files carry a `## Project Context` block today;
  15 real skills (Atlassian, Linear, communication, plugin-builder) do not.
- **Decision:** Every Han skill participates. The 15 skills without a project-context resolution step gain one as part
  of this feature.
- **Rationale:** User chose full coverage over the research's narrower proposal. Uniform participation means an
  engineer never has to remember which skills honor the config; combined with D12 (inapplicable settings silently
  ignored), full coverage costs nothing in noise.
- **Evidence:** User input, overriding the research report's V2 scoping proposal.
- **Rejected alternatives:**
  - Only the 26 skills that already resolve project context (the research's recommendation) — rejected by the user in
    favor of a uniform contract.
  - A pilot subset of agent-dispatching skills — rejected by the user; partial coverage makes the feature harder to
    explain and trust.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D12
- **Referenced in spec:** Primary Flow.

### D5: Extra agents join the candidate pool under existing caps

- **Question:** How do project-supplied extra agents interact with a skill's hardcoded roster, signal-based selection,
  and size-band caps?
- **Decision:** Config-named agents join the candidate pool and compete under the same signal-based selection and the
  same size-band caps as the skill's own roster. A name that does not resolve to an agent available in the session is
  skipped with a one-line note, and dispatch proceeds.
- **Rationale:** Joining the pool covers the stated need (project-defined agents get considered) without changing any
  skill's selection logic or cost profile. Roster validation keeps a typo or stale name from silently breaking
  dispatch.
- **Evidence:** User input. Roster mechanics: codebase, research A20 (`plan-implementation`, `code-review`, `research`
  SKILL.md roster tables). Validation requirement: research validation finding V9.
- **Rejected alternatives:**
  - Reprioritizing only the skill's own roster — rejected because it does not cover the stated need for
    project-supplied agents.
  - Extra agents exempt from caps, always dispatched — rejected because it changes every configured run's cost and
    undermines the size-band discipline.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes; Out of Scope.

### D6: Precedence: explicit input, config file, discovery sources, defaults

- **Question:** When sources disagree, which value wins?
- **Decision:** Explicit user input first, then `.han/config.md`, then CLAUDE.md's `## Project Discovery` section, then
  `project-discovery.md`, then the skill's built-in defaults. Conflicts resolve silently in that order.
- **Rationale:** A dedicated configuration file the engineer wrote on purpose should beat generic discovery output. The
  known trade-off — a value visible in CLAUDE.md silently outranked by a file the team may forget — is mitigated by the
  CLAUDE.md pointer (D10). The research labels this order a design proposal to validate in use, not a derived fact.
- **Evidence:** User input, accepting the research report's proposed order (flagged as a design proposal in validation
  finding V4).
- **Rejected alternatives:**
  - CLAUDE.md outranks the config file — rejected because it makes the dedicated config unable to override the very
    sources it exists to override.
  - Surfacing every conflict to the user instead of resolving it — rejected because it turns a routine resolution step
    into a recurring interruption.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D10
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes.

### D7: v1 override set: output directory and extra agents only

- **Question:** Which overrides does the file support at launch?
- **Decision:** Exactly two: the output directory for skill-written markdown deliverables, and the extra agents for
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
- **Dependent decisions:** —
- **Referenced in spec:** Outcome.

### D8: One file in v1, not a folder

- **Question:** Is the configuration one file or a `.han/` folder of per-concern files?
- **Decision:** One file, `.han/config.md`, in v1.
- **Rationale:** A deliberate simplification to avoid speculative structure, not a claim that one file is superior on
  the merits. The research names the migration cost of splitting later and accepts it; the reopening trigger is
  recorded in the spec's Deferred section.
- **Evidence:** Research report recommendation and validation finding V8 (which reframed the single file as a v1
  simplification after noting a folder would mirror Han's per-artifact probe convention more closely).
- **Rejected alternatives:**
  - A folder of per-concern files — rejected for v1 because there are only two override classes to hold; deferred, not
    discarded.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Deferred (YAGNI).

### D9: Graceful degradation: a bad config can never break a skill

- **Question:** What happens when the file is malformed, names unknown settings, or lists agents that do not exist?
- **Decision:** A configuration problem can never fail a skill run. Unusable content is ignored, the affected settings
  fall through to the rest of the precedence chain, and the user sees a one-line note naming what was ignored.
  Content that applies cleanly produces no note at all.
- **Rationale:** The config is an optional convenience; letting it block work would make it a liability. The one-line
  note keeps degradation visible without turning it into an interruption.
- **Evidence:** Research validation finding V9, which required explicit failure-mode handling before recommending the
  design.
- **Rejected alternatives:**
  - Failing fast on a malformed file — rejected because a typo in an optional file should never stop a review or a
    plan.
  - Silent ignoring with no note — rejected because the user would have no way to notice a broken override.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes; User Interactions.

### D10: project-discovery offers a CLAUDE.md pointer

- **Question:** How does a contributor who has never heard of `.han/config.md` find out it exists and is in effect?
- **Decision:** The project-discovery skill, when run in a project that has the file, offers to write a one-line
  pointer to it into the project's CLAUDE.md, beside the Project Discovery section it already maintains. The pointer is
  written only with user consent and never duplicated.
- **Rationale:** Nothing in Claude Code surfaces a `.han/` folder on its own; the pointer puts the file in the document
  every contributor already reads, and directly mitigates D6's visibility trade-off.
- **Evidence:** Research validation finding V3, which found Han's own precedent (project-discovery writes into
  auto-loaded files precisely because they are auto-loaded) and elevated the pointer to part of the recommendation.
  Codebase: `han-core/skills/project-discovery/SKILL.md` (research A21).
- **Rejected alternatives:**
  - No discoverability aid — rejected because a Han-invented convention has zero native discoverability and would
    silently outrank visible CLAUDE.md values (D6).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Actors and Triggers; Alternate Flows and States; Edge Cases and Failure Modes.
