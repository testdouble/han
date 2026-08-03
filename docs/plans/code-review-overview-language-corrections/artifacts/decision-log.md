# Decision Log: Understandable and Usable Output from Code Review and Code Overview

This file records every decision settled while specifying the corrections to the reader-facing output of the
`code-review` and `code-overview` skills. Behavioral statements live in
[../feature-specification.md](../feature-specification.md); this file carries the history, rationale, evidence, and
rejected alternatives.

The boundary these decisions were settled inside is recorded in [scope-boundary.md](./scope-boundary.md).

Every decision below was classified once, after the review round returned, as full or trivial. The D# numbers were
assigned while drafting and did not change in that pass, so every inline link in the specification still resolves.

## Trivial decisions

- D4: Both skills source the explanation standard before they write for a non-implementer — each skill sources Han's
  standard for explaining work to a non-implementer before drafting the content that reader sees: the review before its
  finding explanations, the overview before its closing restatement, and both before their closing message (considered
  restating the standard inline in each skill; rejected because the repository keeps one canonical copy of a shared
  standard and sources it). — Referenced in spec: Primary Flow; Coordinations.

## Full decisions

### D1: Who the second explanation on a finding is written for

- **Question:** A review finding today carries one prose slot, written for someone who will open the file. Who is the
  new required explanation written for?
- **Decision:** The reader who will not open the file. Every corrective finding carries a plain-language explanation
  answering three questions: what goes wrong that someone could observe, what has to be true for it to happen, and how
  likely that is, including saying outright when the finding may be a no-op. The explanation answers all three; it does
  not print three fixed slots. Where an answer is not in doubt, it is a clause rather than a sentence. The explanation
  leads the finding, ahead of the register written for the person who will open the file.
- **Rationale:** This is the most-repeated request in the reviewed corpus and it is a request for a register, not for
  more facts. One session spent four consecutive turns asking for exactly this, finding by finding. The capability is
  already demonstrated in those follow-up answers; it is simply not in the report.
- **Evidence:** Issue 170, improvement 1 and finding 3. Quoted user turns: "explain sugg-001 in plain language, no
  technical details" repeated across four findings in session 70cc4998; "give me a brief description of how and why the
  two queries in sugg-002, diverge" in session 2c2aefa2. The finding template's single prose slot is at
  `han-coding/skills/code-review/references/template.md:78-82`. Han's standard for this reader already exists at
  `han-communication/references/explanation-rule.md` and neither skill invokes it.
- **Rejected alternatives:**
  - Rewrite the existing prose slot to serve both readers — rejected because the two registers need different things:
    the author needs the location and the mechanism, the non-author needs the consequence and the likelihood. Collapsing
    them loses one.
  - Produce the plain-language explanation on request rather than in the report — rejected because that is the current
    behavior and it is what the issue measures as the cost.
  - Require all three answers at full length on every finding regardless of doubt — rejected on the simpler-version test
    after review. On a finding whose failure is certain and unconditional, the preconditions and likelihood both collapse
    to "always", and printing them at length is the symmetry pattern the YAGNI rule names. Requiring the questions to be
    answered keeps the whole of the evidence; requiring three sentences does not.
  - Let the two explanations appear in either order — rejected after review. The reader this one is written for would
    otherwise have to read past prose addressed to someone else to reach their own, which is the same argument already
    accepted for the closing message.
- **A note on where the length went.** The work item scores the current output poorly on length, and its own stated
  reason for that score is the review pasting itself into the conversation and both closing messages opening with
  bookkeeping. Both are fixed here, by D7 and D8. Growing each finding was weighed against that score and accepted,
  bounded by the simpler-version rewrite above and by D16, which keeps the growth out of the surface a person scans.
- **Linked technical notes:** —
- **Driven by findings:** F1, F4, F12, F13
- **Dependent decisions:** D2, D3, D4, D15, D16
- **Referenced in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes; Open Items

### D2: Which findings carry the second explanation

- **Question:** Does the required plain-language explanation apply to advisory findings as well as corrective ones?
- **Decision:** Corrective findings only. Critical, warning, and suggestion findings each carry it. Advisory findings do
  not.
- **Rationale:** The advisory class already answers the same question in a different form. Each advisory finding carries
  a stated trigger describing the concrete circumstance that would justify keeping the code, which is the preconditions
  and likelihood the new explanation exists to supply. Requiring both would print the same content twice.
