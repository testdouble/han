# Research: Stopping Points for Collaborative Work That Is Not Code

What makes a good stopping point for human review when an assistant is doing collaborative work that is not code, and
who should decide where that point falls? Evidence mode: strict.

## Summary

Stop where the kind of feedback changes, not where a word count is hit. That is the one finding solid enough to build
on. It holds across professional editing bodies, two peer-reviewed studies of how writers revise, and design
practice in a separate field. Review the shape of the work before its surface, every time. Polish applied before the
shape is settled gets thrown away when the shape changes.

That gives a different unit for each kind of work. For a decision, the unit is one decision, presented with its context,
the options weighed, and what it commits you to. For written work, the unit is one rung of a fidelity ladder: the shape
first, then a rough draft, then the language. You get structural feedback while the work is still cheap to restructure,
and you never review the same thing twice for two different concerns. For code you already have the answer. For
genuinely open-ended work there is no established answer, and I found none, so the assistant should propose a plan and
let you change it.

One finding should change how the walkthrough itself is written. Explaining your reasoning to a reviewer does not
reliably make them more careful, and can make them less so. Explanations read as a signal of competence whether or not
their content holds up, and a polished explanation invites agreement. What does work is making claims cheap to check,
and getting the reviewer to form a view before they see the reasoning. So the walkthrough should hand you something to
check, not something to be convinced by.

Two smaller results are worth carrying. Who picks the stopping point barely matters for commitment, as long as the
reason for the choice is stated, so the assistant proposing a plan you can redirect is fine.

Feedback also belongs in a written record rather than in the assistant's memory of the conversation, which your suite
already has a convention for.

The gap: nobody has studied this exact situation. Every source describes humans reviewing a mostly-finished thing, or a
person using an assistant once. An assistant building something with you across many stops is not in the literature.

- **Confidence:** High for staging by concern, Medium for the per-kind units, Low for open-ended work

## Research Results

### Stop where the concern changes, not where the document divides

This is the best-evidenced finding in the whole report, and it comes from four independent directions.

Professional editing stages work by concern in a fixed order: structure first, then language and style, then grammar and
consistency, then typographical errors on a near-final proof. Two national professional bodies define the same stages in
the same order, one in the United States and one in the United Kingdom (A16, A17). Multiple practitioner editors give
the same reason for the order (A20).

Two peer-reviewed studies of how people revise back it up from a different angle. Inexperienced writers revise at the
word level, while experienced writers revise for meaning and structure first (A18, A19). That is genuine corroboration
rather than one claim repeated, because professional practice and academic research arrived at it separately.

The reason the order matters is concrete. Polishing a paragraph that a structural edit will delete is, in one editor's
words, "effort spent decorating rooms that are about to be knocked through" (A20).

The same principle shows up in design work, from sources with no connection to editing. Low-fidelity work draws
structural feedback while high-fidelity work draws only cosmetic feedback, and people are reluctant to criticize
something that looks finished (A13). An engineering leader writing about design proposals observed the same thing
independently: "the more polished a document looks, the softer reviews tend to be" (A12). Two unrelated fields reaching
the same conclusion is strong corroboration.

### The unit for a decision is one decision

For work that produces a decision rather than an artifact, the established unit is unambiguous. The originating source
for the architectural decision record states that "one ADR describes one significant decision" (A10). An independently
maintained community reference says the same thing in nearly identical words (A11). Both put it at one or two pages
with a fixed shape: the context, the decision, and its consequences.

How much review a decision deserves scales with how reversible it is. Amazon's framework separates decisions you can
walk back cheaply from ones you cannot, and prescribes fast review by a small group for the first and slow, wide review
for the second (A6).

Every decision-record template separates the problem, the options, and the chosen option into distinct sections, and
that convergence is well corroborated across at least four independent template families (A10, A11).

But **no source treats those three sections as three separate review checkpoints**. That is a real gap: they are
documented as parts of one document, written and reviewed together. Turning them into a review sequence is a
reasonable extension, not an established practice, and I am flagging it as such rather than dressing it up.

Published proposal processes offer less than you would hope. The Rust language's process gives no size guidance and no
rule for splitting a large proposal, and the same search of Python's process returned nothing either (A3). One
widely-cited account of design documents at Google gives concrete numbers: roughly ten to twenty pages for a large
one, one to three pages for a small one, with direction to split when a document outgrows itself. That figure comes
from one author's account (A8) [single-source].

### The unit for prose is one rung of a fidelity ladder

Reviewing prose section by section is the wrong cut. The editorial staging above operates on the whole manuscript per
pass, not on one chapter at a time.

That creates a problem this loop has to solve. Editorial staging assumes a finished draft already exists, because its
first pass reads the whole thing for structure. A loop that produces work in pieces cannot wait for a finished draft
before its first stop. Taken literally, the editorial unit would make the first chunk "write the entire draft," which is
no loop at all.

The resolution is to stage by fidelity rather than by pass over a finished artifact. Review the shape while it is still
a shape, then the rough draft, then the language. Two independent lines of evidence support this. A university writing
center states the timing rule directly: feedback on an outline or rough draft can still change foundational choices.
Feedback on a polished draft is limited to surface concerns, because the foundations are no longer practically
revisable (A22). Design practice reaches the same place from another direction, finding that low-fidelity work draws
structural feedback and high-fidelity work draws only cosmetic feedback (A13).

Staging by fidelity keeps what the editorial evidence establishes, which is the order of concerns, while
dropping the precondition that the whole draft exist first. Each rung is a chunk, and the concern reviewed at that rung
is set by the staging rule.

The competing pattern is worth naming because it is real. Amazon's narrative process caps a document at six pages, has
the group read it in silence, and discusses it as a whole. It is deliberately not circulated in pieces (A25)
[single-source], on the argument that reading parts in isolation produces worse structural feedback than reading the
connected whole. Reverse outlining sits in the same family, distilling each paragraph of a finished draft to its main
idea to check structure before any language work (A21). Both require the artifact to exist before review starts.

