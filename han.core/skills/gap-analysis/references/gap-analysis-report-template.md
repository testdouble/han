---
title: "Gap Analysis: {{source_artifact_name}} vs {{target_artifact_name}}"
comparison_direction: "{{source_artifact_name}} (current state) -> {{target_artifact_name}} (desired state)"
scope: "{{one_sentence_describing_what_was_compared_and_what_was_excluded}}"
generated: "{{YYYY-MM-DD}}"
generated_by: "han:gap-analysis"
sections_included:
  - executive_summary
  - indexed_gaps
  - technical_details   # remove this line if section 3 was not requested
  - swarm_findings      # remove this line only if user passed `no swarm` (the swarm runs by default)
---

# Gap Analysis: {{source_artifact_name}} vs {{target_artifact_name}}

## How to Read This Report

This report compares **{{source_artifact_name}}** (what exists today) against **{{target_artifact_name}}** (what is expected). It is layered, so you can stop at any section and still have a complete picture at that level of detail:

- **Section 1 — Executive Summary.** The shape and magnitude of the gap in plain language. Read this if you have two minutes.
- **Section 2 — Indexed Gaps.** Every gap, individually titled and explained in plain language, with a stable ID (e.g., `G-007`) you can cite in tickets, threads, and follow-up work. Read this if you need to discuss specific gaps.
- **Section 3 — Technical Details** *(included only if requested).* Engineering-grade fidelity for each gap: where it lives, what would need to change, and how to act on it. Read this if you are implementing the fix.
- **Section 4 — Swarm Findings** *(included only if a validator/augmenter swarm was run).* Confidence signals, contradictions, and augmentations from a panel of secondary analyses. Read this if you want to know which gaps are most certain.

Every gap has a stable ID. Sections 3 and 4 reference those IDs. If a gap appears in section 2 as `G-007`, you will find its technical detail under `G-007` in section 3 and any swarm commentary under `G-007` in section 4.

**Gap categories used throughout:**
- **Missing** — present in {{target_artifact_name}}, absent in {{source_artifact_name}}.
- **Partial** — present in both, but {{source_artifact_name}} does not fully satisfy {{target_artifact_name}}.
- **Divergent** — present in both, but {{source_artifact_name}} does something materially different from {{target_artifact_name}}.
- **Implicit** — assumed or implied by {{target_artifact_name}} but never made explicit; {{source_artifact_name}} may or may not handle it.

---

## 1. Executive Summary

> Plain language only. No file paths, function names, line numbers, or implementation vocabulary. A non-technical stakeholder must be able to read this section alone and know the shape and magnitude of the gap.

**Bottom line:** {{one_or_two_sentence_verdict_on_overall_alignment_e_g_substantially_aligned_with_three_significant_gaps_or_materially_diverged_in_two_areas}}

**Magnitude at a glance:**

| Category    | Count | Plain-language meaning                                                  |
|-------------|-------|-------------------------------------------------------------------------|
| Missing     | {{n}} | Things {{target_artifact_name}} expects that are not present today.     |
| Partial     | {{n}} | Things that exist but do not fully meet expectations.                   |
| Divergent   | {{n}} | Things that exist but behave differently than expected.                 |
| Implicit    | {{n}} | Expectations that were never made explicit and need a decision.         |
| **Total**   | {{n}} |                                                                         |

**The shape of the gap (3-5 bullets, plain language):**

- {{theme_1_describing_a_cluster_of_related_gaps_in_plain_language}}
- {{theme_2}}
- {{theme_3}}
- {{optional_theme_4}}
- {{optional_theme_5}}

**What this means for the work ahead:** {{two_to_four_sentences_in_plain_language_about_the_practical_implication_no_jargon_no_paths_no_code}}

**Where to look next:** Section 2 lists every gap individually. {{include_if_section_3_present: Section 3 has the technical detail engineers will need.}} {{include_if_section_4_present: Section 4 reports how confident the analysis is and where secondary checks disagreed.}}

---

## 2. Indexed Gaps

> Plain language only. Each gap is a self-contained entry: a reader landing on a single gap via search or a deep link should understand it without reading the rest of the report.

**Index (scan view):**

| ID      | Category   | Title (plain language)                                       |
|---------|------------|--------------------------------------------------------------|
| G-001   | {{cat}}    | {{plain_language_title}}                                     |
| G-002   | {{cat}}    | {{plain_language_title}}                                     |
| G-003   | {{cat}}    | {{plain_language_title}}                                     |
| ...     | ...        | ...                                                          |

