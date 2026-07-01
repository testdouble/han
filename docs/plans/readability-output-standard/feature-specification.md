# Feature Specification: Human-Readable Output Standard

A shared, evolvable readability standard that every reader-facing Han skill applies while it writes, so skill output leads with the main point, uses plain language, and reveals detail in layers, and reads consistently across skills instead of being restated skill by skill.

## Outcome

The standard aims for one result: when an operator runs any reader-facing Han skill, the human-facing deliverable it produces can be found, understood, and used by a reader who did not do the work and lacks the author's context.

That aim is pursued, not guaranteed, and it is pursued through observable properties of the text rather than a comprehension score. The output leads with its main point, gives each paragraph one idea with the first sentence carrying it, uses descriptive headings, keeps sentences short and active, prefers common words, and reveals complexity in layers ([the standard's required properties](#what-the-standard-requires)). The observable gate on those properties is the standardized self-check each skill runs before finishing ([D11](artifacts/decision-log.md#d11-the-standardized-self-check-a-bounded-set-of-behaviorally-anchored-criteria)); the standard commits to that check, not to a promise about a reader's comprehension.

Output reads consistently across skills because every reader-facing skill applies **one shared readability rule** as it writes, the same mechanism skills already use for the shared YAGNI and evidence rules ([D1](artifacts/decision-log.md#d1-standard-shape-shared-rule-file-on-the-yagnievidence-model)). A contributor who adds or evolves a reader-facing skill has one source of truth to cite and one place to change the rules, rather than re-deriving plain-language guidance per skill.

## Scope: which skills are reader-facing

A skill is **in scope** when its primary deliverable is human-facing prose that a non-author reads end to end to understand something (a finding, a summary, a plan of record, a document). Thirteen skills meet that test today:

- **han-core:** research, gap-analysis, project-documentation, issue-triage, runbook, architectural-decision-record
- **han-coding:** code-overview, investigate, code-review, architectural-analysis
- **han-reporting:** stakeholder-summary, html-summary
- **han-github:** update-pr-description

Deliberately **out of scope**: skills whose primary output is code (test-driven development, refactoring), a structured specification, plan, or work-item artifact consumed mainly by downstream skills (the feature-planning and work-item skills), or the plugin-building and repository-operations skills. The enumerated list above is authoritative; the inclusion test is the guide a contributor applies when adding a new skill, and the two are kept in sync ([D3](artifacts/decision-log.md#d3-skill-scope-all-thirteen-reader-facing-prose-skills)).

## What the standard requires

The standard's required output properties are named here so a reader of this spec can resolve every referent (for example "the length guidance") without leaving the document. This is the behavioral shape of the rule, not its full authored text, which lives in the shared rule itself.

- **Main point first.** The opening line states the main point (bottom line up front).
- **One idea per paragraph.** Each paragraph carries one idea, with its first sentence carrying the weight.
- **Descriptive headings.** Each heading names its content rather than a generic label, so a reader scanning headings can navigate.
- **Short, active sentences.** Sentences are short (roughly fifteen to twenty words on average) and active by default; the self-check flags any sentence past a soft threshold of about thirty words as a candidate to split, which is a review trigger, not a hard cap ([D7](artifacts/decision-log.md#d7-qualitative-length-guidance-with-a-soft-self-check-flag-not-hard-word-caps)).
- **Common words.** Prefer the common word over the technical synonym; define a term on first use when it cannot be replaced.
- **No blocklisted words.** Reuse the existing vocabulary blocklist ([D6](artifacts/decision-log.md#d6-reuse-the-existing-vocabulary-blocklist-with-skill-local-lists-layered-on-top)) for word-level rules.
- **Progressive disclosure.** Reveal the core first and detail in layers.

The standard is deliberately kept tight. Structural rules that apply to only a minority of in-scope deliverables (for example "conditions before instructions") are left out to keep the applied set small; the selection principle is recorded so the boundary stays legible to a contributor evolving the rule ([D2](artifacts/decision-log.md#d2-layered-enforcement-applied-in-stages-not-as-one-instruction-block)).

## Actors and Triggers

- **Actors:**
  - **The operator** — runs a reader-facing skill and reads the deliverable. The primary beneficiary; experiences more readable, more consistent output.
  - **The skill author / contributor** — wires the standard into a reader-facing skill and evolves the shared rule over time. The contributor reaches the wiring procedure through the project's contributor guide and a per-skill application surface, not the runtime rule ([D12](artifacts/decision-log.md#d12-operator-summary-contributor-front-door-and-concepts-index-placement)).
- **Triggers:**
  - A reader-facing skill runs and begins producing its human-facing deliverable.
  - A contributor adds a new reader-facing skill, or edits the shared readability rule.
- **Preconditions:**
  - The shared readability rule is present in the running skill's plugin (vendored the same way the YAGNI and evidence rules are). No skill is wired to load the rule before its plugin carries the copy ([D9](artifacts/decision-log.md#d9-vendoring-manual-byte-identical-copies-into-the-four-plugins-that-ship-in-scope-skills)).

## Primary Flow

When an in-scope skill produces its deliverable:

1. The skill loads the shared readability rule as it produces its human-facing output. For the skills that already load the shared YAGNI or evidence rules, this reuses an established habit; for the rest, loading a shared rule is new behavior wired for the first time ([D1](artifacts/decision-log.md#d1-standard-shape-shared-rule-file-on-the-yagnievidence-model)).
2. The skill applies an always-on audience frame while drafting: write for a capable reader who did not do this work and lacks the author's context. The five skills whose reader is specifically an engineer (investigate, update-pr-description, code-review, architectural-analysis, project-documentation) each name that audience instead of defaulting, and may scope the frame per section so technical specifics a reader needs are not simplified away ([D10](artifacts/decision-log.md#d10-audience-frame-generalized-with-a-named-audience-per-engineer-facing-skill)).
3. The skill drafts the deliverable into an output template that already carries the standard's structural rules:
   - the main point first,
   - descriptive front-loaded headings,
   - one idea per paragraph with the first sentence carrying the weight,
   - numbered lists for steps and bullets for non-sequential items,
   - detail revealed progressively.
4. The skill runs the standardized plain-language self-check against a bounded set of behaviorally-anchored yes/no criteria before finishing ([D11](artifacts/decision-log.md#d11-the-standardized-self-check-a-bounded-set-of-behaviorally-anchored-criteria)). Anything the self-check fails is corrected before the deliverable is presented. The self-check and any rewrite operate on prose only; code blocks, diagram bodies, rendered markup, and citation identifiers are left unchanged ([D15](artifacts/decision-log.md#d15-the-self-check-and-rewrite-operate-on-prose-regions-only)).
5. The skill presents the finished deliverable.

The rule is applied in stages, never as one large block of instructions: its structural rules shape the template, and its testable criteria run as a discrete self-check after the draft exists. A skill applies one stage at a time ([D2](artifacts/decision-log.md#d2-layered-enforcement-applied-in-stages-not-as-one-instruction-block)).

## Alternate Flows and States

### Synthesis skills run a dedicated readability rewrite pass

- **Entry condition:** The skill has a **synthesis or editor step** — a distinct pass, after the full draft exists, that reviews or consolidates the whole draft before it is presented (whether by dispatching a review agent or running an in-process multi-pass review). By that criterion, the synthesis skills are research, stakeholder-summary, code-overview, gap-analysis (at its consolidated report sizes), code-review, architectural-analysis, project-documentation, investigate, and update-pr-description ([D5](artifacts/decision-log.md#d5-synthesis-skills-run-the-dispatched-rewrite-pass-defined-by-a-single-checkable-criterion)).
- **Sequence:** After the draft is written (Primary Flow step 3) and before the self-check (step 4), the skill dispatches a dedicated readability-editor reviewer that audits and rewrites the draft against a small, behaviorally-anchored rubric, preserving every fact ([D4](artifacts/decision-log.md#d4-a-new-dedicated-readability-editor-reviewer-that-replaces-existing-readability-passes)). A synthesis skill that cannot dispatch an agent today gains that capability as part of wiring the standard in ([D5](artifacts/decision-log.md#d5-synthesis-skills-run-the-dispatched-rewrite-pass-defined-by-a-single-checkable-criterion)). Where a skill already runs a readability pass of its own (code-overview's structure-and-cold-read review; stakeholder-summary's plain-language self-check pass), the dedicated reviewer replaces that readability pass rather than stacking a second one on top ([D4](artifacts/decision-log.md#d4-a-new-dedicated-readability-editor-reviewer-that-replaces-existing-readability-passes)). Any imperative or conditional content carried in from the skill's own source material is delimited so the rewrite treats it as text to preserve, not as instructions to follow.
- **Exit:** The rewritten draft, with every fact preserved, continues to the self-check and is presented.

### Non-synthesis skills apply the rule inline only

- **Entry condition:** The skill has no synthesis or editor step. By the criterion above, this covers html-summary, issue-triage, runbook, and architectural-decision-record.
- **Sequence:** The skill applies the template, audience frame, and self-check (Primary Flow) but dispatches no dedicated readability reviewer. The self-check's fact-preservation criterion is the fidelity guard on these skills' output, since no rewrite pass runs ([D11](artifacts/decision-log.md#d11-the-standardized-self-check-a-bounded-set-of-behaviorally-anchored-criteria)).
- **Exit:** The deliverable is presented after the self-check.

### A contributor adds a new reader-facing skill

- **Entry condition:** A contributor is authoring a new skill whose primary deliverable is human-facing prose (per the inclusion test).
- **Sequence:** The contributor follows the wiring procedure from its named home: embed the structural rules in the skill's output template, have the skill load and apply the shared rule, and add the standardized self-check. If the new skill has a synthesis or editor step, the contributor also wires the dispatched rewrite pass and adds the skill to the in-scope enumeration ([D3](artifacts/decision-log.md#d3-skill-scope-all-thirteen-reader-facing-prose-skills)).
- **Exit:** The new skill produces output under the standard with no per-skill re-statement of the rules.

### The shared rule evolves

- **Entry condition:** A contributor changes the readability rule.
- **Sequence:** The contributor edits the canonical copy, then copies it byte-for-byte into each of the four plugins that ship an in-scope skill ([D9](artifacts/decision-log.md#d9-vendoring-manual-byte-identical-copies-into-the-four-plugins-that-ship-in-scope-skills)). The operator-facing summary is updated to match.
- **Exit:** Every in-scope skill applies the updated rule on its next run.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
|-----------|-------------------|
| The deliverable is inherently technical (e.g., investigate's root-cause finding). | The standard governs *how* the content is said — lead with the answer, plain framing, progressive disclosure — not whether necessary technical facts appear. No required technical fact is removed to satisfy the standard, and the self-check's fact-preservation criterion enforces this on non-synthesis skills that have no rewrite pass. |
| The readability pass or audience frame would drop a fact to read more simply. | Fidelity wins. Every fact in the draft is preserved: every claim, quantity, named entity, and stated condition or qualifier survives with its precision intact. Flattening "exceeded 340ms in three of ten windows" to "was sometimes slow," or "only when X and Y both hold" to "generally," is a fidelity failure, not a simplification ([D11](artifacts/decision-log.md#d11-the-standardized-self-check-a-bounded-set-of-behaviorally-anchored-criteria)). |
| The self-check is asked to judge subjective clarity. | The self-check evaluates concrete, behaviorally-anchored yes/no criteria (see [D11](artifacts/decision-log.md#d11-the-standardized-self-check-a-bounded-set-of-behaviorally-anchored-criteria)), never "is this clear?" |
| The deliverable mixes prose with code blocks, diagrams, rendered markup, or citation identifiers. | The self-check and rewrite operate on prose regions only. Content inside code fences, diagram bodies, rendered markup, and inline citation identifiers is neither evaluated nor altered; citation identifiers in particular survive the rewrite unchanged so they still resolve to their registry ([D15](artifacts/decision-log.md#d15-the-self-check-and-rewrite-operate-on-prose-regions-only)). |
| The audience frame conflicts with a skill whose real reader is an expert. | The skill names its actual reader (an engineer, a pull-request reviewer) instead of the default frame, and may scope the frame per section so technical specifics a reader needs are not simplified away ([D10](artifacts/decision-log.md#d10-audience-frame-generalized-with-a-named-audience-per-engineer-facing-skill)). |
| A skill already runs its own readability pass or plain-language self-check. | The standard's dispatched reviewer replaces the skill's existing readability pass, and the standardized self-check subsumes the skill's existing plain-language pass, so the deliverable gets one readability review, not two conflicting ones ([D4](artifacts/decision-log.md#d4-a-new-dedicated-readability-editor-reviewer-that-replaces-existing-readability-passes)). |
| A skill enforces its own word-level blocklist that overlaps the shared one. | The shared blocklist is authoritative for the words it covers; a skill's own list is kept only for the domain-specific terms the shared list does not cover, layered on top rather than duplicating it ([D6](artifacts/decision-log.md#d6-reuse-the-existing-vocabulary-blocklist-with-skill-local-lists-layered-on-top)). |
| A skill's output is a durable committed file, not ephemeral text (project-documentation). | The standard applies at generation time. A committed document is written readable, but a later manual edit or partial re-run is not re-checked against the rule; that is an accepted gap, not a guarantee the file stays conformant forever ([D16](artifacts/decision-log.md#d16-the-standard-applies-at-generation-time-only)). |
| The rule is large enough that applying it all at once would degrade compliance. | The rule is applied in stages (template, then a discrete self-check), never as a single stacked instruction block ([D2](artifacts/decision-log.md#d2-layered-enforcement-applied-in-stages-not-as-one-instruction-block)). |
| Source material the rewrite pass reads contains imperative or conditional prose. | That content is delimited so the rewrite treats it as text to preserve, not as instructions to follow. |
| A vendored copy of the rule diverges from, or is missing against, the canonical copy. | The copies must be byte-identical, and no skill is wired to load the rule before its plugin carries the copy; divergence or a missing copy is a rollout defect, held to the same discipline as the YAGNI and evidence rule copies ([D9](artifacts/decision-log.md#d9-vendoring-manual-byte-identical-copies-into-the-four-plugins-that-ship-in-scope-skills)). |
| A skill loads the rule but its other instructions crowd it out. | Loading does not guarantee compliance; the template, the audience frame, and the self-check are what make the rule take effect, not loading alone ([D1](artifacts/decision-log.md#d1-standard-shape-shared-rule-file-on-the-yagnievidence-model)). |

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
|---------------------|-----------|-------------|-----------------------------------|
| Shared readability rule | inbound | Each in-scope skill loads and applies the rule as it produces output. | The rule must be present in the skill's plugin before the skill is wired to load it. |
| Vocabulary blocklist (the existing writing-voice profile) | outbound | The readability rule points skills at the existing blocklist for word-level rules instead of duplicating them ([D6](artifacts/decision-log.md#d6-reuse-the-existing-vocabulary-blocklist-with-skill-local-lists-layered-on-top)). | The blocklist becomes relevant to skill output at runtime for the first time; it continues to govern operator documentation unchanged. Skill-local word lists supplement it, never override it. |
| Dedicated readability-editor reviewer | outbound | Synthesis skills dispatch the reviewer for the rewrite pass, replacing any readability pass they run today ([D4](artifacts/decision-log.md#d4-a-new-dedicated-readability-editor-reviewer-that-replaces-existing-readability-passes)). | Runs after the draft exists and before the self-check. Synthesis skills without dispatch capability gain it. |
| Canonical rule copy and its per-plugin copies | outbound | The canonical copy lives with the other shared rules in the core plugin's references ([D13](artifacts/decision-log.md#trivial-decisions)) and is duplicated byte-for-byte into the four plugins that ship in-scope skills: core, coding, reporting, and github ([D9](artifacts/decision-log.md#d9-vendoring-manual-byte-identical-copies-into-the-four-plugins-that-ship-in-scope-skills)). | All copies stay byte-identical. The reporting and github plugins receive a shared-rule reference for the first time. |
| Operator summary, contributor guide, and concepts index | outbound | A plain-language operator summary of the rule sits beside the existing YAGNI and evidence summaries and is named to match them ([D14](artifacts/decision-log.md#trivial-decisions)); the contributor guide and a per-skill application surface carry the wiring procedure; the concepts index lists readability as a distinct output-quality standard, not as a fourth universal decision mechanic ([D12](artifacts/decision-log.md#d12-operator-summary-contributor-front-door-and-concepts-index-placement)). | The summary mirrors the structure of the existing summaries and is updated when the rule changes. The concepts index framing is updated to place readability in its own category. |

## Out of Scope

- **CI or prose-linting enforcement over produced output.** Most reader-facing skill output is ephemeral conversational or scratch text with no build surface to lint; even the one in-scope skill that writes a committed file is covered only at generation time ([D8](artifacts/decision-log.md#d8-readability-formulas-and-linting-are-not-the-enforcement-mechanism), [D16](artifacts/decision-log.md#d16-the-standard-applies-at-generation-time-only)).
- **Controlled-language systems** (a fixed approved-word list with hard length caps). High authoring cost, stilted output unfit for analytical deliverables, and cannot be auto-applied to existing prose.
- **A readability-formula score as the standard's target or spine.** Formulas are weak comprehension proxies that reward gaming; they are not the measure the standard optimizes ([D8](artifacts/decision-log.md#d8-readability-formulas-and-linting-are-not-the-enforcement-mechanism)).
- **Changing the operator-documentation voice profile.** The existing voice profile continues to govern operator docs; this feature reuses its blocklist but does not rewrite it.
- **Skills whose primary output is not human-facing prose** — code-writing skills, and the specification, plan, work-item, and coding-standard skills whose output is a governed structured artifact (see [Scope](#scope-which-skills-are-reader-facing)).

## Deferred (YAGNI)

### Readability-formula diagnostic (Flesch / grade level) as an optional one-glance check

- **Why deferred:** Fails the evidence test. No operator has asked for a numeric readability diagnostic, and the formulas are documented as poor comprehension proxies ([D8](artifacts/decision-log.md#d8-readability-formulas-and-linting-are-not-the-enforcement-mechanism)); including one now would be speculative machinery.
- **Reopen when:** An operator asks for a rough numeric diagnostic, or a measured case shows the qualitative self-check is missing a class of unreadable output a formula would catch.
- **Source:** Research report option O6; conversation.

### Automated sync of the vendored rule copies

- **Why deferred:** Simpler-version test. Manual byte-for-byte copying matches how the YAGNI and evidence rules are already vendored; a build-step sync is more machinery than the current pattern needs.
- **Reopen when:** A vendored copy is observed to have drifted from, or gone missing against, the canonical copy in practice.
- **Source:** Simpler-version test against the existing vendoring pattern.

## Open Items

None. Both items raised during specification were resolved by the user: investigate and update-pr-description are classified as synthesis skills ([D5](artifacts/decision-log.md#d5-synthesis-skills-run-the-dispatched-rewrite-pass-defined-by-a-single-checkable-criterion)), and each engineer-facing skill names its audience ([D10](artifacts/decision-log.md#d10-audience-frame-generalized-with-a-named-audience-per-engineer-facing-skill)).

## Summary

- **Outcome delivered:** Every reader-facing Han skill produces output a non-author reader can find, understand, and use, by applying one shared readability rule as it writes.
- **Primary actors:** The operator who reads skill output; the contributor who wires and evolves the standard.
- **Decisions settled by evidence:** 11 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 5 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, information-architect, test-engineer, edge-case-explorer — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** A testable scope boundary and an explicit synthesis criterion replaced two ill-defined category words; the self-check became a bounded criteria set with a fact-preservation check; the audience frame was generalized; prose-only scoping, generation-time-only coverage, and existing-pass replacement were added — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0
</content>
