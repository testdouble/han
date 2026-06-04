# IA Analysis: Output Right-Sizing for Research, Plan-a-Feature, and Plan-Implementation Artifacts (Issue #36)

## Scope

Three artifact-design surfaces flagged by real user feedback in GitHub issue #36 for an "Output length appropriateness" problem (research report rated 2/5; plan-a-feature and plan-implementation rated 3/5):

- **R1** — research report shape: `han.core/skills/research/references/research-report-template.md` and the rendering rules in `han.core/skills/research/SKILL.md` (Operating Principles, line 28; Step 6, lines 106-110; Step 8, lines 122-126).
- **F1** — plan-a-feature decision log shape: `han.core/skills/plan-a-feature/references/decision-log-template.md` (full/trivial classification, lines 8-27).
- **I3** — plan-implementation plan body shape: `han.core/skills/plan-implementation/references/feature-implementation-plan-template.md` ("Implementation Approach" altitude comment, lines 51-53).

Read for governing constraints: `docs/writing-voice.md` (voice profile), `docs/sizing.md` (small/medium/large model), and the repo conventions in `CLAUDE.md` ("one canonical source per concept", "YAGNI applies to docs too", "indexes stay complete").

These are text-first content surfaces a human reads to make a decision, so the IA lens applies directly: progressive disclosure, information scent, layered reads, minimalism (Carroll), and DITA topic-typing.

This audit is scoped to the **fix approach** for three already-confirmed problems, not to discovering new ones. The feedback is the evidence; my job is to recommend the minimal structural change that respects the repo's "one canonical structure" and "YAGNI-on-docs" conventions.

## Reader Context

- **Primary reader goal (JTBD):** "When I am a solo or small-team product engineer who just ran a Han skill, I want the artifact to surface the answer and the load-bearing detail at the top and let me stop reading once I can act, so I can make the decision without paying a reading tax sized for a problem larger than mine."
- **Audience segments:**
  1. **Decider-now** (dominant for research; the issue author): ran the skill on a personal/small tooling decision, wants the call and how solid it is, then wants to stop.
  2. **Builder-during-implementation** (plan-implementation): reads the plan body while writing code; wants the *how* at planning altitude, not config-file contents they will copy from the real file anyway.
  3. **Auditor-later / future-self** (decision logs, sources): comes back weeks later asking "why did we pick this?" and "can I still trust the sourcing?" Needs traceability, but rarely needs every rejected-alternative paragraph re-litigated.
- **Tasks covered:** decide and act (R1); reconstruct a decision's rationale (F1); build from the plan (I3); re-verify trust in the conclusion (R1 sources, F1 alternatives).
- **Arrival paths considered:** the operator reads the artifact in-channel immediately after the run, then re-opens the written file later. Both arrivals are top-down linear reads of a single Markdown file. There is no nav, no search index, no TOC surface beyond the headings themselves. That makes **the top of the file the only front door**, which raises the stakes on what lives there.

## Question Log

