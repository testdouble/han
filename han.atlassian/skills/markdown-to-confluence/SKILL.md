---
name: markdown-to-confluence
description: >
  Publishes a local Markdown file to a user-specified Confluence location, creating a new page or
  updating an existing one through the Atlassian MCP server. Use when the user wants to post,
  publish, push, or sync a Markdown file to a Confluence space or page. Requires a configured
  Atlassian MCP server. Does not write or generate the Markdown itself — point it at an existing
  file, or use project-documentation-to-confluence for the document-then-publish flow, or
  plan-a-feature-to-confluence for the plan-then-publish flow. Does not publish to Jira — use
  work-items-to-jira.
argument-hint: "[path to markdown file] [confluence location: page URL or space + parent] [--mode draft|live (default draft)]"
allowed-tools: Read, Glob, Grep, Bash(find *), mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__atlassianUserInfo, mcp__claude_ai_Atlassian__getConfluenceSpaces, mcp__claude_ai_Atlassian__getConfluencePage, mcp__claude_ai_Atlassian__getPagesInConfluenceSpace, mcp__claude_ai_Atlassian__getConfluencePageDescendants, mcp__claude_ai_Atlassian__createConfluencePage, mcp__claude_ai_Atlassian__updateConfluencePage
---

# Markdown to Confluence

This skill takes one local Markdown file and publishes it to a Confluence
location that **the user must specify** — creating a new page or updating an
existing one through the Atlassian MCP server. It owns everything about the
posting itself: the MCP preflight, resolving the destination, reading the file,
the create-or-update call, and reporting the result. It does not write the
Markdown; the caller supplies an existing file.

Callers that supply an explicit publish mode and location (for example
`han.atlassian:project-documentation-to-confluence`) run this skill straight through without
re-asking. Invoked on its own with pieces missing, it asks for them and defaults
to a safe unpublished draft.

## Step 0: Atlassian MCP Preflight (hard requirement)

This skill cannot run without a configured and connected Atlassian MCP server.

