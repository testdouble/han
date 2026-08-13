# Research: Stopping Points for Collaborative Work That Is Not Code

What makes a good stopping point for human review when an assistant is doing collaborative work that is not code, and
who should decide where that point falls? Evidence mode: strict.

## Summary

Stop where the kind of feedback changes, not where a word count is hit. That is the one finding solid enough to build
on, and it holds across professional editing bodies, two peer-reviewed studies of how writers revise, and design
practice in a separate field. Review the shape of the work before its surface, every time. Polish applied before the
shape is settled gets thrown away when the shape changes.

That gives a different unit for each kind of work. For a decision, the unit is one decision, presented with its context,
the options weighed, and what it commits you to. For written work, the unit is one concern across the whole draft, not
one section of it: read for structure, then read for language, never both at once. For code you already have the answer.
For genuinely open-ended work there is no established answer, and I found none, so the assistant should propose a plan
and let you change it.

One finding should change how the walkthrough itself is written. Explaining your reasoning to a reviewer does not
reliably make them more careful, and can make them less so. Explanations read as a signal of competence whether or not
their content holds up, and a polished explanation invites agreement. What does work is making claims cheap to check,
and getting the reviewer to form a view before they see the reasoning. So the walkthrough should hand you something to
check, not something to be convinced by.

Two smaller results worth carrying. Who picks the stopping point barely matters for commitment, as long as the reason
for the choice is stated, so the assistant proposing a plan you can redirect is fine. And feedback belongs in a written
record rather than in the assistant's memory of the conversation, which your suite already has a convention for.

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
for the architectural decision record states that "one ADR describes one significant decision," and an independently
maintained community reference says the same thing in nearly identical words (A10, A11). Both put it at one or two pages
with a fixed shape: the context, the decision, and its consequences.

How much review a decision deserves scales with how reversible it is. Amazon's framework separates decisions you can
walk back cheaply from ones you cannot, and prescribes fast review by a small group for the first and slow, wide review
for the second (A6).

There is a real gap here. Every decision-record template separates the problem, the options, and the chosen option into
distinct sections, and that convergence is well corroborated across at least four independent template families (A10,
A11). But **no source treats those three sections as three separate review checkpoints**. They are documented as parts
of one document, written and reviewed together. Turning them into a review sequence is a reasonable extension, not an
established practice, and I am flagging it as such rather than dressing it up.

Published proposal processes offer less than you would hope. The Rust language's process gives no size guidance and no
rule for splitting a large proposal, and the same search of Python's process returned nothing either (A3). One
widely-cited account of design documents at Google gives concrete numbers, roughly ten to twenty pages for a large one
and one to three for a small one, with direction to split when a document outgrows itself, but that is one author's
account (A8) [single-source].

### The unit for prose is one concern over the whole draft

Reviewing prose section by section is the wrong cut. The editorial staging above operates on the whole manuscript per
pass, not on one chapter at a time.

Two patterns compete for how to stage the work itself. Reverse outlining distills each paragraph of a finished draft to
its main idea, checking structure before any language work (A21). Amazon's narrative process goes the other way: a
complete document capped at six pages, read in silence by the group and then discussed as a whole, deliberately not
circulated in pieces, on the argument that reading parts in isolation produces worse structural feedback than reading
the connected whole (A25) [single-source].

A university writing center adds the timing rule. Feedback on an outline or rough draft can still change foundational
choices, while feedback on a polished draft is limited to surface concerns because the foundations are no longer
practically revisable (A22).

Writing workshops give one concrete size: two and a half to five thousand words per piece (A24) [single-source]. They
also give a rule worth stealing. Two independent sources describe a named alternative to the standard workshop that
sequences feedback deliberately: what is working, then the author's own questions, then neutral questions, then opinions
only with permission (A23). That is the same structure-before-surface principle, applied inside a single conversation
rather than across separate passes.

### Explaining your reasoning can make the reviewer less careful

This is the finding that should change the design, and it is well corroborated by controlled studies.

