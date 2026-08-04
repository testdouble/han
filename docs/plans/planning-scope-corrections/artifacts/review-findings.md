# Review Findings: Planning Scope Corrections Implementation Plan

<!--
Findings from reviews of [../feature-implementation-plan.md](../feature-implementation-plan.md).
Round-by-round detail lives in [review-iteration-history.md](review-iteration-history.md).
Committed decisions live in [implementation-decision-log.md](implementation-decision-log.md).
-->

## Major findings

### F1: The blast-radius count was wrong, and it hid a scope contradiction

- **Agent:** `han-core:evidence-based-investigator`, `han-core:adversarial-validator`, `han-core:junior-developer`
- **Category:** assumption refuted
- **Finding:** The plan stated "twelve skills across seven plugins dispatch `han-core` agents" as a measured figure,
  and used it as the entire impact statement for risk R5. A repository-wide check returns nineteen skills across six
  plugins. The undercount mattered beyond arithmetic: the real set includes `iterative-plan-review`, which the plan's
  own Out of Scope bullet listed as untouched.
- **Evidence considered:** Every `SKILL.md` carrying a `han-core:` reference, filtered for real dispatch language
  rather than naming-convention prose. `han-feedback/skills/han-feedback/SKILL.md` matches the grep but dispatches
  nothing, so it is excluded. `han-planning/skills/iterative-plan-review/SKILL.md` genuinely dispatches three agents.
- **Resolution:** Corrected the figure everywhere it appears. Rewrote the Out of Scope bullet to scope the exclusion to
  that skill's own steps and state the one way the change does reach it. Added the reach to R5's own text.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Constraints and Boundaries, Implementation Approach (Where the blind-spot disclosure is stated),
  Risks and Assumptions

### F2: The insert point is not uniform, and one agent would take the rule in the wrong place

- **Agent:** `han-core:evidence-based-investigator`, `han-core:adversarial-validator`, `han-core:junior-developer`
- **Category:** assumption refuted
- **Finding:** The plan said "the insert point is uniform: a bullet list at the end of every file," and the decision
  log recorded it as verified across the roster. In `han-core/agents/gap-analyzer.md`, `## Rules` at line 241 is
  followed by `## Graceful Degradation` at line 258. An implementer appending to the end of that file lands the rule
  outside any rules list.
- **Evidence considered:** The last `##` heading of all twenty-two `han-core` agent files. Twenty-one end in
  `## Rules`; `gap-analyzer.md` does not.
- **Resolution:** Replaced the uniformity claim with a named exception, and made handling that file by name part of
  unit 2's Delivers cell and the Definition of Done.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Implementation Approach (The insert point is uniform except once), Work Units and Sequencing,
  Definition of Done

### F3: The agent roster is twenty-four, and the rule is meaningless on three of them

- **Agent:** `han-core:junior-developer`, `han-core:adversarial-validator`
- **Category:** ambiguity
- **Finding:** The plan scoped the rule to "all twenty-two for consistency." The repository holds twenty-four agent
  definitions: `han-communication/agents/readability-editor.md` and `han-research/agents/research-analyst.md` sit
  outside `han-core`, and three of the four planning skills dispatch `readability-editor`. Separately,
  `project-scanner` and `codebase-explorer` return discovery inventories with no severity and no assumptions concept,
  so a rule about putting a disclosure on a finding has no referent in either file.
- **Evidence considered:** All twenty-four agent definitions. `project-scanner` and `codebase-explorer` return `D#`
  discovery items; `readability-editor` returns a rewritten draft plus a rubric verdict; `research-analyst` returns
  evidence-bearing research output.
- **Resolution:** Replaced the count-based scope with a test: an agent takes the rule when its output is a claim a
  dispatching skill weighs. Named the three exclusions and the one inclusion from outside `han-core`. The test
  resolves to twenty-one.
- **Resolved by:** user input
- **Raised in round:** R4
- **Changed in plan:** Implementation Approach (Which agents take the rule), Work Units and Sequencing, Definition of
  Done, Specialist Handoffs for Implementation

