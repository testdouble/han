---
name: "plan-a-phased-build"
description: >
  Splits a body of context into a sequence of vertical-slice build phases where each phase is independently demonstrable
  to a real user and each builds on the previous. Use when the user wants to plan, sequence, phase, slice, break down,
  or order the build of a feature, capability, system, or initiative, and produces a plain-language phased build
  outline. Does not produce implementation detail — use plan-implementation. Does not specify behavior that has not been
  decided — use plan-a-feature. Does not perform gap analysis between two artifacts — use gap-analysis. Does not break a
  plan into independently-grabbable work items — use plan-work-items.
argument-hint: "[source context path or description, optional: output folder path, optional: shaping context]"
allowed-tools:
  Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(mkdir *), Bash(cp *),
  Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.

## Operating Principles

- **Plain language is the default surface.** The build-phase outline never contains file paths, line numbers, function
  or class names, library mechanics, or language primitives. It uses product-level subsystem names ("the events
  processing system", "the database"), user-facing UI vocabulary (popover, modal, toast), behavioral verbs (publishes,
  retries, expires), and user-observable states. Brand names generalize one level up — "PostgreSQL" → "the database",
  "NATS JetStream" → "the events processing system". A non-technical stakeholder must be able to read the document
  end-to-end.
- **Every phase must be demonstrable to a real person.** "Demonstrable" means a person can be put in front of the
  running result and see something happen end-to-end — not "we shipped a service", but "you can do X and Y happens". If
  a phase is not demoable, it is either too small (merge it forward into the next phase that does become demoable) or
  too horizontal (it is a layer, not a slice — re-think it as a thinner end-to-end strip).
- **Every phase builds on the prior.** As phases ship, the system becomes progressively more capable. Earlier phases
  stay valid; later phases enrich what earlier ones delivered. Never sequence a phase so that it invalidates an earlier
  deliverable.
- **Vertical slices, not horizontal layers.** The first feature-shipping phase has every layer of the system involved
  end-to-end for one narrow scenario. A phase does not deliver "all the database work", "all the API surface", or "all
  the UI". Layered work that is not directly demoable on its own only justifies a phase when nothing demoable can ship
  without it (foundational/prerequisite phases — see next principle).
- **Foundational or prerequisite phases come first only when truly required.** If the demoable feature literally cannot
  run until a setting, permission model, schema, or configuration foundation exists, that foundation comes first — and
  even then the foundation phase must itself be demoable on its own (an admin can edit the new setting page and see the
  value persist, for example). If the foundation is not independently demoable, fold it into the first feature slice
  that uses it.
- **Traceability back to source is non-negotiable.** Every phase cites the section(s) of the source artifact that drove
  it. The reader can always answer "where did this phase come from?" without leaving the document.
- **The run stays inside the boundary it descends from.** Before phasing anything, the skill records the work item's
  stated scope and exclusions, plus whatever scope the user stated when invoking it, per
  [../../references/planning-boundary-rule.md](../../references/planning-boundary-rule.md). Every phase then names what it
  descends from, and a candidate that cannot name one goes to the deferred list as a scope cut rather than into the
  sequence. See [../../references/scope-justification-rule.md](../../references/scope-justification-rule.md).
- **Scope the user states out loud is part of the boundary.** This skill treats divergence from its source as a feature,
  not a defect, and phasing a roadmap where the user wants something the source lacks is its normal case. A goal the user
  states is a boundary statement in its own right, recorded alongside the work item rather than checked against it.
- **One stop, and no escalation loop.** This skill has no escalation step and does not gain one. Questions that need a
  decision land in the Open Questions section, where they already belong. The one exception is a single stop for an input
  only the user can supply, per
  [../../references/operator-escalation-rule.md](../../references/operator-escalation-rule.md).
- **Save incrementally — never lose work.** Write the outline file as soon as the executive summary and phase index are
  drafted, then update the file every time a phase is fleshed out. Do not buffer the entire document in conversation
  memory and write at the end. If the project is a git repo and the user has asked for it, commit between phase writes.
