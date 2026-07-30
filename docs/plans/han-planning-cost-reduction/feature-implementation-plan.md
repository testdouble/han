# Feature Implementation Plan: Cheaper, Faster Planning Runs

This plan builds the specification's three changes into the five `han-planning` skills. Two of them convene smaller
review teams. Four of them gain an executed check that design images listed in the boundary record are on disk. One
gains an executed check that a reviewed plan's cross-references resolve. Three stop proofreading text the readability
editor already rewrote.

Most of the work is prose editing inside skill instruction files. The part that is not is two new Bash scripts. Both
scripts read values out of documents an earlier run wrote, and how they read those values is where nearly every
decision in this plan went.

## Outcome

When this plan is executed, five skill files in `han-planning` carry reduced expert counts, one executed check each, and
no second readability pass where an editor already ran. Two new scripts exist: a design-image check, in four
byte-identical per-skill copies, and a cross-reference check, in one. Two new test files exist beside them. No
permission frontmatter changed anywhere.

The operator gets the saving the specification promised, plus a check that can fail. Where a check cannot verify, the run
says so in its summary and writes it into the plan folder, so the next skill in the chain does not read that folder as
fully verified.

## User Stories

- **US-1:** As an operator running `plan-implementation` or `iterative-plan-review`, I want the review team to consult
  fewer domain experts, so that a run costs me less waiting time and less budget.
- **US-2:** As an operator running any of the four skills that gate on design material, I want the design-image check to
  run, so that I find out which images are missing instead of reading a claim that they were checked.
- **US-3:** As an operator running `iterative-plan-review`, I want the cross-reference check to run, so that a
  broken link between a plan and its companion files is found before I rely on it.
- **US-4:** As an operator, I want a check that refused a value or never started to say which of those happened, so that
  I know whether to fix the record or the check.
- **US-5:** As an operator, I want the run to stop walking a readability checklist over text the editor already rewrote,
  so that I wait less without losing any fact from my plan.
- **US-6:** As an operator whose planning work spans several skills, I want an unverified check recorded in the plan
  folder, so that the next run in the chain inherits the truth rather than a clean-looking folder.

## Constraints and Boundaries

- **Driving constraint:** cost and wall-clock time on every planning run, which is what the source research measured and
  what the operator asked to reduce. Nothing here is deadline-driven.
- **Recorded boundary:** [artifacts/scope-boundary.md](artifacts/scope-boundary.md). The boundary is the research report
  at `docs/research/han-planning-cost-reduction.md` plus the operator's invocation text; there is no ticket. It names two
  skills for the expert reduction and one skill's step for the cross-reference conversion. It excludes the question
  cadence, model routing, prose compression, and splitting the oversized skill files.
- **Out of scope:** every exclusion the specification records, unchanged. In particular this plan lowers no repeat
  ceiling, edits no agent or editor definition, and touches no skill outside the five planning skills.