Writing workshops give one concrete size: two and a half to five thousand words per piece (A24) [single-source].

They also give a rule worth stealing. Two independent sources describe a named alternative to the standard workshop
that sequences feedback deliberately: what is working, then the author's own questions, then neutral questions, then
opinions only with permission (A23). That is the same structure-before-surface principle, applied inside a single
conversation rather than across separate passes.

### Explaining your reasoning can make the reviewer less careful

This is the finding that should change the design, and it is well corroborated by controlled studies.

Passive explanations do not reliably reduce over-reliance on an assistant's output, and sometimes increase it (A33).
Explanations act partly as a signal of competence, working on the reviewer's trust regardless of whether the content
holds up (A35). One study of five experiments with 731 participants found explanations reduce over-reliance only when
they lower the cost of checking the claim independently. Hard-to-parse explanations make things worse, because they
raise that cost (A32).

The one intervention that worked better than any explanation design was making the reviewer commit to their own
judgment before seeing the assistant's reasoning (A33). It cost reviewer satisfaction, which the study measured rather
than assumed.

One result cuts the other way and is worth keeping. A randomized trial of 108 reviewers found no significant anchoring
effect: reviewers shown a flawed early version revised their assessment once corrected material arrived (A36)
[single-source]. So showing your work early does not permanently fix someone's view.

Taken together: a walkthrough should hand the reviewer concrete, checkable claims rather than a fluent case, and should
not lead with the reasoning that makes the work sound right.

### Who picks the stopping point matters less than whether the reason is stated

Fifty years of goal-setting research says that when difficulty is held constant, goals someone helped set and goals
assigned to them produce statistically indistinguishable performance. An assigned goal reaches equivalent
commitment when it comes with a rationale (A30, A31). Participation's real effect is that people set themselves harder
targets.

That literature answers a narrower question than the one asked. It measures the commitment of the person doing the work,
not the care of the person reviewing it. **No study compares how carefully someone reviews at a checkpoint they
helped choose against one imposed on them.** That is a genuine gap, and the goal-setting evidence should not be read as
settling it.

### Review degrades without an objective gate, but nobody has measured how much

Habituation is corroborated. A systematic review found that reviewers of highly-but-imperfectly reliable systems show
measurable desensitization over time. Erroneous advice raised the risk of an incorrect decision by 26 percent
across four clinical studies (A29). Practitioner accounts name the same pattern for AI-written code and recommend
anchoring review in objective gates such as tests (A38, A39).

Survey data shows a gap between stated distrust and actual behavior. 96 percent of developers say they do not fully
trust AI-generated code, while only 48 percent consistently verify it before merging (A37) [single-source for the exact
figures, from a vendor selling code-quality tooling, though the direction is corroborated by an independently run
survey].

**No study compares degradation between artifacts with an objective pass-or-fail gate and artifacts without one.** The
automation-bias literature comes largely from aviation and clinical settings, which do have eventual objective outcomes,
so it does not isolate the missing-ground-truth variable. The reasoning that a failing test is exactly the kind of
salient failure signal that interrupts habituation is plausible and unevidenced, and I am not carrying it as a finding.

### Feedback belongs in a written record

No study tests written-versus-remembered feedback for this kind of work. The closest well-evidenced analogy is surgical:
teams using a written checklist missed about 6 percent of critical steps against about 23 percent when working from
memory, in simulated crisis scenarios (A41).

Professional editing implements exactly this with the style sheet, a running record of decisions and their reasons kept
so a decision does not have to be re-argued or misremembered later (A42). That is mature convention rather than measured
outcome.

### Stopping costs something, and the cost is measured

Knowledge workers take an average of 23 minutes and 15 seconds to return to a task at full focus after an interruption
(A40). That study is about general knowledge work, not about reviewing an assistant's output, so applying it here is
inference.

Two independent practitioner accounts describe review quality decaying into rubber-stamping past some volume threshold,
though neither identifies where that threshold sits (A43).

### Your own suite already runs three patterns

Han contains three proven approaches, and the differences between them are instructive.

**One unit per turn.** The walkthrough presents one step and ends the turn. The escalation rule allows one question per
turn while stating how many are pending. The API design skill surfaces open items one at a time, never batched, because
"each answer routinely settles or reshapes the ones behind it" (A44, A46, A48).

**Bounded rounds with a stop rule that is computed, not judged.** The plan-review skill runs review rounds capped by
size band and stops on a deterministic condition: two or fewer new findings and zero major ones (A53). Its sibling
aggregates each round into a claim ledger that groups findings by category and marks each one evidenced, anecdotal,
disputed, or unverified, then gates on that (A54). This is neither of the other two patterns. Review happens in batches,
but how many batches is decided by what the batches turn up rather than by a plan fixed in advance.

**Whole artifact, then review.** The documentation skill drafts the complete document and only then dispatches
reviewers, with its two operator questions confined to the opening step before any drafting (A51). The coding-standard
skill is close but not the same: it stops mid-draft to get approval for the file globs its standard will govern, and
will "not write the file until the user confirms or proposes a substitute" (A52). So one skill in this suite genuinely
runs stop-free after its opening, and one has a single mid-draft gate on a choice that is expensive to get wrong.

There is also an existing convention for carrying feedback forward: an escalation register recording each question as
asked, the answer, and where the answer landed (A47).

## Options to Consider

### O1: Stage by concern, with the unit set by the kind of work

- **What it is:** The boundary falls where the kind of feedback changes. One decision for decision work, one rung of a
  fidelity ladder for prose, one behavior or one named refactoring for code.
- **Trade-offs:** Rests on the strongest evidence in the report, with support from four independent directions. Two
  costs. It needs a different unit defined per kind of work, and for open-ended work no source defines one. The
  prose unit is a reconciliation rather than a direct reading. The editorial evidence establishes the order of concerns,
  but it assumes a finished draft. This option keeps that order and drops the precondition, on the strength of two
  further sources about when feedback can still change something (A13, A22).
