# /plan-a-feature-to-confluence

Operator documentation for the `/plan-a-feature-to-confluence` skill in the opt-in `han.atlassian` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.atlassian/skills/plan-a-feature-to-confluence/SKILL.md`](../../../han.atlassian/skills/plan-a-feature-to-confluence/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Choosing a Han plugin](../../choosing-a-han-plugin.md)

## TL;DR

- **What it does.** Runs the core [`/plan-a-feature`](../han.core/plan-a-feature.md) skill to build a feature specification in a temporary folder, shows you the files to review, and then, after you confirm, publishes the plan to a Confluence location you specify by handing each file to [`/markdown-to-confluence`](./markdown-to-confluence.md): the spec as a parent page and each companion artifact as a child page beneath it.
- **When to use it.** You want a new feature planned from scratch *and* posted to a specific Confluence space or page, not just to local files.
- **What you get back.** A working-draft plan folder under `/tmp/` that you can review, plus a small Confluence page tree at the location you named (if you choose to publish): the spec page with the decision log, team findings, and technical notes as child pages.

## Key concepts

- **A thin orchestrator over two skills.** The interview, the design-tree walk, the review team, and the project-manager synthesis all belong to [`/plan-a-feature`](../han.core/plan-a-feature.md). The publishing, the location resolution, and the create-or-update calls all belong to [`/markdown-to-confluence`](./markdown-to-confluence.md). This skill only validates its inputs, runs the planning skill to a temporary folder, lets you review the files, takes your publish choice, and hands each file to the publisher.
- **A plan is a set of files, so Confluence gets a page tree.** `/plan-a-feature` produces a primary `feature-specification.md` plus companion artifacts under `artifacts/` (the decision log, the team findings, and a lazily-created technical-notes file). This skill publishes the spec as a parent page and each companion artifact that exists as a child page beneath it.
- **It publishes in a single pass using title-based links.** The files link to each other with relative paths that break once each is a separate page. Because the skill decides every page's title up front, it rewrites those cross-file links into Confluence title-based page-link macros (`<ac:link><ri:page ri:content-title="..."/></ac:link>`) before creating any page. Those macros resolve by title at view time, so no page URL has to exist first, and each page is created exactly once with no separate update pass. It drops the `#heading` fragment in the rewrite (see the limitation under "What you get back").
- **The Atlassian MCP server is required.** The skill checks the server is connected before it produces any plan, so a missing server fails fast. If the server is missing or not authenticated, the skill stops and points you at `/plan-a-feature` for a local-only run. It never silently falls back to local.
- **The plan lands in `/tmp/` first.** Unlike `/plan-a-feature` on its own, this skill instructs the planning run to write its folder under `/tmp/` rather than into your repo's docs directory. That keeps the working plan out of the repo until you decide to publish it. Move it into the repo yourself if you want to keep it locally too.
- **You review before publishing.** The skill shows you the `/tmp/` file paths so you can open and read the spec and its artifacts, then asks how to publish. Nothing is posted until you choose.
- **You must provide the location.** The skill does not search Confluence for the right page. A real Confluence instance is large and full of duplicate and similarly-named pages, so guessing the destination is unreliable. You name the place for the spec; the artifacts become its children.
- **Confirmed publish, with a draft default.** Publishing puts the content where other people can see it, so the skill waits for your choice before posting. You get three options: save the pages as Confluence drafts to edit and publish yourself (the recommended default), publish them live immediately, or keep them local only. The chosen mode applies to every page in the tree.

## When to use it

**Invoke when:**

- A new feature needs a specification that lives in Confluence, where your team reads it, not only in the repo.
- You are planning a feature and the spec belongs under an existing Confluence space or page from the start.
- You want the spec and its decision log, team findings, and technical notes posted as one navigable page tree in one pass.

**Do not invoke for:**

- **Local-only planning.** Use [`/plan-a-feature`](../han.core/plan-a-feature.md). This skill is for when the plan also needs to land in Confluence.
- **Publishing an existing markdown file.** Use [`/markdown-to-confluence`](./markdown-to-confluence.md) when you already have the file and just want it posted, without generating a new plan.
- **Refining or stress-testing an existing plan.** Use [`/iterative-plan-review`](../han.core/iterative-plan-review.md).
- **Documenting an already-built feature to Confluence.** Use [`/project-documentation-to-confluence`](./project-documentation-to-confluence.md). That skill describes what exists; this one specifies what to build.