### F4: The seam between the agent and the consuming skill had no stated shape

- **Agent:** `han-core:adversarial-validator`
- **Category:** unhandled failure mode
- **Finding:** The plan split responsibility, with the agent supplying the disclosure and the dispatching skill
  applying the severity-stripping rule, without saying what "on the finding" has to look like for the skill to
  recognize it. The claim "no output format changes" and the requirement "the skill can reliably act on it" were
  asserted together without being reconciled, across agents whose formats already differ.
- **Evidence considered:** Ten agents carry a findings section with per-finding fields; the rest use numbered items
  under an output-format heading. Nothing in the plan or the decision named a marker, phrase, or field.
- **Resolution:** The rule line now names one shape, so every included agent writes the same form and both consuming
  skills read it. Added as its own subsection, a Definition of Done item, and a Testing Strategy check on both halves.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Implementation Approach (The seam between the agent and the skill needs a stated shape),
  Definition of Done, Testing Strategy

### F5: Widening the accepted file set breaks a working script in an unscoped plugin

- **Agent:** `han-core:junior-developer`
- **Category:** overlap with existing code
- **Finding:** The plan widened the accepted visual-material set past PNG so the inventory stops dropping other
  formats silently. A second consumer reads the same folder and is hardcoded to PNG:
  `han-github/skills/work-items-to-issues`. Its upload script selects assets with a pattern ending in a literal `.png`,
  and its embed rules require a `.png` source filename. A JPG that now flows into a work item is skipped by the upload
  and renders as a broken image in the issue. `han-github` appeared nowhere in the fan-out list, the Out of Scope list,
  or the risk table, and the decision that widens the set was filed as trivial.
- **Evidence considered:** `han-github/skills/work-items-to-issues/scripts/upload-screenshots.sh:47` and
  `references/screenshot-embed-rules.md:27`.
