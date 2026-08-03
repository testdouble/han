# Decision Log: Understandable and Usable Output from Code Review and Code Overview

This file records every decision settled while specifying the corrections to the reader-facing output of the
`code-review` and `code-overview` skills. Behavioral statements live in
[../feature-specification.md](../feature-specification.md); this file carries the history, rationale, evidence, and
rejected alternatives.

The boundary these decisions were settled inside is recorded in [scope-boundary.md](./scope-boundary.md).

## Full decisions

### D1: Who the second explanation on a finding is written for

- **Question:** A review finding today carries one prose slot, written for someone who will open the file. Who is the
  new required explanation written for?
- **Decision:** The reader who will not open the file. Every corrective finding carries a plain-language explanation
  giving the observable consequence, the preconditions that must all hold for it to happen, and an honest likelihood,
  including saying outright when the finding may be a no-op.
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
  - Produce the plain-language register on request rather than in the report — rejected because that is the current
    behavior and it is what the issue measures as the cost.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D2, D3, D4
- **Referenced in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes

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
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes

### D3: Publishing the reachability reasoning instead of discarding it

- **Question:** The review already works out whether a finding's failure mode can be reached, uses that to set severity,
  and then throws the reasoning away. Where does that reasoning go?
- **Decision:** Into the finding's plain-language explanation, as the preconditions and likelihood it already computed.
  When the review demotes a finding for being unreachable, the reason it demoted is what the reader sees.
- **Rationale:** The corpus contains the exact question this answers: a user asked whether a suggestion described a real
  error condition, and the honest answer was that three conditions had to hold at once and the population where all
  three held was probably empty. Everything in that answer was available at review time. Reusing the reasoning costs
  nothing and removes a question class.
- **Evidence:** Issue 170, improvement 1 and finding 4. Quoted user turn from session 2d405303: "i don't understand
  SUGG-001. is there an actual error condition that can be caused by this?" The demotion gate that computes and discards
  the reasoning is at `han-coding/skills/code-review/SKILL.md:355-381`.
- **Rejected alternatives:**
  - Publish the reasoning as a separate audit section — rejected because it separates the reasoning from the finding it
    qualifies, and the reader's question is always about a specific finding.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes

### D4: Both skills source the explanation standard before they write for a non-implementer

- **Question:** What makes the new register consistent across runs rather than left to chance?
- **Decision:** Each skill sources Han's explanation standard before drafting the content a non-implementer reads: the
  review before it drafts finding explanations, the overview before it writes its closing restatement. Both also source
  it before writing their closing message.
- **Rationale:** The standard exists, defines this exact reader, and is sourced the same way the readability standard
  already is. Neither skill invokes it today, which is the gap rather than a model shortcoming.
- **Evidence:** Issue 170, improvement 1: "Invoke `han-communication:explanation-guidance` before drafting findings; the
  standard for this reader already exists and neither skill uses it." The standard is at
  `han-communication/references/explanation-rule.md`; its stated application point is "before writing an escalation, a
  confirmation turn, a stop, or any summary a non-implementer reads" (lines 78-83). The parallel readability sourcing is
  at `han-coding/skills/code-review/SKILL.md:457` and `han-coding/skills/code-overview/SKILL.md:211`.
- **Rejected alternatives:**
  - Restate the standard inline in each skill — rejected because the repository keeps one canonical copy of a shared
    standard and sources it, per the conventions in `CLAUDE.md`.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Coordinations

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
  configuration since 2026-07-30 and is a recognized key per `han-core/references/config-rule.md:44`. Only the three
  Atlassian skills consume it today, confirmed by grep across every `SKILL.md`. The overview's out-of-repository
  prescription is at `han-coding/skills/code-overview/SKILL.md:265-269`; its ephemerality commitment is a separate
  operating principle at lines 82-84. The review has no output-location step at all.
- **Rejected alternatives:**
  - Drop the out-of-repository prescription entirely, as improvement 2's wording suggests — rejected because the
    prescription is both a default and an override, and only the override is the defect. Dropping both would let an
    unconfigured overview land in the repository, against the skill's own ephemerality principle.
  - Have the review default outside the repository to match the overview — rejected because the review already resolves
    an in-repository directory for its specialists' reports, and splitting the report from those reports makes the run's
    output harder to find, not easier.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D6
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes; Coordinations

### D6: How the review report file is named

- **Question:** Consecutive reviews overwrite each other because the report carries a fixed name. What distinguishes one
  run's report from the next?
- **Decision:** The report is named from the branch or ticket the review covers. When the run has neither, it is named
  from the target that was reviewed.
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
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes

### D7: What the review says when it finishes

- **Question:** The review currently ends by pasting itself into the conversation with no path in it. What does it say
  instead?
- **Decision:** The review closes with a short message carrying the recommendation, the finding count by severity, and
  the path the report was written to. The full report is not pasted into the conversation.
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
- **Driven by findings:** —
- **Dependent decisions:** D8
- **Referenced in spec:** Primary Flow; User Interactions

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
- **Referenced in spec:** Primary Flow; User Interactions

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
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes

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
  `han-communication/references/readability-rule.md:51`. Twenty-six skills source that rule, confirmed by grep across
  every `SKILL.md`. The rewriting agent's rule source is `han-communication/agents/readability-editor.md`.
- **Rejected alternatives:**
  - Put the rule in the overview's template only — rejected by the operator. It matches where all four complaints came
    from, but leaves the rule with no enforcer.
  - Split it, with coined terms in the shared standard and external technologies local to the overview — rejected by the
    operator. It splits one rule across two homes, and a reader meeting an unglossed runtime name in a specification has
    the same problem they had in an overview.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Coordinations

### D11: The overview's closing restatement

- **Question:** The reliable next action after an overview is to paste a plain-language paragraph somewhere else. Does
  the overview produce it?
- **Decision:** Yes. The overview ends with three or four sentences a non-author could read aloud, carrying no file
  paths and no type names.
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
- **Linked technical notes:** —
- **Driven by findings:** —
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
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Coordinations

### D13: What "where to start" gives the reader

- **Question:** The overview lists the right entry points and the person still asks which file to open first. What is
  missing?
- **Decision:** An order. The entry points are numbered in reading order, each with one line on what the reader learns
  there. When the target is an interface other code calls, the section also carries one runnable example call.
- **Rationale:** A set is not a sequence. The person asked which file to open first even though the right files were all
  listed, and then asked what an actual call would look like, which is the first useful artifact when the target is an
  interface rather than a flow.
- **Evidence:** Issue 170, improvement 6 and finding 8. Quoted user turns from session 435c664e: "what graphql file do i
  need to look at first, to start tracing this path through the code?" and "what would an actual graphql query look
  like, if i wanted to use the existing workaround for re-calculating an existing [record]?" The current requirement is
  concrete entry points without an order, at
  `han-coding/skills/code-overview/references/overview-template.md:38-40` and lines 101-104.
- **Rejected alternatives:**
  - Include an example call for every target — rejected under the simpler-version test. The request came from an
    interface target, where a call is the way in. For a flow target the entry point is a file, and an invented example
    call would be noise.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; User Interactions

### D14: The overview may report that a change's stated reason is not supported

- **Question:** The overview reports the stated reason for a change faithfully and never checks it against the code, so
  it can correctly describe the motivation for a change the code shows to be unnecessary. May it say so?
- **Decision:** Yes, in the section that states the reason, as a fact about the reason. It says the code already
  satisfies the stated motivation, or that the code does not support the reason given. It raises no finding, assigns no
  severity, and recommends no change.
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
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Alternate Flows and States
