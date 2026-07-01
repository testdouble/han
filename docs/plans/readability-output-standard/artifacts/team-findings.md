# Team Findings: Human-Readable Output Standard

This file records every finding raised by the review team for the Human-Readable Output Standard, and how each was resolved. Behavioral outcomes live in [../feature-specification.md](../feature-specification.md); decisions the findings affected live in [decision-log.md](decision-log.md). No `feature-technical-notes.md` exists for this feature: no load-bearing mechanic qualified, because the vendoring and runtime-loading mechanics are both discoverable from the existing YAGNI/evidence rule pattern in the repo.

**Review team (feature size: Large):** junior-developer, information-architect, test-engineer, edge-case-explorer. Each reviewed the draft at the behavioral level under a domain-scoped brief. Findings below are the deduplicated, consolidated set; several were raised independently by more than one agent, which is noted.

Findings are classified **major** (changes a behavioral commitment, edge-case rule, alternate flow, failure mode, coordination, or is a "mechanics leaking into spec" finding) or **minor** (wording, naming, formatting, citation cleanup).

## Major findings

### F1: "Reader-facing prose skill" is not a testable boundary

- **Agent:** junior-developer (corroborated by information-architect on the classification gap)
- **Finding:** Scope was an enumerated list of eight skills with no membership test. Five other skills produce human-facing prose reports (code-review, architectural-analysis, issue-triage, runbook, architectural-decision-record) and were silently excluded; a contributor adding a new skill would have no rule to self-classify it, reintroducing the per-skill judgment the standard exists to remove.
- **Resolution:** Escalated to the user, who chose to include all thirteen prose-producing skills now. Added a written inclusion test and an authoritative enumerated list kept in sync with it (Scope section).
- **Resolved by:** user input
- **Affected decisions:** D3
- **Changed in spec:** Scope (new section), Alternate Flows and States, Out of Scope, Summary

### F2: "Synthesis skill" rested on three inconsistent criteria

- **Agent:** junior-developer (corroborated by information-architect)
- **Finding:** The three synthesis skills were justified by three different properties ("has an agent step" for two, "has an internal self-check" for the third), so the category that decides which skills get the rewrite pass was not checkable.
- **Resolution:** Defined a single checkable criterion — a distinct pass, after the full draft exists, that reviews or consolidates the whole draft before presenting it — and re-derived the synthesis set from it.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Changed in spec:** Alternate Flows and States (entry conditions)

### F3: stakeholder-summary has no agent-dispatch capability for the rewrite pass

- **Agent:** junior-developer and edge-case-explorer (independently)
- **Finding:** D4 makes the rewrite pass an agent dispatch, but stakeholder-summary's tool surface has no Agent capability; its synthesis is the in-process Pass A/B/C. The rewrite pass as specified was unsatisfiable for one of the three named synthesis skills.
- **Resolution:** Escalated to the user, who chose to give in-process-synthesis skills dispatch capability rather than fold the review into their existing self-check. The spec now states that a synthesis skill lacking dispatch capability gains it as part of wiring the standard in.
- **Resolved by:** user input
- **Affected decisions:** D5
- **Changed in spec:** Alternate Flows and States (synthesis sequence), Coordinations

### F4: The dedicated reviewer's interaction with existing readability passes was unspecified

- **Agent:** junior-developer, information-architect, edge-case-explorer (independently)
- **Finding:** code-overview already dispatches information-architect + junior-developer for a readability pass, and stakeholder-summary already runs a plain-language self-check pass. The spec added a new reviewer and a new self-check without saying whether they replace, wrap, or stack on the existing passes, risking double-review with conflicting verdicts.
- **Resolution:** The dedicated reviewer replaces a skill's existing readability pass, and the standardized self-check subsumes a skill's existing plain-language pass, so a deliverable gets one readability review.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Changed in spec:** Alternate Flows and States, Coordinations, Edge Cases and Failure Modes

### F5: "The same way it already loads the YAGNI and evidence rules" was over-general

- **Agent:** junior-developer
- **Finding:** Of the eight originally-scoped skills, only research, investigate, and gap-analysis reference the shared rules on disk. For the rest, loading a shared rule is new behavior, not a mirror of existing behavior; the analogy overstated the current state.
- **Resolution:** Reworded Primary Flow step 1 to distinguish skills that already load shared rules from those gaining the behavior, and treat the latter as new wiring.
- **Resolved by:** evidence
- **Affected decisions:** D1
- **Changed in spec:** Primary Flow (step 1)

