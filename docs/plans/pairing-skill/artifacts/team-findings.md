# Team Findings: pairing

This file records every finding raised by the review team for `pairing`, and how each was resolved. Behavioral
outcomes live in [../feature-specification.md](../feature-specification.md); the decisions those findings affected live in
[decision-log.md](decision-log.md). No `feature-technical-notes.md` was created for this feature, because no mechanic
qualified as load-bearing and not discoverable from the repository.

Three reviewers ran in parallel: `han-core:junior-developer` over the whole artifact set, `han-core:user-experience-designer`
over the interaction model, and `han-core:information-architect` over routing, placement, and documentation surfaces.
Several findings were raised by two reviewers independently and are merged into one record here, carrying both original
identifiers.

## Major findings

### F1: The guard against nodding through fired after the choice it was meant to guard

- **Agent:** junior-developer, user-experience-designer
- **Reviewer identifiers:** JD-004, UX-008
- **Finding:** The ask sat at the stop, which comes after the piece is built. Both studies behind it work by having the
  person commit before the assistant's answer exists. With the work already produced, the ask is retrospective: it buys
  the measured satisfaction cost and none of the measured benefit. The junior developer traced this to the reversibility
  framework, which prescribes deliberate review before an irreversible choice, not after.
- **Resolution:** The ask moved ahead of the build, for pieces the plan marked as carrying a hard-to-reverse choice. The
  operator's answer about frequency is untouched; only the ordering changed.
- **Resolved by:** evidence
- **Affected decisions:** D7, D14
- **Changed in spec:** Primary Flow

### F2: A stop could demand a judgment with no accepted way to decline

- **Agent:** user-experience-designer
- **Reviewer identifiers:** UX-007
- **Finding:** Nothing said whether "I don't know" or "just show me" was an acceptable answer. The study behind the ask
  found its benefit concentrated in people already inclined toward effortful thinking, so a mandatory guess taxes the
  fatigued, the second-language, and the newly-arrived reader hardest while returning them the least. Without an accepted
  non-answer the friction becomes a gate, and the rational response to a gate is to leave the mode.
- **Resolution:** Declining is now a first-class answer that advances the stop unchanged.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Changed in spec:** Primary Flow, User Interactions

### F3: The reveal after the ask was unspecified, and two of its likely shapes break the design

- **Agent:** user-experience-designer
- **Reviewer identifiers:** UX-007
- **Finding:** The specification ended at the ask. If the reveal grades the guess, the stop becomes a quiz that corrects
  you at the highest-stakes moment in the session, and you learn to answer noncommittally. If it defends a divergence, it
  leads with the fluent case that D6 rules out on evidence, at the stop where over-reliance costs most.
- **Resolution:** The reveal presents the work in the same form as any other stop. It does not restate your read, score
  it, or defend a divergence from it.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Changed in spec:** Primary Flow

### F4: The reversibility judgment was silent and uncontestable

- **Agent:** user-experience-designer, junior-developer
- **Reviewer identifiers:** UX-008, JD-004
- **Finding:** No test said what "expensive to walk back" meant, nothing disclosed the call, and nothing let the person
  overturn it. The framework it rests on treats reversibility as an explicit shared classification whose value is in being
  visible and arguable. Unannounced, the friction is unpredictable, and the promise that it fires only where warranted is
  unverifiable from the person's seat.
- **Resolution:** The plan proposed before work starts names which pieces it expects to carry such a choice, making the
  call contestable at plan time.
- **Resolved by:** evidence
- **Affected decisions:** D14
- **Changed in spec:** Primary Flow

### F5: The record governing every later piece was one the person could never read

- **Agent:** user-experience-designer, junior-developer
- **Reviewer identifiers:** UX-006, JD-013
- **Finding:** The record was written, read by the mode, and survived compaction, but nothing said the person could read
  it. A misrecorded correction would then govern the rest of the session and surface only as work that feels subtly wrong.
  That is the mid-context recall failure the record exists to prevent, imposed on the person instead.
