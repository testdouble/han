# Decision Log: Human-Readable Output Standard

This file records every decision settled while specifying the Human-Readable Output Standard. Behavioral statements live in [../feature-specification.md](../feature-specification.md); this file captures the history, rationale, evidence, and rejected alternatives for each decision.

Evidence sources draw on two trust classes: **codebase** (the trusted current-state anchor, files on disk in this repo) and **web** (the research report's external sources, outside the trust boundary, carried at the strength the report assigned). The research report is at `docs/research/human-readable-output-standard.md`; its source IDs (A1, A24, etc.) are cited where a decision rests on them. Review-team findings are in [team-findings.md](team-findings.md).

## Trivial decisions

- D13: Canonical location of the rule — the rule's canonical copy lives with the other shared rules in the core plugin's references, alongside `yagni-rule.md` and `evidence-rule.md`. — Referenced in spec: Coordinations.
- D14: Naming follows the existing pattern — the rule is named to match `yagni-rule.md` / `evidence-rule.md`, and its operator summary matches `docs/yagni.md` / `docs/evidence.md` (considered a novel name; rejected because the value is recognizability as a sibling of the existing rules). — Referenced in spec: Coordinations.

## Full decisions

### D1: Standard shape: shared rule file on the YAGNI/evidence model

- **Question:** How should the readability standard be delivered — as one shared rule that every reader-facing skill applies, as per-skill restated guidance with no shared file, or as a docs-only concept re-implemented per skill (the sizing model)?
- **Decision:** One shared readability rule that reader-facing skills load and apply at runtime, the same way they use the shared YAGNI and evidence rules. Output stays consistent because the rules live in one place, not because each skill restates them.
- **Rationale:** Han already ships this mechanism and it has runtime grip: `docs/yagni.md` states that "every YAGNI-aware skill and agent loads that file at runtime," and skill steps direct the executor to read and apply the referenced rule by relative link. The operator asked for a shared, evolvable reference, which is itself acceptable evidence. A single source of truth is easier to keep current than the same rules re-stated per skill. Loading does not by itself guarantee compliance, so the template, audience frame, and self-check carry the rule into effect (see D2).
- **Evidence:** codebase — `han-core/references/yagni-rule.md`, `han-core/references/evidence-rule.md`, `docs/yagni.md:13`; research recommendation and A53, A57. User input. Finding F5 corrected the claim that every in-scope skill already loads shared rules: only research, investigate, and gap-analysis do today, so for the rest loading is new behavior, now stated as such in Primary Flow step 1.
- **Rejected alternatives:**
  - Per-skill restated guidance with no shared file (research option O3) — rejected because it omits the single evolvable source of truth the operator asked for, and each skill re-derives the rules. The drift this risks is plausible but un-measured, so O3 is the honest lower-cost alternative rather than a defeated one.
  - Docs-only concept re-implemented per skill, like sizing — rejected because sizing has no shared rule file and no runtime loading; it would not give the standard runtime grip.
- **Linked technical notes:** —
- **Driven by findings:** F5
- **Dependent decisions:** D2, D9, D12
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D2: Layered enforcement, applied in stages, not as one instruction block

- **Question:** How does a skill apply a rule of roughly eight to twelve items without reproducing the "curse of instructions," where compliance decays as simultaneous instructions stack up?
- **Decision:** The rule is never fired as one instruction block. Its structural rules shape each skill's output template, and its testable criteria run as a discrete self-check after the draft exists. A skill applies one stage at a time. The applied rule set is kept deliberately tight; structural rules that apply to only a minority of in-scope deliverables (for example "conditions before instructions") are left out, and that selection principle is recorded so the boundary stays legible.
- **Rationale:** Compliance with a stacked instruction set drops sharply as the count rises; splitting the work across a template and a separate check keeps each step's constraint count low.
- **Evidence:** web (via research report) — A24 (curse of instructions), A23 (per-constraint decomposition). codebase — several skills already embed structural rules in their output templates. Finding F9 removed prompt-delivery mechanics (few-shot exemplars, "handed to the model as examples") from the spec's behavioral sentences; that mechanism is an implementation choice, not a spec commitment. Finding F22 required recording why the structural set was pared.
- **Rejected alternatives:**
  - Load the whole rule as a single instruction block each run — rejected because it reproduces the exact failure the rule is meant to dodge.
  - Prescribe the few-shot exemplar delivery in the spec — rejected as an implementation mechanic; it belongs to the rule's authoring and the implementation plan, not the behavioral spec.
- **Linked technical notes:** —
- **Driven by findings:** F9, F22
- **Dependent decisions:** D11
- **Referenced in spec:** What the standard requires, Primary Flow, Edge Cases and Failure Modes

### D3: Skill scope: all thirteen reader-facing prose skills

- **Question:** Which reader-facing skills does the standard commit to wiring now, and is "reader-facing prose skill" a testable boundary?
- **Decision:** All thirteen skills whose primary deliverable is human-facing prose a non-author reads end to end: research, gap-analysis, project-documentation, issue-triage, runbook, architectural-decision-record, code-overview, investigate, code-review, architectural-analysis, stakeholder-summary, html-summary, and update-pr-description. A written inclusion test guides which future skills join; the enumerated list is authoritative and kept in sync with the test.
- **Rationale:** The operator chose to include the five additional prose-producing skills the review team surfaced (code-review, architectural-analysis, issue-triage, runbook, architectural-decision-record) on top of the eight originally scoped. The review team showed that an enumerated list with no test reintroduces the per-skill judgment the standard exists to remove, so a test accompanies the list.
- **Evidence:** User input (both interview rounds). codebase — the current-state audit of each skill's SKILL.md confirms all thirteen produce human-facing prose reports; the excluded skills produce code or governed structured artifacts.
- **Rejected alternatives:**
  - The eight originally-scoped skills, deferring the other five — rejected on the operator's choice to include all thirteen now.
  - An enumerated list with no inclusion test — rejected because a contributor adding a new skill would have no way to self-classify it, which the review team flagged as reintroducing per-skill drift.
- **Linked technical notes:** —
- **Driven by findings:** F1
- **Dependent decisions:** D5
- **Referenced in spec:** Scope, Alternate Flows and States

### D4: A new dedicated readability-editor reviewer that replaces existing readability passes

- **Question:** How is the editor-agent readability pass provided — by reusing the two existing prose reviewers, or by a new dedicated reviewer — and how does it interact with the readability passes some skills already run?
- **Decision:** A new dedicated readability-editor reviewer that audits and rewrites a draft against a small, behaviorally-anchored rubric, preserving every fact. Where a synthesis skill already runs a readability pass of its own (code-overview's structure-and-cold-read review; stakeholder-summary's plain-language self-check pass), the dedicated reviewer replaces that pass rather than stacking a second one on top.
- **Rationale:** The operator chose a dedicated reviewer over reusing the existing two. A tight rubric with concrete yes/no anchors gives targeted feedback and guards against the unreliability of ungrounded prose judging. The review team found that two of the most central skills already run readability passes, so the spec had to state replacement to avoid double-review with conflicting verdicts.
- **Evidence:** User input. web (via research report) — A30 (ungrounded self-judging is unreliable; anchors required), A50 (rubrics need three to six behaviorally-anchored dimensions). codebase — code-overview dispatches `information-architect` + `junior-developer` for a readability pass today (the pattern this reviewer generalizes and replaces); stakeholder-summary runs a Pass A/B/C self-check.
- **Rejected alternatives:**
  - Reuse the existing `information-architect` + `junior-developer` reviewers, as code-overview does today — rejected on the operator's choice. Recorded here because it is the strictly simpler version that satisfies the same evidence; the review team (F23) flagged the new agent as a YAGNI candidate resolved by the operator's explicit request, so the maintenance cost of a net-new agent is a conscious choice, not a default.
  - Add the dedicated reviewer alongside a skill's existing readability pass — rejected because it produces double-review and conflicting recommendations on one draft.
- **Linked technical notes:** —
- **Driven by findings:** F4, F23
- **Dependent decisions:** D5
- **Referenced in spec:** Alternate Flows and States, Coordinations, Edge Cases and Failure Modes

### D5: Synthesis skills run the dispatched rewrite pass, defined by a single checkable criterion

- **Question:** Where does the dedicated "rewrite for readability, preserve every fact" pass run, and how is that set of skills defined so a contributor can classify a skill unambiguously?
- **Decision:** The rewrite pass runs in skills that have a **synthesis or editor step** — a distinct pass, after the full draft exists, that reviews or consolidates the whole draft before it is presented, whether by dispatching a review agent or running an in-process multi-pass review. By that single criterion the synthesis skills are research, stakeholder-summary, code-overview, gap-analysis (at its consolidated report sizes), code-review, architectural-analysis, project-documentation, investigate, and update-pr-description; the operator confirmed the last two count, since each already dispatches an agent after the draft exists (a correctness validator; a description writer) that hosts the readability pass. A synthesis skill that cannot dispatch an agent today (stakeholder-summary) gains that capability as part of wiring the standard in, so all synthesis skills run the dedicated reviewer uniformly. Every other in-scope skill (html-summary, issue-triage, runbook, architectural-decision-record) applies the template, audience frame, and self-check but runs no rewrite pass.
- **Rationale:** The research recommendation softens a mandatory two-pass to "where a skill already synthesizes"; a mandatory rewrite everywhere adds cost and over-simplification risk with little gain. The review team showed the original three-skill list rested on three inconsistent criteria and misclassified gap-analysis (which has a consolidation step) as non-synthesis, so a single checkable property replaced the ad hoc list. The operator chose to give in-process-synthesis skills dispatch capability rather than fold the review into their existing self-check, so the mechanism is uniform.
- **Evidence:** User input (dispatch-capability choice). web (via research report) — A22, A23 (two-pass payoff), A29 (readability/accuracy tension on dense content). codebase — code-overview's Step 7 agent pass; stakeholder-summary's multi-pass self-check; gap-analysis's project-manager consolidation at medium/large (`docs/concepts.md:62`); research's report synthesis.
- **Rejected alternatives:**
  - A mandatory rewrite pass in every reader-facing skill — rejected because the added cost and over-simplification risk are not justified where no synthesis step exists.
  - Defining the synthesis set by "already dispatches an agent" — rejected because it misclassifies stakeholder-summary (in-process synthesis, no dispatch) and would exclude it against the operator's intent.
  - Folding the review into stakeholder-summary's existing self-check instead of granting dispatch capability — rejected on the operator's choice for uniform dispatch.
  - Classing investigate and update-pr-description as non-synthesis (self-check only) — this was the draft's default and the subject of open item OI-1; the operator resolved it by confirming both count as synthesis skills.
- **Linked technical notes:** —
- **Driven by findings:** F2, F3, F21
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States

### D6: Reuse the existing vocabulary blocklist, with skill-local lists layered on top

- **Question:** Should the readability rule state its own word-level vocabulary rules, or reuse the blocklist in the operator writing-voice profile, and how do skills' own existing word lists relate to it?
- **Decision:** The readability rule points skills at the existing blocklist for word-level rules rather than duplicating them. The shared blocklist is authoritative for the words it covers; a skill's own word list is kept only for domain-specific terms the shared list does not cover, layered on top rather than duplicating it. This makes the blocklist relevant to skill output at runtime for the first time; it continues to govern operator documentation unchanged.
- **Rationale:** The blocklist already exists and is specific. Reusing it avoids maintaining the same vocabulary rules twice. The review team found that stakeholder-summary and html-summary already carry their own banned-word lists that partially overlap the shared one, so the spec states which list is authoritative to prevent drift and duplication.
- **Evidence:** User input. codebase — `docs/writing-voice.md` (the blocklist), not currently loaded at runtime by any skill; `han-reporting/skills/stakeholder-summary/SKILL.md` and `han-reporting/skills/html-summary/references/writing-conventions.md` carry skill-local banned-word lists.
- **Rejected alternatives:**
  - Keep the readability rule self-contained and leave the writing-voice profile for operator docs only — rejected on the operator's choice; it would duplicate the vocabulary rules.
  - Retire the skill-local lists entirely in favor of the shared one — rejected because those lists carry domain-specific terms (for example distributed-systems jargon) the shared list does not cover.
- **Linked technical notes:** —
- **Driven by findings:** F18
- **Dependent decisions:** —
- **Referenced in spec:** What the standard requires, Coordinations, Edge Cases and Failure Modes

### D7: Qualitative length guidance with a soft self-check flag, not hard word caps

- **Question:** Should the length rules be hard numeric caps, purely qualitative targets, or a mix — and how does a yes/no self-check evaluate a qualitative target?
- **Decision:** Qualitative length guidance for drafting (short sentences, roughly fifteen to twenty words on average, few past twenty-five to thirty), with the self-check flagging any sentence past a soft threshold of about thirty words as a candidate to split. The flag is a review trigger, not a hard cap; a longer sentence can stand if it reads clearly.
- **Rationale:** Models overshoot hard numeric targets, and caps can strip connective tissue. But the review team showed a yes/no self-check cannot evaluate a purely qualitative average, so a soft per-sentence flag gives the self-check something concrete to trigger on without becoming a hard cap that degrades cohesion.
- **Evidence:** web (via research report) — A28 (LLMs overshoot numeric length targets; qualitative targets work better). The report drops the single-source first-party postmortem (A39) from the basis; this decision rests on A28.
- **Rejected alternatives:**
  - A hard per-sentence or per-document word cap — rejected because models overshoot the target and caps degrade cohesion.
  - Purely qualitative guidance with no self-check anchor — rejected because the self-check could not answer yes/no consistently, which the review team flagged as an internal contradiction with D11.
- **Linked technical notes:** —
- **Driven by findings:** F12
- **Dependent decisions:** D11
- **Referenced in spec:** What the standard requires

### D8: Readability formulas and linting are not the enforcement mechanism

- **Question:** Should a readability formula (Flesch, grade level) be the standard's target, and should output be gated by a prose linter in CI?
- **Decision:** No to both. Formulas are demoted to an optional diagnostic (deferred), never the spine. CI/prose-linting is out of scope because most skill output is ephemeral, not committed files in a pipeline.
- **Rationale:** Formulas are weak comprehension proxies that reward gaming. Prose linting changes output at scale only by hard-gating committed files, which reader-facing skill output generally is not.
- **Evidence:** web (via research report) — A10 (formula criticism), A42 and A49 (Vale/CI mechanism), A7-A9 (the formulas). codebase — skill output is conversational or scratch text (A55, A57). The one committed-file exception (project-documentation) is handled by D16.
- **Rejected alternatives:**
  - A Flesch band or grade-level target as the standard's measure (research option O6) — rejected as a poor proxy that rewards gaming.
  - Vale or equivalent prose linting in CI over produced output (research option O5) — rejected on fit.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D16
- **Referenced in spec:** Out of Scope, Deferred (YAGNI)

### D9: Vendoring: manual byte-identical copies into the four plugins that ship in-scope skills

- **Question:** How is the shared rule made available to skills across plugins?
- **Decision:** The canonical copy lives in the core plugin's references and is copied byte-for-byte into every plugin that ships an in-scope skill — the coding, reporting, and github plugins — the same way the YAGNI and evidence rules are vendored. All copies stay byte-identical, and no skill is wired to load the rule before its plugin carries the copy.
- **Rationale:** This is the proven, understood mechanism. The vendored YAGNI and evidence copies are byte-identical to their originals, so each plugin's skills run with no cross-plugin dependency. The review team found that the reporting and github plugins have no `references/` directory today, so they receive a shared-rule reference for the first time; the mechanism is proven even though the target is new for those two. The team also flagged a rollout-sequencing risk (a skill wired to load a copy that is not yet present), which the byte-identical-and-present requirement addresses.
- **Evidence:** codebase — identical vendored copies of `yagni-rule.md` / `evidence-rule.md` in `han-planning/references/` and `han-coding/references/`; `han-reporting/` and `han-github/` have no `references/` directory today; the in-scope skills live in han-core, han-coding, han-reporting, and han-github.
- **Rejected alternatives:**
  - A build-step or automated sync of the copies — rejected under the simpler-version test; recorded in Deferred (YAGNI) with a reopen trigger.
- **Linked technical notes:** —
- **Driven by findings:** F6, F17
- **Dependent decisions:** —
- **Referenced in spec:** Preconditions, Alternate Flows and States, Coordinations, Edge Cases and Failure Modes

### D10: Audience frame generalized, with a named audience per engineer-facing skill

- **Question:** What single instruction should be on for every reader-facing skill while it drafts, given that some skills' readers are experts who have seen the code?
- **Decision:** An always-on default audience frame: write for a capable reader who did not do this work and lacks the author's context. The five skills whose reader is specifically an engineer each name that audience rather than defaulting, and may scope the frame per section so technical specifics a reader needs are not simplified away:
  - **investigate** — the engineer who will implement the fix and may be paged on the bug.
  - **update-pr-description** — the reviewer evaluating the pull request, who will read the code.
  - **code-review** — the author and reviewers of the change under review.
  - **architectural-analysis** — the engineer weighing the module's design and deciding whether to change it.
  - **project-documentation** — a technically-literate reader who needs to understand the feature's behavior before reading or modifying its code.
  The remaining in-scope skills keep the default frame; any skill with an even more specific audience (for example stakeholder-summary's non-technical stakeholders) names it the same way.
- **Rationale:** Audience framing is the most practical single instruction for plain output, backed by Anthropic's prompting guidance. The review team showed that a fixed "non-expert who has not seen the code" frame mis-fits skills whose readers demonstrably have seen the code (update-pr-description, investigate, project-documentation's own stated audience), steering output away from its real reader. The operator chose to commit each engineer-facing skill to a named audience rather than leave it a general permission, so the sharpening is consistent and not left to each author to rediscover. This resolved open item OI-1.
- **Evidence:** web (via research report) — A21 (audience/grade-level targeting, domain-caveated per V6), A32 (Anthropic prompting guidance), A29 (fidelity constraint on dense output). codebase — `han-core/skills/project-documentation/SKILL.md` defines a technically-literate audience; `han-coding/skills/investigate/SKILL.md` presents a plan to an engineer about to implement.
- **Rejected alternatives:**
  - A single fixed "non-expert who has not seen the code" frame for all skills — rejected because it mis-frames the skills whose readers are engineers.
  - Leaving per-skill sharpening as a general permission with no named audiences — this was the draft's approach (open item OI-1); rejected on the operator's choice to name each engineer-facing skill's audience so the framing is consistent rather than author-dependent.
  - A grade-level numeric target instead of an audience frame — rejected because numeric targets are overshot and grade levels are meaningless for adult expert readers.
- **Linked technical notes:** —
- **Driven by findings:** F7
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D11: The standardized self-check: a bounded set of behaviorally-anchored criteria

- **Question:** What does the standardized plain-language self-check evaluate, and is it a bounded, checkable set?
- **Decision:** A bounded set of concrete, behaviorally-anchored yes/no criteria, run as a discrete pass after the draft exists:
  1. the opening line states the main point;
  2. each heading names its content (is descriptive, not generic);
  3. each paragraph carries one idea and leads with it;
  4. no sentence runs past the soft length flag (about thirty words) without reason;
  5. no blocklisted word is present;
  6. every fact is preserved — every claim, quantity, named entity, and stated condition or qualifier in the draft survives with its precision intact.
  The set is enumerated, not illustrative, and is kept small to respect D2.
- **Rationale:** General models barely beat random on subjective writing-quality assessment and carry a sycophancy bias, so the check needs concrete anchors. The review team showed the original three illustrative examples left the standard's most-corroborated structural rules unchecked and, critically, gave the standard's declared winning constraint (fidelity) no criterion at all; a self-check that cannot observe a dropped fact cannot enforce fact preservation, which matters most on the non-synthesis skills that have no rewrite pass. Criterion 6 defines "fact" concretely (claim, quantity, named entity, condition/qualifier) and covers precision flattening, not just topical presence.
- **Evidence:** web (via research report) — A30 (unreliable ungrounded self-judging), A29 (fidelity loss on dense content), A13 (heading scanning). codebase — stakeholder-summary's Pass A/B/C is the closest current example to generalize.
- **Rejected alternatives:**
  - A subjective "rate the clarity of this text" self-check — rejected because ungrounded self-judging is unreliable and biased.
  - An open-ended, illustrative-only criteria set — rejected because it left structural and fidelity checks unspecified, so a reader could not tell what the self-check actually covers.
  - Porting all structural rules into the self-check — rejected because it would reintroduce the curse of instructions (D2); only the highest-value template-unguaranteeable checks are included.
- **Linked technical notes:** —
- **Driven by findings:** F10, F11, F12, F15
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### D12: Operator summary, contributor front door, and concepts-index placement

- **Question:** How does the standard surface to its two audiences — the operator and the contributor — separate from the runtime rule?
- **Decision:** A plain-language operator summary of the rule sits beside the existing YAGNI and evidence summaries and mirrors their structure. The contributor's wiring procedure gets a named home: the project contributor guide plus a per-skill application surface analogous to the YAGNI application table. The concepts index lists readability as a distinct output-quality standard, not as a fourth universal decision mechanic alongside sizing, YAGNI, and evidence.
- **Rationale:** Every shared rule in Han pairs a runtime rule file with an operator summary. The review team found that the operator got a home but the contributor (a named actor with a four-layer wiring task) did not, and that the concepts index frames its three mechanics as "the whole model." Readability is a different kind of thing — an output standard scoped to prose skills, not a near-universal dispatch/inclusion/confidence rule — so it enters the index as its own category rather than silently becoming a fourth peer.
- **Evidence:** codebase — `docs/yagni.md` (operator extract with a per-skill application table), `docs/evidence.md`, `docs/concepts.md` (the "whole model" framing of three mechanics), `CONTRIBUTING.md` (the established contributor front door).
- **Rejected alternatives:**
  - Ship the runtime rule with no operator summary — rejected because it breaks the rule/summary pairing.
  - Append readability as a fourth foundational mechanic in the concepts index without reframing — rejected because it would over-state readability's scope as universal.
  - Leave the contributor wiring procedure homeless in the runtime rule — rejected because the rule carries output rules, not wiring steps.
- **Linked technical notes:** —
- **Driven by findings:** F19, F20
- **Dependent decisions:** —
- **Referenced in spec:** Actors and Triggers, Coordinations

### D15: The self-check and rewrite operate on prose regions only

- **Question:** How do the self-check and rewrite pass treat deliverables that mix prose with code blocks, diagrams, rendered markup, or citation identifiers?
- **Decision:** The self-check and rewrite operate on prose regions only. Content inside code fences, diagram bodies, rendered markup (for example an HTML report), and inline citation identifiers is neither evaluated by the self-check nor altered by the rewrite. Citation identifiers in particular survive the rewrite unchanged so they still resolve to their registry.
- **Rationale:** The review team found that several in-scope deliverables interleave prose with functional non-prose whose exact syntax matters: diagrams, HTML markup and class names, code snippets, and citation identifiers whose whole value is resolvability. A sentence-and-paragraph-shaped self-check applied to those regions would either corrupt them or produce false results. html-summary's readability is also substantially visual, so its self-check applies to its prose content and its visual layout stays governed by its existing layout conventions.
- **Evidence:** codebase — `han-core/skills/research/SKILL.md` (citation resolvability invariant), `han-reporting/skills/html-summary` (rendered HTML with a diagram bundle), investigate's fenced code and function signatures.
- **Rejected alternatives:**
  - Apply the prose self-check uniformly across the whole deliverable — rejected because it would evaluate or rewrite non-prose regions and break citation resolvability.
- **Linked technical notes:** —
- **Driven by findings:** F8, F14
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D16: The standard applies at generation time only

- **Question:** The out-of-scope rationale calls skill output ephemeral, but one in-scope skill (project-documentation) writes a committed, later-editable file. Does the standard cover it after generation?
- **Decision:** The standard applies at generation time. A committed document is written readable, but a later manual edit or a partial re-run is not re-checked against the rule. That is an accepted gap, stated plainly, not a guarantee that a committed file stays conformant forever.
- **Rationale:** The review team showed that project-documentation's output is a persistent repository file, unlike the other skills' scratch or conversational output, which weakens the blanket "ephemeral, no CI surface" rationale for ruling out linting. Scoping the guarantee to generation time keeps the rationale honest without adding CI machinery the project does not need.
- **Evidence:** codebase — `han-core/skills/project-documentation/SKILL.md` writes to `docs/{feature-name}.md`.
- **Rejected alternatives:**
  - Claim the standard keeps committed files conformant over time — rejected because nothing re-checks the file after a manual edit; the claim would be false.
  - Add CI linting to cover committed output — rejected on the same fit grounds as D8.
- **Linked technical notes:** —
- **Driven by findings:** F16
- **Dependent decisions:** —
- **Referenced in spec:** Out of Scope, Edge Cases and Failure Modes
</content>
