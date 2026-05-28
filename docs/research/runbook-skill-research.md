# Research: A `/runbook` skill for Han

One open-ended question: how should a new `/runbook` skill produce runbooks in a consistent format, and what format, scope, inputs, and dispatch model should it adopt?

Evidence mode: **strict** (default — every claim that bears on the recommendation is sourced or carried with an explicit single-source caveat).

## Summary

Industry runbook practice splits cleanly into two structural families — full operations manuals and per-alert incident triage documents — and the production-grade examples that combine both (GitLab, OpenShift) layer them, with a per-service README on top and small per-scenario runbook files underneath. A small core set of sections recurs across nearly every published format: who owns it, when to use it, the exact commands to run with their expected output, how to verify the fix worked, who to escalate to, how to roll back. Staleness is the universally cited failure mode, and the strongest mitigation is making the runbook live in version control next to the code it describes, with explicit owner and last-validated metadata that surface decay rather than hide it.

For Han's primary audience of solo or small-team product engineers, the recommended skill is the simplest version that satisfies the evidence: a deterministic template installer that asks a few targeted questions, fills a single cross-format core template, enforces a YAGNI preflight that the runbook is grounded in something real (an alert that has fired, a recurring task, a live failure mode on a service that has traffic), and writes a single runbook file per invocation. The evidence is well-corroborated for the structural choices (template content, file location, staleness metadata) and medium-confidence for the input-collection style; an earlier, more elaborate "bounded interview plus optional specialist review" design did not survive adversarial validation and was simplified.

## Research Results

### Two structural families and one production hybrid

