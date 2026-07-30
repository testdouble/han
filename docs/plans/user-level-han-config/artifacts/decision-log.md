# Decision Log: Personal Han Configuration

Every decision settled while specifying the personal configuration layer. The behavioral statements live in
[../feature-specification.md](../feature-specification.md); this file carries the rationale, evidence, and rejected
alternatives behind each one.

## Trivial decisions

- D6: The personal file applies with no project file present — a project carrying no configuration file of its own runs
  on your personal settings (considered requiring a project file before the personal one applies; rejected because it
  leaves the personal file with no effect in the case it was written for). — Referenced in spec: Alternate Flows and
  States.

## Full decisions

### D1: Two configuration layers, with the project file on top

- **Question:** does Han read one configuration file or two, and which one wins?
- **Decision:** Han reads a personal configuration first and a project configuration second. The project file adjusts
  what the personal file established. Both files stay; neither replaces the other.
- **Rationale:** the operator asked for exactly this order, and confirmed in the direction-of-travel turn that the
  project file keeps its role.
- **Evidence:** user input, quoted in [scope-boundary.md](./scope-boundary.md) under Stated Scope and Direction of
  Travel.
- **Rejected alternatives:**
  - Personal file wins over the project file — rejected because a project's own settings would stop working the moment a
    person wrote a personal file, which inverts what the operator asked for.
  - Personal file replaces the project file entirely when present — rejected because the operator called it an override
    layer, not a substitute.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D2, D3, D4, D6, D9
- **Referenced in spec:** Outcome

### D2: Where the personal configuration file lives

- **Question:** what path holds the personal configuration?
- **Decision:** `.han/config.md` inside your Claude Code configuration directory. The project file keeps its current
  location, found only in the directory the skill runs from, with no upward search.
- **Rationale:** the operator named this location. Reusing the `.han/config.md` name in both places means one documented
  schema covers both files, and a person moving a setting between them changes nothing but the file it sits in.
- **Evidence:** user input, quoted in [scope-boundary.md](./scope-boundary.md). The existing working-directory rule is in
  `han-core/references/config-rule.md` under "Working directory".
- **Rejected alternatives:**
  - A differently-named personal file — rejected because two schemas for the same four settings would drift, and there
    is no setting that belongs to only one of the two layers.
  - Searching up the directory tree for a project file as a middle layer — rejected because the current rule deliberately
    scopes discovery to the working directory, and nothing in the request asks to change it.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** D5
- **Referenced in spec:** Primary Flow, Out of Scope

### D3: Settings merge one at a time rather than whole-file

- **Question:** when both files exist, does the project file replace the personal one wholesale, or setting by setting?
- **Decision:** setting by setting. Each setting resolves on its own, and the project's value is used only for the
  settings the project file names. A project file naming one setting leaves the rest of your personal settings in place.
- **Rationale:** the operator described the project file as supplying "overrides," which is a per-setting word. A
  whole-file replacement would mean a project that wants a different swarm size silently loses your writing voice and
  output directory too.
- **Evidence:** user input. The existing precedence chain in `han-core/references/config-rule.md` already resolves "each
  scalar setting" independently through a chain of sources, so a per-setting merge extends a mechanic the rule has rather
  than adding one.
- **Rejected alternatives:**
  - Whole-file replacement — rejected because a one-line project file would wipe out three personal settings the project
    never mentioned.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D4, D9
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D4: Extra agents combine across both files

- **Question:** does the project's `## Extra Agents` list replace the personal list or add to it?
- **Decision:** both lists are considered together. An agent named in either file is a candidate, and an agent named in
  both is one candidate counted once against the skill's size cap.
- **Rationale:** the list is already defined as additive rather than replacing, so the two-file case follows the rule
  that is written rather than needing a new one.
- **Evidence:** `han-core/references/config-rule.md`, "Precedence" section: "The extra-agents list adds rather than
  replaces." The same file's "Extra agents joining the pool" section already handles a duplicate entry as one candidate.
- **Rejected alternatives:**
  - The project list replaces the personal list — rejected because it contradicts the additive rule already in force for
    agents the operator names explicitly.
- **Linked technical notes:** —
- **Driven by findings:** F11
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D5: A relative path is rooted at the file that declares it

- **Question:** when a setting names a path, what is that path relative to?
- **Decision:** the folder holding the configuration file that declared it. A relative path in the project file resolves
  against the project, exactly as today. A relative path in the personal file resolves against your Claude Code
  configuration directory.
- **Rationale:** a writing-voice profile you keep personally lives beside your personal configuration, not inside every
  project. Under the old reading, a personal `writing-voice` value would point at a file most projects do not have, and
  the missing-file rule would stop and ask you what to do on nearly every run. Rooting a path at its own file makes the
  personal setting usable everywhere and leaves the project file's behavior unchanged.
- **Evidence:** user input, answering escalation E1 directly. The failure it avoids is the missing-file prompt defined in
  `han-core/references/config-rule.md` under `writing-voice`.
- **Rejected alternatives:**
  - Every path relative to the working directory, as today — rejected because it makes a personal writing-voice profile
    unusable unless every project carries a copy at the same relative path, which is the copying problem this feature
    exists to remove.
  - Every path relative to the personal configuration directory — rejected because `output-directory` names a place to
    write inside the project you are working in, and rooting it at the configuration directory would send every
    deliverable there.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D8
- **Referenced in spec:** Primary Flow

### D7: Every message about configuration names which file it came from