- **Resolution:** `han-github` widens to the same set, as its own work unit with a run-the-script verification. New
  decision [D-20](implementation-decision-log.md#d-20-the-github-screenshot-chain-widens-with-the-accepted-file-set).
- **Resolved by:** user input
- **Raised in round:** R4
- **Changed in plan:** Implementation Approach (Visual material, producer and consumer), Work Units and Sequencing
  (unit 8), Definition of Done, Testing Strategy

### F6: The copy grant was cited in one unit while three other units delivered the behavior it enables

- **Agent:** `han-core:junior-developer`
- **Category:** unhandled failure mode
- **Finding:** The decision adds the copy tool to all four planning skills, but only the `plan-implementation` row
  cited it, and that row named only the directory-creating grant. The three units that deliver visual-material
  persistence cited nothing. Following the table literally, those skills ship their persistence commitment inert, and
  the failure surfaces at the walkthrough for a reason nobody planned for.
- **Evidence considered:** The four skills' current `allowed-tools` lines carry no `cp`; the decision requires it on
  all four.
- **Resolution:** Each planning skill's unit now names its own copy grant in its Delivers cell, and a Definition of
  Done item checks the grant and the prompt-text constraint directly rather than only through an outcome.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Work Units and Sequencing, Definition of Done

### F7: The acceptance checklist had three loads and no address

- **Agent:** `han-core:junior-developer`
- **Category:** ambiguity
- **Finding:** The checklist is the sole mitigation for the coverage risk, the stated verification for two units, and a
  Definition of Done item. It had no path, no format, no owning unit, and a circular dependency: unit 1's verification
  is a read-through against a checklist that must cover commitments defined by later units.
- **Evidence considered:** The plan named its author and its ordering but no location. The contrast is the plan's own
  boundary-record decision, which spent a full decision on a filename for the same reason.
- **Resolution:** Gave it a path, an owning unit, and an incremental shape. New decision
  [D-21](implementation-decision-log.md#d-21-the-acceptance-checklist-has-a-path-and-an-owning-unit).
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Testing Strategy, Work Units and Sequencing (unit 1), Definition of Done

### F8: Two units and one whole behavior had no Definition of Done coverage

- **Agent:** `han-core:junior-developer`
- **Category:** ambiguity
- **Finding:** No checkbox mentioned `han-feedback`, so the plan could be marked done with that unit unbuilt. No
  positive checkbox asserted that any skill escalates one question at a time, so the escalation reference file could
  ship with zero consumers wired and every checkbox would pass. Seven further commitments had no checkbox, which the
  plan's own risk register names and then does not close.
- **Evidence considered:** Thirteen checkboxes against roughly fifteen commitments plus the amendment.
- **Resolution:** Added a per-unit gate as the first item, which closes the general gap, plus individual items for the
  escalation behavior, the `han-feedback` corrections, the long-form docs, the copy grants, and the `han-github`
  widening.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Definition of Done

### F9: The plan's own governing sentence contradicted its own sequencing

- **Agent:** `han-core:structural-analyst`
- **Category:** ambiguity
- **Finding:** The plan stated that two contracts must land whole inside a single unit, naming the visual-material
  producer and consumer pair. The producer sits in one unit and the consumer in another, and the plan's own next
  paragraph describes the resulting gap as expected. The decision that owns sequencing had deliberately chosen
  consumer-first ordering, so the sentence was never true of that pair.
- **Evidence considered:** The sequencing decision's rejected alternatives explicitly rejected producer-first ordering.
- **Resolution:** Corrected the sentence to name one contract that lands whole, and stated plainly that the pair is
  deliberately split, why the split is safe, and what the two halves genuinely do share, which is the heading string
  unit 1 fixes first. Corrected the same claim in the sequencing decision.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Work Units and Sequencing

### F10: A work-unit cell reintroduced the exact misreading its decision warns against

- **Agent:** `han-core:structural-analyst`
- **Category:** ambiguity
- **Finding:** The escalation decision says out loud that a register lands in two skills only, and warns that an
  implementer will otherwise invent an escalation pass in `plan-a-phased-build` simply to have somewhere to put it.
  That skill's Delivers cell read "the single stop with its register," which attributes a register to it. The one place
  the decision asked to be said out loud is the place an implementer works from.
- **Evidence considered:** The decision's own stated reason for being explicit.
- **Resolution:** Reworded the cell to "the single stop with no escalation pass added."
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Work Units and Sequencing

### F11: Two decisions disagreed on how many skills consume the justification field

- **Agent:** `han-core:structural-analyst`
- **Category:** ambiguity
- **Finding:** The reference-decomposition decision stated the justification field's consumers as "all four," while the
  decision made in the same round establishes that `plan-a-feature` produces no work units and takes the cut list only.
  The first decision is the design rationale someone authoring the shared file would read, and it carried the wrong
  number with no cross-link to the correction.
- **Evidence considered:** The two decisions read against each other, and the work-unit cell that already reflects the
  correct answer.
- **Resolution:** Corrected the consumer count to three for the justification field and four for the cut list, with a
  cross-link to the decision that settles it.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** none; the correction is in the decision log

### F12: Unit 1 could not be built without inventing four things

- **Agent:** `han-core:junior-developer`
- **Category:** ambiguity
- **Finding:** The plan fixes the boundary record's name but never its shape, although four separate mechanics read it
  back, including a completeness gate that has to iterate the items it lists. It asks for the "beside the plan" answer
  without giving it. It commits to stating an accepted file set without enumerating it, and one named member is a URL
  that cannot be copied. It requires an ownership preamble in three files while the claimed precedent carries none, so
  the matching Definition of Done item was unfalsifiable.
- **Evidence considered:** `han-communication/references/readability-rule.md` and `writing-voice.md` carry no ownership
  preamble. The specification's own closed open item is the memory-based gate failure a shapeless record would
  reproduce.
- **Resolution:** Named all four as questions the shared reference file settles outright, listed under the section that
  introduces it, and tied them to the unit that has to answer them.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Implementation Approach (Where the shared rules live), Open Items, Recommendation

### F13: The amendment falsified six statements that were never updated

- **Agent:** `han-core:adversarial-validator`, `han-core:junior-developer`
- **Category:** ambiguity
- **Finding:** The scope-expanding amendment changed one section by hand and left the rest describing the earlier
  world. The opening paragraph undercounted both plugins and units. The Implementation Approach's framing enumeration
  had no entry for the new work. The "Watch after ship" bullet and the Recommendation both still described a
  reviewer-brief experiment that no longer exists. One assumption pointed at that experiment. The sequencing decision's
  own text still listed seven units with no mention of the new one.
- **Evidence considered:** Each statement read against what the amendment added.
- **Resolution:** Corrected all six. Also added the sentence the amendment needed and never had: the new rule is copied
  into many files rather than stated once, which is the opposite of this plan's centralizing thesis, and it is an
  accepted exception rather than an oversight. That tension is now stated in the Outcome, where a reader meets the
  thesis, and carried as its own risk.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Outcome, Constraints and Boundaries, Implementation Approach, Risks and Assumptions,
  Recommendation

### F14: The new unit traced to no user story

- **Agent:** `han-core:junior-developer`
- **Category:** ambiguity
- **Finding:** The widest-blast-radius unit in the plan was mapped to two stories that are about something else, one
  about visual material surviving the session and one about conventions being stated once. The second is close to the
  opposite of what the unit does.
- **Evidence considered:** The two stories' own wording against the unit's Delivers cell.
- **Resolution:** Added a story for the behavior the unit does serve, an operator receiving a reviewer's admission
  attached to the finding that rests on it, and remapped the unit to it.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** User Stories, Work Units and Sequencing

### F15: Three repository surfaces went stale at unit 1 and stayed stale for seven units

- **Agent:** `han-core:junior-developer`
- **Category:** ambiguity
- **Finding:** The plan asserts every unit leaves the repository coherent, and separately lists surfaces that go stale
  the moment the new skill lands while assigning their correction to the final unit. The repository-map line describing
  the shared reference folder becomes wrong the instant unit 1 lands owned files there.
- **Evidence considered:** The plan's own fan-out list against its own coherence claim, and the current text of the
  repository-map line.
- **Resolution:** Moved the repository-map correction into unit 1, the unit that makes it wrong. The remaining sweep
  surfaces stay in the final unit.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Work Units and Sequencing, Implementation Approach (Documentation fan-out)

### F16: Whether the new standard carries a self-check materially changes unit 1's size

- **Agent:** `han-core:junior-developer`
- **Category:** ambiguity
- **Finding:** The decision settles the new standard's filename, its skill, and where its boundary statement goes, but
  not what it contains. The named model ends in a standardized self-check that consuming skills run as a discrete step.
  One implementer ships a short rule the skills read while drafting; another mirrors the model and obliges four skills
  to gain a check step, which is a materially larger change.
- **Evidence considered:** `han-communication/references/readability-rule.md`'s structure against the specification's
  scope for the new standard.
- **Resolution:** Recorded as an open item with the smaller version named as the default, so an implementer does not
  silently choose the larger one.
- **Resolved by:** deferred to open item
- **Raised in round:** R4
- **Changed in plan:** Open Items, Recommendation

### F17: The dependency notation could not express where the new unit sits

- **Agent:** `han-core:structural-analyst`
- **Category:** ambiguity
- **Finding:** The final unit's dependencies read as an integer range while a unit named with a letter suffix sat
  inside that range, so whether it was included was undecided by the notation. The range also included a unit the final
  one does not consume anything from.
- **Evidence considered:** The fan-out decision's enumeration, which references nothing the `han-feedback` unit
  delivers.
- **Resolution:** Renumbered every unit to a plain integer and replaced the range with an explicit list.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Work Units and Sequencing

### F18: The single-incident evidence base was generalized further than it supports

- **Agent:** `han-core:adversarial-validator`
- **Category:** assumption refuted
- **Finding:** The amendment's premise is that agents already disclose reliably and only misplace the disclosure,
  resting on one reported run. The specification itself flags that evidence as an accepted limit rather than a
  demonstrated pattern, and explicitly declines to build for the silent case for that reason. The supporting
  observation that six agents carry an assumptions section is equally consistent with the opposite reading: agents have
  somewhere to put disclosures and routinely bury them there.
- **Evidence considered:** The specification's own decision and its deferred entry on the undisclosed case.
- **Resolution:** The plan's claim was softened to what the evidence supports. It now says these agents already have
  somewhere to put a disclosure and none is told to put it where the reader of the finding will see it, rather than
  claiming they already produce it reliably. The user's decision to expand scope stands on the durability argument,
  which does not depend on the contested premise.
- **Resolved by:** evidence
- **Raised in round:** R4
- **Changed in plan:** Implementation Approach (Where the blind-spot disclosure is stated)

## Minor edits

- F19: Corrected a line-range citation for the contradicting missing-artifact step, which is off by one at the start. `han-core:evidence-based-investigator`. Section: Implementation Approach
- F20: Removed the claim that the consumer greps for the table heading; the file names it as a mapping source and hedges it with "or equivalent". `han-core:evidence-based-investigator`. Section: Implementation Approach
- F21: Replaced a literal inline-embed form that does not match the consumer's actual text, which uses ellipsis placeholders, and made fixing that placeholder part of unit 1. `han-core:evidence-based-investigator`. Section: Implementation Approach
- F22: Restored risk-register ID ordering, which the amendment had left out of sequence. `han-core:junior-developer`. Section: Risks and Assumptions
- F23: Corrected the follow-on-check count in the Testing Strategy, which the amendment left at three. `han-core:junior-developer`. Section: Testing Strategy
- F24: Split the manifests between the unit that creates the skill and the final sweep, which two sections had assigned differently. `han-core:junior-developer`. Section: Work Units and Sequencing

### F25: The GitHub widening named two hardcoded locations where three exist

- **Agent:** `han-core:evidence-based-investigator`
- **Category:** overlap with existing code
- **Finding:** The correction applied in R4 named the upload script's asset pattern and the embed rules'
  source-filename requirement as the two places `han-github` hardcodes PNG. A third exists:
  `references/issue-template.md` carries the embed markdown an implementer copies when writing an issue's screenshot
  section, plus a stated path scheme, both ending in `.png`. Widening the upload without widening the template
  produces an issue body that writes a PNG extension over a file that is not one, so the upload succeeds and the image
  still breaks. The skill's own prose describes the same behavior but is descriptive rather than a separate
  enforcement point.
- **Evidence considered:** `han-github/skills/work-items-to-issues/references/issue-template.md` at its embed markdown
  and its path-scheme statement, checked across the whole skill directory rather than the two files already named.
- **Resolution:** Added the third location to the plan's touch-point list and to the decision, with a sentence naming
  why a first pass misses it.
- **Resolved by:** evidence
- **Raised in round:** R5
- **Changed in plan:** Implementation Approach (Visual material, producer and consumer)

### F26: Renumbering the work units broke ten cross-references in the decision log

- **Agent:** `han-core:evidence-based-investigator`
- **Category:** ambiguity
- **Finding:** R4 renumbered the work units to plain integers and swept the plan, but not the decision log's
  `Referenced in plan:` fields. Ten decisions pointed at unit numbers that had shifted, every one off by exactly the
  old-to-new mapping, including the clearest surviving literal reference to the removed letter-suffixed unit. One
  decision also still carried the line range corrected in the plan during the same round.
- **Evidence considered:** Each decision's `Referenced in plan:` field read against the corrected work-unit table.
- **Resolution:** Remapped all ten, corrected the line range, and expanded the copy-grant decision to name all four
  units that now carry it rather than the single unit it had cited.
- **Resolved by:** evidence
- **Raised in round:** R5
- **Changed in plan:** none; the corrections are in the decision log