Across the surveyed formats, runbooks split into two structural families. **Comprehensive operations manuals** (SkeltonThatcher's `run-book-template`, the Limoncelli seven-section model surfaced via PagerDuty and Process.st, Lab Zero's DevOps Runbook Guide, the Atlassian Confluence DevOps Runbook Template) treat a runbook as a wide-scope document covering service overview, architecture, deployment, configuration, routine operations, monitoring, and disaster recovery (A1, A2, A4, A7, A9). **Incident-focused triage documents** (Emmer's incident runbook template, Rootly's incident-response runbooks guide, OneUptime's effective-runbooks guide, Nobl9's runbook example, The Good Shell's incident runbook template) treat a runbook as a narrow, per-alert artifact organized around trigger, diagnosis, mitigation, verification, escalation, and rollback (A3, A12, A15, A16, A19).

In live production at scale, the two families combine rather than compete. GitLab organizes its production runbooks at `{service-name}/{runbook-name}.md` within a dedicated runbooks repository: each service directory has a README that covers the operations-manual concerns and separate per-scenario `.md` files that handle individual symptoms (A6). OpenShift uses `alerts/{operator-name}/{AlertName}.md` — naming the file after the alert it answers (A17). Google SRE's "playbook entry" model is structurally equivalent: every alert ties to a playbook entry with severity, impact, debugging suggestions, and mitigation steps (A13).

### The cross-format core: sections that appear nearly everywhere

A small set of sections recurs across most of the surveyed formats. These are the sections corroborated independently by at least four sources, and they map directly to what an engineer actually needs at 3am: header metadata (owner, last-updated, last-validated date, severity, alert or trigger link), a trigger or "when to use" statement, step-by-step procedure written in imperative voice with copy-pasteable commands and expected output per step, verification of the fix, escalation path, and rollback (A3, A12, A15, A16; reinforced by GitLab and OpenShift production practice in A6 and A17). Sections that are format-specific or supported by only a single source — explicit incident-commander/comms-lead role assignments (A19), SLA section (A1, A7), full deployment instructions (A1, A7), and Lab Zero's "Future Considerations" (A9) — are real choices but lower-confidence, and are not in the cross-format core.

The "five A's" framework (Actionable, Accessible, Accurate, Authoritative, Adaptable) appears in three sources — Emmer, Rootly, and incident.io (A3, A12, A20) — and is a useful vocabulary, but it does not appear in Google SRE, GitLab production practice, or OpenShift production practice [V8]. Treat it as helpful shorthand, not industry-standard terminology.

### Staleness is the universally cited failure mode

Every surveyed source identifies staleness as the runbook failure mode that matters most. Google SRE names a specific tension: the more detailed the runbook, the faster it goes out of date as systems change (A13). The Hacker News practitioner thread confirms staleness as the most-cited reason runbooks get abandoned (A14). Vendor-source claims that "outdated runbooks are worse than no runbooks" (A6) and "if an engineer runs a command that fails, they will stop using the runbook entirely" (A8) appear with commercial interest behind them [V3, V8], but the directional finding — staleness destroys trust — is corroborated by non-vendor production practice in GitLab and OpenShift (active per-runbook maintenance) and by Google SRE.

The strongest mitigation in the evidence is structural: keep the runbook in version control next to the code it describes (A6, A8, A9, A13), ship runbook updates in the same pull request as infrastructure changes (A6), and require owner plus last-validated metadata on every runbook so decay is visible rather than hidden (A6 dual-date tracking; A9 metadata headers; A13 ownership fields). Game-day testing and quarterly review cycles are corroborated mitigations (A9, A10, A12), but they are workflow recommendations the skill cannot enforce on its own.

### Audience: 3am on-call, with a documented gap for solo engineers

Every incident-focused source explicitly designs for an on-call engineer under pressure who may have been onboarded recently and may have been pulled out of REM sleep (A3, A12, A14, A16). Operations-manual sources additionally serve new-hire onboarding and ops-team reference (A2, A4, A9). The Hacker News thread surfaces a real tension: runbooks written for new hires drift into over-explanation that experienced engineers don't want when an alert fires (A14).

No surveyed source specifically designs for solo or small-team product engineers — Han's primary audience. The closest fits are the Atlassian (A4) and Lab Zero (A9) operations-manual formats, both of which implicitly assume a team with dedicated ops roles. This is a documented audience gap, not corroborated evidence that any specific format serves Han's audience [V2]. The implication is that an opinionated, low-friction format is more valuable to Han's audience than a comprehensive format borrowed from enterprise practice.

### Level of detail: imperative commands with expected output, not prose

There is near-universal convergence across sources on the right level of detail: exact, copy-paste-ready commands written in imperative voice, with expected output for each step (A1, A2, A8, A9, A12, A13, A16). Rootly's framing — "every step should be a command, not a paragraph" (A12) — is corroborated by practitioner reports that placeholders requiring mental substitution at 3am are a usability failure (A14). Screenshots are recommended as supplements for visually complex steps, not as substitutes (A1, A12). Troubleshooting trees with conditional branches handle non-deterministic incident paths (A2, A12).

### Input modes in practice

Four input modes are observable in the field, but only the first is broadly corroborated:

- **Deterministic template fill-in** is the dominant documented approach: a shared template the engineer fills in, with the structural scaffolding providing the consistency and the human supplying the specifics (A1, A2, A9, A10).
- **Questionnaire / onboarding interview** appears in AWS Incident Detection and Response, which uses a CLI-based onboarding questionnaire to derive runbook drafts (A5). This is a managed-service enterprise practice rather than a general industry pattern [V2], and Nobl9 (a vendor source [V8]) similarly recommends SME surveys for wider input collection (A10).
- **Postmortem-derived** continuous improvement — runbooks updated from incident action items — is a corroborated authoring trigger, not a primary creation mode (A3, A4, A6, A13, A16).
- **System-area scan** — generating a runbook from code or infrastructure inspection — is not described by any surveyed source.

The academic FATA framework (A14) claims 27.7–47.4% quality improvement from proactive clarifying questions, but the figures are single-source, the paper is not runbook-specific, and the magnitude cannot be independently verified [V1]. Discounting A14 entirely leaves the directional claim (asking targeted questions before generating produces better output) corroborated weakly by A5 and A10, both of which are domain- or audience-mismatched.

### File location and naming

There is no single industry standard, but corroborated directional patterns are clear. GitLab uses `{service}/{runbook-name}.md` in a dedicated runbooks repository (A6). OpenShift uses `alerts/{operator-name}/{AlertName}.md` (A17). OneUptime recommends `{service}-{action}-{scope}.md` (A9, single-source on that exact formula). The directional convention — service or alert identifier first in the name, kebab-case, version-controlled, alongside or adjacent to code — is corroborated across A6, A7, A9, A13, A17.

For Han, which writes into whatever target project it is invoked in, the simplest defensible convention is `docs/runbooks/{slug}.md` with kebab-case slugs of the form `{service-or-area}-{scenario}`. Subdirectories per service (`docs/runbooks/{service}/{scenario}.md`) are the right form for projects with multiple services.

### Han codebase patterns this skill must align with

Han's documentation-producing skills (`project-documentation`, `architectural-decision-record`, `coding-standard`, `stakeholder-summary`) follow a uniform pattern: resolve project context from CLAUDE.md's Project Discovery section first, fall back to `project-discovery.md`, then glob for defaults; ask before overwriting an existing file; optionally dispatch agents for review; write the output; update CLAUDE.md or an index. The skill skeleton — YAML frontmatter, optional Pre-requisites section, Project Context block of context-injection commands, numbered imperative steps — is consistent across all skills, and a reference folder holds the templates the SKILL.md reads.

Two scope facts from existing agents are load-bearing. The `on-call-engineer` agent **explicitly excludes runbook documents** from its scope, naming them as `devops-engineer`'s domain. The `devops-engineer` agent **explicitly names "runbook for an alert that has never fired" as a YAGNI anti-pattern**, requiring evidence the alert is firing or imminently will. The canonical example is Sentry runbooks for staging-only Sentry where data isn't reaching production. This is a strict version of the YAGNI gate, and applying it as a blanket prohibition on proactive runbooks would over-trigger [V5]: a runbook for a known failure mode (disk full, OOM kill) on a service that is in production but hasn't yet hit that failure is not the same as a runbook for an alert that will never fire because no signal flows.

The relevant Han skills the `/runbook` skill should not absorb the work of: `/project-documentation` (feature and system docs, not operational triage), `/architectural-decision-record` (one-off decisions, not repeatable procedures), `/coding-standard` (conventions, not operational procedures). `/project-documentation` could in principle produce a runbook-shaped document but its template is for Overview / Key Files / Behavior / Configuration / Error Handling, not for triage sequences with copy-pasteable commands [V4].

## Options to Consider

### O1: Comprehensive operations-manual format (Limoncelli / SkeltonThatcher model)

- **What it is:** One wide-scope document per service covering overview, architecture, deploy, ops, monitoring, troubleshooting.
- **Trade-offs:** Captures everything a new team member needs. Broad maintenance surface; harder to scan at 3am. Conflates "operate this day-to-day" with "respond to this alert now." Largest staleness exposure.
- **Rests on:** A1, A2, A7, A9
- **Evidence status:** corroborated

### O2: Per-alert incident-focused runbook (Emmer / Rootly / OneUptime model)

- **What it is:** One runbook per alert or failure mode: trigger, diagnosis, mitigation, verification, escalation, rollback.
- **Trade-offs:** Best 3am usability and alert-to-runbook linking; lowest per-document maintenance surface. Requires mature alerting infrastructure; may be overhead for solo engineers maintaining many small files.
- **Rests on:** A3, A12, A15, A16, A17, A19 (with vendor-source caveat per V3 on the breadth of "6+ corroborating sources")
- **Evidence status:** corroborated, with vendor weighting noted

### O3: Two-layer hybrid (GitLab / OpenShift production pattern)

- **What it is:** Per-service README covering operations-manual concerns plus per-scenario runbook files in the incident-focused structure.
- **Trade-offs:** Separates "understanding the system" from "resolving the alert." Two artifacts to maintain. No single published template targets this for small teams; the synthesis is from observed production practice.
- **Rests on:** A6, A17 with synthesis [reasoning]
- **Evidence status:** corroborated for the pattern; [reasoning] for the small-team applicability

### O4: Minimal cross-format core template (deterministic fill-in)

- **What it is:** A single lean template — header metadata, trigger, steps, verification, escalation, rollback — that the user fills in. No interview, no agent dispatch.
- **Trade-offs:** Lowest build complexity. Lowest per-runbook authoring friction for experienced authors. Blank-page problem for first-time authors; relies on the template prompting being good. No architecture context — that lives elsewhere.
- **Rests on:** A3, A12, A15, A16; reinforced by GitLab and OpenShift production sections in A6, A17
- **Evidence status:** corroborated

### O5: Bounded-interview hybrid with optional specialist review (original recommendation)

- **What it is:** A bounded interview collecting service identity, trigger, mitigation commands with expected output, escalation, rollback, validation contact; deterministic template producing the draft; optional `devops-engineer` review pass.
- **Trade-offs:** Captures structured input quality benefits — if those benefits are real. Most complex to build and test. The "optional devops-engineer review" component does not match an existing agent's protocols [V6]. The interview-over-template advantage rests on a single domain-mismatched academic paper (A14) and a single audience-mismatched enterprise practice (A5) [V1, V2, V7].
- **Rests on:** A5 [V2], A14 [V1], A10 (vendor), plus the corroborated cross-format core
- **Evidence status:** core sections corroborated; interview-structure justification weakened to single-source after validation; "optional review" component refuted

### O6: Template installer with YAGNI preflight and mandatory staleness metadata

- **What it is:** A deterministic skill that resolves project context, asks a small number of targeted questions (service or area, scenario or trigger, owner, last-validated date), enforces a YAGNI preflight (the scenario is real — an alert has fired, a recurring task exists, or a live service has the failure mode in scope), fills the minimal cross-format core template, and writes one runbook per invocation to `docs/runbooks/{slug}.md`. No agent dispatch. Mandatory metadata fields force staleness signals to be visible from day one.
- **Trade-offs:** Simplest version that satisfies the evidence. Aligns with how `/architectural-decision-record` works — install a template, force the user to surface the forcing function. No interview loop; the targeted questions are part of normal Project Context resolution rather than a separate conversational phase. Misses the audience benefit (if any) of free-form clarifying conversation. Quality depends heavily on template prompting.
- **Rests on:** A3, A12, A15, A16 for sections; A6, A17 for naming and version-control conventions; Han's `devops-engineer` agent and `yagni-rule.md` for the YAGNI preflight; V4 and V7 for framing.
- **Evidence status:** corroborated

## Recommendation

**Recommendation: O6 — template installer with YAGNI preflight and mandatory staleness metadata, writing one runbook per invocation to `docs/runbooks/{slug}.md`.**

This is the original-recommendation O5 with the components that did not survive validation stripped out: the bounded interview is reduced to targeted preflight questions, and the "optional `devops-engineer` review" is removed because that agent's protocols do not match runbook-document review [V6]. The result is structurally closer to how `/architectural-decision-record` works, which is the right shape for a Han skill: a template, a forcing-function gate, and the human filling in the specifics with prompting in the template itself.

**Evidence basis:**

- **Cross-format core sections** (header metadata, trigger, steps with imperative copy-pasteable commands and expected output, verification, escalation, rollback) — corroborated by at least four independent sources (A3, A12, A15, A16) and reinforced by GitLab and OpenShift production practice (A6, A17). This is the strongest evidence in the set.
- **File location and naming** (`docs/runbooks/{slug}.md`, kebab-case, service-or-area first) — corroborated directionally across A6, A7, A9, A13, A17. The exact path is a defensible synthesis of corroborated patterns.
- **Mandatory staleness metadata** (owner, last-validated date) — corroborated mitigations against the universally cited staleness failure mode, anchored in non-vendor practice (GitLab and OpenShift active maintenance, Google SRE post-page updates) even after vendor sources are downweighted [V8].
- **YAGNI preflight** — anchored in Han's own `devops-engineer` agent and `yagni-rule.md`, with the threshold tuned to match the rule's actual evidence test (real production code path, documented incident, real alert that has fired, recurring task, measured metric) rather than the strict Sentry-style "no signal at all" form [V5]. The preflight warns and offers to proceed if evidence is thin; it blocks only when the scenario is purely speculative.
- **Single-runbook scope per invocation** — the per-alert incident-focused model is the most usable shape at 3am (A14, A12), and producing one runbook at a time keeps each invocation focused.

**What this recommendation does not rest on:** the FATA framework's quality-improvement figures (A14, single-source and domain-mismatched [V1]); AWS IDR's questionnaire-to-template pipeline as a model for solo engineers (A5, audience-mismatched [V2]); vendor-sourced strong-form staleness quotes (A6, A8 [V3, V8]); the "five A's" framework as industry-standard vocabulary [V8]; specialist-agent review of runbook drafts [V6].

**Deciding criteria for teams who would want a different answer:**

- Mature alerting infrastructure with many services and well-named alerts: O2 scales better than O6 because alert-to-runbook linking becomes the primary navigation.
- Onboarding is the primary use case: O1 (full operations manual) fits the need; `/project-documentation` may already cover it.
- A team with a real DevOps reviewer in the loop: O5's "specialist review" component becomes meaningful if it's a human reviewer rather than an agent that doesn't match the protocol [V6].

## Validation

### V1: FATA framework is single-source and domain-mismatched

- **Strategy:** Challenge the Evidence
- **Investigation:** Checked corroboration for arXiv 2508.08308's 27.7–47.4% quality-improvement claim; found no independent replication and no runbook-specific application of the framework.
- **Result:** Partially Refuted — the magnitude figures are not load-bearing; the directional claim survives weakly via A5 and A10.
- **Impact:** Recommendation pivoted away from interview-structure as primary justification; O5 → O6.

### V2: AWS IDR is audience-mismatched to Han users

- **Strategy:** Challenge the Evidence
- **Investigation:** A5 is a paid enterprise managed-service workflow; no source addresses solo or small-team product engineers, Han's primary audience.
- **Result:** Partially Refuted — A5 establishes that interview-driven runbook collection exists in practice, but not that it generalizes to Han's audience.
- **Impact:** The bounded-interview component lost its primary corroboration; reduced to a few targeted preflight questions in O6.

### V3: Vendor-blog concentration inflates the "6+ sources" cross-format core claim

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Reweighted sources: Rootly, OneUptime, FireHydrant, incident.io, Nobl9 sell adjacent tooling. Independent non-vendor corroboration reduces to Emmer + The Good Shell + GitLab production + OpenShift production.
- **Result:** Partially Refuted — the cross-format core survives, but the strength is "4 independent sources including production practice" rather than "6+ corroborating sources."
- **Impact:** Sections beyond the core (specifically dual-date metadata, severity level) are treated as recommended-not-required in the template.

### V4: "No new skill" and "template installer" options were missing from the framing

- **Strategy:** Challenge the Options Framing
- **Investigation:** `/project-documentation` has a Guard check that suggests siblings for ADRs and standards; a runbook is neither, and that skill's template targets feature/system docs, not triage. A template-installer option matching how `/architectural-decision-record` works was not framed.
- **Result:** Refuted — the original options set had a real gap.
- **Impact:** Added O6; recommendation pivoted to it.

### V5: The YAGNI gate threshold is undefined

- **Strategy:** Challenge the Assumptions
- **Investigation:** The `devops-engineer` agent's canonical YAGNI example (Sentry where no data flows) is a stricter case than "alert has not fired yet on a live service." The general YAGNI rule allows several other forms of evidence (production code path, recurring task, measured metric).
- **Result:** Confirmed — the original O5 was ambiguous on which gate applies.
- **Impact:** O6 specifies that the preflight blocks purely speculative runbooks and warns-and-proceeds when evidence is thin but plausible (live service, known failure mode class, recurring task).

### V6: "Optional devops-engineer review" component is phantom

- **Strategy:** Challenge the Recommendation
- **Investigation:** `devops-engineer`'s protocols cover DORA, Twelve-Factor, Golden Signals, production-readiness — not runbook-document quality review. `on-call-engineer` explicitly excludes runbook documents from its scope. No Han agent's defined scope covers runbook-document quality.
- **Result:** Confirmed — the component is unvalidated.
- **Impact:** Removed from O6.

### V7: Discounting A14 + A5 erases O5's edge over O4

- **Strategy:** Challenge the Recommendation
- **Investigation:** With A14 (FATA) discounted as single-source and A5 (AWS IDR) downweighted as audience-mismatched, the interview-vs-template distinction in O5 loses its evidence base. The remaining substantive differences (YAGNI gate, forced metadata, structured output) can all be implemented in a template installer.
- **Result:** Refuted — the original O5 recommendation does not survive when its weakest sources are discounted.
- **Impact:** Recommendation rewritten to O6.

### V8: "Five A's" framework and strong-form staleness claims are vendor-anchored

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The "five A's" appears in Emmer (practitioner blog), Rootly (vendor), incident.io (vendor) — three sources, only one non-vendor. Strong-form staleness quotes ("worse than no runbooks") trace to SupportBench and UptimeLabs (both vendors). Non-vendor practice (Google SRE, GitLab, OpenShift) corroborates the direction but not the strong form.
- **Result:** Partially Refuted — staleness mitigations survive (owner, last-validated date); the "five A's" treated as shorthand, not as industry-standard vocabulary.
- **Impact:** Template does not adopt "five A's" as required structure; staleness metadata fields are required.

### Adjustments Made

The recommendation was rewritten from O5 (bounded interview + minimal template + optional devops-engineer review) to O6 (template installer with YAGNI preflight and mandatory staleness metadata). The change is driven by V4 (missed option), V6 (phantom review component), and V7 (interview justification collapses under V1 + V2 discounting). The structural choices the original recommendation made — cross-format core sections, file location and naming, mandatory staleness metadata, YAGNI gate — all survive; the input-collection style is simpler.

### Confidence Assessment

- **Confidence:** Medium-high on structural and content choices; medium on input-collection style.
- **Remaining risks:**
  - **Audience gap is unresolved.** No source addresses solo or small-team product engineers; the recommendation extrapolates from enterprise and open-source-infrastructure practice. If the audience needs differ materially, the template's prompting will need iteration.
  - **YAGNI gate calibration.** V5 set the threshold direction; the actual prompts in the preflight need to be tested on real invocations to confirm they neither over-block (refusing reasonable proactive runbooks) nor under-block (waving through speculative ones).
  - **No agent reviews runbook quality.** If quality variance is high after the skill ships, the answer is either to define a new `runbook-reviewer` agent with the right protocols or to harden the template's in-line prompting. Both are deferred until evidence of variance accumulates.
  - **Single-author bias.** The template installer model assumes the author and the eventual runbook user may be the same person (solo / small team). For larger teams, the absent peer-review workflow (corroborated as a mitigation in A4, A6, A8) is unaddressed; teams that need it can layer their normal PR review on top.

## Artifacts

### A1: PagerDuty — What is a Runbook?
- **Link / location:** https://www.pagerduty.com/resources/automation/learn/what-is-a-runbook/
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor — interested-party scrutiny)
- **Summary:** Defines a runbook as a how-to guide for repeated tasks; cites Limoncelli's seven sections (Overview, Build, Deploy, Common Tasks, Pager Playbook, DR, SLA). Distinguishes runbook (single-task) from playbook (multi-runbook strategy).
- **Evidence status:** corroborated by A7

