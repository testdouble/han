---
name: plan-a-feature-to-confluence
description: >
  Builds a feature specification from scratch with plan-a-feature and publishes it to a
  user-specified Confluence location, posting the spec as a parent page and each companion artifact
  (decision log, team findings, technical notes) as a child page beneath it. Use when the user wants
  a new feature planned, designed, scoped, or specified AND posted to a Confluence space or page.
  Requires a configured Atlassian MCP server. Does not plan to local files only — use plan-a-feature.
  Does not publish an arbitrary existing markdown file — use markdown-to-confluence. Does not refine
  or stress-test an existing plan — use iterative-plan-review. Does not document already-built
  features to Confluence — use project-documentation-to-confluence.
arguments: size
argument-hint: "[size: small | medium | large] [feature description] [confluence location: page URL or space + parent] [--mode draft|live (default draft)]"
allowed-tools: Read, Write, Edit, Glob, Grep, Skill, Bash(find *), mcp__claude_ai_Atlassian__getAccessibleAtlassianResources
---

# Plan a Feature to Confluence

This skill builds a feature specification with the core `han.core:plan-a-feature`
skill, lets the user review the result, and then publishes it to a Confluence
location that **the user must specify**. It is a thin orchestrator: the planning
work belongs to `han.core:plan-a-feature`, and the publishing work belongs to
`han.atlassian:markdown-to-confluence`. This skill only validates its inputs, runs the
planning skill to a temporary folder, gets the user's review and publish choice,
and hands each file to the publisher.

`han.core:plan-a-feature` produces a small **set** of files — the primary
`feature-specification.md` plus companion artifacts under `artifacts/` (the
decision log, the team findings, and a lazily-created technical-notes file). This
skill publishes the **spec as a parent page** and each companion artifact as a
**child page** beneath it, so the whole plan lands in Confluence as one small
page tree. The files cross-reference each other with relative links that do not
resolve once each file is its own Confluence page. Because this skill decides
every page's title up front, it rewrites those cross-file links into Confluence
**title-based page-link macros** (the `<ac:link><ri:page ri:content-title="..."/>…</ac:link>`
form; Step 5 gives the exact macro to emit, link body and all) before creating
any page — these resolve by title at view time, so no page URL or ID has to exist
first. That collapses publishing to a **single create pass**:
there is no separate relink-and-update pass, and each page is created exactly
once.

The six steps below are the whole skill. It does not resolve Confluence pages or
call the Confluence MCP create/update tools itself; `han.atlassian:markdown-to-confluence`
owns all of that.

## Step 1: Validate Inputs

Confirm the skill has everything it needs before spending effort producing a
plan:

1. **Atlassian MCP reachable (hard requirement).** Call
   `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` to confirm the
   server is connected and retrieve the cloud ID(s). If the tool is not
   available, the call errors, or it returns no accessible resources (typically
   an authentication or configuration problem), **stop immediately**. Tell the
   user this skill requires the Atlassian MCP server to be installed, configured,
   and authenticated, and that they can re-run it once it is connected. Do not
   fall back to a local-only run; for local-only planning, point them at
   `han.core:plan-a-feature`. This preflight runs first so a missing server fails
   before any planning work begins.
2. **A feature to plan.** Confirm the request names a feature, capability, or
   system behavior to specify. This — together with the `size` argument and any
   relevant conversation context — is forwarded to `han.core:plan-a-feature`
   verbatim in Step 2. If the request is too thin to start, let
   `han.core:plan-a-feature` run its own interview; do not pre-empt it here.
3. **A Confluence destination.** Confirm the request provides a target location:
   a **Confluence page URL** (to update that page, or create the spec as a child
   under it), or a **space** (key or name) plus an optional **parent page**. If
   none was provided, ask for one with `AskUserQuestion`, explaining plainly that
   the skill needs an exact destination because it does not search Confluence. Do
   not resolve the page tree here — only confirm a location was given. Carry it
   through to Step 5; `han.atlassian:markdown-to-confluence` resolves it.

## Step 2: Produce the Plan to a Temporary Folder

Invoke the `han.core:plan-a-feature` skill with the **Skill** tool, **forwarding
all provided context** verbatim: the `size` argument (if the user passed
`small`, `medium`, or `large`), the feature description, any known constraints or
entry points, and the relevant conversation context. Do not summarize, trim, or
reinterpret the user's context; pass it through so `han.core:plan-a-feature` runs
exactly as it would on its own — interview, review team, finding resolution, and
project-manager synthesis included — **except** add one explicit instruction: it
must write its output folder under `/tmp/` (for example
`/tmp/<feature-slug>/`) rather than into the repo's docs directory, and it should
not prompt the user to choose or confirm an output location, because this skill
owns that decision. This keeps the working plan out of the repo until the user
decides to publish it.