- **Resolution:** The record is readable on request, and when the mode applies a recorded entry to a later piece it names
  which entry it applied.
- **Resolved by:** evidence
- **Affected decisions:** D8
- **Changed in spec:** Primary Flow, User Interactions, Coordinations

### F6: Contradiction detection was the expensive way to reach a cheap outcome

- **Agent:** user-experience-designer, junior-developer
- **Reviewer identifiers:** UX-016, JD-016
- **Finding:** `Category: YAGNI candidate`. No user-described need, incident, or measurement supported it, and it was the
  most expensive behavior proposed for this mode: a semantic comparison of every new remark against the whole record, at
  every stop. A false positive costs a turn defending feedback never contradicted; a false negative protects nothing.
- **Resolution:** Deferred with a reopening trigger. F5's entry attribution satisfies the same concern with no detection
  capability and no false positives, and the person catches the conflict with the entry in front of them.
- **Resolved by:** evidence
- **Affected decisions:** D8
- **Changed in spec:** Edge Cases and Failure Modes, Deferred (YAGNI)

### F7: The four kinds were not mutually exclusive and nothing broke a tie

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-003
- **Finding:** Drafting a decision record produces a decision and prose. The operator's own prose example was described by
  the operator as open-ended, so a single example spanned two kinds. Everything downstream keys off the sort, so two runs
  on the same request could sort differently and produce different loops. The suite's own precedent is to name the test
  rather than say the mode identifies the answer.
- **Resolution:** An ordered test with a first-match rule, so the order is the tie-break.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Changed in spec:** Primary Flow

### F8: The sort was never disclosed, so its premise could not be corrected

- **Agent:** user-experience-designer
- **Reviewer identifiers:** UX-009
- **Finding:** The sort is the largest single determinant of the experience, setting how often the person is interrupted
  and what they review. A proposal is correctable only if the person can see it. Someone whose design document sorted as
  open-ended rather than prose would see a plan they vaguely dislike with no vocabulary for what is wrong.
- **Resolution:** The proposed plan names which kind the work sorted into.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Changed in spec:** Primary Flow

### F9: The fourth kind changed no behavior

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-015
- **Finding:** `Category: YAGNI candidate`, named anti-pattern symmetry. The open-ended branch produced "whatever the plan
  named," which is what the plan does regardless of kind. A four-way sort with a no-op fourth branch makes the sort harder
  for no behavior change, and later skills would copy the pattern.
- **Resolution:** Collapsed to three tests plus a fall-through.
- **Resolved by:** evidence
- **Affected decisions:** D3, D13
- **Changed in spec:** Primary Flow

### F10: The mode's own founding example routed to a thinner result

- **Agent:** information-architect
- **Reviewer identifiers:** IA-003
- **Finding:** Pairing on an API design is one of the operator's three founding examples, and the skill covering it was
  given no flag. The request therefore sorted past the skill-backed branch into decision work, and the mode would build its
  own decision loop beside a skill that already runs discovery, an options document, a question round, and an adversarial
  validation round. No description clause fixes it, because there was no paired variant to delegate to. Notably, the
  decision to propose rather than ask cites that same skill as its precedent without noticing it is also a competitor.
- **Resolution:** Escalated. The operator gave that skill the flag, which widens the test behind the original survey. The
  re-survey under the wider test is recorded as an open item.
- **Resolved by:** user input
- **Affected decisions:** D10
- **Changed in spec:** Actors and Triggers, Alternate Flows and States, Coordinations, Open Items

### F11: The plugin placement closed a dependency cycle and broke a documented install