### A2: SkeltonThatcher run-book-template
- **Link / location:** https://github.com/SkeltonThatcher/run-book-template
- **Retrieved:** 2026-05-28
- **Trust class:** web (open-source template)
- **Summary:** Ten-section operations-manual template covering service overview, characteristics, resources, security, configuration, backup/restore, monitoring, operational tasks, maintenance, failover/recovery. Dev team owns it.
- **Evidence status:** corroborated by A1, A7, A9 on operations-manual breadth

### A3: Christian Emmer — An Effective Incident Runbook Template
- **Link / location:** https://emmer.dev/blog/an-effective-incident-runbook-template/
- **Retrieved:** 2026-05-28
- **Trust class:** web (independent practitioner blog)
- **Summary:** Five-section incident runbook (Summary, Triage, Mitigation, Validation, Remediation). Introduces "five A's." Cites Google SRE's 3x MTTR improvement claim. Recommends continuous editing over formal review cycles.
- **Evidence status:** corroborated by A12, A20 on five A's; by A13 on the 3x claim

### A4: Atlassian Confluence — DevOps Runbook Template
- **Link / location:** https://www.atlassian.com/software/confluence/templates/devops-runbook
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor)
- **Summary:** Three-section template: architecture overview, contacts, procedures (start/stop/monitor/troubleshoot). Heavier on architecture and contacts than on incident branching.
- **Evidence status:** corroborated by A2, A6 on architecture-overview structure

