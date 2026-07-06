# /investigate-to-confluence

Operator documentation for the `/investigate-to-confluence` skill in the opt-in `han-atlassian` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-atlassian/skills/investigate-to-confluence/SKILL.md`](../../../han-atlassian/skills/investigate-to-confluence/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Choosing a Han plugin](../../choosing-a-han-plugin.md)

## TL;DR

- **What it does.** Runs the core [`/investigate`](../han-coding/investigate.md) skill to root-cause a bug or unexpected behavior, and writes the investigation report to a temporary file. Shows you the file to review. After you confirm, publishes it to a Confluence location you specify by handing the file to [`/markdown-to-confluence`](./markdown-to-confluence.md).
- **When to use it.** You want something diagnosed *and* the findings posted to a specific Confluence space or page, not only to a local file.
- **What you get back.** A working-draft markdown report under `/tmp/` that you can review, plus a created or updated Confluence page at the location you named (if you choose to publish). No code is changed.

## Key concepts

- **A thin orchestrator over two skills.** The investigation work, the parallel evidence-gathering, the specialist analysis, and the adversarial validation all belong to [`/investigate`](../han-coding/investigate.md). The publishing work, the location resolution, and the create-or-update call all belong to [`/markdown-to-confluence`](./markdown-to-confluence.md). This skill only validates its inputs, runs the investigation to a temporary file, lets you review it, takes your publish choice, and hands the file to the publisher.
- **One report, one page.** `/investigate` produces a single report file (problem statement, evidence summary, root cause, planned fix, validation, and summary), with no companion artifacts. So this skill publishes one Confluence page. It is the single-page sibling of [`/project-documentation-to-confluence`](./project-documentation-to-confluence.md), not the parent-plus-children tree of [`/plan-a-feature-to-confluence`](./plan-a-feature-to-confluence.md).
- **It publishes findings, it does not ship them.** `/investigate` on its own ends by presenting the plan for approval and can trigger the fix's implementation. This wrapper instructs it to stop at the report and change no code, because the point is to publish the diagnosis, not to apply it.
- **The Atlassian MCP server is required.** The skill checks the server is connected before it runs any investigation, so a missing server fails fast. If the server is missing or not authenticated, the skill stops and points you at `/investigate` for a local-only run. It never silently falls back to local.
- **The report lands in `/tmp/` first.** Unlike `/investigate` on its own, this skill instructs the investigation run to write to a `/tmp/` file rather than into your repo. That keeps the working report out of the repo until you decide to publish it.
- **You review before publishing.** The skill shows you the `/tmp/` file path so you can open and read the report, then asks how to publish. Nothing is posted until you choose.
- **You must provide the location.** The skill does not search Confluence for the right page. A real Confluence instance is large and full of duplicate and similarly-named pages, so guessing the destination is unreliable. You name the place; `/markdown-to-confluence` publishes there.
- **Confirmed publish, with a draft default.** Publishing puts the content where other people can see it, so the skill waits for your choice before posting. You get three options: save it as a Confluence draft to edit and publish yourself (the recommended default), publish it live immediately, or keep it local only.

## When to use it

**Invoke when:**

- A bug or production incident has been investigated and the root-cause writeup needs to live in Confluence, where your team reads it, not only in the repo.
- You want a diagnosis shared with stakeholders or on-call for review before anyone fixes the underlying problem.
- You already know the exact Confluence space or page where the report belongs and want it investigated and published in one pass.

**Do not invoke for:**

- **Local-only investigation.** Use [`/investigate`](../han-coding/investigate.md). This skill is for when the findings also need to land in Confluence.
- **Publishing an existing markdown file.** Use [`/markdown-to-confluence`](./markdown-to-confluence.md) when you already have the report and only want it posted, without running a new investigation.
- **Documenting an already-understood feature.** Use [`/project-documentation-to-confluence`](./project-documentation-to-confluence.md).
- **Planning or specifying a new feature.** Use [`/plan-a-feature-to-confluence`](./plan-a-feature-to-confluence.md).
- **Publishing to Jira.** Use [`/work-items-to-jira`](./work-items-to-jira.md).

## How to invoke it

Run `/investigate-to-confluence` in Claude Code.

The skill ships in the opt-in `han-atlassian` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han-atlassian@han` (it pulls `han-core`, `han-planning`, and `han-coding` along the way), and make sure the Atlassian MCP server is configured and authenticated. See [Choosing a Han plugin](../../choosing-a-han-plugin.md) for where it sits in the suite.

Give it:

1. **The symptom or question to investigate.** *"Users intermittently get logged out mid-session," "the webhook retries fire twice."* This is forwarded to `/investigate` unchanged.
2. **The Confluence destination.** A page URL, or a space (key or name) plus an optional parent page. If you do not provide one, the skill asks for it before doing anything, because it does not search Confluence for the right place.
3. **Reproduction details or suspected entry points, optional.** Error messages, stack traces, or where in the code you suspect the problem lives. The investigator agents trace it anyway, but seed details speed the pass.

