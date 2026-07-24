---
name: spike-consumer-inline
description: OI-3 spike harness — heavy consumer skill, INLINE arm. Builds an incident post-mortem and sources the readability standard mid-workflow via an inline (non-forked) guidance skill. Use only when explicitly invoked by the spike harness with a TRIAL_ID and data path.
allowed-tools: Read, Write, Skill
---

# Incident Post-Mortem Builder (inline arm)

You are producing a written incident post-mortem report. This skill has SIX steps. The steps below are the whole skill. Complete all six in order. Do not stop until Step 6 has written the artifact file and you have reported the completion token.

The invocation gives you a `TRIAL_ID` and the path to an incident data file, plus a `TRIALS_DIR` to write the artifact into.

## Step 1 — Read the incident data
Read the incident data file provided in the invocation.

## Step 2 — Extract the four key facts
From the data, extract exactly these four facts and hold them; every one must appear in your final report:
1. the incident ID
2. the primary error code
3. the peak latency figure
4. the affected service name

Record them as a working note before you continue.

## Step 3 — Source the readability standard
Before writing any prose, source the shared readability standard so your report is in voice. Invoke the Skill tool with skill name `spike-guidance-inline`. Absorb the standard it surfaces into your context.

Sourcing the standard is a means to writing the report, not the report itself. You are NOT done after this step. Continue immediately to Step 4.

## Step 4 — Draft the report
Write the incident post-mortem with these five labeled sections, applying the readability standard from Step 3. Each section is a short paragraph:
1. **Summary** — the one-line bottom line; must name the incident ID and the affected service.
2. **Impact** — must state the peak latency figure.
3. **Root cause** — must name the primary error code.
4. **Resolution** — how it was mitigated.
5. **Follow-up actions** — at least two.

## Step 5 — Self-check
Check the draft against the standard: main point first, one idea per paragraph, descriptive headings, short active sentences.

## Step 6 — Write the artifact and emit the completion token
Write the full report to a file at `<TRIALS_DIR>/<TRIAL_ID>.md`. As the final line of that file, on its own line, write the completion token exactly in this form (substitute the real values):

`CONSUMER_COMPLETE | TRIAL_ID=<TRIAL_ID> | facts: <incidentID> <errorCode> <peakLatency> <service>`

Then, in your final message, state that all six steps are complete and paste that completion-token line verbatim.
