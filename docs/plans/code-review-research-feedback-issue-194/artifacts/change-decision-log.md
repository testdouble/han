# Change Decision Log: Code Review and Research Response to Feedback Issue #194

<!--
This file records every decision committed while planning this change. The plan itself lives in
[../change-plan.md](../change-plan.md) — this file captures the question, rationale, evidence, and rejected
alternatives behind each decision. Evidence about the code as it stands today lives in
[current-state-findings.md](current-state-findings.md) as numbered C-N findings.
-->

## Trivial decisions

- D-13: Both long-form skill docs are updated in the same change — the doc in each plugin's `docs/skills/` is
  canonical for its skill by the repository's own convention, and each currently states a fact this change makes
  wrong. — Referenced in plan: Surface Delta, Change Units.
- D-14: No plugin version is bumped and no CHANGELOG entry is written — `CLAUDE.md` assigns the changelog to the
  `han-release` skill, and no version bump was asked for. — Referenced in plan: Change Units.
- D-20: Three reference files get contents-list maintenance in the units that touch them — two gain an entry for a new
  section, and the verification file gains a contents list outright, because it sits at exactly the length past which
  the authoring guidance requires one and this change pushes it over. Raised by `han-core:junior-developer`. —
  Referenced in plan: Surface Delta, Change Units.
- D-15: `han-research/agents/research-analyst.md` is not changed — the analyst keeps numbering its own sources from
  `A1`, because D-8 puts the whole fix on the orchestrator's side of the merge. — Referenced in plan: Target State.

## Full decisions

### D-1: The degraded mode is named, and it is not a fourth letter in the existing series

- **Question:** What is the manual-only execution mode called, and does it extend the skill's existing Mode A / Mode B
  / Mode C series?
- **Decision:** The mode is called **`manual-only mode`**. The A/B/C letter series is not extended. The existing
  letters enumerate one axis, how much git context the run has; whether agent dispatch is available is a second,
  independent axis. A Mode A run with a full branch diff can be manual-only, and so can a Mode C run.
- **Rationale:** A fourth letter would assert that the four states are mutually exclusive, which they are not. Naming
  the mode at all is what the change is for: C-1 records that the only handling today is a step-skip sentence that
  names no mode, and C-13 records the repository's own authoring rule that a degraded path gets a name so other
  sites can refer to it.
- **Evidence:** C-1, C-13. The authoring rule verbatim: "Define modes explicitly by name so the skill body and review
  output can reference them clearly."
- **Behavior impact:** Preserving on its own. Naming a mode changes no output; the entries that depend on this
  decision carry the behavior changes.
- **Rejected alternatives:**
  - **`Mode D`** — rejected because it puts a second axis into a one-axis enumeration, and every existing site that
    says "Mode B and Mode C" would become ambiguous about whether it also means Mode D.
  - **Leaving the state unnamed and describing it inline at each site** — rejected because C-2 and C-3 establish
    three separate consumers (the report block, the closing message, the verification item), and C-16 records the
    repository's convention that a rule with several consumers gets one named home the others cite.
- **Revisit criterion:** If agent availability and git context ever become mutually exclusive, the axes have merged
  and one enumeration is correct.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-1, S-2, S-3
- **Dependent decisions:** D-2, D-3
- **Referenced in plan:** Target State, Surface Delta

### D-2: The coverage disclosure renders only when coverage was absent, and it reaches the closing message too

- **Question:** Where does the disclosure live, and does the report carry it on every run or only on degraded runs?
- **Decision:** Two places. In the report, a `## Review Coverage` section at heading level two — a peer of Recommended
  Changes, not a child of Review Summary — rendering immediately after the Review Summary block closes and **only when
  some planned coverage was absent**, so its absence means every planned coverage ran. It is named in the template's
  fixed section order, since a section absent from that list has no defined position. It opens with a line naming its
  own cause, because the report's reader and the operator are different people and a reviewer on a pull request never
  sees the closing message. Then one row per absent item:

  ```markdown
  - **Absent:** {coverage name} — {reason}; {swept by hand under {categories} | not swept — {what to do instead}}.
  ```

  Worked example:

  ```markdown
  ## Review Coverage

  Agent dispatch was unavailable on this run, so no specialist read this change (manual-only mode).

  - **Absent:** security review — swept by hand under Data Isolation, Error Handling, API Design. Nothing substitutes for an exploit path demonstrated against the code.
  - **Absent:** concurrency review — not swept; no checklist category covers races or lock ordering. Check shared state and async ordering by hand before merging.
  - **Absent:** independent validation of the findings — not swept; the findings below were not re-checked against the code by a second pass. Weigh each on its own evidence.
  ```

  Three things the grammar does deliberately, all of them corrections from the review round. The plain-English coverage
  name leads and the agent identifier is dropped, because a reviewer on a pull request has no roster and no plugin
  installed. Internal step numbers are gone for the same reason. And the `not swept` branch carries a clause saying
  what to do instead, because a line with no verb aimed at the reader gets read as bookkeeping about the run rather
  than as something addressed to them.

  The population is settled once: every agent selection produced, plus the independent validation pass, which is
  planned coverage a manual-only run cannot reach because it dispatches an agent. Selection is a fact by the time
  detection fires, not a counterfactual.

  And in the closing message, one clause appended to the run's-own-facts part, naming the cause and the consequence
  rather than a mode name and a count:

  ```
  Medium: 6 files touched, adds one index. Agent dispatch was unavailable, so no specialist read this change; 8 of 11
  coverage areas were swept by hand and 3 were not. See Review Coverage in the report.
  ```

