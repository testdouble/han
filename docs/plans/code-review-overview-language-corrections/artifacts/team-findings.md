# Team Findings: Understandable and Usable Output from Code Review and Code Overview

This file records every finding raised by the review team for this feature, and how each was resolved. Behavioral
outcomes live in [../feature-specification.md](../feature-specification.md); decisions the findings affected live in
[decision-log.md](decision-log.md). No `feature-technical-notes.md` was created for this feature: every mechanic the
spec relies on is discoverable from the repository, so no note qualified.

**Review team.** `han-core:junior-developer`, `han-core:user-experience-designer`, `han-core:edge-case-explorer`.
Feature size: medium. Every finding below was resolved from evidence; none required escalating to the operator.

**Merged records.** Several findings arrived from two reviewers in different words and are recorded once, carrying each
reviewer's own identifier.

## Major findings

### F1: The explanation is required in full even where two of its three answers are certain

- **Agent:** han-core:junior-developer, han-core:user-experience-designer
- **Reviewer identifiers:** JD-009, UX-008
- **Finding:** `Category: YAGNI candidate`, simpler-version available. The work item asks for "a required plain-language
  line"; the draft turned that into three required components with no bound. On a finding whose failure is certain and
  unconditional, the preconditions and likelihood both collapse to "always", and printing them at length is the
  symmetry pattern the YAGNI rule names. It also compounds the length pressure raised in F4 and F12.
- **Resolution:** Accepted. The explanation must answer all three questions; it does not print three fixed slots, and an
  answer not in doubt is a clause rather than a sentence. The requirement itself was not made optional, which would
  reintroduce the original defect.
- **Resolved by:** evidence
- **Affected decisions:** D1
- **Changed in spec:** Primary Flow; Edge Cases and Failure Modes

### F2: Security findings were left unclassified against the new rules

- **Agent:** han-core:junior-developer, han-core:user-experience-designer
- **Reviewer identifiers:** JD-005, UX-003
- **Finding:** Security findings are corrective, are deliberately exempt from the pass that lowers severity for
  unreachable failure modes, and sit in their own section that already ends with a remediation note. The draft's rules
  named critical, warning, and suggestion findings and said nothing about them, so two reasonable implementations would
  produce different reports. Both reviewers observed that a security finding is the one a non-implementer can least
  evaluate unaided.
- **Resolution:** Settled as a new decision. Security findings carry the plain-language explanation on the same terms as
  every other finding a reader is expected to act on. They do not gain a separately-labelled fix route, because their
  section already carries remediation content and a second answer to the same question would collide with it.
- **Resolved by:** evidence
- **Affected decisions:** D15 (new), D2, D12
- **Changed in spec:** Primary Flow

### F3: The specification used vocabulary its own reader cannot resolve

- **Agent:** han-core:user-experience-designer, han-core:junior-developer
- **Reviewer identifiers:** UX-003, JD-010
- **Finding:** "Corrective", "advisory", and "register" are terms the specification coined or borrowed and never
  explained, and none of them appears in a report a person reads. The classes a report shows are critical, warning,
  suggestion, security, and the advisory class. This is the specification failing the exact rule it is writing in D10.
- **Resolution:** Accepted. The specification now states the mapping in the reader's own vocabulary, uses "a finding the
  reader is expected to act on" in place of the coined shorthand, and records in D2 that both skills use the report's
  vocabulary rather than this document's.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Changed in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes; User Interactions; Coordinations

### F4: The complaint about visual weight was answered with more words at the same weight

- **Agent:** han-core:user-experience-designer
- **Reviewer identifiers:** UX-001, UX-002
- **Finding:** The sharpest finding of the round. The originating complaint is comparative: a probable no-op "read as a
  behavior change at the same visual weight as the two findings beside it". The draft's answer was additive. The finding
  kept its severity, its position, and its summary row, and gained a paragraph, so a person triaging thirty findings had
  to read the new explanation on every finding to discover which ones did not need reading. The report's only index, its
  summary table, gained nothing while the body it indexes roughly doubled.
- **Unverified:** rests in part on a density estimate the reviewer could not confirm against a rendered report, because
  no example output or visual material was supplied to this run. The structural half of the claim was verified directly:
  the draft did not mention the summary table anywhere.
