# Implementation Decision Log: Personal Han Configuration

Every implementation decision committed while planning the personal configuration layer. The plan itself lives in
[../feature-implementation-plan.md](../feature-implementation-plan.md); this file carries the question, rationale,
evidence, and rejected alternatives behind each decision. Round-by-round history lives in
[implementation-iteration-history.md](implementation-iteration-history.md).

These are implementation decisions only. The behavioral decisions D1 through D11 were settled during specification and
live in [decision-log.md](decision-log.md); nothing here reopens one.

## Trivial decisions

- D-11: The interpretation contract keeps its filename — `config-rule.md` stays `config-rule.md` in all twelve plugins,
  even though its title and opening line stop saying "project". Renaming it would change every referring path in
  CLAUDE.md, in the paragraph beneath all 40 probes, and in the two readability skills, for no behavioral gain. —
  Referenced in plan: Implementation Approach.
- D-12: `project-discovery` Step 5 is left alone — the CLAUDE.md pointer that Step 5 maintains keeps naming the project
  file only, and gains no mention of the personal file. Settled directly by the specification's Cut for Scope entry
  "Extending the CLAUDE.md pointer to name the personal file". — Referenced in plan: Constraints and Boundaries.
- D-13: Removing the containment guard is announced in prose, not at run time — one sentence in the operator guide and
  one in the release notes, and no new message on any run. Settled directly by the specification's Deferred (YAGNI)
  entry "Telling you where deliverables landed when the output directory sits outside the project". — Referenced in
  plan: Constraints and Boundaries, Operational Readiness, Risks and Assumptions.
- D-14: The canonical copy is edited once and the other eleven are copied from it — `han-core/references/config-rule.md`
  is edited by hand, and the eleven vendored copies are produced from it rather than edited in place. Settled by the
  convention CLAUDE.md already states: edit the canonical copy and re-sync the others. — Referenced in plan: Implementation
  Approach, Work Units and Sequencing.

## Full decisions

### D-1: Prove the probe loads before anything fans out

- **Question:** does the work start by editing 40 skill files, or by proving on one file that the new probe shape loads
  at all?
- **Decision:** one skill gets the new probe first, and its behavior is observed across four cases before any other file
  is touched. The candidate is `han-communication:readability-guidance`, because its `allowed-tools` is `Read` alone,
  which is the strictest permission case in the suite. All four cases must pass, and the observed injected value is
  written down verbatim rather than recorded as "worked":

  | Case | `CLAUDE_CONFIG_DIR` | File at `$dir/.han/config.md` | Expected injected value      |
  | ---- | ------------------- | ----------------------------- | ---------------------------- |
  | 1    | set                 | present                       | that file's content          |
  | 2    | set                 | absent                        | empty, and the skill loads   |
  | 3    | unset               | `~/.claude/.han/config.md` present | that file's content     |
  | 4    | unset               | absent                        | empty, and the skill loads   |

  Case 1 read against case 3 is the point of the exercise. Case 1 on its own proves nothing, because on a machine where
  both directories exist the wrong directory still yields file content.

- **Evidence:**
  - No probe anywhere in the suite contains a `$` today, so the shape this feature needs has never shipped here
    (`.discovery-notes.md`, "The configuration surface, measured"; claim `CL-1`).
  - The repository's own loader guidance allowlists commands and refuses four constructs, and says nothing either way
    about `${VAR:-default}` parameter expansion. Its line 118 warns the allowlist can shift between Claude Code
    versions (`han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md`).
  - A documented incident records that a probe exiting nonzero aborted every Han skill in every project without the
    optional file (`docs/plans/fix-config-probe-exit-code/`). The failure mode this feature risks is worse, because it
    is silent: an unexpanded variable still exits 0, still injects empty, and the feature never works, with no error
    anywhere. `D10` deliberately removes the one message that would have distinguished "not found" from "never written"
    (claim `CL-2`).
  - `T1` in [feature-technical-notes.md](feature-technical-notes.md) records that `CLAUDE_CONFIG_DIR` and `~/.claude`
    both exist and point at different places on the machine this feature was specified on.
- **Rejected alternatives:**
  - Edit all 40 probe lines and find out at review time — rejected because the failure is silent. A wrong probe passes
    lint, passes every existing Bats test, loads without error, and ships.
  - Prove it on a skill that declares `Bash` — rejected because that is the permissive case. A probe that loads under
    `Bash` tells you nothing about the 13 skills that declare no `Bash` at all.
  - Test only case 1 — rejected because it cannot tell a correct resolution from a hardcoded default on a machine where
    both directories exist, which is the exact machine `T1` describes.