### F6: han-reporting and han-github vendor no shared rule today

- **Agent:** junior-developer
- **Finding:** D9's "same way the YAGNI and evidence rules are already vendored" holds for two of the four target plugins. han-reporting and han-github have no `references/` directory at all, so they receive a shared-rule reference for the first time — unstated setup work.
- **Resolution:** D9 and Coordinations now note that reporting and github receive a shared-rule reference for the first time; the mechanism is proven even though the target is new for those two.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Changed in spec:** Coordinations

### F7: The always-on audience frame mis-fits skills whose readers are experts

- **Agent:** junior-developer, edge-case-explorer, information-architect (independently)
- **Finding:** "Write for a smart non-expert who has not seen the code" is wrong for update-pr-description (read by reviewers who see the code), investigate (read by engineers implementing the fix), and project-documentation (whose own stated audience is technically literate). The single frame steers those skills away from their real reader.
- **Resolution:** Generalized the frame to "a capable reader who did not do this work and lacks the author's context." The per-skill sharpening was first left as an open item, then resolved by the user: each of the five engineer-facing skills now names its audience in D10, and no open items remain.
- **Resolved by:** evidence
- **Affected decisions:** D10
- **Changed in spec:** Primary Flow (step 2), Edge Cases and Failure Modes, Open Items

### F8: html-summary's rendered output does not fit a prose-sentence self-check

- **Agent:** junior-developer
- **Finding:** html-summary produces an HTML deliverable whose readability is substantially visual/structural, but the self-check anchors are prose-sentence-shaped, so the check would either be skipped or produce false passes for one in-scope skill.
- **Resolution:** Scoped the self-check and rewrite to prose regions only (D15); html-summary's self-check applies to its prose content, and its visual layout stays governed by its existing layout conventions.
- **Resolved by:** evidence
- **Affected decisions:** D15
- **Changed in spec:** Primary Flow (step 4), Edge Cases and Failure Modes

### F9: The spec leaked prompt-delivery mechanics into behavioral sentences

- **Agent:** junior-developer (corroborated by information-architect)
- **Finding:** Primary Flow described "do/don't pairs handed to the model as examples," "few-shot," and "one layer at a time" — how the rule is delivered to the model, not what behavior is guaranteed. This is a mechanics-leaking-into-spec issue.
- **Resolution:** Removed the few-shot/exemplar mechanic from the spec's behavioral sentences; kept the behavioral commitment that the rule is applied in stages, not one block. The delivery mechanism is an implementation choice recorded in D2's rejected alternatives.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Changed in spec:** Primary Flow (closing paragraph), What the standard requires

### F10: "Preserve every fact" was asserted but unverifiable and uncovered by the self-check

- **Agent:** test-engineer and information-architect (independently; the highest-risk finding for both)
- **Finding:** The rewrite pass and the fidelity edge case commit to "preserving every fact" and call dropping one a failure, but "fact" was never defined, no comparison mechanism was named, and the self-check's illustrated criteria were all readability-positive — none could observe a dropped fact. The spec asserted an enforcement path (self-check) its own definition of the self-check did not cover, worst on the non-synthesis skills that have no rewrite pass at all.
- **Resolution:** Added a fact-preservation criterion to the bounded self-check (D11, criterion 6) and defined "fact" concretely: every claim, quantity, named entity, and stated condition or qualifier. Narrowed the fidelity edge-case rows to reference that criterion.
- **Resolved by:** evidence
- **Affected decisions:** D11
- **Changed in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### F11: The self-check was illustrated, not bounded, and left structural rules unchecked

- **Agent:** test-engineer and information-architect (independently)
- **Finding:** D11 and the spec gave three parenthetical examples of self-check criteria with no statement of whether the set was complete. The structural rules the spec commits to (one idea per paragraph, descriptive headings, progressive disclosure) had no matching self-check criterion, and the research names structural rules the most-corroborated layer, so the self-check under-covered its own most important layer.
- **Resolution:** Enumerated the self-check as a bounded six-criterion set including descriptive-heading and paragraph-lead checks (the highest-value template-unguaranteeable structural properties), while keeping the set small to respect D2.
- **Resolved by:** evidence
- **Affected decisions:** D11
- **Changed in spec:** Primary Flow (step 4), What the standard requires