- **Evidence:** Issue 170's improvement 1 names warnings, suggestions, and critical findings and does not name the
  advisory class. The advisory section's existing reopen-trigger requirement is at
  `han-coding/skills/code-review/references/template.md:89-93`. The advisory class is explicitly non-correcting per
  `han-coding/skills/code-review/SKILL.md:54-61`.
- **Rejected alternatives:**
  - Require it on every finding including advisory ones — rejected because it duplicates the reopen trigger and lengthens
    a section the issue already praises for being short.
- **Naming, after review.** "Corrective" and "advisory" are the words this specification uses; they are not words a
  reader of a report sees. In the report, corrective means the critical, warning, suggestion, and security findings, and
  advisory means the findings the report already states will not be corrected unless asked for. Both skills state the
  mapping in the reader's own vocabulary rather than adopting this specification's shorthand.
- **Linked technical notes:** —
- **Driven by findings:** F3, F2
- **Dependent decisions:** D15
- **Referenced in spec:** Outcome; Primary Flow

### D3: Publishing the reachability reasoning instead of discarding it

- **Question:** The review already works out whether a finding's failure mode can be reached, uses that to set severity,
  and then throws the reasoning away. Where does that reasoning go?
- **Decision:** Into the finding's plain-language explanation, as the preconditions and likelihood. When the review has
  already lowered a finding's severity for being unreachable, the reason it lowered is what the reader sees. Where the
  review holds no such reasoning, the writer derives the answers from the finding's own evidence at drafting time.
- **What that derivation is and is not.** It is writing work. The reasoning is read out of evidence the finding already
  carries, and it never feeds back into the finding's severity, whether it is found or dropped. The severity was already
  set by passes this feature leaves untouched, and a finding whose explanation turns out to read "this may be a no-op"
  keeps the severity those passes gave it.
- **Rationale:** The corpus contains the exact question this answers: a user asked whether a suggestion described a real
  error condition, and the honest answer was that three conditions had to hold at once and the population where all
  three held was probably empty. Everything in that answer was available at review time.

  Review corrected an earlier version of this rationale, which claimed the review already holds this reasoning for every
  finding. It does not. The gate that lowers severity for an unreachable failure mode matches a fixed list of phrases in
  the producing specialist's own words, and says of itself that the phrase list is its only signal. So it produces
  reasoning worth publishing on the findings it matches and nothing at all on the rest. Publishing what it does produce
  still removes a question class at no cost; the rest is derived at drafting time, from evidence the finding already
  carries.
- **Evidence:** Issue 170, improvement 1 and finding 4. Quoted user turn from session 2d405303: "i don't understand
  SUGG-001. is there an actual error condition that can be caused by this?" The demotion gate that computes and discards
  the reasoning is at `han-coding/skills/code-review/SKILL.md:355-381`.
- **Rejected alternatives:**
  - Publish the reasoning as a separate audit section — rejected because it separates the reasoning from the finding it
    qualifies, and the reader's question is always about a specific finding.
  - Require the explanation only on findings the gate matched — rejected. It would restrict the answer to the findings
    whose specialist happened to use one of eight words, which is not the same population as the findings a reader
    cannot judge.
- **Linked technical notes:** —
- **Driven by findings:** F11
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Alternate Flows and States; Out of Scope

### D5: Where the report and the overview are written

- **Question:** Both skills ignore the configured destination, so someone types it into nineteen of twenty invocations.
  How does the destination resolve?
- **Decision:** Both skills resolve their destination through Han's configuration precedence chain, so a configured base
  directory is honored. Absent any configuration, each keeps the destination it has today: the review lands beside the
  reports its specialists already write, and the overview lands outside the repository.
- **Rationale:** The configured destination being ignored is the whole defect. Removing each skill's default as well
  would change behavior the issue does not complain about, and the overview's out-of-repository default carries a
  separate commitment: the overview is an orientation aid, not documentation, and must not be committed. Honoring
  configuration when it exists satisfies the evidence with the smaller change.
