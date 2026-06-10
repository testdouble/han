---
title: "Architectural Analysis: {{focus_area}}"
focus_area: "{{module_directory_or_feature_analyzed}}"
size: "{{small | medium | large}} — {{one_line_justification}}"
roster: "{{comma_separated_list_of_dispatched_agents}}"
git_available: "{{yes | no — churn and recency evidence skipped when no}}"
generated: "{{YYYY-MM-DD}}"
generated_by: "han.core:architectural-analysis"
sections_included:
  - executive_summary
  - structural_analysis
  - behavioral_analysis
  - concurrency_analysis        # remove this line if concurrency-analyst was not dispatched
  - security_analysis           # remove this line if adversarial-security-analyst was not dispatched
  - data_engineering_analysis   # remove this line if data-engineer was not dispatched
  - devops_readiness            # remove this line if devops-engineer was not dispatched
  - on_call_resilience          # remove this line if on-call-engineer was not dispatched
  - codebase_map                # remove this line if codebase-explorer was not dispatched
  - risk_assessment
  - software_architecture_recommendations
  - system_architecture_recommendations   # remove if system-architect was not dispatched
  - system_level_concerns_deferred         # remove if system-architect WAS dispatched
---

# Architectural Analysis: {{focus_area}}

## How to Read This Report

This report analyzes the architecture of **{{focus_area}}**. It is layered: each analysis section is the verbatim output of one specialist agent, and the Executive Summary is the only synthesized prose.

- **Executive Summary.** The shape of the architecture, the few findings that matter most, and the highest-impact recommendations. Read this if you have two minutes.
- **Analysis sections** (Structural, Behavioral, and any of Concurrency / Security / Data-Engineering / DevOps / On-Call Resilience / Codebase Map that were part of this run). Each is a specialist's full findings with file paths and verbatim code. Findings carry stable IDs (`S#`, `B#`, `C#`, `SEC-###`, `DOR-###`, `OCE-###`) you can cite in tickets and follow-up work.
- **Risk Assessment.** `R#` items scoring the structural / behavioral / concurrency findings by likelihood, severity, blast radius, and reversibility.
- **Software-Architecture Recommendations.** `A#` recommendations, each cross-referencing the findings that drove it and the SOLID / cohesion / coupling concern it addresses, with pseudocode sketches.
- **System-Architecture Recommendations** *(only when a cross-service / bounded-context seam was present and `system-architect` was dispatched)* **or** **System-level concerns deferred** *(otherwise)*.

> Sizing and roster: this run was classified **{{size}}** and dispatched **{{roster}}**. A smaller run dispatches fewer specialists and calibrates findings more conservatively; re-run at a larger size if a domain was omitted. {{git_availability_sentence — e.g., "Git was unavailable, so churn- and recency-based likelihood evidence was skipped." — omit if git was available}}

> Sections not part of this run: {{list each section whose agent was not dispatched, one short clause each — e.g., "No Concurrency section: no concurrency signal in the focus area." Replace this whole line with "All standard sections were generated for this run." when nothing was dropped.}}

---

## Executive Summary

> The only synthesized section. Plain enough that a lead can read it alone and know what matters.

**Focus area:** {{what_was_analyzed_and_its_boundary}}

**Bottom line:** {{one_or_two_sentence_verdict_on_architectural_health}}

**Most critical findings (3–5, across all dispatched dimensions):**

- {{finding_with_its_ID_e_g_S3_circular_dependency_between_x_and_y_and_why_it_matters}}
- {{finding_2}}
- {{finding_3}}
- {{optional_finding_4}}
- {{optional_finding_5}}

**Highest-impact recommendations:**

- {{recommendation_with_its_ID_e_g_A1_extract_an_interface_at_the_persistence_seam}}
- {{recommendation_2}}
- {{optional_recommendation_3}}

**Clean dimensions and omitted domains:** {{explicit_note_on_any_dimension_that_found_no_issues_e_g_no_concurrency_patterns_present_and_any_signalled_domain_the_band_cap_omitted_with_a_re_run_suggestion. Write "None — every dispatched dimension surfaced findings and no signalled domain was omitted." when true.}}

---

## Structural Analysis

> Verbatim output from `structural-analyst`. `S#` findings on module boundaries, coupling, dependency direction, abstractions, and duplication.

{{structural_analyst_verbatim_output}}

---

## Behavioral Analysis