- **Agent:** junior-developer, information-architect
- **Reviewer identifiers:** JD-001, JD-014, IA-007, IA-008
- **Finding:** `han-coding` already depends on `han-core`, so a `han-core` skill requiring `han-coding` closes a cycle, and
  `han-core`'s stated invariant is that it depends on no other Han plugin. The placement was argued entirely on where the
  skill reads right and never checked for whether it builds. Separately, the plugin index offers an install described as
  having only the shared agents and project discovery, under which two of the three coordinations do not exist and no
  behavior was specified. The information architect added that the plugin's organizing principle, stated identically in its
  front door, the plugin index, and three manifests, is shared infrastructure other plugins consume, which a user-facing
  working mode is not.
- **Resolution:** Verified directly against the plugin manifests before escalating; the cycle is real. Escalated. The
  operator kept the placement and made the backing skills optional, which keeps the invariant literally true because
  nothing is required. The relabeling the information architect identified became part of the work.
- **Resolved by:** user input
- **Affected decisions:** D12, D21
- **Changed in spec:** Actors and Triggers, Edge Cases and Failure Modes, What Else Has To Change When This Ships

### F12: The pre-work plan promised a list of pieces that did not exist yet

- **Agent:** user-experience-designer
- **Reviewer identifiers:** UX-010
- **Finding:** For skill-backed work the pieces are the backing skill's own units, and both backing skills build their
  lists partway into their own runs and report them without gating. At the moment the pre-work plan is made, the list does
  not exist. The promise was therefore either unmet or a silent change to a backing skill's gating, which D2 forbids, and
  the specification did not say which. This lands on the operator's own first named example.
- **Resolution:** The promise splits by kind. For skill-backed work the pre-work plan names the skill, its unit, and the
  reason; the skill's own list becomes the plan of pieces at the first stop, where it can still be redirected.
- **Resolved by:** evidence
- **Affected decisions:** D15
- **Changed in spec:** Primary Flow

### F13: No stop said where the person was in the plan

- **Agent:** user-experience-designer
- **Reviewer identifiers:** UX-002
- **Finding:** Both commitments were local to the piece in hand plus a one-step lookahead. Neither named the current
  position, what remained, or the plan as it stands after a renegotiation. Two conventions already in this suite carry
  exactly this, and the backing skills carry it too by crossing items off a list. Without it the person cannot decide
  whether they have the attention for two more pieces.
- **Resolution:** Each stop names which piece this is against the plan and what remains, and the plan is available on
  request.
- **Resolved by:** evidence
- **Affected decisions:** D16
- **Changed in spec:** Primary Flow, User Interactions

### F14: The compaction row restored the assistant's continuity and not the person's

- **Agent:** user-experience-designer, junior-developer
- **Reviewer identifiers:** UX-015, JD-007
- **Finding:** The row addressed only the record surviving. The person returns to a terminal where the last stop has
  scrolled away and must reconstruct which piece was in hand. The mode's own evidence measures that cost at an average of
  23 minutes and 15 seconds to resume at full focus. Continuity solved for the assistant and left unsolved for the person
  inverts the premise that the person is in the lead.
- **Resolution:** On resuming, the mode restates the piece in hand and its position before continuing.
- **Resolved by:** evidence
- **Affected decisions:** D16
- **Changed in spec:** Edge Cases and Failure Modes

### F15: The specification claimed a guarantee its own research says nothing can provide

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-006
- **Finding:** "Nothing further is built until you respond" was stated as a hard guarantee. The collaborative-mode research
  is explicit that every option relies on the assistant following an instruction, and options differ in how much weight
  the instruction carries rather than in whether it can be enforced. No behavior was specified for an overrun, which is
  the most likely real failure of the feature, and the tendency is real in the very skill being flagged.
- **Resolution:** Softened to a directive, with an edge-case row specifying that an overrun is named, its unreviewed pieces
  listed, and a walk-back offered.
- **Resolved by:** evidence
- **Affected decisions:** D17
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F16: Nothing bounded replanning, and the specification did not say that was deliberate

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-021
- **Finding:** With the plan reopenable on any out-of-piece feedback, "the plan is finished" is not a fixed target and
  ending is left entirely to the person. That may be right, but unstated it reads as a gap.
