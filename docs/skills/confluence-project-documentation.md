# /confluence-project-documentation

Operator documentation for the `/confluence-project-documentation` skill in the opt-in `han.atlassian` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.atlassian/skills/confluence-project-documentation/SKILL.md`](../../han.atlassian/skills/confluence-project-documentation/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md) · [Choosing a Han plugin](../choosing-a-han-plugin.md)

## TL;DR

- **What it does.** Runs the core [`/project-documentation`](./project-documentation.md) skill to write or update feature documentation, then, after you confirm, publishes that documentation to a Confluence location you specify, using the Atlassian MCP server.
- **When to use it.** You want a feature, system, or component documented *and* posted to a specific Confluence space or page, not just to a local file.
- **What you get back.** The same local `docs/{feature-name}.md` that `/project-documentation` produces, plus a created or updated Confluence page at the location you named.

## Key concepts

- **A thin wrapper around `/project-documentation`.** The documentation work, the codebase exploration, the content audit, and the information-architecture review all belong to [`/project-documentation`](./project-documentation.md). This skill forwards your context to it unchanged and adds three things: the Atlassian MCP requirement, the required destination, and a confirmed publish step.
- **The Atlassian MCP server is required.** The skill checks the server is connected before it does any work. If the server is missing or not authenticated, the skill stops and points you at `/project-documentation` for a local-only run. It never silently falls back to local.
- **You must provide the location.** The skill does not search Confluence for the right page. A real Confluence instance is large and full of duplicate and similarly-named pages, so guessing the destination is unreliable. You name the place; the skill publishes there.
- **Two location forms.** Give it a Confluence page URL (to update that page, or to create a child page under it), or a space plus an optional parent page. The skill resolves whichever you provide.
- **Confirmed publish, with a draft default.** Publishing puts the content where other people can see it, so the skill shows you the resolved destination and the exact action (create page "X" under "Parent", or update page "Y") and waits for your choice before posting. You get three options: save it as a Confluence draft to edit and publish yourself (the recommended default), publish it live immediately, or keep it local only.
- **Markdown posts directly.** The Atlassian Confluence MCP tools accept Markdown, so the document publishes as-is with no manual conversion to Confluence storage format.

## When to use it

**Invoke when:**

- A feature or subsystem needs documentation that lives in Confluence, where your team reads it, not only in the repo.
- A Confluence page has gone stale after a refactor or behavioral change and you want it re-derived from the current code and updated in place.
- You already know the exact Confluence space or page where the doc belongs and want it written and published in one pass.

**Do not invoke for:**

- **Local-only documentation.** Use [`/project-documentation`](./project-documentation.md). This skill is for when the doc also needs to land in Confluence.
- **Technology stack discovery.** Use [`/project-discovery`](./project-discovery.md).
- **Architectural decisions.** Use [`/architectural-decision-record`](./architectural-decision-record.md).
- **Coding conventions.** Use [`/coding-standard`](./coding-standard.md).
- **Runbooks for operational scenarios.** Use [`/runbook`](./runbook.md).

## How to invoke it

Run `/confluence-project-documentation` in Claude Code.

The skill ships in the opt-in `han.atlassian` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han.atlassian@han` (it pulls `han.core` along the way), and make sure the Atlassian MCP server is configured and authenticated. See [Choosing a Han plugin](../choosing-a-han-plugin.md) for where it sits in the suite.

Give it:

1. **The feature or system to document.** *"The authentication system," "the webhook retry mechanism."* This is forwarded to `/project-documentation` unchanged.
2. **The Confluence destination.** A page URL, or a space (key or name) plus an optional parent page. If you do not provide one, the skill asks for it before doing anything, because it does not search Confluence for the right place.
3. **Known entry points, optional.** If you know where the feature lives in the code, mention it. The explorer agents find it anyway, but seed paths speed the pass.

Example prompts:

- `/confluence-project-documentation`. *"Document the authentication system and publish it to the Engineering space under the 'Services' page."*
- `/confluence-project-documentation`. *"Update https://acme.atlassian.net/wiki/spaces/ENG/pages/12345/Payments to match the new Stripe integration."*
- `/confluence-project-documentation`. *"Create docs for the notification dispatcher (entry point `src/notifications/dispatcher.ts`) as a child page under our 'Architecture' page in the ENG space."*

## What you get back

Two artifacts:

- **The local doc.** Everything [`/project-documentation`](./project-documentation.md) produces: a new or updated `docs/{feature-name}.md` that leads with behavior, plus the `CLAUDE.md` / `AGENTS.md` reference and bidirectional cross-references. This file is the source content for Confluence.
- **The Confluence page.** A page created at, or updated in place at, the location you named, either as an unpublished draft (the default) or live, per your choice. The skill reports the page URL on success and tells you which mode it used; for a draft, you still review and publish it yourself in Confluence. Mermaid diagrams publish as Mermaid source in code blocks (see below).

If you keep it local only at the confirmation step, you still keep the local doc; nothing is published.

## How to get the most out of it

- **Have the destination ready.** The fastest run is the one where you paste the page URL or name the space and parent up front, so the skill never has to stop and ask.
- **Use update mode for living docs.** Point the skill at an existing page URL to keep a Confluence doc in sync with the code over time, rather than creating a new page each pass.
- **Know how diagrams land.** `/project-documentation` writes diagrams as Mermaid in fenced code blocks. Confluence does not render Mermaid without a macro, so the blocks post as source. If your space has a Mermaid macro, they may render; otherwise they read as code. The skill leaves them intact and tells you they posted as source.
- **Run `/project-discovery` first.** As with `/project-documentation`, the discovery reference helps the skill find the docs directory and align code-fence languages with the project's stack.

## Cost and latency

The skill itself dispatches no agents. Its cost is whatever [`/project-documentation`](./project-documentation.md) costs (two to three `codebase-explorer` agents in parallel, one `content-auditor` in update mode, and one `information-architect` before verification, all on their default models), plus a handful of fast Atlassian MCP calls to resolve the location and publish the page. For a medium feature, expect a few minutes total, the same shape as `/project-documentation`, with a short publish step at the end.

## In more detail

The skill walks a short, deterministic process around the core documentation run:

0. **Atlassian MCP preflight.** Call `getAccessibleAtlassianResources` to confirm the server is connected and to get the cloud ID. If it is unavailable, stop before doing any work.
1. **Resolve the target location.** Read the destination from your request, or ask for it. Resolve a page URL to a page (and decide update-vs-child), or resolve a space and parent page to their IDs. Fail fast if the location does not resolve.
2. **Produce the documentation locally.** Invoke `/project-documentation` with all your context forwarded verbatim, and capture the markdown file it writes or updates.
3. **Confirm publication.** Show the local doc path and the exact destination and action, and ask how to publish: save as a draft (the recommended default), publish live, or keep it local only.
4. **Publish to Confluence.** Post the markdown directly with `contentFormat: "markdown"`, creating a new page or updating an existing one in the chosen mode (draft or live), then report the page URL.
5. **Verification.** Preflight passed, the location was user-specified, the local doc was produced, confirmation was obtained, and the page was created or updated.

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](./README.md). All skills, grouped by purpose.
- [`/project-documentation`](./project-documentation.md). The core skill this one wraps. Use it directly for local-only documentation.
- [`/project-discovery`](./project-discovery.md). Run first so the documentation pass finds the docs directory and stack language.
- [Choosing a Han plugin](../choosing-a-han-plugin.md). Why `han.atlassian` is installed separately from the bundled suite, and what it requires.
- [`SKILL.md` for /confluence-project-documentation](../../han.atlassian/skills/confluence-project-documentation/SKILL.md). The internal process definition.