- **Resolution:** Accepted, in the form the reviewer proposed across its two findings. A new decision puts the
  may-never-fire cue on the finding's opening line and in its summary row, and the fix route in the summary row beside
  the brief description, so triage happens before the reading rather than after it. The two halves rest on different
  evidence and D16 records which is which: the cue answers the originating complaint directly, and the route in the row
  rests on the second finding plus the work item's record of the question being asked after every review. The severity
  scheme, the row order, and the finding identifiers are untouched, and are now named in Out of Scope.
- **Resolved by:** evidence
- **Affected decisions:** D16 (new), D1, D12
- **Changed in spec:** Outcome; Primary Flow; Alternate Flows and States; User Interactions; Out of Scope

### F5: The naming fix did not cover the collision its own evidence describes

- **Agent:** han-core:junior-developer, han-core:edge-case-explorer
- **Reviewer identifiers:** JD-003, EC1
- **Finding:** Two parts. First, the session quoted as evidence for naming the report from the branch is a person
  re-reviewing the same branch, and the draft had no behavior for a report already existing at the derived name, so a
  report someone was working as a queue could be silently destroyed. Second, the draft folded the two review modes that
  have no branch diff into one fallback that fits neither: one of them has a branch name that may be the default branch
  and therefore distinguishes nothing, and the other can have a multi-file scope with no single name.
- **Resolution:** Both accepted. The run replaces an existing report and names the replaced report in its closing
  message. A branch name that does not distinguish the run is not used; the report is named from the single file,
  directory, or symbol reviewed, or the common parent of the reviewed files.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Changed in spec:** Edge Cases and Failure Modes

### F6: A review whose only findings are advisory had no defined closing message

- **Agent:** han-core:edge-case-explorer
- **Reviewer identifiers:** EC4
- **Finding:** Rated the reviewer's highest-priority gap. The advisory pass runs on every change regardless of size, so
  a run with no corrective findings and some advisory ones is ordinary rather than exotic. The draft's rules did not
  compose: the "finds nothing" row said the message reports approval, while the report body would list advisory items
  the message never mentioned.
- **Resolution:** Accepted. The recommendation stays approval, because advisory findings never block a merge. The
  message reports the count a person must act on as zero and names the advisory count separately, so nobody is told "no
  findings" about a report whose body lists items.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Changed in spec:** Edge Cases and Failure Modes

### F7: A destination that cannot be written had no behavior, and the spec claimed no new error states

- **Agent:** han-core:edge-case-explorer, han-core:user-experience-designer
- **Reviewer identifiers:** EC2, UX-010
- **Finding:** The draft covered a configured destination that points outside the working directory and not one that
  cannot be written: absent, read-only, or out of space. The canonical configuration rule covers configuration that is
  unusable as configuration, not a directory absent on disk. Meanwhile the draft asserted "Error states: None new",
  which forecloses the case rather than answering it. Without a stated fallback the run could report a path to a file
  that does not exist, which is the same class of wasted turn this feature exists to remove.
- **Resolution:** Accepted. The run writes to the unconfigured default and says so in its closing message, naming the
  destination it could not use. The run is not abandoned, because everything it produced is finished by the time it
  writes. The "no new error states" claim was replaced with the one error state the feature actually introduces.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Changed in spec:** Edge Cases and Failure Modes; User Interactions

### F8: A configured destination inside the repository conflicted with the overview's own commitment

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-006
- **Finding:** D5's rationale leans on the overview's commitment not to be committed as the reason for keeping its
  out-of-repository default, then honors a configured destination that may well be inside the repository, and says
  nothing about the tension.
- **Resolution:** Accepted and stated. Configuration wins and the run says nothing, which is the treatment the canonical
  configuration rule already gives a destination outside the working directory. The commitment governs the skill's own
  default, not what a person configures.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Changed in spec:** Edge Cases and Failure Modes

### F9: The widest-reaching change in the feature was visible only in a table cell

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-004
- **Finding:** The scope statements frame this as a two-skill change while the coordination table commits every document
  Han produces, through a standard many skills source. Anyone sizing implementation from the Outcome would under-size
  it, and nothing said whether the other documents are checked.
- **Resolution:** Accepted. The reach is now stated in the Outcome as a paragraph of its own, and Out of Scope says
  plainly that auditing the documents that inherit the rule is not part of this work. The placement itself was the
  operator's decision and was not reopened.
- **Resolved by:** evidence
- **Affected decisions:** D10
- **Changed in spec:** Outcome; Out of Scope

