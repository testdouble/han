---
name: code-overview-to-confluence
description: >
  Produces a progressive-disclosure overview of unfamiliar code or a pull request's changes with
  code-overview and publishes the resulting overview to a user-specified Confluence location. Use
  when the user wants code or a PR explained, oriented, or made sense of AND the overview posted to
  a Confluence space or page. Requires a configured Atlassian MCP server. Does not produce the
  overview to a local file only — use code-overview. Does not publish an arbitrary existing markdown
  file — use markdown-to-confluence. Does not document an already-understood feature to Confluence —
  use project-documentation-to-confluence. Does not root-cause a bug to Confluence — use
  investigate-to-confluence. Does not plan or specify a new feature to Confluence — use
  plan-a-feature-to-confluence. Does not publish to Jira — use work-items-to-jira.
argument-hint: "[size: small | medium | large] [target: file, directory, symbol, or PR reference — defaults to the current branch's changes] [confluence location: page URL or space + parent] [--mode draft|live (default draft)]"
allowed-tools: Read, Glob, Grep, Skill, Agent, Bash(find *), mcp__claude_ai_Atlassian__getAccessibleAtlassianResources
---

# Code Overview to Confluence

This skill runs a progressive-disclosure code overview with the core
`han-coding:code-overview` skill, lets the user review the resulting overview, and
then publishes it to a Confluence location that **the user must specify**. It is a
thin orchestrator: the overview work belongs to `han-coding:code-overview`, and the
publishing work belongs to `han-atlassian:markdown-to-confluence`. This skill only
validates its inputs, runs the overview to a scratch file, gets the user's review
and publish choice, and hands the file to the publisher.

`han-coding:code-overview` produces a **single** scratch file (the overview: what the
code does, how it flows, where to start, and — in PR mode — what changed and what
to watch when reviewing). It does not produce companion artifacts, so this skill
publishes that one file as a single Confluence page — the single-page sibling of
`han-atlassian:investigate-to-confluence` and `han-atlassian:project-documentation-to-confluence`,
not the parent-plus-children tree of `han-atlassian:plan-a-feature-to-confluence`.

The five steps below are the whole skill. It does not resolve Confluence pages or
call the Confluence MCP create/update tools itself; `han-atlassian:markdown-to-confluence`
owns all of that.

## Step 1: Validate Inputs

Confirm the skill has everything it needs before spending effort on an overview:

1. **Atlassian MCP reachable (hard requirement).** Call
   `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to confirm the
   server is connected and retrieve the cloud ID(s). If the tool is not
   available, the call errors, or it returns no accessible resources (typically
   an authentication or configuration problem), **stop immediately**. Tell the
   user this skill requires the Atlassian MCP server to be installed, configured,
   and authenticated, and that they can re-run it once it is connected. Do not
   fall back to a local-only run; for a local-only overview, point them at
   `han-coding:code-overview`. This preflight runs first so a missing server fails
   before any overview work begins.
2. **A target to overview (optional).** The target may be a file, directory,
   symbol, or pull request reference, and an optional size (`small`, `medium`, or
   `large`). All of this — together with the relevant conversation context — is
   forwarded to `han-coding:code-overview` verbatim in Step 2. A target is not
   required: with none given, `han-coding:code-overview` defaults to the current
   branch's changes. Do not resolve or classify the target here; that is
   `han-coding:code-overview`'s job.
3. **A Confluence destination.** Confirm the request provides a target location:
   a **Confluence page URL** (to update that page, or create a child under it),
   or a **space** (key or name) plus an optional **parent page**. If none was
   provided, ask for one with `AskUserQuestion`, explaining plainly that the
   skill needs an exact destination because it does not search Confluence. Do not
   resolve the page tree here — only confirm a location was given. Carry it
   through to Step 5; `han-atlassian:markdown-to-confluence` resolves it.

## Step 2: Produce the Overview to a Scratch File

Invoke the `han-coding:code-overview` skill with the **Skill** tool, **forwarding all
provided context** verbatim: the target (file, directory, symbol, or PR
reference, or none for the current branch's changes), any size the user gave, and
the relevant conversation context. Do not summarize, trim, or reinterpret the
user's context; pass it through so `han-coding:code-overview` runs exactly as it would
on its own (target resolution, mode and size selection, parallel
`codebase-explorer` exploration, synthesis, and the readability-review pass).

`han-coding:code-overview` already writes its overview to a scratch file outside the
repository and changes no code, so this skill adds no behavioral instructions — it
only needs the resulting file. **Capture the exact scratch-file path it wrote**
(for example `${TMPDIR:-/tmp}/code-overview-<slug>.md`). That markdown file is the
source content for Confluence. Proceed to Step 3 once it finishes.

## Step 3: Show the File for Review

Tell the user the exact scratch-file path of the generated overview so they can
open and review it before deciding whether to publish. State plainly that the
content has not been published anywhere yet, and that no code was changed.

## Step 4: Confirm the Publish Choice

Publishing to Confluence puts the content where other people can see it, so
require an explicit choice before posting. Ask with `AskUserQuestion`, restating
the **scratch-file path** and the **Confluence destination** the user provided.
Offer three options, listing the draft option first as the recommended default:

- **"Yes, save it as a draft to edit later (recommended)"** — published as an
  unpublished Confluence draft for the user to review, edit, and publish
  themselves. This is the default. (Publish mode: **draft**.)
- **"Yes, publish it live now"** — the page goes live immediately. (Publish
  mode: **live**.)
- **"No, keep it local only"** — nothing is published.

If the user keeps it local only, **stop**. Report the scratch-file path and state
clearly that nothing was published to Confluence. Otherwise, record the chosen
publish mode (draft or live) for Step 5.

## Step 5: Publish with markdown-to-confluence

Invoke the `han-atlassian:markdown-to-confluence` skill with the **Skill** tool, forwarding:

- the **scratch-file markdown path** captured in Step 2,
- the **Confluence destination** the user provided in Step 1 (the page URL, or
  the space plus optional parent page), passed through verbatim, and
- the **publish mode** the user chose in Step 4 (`draft` or `live`), stated
  explicitly so `han-atlassian:markdown-to-confluence` does not re-ask.

`han-atlassian:markdown-to-confluence` resolves the location, reads the file, creates or
updates the page in the chosen mode, handles Mermaid diagrams, and reports the
resulting page URL. Relay its result to the user: the created or updated page's
URL and whether it went live or was saved as a draft. If publishing fails,
report the error and confirm the scratch-file markdown is unchanged and intact.

## Verification

1. **Inputs validated:** the Atlassian server was reachable and a Confluence
   location was provided — or the skill stopped before doing any work.
2. **Overview produced to a scratch file:** `han-coding:code-overview` ran with the
   full forwarded context, wrote the overview to a scratch file whose path was
   captured, and changed no code.
3. **User reviewed:** the scratch-file path was shown to the user before any
   publish.
4. **Explicit choice obtained:** the user chose draft, live, or local-only.
5. **Publish delegated and reported:** when the user chose to publish,
   `han-atlassian:markdown-to-confluence` created or updated the page in the chosen mode and
   its URL was relayed; when the user declined, only the scratch file exists.