- **Q1 [Answered] — Arrival/usage pattern:** How is the artifact consumed? — Top-down linear read of one Markdown file, in-channel then re-opened later. There is no navigation surface; headings are the only wayfinding. So progressive disclosure must happen *within the single file*, by ordering and by making lower sections skippable — not by splitting into multiple files the reader has to navigate (`SKILL.md:36`, `SKILL.md:126`).
- **Q2 [Answered] — Does a layered read already exist?** — Partially. The research template already mandates a plain-language Summary at the very top and Sources at the very bottom (`research-report-template.md:6-15`, `:84-96`). The bones of a layered read are present; the problem is that the middle and bottom layers are **mandatory at full weight regardless of decision clarity**, so the layered read never actually lets the reader stop.
- **Q3 [Answered] — Is the confidence rating discoverable where the decider needs it?** — No. The Summary carries only a one-phrase solidity statement (`research-report-template.md:11-13`); the formal High/Med/Low rating lives in the Validation section's Confidence Assessment (`research-report-template.md:79-82`), below Results, Options, Recommendation, and Validation. A decider who stops at the Summary never sees the formal rating. This is a progressive-disclosure failure: a required-for-the-decision datum is buried below optional supporting material.
- **Q4 [Answered] — Is "Sources always present, never omitted" load-bearing for traceability?** — The traceability invariant is that **every conclusion traces to a source via inline `A#` IDs** (`SKILL.md:28`, `:110`). That invariant requires the IDs to resolve to entries; it does **not** require each entry to carry a full paragraph-length summary, nor does it require the registry to sit at full visual weight between the reader and "done." Traceability is about *resolvability*, not *prominence or verbosity*. So the registry can be condensed and de-emphasized without breaking the invariant.
- **Q5 [Answered] — What does the full/trivial trigger actually gate on?** — Presence, not weight. A decision is "full" if it has **at least one** rejected alternative (`decision-log-template.md:13`), with a tie-breaker "if unsure, treat as full" (`decision-log-template.md:26-27`). So an obvious-but-named alternative ("we could store it as JSON instead — rejected, we already use TOML everywhere") mechanically forces the full eight-field block. That is exactly D10/D12 in the feedback.
- **Q6 [Answered] — Does the plan body have an altitude ceiling?** — No. "Technical details are welcome here — this is the *how* document" (`feature-implementation-plan-template.md:53`) with no rule distinguishing *naming* a config artifact from *inlining its full contents*. A 25-line plist block satisfies the template as written.
- **Q7 [Assumed] — Is the dominant research use case low-stakes (personal tooling) or high-stakes (irreversible architecture)?** — Assumed: the skill defaults to **small** and the feedback is explicitly about "a personal tooling decision" (`sizing.md:10`, R1 feedback verbatim). I assume the *common* run is small-stakes and the right-sized default should serve it, while never *blocking* the high-stakes reader from full rigor. This assumption shapes the R1 remediation toward "let small runs render lean," not "cap every run."
- **Q8 [Open] — Does the operator know they can re-run larger, or ask for the long version?** — See Open Questions OQ1. Affects whether a lean default is safe (a reader who cannot get back to full rigor is under-served) or risky.

## Assumptions

- The common research run is a small-band, relatively-clear decision; the right-sized default should serve that reader without removing the high-stakes reader's path to full rigor (Q7).
- Traceability means inline `A#` IDs resolve to a registry entry, not that every entry is verbose or visually prominent (Q4).
- These artifacts are read top-down as single files with no external nav (Q1). Progressive disclosure must therefore be achieved by ordering, weight, and optionality *inside one file* — consistent with the repo's "one canonical structure" convention in `CLAUDE.md`.
- Voice constraints from `docs/writing-voice.md` (no em-dashes, direct second person, no hype, no "just"/"actually") apply to any new template prose proposed here.

## Open Questions

**OQ1: Does the operator have a known, low-friction path to the *full* version after receiving a lean one?**
- **Why it matters:** Every remediation below leans toward "tighten the single artifact so lower layers are condensable/omittable" rather than "add a second executive-summary mode." That is only safe if the auditor-later reader can still recover full detail when they need it. The research skill is explicitly re-runnable ("the user re-runs larger", `SKILL.md:26`), which partly answers this, but re-running regenerates rather than expands, and it is not stated in the artifact itself.
- **Findings affected:** IA-001, IA-002, IA-004.
- **How to resolve:** Confirm via the skill's closing message (`SKILL.md:128`) whether the operator is told they can re-run larger / ask for expanded sourcing, or add a one-line pointer. A support-ticket or re-run-frequency pull would settle whether deciders actually want the long version later.

