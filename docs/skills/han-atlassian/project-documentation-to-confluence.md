# /project-documentation-to-confluence

Operator documentation for the `/project-documentation-to-confluence` skill in the opt-in `han-atlassian` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-atlassian/skills/project-documentation-to-confluence/SKILL.md`](../../../han-atlassian/skills/project-documentation-to-confluence/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Choosing a Han plugin](../../choosing-a-han-plugin.md)

## TL;DR

- **What it does.** Runs the core [`/project-documentation`](../han-core/project-documentation.md) skill to write feature documentation to a temporary file, and shows you the file to review. After you confirm, publishes it to a Confluence location you specify by handing the file to [`/markdown-to-confluence`](./markdown-to-confluence.md).
- **When to use it.** You want a feature, system, or component documented *and* posted to a specific Confluence space or page, not only to a local file.
- **What you get back.** A working-draft markdown file under `/tmp/` that you can review, plus a created or updated Confluence page at the location you named (if you choose to publish).

## Key concepts

- **A thin orchestrator over two skills.** The documentation work, the codebase exploration, the content audit, and the information-architecture review all belong to [`/project-documentation`](../han-core/project-documentation.md). The publishing work, the location resolution, and the create-or-update call all belong to [`/markdown-to-confluence`](./markdown-to-confluence.md). This skill only validates its inputs, runs the documentation to a temporary file, lets you review it, takes your publish choice, and hands the file to the publisher.
- **The Atlassian MCP server is required.** The skill checks the server is connected before it generates any documentation, so a missing server fails fast. If the server is missing or not authenticated, the skill stops and points you at `/project-documentation` for a local-only run. It never silently falls back to local.
- **Documentation lands in `/tmp/` first.** Unlike `/project-documentation` on its own, this skill instructs the documentation run to write to a `/tmp/` file rather than into your repo's docs directory. That keeps the working draft out of the repo until you decide to publish it.
- **You review before publishing.** The skill shows you the `/tmp/` file path so you can open and read the draft, then asks how to publish. Nothing is posted until you choose.
- **You must provide the location.** The skill does not search Confluence for the right page. A real Confluence instance is large and full of duplicate and similarly-named pages, so guessing the destination is unreliable. You name the place; `/markdown-to-confluence` publishes there.
- **Confirmed publish, with a draft default.** Publishing puts the content where other people can see it, so the skill waits for your choice before posting. You get three options: save it as a Confluence draft to edit and publish yourself (the recommended default), publish it live immediately, or keep it local only.

## When to use it

**Invoke when:**

- A feature or subsystem needs documentation that lives in Confluence, where your team reads it, not only in the repo.
- A Confluence page has gone stale after a refactor or behavioral change and you want it re-derived from the current code and updated in place.
- You already know the exact Confluence space or page where the doc belongs and want it written and published in one pass.

**Do not invoke for:**

- **Local-only documentation.** Use [`/project-documentation`](../han-core/project-documentation.md). This skill is for when the doc also needs to land in Confluence.
- **Publishing an existing markdown file.** Use [`/markdown-to-confluence`](./markdown-to-confluence.md) when you already have the file and only want it posted, without generating new documentation.
- **Technology stack discovery.** Use [`/project-discovery`](../han-core/project-discovery.md).
- **Architectural decisions.** Use [`/architectural-decision-record`](../han-core/architectural-decision-record.md).
- **Coding conventions.** Use [`/coding-standard`](../han-coding/coding-standard.md).
- **Runbooks for operational scenarios.** Use [`/runbook`](../han-core/runbook.md).
- **Planning or specifying a new feature.** Use [`/plan-a-feature-to-confluence`](./plan-a-feature-to-confluence.md). This skill documents a feature that already exists; that one specs a feature before it is built and publishes the spec.

## How to invoke it

Run `/project-documentation-to-confluence` in Claude Code.

The skill ships in the opt-in `han-atlassian` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han-atlassian@han` (it pulls `han-core`, `han-planning`, and `han-coding` along the way), and make sure the Atlassian MCP server is configured and authenticated. See [Choosing a Han plugin](../../choosing-a-han-plugin.md) for where it sits in the suite.

Give it:

1. **The feature or system to document.** *"The authentication system," "the webhook retry mechanism."* This is forwarded to `/project-documentation` unchanged.
2. **The Confluence destination.** A page URL, or a space (key or name) plus an optional parent page. If you do not provide one, the skill asks for it before doing anything, because it does not search Confluence for the right place.
3. **Known entry points, optional.** If you know where the feature lives in the code, mention it. The explorer agents find it anyway, but seed paths speed the pass.

Example prompts:

- `/project-documentation-to-confluence`. *"Document the authentication system and publish it to the Engineering space under the 'Services' page."*
- `/project-documentation-to-confluence`. *"Update https://acme.atlassian.net/wiki/spaces/ENG/pages/12345/Payments to match the new Stripe integration."*
- `/project-documentation-to-confluence`. *"Create docs for the notification dispatcher (entry point `src/notifications/dispatcher.ts`) as a child page under our 'Architecture' page in the ENG space."*

## What you get back

Two artifacts:

- **The working draft.** A markdown file under `/tmp/` that [`/project-documentation`](../han-core/project-documentation.md) writes, leading with behavior. This file is the source content for Confluence and the thing you review before publishing. It lives in `/tmp/`, not your repo, so it does not get committed unless you move it there yourself.
- **The Confluence page.** A page created at, or updated in place at, the location you named, either as an unpublished draft (the default) or live, per your choice. The skill reports the page URL on success and tells you which mode it used; for a draft, you still review and publish it yourself in Confluence. Mermaid diagrams publish as Mermaid source in code blocks (see below).

If you keep it local only at the confirmation step, you still keep the `/tmp/` draft; nothing is published.

## How to get the most out of it

- **Have the destination ready.** The fastest run is the one where you paste the page URL or name the space and parent up front, so the skill never has to stop and ask.
- **Use update mode for living docs.** Point the skill at an existing page URL to keep a Confluence doc in sync with the code over time, rather than creating a new page each pass.
- **Review the `/tmp/` draft before you publish.** The skill stops and shows you the file path on purpose. Open it, read it, and only then pick draft, live, or local-only. If it needs changes, edit the `/tmp/` file (or re-run) before publishing.
- **Know how diagrams land.** `/project-documentation` writes diagrams as Mermaid in fenced code blocks. Confluence does not render Mermaid without a macro, so the blocks post as source. If your space has a Mermaid macro, they may render; otherwise they read as code. `/markdown-to-confluence` leaves them intact and tells you they posted as source.
- **Run `/project-discovery` first.** As with `/project-documentation`, the discovery reference helps the skill find the docs directory and align code-fence languages with the project's stack.

## Cost and latency

The skill itself dispatches no agents. Its cost is whatever [`/project-documentation`](../han-core/project-documentation.md) costs: two to three `codebase-explorer` agents in parallel, one `content-auditor` in update mode, and one `information-architect` before verification, all on their default models. On top of that, it costs the handful of fast Atlassian MCP calls [`/markdown-to-confluence`](./markdown-to-confluence.md) makes to resolve the location and publish the page. For a medium feature, expect a few minutes total, the same shape as `/project-documentation`, with a short publish step at the end.

## In more detail

The skill walks a short, deterministic five-step process:

1. **Validate inputs.** Confirm the Atlassian MCP server is reachable (calling `getAccessibleAtlassianResources`), that the request names something to document, and that a Confluence destination was provided. If the server is unavailable, stop before generating anything. If no destination was given, ask for one. The skill does not resolve the page tree here; it only confirms a location exists.
2. **Produce the documentation to a temporary file.** Invoke `/project-documentation` with all your context forwarded verbatim, plus one added instruction: write the result to a `/tmp/` file rather than the repo docs directory. Capture that path.
3. **Show the file for review.** Tell you the exact `/tmp/` path so you can open and read the draft before deciding anything.
4. **Confirm the publish choice.** Ask how to publish: save as a draft (the recommended default), publish live, or keep it local only. If you keep it local only, the skill stops and reports the `/tmp/` path.
5. **Publish with `/markdown-to-confluence`.** Hand the `/tmp/` file path, the Confluence destination, and your chosen publish mode to [`/markdown-to-confluence`](./markdown-to-confluence.md), which resolves the location, posts the page, and reports its URL.

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/project-documentation`](../han-core/project-documentation.md). The core skill this one runs to produce the documentation. Use it directly for local-only documentation.
- [`/markdown-to-confluence`](./markdown-to-confluence.md). The publisher this skill hands the file to. Use it directly to publish any existing markdown file to Confluence.
- [`/plan-a-feature-to-confluence`](./plan-a-feature-to-confluence.md). The sibling that plans and publishes a new feature specification to Confluence, rather than documenting one that already exists.
- [`/investigate-to-confluence`](./investigate-to-confluence.md). The single-page sibling that root-causes a bug and publishes the investigation report to Confluence, rather than documenting a feature.
- [`/project-discovery`](../han-core/project-discovery.md). Run first so the documentation pass finds the docs directory and stack language.
- [Choosing a Han plugin](../../choosing-a-han-plugin.md). Why `han-atlassian` is installed separately from the bundled suite, and what it requires.
- [`SKILL.md` for /project-documentation-to-confluence](../../../han-atlassian/skills/project-documentation-to-confluence/SKILL.md). The internal process definition.