- **Rests on:** (A10, A11, A13, A16, A17, A18, A19, A20, A22)
- **Evidence status:** corroborated for the concern order; the fidelity-ladder unit for prose is a reconciliation of
  A16 through A20 with A13 and A22, not a practice any single source documents

### O2: A negotiated chunk plan, proposed by the assistant and redirected by you

- **What it is:** Before work starts, the assistant proposes where it will stop and why. You accept or change it, and
  either side can renegotiate as the work reveals itself.
- **Trade-offs:** Goal-setting research says a stated rationale closes most of the gap between an imposed plan and a
  negotiated one (A30, A31). So a proposal you can change costs little and buys a cheap early correction. Your API
  design skill already runs this shape (A48). Against it: no evidence that negotiating a checkpoint makes anyone review
  more carefully at it, which is a real gap rather than a demonstrated weakness.
- **The alternative this option does not beat on evidence:** asking the person where to stop before proposing anything.
  The same research shows participation's real effect is that people set themselves harder targets (A30), which
  licenses asking first as well as proposing first. The reason to prefer proposing is practical rather than
  evidenced. A proposal gives the person something concrete to react to. A blank question at the start of a task
  asks them to plan work they have not seen yet. That is a judgment call, not a finding.
- **Rests on:** (A30, A31, A48)
- **Evidence status:** corroborated for the commitment claim, uncorroborated for the review-quality claim, and the
  choice over asking first is reasoned rather than evidenced

### O3: A bounded whole artifact, reviewed in one piece

- **What it is:** Cap the work at something short enough to review entire, then review all of it rather than parts.
- **Trade-offs:** Directly addresses the risk that reviewing parts gives good feedback on a piece while missing whether
  it fits. Amazon's six-page narrative is the documented instance, and two of your own skills already work this way
  (A25, A51, A52). Against it: one documented external instance only, and it needs a hard length cap that long-running
  work cannot honor.
- **Rests on:** (A25, A51, A52)
- **Evidence status:** single-source externally, corroborated by two in-repo skills

### O4: Fixed-cadence stops, decoupled from the work's shape

- **What it is:** Stop on a rhythm rather than at a content boundary, reviewing whatever exists at that point.
- **Trade-offs:** Two independent practitioner sources recommend frequent regular critique over one large review (A1,
  A2). It also sidesteps defining a unit at all, which is attractive for open-ended work. Against it: a cadence rule
  says nothing about what should be ready at each stop, so it needs pairing with a content rule. The sources describing
  it were describing visual design critique, not this. And the supporting consulting material is the weakest evidence
  in the report (A27, A28).
- **Rests on:** (A1, A2, A27, A28)
- **Evidence status:** corroborated for the cadence claim in its original domain, uncorroborated for transfer to this one

### O5: Scale the stop to how reversible the work is

- **What it is:** Stop and hand control back for choices that are expensive to undo. Keep going through ones you can
  walk back cheaply.
- **Trade-offs:** The best-corroborated guidance about decisions rather than artifacts (A6), and it directly answers the
  interruption cost, since it spends your attention where reversal is expensive (A40, A43). Against it: it calibrates
  how much scrutiny, not where the boundary falls, so it cannot stand alone.
- **Rests on:** (A6, A40, A43)
- **Evidence status:** corroborated

### O6: Build the walkthrough for checking, not for convincing

- **What it is:** Present concrete checkable claims and what changed, keep the reasoning available but not front-loaded,
  and give the reviewer something to form a view on before they meet the case for the work.
- **Trade-offs:** Backed by two controlled studies rather than by practice or analogy (A32, A33), and it directly
  counters the habituation risk that motivated the question (A29). Three costs. The study measuring the effective
  version also measured reduced reviewer satisfaction, so this makes the loop less pleasant on purpose (A33). It is
  orthogonal to boundary placement rather than an alternative to it. And its two supporting studies come from the same
  research conversation about over-reliance and explanation, published in the same venue, with one explicitly reframing
  the other's line of findings. So they are not independent in the way this report demands elsewhere.
- **Rests on:** (A29, A32, A33, A35)
- **Evidence status:** corroborated, with the caveat that A32 and A33 share a research lineage; A35's only stated
  corroboration is those same two, and A29 supports the general habituation mechanism rather than this specific claim

### O7: Bounded rounds with a stop rule that is computed rather than judged

- **What it is:** Work proceeds in batches. After each one, findings are classified and counted, and a fixed rule
  decides whether another round happens. Two skills in this repository already run this shape (A53, A54).
- **Trade-offs:** It is the only pattern here where "are we done" has an answer nobody has to argue about, which is a
  direct guard against the loop running until someone gets tired. It is also proven in this codebase rather than
  borrowed. Against it: it needs a countable signal to gate on, and the two skills using it have one because their
  rounds produce findings that can be counted and graded. Work being built rather than reviewed produces no such
  signal, so this pattern has nothing to compute over in the case this research serves.
- **Rests on:** (A53, A54)
- **Evidence status:** corroborated in the codebase; no external source supports transferring it to production work

### O8: No chunk structure at all for open-ended work

- **What it is:** For work with no backing discipline, drop the loop and simply converse, stopping wherever the
  conversation naturally does.
- **Trade-offs:** This deserves naming precisely because the report found no evidence for any unit in open-ended work.
  Imposing a structure the literature does not support is a real risk, and conversation is the honest default when
  nothing is known. Against it: the interruption and fatigue evidence cuts both ways, and an unstructured conversation
  has no defense against the failure the whole loop exists to prevent (A29, A43). That failure is a large amount of
  work arriving at once, with the person nodding through it. It also gives the person nothing to redirect early.
- **Rests on:** (A29, A43), and the absence of evidence for any alternative in this case
- **Evidence status:** no evidence either way; named here so the choice of O2 for this case reads as deliberate

## Recommendation

