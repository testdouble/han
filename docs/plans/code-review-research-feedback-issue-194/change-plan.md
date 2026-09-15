# Change Plan: Code Review and Research Response to Feedback Issue #194

## Why This Change

Feedback issue #194 reports four defects in two Han skills, three in `code-review` and one in `research`. This is a
finding already established: the issue is a retrospective filing from a local observation log. Each defect is a run
that already happened, with the failure written down at the time by the run that hit it. The issue names what unites
three of them in its own words: "a check that confirms a _reference exists_ while never confirming it _points at the
right thing_."

The fourth, and the one the issue lists first, is a different failure. A `code-review` run in an environment that
forbids agent dispatch produced a complete-looking report that never disclosed that no specialist had read the change.

Source: [testdouble/han#194](https://github.com/testdouble/han/issues/194), quoted in full in
[`artifacts/scope-boundary.md`](artifacts/scope-boundary.md).

## What Changes, In One Paragraph

After this change, both skills say out loud what they did not do, and both check that a reference points at the right
thing rather than merely at something. `code-review` gains a named mode it enters when it cannot dispatch specialists,
a by-hand sweep that substitutes for them, and a report section that records which coverage was absent. It gains a
checklist category that fires when a diff changes what gets packaged. That category tells the reviewer the review did
not open the built artifact, and names what to check by hand. It gains a rule that a finding's location must be confirmed by reading
the unit that contains it, never carried forward from the last header a scan passed. And `research` gains a two-part
traceability invariant, a recorded old-to-new mapping across the merge that renumbers its source identifiers, and a
rewrite through that mapping covering every surface a citation lives on.

## Current State

`code-review` dispatches specialist agents as its primary analysis engine and has no name for the state where it
cannot. One sentence in its collection step is the whole of its response, and it says only which sub-steps to skip
([C-1](artifacts/current-state-findings.md#c-1-the-only-handling-of-no-agents-ran-is-a-step-skip-guard-not-a-mode)).
Nothing downstream renders a disclosure: the report template's only always-present elements are its summary table and
its recommendation, and the structural verification list has no item requiring a coverage statement
([C-2](artifacts/current-state-findings.md#c-2-no-downstream-surface-renders-a-coverage-disclosure)). The closing
message has four fixed parts and coverage is not among them
([C-3](artifacts/current-state-findings.md#c-3-the-closing-message-has-four-fixed-parts-and-coverage-is-not-one-of-them)).
Agent selection reasons only about signals in the changed-file list, so an environment that forbids dispatch is
invisible until a tool call fails
([C-4](artifacts/current-state-findings.md#c-4-agent-selection-reasons-only-about-file-list-signals-never-about-whether-dispatch-is-reachable)),
and the manual review runs at its normal depth either way, never scoped to substitute for what the agents cover
([C-5](artifacts/current-state-findings.md#c-5-the-manual-review-is-never-scoped-to-substitute-for-the-specialist-categories)).

The checklist governs source text only. No category reaches built output, and the review step actively skips compiled
output ([C-6](artifacts/current-state-findings.md#c-6-the-checklist-governs-source-text-only-and-the-procedure-actively-steers-away-from-built-output)).
The skill's only instruction about a finding's location is to include one. The verification item that looks like a
check on it resolves the path against a file list, rather than reading the code
([C-8](artifacts/current-state-findings.md#c-8-no-rule-resolves-the-enclosing-member-of-a-cited-location-and-the-check-that-looks-like-one-tests-the-file)).

In `research`, the traceability invariant is resolvability, stated identically in four places. Each place describes the
existence of a target rather than a match between what an entry says and what the claim it supports asserts
([C-10](artifacts/current-state-findings.md#c-10-researchs-traceability-invariant-is-resolvability-stated-identically-in-four-places)).
Every parallel analyst mints its sources from `A1`, and the band caps put two to eight analysts in one wave above the
small band. The collision is structural rather than incidental. The merge consolidates them into one sequence with
no recorded mapping and no instruction to rewrite citations through one
([C-11](artifacts/current-state-findings.md#c-11-every-parallel-analyst-mints-a1-independently-and-the-merge-renumbers-with-no-mapping)).
A second citation surface sits inside the registry being renumbered. Each entry's evidence-status field cross-references
other sources by identifier, written by an analyst against that analyst's own numbering, and no step names it
([C-19](artifacts/current-state-findings.md#c-19-a-second-citation-surface-sits-inside-the-registry-being-renumbered)).

**The structural property this change addresses.** In both skills, the site that verifies and the claim it guards have
come apart. Each verification reads a property that is cheap to check and adjacent to the one that matters: that a path
appears in a list, that an identifier resolves to an entry, that a step was skipped. Nothing reads the thing the
reference points at.

Three findings shape how the change can be built, more than the defects themselves do. The `code-review` skill body
sits five lines under a ceiling the authoring guidance sets, with two commits in the recorded history spent enforcing
it. New instruction content goes into reference files, and the body gains at most a pointer
([C-15](artifacts/current-state-findings.md#c-15-code-reviewskillmd-sits-five-lines-under-a-ceiling-the-guidance-sets-and-two-commits-have-already-enforced)).
The repository already carries both patterns this change needs. The first is a named-mode degradation rule whose own
worked example is this skill's git modes ([C-13](artifacts/current-state-findings.md#c-13-the-repository-already-has-a-named-mode-degradation-pattern-and-code-review-already-uses-it)).
The second is a sibling skill that discloses an unaudited evidence class in both its artifact and its summary, for the
stated purpose of making a coverage gap visible rather than silent
([C-14](artifacts/current-state-findings.md#c-14-one-sibling-skill-already-carries-the-coverage-disclosure-pattern-in-both-its-artifact-and-its-summary)).
And `code-review`'s own parallel fan-out cannot produce the collision `research` produces, for two independent reasons,
which bounds the change rather than widening it
([C-21](artifacts/current-state-findings.md#c-21-code-reviews-own-fan-out-is-structurally-immune-to-the-same-defect)).

## Target State

### `code-review`: a named mode, a sweep, and a disclosure

The skill has a mode called **manual-only mode**, which it enters when the dispatch attempt produces no agent results.
The name is not a fourth letter in the existing Mode A / Mode B / Mode C series
([D-1](artifacts/change-decision-log.md#d-1-the-degraded-mode-is-named-and-it-is-not-a-fourth-letter-in-the-existing-series)).
Those letters enumerate how much git context a run has, and agent availability is a second, independent axis.
A Mode A run with a full branch diff can be manual-only.

`agent-dispatch.md` owns the mode. It is already loaded at the dispatch step, already the authoritative home for one
cross-file rule, and already carries the roster the absent-coverage list is derived from. It owns four things: the
mode's name, how a run detects it, what selection produces in that mode, and which checklist categories substitute for
each absent agent. It does not restate the report's block format or the verification item.

Detection is by the **dispatch mechanism failing**, not by the results being empty, and not by a probe
([D-3](artifacts/change-decision-log.md#d-3-the-mode-is-detected-by-the-dispatch-mechanism-failing-never-by-an-empty-result)).
The two triggers are a dispatch tool that is unavailable and a dispatch call that is denied. **An agent that returns
with nothing to say is not a trigger.** The always-dispatched security agent is specified to stay silent when
its evidence standard is not met. Reading silence as failure would print a disclosure saying security coverage was
absent on a run where it ran and passed. A false disclosure is worse than the silent one this change is fixing.

The line the run emits:

```
Manual-only mode: agent dispatch unavailable ({verbatim tool error, or "Agent tool not in allowed-tools"}).
Manual review is the primary path. Coverage absent: junior-developer, security, and every conditional agent
Step 3.2 selected. See the sweep mapping for what substitutes.
```

The sweep is a stated mapping, one line per agent, so two runs do the same thing
([D-4](artifacts/change-decision-log.md#d-4-the-by-hand-sweep-is-a-stated-mapping-from-each-absent-agent-to-checklist-categories)).
The mapping is written out for every agent on the roster, because writing it out is what reveals how much the sweep
recovers:

```
- `han-core:junior-developer` → Code Maintainability, Documentation, Code Style & Patterns, Architecture Decision Records — at the {size} band from Step 3.1.
- `han-core:adversarial-security-analyst` → Data Isolation, Error Handling, API Design — at the {size} band. Partial: nothing substitutes for an exploit path demonstrated against the code.
- `han-core:test-engineer` → Testing, Correctness — at the {size} band.
- `han-core:edge-case-explorer` → Correctness, Error Handling — at the {size} band. Partial: the checklist asks whether edge cases are handled, not which ones exist.
- `han-core:structural-analyst` → Code Organization, Code Maintainability — at the {size} band.
- `han-core:behavioral-analyst` → Error Handling, Correctness — at the {size} band.
- `han-core:data-engineer` → Database, Performance, Data Isolation — at the {size} band.
- `han-core:on-call-engineer` → Error Handling, Performance — at the {size} band. Partial: no category covers timeouts, retry backoff, or idempotency.
- `han-core:concurrency-analyst` → nothing substitutes. No checklist category covers races, lock ordering, or shared mutable state.
- `han-core:devops-engineer` → nothing substitutes. No checklist category covers rollout, observability, or infrastructure.
- An agent from a project config's `## Extra Agents` list → nothing substitutes. Name the agent and say its coverage was not swept.
```

**Writing the mapping out changes what the sweep is worth, and the plan says so rather than implying more.** Four of
the roster's agents have no counterpart or a partial one. A manual-only run recovers most of what the structural,
behavioral, data, and testing agents cover, and recovers nothing of what the concurrency and devops agents cover. Those
last two produce coverage rows reading `not swept`, which is the honest result and the reason the disclosure matters
more than the sweep does.

The report carries a `## Review Coverage` section immediately after the Review Summary block closes, rendered **only
when some planned coverage was absent**
([D-2](artifacts/change-decision-log.md#d-2-the-coverage-disclosure-renders-only-when-coverage-was-absent-and-it-reaches-the-closing-message-too)).
Its absence means every planned coverage ran.
The heading is `##`, a peer of Recommended Changes rather than a child of Review Summary, and it joins the template's
fixed section order by name at that position. `template.md` owns the block, its heading level, its position, its
opening line, and its row grammar.

**The block stands alone for a reader who never saw the terminal.** The report's reader and the operator are different
people: a reviewer on a pull request never sees the closing message, and the operator may never open the file. So the
block opens by naming its own cause rather than relying on the message to have explained it.

```markdown
## Review Coverage

Agent dispatch was unavailable on this run, so no specialist read this change (manual-only mode).

- **Absent:** {coverage name} — {reason}; {swept by hand under {categories} | not swept — {what to do instead}}.
```

Worked, and this example, the detection line above, and the closing message below all describe the same run:

```markdown
## Review Coverage

Agent dispatch was unavailable on this run, so no specialist read this change (manual-only mode).

- **Absent:** security review — swept by hand under Data Isolation, Error Handling, API Design. Nothing substitutes for an exploit path demonstrated against the code.
- **Absent:** concurrency review — not swept; no checklist category covers races or lock ordering. Check shared state and async ordering by hand before merging.
- **Absent:** independent validation of the findings — not swept; the findings below were not re-checked against the code by a second pass. Weigh each on its own evidence.
```

Two things the grammar does deliberately. The plain-English coverage name comes first and the agent identifier is
dropped, because a reviewer on a pull request has no roster and no plugin. And the `not swept` branch carries a clause
saying what to do instead, because a line with no verb aimed at the reader gets read as bookkeeping about the run.

The population is settled once: **every agent Step 3.2 selected, plus the independent validation pass**, which is
planned coverage that a manual-only run cannot reach because it dispatches an agent. Selection is a fact by the time
detection fires, not a counterfactual, since the dispatch attempt is what detects.

The closing message carries one clause in its run's-own-facts part, which is already where the run's conduct is
reported. It names the cause and the consequence rather than a mode name and a count, because "manual-only mode" reads
as a setting somebody chose and the operator chose nothing:

```
Medium: 6 files touched, adds one index. Agent dispatch was unavailable, so no specialist read this change; 8 of 11
coverage areas were swept by hand and 3 were not. See Review Coverage in the report.
```

`output-verification.md` owns the check: when the run was manual-only, the block is present and carries one row per
agent selection produced or would have produced. When coverage was complete, the block is absent.

### `code-review`: a packaging category that names the gap

A new `Packaging (when applicable)` category in `review-checklist.md` fires on a diff that changes what gets packaged.
Its triggers are shading or relocation rules, vendoring, include and exclude patterns, dependency scope changes, and
bundling configuration. **It does not open the built artifact.** The run acquires no new command permission
([D-5](artifacts/change-decision-log.md#d-5-the-packaging-category-names-the-gap-rather-than-inspecting-the-artifact)).

The finding it raises, pinned by worked example so two runs write the same thing:

```markdown
**WARN-002** `build.gradle:41` Someone installs the published jar and calls `WidgetFactory.create`, and it fails at
startup with a missing-class error, because the exclude rule added here drops a class that surviving classes still
reference. This review did not open the built artifact and cannot tell you whether that happened: the exclude
patterns say what was removed, not what still points at it. A green build is not evidence either, because a
development run has a wider classpath than the shipped artifact. Check the produced artifact before merging: that
every internal reference resolves inside it, that no third-party package is exported unrelocated, and that the
licence notices the packaging requires are present. **Fix:** by hand.
```

**The first sentence is derived from the diff; the rest is fixed.** The category says so, because a builder who
pastes the worked example with the path swapped produces five identical sentences on every packaging review. A
reader stops reading them by the third. The first sentence names the specific rule or pattern the diff added and the
specific symptom it could produce. Sentences two onward are invariant.

**The summary-table row opens with `Not checked —`**, matching the existing `May never fire —` cue the template already
uses to mark a finding class a triaging reader should weigh differently. Without it, a row that says the review did not
look sits at the same visual weight as a proven defect. A reader triaging thirty findings cannot tell them apart
until they open one.

The category states its own mode scope, inside the category rather than only in its caller, which is the defect
[C-18](artifacts/current-state-findings.md#c-18-the-yagni-checklists-mode-exception-lives-only-in-its-caller-not-in-the-file-named-canonical)
records against the neighbouring YAGNI section:

```
**Mode scope.** This category applies in Mode A only. Step 4's Mode B and Mode C conservative rule admits only
focus-area items, source-file items, and file-boundary items, and without a base-branch diff the run cannot tell
what the change altered about packaging. Same reason the YAGNI checklist is suspended in those modes.
```

### `code-review`: a location is confirmed, not carried forward

The rule fires on a specific, current path rather than on a population the skill does not reach
([D-6](artifacts/change-decision-log.md#d-6-the-location-rule-fires-on-the-region-read-path-which-is-the-one-that-survives-d-5)).
Step 4 reads a file over a thousand lines by its changed regions and their surrounding context rather than whole. **A
location established from a region read is exactly the failure the work item describes.** You see a hit, and you look
upward for the nearest declaration. The declaration you find may not be the one that encloses it.

`finding-content.md` gains the rule. It owns what every finding carries and is loaded at the drafting step, which is
the moment the work item names: re-read the cited unit in isolation before writing the finding.

```
A location established by reading a region of a file rather than the unit that contains it is a guess until the unit
is read. Read the enclosing unit in isolation before writing the finding, and never carry forward the nearest
declaration a region read happened to include. Where a finding's severity depends on which unit the location names,
confirm the unit twice.
```

The location form is the existing one plus the enclosing unit and how it was confirmed:

```
**CRIT-003** `src/billing/reconciler.rb:2841` (enclosing member: `Reconciler.retry_batch`, confirmed by reading
lines 2790-2860 in isolation) {explanation} … **Fix:** by hand.
```

**The population is region reads, and it does not reach every cited location.** A finding from a file the run read
whole carries no such note. That keeps the rule off the twenty-nine other findings a capped review can hold, which is
the cost that made the general version a deferral.

Two guards, because each is absent when the other runs
([D-7](artifacts/change-decision-log.md#d-7-the-attribution-rule-is-guarded-in-two-places-because-each-is-absent-when-the-other-runs)).
A fifth challenge axis joins the lettered list in the validation pass's brief:

```
(e) findings whose cited location came from a region read and names an enclosing unit that was never read in
isolation, and any finding whose severity depends on which unit the location names.
```

And a structural verification item runs in every mode where the validation pass does not. It asserts that such a
finding names its enclosing unit and the lines read to confirm it.

### `research`: one home for the invariant, and a mapping across the merge

The traceability invariant is two-part and defined in Operating Principles alone
([D-8](artifacts/change-decision-log.md#d-8-the-traceability-invariant-is-two-part-and-it-is-defined-in-one-place)):

```
The traceability invariant is two-part. Resolvability: every `A#` cited inline resolves to a registry entry carrying
its link, retrieval date, trust class, and evidence status. Support: the cited entry's `Summary (one line)` states
something that bears on the claim the citation is attached to. Resolvability is necessary and not sufficient.
```

The merge step, which already renumbers and already filters by relevance, gains ownership of the record of what those
two jobs did ([D-9](artifacts/change-decision-log.md#d-9-the-merge-records-an-old-to-new-mapping-and-the-rewrite-covers-the-evidence-status-field)).
The mapping is a working record the run holds while it renders, not a report section. Nothing in the report reads it,
and persisting it is a deferral with its own trigger.

```markdown
| Analyst angle       | Local ID | Source                          | Merged ID | Disposition                        |
| ------------------- | -------- | ------------------------------- | --------- | ---------------------------------- |
| messaging-patterns  | A1       | Kafka docs, exactly-once        | A1        | renumbered                         |
| messaging-patterns  | A2       | Fowler, "What do you mean by X" | A2        | renumbered                         |
| delivery-semantics  | A1       | Fowler, "What do you mean by X" | A2        | merged into A2 (same source as messaging-patterns A2) |
| delivery-semantics  | A2       | vendor blog, undated            | —         | dropped (not relevant to the results) |
```

The `Source` column is what makes the mapping checkable. Without it, nobody can join a row back to the analyst output
it came from, and the plan's own mitigation for a wrongly-built mapping has nothing to check against.

The rewrite through that mapping covers every `A#` in Research Results, in each option's `Rests on`, and in the
recommendation's `Evidence basis`. **It also covers every `Evidence status` field** — both in the registry table's last
column and in each detail block. That last surface is the one nobody names today, and a rewrite covering only prose
leaves it stale.

A claim whose only source the merge dropped carries the canonical no-evidence label with a reopen trigger, or is
dropped with its source. It is not relabelled single-source, because the evidence rule this skill already loads forbids
that collapse in as many words
([D-10](artifacts/change-decision-log.md#d-10-a-claim-whose-only-source-the-merge-dropped-is-labeled-no-evidence-not-single-source)).

**Two column enumerations are reconciled in the same unit.** The merge step and the final step each list the registry
table's columns inline, and neither list includes the one-line summary the support check reads. A run following the
skill rather than the template would render a registry the check cannot read. Both lists gain the column.

The validation pass receives the mapping alongside the registry it already gets. The final check becomes two-part
rather than gaining a pass beside it, and the report template's sources comment cites the invariant instead of defining
it.

### What deliberately does not change

No new reference file, in either skill, for any of the four defects. Three of the four land in lists that are already
extensible, and each new file would spend body lines a file five under its ceiling does not have. No shared rule
generalizing the three citation defects. The shape they share is a moral rather than a procedure, and the only
candidate second consumer inside `code-review` is ruled out by
[C-21](artifacts/current-state-findings.md#c-21-code-reviews-own-fan-out-is-structurally-immune-to-the-same-defect)
([D-11](artifacts/change-decision-log.md#d-11-no-new-reference-file-and-no-shared-rule-generalizing-the-three-citation-defects)).
The `research-analyst` agent is unchanged: it keeps numbering its own sources from `A1`, because the whole fix sits on
the orchestrator's side of the merge ([D-15](artifacts/change-decision-log.md#trivial-decisions)). No plugin version is
bumped and no changelog entry is written ([D-14](artifacts/change-decision-log.md#trivial-decisions)).

## Surface Delta

### S-1: `agent-dispatch.md` § manual-only mode — Added

**Target state.** `agent-dispatch.md` carries a section defining manual-only mode: its name, the detection line a run
emits when the dispatch attempt produces no agent results, what selection produces in that mode, and a mapping from
each roster agent to the checklist categories that substitute for it at the run's size band. It is the authoritative
home for the mode; every other site names it rather than describing it.

**Behavior.** Changing. A manual-only run raises findings it did not raise before, in the mapped categories. The
observer is the author of the change under review. Settled by the recorded boundary, which asks for the by-hand sweep
at the same size band in as many words.

**Why.** [C-1](artifacts/current-state-findings.md#c-1-the-only-handling-of-no-agents-ran-is-a-step-skip-guard-not-a-mode)
records the only handling today as a step-skip sentence naming no mode;
[C-5](artifacts/current-state-findings.md#c-5-the-manual-review-is-never-scoped-to-substitute-for-the-specialist-categories)
records the manual review running at its normal depth either way.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-the-degraded-mode-is-named-and-it-is-not-a-fourth-letter-in-the-existing-series),
[D-3](artifacts/change-decision-log.md#d-3-the-mode-is-detected-by-the-dispatch-mechanism-failing-never-by-an-empty-result),
[D-4](artifacts/change-decision-log.md#d-4-the-by-hand-sweep-is-a-stated-mapping-from-each-absent-agent-to-checklist-categories)

### S-2: `code-review/SKILL.md` Step 3's pointer to `agent-dispatch.md` — Re-scoped

**Target state.** The pointer names the manual-only mode among what the reference file specifies. It states no
detection rule, no mapping, and no disclosure.

**Behavior.** Preserving. The run loads the same file at the same point.

**Why.** [C-15](artifacts/current-state-findings.md#c-15-code-reviewskillmd-sits-five-lines-under-a-ceiling-the-guidance-sets-and-two-commits-have-already-enforced):
the body gains at most a pointer.

**Depends on.** S-1.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-the-degraded-mode-is-named-and-it-is-not-a-fourth-letter-in-the-existing-series)

### S-3: `code-review/SKILL.md` Step 7's skip sentence — Re-scoped

**Target state.** The sentence owns which sub-steps skip and under what condition, and nothing else. It names
manual-only mode, defined in `agent-dispatch.md`. Its clause about the independent validation pass says that pass skips
too in manual-only mode, because that pass dispatches an agent and dispatch is what is unavailable. Outside manual-only
mode the clause is unchanged: the pass still runs whenever the review produced at least one corrective finding.

**Behavior.** **Changing.** Two things differ. The condition changes from "no agents were dispatched" to "the dispatch
mechanism failed." The independent validation pass now skips in that mode, where the sentence today says it still
runs. The observer is the report's reader, who gets findings that were not re-checked against the code by a second
pass, and who is told so by the coverage row S-4 renders.

**Why.** [C-1](artifacts/current-state-findings.md#c-1-the-only-handling-of-no-agents-ran-is-a-step-skip-guard-not-a-mode)
records that sentence carrying an entire execution mode as a guard clause. The validation clause has to change because
[C-9](artifacts/current-state-findings.md#c-9-the-one-pass-in-code-review-that-re-reads-the-code-has-four-named-challenge-axes-and-location-is-not-one)
records that the pass dispatches an agent. Leaving "still runs" in place would instruct a run to do the thing it
discovered it cannot do.

**Depends on.** S-1.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-the-degraded-mode-is-named-and-it-is-not-a-fourth-letter-in-the-existing-series),
[D-3](artifacts/change-decision-log.md#d-3-the-mode-is-detected-by-the-dispatch-mechanism-failing-never-by-an-empty-result)

### S-4: `template.md` § Review Coverage — Added

**Target state.** The report template defines a `## Review Coverage` section at heading level two, a peer of Recommended
Changes rather than a child of Review Summary. It renders immediately after the Review Summary block closes, and only
when some planned coverage was absent. Its absence means every planned coverage ran, and the template says so where the
block is defined. It opens with a line naming its own cause, so it stands alone for a reader who never saw the terminal.
It then carries one row per absent item in the pinned grammar. The rows name coverage in plain English and carry no agent
identifier or internal step number.

**Behavior.** Changing. A degraded run's report gains a section it did not carry. The observer is the report's reader,
who is a different person from the operator: a reviewer on a pull request sees this file and never sees the closing
message. Settled by the recorded boundary, which asks for a matching line in the report template so the disclosure has a
fixed home.

**Why.** [C-2](artifacts/current-state-findings.md#c-2-no-downstream-surface-renders-a-coverage-disclosure): no surface
exists today, and a zero-agent report is structurally indistinguishable from a full-roster one.

**Depends on.** S-1, which supplies the absent-coverage list the rows render.

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-the-coverage-disclosure-renders-only-when-coverage-was-absent-and-it-reaches-the-closing-message-too)

### S-5: `template.md` § the fixed section order — Re-scoped

**Target state.** The template's fixed-order list names Review Coverage in its position, between the Review Summary
block and Critical. The list is the authority on where a present section goes, and a section absent from it has no
defined position.

**Behavior.** Preserving. The list is an instruction to the run about ordering; naming a section in it changes no
output beyond what S-4 already produces.

**Why.** The order list today names Critical, Warnings, Suggestions, YAGNI, Security Vulnerabilities, Remediation, and
What's Good, and a section not on it has nowhere defined to sit. The structural verification item that checks fixed
order reads this list, so a block missing from it cannot be checked for position.

**Depends on.** S-4.

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-the-coverage-disclosure-renders-only-when-coverage-was-absent-and-it-reaches-the-closing-message-too)

### S-6: `output-verification.md` § Step 9.1, coverage-block item — Added

**Target state.** A structural verification item asserting that a manual-only run's report carries the Review Coverage
block with one row per agent selection produced or would have produced, and that a full-coverage run's report does not
carry it.

**Behavior.** Preserving. Its only effect is to enforce S-4, so the observable difference belongs to that entry.

**Why.** [C-2](artifacts/current-state-findings.md#c-2-no-downstream-surface-renders-a-coverage-disclosure): the
verification list has no item requiring a coverage statement, so a missing block would go uncaught.

**Depends on.** S-4.

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-the-coverage-disclosure-renders-only-when-coverage-was-absent-and-it-reaches-the-closing-message-too)

### S-7: `code-review/SKILL.md` Step 10's run's-own-facts part — Re-scoped

**Target state.** That part of the closing message carries the size band and the validator reconciliation line, plus one
clause naming the cause and the consequence. That clause states that agent dispatch was unavailable, so no specialist
read the change; it states how many coverage areas were swept by hand and how many were not; and it points to the
report's Review Coverage section. It names a consequence rather than a mode name, and it does not list the absent
areas; the report's block does.

**Behavior.** Changing. The closing message gains a clause on degraded runs. The observer is the operator in the turn.
The work item names the report rather than the message. The message clause is a necessity of the disclosure it asks
for, because the run never pastes the report into the conversation.

**Why.** [C-3](artifacts/current-state-findings.md#c-3-the-closing-message-has-four-fixed-parts-and-coverage-is-not-one-of-them):
part 4 is already where the run's own conduct is reported.

**Depends on.** S-4.

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-the-coverage-disclosure-renders-only-when-coverage-was-absent-and-it-reaches-the-closing-message-too)

### S-8: `review-checklist.md` § Packaging (when applicable) — Added

**Target state.** The checklist carries a `Packaging (when applicable)` category, listed in the file's contents and
headed with the same suffix. It names the diff triggers, what the finding it raises must state, its default severity,
and its own mode scope. It directs no artifact inspection and requires no command the skill is not already permitted.

**Behavior.** Changing. A Mode A review of a diff that alters packaging raises a finding it did not raise before. The
observer is the author of the change. Settled by the operator's answer, which departs from the work item; the work item
asks for the artifact to be inspected and this does not inspect it.

**Why.** [C-6](artifacts/current-state-findings.md#c-6-the-checklist-governs-source-text-only-and-the-procedure-actively-steers-away-from-built-output)
records that no category reaches built output and the review step actively skips it;
[C-7](artifacts/current-state-findings.md#c-7-the-checklists-shape-a-new-category-has-to-match) records the shape this
matches.

**Decision.** [D-5](artifacts/change-decision-log.md#d-5-the-packaging-category-names-the-gap-rather-than-inspecting-the-artifact),
[D-12](artifacts/change-decision-log.md#d-12-escalation-register-the-one-question-this-run-took-to-the-operator)

### S-9: `finding-content.md` § enclosing-unit attribution — Added

**Target state.** `finding-content.md` carries the rule that a finding's location, when it was established by reading a
region of a file rather than the unit that contains it, is confirmed by reading that unit in isolation before the
finding is written. The rule never lets that location be carried forward from the nearest declaration the region
happened to include. It carries the location form: the existing reference plus the enclosing unit and the lines read to confirm it. Its population is
region reads, which is the path Step 4 takes on a file over a thousand lines. A finding from a file read whole carries
no such note.

**Behavior.** Changing. Such a finding carries a form it did not carry, and confirming the unit can change which unit
the finding names, which can change its severity. The observer is the report's reader.

**Why.** [C-8](artifacts/current-state-findings.md#c-8-no-rule-resolves-the-enclosing-member-of-a-cited-location-and-the-check-that-looks-like-one-tests-the-file):
the skill's only instruction about a location is to include one. The population is Step 4's own instruction to read a
file over a thousand lines by its changed regions and their surrounding context. That is the same failure the work
item describes at a different altitude: a hit found in a region, attributed upward to the nearest declaration the
region included.

**Depends on.** S-8, which settles that no archive path can produce such a location and therefore what altitude the
rule is written at.

**Decision.** [D-6](artifacts/change-decision-log.md#d-6-the-location-rule-fires-on-the-region-read-path-which-is-the-one-that-survives-d-5)

### S-10: `output-verification.md` § Step 9.1, attribution item — Added

**Target state.** A structural verification item asserting that a finding whose location came from a region read names
its enclosing unit and the lines read to confirm it. It runs in every mode. The file gains a contents list in the same
unit, because it sits exactly at the length past which the authoring guidance requires one and this change pushes it
over.

**Behavior.** Preserving. Its only effect is to enforce S-9.

**Why.** [C-9](artifacts/current-state-findings.md#c-9-the-one-pass-in-code-review-that-re-reads-the-code-has-four-named-challenge-axes-and-location-is-not-one):
the validation pass does not run when a review produced no corrective findings, and after S-1 it cannot run at all in
manual-only mode. A guard that lives only there is absent in the run that needs it most.

**Depends on.** S-9.

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-the-attribution-rule-is-guarded-in-two-places-because-each-is-absent-when-the-other-runs)

### S-11: `finding-filters.md` § Step 7.4 brief, axis (e) — Added

**Target state.** The validation pass's verbatim brief carries a fifth lettered challenge axis, naming findings whose
location came from a region read and names an enclosing unit never read in isolation, and any finding whose severity
depends on which unit the location names.

**Behavior.** Changing. A finding may be demoted or dropped that previously stood. The observer is the report's reader.
Settled by the recorded boundary, which asks that a severity depending on the location be confirmed twice.

**Why.** [C-9](artifacts/current-state-findings.md#c-9-the-one-pass-in-code-review-that-re-reads-the-code-has-four-named-challenge-axes-and-location-is-not-one):
this is the only pass that judges a finding by re-reading the code, and its axes are an extensible lettered list. Its
demand for counter-evidence at a path and line presumes the location is already right.

**Depends on.** S-9, which defines the form the axis challenges.

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-the-attribution-rule-is-guarded-in-two-places-because-each-is-absent-when-the-other-runs)

### S-12: `research/SKILL.md` Operating Principles § traceability invariant — Re-scoped

**Target state.** Operating Principles is the only place the invariant is defined, and it defines it as two-part:
resolvability, and support by the cited entry's one-line summary, with resolvability necessary and not sufficient.

**Behavior.** Changing. A run must now check support, so a citation may be rewritten that previously stood. The
observer is the report's reader. Settled by the recorded boundary, which asks the skill to state that syntactic
resolvability is necessary but not sufficient.

**Why.** [C-10](artifacts/current-state-findings.md#c-10-researchs-traceability-invariant-is-resolvability-stated-identically-in-four-places):
four co-equal statements, each describing existence of a target.
[C-12](artifacts/current-state-findings.md#c-12-the-sources-table-already-carries-the-one-line-summary-a-semantic-check-would-read)
is why the support half needs no new field: the registry table already carries the summary the check reads.

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-the-traceability-invariant-is-two-part-and-it-is-defined-in-one-place)

### S-13: `research/SKILL.md` Step 6 — Re-scoped

**Target state.** The merge step owns the old-to-new mapping in its pinned field layout, the rewrite of every citation
surface through it, and the handling of a dropped source. It cites the invariant by name and does not restate it.

**Behavior.** Changing. A citation may be rewritten to a different identifier than an analyst wrote, and a claim whose
only source was dropped loses its citation and carries the no-evidence label. The observer is the report's reader.
Settled by the recorded boundary for the mapping and the rewrite, and by the canonical evidence rule for the dropped
case.

**Why.** [C-11](artifacts/current-state-findings.md#c-11-every-parallel-analyst-mints-a1-independently-and-the-merge-renumbers-with-no-mapping),
[C-19](artifacts/current-state-findings.md#c-19-a-second-citation-surface-sits-inside-the-registry-being-renumbered),
[C-20](artifacts/current-state-findings.md#c-20-two-of-the-three-merge-collision-cases-have-no-stated-handling).

**Depends on.** S-12.

**Decision.** [D-9](artifacts/change-decision-log.md#d-9-the-merge-records-an-old-to-new-mapping-and-the-rewrite-covers-the-evidence-status-field),
[D-10](artifacts/change-decision-log.md#d-10-a-claim-whose-only-source-the-merge-dropped-is-labeled-no-evidence-not-single-source)

### S-14: `research/SKILL.md` Step 7's validator brief — Re-scoped

**Target state.** The validation dispatch passes the mapping alongside the registry, the results, the options, and the
recommendation it already passes, and its charter names citation support as something to attack.

**Behavior.** Changing. The validator may raise a finding it would not have raised. The observer is the report's
reader.

**Why.** The issue records the validator as the only thing that caught the defect. It caught the defect by reading
entry contents for other reasons, rather than because its charter named this
([C-12](artifacts/current-state-findings.md#c-12-the-sources-table-already-carries-the-one-line-summary-a-semantic-check-would-read)
covers the input it reads).

**Depends on.** S-13.

**Decision.** [D-9](artifacts/change-decision-log.md#d-9-the-merge-records-an-old-to-new-mapping-and-the-rewrite-covers-the-evidence-status-field)

### S-15: `research/SKILL.md` Step 8's resolution check — Re-scoped

**Target state.** The final check is two-part: every cited identifier resolves, and the entry it resolves to states
something bearing on the claim it is attached to. It cites the invariant by name and does not restate it.

**Behavior.** **Changing.** This is where the support judgment first executes over a finished report. It catches a
citation pointing at the wrong entry for reasons having nothing to do with a merge. An analyst that cited the wrong
source in a run with no collision at all previously passed here and now does not. The observer is the report's reader.
Settled by the recorded boundary, which asks for a pass confirming the cited entry's one-line summary supports
the claim it is attached to.

**Why.** [C-10](artifacts/current-state-findings.md#c-10-researchs-traceability-invariant-is-resolvability-stated-identically-in-four-places):
this is the site that checks the invariant, and it checks existence today. S-12 states the invariant as drafting
guidance and S-13 corrects identifiers across the merge; neither performs the check, so classifying this entry as their
enforcement understated what it does.

**Depends on.** S-12.

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-the-traceability-invariant-is-two-part-and-it-is-defined-in-one-place)

### S-16: `research-report-template.md` § Sources comment — Re-scoped

**Target state.** The comment tells a reader that every cited identifier resolves to an entry below, and cites the
invariant by name rather than defining it.

**Behavior.** Preserving. The rendered report is unchanged.

**Why.** [C-10](artifacts/current-state-findings.md#c-10-researchs-traceability-invariant-is-resolvability-stated-identically-in-four-places):
the fourth of the four statements.

**Depends on.** S-12.

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-the-traceability-invariant-is-two-part-and-it-is-defined-in-one-place)

### S-17: `code-review/SKILL.md` Step 8's restatement of the template's render rules — Re-scoped

**Target state.** Step 8 points at `template.md` for the lazy-section and fixed-order rules rather than restating them,
under the same authoritative-home convention the skill applies to size-based demotion. Conditional: this entry lands
only if the line count measured at build time leaves less headroom than this change's pointers need.

**Behavior.** Preserving. No output changes; the file is already read at that step.

**Why.** [C-15](artifacts/current-state-findings.md#c-15-code-reviewskillmd-sits-five-lines-under-a-ceiling-the-guidance-sets-and-two-commits-have-already-enforced)
and [C-16](artifacts/current-state-findings.md#c-16-the-repositorys-authoritative-home-convention-exists-and-neither-new-rule-has-one).

**Decision.** [D-16](artifacts/change-decision-log.md#d-16-the-headroom-unit-runs-only-if-the-measured-line-count-at-build-time-requires-it)

### S-18: `han-coding/docs/skills/code-review.md` — Re-scoped

**Target state.** The long-form doc describes manual-only mode alongside the git modes and says the two are
independent axes rather than one enumeration. Its account of the report names the Review Coverage section and what its
absence means. Its account of the closing message carries the manual-only clause. And its key concepts name the
Packaging category and the location-attribution rule. It states the modes without a running total, so a later mode
cannot make a count wrong.

**Behavior.** Preserving. The doc carries no behavior of its own; it stops stating what S-1 through S-11 made wrong.

**Why.** The repository's convention makes the long-form doc canonical for its skill, and the doc currently states
"Three review modes" as a key concept and describes a report with no coverage section.

**Depends on.** S-1 through S-11.

**Decision.** [D-13](artifacts/change-decision-log.md#trivial-decisions)

### S-19: `han-research/docs/skills/research.md` — Re-scoped

**Target state.** The doc states the traceability invariant in its two-part form, matching Operating Principles, and
says what the merge records.

**Behavior.** Preserving, on the same grounds as S-18.

**Why.** The doc currently states the invariant as resolvability alone, which S-12 makes incomplete.

**Depends on.** S-12, S-13.

**Decision.** [D-13](artifacts/change-decision-log.md#trivial-decisions)

### S-20: `research/SKILL.md` the registry's column enumerations — Re-scoped

**Target state.** Both places that list the registry table's columns inline name the one-line summary column, matching
the template. A run that follows the skill rather than the template renders a registry the support check can read.

**Behavior.** Preserving on the rendered report, which already carries the column via the template. It removes a state
where a run following the skill alone would render a table the check cannot read.

**Why.** [C-12](artifacts/current-state-findings.md#c-12-the-sources-table-already-carries-the-one-line-summary-a-semantic-check-would-read)
is the evidence that the support check needs no new field, and it rests on the template. Both of the skill's own
enumerations omit that column, so the evidence held for one of three surfaces.

**Depends on.** S-12.

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-the-traceability-invariant-is-two-part-and-it-is-defined-in-one-place)

### S-21: `post-code-review-to-pr` § the PR body's sections — Re-scoped

**Target state.** The skill that posts a review to a pull request names Review Coverage among the optional sections it
carries across. It exempts Review Coverage from the clarity pass's length-matching instruction, alongside the Review
Summary table and the Review Recommendation. A coverage disclosure survives to the pull request.

**Behavior.** Changing. A pull request body from a degraded run carries the coverage section. The observer is every
reviewer on that pull request, which is the widest audience any of these surfaces has and the only one that sees
neither the terminal nor the report file.

**Why.** That skill builds the public body from the report file and lists the optional sections it expects, a list
Review Coverage would not be on. Its clarity pass then instructs a run that every finding earns its place by naming a
specific problem at a specific location, and to skip filler sections. A section that names no problem at any location
is the most deletable block in the body by that bar. The pass is carried out by a dispatched agent applying the bar
as written. Without this entry, the fix for the first defect is deleted on the surface with the widest audience,
reproducing the original failure one level out.

**Depends on.** S-4.

**Decision.** [D-18](artifacts/change-decision-log.md#d-18-the-disclosure-has-to-survive-to-the-pull-request-so-the-skill-that-posts-it-is-in-scope)

## Behavior Changes

Eleven entries change something a person can observe. Nothing here is pinned by a test. The repository's Bats suite
covers the shell scripts beside it, nothing executes or asserts on a skill's procedure, and no part of this change is
scriptable enough to test that way. Each of these is caught by a reader or not at all.

**Two of them do less than feedback issue #194 asked for, and both departures are your decision.**

- **S-8, the packaging finding.** The issue asks the run to open the built artifact and check it. It does not open it.
  A reviewer whose diff changes packaging is told the review has that hole and what to check by hand. The defect the
  issue reported, an exclude rule dropping a class that surviving classes still called, is not caught. You chose this
  after being told it does not close the defect
  ([D-12](artifacts/change-decision-log.md#d-12-escalation-register-the-one-question-this-run-took-to-the-operator)).
- **S-9, the location rule.** The issue's example is a hit inside a class's static initializer attributed to the method
  printed before it in disassembler output. Because S-8 means a run never disassembles anything, that case cannot
  arise. The rule fires instead on the path that does exist. Step 4 reads a file over a thousand lines by its changed
  regions, and a location found in a region can be attributed upward to the wrong declaration. Same failure, reachable
  altitude. The review round caught an earlier version of this entry aiming at a population the skill does not read at
  all, and this is the corrected form.

The other nine do what the issue asks, and the recorded boundary is the decision on each.

- **S-1.** A review that cannot reach its specialists raises findings by hand that it previously left to them. Someone
  reviewing a change in a restricted environment sees more findings, in the mapped categories. Observer: the author of
  the change. **The mapping written out in full shows this recovers less than it sounds like**: four roster agents have
  no counterpart or a partial one, and concurrency and infrastructure coverage is recovered not at all.
- **S-3.** In that same run, the pass that re-checks findings against the code no longer runs, because it dispatches an
  agent. Findings reach the report without a second opinion, and the coverage block says so. Observer: the report's
  reader.
- **S-4.** A report from such a run carries a section naming what was not covered and why; a report from a healthy run
  carries no such section. Observer: the report's reader, who on a pull request is not the person who ran it.
- **S-7.** The message the run closes with says dispatch was unavailable, that no specialist read the change, and how
  many coverage areas were swept by hand. Observer: the operator in the turn.
- **S-11.** A finding whose enclosing unit was guessed rather than read can be demoted a severity or dropped, so a
  report can carry fewer findings than it would have. Observer: the report's reader.
- **S-12.** A research report's citations are now checked against what the cited source says, so a citation pointing at
  an unrelated entry gets corrected before the report is presented. Observer: the report's reader.
- **S-13.** A claim whose source the merge dropped loses its citation and is labelled as having no evidence, rather
  than keeping a citation to something else. In a strict-mode run that can mean a recommendation no longer rests on
  what it appeared to rest on. Observer: the report's reader.
- **S-14.** The pass that attacks the report's evidence can raise a finding about a citation that does not support its
  claim. Observer: the report's reader.
- **S-15.** The final check catches a citation that points at the wrong entry even when no merge collision occurred, so
  a run that never fanned out is covered too. Observer: the report's reader.
- **S-21.** A pull request body from a degraded run carries the coverage disclosure. Observer: every reviewer on that
  pull request. This is the widest audience of the three surfaces and the only one that sees neither the terminal nor
  the report file.

## Change Units

Each unit leaves every skill file internally consistent: no pointer without a target, no rule with two homes, no
verification item asserting something no template produces.

### Unit 0: Free headroom in the `code-review` body

**What it does.** Collapses Step 8's restatement of the template's own render rules to a pointer, under the convention
the same skill already applies to size-based demotion.

**Delta entries.** S-17.

**Ordering constraint.** Runs before **Units 3 and 4**, and only if the measured line count leaves less headroom than
the pointers those two units add to the body. Measure first: the file has moved in twenty-eight commits in ninety days,
so the number in the findings is a reading, not a constant.

**How you know it worked.** Two measurements, not one. Before Unit 3, the body has room for the pointers Units 3 and 4
add. **After Unit 4 lands, measure again.** That second reading is the only conclusive test of whether this unit did
its job, because the content it made room for does not exist until then. And the render rules read the same way to
someone following Step 8 with `template.md` open.

### Unit 1: `research`, one home for the invariant

**What it does.** Rewrites the invariant in Operating Principles as two-part. Converts the merge step, the final check,
and the report template's comment from definitions to citations. Adds the one-line summary column to both of the
skill's inline column enumerations.

**Delta entries.** S-12, S-15, S-16, S-20.

**Ordering constraint.** Before Unit 2, or the strengthened check contradicts three surviving statements of the weaker
form.

**How you know it worked.** Searching the skill and its template for the invariant finds one definition and three
citations of it, and both column enumerations name every column the template's table renders.

### Unit 2: `research`, the mapping and the rewrite

**What it does.** Gives the merge step the mapping, the rewrite across every citation surface including the
evidence-status field, and the dropped-source handling. Passes the mapping to the validation dispatch.

**Delta entries.** S-13, S-14.

**Ordering constraint.** After Unit 1.

**How you know it worked.** Run any genuinely two-domain question at the medium band, which is enough to dispatch
parallel analysts that each restart their own numbering. Then check the rendered report against what the analysts
returned. Every identifier inside an evidence-status field points at the source that analyst cited, and a
claim whose source was dropped carries no citation rather than a rewritten one. The mapping itself is a working record
the run holds, not a report section, so it is checked during the run rather than read afterward.

### Unit 3: `code-review`, manual-only mode

**What it does.** Adds the mode section to `agent-dispatch.md` with its detection rule and the full sweep mapping, and
points Step 3 and Step 7 at it, including Step 7's changed clause about the validation pass.

**Delta entries.** S-1, S-2, S-3.

**Ordering constraint.** After Unit 0 if headroom is short.

**How you know it worked.** Deny the session's dispatch permission and run the skill on a real diff. The run names the
mode, sweeps the mapped categories, skips the validation pass, and reaches the report step. Then run it again normally
and confirm an agent that returns with nothing to say does not trip the mode. Nothing yet says any of this in the
report; that is Unit 4.

### Unit 4: `code-review`, the coverage disclosure

**What it does.** Adds the Review Coverage block to the template with its heading level, opening line, and row grammar.
Names it in the fixed section order. Adds the verification item and the closing-message clause.

**Delta entries.** S-4, S-5, S-6, S-7.

**Ordering constraint.** After Unit 3, which produces the absent-coverage list the rows render.

**How you know it worked.** The dispatch-denied run from Unit 3 now produces a report whose coverage block names its
own cause and carries one row per absent area. A healthy run produces a report with no such section. Read the
closing message alone, without opening the file, and check that it tells you no specialist read the change.

### Unit 5: `code-review`, the packaging category

**What it does.** Adds the `Packaging (when applicable)` category with its triggers, its finding content and which
sentence varies, its summary-row prefix, its severity default, and its mode scope.

**Delta entries.** S-8.

**Ordering constraint.** None. Independent of Units 0 through 4.

**How you know it worked.** A small fixture diff touching include or exclude patterns, reviewed twice. In Mode A it
raises one warning whose first sentence names the rule the diff added, with a row opening `Not checked —`. In Mode C
the same diff raises nothing from this category.

### Unit 6: `code-review`, location attribution and its two guards

**What it does.** Adds the attribution rule and location form to `finding-content.md`, the fifth challenge axis to the
validation brief, and the structural verification item, plus a contents list on the verification file.

**Delta entries.** S-9, S-10, S-11.

**Ordering constraint.** After Unit 5, which settles what altitude the rule is written at.

**How you know it worked.** Review a file over a thousand lines with a finding in a region far from the top. The
finding names its enclosing unit and the lines read to confirm it. **The second guard cannot be staged.** Nobody can
inject a malformed finding and force the verification pass to reject it, so that half is verified by reading the item
rather than by running it. This plan says so, rather than claiming a check nobody can run.

### Unit 7: The disclosure survives to the pull request

**What it does.** Names Review Coverage among the optional sections `post-code-review-to-pr` carries across, and
exempts it from the clarity pass's length-matching instruction.

**Delta entries.** S-21.

**Ordering constraint.** After Unit 4, which creates the section.

**How you know it worked.** Post a review from the dispatch-denied run to a pull request and read the posted body. The
coverage section is in it.

### Unit 8: The long-form docs

**What it does.** Brings both skills' canonical docs into line with what the skills now do.

**Delta entries.** S-18, S-19.

**Ordering constraint.** Last. Documenting a behavior before it lands is how the two drift.

**How you know it worked.** Neither doc states a fact this change made wrong, and the `code-review` doc names its modes
without a running total.

## Risks

**The disclosure gets deleted on its way to the pull request.** This is the risk the review round caught and Unit 7
answers. The skill that posts a review publicly is instructed to skip sections that name no problem at a location, and
a coverage disclosure names none by construction. If Unit 7 is dropped or its exemption is worded loosely, the fix for
the first defect survives on the two surfaces with the narrowest audiences. It vanishes from the one with the widest.
Detectable by posting a degraded run's review to a pull request and reading the posted body.

**The disclosure lands in a file nobody reads.** The coverage block renders into a report the run deliberately never
pastes into the conversation. If the closing-message clause in S-7 is dropped or weakened back to a mode name and a
count, a person who stops at the terminal learns nothing. That reproduces the original failure one level up.
Detectable by running the skill with dispatch denied and reading only what the terminal says.

**Conditional rendering leaves a reader wanting assurance with none.** The absence of the coverage section means full
coverage ran. A reader who wants positive confirmation of that — an auditor, or someone weighing an old approval months
later — has nothing to read, because absence is not a statement. This is a real cost, and it is a smaller one than it
first looks. A reader who never sees the section correctly assumes the review did what reviews do, and the section's
absence matches that assumption. The always-present alternative is recorded with its reopen trigger, and the trigger is
this reader appearing, not a reader drawing a wrong inference.

**Unit 5 raises a finding on every packaging diff, including ones that are fine.** The category cannot tell a dangerous
exclude rule from a harmless one, because it does not open the artifact. Its blast radius is every Mode A review of a
build-configuration change. Two mitigations are in the plan and both matter. The first sentence is derived from the
diff, so the finding does not degrade into identical boilerplate. The summary row opens with a cue marking it as
something the review did not check rather than something it proved. A third question stays open, below.

**Unit 6's rule fires on a narrower population than a loose reading suggests.** The population is region reads on files
over a thousand lines. Written loosely it reaches every finding; written tightly it reaches none. An earlier draft of
this entry aimed at a population the skill does not read at all, and the review round caught it. The worked example is
what holds the scope in place, so a builder who drops the example for brevity removes the calibration.

**Unit 2 has the widest blast radius in `research`.** Every citation in every medium or large report passes through the
mapping. A mapping built wrongly relabels citations that were correct, which is worse than the defect it fixes, because
the defect was rare and this would be systematic. The mapping's source column exists so a run can be checked against
one analyst's raw output before the rewrite is trusted.

**Nothing here is pinned by a test.** No runner in this repository can execute a skill's procedure, and no part of this
change is scriptable enough for a Bats test. Both conditions the change exists to handle are reproducible locally at
the cost of one deliberate run each, and the unit checks above say how. What does not exist is anything that would
catch a regression later.

## Deferred (YAGNI)

- **A shared rule generalizing the three citation defects**, in a vendored reference file. The shape they share is a
  moral rather than a procedure, and the only candidate second consumer inside `code-review` is ruled out by C-21.
  **Reopen when** a third skill needs identifier-mapping-after-merge.
- **A new reference file per defect** — `degraded-modes.md`, `built-output-review.md`, `citation-integrity.md`. Each
  would cost a body link against a five-line budget, and each rule has a home in a file that already exists. **Reopen
  when** a second skill consumes the same rule.
- **`Mode D` as a fourth letter in the existing series.** **Reopen when** git context and agent availability become
  mutually exclusive.
- **An always-present Review Coverage section on full-coverage runs.** **Reopen when** a run is observed where a reader
  missed the gap because the section rendered only on absence.
- **Per-analyst identifier prefixes in `research`.** In `code-review` the equivalent immunity is free because prefixes
  are per-agent-type identities. In `research` every analyst is the same agent type, so a prefix would have to be a
  dispatch-order index passed in the brief. **Reopen when** a citation is rewritten wrongly despite the mapping.
- **Generalizing the location-attribution rule to every cited location.** The cost would land on all thirty findings a
  capped review can carry. **Reopen when** a misattributed ordinary source location is reported.
- **An agent-availability probe in the shared `scripts/`.** A shell script cannot observe whether a model's tool call
  will be permitted. **Reopen when** a host exposes tool availability to a script.
- **Teaching the shared `han-core` specialist agents the location-attribution rule.** Those agents serve every skill
  that dispatches them, so changing their output contract reaches past these two skill folders. **Reopen when** an
  agent brief is given a generated artifact to scan.
- **Persisting the `research` mapping to a file.** The report is that skill's only output. **Reopen when** an operator
  asks to audit a merge after the fact.
- **A test harness pinning report structure.** No runner in this repository can execute a `SKILL.md`. **Reopen when**
  one exists.

## Cut for Scope

Both entries are yours to reinstate, and your saying so is itself a valid justification the reinstated entry records
([D-17](artifacts/change-decision-log.md#d-17-two-gaps-the-discovery-round-found-are-cut-for-scope-and-named-for-the-operator)).

- **The YAGNI section's missing mode scope**
  ([C-18](artifacts/current-state-findings.md#c-18-the-yagni-checklists-mode-exception-lives-only-in-its-caller-not-in-the-file-named-canonical)).
  Someone opening `review-checklist.md` to follow its YAGNI procedure applies it to an uncommitted-changes review,
  because the file states the procedure unconditionally while Step 4 suspends it there. Cut because feedback issue
  #194 does not report it and it is not a necessity of any of the four defects. It is the same class of edit as the
  mode-scope paragraph Unit 5 already writes, in the same file, so reinstating it is close to free.
- **The unnamed mechanism behind generalist-finding deduplication**
  ([C-22](artifacts/current-state-findings.md#c-22-the-junior-developer-deduplication-instruction-names-no-mechanism)).
  A review can carry a generalist finding pointing at a specialist finding that says something else, because nothing
  states how "the same issue" is decided. The check confirms the reference exists, rather than that it fits. That is
  the issue's own shared shape in a defect the issue does not report. Cut on the same grounds, and it is labelled
  `Unverified` in any case: nobody could inspect a completed run's output to see whether the substitution is carried
  out correctly today.

## Open Items

- **Non-blocking, and the one I would put back in front of you: a packaging diff can no longer produce a clean
  review.** The finding S-8 raises is a warning, and the template turns any warning into "this code can be merged, but
  the identified warnings should be reviewed first." So every Mode A review of a build-configuration change stops
  saying the code can be approved, including changes with nothing wrong. The summary-row prefix marks the row as
  something unchecked rather than something proven, which is the mitigation available inside the template's existing
  vocabulary. Exempting the recommendation line itself is a change to what an approval means, so it is yours rather
  than mine to make. What would settle it: your call, or a few runs showing whether readers start discounting the
  recommendation line on packaging diffs.
- **Non-blocking: defect 2 is closed by disclosure, not by inspection.** Issue #194 asks the run to inspect the
  produced artifact; you chose the disclosure knowing it does not catch the reported defect
  ([D-12](artifacts/change-decision-log.md#d-12-escalation-register-the-one-question-this-run-took-to-the-operator)).
  What would settle it differently: a packaging defect reaching production through a review that carried the S-8
  finding.
- **Non-blocking: no runtime evidence exists for either reported failure.** Nobody in this run could observe a
  `code-review` run with dispatch denied, or a `research` fan-out whose registries collided. Every claim about what
  those runs produce rests on reading the procedure. The issue supplies the substitute: it reports both as runs that
  already happened, and the unit checks say how to stage each one locally.

## Review Findings

One round, at the medium band's cap of two, stopped after one. Every finding was a correction this plan could
apply, rather than a question needing a specialist whose domain had not run. Three specialists reviewed the draft:
`han-core:junior-developer`, `han-core:test-engineer`, and `han-core:user-experience-designer`. Decisions are in
[`artifacts/change-decision-log.md`](artifacts/change-decision-log.md); what follows is what changed and why.

**Findings that changed a delta entry, sending it back through the behavior gate:**

- **S-9's population did not exist.** The draft aimed the location rule at generated files on the diff, which Step 4
  instructs the run to skip. It also aimed at automated-check output, which already emits its own file and line. The rule was
  keeping a fix alive with nothing to fire on. Re-scoped to the region-read path, which is real and current. Raised by
  `han-core:junior-developer`.
- **S-3 was not behavior-preserving.** Its condition changes, and the pass that re-checks findings against the code
  must now skip in manual-only mode because it dispatches an agent. The draft's own reasoning elsewhere relied on that
  fact, while the entry said the opposite. Reclassified and the clause written. Raised by `han-core:junior-developer`.
- **S-15 was not behavior-preserving.** It is where the support judgment first executes, so it catches a wrong citation
  in a run with no merge collision at all. Reclassified. Raised by `han-core:test-engineer`.
- **A third surface would have deleted the disclosure.** The skill that posts a review to a pull request is instructed
  to skip sections naming no problem at a location. Added as S-21 and Unit 7. Raised by
  `han-core:user-experience-designer`.

**Findings that corrected a pinned contract:**

- The detection rule counted an empty agent result as a dispatch failure. That would have printed a disclosure saying
  security coverage was absent on a run where the always-dispatched security agent ran and stayed silent by design. A
  false disclosure is worse than the silent one this change fixes. Dropped that trigger.
- The three worked examples of a degraded run described three different runs, with four items in one, two in another,
  and a count of six in the third. Made to describe one run, and the coverage population stated once.
- The mapping's worked example mapped three different local identifiers to one merged identifier with contradictory
  dispositions, and carried no column naming the source. Nothing could be joined back to an analyst's output.
  Rewritten with a source column.
- Where the `research` mapping lives was specified two contradictory ways: a unit check said the report carries it
  while the deferral list said persisting it was out of scope. Settled as a working record the run holds.
- The support check reads a column that both of the skill's own inline column enumerations omit. Added as S-20.
- The sweep mapping showed two rows of roughly eleven. Written out in full, which is what revealed that four agents
  have no counterpart or a partial one, and that a config-declared extra agent cannot be pre-mapped at all.

**Findings that corrected the plan's own bookkeeping:**

- Unit 0's ordering constraint named the wrong units, sequencing a `research` unit behind a `code-review` headroom
  edit. Corrected, and the second measurement it needs is now scheduled.
- S-5 was a no-op: a lazily-rendered block already satisfies the verification item the draft proposed to amend.
  Repurposed to the fixed-order list, which genuinely does need the section named in it.
- Unit 6's second check is not stageable, and the plan now says so instead of claiming a check nobody can run.
- Three reference files need contents-list maintenance, one of them because this change pushes it past the length that
  requires one ([D-20](artifacts/change-decision-log.md#trivial-decisions)).

**Findings not acted on, with the reason:**

- The authoring guidance puts conditional logic in a `SKILL.md` body and domain knowledge in a reference file, which
  argues against S-1's placement. Not acted on. That file already carries the dispatch steps and is already named an
  authoritative home, so the in-file precedent is stronger than the general rule, and the body has no room. Recorded
  because the plan justified the placement by line count where the guidance would ask what kind of content it is
  ([D-19](artifacts/change-decision-log.md#d-19-the-guidances-placement-rule-is-noted-and-not-followed-with-the-reason-recorded)).
- The always-present coverage section was re-examined and left rejected, with the reopen trigger sharpened to name the
  reader it would serve.

**Nothing was labeled `Unverified` in a way that blocks.** Two findings rested on inputs nobody could inspect, both
about surfaces no run has produced yet: a rendered report from a degraded run, and a posted pull request body. The
instruction text underlying both was read directly and confirmed, so the fixes rest on what the files say rather than
on what a run would do.
