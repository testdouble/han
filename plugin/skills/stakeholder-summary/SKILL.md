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

Use the template at [`references/stakeholder-summary-template.md`](references/stakeholder-summary-template.md). Write the file at the resolved output path, filling in each section in order:

1. **Title** — `# {{Feature Name}} — Stakeholder Summary`. Derive the feature name from the source spec's title or H1.
2. **What problem are we solving?** One or two short paragraphs from the customer's point of view, followed by a short bulleted list of the capabilities the feature introduces (each as a bold name plus one sentence in the customer's voice).
3. **What does this open up?** Four to six bullets naming the outcomes the feature enables — customer confidence, data trust, downstream features unblocked, etc. Each bullet leads with a bold phrase and adds one sentence of why it matters.
4. **What will the user experience look like?** One short paragraph framing the experience, followed by a Mermaid `flowchart TD` showing the user-facing decision and its branches. Keep nodes short and customer-readable. It is acceptable to omit if the change truly has no user interface impact, but this will be rare.
5. **How does the data flow today vs. after this change?** Mermaid `flowchart LR` diagrams:
  - today (showing the pain point with `style` highlighting on the problem nodes)
  - after-this-change for each meaningful path (highlighting the resulting good state in green).
  - Match the diagram count to the actual number of paths in the spec — do not invent paths just to mirror the template.
  - For all Mermaid charts, do not literally match the template unless the spec aligns. Use a chart that makes sense for the user experience and data flows being described by the feature specification itself. The template contains examples only.
6. **What is intentionally not in this slice?** Bulleted list of items deliberately excluded. Each item leads with a bold phrase and a one-sentence reason or pointer to where it lives instead.
7. **What we are asking stakeholders.** Three to five open questions, phrased so a non-technical reader can answer them. Frame them as framing/scope/trade-off questions, not technical decisions.

**Write the file in one pass once the content is ready** — the document is short enough that incremental saves are unnecessary. After writing, read it back end-to-end and rewrite any sentence that still leaks implementation detail.

## Step 5: Self-Check Before Presenting

Before reporting the summary as done, verify:

- No file paths, function names, class names, database tables, API endpoints, or library names appear in the document.
- Every Mermaid diagram renders mentally — node labels are short, edges are labeled where the relationship is not obvious, and the diagram tells a story without needing the surrounding prose.
- The "intentionally not in this slice" list matches what the source spec actually defers — nothing fabricated.
- The closing questions are answerable by a stakeholder without engineering context.

If any check fails, fix it before presenting.

## Step 6: Present the Summary

Summarize for the user in one short message:

- The output file path.
- The number of capabilities introduced, the number of "what this opens up" outcomes, and the number of open questions.
- The next concrete action — typically "review the summary, especially the open questions section, and share it with stakeholders, or tell me what to tighten before you do".

Ask whether the user wants to refine wording, add or remove a question, or consider the summary ready to share.