- **Evidence:** Issue 170, improvement 2 and finding 1. The configured setting has existed in the operator's personal
  configuration since 2026-07-30 and is a recognized key per `han-core/references/config-rule.md:44`. Only the Atlassian
  skills consume it today, confirmed by grep across every `SKILL.md`. The overview's out-of-repository
  prescription is at `han-coding/skills/code-overview/SKILL.md:265-269`; its ephemerality commitment is a separate
  operating principle at lines 82-84. The review has no output-location step at all.
- **Rejected alternatives:**
  - Drop the out-of-repository prescription entirely, as improvement 2's wording suggests — rejected because the
    prescription is both a default and an override, and only the override is the defect. Dropping both would let an
    unconfigured overview land in the repository, against the skill's own ephemerality principle.
  - Have the review default outside the repository to match the overview — rejected because the review already resolves
    an in-repository directory for its specialists' reports, and splitting the report from those reports makes the run's
    output harder to find, not easier.
- **A configured destination inside the repository, after review.** Configuration wins, and the run says nothing about
  it. The person who configured a destination inside the repository chose it, which is the same treatment the canonical
  configuration rule already gives a destination outside the working directory. The overview's commitment not to be
  committed is a commitment the skill makes about its own default, not a veto over what a person configures.
- **A destination that cannot be written, after review.** The run writes to the unconfigured default instead and says in
  its closing message that it did, naming the destination it could not use. It does not fail the run: everything the run
  produced is already finished by the time it writes, and losing all of it to a missing directory is the worse outcome.
- **Linked technical notes:** —
- **Driven by findings:** F7, F8, F18
- **Dependent decisions:** D6
- **Referenced in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes; Coordinations; User Interactions

### D6: How the review report file is named

- **Question:** Consecutive reviews overwrite each other because the report carries a fixed name. What distinguishes one
  run's report from the next?
- **Decision:** The report is named from the branch or ticket the review covers. When the branch does not distinguish
  the run, because the review is running against the default branch or against a scope with no branch at all, the report
  is named from what was reviewed: the single file, directory, or symbol when there is one, and the common parent of the
  reviewed files when there is not.
- **When a report already exists at that name.** The run replaces it and says so in its closing message, naming the
  report it replaced. Review raised this as the case D6's own quoted evidence describes: a person re-reviewing a branch
  after acting on the first report. Keeping both would leave two reports for one branch with nothing in their names to
  say which is current, which is the confusion the naming change exists to remove. Saying so is what protects a person
  still working the earlier report as a queue.
- **Rationale:** The fixed name is a real collision, visible in a session where the invocation itself had to work around
  it. Branch and ticket are the identifiers a person recognizes, and one of them is available in every mode that has
  git. The fallback matters because the review runs against a plain directory when git is absent, and a run with no
  distinguishing name is exactly the case the collision comes from.
- **Evidence:** Issue 170, improvement 2 and finding 2. Quoted invocation from session ce765d64: "delete the existing
  review for this in .scratch/ and write a new review file in .scratch/". The three review modes, including the no-git
  mode, are at `han-coding/skills/code-review/SKILL.md:108-131`. The overview already names its file from a target slug
  at `han-coding/skills/code-overview/SKILL.md:267-268`.
- **Rejected alternatives:**
  - Add a timestamp — rejected because it distinguishes runs without saying what they cover, so a person choosing among
    three files learns nothing from the names.
  - Change the overview's naming too — rejected because the overview's target slug already distinguishes its runs, so
    there is no collision to fix.
  - Distinguish the second review of a branch rather than replacing the first — rejected as above: two reports for one
    branch, neither named as current.
- **Linked technical notes:** —
- **Driven by findings:** F5
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes

### D7: What the review says when it finishes

- **Question:** The review currently ends by pasting itself into the conversation with no path in it. What does it say
  instead?
- **Decision:** The review closes with a short message carrying the recommendation, the finding count by severity, and
  the path the report was written to. The full report is not pasted into the conversation.
- **When the only findings are advisory.** The recommendation is still that the code can be approved, because the
  advisory class is non-correcting by construction and never blocks a merge. The message says the corrective count is
  zero and names the advisory count separately, so the person is not told "no findings" about a report whose body lists
  items. Review raised this as an ordinary state rather than an exotic one: the advisory pass runs on every change
  regardless of size.
- **Rationale:** The overview already does this and the issue names it as the behavior the review is missing. The one
  fact a person needed after a review, the path, was absent from a message long enough to contain everything else.