Let `han.core:plan-a-feature` complete its full process. **Capture the exact
`/tmp/` paths of every file it wrote:**

- `/tmp/<feature-slug>/feature-specification.md` — the primary spec (always written).
- `/tmp/<feature-slug>/artifacts/decision-log.md` — the decision history (always written).
- `/tmp/<feature-slug>/artifacts/team-findings.md` — the review-team findings (always written).
- `/tmp/<feature-slug>/artifacts/feature-technical-notes.md` — load-bearing mechanics. **Lazily created — only present if at least one technical note qualified.** Confirm whether it exists before relying on it.

Proceed to Step 3 once it finishes.

## Step 3: Show the Files for Review

Tell the user the exact `/tmp/` paths of every generated file — the spec and each
companion artifact that was actually written (the technical-notes file only if it
exists) — so they can open and review them before deciding whether to publish.
State plainly that nothing has been published anywhere yet.

## Step 4: Confirm the Publish Choice

Publishing to Confluence puts the content where other people can see it, so
require an explicit choice before posting. Ask with `AskUserQuestion`, restating
the **`/tmp/` file paths** and the **Confluence destination** the user provided,
and making clear that publishing creates **one parent page (the spec) plus one
child page per companion artifact**, and that the cross-page links between them
resolve **by page title** — so the published pages should not be renamed in
Confluence afterward, or the inbound cross-links break. Offer three options,
listing the draft option first as the recommended default:

- **"Yes, save them as drafts to edit later (recommended)"** — every page is
  published as an unpublished Confluence draft for the user to review, edit, and
  publish themselves. This is the default. (Publish mode: **draft**.)
- **"Yes, publish them live now"** — the pages go live immediately. (Publish
  mode: **live**.)
- **"No, keep them local only"** — nothing is published.

If the user keeps it local only, **stop**. Report the `/tmp/` folder path and
state clearly that nothing was published to Confluence. Otherwise, record the
chosen publish mode (draft or live) for Step 5. The chosen mode applies to every
page in the tree.

## Step 5: Rewrite Cross-Links to Title Macros, Then Publish the Tree

Publishing is a **single create pass**: rewrite the cross-file links into
title-based page-link macros first, then create each page once with its final
body. No second update pass is needed, because the macros resolve by title and
do not depend on any page URL or ID.

**Decide every page's final title up front.** The title is used in two places —
as the page's create-title, and as the `ri:content-title` in every macro that
links to that page — so pick each title once and reuse it in both, so they can
never drift apart:

- **Spec (the parent page):** the feature name.
- **Decision log:** `<Feature Name> — Decision Log`.
- **Team findings:** `<Feature Name> — Team Findings`.
- **Technical notes** (only if the file exists): `<Feature Name> — Technical Notes`.

These titles must be **distinct within the target space** for the macros to
resolve unambiguously. A `ri:content-title` macro resolves against the **whole
space**, not just this tree, so a title that collides with a page that already
exists in the destination space is a real hazard: the link can resolve to the
wrong page, and the create call may fail or be rejected for a duplicate title.
The feature-name prefix keeps the four titles distinct from each other; pick a
spec title specific enough that it is unlikely to already exist in the space, and
if you have any signal that one does (for example the user pointed at a page that
already carries the feature name), choose a more specific title before
publishing.

1. **Rewrite cross-file links to title macros, leaving the `/tmp/` originals
   intact.** Write the rewritten copies to a dedicated subfolder (for example
   `/tmp/<feature-slug>/.confluence-publish/`) so the originals the user reviewed
   in Step 3 keep their working local markdown links. For each file, read it once
   and rewrite **only** the cross-file links:
   - Resolve each relative markdown link target against the directory of the file
     being rewritten. If it resolves to **another file in the published set**,
     replace the whole markdown link `[text](target#fragment)` with a Confluence
     title-based page-link macro pointing at that file's pre-decided title:

     ```
     <ac:link><ri:page ri:content-title="TARGET PAGE TITLE"/><ac:plain-text-link-body><![CDATA[text]]></ac:plain-text-link-body></ac:link>
     ```

     Omit `ri:space-key` — the whole tree lands in one space, so a same-space
     title reference resolves without it. Keep the original link text inside the
     link body. If that text contains the sequence `]]>`, it would close the
     `CDATA` section early and produce malformed storage XML, so split it across
     two `CDATA` sections (`]]` in the first, `>` in the next) or drop the `CDATA`
     wrapper and XML-escape the text instead. Plain markdown emphasis in the link
     text (`**bold**`) is not rendered inside a plain-text link body; it posts as
     literal characters.
   - **Drop the `#fragment`** (the `#d4-...`, `#t3-...`, or section anchor).
     Confluence Cloud generates its own heading anchors with a scheme that does
     not match these slugs, so the link lands the reader at the **top of the
     correct page**, not the exact heading. (The macro form leaves the door open
     to add an explicit `ri:anchor` later if a space's heading-anchor scheme is
     pinned down; do not emit anchors now.)
   - Leave every other link, and all other content, exactly as written. Do not
     touch links that point outside the published set (external URLs, code
     references).

