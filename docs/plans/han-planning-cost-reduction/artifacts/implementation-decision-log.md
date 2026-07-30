# Implementation Decision Log: Cheaper, Faster Planning Runs

Every implementation decision committed while planning this feature. Behavioral and implementation statements live in
[../feature-implementation-plan.md](../feature-implementation-plan.md); this file carries the question, rationale,
evidence, and rejected alternatives for each one. Round-by-round history lives in
[implementation-iteration-history.md](implementation-iteration-history.md).

Each decision was classified full or trivial once, after the loop closed. No `feature-technical-notes.md` exists for the
source specification, so no `T#` mechanic constrains any decision here and none is cited. The specification's own
decisions are cited as `D1` to `D13` and live in [decision-log.md](decision-log.md); this file's own decisions are
numbered `D-1` upward and the two numbering schemes do not overlap.

## Trivial decisions

- D-15: Reuse the established script preamble form — every new script opens with `set -euo pipefail`, validates argument
  presence with `"${1:?message}"`, and guards each path with an explicit `[ -f ]` or `[ -d ]` test, copying the form
  already used by `han-github/skills/work-items-to-issues/scripts/upload-screenshots.sh`. Presence validation is not
  shape validation, and shape is owned by [D-6](#d-6-anchored-whole-string-allow-list-on-the-recorded-location). —
  Referenced in plan: Implementation Approach, Security Posture.
- D-16: Tests sit beside the script they cover — each new `.bats` file takes the script's basename and lives in the same
  `scripts/` directory, which is the convention `test/sanity.bats` states and `npm test` collects by find. — Referenced
  in plan: Testing Strategy, Work Units and Sequencing.
- D-17: Lean on the existing lint gate rather than adding one — ShellCheck already runs over every script through `prek`
  and `npm run lint`, so the new scripts inherit that gate and the plan adds no new one. — Referenced in plan: Testing
  Strategy.

## Full decisions

### D-1: Four per-skill copies of the design-image check

- **Question:** The design-image check is needed by four skills in one plugin. One shared copy, or one copy per skill?
- **Decision:** Four copies, one in each skill's own `scripts/` directory, invoked as
  `${CLAUDE_SKILL_DIR}/scripts/<name>.sh`. The four are byte-identical except for a mutual `NOTE:` comment naming the
  other three.
  - Carried by `plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, and `plan-work-items`.
- **Rationale:** This is not a judgment call the plan gets to make. The repository's authoring guidance states the rule
  directly, and the one precedent in the repository (the two byte-identical `detect-*-context.sh` copies) already follows
  it. Four copies is also the structurally simpler shape: no new plugin-level directory, no cross-skill path resolution,
  no hidden dependency between skills.
- **Evidence:**
  - `han-plugin-builder/skills/guidance/references/skill-building-guidance/script-execution-instructions.md:77-81`:
    "Skills must be self-contained. If two skills use the same script, each skill gets its own copy in its own
    `scripts/` directory. Do not reference scripts from another skill's directory."
  - `.discovery-notes.md`, which records that no plugin-level `scripts/` directory exists anywhere in the repository, and
    that `${CLAUDE_PLUGIN_ROOT}` is used today only to reach `references/`.
  - `han-core:software-architect` finding `A1`, ledger row `R1-C1`.
- **Rejected alternatives:**
  - One shared copy under a new plugin-level `scripts/` directory, reached through `${CLAUDE_PLUGIN_ROOT}` — rejected
    because the guidance above forbids cross-skill script references, and because no such directory exists in the
    repository to follow.
  - Four copies with no sync marker — rejected because the copies are then silently divergent; the mutual `NOTE:`
    comment is the precedent's own remedy.
- **Specialist owner:** `han-core:software-architect`
- **Revisit criterion:** If `script-execution-instructions.md` is revised to permit plugin-level shared scripts, or a
  fifth skill needs the same check.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-2, D-3, D-12
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Deferred (YAGNI)

### D-2: Two positional arguments, no flags

- **Question:** How does the design-image check learn which boundary record to read and where the design folder is?
- **Decision:** Two positional arguments and no flags: the boundary-record path first, the designs directory second. The
  calling skill resolves both.
- **Rationale:** The specification commits the check to reading the record beside the deliverable it gates, and two
  records can exist on a `plan-work-items` run, so the choice of which record to read belongs to the caller and not to
  the script ([D13](decision-log.md#d13-read-the-record-beside-the-deliverable-being-gated)). It also absorbs the fact
  that the four prose instances of the check resolve the design folder three different ways today, without the script
  needing to know which skill invoked it.
- **Evidence:**
  - `han-core:software-architect` finding `A2`, ledger row `R1-C4`: the four prose instances are not the same check, and
    the differences belong in arguments rather than in four script bodies.
  - `han-planning/references/planning-boundary-rule.md:36`, which commits a skill to reading a record from one folder
    while writing its own beside its own deliverable.
- **Rejected alternatives:**
  - Have the script discover the record and folder itself by walking upward from the working directory — rejected
    because the two-record case then resolves by accident rather than by the caller's intent, which is the failure
    `D13` exists to prevent.
  - Named flags — rejected as an argument surface with no second caller shape to justify it; the script takes exactly
    two inputs and both are always required.
  - Four differing scripts, one per call site — rejected because it multiplies the drift surface `D-3` exists to bound.
- **Specialist owner:** `han-core:software-architect`
- **Revisit criterion:** If a caller needs to pass a third input, or if a caller legitimately needs the script to read
  both records.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2 (confirmed in the YAGNI sweep)
- **Dependent decisions:** D-14
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing

### D-3: One test file plus a drift assertion, not four

- **Question:** Four copies of a script — four copies of its test file, or one?
- **Decision:** One `.bats` file, beside the canonical copy. It exercises the check's behavior through that copy, and it
  asserts that the other three copies are byte-identical to it except for their `NOTE:` line.
- **Rationale:** A duplicated test file duplicates the maintenance without adding coverage, and the drift assertion
  catches the failure mode four copies actually have. The repository supplies direct evidence that a sync note drifts
  before the code does.
- **Evidence:**
  - `han-coding/skills/code-review/scripts/detect-review-context.bats:1-8`, whose header comment names three copies of
    the detector's tests ("automated-test-planning and review-skill-or-agent") while only two exist. A sync note has
    already drifted in this repository at two copies; this plan is proposing four.
  - `han-core:software-architect` finding `A5`, ledger row `R1-C5`.
- **Rejected alternatives:**
  - Four duplicated test files, matching the existing `detect-*-context.bats` precedent — rejected because that
    precedent is the source of the measured drift above, and because the copies are asserted identical, so three of the
    four runs would be re-running proven-identical code.
  - No drift assertion at all — rejected because the four-copy shape in [D-1](#d-1-four-per-skill-copies-of-the-design-image-check)
    is only safe while the copies stay identical, and nothing else in the repository enforces that.
- **Specialist owner:** `han-core:test-engineer`
- **Revisit criterion:** If the copies must legitimately diverge beyond their `NOTE:` line, the assertion becomes wrong
  and the decision reopens.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2 (confirmed against the scope floor as a necessity of D-1)
- **Dependent decisions:** —
- **Referenced in plan:** Testing Strategy, Work Units and Sequencing, Risks and Assumptions

### D-4: The cross-reference check is one copy and materially larger work

- **Question:** Does the cross-reference check share plumbing with the design-image check, and how should the two be
  sized against each other?
- **Decision:** The cross-reference script lands in `iterative-plan-review/scripts/` only. No sync note, no shared
  plumbing, no shared harness with its twin. It is planned and sequenced as materially larger work than the
  design-image check, in its own work unit.
- **Rationale:** It has exactly one call site, so the four-copy problem does not apply and the mutual `NOTE:` convention
  would be a note pointing at nothing. It is also not the same size of job: the step it replaces states four invariants,
  three of them conditional on spec-aware mode, plus markdown fence awareness. Budgeting the two scripts as equivalent
  would underestimate the larger one.
- **Evidence:**
  - `han-core:software-architect` finding `A6`, ledger row `R1-C6`.
  - `han-planning/skills/iterative-plan-review/SKILL.md`, Step 6.5, which states those invariants and their
    mode-conditional application.
- **Rejected alternatives:**
  - A shared harness or output-formatting library across the two scripts — rejected under the YAGNI gate at two
    implementations; deferred with a trigger.
  - Planning both scripts as one work unit of comparable size — rejected because the invariant count and the
    fence-awareness requirement make them unequal, and a single unit hides that.
- **Specialist owner:** `han-core:software-architect`
- **Revisit criterion:** If a second skill's cross-reference check is reinstated from the specification's cut list, the
  one-copy premise changes and `D-1`'s reasoning applies instead.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-8
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Deferred (YAGNI)

### D-5: Row-oriented per-row accounting, never extraction by pattern

- **Question:** How does the design-image check read the record's list of visual material?
- **Decision:** The check locates the `## Visual Material Received` section by exact heading, stops at the next `## `
  heading, and puts every data row it finds in that section into exactly one of three buckets: recorded link, accepted
  file location, or refused. It reports the count of rows examined, so a record with zero items reads differently from a
  record whose every row was refused.
- **Rationale:** This is the single decision that determines whether the feature delivers its own premise. The nearest
  precedent in the repository extracts matching values with a grep pattern and processes what it finds. That shape would
  satisfy a review looking for an allow-list while making every refusable row invisible: five malformed rows and an
  empty list would both produce no output and both pass. An empty list is a state the specification requires to pass, so
  the two must be distinguishable, and only per-row accounting distinguishes them.
- **Evidence:**
  - `han-core:adversarial-security-analyst` finding `S-8`, ledger row `R1-C9`.
  - `han-github/skills/work-items-to-issues/scripts/upload-screenshots.sh:57`, the grep-extraction precedent this
    decision declines to copy.
  - The specification requires an empty list to pass and a malformed row to be refused and named
    ([D9](decision-log.md#d9-a-check-reports-one-of-three-outcomes-and-never-assumes-a-pass),
    [D11](decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted)).
  - `han-planning/references/planning-boundary-rule.md`, whose completeness gate states its own purpose as catching
    partial loss and not passing vacuously.
- **Rejected alternatives:**
  - Extract candidate filenames with a pattern and check each one found, copying the existing precedent — rejected
    because it reintroduces the vacuous pass this whole feature exists to remove, and it does so invisibly.
  - Parse the whole record as a table without anchoring on the heading — rejected because other sections of the record
    also contain tables, so rows from an unrelated section would enter the accounting.
- **Specialist owner:** `han-core:adversarial-security-analyst`
- **Revisit criterion:** If the boundary record's format stops using a heading-delimited table for received material.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-6, D-7, D-11
- **Referenced in plan:** Implementation Approach, Security Posture, Testing Strategy, Definition of Done

### D-6: Anchored whole-string allow-list on the recorded location

- **Question:** What exactly does the check accept as a valid recorded file location?
- **Decision:** After stripping at most one surrounding pair of backticks, the value must match an anchored whole-string
  allow-list of permitted characters and accepted extensions, with an optional `ui-designs/` prefix, and any value
  containing `..` is refused outright. The check does not normalize the value, does not resolve it to a real path before
  validating, and does not retry a trimmed variant of a value it refused.
  - The shape, as a decision-bearing value:
    `^(ui-designs/)?[A-Za-z0-9._-]+\.(png|jpg|jpeg|gif|webp|svg|pdf)$`
- **Rationale:** Allow-listing permitted characters is the only form that fails closed on shapes nobody anticipated; a
  deny-list of dangerous characters fails open on the next one. Anchoring whole-string is what makes the extension part
  meaningful rather than a substring anywhere in the value. The backtick strip and the optional folder prefix are not
  leniency: the boundary rule's own canonical example carries both, so a check implemented by reading the
  specification's untrusted-input decision literally would refuse the rule's own example and fail every correctly
  written record. Not normalizing and not retrying is what keeps the validated value and the used value the same value.
- **Evidence:**
  - `han-planning/references/planning-boundary-rule.md:86`, the canonical example row, whose location cell reads
    `` `ui-designs/card-empty-state.png` `` — folder prefix and backticks both.
  - The same rule's accepted-file-set section, which supplies the seven extensions.
  - `han-core:adversarial-security-analyst` finding `S-9`, ledger row `R1-C10`.
  - `han-github/skills/work-items-to-issues/scripts/upload-screenshots.sh:48`, where the same extension set is already
    encoded as `ASSET_EXT_PATTERN` with a comment naming the rule as its source.
- **Rejected alternatives:**
  - Deny-list the dangerous characters — rejected because it fails open on any shape not enumerated, and the security
    review was explicit that the allow-list direction is the one that holds.
  - Normalize or resolve the value first, then validate — rejected because validating a value other than the one that
    gets used is the standard route to a bypass.
  - Retry a trimmed or repaired variant when the first form is refused — rejected because a check that repairs what it
    gates no longer gates it.
  - Accept only a bare filename with no prefix and no backticks, as a literal reading of
    [D11](decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted) suggests — rejected because it
    refuses the boundary rule's own canonical example.
- **Specialist owner:** `han-core:adversarial-security-analyst`
- **Revisit criterion:** If the accepted file set in `planning-boundary-rule.md` changes, or if the record format
  changes how a location cell is written.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-13
- **Referenced in plan:** Implementation Approach, Security Posture, Testing Strategy

### D-7: The link branch is a leading-anchored literal match

- **Question:** How does the check recognize a row that records a hosted link rather than a kept file?
- **Decision:** One test, on the recorded marker, anchored at the start of the value: the shape
  `case "$kept" in '(not a file)'*)`. Not a substring search, not a URL-scheme test, not a heuristic about whether a
  value looks like a link.
- **Rationale:** This is the highest-value single line in either script, because it is the one branch that reports
  present without touching disk. Any looser test hands an attacker, or an ordinary hand-written record, a route to a
  pass for material nobody kept. Anchoring at the start means the marker has to be what the record format says it is
  rather than something appearing anywhere in a free-text cell.
- **Evidence:**
  - `han-planning/references/planning-boundary-rule.md:87`, the canonical link row, whose cell begins
    `(not a file) https://figma.com/...`.
  - The same rule's instruction not to fetch a supplied link.
  - The specification requires the branch to be entered only on the recorded marker and never inferred from how a value
    looks ([D11](decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted)).
  - `han-core:adversarial-security-analyst` finding `S-10`, ledger row `R1-C11`.
- **Rejected alternatives:**
  - Substring test for the marker anywhere in the cell — rejected because a refusable row that happens to contain the
    marker text then passes.
  - Test for a URL scheme, or for anything that reads as a link — rejected explicitly by the specification, and it is
    the exact inference that produces a pass for unkept material.
- **Specialist owner:** `han-core:adversarial-security-analyst`
- **Revisit criterion:** If `planning-boundary-rule.md` changes the link marker.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Security Posture, Testing Strategy, Definition of Done

### D-8: The cross-reference check never builds a pattern from document text

- **Question:** The cross-reference check reads a plan document and searches its companions for what it finds. How does
  document text reach a search without becoming part of the search's own syntax?
- **Decision:** Three commitments. The check extracts identifiers using its own anchored patterns, never patterns built
  from document text. Any value taken from a document is searched for as a fixed string, with `grep -F` and with `--`
  before the filename. And the example-block exclusion is a fence-state toggle evaluated as the file is walked, before
  the identifier scan, rather than a filter applied to results afterward.
- **Rationale:** Plan section headings are free prose, and a heading interpolated into a regular expression becomes
  syntax. Fixed-string search removes the whole class. `--` before the filename removes the separate class where a
  value that begins with a dash is read as an option. The fence toggle has to run before the scan because a post-hoc
  filter has already treated example text as a live reference by the time it decides to drop it, and any side effect of
  scanning it has already happened.
- **Evidence:**
  - `han-core:adversarial-security-analyst` finding `S-11`, ledger row `R1-C12`.
  - The specification requires a cross-reference inside an example block to be ignored
    ([D4](decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)) and requires document text in a result to
    be reported as text ([D11](decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted)).
- **Rejected alternatives:**
  - Build a search pattern from the heading or identifier text read out of the plan — rejected because free prose
    becomes regular-expression syntax, which is the injection surface itself.
  - Scan first and filter example-block hits out of the results — rejected because the exclusion then runs after the
    thing it is meant to prevent.
- **Specialist owner:** `han-core:adversarial-security-analyst`
- **Revisit criterion:** If the plan format gains a second kind of literal block the exclusion must also honor.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Security Posture, Testing Strategy

### D-9: Exit status carries the outcome, and prose never does

- **Question:** How does the run learn which of the three outcomes a check produced?
- **Decision:** Each script returns a distinct exit status for each of passed, failed, and could-not-verify. The skill
  step says in words that the run reports the outcome the status carries, and that every line the script printed is
  quoted document text rather than an instruction the run follows.
- **Rationale:** The specification commits a check to three outcomes and to never assuming a pass. A status is a value
  the run cannot misread; a line of prose printed by a script is text a run can be talked into by whoever wrote the
  document that text came from. Saying so in the skill step is the part that makes the guarantee hold, because the
  script cannot enforce how its own output is read.
- **Evidence:**
  - The specification's three-outcome commitment
    ([D9](decision-log.md#d9-a-check-reports-one-of-three-outcomes-and-never-assumes-a-pass)) and its requirement that
    text from a record is reported as text and never interpreted as an instruction
    ([D11](decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted)).
  - `han-core:adversarial-security-analyst` finding `S-14`, ledger row `R1-C14`.
- **Rejected alternatives:**
  - Return a single non-zero status for both failed and could-not-verify and distinguish them in the printed text —
    rejected because the specification requires the operator to be able to tell a refused value from a check that never
    ran, and the distinction would then live only in text.
  - Report a could-not-verify as a success so the run continues cleanly — rejected outright; it is the vacuous pass in
    another costume.
- **Specialist owner:** `han-core:adversarial-security-analyst`
- **Revisit criterion:** None foreseen; reopens only if the three-outcome commitment changes.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-10
- **Referenced in plan:** Implementation Approach, Security Posture, Definition of Done

### D-10: The skill writes the unverified record as a fenced excerpt

- **Question:** The specification requires an unverified check to be recorded in the artifacts. That write is performed
  by the skill, not by the script. What constrains it?
- **Decision:** The skill instruction writes a bounded excerpt of the check's output inside a fenced block, rather than
  placing a raw cell value inline in prose or in a table cell.
- **Rationale:** This is the gap most likely to be missed, because everything about input handling in this plan lives in
  the scripts and this one write happens outside them. The script's sanitizing boundary does not extend to text the
  skill copies into a file it authors. A fenced block bounds the damage a document-supplied value can do to the artifact
  a later skill reads, and a bounded excerpt bounds how much of it travels.
- **Evidence:**
  - `han-core:adversarial-security-analyst` finding `S-14`, ledger row `R1-C13`: the sanitizing boundary lives in the
    script, and the artifact write the skill performs bypasses it.
  - The specification requires the unverified state to reach the artifacts and not only the summary
    ([D12](decision-log.md#d12-record-an-unverified-check-in-the-artifacts-not-only-in-the-summary)).
- **Rejected alternatives:**
  - Write the offending value inline in the artifact's prose or table — rejected because the next skill reads that file
    as input, so an unfenced value crosses a second trust boundary with no bound on it.
  - Have the script write the artifact itself, so the sanitizer covers it — rejected because the artifact's shape and
    location are the skill's business, and it would give a check write access to the folder it gates.
- **Specialist owner:** `han-core:adversarial-security-analyst`
- **Revisit criterion:** If the artifact format changes such that a fenced block cannot be placed where the record goes.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Security Posture, Definition of Done

### D-11: A refusal names the row and the item, and echoes the value only where needed

- **Question:** How much of a refused value does the check show the operator?
- **Decision:** A refusal is identified by row number plus the item's name. The offending value itself is echoed only
  where the operator needs to see it to fix the record, and when it is, it passes through one bounded transform: strip
  control characters, collapse newlines and tabs, truncate, emit as one labeled line.
- **Rationale:** The operator has to be able to find the row they need to fix, and a row number plus a name does that
  without moving the untrusted text at all. Echoing every refused value by default moves more untrusted text across the
  boundary than the operator needs on the common path. The bounded transform exists because one place does need the
  value, and that one place should be the only route it takes.
- **Evidence:**
  - `han-core:adversarial-security-analyst` finding `S-14`, ledger row `R1-C13`. The specialist proposed this as the
    primary form.
  - The specification requires the check to name the offending row
    ([D11](decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted)), which a row number and item name
    satisfy.
- **Rejected alternatives:**
  - Echo the offending cell's value on every refusal — rejected because the simpler version satisfies the same
    evidence. This was the plan's own earlier commitment and was replaced in the R2 YAGNI sweep.
  - Never echo the value at all — rejected because an operator debugging an unfamiliar record needs to see what was
    refused at least once.
- **Specialist owner:** `han-core:adversarial-security-analyst`
- **Revisit criterion:** If an operator cannot resolve a refusal from row number and item name alone.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2 (replaced with the simpler form in the YAGNI sweep)
- **Dependent decisions:** —
- **Referenced in plan:** Security Posture, Testing Strategy

### D-12: No permission-frontmatter edits in any skill

- **Question:** Does each skill declare its new check in the `allowed-tools` frontmatter?
- **Decision:** No skill's permission frontmatter is edited. The operator approves the check once per run, the first
  time a run reaches it. The plan contains no `allowed-tools` changes at all.
- **Rationale:** A declaration of that shape cannot match. Permission patterns are prefix matches, and the command as it
  runs begins with an expanded absolute skill-directory path that no declaration contains. The repository's own
  authoring guidance reaches that conclusion and states the remedy, and every script-running skill in the repository
  already follows it. Declaring anyway would leave five inert lines behind and make these the only skills doing
  something the repository's rule says does not work.
- **Evidence:**
  - `han-plugin-builder/skills/guidance/references/skill-building-guidance/script-execution-instructions.md:67-75`,
    which states that the patterns are prefix matches, that the runtime command starts with the expanded absolute
    skill-directory path, that "the prefix won't match," and therefore "omit them from `allowed-tools`. Scripts
    typically run once per skill invocation, so a single user approval is acceptable."
  - A survey of every skill in this repository that invokes a script: nine such skills, none declaring its own script.
    `han-reporting/skills/html-summary/SKILL.md` runs a script while declaring `allowed-tools: Read, Write`, with no
    Bash permission at all.
  - Operator input, recorded as escalation `E1` / `OQ-1` in
    [implementation-iteration-history.md](implementation-iteration-history.md).
  - The specification was corrected to match, and its own findings file records the correction as `S3`.
- **Rejected alternatives:**
  - Add five narrow declarations naming each script's invocation path, as the specification originally committed and as
    `han-core:adversarial-security-analyst` recommended — rejected on the guidance above, which reasons about this exact
    case, and on the nine-skill survey.
  - Widen the prefix to `Bash(bash *)`, `Bash(sh *)`, or `Bash(*.sh *)` so a pattern does match — rejected outright.
    The security review was specific that each of those auto-approves arbitrary shell for the rest of the run, in skills
    that also hold write access.
  - Declare it anyway and verify against the host afterward — rejected by the operator in favor of following the written
    guidance.
- **Specialist owner:** `han-core:software-architect`
- **Revisit criterion:** If `script-execution-instructions.md` is revised, or if the host gains a permission form that
  can match an expanded skill-directory path.
- **Dissent (if any):** `han-core:adversarial-security-analyst` recommended adding the five declarations (`S-13`,
  ledger row `R1-C3`) and its position did not prevail. It was a documented disagreement with
  `han-core:software-architect` (`A4`, `R1-C2`), settled by the skill reading the cited rule directly rather than
  weighing the two recommendations, and then confirmed by the operator. The dissenting specialist's accompanying warning
  is kept in full and appears above as the second rejected alternative: whatever the plan does, it must not widen the
  prefix. Recorded under disagree-and-commit.
- **Driven by rounds:** R1 (raised and disputed), R2 (settled by operator input)
- **Dependent decisions:** —
- **Referenced in plan:** Constraints and Boundaries, Implementation Approach, Security Posture, Deferred (YAGNI)

### D-13: A third encoding of the accepted file set, with a citing comment

- **Question:** The accepted file set already appears in two places. The new script needs it. Extract a shared constant,
  or encode it a third time?
- **Decision:** Encode it a third time, in the script, with a comment naming `planning-boundary-rule.md` as its source.
- **Rationale:** The rule that owns the set prescribes exactly this remedy for the duplication, and the existing
  precedent already implements it. The set also has one commit of history behind it, so there is no observed drift to
  respond to.
- **Evidence:**
  - `han-planning/references/planning-boundary-rule.md`, whose accepted-file-set section owns the set and prescribes the
    citing comment.
  - `han-github/skills/work-items-to-issues/scripts/upload-screenshots.sh:6-8` and `:48`, the existing encoding with its
    citing comment.
  - `han-core:software-architect` finding `A7`, ledger row `R1-C8`.
- **Rejected alternatives:**
  - Extract a shared Bash constant across the encodings — rejected under the YAGNI gate; deferred with a trigger. A
    shared constant would also have to live outside every skill's own directory, which
    [D-1](#d-1-four-per-skill-copies-of-the-design-image-check) rules out.
- **Specialist owner:** `han-core:software-architect`
- **Revisit criterion:** If the set changes and an encoding is found to have been missed.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2 (confirmed in the YAGNI sweep)
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Deferred (YAGNI)

### D-14: plan-work-items records only the material its own run received

- **Question:** On a run with two boundary records, does `plan-work-items` copy the inherited record's visual-material
  rows into the record beside its own deliverable?
- **Decision:** No. It writes only the rows for material its own run received, and names the inherited record's path in
  Record Provenance. One sentence of prose in that skill, with no new column, no flag, and no script change.
- **Rationale:** [D-2](#d-2-two-positional-arguments-no-flags) has the caller name the record to read, and
  [D13](decision-log.md#d13-read-the-record-beside-the-deliverable-being-gated) makes that the record beside the
  deliverable. That check is only correct if the record beside the deliverable is self-consistent, which this makes it.
  Naming the inherited path is something the boundary rule already requires, so nothing new is introduced.
- **Evidence:**
  - `han-planning/references/planning-boundary-rule.md:36-37`, which already requires the inherited path in Record
    Provenance.
  - `han-core:software-architect` finding `A3` and `han-core:adversarial-security-analyst` finding `S-12`, ledger row
    `R1-C7`. Both raised it and both proposed this resolution independently.
- **Rejected alternatives:**
  - A provenance column on the record's material table — rejected as a format change where a sentence suffices.
  - A `--this-run-only` flag on the script — rejected under the YAGNI gate as a configuration knob with no caller
    needing the other setting; deferred with a trigger.
  - Have the check read both records and reconcile them — rejected because two records can legitimately differ, so
    reconciliation has no correct answer, and because it contradicts `D13`.
- **Specialist owner:** `han-core:software-architect`
- **Revisit criterion:** If an observed two-folder run shows an operator expecting inherited rows to appear beside the
  later deliverable.
  Unverified: could not inspect a real two-folder `plan-work-items` run, because no plan folder in this repository
  exercises the split-folder case, so this rests on the rule's text rather than an observed run.
- **Dissent (if any):** None.
- **Driven by rounds:** R1 (raised as `OQ-2`, resolved by evidence), R2 (confirmed in the YAGNI sweep)
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Risks and Assumptions

### D-18: The prose-edit majority gets no test, and the plan says so

- **Question:** Most of this feature is prose edits inside skill files. What tests cover them?
- **Decision:** None, deliberately, and the plan states that in writing rather than letting a test suite imply coverage
  it does not have. The expert-count reductions, the checklist removals, the stale repeat-count correction, and the
  narrated-check annotation all ship with no automated test.
- **Rationale:** A test over instruction prose can only assert that a string is present. It proves the string exists and
  nothing about whether the number in it is right, whether it agrees with a neighbouring sentence, or whether the
  instruction reads coherently. A suite that appears to cover the prose edits is worse than no suite, because a reader
  infers coverage from its existence. Saying so in the plan is what keeps the gap visible.
- **Evidence:**
  - `han-core:test-engineer`'s assessment of the prose-edit category, ledger row `R1-C16`.
  - The specification's own decision log calls the repeat-count correction an implementation task rather than a runtime
    behavior ([D8](decision-log.md#d8-correct-the-contradictory-repeat-count)).
- **Rejected alternatives:**
  - Grep-based assertions that each skill's size bands name the reduced counts — rejected because the assertion passes
    on a file whose surrounding prose contradicts the number it matched.
  - A test asserting each skill's permission frontmatter declares the check — dropped, not merely rejected. It was the
    one prose edit worth testing precisely because a frontmatter field is structured, and
    [D-12](#d-12-no-permission-frontmatter-edits-in-any-skill) removed the field it would have asserted.
- **Specialist owner:** `han-core:test-engineer`
- **Revisit criterion:** If a prose edit in these skills is later found to have regressed silently.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2 (the frontmatter test was dropped in the YAGNI sweep)
- **Dependent decisions:** —
- **Referenced in plan:** Testing Strategy, Work Units and Sequencing, Risks and Assumptions

### D-19: Consolidate the test cases by behavior, not one per specification row

- **Question:** The specification lists thirteen edge-case rows. Does each get its own test?
- **Decision:** No. Eleven of the thirteen are check behavior and two are not testable at all. The eleven collapse into
  a smaller set of behavior-shaped cases: one parametrized case covers all-missing and partial-missing and asserts the
  count of named missing items rather than that at least one was named; one case with three fixture rows covers the
  three malformed-row conditions; and one refusal case is added per rejected shape class.
  - The rejected shape classes: absolute path, `..` traversal, glob metacharacter, command-substitution text, an
    unaccepted extension, and one cell whose text reads as an instruction.
- **Rationale:** The specification's rows are conditions, not test cases, and several state the same behavior under
  different inputs. Asserting the count of named missing items is what distinguishes a check that names every missing
  item from one that stops at the first. The shape-class cases are the ones that would otherwise have no coverage at
  all, because no specification row enumerates them.
- **Evidence:**
  - `han-core:test-engineer`'s per-row walk of the specification's edge-case table, ledger row `R1-C15`, which found
    eleven of the thirteen rows to be check behavior and two to be untestable.
  - `.discovery-notes.md`, recording the Bats style the cases follow: a `mktemp -d` sandbox in `setup()`, removed in
    `teardown()`, with helpers parsing line-oriented output.
- **Rejected alternatives:**
  - One test per specification edge-case row — rejected because two rows are not testable and several duplicate each
    other's behavior, so the mapping would produce empty and redundant cases and imply the two untestable rows were
    covered.
  - Assert only that a missing-item failure names at least one item — rejected because it passes on a check that stops
    after the first miss, which is the partial-loss failure the gate exists to catch.
- **Specialist owner:** `han-core:test-engineer`
- **Revisit criterion:** If a refusal shape reaches production that none of the shape-class cases represents.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Testing Strategy, Definition of Done