- **Evidence:** Issue 170, improvement 2 and finding 2. Quoted user turn from session 2c2aefa2 immediately after a
  review: "where was that output written?" The overview's equivalent step is at
  `han-coding/skills/code-overview/SKILL.md:328-332`; the review's process ends at verification,
  `han-coding/skills/code-review/SKILL.md:491-495`.
- **Rejected alternatives:**
  - Keep pasting the review and add the path — rejected because the length is itself a defect: the path was already
    recoverable from a long message and the person still had to ask.
- **Linked technical notes:** —
- **Driven by findings:** F6
- **Dependent decisions:** D8
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes; User Interactions

### D8: What leads the closing message in both skills

- **Question:** Both closing messages open with bookkeeping about the run. What leads instead?
- **Decision:** The answer leads. For the review, that is the recommendation and the counts by severity. For the
  overview, that is why the code or change exists and any divergence from its stated purpose. Facts about how the run
  was conducted come last or not at all.
- **Rationale:** Both reports are already held to a standard that puts the main point first, and the closing message is
  the part a person actually reads first. Applying the standard to the report but not to the message inverts the
  intended order at the one place it matters most.
- **Evidence:** Issue 170, improvement 8 and finding 10. Quoted opening line from session 2c2aefa2: "Verification
  complete: task IDs are sequential, all findings trace to dispatched agents or manual passes, no contradictory pairs,
  no empty sections, and the readability self-check passes." Session 34a5fc56 led with a production block above the two
  facts that mattered. The overview's current closing content is specified at
  `han-coding/skills/code-overview/SKILL.md:330`.
- **Rejected alternatives:**
  - Drop the run bookkeeping entirely — rejected because a coverage gap and a size that under-covered the target are
    facts a person needs in order to decide whether to re-run. Demoting them is enough; removing them loses signal.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes

### D9: Who owns diagram legibility

- **Question:** The pass that rewrites the overview for readability is barred from touching diagrams, so nothing checks
  whether a diagram can be read. Who checks?
- **Decision:** The overview skill checks it against a stated rule: a diagram's boxes name components and boundaries,
  not fields, types, or annotations, and the detail belongs in the prose beneath the diagram. The rewrite pass stays out
  of diagram bodies.
- **Rationale:** This is the only formatting complaint that recurred, it arrived twice, and both times the fix was the
  same. The exemption is right for accuracy, because a rewrite that edits a diagram body can silently change what the
  diagram claims, and it is wrong for reading load. Naming the rule and giving the skill the check separates the two.
- **Evidence:** Issue 170, improvement 3 and finding 5. Quoted user turns: "reduce the details in the mermaid diagram.
  it's too difficult to read right now" (session 34a5fc56); "take the technical details out of the diagram blocks. the
  rendered blocks are difficult to read with all the detailed descriptions and technical references. i want high level
  (mobile, web, graphql, shared engine, etc)" (session 435c664e). The confirmation that the fix worked, same session:
  "ok, this is good. i understand the over-all flow now." The exemption is at
  `han-coding/skills/code-overview/SKILL.md:306` and again at line 318. The template's only current diagram rule is the
  scope label, `han-coding/skills/code-overview/references/overview-template.md:41-42`.
- **Rejected alternatives:**
  - Let the rewrite pass edit diagram bodies — rejected because that pass optimizes for reading and would be free to
    reword a box in a way that changes what the diagram asserts about the code. The accuracy pass runs before it and
    would not see the change.
  - Leave legibility to the reader to request — rejected because that is the current behavior and it is what the two
    complaints cost.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes; Out of Scope; Deferred (YAGNI)

### D10: Where the extended gloss rule lives

- **Question:** A reader cannot look up a term the document invented. Requiring a gloss at first use is agreed; the
  question is whether that requirement binds every Han document or only the overview.
- **Decision:** It goes in Han's shared writing standard, so every document Han produces glosses a term the reader
  cannot resolve: external technologies and language runtimes, named statistical or numerical methods, and compound
  nouns the document coins for its own convenience.
- **Rationale:** The operator chose this after being shown the trade-off. The reason that argued for it: the agent that
  rewrites finished drafts reads only the shared standard, so a rule kept local to the overview would have nothing
  enforcing it beyond the overview's own self-check. Putting the rule where the enforcer already looks is what makes it
  hold.
