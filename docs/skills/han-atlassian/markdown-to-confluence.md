# /markdown-to-confluence

Operator documentation for the `/markdown-to-confluence` skill in the opt-in `han-atlassian` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-atlassian/skills/markdown-to-confluence/SKILL.md`](../../../han-atlassian/skills/markdown-to-confluence/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Choosing a Han plugin](../../choosing-a-han-plugin.md)

## TL;DR

- **What it does.** Publishes one local Markdown file to a Confluence location you specify, creating a new page or updating an existing one through the Atlassian MCP server.
- **When to use it.** You already have a Markdown file and want it posted to a specific Confluence space or page.
- **What you get back.** A created or updated Confluence page at the location you named, either as an unpublished draft (the default) or live. Your source file is left untouched.

## Key concepts

- **It posts; it does not write.** This skill takes an existing Markdown file as input. It does no codebase exploration and no authoring. If you want documentation generated from your code and then published in one pass, use [`/project-documentation-to-confluence`](./project-documentation-to-confluence.md), which generates the file and hands it to this skill.
- **The Atlassian MCP server is required.** The skill checks the server is connected before it does any work. If the server is missing or not authenticated, it stops. It never falls back to anything else.
- **You must provide the location.** The skill does not search Confluence for the right page. A real Confluence instance is large and full of duplicate and similarly-named pages, so guessing the destination is unreliable. You name the place; the skill publishes there.
- **Two location forms.** Give it a Confluence page URL (to update that page, or to create a child page under it), or a space (key or name) plus an optional parent page. The skill resolves whichever you provide.
- **Draft by default.** The publish mode controls whether the page goes live or is saved as an unpublished draft. If a caller passes the mode explicitly, the skill uses it without asking. Invoked on its own with no mode, it defaults to a draft so nothing goes live unintentionally.
- **Markdown posts directly.** The Atlassian Confluence MCP tools accept Markdown, so the document publishes as-is with no manual conversion to Confluence storage format. A file may also carry embedded Confluence storage macros mixed into the Markdown, for example the title-based page-link macros that [`/plan-a-feature-to-confluence`](./plan-a-feature-to-confluence.md) writes into its cross-page links before handing the file over. The skill posts those verbatim too; it never strips or rewrites the content it is given.

## When to use it

**Invoke when:**

- You have a Markdown file (a doc, a report, a summary) and want it published to a known Confluence page or space.
- You want to update an existing Confluence page from a Markdown file you maintain locally.
- Another skill or workflow has produced a Markdown file and the next step is to put it in Confluence.

**Do not invoke for:**

- **Generating documentation from code.** Use [`/project-documentation-to-confluence`](./project-documentation-to-confluence.md) to document a feature and publish it in one pass, or [`/project-documentation`](../han-core/project-documentation.md) for a local-only doc.
- **Publishing work items to Jira.** Use [`/work-items-to-jira`](./work-items-to-jira.md).
- **Searching Confluence for where something belongs.** The skill does not search; you provide the destination.

## How to invoke it

Run `/markdown-to-confluence` in Claude Code.

The skill ships in the opt-in `han-atlassian` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han-atlassian@han` (it pulls `han-core`, `han-planning`, and `han-coding` along the way), and make sure the Atlassian MCP server is configured and authenticated. See [Choosing a Han plugin](../../choosing-a-han-plugin.md) for where it sits in the suite.

Give it:

1. **The Markdown file path.** The local file to publish. If you do not provide one, the skill asks for it.
2. **The Confluence destination.** A page URL, or a space (key or name) plus an optional parent page. If you do not provide one, the skill asks for it before posting, because it does not search Confluence for the right place.
3. **The publish mode, optional.** `draft` (the default) or `live`. Omit it to save a draft.

Example prompts:

- `/markdown-to-confluence`. *"Publish `docs/payments.md` to the Engineering space under the 'Services' page."*
- `/markdown-to-confluence`. *"Update https://acme.atlassian.net/wiki/spaces/ENG/pages/12345/Payments from `/tmp/payments.md` and publish it live."*
- `/markdown-to-confluence`. *"Post `~/notes/incident-review.md` as a child page under our 'Incidents' page in the OPS space, draft."*

## What you get back

A created or updated Confluence page at the location you named, either as an unpublished draft (the default) or live, per the mode you chose or were passed. The skill reports the page URL on success and tells you which mode it used; for a draft, you still review and publish it yourself in Confluence. Mermaid diagrams publish as Mermaid source in code blocks (see below).

Your source Markdown file is read, never modified. On failure, the skill reports the error and confirms the file is intact.

## How to get the most out of it

- **Have the destination ready.** The fastest run is the one where you paste the page URL or name the space and parent up front, so the skill never has to stop and ask.
- **Use update mode for living docs.** Point the skill at an existing page URL to keep a Confluence page in sync with a Markdown file you maintain, rather than creating a new page each time.
- **Lean on the draft default.** Leaving the mode unset saves an unpublished draft you can review and publish yourself in Confluence, which is the safer way to post something the first time.
- **Know how diagrams land.** If your Markdown has Mermaid diagrams in fenced code blocks, Confluence does not render them without a macro, so the blocks post as source. The skill leaves them intact and tells you they posted as Mermaid source.

## Cost and latency

The skill dispatches no agents. Its cost is a handful of fast Atlassian MCP calls: one preflight, a few to resolve the location, and one to create or update the page. Expect a few seconds plus whatever the Confluence MCP round-trips take.

## In more detail

The skill walks a short, deterministic process:

0. **Atlassian MCP preflight.** Call `getAccessibleAtlassianResources` to confirm the server is connected and to get the cloud ID. If it is unavailable, stop before doing any work.
1. **Confirm the source file.** Resolve and read the Markdown file. If the path is missing or unreadable, ask for it.
2. **Resolve the target location.** Read the destination from your request, or ask for it. Resolve a page URL to a page (and decide update-vs-child), or resolve a space and parent page to their IDs. Fail fast if the location does not resolve.
3. **Determine the publish mode.** Use an explicitly supplied mode, or default to a draft.
4. **Publish to Confluence.** Post the Markdown directly with `contentFormat: "markdown"`, creating a new page or updating an existing one in the chosen mode (draft or live), then report the page URL.
5. **Verification.** Preflight passed, a readable file was supplied, the location was user-specified, and the page was created or updated.

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/project-documentation-to-confluence`](./project-documentation-to-confluence.md). The skill that generates documentation and hands the file to this one. Use it when the doc needs to be written first.
- [`/plan-a-feature-to-confluence`](./plan-a-feature-to-confluence.md). The skill that builds a feature spec and its companion artifacts, then hands each file to this one as a page tree. Use it when a plan needs to be written first.
- [`/investigate-to-confluence`](./investigate-to-confluence.md). The skill that root-causes a bug and hands the investigation report to this one. Use it when a diagnosis needs to be produced first.
- [`/work-items-to-jira`](./work-items-to-jira.md). The other `han-atlassian` skill, for publishing work items to Jira.
- [Choosing a Han plugin](../../choosing-a-han-plugin.md). Why `han-atlassian` is installed separately from the bundled suite, and what it requires.
- [`SKILL.md` for /markdown-to-confluence](../../../han-atlassian/skills/markdown-to-confluence/SKILL.md). The internal process definition.