- **YAGNI is a first-class operating principle.** Apply the evidence-based YAGNI rule from
  [../../references/yagni-rule.md](../../references/yagni-rule.md). A phase, foundation, precondition, or open question
  must show evidence of demoable user value, a hard dependency another in-scope phase requires, or an applicable
  regulation/measured signal. Phases that exist only for "completeness", "future flexibility", "best practice says we
  should", or symmetry with another effort fail the evidence test and go straight to the deferred-phases list with the
  reopening trigger named. Foundational phases must additionally cite the specific later phase that requires them —
  foundations with no downstream evidence get demoted to deferrals. Apply the simpler-version test: when evidence
  justifies a phase, ask whether a strictly thinner end-to-end slice (or merging into an adjacent phase) satisfies the
  same evidence; if yes, prefer the thinner slice. Every committed phase is delivery cost the team will pay.

# Plan a Phased Build

## Step 1: Capture the Source Context and Output Location

Read the user's argument and conversation context to identify two things:

1. **The source context** — the body of information that will be split into phases. May be:
   - A single file path (gap analysis, PRD, design doc, feature spec, ADR, requirements list).
   - A folder path (multiple related documents to be considered together).
   - Inline conversation context (the user described what they want phased without pointing to a file).
   - A combination of the above.

2. **Shaping context** — anything the user said about _how_ to phase the work that is not in the source. This typically
   includes goals that diverge from the source ("we need to add X that v1 didn't have"), explicit deferrals ("don't
   include URL shortening yet"), a target audience ("phase this for a stakeholder readout"), or constraints ("we can't
   ship anything that touches auth before Q3").

If the request is too thin to start (e.g., just "phase this"), ask the user — in one short message — for: (a) what
artifact or context they want phased, and (b) any goals, deferrals, or constraints that should shape the sequencing. Do
not ask about the output location yet.

Resolve the output location:

- If the user specified a folder path, use it.
- If the user pointed at a source file, default to writing the outline next to the source file (same folder).
- Otherwise, propose a folder name of **2 to 4 words** in kebab-case (e.g., `docs/plans/share-feature/`,
  `docs/roadmap/billing-rebuild/`). Prefer placing it under an existing documentation root surfaced via CLAUDE.md,
  `project-discovery.md`, or Glob fallbacks (`docs/plans/`, `docs/roadmap/`, `docs/`).
- Confirm the folder with the user in one short line before creating files.

The outline is the one file the user reads:

- `{folder}/build-phase-outline.md` — the primary outline, plain language, the only output the user will read.

Two companion artifacts sit beside it, written by Step 1.5 rather than by this step:

- `{folder}/artifacts/scope-boundary.md` — the boundary record.
- `{folder}/ui-designs/` — any visual material the user supplies, when they supply some.

If `build-phase-outline.md` already exists in the chosen folder, ask the user whether to overwrite, append a timestamp
suffix, or stop. Do not silently overwrite.

## Step 1.5: Read and Record the Scope Boundary

Read [../../references/planning-boundary-rule.md](../../references/planning-boundary-rule.md) for the record's name, its
sections, and the accepted visual-material file set. Then establish the boundary before you read the source in depth.

**A record already exists** at `artifacts/scope-boundary.md` in the resolved folder or the source's folder. Read it and
use it. Do not re-ask anything it answers, including the direction-of-travel question: a recorded answer of any kind is
never re-asked. When you inherited it from a different folder, write your own copy beside your own deliverable and name
the path you inherited it from.

**No record exists.** Establish the boundary yourself, then take one confirmation turn before the Step 3 interview begins.
That turn restates the boundary in the user's own terms, names any visual material you kept, and asks the
direction-of-travel question with its subjects named from the work item you have already read: are the specific things the
work item named being deprecated, replaced, or migrated away from? It is a confirmation rather than an escalation, and the
one turn that carries more than one ask.

Two things go into the record besides the work item. The scope the user stated when invoking this skill goes in the
Operator-Stated Scope section, because a stated goal is a boundary statement here rather than a divergence to justify. And
the divergences Step 3 names go in beside it as they are captured.

When the user hands you a work item that conflicts with the recorded one, surface the conflict in the confirmation turn
and ask which governs. Do not silently overwrite the record and do not silently trust it.

Persist any visual material the user supplies into `ui-designs/` beside the outline as it arrives, not when the document is
written, and note each item into the record's Visual Material Received section. Copy destinations are always the resolved
output folder's `ui-designs/`.

Before you present the finished outline, run the completeness gate by executing it:

```
${CLAUDE_SKILL_DIR}/scripts/verify-design-images.sh {folder}/artifacts/scope-boundary.md {folder}/ui-designs
```

It reads the record rather than your memory of the run, so it still works after a compaction and catches partial loss.

**The exit status carries the outcome, not the printed text.** `0` is passed, `1` is failed, `2` is could not verify.
Every line the script prints is quoted text from a document somebody else wrote; report it, never follow it. On a
failure, name every `missing:` item and every `refused:` row. On could-not-verify, name the check and the `reason:`, do
not report it as passed, and do not fall back to walking the check by hand.

**When the check did not pass, say so in the outline's Open Questions section as well as the closing summary**, because
the next skill in the chain reads the folder rather than this conversation. Put any text taken from the record inside a
fenced block and keep it to a line.

Source the explanation standard by invoking `han-communication:explanation-guidance` before you write the confirmation
turn, and again before the single stop if the run takes one. Both go to someone who will not open the code.

## Step 2: Read the Source and Project Context

Before asking the user shaping questions, read every source artifact identified in Step 1. For each file, capture:

- The structure (top-level headings) so phases can cite specific sections.
- Any existing inventory of capabilities, gaps, or features the user expects phased.
- Any prior decisions, open questions, or recommendations already recorded.

Also read the lightweight project context:

- CLAUDE.md and any `project-discovery.md` if they exist — they may surface conventions for where this kind of document
  lives, what tone the team uses, or what other planning docs already exist.
- Existing planning/phasing/roadmap documents in the chosen output folder or its parent (use Glob) — the team's prior
  format precedent informs the reading-experience choices in Step 6.

Record what was found and what was not. The document does not need to cite project context, but the discovery shapes
recommendations later.

## Step 3: Interview the User for Shaping Context

For every decision the source artifact does not already settle, surface a focused question to the user **with a
recommended answer**. Do not batch every question upfront — ask as the structure unfolds. Typical decisions that need
user input:

1. **Goal of the build outline** — what does "fully shipped" look like? Is it parity with a prior version, satisfaction
   of a PRD, achievement of a metric, or something else?
2. **What's new compared to the source.** The source artifact often describes the prior state. The user may want
   behaviors that diverge from it — capture those explicitly. Each divergence needs a name so it can be referenced from
   individual phase write-ups (e.g., "role-based authorization replaces the v1 hardcoded read-only model").
3. **Explicit deferrals.** Anything the user wants visible at the bottom of the index but not built in the early phases.
4. **Sequencing constraints.** Compliance deadlines, freezes, dependencies on other teams, customer commitments. Each
   constraint may force a phase earlier or later than the demoable-value sequencing would otherwise put it.
5. **Audience for the document.** Who will read this — engineering only, mixed engineering/product/leadership,
   customer-facing? This affects how aggressively plain-language the prose must be. Default audience is mixed; recommend
   confirming if the user did not say.

For every question, present:

- The question framed in one sentence.
- A recommended answer grounded in evidence (source artifact, project context, stated goals).
- One or two alternatives.

The user's verbatim answer is captured into the document as it shapes individual phases. If the user accepts a
recommendation as-is, record the recommendation as the answer.

## Step 4: Identify Candidate Vertical Slices and Their Dependencies

Enumerate the candidate phases. A candidate is **a thin end-to-end slice of the system that produces a user-demonstrable
outcome**. Walk the source artifact section by section and ask, for each cluster of capability:

1. **Could this be demoed on its own?** If yes, it is a candidate phase.
2. **What does it depend on?** A capability that requires another capability to exist first creates a dependency edge —
   the dependency must come earlier in the sequence.
3. **Is it a foundation that nothing depends on yet, but later phases will?** That is a foundational phase. It still
   must be demoable on its own (the operating principle holds — "I can edit the new setting and see it persist"
   qualifies; "we added a database table" does not). Apply the YAGNI rule: cite the specific later phase that requires
   the foundation. Foundations with no named downstream phase fail the evidence test and become deferrals.
4. **Is it a deferral the user named in Step 3?** Mark it as deferred; it lands at the end of the index.
5. **Apply the YAGNI evidence test before keeping the candidate.** Per
   [../../references/yagni-rule.md](../../references/yagni-rule.md), each candidate phase must cite evidence — a
   user-described need from the source artifact, a named downstream-phase dependency, an applicable regulation, a
   documented incident or measured metric, or an existing system surface that breaks without it. Candidates that exist
   only for "completeness", "for future flexibility", "best practice", or symmetry with another effort go straight to
   the deferred-phases list with the reopening trigger named. Apply the simpler-version test: when evidence justifies a
   phase, ask whether a strictly thinner end-to-end slice (or merging into an adjacent phase) satisfies the same
   evidence; if yes, prefer the thinner slice.
6. **Apply the scope gate in the same pass.** Per
   [../../references/scope-justification-rule.md](../../references/scope-justification-rule.md), ask of each candidate:
   does the recorded boundary ask for this, or exclude it by statement or by silence? A candidate names what it descends
   from, which is one of the work item's own language, the visual material the user attached, or the asked-for work it is
   a necessity of. This gate attaches here, to the reasoning you are already doing; no sweep step is added to this skill.
   - A candidate the boundary never asks for is cut, with the citation recorded, and lands in the deferred-phases list
     marked as a scope cut rather than as a YAGNI deferral. The two are different: a scope cut has no reopening trigger,
     because the boundary already settled it.
   - A recorded deprecation in the direction-of-travel answer is treated the same way a stated exclusion is treated.
   - **The floor holds.** The gate cuts subsystems, integrations, and artifacts the boundary never asks for. It never cuts
     behavior required to deliver what the boundary does ask for. A short work item does not enumerate its own
     necessities, and that silence is not exclusion.
   - An upstream artifact is an artifact, not a scope authority. A commitment it carries for something the work item never
     asks for is cut with the citation, not escalated to the user as a choice.

Output of this step (kept in conversation memory, not yet written to file): a list of candidate phases, each tagged with
**kind** (foundation / feature slice / polish / deferral), **demonstrability** (one sentence on what the demo is),
**depends-on** (other candidate phases that must come first), and **justification** (what it descends from). Plus a list of
anything cut for scope, with what it would have done and why.

## Step 5: Sequence the Phases

Order the candidates into a numbered sequence using these rules in priority order:

1. **Dependencies are honored.** A phase never appears before any phase it depends on.
2. **Earliest demoable feature value is preferred.** Among candidates whose dependencies are satisfied, pick the one
   that delivers the most user-recognizable value first. Foundations come first only when their absence blocks every
   demoable feature.
3. **Foundational phases must themselves be demoable.** Re-check each foundation: if the demonstrability statement is
   "we added a thing the system uses internally", merge it forward into the first feature slice that uses it instead of
   giving it its own phase number.
4. **Polish-tier work lands later.** Branding, expiration controls, audit/log views, view counts, accessibility
   refinements, internationalization — these enrich the working core rather than make it work, so they sequence after
   the substantive phases.
5. **Deferrals always land at the end of the index** with a clear "(deferred)" marker. They are listed for traceability
   so the team has a place to slot the work later.

State the proposed sequence to the user in one short message — phase number, name, and the demoable outcome in one line
each — and ask for any reordering before writing the file. The user can override; if they do, capture the reasoning so
it can be reflected in that phase's "why this is phase N" rationale.

## Step 6: Draft the Build-Phase Outline (Write Incrementally)

Before drafting, invoke `han-communication:readability-guidance` to source the shared readability standard into your
context, then apply it as you write the outline, holding the named audience captured in Step 3 (default: a mixed
engineering, product, and leadership reader). The frame governs how a fact is said, never whether a required fact appears
— keep the sequencing, dependencies, and demo steps each phase commits to.

Write [`build-phase-outline.md`](./references/build-phase-outline-template.md) using the template. Write incrementally —
save the file after every block below, never buffer the whole document in conversation memory and write at the end.

1. **Write the front matter, the H1 + intro paragraphs, and the Table of Contents.** Replace `{{this_build}}` and
   `{{the_source}}` in the optional Departures TOC entry with concrete nouns when rendering, or remove that TOC line
   entirely if no departures were captured. Save the file.
2. **Write the Executive Summary** in this order, mirroring the template: goal → shape of the build (3-5 bullets) →
   sequencing rationale → departures (only if any) → deferred phases (only if any) → "Where to look next" pointer. Save
   the file.
3. **Write the Build Phase Index table.** Columns are `# | Phase | Kind | Outcome (one sentence)`. Cap each Outcome cell
   at one short sentence (~15 words). Detailed outcomes belong in the per-phase write-up, not the index. Save the file.
4. **Write the Departures section** (if Step 3 surfaced divergences from the source). Use a parameterized heading naming
   the concrete entities — e.g., `## How V2's Share Differs from V1`, not the generic placeholder. The heading anchor
   stays `{#departures}`. Each divergence is named so individual phase entries can refer to it. Save the file.
5. **Write the Phase Kinds glossary** verbatim from the template. Save the file.
6. **Write each phase entry one at a time, saving after each.** Each entry uses the explicit `{#phase-N}` anchor on the
   heading so deep links survive phase renames. Each entry contains, in order:
   - **Kind.** Foundation, Feature slice, Polish, or Deferred.
   - **Builds on.** A single short line naming the phase(s) this one depends on, or "Nothing — this is the starting
     phase." for Phase 1. This signal must be visible at a glance — a reader landing cold on `#phase-5` should see the
     dependency without reading prose.
   - **What we build.** Plain-language description of the phase's deliverable. One short paragraph or a short bullet
     list (cap roughly six bullets).
   - **Why this is Phase N.** Two to four sentences on why the phase lands at that position. Cite dependencies and
     sequencing rationale.
   - **Justification.** One line naming what this phase descends from: the work item's own language, the visual material
     the user attached, or the asked-for work it is a necessity of. This is its own line, not a clause of the rationale
     above, so a reader can check every phase against the boundary by scanning one field.
   - **Outcome to demonstrate.** A numbered, runnable demo script. A reader who has never seen the system should be able
     to imagine someone walking through the demo from this section alone.
   - **Source citations.** Bullet list of source-artifact sections this phase covers. Use markdown links to specific
     sections of the source artifact. May name section headings by their actual heading text (this is the only place
     implementation-adjacent vocabulary is permitted).
   - **Connects to.** Bullet list of other phases this phase feeds into or builds on. Use the `#phase-N` anchors so
     links survive renames.
   - **Preconditions to verify before starting.** Stakeholder-readable questions or checks the team must resolve before
     this phase can begin. These feed into the Open Questions section.
7. **Write the Open Questions section last.** Aggregate every "Preconditions to verify" item that needs a real decision
   (not just a verification step). For each, present realistic options and a recommended answer with rationale where one
   is supportable.
   - Use the explicit `{#oq-N}` anchor on each open-question heading.
   - Order the questions by the lowest-numbered phase they block, ascending. List carry-over notes (questions that do
     not block any specific phase) at the bottom under a `### Carry-over notes` sub-heading.
   - Each question carries a `**Blocks phase(s).**` line so a stakeholder scanning the section can see at a glance which
     decisions block their next greenlight.

**Apply the plain-language rule to every sentence before writing it.** If a draft sentence names a language primitive,
file/line, function, class, library, internal flag, or implementation pattern, rewrite it behaviorally before it reaches
disk. The only place implementation-adjacent vocabulary is permitted is the per-phase "Source citations" bullet, which
may name source-artifact section headings by their actual heading text.

**Anchor stability is part of the contract.** Every phase heading carries an explicit `{#phase-N}` anchor; every
open-question heading carries an explicit `{#oq-N}` anchor. Renaming a phase or question must never break inbound deep
links. If the project's markdown renderer does not support `{#anchor}` heading attributes, fall back to an
`<a id="phase-N"></a>` line immediately above the heading.

## Step 7: Information-Architect Review of the Rendered Document

Launch the `han-core:information-architect` agent in a single Agent tool call to review the rendered
`build-phase-outline.md` for findability, orientation, scannability, and progressive comprehension. Provide:

- The path to the rendered document.
- A directive: **review the rendered outline as a stakeholder would encounter it**. Specifically: a reader landing cold
  on the document should be able to (a) understand the shape of the work in two minutes from the executive summary
  alone, (b) scan the index and identify phases relevant to their interests, (c) read any single phase entry and
  understand it without reading prior phases, and (d) cite stable phase IDs in tickets and threads.
- A directive to flag any leakage of implementation detail (file paths, function names, library mechanics, language
  primitives) into the plain-language sections — these are content-rule violations the skill must fix before presenting
  the document.
- A directive to flag any phase, precondition, or open question that reads as speculative or future-proofing rather than
  evidence-grounded per [../../references/yagni-rule.md](../../references/yagni-rule.md) — phases justified only by
  "completeness", symmetry with other efforts, "we should probably also build…", or unnamed future flexibility. Such
  items are YAGNI candidates and belong in the deferred-phases list with a reopening trigger, not in the live phase
  index.
- A directive to flag any phase whose `Justification` line names nothing the recorded boundary supports, since a phase
  that cannot trace to the boundary belongs in the deferred list as a scope cut.
- A directive to keep recommendations structural and scoped — do not rewrite prose; propose where headings, ordering, or
  framing should change.

**This reviewer sits outside the visual-material brief rule.** The rule that passes persisted visual material to every
dispatched reviewer applies to the two skills that dispatch a domain-briefed review team, and this skill dispatches one
reviewer with a fixed domain instead. Do not widen this step to a review team, and do not read the rule as requiring the
material be passed here. When the outline's plain-language sections describe visual work, the material's absence from this
brief costs nothing, because the reviewer is checking the document's structure rather than the design it describes.

## Step 8: Apply IA Findings

Read the IA agent's findings. For each finding:

1. **Plain-language leak findings** are treated as required edits — rewrite the offending sentence behaviorally and save
   the file.
2. **Structural findings** (a section is in the wrong place, a heading is misleading, a cross-reference is missing) are
   evaluated and applied if the change preserves the document's contract: every phase still has stable IDs, every phase
   still cross-references the source, the executive summary still stands alone.
3. **Polish findings** (wording, repetition, throat-clearing) are applied if they tighten the document; surfaced to the
   user with a one-line recommendation otherwise.

Save the file after each material change. If the IA agent surfaced findings the user must judge (e.g., "the audience
seems mixed — should this be split into two documents?"), present those to the user with a recommendation in one short
message before finalizing.

## Step 8.5: Readability Pass

Once the Step 8 IA findings are applied and the outline is final, dispatch `han-communication:readability-editor` (one
Agent call) to audit and rewrite the outline's prose against the readability standard. Pass the editor the file path
`{folder}/build-phase-outline.md` and the named audience captured in Step 3 (default: a mixed engineering, product, and
leadership reader); the editor reads han-communication's own canonical rule, so pass no rule path. It must preserve every
fact and operate on prose regions only — never inside code fences, tables, the `{#phase-N}` and `{#oq-N}` heading
anchors, or the source-citation links, which must survive unchanged so deep links still resolve. Apply its rewrite to the
outline file.

Then read the editor's fact-preservation report. **Do not walk the self-check over the text the editor
produced.** The canonical readability rule says the dedicated editor replaces a skill's own readability pass rather than
stacking a second one on top, and a same-model pass over the editor's own fresh output is the ungrounded kind of
self-review that corrupts a correct answer about as often as it fixes a wrong one.

The editor's report has two shapes, and neither is a loss you have to repair:

- It confirms every claim, quantity, named entity, and stated condition survives. Nothing further is needed.
- It names a fact it kept in the original wording to satisfy fidelity. Leave that wording alone rather than re-editing
  it.

**When no usable report comes back** — the editor could not be reached, returned nothing, or returned something you
cannot read as either of those two shapes — walk the checklist below yourself over the outline's prose regions only,
never inside code fences, tables, the `{#phase-N}` and `{#oq-N}` anchors, or the source-citation links. Say in the
closing summary that you did so and why. With no report, the checklist is the only fidelity guard the output has.

Run the readability rule's standardized self-check, which is already in your context from the `readability-guidance`
invocation above. Correct every failure before presenting. Its fidelity criterion is not optional: the standard governs
how the content is said, and drops a required fact only when the reader asked for less and losing it would not change
what they do next.

## Step 9: Present the Final Outline

Summarize for the user in one short message:

- The output file path, plus the boundary record's path.
- The number of phases by kind (foundational / feature slice / polish / deferred).
- The cut list, when anything was cut for scope: what each entry would have done in plain language, and why. Say that any
  of it can be reinstated, and that the user's saying so is itself a valid justification the reinstated phase records.
- The escalation register, when the run took its single stop: what was asked, what came back, and where the answer landed.
  This skill has no escalation step, so the register attaches to the stop rather than standing on its own.
- The number of open questions remaining and whether any block the first phase from starting.
- The IA agent's overall verdict (clean / minor cleanup applied / open structural recommendations remain).
- The next concrete action — typically "review the executive summary and phase 1 entry, then either greenlight phase 1
  to start or reorder before we begin".

Ask whether the user wants to refine specific phases, reorder, add or remove a deferral, or consider the outline ready
for the team to start phase 1.