Confirm the server is reachable by calling
`mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to retrieve the
cloud ID(s). If the tool is not available, the call errors, or it returns no
accessible resources (typically an authentication or configuration problem),
**stop immediately**. Tell the user this skill requires the Atlassian MCP server
to be installed, configured, and authenticated, and that they can re-run the
skill once it is connected.

If more than one cloud / site is accessible, note which sites are available;
you will confirm the correct one while resolving the location in Step 2.

## Step 1: Confirm the Source Markdown File

Resolve the Markdown file path from the arguments or conversation. Read it and
confirm it exists and has content. If no file path was provided, or the path
does not resolve to a readable file, ask the user for the path with
`AskUserQuestion` and do not proceed without one. This is the exact content that
will be posted; do not rewrite, summarize, or restructure it.

A body may legitimately contain embedded Confluence storage macros mixed into the
Markdown — for example, an orchestrating skill such as
`han.atlassian:plan-a-feature-to-confluence` rewrites its cross-page links into
title-based page-link macros (the `<ac:link><ri:page ri:content-title="..."/>…</ac:link>`
form, link body included) before handing the file over. Post these verbatim along
with the rest of the body; do not strip or escape them.

## Step 2: Resolve the Target Confluence Location (required)

**This skill does not search Confluence for the right place.** A typical
Confluence instance is large and full of duplicate or similarly-named pages, so
guessing the destination is unreliable. The user must name the exact location.

1. **Find a location in the request.** Check the arguments and conversation for
   either of:
   - a **Confluence page URL** (to update that page, or to create a child page
     under it), or
   - a **space** (key or name) plus an optional **parent page** (title, ID, or
     URL).
2. **If no location was provided, ask for one.** Use `AskUserQuestion` to
   request it, and explain plainly that the skill needs an exact destination
   because it does not search Confluence. Offer both accepted forms (a page URL,
   or a space plus parent page). This is required: do not proceed without a
   location.
3. **Resolve the location concretely now, so failures surface early.** Use the
   cloud ID from Step 0 for every call.
   - **From a page URL:** extract the page ID from the `/pages/<id>/` segment and
     call `mcp__claude_ai_Atlassian__getConfluencePage` to confirm it exists and
     to read its space and title. Then determine the intent: **update that page**,
     or **create a new child page under it**. If the user did not already say,
     ask with `AskUserQuestion`.
   - **From a space (+ parent):** call
     `mcp__claude_ai_Atlassian__getConfluenceSpaces` to resolve the space ID from
     the key or name. If a parent page was named, find it with
     `mcp__claude_ai_Atlassian__getPagesInConfluenceSpace` or
     `mcp__claude_ai_Atlassian__getConfluencePageDescendants` (or by page ID/URL)
     to get the parent page ID. With no parent, the new page is created at the
     space root.
4. **Record the resolved target:** cloud ID, space (ID + human name), parent
   page ID (if any), existing page ID (if updating), the **mode**
   (`create` a new page, or `update` an existing one), and the intended page
   **title**. If updating, default the title to the existing page's title unless
   the user asked to rename it.

## Step 3: Determine the Publish Mode

The publish mode controls whether the page goes live or is saved as an
unpublished draft.

- If the caller supplied an explicit mode (`draft` or `live`), use it. A caller
  that already confirmed the choice with the user (such as
  `han.atlassian:project-documentation-to-confluence`) passes the mode through; do not ask
  again.
- If no mode was supplied, **default to `draft`** so nothing is published live
  unintentionally. The user can re-run for `live`, or you may confirm with
  `AskUserQuestion` whether to save a draft (recommended default) or publish
  live now.

## Step 4: Publish to Confluence

Read the Markdown file from Step 1 and publish it with the Atlassian MCP server.
The Confluence MCP tools accept Markdown directly via `contentFormat: "markdown"`,
so post the document body as-is — no manual conversion to storage/XHTML is
needed. Any embedded storage macros (such as the `ac:link` page-link macros
described in Step 1) ride along in the same body; post them verbatim.

Apply the publish mode from Step 3 with the create/update tool's status
parameter: **draft** → `status: "draft"` (unpublished draft), **live** →
`status: "current"` (immediately visible). Confirm the exact field against the
tool's input schema when you call it, and use whatever the tool exposes for
draft-vs-published.

- **Create mode:** call `mcp__claude_ai_Atlassian__createConfluencePage` with the
  cloud ID, space ID, `title`, the markdown `body`, `contentFormat: "markdown"`,
  the chosen `status` (`"draft"` or `"current"`), and the parent page ID when one
  was resolved.
- **Update mode:** call `mcp__claude_ai_Atlassian__getConfluencePage` first to
  read the current page (for its version and existing content), then call
  `mcp__claude_ai_Atlassian__updateConfluencePage` with the cloud ID, page ID,
  `title`, the markdown `body`, `contentFormat: "markdown"`, and the chosen
  `status`. If the user chose draft for a page that is already published and the
  tool cannot hold an unpublished draft over a live page, do not silently publish
  it live: tell the user, and ask whether to publish the update live or keep the
  changes local only.

**Diagram note:** Markdown produced by Han's documentation skills emits Mermaid
diagrams in fenced ```mermaid``` code blocks. Confluence does not render Mermaid
natively without a Mermaid macro, so these blocks publish as code, not rendered
diagrams. Leave them intact — do not silently strip them — and tell the user the
diagrams posted as Mermaid source, in case their space has a macro that renders
them or they want to convert them by hand.

On success, report the created or updated page's URL, and state whether it was
published live or saved as a draft. For a draft, make clear the user still needs
to review and publish it in Confluence. On failure, report the error and confirm
the source Markdown file is unchanged and intact.

## Step 5: Verification

1. **MCP preflight passed:** the Atlassian server was reachable, or the skill
   stopped before doing any work.
2. **Source file confirmed:** a readable Markdown file was supplied and read.
3. **Location was user-specified:** the destination came from the user, never
   from an automated Confluence search.
4. **Publish reported:** the page was created or updated in the chosen mode
   (live or draft) and its URL was returned.