### F10: Nothing confirmed the new required content actually appears

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-007
- **Finding:** Only the diagram rule carried a stated check. The explanation, the fix route, the ordered starting points,
  the closing restatement's constraints, and the extended glosses all carried the word "required" and nothing checking
  it. A requirement with nothing checking it is a preference, and the failure mode is silent: the run produces today's
  output and nobody notices.
- **Resolution:** Accepted as a new decision. Each skill checks its own output before presenting, in the place each
  already has for a check like this, and fixes a failure before presenting. A separate verification pass was rejected
  under the simpler-version test. D9's existing diagram check was the model for where a check belongs; D9's own text was
  not changed.
- **Resolved by:** evidence
- **Affected decisions:** D17 (new)
- **Changed in spec:** Primary Flow

### F11: The explanation was specified as republished reasoning the review does not actually hold

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-001
- **Finding:** Rated a decision-blocker. The draft said the explanation states reasoning the review already worked out.
  The pass it cited matches a fixed list of phrases in the producing specialist's own words and says of itself that the
  phrase list is its only signal, so it produces reasoning worth publishing on the findings it matches and nothing at
  all on the rest. The draft therefore assumed analysis that does not exist, and if the writer must derive it, that
  looked like it crossed the line Out of Scope draws around changing how findings are challenged.
- **Unverified:** the reviewer could not read the session transcripts the work item quotes, because they are not in this
  repository, so the claim about what those sessions wanted rests on the work item's own verbatim quotes. The core of
  the finding was verified directly against the skill definition and stands on its own.
- **Resolution:** Accepted, and the rationale corrected rather than the behavior changed. The explanation publishes the
  reasoning where it exists and derives the answers from the finding's own evidence where it does not. Deriving them is
  writing work and never feeds back into the finding's severity, which is now stated in the decision and in Out of
  Scope. Restricting the explanation to findings the phrase gate matched was rejected: that is not the same population
  as the findings a reader cannot judge.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Changed in spec:** Primary Flow; Out of Scope

### F13: Nothing fixed the order of the two explanations inside a finding

- **Agent:** han-core:user-experience-designer
- **Reviewer identifiers:** UX-004
- **Finding:** The draft accepted a main-point-first argument for the closing message and did not make the same argument
  where the density actually landed. The reader the new explanation is written for would have to read past prose
  addressed to someone else to reach their own, and the order would vary run to run.
- **Resolution:** Accepted. The plain-language explanation leads the finding; the existing register follows it.
- **Resolved by:** evidence
- **Affected decisions:** D1
- **Changed in spec:** Primary Flow

### F14: Two plain-language restatements of the same thing, with no stated relationship

- **Agent:** han-core:user-experience-designer
- **Reviewer identifiers:** UX-006
- **Finding:** The overview's closing document paragraph and its closing terminal message both restate why the code
  exists, both drafted against the same standard, with nothing saying whether one reuses the other. Left unstated the
  two texts drift and the reader learns to distrust the shorter one. The reviewer also noted that the person's next
  action is to paste plain language somewhere, and pasting from the terminal is the cheaper path.
- **Resolution:** Accepted, in the simpler form the reviewer proposed. The document's closing sentences are the
  canonical text and the closing message carries them rather than writing its own version.
- **Resolved by:** evidence
- **Affected decisions:** D11
- **Changed in spec:** Primary Flow; User Interactions

### F15: The example-call rule belongs to the entry point, not the target

- **Agent:** han-core:user-experience-designer, han-core:edge-case-explorer
- **Reviewer identifiers:** UX-007, EC6
- **Finding:** The draft treated "interface" and "flow" as exclusive properties of a target. The session the requirement
  came from was not exclusive: the person asked which file to open first to trace a path, and what an actual call would
  look like, about the same target. Directory and change-set targets routinely contain both.
- **Resolution:** Accepted. The rule attaches to the entry point: any starting point that is an interface other code
  calls carries one example call, and flow entry points do not. This covers the mixed case with no rule for it.
- **Resolved by:** evidence
- **Affected decisions:** D13
- **Changed in spec:** Primary Flow; Edge Cases and Failure Modes

### F16: A contradicted reason and an unrecoverable reason were collapsed into one flow

- **Agent:** han-core:edge-case-explorer
- **Reviewer identifiers:** EC5
- **Finding:** Saying the code does not support a stated reason is a checked claim. Finding no evidence either way is a
  different state, and the overview already handles it by marking the reason as inferred. The draft's alternate flow
  read as if every reason mismatch were the first case, which risks the overview asserting a contradiction it never
  found — a stronger claim than its evidence supports, and the exact failure the skill's accuracy commitment exists to
  prevent.