- **Rationale:** The report is where the issue asks for it, in as many words, and a fixed home is what it asks for.
  The closing message carries it too because the message is what a person reads first and the report is a file they
  may not open; a disclosure only in the file would leave the reported failure half-fixed. Conditional rendering
  rather than an always-present section follows the template's own lazy-section rule, which C-2 quotes, so the
  disclosure costs nothing on a healthy run.
- **Evidence:** C-2 (no surface exists today, and the lazy-section rule that governs any new one), C-3 (the closing
  message's four parts, with part 4 already the home for the run's own conduct), C-14 (the sibling skill that already
  discloses a coverage gap in both its artifact and its summary, with the stated purpose "so the coverage gap is
  visible rather than silent"). The work item asks for it directly: "the report must record which specialist coverage
  was absent. Add a matching line to the report template so the disclosure has a fixed home."
- **Behavior impact:** **Changing.** A degraded run's report gains a section it did not carry, and every run's
  closing message can gain a clause. The observer is the person reading the report and the operator in the turn. The
  work item asks for both in its suggested fix, so the recorded boundary is the decision on it; no separate operator
  answer was sought. Named in the run's closing summary as a behavior change.
- **Rejected alternatives:**
  - **An always-present Review Coverage section stating full coverage on healthy runs** — rejected because it
    contradicts the template's lazy-section rule that C-2 quotes, and it puts a line on every report to carry
    information the absent case already conveys. Recorded as a YAGNI candidate with its reopen trigger.
  - **The report only, with no closing-message clause** — rejected because the report is a file the run explicitly
    never pastes into the conversation, so a reader who stops at the message would learn nothing about the gap. That
    is the reported failure at one remove.
  - **A row in the Review Summary table instead of its own section** — rejected because that table is defined as an
    index of findings, one row per finding, and absent coverage is not a finding.
- **Revisit criterion:** A reader who needs positive confirmation that coverage was complete — an auditor, or someone
  weighing an old approval months later — appearing as a real reader of these reports. The review round sharpened this
  trigger: the risk is not that a reader draws a wrong inference from silence, because the default reading of silence
  matches the truth. The risk is that a reader wanting assurance has nothing to read.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-4, S-5, S-6, S-7
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes

### D-3: The mode is detected by the dispatch mechanism failing, never by an empty result

- **Question:** How does a run learn that agent dispatch is unavailable, and how does it avoid mistaking an agent with
  nothing to say for an agent that never ran?
- **Decision:** Two triggers, both about the mechanism: the dispatch tool is unavailable, or the dispatch call is
  denied. **An empty or silent agent result is not a trigger.** No new probe and no change to the existing detection
  script. The line the run emits:

  ```
  Manual-only mode: agent dispatch unavailable ({verbatim tool error, or "Agent tool not in allowed-tools"}).
  Manual review is the primary path. Coverage absent: junior-developer, security, and every conditional agent
  Step 3.2 selected. See the sweep mapping for what substitutes.
  ```

- **Rationale:** Nothing earlier in the run can know the answer. C-4 records that selection reasons only about signals
  in the changed-file list and that the frontmatter lists the dispatch tool beside every other tool with no guard, so
  the first moment the state is observable is the dispatch itself.

  The exclusion of empty results is the correction the review round forced, and it matters more than the rest of this
  decision. An earlier draft counted "every dispatched agent fails to return" as a third trigger. C-4 quotes the roster
  entry for the always-dispatched security agent: "the agent stays silent when the standard is not met." A run reading
  that silence as failure would enter the mode, sweep by hand, and print a disclosure claiming security coverage was
  absent on a run where it ran and passed. **A false disclosure is worse than the silent one this change exists to
  fix**, because the whole point of the block is that a reader can trust what it says.
- **Evidence:** C-4, C-13. C-13 records the one difference from the existing git modes that matters: those are probed
  by a script before the work starts, and a shell script cannot observe whether a model's tool call will be permitted.
  The silent-agent case was raised by `han-core:junior-developer` in the review round and confirmed against the roster
  text.
- **Behavior impact:** Preserving on its own. Detection produces a recorded line; the observable changes belong to the
  disclosure and the sweep.
- **Rejected alternatives:**
  - **Counting an empty agent result as a trigger** — rejected on the evidence above.
  - **A new probe in the shared repo-root `scripts/`** — rejected as cross-plugin infrastructure carrying its own Bats
    tests, for a state the dispatch attempt already reveals. Deferred with a reopen trigger.
  - **Extending the existing detection script** — rejected on the same grounds plus a concrete one: a shell script
    cannot observe whether a model's tool call will be permitted.
- **Revisit criterion:** If a host exposes tool availability to a shell script, the probe becomes the cheaper
  detection. If an agent is ever specified to fail silently in a way indistinguishable from passing silently, the
  exclusion needs revisiting.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-1, S-3
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta

### D-4: The by-hand sweep is a stated mapping from each absent agent to checklist categories

- **Question:** What does "sweep the specialist categories by hand" mean concretely, so a run does the same thing
  twice?
- **Decision:** A mapping stated in `agent-dispatch.md`'s new manual-only section, one line per agent, pinned by a
  grammar line and worked entries:

  ```
  - `{agent}` → sweep by hand under {review-checklist category}, {category} — at the {size} band from Step 3.1.
  - `han-core:test-engineer` → sweep by hand under Testing, Correctness — at the {size} band from Step 3.1.
  - `han-core:adversarial-security-analyst` → sweep by hand under Data Isolation, Error Handling, API Design — at the {size} band from Step 3.1.
  ```

  The mapping is written out in the plan for every agent on the roster, plus a fallback row form for an agent a project
  config's `## Extra Agents` list contributes, which cannot be pre-mapped because the file has never heard of it.

  **Writing it out changed what this decision is worth, and the plan says so.** Four of the roster's agents have no
  checklist counterpart or only a partial one: concurrency and infrastructure coverage is recovered not at all, and
  security and resilience coverage only in part. An earlier draft showed two rows and implied the sweep recovered most
  of what was lost. It does not, and the honest result is that the disclosure matters more than the sweep does.

- **Rationale:** C-5 establishes that the manual checklist runs at its normal depth whether the agents ran or not, and
  that nothing conditions its scope on the dispatch outcome. A sweep instruction with no mapping would leave the
  substitution to each run's judgment, which is the state C-5 already describes. Naming the band is what the work
  item asks for.
- **Evidence:** C-5, C-7 (the checklist's category names the mapping's right-hand side draws on). The work item:
  "the specialist categories the roster would have covered should be swept by hand at the same size band".
- **Behavior impact:** **Changing.** A manual-only run raises findings it did not raise before, in the mapped
  categories. The observer is the author of the change under review. The work item asks for the sweep in its
  suggested fix, so the recorded boundary is the decision on it. Named in the run's closing summary.
- **Rejected alternatives:**
  - **"Review more carefully when no agents ran"** — rejected because it is not a mapping and two runs would do
    different things.
  - **Dispatching nothing and disclosing only** — rejected because it discards the coverage the work item asks to
    recover, and the disclosure alone would report a gap the run made no attempt to close.
- **Revisit criterion:** If an agent's coverage is found to have no checklist counterpart at all, that agent's row
  says "nothing substitutes" rather than naming a category that does not cover it.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-1
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes

### D-5: The Packaging category names the gap rather than inspecting the artifact

- **Question:** Does a `code-review` run open a built artifact when the diff changes what gets packaged, or does it
  report that it did not?
- **Decision:** It reports. A new `Packaging (when applicable)` category in `review-checklist.md` triggers on a diff
  that changes what gets packaged and raises an ordinary review finding. The run acquires no new command permission
  and opens no archive. The category matches the shape C-7 records: an entry in the file's contents list and a
  heading, both carrying the `(when applicable)` suffix, over a bullet list of concrete triggers.

  The triggers, which are the diff signals the category watches for: shading or relocation rules, vendoring, include
  and exclude patterns, dependency scope changes, and bundling configuration.

  What the finding must state, pinned as a worked example so two runs write the same thing:

  ```markdown
  **WARN-002** `build.gradle:41` Someone installs the published jar and calls `WidgetFactory.create`, and it fails at
  startup with a missing-class error, because the exclude rule added here drops a class that surviving classes still
  reference. This review did not open the built artifact and cannot tell you whether that happened: the exclude
  patterns say what was removed, not what still points at it. A green build is not evidence either, because a
  development run has a wider classpath than the shipped artifact. Check the produced artifact before merging: that
  every internal reference resolves inside it, that no third-party package is exported unrelocated, and that the
  licence notices the packaging requires are present. **Fix:** by hand.
  ```

  **Severity:** WARN by default, since the finding names work the author has to do rather than a defect the review
  proved. It follows the size-based demotion in Step 3.3 like every other manual finding.

  **The first sentence varies with the diff; the rest is fixed.** The category says so explicitly. Without that, a
  builder can satisfy this decision by pasting the worked example with the path swapped, and every packaging review
  then carries five identical sentences that a reader stops reading by the third. The first sentence names the specific
  rule the diff added and the specific symptom it could produce.

  **The summary-table row opens with `Not checked —`**, matching the `May never fire —` cue the template already uses to
  mark a finding class a triaging reader should weigh differently, and placed for the same stated reason: so a person
  triaging thirty findings gets the cue before opening any one of them. Without it, a row saying the review did not look
  sits at the same visual weight as a proven defect.

  **Mode scope**, stated inside the category rather than only in its caller:

  ```
  **Mode scope.** This category applies in Mode A only. Step 4's Mode B and Mode C conservative rule admits only
  focus-area items, source-file items, and file-boundary items, and without a base-branch diff the run cannot tell
  what the change altered about packaging. Same reason the YAGNI checklist is suspended in those modes.
  ```

- **Rationale:** The operator was asked how far a review run should reach into build output and chose the
  disclosure. Their words: **"option b"**, against a question that named the alternative as opening the archive and
  reporting the dangling reference, and named the cost of that alternative as a standing command permission
  auto-approved on every future review including on repositories that build nothing.

  C-7 supplies the shape, so this is an extension of an extensible list rather than a change to the review procedure.
  Stating the mode scope inside the category answers C-18 directly: that finding records the YAGNI section asserting
  its procedure unconditionally while its caller suspends it in two modes, and a new category repeating that mistake
  would be avoidable at the cost of one paragraph.
- **Evidence:** operator answer (verbatim: "option b"), C-6, C-7, C-18. The work item asks for the trigger and for
  the dev-classpath caveat, both of which this carries. It asks for the inspection, which this does not do; see
  Behavior impact. The variance requirement and the summary-row cue were both raised by
  `han-core:user-experience-designer` in the review round, the second against the plan's own stated risk that this
  finding degrades into a warning people learn to skip.
- **Behavior impact:** **Changing.** A Mode A review of a diff that alters packaging raises a finding it did not
  raise before. The observer is the author of the change. Settled by the operator's answer above rather than by the
  work item, because the work item and the operator diverge here.

  **Say plainly what this does not do.** The work item asks the run to inspect the produced artifact, and this does
  not inspect it. The defect that prompted the work item, an exclude rule dropping a class that surviving classes
  still called, is not caught by this category. What changes is that a reviewer is told the review has that hole and
  what to check by hand, instead of a silent pass. That is a smaller fix than the work item asked for, and it is the
  fix the operator chose after being told so.
- **Rejected alternatives:**
  - **Opening the artifact with a narrow read-only command permission** — rejected by the operator. It was the
    recommended option and it is the only one that closes the reported defect. Reopening it means adding the
    narrowest reader prefixes plus a "could not inspect" branch for a missing reader or an unbuilt artifact.
  - **Asking the operator mid-run to run one command and paste the output** — rejected: the skill's design writes a
    file and explicitly never pastes the review into the conversation, so a stop for input cuts across it.
  - **Grepping source imports against the build config's exclude patterns** — rejected on stronger grounds than
    cost. Bytecode references are a superset of source imports, so this method produces confident passes on exactly
    the reported failure mode. It is worse than disclosing, because disclosing admits the gap and this hides it.
  - **Three bullets appended to `Code Organization`** — rejected because C-7 records that category as a
    file-placement rule with no conditional suffix, so a diff-triggered item there would run on every review and
    would have nowhere to state its mode scope.
  - **A row in the coverage block from D-2** — rejected because that block records coverage that was planned and did
    not happen. Under this decision the run never plans to inspect an artifact, so the absence is the skill's
    designed scope rather than a gap in a particular run.
- **Revisit criterion:** A reported instance of a packaging defect reaching production through a review that carried
  this finding reopens the inspection option.
- **Left open rather than settled:** this finding is a warning, and the template turns any warning into a recommendation
  that the code not be approved as-is. So a Mode A review of a build-configuration change with nothing wrong stops
  saying the code can be approved. The summary-row cue is the mitigation available inside the template's existing
  vocabulary. Exempting the recommendation line itself changes what an approval means, which is the operator's call and
  not this plan's; it is carried in `## Open Items`.
- **Dissent (if any):** None recorded. The plan recommended the inspecting option and the operator chose otherwise;
  that is a decision, not a dissent.
- **Settles delta entry:** S-8
- **Dependent decisions:** D-6
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes

### D-6: The location rule fires on the region-read path, which is the one that survives D-5

- **Question:** D-5 means a run never opens compiled output, so no finding can cite a location inside an archive. Does
  defect 3's fix still have anything to fire on, and if so, what?
- **Decision:** Yes, on one specific current path. Step 4 reads a file over a thousand lines by its changed regions and
  their surrounding context rather than whole. **A location established from a region read is the work item's failure
  at a reachable altitude**: you find a hit in a region, you look upward for the nearest declaration, and the
  declaration the region happened to include may not be the one that encloses it.

  The rule: when a finding's location was established by reading a region of a file rather than the unit that contains
  it, read the enclosing unit in isolation before writing the finding, and never carry forward the nearest declaration
  the region included. It lives in `finding-content.md`, which owns what every finding carries and is loaded at the
  drafting step, the moment the work item names.

  The location form:

  ```
  **CRIT-003** `src/billing/reconciler.rb:2841` (enclosing member: `Reconciler.retry_batch`, confirmed by reading
  lines 2790-2860 in isolation) {explanation} … **Fix:** by hand.
  ```

  A finding from a file the run read whole carries no such note.

- **Rationale:** This is the second home this rule has had, and the review round is why. An earlier draft aimed it at
  "machine-generated output the run reads", naming two populations. `han-core:junior-developer` established that
  neither is real: C-6 quotes Step 4 instructing the run to skip generated files outright, and automated-check output
  already emits its own file and line rather than requiring a scan. The draft was spending three delta entries and a
  change unit on a rule with nothing to fire on, and the finding was right.

  The region-read path is different in kind, because the run is instructed to take it. It is not a population the plan
  went looking for to keep a fix alive; it is the one place the procedure itself creates the conditions the work item
  describes.
- **Evidence:** C-8 (the skill's only instruction about a location is to include one, and the check that looks like
  verification resolves the path against a file list instead of reading the code), C-6 and D-5 (why the archive and
  generated-file populations are unreachable), and Step 4's own instruction to read a large file by its changed regions
  and their surrounding context. The correction was raised by `han-core:junior-developer`.
- **Behavior impact:** **Changing.** Such a finding carries a form it did not carry, and confirming the unit can change
  which unit the finding names, which can change its severity. The observer is the report's reader.

  **Say plainly what this does not do.** The work item's own example is a hit inside a class's static initializer
  attributed to the method printed before it in disassembler output. Under D-5 a run never disassembles anything, so
  that case cannot arise and this rule does not catch it.
- **Rejected alternatives:**
  - **Deferring defect 3's fix entirely**, which the review round offered as the alternative — rejected because the
    region-read path makes the failure reachable, so a deferral would leave a real gap while claiming the situation
    could not arise.
  - **Aiming the rule at generated files on the diff or at automated-check output** — rejected on the evidence above.
    This was the draft's own position and it was wrong.
  - **Keeping the `{artifact-path}!{member-path}#{member-name}` grammar** — rejected because after D-5 nothing can
    produce such a location.
  - **Generalizing to every cited location** — rejected as a YAGNI candidate. The cost would land on all thirty
    findings a capped review can carry, and no finding supports it.
  - **Amending `output-verification.md` item 6** — rejected. Item 6 resolves a path against the Step 1 file list, and a
    large source file read in regions is on that list, so item 6 passes unamended.
- **Revisit criterion:** If D-5 is reopened and a run gains the ability to read an archive, the archive grammar comes
  back with it.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-9
- **Dependent decisions:** D-7
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes

### D-7: The attribution rule is guarded in two places, because each is absent when the other runs

- **Question:** Where does the check on D-6's rule live?
- **Decision:** Both places. A fifth challenge axis in the Step 7.4 validator brief, appended to the lettered list
  C-9 records:

  ```
  (e) findings whose cited location was carried forward from a scan of machine-generated output rather than
  confirmed by reading the enclosing unit, and any finding whose severity depends on which unit the location names.
  ```

  And a new structural verification item that runs in every mode, asserting that a finding whose location came from
  scanning machine-generated output names its enclosing unit and how that unit was confirmed.
- **Rationale:** Neither guard covers the other's gap. C-9 records that Step 7.4 does not run when a review produced
  no corrective findings, and after D-1 it cannot run at all in manual-only mode, since it dispatches an agent. So
  the axis alone would be absent in exactly the degraded run defect 1 describes. The verification item alone would
  confirm a form was followed without anyone re-reading the code, which is the existence-versus-correctness failure
  the work item is about.
- **Evidence:** C-8, C-9, D-6. The work item: "treat a severity that depends on the location as a reason to confirm
  it twice."
- **Behavior impact:** **Changing.** A finding may now be demoted or dropped that previously stood. The observer is
  the report's reader.
- **Rejected alternatives:**
  - **Axis (e) alone** — rejected on the C-9 evidence above: it is absent in the run that needs it most.
  - **The verification item alone** — rejected because it checks compliance with a form, not the attribution.
- **Revisit criterion:** A misattributed location surviving both guards in a real run.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-10, S-11
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes

### D-8: The traceability invariant is two-part, and it is defined in one place

- **Question:** What is the invariant after this change, and which of its four current statements defines it?
- **Decision:** Two-part, defined in `research/SKILL.md`'s Operating Principles and nowhere else. The sentence it
  carries:

  ```
  The traceability invariant is two-part. Resolvability: every `A#` cited inline resolves to a registry entry carrying
  its link, retrieval date, trust class, and evidence status. Support: the cited entry's `Summary (one line)` states
  something that bears on the claim the citation is attached to. Resolvability is necessary and not sufficient.
  ```

  Step 6, Step 8, and the report template's `Sources` comment stop defining it and cite it by name. Step 8's existing
  resolution line becomes the two-part check rather than gaining a new pass beside it.

- **Rationale:** C-10 records the invariant stated identically in four places. Strengthening it in one place and
  leaving three copies asserting the weaker form is the drift the repository's authoritative-home convention exists
  to prevent, and C-16 records that convention with a worked instance in this same area. The support half needs no new
  input: C-12 records that the registry table already carries the one-line summary the check reads, so the check adds
  no field to the template and asks nothing new of any analyst.
- **Evidence:** C-10, C-12, C-16. The work item: "State in the skill that syntactic resolvability is necessary but
  not sufficient."
- **Behavior impact:** **Changing.** A run must now check support, so a citation may be rewritten that previously
  stood. The observer is the report's reader. The work item asks for it directly.
- **Rejected alternatives:**
  - **Amending all four statements in place** — rejected because it preserves the four-way duplication C-10 records,
    and the next change to the invariant would have to be made four times again.
  - **A new `references/citation-integrity.md`** — rejected under D-11.
- **Revisit criterion:** If a second skill adopts the invariant, its home moves to a shared reference file and both
  skills cite it.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-12, S-15, S-16, S-20
- **Dependent decisions:** D-9, D-10
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes

### D-9: The merge records an old-to-new mapping, and the rewrite covers the evidence-status field

- **Question:** What form does the mapping take, and which citation surfaces are rewritten through it?
- **Decision:** A mapping built at Step 6, the step that already renumbers, pinned as a field layout with worked
  rows:

  ```markdown
  | Analyst angle       | Local ID | Source                          | Merged ID | Disposition                        |
  | ------------------- | -------- | ------------------------------- | --------- | ---------------------------------- |
  | messaging-patterns  | A1       | Kafka docs, exactly-once        | A1        | renumbered                         |
  | messaging-patterns  | A2       | Fowler, "What do you mean by X" | A2        | renumbered                         |
  | delivery-semantics  | A1       | Fowler, "What do you mean by X" | A2        | merged into A2 (same source as messaging-patterns A2) |
  | delivery-semantics  | A2       | vendor blog, undated            | —         | dropped (not relevant to the results) |
  ```

  The mapping is a working record the run holds while it renders, not a report section: nothing in the report reads it,
  and persisting it is a deferral with its own trigger. The `Source` column is what makes it checkable, since without it
  nobody can join a row back to the analyst output it came from.

  Both of the skill's inline enumerations of the registry table's columns gain the one-line summary column in the same
  unit. The support check reads that column, and a run following the skill rather than the template would render a
  table the check cannot read.

  The rewrite covers every `A#` in Research Results, in each Option's `Rests on`, in the Recommendation's
  `Evidence basis`, **and inside every `Evidence status` field** — `corroborated by {A#}` and
  `contradicted by {A#}` — in both the registry table's last column and each `A#` detail block. Step 7 passes the
  mapping to the validator alongside the registry it already receives.
- **Rationale:** C-11 establishes that the collision is structural rather than incidental above the small band,
  because every analyst in a wave restarts at `A1`, and that "merging duplicates" is itself a renumbering, so the
  merge cannot preserve any analyst's numbering even in principle. The evidence-status field is on the list because
  C-19 records it as a citation surface nobody names: it is written by an analyst against that analyst's own local
  numbering and it lives inside the registry being renumbered. A rewrite covering only prose would leave it stale,
  which fixes half the defect.
- **Evidence:** C-11, C-19, C-20. The work item: "Where a merge renumbers identifiers, record the old-to-new mapping
  and rewrite citations through it rather than by hand." Three corrections came from `han-core:junior-developer` in the
  review round: the earlier worked example mapped three different local identifiers to one merged identifier with
  contradictory dispositions and carried no source column; the mapping's home was specified two contradictory ways; and
  the summary column the support check reads is absent from both of the skill's own column enumerations.
- **Behavior impact:** **Changing.** A citation may be rewritten to a different identifier than the one an analyst
  wrote. The observer is the report's reader. The work item asks for it directly.
- **Rejected alternatives:**
  - **The support check alone, rewriting citations by reading** — rejected because rewriting by hand is the thing
    that already failed, and C-11 establishes that at medium and large every analyst restarts at `A1`, so there is
    nothing for a careful reader to anchor on.
  - **Per-analyst identifier prefixes so no collision occurs** — rejected as a YAGNI candidate, and on a concrete
    ground beyond that. C-21 records why the equivalent immunity is free in `code-review`: its prefixes are
    per-agent-type identities. In `research` every analyst is the same agent type, so a prefix would have to be a
    dispatch-order index passed in the brief, adding a brief field and coupling the identifier space to roster order.
- **Revisit criterion:** A run where a citation was rewritten wrongly despite the mapping reopens the prefix option.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-13, S-14
- **Dependent decisions:** D-10
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes

### D-10: A claim whose only source the merge dropped is labeled no-evidence, not single-source

- **Question:** What happens to a claim whose cited source the merge dropped as not relevant to the results?
- **Decision:** The claim either loses its citation and carries the canonical no-evidence label with a reopen
  trigger, or it is dropped along with its source. It is **not** relabeled `[single-source]`, and in strict mode it
  cannot support the recommendation.
- **Rationale:** This corrects the architect's proposal, which pinned the dropped case as
  "marked `[single-source]` or `[reasoning]` per the evidence mode". Two things are wrong with that. A claim whose
  only source was dropped has no source, not one, and the canonical evidence rule forbids exactly that collapse in as
  many words. And `[reasoning]` is defined as an exploratory-mode-only label, so in strict mode it is not available.
- **Evidence:** C-20 (the dropped case has no stated handling today) and the canonical evidence rule's third
  principle, verbatim: "Do not collapse 'no evidence' into 'very weak evidence.' They are different states." Settled
  from evidence; no operator question was needed.
- **Behavior impact:** **Changing**, inheriting D-9's classification. A claim's evidence label can change and a
  recommendation can lose support it appeared to have. The observer is the report's reader. The direction is toward
  the canonical rule the skill already loads, so the change reduces a divergence rather than introducing one.
- **Rejected alternatives:**
  - **Marking the claim `[single-source]`** — rejected because the canonical rule this skill loads forbids the
    collapse, and because it would overstate the evidence in the one case the reader most needs it not overstated.
  - **Keeping the source in the registry rather than dropping it** — rejected because it would override the merge's
    own relevance filter from downstream, and a registry padded with sources nothing cites is a different defect.
- **Revisit criterion:** If the canonical evidence rule's no-evidence pattern changes, this follows it.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-13
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes

### D-11: No new reference file, and no shared rule generalizing the three citation defects

- **Question:** Does any of the four fixes earn a new reference file, and does the shared shape the work item names
  earn a shared rule?
- **Decision:** No to both. Every rule lands in a file that already exists. The shared shape is stated in the work
  item and in this plan's own framing, and nothing executable is extracted from it.
- **Rationale:** Two independent reasons for the file half. Three of the four fixes land in lists that are already
  extensible: C-7's conditional-category shape, C-9's lettered challenge axes, and the numbered verification items. And
  C-15 quotes the authoring rule that every reference file is linked directly from its `SKILL.md`, never
  reference-to-reference, so each new file spends body lines a 495-line file against a 500-line ceiling does not
  have.

  For the shared-rule half, the shape is a description rather than an instruction. The three mechanisms are
  inspecting an archive's internal references, isolating an enclosing member from compiled output, and rewriting
  identifiers through a merge mapping; they share a moral, not a procedure. C-21 removes the only candidate second
  consumer for the identifier half by establishing that `code-review`'s own fan-out cannot produce the collision. And
  C-17 records that the natural home would be a vendored file, making it a multi-plugin edit with a re-sync
  obligation. An abstraction with one consumer per mechanism and no named second consumer is the
  single-implementation anti-pattern the YAGNI rule names.
- **Evidence:** C-7, C-9, C-15, C-17, C-21.
- **Behavior impact:** Preserving. This decision is about where rules live, not what a run does.
- **Rejected alternatives:**
  - **`references/degraded-modes.md`, `references/built-output-review.md`, `references/citation-integrity.md`** —
    each rejected on the two grounds above. Recorded as YAGNI candidates with reopen triggers.
  - **A shared "a reference must point at the right thing" rule in `han-core/references/`** — rejected as above, and
    deferred rather than dropped, with the trigger named.
- **Revisit criterion:** A third skill needing identifier-mapping-after-merge, or a second skill consuming any one of
  these rules, reopens the corresponding file.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** — (shapes the plan without committing one entry)
- **Dependent decisions:** D-1, D-5, D-8
- **Referenced in plan:** Target State, Deferred (YAGNI)

### D-12: Escalation register — the one question this run took to the operator

- **Question:** How much reach should a `code-review` run have into build output: should the skill acquire the
  permission to open and read a compiled artifact, or stop at naming the gap and disclosing it?
- **Decision:** Stop at naming the gap. The operator's answer, verbatim: **"option b"**.
- **Rationale:** This is the run's only escalation, and it reached the operator because the repository could not
  settle it. What the repository did settle, and what therefore stayed out of the question: no rule forbids a new
  command permission, the authoring guidance's standard on the subject is granularity rather than an allowlist, and
  the security guidance says nothing about which commands a skill may run. What was left was a judgment about what
  this skill is for, and what a standing permission costs on every future run.

  The question as put named three candidate answers and a recommendation. It opened with a concrete outcome rather
  than a mechanism: someone reviews a branch that changes which compiled classes get bundled into a shipped jar, the
  exclude list drops a class three surviving classes still call, the build passes, and the reviewer is asked what
  they should see. Option A opened the archive and reported the dangling reference, at the cost of a command
  permission auto-approved on every later review including on repositories that build nothing. Option B reported
  that the review did not look. Option C stopped mid-run to ask the operator for one command's output. The
  recommendation was A, with the reason stated plainly: B does not close the defect the work item reported. The
  operator was told that before answering and chose B.
- **Evidence:** operator answer. The reframe that preceded it came from `han-core:junior-developer` in conversational
  mode and settled five sub-questions from the repository, leaving one for the operator. One claim in that reframe
  was wrong and was corrected before the question went out: it reported `Bash(make *)` and `Bash(npm *)` as stale
  grants unused by the skill, but Step 2 runs whatever test, lint, and build commands it discovered from project
  config, which is what those prefixes exist for.
- **Behavior impact:** Changing, through D-5 and D-6, which this decision governs.
- **Rejected alternatives:** Recorded in full under D-5.
- **Revisit criterion:** Recorded under D-5.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-8, S-9
- **Dependent decisions:** D-5, D-6
- **Referenced in plan:** Behavior Changes, Open Items

### D-18: The disclosure has to survive to the pull request, so the skill that posts it is in scope

- **Question:** The coverage disclosure is written into a report file. Does it reach the people who read that report on
  a pull request?
- **Decision:** Not as things stand, so `han-github/skills/post-code-review-to-pr` is brought into the change. It names
  Review Coverage among the optional sections it carries across from the report, and exempts it from the clarity pass's
  length-matching instruction alongside the Review Summary table and the Review Recommendation.
- **Rationale:** That skill builds the public pull request body from the report file and enumerates the optional
  sections it expects to find, a list this new section would not be on. Its clarity pass then instructs the run that
  every finding earns its place by naming a specific problem at a specific location, and to skip filler sections. **A
  coverage disclosure names no problem at any location by construction**, so it is the most deletable block in the body
  by that skill's own stated bar, and the pass is carried out by a dispatched agent applying the bar as written.

  Left alone, the fix for the first defect would survive on the two surfaces with the narrowest audiences and vanish
  from the one with the widest. A reviewer on a pull request sees neither the terminal nor the report file. That is the
  reported failure reproduced one level out, in a skill the plan had not looked at.
- **Evidence:** raised by `han-core:user-experience-designer` in the review round and confirmed by reading the skill's
  own step text. The scope authority is the operator's answer in the confirmation turn, quoted in
  `artifacts/scope-boundary.md`: "expand to other files where it fits." This fits: the YAGNI evidence is a named direct
  dependency, since S-4 cannot reach that audience without it.
- **Behavior impact:** **Changing.** A pull request body from a degraded run carries the coverage section. The observer
  is every reviewer on that pull request.
- **Rejected alternatives:**
  - **Leaving the skill alone and accepting the loss** — rejected because the pull request is the widest audience the
    disclosure has, and losing it there is losing most of the fix.
  - **Wording the section so it reads as a finding at a location** — rejected because it is not one, and dressing it as
    one to survive a filter would put it in the summary table, which indexes findings.
- **Revisit criterion:** If the posting skill's clarity pass is ever rewritten to reason about section kinds rather than
  about findings, the exemption may become unnecessary.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-21
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta, Behavior Changes, Change Units

### D-19: The guidance's placement rule is noted and not followed, with the reason recorded

- **Question:** The authoring guidance says conditional logic belongs in a `SKILL.md` body and domain knowledge such as
  templates, checklists, and decision matrices belongs in a reference file. S-1 puts an execution mode's detection rule
  and branch in a reference file. Is the placement wrong?
- **Decision:** Keep the placement. Record the tension rather than leaving it implicit.
- **Rationale:** Two things outweigh the general rule here. That reference file already carries the dispatch steps the
  mode belongs to, and C-16 records it as an authoritative home for a cross-file rule, so the in-file precedent is
  specific where the guidance is general. And the body has no room: C-15 puts it five lines under a ceiling that two
  commits in the recorded history exist to enforce.

  What the review round correctly objected to was the plan's reasoning rather than its conclusion. The draft justified
  the location by line count, and the guidance would ask what kind of content it is. Both answers point the same way
  here; recording that they are different questions is what keeps a later reader from generalizing the line-count
  argument to a case where they diverge.
- **Evidence:** raised by `han-core:junior-developer` in the review round. C-15, C-16.
- **Behavior impact:** Preserving. This decision changes where a rule is written, not what a run does.
- **Rejected alternatives:**
  - **Putting the detection rule in the body** — rejected on the headroom evidence, and because it would split the mode
    across two files with the branch in one and its mapping in the other.
- **Revisit criterion:** If the body gains substantial headroom and the mode grows a second branch, the placement is
  worth reconsidering on the guidance's own terms.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** —
- **Dependent decisions:** —
- **Referenced in plan:** Review Findings

### D-16: The headroom unit runs only if the measured line count at build time requires it

- **Question:** Does the change need to free lines in `code-review/SKILL.md` before adding pointers to it?
- **Decision:** Conditionally. Step 8 of that skill restates the template's own lazy-section and fixed-order rules in
  substantially the same words, and `template.md` is loaded at Step 8 on every run, so the restatement can collapse
  to a pointer under the same convention C-16 records. That unit runs only when the line count measured at build time
  leaves less headroom than the pointers this change adds. The measurement decides, not this plan.
- **Rationale:** C-15 records the file at 495 lines against a 500-line ceiling and twenty-eight commits in ninety
  days. Both numbers matter: the first says headroom is nearly gone, the second says the number will have moved by
  the time anyone builds this. Committing the unit unconditionally would spend a change nobody may need; omitting it
  would leave the builder stuck.
- **Evidence:** C-15, C-16.
- **Behavior impact:** Preserving. No output changes. The only reader at risk is a run that skips reading
  `template.md`, which Step 8 already instructs it to read.
- **Rejected alternatives:**
  - **Running it unconditionally** — rejected because the file may have headroom by build time and the change would
    then be unmotivated.
  - **Letting the body exceed the ceiling** — rejected because two commits in the recorded history exist only to
    bring skill bodies back under it.
- **Revisit criterion:** Measured headroom at build time is the criterion; it is not revisited otherwise.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** S-17
- **Dependent decisions:** —
- **Referenced in plan:** Change Units

### D-17: Two gaps the discovery round found are cut for scope, and named for the operator

- **Question:** The discovery round found two real gaps feedback issue #194 does not report. Do they join this change?
- **Decision:** No. Both are cut, recorded in the plan's cut list, and named in the run's closing summary so the
  operator can reinstate either.
- **Rationale:** The recorded boundary is issue #194 and its four defects. The operator widened the area to files
  outside the two skill folders where a fix belongs there, which is a statement about *where* the four fixes may
  land, not about which defects the change addresses. Neither gap is a necessity of any of the four, so the scope
  gate's floor does not save them.

  The two:

  - **C-18.** `review-checklist.md`'s YAGNI section states its two-pass procedure unconditionally, while Step 4
    suspends it in the two modes that have no diff. A reader who opens the checklist alone, which its "canonical
    home" framing invites, follows an instruction its caller overrides. This is the same class of edit as D-5's
    mode-scope paragraph, in the same file, so reinstating it would be cheap.
  - **C-22.** The rubric tells a run not to duplicate a generalist finding another agent already raised and to
    reference the specialist's classification instead. Nothing states how "the same issue" is determined, and the
    generalist runs in an isolated context in the same parallel wave, so only the orchestrator can carry the
    substitution out. The verification item checks that the reference exists, never that it points at the right
    finding. That is the work item's own shared shape in a defect the work item does not report.
- **Evidence:** C-18, C-22, and `artifacts/scope-boundary.md`'s Stated Scope and Operator-Stated Scope sections. C-22
  is labeled `Unverified` and carries no blocking weight in any case.
- **Behavior impact:** Preserving. Nothing is changed for either.
- **Rejected alternatives:**
  - **Absorbing C-18 into D-5's unit** — rejected because it is a separate defect in the same file, and folding an
    unrequested fix into a requested unit is how a cut stops being visible. It is one line for the operator to ask
    for.
  - **Absorbing C-22** — rejected on the same ground, plus its `Unverified` label.
- **Revisit criterion:** The operator saying so. Their direction is itself a valid justification, and a reinstated
  entry records it as one.
- **Dissent (if any):** None recorded.
- **Settles delta entry:** — (produces the cut list)
- **Dependent decisions:** —
- **Referenced in plan:** Cut for Scope