**OQ2: For trivial-but-present alternatives, does the future auditor ever need the discarded option recorded at all, or is a one-line mention sufficient?**
- **Why it matters:** F1's minimal fix (weight-based trigger) lets an obvious alternative live as a one-line clause in the trivial entry instead of a full block. That is correct only if a one-line mention preserves enough audit trail. If compliance or a strict "every alternative fully recorded" norm applies, the trigger must stay presence-based.
- **Findings affected:** IA-003.
- **How to resolve:** Product decision by the maintainers on the decision-log's audit contract. The repo is solo/small-team (`docs/why-solo-and-small-teams.md`), which argues against a heavyweight audit contract, but this should be confirmed.

## Summary

Three Han artifact templates fail the layered-read test in the same way: the orienting layer is present, but the supporting layers below it are mandatory at full weight regardless of how much the reader's decision actually needs, so the reader cannot stop early. The correct fix in all three cases is to **tighten the existing single canonical artifact** so the layered read works (key info up top, supporting detail condensed/optional/omittable) rather than to add a second "executive-summary mode" output shape. A second mode would violate the repo's "one canonical structure" and "YAGNI-on-docs" conventions and split traceability across two artifacts for no gain the single-artifact fix cannot deliver.

| Severity               | Count |
|------------------------|-------|
| Blocks comprehension   | 0     |
| Degrades comprehension | 2     |
| Friction               | 3     |
| Polish                 | 1     |

Open Questions: 2 (must be answered before findings are fully actionable)

Full analysis written to: /Users/mxriverlynn/dev/testdouble/han/docs/plans/skills-feedback-issue-36/artifacts/ia-right-sizing-findings.md

## Findings

### Cross-cutting verdict: tighten the single artifact, do not add a mode

Before the per-item findings, the question that governs all three: **is the right fix a separate executive-summary mode, or tightening the existing single artifact?**

The answer is tightening, for every item, on three grounds:

1. **Progressive disclosure is an ordering-and-weight property, not a second-document property.** Nielsen's progressive disclosure and Mark Baker's Every-Page-Is-Page-One both put the orienting layer first and let supporting detail recede; neither requires a separate "summary edition." The research template *already* implements the spine of this (Summary at top, Sources at bottom). The defect is not a missing mode; it is that the lower layers are mandatory at full weight (Q2). You fix that where it lives.

2. **A second mode violates two stated repo conventions.** `CLAUDE.md` states "one canonical source per concept" and "YAGNI applies to docs too — don't add speculative sections... for-future-flexibility." An "executive-summary mode" is a second canonical shape for the same artifact: it duplicates the orienting content, forces a mode-selection decision on the operator, and splits the question "where does the answer live?" across two outputs. That is the **Category Fiction / TOC-As-Architecture** trap inverted — adding structure to compensate for a structure that simply isn't letting the reader stop.

3. **A mode does not solve traceability better than tightening does.** R1's deepest tension is "keep traceability while shedding length." A separate summary mode that *drops* the Sources registry breaks the `A#` traceability invariant (Q4). Tightening keeps the IDs resolvable while condensing the entries. Tightening wins on the exact axis a mode would have to compromise.

A mode is only warranted when two audiences need genuinely different *content*, not the same content at different depths. Here, all readers want the same answer; they differ only in how far down they read. That is the textbook case for progressive disclosure within one artifact, not for a second shape.

---