- **Recommendation:** A composite of O1, O2, O5, and O6. No single option answers the question, and the evidence
  supports each of these four on a different axis: O1 sets where the boundary falls, O2 sets who chooses it, O5 sets how
  hard to stop, and O6 sets what happens at the stop. O3 and O4 are not recommended, for reasons below.

- **Evidence basis:** O1 rests on the strongest corroboration in the report, four independent directions converging on
  staging by concern with structure before surface (A16, A17, A18, A19, A20, A13). The per-kind units are more uneven.
  One decision per record is well corroborated (A10, A11). The prose unit is weaker and should be treated that way.
  The editorial evidence establishes the order of concerns but assumes a finished draft. Staging by fidelity keeps that
  order while dropping the precondition, resting on two further sources about when feedback can still change something
  (A13, A22). No single source documents that as a practice. For open-ended work no source defines a unit at all, which
  is why O2 carries that case.

  O2 rests on goal-setting research showing a stated rationale closes most of the gap between an imposed and a
  negotiated plan (A30, A31). It also rests on an existing skill in this repository that already surfaces open items
  one at a time, for the stated reason that each answer reshapes the ones behind it (A48). The claim that negotiation
  improves review quality is **not** evidenced and is not part of the basis.

  O5 rests on the reversibility framework, corroborated by an independent secondary source (A6), and answers the
  measured interruption cost of stopping (A40).

  O6 rests on two controlled studies (A32, A33), reinforced by the mechanism behind them (A35) and by the habituation
  review that motivated the question (A29). Adversarial validation established that those two studies are not
  independent of each other. They belong to the same research conversation about over-reliance and explanation, in the
  same venue, with one reframing the other's line of findings. This report demands independence elsewhere, so it has to
  concede the shortfall here. O6 is well evidenced by controlled experiment and thinly corroborated, which is a
  different thing from the four-directional support behind O1. Discounting both studies would leave O6 with only the
  general habituation literature, which is about a different question, and the recommendation would lose it.

  Carrying feedback into a written record rather than the assistant's memory rests on an analogy from an adjacent domain
  with strong numbers: 6 percent against 23 percent missed steps (A41). It also rests on mature professional convention
  (A42) and an existing convention in this repository (A47). It is analogy rather than direct measurement, and it is
  corroborated well enough to act on.

  **Why not the others.** O3 reviews a bounded whole, which needs the artifact to exist before review starts and so
  conflicts with the loop's premise that work arrives in pieces. It stays worth knowing because one skill in this
  repository runs that way. It also names a real risk the composite has to answer: parts reviewed in isolation
  can each look right while the whole does not (A25, A51).

  O4 is the weakest-evidenced option, its supporting sources describe a different domain, and a cadence rule alone
  never says what should be ready at the stop.

  O7 needs a countable signal to gate on, and work being built produces none. Its idea of a stop rule nobody argues
  about is worth borrowing, though, if a countable signal ever appears.

  O8 is the honest default for open-ended work, given that no evidence supports any unit there. O2 is preferred over
  it only because a proposed plan gives the person something to redirect before the work exists, which O8 cannot offer.

  **What is not settled.** Three gaps are real and none of them is papered over above. No source documents splitting a
  decision's problem, options, and choice into separate review checkpoints, so that staging is an extension rather than
  a practice. No study compares review care at a negotiated checkpoint against an imposed one. No study compares review
  degradation with and without an objective gate, which matters here precisely because non-code work has no test suite.
  And no source anywhere describes this exact situation, an assistant building work with a person across many stops.
  Every source describes either a human reviewing a mostly-finished artifact or a person consulting an assistant once.

## Validation

### V1: The prose unit needed the very precondition used to reject a competing option

- **Strategy:** Challenge the Recommendation
- **Investigation:** Compared the loop's premise that work arrives in pieces against O1's original prose unit, one
  concern pass over the whole draft, and against the stated reason for rejecting O3. Editorial staging assumes a
  finished draft, so the first chunk would have been "write the entire draft," which is O3 in substance.
- **Result:** Confirmed. This was the report's sharpest internal contradiction.
- **Impact:** The largest change here. The prose unit is now one rung of a fidelity ladder, which keeps the order of
  concerns the editorial evidence establishes while dropping the finished-draft precondition, resting on A13 and A22.
  Its evidence status now says plainly that no single source documents this as a practice.

### V2: A skill was described as running stop-free when it has a mid-draft gate

- **Strategy:** Challenge the Evidence
- **Investigation:** Read the coding-standard skill in full. Its drafting step stops to propose the file globs the
  standard will govern and states it will "not write the file until the user confirms or proposes a substitute." A
  search of the documentation skill confirmed its two operator questions sit in the opening step, before drafting.
- **Result:** Refuted, as originally written.
- **Impact:** The in-repo precedent section and A52 are corrected. One skill runs stop-free after its opening; the other
  has a single mid-draft gate on an expensive-to-reverse choice. The argument against O3 now cites the one skill that
  supports it.

### V3: A third in-repo pattern was gathered as evidence and never used

- **Strategy:** Challenge the Options Framing
- **Investigation:** Two source entries documented bounded review rounds with a stop rule computed from finding counts
  and severities, and neither appeared anywhere outside the sources table. That pattern is neither one-unit-per-turn
  nor whole-artifact-then-review.
- **Result:** Confirmed.
- **Impact:** Added as O7, and the in-repo section now describes three patterns rather than two. O7 is not recommended,
  because it needs a countable signal to gate on and work being built produces none.

### V4: The two studies behind the walkthrough finding share a lineage

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The report applies independence scrutiny rigorously to the staging finding and flags shared data
  lineage elsewhere. It does not apply that scrutiny to A32 and A33, which sit in the same research conversation and
  venue, with one reframing the other's line of findings.
- **Result:** Confirmed.
- **Impact:** O6's evidence status and the recommendation's evidence basis now carry the caveat, and the claim that it
  was the only option with a controlled study behind it is gone.

### V5: Losing those two studies would cost the walkthrough finding