- **Specialist owner:** `han-core:devops-engineer`
- **Revisit criterion:** a future Claude Code release documents its command classifier, at which point the shape can be
  read off the documentation instead of measured.
- **Dissent (if any):** none.
- **Driven by rounds:** R1
- **Dependent decisions:** D-2, D-3, D-4
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Definition of Done, Testing Strategy

### D-2: Two candidate probe shapes, checked in the same pass

- **Question:** which probe shape resolves the Claude Code configuration directory, given that the shape has never
  shipped in this suite?
- **Decision:** two shapes are checked in the same pass as `D-1`, and the simpler one wins if it loads.

  Shape A is one line with a nested expansion:

  ```text
  - personal .han/config.md: !`cat "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.han/config.md" 2>/dev/null || echo ""`
  ```

  Shape B is three probes, each with the simplest expansion available:

  ```text
  - CLAUDE_CONFIG_DIR: !`echo "$CLAUDE_CONFIG_DIR"`
  - personal .han/config.md (configured dir): !`cat "$CLAUDE_CONFIG_DIR/.han/config.md" 2>/dev/null || echo ""`
  - personal .han/config.md (default dir): !`cat "$HOME/.claude/.han/config.md" 2>/dev/null || echo ""`
  ```

  Shape A is preferred. Shape B is the fallback, and it carries its resolution in the contract's prose rather than in
  the shell: a non-empty first line means the personal configuration is the second line and the third is ignored
  entirely, and an empty first line means the personal configuration is the third line. That reproduces `T1` exactly,
  including the case that matters most, where the variable is set, its file is absent, and `~/.claude/.han/config.md`
  exists on disk, so there is no personal configuration.

- **Rationale:** shape A costs one line and reads the way the behavior reads. Shape B costs a whole extra
  configuration file's worth of injected context on any machine holding both files, multiplied across 40 skills, which
  is a real and recurring cost worth naming rather than absorbing quietly. Against that, shape B degrades more
  gracefully, because `echo` is allowlisted and the `2>/dev/null || echo ""` compound is already proven by fifteen or
  more working probes in this suite.
- **Evidence:**
  - `context-injection-commands.md:52` allowlists `echo`; lines 106 through 111 document the
    `2>/dev/null || echo ""` guard (claim `CL-3`).
  - The `|| true` form was explicitly refuted during the earlier probe incident because `true` is not allowlisted
    (`docs/plans/fix-config-probe-exit-code/`, summarized in `.discovery-notes.md`).
  - `T1` in [feature-technical-notes.md](feature-technical-notes.md) states the resolution order the two shapes must
    both reproduce.
- **Rejected alternatives:**
  - A two-probe variant of shape B, dropping the `echo "$CLAUDE_CONFIG_DIR"` line — rejected because it cannot express
    the case where the variable is set, its file is absent, and the default directory holds a file. That combination
    must yield no personal configuration, and two `cat` lines alone cannot say so.
  - Picking one shape up front and checking only it — rejected because a second check pass costs a fraction of a day
    and a wrong first pick costs the whole fan-out.
- **Specialist owner:** `han-core:devops-engineer`
- **Revisit criterion:** shape A loads, in which case shape B and its extra context cost are dropped from the plan.
- **Dissent (if any):** none.
- **Driven by rounds:** R1
- **Dependent decisions:** D-4, D-5
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing

### D-3: The contingency is pre-decided, so the fan-out cannot stall

- **Question:** what happens if neither probe shape loads?
- **Decision:** the answer is settled now, before the check runs, so the work cannot stall halfway through 40 files. If
  neither shape loads, no probe can satisfy `T1`, and the recommended route is to move the personal read out of the
  probe and into a skill step that uses the `Read` tool as its first action. That satisfies the Coordinations ordering
  requirement, which asks only that both files be read before the first setting is used. The cost is honest and worth
  stating: it adds a step to 40 files and it touches `allowed-tools` in the 13 skills that declare no `Bash` today
  (`tdd`, `refactor`, and `investigate` in han-coding; `readability-guidance`, `edit-for-readability`, and
  `explanation-guidance` in han-communication; `runbook` in han-documentation; `html-summary` in han-reporting; four
  han-atlassian skills; and `work-items-to-linear` in han-linear).

  The alternative route is to halt and re-escalate, on the grounds that the committed mechanic is unimplementable
  through the mechanism the suite uses everywhere else. The recommendation is the `Read`-tool route. The check decides
  which route is taken, and nobody has to make the call under pressure with 22 files edited.

- **Rationale:** the earlier probe incident is the reason this is pre-decided. That failure was discovered after a
  byte-identical line had already landed in 39 files, and the repair was another suite-wide sweep. Deciding the
  contingency before the fan-out starts is the cheapest possible insurance against repeating that shape of work.
