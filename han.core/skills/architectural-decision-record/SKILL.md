---
name: architectural-decision-record
description: >
  Create, extract, or convert an ADR (architectural decision record) using the ADR template. Use
  when creating new ADRs, extracting an ADR from existing documentation, converting a document
  into an ADR, recording an architecture or design decision, or updating the status of an existing
  ADR. Does not create or update enforceable coding standards or conventions — use coding-standard
  for that. Does not write feature or system documentation — use project-documentation instead.
argument-hint: [topic-or-title or document-path]
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(mkdir *), Bash(find *)
---

# Create ADR

## Operating Principles

- **YAGNI applies to ADRs themselves.** Apply the evidence-based YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md). An ADR is worth recording only when there is a concrete forcing function today — a real decision the team is actively making, an existing code path or architectural choice that will be locked in by this record, an applicable regulation, a customer commitment, or a documented incident that drove the choice. ADRs about decisions that don't have to be made yet, "for future flexibility", "best practice says we should pick X", or symmetry with other ADRs ("we have one for auth, so we should have one for billing") are YAGNI candidates and the ADR should not be written. When proposed, recommend deferral with the trigger that would justify writing the ADR (a real decision arising, a real incident, a real regulation taking effect). The user always wins; the rule's job is to make the cost of writing speculative architectural records visible — every ADR is a future-reader's load and a pattern future agents will treat as committed.
- **The companion evidence rule applies to the ADR's supporting evidence.** Apply the evidence rule from [../../references/evidence-rule.md](../../references/evidence-rule.md) to the citations that justify the ADR's decision and rejected alternatives. Name the trust class of each citation (codebase, web, provided); mark single-source web claims that drive the chosen option; and when no evidence at any tier supports a claimed trade-off, label it rather than presenting it as a weak preference.

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Step 1: Determine Mode

Determine which mode to operate in based on the user's request:

| Mode | When | Initial Status | Then |
|------|------|----------------|------|
| Creating new | Building an ADR from scratch for a new or recent decision | `proposed` | → Step 2 |
| Converting existing | User provides an existing document to convert into an ADR | `accepted` | → Step 2 |
| Updating existing | Modifying an existing ADR (status change, superseding, adding notes) | — | Read the existing ADR, → Step 3 |

## Step 2: Discover Project Structure

1. **Retrieve project config:** Resolve project config: read CLAUDE.md's `## Project Discovery` section for docs and ADR directories; fall back to project-discovery.md; fall back to Glob defaults (`docs/`, `docs/adr/`). Continue without any keys that remain unfound.

2. **Determine the ADR directory:** Use the ADR directory if found; otherwise use `{docs-dir}/adr/` if a docs directory was found; otherwise use `docs/adr/`. Run `mkdir -p` on the resolved directory to ensure it exists.

3. **Enumerate existing ADRs:** Use Glob to find existing `.md` files in the ADR directory.

4. **Check existing ADR format:** If existing ADRs were found, read one to understand the project's format. If it differs from [template.md](./references/template.md), ask the user whether to match the existing format or use this skill's template.

5. **Discover the filename hierarchy taxonomy:** ADRs are organized by a one- or two-level hierarchy encoded in the filename so related decisions sort together in a directory listing. Discover the taxonomy that applies to *this* project — never hardcode it.
   - **From existing filenames:** If existing ADRs were enumerated, parse their filenames to extract the leading hierarchy segments already in use (e.g., `auth-session-storage.md` → top-level `auth`; `auth-tokens-rotation.md` → top-level `auth`, second-level `tokens`). Build a list of top-level prefixes and known second-level prefixes per top-level.
   - **From project context:** Read CLAUDE.md and project-discovery.md (paths from project context above) to identify the project's languages, frameworks, runtimes, subsystems, and bounded contexts. Each is a candidate top-level hierarchy (e.g., `auth`, `billing`, `api`, `worker`, `postgres`, `terraform`).
   - **Carry forward to Step 4:** the discovered top-level prefixes (existing + candidate) and any second-level prefixes already in use under each.

## Step 3: Gather Context

1. From the arguments and conversation, determine:
   - **Topic/title** — What is the ADR about?
   - **Decision** — What was decided and why?
   - **Alternatives** — What other options were considered?
   - **Forcing function** — What concrete trigger requires this decision *now*? Per [../../references/yagni-rule.md](../../references/yagni-rule.md), an ADR requires evidence that the decision must be made today: an active engineering choice, a code path locking in, a regulation taking effect, a customer commitment, a documented incident driving the choice. If no forcing function exists, recommend deferring the ADR rather than writing it; surface the recommendation to the user with the trigger that would justify revisiting.
2. If any of these are unclear or missing, use `AskUserQuestion` to clarify before writing. If the forcing function is the unclear one, surface that explicitly — "I don't see a current trigger forcing this decision; recommend deferring the ADR until {trigger}. Override?"

### Explore the Codebase

Skip agent exploration if the user has already provided full context (converting or updating). When creating a new ADR with sparse context, launch 1-2 `han.core:codebase-explorer` agents to discover evidence. Use 1 agent for narrow decisions, 2 when the decision crosses multiple system areas. Explorer 1 focuses on code affected by the decision topic (current patterns, entry points, core logic). Explorer 2 focuses on existing ADRs, coding standards, and project docs (starting from the docs directory found in Step 2).

### Compile Evidence