Passive explanations do not reliably reduce over-reliance on an assistant's output, and sometimes increase it (A33).
Explanations act partly as a signal of competence, working on the reviewer's trust regardless of whether the content
holds up (A35). One study of five experiments with 731 participants found explanations reduce over-reliance only when
they lower the cost of checking the claim independently, and that hard-to-parse explanations make things worse by
raising that cost (A32).

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
assigned to them produce statistically indistinguishable performance, and that an assigned goal reaches equivalent
commitment when it comes with a rationale (A30, A31). Participation's real effect is that people set themselves harder
targets.

That literature answers a narrower question than the one asked. It measures the commitment of the person doing the work,
not the care of the person reviewing it. **No study found compares how carefully someone reviews at a checkpoint they
helped choose against one imposed on them.** That is a genuine gap, and the goal-setting evidence should not be read as
settling it.

### Review degrades without an objective gate, but nobody has measured how much

Habituation is corroborated. A systematic review found that reviewers of highly-but-imperfectly reliable systems show
measurable desensitization over time, and that erroneous advice raised the risk of an incorrect decision by 26 percent
across four clinical studies (A29). Practitioner accounts name the same pattern for AI-written code and recommend
anchoring review in objective gates such as tests (A38, A39).

Survey data shows the gap between stated distrust and actual behavior: 96 percent of developers say they do not fully
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

### Your own suite already runs both patterns

Han contains two proven approaches, and the split is instructive.

Five skills use one unit per turn: the walkthrough presents one step and ends the turn, the escalation rule allows one
question per turn while stating how many are pending, and the API design skill surfaces open items one at a time,
never batched, because "each answer routinely settles or reshapes the ones behind it" (A44, A46, A48).

Two skills do the opposite. Both the documentation skill and the coding-standard skill write the complete artifact
first, then dispatch reviewers over the finished work, with no stops in between (A51, A52). That is a deliberate choice,
and it matches Amazon's narrative argument that a connected whole reviews better than parts.

There is also an existing convention for carrying feedback forward: an escalation register recording each question as
asked, the answer, and where the answer landed (A47).

## Options to Consider

### O1: Stage by concern, with the unit set by the kind of work

- **What it is:** The boundary falls where the kind of feedback changes. One decision for decision work, one concern
  pass over the whole draft for prose, one behavior or one named refactoring for code.
- **Trade-offs:** Rests on the strongest evidence in the report, and it is the only scheme with support from four
  independent directions. The cost is that it needs a different unit defined per kind of work, and for open-ended work
  no source defines one.
- **Rests on:** (A10, A11, A13, A16, A17, A18, A19, A20, A22)
- **Evidence status:** corroborated

### O2: A negotiated chunk plan, proposed by the assistant and redirected by you

- **What it is:** Before work starts, the assistant proposes where it will stop and why. You accept or change it, and
  either side can renegotiate as the work reveals itself.
- **Trade-offs:** Goal-setting research says a stated rationale closes most of the gap between an imposed plan and a
  negotiated one, so a proposal you can change costs little and buys a cheap early correction (A30, A31). Your API
  design skill already runs this shape (A48). Against it: no evidence that negotiating a checkpoint makes anyone review
  more carefully at it, which is a real gap rather than a demonstrated weakness.
- **Rests on:** (A30, A31, A48)
- **Evidence status:** corroborated for the commitment claim, uncorroborated for the review-quality claim

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
  says nothing about what should be ready at each stop, so it needs pairing with a content rule; the sources describing
  it were describing visual design critique, not this; and the supporting consulting material is the weakest evidence
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
- **Trade-offs:** The only option in the report with a controlled study behind its causal mechanism (A32, A33). It
  directly counters the habituation risk that motivated the question (A29). Against it: the one study measuring the
  effective version also measured reduced reviewer satisfaction, so this makes the loop less pleasant on purpose (A33).
  It is orthogonal to boundary placement rather than an alternative to it.
- **Rests on:** (A29, A32, A33, A35)
- **Evidence status:** corroborated

## Recommendation

- **Recommendation:** A composite of O1, O2, O5, and O6. No single option answers the question, and the evidence
  supports each of these four on a different axis: O1 sets where the boundary falls, O2 sets who chooses it, O5 sets how
  hard to stop, and O6 sets what happens at the stop. O3 and O4 are not recommended, for reasons below.