- **Evidence:**
  - The Coordinations table in [../feature-specification.md](../feature-specification.md) states the requirement as
    "Both files are read before the first setting is used", which a first-action `Read` step satisfies as well as a
    probe does.
  - `allowed-tools` was counted across the 40 skills, and 13 declare no `Bash` (claim `CL-14`).
  - `docs/plans/fix-config-probe-exit-code/` records the cost of discovering a probe problem after the fan-out.
- **Rejected alternatives:**
  - Decide the contingency if and when the check fails — rejected because it converts a planning question into a
    mid-fan-out interruption, which is the condition under which the earlier incident's repair was rushed.
  - Halt and re-escalate as the primary route — rejected as the recommendation, though kept as the second option,
    because the `Read`-tool route delivers the specified behavior and the escalation route delivers nothing while
    spending an operator turn.
- **Specialist owner:** `han-core:devops-engineer`
- **Revisit criterion:** the `D-1` check fails for both shapes, which makes this decision active rather than
  contingent.
- **Dissent (if any):** none.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Risks and Assumptions, Recommendation

### D-4: The run receives the resolved directory as a value, not only the file content

- **Question:** the probe injects file content, but two committed behaviors need to know which directory the personal
  file came from. Where does that value come from?
- **Decision:** the resolved configuration directory is injected as its own value alongside the file content. This is a
  requirement on the probe, not something to be discovered while implementing. Shape B already carries the line that
  supplies it. Shape A needs its own companion `echo` line for the same purpose.
- **Rationale:** `D5` roots a relative path at the folder holding the file that declared it, so a personal
  `writing-voice` value cannot be resolved without knowing that folder. The "Both lookups resolve to the same file" edge
  case needs the same value, because the run has to notice that the project directory and the configuration directory
  are the same place before it counts one file twice.
- **Evidence:**
  - [../feature-specification.md](../feature-specification.md), Primary Flow step 5, and the "Both lookups resolve to
    the same file" row of Edge Cases and Failure Modes (claim `CL-4`).
  - [decision-log.md](decision-log.md), `D5`.
- **Rejected alternatives:**
  - Infer the directory from the content — rejected because content carries no path, and two identical files are
    indistinguishable by content alone.
  - Have the run compute the directory itself at run time — rejected because 13 of the 40 skills declare no `Bash`, so
    they have no way to read an environment variable.
- **Specialist owner:** `han-core:devops-engineer`
- **Revisit criterion:** none foreseen. Both behaviors that need the value are committed in the specification.
- **Dissent (if any):** none.
- **Driven by rounds:** R1
- **Dependent decisions:** D-5
- **Referenced in plan:** Implementation Approach

### D-5: The two configuration reads get distinct labels, settled before the fan-out

- **Question:** what does each of the two configuration reads call itself in the injected context?
- **Decision:** the two reads carry distinct labels, and the label pair is settled and written down before the first of
  the 40 files is edited. The paragraph beneath each probe, which is identical across all 40 files today and currently
  ends "no project config is present", is rewritten in the same pass to name both reads by their labels.
- **Rationale:** `D7` requires every message about configuration to name the file it came from. Two probe lines both
  labeled `.han/config.md` make that impossible to satisfy, because the run has no way to say which one it means.
  Settling the labels first matters because 40 files have to match each other exactly, and a label chosen file by file
  produces 40 near-misses.
- **Evidence:**
  - [decision-log.md](decision-log.md), `D7`, requires every configuration message to name its file (claim `CL-5`).
  - All 40 probe lines and the three-line paragraph beneath them are identical today
    (`.discovery-notes.md`, "The configuration surface, measured").
- **Rejected alternatives:**
  - Reuse the same label for both reads — rejected because it makes `D7` unimplementable, which would reopen a settled
    behavioral decision.
  - Let each skill word its own label — rejected because the fan-out's only completeness check is a grep for one exact
    string, and 40 wordings defeat it.
- **Specialist owner:** `han-core:junior-developer`
- **Revisit criterion:** none foreseen.
- **Dissent (if any):** none.
- **Driven by rounds:** R1
- **Dependent decisions:** D-6
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Definition of Done

### D-6: The contract, the probes, and the guide land together

- **Question:** in what order do the interpretation contract, the 40 probe lines, and the operator guide land?
- **Decision:** together, in one change. Across two separate commits, either order is wrong. Contract first means every
  skill is instructed to resolve a personal file it is never handed content for. Probes first means personal content
  arrives with no instruction attached, and a skill may reasonably treat it as the project configuration and apply it
  with the wrong precedence.
