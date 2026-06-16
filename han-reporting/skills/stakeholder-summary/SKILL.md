---
name: "stakeholder-summary"
description: >
  Produces a plain-language stakeholder summary from an existing feature
  specification, for sharing with non-technical stakeholders before
  implementation kicks off. Use when the user wants to draft a stakeholder
  summary, executive summary, or business summary of a feature spec or PRD.
  Does not write the spec itself — use plan-a-feature. Does not sequence the
  build into phases — use plan-a-phased-build. Does not produce an
  implementation plan — use plan-implementation.
argument-hint: "[path to feature-specification.md, optional: extra context for the summary]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(find *)
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Operating Principles

- **Plain language only.** The stakeholder summary never contains file paths, line numbers, function or class names, library mechanics, database tables, API shapes, or language primitives. Use product-level subsystem names ("the telematics provider", "the customer list"), user-facing UI vocabulary (badge, popup, list), and behavioral verbs (create, edit, update, claim, merge, sync). A non-technical stakeholder must be able to read the document end-to-end without translation.
- **Center the customer, not the system.** Lead with the problem the customer experiences, then the capabilities introduced, then the experience, then the data flow, then what is out of scope, then the questions. The system is the means, not the subject.
- **High level only.** A stakeholder summary is for getting feedback before kickoff. Skip anything that would only matter once implementation has started: schemas, sequencing, file boundaries, test plans, rollout strategy, telemetry. If a detail is only meaningful to engineers, it does not belong in this document.
- **Diagrams carry weight.** Use Mermaid for both the user experience flow and the data flow before-and-after. Diagrams are not decoration — they replace paragraphs of prose, so they must be readable on their own.
- **Open questions are stakeholder-shaped.** The closing questions are framed in customer or product language, not engineering language. They ask stakeholders to confirm framing, scope, and trade-offs — not to make technical decisions.

# Stakeholder Summary

## Step 1: Resolve the Source and Output Paths

Read the user's argument and conversation context. Identify:

1. **The source specification** — the file the summary will be derived from. Usually a `feature-specification.md`, but may be a PRD, design doc, or similar. If the user did not name a file, ask in one short message which file to summarize.
2. **The output path** — `stakeholder-summary.md` in the **same directory** as the source file. Do not place it anywhere else unless the user explicitly says so.
3. **Shaping context** — anything the user added about the audience, tone, or emphasis ("this is going to leadership", "lean into the customer-trust angle"). Capture it for use in Steps 3 and 4.

If `stakeholder-summary.md` already exists in the target directory, ask the user whether to overwrite, append a timestamp suffix, or stop. Do not silently overwrite.

## Step 2: Read the Source and Project Context

Read the feature specification end-to-end. Then capture:

- The customer problem the feature addresses, in the customer's own words where possible.
- The capabilities the feature introduces, expressed as user-visible actions (not API endpoints, not database changes). This is true even if the outcome is an API and not user visible yet. We want to provide what the spec will do for our end users.
- The user experience: what the customer sees, what choices they make, what happens after each choice.
- The current data flow (what happens today) and the new data flow (what will happen after this ships), at the level of "system A sends X to system B".
- What the spec explicitly says is out of scope, deferred, or handled elsewhere.
- Any open questions the spec already names.

Read the CLAUDE.md in the project named in the specification and `project-discovery.md` if present — they may surface vocabulary or naming conventions the stakeholder summary should follow.

## Step 3: Translate Technical Content into Plain Language

For every piece of content destined for the summary, apply a translation pass:

- **System names generalize one level up.** "PostgreSQL" → "the database"; "the FleetCommand API" → "the telematics provider"; "the React component" → "the screen".
- **API and data shapes become user-visible behaviors.** "POST /units/claim" → "Claim it"; "PATCH /customers/1/update endpoint with [field_name]" → "update the existing customer record".
- **Engineering trade-offs become product trade-offs.** "Eventually consistent reads from the replica" → not mentioned; "we are not building bulk actions" → "Bulk actions. One record at a time for now."
- **Acronyms and brand names** stay only if a stakeholder would already know them (e.g., the product's own brand, well-known integrations). Otherwise generalize.

If a piece of content cannot be translated without losing meaning, leave it out. The summary is for feedback on shape and direction, not technical correctness.

## Step 4: Draft the Stakeholder Summary

Use the template at [`references/stakeholder-summary-template.md`](./references/stakeholder-summary-template.md). Write the file at the resolved output path, filling in each section in order:

1. **Title** — `# {{Feature Name}} — Stakeholder Summary`. Derive the feature name from the source spec's title or H1.
2. **What problem are we solving?** One or two short paragraphs from the customer's point of view, followed by a short bulleted list of the capabilities the feature introduces (each as a bold name plus one sentence in the customer's voice).
3. **What does this open up?** Four to six bullets naming the outcomes the feature enables — customer confidence, data trust, downstream features unblocked, etc. Each bullet leads with a bold phrase and adds one sentence of why it matters.
4. **What will the user experience look like?** One short paragraph framing the experience, followed by a Mermaid `flowchart TD` showing the user-facing decision and its branches. Keep nodes short and customer-readable. It is acceptable to omit if the change truly has no user interface impact, but this will be rare.
5. **How does the data flow today vs. after this change?** Mermaid `flowchart LR` diagrams. **The number of diagrams in each subsection — both "today" and "after this change" — matches the number of meaningfully distinct paths the spec actually describes. Never invent paths to hit a template count. Never collapse genuinely distinct paths into one diagram to fit a template count. One today diagram and three "after this change" diagrams is correct if that is what the spec needs; two today diagrams and one "after this change" diagram is also correct if that is what the spec needs.** Both subsections follow the same shape:

  - **Today.** One diagram per meaningfully distinct *current* path, each showing the pain point with `style` highlighting on the problem nodes. If there is only one current path worth showing (the common case), produce a single "Today" diagram with a one-sentence lead-in above it and no prose block below — the lead-in is enough. If there are two or more current paths, each diagram gets a one-sentence lead-in *and* a 3 to 5 sentence prose block immediately below that walks the reader through the flow, names the pain point, and names what makes this current path distinct from the other current paths.
  - **After this change.** One diagram per meaningfully distinct *new* path, highlighting the resulting good state in green. Every "after this change" diagram is followed by a 3 to 5 sentence prose description placed immediately below the diagram, walking the reader through the flow the diagram shows. When there are two or more "after this change" paths, each prose block must additionally name the trigger or condition that sends the customer down this path rather than the others, and the outcome that differs between paths — a stakeholder reading the prose blocks back-to-back should be able to articulate when each path applies. When there is only one "after this change" path, the prose still walks the flow but does not manufacture a contrast against paths that do not exist.
  - For all Mermaid charts, do not literally match the template unless the spec aligns. Use a chart that makes sense for the user experience and data flows being described by the feature specification itself. The template contains examples only.
6. **What is intentionally not in this slice?** Bulleted list of items deliberately excluded. Each item leads with a bold phrase and a one-sentence reason or pointer to where it lives instead. Close the section with a single one-line catch-all confirmation prompt directed at stakeholders — something like *"If any of these cuts would block your team, flag it before we kick off."* That one line replaces the per-item "is this OK?" question that would otherwise duplicate into the next section.
7. **What we are asking stakeholders.** Three to five open questions that present a real trade-off, framing call, or sequencing choice the stakeholder must weigh in on. **A question only earns a spot here if it asks the stakeholder to choose between two or more substantive alternatives, or to confirm framing the document presents as genuinely open.** A bare "is it acceptable that X is deferred?" — where X is already listed in "What is intentionally not in this slice?" — is the duplication this rule exists to prevent. Push those back into the prior section's closing prompt. Questions in this section must either:
  - present a trade-off with two or more named alternatives (for example, *"Remove the broken button vs. show a placeholder message — which fits the brand better?"*), or
  - confirm framing or scope that is not already settled by the body of the document (for example, *"Are we right to treat this as a v1 for desktop users only, or should mobile parity be part of v1?"*), or
  - surface an open question the source spec itself names as unresolved.
  Frame every question so a non-technical reader can answer it, and connect each one to a section above it so the reader can see what it follows from.

