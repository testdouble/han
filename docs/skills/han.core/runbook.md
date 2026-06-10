# /runbook

Operator documentation for the `/runbook` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.core/skills/runbook/SKILL.md`](../../../han.core/skills/runbook/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Creates or updates a runbook for a single operational scenario, using a consistent template that leads with symptoms and progressively discloses the procedure.
- **When to use it.** An alert has fired, an incident has occurred, a recurring task needs to be captured, or a known failure mode on a live service needs a documented response.
- **What you get back.** A single runbook file under `docs/runbooks/` (or the project's existing runbook directory) with metadata, symptoms, prerequisites, an imperative-voice procedure with expected output per step, verification, escalation, and rollback.

## Key concepts

- **Three modes.** Creating new, Updating existing (edit in place, new change-history entry), Validating existing (refresh `Last validated` after running the procedure end-to-end).
- **One runbook per invocation.** The skill produces a single file. Rerun the skill per scenario; do not try to batch.
- **YAGNI preflight.** Before the skill writes anything, it requires the scenario to be real: an alert that has fired, a documented incident, a recurring task, a live failure mode on a service receiving traffic, or a customer / stakeholder commitment. Speculative runbooks are deferred.
- **Symptom-first structure.** The template promotes Symptoms to a top-level section directly under the metadata block so a reader arriving from an alert link can confirm "this is the right runbook" in under ten seconds.
- **Imperative commands with expected output.** Every step in the procedure shows the exact command and what success looks like. Prose paragraphs in place of commands are an authoring failure the skill prompts against.
- **Staleness made visible.** Owner, Last validated, Last edited, Reversible, Origin, and a Change history with validation status all sit in the metadata so decay shows up in the artifact instead of hiding inside it.

## When to use it

**Invoke when:**

- An alert just fired for the first time and you mitigated it manually; capture what you did before you forget.
- A documented incident or post-mortem produced a procedure that should be reusable.
- The team performs a recurring task (cert rotation, index rebuild, monthly data export) and the procedure should be captured so it does not live only in one person's head.
- A known failure mode on a live service needs a documented response before the next on-call rotation.
- You ran an existing runbook end-to-end and want to refresh its `Last validated` date and change-history entry.

**Do not invoke for:**

- **Feature or system documentation.** Use [`/project-documentation`](./project-documentation.md). That skill describes what a feature does and how it works; this skill describes what to do when an operational scenario occurs.
- **An architectural or design decision.** Use [`/architectural-decision-record`](./architectural-decision-record.md). An ADR records a decision and its alternatives; a runbook captures an operational procedure.
- **Coding rules or conventions.** Use [`/coding-standard`](./coding-standard.md).
- **An incident investigation in flight.** Use [`/investigate`](./investigate.md) for evidence-based root-cause work. Run `/runbook` after the investigation lands a procedure that the team will reuse.
- **A speculative runbook for an alert that has not fired.** The skill's YAGNI preflight will defer it. Wait until the alert actually fires or until evidence accumulates.

## How to invoke it

Run `/runbook` in Claude Code.

Give it:

1. **The scenario.** Lead with the observable symptom or operation: *"Postgres primary unreachable: connections time out,"* *"Weekly reindex job,"* *"Queue backlog over 5000."* The clearer the scenario, the less the skill needs to ask.
2. **The evidence the scenario is real.** A link to the firing alert, a post-mortem, the schedule file, a customer report, or a brief description of how you observed the failure mode. The skill's YAGNI preflight needs this before it will write the runbook.
3. **The procedure that worked.** The exact commands you ran, what their output looked like, what you checked to confirm the fix. The skill captures these verbatim; it does not invent commands.
4. **Optional: an existing runbook to update.** Pass the path. The skill will read it, ask what changed, and edit in place with a new change-history entry.

Example prompts:

- `/runbook`. *"Write the runbook for the queue-backlog alert I just mitigated. Alert fired at 14:22 today, incident report at `docs/incidents/2026-05-28-queue-backlog.md`. Fix was to restart the consumer pool with `kubectl rollout restart deploy/consumer -n workers` and verify queue depth dropped below 1000 within five minutes."*
- `/runbook`. *"Capture our weekly Postgres reindex procedure. Schedule lives in `ops/cron/reindex.yaml`; the steps are in my head."*
- `/runbook docs/runbooks/postgres-primary-unreachable.md`. *"Update — we changed the escalation channel from PagerDuty to OpsGenie last week, and I ran the procedure end-to-end this morning."*
- `/runbook`. *"I want to write a runbook for a Sentry alert we don't have data flowing to yet."* The skill will defer this per YAGNI.

## What you get back

A single runbook file plus light integration:

- **`docs/runbooks/{slug}.md`** (or the project's existing runbook directory and convention). The file follows the template at [`references/runbook-template.md`](../../../han.core/skills/runbook/references/runbook-template.md). Required sections: title, one-line description, metadata block (Severity, Triggers, Reversible, Last validated, Last edited, Owner, Origin), Symptoms, Prerequisites, Resolve (or Quick fix), Verify the fix landed, Escalate, Rollback, Live links, Change history. Optional sections (deleted entirely if they do not apply): Likely cause, Not this — try instead, Background, Quick fix, If a step fails, If the problem comes back, What didn't work and why, Background and related.
- **A metadata block tuned for 2am scanning.** Severity and Triggers up top; Reversible visible before the engineer commits to any destructive step; Last validated distinct from Last edited so trust signals are not muddied; Origin holding the YAGNI evidence.
- **An imperative procedure.** Every step shows the exact command and what success looks like, with explicit branching when output differs.
- **Filename convention discovered from the project.** Flat (`docs/runbooks/{scenario}.md`), per-service (`docs/runbooks/{service}/{scenario}.md`), or alert-keyed (`docs/runbooks/alerts/{AlertName}.md`) depending on what the project already uses. The skill matches existing convention when more than two runbooks are present; consistency is the larger value.
- **Cross-references.** If CLAUDE.md or AGENTS.md lists runbooks, the skill adds an entry. If the runbook closes a procedure in an incident report or post-mortem, the skill adds a back-reference. If the alert that triggers the runbook has a definition file in the repository, the skill adds a comment in that file pointing to the runbook.

## How to get the most out of it

- **Bring real evidence, not "we should probably have a runbook for X."** The YAGNI preflight will defer speculative runbooks. The skill is most useful right after a real incident, while the procedure is fresh.
- **Capture the commands verbatim.** The skill writes what you give it. If you paste the exact `kubectl` invocation that worked, that is what the runbook will say. If you describe the procedure in prose, the skill will ask you for the commands before writing.
- **Note "what didn't work" too.** The template has an optional section for it. The next reader benefits from knowing which paths look promising but fail.
- **Run the procedure end-to-end before updating `Last validated`.** Editing the runbook does not validate it. The skill keeps Last edited and Last validated separate on purpose.
- **Pair with `/investigate`** when the runbook comes out of a bug investigation. The investigation lands the fix; `/runbook` captures the procedure for the next engineer who sees the same symptom.

## YAGNI

A runbook requires **evidence the scenario is real today**: an alert that has fired, a documented incident, a recurring task that exists, a live failure mode on a service receiving production traffic, or a customer or stakeholder commitment to document the procedure. Runbooks for hypothetical alerts, "we might need this someday," or symmetry with other runbooks ("we have one for the database, so we should have one for the cache") are YAGNI candidates and are deferred.

The canonical project anti-pattern: Sentry runbooks for staging-only Sentry where data isn't reaching production. The alerts will never fire because no signal flows, and the runbook becomes a load-bearing pattern future agents will copy.

When the preflight finds no current trigger, the skill recommends deferring the runbook and names the trigger that would justify revisiting (the alert firing, the first occurrence of the failure mode, the first run of the recurring task, a customer commitment landing). The user always wins; if they override, the override is recorded explicitly in the runbook's Origin field so future readers can see the runbook was written without standard evidence.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

The companion [evidence rule](../../evidence.md) applies to the citations that ground the scenario: name the trust class of each piece of evidence (alert history, incident report, on-call rotation pattern); cite the actual artifact (dashboard URL, ticket ID, log query) rather than paraphrased recollection; surface single-source claims as such rather than presenting them as settled.

## Cost and latency

The skill is deterministic and does not dispatch agents. A typical run is one or two short rounds of clarifying questions (the YAGNI evidence, missing metadata, the exact commands) followed by a single file write. Runs are fast; the cost is dominated by the back-and-forth needed to capture the procedure accurately.

The skill is built for tight-loop iteration after an incident: write the runbook now while the commands are fresh, then rerun the skill in validate mode the next time someone executes the procedure to refresh `Last validated`.

## In more detail

The skill walks a seven-step process:

1. **Determine mode.** Creating new, Updating existing, or Validating existing.
2. **YAGNI preflight.** Gate the work on real evidence: alert that has fired, incident, recurring task, live failure mode, customer commitment. Recommend deferral when no trigger exists; the user can override and the override is recorded.
3. **Discover project structure.** Resolve the runbooks directory from CLAUDE.md's Project Discovery section, then `project-discovery.md`, then defaults (`docs/runbooks/`, `runbooks/`). Detect whether the project organizes runbooks flat, per-service, or alert-keyed.
4. **Gather context.** Title, severity, triggers, reversibility, origin, owner, prerequisites, symptoms, the procedure with exact commands and expected output, verification, escalation conditions and channels, rollback.
5. **Write the runbook.** Copy the template, fill the metadata, fill each required section, fill applicable optional sections, delete the headings for optional sections that do not apply, delete the author guidance block.
6. **Integration.** CLAUDE.md or AGENTS.md entry if the project lists runbooks; back-reference from incident reports or post-mortems; comment in alert-definition files that point to the runbook.
7. **Verification.** Re-read the file, confirm no placeholders remain, confirm Origin contains real evidence (or an explicit override), confirm Symptoms is concrete, confirm every step shows command and expected output, confirm Verify is distinct from per-step output, confirm Escalate leads with conditions, confirm Rollback is filled or explicitly marked not applicable, confirm empty optional sections are deleted, confirm the change-history creation entry exists.

The template is reviewed by [`information-architect`](../../agents/han.core/information-architect.md) and [`junior-developer`](../../agents/han.core/junior-developer.md) inputs that landed during its design pass. Progressive disclosure runs in two directions: from observable symptom toward likely cause and adjacent failures, and from quick fix toward branching procedure with verification and rollback. The metadata block carries the front-door signals (Severity, Reversible, Last validated) that a tired reader needs before committing to any step.

## Sources

The skill's structure is grounded in established runbook practice and the project's own evidence-based conventions.

### Google SRE Workbook — On-Call

The "playbook entry" pattern in Google SRE — every alert ties to a playbook entry with severity, impact, debugging, and mitigation — anchors the skill's per-scenario structure and the alert-to-runbook linking convention. The corroborated 3x MTTR improvement claim is the only quantitative evidence in the field for runbook value.

URL: https://sre.google/workbook/on-call/

### GitLab Production Runbooks

GitLab's per-service runbooks repository demonstrates the production-grade pattern the skill mirrors: kebab-case filenames, runbooks organized by service or alert, owned by the team that operates the service, updated in the same pull requests as the infrastructure they describe. The skill's flat / per-service / alert-keyed convention detection traces to this practice.

URL: https://runbooks.gitlab.com/

### OpenShift Runbooks

The alert-keyed naming convention (`alerts/{operator}/{AlertName}.md`) the skill detects and matches comes from OpenShift's runbook repository, where the runbook file name is the alert it answers.

URL: https://github.com/openshift/runbooks

### `han.core/references/yagni-rule.md`

The skill's YAGNI preflight applies the project's own evidence-based YAGNI rule. The canonical anti-pattern — "runbook for an alert that has never fired" — comes directly from this rule and from the `devops-engineer` agent definition that codifies it.

URL: [`han.core/references/yagni-rule.md`](../../../han.core/references/yagni-rule.md)

### `docs/research/runbook-skill-research.md`

The skill's design rests on a research pass that surveyed industry runbook formats (Google SRE, GitLab, OpenShift, PagerDuty, Atlassian, Rootly, OneUptime, FireHydrant, incident.io, Nobl9, and more), Han codebase patterns, and adversarial validation. The validation collapsed an earlier interview-driven design in favor of the simpler template installer.

URL: [`docs/research/runbook-skill-research.md`](../../research/runbook-skill-research.md)

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../../yagni.md). The evidence-based rule the skill applies before writing a runbook. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Evidence](../../evidence.md). The companion rule the skill applies to the citations that ground the scenario: trust classes, the corroboration gate, and the no-evidence label.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/investigate`](./investigate.md). The investigation skill that often produces a procedure worth capturing as a runbook. Investigate first, then capture.
- [`/project-documentation`](./project-documentation.md). For feature and system docs. Pair when a runbook needs background a feature doc already provides.
- [`/architectural-decision-record`](./architectural-decision-record.md). For decisions that produce the system the runbook operates on.
- [`information-architect`](../../agents/han.core/information-architect.md). Reviewed the runbook output template for progressive disclosure during the skill's design pass.
- [`junior-developer`](../../agents/han.core/junior-developer.md). Reviewed the runbook output template for generalist readability during the skill's design pass.
- [`devops-engineer`](../../agents/han.core/devops-engineer.md). The agent that consumes runbooks during production-readiness review and whose YAGNI anti-pattern definition anchors the skill's preflight.
- [`SKILL.md` for /runbook](../../../han.core/skills/runbook/SKILL.md). The internal process definition.