> Verbatim output from `behavioral-analyst`. `B#` findings on data flow, error propagation, state management, and integration boundaries.

{{behavioral_analyst_verbatim_output}}

---

## Concurrency Analysis

> Verbatim output from `concurrency-analyst`. `C#` findings on race conditions, resource contention, deadlock potential, async error handling, and synchronization. If the analyst reported no concurrency patterns, that statement is carried here verbatim — it is a result, not a missing section.
>
> Remove this entire section, its `sections_included` line, and its "How to Read" mention if `concurrency-analyst` was not dispatched (no concurrency signal in the focus area).

{{concurrency_analyst_verbatim_output_or_no_concurrency_patterns_statement}}

---

## Security Analysis

> Verbatim output from `adversarial-security-analyst`. `SEC-###` findings, each with a demonstrated exploit path or CVE reference, scoped to the focus area.
>
> Remove this entire section, its `sections_included` line, and its "How to Read" mention if `adversarial-security-analyst` was not dispatched.

{{adversarial_security_analyst_verbatim_output}}

---

## Data-Engineering Analysis

> Verbatim output from `data-engineer`. Findings on schema, migrations, query/access patterns, and data contracts within the focus area, each citing the data-engineering principle violated and the data-level impact.
>
> Remove this entire section, its `sections_included` line, and its "How to Read" mention if `data-engineer` was not dispatched.

{{data_engineer_verbatim_output}}

---

## DevOps Readiness

> Verbatim output from `devops-engineer`. `DOR-###` findings on operability, rollout safety, observability, and scale within the focus area, each citing the operational principle violated and the production blast radius.
>
> Remove this entire section, its `sections_included` line, and its "How to Read" mention if `devops-engineer` was not dispatched.

{{devops_engineer_verbatim_output}}

---

## On-Call Resilience

> Verbatim output from `on-call-engineer`. `OCE-###` findings at the application source line, naming the code-level resilience anti-pattern, the named production failure mode it leads to, and the production impact at 3am. Application source only — infrastructure and pipeline concerns live in DevOps Readiness above.
>
> Remove this entire section, its `sections_included` line, and its "How to Read" mention if `on-call-engineer` was not dispatched.

{{on_call_engineer_verbatim_output}}

---

## Codebase Map

> Verbatim output from `codebase-explorer`. Entry points, core logic, data models, configuration, and tests for the focus area — the discovery map the analysts and architects worked from.
>
> Remove this entire section, its `sections_included` line, and its "How to Read" mention if `codebase-explorer` was not dispatched.

{{codebase_explorer_verbatim_output}}

---

## Risk Assessment

> Verbatim output from `risk-analyst`. `R#` items, ordered highest risk first, each cross-referencing the `S`/`B`/`C` findings it scores.

{{risk_analyst_verbatim_output}}

---

## Software-Architecture Recommendations

> Verbatim output from `software-architect`. `A#` recommendations ordered by impact, each cross-referencing upstream findings, naming the SOLID / cohesion / coupling concern, and carrying a pseudocode sketch and a YAGNI-evidence line. Recommendations crossing a service or bounded-context seam are deferred (see the final section).

{{software_architect_verbatim_output}}

---

## System-Architecture Recommendations

> Verbatim output from `system-architect`. `SA#` recommendations and a context-map sketch for the cross-service / bounded-context seam that triggered its dispatch.
>
> Render this section ONLY when `system-architect` was dispatched (large size, system-seam signal). Otherwise remove it and render "System-level concerns deferred" below instead.

{{system_architect_verbatim_output}}

---

## System-level concerns deferred

> Render this section ONLY when `system-architect` was NOT dispatched. It carries the boundary-crossing findings `software-architect` flagged as out of its altitude.
>
> Remove this section (and its `sections_included` line) when `system-architect` WAS dispatched — its recommendations replace this list.

The following findings cross a service boundary, bounded-context seam, or trust boundary, and were deferred by `software-architect` rather than absorbed at software altitude:

- {{deferred_finding_ID_and_one_line_reason_it_is_system_level}}
- {{repeat}}

To get recommendations at that altitude, dispatch `system-architect` separately against this focus area, or re-run `/architectural-analysis` at `large` size so it is included automatically when a system-seam signal is present.

---

*End of report. Finding IDs (`S#`, `B#`, `C#`, `SEC-###`, `DOR-###`, `OCE-###`, `R#`, `A#`, `SA#`) are stable for the life of this report — cite them in tickets, ADRs, and follow-up work.*