After agents complete (or if skipped), merge findings with user-provided context. Agent discovery items map to Context (current state of the codebase), Decision (why the chosen option fits), and Notes (key files table, cross-references). Merge duplicates and resolve conflicts between agents.

### Dispatch Architectural Review

Skip this sub-step in update mode when only status is changing. Otherwise, launch review agents **in parallel** against the compiled evidence, the proposed decision, and the considered alternatives. Pass each agent the topic, the proposed decision, the alternatives, and the evidence compiled above.

1. **Launch architect agent** — use `han.core:software-architect` when the decision is scoped to a single codebase or bounded context (module boundaries, class and interface design, abstraction points, refactoring paths). Use `han.core:system-architect` when the decision crosses service or bounded-context seams (integration patterns, data ownership across services, failure-domain topology, context-map relationships). If uncertain, prefer `han.core:system-architect`. Prompt: "Review the proposed decision against the compiled evidence. For the chosen option, identify structural or topological risks that the ADR's Consequences section should name. For each rejected alternative, identify the strongest case *for* it that the ADR's Decision section needs to rebut or concede. Return findings keyed to the ADR's Decision, Decision Drivers, and Consequences sections."

2. **Launch han.core:risk-analyst agent** — prompt: "Assess the risk of adopting the chosen option versus staying with the current approach or adopting each rejected alternative. Score each on likelihood, severity, blast radius, and reversibility. Return findings keyed to the ADR's Consequences section, and flag any dimension where a rejected alternative scores better than the chosen option — the ADR needs to explain why."

3. **Launch han.core:junior-developer agent in artifact-review mode** — prompt: "Read the proposed Context, Decision, Decision Drivers, and Considered Options as a generalist encountering this decision for the first time. Surface: unexplained jargon, assumptions baked into the Decision Drivers without evidence, alternatives dismissed without a reason a generalist would accept, and places where the ADR relies on context a future reader will not have. Return a short list of clarifying questions and must-answer gaps."

Merge the three agents' findings into the Decision, Decision Drivers, and Consequences sections before writing. Where an agent raises a must-answer gap that requires user judgment, surface it with a recommended resolution rather than resolving silently.

## Step 4: Write the ADR

1. **Convert source document (if converting):** Read the source document and map sections to ADR sections using the mapping at [conversion-mapping.md](./references/conversion-mapping.md).

2. Copy the template from [template.md](./references/template.md)

3. **File name and location:** `{top-level}[-{second-level}]-{kebab-case-title}.md` — a one- or two-level hierarchy prefix followed by the decision's specific title. The hierarchy must come from the taxonomy discovered in Step 2.6, never invented or hardcoded.
   - **Top-level (required):** the highest-level grouping the decision belongs to (e.g., `auth`, `billing`, `api`, `postgres`). Reuse an existing top-level prefix from Step 2.6 when one fits; only introduce a new top-level when no existing prefix applies, and prefer one that matches a subsystem, bounded context, or technology already named in CLAUDE.md or project-discovery.md.
   - **Second-level (optional):** add only when the top-level has — or will plausibly grow — multiple ADRs that benefit from a sub-grouping (e.g., `auth-tokens-…`, `auth-sessions-…`). Reuse an existing second-level prefix from Step 2.6 when one fits. Skip the second level when the ADR is the only one (or one of a few) under its top-level.
   - **Kebab-case-title (required):** the specific decision, kebab-cased, distinct from the hierarchy prefix.
   - If the discovered taxonomy offers more than one reasonable placement, ask the user to choose before writing.
   - Place the file in the directory from Step 2.

4. **Fill in metadata:** Status per Step 1 mode (`proposed` for new, `accepted` for converted; use `deprecated` or `superseded` when updating). Date Created / Last Updated: current date and time.

5. **Fill each required section** following the template's HTML comments for guidance.

6. **Notes section must include:**
   - **Key files table** — important files related to this decision:
     | File | Purpose |
     |------|---------|
     | `path/to/file` | Description |
   - **Cross-references** — links to related ADRs (e.g., `See also [Soft Deletes](./data-soft-deletes.md)`)
   - **Related docs** — links to related docs outside the ADR directory

7. **If updating an existing ADR:** Update Status, Last Updated, and add notes about what changed. If superseding, cross-reference the new ADR and set the old ADR's status to `superseded`.

8. **Handle source document (conversions only):** If the source document is fully subsumed, delete it and update references in CLAUDE.md, AGENTS.md, and other markdown files. If it retains useful content, add a link to the new ADR and remove migrated sections.

## Step 5: Integration

1. Add a `See` reference in the relevant section of any existing CLAUDE.md or AGENTS.md, following the pattern of existing ADR references. Place it near the feature or component the ADR describes.
2. Search for related documentation (other ADRs, coding standards, feature docs) and add cross-references in the new ADR's Notes section.
3. Add back-references from related docs where they add value.
4. If converting (Step 4), confirm all old references to the source document are updated.

## Step 6: Verification

Read back the ADR file and confirm:

1. All metadata fields are filled (no `{placeholder}` values remain) and template structure from [template.md](./references/template.md) was followed
2. All required sections (Context, Decision Drivers, Considered Options, Decision, Consequences, Notes) have substantive content, and Notes includes a key files table with paths verified by Glob
3. Cross-references in the ADR point to documents that exist
4. Agent configuration file references (CLAUDE.md/AGENTS.md) correctly point to the new ADR
5. If converting: source document was handled (deleted or updated with link)
6. Fix any issues found
