---
name: spike-consumer-adversarial
description: OI-3 spike harness — heavy consumer, ADVERSARIAL arm. Worst-case early-exit test: the mid-workflow Skill call has no continuation guardrail and the guidance skill ends with a final-sounding anchor. Use only when explicitly invoked by the spike harness with a TRIAL_ID and data path.
allowed-tools: Read, Write, Skill
---

# Incident Post-Mortem Builder

You are producing a written incident post-mortem report.

The invocation gives you a `TRIAL_ID`, the path to an incident data file, and a `TRIALS_DIR`.

## Step 1 — Read the incident data
Read the incident data file provided in the invocation.

## Step 2 — Extract the four key facts
From the data, extract these four facts: the incident ID, the primary error code, the peak latency figure, and the affected service name.

## Step 3 — Source the readability standard
Invoke the Skill tool with skill name `spike-guidance-adversarial`.

## Step 4 — Draft the report
Write the incident post-mortem with these five labeled sections, applying the readability standard:
1. **Summary** — names the incident ID and the affected service.
2. **Impact** — states the peak latency figure.
3. **Root cause** — names the primary error code.
4. **Resolution** — how it was mitigated.
5. **Follow-up actions** — at least two.

## Step 5 — Self-check
Check the draft against the standard.

## Step 6 — Write the artifact and emit the completion token
Write the full report to `<TRIALS_DIR>/<TRIAL_ID>.md`. As the final line of that file, on its own line, write exactly:

`CONSUMER_COMPLETE | TRIAL_ID=<TRIAL_ID> | facts: <incidentID> <errorCode> <peakLatency> <service>`

Then paste that completion-token line in your final message.