- **Strategy:** Challenge the Recommendation
- **Investigation:** Traced O6's supporting sources. One of the four has no corroboration beyond those same two studies,
  and the fourth supports general habituation rather than this specific claim.
- **Result:** Confirmed.
- **Impact:** The recommendation now states this sensitivity outright rather than leaving a reader to discover it.

### V6: Two smaller citation errors

- **Strategy:** Challenge the Evidence
- **Investigation:** The cited line range for the test-driven cycle did not contain the "cross the item off" language,
  which sits about 65 lines later. A separate count of skills using one unit per turn did not reconcile against the
  escalation rule's own list of consumers.
- **Result:** Partially Refuted on the first, since the claim was true of the skill but the range was wrong.
- **Impact:** The line range is corrected. The count is removed rather than fixed, following this repository's
  convention of describing sets completely instead of stating running totals.

### V7: Two viable alternatives were never named

- **Strategy:** Challenge the Options Framing
- **Investigation:** Checked whether "no chunk structure at all for open-ended work" and "ask the person where to stop
  rather than proposing a plan" appeared anywhere. Neither did, despite the report conceding it found no evidence for
  any unit in open-ended work.
- **Result:** Confirmed.
- **Impact:** The first is added as O8 and dismissed with a stated reason. The second is addressed inside O2, which now
  says plainly that preferring a proposal over a question is a judgment call rather than a finding.

### V8: Single-sourced material stayed out of the recommendation

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Enumerated every artifact flagged single-source and cross-referenced against each recommended
  option. O1, O2, and O6 contain none. O5 loses only the interruption-cost study.
- **Result:** Confirmed, in the report's favor.
- **Impact:** No change. The recommended composite does not depend on any single-sourced external claim, though this
  does not offset the lineage problem in V4, which is a different failure mode.

### V9: A weak retrieval did not affect the headline finding

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** One editorial body's page was retrieved through search snippets after an HTTP 403. Checked whether
  removing it collapses the four-directional support behind the staging finding. It does not: a second professional
  body, a practitioner account, and two composition studies remain, still spanning practice and research.
- **Result:** Confirmed, in the report's favor.
- **Impact:** No change.

### Adjustments Made

Validation changed the report substantially. The prose unit was rewritten from a pass over a finished draft to a rung of
a fidelity ladder, which was the only way to make it compatible with the loop it serves (V1). The in-repo precedent
section was corrected and expanded from two patterns to three (V2, V3). O7 and O8 were added, and O2 now addresses the
alternative it beats on judgment rather than evidence (V3, V7). O6's evidence claim was softened to admit its two
studies share a lineage, and the recommendation now states what discounting them would cost (V4, V5). One citation range
was corrected and one count removed (V6).

The recommendation survived, but the prose half of O1 did not survive in its original form.

### Confidence Assessment

- **Confidence:** High for staging by concern, Medium for the per-kind units, Low for open-ended work
- **Remaining Risks:** The rating splits three ways because the evidence does.

  Staging by concern, structure before surface, is High. Four independent directions support it: two national editing
  bodies, a practitioner account, two peer-reviewed composition studies, and design practice in an unrelated field
  reaching the same conclusion (A13, A16, A17, A18, A19, A20). Validation attacked it and it held.

  The per-kind units are Medium, and unevenly so. One decision per record is well corroborated (A10, A11). The prose
  unit is a reconciliation this report performed rather than a practice any source documents, and after V1 it says so.
  If that reconciliation is wrong, prose work has no evidenced unit either.

  Open-ended work is Low, and honestly so. No source describes a unit for it, which is why the recommendation falls back
  to a negotiated plan and why O8 is named rather than buried.

  Three gaps stay open and none is closed by this report. No source documents splitting a decision into separate review
  checkpoints. No study compares review care at a negotiated checkpoint against an imposed one. No study compares review
  degradation with and without an objective gate, which matters most here, because non-code work is exactly the case
  with no test suite to fall back on.

  One process caveat. The validator could not fetch web pages, so all 43 external artifacts rest on the research agents'
  reporting rather than independent confirmation. The codebase artifacts were checked directly against the files, and
  two of them were wrong, which is why V2 and V6 exist.

## Sources