- **No permission frontmatter is edited**, in any of the five skills. The operator approves each check once per run
  instead ([D-12](artifacts/implementation-decision-log.md#d-12-no-permission-frontmatter-edits-in-any-skill)). This
  overturned a commitment the specification originally made, and the specification was corrected to match.
- **No production surface exists.** These are Markdown instruction files and two Bash scripts that run on an operator's
  machine during a planning session. There is no service, no deployment, no pipeline change, and no telemetry, so this
  plan carries no operational-readiness or on-call section. That absence is a judgment recorded here, not an omission.
- **Watch after ship:** whether the four copies of the design-image check stay identical, and whether the reduced teams
  change the quality of a plan. The second is unmeasured and deferred until after implementation, because the comparison
  needs the reduced counts to exist first.

## Implementation Approach

The work splits cleanly into two halves that barely touch each other. One half is prose editing inside five skill files:
reduced expert counts, removed checklist passes, a corrected repeat count, and the sentences that invoke the new checks.
The other half is two Bash scripts with tests. The prose half carries almost no risk and almost no test coverage; the
script half carries nearly all of both.

The scripts follow the repository's existing shape for skill scripts rather than inventing one. Each lives in its own
skill's `scripts/` directory and is invoked from the skill body by its expanded skill-directory path. Each opens with
the same strict-mode and argument-guard preamble the existing screenshot uploader uses, and takes its tests in a `.bats`
file of the same basename sitting beside it
([D-15, D-16](artifacts/implementation-decision-log.md#trivial-decisions)).

- `${CLAUDE_SKILL_DIR}/scripts/<name>.sh` is the invocation form.
- ShellCheck already runs over every script in the repository through `prek` and `npm run lint`, so the new scripts
  inherit that gate and this plan adds no new one
  ([D-17](artifacts/implementation-decision-log.md#trivial-decisions)).

### How the design-image check is carried by four skills

Four skills need the same check, so each gets its own copy of it. The four copies are byte-identical except for a mutual
comment naming the other three. The repository's authoring guidance requires this, and it matches what its one existing
precedent for a shared script already does
([D-1](artifacts/implementation-decision-log.md#d-1-four-per-skill-copies-of-the-design-image-check)). Only one of the
four carries a test file; that test exercises the check through the canonical copy and separately asserts the other three
are identical to it
([D-3](artifacts/implementation-decision-log.md#d-3-one-test-file-plus-a-drift-assertion-not-four)).

The check learns nothing by itself. The calling skill hands it the record to read and the folder to look in, as two
positional arguments and no flags, because the choice of which record to read belongs to the caller
([D-2](artifacts/implementation-decision-log.md#d-2-two-positional-arguments-no-flags)). That is what makes the check
correct on a run where two boundary records exist. The specification already settled that case in favor of the record
beside the deliverable being gated.

- Carried by `plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, and `plan-work-items`.

### How the check reads the record

This is the decision-bearing part of the whole plan. The check walks the record's received-material section row by row
and puts every row it finds into exactly one of three buckets: a recorded link, an accepted file location, or a refusal.
It reports how many rows it examined, so a record listing nothing reads differently from a record whose every row was
refused ([D-5](artifacts/implementation-decision-log.md#d-5-row-oriented-per-row-accounting-never-extraction-by-pattern)).
The alternative shape, pulling matching filenames out of the record with a pattern, would have satisfied a reviewer
looking for an allow-list. But it would have made every refusable row invisible, which is the vacuous pass this feature
exists to remove.

An accepted location has to match an anchored allow-list of permitted characters and accepted file types. Before that
check runs, at most one surrounding pair of backticks is stripped, and the design folder's own name is allowed as an
optional prefix. Anything containing a parent-directory reference is refused. The check does not normalize the value, does not resolve it against
the filesystem before validating it, and does not retry a repaired version of something it refused
([D-6](artifacts/implementation-decision-log.md#d-6-anchored-whole-string-allow-list-on-the-recorded-location)). The
prefix and the backticks are not leniency: the rule that owns the record format writes its own canonical example with
both, so a stricter reading would refuse every correctly written record.

- The accepted shape: `^(ui-designs/)?[A-Za-z0-9._-]+\.(png|jpg|jpeg|gif|webp|svg|pdf)$`
- The extension set is encoded here for a third time, with a comment naming
  `han-planning/references/planning-boundary-rule.md` as its source, which is the remedy that rule itself prescribes
  ([D-13](artifacts/implementation-decision-log.md#d-13-a-third-encoding-of-the-accepted-file-set-with-a-citing-comment)).

A row recording a hosted link rather than a kept file is reported present without touching disk. That branch is entered
on one test only: a literal match on the recorded marker, anchored at the start of the value
([D-7](artifacts/implementation-decision-log.md#d-7-the-link-branch-is-a-leading-anchored-literal-match)). It is the
highest-value single line in either script, because it is the one branch that passes without looking at the filesystem.

- The form: `case "$kept" in '(not a file)'*)`

### How the cross-reference check differs

It lands in `iterative-plan-review` only, with one copy, no sync comment, and no plumbing shared with its twin. It is
also the larger job of the two and is planned as such: the step it replaces states four invariants, three of them
conditional on the review's mode, plus awareness of markdown fenced blocks
([D-4](artifacts/implementation-decision-log.md#d-4-the-cross-reference-check-is-one-copy-and-materially-larger-work)).

Its own input risk is different from the design-image check's. It reads a plan document and then searches that plan's
companions for what it found, so document text has to reach a search without becoming part of the search's syntax. It
extracts identifiers with its own anchored patterns and searches for any document-supplied value as a fixed string. It
decides whether a match is inside an example block as it walks the file, rather than filtering example hits out
afterward
([D-8](artifacts/implementation-decision-log.md#d-8-the-cross-reference-check-never-builds-a-pattern-from-document-text)).

### How an outcome reaches the run

The exit status carries which of the three outcomes happened, and prose never does. Each printed line is quoted document
text, and the skill step says so in words, because the script cannot control how its own output is read
([D-9](artifacts/implementation-decision-log.md#d-9-exit-status-carries-the-outcome-and-prose-never-does)).

Both scripts print the same shape, so both scripts and both test files share one vocabulary. The shape is the
line-oriented `key: value` form this repository already uses in its other detector scripts. Detail follows the prose that
describes it:

```
result: passed | failed | unverified
reason: <named reason>          # present only when result is unverified
missing: <item name>            # zero or more, only when result is failed (design-image check)
refused: row=<n> item=<name>    # zero or more, only when result is failed (design-image check)
missing-target: <id> <where>    # zero or more, only when result is failed (cross-reference check)
empty-field: <id> <field>       # zero or more, only when result is failed (cross-reference check)
```

The two failure keys on each check are separate because the specification requires an operator to tell the two failures
apart. The shape is a convention rather than shared code: the two scripts stay independent, and agreeing on the
vocabulary costs nothing to maintain and cannot break.

One part of the specification's requirements happens outside the scripts entirely. Recording an unverified check into the
plan folder is a write the skill performs, so the script's input handling does not cover it. The skill instruction writes
a bounded excerpt inside a fenced block rather than dropping a raw cell into prose or a table
([D-10](artifacts/implementation-decision-log.md#d-10-the-skill-writes-the-unverified-record-as-a-fenced-excerpt)). This
is the easiest thing in the plan to miss, because everything else about untrusted values lives in the scripts.

### The one convention change outside the scripts

`plan-work-items` can hold two boundary records, one inherited and one beside its own deliverable. It writes only the
rows for material its own run received and names the inherited record's path in provenance, which the boundary rule
already requires. That is one sentence of prose in that skill, with no new column, no flag, and no script change
([D-14](artifacts/implementation-decision-log.md#d-14-plan-work-items-records-only-the-material-its-own-run-received)).

## Work Units and Sequencing

| #   | Work Unit                                                                 | Story            | Delivers                                                                                                                                                                                                      | Justification                                                                                                                                                                            | Depends On | Verification                                                                                                                                                     |
| --- | ------------------------------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Reduce the domain-expert counts in `plan-implementation`                  | US-1             | A `plan-implementation` run convenes three or four experts at large, two at medium, one at small, with the parallel first wave and the ceilings intact                                                        | The boundary's Stated Scope names this skill first for the reduction                                                                                                                     | —          | Read-through against the size bands; no test, by [D-18](artifacts/implementation-decision-log.md#d-18-the-prose-edit-majority-gets-no-test-and-the-plan-says-so) |
| 2   | Reduce the domain-expert counts in `iterative-plan-review`                | US-1             | A team-mode review convenes two experts at large and one at medium, with its smallest size still convening no team                                                                                            | The boundary's Stated Scope names this skill's team mode; the derived counts were confirmed by the operator, closing OI-1                                                                | —          | Read-through; no test, by [D-18](artifacts/implementation-decision-log.md#d-18-the-prose-edit-majority-gets-no-test-and-the-plan-says-so)                        |
| 3   | Correct the stale repeat count in `iterative-plan-review`                 | US-1             | The skill's own stated repeat range matches the ceilings it enforces                                                                                                                                          | A necessity of committing to the current ceilings; the specification calls it an implementation task                                                                                     | 2          | Read-through; no test, by [D-18](artifacts/implementation-decision-log.md#d-18-the-prose-edit-majority-gets-no-test-and-the-plan-says-so)                        |
| 4   | Retire the second readability pass in the three editor-running skills     | US-5             | `plan-a-feature`, `plan-implementation`, and `plan-a-phased-build` read the editor's fact-preservation report instead of re-walking the checklist, and keep the checklist text as the editor-failure fallback | The boundary's Stated Scope names all three skills for this change                                                                                                                       | —          | Read-through; no test, by [D-18](artifacts/implementation-decision-log.md#d-18-the-prose-edit-majority-gets-no-test-and-the-plan-says-so)                        |
| 5   | Build the design-image check and its tests, in `plan-a-feature`           | US-2, US-4       | A script that reads a boundary record and a designs folder and returns passed, failed with every missing item named, or could not verify                                                                      | The boundary's Stated Scope names the completeness gate's file-existence check for conversion                                                                                            | —          | Its own `.bats` file, run by `npm test`; ShellCheck through `npm run lint`                                                                                       |
| 6   | Replicate the check into the other three skills, with the drift assertion | US-2             | Byte-identical copies in `plan-implementation`, `plan-a-phased-build`, and `plan-work-items`, and a test that fails if any of them drifts                                                                     | A necessity of the four-copy shape a written authoring rule requires ([D-1](artifacts/implementation-decision-log.md#d-1-four-per-skill-copies-of-the-design-image-check))               | 5          | The drift assertion in the same `.bats` file                                                                                                                     |
| 7   | Wire the four skills' prose to the executed check                         | US-2, US-4, US-6 | Each of the four skills invokes the check with the record beside its own deliverable, reports one of three outcomes, and records an unverified outcome in the artifacts                                       | A necessity of the conversion: a script no skill invokes changes nothing                                                                                                                 | 5, 6       | Read-through; the behavior underneath it is covered by unit 5's tests                                                                                            |
| 8   | Add the `plan-work-items` record convention                               | US-2             | That skill records only the visual material its own run received, and names the inherited record's path in provenance                                                                                         | A necessity of the check being correct in one of its four callers ([D-14](artifacts/implementation-decision-log.md#d-14-plan-work-items-records-only-the-material-its-own-run-received)) | 7          | Read-through; unverifiable against a real two-folder run, see assumption A4                                                                                      |
| 9   | Build the cross-reference check and its tests, in `iterative-plan-review` | US-3, US-4       | A script that reads a plan and its companions and reports a dangling identifier, a resolved-but-incomplete entry, or a pass, ignoring example blocks                                                          | The boundary's Stated Scope names this check by skill and step                                                                                                                           | —          | Its own `.bats` file, run by `npm test`; ShellCheck through `npm run lint`                                                                                       |
| 10  | Wire `iterative-plan-review`'s prose to the executed check                | US-3, US-4, US-6 | That skill's cross-reference step invokes the check, reports one of three outcomes, and records an unverified outcome in the artifacts                                                                        | A necessity of the conversion                                                                                                                                                            | 9          | Read-through; the behavior underneath it is covered by unit 9's tests                                                                                            |
| 11  | Record why the third check stays narrated                                 | US-4             | The skills carrying the uninspected-input check state, at that step, that it runs on returned reviewer output rather than on a file                                                                           | The specification commits to this annotation as part of leaving that check narrated                                                                                                      | —          | Read-through; no test, by [D-18](artifacts/implementation-decision-log.md#d-18-the-prose-edit-majority-gets-no-test-and-the-plan-says-so)                        |

Units 1 to 4 and unit 11 are prose-only and independent of everything else, so they can land first and in any order.
Units 5 to 8 are one chain. Unit 9 is the largest single unit in the plan and depends on nothing, so it can start in
parallel with the design-image chain, but it should not be squeezed into the same budget
([D-4](artifacts/implementation-decision-log.md#d-4-the-cross-reference-check-is-one-copy-and-materially-larger-work)).

## Definition of Done

- [x] `plan-implementation` and `iterative-plan-review` state the reduced expert counts, and both still dispatch every
      team member in one parallel wave.
- [x] `iterative-plan-review` states no repeat range that exceeds its own ceilings.
- [x] The three editor-running skills read the editor's fact-preservation report, and each still carries the checklist
      text as the fallback for an unusable report.
- [x] A record listing no visual material passes, and a record whose every row is refused fails, and the two outputs are
      distinguishable ([D-5](artifacts/implementation-decision-log.md#d-5-row-oriented-per-row-accounting-never-extraction-by-pattern)).
- [x] A record listing five images with three on disk fails and names both missing items, not one
      ([D-19](artifacts/implementation-decision-log.md#d-19-consolidate-the-test-cases-by-behavior-not-one-per-specification-row)).
- [x] A row recording a hosted link is reported present with no fetch attempted, and the branch is entered only on the
      recorded marker ([D-7](artifacts/implementation-decision-log.md#d-7-the-link-branch-is-a-leading-anchored-literal-match)).
- [x] A refused value is refused, not resolved, and the run's report names its row without the sandbox being touched
      ([D-6](artifacts/implementation-decision-log.md#d-6-anchored-whole-string-allow-list-on-the-recorded-location)).
- [x] Each check returns a distinct exit status for passed, failed, and could-not-verify, and never reports
      could-not-verify as a pass ([D-9](artifacts/implementation-decision-log.md#d-9-exit-status-carries-the-outcome-and-prose-never-does)).
- [x] A cross-reference inside an example block is ignored, and a resolved-but-empty target fails with a reason textually
      distinct from a dangling one.
- [x] An unverified check appears in the plan folder's artifacts as a fenced excerpt, not only in the run's summary
      ([D-10](artifacts/implementation-decision-log.md#d-10-the-skill-writes-the-unverified-record-as-a-fenced-excerpt)).
- [x] The four copies of the design-image check are byte-identical except for their mutual note, and a test asserts it
      ([D-3](artifacts/implementation-decision-log.md#d-3-one-test-file-plus-a-drift-assertion-not-four)).
- [x] `npm test` and `npm run lint` both pass.
- [x] No skill's `allowed-tools` frontmatter differs from what is on disk today
      ([D-12](artifacts/implementation-decision-log.md#d-12-no-permission-frontmatter-edits-in-any-skill)).

## Testing Strategy

The tests cover the two scripts and nothing else. Eleven of the specification's thirteen edge-case rows describe check
behavior and are covered; two describe states no test can reach, and they are not covered.

The larger half of this feature by volume, the prose edits, gets no tests at all, and this plan states that rather than
shipping a suite that implies otherwise
([D-18](artifacts/implementation-decision-log.md#d-18-the-prose-edit-majority-gets-no-test-and-the-plan-says-so)).
A grep proving a number appears in a skill file proves the string exists and nothing about whether it is right or whether
the sentence beside it contradicts it.

- **Observable behaviors to test, design-image check:** a record listing nothing passes; a record with missing items
  fails and names every one of them; a malformed row is refused rather than resolved; a recorded link is accepted with
  nothing fetched; a missing or unreadable record reports could-not-verify and names the record; injection-shaped cell
  text is reported verbatim in the refusal with the sandbox untouched.
- **Observable behaviors to test, cross-reference check:** the happy path, which is the only place a pass is exercised; a
  dangling identifier fails naming the reference and where it sits; a resolved target with an empty required field fails
  with a textually distinct reason; a reference inside an example block is ignored; a missing input reports
  could-not-verify.
- **Edge cases requiring coverage:** one refusal case per rejected shape class, because no specification row enumerates
  them.
  - Absolute path, parent-directory traversal, glob metacharacter, command-substitution text, an unaccepted extension,
    and one cell whose text reads as an instruction.
- **Case consolidation:** all-missing and partial-missing collapse into one parametrized case asserting the count of
  named missing items; the three malformed-row conditions collapse into one case carrying three fixture rows
  ([D-19](artifacts/implementation-decision-log.md#d-19-consolidate-the-test-cases-by-behavior-not-one-per-specification-row)).
- **Test doubles posture and levels:** none needed. Both scripts read the filesystem and nothing else, so every case is a
  Bats test over a temporary sandbox built in `setup()` and removed in `teardown()`, following the existing detector
  tests' style. No unit, integration, and end-to-end split applies.
- **Where tests live and how they run:** beside each script, same basename, `.bats` extension, collected by `npm test`
  ([D-16](artifacts/implementation-decision-log.md#trivial-decisions)). ShellCheck runs over both scripts through the
  existing `npm run lint` gate ([D-17](artifacts/implementation-decision-log.md#trivial-decisions)).
- **Not covered, deliberately:** the two untestable specification rows (an existing plan folder written under the old
  behavior, and an operator wanting broader coverage than the reduced default), and the correction of the stale repeat
  count, which the specification's own decision log calls an implementation task.

## Security Posture

Both checks read values out of a document that some earlier run, or a person, wrote by hand. Those values reach something
that executes. That is the whole threat surface, and it is the reason most of this plan's decisions exist.

**The vacuous pass, which is the threat the feature itself is about.** Reading the record by extracting matching values
with a pattern would make every refusable row invisible: a record with five malformed rows would produce output identical
to a record with no rows, and the empty record has to pass. Per-row accounting with a reported row count is the
mitigation ([D-5](artifacts/implementation-decision-log.md#d-5-row-oriented-per-row-accounting-never-extraction-by-pattern)).

**A crafted file location.** Mitigated by an anchored whole-string allow-list of permitted characters and accepted
extensions, with parent-directory references refused outright. There is no normalization, no filesystem resolution
before validation, and no retry of a repaired variant
([D-6](artifacts/implementation-decision-log.md#d-6-anchored-whole-string-allow-list-on-the-recorded-location)). The
allow-list direction is deliberate: a deny-list fails open on the next shape nobody thought of.

**A row talking its way into the link branch.** That branch reports material present without touching disk, so anything
that reaches it wrongly is a pass for material nobody kept. Mitigated by a single leading-anchored literal match on the
recorded marker, with no substring test, no scheme test, and no inference from how a value looks
([D-7](artifacts/implementation-decision-log.md#d-7-the-link-branch-is-a-leading-anchored-literal-match)).

**Document text becoming search syntax.** Plan headings are free prose, and a heading interpolated into a pattern is
syntax. Mitigated by extracting identifiers with the script's own anchored patterns, and searching for document-supplied
values as fixed strings with an explicit end-of-options marker before the filename. The check also toggles
example-block state while walking the file, rather than filtering example hits out afterward
([D-8](artifacts/implementation-decision-log.md#d-8-the-cross-reference-check-never-builds-a-pattern-from-document-text)).

**Untrusted text crossing into an artifact the next run reads.** The unverified-check record is written by the skill,
outside the scripts, so it is outside their input handling. Mitigated by writing a bounded excerpt inside a fenced block
([D-10](artifacts/implementation-decision-log.md#d-10-the-skill-writes-the-unverified-record-as-a-fenced-excerpt)).

**Untrusted text reaching the operator's turn.** Mitigated by identifying a refusal by row number and item name, and
echoing the offending value only where the operator needs it. That happens through one bounded transform: it strips
control characters, collapses newlines and tabs, truncates, and emits a single labeled line
([D-11](artifacts/implementation-decision-log.md#d-11-a-refusal-names-the-row-and-the-item-and-echoes-the-value-only-where-needed)).

**Outcome reported as prose rather than status.** Mitigated by distinct exit statuses for the three outcomes, with the
skill step stating that the run reports the status's outcome and treats every printed line as quoted document text
([D-9](artifacts/implementation-decision-log.md#d-9-exit-status-carries-the-outcome-and-prose-never-does)).

**Permission surface.** No skill's frontmatter is edited, and no permission prefix is widened. Widening to any wildcard
over shell or script names would auto-approve arbitrary shell for the rest of a run, in skills that also hold write
access ([D-12](artifacts/implementation-decision-log.md#d-12-no-permission-frontmatter-edits-in-any-skill)). No
permission any skill holds is treated as making a value safe to use; a command approval constrains the command, not its
arguments.

**What must not ship, stated so a reviewer can look for it:**

- Extraction by grep in place of per-row accounting.
- A link branch on anything but the anchored literal marker.
- `eval`, an unquoted value in a command word, re-expansion through backticks or `$(...)`, or a filesystem test built
  from a glob.
- A check that repairs anything it gates.
- A broad or wildcard permission grant, of any shape.
- Could-not-verify reported as a success status.
- Four copies of the design-image check that are not byte-identical.

The script preamble copies what transfers from the existing screenshot uploader: strict mode, argument-presence guards,
explicit file and directory tests, and the extension pattern with its comment naming the rule as its source
([D-15](artifacts/implementation-decision-log.md#trivial-decisions)). Presence validation is not shape validation, and
in these checks the untrusted values never reach the argument list at all.

## Risks and Assumptions

### Risks

| ID  | Risk                                                                                                                 | Impact                                                                                       | Mitigation                                                                                                                                                                                                                                       | Owner                                   |
| --- | -------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------- |
| R1  | The design-image check is implemented by copying the nearest precedent's grep extraction                             | The feature ships with the exact failure it exists to remove, and the tests would still pass | Per-row accounting with a reported row count, plus the test case that distinguishes an empty record from an all-refused one ([D-5](artifacts/implementation-decision-log.md#d-5-row-oriented-per-row-accounting-never-extraction-by-pattern))    | `han-core:adversarial-security-analyst` |
| R2  | The four copies of the design-image check drift apart                                                                | Two skills silently gate on different rules                                                  | The drift assertion in the single test file ([D-3](artifacts/implementation-decision-log.md#d-3-one-test-file-plus-a-drift-assertion-not-four)); the repository already has a sync note that drifted at two copies                               | `han-core:test-engineer`                |
| R3  | The allow-list is implemented strictly enough to refuse the boundary rule's own canonical example                    | Every correctly written record fails the check                                               | The accepted shape allows the folder prefix and strips one backtick pair, and a test case uses the rule's canonical row verbatim ([D-6](artifacts/implementation-decision-log.md#d-6-anchored-whole-string-allow-list-on-the-recorded-location)) | `han-core:adversarial-security-analyst` |
| R4  | The cross-reference check is budgeted as equivalent to its twin and lands half-built                                 | The one check the boundary named by step is the one that ships weakest                       | It is a single work unit of its own, sequenced independently, and named as materially larger work ([D-4](artifacts/implementation-decision-log.md#d-4-the-cross-reference-check-is-one-copy-and-materially-larger-work))                         | `han-core:software-architect`           |
| R5  | The artifact write is implemented without the fenced excerpt, because every other input concern lives in the scripts | Untrusted text lands unbounded in a file the next skill reads as input                       | Called out as the plan's most-missable item, with its own definition-of-done line ([D-10](artifacts/implementation-decision-log.md#d-10-the-skill-writes-the-unverified-record-as-a-fenced-excerpt))                                             | `han-core:adversarial-security-analyst` |
| R6  | The prose edits regress silently, since nothing tests them                                                           | A skill states a count that contradicts a sentence beside it, and no gate catches it         | Accepted rather than mitigated, and stated in writing instead of covered by a test that would only prove a string exists ([D-18](artifacts/implementation-decision-log.md#d-18-the-prose-edit-majority-gets-no-test-and-the-plan-says-so))       | `han-core:test-engineer`                |

### Assumptions

| ID  | Assumption                                                                                             | What Changes If Wrong                                                                                                | Status   |
| --- | ------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- | -------- |
| A1  | The skill-directory variable expands to an absolute path at run time, so the invocation form resolves  | Every invocation in all five skills is wrong, and the checks never start                                             | Verified |
| A2  | A permission prefix cannot match the expanded command, so a declaration would be inert                 | Five declarations would have been worth adding, and the operator would not approve once per run                      | Verified |
| A3  | How this host expands a skill-directory variable inside a permission prefix and inside a Bash argument | Nothing in this plan; the plan uses per-skill paths and declares no permission, so both halves are already moot      | Deferred |
| A4  | A two-folder `plan-work-items` run behaves as the boundary rule's text describes                       | The record beside the deliverable might not be self-consistent, and the whole-record check would need a second input | Deferred |
| A5  | Every new `.bats` file anywhere outside `node_modules` is collected by the test command                | The new tests exist and never run                                                                                    | Verified |
| A6  | A smaller review team produces a materially equivalent plan                                            | The saving costs plan quality, and the expert counts would need revisiting                                           | Deferred |

- A1 and A2 are settled by
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/script-execution-instructions.md`, lines 60 to
  75, plus a survey finding nine script-running skills in this repository and none declaring its own script.
- A5 is settled by the root `package.json` test script, which collects by find across the repository.
- A4 is the unobserved half of the two-record case, deferred by the operator until the symptom appears: a check failing
  on material nobody lost.
  Unverified: could not inspect a real two-folder `plan-work-items` run, because no plan folder in this repository
  exercises the split-folder case.
- A6 is inherited from the specification as OI-2 and is not this plan's to resolve. It is deferred rather than open,
  because the comparison that would settle it needs the reduced counts to exist first.

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. Nothing here carries a reopening trigger,
because the recorded boundary already settled it. The specification records six cuts in full. The two below are the ones
that determine which work units exist in this plan; the other four are recorded in
[the specification's Cut for Scope section](feature-specification.md#cut-for-scope) rather than restated here.

### Making a specification run cheaper too, by reducing the review team in `plan-a-feature`

- **Why cut:** the boundary's Stated Scope names two skills for the reduction, and `plan-a-feature` is not one of them,
  even though it convenes a comparable team and would yield a comparable saving. The operator reinstating it is the only
  route back.
- **Source:** inherited from the specification, decision
  [D2](artifacts/decision-log.md#d2-scope-the-reduction-to-the-two-skills-the-boundary-names).

### Making `plan-a-feature` and `plan-implementation` check their own cross-references automatically

- **Why cut:** the boundary names one instance of that check, by skill and step. Both of those skills carry an
  equivalent one over their own companion files, so this plan leaves two hand-run instances in place, in the two skills
  that produce the artifacts every later skill reads.
- **Source:** inherited from the specification, decision
  [D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated).

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it. Each of the eight was proposed and then declined by the specialist who raised it.

### One shared copy of the design-image check in a plugin-level scripts directory

- **Why deferred:** the evidence points the other way. A written authoring rule requires each skill to carry its own copy,
  and no plugin-level `scripts/` directory exists anywhere in this repository to follow.
- **Reopen when:** `script-execution-instructions.md` is revised to permit shared scripts, or the drift assertion starts
  failing often enough that four copies is measurably the more expensive shape.
- **Source:** R1, `han-core:software-architect`. Recorded as a rejected alternative on
  [D-1](artifacts/implementation-decision-log.md#d-1-four-per-skill-copies-of-the-design-image-check).

### A shared check harness or output-formatting library across the two scripts

- **Why deferred:** failed the evidence test at two implementations. Named anti-pattern: an abstraction before three
  concrete uses exist.
- **Reopen when:** a third executed check is added, or the two scripts' output formats have to agree for a consumer that
  reads both.
- **Source:** R1, `han-core:software-architect`. Recorded as a rejected alternative on
  [D-4](artifacts/implementation-decision-log.md#d-4-the-cross-reference-check-is-one-copy-and-materially-larger-work).

### A shared Bash constant for the accepted file set

- **Why deferred:** the rule that owns the set prescribes a citing comment as the remedy for the duplication, and the set
  has one commit of history, so there is no observed drift to respond to. A shared constant would also have to live
  outside every skill's own directory, which the four-copy rule rules out.
- **Reopen when:** the accepted file set changes and an encoding is found to have been missed.
- **Source:** R1, `han-core:software-architect`. Recorded as a rejected alternative on
  [D-13](artifacts/implementation-decision-log.md#d-13-a-third-encoding-of-the-accepted-file-set-with-a-citing-comment).

### A flag telling the design-image check to consider only this run's material

- **Why deferred:** failed the evidence test. Named anti-pattern: a configuration knob no caller sets a non-default value
  for. The one-sentence record convention makes the record beside the deliverable self-consistent, so no caller needs the
  other setting.
- **Reopen when:** a caller legitimately needs the check to consider an inherited record's rows.
- **Source:** R1, `han-core:software-architect`. Recorded as a rejected alternative on
  [D-14](artifacts/implementation-decision-log.md#d-14-plan-work-items-records-only-the-material-its-own-run-received).

### A shared validation or sanitizing helper the two scripts both call

- **Why deferred:** failed the evidence test at two implementations, and the two scripts validate different things: one
  validates a file location, the other never validates document text at all because it searches for it as a fixed string.
- **Reopen when:** a third script needs the same validation, or the two are found to need identical sanitizing.
- **Source:** R1, `han-core:adversarial-security-analyst`.

### Machine-readable output from either check

- **Why deferred:** failed the evidence test. The only consumer is the run that invoked the check, and the exit status
  already carries the outcome it acts on.
- **Reopen when:** a second consumer needs to parse a check's result rather than read its status.
- **Source:** R1, `han-core:adversarial-security-analyst`.

### A configurable extension allow-list or a strict mode

- **Why deferred:** failed the evidence test. Named anti-pattern: a configuration knob no caller sets. The accepted set
  is owned by the boundary rule, so making it configurable would let a caller disagree with the rule.
- **Reopen when:** a project needs an accepted file type the boundary rule does not name, which would be a change to the
  rule first.
- **Source:** R1, `han-core:adversarial-security-analyst`.

### An audit trail of every refused row, beyond the unverified record the specification already requires

- **Why deferred:** failed the evidence test. Named anti-pattern: an audit record nobody reads. No run has been observed
  needing the history, and the specification already requires the unverified state to reach the artifacts.
- **Reopen when:** an operator has to reconstruct which rows a past run refused and the plan folder cannot tell them.
- **Source:** R1, `han-core:adversarial-security-analyst`.

## Open Items

- **OI-1: Resolved.** The expert counts for `iterative-plan-review` were derived from the counts agreed for
  `plan-implementation` rather than agreed directly. That skill fills a third seat conditionally, so its medium band
  already carries no more than one expert on a plan that makes claims about code, and the reduction binds on the large
  band alone on those runs.
  - **Resolved by:** the operator confirmed the derived counts as they stand. Work unit 2 builds to the counts in
    [D2](artifacts/decision-log.md#d2-scope-the-reduction-to-the-two-skills-the-boundary-names) with no adjustment.
  - **Blocks implementation:** No, and no longer open. Inherited from the specification.
- **OI-2: Deferred until after implementation.** Whether a smaller team produces a materially different plan is
  unmeasured, and the source research says the honest sequencing is to measure before committing to a permanent count.
  - **Why deferred rather than open:** the comparison cannot be run until the reduced counts exist to compare against, so
    this plan has no way to close it. The operator deferred it on those grounds and will open separate work if the
    comparison turns out to be worth running.
  - **Resolves when:** after this plan ships, one real plan is run at the old counts and the new counts and the outputs
    compared. Tracked as a deferral rather than a blocker, alongside the cost-measurement entry under
    `## Deferred (YAGNI)`, which carries the same trigger.
  - **Blocks implementation:** No, and it cannot be worked before implementation. Inherited from the specification and
    carried as assumption A6.
- **OI-3: Resolved by deferral.** How this host expands a skill-directory variable inside a permission prefix, and
  inside a Bash argument, could not be inspected from this repository.
  - **Resolved by:** the operator closed it by deferral. The underlying question is still unanswered, and this plan
    stops carrying it because two decisions made it moot: the permission half by
    [D-12](artifacts/implementation-decision-log.md#d-12-no-permission-frontmatter-edits-in-any-skill), which declares no
    permission, and the argument half by
    [D-1](artifacts/implementation-decision-log.md#d-1-four-per-skill-copies-of-the-design-image-check), which gives every
    invocation the skill's own path.
  - **Reopens if:** anyone proposes replacing the four per-skill copies with one shared copy. That proposal cannot be
    evaluated without the answer, and the deferred entry for a shared scripts directory under `## Deferred (YAGNI)`
    carries the same dependency.
  - **Blocks implementation:** No, and no longer open.
    Unverified: could not inspect the host runtime, because it lives outside this repository.
- **OI-4: Resolved by deferral, until the problem is seen.** No plan folder in this repository exercises the two-folder
  `plan-work-items` case, so the record convention in work unit 8 rests on the boundary rule's text rather than an
  observed run.
  - **Resolved by:** the operator closed it by deferral, on the grounds that the convention is worth building as written
    and worth revisiting only if it misbehaves. Work unit 8 ships the one sentence unchanged.
  - **Reopens if:** a real two-folder run fails the design-image check on material nobody lost, which is the symptom this
    would produce. That symptom is specific enough to recognize without watching for it.
  - **Blocks implementation:** No, and no longer open. Carried as assumption A4.
    Unverified: could not inspect a real two-folder run, because no plan folder in this repository exercises the case.

## Sources and Plan Records

- **Feature specification:** [feature-specification.md](feature-specification.md)
- **Specification companions:** [decision log](artifacts/decision-log.md), [team findings](artifacts/team-findings.md),
  [scope boundary](artifacts/scope-boundary.md). No `feature-technical-notes.md` exists for this feature, so no `T#`
  mechanic constrains this plan and none is cited; that absence is a fact about the specification, not a gap in it.
- **Specification decisions inherited:** D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13
- **Specification open items respected:** OI-1 (closed by the operator) and OI-2 (deferred until after implementation),
  carried above under the same identifiers
- **Decision rationale and rejected alternatives:**
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Team composition and round-by-round history:**
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)

## Recommendation

Ship as planned. Every open item is non-blocking, and no specialist named a handoff for implementation. The four
work units carrying real risk each have a test file or a named definition-of-done line against them. Start with the
prose-only units to bank the saving early, and give the cross-reference check its own budget rather than treating it as
the design-image check's twin.