### A5: AWS Incident Detection and Response — Develop Runbooks
- **Link / location:** https://docs.aws.amazon.com/IDR/latest/userguide/idr-workloads-dev-runbook.html
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor / managed service)
- **Summary:** AWS IDR uses CLI-based onboarding questionnaire to derive runbook drafts for enterprise customers.
- **Evidence status:** single-source for questionnaire-to-runbook pipeline; audience-mismatched per V2

### A6: GitLab Runbooks repository
- **Link / location:** https://runbooks.gitlab.com/ ; https://gitlab.com/gitlab-com/runbooks
- **Retrieved:** 2026-05-28
- **Trust class:** web (production open-source practice)
- **Summary:** Service-centric directory structure matching service catalog; per-service README plus individual `.md` runbooks organized by symptom. Naming kebab-case. Co-located with infrastructure code; updates ship in same PRs.
- **Evidence status:** corroborated by A17 on alert-keyed organization

### A7: Process.st — How to Create a Runbook
- **Link / location:** https://www.process.st/create-a-runbook/
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor blog)
- **Summary:** Independent corroboration of Limoncelli's seven sections; recommends plan/write/test phases.
- **Evidence status:** corroborated by A1

### A8: UptimeLabs — Incident Response Runbook
- **Link / location:** https://uptimelabs.io/learn/what-is-an-incident-response-runbook/
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor)
- **Summary:** Service teams own service runbooks; SRE owns shared infrastructure runbooks. PR-based updates. "If an engineer runs a command that fails, they will stop using the runbook entirely."
- **Evidence status:** strong-form staleness quote single-sourced per V8; ownership model corroborated by A4 (IncidentHub), A16 (drdroid)