- **Resolution:** Stated as deliberate, beside the entry explaining why a computed stop rule does not transfer here.
- **Resolved by:** evidence
- **Affected decisions:** D18
- **Changed in spec:** Primary Flow, Out of Scope

### F17: The loop had two gears and the only gear change was one-way

- **Agent:** user-experience-designer
- **Reviewer identifiers:** UX-001
- **Finding:** The person at their eleventh stop, tired but not finished reviewing, could continue at full ceremony or turn
  review off for the remainder. That is the shape the mode's own evidence warns about, since review quality decays into
  rubber-stamping past a volume threshold and the only escape offered is to stop reviewing entirely. The walkthrough
  convention the specification claims to inherit already carries an exception for an explicit request for several steps,
  and it was dropped in translation. The switch to unattended finishing also had no committed acknowledgement.
- **Resolution:** An explicit request for more than one piece is honored as asked and the loop returns to its normal pace
  at the following stop. The switch to unattended finishing is acknowledged in the turn it is requested, naming what will
  now go unreviewed.
- **Resolved by:** evidence
- **Affected decisions:** D19
- **Changed in spec:** Alternate Flows and States, Edge Cases and Failure Modes, User Interactions

### F18: The invocation contract named two mechanisms and settled neither

- **Agent:** information-architect
- **Reviewer identifiers:** IA-001
- **Finding:** One bullet named both a slash command, where everything after it is argument text and no competition occurs,
  and open phrasing, where the sentence is matched against every available skill. Whether every collision below fires at
  all depends on which is supported, and an implementer could not tell.
- **Resolution:** Split into two named entry paths, with both supported and their different consequences stated.
- **Resolved by:** evidence
- **Affected decisions:** D20
- **Changed in spec:** Actors and Triggers

### F19: Every quoted trigger phrase contained another skill's strongest trigger word

- **Agent:** information-architect
- **Reviewer identifiers:** IA-002
- **Finding:** The mode's own example phrasings name `tdd` and `refactor` directly, and neither of those skills' routing
  text mentions pairing, collaboration, or stopping for review. Whichever answers, one of two failures follows: the person
  gets the uninterrupted run this mode exists to replace, or gets stopped at every step when they wanted a straight run.
  The deeper problem is that every boundary in the suite is exclusive, and the correct relationship here is delegating,
  which the exclusive form cannot express. The suite's own guidance calls one-way disambiguation a gap requests fall
  through; here it was zero-way.
- **Resolution:** The specification now commits both sides to saying it, and carries a table of which skill answers for
  which kind of phrasing. The routing surface is named as a coordination in its own right.
- **Resolved by:** evidence
- **Affected decisions:** D20
- **Changed in spec:** Which Skill Answers When You Say It In Your Own Words, Coordinations

### F20: The pacing skill shares the entire vocabulary and was absent from the coordinations

- **Agent:** information-architect
- **Reviewer identifiers:** IA-004
- **Finding:** Every load-bearing phrase in the User Interactions section already belongs to `code-walkthrough`'s trigger
  vocabulary. The specification acknowledged the shared convention in prose and then omitted that skill from the
  coordination table. The real distinction was available and stated nowhere: that skill paces you through work that already
  exists and writes nothing, while this mode builds work while pacing you through it. A person mid-branch asking to be
  walked through as it gets built could get a silent no-op.
- **Resolution:** Added as a routing coordination with no runtime handoff, and the produced-versus-existing distinction is
  now committed on both sides.
- **Resolved by:** evidence
- **Affected decisions:** D20
- **Changed in spec:** Which Skill Answers When You Say It In Your Own Words, Coordinations

### F21: Requests to understand something would receive a plan to build things

- **Agent:** information-architect
- **Reviewer identifiers:** IA-005
- **Finding:** All the kinds presupposed a produced artifact. "Help me understand this module" produces understanding, so
  it fell through to open-ended and the mode would propose a plan of pieces to build. It sorts cleanly, so the too-vague
  guard never trips. The backing research addresses producing and never explanation.