> IDs are assigned in the order gaps were identified and are stable for the life of this report. Cite them as `G-NNN` in tickets, comments, and follow-up reports.

---

### G-001 — {{plain_language_title}}

- **Category:** {{Missing | Partial | Divergent | Implicit}}
- **Expected ({{target_artifact_name}}):** {{plain_language_description_of_what_target_calls_for}}
- **Current ({{source_artifact_name}}):** {{plain_language_description_of_what_source_actually_does_or_omits}}
- **Why it matters:** {{one_to_three_sentences_plain_language_consequence_for_users_or_the_business}}
- **Additional context (swarm):** {{optional_plain_language_augmentation_e_g_actor_perspective_note_from_junior_developer_or_secondary_effect_from_a_domain_specialist; omit this line entirely when no swarm augmentation applies to this gap}}
- **Confidence:** {{High | Medium | Low}} — {{one_sentence_reason_e_g_directly_stated_in_both_artifacts_or_inferred_from_context}}

{{repeat_block_for_each_gap_G-002_G-003_etc}}

---

## 3. Technical Details

> Included only when the user requested technical details. Engineers are the audience here. Every entry references a gap ID from section 2 and adds technical fidelity — it does not restate the plain-language explanation.

### How this section relates to section 2

Each entry below is keyed to a gap ID (e.g., `G-007`). The plain-language description is in section 2; this section adds where the gap lives in the codebase or artifact, what specifically diverges, and a concrete remediation direction.

If a gap from section 2 has no entry here, it means no technical action is required (typically `Implicit` gaps awaiting a product decision).

---

#### G-001 — Technical detail

- **Locations:** {{file_path:line_or_anchor; file_path:line_or_anchor}}
- **Relevant identifiers:** {{function_class_module_field_or_API_names}}
- **Specifics of the divergence:** {{precise_technical_description_of_what_target_specifies_vs_what_source_does}}
- **Remediation direction:** {{concrete_change_or_decision_needed_to_close_the_gap}}
- **Effort signal:** {{Trivial | Small | Medium | Large | Unknown}} — {{one_sentence_basis}}
- **Risks / dependencies:** {{anything_that_would_block_or_complicate_remediation}}

{{repeat_block_for_each_gap_with_technical_content}}

---

## 4. Swarm Findings

> Included only when a validator/augmenter swarm was run. This section reports how secondary agents corroborated, contradicted, or augmented the primary gap list. It does not introduce new gaps in isolation — anything the swarm surfaced that warrants tracking has already been folded into section 2 with its own ID.

### How this section relates to sections 2 and 3

Entries are grouped by the kind of signal the swarm produced. Each entry references the affected gap IDs. Use this section to gauge confidence and to spot disagreements that may warrant a second look before acting.

### Swarm composition

- **Validators run:** {{list_validator_agent_names_and_roles}}
- **Augmenters run:** {{list_augmenter_agent_names_and_roles}}
- **Total runs:** {{n}}

### Confirmations

> Gaps where the swarm independently agreed with the primary analysis. Higher confidence; safe to act on.

- **G-{{id}}** — {{which_swarm_agents_confirmed_and_what_they_added_if_anything}}
- {{repeat}}

### Contradictions

> Gaps where at least one swarm agent disagreed with the primary analysis (different category, different severity, or claimed the gap does not exist). Treat as needing human adjudication before remediation.

- **G-{{id}}** — **Disagreement:** {{summary_of_the_disagreement}}. **Adjudication note:** {{author_or_skill_one_line_recommendation_or_unresolved}}.
- {{repeat}}

### Augmentations

> Additional context the swarm contributed to existing gaps — refined explanations, extra examples, related risks. Does not change the gap itself, but enriches understanding.

- **G-{{id}}** — {{augmenting_observation_in_plain_language}}
- {{repeat}}

### Confidence summary

| Confidence | Gap IDs                          | Interpretation                                              |
|------------|----------------------------------|-------------------------------------------------------------|
| High       | {{G-001, G-004, ...}}            | Confirmed by multiple swarm agents; safe to act on.         |
| Medium     | {{G-002, ...}}                   | Confirmed by some, augmented by others; minor refinement.   |
| Low        | {{G-003, ...}}                   | Contradicted or only partially supported; adjudicate first. |

---

*End of report. If you need to cite a specific gap elsewhere, use its `G-NNN` ID — those IDs are stable for the life of this report.*