- **Resolution:** Accepted. The alternate flow's entry condition now requires that the overview checked and found the
  contradiction, and the flow carries an explicit statement that a reason the code says nothing about is the other case
  and stays there.
- **Resolved by:** evidence
- **Affected decisions:** D14
- **Changed in spec:** Alternate Flows and States

### F19: The Open Items section was omitted while the summary asserted none

- **Agent:** han-core:junior-developer
- **Reviewer identifiers:** JD-008
- **Finding:** The draft claimed zero open items while two summary fields were explicitly incomplete and four of the
  reviewer's own findings named decisions implementation could not make on its own. The count is what a downstream
  planning run reads to decide whether it can proceed.
- **Unverified:** the reviewer noted it could not see the other reviewers' findings, because this record was unpopulated
  when it ran, so some of its open questions might already be raised elsewhere. They were: all four were resolved in
  this pass.
- **Resolution:** Accepted. Every question the reviewer raised was settled from evidence in this pass and is recorded
  above. One genuine open item remains, and the section now carries it with what would resolve it and whether it blocks
  implementation.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Changed in spec:** Open Items; Summary

### F20: Concurrent runs writing to one destination

- **Agent:** han-core:edge-case-explorer
- **Reviewer identifiers:** EC3
- **Finding:** Naming the report from the branch means two people reviewing the same branch at once produce the same
  filename in the same configured directory. The reviewer flagged this for awareness rather than recommending new
  behavior, and noted its own evidence-test failure: nothing in the corpus reports it.
- **Resolution:** Deferred under the YAGNI rule with a reopening trigger, in the spec's deferral section. The reviewer's
  own recommendation was that one line beats silence, which the deferral supplies.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Changed in spec:** Deferred (YAGNI)

### F21: Counting conditional findings in the review's closing message

- **Agent:** han-core:user-experience-designer
- **Reviewer identifiers:** UX-005
- **Finding:** Severity counts remain the closing message's whole triage signal, while the feature itself establishes
  that a finding at any severity may never fire. The person decides whether to open the report on a number the
  specification just qualified.
- **Resolution:** Deferred with a reopening trigger, on the reviewer's own recommendation and on the simpler-version
  test: F4's resolution already puts the fact in the surface a person triages from, and a second signal for the same
  fact before the first has been seen in use is not yet earned.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Changed in spec:** Deferred (YAGNI)

## Minor edits

- F12: The trade between per-finding growth and the work item's own length score was never recorded, so a reader could
  not tell a considered trade from an oversight — han-core:junior-developer — recorded in D1 rather than the spec, plus
  an open item.
- F17: The edge-case row for a configured location outside the working directory restated a rule the canonical
  configuration rule already owns, creating a second home that can drift — han-core:user-experience-designer — row
  removed from Edge Cases and Failure Modes.
- F18: Hardcoded suite-wide skill counts, against the repository's count-free convention — han-core:junior-developer —
  rephrased without the count in Cut for Scope, and in the evidence of D5 and D10, which counted the skills consuming
  the configured output location and the skills sourcing the shared writing standard.

## Unaudited evidence classes

- The session transcripts the work item quotes, supporting D1, D3, D5, D6, D7, D8, D9, D11, D12, D13, and D14. No
  reviewer received them, because they are session artifacts outside this repository. Every quotation used as evidence
  comes from the work item's own verbatim text, which two reviewers independently read from the live issue and found to
  match the boundary record.
- A rendered example report or overview under the new rules, bearing on F4. No reviewer received one, because none
  exists yet. This is what open item OI-1 exists to resolve.
- The three reviewers' reports in their own words, bearing on every record above. Synthesis received them condensed
  rather than verbatim, because the three together run several times the length of these artifacts. Attribution in this
  record was therefore checked against the merged reviewer identifiers rather than against each reviewer's wording; a
  claim that could only be settled by a reviewer's exact phrasing is not settled here.

## Escalation register

### E1: Whether the extended gloss rule binds every Han document or only the overview

- **Answer:** "go with first" — put it in Han's shared writing standard, so every Han document gains the rule and the
  agent that rewrites finished drafts enforces it.
- **Landed in:** [D10](decision-log.md#d10-where-the-extended-gloss-rule-lives), and the Outcome, Primary Flow,
  Coordinations, and Out of Scope sections of the specification.