- **Resolution:** An edge-case row stating this is not the mode's work and naming where it goes. A fifth kind was not added,
  because no evidence defines a unit for it and adding one would be speculative.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F22: The specification named no documentation surface, specifying the skill as an orphan

- **Agent:** information-architect
- **Reviewer identifiers:** IA-009
- **Finding:** The contribution guide enumerates the stops a new skill must make and the specification named none, and the
  coverage rule requires the long-form document to land in the same pull request rather than as a follow-up. Two further
  groups become inaccurate on the day this ships: the plugin's identity in its front door, index entry, and manifests, and
  the operator manuals plus routing text of the skills gaining the flag.
- **Resolution:** A specification section naming the three groups, plus the note that the mode takes no size argument so
  the sizing documentation does not apply.
- **Resolved by:** evidence
- **Affected decisions:** D21
- **Changed in spec:** What Else Has To Change When This Ships

### F23: Confidence caveats sat only in the artifact that declares itself non-normative

- **Agent:** junior-developer, information-architect
- **Reviewer identifiers:** JD-011, JD-005, JD-010, IA-010
- **Finding:** The research rates staging by concern High, the per-kind units Medium, and open-ended work Low, and says
  that if the prose reconciliation is wrong then prose work has no evidenced unit at all. The specification presented all
  rows at equal weight, and the decision log that carries the caveats states in its own opening that behavior lives in the
  specification. An implementation plan reading the specification alone would treat the prose ladder and the
  skill-backed unit as equally settled. The nodding-through row separately attributed the whole guard to how a stop is
  presented, which the research does not support: that is a trend over time, and no study compares degradation with and
  without an objective gate.
- **Resolution:** A confidence section in the specification naming which parts are High, Medium, and Low. The
  nodding-through row's rationale was corrected to say what the mode declines to do rather than claiming the guard works.
  The corrected row initially replaced the unsupported claim with a second one, that a run of silent approvals more
  likely signals a wish for a different pace than a lapse in care; synthesis removed it, because no evidence in either
  report speaks to what a run of approvals signals. The row now states only that the mode does not read approvals as a
  lapse in care and may offer the faster gear once.
- **Resolved by:** evidence
- **Affected decisions:** D13
- **Changed in spec:** How Confident Each Part of This Design Is, Edge Cases and Failure Modes

### F24: A plan reopening the person did not request had no way back

- **Agent:** user-experience-designer
- **Reviewer identifiers:** UX-005
- **Finding:** The mode, not the person, decides that a remark reaches outside the piece, and that determination replaces
  the plan the person agreed to. The stated exits were accept or change, neither of which is "keep the plan, treat that as
  a note for later." Someone thinking out loud, which is the working style this mode is built for, triggers a replan they
  did not ask for.
- **Resolution:** The mode names its reading before acting on it, and a third exit declines the reopening and records the
  feedback as scoped to later work.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Changed in spec:** Alternate Flows and States

### F25: The re-show after a fix said nothing about what changed

- **Agent:** user-experience-designer
- **Reviewer identifiers:** UX-003
- **Finding:** "Shown to you again" was the whole commitment. To confirm the correction landed and nothing else moved, the
  person had to re-read reviewed material and hold the first version in memory to compare. That works directly against the
  evidence behind presenting checkable claims, whose mechanism is lowering the cost of checking, and raises it at the
  moment the person is most invested.
- **Resolution:** The re-show names the correction it applied and what it touched before restating the piece, in prose so
  it reads aloud rather than depending on a side-by-side comparison.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Changed in spec:** Primary Flow

### F26: Ending the loop left in-flight work in an unstated state

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-020
- **Finding:** If a backing skill was mid-cycle when the person stopped, files are edited and possibly failing. The exit
  said nothing about whether the mode reports the state of the tree. The backing skills' own stop rules do report where
  things stand, but the loop's exit did not say it inherits that.
- **Resolution:** The exit report covers the state of any work a backing skill left mid-cycle, and names where the feedback
  record was written.