- **Question:** when Han says something about a configuration value, does it say which of the two files held it?
- **Decision:** yes, on both the failure path and the success path. A note about content that could not be used names the
  setting and its file. A skill that announces a setting it adopted, such as a size band, names the file the band came
  from. Two separate problems in two files produce two notes, because each names a different thing to fix.
- **Rationale:** the note exists so you know what was ignored and where to go. With two files carrying the same name and
  the same settings, a message that omits the file leaves you opening both. The same reasoning applies to the
  announcement that fires on every successful sizing run, not only to error output.
- **Evidence:** `han-core/references/config-rule.md`, "Degradation and the one-line note", and the `default-swarm-size`
  requirement in the same file to "announce the band with the config named as the source." The shipped announcement text
  is in `han-planning/skills/plan-a-feature/SKILL.md`.
- **Rejected alternatives:**
  - Keep every message as it reads today — rejected because the same setting name can appear in both files, so no
    message would identify the file to fix.
  - Show two notes for one problem, one per file — rejected because it doubles the output for a problem that lives in one
    place. Two notes are correct only when there are two problems.
- **Linked technical notes:** —
- **Driven by findings:** F4, F7
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes, User Interactions

### D8: A configured path may point anywhere, in either file

- **Question:** must a configured path stay inside the project, as `output-directory` does today?
- **Decision:** no. Any configured path may be a full path, may use `~` for your home directory, and may contain `..`
  segments. This applies to both files, not only the personal one, so `output-directory` in a project file is also no
  longer refused for pointing outside the project. The directory is created on first write wherever it points.
- **Rationale:** the operator chose one uniform rule for every path in the configuration over keeping a special guard on
  one setting, knowing the guard is what keeps generated deliverables in version control by default.
- **Evidence:** user input, answering escalation E2 directly and overriding the recommendation to keep the guard. The
  guard being removed is defined in `han-core/references/config-rule.md` under "Output-directory containment" and
  described to readers in `docs/configuration.md`.
- **Rejected alternatives:**
  - Keep refusing full paths and `..` escapes everywhere — recommended and rejected by the operator.
  - Relax the guard for the personal file only, keeping it on the project file — the strictly simpler version that
    satisfies the writing-voice evidence, raised as finding F2. Rejected because the operator's answer chose the uniform
    rule with its cost named, and a rule that behaves differently depending on which of two identical files declared a
    value is harder to hold than either alternative.
- **Linked technical notes:** —
- **Driven by findings:** F2
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Alternate Flows and States, Edge Cases and Failure Modes, Deferred (YAGNI)

### D9: The personal file sits directly beneath the project file in the chain

- **Question:** where does the personal configuration sit relative to the CLAUDE.md `## Project Discovery` section and
  the project-discovery file, which the chain already consults?
- **Decision:** directly beneath the project's `.han/config.md` and above CLAUDE.md. The chain reads: what you tell the
  skill, the project configuration, the personal configuration, the CLAUDE.md section, the project-discovery file, the
  skill's defaults.
- **Rationale:** the two configuration files carry the same settings under the same name, so keeping them adjacent makes
  the chain predictable. Splitting them around a third source means a person's setting wins in projects with no CLAUDE.md
  and loses in projects with one, for reasons unrelated to configuration.
- **Evidence:** user input, answering escalation E3 directly. The existing five-source chain is in
  `han-core/references/config-rule.md` under "Precedence".
- **Rejected alternatives:**
  - CLAUDE.md outranks the personal file — rejected by the operator. It reads well as a principle, since anything a
    project says about itself is more specific than a personal default, but it makes the common case (a project with a
    CLAUDE.md and no configuration file) the case where your personal setting silently does nothing.
- **Linked technical notes:** —
- **Driven by findings:** F1
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States

### D10: An unreachable personal configuration is silent

- **Question:** should a run say something when it cannot reach your Claude Code configuration directory at all, as
  distinct from when you never wrote a personal file?
- **Decision:** no. Both cases are treated as no personal configuration, with no note.
- **Rationale:** a run cannot tell the two apart, so any warning it produced for the unreachable case would also fire for
  every person who never wrote a personal file. That is the larger group by far. A file that is present but unreadable is
  a different case and does get a note, under the rule already in force.
- **Evidence:** `han-core/references/config-rule.md`, "Degradation and the one-line note": a file unreadable as text gets
  a note, while an absent file produces none. Raised as finding F3.
- **Rejected alternatives:**
  - Warn whenever the personal file is not found — rejected because it turns the ordinary case, no personal file, into a
    message on every run.
- **Linked technical notes:** T1
- **Driven by findings:** F3
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes

### D11: The change lands everywhere configuration is read, or nowhere

- **Question:** do all configuration-reading skills gain the personal lookup at once, and is the operator-facing guide
  part of the work?
- **Decision:** yes to both. Every skill that reads configuration today gains the personal lookup, and the guide is
  rewritten to describe both files and the removed guard.
- **Rationale:** settings that follow you into some skills and not others are harder to reason about than settings that
  follow you into none, because you cannot predict which run honors them. The guide is the only place most readers meet
  this behavior, and it currently tells them a full path is refused.
- **Evidence:** `CLAUDE.md` records that the contract is vendored byte-identical into every skill-carrying plugin and
  that `docs/configuration.md` holds the single canonical schema example. Raised as finding F5.
- **Rejected alternatives:**
  - Land it in a few skills first and spread it later — rejected because a person cannot tell which skills honor their
    settings, so the half-done state is worse than either end state.
- **Linked technical notes:** —
- **Driven by findings:** F5, F2
- **Dependent decisions:** —
- **Referenced in spec:** Coordinations