Example prompts:

- `/investigate-to-confluence`. *"Figure out why the nightly export job times out and publish the findings to the Engineering space under the 'Incidents' page."*
- `/investigate-to-confluence`. *"Investigate the duplicate-charge bug and update https://acme.atlassian.net/wiki/spaces/ENG/pages/12345/Payments-Incident with the root cause."*
- `/investigate-to-confluence`. *"Diagnose the flaky checkout test (it fails under load) and post the report as a child page under our 'Bugs' page in the ENG space."*

## What you get back

Two artifacts:

- **The working draft.** A markdown investigation report under `/tmp/` that [`/investigate`](../han-coding/investigate.md) writes: problem statement, evidence summary, root cause analysis, planned fix, validation results, and a leading summary. This file is the source content for Confluence and the thing you review before publishing. It lives in `/tmp/`, not your repo, so it does not get committed unless you move it there yourself. No code is changed.
- **The Confluence page.** A page created at, or updated in place at, the location you named, either as an unpublished draft (the default) or live, per your choice. The skill reports the page URL on success and tells you which mode it used; for a draft, you still review and publish it yourself in Confluence. Mermaid diagrams publish as Mermaid source in code blocks (see below).

If you keep it local only at the confirmation step, you still keep the `/tmp/` draft; nothing is published.

## How to get the most out of it

- **Have the destination ready.** The fastest run is the one where you paste the page URL or name the space and parent up front, so the skill never has to stop and ask.
- **Use update mode for a living incident page.** Point the skill at an existing page URL to keep a Confluence incident or root-cause page in sync as the investigation deepens, rather than creating a new page each pass.
- **Review the `/tmp/` draft before you publish.** The skill stops and shows you the file path on purpose. Open it, read it, and only then pick draft, live, or local-only. If it needs changes, edit the `/tmp/` file (or re-run) before publishing.
- **Know how diagrams land.** If the report includes Mermaid in fenced code blocks, Confluence does not render Mermaid without a macro, so the blocks post as source. If your space has a Mermaid macro, they may render; otherwise they read as code. `/markdown-to-confluence` leaves them intact and tells you they posted as source.
- **Fix separately.** This skill stops at the report and changes no code. When you are ready to apply the fix, run [`/investigate`](../han-coding/investigate.md) directly (or [`/tdd`](../han-coding/tdd.md) against the planned fix) so the implementation goes through the normal review path.

## Cost and latency

The skill itself dispatches no agents. Its cost is whatever [`/investigate`](../han-coding/investigate.md) costs: at least two `evidence-based-investigator` agents in parallel, any conditional specialist analysts the symptom calls for, and one or more `adversarial-validator` agents, all on their default models. On top of that, it costs the handful of fast Atlassian MCP calls [`/markdown-to-confluence`](./markdown-to-confluence.md) makes to resolve the location and publish the page. For a typical bug, expect a few minutes total, the same shape as `/investigate`, with a short publish step at the end.

## In more detail

The skill walks a short, deterministic five-step process:

1. **Validate inputs.** Confirm the Atlassian MCP server is reachable (calling `getAccessibleAtlassianResources`), that the request names something to investigate, and that a Confluence destination was provided. If the server is unavailable, stop before running anything. If no destination was given, ask for one. The skill does not resolve the page tree here; it only confirms a location exists.
2. **Produce the investigation report to a temporary file.** Invoke `/investigate` with all your context forwarded verbatim, plus two added instructions: write the result to a `/tmp/` file rather than the repo, and stop at the report without implementing the fix. Capture that path.
3. **Show the file for review.** Tell you the exact `/tmp/` path so you can open and read the report before deciding anything.
4. **Confirm the publish choice.** Ask how to publish: save as a draft (the recommended default), publish live, or keep it local only. If you keep it local only, the skill stops and reports the `/tmp/` path.
5. **Publish with `/markdown-to-confluence`.** Hand the `/tmp/` file path, the Confluence destination, and your chosen publish mode to [`/markdown-to-confluence`](./markdown-to-confluence.md), which resolves the location, posts the page, and reports its URL.

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/investigate`](../han-coding/investigate.md). The core skill this one runs to produce the report. Use it directly for a local-only investigation, or to implement the fix.
- [`/markdown-to-confluence`](./markdown-to-confluence.md). The publisher this skill hands the file to. Use it directly to publish any existing markdown file to Confluence.
- [`/project-documentation-to-confluence`](./project-documentation-to-confluence.md). The single-page sibling that documents an already-understood feature to Confluence, rather than diagnosing a problem.
- [`/plan-a-feature-to-confluence`](./plan-a-feature-to-confluence.md). The sibling that plans and publishes a new feature specification to Confluence as a page tree.
- [Choosing a Han plugin](../../choosing-a-han-plugin.md). Why `han-atlassian` is installed separately from the bundled suite, and what it requires.
- [`SKILL.md` for /investigate-to-confluence](../../../han-atlassian/skills/investigate-to-confluence/SKILL.md). The internal process definition.
