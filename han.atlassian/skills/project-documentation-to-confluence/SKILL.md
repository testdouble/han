---
name: project-documentation-to-confluence
description: >
  Creates or updates project documentation for a feature, system, or component and publishes it to
  a user-specified Confluence location. Use when the user wants feature or system documentation
  written to Confluence, posted to a Confluence space or page, or synced to a Confluence location.
  Requires a configured Atlassian MCP server. Does not document to local files only — use
  project-documentation for that. Does not publish an arbitrary existing markdown file — use
  markdown-to-confluence for that. Does not plan or specify a new feature to Confluence — use
  plan-a-feature-to-confluence for that. Does not create architectural decision records — use
  architectural-decision-record. Does not create coding standards — use coding-standard. Does not
  produce runbooks — use runbook.
argument-hint: "[feature-name or doc-path] [confluence location: page URL or space + parent]"
allowed-tools: Read, Glob, Grep, Skill, Agent, Bash(date *), Bash(git config *), Bash(whoami), Bash(mkdir *), Bash(find *), mcp__claude_ai_Atlassian__getAccessibleAtlassianResources
---

# Project Documentation to Confluence

This skill produces project documentation with the core `han.core:project-documentation`
skill, lets the user review the result, and then publishes it to a Confluence
location that **the user must specify**. It is a thin orchestrator: the
documentation work belongs to `han.core:project-documentation`, and the publishing work
belongs to `han.atlassian:markdown-to-confluence`. This skill only validates its inputs,
runs the documentation to a temporary file, gets the user's review and publish
choice, and hands the file to the publisher.

The five steps below are the whole skill. It does not resolve Confluence pages or
call the Confluence MCP create/update tools itself; `han.atlassian:markdown-to-confluence`
owns all of that.

## Step 1: Validate Inputs

Confirm the skill has everything it needs before spending effort producing
documentation:

1. **Atlassian MCP reachable (hard requirement).** Call
   `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to confirm the
   server is connected and retrieve the cloud ID(s). If the tool is not
   available, the call errors, or it returns no accessible resources (typically
   an authentication or configuration problem), **stop immediately**. Tell the
   user this skill requires the Atlassian MCP server to be installed, configured,
   and authenticated, and that they can re-run it once it is connected. Do not
   fall back to a local-only run; for local-only documentation, point them at
   `han.core:project-documentation`. This preflight runs first so a missing server fails
   before any documentation is generated.
2. **A documentation subject.** Confirm the request names a feature, system,
   component, or existing doc to document. This is forwarded to
   `han.core:project-documentation` verbatim in Step 2.
3. **A Confluence destination.** Confirm the request provides a target location:
   a **Confluence page URL** (to update that page, or create a child under it),
   or a **space** (key or name) plus an optional **parent page**. If none was
   provided, ask for one with `AskUserQuestion`, explaining plainly that the
   skill needs an exact destination because it does not search Confluence. Do not
   resolve the page tree here — only confirm a location was given. Carry it
   through to Step 5; `han.atlassian:markdown-to-confluence` resolves it.

## Step 2: Produce the Documentation to a Temporary File

Invoke the `han.core:project-documentation` skill with the **Skill** tool, **forwarding
all provided context** verbatim: the feature name or document path argument, the
scope, any known entry points, and the relevant conversation context. Do not
summarize, trim, or reinterpret the user's context; pass it through so
`han.core:project-documentation` runs exactly as it would on its own — **except** add one
explicit instruction: it must write the resulting documentation to a file under
`/tmp/` (for example `/tmp/<feature-slug>.md`) rather than into the project's
docs directory. This keeps the working draft out of the repo until the user
decides to publish it.

Let `han.core:project-documentation` complete its full process (codebase exploration,
writing the doc, content audit, information-architecture review, and
verification). **Capture the exact `/tmp/` file path it wrote.** That markdown
file is the source content for Confluence. Proceed to Step 3 once it finishes.

## Step 3: Show the File for Review

Tell the user the exact `/tmp/` path of the generated documentation so they can
open and review it before deciding whether to publish. State plainly that the
content has not been published anywhere yet.

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

If the user keeps it local only, **stop**. Report the `/tmp/` doc path and state
clearly that nothing was published to Confluence. Otherwise, record the chosen
publish mode (draft or live) for Step 5.

## Step 5: Publish with markdown-to-confluence

Invoke the `han.atlassian:markdown-to-confluence` skill with the **Skill** tool, forwarding:

- the **`/tmp/` markdown file path** captured in Step 2,
- the **Confluence destination** the user provided in Step 1 (the page URL, or
  the space plus optional parent page), passed through verbatim, and
- the **publish mode** the user chose in Step 4 (`draft` or `live`), stated
  explicitly so `han.atlassian:markdown-to-confluence` does not re-ask.

`han.atlassian:markdown-to-confluence` resolves the location, reads the file, creates or
updates the page in the chosen mode, handles Mermaid diagrams, and reports the
resulting page URL. Relay its result to the user: the created or updated page's
URL and whether it went live or was saved as a draft. If publishing fails,
report the error and confirm the `/tmp/` markdown file is unchanged and intact.

## Verification

1. **Inputs validated:** the Atlassian server was reachable, a documentation
   subject was present, and a Confluence location was provided — or the skill
   stopped before doing any work.
2. **Doc produced to /tmp:** `han.core:project-documentation` ran with the full forwarded
   context and wrote the documentation to a `/tmp/` file whose path was captured.
3. **User reviewed:** the `/tmp/` path was shown to the user before any publish.
4. **Explicit choice obtained:** the user chose draft, live, or local-only.
5. **Publish delegated and reported:** when the user chose to publish,
   `han.atlassian:markdown-to-confluence` created or updated the page in the chosen mode and
   its URL was relayed; when the user declined, only the `/tmp/` doc exists.
