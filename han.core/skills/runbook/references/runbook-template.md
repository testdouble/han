<!--
AUTHOR: fill this template, then delete this comment block.

REQUIRED sections: Title, one-line description, metadata, Symptoms,
Prerequisites, Resolve (or Quick fix), Verify the fix landed, Escalate,
Rollback, Live links, Change history.

OPTIONAL sections (delete the entire heading if it does not apply —
an empty section reads as "this runbook is incomplete"): Likely cause,
Not this — try instead, Background, Quick fix, If a step fails, If the
problem comes back, What didn't work and why, Background and related.

EVIDENCE GATE: per the project's YAGNI rule, do not write a runbook for
an alert that has never fired or a scenario that has never occurred.
The Origin field below requires the citation. If you cannot cite one,
defer the runbook — write it the first time the scenario actually
happens.
-->

# Runbook: {Title}

<!-- Title rule: lead with the observable symptom or failure mode, not the system name. Match the alert subject line if you can. Good: "Postgres primary unreachable: connections time out". Bad: "Database runbook" or "Failover procedure". The reader is matching this against an alert subject line in two seconds. -->

> {One-line description: what the engineer will see and what this runbook does about it. Mirror the alert text where possible.}

- **Severity:** {SEV-1 | SEV-2 | SEV-3 | routine} <!-- Use your org's existing severity scheme. If the alert uses a different name (P1/P2), put it in parentheses so the reader does not have to translate. -->
- **Triggers:** {alert name(s) and link, schedule, upstream runbook, customer report, or "manual"}
- **Reversible:** {yes — see Rollback | partial — see Rollback | no — wait it out | no — data loss possible} <!-- Front-door signal so the engineer knows before they commit whether they can back out. -->
- **Last validated:** {YYYY-MM-DD by {who}} <!-- "Validated" = ran the procedure end-to-end against production or a faithful staging environment. Edits without a validation run do not update this date. -->
- **Last edited:** {YYYY-MM-DD}
- **Owner:** {team or person paged at 2am for this runbook's freshness}
- **Origin:** {link to the incident, alert-firing record, ticket, recurring task, or "first observed YYYY-MM-DD in {context}"} <!-- Required. Per the project's YAGNI rule, runbooks for alerts that have never fired are an anti-pattern; this field is the evidence. -->

## Symptoms

<!-- What the engineer sees that brought them here. Alert text, error message, log line, user-visible behavior. The reader is confirming "yes, this is the right runbook" in under 10 seconds. -->

- …

### Likely cause (optional)

<!-- One or two of the top causes, ordered by likelihood. The Resolve section will branch on them. Delete the heading if you genuinely don't know. -->

### Not this — try instead (optional)

<!-- Near-neighbor failures this runbook could be confused with, each pointing at where to go. Delete if no near-neighbor exists. -->

- **{Adjacent symptom}** — try {other runbook path}

## Background (optional)

<!-- One paragraph on why the system has this failure mode at all. Helps a future reader reason about variants the procedure does not cover. Delete if the failure mode is self-explanatory. -->

## Prerequisites

<!-- What the engineer needs before running the procedure: access groups, VPN, kubectl context, env vars, CLI tools (with minimum versions), on-call privileges. If nothing is required beyond a workstation, write "None — workstation only." Do not leave blank. -->

- …

## Quick fix (optional)

<!-- Use only when the fix is one or two commands the engineer can safely run without reading the rest. "Safe" = reversible, low blast radius, harmless if this turns out to be the wrong runbook. If you fill this section, omit Resolve — don't duplicate the procedure. -->

**Run only if:** {the single precondition that makes this safe to run sight-unseen}.

```
$ {exact-command-1}
$ {exact-command-2}
```

Then jump to [Verify the fix landed](#verify-the-fix-landed).

## Resolve

<!-- Numbered steps. Imperative voice ("Check…", "Run…", "Restart…"). One logical action per step; if a step has more than one expected outcome, split it. Non-command steps are fine — describe the action (open a dashboard, ask the customer to retry, watch a graph). -->

### 1. {First action}

```
$ {exact-command}
```

Expected output:

```
{what success looks like}
```

If you see something different: {what that means and which step or escalation to jump to}.

### 2. {Second action}

```
$ {exact-command}
```

Expected output:

```
{what success looks like}
```

<!-- Continue numbering. Keep each step to one action and one expected outcome. -->

## Verify the fix landed

<!-- Separate from per-step "Expected output" above. Per-step output tells the engineer a command ran; this section tells them the original symptom is gone. -->

- {Check 1 — what to look at, what counts as healthy}
- {Check 2 — alert auto-clears, dashboard returns to baseline, user confirmation, …}

## If a step fails (optional)

<!-- Keyed to step numbers. Stays in the procedural flow. Leave the section in even if empty at first; fill it as the procedure is exercised. -->

- **Step N failed with {error}:** {what to try, or which escalation}

## If the problem comes back (optional)

<!-- Different from "a step failed" — the runbook worked, but the underlying cause recurs. -->

- **Recurrence pattern:** {what to investigate, which related runbook to consult, when to open an incident}

## What didn't work and why (optional)

<!-- Paths that look promising but fail. Stops the next reader from re-running failed experiments. Add entries as the procedure is exercised. -->

- **{What was tried}:** {why it failed, when not to try it again}

## Escalate

<!-- When and to whom. Order by who to try first. Each line: condition → role/recipient → channel (PagerDuty service, Slack room, phone). The condition matters more than the recipient — the reader is looking for "when do I escalate," not "who is on the list." -->

1. **If {condition, e.g., step 3 fails or 15 minutes elapsed without resolution}:** page {role / person} via {channel — PagerDuty service `service-name`, Slack `#channel`, phone}
2. **If {next condition}:** {next contact and channel}

## Rollback

<!-- How to undo the fix if it makes things worse. If rollback is not possible, say so explicitly with the alternative ("Not possible — wait for X" or "No rollback — escalate immediately to Y"). Do not leave this blank. -->

{Describe the rollback as steps; include exact commands when applicable. If not applicable, write "Not applicable — {reason and what to do instead}."}

## Live links

<!-- Operational surfaces used during the incident: dashboards, status pages, log queries, the firing alert itself. Pointers, not full content. -->

- {label}: {url}

## Background and related (optional)

<!-- Read after the incident, not during: adjacent runbooks, ADRs, post-mortems, design docs. Delete the section if there is nothing yet. -->

- {label}: {path or url}

## Change history

<!-- Append-only. Newest entry on top. Record who changed what, why, and whether the change was validated against production. The first entry is the creation entry — cite the incident, alert firing, or recurring task that motivated writing this runbook. -->

- **{YYYY-MM-DD}** — {who}: {what changed and why} [validated: yes | no | partial — {scope}]