### A9: Lab Zero — DevOps Runbook Guide
- **Link / location:** https://guides.labzero.com/technical_guides/dev_ops_runbook_guide.html
- **Retrieved:** 2026-05-28
- **Trust class:** web (consultancy guide)
- **Summary:** "Table of contents" model: Overview, Observability, Onboarding, Admin, Deploy, Server, Services, Config, Certificates, Further Docs, Known Failures, Future Considerations. Runbook as link hub more than play-by-play.
- **Evidence status:** corroborated by A2 on operations-manual breadth

### A10: Nobl9 — Runbook Example: A Best Practices Guide
- **Link / location:** https://www.nobl9.com/it-incident-management/runbook-example
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor — SLO tooling, commercially adjacent)
- **Summary:** Core template: Title/Objective, Triggers, Instructions, Outcomes, Escalation, Contact. Recommends SME conversations and surveys for input collection. Emphasizes cross-runbook consistency.
- **Evidence status:** corroborated by A12, A15 on sections; vendor weighting per V8

### A11: GitLab Runbooks — directory layout (operational artifact)
- **Link / location:** https://gitlab.com/gitlab-com/runbooks (tree)
- **Retrieved:** 2026-05-28
- **Trust class:** codebase-equivalent (production open-source repository)
- **Summary:** Folder convention explicitly tied to service catalog; explicit rule against ad-hoc top-level directories.
- **Evidence status:** corroborated by A6 (same source, operational view)