| ID  | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
| --- | ------ | --------------- | --------- | ----------- | ------------------ | --------------- |
| A1 | NN/g: Design Critiques | https://www.nngroup.com/articles/design-critiques/ | 2026-08-13 | web | Critique is narrowly scoped, frequent, works at any fidelity, and is distinct from approval. | corroborated by A2 |
| A2 | Berkun: How To Run a Design Critique | https://scottberkun.com/essays/23-how-to-run-a-design-critique/ | 2026-08-13 | web | Three or four specific questions per session; weekly cadence; critique informs rather than authorizes. | corroborated by A1 |
| A3 | Rust RFC process | https://rust-lang.github.io/rfcs/0002-rfc-process.html | 2026-08-13 | web | No size threshold and no splitting guidance; a negative result also true of Python's process. | single source (negative result) |
| A4 | Boehm cost-of-change data | https://reworkcost.com/boehm-cost-of-change-curve | 2026-08-13 | web | Cost to fix rose from 1x at requirements to 50-200x in production; 2001 revision found 1:5 to 1:20 for iterative teams. | corroborated by A5 |
| A5 | Mountain Goat: cost-of-change curve | https://www.mountaingoatsoftware.com/blog/the-cost-of-change-curve-is-outdated | 2026-08-13 | web | Direction holds, magnitude flattened; feedback delay now dominates. | corroborated by A4, same data lineage |
| A6 | Amazon one-way/two-way doors | https://aws.amazon.com/executive-insights/content/how-amazon-defines-and-operationalizes-a-day-1-culture/ | 2026-08-13 | web | Irreversible decisions get slow wide review; reversible ones get fast review by a small group. | corroborated by an independent secondary source |
| A7 | LeanIX: architecture review boards | https://www.leanix.net/en/wiki/ea/architecture-review-board | 2026-08-13 | web | Boards review whole proposals gated by cost and impact; no sizing metric given. | single source (caveated, vendor) |
| A8 | Ubl: Design Docs at Google | https://www.industrialempathy.com/posts/design-docs-at-google/ | 2026-08-13 | web | 10-20 pages for a large design doc, 1-3 for a small one, split when it outgrows itself. | single source (caveated) on the figures |
| A9 | Google Research: Improving Design Reviews | https://research.google/pubs/improving-design-reviews-at-google/ | 2026-08-13 | web | 25% reduction in median approval time across 141,652 documents; review latency is a measured cost. | single source, abstract only |
| A10 | Nygard: Documenting Architecture Decisions | https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions | 2026-08-13 | web | "One ADR describes one significant decision"; five-part structure, one to two pages. | corroborated by A11 |
| A11 | adr.github.io | https://adr.github.io/ | 2026-08-13 | web | "Captures a single AD and its rationale"; same unit, independently maintained. | corroborated by A10 |
| A12 | Calçado: A Structured RFC Process | https://philcalcado.com/2018/11/19/a_structured_rfc_process.html | 2026-08-13 | web | Widening-circle review over fixed size gates; "the more polished a document looks, the softer reviews tend to be". | corroborated cross-domain by A13 |
| A13 | Buxton fidelity principle, via Whatley | https://www.simonwhatley.co.uk/writing/low-fidelity-design-gets-high-level-feedback-high-fidelity-designs-get-low-level-feedback/ | 2026-08-13 | web | Low-fidelity work draws structural feedback; high-fidelity draws cosmetic; people won't criticize what looks finished. | corroborated cross-domain by A12 |
| A14 | Double Diamond design model | https://en.wikipedia.org/wiki/Double_Diamond_(design_process_model) | 2026-08-13 | web | Four stages as two diverge-converge cycles, problem space then solution space; not tied to review triggers. | single source (caveated, tertiary) |
| A15 | Increment: Planning with RFCs | https://increment.com/planning/planning-with-requests-for-comments/ | 2026-08-13 | web | RFC templates add estimated size and definition of done; cadence needs deliberate infrastructure. | single source (caveated) |
| A16 | Editorial Freelancers Association | https://www.the-efa.org/editorial-services-definitions/ | 2026-08-13 | web | Four editing levels in fixed order: developmental, line, copy, proofread. | corroborated by A17, A18, A19, A20 |
| A17 | CIEP editorial stage definitions | https://www.ciep.uk/resource/what-is-the-difference-between-copyediting-and-proofreading.html | 2026-08-13 | web | Same three-stage order from an independent national body; retrieved via search snippets after HTTP 403. | corroborated by A16 |
| A18 | Sommers 1980, CCC 31(4) | https://eric.ed.gov/?id=EJ240356 | 2026-08-13 | web | Students revise by rewording; experienced writers revise recursively for meaning and structure. | corroborated by A19 |
| A19 | Faigley & Witte 1981, CCC 32(4) | https://scholarsarchive.byu.edu/cgi/viewcontent.cgi?article=1016&context=journalrw | 2026-08-13 | web | Meaning changes versus surface changes; experienced writers make meaning changes more often. Read via secondary summary. | corroborated by A18 |
| A20 | The Expert Editor: edit types | https://experteditor.com.au/article/copyedit-vs-proofread-vs-structural-edit-which-your-draft-actually-needs/ | 2026-08-13 | web | "Effort spent decorating rooms that are about to be knocked through." | corroborated by A16, A17 |
| A21 | GMU Writing Center: Reverse Outlining | https://writingcenter.gmu.edu/writing-resources/writing-as-process/reverse-outlining | 2026-08-13 | web | Distill each paragraph to its main idea to check structure before sentence-level revision. | corroborated by A22 |
| A22 | UNC Writing Center: Getting Feedback | https://writingcenter.unc.edu/tips-and-tools/getting-feedback/ | 2026-08-13 | web | Early feedback changes foundations; late feedback is limited to surface concerns. Share often. | corroborated by A21 |
| A23 | Workshop models: Iowa and Lerman | https://writers.com/how-to-workshop-creative-writing | 2026-08-13 | web | Iowa gag rule; Lerman sequences what's working, author questions, neutral questions, then opinions with permission. | corroborated by an independent practitioner account |
| A24 | Fiction Foundry workshop guidelines | https://fictionfoundry.alumni.columbia.edu/workshop_manuscript_guidelines | 2026-08-13 | web | 2,500-5,000 words per manuscript, six per session, advance written critiques. | single source (caveated) |
| A25 | Amazon PR/FAQ process | https://workingbackwards.com/concepts/working-backwards-pr-faq-process/ | 2026-08-13 | web | Six-page cap, read in silence as a whole, deliberately not circulated in pieces. | single source (caveated) |
| A26 | Minto Pyramid Principle | https://slideworks.io/resources/the-pyramid-principle-mckinsey-toolbox-with-examples | 2026-08-13 | web | Conclusion first, then arguments, then evidence; document structure rather than review cadence. | single source (caveated) |
| A27 | Umbrex: hypothesis-driven problem solving | https://umbrex.com/resources/frameworks/strategy-frameworks/hypothesis-driven-problem-solving/ | 2026-08-13 | web | Weekly or biweekly sprints with a 30-60 minute synthesis checkpoint and a living hypothesis board. | single source (caveated) |
| A28 | Cooper Stage-Gate process | https://www.toolshero.com/innovation/stage-gate-process/ | 2026-08-13 | web | Stages separated by go/kill/hold/recycle gates; physical product development, not knowledge work. | single source (caveated, adjacent domain) |
| A29 | Parasuraman & Manzey: Complacency and Bias | https://pmc.ncbi.nlm.nih.gov/articles/PMC3240751/ | 2026-08-13 | web | Erroneous advice raised incorrect-decision risk 26%; complacency rises with highly-but-imperfectly reliable systems. | corroborated by A38, A39 |
| A30 | Locke & Latham 2019 retrospective | https://www.decisionskills.com/uploads/5/1/6/0/5160560/locke_latham_2019_the_development_of_goal_setting_theory_50_years.pdf | 2026-08-13 | web | With difficulty held constant, participative and assigned goals perform alike; rationale closes the commitment gap. | corroborated by A31 |
| A31 | Latham & Yukl 1975 | https://web.mit.edu/curhan/www/docs/Articles/15341_Readings/Group_Performance/Latham%20and%20Yukl%20-%201975%20-%20Assigned%20versus%20participative%20goal%20setting%20with%20ed.pdf | 2026-08-13 | web | Participative goal-setting raised productivity because the goals set were harder, not because of participation. | corroborated by A30, read via secondary summary |
| A32 | Vasconcelos et al. 2023, CSCW | https://arxiv.org/abs/2212.06823 | 2026-08-13 | web | Five studies, 731 participants: explanations reduce overreliance only when they lower verification cost. | corroborated by A33, A35 |
| A33 | Buçinca et al. 2021, CSCW | https://arxiv.org/abs/2102.09692 | 2026-08-13 | web | Passive explanations do not reduce overreliance and can increase it; forcing the reviewer to judge first does, at a satisfaction cost. | corroborated by A32 |
| A34 | Zhang, Liao & Bellamy 2020, FAT* | https://dl.acm.org/doi/10.1145/3351095.3372852 | 2026-08-13 | web | Confidence scores and explanations are a weak, inconsistent lever on appropriate reliance. Abstract only; paywalled. | corroborated by A32, A33 |
| A35 | Ehsan & Riedl: explainability pitfalls | https://technologyandsociety.org/human-centricity-in-the-relationship-between-explainability-and-trust-in-ai/ | 2026-08-13 | web | Explanations signal perceived competence independent of whether their content is sound. | corroborated by A32, A33 |
| A36 | Reviewer anchoring RCT | https://arxiv.org/abs/2307.05443 | 2026-08-13 | web | 108 reviewers: no significant anchoring; reviewers revised scores once corrected material arrived. | single source (caveated), conflicts with a naive first-impression model |
| A37 | Sonar and Stack Overflow developer surveys | https://www.sonarsource.com/state-of-code-developer-survey-report.pdf | 2026-08-13 | web | 96% do not fully trust AI code; only 48% consistently verify before merging. | single source (caveated, vendor) for the figures; direction corroborated |
| A38 | Thoughtworks: complacency with AI code | https://www.thoughtworks.com/radar/techniques/complacency-with-ai-generated-code | 2026-08-13 | web | Vigilance drops after a few positive experiences; recommends anchoring review in objective gates. | corroborated by A29, A39 |
| A39 | Atomic Robot: AI review fatigue | https://atomicrobot.com/blog/ai-review-fatigue/ | 2026-08-13 | web | Vigilance decrement, automation complacency, and context-switching residue compound. | corroborated by A29 |
| A40 | Mark et al. 2008, CHI | https://ics.uci.edu/~gmark/chi08-mark.pdf | 2026-08-13 | web | Average 23 minutes 15 seconds to resume a task after interruption; faster but more stressed completion. | single source (caveated for this application) |
| A41 | Surgical checklist studies | https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11536331/ | 2026-08-13 | web | Teams missed ~6% of critical steps with a checklist against ~23% from memory. | corroborated across two independent sources |
| A42 | Editorial style sheets | https://www.daniellencarter.com/post/editing-with-style-sheets | 2026-08-13 | web | A running record of editorial decisions and reasons, kept so decisions aren't re-argued or misremembered. | single source (caveated), practice broadly attested |
| A43 | Review fatigue practitioner accounts | https://hackernoon.com/the-oversight-fatigue-problem-why-hitl-breaks-down-at-scale-and-what-comes-after | 2026-08-13 | web | Review quality decays into rubber-stamping past a volume threshold; concentrate review at fewer points. | two practitioner sources converge; neither cites data |
| A44 | code-walkthrough operating principles | `han-coding/skills/code-walkthrough/SKILL.md:41-46` | n/a | codebase | "One step per turn, then stop and wait... the pacing is the deliverable." | corroborated by A46, A48 |
| A45 | walkthrough step format | `han-coding/skills/code-walkthrough/references/walkthrough-step-format.md:1-26` | n/a | codebase | A step earns its place where behavior turns: a branch, transformation, dispatch, boundary crossing, or write. | corroborated by A44 |
| A46 | operator-escalation rule | `han-planning/references/operator-escalation-rule.md:16-24` | n/a | codebase | One question per turn, stating how many are pending so the operator knows the queue depth. | corroborated by A44, A48 |
| A47 | escalation register | `han-planning/references/operator-escalation-rule.md:102-115` | n/a | codebase | Records each question as asked, the answer, and where the answer landed in the artifact. | corroborated by A49 |
| A48 | design-an-api open-item gate | `han-coding/skills/design-an-api/SKILL.md:289-307` | n/a | codebase | Open items surfaced one at a time, never batched, because each answer reshapes the ones behind it. | corroborated by A44, A46 |
| A49 | plan-a-feature decision log | `han-planning/skills/plan-a-feature/SKILL.md:110-115` | n/a | codebase | Stable decision IDs cross-referenced inline so every link keeps resolving through revisions. | corroborated by A47 |
| A50 | tdd red-green-refactor unit | `han-coding/skills/tdd/SKILL.md:126-134,199-207` | n/a | codebase | One behavior per cycle, three phases never collapsed, each closing by crossing the item off the list. | corroborated by A44 |
| A51 | project-documentation structure | `han-documentation/skills/project-documentation/SKILL.md:36-200` | n/a | codebase | Writes the complete document, then dispatches reviewers; its two operator questions sit in the opening step, before drafting. | corroborated by A52 with the difference noted |
| A52 | coding-standard structure | `han-coding/skills/coding-standard/SKILL.md:214-226,338-382` | n/a | codebase | Stops mid-draft for approval of the globs the standard governs and will not write until confirmed; the later audit is a self-check, not a gate. | contrasts with A51; corrected by validation finding V2 |
| A53 | iterative-plan-review rounds | `han-planning/skills/iterative-plan-review/SKILL.md:249-355` | n/a | codebase | Rounds capped by band, with a deterministic stop rule and findings recorded per round. | corroborated by A54 |
| A54 | plan-implementation round aggregation | `han-planning/skills/plan-implementation/references/round-aggregation.md:1-44` | n/a | codebase | Claim ledger grouping findings by category and marking each evidenced, anecdotal, disputed, or unverified. | corroborated by A53 |