- **Resolved by:** evidence
- **Affected decisions:** D18
- **Changed in spec:** Alternate Flows and States

### F27: A multi-approach plan reliably trips a backing skill's own precondition

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-017
- **Finding:** The specification permits a request spanning approaches, such as sketching a shape and then building it
  test-first. One backing skill refuses to run alongside an in-flight test-driven loop. A plan sequencing them will hit
  that stop if the first loop is not fully closed, and the person experiences it as the mode contradicting its own plan.
  The reviewer noted it had read only the stop-rule regions of both skills rather than their full precondition sets.
- **Resolution:** The plan orders sequenced backing skills so each skill's own preconditions hold when its turn arrives.
- **Resolved by:** evidence
- **Affected decisions:** D11
- **Changed in spec:** Alternate Flows and States

### F34: The name broke the suite's own naming convention and under-scented for non-code work

- **Agent:** information-architect
- **Reviewer identifiers:** IA-006
- **Finding:** The name was an imperative sentence addressed to the assistant, where every other skill in the suite is
  named for an activity or an artifact, and the plugin-building guidance asks for a gerund process name with a stated
  heuristic the original name violated. Three costs followed: it set a precedent a future skill author would read as
  sanctioned, it carried pair-programming associations the mode does not meet, and someone scanning the skills index for
  help with prose would not stop at it.
- **Resolution:** Escalated after the review round closed, and the operator renamed the skill to `pairing`. "Pair with me
  on" stays as description wording, so nothing about how a person asks for the mode changed. The reviewer noted that
  routing matches on description rather than name, which is what made the rename free.
- **Resolved by:** user input
- **Affected decisions:** D23
- **Changed in spec:** the whole document, by rename; Open Items

## Minor edits

- F28: The vague-request re-ask posed a blank question, which the same specification rejects elsewhere; it now names what
  was ambiguous, offers candidate readings, and defines what happens if the answer is still not enough —
  user-experience-designer (UX-013) — Edge Cases and Failure Modes
- F29: "The reasoning is available" was an affordance nothing announced, so in a conversational surface it was functionally
  absent; the stop now says so in one line — user-experience-designer (UX-012) — Primary Flow
- F30: The ask posed an open question where the suite's convention gives named candidates; it now names the dimension the
  choice turns on, without supplying the answer, which would anchor the guess — user-experience-designer (UX-011) —
  Primary Flow
- F31: A coordination row described one component setting a value another reads rather than a behavior; restated as
  behavior — junior-developer, user-experience-designer (JD-022, UX-017) — Coordinations
- F32: A hardcoded skill count and plugin count in the boundary record violated the repository's count-free convention;
  both removed rather than corrected — junior-developer, information-architect (JD-018, IA-012) — scope-boundary.md
- F33: The summary reported zero open items while the review round had not run — junior-developer (JD-019) — Summary

## Unaudited evidence classes

- The two research reports backing this specification. The junior developer and the information architect read them under
  explicit authorization; the user-experience designer was authorized for the chunk-boundary report only, so no finding of
  theirs rests on the collaborative-mode report, and they said so. No reviewer independently re-verified the external web
  sources behind either report, which the reports themselves already flag as a limitation of their own validation.
- Claude Code's live skill-routing behavior. The information architect could not observe how a request naming both a slash
  command and a competing skill's trigger word actually routes, because no running session exists in this repository. Every
  routing finding therefore rests on reading the competing description text rather than on observed behavior, and the
  reviewer disclosed this on each affected finding. The suite's own documented probe would settle it before the skill
  ships.
- The full precondition sets of the backing skills. Two reviewers read only the stop-rule and unit-boundary regions
  returned by targeted search rather than those skills end to end, and both disclosed it. F27 rests on a partial read.

Per the unverified rule, no finding above carries build-blocking severity on the strength of an input nobody inspected.
F27's blocking status is limited accordingly.

## Escalation register