- **Rationale:** these are content files read at load time, not code with a compile step between writing and running.
  There is no window in which a half-landed state is inert. The moment a probe line ships, every run reads it.
- **Evidence:**
  - Claim `CL-13`. The probe lines and the contract are both loaded as skill context at run time, so a partial state is
    live rather than dormant.
  - [decision-log.md](decision-log.md), `D11`, commits to the change landing everywhere configuration is read or
    nowhere.
- **Rejected alternatives:**
  - Land the contract first, then the probes — rejected because it produces runs that look for a value nothing supplies.
  - Land the probes first, then the contract — rejected because it hands skills personal content with no precedence
    rule, and the plausible wrong reading is to treat it as the project file, which inverts `D1`.
- **Specialist owner:** `han-core:junior-developer`
- **Revisit criterion:** none foreseen.
- **Dissent (if any):** none.
- **Driven by rounds:** R1
- **Dependent decisions:** D-7
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing

### D-7: Completeness is checked with greps at review time, with the expected counts written down

- **Question:** how does anyone know the fan-out reached every file?
- **Decision:** four checks run at review time, and the expected result of each is written into the plan before the work
  starts, so a reviewer compares against a number rather than judging by eye.

  | Check                                                   | Expected result                                       |
  | ------------------------------------------------------- | ----------------------------------------------------- |
  | Grep for the new personal-read probe line                | 40 files                                              |
  | Grep for the old probe form with no personal read beside it | 0 files                                           |
  | `md5 -q han-*/references/config-rule.md \| sort -u`      | exactly one hash across the 12 files                  |
  | Read `docs/configuration.md`                             | containment sentence gone, both files described       |

  The prose sites that no grep can reach are hand-checked, and their count is stated in the plan so the reviewer knows
  when the hand-check is finished rather than guessing.

- **Rationale:** the checksum check is a real passing invariant today rather than an aspiration, because the 12
  vendored copies already share one hash. A check that passes before the work starts and must still pass after it is
  exactly the shape that catches a missed copy. The hand-checked prose sites are separated out honestly, because a grep
  provably cannot find them.
- **Evidence:**
  - `md5 -q han-*/references/config-rule.md | sort -u` returns one hash across 12 files today (claim `CL-7`, verified
    again while writing this plan).
  - The two writing-voice sentences are worded differently, at
    `han-communication/skills/readability-guidance/SKILL.md:44` and
    `han-communication/skills/edit-for-readability/SKILL.md:75`, so no single grep finds both (claim `CL-8`).
- **Rejected alternatives:**
  - A Bats check asserting probe-line counts and vendored-copy checksum equality — rejected on the YAGNI evidence test
    and recorded in the plan's Deferred (YAGNI) section. The one documented incident in this area was a byte-identical
    line that was wrong in all 39 files, which a text-equality check would have passed cleanly. No incident of a missed
    file or a drifted copy exists.
  - Eyeball the diff — rejected because a 60-file diff is where a single missed file hides best.
- **Specialist owner:** `han-core:devops-engineer`
- **Revisit criterion:** the checksum grep returns more than one hash on any branch, or a second suite-wide fan-out
  misses a file. Either event reopens the Bats check.
- **Dissent (if any):** `han-core:junior-developer` (`JD-005`) argued for the Bats check, citing the documented
  probe-exit-code incident as evidence that a suite-wide fan-out in this area has already gone wrong once and that
  nothing in the repository would catch it happening again. `han-core:devops-engineer` (`R8`) argued that the same
  incident would not have been caught by a text-equality test, because the wrong line was present and identical in
  every file, and that the greps satisfy the same need with no new machinery. Recorded as claim `CL-15` and resolved in
  `R8`'s favor by the evidence test, with the reopening trigger above. Recorded under disagree-and-commit.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Work Units and Sequencing, Definition of Done, Risks and Assumptions, Deferred (YAGNI)

### D-8: The run expands a home-directory shortcut before using a configured path

- **Question:** `D8` accepts `~` in a configured path. What expands it?
- **Decision:** the run does, and the interpretation contract says so in one line: expand a leading `~` to the home
  directory before using the value. This is stated in the contract rather than left to the shell.
- **Rationale:** shells expand `~`; tools do not. A path handed to a file-reading tool with a literal `~` in it does not
  resolve. Thirteen of the 40 skills declare no `Bash` at all, so there is no shell in the picture for them, and a rule
  that quietly depends on one would work in 27 skills and silently fail in 13. That is the partial-rollout outcome
  `D11` rejects, arriving through the back door.