### A12: Rootly — Incident Response Runbooks Guide
- **Link / location:** https://rootly.com/incident-response/runbooks
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor — incident management)
- **Summary:** Seven sections: Trigger/Detection, Impact, Containment, Resolution, Validation, Communication, Post-Incident. Endorses five A's. Recommends copy-pasteable commands, version control, quarterly reviews.
- **Evidence status:** corroborated by A3, A15, A16; vendor weighting per V3

### A13: Google SRE Workbook — On-Call
- **Link / location:** https://sre.google/workbook/on-call/
- **Retrieved:** 2026-05-28
- **Trust class:** web (industry reference, non-vendor)
- **Summary:** Google calls their runbooks "playbooks"; every alert ties to a playbook entry with severity, impact, debugging, mitigation. Names the specificity-vs-staleness tension. Update after every page.
- **Evidence status:** corroborated by A3 on 3x MTTR claim; anchors several other findings as non-vendor source

### A14: arXiv 2508.08308 — FATA framework
- **Link / location:** https://arxiv.org/html/2508.08308v1
- **Retrieved:** 2026-05-28
- **Trust class:** web (academic, single-source)
- **Summary:** Claims 27.7–47.4% quality improvement from proactive clarifying questions. Not runbook-specific.
- **Evidence status:** single-source; magnitude figures not load-bearing per V1

### A15: Nobl9 — Runbook Example (separate from A10)
- **Link / location:** see A10
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor)
- **Summary:** Merged into A10 in this consolidated registry; retained as ID for cross-references from upstream research.
- **Evidence status:** see A10

### A16: OneUptime — How to Create Effective Runbooks
- **Link / location:** https://oneuptime.com/blog/post/2026-02-02-effective-runbooks/view
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor)
- **Summary:** Seven sections: Metadata Header (ID, version, owner, duration, risk), Trigger, Prerequisites, Steps with expected outputs, Verification, Escalation, Rollback. Imperative voice; copy-paste-ready commands; change-triggered review; monthly game days. Recommends `{service}-{action}-{scope}.md` naming.
- **Evidence status:** corroborated by A12 on structure; naming pattern single-source on exact form (direction corroborated by A6)

### A17: OpenShift Runbooks
- **Link / location:** https://github.com/openshift/runbooks
- **Retrieved:** 2026-05-28
- **Trust class:** codebase-equivalent (production open-source)
- **Summary:** `alerts/{operator-name}/{AlertName}.md` naming. Files named after the alert they address. Confirms alert-to-runbook linking as first-class.
- **Evidence status:** corroborated by A6 on alert-keyed organization

### A18: FireHydrant — Runbook Best Practices
- **Link / location:** https://docs.firehydrant.com/docs/runbook-best-practices
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor)
- **Summary:** Six-section template (Title, Scope, Objective, Steps, Troubleshooting, References) with branching paths and visual aids.
- **Evidence status:** corroborated by A9, A15 on scope/references structure; vendor weighting per V3