### E1: Which plugin should carry a pairing mode you would also use on a stakeholder email?

- **Answer:** `han-core`, invoked as `/han-core:pairing`. The operator chose it over keeping the originally-named
  `han-coding` home and over creating a new `han-collaboration` plugin.
- **Landed in:** [D12](decision-log.md#d12-the-skill-lives-in-han-core-and-its-backing-skills-are-optional), and the Actors
  and Triggers section of the specification.

### E2: When your feedback says the piece just built is wrong, does it get fixed now or become the next piece?

- **Answer:** Fixed now, then shown again before anything new is built. The operator chose this over deferring the
  correction to the next piece and over asking each time.
- **Landed in:** [D9](decision-log.md#d9-feedback-condemning-the-piece-in-hand-is-fixed-in-place-and-re-shown), plus the
  Primary Flow and Alternate Flows sections of the specification.

### E3: How much of the guard against nodding through do you want, given that it measurably annoys reviewers?

- **Answer:** Ask for the operator's own read first only at stops where a mistake is expensive to undo. The operator chose
  this over never asking and over asking at every stop.
- **Landed in:** [D7](decision-log.md#d7-the-mode-asks-for-your-read-first-only-where-a-mistake-is-expensive-to-undo),
  plus the Primary Flow and User Interactions sections of the specification.

### E4: The placement creates a dependency cycle and breaks a documented install. How should it resolve?

- **Answer:** Stay in `han-core` and treat the backing skills as optional. The operator chose this over a new
  `han-collaboration` plugin and over returning to `han-coding`.
- **Landed in:** [D12](decision-log.md#d12-the-skill-lives-in-han-core-and-its-backing-skills-are-optional) and
  [D21](decision-log.md#d21-the-surfaces-that-stop-being-accurate-are-part-of-this-work), plus the Edge Cases and What Else
  Has To Change sections of the specification.

### E5: Pairing on an API design would route past the skill that already covers it. What should happen?

- **Answer:** Give that skill the collaborative flag too. The operator chose this over routing to it unpaired and over
  letting the mode's own decision loop supersede it.
- **Landed in:** [D10](decision-log.md#d10-five-skills-gain-an-opt-in-collaborative-flag),
  plus the Actors and Triggers, Alternate Flows, Coordinations, and Open Items sections of the specification.

### E6: Where should the stopping and question-asking convention for this mode live?

- **Answer:** A new canonical rule file owned by `han-core`. The operator chose it over carrying the convention inline
  and over extending the existing escalation rule.
- **Landed in:** [D22](decision-log.md#d22-the-stopping-convention-is-a-canonical-rule-file-owned-by-han-core), plus the
  Open Items and What Else Has To Change sections of the specification.

### E7: When should the widened flag test be run against the rest of the suite?

- **Answer:** Now, before the implementation plan. The operator chose this over deferring it to the implementation plan
  and over closing the question at three skills.
- **Landed in:** the survey recorded in E8 below.

### E8: Two more skills qualify under the widened test. Should they get the flag?

- **Answer:** Flag both. The operator chose this over flagging `plan-implementation` alone and over keeping the mode at
  three skills. The survey covered every skill in the plugins the operator did not rule out;
  `iterative-plan-review` and `plan-implementation` were the only additions, and the reasons every other skill failed are
  recorded in D10.
- **Landed in:** [D10](decision-log.md#d10-five-skills-gain-an-opt-in-collaborative-flag), plus the Alternate Flows,
  Coordinations, and What Else Has To Change sections of the specification.

### E9: Does the skill keep the name pair-with-me?

- **Answer:** No. It is renamed to `pairing`, with "pair with me on" kept as description wording. The operator chose this
  over keeping the original name with a recorded exception and over a name describing the loop. This overrode the
  recommendation, which was to keep the original name.
- **Landed in:** [D23](decision-log.md#d23-the-skill-is-named-pairing-and-the-phrase-people-type-lives-in-its-description),
  the specification's Open Items section, and the name of this plan folder.
