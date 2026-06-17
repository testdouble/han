---
name: investigate-to-confluence
description: >
  Runs an evidence-based investigation of a bug, failure, or unexpected behavior with investigate
  and publishes the resulting investigation report to a user-specified Confluence location. Use when
  the user wants something debugged, diagnosed, or root-caused AND the findings posted to a
  Confluence space or page. Requires a configured Atlassian MCP server. Does not investigate to a
  local file only — use investigate. Does not publish an arbitrary existing markdown file — use
  markdown-to-confluence. Does not document an already-understood feature to Confluence — use
  project-documentation-to-confluence. Does not plan or specify a new feature to Confluence — use
  plan-a-feature-to-confluence. Does not publish to Jira — use work-items-to-jira.
argument-hint: "[symptom or question to investigate] [confluence location: page URL or space + parent] [--mode draft|live (default draft)]"
allowed-tools: Read, Glob, Grep, Skill, Agent, Bash(find *), mcp__claude_ai_Atlassian__getAccessibleAtlassianResources
---

# Investigate to Confluence

This skill runs an evidence-based investigation with the core `han-coding:investigate`
skill, lets the user review the resulting report, and then publishes it to a
Confluence location that **the user must specify**. It is a thin orchestrator:
the investigation work belongs to `han-coding:investigate`, and the publishing work
belongs to `han-atlassian:markdown-to-confluence`. This skill only validates its inputs,
runs the investigation to a temporary file, gets the user's review and publish
choice, and hands the file to the publisher.

`han-coding:investigate` produces a **single** report file (the investigation plan:
problem statement, evidence summary, root cause analysis, planned fix, validation
results, and summary). It does not produce companion artifacts, so this skill
publishes that one file as a single Confluence page — the single-page sibling of
`han-atlassian:project-documentation-to-confluence`, not the parent-plus-children tree of
`han-atlassian:plan-a-feature-to-confluence`.

The five steps below are the whole skill. It does not resolve Confluence pages or
call the Confluence MCP create/update tools itself; `han-atlassian:markdown-to-confluence`
owns all of that.

## Step 1: Validate Inputs

Confirm the skill has everything it needs before spending effort on an
investigation:

1. **Atlassian MCP reachable (hard requirement).** Call
   `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to confirm the
   server is connected and retrieve the cloud ID(s). If the tool is not
   available, the call errors, or it returns no accessible resources (typically
   an authentication or configuration problem), **stop immediately**. Tell the
   user this skill requires the Atlassian MCP server to be installed, configured,
   and authenticated, and that they can re-run it once it is connected. Do not
   fall back to a local-only run; for a local-only investigation, point them at
   `han-coding:investigate`. This preflight runs first so a missing server fails
   before any investigation work begins.
2. **A symptom or question to investigate.** Confirm the request names a bug,
   failure, error, integration, or unexpected behavior to investigate. This —
   together with any relevant conversation context — is forwarded to
   `han-coding:investigate` verbatim in Step 2. If the request is too thin to
   start, let `han-coding:investigate` run its own investigation rather than
   pre-empting it here.
3. **A Confluence destination.** Confirm the request provides a target location:
   a **Confluence page URL** (to update that page, or create a child under it),
   or a **space** (key or name) plus an optional **parent page**. If none was
   provided, ask for one with `AskUserQuestion`, explaining plainly that the
   skill needs an exact destination because it does not search Confluence. Do not
   resolve the page tree here — only confirm a location was given. Carry it
   through to Step 5; `han-atlassian:markdown-to-confluence` resolves it.

## Step 2: Produce the Investigation Report to a Temporary File

Invoke the `han-coding:investigate` skill with the **Skill** tool, **forwarding all
provided context** verbatim: the symptom or question, any known reproduction
steps or error messages, any suspected entry points, and the relevant
conversation context. Do not summarize, trim, or reinterpret the user's context;
pass it through so `han-coding:investigate` runs exactly as it would on its own
(parallel investigators, conditional specialist analysts, adversarial validation,
and the final report) — **except** add two explicit instructions:

- It must write the resulting investigation report to a file under `/tmp/` (for
  example `/tmp/<symptom-slug>.md`) rather than into the project's docs or plans
  directory. This keeps the working report out of the repo until the user decides
  to publish it.
- It must **stop after producing the report**. `han-coding:investigate` normally
  ends by presenting the plan for approval and can trigger the fix's
  implementation on approval; this skill wants the report only, so instruct it
  not to implement the fix or change any code — this skill publishes findings,
  it does not ship them.

Let `han-coding:investigate` complete its full investigation process. **Capture the
exact `/tmp/` file path it wrote.** That markdown file is the source content for
Confluence. Proceed to Step 3 once it finishes.

## Step 3: Show the File for Review

Tell the user the exact `/tmp/` path of the generated investigation report so
they can open and review it before deciding whether to publish. State plainly
that the content has not been published anywhere yet, and that no code was
changed.

## Step 4: Confirm the Publish Choice

Publishing to Confluence puts the content where other people can see it, so
require an explicit choice before posting. Ask with `AskUserQuestion`, restating
the **`/tmp/` file path** and the **Confluence destination** the user provided.
Offer three options, listing the draft option first as the recommended default:

- **"Yes, save it as a draft to edit later (recommended)"** — published as an
  unpublished Confluence draft for the user to review, edit, and publish
  themselves. This is the default. (Publish mode: **draft**.)
- **"Yes, publish it live now"** — the page goes live immediately. (Publish
  mode: **live**.)
- **"No, keep it local only"** — nothing is published.

If the user keeps it local only, **stop**. Report the `/tmp/` report path and
state clearly that nothing was published to Confluence. Otherwise, record the
chosen publish mode (draft or live) for Step 5.

## Step 5: Publish with markdown-to-confluence

Invoke the `han-atlassian:markdown-to-confluence` skill with the **Skill** tool, forwarding:

- the **`/tmp/` markdown file path** captured in Step 2,
- the **Confluence destination** the user provided in Step 1 (the page URL, or
  the space plus optional parent page), passed through verbatim, and
- the **publish mode** the user chose in Step 4 (`draft` or `live`), stated
  explicitly so `han-atlassian:markdown-to-confluence` does not re-ask.

`han-atlassian:markdown-to-confluence` resolves the location, reads the file, creates or
updates the page in the chosen mode, handles Mermaid diagrams, and reports the
resulting page URL. Relay its result to the user: the created or updated page's
URL and whether it went live or was saved as a draft. If publishing fails,
report the error and confirm the `/tmp/` markdown file is unchanged and intact.

## Verification

1. **Inputs validated:** the Atlassian server was reachable, a symptom or
   question to investigate was present, and a Confluence location was provided —
   or the skill stopped before doing any work.
2. **Report produced to /tmp:** `han-coding:investigate` ran with the full forwarded
   context, wrote the investigation report to a `/tmp/` file whose path was
   captured, and did not implement the fix or change any code.
3. **User reviewed:** the `/tmp/` path was shown to the user before any publish.
4. **Explicit choice obtained:** the user chose draft, live, or local-only.
5. **Publish delegated and reported:** when the user chose to publish,
   `han-atlassian:markdown-to-confluence` created or updated the page in the chosen mode and
   its URL was relayed; when the user declined, only the `/tmp/` report exists.