### A19: The Good Shell — Incident Runbook Template
- **Link / location:** https://thegoodshell.com/incident-runbook-template/
- **Retrieved:** 2026-05-28
- **Trust class:** web (technical blog)
- **Summary:** Ten-section incident-focused template with explicit role assignments (incident commander, ops lead, comms lead, scribe) and communication templates per severity level.
- **Evidence status:** role-assignments component single-source per V8

### A20: incident.io — What Are Runbooks?
- **Link / location:** https://incident.io/blog/what-are-runbooks
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor — incident management)
- **Summary:** Endorses five A's framework. Distinguishes runbooks (specific incidents, technical) from playbooks (overall strategy).
- **Evidence status:** five A's corroborated weakly per V8

### A21: SupportBench — Runbook Maintenance Best Practices
- **Link / location:** https://www.supportbench.com/how-to-maintain-runbooks-when-engineering-changes-processes/
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor — customer support software)
- **Summary:** Identifies unclear ownership and lack of change-control integration as primary rot causes. Recommends ship-with-code, dual-date tracking, peer review. "Outdated runbooks are worse than no runbooks."
- **Evidence status:** strong-form quote single-sourced per V8; ship-with-code mitigation corroborated by A6

### A22: incident.io — Automated Runbooks Guide
- **Link / location:** https://incident.io/blog/automated-runbook-guide
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor)
- **Summary:** Addresses staleness/trust problem directly. Service-based ownership via service catalog. Identifies trigger types (alert, webhook, manual, scheduled).
- **Evidence status:** corroborated by A8, A21 on staleness; service-based ownership corroborated by A6

### A23: IncidentHub — No-Nonsense Guide to Runbook Best Practices
- **Link / location:** https://blog.incidenthub.cloud/The-No-Nonsense-Guide-to-Runbook-Best-Practices
- **Retrieved:** 2026-05-28
- **Trust class:** web (technical blog)
- **Summary:** Service-team vs. SRE/ops ownership split; post-incident update by on-call engineer reviewed by peers. Recommends descriptive titles like `runbook-cpu-usage-critical-alert`.
- **Evidence status:** corroborated by A8, A16 on ownership

### A24: Cortex — Runbooks vs. Playbooks
- **Link / location:** https://www.cortex.io/post/runbooks-vs-playbooks
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor)
- **Summary:** Runbooks tactical, playbooks strategic. DR playbook contains a runbook per technical sub-task.
- **Evidence status:** corroborated by A20 on tactical/strategic split

### A25: Cutover — Runbooks vs. Playbooks vs. SOPs
- **Link / location:** https://cutover.com/blog/differences-runbooks-playbooks-sops
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor)
- **Summary:** Playbooks strategic-adaptive; runbooks complex multi-step known operations; SOPs granular routine. Predictability spectrum.
- **Evidence status:** corroborated by A24, A26

### A26: Upstat — Runbook vs. SOP
- **Link / location:** https://upstat.io/blog/runbook-vs-sop
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor)
- **Summary:** Runbooks reactive with branching; SOPs proactive linear. Deployment guides are specialized SOPs.
- **Evidence status:** corroborated by A25

### A27: Hacker News — Writing Runbook Documentation When You're an SRE (thread)
- **Link / location:** https://news.ycombinator.com/item?id=22207452
- **Retrieved:** 2026-05-28
- **Trust class:** web (practitioner discussion, mixed)
- **Summary:** Practitioner debate: staleness most-cited failure mode. Recommendations for single-page keyword-dense format, `$VARIABLE` notation for safe copy-paste, sample expected outputs.
- **Evidence status:** corroborated by A13, A16 on practitioner experience

### A28: drdroid — Runbooks Guide for SRE / On-Call Teams
- **Link / location:** https://drdroid.io/guides/runbooks-guide-for-sre-on-call-teams
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor)
- **Summary:** Runbook creation as documentation requirement for new launches; on-call updates after incidents.
- **Evidence status:** corroborated by A4, A23

### A29: Han codebase — `plugin/skills/project-documentation/SKILL.md`
- **Link / location:** plugin/skills/project-documentation/SKILL.md
- **Retrieved:** n/a (codebase current state)
- **Trust class:** codebase
- **Summary:** Resolves docs directory from CLAUDE.md Project Discovery section; falls back to project-discovery.md. Dispatches 2-3 codebase-explorer agents in parallel. Updates CLAUDE.md with reference. Asks before overwriting.
- **Evidence status:** corroborated by A30, A31 on shared skeleton

### A30: Han codebase — `plugin/skills/architectural-decision-record/SKILL.md`
- **Link / location:** plugin/skills/architectural-decision-record/SKILL.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Writes to discovered ADR directory with one- or two-level filename hierarchy. Template installer pattern with forcing-function YAGNI gate. Dispatches validators.
- **Evidence status:** corroborated by A29, A31

### A31: Han codebase — `plugin/skills/coding-standard/SKILL.md`
- **Link / location:** plugin/skills/coding-standard/SKILL.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Writes to `{docs-dir}/coding-standards/{name}.md` plus path-scoped index files. Applies YAGNI gate with evidence of active use and friction.
- **Evidence status:** corroborated by A29, A30