- **Evidence basis:** O1 rests on the strongest corroboration in the report, four independent directions converging on
  staging by concern with structure before surface (A16, A17, A18, A19, A20, A13). The per-kind units are more uneven:
  one decision per record is well corroborated (A10, A11), one concern pass over a whole prose draft is well
  corroborated (A16, A17), and for open-ended work no source defines a unit at all, which is why O2 carries that case.

  O2 rests on goal-setting research showing a stated rationale closes most of the gap between an imposed and a
  negotiated plan (A30, A31), plus an existing skill in this repository that already surfaces open items one at a time
  for the stated reason that each answer reshapes the ones behind it (A48). The claim that negotiation improves review
  quality is **not** evidenced and is not part of the basis.

  O5 rests on the reversibility framework, corroborated by an independent secondary source (A6), and answers the
  measured interruption cost of stopping (A40).

  O6 rests on the two controlled studies that are the most methodologically solid evidence in the report (A32, A33),
  reinforced by the mechanism behind them (A35) and by the habituation review that motivated the question (A29).

  Carrying feedback into a written record rather than the assistant's memory rests on an analogy from an adjacent domain
  with strong numbers, 6 percent against 23 percent missed steps (A41), plus mature professional convention (A42), plus
  an existing convention in this repository (A47). It is analogy rather than direct measurement, and it is corroborated
  well enough to act on.

  **Why not O3 and O4.** O3 reviews a bounded whole, which conflicts with the loop's premise that work arrives in
  pieces. It stays worth knowing because two skills in this repository already use it, and it names a real risk: parts
  reviewed in isolation can each look right while the whole does not (A25). O4 is the weakest-evidenced option, its
  supporting sources describe a different domain, and a cadence rule alone never says what should be ready at the stop.

  **What is not settled.** Three gaps are real and none of them is papered over above. No source documents splitting a
  decision's problem, options, and choice into separate review checkpoints, so that staging is an extension rather than
  a practice. No study compares review care at a negotiated checkpoint against an imposed one. No study compares review
  degradation with and without an objective gate, which matters here precisely because non-code work has no test suite.
  And no source anywhere describes this exact situation, an assistant building work with a person across many stops;
  every source describes either a human reviewing a mostly-finished artifact or a person consulting an assistant once.

## Validation

<!-- adversarial-validator findings pending -->

### Confidence Assessment

- **Confidence:** Pending validation.
- **Remaining Risks:** Pending validation.

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
| A50 | tdd red-green-refactor unit | `han-coding/skills/tdd/SKILL.md:126-134` | n/a | codebase | One behavior per cycle, three phases never collapsed, each closing by crossing the item off the list. | corroborated by A44 |
| A51 | project-documentation structure | `han-documentation/skills/project-documentation/SKILL.md:36-200` | n/a | codebase | Writes the complete document, then dispatches reviewers; no mid-run stops. | corroborated by A52 |
| A52 | coding-standard structure | `han-coding/skills/coding-standard/SKILL.md:338-382` | n/a | codebase | Drafts the whole standard before team review; the audit is a self-check, not a gate. | corroborated by A51 |
| A53 | iterative-plan-review rounds | `han-planning/skills/iterative-plan-review/SKILL.md:249-355` | n/a | codebase | Rounds capped by band, with a deterministic stop rule and findings recorded per round. | corroborated by A54 |
| A54 | plan-implementation round aggregation | `han-planning/skills/plan-implementation/references/round-aggregation.md:1-44` | n/a | codebase | Claim ledger grouping findings by category and marking each evidenced, anecdotal, disputed, or unverified. | corroborated by A53 |

### A16: Editorial Freelancers Association service definitions — recommendation-bearing

- **Link / location:** https://www.the-efa.org/editorial-services-definitions/
- **Retrieved:** 2026-08-13
- **Trust class:** web (professional association)
- **Summary:** Defines four editing levels and their order: developmental editing restructures and reorganizes,
  line editing works sentence and paragraph language and style, copyediting handles grammar, punctuation, and
  consistency, and proofreading catches typographical and formatting errors on near-final proofs. States that line
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
  decision rather than to an artifact, and it is what lets the loop spend the operator's attention where reversal is
  expensive instead of stopping uniformly.
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
