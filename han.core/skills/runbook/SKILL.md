---
name: runbook
description: >
  Create or update a runbook for an operational scenario — an incident an alert fires for, a
  recurring scheduled task, or a known failure mode on a live service — using a consistent
  template. Use when writing, drafting, authoring, or updating a runbook for an alert, incident,
  on-call procedure, scheduled maintenance, or operational SOP. Applies a YAGNI preflight
  requiring the scenario to be real before producing the runbook. Does not produce feature or
  system documentation — use project-documentation. Does not record architectural decisions — use
  architectural-decision-record. Does not create coding standards — use coding-standard.
argument-hint: [topic or scenario, or path to existing runbook to update]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git config *), Bash(whoami), Bash(date *), Bash(mkdir *), Bash(find *)
---

# Create or Update Runbook

## Operating Principles

- **YAGNI applies to runbooks themselves.** Apply the evidence-based YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md). A runbook is worth writing only when the scenario is grounded in something real: an alert that has actually fired, a documented incident, a recurring task that exists, or a known failure mode on a service that receives production traffic. Runbooks for hypothetical alerts, "best practice says we should have one," or "we'll need this someday" are YAGNI candidates and the runbook should be deferred until the scenario actually occurs. The canonical anti-pattern from project history: Sentry runbooks for staging-only Sentry where data isn't reaching production — alerts that will never fire because no signal flows. The user always wins; the rule's job is to make the cost of speculative runbooks visible.
- **The companion evidence rule applies to the runbook's supporting evidence.** Apply the evidence rule from [../../references/evidence-rule.md](../../references/evidence-rule.md) to the citations that ground the scenario: name the trust class of each piece of evidence (alert history, incident report, on-call rotation pattern); cite the actual artifact (dashboard URL, ticket ID, log query) rather than paraphrased recollection; and surface single-source claims as such rather than presenting them as settled.
- **One runbook per invocation.** The skill produces a single runbook file. Multi-runbook batches conflate scope; rerun the skill per scenario.
- **Imperative commands with expected output.** The template requires every step to show the exact command and what success looks like. Prose paragraphs in place of commands are an authoring failure the skill prompts against.
- **Staleness is the failure mode.** The template requires owner, last-validated, last-edited, and a change-history entry so decay is visible rather than hidden. The skill does not enforce a review cadence — that is a team-level workflow concern — but the metadata fields make the cadence auditable.

## Project Context

- Git user: !`git config user.name` (!`git config user.email`)
- OS username: !`whoami`
- Today's date: !`date +%Y-%m-%d`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Step 1: Determine Mode

Determine which mode to operate in based on the user's request:

| Mode | When | Then |
|------|------|------|
| Creating new | Drafting a runbook for a scenario the project does not yet have one for | → Step 2 |
| Updating existing | Modifying an existing runbook (new step, validation date refresh, escalation change) | Read the existing runbook → Step 4 |
| Validating existing | User says they ran the procedure end-to-end and wants to refresh `Last validated` and add a change-history entry | Read the existing runbook → Step 4 (update mode, validation entry only) |

## Step 2: Apply the YAGNI Preflight

Before discovering structure or gathering context, gate the work. Ask the user (or confirm from their request) which of the following describes the scenario:

1. **An alert that has actually fired** — name the alert, link the firing incident or alert manager record.
2. **A documented incident or post-mortem** — link it.
3. **A recurring scheduled task** that the team performs (weekly index rebuild, monthly cert rotation, etc.) — name the cadence and where the schedule lives.
4. **A live failure mode** on a service that receives production traffic, where the failure has occurred or is expected to occur with current measured pressure — name the service and the failure mode.
5. **Customer report or stakeholder commitment** requiring this procedure to be documented now — link it.

If none of these applies, recommend deferring the runbook. Surface the recommendation to the user with the trigger that would justify revisiting:

> "I don't see a current trigger forcing this runbook. Per the project's YAGNI rule, runbooks for alerts that have never fired are an anti-pattern. Recommend deferring until {trigger — first alert fires, first occurrence of the failure mode, first run of the recurring task, customer commitment lands}. Override and proceed anyway?"

The user always wins. If they override, record the override in the runbook's Origin field as `"override: written preventively at user request on {date} — {reason}"` so future readers can see the runbook was written without standard evidence.

If the scenario does pass the preflight, capture the evidence — the user will be asked again at Step 4 to drop the link or reference into the runbook's `Origin` metadata field.

## Step 3: Discover Project Structure

1. **Resolve project config.** Read CLAUDE.md's `## Project Discovery` section for documented runbook and docs directories. Fall back to `project-discovery.md`. Fall back to Glob defaults (`docs/runbooks/`, `runbooks/`, `docs/`). Continue without any keys that remain unfound.

2. **Determine the runbooks directory.** Use the runbooks directory if found; otherwise use `{docs-dir}/runbooks/` if a docs directory was found; otherwise default to `docs/runbooks/`. Run `mkdir -p` on the resolved directory to ensure it exists.

3. **Enumerate existing runbooks.** Use Glob to find existing `.md` files in the runbooks directory and any service subdirectories. Read filenames to detect whether the project organizes runbooks flat (`docs/runbooks/{scenario}.md`), per-service (`docs/runbooks/{service}/{scenario}.md`), or alert-keyed (`docs/runbooks/alerts/{AlertName}.md`).

4. **Resolve author information.** If git user or email is empty in the project context above, ask the user for their name and email.

5. **Check existing runbook format.** If existing runbooks were found, read one to understand the project's format. If it differs from [runbook-template.md](./references/runbook-template.md), ask the user whether to match the existing format or use this skill's template. Default to matching the existing format when the project already has more than two runbooks — consistency is the larger value.

## Step 4: Gather Context