### A16: Editorial Freelancers Association service definitions — recommendation-bearing

- **Link / location:** https://www.the-efa.org/editorial-services-definitions/
- **Retrieved:** 2026-08-13
- **Trust class:** web (professional association)
- **Summary:** Defines four editing levels and their order. Developmental editing restructures and reorganizes;
  line editing works sentence and paragraph language and style; copyediting handles grammar, punctuation, and
  consistency; proofreading catches typographical and formatting errors on near-final proofs. States that line
  editing follows developmental work and proofreading comes last. This is one of the two national professional bodies
  whose independent agreement anchors the staging finding.
- **Evidence status:** corroborated by A17 (a separate national body in another country), and independently by the
  composition research in A18 and A19

### A18: Sommers, "Revision Strategies of Student Writers and Experienced Adult Writers" — recommendation-bearing

- **Link / location:** https://eric.ed.gov/?id=EJ240356
- **Retrieved:** 2026-08-13
- **Trust class:** web (peer-reviewed, foundational composition-studies research)
- **Summary:** A study of 8 student writers and 7 experienced adult writers, published in College Composition and
  Communication. Found that student writers treat revision as word-level rewording while experienced writers revise
  recursively, focused on meaning and structure rather than working linearly by stage. This matters here because it
  arrives at the structure-before-surface finding from academic research rather than professional convention, making
  the agreement with A16 and A17 genuine corroboration rather than one claim repeated.