**IA-001: The research report's lower layers render at full weight on every run, defeating the layered read the template already sets up.**
- **Principle:** Progressive disclosure (Nielsen); Carroll minimalism (cut content that does not serve the reader's task); the **Wall-of-Text / Everything-at-Once** anti-pattern applied to a mandated structure.
- **Location:** `han.core/skills/research/SKILL.md:28` ("One fixed report structure... rendered every run"), reinforced at `:110` and `:126` ("The Sources registry is always rendered, even for a minimal run"); `research-report-template.md:84-114` (full per-source entry shape).
- **Evidence:** The Operating Principle mandates the full fixed structure "every run" and the Sources registry "always present, even for a minimal run — never omitted" (stated three times: `SKILL.md:28`, `:110`, `:126`). Per-source entries each carry link, retrieval date, trust class, a paragraph summary, and evidence status (`research-report-template.md:98-112`). At 39 sources that is the bulk of the 1,500+ words the feedback cites, generated even when the decision is clear.
- **Reader Impact:** The decider-now audience, arriving in-channel right after a small-band personal-tooling run, gets the answer in the Summary but must then scroll past a full-weight Results + Options + Recommendation + Validation + 39-entry registry to reach the end of an artifact they were done with at line 15. The layered read exists structurally but never pays off, because no layer below the Summary is allowed to shrink with the decision's clarity.
- **Related questions:** Q1 (answered), Q2 (answered), Q7 (assumed), OQ1 (open).
- **Severity:** Degrades comprehension.
- **Remediation:** Keep the one fixed structure; make the *depth of the lower layers scale with the band*, which the skill already computes (`sizing.md`, `SKILL.md` Step 3). Concretely: (a) for a small-band run, render Research Results and Options at calibrated brevity (the skill already briefs analysts this way at `SKILL.md:102` — propagate that calibration into the rendered report, not just the agent briefs); (b) condense Sources per IA-002; (c) move the formal confidence rating up per IA-004. This is a tightening of the existing template's rendering rules, not a new mode. Do not drop any section — keep every section heading so the structure stays canonical and EPPO-stable, but let small runs fill them leanly.

**IA-002: The Sources registry is mandatory, verbose, and positioned as a full-weight wall between the reader and the end of the report — but traceability only requires resolvable IDs, not prominence or per-entry prose.**
- **Principle:** Information scent / foraging (the registry is a lookup surface, not a read-through surface, yet is rendered as read-through); DITA topic-type boundary (reference content presented as if it were narrative); Carroll minimalism.
- **Location:** `research-report-template.md:84-114`; `SKILL.md:28`, `:110`, `:126`.
- **Evidence:** "ALWAYS present, even for a minimal run — never omitted" (`research-report-template.md:88-89`), repeated at `SKILL.md:110` and `:126`. Each entry is a five-field block including a "short paragraph" summary (`research-report-template.md:103`). For a personal tooling decision the feedback found 39 such blocks.
- **Reader Impact:** The decider-now reader never needs to read the registry top-to-bottom; they need it only to *resolve a specific `A#`* when they want to check one claim. Presenting it as 39 full prose blocks treats a random-access reference table as a linear narrative — the **Reference-As-Tutorial** anti-pattern in reverse. The auditor-later reader, who *does* use the registry, would be served better by a scannable table than by paragraphs.
- **Related questions:** Q4 (answered), OQ1 (open).
- **Severity:** Friction.
- **Remediation:** Three tightenings, all preserving the `A#` traceability invariant:
  1. **Condense the entry shape to a table row** for the citation pointer (ID, title, link, trust class, evidence status), and reserve the paragraph "summary" only for sources the recommendation actually rests on. A source that is cited once in passing does not need a paragraph; its row and inline `A#` already carry the trace.
  2. **De-emphasize, do not omit.** Keep the registry at the bottom (it already is, correctly), and let small runs render the compact table form. "Never omitted" stays true; "always a paragraph per source" does not need to. This keeps Q4's traceability invariant (IDs resolve) while shedding the bulk.
  3. **Defensibility of "always present":** "always present" is defensible *as resolvability* — every inline `A#` must land somewhere. It is **not** defensible *as full verbosity on a minimal run*. Reword the three SKILL.md statements from "always rendered in full" to "every cited `A#` always resolves to an entry; entry depth scales with the band." That preserves the invariant the rule actually protects.

**IA-003: The decision-log full/trivial trigger fires on the *presence* of an alternative, not its *weight*, forcing full eight-field entries for decisions whose alternative is obvious.**
- **Principle:** Carroll minimalism (task-oriented chunking — the format should match what the future reader needs to reconstruct, not a mechanical trigger); Dan Brown's Principle of Disclosure (show detail proportional to the decision's actual complexity).
- **Location:** `han.core/skills/plan-a-feature/references/decision-log-template.md:12-13` ("full when any of these signals is present: it has at least one rejected alternative") and `:26-27` ("If unsure, treat the decision as full").
- **Evidence:** The classification is trigger-based on presence: any rejected alternative ⇒ full (`:13`). The tie-breaker compounds it (`:26-27`). D10/D12 in the feedback are decisions where "the alternatives are obvious and the rationale fits in two sentences" but the presence of a named alternative mechanically forced the full block.
- **Reader Impact:** The auditor-later / future-self reader scanning the decision log to reconstruct *why* hits full eight-field blocks (Question, Decision, Rationale, Evidence, Rejected alternatives, three cross-ref fields) for decisions whose answer was "the only reasonable one given an obvious convention." The signal-to-text ratio drops; the genuinely load-bearing decisions are harder to spot among the inflated ones. The template's own definition of trivial already names this exact case ("the only reasonable one given an obvious convention with no alternative worth discussing", `:23-24`) — but the *trigger* contradicts the *definition*.
- **Related questions:** Q5 (answered), OQ2 (open).
- **Severity:** Degrades comprehension.
- **Remediation (minimal change to the classification rule):** Change the first full-trigger from presence-based to **weight-based**, aligning the trigger with the template's own trivial definition. Replace `decision-log-template.md:13`:
  - From: "it has at least one rejected alternative;"
  - To: "it has at least one rejected alternative **that was worth discussing** — an alternative a reasonable engineer would have plausibly chosen, such that the rationale for rejecting it is not self-evident from the convention. An obvious alternative dismissed in one clause does not trigger full; record it inline in the trivial entry."
  Then extend the trivial bullet format (`decision-log-template.md:52-54`) to permit an optional trailing clause: `— D#: {title} — {outcome}; {obvious alternative} not chosen because {one clause}. — Referenced in spec: {sections}.` This keeps the discarded option on the record (answering OQ2's audit concern at one-line cost) without the eight-field block. Leave the "if unsure, treat as full" tie-breaker (`:26-27`) in place — it is the correct safety default; only the *trigger* needs the weight qualifier so that "unsure" stops being the common case.

**IA-004: The formal confidence rating lives in the Validation section, below every optional supporting layer, so a reader who stops at the Summary never sees how solid the answer is in calibrated terms.**
- **Principle:** Progressive disclosure (a decision-critical datum is disclosed *after* optional detail); information scent (the Summary's one-phrase solidity statement under-predicts that a formal rating exists below).
- **Location:** `research-report-template.md:11-13` (Summary carries only a one-phrase solidity statement) vs. `:79-82` (formal High/Medium/Low Confidence Assessment, inside Validation, after Results/Options/Recommendation/Validation findings).
- **Evidence:** The Summary instruction says "Close with one phrase on how solid it is" (`:11-13`); the structured "Confidence: High / Medium / Low" field sits at `:81`, four major sections down. The R1 feedback explicitly notes "the formal High/Med/Low confidence rating lives down in the Validation section."
- **Reader Impact:** The decider-now reader's task is "make the call and gauge how much to trust it." They get the call (Summary) and a soft phrase, but the calibrated rating they would weigh the decision against is gated behind material they wanted to skip. Two readers can act on the same Summary with very different warranted confidence and not know it.
- **Related questions:** Q3 (answered), OQ1 (open).
- **Severity:** Friction.
- **Remediation:** Promote the **formal confidence rating into the Summary** as a single labeled line (e.g., a final `**Confidence:** High / Medium / Low` line in the Summary block), while leaving the *reasoning* for that rating — remaining risks, single-source reliance — in the Validation section's Confidence Assessment. This is classic progressive disclosure: the rating (the datum the decider needs) goes up; the justification (the detail the auditor needs) stays down. The Summary must still stay ID-free per `research-report-template.md:9` and `:91`, so the promoted line carries the rating only, not `A#` references. One-line template change; no new section.

**IA-005: The plan-implementation "Implementation Approach" guidance invites unbounded technical detail with no altitude ceiling, so config-file contents get inlined where a reference would do.**
- **Principle:** Information altitude / LATCH (the plan is a *how-it-fits* document, a different altitude than the artifact files it describes); Carroll minimalism (cut content that adds length without adding decision-relevant information); the **Reference-As-Tutorial** anti-pattern (dumping verbatim reference into a planning narrative).
- **Location:** `han.core/skills/plan-implementation/references/feature-implementation-plan-template.md:53` ("Technical details are welcome here — this is the *how* document") and the four subsections it governs (`:55-69`), none of which distinguish naming an artifact from inlining its contents.
- **Evidence:** The comment welcomes technical detail with no ceiling (`:53`). The I3 feedback: "Plist XML in the plan body is verbose... full XML blocks are 25+ lines each and belong in the actual plist files... the XML adds length without adding information a developer needs during build."
- **Reader Impact:** The builder-during-implementation reader reads the plan to learn *how the feature fits and what to build*, then writes the real config file. A 25-line verbatim plist in the plan body forces them to scroll past content they will author (correctly) in the actual file, and risks the plan and the real file drifting out of sync — two canonical copies of the same config, violating "one canonical source per concept" at the content level. The plan's altitude (decisions, integration points, sequencing) is diluted by file-level material that belongs one altitude down.
- **Related questions:** Q6 (answered).
- **Severity:** Friction.
- **Remediation (one-line altitude principle the template can adopt):** Add to the Implementation Approach comment (`:53`):
  > **Altitude rule: name and reference config artifacts; do not inline their contents.** State which config file changes, what setting changes, and why — link to or name the file. Inline only the specific lines whose *value* is itself a decision a reader must see here (a flag default, a key name, a threshold). A full file block belongs in the file, not the plan.
  This is a tightening of existing guidance, not a new section or rule surface. It distinguishes *naming/referencing* (in scope for a how-document) from *reproducing contents* (out of scope), which the template currently fails to do (Q6).

**IA-006: The three "always rendered in full" restatements in research SKILL.md create a rule-surface that will resist the IA-001/IA-002 tightening unless updated together.**
- **Principle:** Cross-reference integrity / single-source-of-truth (the same mandate stated three times must change in three places or the rule contradicts itself); labeling consistency.
- **Location:** `han.core/skills/research/SKILL.md:28`, `:110`, `:126` (and the template echo at `research-report-template.md:88-89`, `:110`, `:114`).
- **Evidence:** "always present, even for a minimal run" / "always rendered, even for a minimal run" appears at `SKILL.md:28`, `:110`, `:126`. The R1 feedback itself notes the constraint is "stated in 3 places."
- **Reader Impact:** This is a maintainer-facing finding, not an operator one, but it directly governs whether IA-001/IA-002 can land cleanly. If only one of the three statements is reworded from "always full" to "always resolves, depth scales with band," the rendering rule contradicts itself and a future author cannot tell which governs.
- **Related questions:** Q4 (answered).
- **Severity:** Polish.
- **Remediation:** When applying IA-002, update all three SKILL.md statements and the template's echoes in lockstep to the resolvability wording ("every cited `A#` always resolves to an entry; entry depth and the report's lower layers scale with the band"). Verify with a grep for "always" across both files at edit time.

---

> **Protocol 1 — Critical Inquiry and Reader Context:** Executed. Twelve-category question bank seeded; eight questions logged (six answered from the artifacts and feedback, one assumed, two open). Reader segments and JTBD derived from the feedback and the skills' stated defaults (`sizing.md:10`). No reader was fabricated; the decider-now audience is the issue author, directly attested.

> **Protocol 2 — Content Inventory:** Executed against the three named artifact templates plus their governing SKILL.md rules and the two governing docs (voice, sizing). The set is small and fully enumerated rather than sampled. Topic types: research-report-template = reference+concept hybrid (correctly layered, wrongly weighted); decision-log-template = reference (history); implementation-plan-template = concept/task (the *how*). Findings IA-001 through IA-006 cover the inventory.

> **Protocol 3 — Audience and Task Analysis:** Executed. Three segments mapped (decider-now, builder-during-implementation, auditor-later) against tasks. Under-served: decider-now (forced to read auditor-grade detail — IA-001, IA-002, IA-004) and builder (forced past file-grade detail — IA-005). No over-serving via redundant pages found; the redundancy risk is *within* an artifact (config inlined twice — IA-005), not across pages.

> **Protocol 4 — Topic Typing and Information Model:** Executed. The core typing defect is mandatory full-weight reference content (Sources registry, full decision blocks) embedded in artifacts a reader consumes for a decision — reference presented as read-through narrative (IA-002, IA-003). Each artifact does pass EPPO: a reader landing cold on any of the three can tell what it is from its top section.

> **Protocol 5 — Hierarchy and Progressive Disclosure:** Executed; this is the spine of the audit. Confirmed defects: lower layers mandatory at full weight (IA-001), a decision-critical datum (confidence rating) disclosed below optional detail (IA-004), and no altitude ceiling separating plan-grade from file-grade content (IA-005). The orienting layer is correctly placed first in all three; the failure is downstream weight, not front-door placement.

> **Protocol 6 — Labeling and Navigation Systems:** Executed. Organization is defensible (top-down single file, Summary-first). The relevant labeling defect is the full/trivial *trigger* contradicting the template's own *definition* of trivial (IA-003) — a vocabulary inconsistency within one file. No ghost-navigation or scent-free heading issues found; headings carry good scent.

> **Protocol 7 — Every-Page-Is-Page-One Check:** Executed. All three artifacts are self-contained and survive a cold landing. The EPPO concern is the proposed remediation's own risk: tightening must not orphan the auditor-later reader from full detail — captured as OQ1. Cross-references (`A#`, `D#`, `T#`, decision-log links) are bidirectional by design; the registry condensation in IA-002 explicitly preserves `A#` resolvability so EPPO traceability survives.

> **Protocol 8 — Minimalism Sweep:** Executed; drives IA-001, IA-002, IA-003, IA-005. Each is a "cut content that does not serve the reader's current task" finding: verbose source blocks on minimal runs, full decision blocks for obvious choices, inlined config contents. No throat-clearing/meta-prose defects found in the templates themselves; the comments are instructional, not padding.

> **Protocol 9 — Recency and Cross-Reference Integrity:** Executed (internal cross-refs only; no external links followed). Git shows the sibling effort (issue #34 gap-analysis feedback) is the most recently churned plan area; these three templates are the next right-sizing target in the same vein. Cross-reference integrity check: the three "always present" restatements in research SKILL.md (`:28`, `:110`, `:126`) are a self-consistency hazard for the remediation — logged as IA-006 so they change in lockstep.

## IA Improvement Summary

### What Was Found

All three flagged artifacts (IA-001 through IA-005, plus the maintainer-facing IA-006) share one root defect: the **orienting layer is correctly placed first, but the supporting layers below it are mandatory at full weight regardless of how much the reader's decision actually needs**. The research report forces a full Results + Options + Validation + 39-entry source registry on a clear small-band decision (IA-001, IA-002) and buries the formal confidence rating below all of it (IA-004). The decision log forces full eight-field entries whenever an alternative merely *exists*, even when it is obvious (IA-003). The implementation plan invites unbounded technical detail with no altitude ceiling, so config-file contents get inlined where a reference belongs (IA-005). None of these blocks comprehension; all of them tax the reader's time and dilute signal.

### How to Improve

Ordered by severity and reach (degrades-comprehension first):

1. **(IA-001, IA-002 — research) Let the report's lower layers scale with the band the skill already computes.** Keep the one fixed structure and every section heading. For small-band runs, render Research Results and Options at the brevity the skill already briefs analysts for, and render the Sources registry as a compact table (ID, title, link, trust class, evidence status), reserving a prose summary only for sources the recommendation rests on. Reword "always rendered in full" to "every cited `A#` always resolves to an entry; entry depth scales with the band" — in all three SKILL.md locations and the template echoes together (IA-006).
2. **(IA-003 — plan-a-feature) Make the full/trivial trigger weight-based, not presence-based.** Change `decision-log-template.md:13` so an alternative triggers "full" only when it was *worth discussing*, and extend the trivial bullet format to allow a one-clause mention of an obvious discarded alternative. Keep the "if unsure, treat as full" safety default. This aligns the trigger with the template's own definition of trivial.
3. **(IA-004 — research) Promote the formal confidence rating into the Summary.** Add a single `**Confidence:** High / Medium / Low` line to the Summary block; leave the supporting risk reasoning in Validation. Keep the Summary ID-free.
4. **(IA-005 — plan-implementation) Adopt a one-line altitude rule.** Add to the Implementation Approach comment: name and reference config artifacts; do not inline their contents; inline only the specific values that are themselves decisions.
5. **(IA-006 — research, maintainer hygiene) Change the three "always full" statements in lockstep** when doing step 1, and grep for "always" to confirm consistency.

Every change above is an edit to an existing template comment or SKILL.md rule line. **No new file, no new section, no new "mode" is created.**

### How to Prevent This Going Forward

- **Bake band-scaled rendering into every fixed-structure template, not just agent briefs.** The research skill already calibrates *agent briefs* by band (`SKILL.md:102`) but not the *rendered artifact*. A template-authoring rule — "if the skill is sizing-aware, the rendered artifact's lower layers must scale with the band" — would have caught IA-001 at design time. Consider adding this to `han.plugin-builder/skills/guidance/references/skill-building-guidance/`.
- **Prefer weight-based over presence-based classification triggers in any two-tier format.** IA-003 is a presence trigger contradicting a weight-based definition. A reviewer checklist item — "does the trigger match the definition?" — catches this class.
- **Add an altitude line to any template that says 'technical details welcome.'** IA-005 came from open-ended permission with no ceiling. The "name, don't inline" altitude rule generalizes to any how-document template.
- **When a mandate is restated for emphasis (IA-006), link the restatements** or note "see also line X" so a future edit changes them together.

### Balancing Shipping vs Improving

- **Do now (cheap, high reach, no mode):** IA-003 (one trigger line + one bullet-format extension), IA-004 (one Summary line), IA-005 (one altitude comment). Each is a self-contained single-template edit, low risk, directly answers the feedback, and adds no new structure. These three alone move the plan-a-feature and plan-implementation 3/5 ratings and start on the research 2/5.
- **Do now but with the lockstep care of IA-006:** IA-001 + IA-002 are the largest lever on the research 2/5 rating and should ship together with IA-006, since the three "always full" restatements must change in one pass to avoid a self-contradicting rule.
- **Resolve before shipping the research changes:** OQ1 (can the reader recover full detail later?). If the skill's closing message already tells the operator they can re-run larger or ask for expanded sourcing, the lean default is safe to ship as-is. If not, add that one-line pointer as part of the same change so no reader is stranded without a path to full rigor.
- **Confirm, low urgency:** OQ2 (audit contract for discarded alternatives). The one-clause-mention compromise in IA-003 is a safe default for a solo/small-team tool; confirm with maintainers but do not block on it.