2. **Publish the tree in one create pass.** Use the **Skill** tool for every
   call, and apply the publish mode the user chose in Step 4 to all of them —
   state it explicitly so `han.atlassian:markdown-to-confluence` does not re-ask.
   - **Publish the spec (the parent page) first**, from its rewritten copy.
     Invoke `han.atlassian:markdown-to-confluence`, forwarding the rewritten spec
     copy's path, the **Confluence destination** the user provided in Step 1
     (passed through verbatim), the **publish mode** from Step 4, and the
     **spec title** decided above. **Capture the resulting spec page's URL and
     page ID** — the parent for the artifact pages, and needed for the final
     report.
   - **Publish each existing artifact as a child of the spec page**, from its
     rewritten copy. For each artifact file that exists (`decision-log.md`,
     `team-findings.md`, and `feature-technical-notes.md` only if it was created),
     invoke `han.atlassian:markdown-to-confluence` again, forwarding the rewritten
     artifact copy's path, the **spec page's URL** as the destination with the
     intent to **create a new child page under it** (state this explicitly so the
     publisher does not ask whether to update the spec page), the same **publish
     mode**, and the artifact's **pre-decided title**. Publish the artifacts one
     at a time so each create resolves against the same parent.

   `han.atlassian:markdown-to-confluence` owns location resolution, the create
   call, and Mermaid handling for each file. Because every body already carries
   its final title-macro links, each page is created exactly once — there is no
   update pass.

**Mermaid still posts as source.** As `han.atlassian:markdown-to-confluence`
reports, Mermaid diagrams publish as fenced code blocks, not rendered diagrams,
unless the space has a Mermaid macro. This is not something to silently fix.

Relay the result to the user: the spec parent page's URL, every artifact child
page's URL, whether the tree went live or was saved as drafts, and the caveats:
cross-page links resolve **by page title** and land at the **top** of the target
page (heading-level anchors are not preserved); because they resolve by title,
**renaming** a published page in Confluence may break inbound cross-page links;
and the Mermaid note. If any create fails partway through the tree, report which
file failed and its error, and note which pages were already created. Warn the
user that those already-created pages carry title-macro links pointing at the
pages that did not get created, so those links dangle until the missing pages
exist under their intended titles — and that simply re-running the whole skill
would re-create the pages that already succeeded, producing duplicate-title pages
that break title resolution for the tree. Recommend they create the missing
page(s) by hand under the intended titles, or delete the partial tree and
re-publish from clean. Confirm the `/tmp/` originals are unchanged and intact
either way.

## Step 6: Verification

1. **Inputs validated:** the Atlassian server was reachable, a feature to plan
   was present, and a Confluence location was provided — or the skill stopped
   before doing any work.
2. **Plan produced to /tmp:** `han.core:plan-a-feature` ran with the full
   forwarded context and wrote its files under a `/tmp/` folder whose paths were
   captured, including whether the lazily-created technical-notes file exists.
3. **User reviewed:** the `/tmp/` paths were shown to the user before any publish.
4. **Explicit choice obtained:** the user chose draft, live, or local-only.
5. **Tree published in a single pass:** when the user chose to publish, titles
   were decided up front, cross-file links were rewritten into title-based
   page-link macros in copies under `.confluence-publish/` (fragments dropped,
   `/tmp/` originals untouched), the spec was posted as the parent page and each
   existing companion artifact as a child page in the chosen mode, and each page
   was created exactly once with its URL captured.
6. **Reported:** every page URL was relayed with the publish mode, the
   resolve-by-title and land-at-page-top caveat, the rename caveat, and the
   Mermaid note; when the user declined, only the `/tmp/` files exist.