### A32: Han codebase — `plugin/agents/on-call-engineer.md`
- **Link / location:** plugin/agents/on-call-engineer.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Hard scope boundary: "You do not audit ... runbook documents ... Those belong to `devops-engineer`. Your altitude is application source files only."
- **Evidence status:** load-bearing for skill ownership question

### A33: Han codebase — `plugin/agents/devops-engineer.md`
- **Link / location:** plugin/agents/devops-engineer.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Explicitly reads runbooks. Names "runbook for an alert that has never fired" as a YAGNI anti-pattern; canonical example is Sentry runbooks where data isn't reaching production.
- **Evidence status:** load-bearing for YAGNI preflight

### A34: Han codebase — `plugin/references/yagni-rule.md`
- **Link / location:** plugin/references/yagni-rule.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Gate 1 evidence test: at least one of user-described need, named dependency, production code path, regulatory rule, documented incident, real alert that fired, customer report, measured metric. Gate 2: simpler-version test.
- **Evidence status:** load-bearing for V5 threshold calibration and V7 simpler-version pivot

### A35: Han codebase — `plugin/skills/stakeholder-summary/SKILL.md`
- **Link / location:** plugin/skills/stakeholder-summary/SKILL.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Single-file output with strict plain-language constraint; references template; three self-check passes; no agent dispatch.
- **Evidence status:** corroborated by A29, A30, A31 on the template-installer pattern

### A36: Han codebase — `docs/templates/skill-long-form-template.md`
- **Link / location:** docs/templates/skill-long-form-template.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Strict 13-section structure for long-form operator docs. Related Documentation must link back to README.
- **Evidence status:** load-bearing for the long-form doc deliverable

## References

- PagerDuty — What is a Runbook? https://www.pagerduty.com/resources/automation/learn/what-is-a-runbook/
- SkeltonThatcher run-book-template. https://github.com/SkeltonThatcher/run-book-template
- Christian Emmer — An Effective Incident Runbook Template. https://emmer.dev/blog/an-effective-incident-runbook-template/
- Atlassian Confluence — DevOps Runbook Template. https://www.atlassian.com/software/confluence/templates/devops-runbook
- AWS Incident Detection and Response — Develop Runbooks. https://docs.aws.amazon.com/IDR/latest/userguide/idr-workloads-dev-runbook.html
- GitLab Runbooks. https://runbooks.gitlab.com/ ; https://gitlab.com/gitlab-com/runbooks
- Process.st — How to Create a Runbook. https://www.process.st/create-a-runbook/
- UptimeLabs — Incident Response Runbook. https://uptimelabs.io/learn/what-is-an-incident-response-runbook/
- Lab Zero — DevOps Runbook Guide. https://guides.labzero.com/technical_guides/dev_ops_runbook_guide.html
- Nobl9 — Runbook Example: A Best Practices Guide. https://www.nobl9.com/it-incident-management/runbook-example
- Rootly — Incident Response Runbooks Guide. https://rootly.com/incident-response/runbooks
- Google SRE Workbook — On-Call. https://sre.google/workbook/on-call/
- arXiv 2508.08308 — FATA framework. https://arxiv.org/html/2508.08308v1
- OneUptime — How to Create Effective Runbooks. https://oneuptime.com/blog/post/2026-02-02-effective-runbooks/view
- OpenShift Runbooks. https://github.com/openshift/runbooks
- FireHydrant — Runbook Best Practices. https://docs.firehydrant.com/docs/runbook-best-practices
- The Good Shell — Incident Runbook Template. https://thegoodshell.com/incident-runbook-template/
- incident.io — What Are Runbooks? https://incident.io/blog/what-are-runbooks
- SupportBench — Runbook Maintenance Best Practices. https://www.supportbench.com/how-to-maintain-runbooks-when-engineering-changes-processes/
- incident.io — Automated Runbooks Guide. https://incident.io/blog/automated-runbook-guide
- IncidentHub — No-Nonsense Guide to Runbook Best Practices. https://blog.incidenthub.cloud/The-No-Nonsense-Guide-to-Runbook-Best-Practices
- Cortex — Runbooks vs. Playbooks. https://www.cortex.io/post/runbooks-vs-playbooks
- Cutover — Runbooks vs. Playbooks vs. SOPs. https://cutover.com/blog/differences-runbooks-playbooks-sops
- Upstat — Runbook vs. SOP. https://upstat.io/blog/runbook-vs-sop
- Hacker News — Writing Runbook Documentation When You're an SRE. https://news.ycombinator.com/item?id=22207452
- drdroid — Runbooks Guide for SRE / On-Call Teams. https://drdroid.io/guides/runbooks-guide-for-sre-on-call-teams
- Han plugin — plugin/skills/project-documentation/SKILL.md
- Han plugin — plugin/skills/architectural-decision-record/SKILL.md
- Han plugin — plugin/skills/coding-standard/SKILL.md
- Han plugin — plugin/skills/stakeholder-summary/SKILL.md
- Han plugin — plugin/agents/on-call-engineer.md
- Han plugin — plugin/agents/devops-engineer.md
- Han plugin — plugin/references/yagni-rule.md
- Han plugin — docs/templates/skill-long-form-template.md