- **Evidence status:** corroborated by A19, which distinguishes meaning changes from surface changes and finds the same
  split between experienced and inexperienced writers

### A33: Buçinca, Malaya & Gajos, "To Trust or to Think" — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2102.09692
- **Retrieved:** 2026-08-13
- **Trust class:** web (peer-reviewed, Proceedings of the ACM on Human-Computer Interaction)
- **Summary:** Establishes that passively presented explanations do not reliably reduce over-reliance on an assistant's
  output and can increase it. The only intervention that meaningfully reduced over-reliance was a cognitive forcing
  function, meaning a step that requires the person to engage actively before seeing the assistant's answer. The study
  measured a real cost: lower user satisfaction. The benefit concentrated in people already inclined toward effortful
  thinking. This is the study behind the recommendation that the walkthrough hand the reviewer something to check
  rather than a case to agree with.
- **Evidence status:** corroborated by A32, which independently finds the effect of explanations on reliance is
  conditional rather than uniformly protective

### A32: Vasconcelos et al., "Explanations Can Reduce Overreliance on AI Systems" — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2212.06823
- **Retrieved:** 2026-08-13
- **Trust class:** web (peer-reviewed, Proceedings of the ACM on Human-Computer Interaction)
- **Summary:** Five studies with 731 participants. Reframes earlier null findings: explanations reduce over-reliance
  specifically when they lower the cost of checking a claim independently. On hard tasks people engage more carefully
  with explanations, but explanations that are harder to parse increase over-reliance because they raise verification
  cost. A financial incentive to verify reduced blind acceptance. This is the source for the design consequence that a
  walkthrough should carry concrete checkable claims rather than a fluent narrative.
- **Evidence status:** corroborated by A33 and A35

### A6: Amazon's one-way and two-way door framework — recommendation-bearing

- **Link / location:** https://aws.amazon.com/executive-insights/content/how-amazon-defines-and-operationalizes-a-day-1-culture/
- **Retrieved:** 2026-08-13
- **Trust class:** web (the organization's own account of its internal framework)
- **Summary:** Separates decisions by reversibility. Irreversible, high-consequence decisions warrant slow, deliberate,
  widely consulted review. Reversible, low-cost-of-being-wrong decisions should be made quickly by a small group or a
  single person with good judgment. This is the best-corroborated guidance found about calibrating review effort to a
  decision rather than to an artifact. It is what lets the loop spend the operator's attention where reversal is
  expensive, instead of stopping uniformly.
- **Evidence status:** corroborated by independent secondary sources describing the framework identically

### A48: Han's design-an-api open-item gate — recommendation-bearing

- **Link / location:** `han-coding/skills/design-an-api/SKILL.md:289-307`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Surfaces open items "one at a time, each as its own `AskUserQuestion` call. Never batch them BECAUSE each
  answer routinely settles or reshapes the ones behind it, and a batch asks the user to decide in an order the design
  does not follow." After each answer it re-checks the remaining items, dropping settled ones and rewording changed
  ones. This is the working in-repo precedent for a negotiated, adaptive sequence in decision work, and it is the
  closest existing analogue to the pairing loop this research serves.
- **Evidence status:** corroborated by A44 and A46, which show the same one-unit-per-turn pattern in two other skills

### A41: Surgical checklist studies — recommendation-bearing

- **Link / location:** https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11536331/
- **Retrieved:** 2026-08-13
- **Trust class:** web (peer-reviewed medical human-factors research)
- **Summary:** In simulated operating-room crisis scenarios, teams using a written checklist missed about 6 percent of
  critical steps, against about 23 percent missed when working from memory. This is the strongest available empirical
  anchor for the claim that an externalized written record outperforms recollection. It is domain-specific to surgical
  emergency response, so its application to carrying a reviewer's feedback forward is an analogy rather than a direct
  finding, and it is labeled as such wherever it is used.
- **Evidence status:** corroborated across two independent sources, applied here by analogy