## How to invoke it

Run `/plan-a-feature-to-confluence` in Claude Code.

The skill ships in the opt-in `han.atlassian` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han.atlassian@han` (it pulls `han.core` along the way), and make sure the Atlassian MCP server is configured and authenticated. See [Choosing a Han plugin](../../choosing-a-han-plugin.md) for where it sits in the suite.

Give it:

1. **The feature to plan.** *"A bulk-export jobs feature," "team invite links with expiration."* This, the optional size, and your conversation context are forwarded to `/plan-a-feature` unchanged, which runs its full interview.
2. **The Confluence destination.** A page URL, or a space (key or name) plus an optional parent page. This is where the spec page goes; the artifact pages become its children. If you do not provide a destination, the skill asks for it before doing anything, because it does not search Confluence for the right place.
3. **The size, optional.** `small`, `medium`, or `large` as the first argument, forwarded to `/plan-a-feature` to set its review-team size. Omit it to let `/plan-a-feature` classify the feature itself.

Example prompts:

- `/plan-a-feature-to-confluence`. *"Plan team invite links with expiration and publish them to the Engineering space under the 'Roadmap' page."*
- `/plan-a-feature-to-confluence medium`. *"Spec a bulk-export jobs feature as a child page under https://acme.atlassian.net/wiki/spaces/ENG/pages/12345/Features."*

## What you get back

Two things:

- **The working-draft plan.** A folder under `/tmp/` that [`/plan-a-feature`](../han.core/plan-a-feature.md) writes: `feature-specification.md` at the root and, under `artifacts/`, `decision-log.md`, `team-findings.md`, and (only if a load-bearing mechanic qualified) `feature-technical-notes.md`. These files are the source content for Confluence and the thing you review before publishing. They live in `/tmp/`, not your repo, so they do not get committed unless you move them there yourself.
- **The Confluence page tree.** The spec posted as a parent page at the location you named, with each companion artifact that exists posted as a child page beneath it, either as unpublished drafts (the default) or live, per your choice. The skill reports every page URL on success and tells you which mode it used; for drafts, you still review and publish them yourself in Confluence.

Two things to know about how the content lands:

- **Cross-page links resolve by title, to the page, not the heading.** The spec's inline links to its artifacts (for example `([D4](artifacts/decision-log.md#...))`) are relative file paths that would not resolve once each file is its own Confluence page. The skill rewrites those links into title-based page-link macros that point at the correct Confluence child page by its title. It cannot preserve the `#heading` anchor, because Confluence Cloud generates its own heading anchors with a scheme that does not match the markdown slugs, so a rewritten link lands you at the top of the right page rather than at the exact decision or note. Because the links resolve by title, renaming a published page in Confluence later may break the inbound cross-page links that point at it. Your local `/tmp/` originals keep their working relative links untouched.
- **Mermaid posts as source.** As [`/markdown-to-confluence`](./markdown-to-confluence.md) reports, Mermaid diagrams publish as fenced code blocks, not rendered diagrams, unless your space has a Mermaid macro.

If you keep it local only at the confirmation step, you still keep the `/tmp/` plan folder; nothing is published.

## How to get the most out of it

- **Have the destination ready.** The fastest run is the one where you paste the page URL or name the space and parent up front, so the skill never has to stop and ask.
- **Review the `/tmp/` plan before you publish.** The skill stops and shows you the file paths on purpose. Open the spec and its artifacts, read them, and only then pick draft, live, or local-only. If they need changes, edit the `/tmp/` files (or re-run) before publishing.
- **Decide whether you want the plan in the repo too.** The plan lives in `/tmp/` by design. If you want a local copy under version control, move the folder into your repo's docs tree yourself, or run `/plan-a-feature` directly for a repo-resident plan and publish later with `/markdown-to-confluence`.
- **Know how diagrams and cross-links land.** Cross-file links are rewritten into title-based macros that resolve to the right Confluence pages, but land at the top of the target page rather than the exact decision or note, and Mermaid diagrams post as source unless your space has a macro. Read the spec page knowing a decision link takes you to the Decision Log page, not straight to that decision's heading. Because the links resolve by title, avoid renaming the published pages if you want the cross-links to keep working.
- **Pair with `/plan-implementation` next.** Once the spec is settled, turn it into an implementation plan. The Confluence spec page is the shareable record; the implementation work continues from the local spec.

## YAGNI

This skill produces no artifact of its own, so it adds no YAGNI posture. The plan it publishes is built by [`/plan-a-feature`](../han.core/plan-a-feature.md), which applies the evidence-based [YAGNI](../../yagni.md) rule to every behavior, alternate flow, edge case, coordination, and open item before committing it to the spec, and records deferrals in the spec's `## Deferred (YAGNI)` section. Whatever YAGNI discipline shows up in the published spec comes from that run; this skill neither adds nor relaxes it.

## Cost and latency

The skill itself dispatches no agents. Its cost is whatever [`/plan-a-feature`](../han.core/plan-a-feature.md) costs (its interview plus a review team of two to five `sonnet` sub-agents scaled by size, and a `project-manager` synthesis pass), plus the handful of fast Atlassian MCP calls [`/markdown-to-confluence`](./markdown-to-confluence.md) makes per page to resolve the location and publish. Because the cross-page links are rewritten into title macros before anything is created, each page is published with a single create call and no follow-up update, so a spec with three artifacts is four create steps at the end. For a medium feature, expect the same shape and run time as `/plan-a-feature`, with the publish steps appended.

## In more detail

The skill walks a short, deterministic six-step process:

1. **Validate inputs.** Confirm the Atlassian MCP server is reachable (calling `getAccessibleAtlassianResources`), that the request names a feature to plan, and that a Confluence destination was provided. If the server is unavailable, stop before producing anything. If no destination was given, ask for one. The skill does not resolve the page tree here; it only confirms a location exists.
2. **Produce the plan to a temporary folder.** Invoke `/plan-a-feature` with all your context forwarded verbatim, plus one added instruction: write the output folder under `/tmp/` rather than the repo docs directory, and do not prompt for an output location. Capture the paths of every file written, including whether the lazily-created technical-notes file exists.
3. **Show the files for review.** Tell you the exact `/tmp/` paths so you can open and read the spec and its artifacts before deciding anything.
4. **Confirm the publish choice.** Ask how to publish the page tree: save as drafts (the recommended default), publish live, or keep them local only. If you keep them local only, the skill stops and reports the `/tmp/` folder.
5. **Rewrite cross-links to title macros, then publish the tree.** Decide every page's final title up front, then rewrite each file's cross-file links into title-based page-link macros that point at the target page by its title (dropping the `#heading` fragment), writing the rewritten copies beside the untouched `/tmp/` originals. Then publish in a single create pass: hand the spec to `/markdown-to-confluence` first, at the destination you named, capture its page URL, and publish each existing companion artifact as a child page under it, in the same mode. Each page is created exactly once. Report every page URL, that links resolve by title and land at the top of the target page, the rename caveat, and the Mermaid note.
6. **Verification.** Confirm inputs were validated, the plan was produced to `/tmp/`, the paths were shown for review, an explicit publish choice was obtained, the titles were decided up front and the cross-file links rewritten into title macros, the tree was published in a single create pass with the originals left intact, and everything was reported (or that only the `/tmp/` files exist when you declined).

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/plan-a-feature`](../han.core/plan-a-feature.md). The core skill this one runs to build the specification. Use it directly for a local-only plan.
- [`/markdown-to-confluence`](./markdown-to-confluence.md). The publisher this skill hands each file to. Use it directly to publish any existing markdown file to Confluence.
- [`/project-documentation-to-confluence`](./project-documentation-to-confluence.md). The sibling that documents an already-built feature to Confluence, rather than planning a new one.
- [Choosing a Han plugin](../../choosing-a-han-plugin.md). Why `han.atlassian` is installed separately from the bundled suite, and what it requires.
- [YAGNI](../../yagni.md). The evidence-based rule the underlying `/plan-a-feature` run applies to the spec it builds.
- [`SKILL.md` for /plan-a-feature-to-confluence](../../../han.atlassian/skills/plan-a-feature-to-confluence/SKILL.md). The internal process definition.