### F12: The sentence-length self-check contradicted the qualitative length guidance

- **Agent:** test-engineer
- **Finding:** D7 rejects a hard cap and sets a qualitative average, but D11 asks the self-check to answer yes/no to "does any sentence exceed the length guidance?" A qualitative average has no per-sentence threshold, so the self-check could not answer consistently — an internal tension between two decisions.
- **Resolution:** Added a soft self-check flag (about thirty words) as a review trigger, distinct from a hard cap, reconciling D7 and D11.
- **Resolved by:** evidence
- **Affected decisions:** D7, D11
- **Changed in spec:** What the standard requires

### F13: The top-level Outcome claim had no verification path

- **Agent:** test-engineer
- **Finding:** The Outcome promised a deliverable "can be found, understood, and used by a smart non-expert," a comprehension claim about a hypothetical reader with no stated observable measure (and D8 correctly rules out a formula proxy). The headline promise was only as verifiable as its weakest sub-commitment.
- **Resolution:** Reframed the Outcome as an aim pursued through observable text properties, with the standardized self-check named as the observable gate; the standard commits to the check, not to a comprehension guarantee.
- **Resolved by:** evidence
- **Affected decisions:** — (Outcome framing; no single decision)
- **Changed in spec:** Outcome

### F14: The self-check and rewrite had no boundary between prose and non-prose regions

