---
title: "{{initiative_name}} — Build Phase Outline"
source_artifact: "{{relative_path_to_source_artifact_or_none_if_built_from_conversation}}"
audience: "{{e_g_engineering_product_leadership_mixed}}"
generated: "{{YYYY-MM-DD}}"
generated_by: "han.core:plan-a-phased-build"
---

<!--
WHAT BELONGS IN THIS FILE — non-negotiable plain-language contract

This document describes the order in which {{initiative_name}} will be built.
The work is broken into a sequence of phases. Each phase is a thin end-to-end
deliverable that can be demonstrated to a real person — not a layer of code with
no visible behavior. Each phase builds on the one before it, so as the work
ships, the system becomes progressively more functional.

The audience is mixed engineering, product, and leadership unless stated
otherwise in the front matter. Plain language is the default surface. The body
of this document does NOT contain file paths, line numbers, function or class
names, library mechanics, language primitives, or internal flag names. Brand
names generalize one level up — "PostgreSQL" → "the database", "NATS" → "the
events processing system". The exception is the per-phase "Source citations"
line, which may name a source-artifact section by its actual heading text.

ANCHOR STABILITY RULE (load-bearing)

Phase headings carry an explicit `{#phase-N}` anchor — number-only, name-independent.
Renaming a phase does NOT break inbound deep links. If your renderer does not
support `{#anchor}` heading attributes, replace each phase heading with an
adjacent `<a id="phase-N"></a>` line above the heading instead. Treat the same
rule for `{#oq-N}` on open-question headings.

If a phase is not demoable to a real person, it is either too small (merge it
forward into the next phase that does become demoable) or too horizontal (it is
a layer, not a slice — re-think it as a thinner end-to-end strip).
-->

# {{initiative_name}} — Build Phase Outline

This document describes the order in which {{initiative_name}} will be built. The work is broken into a sequence of **phases**, where each phase is a thin end-to-end deliverable that can be demonstrated to a real person, and each phase builds on the one before it. {{one_to_two_sentences_naming_what_the_initiative_is_in_plain_language}}

This document is the companion to [{{source_artifact_filename}}]({{source_artifact_relative_path}}). The source artifact describes *{{what_the_source_describes_in_one_phrase_e_g_what_exists_today_what_is_missing}}*. This document describes *the order in which the work will be built to close that picture*. Every phase below cites the source-artifact sections it covers, so anyone can trace a phase back to source.

<!--
If no source artifact exists (the build was scoped from conversation alone),
replace the paragraph above with one stating that explicitly and summarizing the
context that scoped the build.
-->

## Table of Contents