**Write the file in one pass once the content is ready** — the document is short enough that incremental saves are unnecessary. After writing, read it back end-to-end and rewrite any sentence that still leaks implementation detail.

## Step 5: Self-Check Before Presenting

Run three passes before reporting the summary as done. Each pass has a single focus, and **each pass begins with a fresh Read of the output file from disk** — do not check against working memory or the draft you held while writing. The Read tool call is required, not optional. Working memory drifts from what actually landed on disk; only the file contents matter.

### Pass A: Internal-consistency / contradiction check

**First, use the Read tool to load the output file from disk.** Then list every load-bearing claim the document makes — capability included, capability deferred, behavior described in a diagram, prose narrative below a diagram, item under "What is intentionally not in this slice", trade-off or framing call in "What we are asking stakeholders". For every pair of claims, ask: does claim X assert something that claim Y denies or implies the opposite of? Pay special attention to:

- **Diagram vs. exclusion.** A capability shown in any data-flow diagram (or its prose block below) that "What is intentionally not in this slice" says is deferred, and vice versa. This is the most common form of contradiction: a diagram walks the customer through a step that uses a capability the exclusion section says is not in the slice. The fix is almost always to disambiguate the wording on one side — clarifying that the diagram is showing a narrower capability than the exclusion appears to forbid, or vice versa.
- **UX vs. data flow.** A behavior in the user-experience flowchart that contradicts a behavior in any data-flow diagram, or vice versa.
- **Outcomes vs. exclusion.** A capability named in "What does this open up?" that "What is intentionally not in this slice" says is deferred.
- **Diagram vs. diagram.** An assumption in the prose under one diagram that conflicts with an assumption in the prose under another diagram.
- **Vocabulary collisions.** The same term used to mean two different things in different sections (for example, "share" used both for *sending a URL another user can open* and for *publishing a view to your whole organization*), or different terms used for the same thing in different sections.

For every contradiction found, take an evidence-based approach to resolving it:

1. **Re-read the source specification** identified in Step 1. The spec is the authoritative source for what the feature does and does not do. Most contradictions in the summary are translation errors — the spec is internally consistent and the summary mistranslated one side.
2. **If the spec resolves the contradiction:** edit the summary so both sides match the spec. If the apparent contradiction is actually a terminology collision (the same word covering two distinct concepts), disambiguate the wording — typically by renaming one usage to a more specific term that the source spec, its CLAUDE.md, or its project-discovery vocabulary already supports. Record in working memory which contradiction was resolved and how, so the same disambiguation can be applied uniformly across every section.
3. **If the spec does not resolve the contradiction** — because the spec is silent on the point, the spec itself is internally inconsistent, or the resolution depends on a judgment call only the user can make — **stop and ask the user.** Do not guess. Use `AskUserQuestion` to surface a structured ask containing:
  - **A plain-language description of the contradiction**, naming both sides explicitly ("Section X says A; Section Y says B; these conflict because…"). Quote the actual phrasing from each section.
  - **Two to four resolution options.** Typical patterns: keep A and rewrite B; keep B and rewrite A; reconcile by disambiguating terminology and using the disambiguated terms in both sections; move the contradicting capability into "What is intentionally not in this slice" and remove it from elsewhere.
  - **Your recommended option, marked clearly,** with a one-sentence reason grounded in the source spec, the project's conventions, or the stakeholder framing the user provided in Step 1. The recommendation must be a concrete option from the list above, not a fresh suggestion.
  - **A direct request that the user pick which resolution to apply.**

After applying any contradiction-driven edits, Read the file from disk again before continuing. Pass B and Pass C must run against the post-fix contents.

### Pass B: Plain-language audit

**First, use the Read tool to load the output file from disk.** Then read the document as a non-technical stakeholder. For each sentence, ask: would a reader without engineering context understand this without translation? Fix anything that fails. Specifically verify:

- **No engineering artifacts.** No file paths, function names, class names, database tables or columns, API endpoints, HTTP verbs, library or framework names, environment variables, queue or topic names, or language primitives.
- **No engineering hedges.** No "eventually consistent", "idempotent", "race condition", "backfill", "migration", "schema", "payload", "request/response", "stateless", "async", "webhook", "polling vs. push", or similar. If a concept like this is load-bearing, restate it as a user-visible behavior or omit it.
- **No leftover scaffolding.** Template placeholders, TODOs, "TBD", or example text from the template that was not replaced with real content.
- **Closing questions are stakeholder-answerable.** A non-technical reader can give a real answer without asking an engineer what the question means.

If Pass B required any edits, apply them with Edit, then **Read the file again from disk** before starting Pass C. The Pass C read-through must run against the post-fix contents, not your memory of what you intended to fix.

### Pass C: Reading-order and progressive-disclosure check

**First, use the Read tool to load the output file from disk again** — even if Pass B required no edits. This re-load is what makes Pass C an actual third pass rather than a continuation of Pass B's attention. Then read the document straight through, top to bottom, as someone arriving cold. Verify the document builds on itself rather than assuming context from a later section:

- **The opening establishes the customer problem before naming any capability.** A reader should know *who is hurting and why* before they see *what we are building*.
- **Each section uses only vocabulary the reader has already encountered.** A noun that appears in the data-flow diagram should have been introduced in the problem or capabilities sections — not first defined inside the diagram. Acronyms and product-internal names appear only if a stakeholder would already know them; otherwise generalize one level up ("the telematics provider", "the customer list").
- **Diagrams are readable on their own.** Node labels and edge labels tell the story without requiring the surrounding prose. A reader who only skims the diagrams should still get the shape of the change.
- **Diagram counts match the spec, not the template.** Both "today" and "after this change" subsections have one diagram per meaningfully distinct path in the spec — no padding to two, no collapsing distinct paths into one. A spec with one current path and three new paths should produce 1 today diagram + 3 after-this-change diagrams. A spec with two current paths and one new path should produce 2 today diagrams + 1 after-this-change diagram.
- **Every "after this change" diagram has a 3-5 sentence prose block immediately below it.** The block walks through the flow. When two or more "after this change" paths exist, each block also names what triggers this path and what outcome differs from the others, so a stakeholder reading the blocks back-to-back can articulate when each path applies. When only one "after this change" path exists, the block walks the flow without manufacturing a contrast against absent siblings.
- **The "Today" subsection scales the same way.** A single today diagram needs only its one-sentence lead-in — no prose block below. Two or more today diagrams each get a 3-5 sentence prose block below that walks the flow, names the pain point, and names what makes this current path distinct from the other current paths.
- **The "today vs. after this change" pairing is obvious.** The before-and-after diagrams sit close enough together that the contrast is visible without scrolling back and forth.
- **The "intentionally not in this slice" list comes after the reader understands what *is* in the slice.** Out-of-scope only makes sense once in-scope is concrete.
- **The closing questions follow from the body.** Each question should connect to a specific section above it — not introduce a new topic the document never mentioned.
- **No question in "What we are asking" restates an item from "What is intentionally not in this slice".** For each closing question, find the exclusion item it would map to. If the question is essentially *"is this exclusion OK?"* with no new trade-off or alternative attached, remove it — the closing one-liner at the bottom of "What is intentionally not in this slice" already collects that confirmation. Every remaining question in "What we are asking" must present a named alternative, an unresolved framing call, or an open question the spec itself names.

If any check in any pass fails, fix it with Edit and Read the file again before re-running the affected pass. If a Pass A edit changes content that Pass B or Pass C already cleared, re-run those passes against the new content — contradiction fixes can re-introduce language or reading-order issues that the earlier passes caught. Do not present a summary that fails Pass A or Pass B — a stakeholder who reads a contradiction or has to ask "what does X mean?" has already lost trust in the document.

## Step 6: Present the Summary

Summarize for the user in one short message:

- The output file path.
- The number of capabilities introduced, the number of "what this opens up" outcomes, and the number of open questions.
- The next concrete action — typically "review the summary, especially the open questions section, and share it with stakeholders, or tell me what to tighten before you do".

Ask whether the user wants to refine wording, add or remove a question, or consider the summary ready to share.