- **Evidence:** User input, this session. Corroborating detail from issue 170, improvement 4 and finding 6: four
  questions across two sessions, each quoting the overview's own words back at it, covering a language runtime, a
  statistical method, and two coined compound nouns. All four passed the current rule at
  `han-communication/references/readability-rule.md:51`. Skills across the suite source that rule, confirmed by grep
  across every `SKILL.md`. The rewriting agent's rule source is `han-communication/agents/readability-editor.md`.
- **Rejected alternatives:**
  - Put the rule in the overview's template only — rejected by the operator. It matches where all four complaints came
    from, but leaves the rule with no enforcer.
  - Split it, with coined terms in the shared standard and external technologies local to the overview — rejected by the
    operator. It splits one rule across two homes, and a reader meeting an unglossed runtime name in a specification has
    the same problem they had in an overview.
- **The reach of this decision is stated, after review.** This is the one change in the feature that reaches past the
  two skills the work item names. Every skill that sources the shared standard inherits the rule, and the agent that
  rewrites finished drafts starts enforcing it on documents this work item never examined. That is the operator's
  choice, made with the trade-off in front of them, and it belongs in the specification's own scope statements rather
  than only in a coordination row.
- **Linked technical notes:** —
- **Driven by findings:** F9, F18
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Coordinations; Out of Scope

### D11: The overview's closing restatement

- **Question:** The reliable next action after an overview is to paste a plain-language paragraph somewhere else. Does
  the overview produce it?
- **Decision:** Yes. The overview ends with three or four sentences a non-author could read aloud, carrying no file
  paths and no type names. Those sentences are the canonical text, and the run's closing message carries them rather
  than writing its own version. Review raised the risk that two independently written restatements of the same thing
  drift apart, and that the person reads the shorter one in the terminal and never opens the document.
- **Rationale:** The overview already holds every fact that paragraph needs. The corpus shows the person either
  paraphrasing it themselves and asking whether the paraphrase holds, or asking for it outright so they can put it in a
  pull request description or a comment to a reviewer.
- **Evidence:** Issue 170, improvement 5 and finding 7. Quoted user turns: "is this accurate for me to say? …" (session
  435c664e); "update pr description. keep it plain language, concise, no technical details" (session 34a5fc56); "give me
  a plain language summary, no technical details, of the [handler function] differences" (session de1c6647).
- **Rejected alternatives:**
  - Put the restatement at the top instead — rejected because the lead section already answers why the code exists for a
    reader of the document. The restatement is written to be lifted out and pasted elsewhere, which is a different
    artifact serving a different reader.
  - Let the closing message write its own version — rejected after review. Two texts saying the same thing in different
    words teach the reader to distrust the shorter one.
- **Linked technical notes:** —
- **Driven by findings:** F14
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; User Interactions

### D12: Each finding names how it gets fixed

- **Question:** After a review, the person asks which Han skill to reach for on a given finding. Does the finding say?
- **Decision:** Yes. Each corrective finding names its remediation route: writing the behavior test-first for a missing
  behavior, restructuring for a design change, or by hand for a small edit.
- **Rationale:** They ask anyway, and the finding already contains what decides the answer. Naming it costs a clause.
- **Evidence:** Issue 170, improvement 5. Quoted user turns: "would `/tdd` or `/refactor` be better for sugg-003?" and
  "would /refactor or /tdd be better suited for this?" The finding-ID scheme these questions address findings by is at
  `han-coding/skills/code-review/SKILL.md:76-86`.
- **Rejected alternatives:**
  - Add a remediation section listing routes for all findings at once — rejected because the report already has a
    section by that name reserved for security findings, and a second one would collide with it. The route belongs on
    the finding a person is looking at.
- **Linked technical notes:** —
- **Driven by findings:** F2, F4
- **Dependent decisions:** D15, D16
- **Referenced in spec:** Primary Flow; User Interactions; Coordinations

### D13: What "where to start" gives the reader

- **Question:** The overview lists the right entry points and the person still asks which file to open first. What is
  missing?
- **Decision:** An order. The entry points are numbered in reading order, each with one line on what the reader learns
  there. When one of those entry points is an interface other code calls, that entry point carries one runnable example
  call.
- **Why the example call attaches to the entry point, not the target.** Review pointed out that the session this came
  from is not a clean case of one or the other. The person asked which file to open first to start tracing a path, and
  what an actual call would look like, about the same target: an interface with substantial flow behind it. Directory
  and change-set targets are routinely both. Attaching the rule to the entry point covers the mixed case without a rule
  for it.