- [Executive Summary](#executive-summary)
- [Build Phase Index](#build-phase-index)
- [How {{this_build}} Differs from {{the_source}}](#departures)  <!-- remove this line if no departures from source were captured -->
- [Phase Kinds](#phase-kinds)
- [Build Phases](#build-phases)
  - [Phase 1: {{phase_1_plain_language_name}}](#phase-1)
  - [Phase 2: {{phase_2_plain_language_name}}](#phase-2)
  - {{repeat_for_every_phase_using_anchor_phase_N}}
  - [Phase {{N_deferred}} (Deferred): {{deferred_phase_name}}](#phase-{{N_deferred}})  <!-- include only if any deferrals -->
- [Open Questions](#open-questions)

---

## Executive Summary {#executive-summary}

> Plain language only. No file paths, function names, line numbers, or implementation vocabulary. A non-technical stakeholder must be able to read this section alone and walk away with the shape of the build, the order of phases, the named departures (if any), and what was deferred (if anything).

**The goal:** {{one_to_two_sentence_statement_of_what_fully_shipped_looks_like}}

**The shape of the build (3-5 bullets, plain language):**

- {{theme_1_describing_an_arc_of_phases_e_g_phases_1_2_lay_foundations_then_phase_3_delivers_the_first_end_to_end_slice}}
- {{theme_2}}
- {{theme_3}}
- {{optional_theme_4}}
- {{optional_theme_5}}

**Sequencing rationale, in plain language:**

{{two_to_four_sentences_explaining_why_the_build_is_ordered_the_way_it_is_e_g_foundations_first_because_the_share_role_choice_must_exist_before_any_share_link_can_authorize_a_visitor_then_the_first_demoable_slice_then_polish}}

**Departures from the source artifact (if any):**

- {{named_departure_1_e_g_role_based_authorization_replaces_the_v1_hardcoded_read_only_model_one_short_sentence_each}}
- {{named_departure_2}}

<!-- Remove the entire Departures block (heading + bullets) if no departures from source were captured. -->

**Phases deliberately deferred:**

{{one_to_three_sentences_naming_what_was_deferred_and_why_e_g_url_shortening_is_listed_at_the_bottom_as_a_later_phase_because_the_long_signed_url_is_acceptable_in_email_and_chat_until_evidence_says_otherwise}}

<!-- Remove the entire Deferred block (heading + paragraph) if nothing was deferred. -->

**Where to look next:** The [Build Phase Index](#build-phase-index) lists every phase in order. {{include_if_departures_present: The [departures section](#departures) names the new behaviors that shape the rest of the plan.}} Detailed write-ups follow under [Build Phases](#build-phases). Decisions the team must resolve before phase 1 can start are at [Open Questions](#open-questions).

---

## Build Phase Index {#build-phase-index}

> The scan view. One row per phase, in build order. Each "Outcome" cell is one short sentence (~15 words). Detailed write-ups follow under [Build Phases](#build-phases); use the link in the Phase column.

| # | Phase | Kind | Outcome (one sentence) |
|---|---|---|---|
| 1 | [{{phase_1_name}}](#phase-1) | {{Foundation \| Feature slice \| Polish}} | {{one_short_sentence_demoable_outcome_in_plain_language_max_15_words}} |
| 2 | [{{phase_2_name}}](#phase-2) | {{kind}} | {{outcome}} |
| 3 | [{{phase_3_name}}](#phase-3) | {{kind}} | {{outcome}} |
| ... | ... | ... | ... |
| {{N}} | [{{phase_N_name}}](#phase-{{N}}) | {{kind}} | {{outcome}} |
| {{N+1}} | [{{deferred_phase_name}} (deferred)](#phase-{{N+1}}) | Deferred | {{outcome_when_or_if_built}} |

> Numbers are assigned in build order and are stable for the life of this outline. Cite them as `Phase N` in tickets, comments, and follow-up reports.

---

## How {{this_build}} Differs from {{the_source}} {#departures}

> Included only when the build introduces deliberate divergences from the source artifact. If the source already describes the desired behavior in full, omit this entire section, the matching TOC entry, and any "Departures" reference in the executive summary.
>
> Replace `{{this_build}}` and `{{the_source}}` with concrete nouns when rendering — e.g., "How V2's Share Differs from V1", or "How the New Billing Engine Differs from the Stripe Integration". Generic phrasing loses information scent for leadership readers.

The build deliberately departs from {{source_artifact_filename}} in the ways named below. Each departure is summarized once here so the rest of the document can refer to it by name.

### 1. {{departure_1_named_in_plain_language}}

{{two_to_five_sentences_describing_what_the_source_assumed_and_what_this_build_does_instead_and_why_the_change_matters}}

### 2. {{departure_2_named_in_plain_language}}

{{description}}

{{repeat_for_every_named_departure}}

---

## Phase Kinds {#phase-kinds}

Every phase is tagged with one of four kinds. The taxonomy is used in the Build Phase Index and on each phase entry's `**Kind.**` line.

- **Foundation** — A capability that does not deliver new user-facing features on its own, but is required for later phases. Must still be demoable in its own right (e.g., "an admin can edit and persist a new setting").
- **Feature slice** — A thin end-to-end strip of new behavior that a real user can experience.
- **Polish** — Branding, refinement, observability, or quality-of-life work that enriches a working core.
- **Deferred** — Listed for traceability; not built in the current plan. Slotted at the end of the index.

---

## Build Phases {#build-phases}

### Phase 1: {{phase_1_plain_language_name}} {#phase-1}

**Kind.** {{Foundation \| Feature slice \| Polish}}.

**Builds on.** {{Nothing — this is the starting phase. \| Phase X (and optionally Phase Y), where the dependency lies in one short clause.}}

<!-- Plain language only — no file paths, function names, library mechanics, or internal flag names. -->
**What we build.** {{plain_language_description_of_the_phase_deliverable_in_one_short_paragraph_or_a_short_bullet_list_max_about_six_bullets_e_g_a_company_admin_can_view_and_edit_their_company_basic_information}}

<!-- Plain language only — keep this section to two to four sentences. -->
**Why this is Phase 1.** {{rationale_for_why_this_phase_lands_at_position_1_two_to_four_sentences_typical_reasons_include_no_demoable_feature_can_run_until_this_exists_or_this_is_the_smallest_first_deliverable_that_surfaces_questions_later_phases_depend_on}}

**Outcome to demonstrate.**

1. {{step_1_in_the_demo_e_g_open_the_app_as_a_company_admin}}
2. {{step_2}}
3. {{step_3}}
4. {{step_n_confirming_the_phase_outcome_is_visible_and_persists}}

**Source citations.**
- {{source_section_citations_with_links_back_to_the_source_artifact_e_g_backs_the_data_shown_in_source_section_12_branded_company_header}}
- {{additional_source_citation_if_any}}

**Connects to.**
- {{links_to_other_phases_this_phase_feeds_into_e_g_establishes_the_page_that_hosts_phase_2_pick_the_share_role}}
- {{additional_phase_connection_if_any}}

<!-- Plain language only — phrase preconditions as questions or checks a stakeholder can read, not as implementation tasks. -->
**Preconditions to verify before starting.**
- {{question_or_check_the_team_must_resolve_before_this_phase_begins_e_g_confirm_the_role_permission_model_can_express_an_edit_company_info_capability_or_decide_whether_to_add_one}}
- {{additional_check_if_any}}

---

### Phase 2: {{phase_2_plain_language_name}} {#phase-2}

**Kind.** {{kind}}.

**Builds on.** {{Phase 1, where the dependency lies in one short clause.}}

**What we build.** {{description}}

**Why this is Phase 2.** {{rationale}}

**Outcome to demonstrate.**

1. {{step_1}}
2. {{step_2}}
3. {{step_3}}

**Source citations.**
- {{citations}}

**Connects to.**
- {{phase_links}}

**Preconditions to verify before starting.**
- {{checks}}

---

{{repeat_phase_block_for_every_phase_in_the_build_phase_index_using_explicit_phase_N_anchor}}

---

### Phase {{N+1}} (Deferred): {{deferred_phase_plain_language_name}} {#phase-{{N+1}}}

> Included only when one or more phases were deliberately deferred. If nothing was deferred, omit every "Phase N (Deferred)" section, its matching index row, and the deferred-phases paragraph in the executive summary.

**Kind.** Deferred.

**Builds on.** {{Phase X if dependencies are known, or "Not applicable until built" if uncertain.}}

**What we build.** {{plain_language_description_of_what_this_phase_would_deliver_when_or_if_built}}

**Why this is deferred.** {{the_reason_for_deferral_in_plain_language_two_to_four_sentences_e_g_the_long_signed_url_is_acceptable_in_email_and_chat_until_evidence_says_otherwise_so_the_cost_of_building_a_shortener_is_not_yet_justified_listed_here_so_the_team_has_a_place_to_slot_the_work_when_evidence_arrives}}

**Reopen when.** {{the_concrete_trigger_that_would_justify_revisiting_e_g_a_measured_metric_a_real_customer_request_a_third_concurrent_use_a_compliance_audit_a_dependency_landing}}

**Outcome to demonstrate (when or if built).**

1. {{step_1}}
2. {{step_2}}
3. {{step_3}}

**Source citations.**
- {{citations}}

---

## Open Questions {#open-questions}

> Decisions or verifications the team must resolve before the corresponding phase starts. Each question is presented with realistic options and a recommended answer where one is supportable. Cite open questions as `OQ-N` in follow-up.
>
> **Ordering:** list open questions by the lowest-numbered phase they block, ascending. Carry-over questions that do not block any specific phase go at the bottom under a `### Carry-over notes` sub-heading.

### OQ-1. {{plain_language_question_phrased_so_a_stakeholder_can_read_it}} {#oq-1}

**Blocks phase(s).** {{Phase_N_or_Phase_N_and_Phase_M}}.

{{one_to_three_sentences_of_context_explaining_what_phase_or_phases_this_blocks_or_shapes}}

- **Option A — {{plain_language_option_summary}}.** {{one_to_three_sentences_describing_the_option_and_its_trade_offs}}
- **Option B — {{plain_language_option_summary}}.** {{description}}
- **Recommendation: {{Option_A_or_B}}.** {{rationale_in_plain_language_with_evidence_or_reasoning_grounded_in_the_source_artifact_or_project_context}}

### OQ-2. {{question}} {#oq-2}

**Blocks phase(s).** {{Phase_N}}.

{{context}}

- **Option A — ...**
- **Option B — ...**
- **Recommendation: ...** {{rationale}}

{{repeat_for_every_phase_blocking_open_question}}

### Carry-over notes

> Questions or recommendations carried over from the source artifact that do not block any specific phase, but should remain visible to the team. Omit this sub-heading if no carry-over notes were captured.

### OQ-{{N}}. {{question}} {#oq-{{N}}}

**Blocks phase(s).** None — carry-over note.

{{context_and_recommendation}}

---

*End of outline. If you need to cite a specific phase elsewhere, use its `Phase N` number — those numbers are stable for the life of this document. If you need to cite a specific open question, use its `OQ-N` ID.*