From the arguments, conversation, and YAGNI preflight in Step 2, capture:

- **Title** — the symptom-first title per the template's title rule. Lead with the observable failure or operation, not the system name. Good: `Postgres primary unreachable: connections time out`. Bad: `Database failover`.
- **Severity** — the org's severity scheme. If the alert uses a different name (P1/P2), record both.
- **Triggers** — the alert name (with link to alert definition or monitoring), the schedule, the upstream runbook, or "manual".
- **Reversibility** — yes, partial, no — wait it out, no — data loss possible. This sets the front-door signal so the engineer knows before they commit whether they can back out.
- **Origin** — the link or reference captured in Step 2. Required.
- **Owner** — team or person paged at 2am for this runbook's freshness.
- **Prerequisites** — access groups, VPN, kubectl context, CLI tools with minimum versions, on-call privileges. "None — workstation only" is a valid answer; blank is not.
- **Symptoms** — what the engineer sees that brings them to this runbook.
- **The procedure** — for each step, the exact command (or non-command action), what success looks like, and what to do if the output differs. Use imperative voice.
- **Verification** — how to confirm the original symptom is gone (separate from per-step expected output).
- **Escalation** — for each escalation step, the condition (time-box or specific failure), the recipient, and the channel (PagerDuty service, Slack room, phone).
- **Rollback** — how to undo the fix, or the explicit alternative if rollback is not possible.

If any of these are unclear, use `AskUserQuestion` to clarify before writing. Ask only for what is genuinely missing; do not re-ask for values present in the user's request.

When the user gives you a recent incident, post-mortem, or alert as the scenario, read it to extract the symptoms, the procedure that worked, and the verification — do not re-derive these from the model's understanding.

## Step 5: Write the Runbook

1. **Copy the template** from [runbook-template.md](./references/runbook-template.md).

2. **File name and location.** Place the file in the runbooks directory from Step 3.

   - **Slug:** kebab-case, lead with the scenario or symptom, not the system name. `postgres-primary-unreachable.md`, not `failover.md`.
   - **Per-service subdirectory:** when the project already organizes runbooks per-service (detected in Step 3), place the file under the matching service directory: `docs/runbooks/{service}/{scenario}.md`. Reuse an existing service directory when one fits; only introduce a new service directory when no existing one applies.
   - **Alert-keyed:** when the project organizes by alert name (detected in Step 3), use the alert name as the file name: `docs/runbooks/alerts/{AlertName}.md`.
   - **Flat default:** when the project has no convention yet, place the file at `docs/runbooks/{slug}.md`.
   - If the project has more than one reasonable placement, ask the user before writing.

3. **Fill the metadata block** with Severity, Triggers, Reversible, Last validated (today's date and the validating party — if the procedure has not been run end-to-end, leave `Last validated` empty and note in change history that it has not yet been validated), Last edited (today's date), Owner, and Origin (from the YAGNI preflight in Step 2).

4. **Fill each required section** following the template's HTML comments for guidance:
   - **Symptoms** — what the engineer sees.
   - **Prerequisites** — required access and tools. Write "None — workstation only" if nothing is required; do not leave blank.
   - **Resolve** — numbered steps with exact commands and expected output. One logical action per step.
   - **Verify the fix landed** — concrete checks that the original symptom is gone.
   - **Escalate** — condition → recipient → channel.
   - **Rollback** — steps to undo, or explicit "Not applicable — {reason and alternative}".
   - **Live links** — operational surfaces used during the incident.
   - **Change history** — start with the creation entry citing the Origin reference.

5. **Fill applicable optional sections** and **delete the headings for any optional section that does not apply**. The optional sections are: Likely cause, Not this — try instead, Background, Quick fix, If a step fails, If the problem comes back, What didn't work and why, Background and related. An empty heading reads as "this runbook is incomplete" — delete rather than leave blank.

6. **Delete the author guidance comment block** at the top of the template once the file is filled in.

7. **If updating an existing runbook:** edit the existing file in place. Append a new change-history entry on top with the date, your name, what changed and why, and the validation status. Update `Last edited` to today; update `Last validated` only if you actually ran the procedure end-to-end against production or a faithful staging environment.

## Step 6: Integration

1. If the project's CLAUDE.md or AGENTS.md has a section that lists runbooks (or that references operational documentation by name), add a one-line entry pointing to the new runbook. Follow the pattern of existing entries; do not invent a new convention.
2. If the runbook closes a procedure documented in an incident report, post-mortem, or related ADR, add a cross-reference from that document back to the runbook.
3. If the runbook's `Triggers` field names an alert that has a definition file in the repository (Prometheus rule, monitoring-as-code config), add a comment in the alert definition pointing to the runbook path.

## Step 7: Verification

Read back the runbook file and confirm:

1. All metadata fields are filled — no `{placeholder}` values remain in Severity, Triggers, Reversible, Owner, Origin. `Last validated` is either a real date with the validating party or explicitly noted as not yet validated in change history.
2. The Origin field contains a real link or reference per the YAGNI preflight. If the user overrode the preflight, the override is recorded explicitly.
3. The Symptoms section is concrete (alert text, error message, log line, or user-visible behavior) rather than generic prose.
4. Every step in Resolve has either an exact command with expected output, or a non-command action with the equivalent "what success looks like" signal.
5. Verify the fix landed lists at least one concrete check that the original symptom is gone, distinct from per-step expected output.
6. Escalate entries lead with a condition (when), then the recipient, then the channel.
7. Rollback is either filled with steps or explicitly marked not applicable with an alternative.
8. Optional sections that do not apply have been deleted entirely — no empty headings remain.
9. The author guidance comment block at the top of the template has been removed.
10. Change history has at least one entry — the creation entry citing Origin.

Fix any issues found before presenting the runbook to the user.