- **Rationale:** A set is not a sequence. The person asked which file to open first even though the right files were all
  listed, and then asked what an actual call would look like, which is the first useful artifact when the target is an
  interface rather than a flow.
- **Evidence:** Issue 170, improvement 6 and finding 8. Quoted user turns from session 435c664e: "what graphql file do i
  need to look at first, to start tracing this path through the code?" and "what would an actual graphql query look
  like, if i wanted to use the existing workaround for re-calculating an existing [record]?" The current requirement is
  concrete entry points without an order, at
  `han-coding/skills/code-overview/references/overview-template.md:38-40` and lines 101-104.
- **Rejected alternatives:**
  - Include an example call for every entry point — rejected under the simpler-version test. Where the entry point is a
    file in a flow, an invented example call would be noise.
  - Decide it per target rather than per entry point — rejected after review, as above.
- **Linked technical notes:** —
- **Driven by findings:** F15
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes

### D14: The overview may report that a change's stated reason is not supported

- **Question:** The overview reports the stated reason for a change faithfully and never checks it against the code, so
  it can correctly describe the motivation for a change the code shows to be unnecessary. May it say so?
- **Decision:** Yes, in the section that states the reason, as a fact about the reason. It says the code already
  satisfies the stated motivation, or that the code does not support the reason given. It raises no finding, assigns no
  severity, and recommends no change.
- **Only a checked contradiction qualifies.** Review separated two states this decision had collapsed. Saying the code
  contradicts the stated reason is a claim the overview must have checked and found to be true. Finding no evidence
  either way is a different state, and it already has its own handling: the overview marks the reason as inferred. An
  overview that reports a contradiction it did not find would be making a stronger claim than its evidence supports,
  which is the exact failure the skill's accuracy commitment exists to prevent.
- **Rationale:** This is a fact about the stated reason, which the overview already owns and already validates for
  accuracy against the code. It is not a judgment about the code's quality, which stays out of the skill. The
  distinction holds because the claim under test is the document's own leading claim, not the code.
- **Evidence:** Issue 170, improvement 7 and finding 9. Quoted user turns from session 435c664e: "given all of this new
  information, are the changes we planned in this branch still necessary? why or why not?" and "given all of this, what
  is the actual problem that this proposed solution would solve?" The skill's no-quality-judgment boundary is at
  `han-coding/skills/code-overview/SKILL.md:69-72`, and the accuracy pass that already re-reads the code to test the
  stated reason is at lines 276-293. The issue's own constraint: "Keep the quality boundary; this is not a finding about
  the code's quality."
- **Rejected alternatives:**
  - Leave it to the review skill — rejected because the review judges the code, and this is a statement about whether
    the change's stated purpose holds. Neither skill would say it, which is the current state.
  - Say it in the navigational section on where the change is hardest to follow — rejected because that section is
    navigational by construction, and an unsupported reason belongs beside the reason it qualifies.
  - Treat a reason the code says nothing about as unsupported — rejected after review. It is a stronger claim than the
    evidence carries, and the skill already has a weaker and more honest one.
- **Linked technical notes:** —
- **Driven by findings:** F16
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States; Out of Scope

### D15: Security findings carry the plain-language explanation but not a separate fix route

- **Question:** Security findings are corrective, sit in their own section with their own shape, and are deliberately
  exempt from the pass that lowers severity for unreachable failure modes. Do they gain the new content?
- **Decision:** They carry the plain-language explanation, on the same terms as every other corrective finding. They do
  not gain a separately-labelled fix route, because their section already ends with a remediation note naming what to
  do.
- **Rationale:** Two reviewers raised this independently, and both observed that a security finding is the one a
  non-implementer can least evaluate unaided, so it is the last finding that should silently skip the explanation. The
  exemption from the severity gate is not a reason to skip it: the exemption exists because the security evidence bar is
  already higher, not because the reader needs less. Adding a second route label beside the existing remediation note
  would put two answers to the same question in one block.
- **Evidence:** The security section, its shape, and its remediation note are at
  `han-coding/skills/code-review/references/template.md:95-111`. The gate exemption and its stated reason are at
  `han-coding/skills/code-review/SKILL.md:380-382`. D12's own rejected alternative already names the collision risk.