- **Agent:** edge-case-explorer
- **Finding:** Several deliverables interleave prose with code fences, diagram bodies, HTML markup, and citation identifiers whose exact syntax matters (research's citation IDs must resolve to a registry). A sentence-shaped self-check and a prose rewrite defined with no prose/non-prose rule would corrupt those regions or break resolvability.
- **Resolution:** Added D15 — the self-check and rewrite operate on prose regions only; code, diagrams, markup, and citation identifiers are neither evaluated nor altered, and citation identifiers survive the rewrite unchanged.
- **Resolved by:** evidence
- **Affected decisions:** D15
- **Changed in spec:** Primary Flow (step 4), Edge Cases and Failure Modes

### F15: Fact preservation did not cover precision or qualifier flattening

- **Agent:** edge-case-explorer
- **Finding:** A rewrite can preserve a fact's topic while flattening its precision ("340ms in three of ten windows" to "sometimes slow," "only when X and Y" to "generally"), changing the truth-value while keeping the subject present.
- **Resolution:** Extended the fidelity commitment and D11's criterion 6 to cover quantities, conditionals, and scope qualifiers, not just topical presence.
- **Resolved by:** evidence
- **Affected decisions:** D11
- **Changed in spec:** Edge Cases and Failure Modes

### F16: project-documentation writes a committed file, contradicting the out-of-scope rationale

- **Agent:** edge-case-explorer
- **Finding:** The out-of-scope rationale rules out CI linting because output is "ephemeral... not committed files," but project-documentation writes a committed, later-editable repository document, and nothing re-verifies it after a manual edit.
- **Resolution:** Added D16 — the standard applies at generation time; a committed file is written readable but a later edit is not re-checked, stated as an accepted gap. Refined the out-of-scope wording accordingly.
- **Resolved by:** evidence
- **Affected decisions:** D16
- **Changed in spec:** Out of Scope, Edge Cases and Failure Modes

### F17: The vendoring edge case covered divergence but not absence

- **Agent:** edge-case-explorer
- **Finding:** The vendoring-drift row addressed a diverged copy but not a missing one, a real sequencing risk during a rollout that adds rule references to thirteen skills across four plugins non-atomically.
- **Resolution:** Extended D9 and the edge-case row: no skill is wired to load the rule before its plugin carries the copy; a missing copy is a rollout defect.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Changed in spec:** Preconditions, Edge Cases and Failure Modes

### F18: Skill-local word-level blocklists overlap the shared one

- **Agent:** edge-case-explorer
- **Finding:** stakeholder-summary and html-summary already carry their own banned-word lists that partially overlap the shared blocklist D6 points to, and D6/D9 addressed only the shared rule's copies, not a skill's own pre-existing list drifting from or duplicating the shared one.
- **Resolution:** D6 now states the shared blocklist is authoritative for the words it covers; a skill's own list is kept only for domain-specific terms the shared list does not cover, layered on top. Added an edge-case row.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Changed in spec:** Coordinations, Edge Cases and Failure Modes

### F19: Appending readability to the concepts index ignored its "whole model" frame

- **Agent:** information-architect
- **Finding:** The concepts index frames sizing/YAGNI/evidence as "the whole model," each a near-universal decision mechanic. Readability is a different kind of thing — an output standard scoped to prose skills — so appending it as a fourth peer would over-state its scope or leave it an orphan.
- **Resolution:** D12 now places readability in the concepts index as a distinct output-quality standard, not a fourth universal mechanic, and updates the "whole model" framing to make room for output standards as a separate category.
- **Resolved by:** evidence
- **Affected decisions:** D12
- **Changed in spec:** Coordinations

### F20: The contributor audience had no named front door

- **Agent:** information-architect
- **Finding:** The spec names the contributor as an actor with a four-layer wiring task but gives only the operator a home (summary + concepts index). The wiring knowledge was homeless; the runtime rule carries output rules, not wiring steps.
- **Resolution:** D12 names the contributor's front door: the project contributor guide plus a per-skill application surface analogous to the YAGNI application table. Reflected in Actors and Triggers and Coordinations.
- **Resolved by:** evidence
- **Affected decisions:** D12
- **Changed in spec:** Actors and Triggers, Coordinations

### F21: gap-analysis was misclassified as non-synthesis

- **Agent:** information-architect (corroborated by edge-case-explorer, which flagged gap-analysis's inline plain-language translation)
- **Finding:** gap-analysis runs a project-manager consolidation step at medium and large sizes — a synthesis/editor step — yet the draft classified it as non-synthesis, so its consolidation (the natural place a fidelity-preserving rewrite would extend) would omit the rewrite pass.
- **Resolution:** Re-derived the classification against the single criterion in D5; gap-analysis is a synthesis skill at its consolidated report sizes and runs the rewrite pass there.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Changed in spec:** Alternate Flows and States

### F22: The structural rule set was pared without a recorded rationale

- **Agent:** information-architect
- **Finding:** A most-corroborated structural rule from the cited source ("conditions before instructions") was dropped while a same-source sibling was kept, with no recorded selection principle, so a contributor evolving the rule could not tell whether the omission was deliberate.
- **Resolution:** Recorded the selection principle in D2 and the What-the-standard-requires section: the applied set is kept tight, and rules applicable to only a minority of in-scope deliverables are left out.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Changed in spec:** What the standard requires

### F23: The new dedicated reviewer is a YAGNI candidate with a simpler reuse alternative

- **Agent:** junior-developer and information-architect (independently)
- **Finding:** A strictly simpler version of the reviewer already exists — the information-architect + junior-developer readability pass code-overview runs — and D4's own rejected-alternative note records it as the lower-cost fallback. The new agent passes the YAGNI evidence gate on user input, but the cost of a net-new maintained agent should be a conscious choice, not a default.
- **Resolution:** Kept the new reviewer on the operator's explicit request (a user-described need, acceptable evidence), and recorded the simpler reuse path in D4's rejected alternatives with the "make the cost conscious" framing. Coupled with F4's replacement disposition, the new reviewer takes over the existing pattern rather than adding to it.
- **Resolved by:** user input
- **Affected decisions:** D4
- **Changed in spec:** — (decision-log rationale only)

## Minor edits

- F24: The spec leaked its own standard in places — Primary Flow step 3 rendered non-sequential rules as an inline comma list, the opening sentence was long and used an em-dash, and the Outcome packed multiple ideas into one paragraph. — information-architect — Fixed in the spec rewrite (step 3 is now a bulleted list; opening and Outcome tightened).
- F25: "Clearly delimited" (source material carried into the rewrite pass) has no stated criterion for what counts as delimited. — test-engineer — Left as a behavioral consequence (source prose is preserved, not executed as instructions); the delimiting mechanism is an implementation detail for plan-implementation. — Alternate Flows and States.
</content>