- **Evidence:**
  - `allowed-tools` counted across the 40 skills: 13 declare no `Bash` (claim `CL-14`).
  - [decision-log.md](decision-log.md), `D8`, accepts `~` and `..` in any configured path.
  - [decision-log.md](decision-log.md), `D11`, rules out behavior that lands in some skills and not others.
- **Rejected alternatives:**
  - Leave expansion to the shell — rejected because 13 skills have no shell available to them.
  - Refuse `~` and require a full path — rejected because it reopens `D8`, which the operator settled directly.
- **Specialist owner:** `han-core:junior-developer`
- **Revisit criterion:** none foreseen.
- **Dissent (if any):** none.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Definition of Done

### D-9: Recommend one coordinated release across every skill-carrying plugin, at a major bump

- **Question:** `D11` promises the change lands everywhere or nowhere. The suite ships as independently versioned
  plugins. How is that promise kept in a user's installed set, and does this plan bump anything?
- **Decision:** the plan records a recommendation and makes no version change. The recommendation is that all twelve
  skill-carrying plugins and the `han` meta-plugin bump together in one release, at a major bump, and that
  `docs/configuration.md` state plainly that the personal file needs the whole suite at or above that version. The
  actual bump and the CHANGELOG entry belong to `/han-release`, which owns them.
- **Rationale:** `D11` guarantees everywhere-or-nowhere within one release, but it cannot reach across what a person
  has installed. Plugin versions currently span 1.0.0 to 5.0.0, so a user who upgrades some plugins and not others gets
  exactly the outcome `D11` rejects: settings that follow them into some skills and not others, with no way to predict
  which. A coordinated release plus one sentence in the guide is the most this repository can do about it, and it is
  worth doing. The major bump follows the repository's own versioning policy, which places behavior changes that would
  surprise existing users at major, and removing the output-directory containment guard is such a change.
- **Evidence:**
  - `docs/semantic-versioning.md` places "major behavior changes that would surprise existing users" at a major bump.
  - Plugin versions currently span 1.0.0 to 5.0.0 across the suite (claim `CL-11`).
  - [decision-log.md](decision-log.md), `D8`, removes the containment guard, which is the surprising change.
- **Rejected alternatives:**
  - Bump only the plugins whose files changed — rejected because a personal file that works in han-planning and not in
    han-coding is the failure `D11` names.
  - Bump at minor — rejected because a project file that was refused before starts being honored after, with no edit by
    anyone, which is a surprise by the policy's own definition.
  - Make the bump inside this plan's execution — rejected because `/han-release` owns versioning and the CHANGELOG in
    this repository, and two owners for one number is how they drift.
- **Specialist owner:** `han-core:devops-engineer`
- **Revisit criterion:** the repository adopts a single suite-wide version, which would make the coordination automatic
  and this recommendation unnecessary.
- **Dissent (if any):** none.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Work Units and Sequencing, Definition of Done, Operational Readiness, Risks and Assumptions

### D-10: The documents the change makes wrong are corrected through the existing documentation sweep

- **Question:** eight further documents describe configuration as project-local and become factually wrong the moment
  this ships. Is correcting them in scope, and who does it?
- **Decision:** yes, in scope, and the repository's own `han-update-documentation` skill runs the sweep. The eight are
  `CLAUDE.md`, `README.md`, `docs/concepts.md`, `docs/sizing.md`, `docs/quickstart.md`,
  `han-communication/docs/skills/readability-guidance.md`, `han-communication/docs/skills/edit-for-readability.md`, and
  `han-core/docs/skills/project-discovery.md`.
- **Rationale:** these documents do not become wrong because someone chose to expand the work. They become wrong as a
  direct result of the asked-for change, which makes correcting them a necessity of the work rather than added scope.
  Naming the sweep skill as the mechanism keeps the correction from turning into eight hand-edits with their own
  completeness problem.
- **Evidence:**
  - The eight documents were enumerated by path during discovery (claim `CL-6`).
  - `CLAUDE.md` describes the suite's documentation layering and names the surfaces that carry configuration language.
  - The repository ships `han-update-documentation` for exactly this pass.
- **Rejected alternatives:**
  - Cut the eight documents as out of scope — rejected because the recorded boundary asks for a change that makes them
    false, and shipping known-false documentation is not a smaller scope, it is an unpaid cost.
  - Correct them by hand, file by file — rejected because it recreates the completeness problem `D-7` exists to solve,
    in a second place, with no grep available.
- **Specialist owner:** `han-core:junior-developer`
- **Revisit criterion:** the sweep skill reports a document it cannot correct, which would move that document to a
  hand-edit with its own review-time check.
- **Dissent (if any):** none.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Definition of Done