- **Rejected alternatives:**
  - Exclude security findings from the explanation — rejected because the exemption they carry is about evidence
    standards, not about the reader.
  - Add the fix route to security findings too — rejected as a duplicate of content the block already carries.
- **Linked technical notes:** —
- **Driven by findings:** F2
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

### D16: The likelihood and the fix route reach the surface a person scans

- **Question:** The report's index is a summary row per finding. Every corrective finding is about to grow. Does the
  index grow with it?
- **Decision:** Yes, in two specific ways. Where the review has established that a finding's failure mode may not be
  reachable, that fact appears on the finding's own opening line and in its summary row. Each summary row also carries
  the fix route beside the brief description.
- **Rationale:** The complaint this feature descends from is comparative, not additive. The work item says a probable
  no-op "read as a behavior change at the same visual weight as the two findings beside it". Answering that with a
  longer finding body leaves the weight exactly where it was and adds reading load on top. The fix is to put the cue in
  the surface the reader already scans, so triage happens before the reading rather than after it.

  The two halves rest on different evidence, and the record supports them unequally. The may-never-fire cue answers the
  originating complaint directly, which is quoted above. The fix route in the row rests on the same reviewer's second
  observation, that the report's only index gains nothing while the body it indexes roughly doubles, plus improvement
  5's evidence that the person asks which skill to reach for anyway. One reviewer raised both halves, in two findings;
  an earlier version of this rationale credited two reviewers converging independently, which the merged record does not
  support.
- **Evidence:** Issue 170, finding 4 and its accuracy rationale: "a finding can be accurate and still mislead by
  weight". The summary table and its brief-description cell are at
  `han-coding/skills/code-review/references/template.md:26-40`. The severity-ordered row order is specified there and is
  unchanged by this decision. This decision adds content inside existing rows: it changes no severity band, no row
  order, and no finding identifier, which is what the Out of Scope statements protect.
- **Rejected alternatives:**
  - Add a separate section or a second table for conditional findings — rejected because it splits one finding list into
    two and the reader would have to reconcile them.
  - Reorder findings so probable no-ops sort last — rejected because the row order is severity-ordered by design and the
    finding identifiers are worked as a queue; changing the order changes an artifact the work item praises.
  - Leave the index unchanged — rejected because that is the state the complaint describes.
  - Put the may-never-fire cue in the row and leave the fix route in the finding body — considered at synthesis, because
    the cue carries the stronger evidence of the two. Rejected because it makes the row answer one triage question and
    not the other, so a person still opens each finding to learn how it gets fixed, which is the question improvement 5
    records them asking after every review.
- **Linked technical notes:** —
- **Driven by findings:** F4
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Alternate Flows and States; User Interactions; Out of Scope;
  Deferred (YAGNI)

### D17: Each skill checks that the new required content is present before it presents

- **Question:** Almost everything this feature adds is content that must be there. What confirms it is?
- **Decision:** Each skill checks its own output before presenting: the review that every corrective finding carries the
  plain-language explanation and a fix route, and that the summary rows carry the route and any conditional cue; the
  overview that its diagrams follow the legibility rule, that its starting points are ordered, that terms a reader
  cannot look up are explained, and that the closing restatement is present and free of file paths and type names. A
  check that fails is fixed before presenting.
- **Rationale:** A requirement with nothing checking it is a preference, and the failure mode is silent: the run
  produces the output it produces today and nobody notices. The overview already carries a check for one of these rules
  and not the others, which is the inconsistency review found.
- **Evidence:** Review finding F10, raised by `han-core:junior-developer` as JD-007: of everything this feature
  requires, only the diagram rule carried a stated check. The overview's existing self-check and the review's
  verification step both already exist as places for this to live, at
  `han-coding/skills/code-overview/SKILL.md:317-326` and `han-coding/skills/code-review/SKILL.md:491-495`.
- **Rejected alternatives:**
  - Rely on the agent that rewrites drafts for readability to enforce it — rejected because that agent is barred from
    changing facts and from touching diagram bodies, so most of this is outside what it may do.
  - Add a separate verification pass — rejected under the simpler-version test. Both skills already have a place where a
    check like this belongs.
- **Linked technical notes:** —
- **Driven by findings:** F10
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow
