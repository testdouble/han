# Scope Boundary: Research without WebSearch (issue #212)

## Work Item

GitHub issue #212 in `testdouble/han`, "Research agent declares WebSearch, which is absent on Bedrock/Vertex, and
degrades to fetch-only without saying so", read through `gh issue view 212 --repo testdouble/han` on 2026-09-11. The
issue is open, unlabeled, and has no comments.

## Stated Scope

The issue's "Summary" section, quoted word for word:

> `han-research`'s research surface declares `WebSearch`, which does not exist on Claude Code installs backed by AWS
> Bedrock or Google Vertex. Because a `tools:` / `allowed-tools:` list can only _narrow_ what the harness offers, the
> declaration is inert rather than additive: the agent silently loses its only discovery mechanism and keeps going.
>
> Affected declarations:
>
> - `han-research/agents/research-analyst.md` — `tools: Read, Glob, Grep, WebSearch, WebFetch`
> - `han-research/skills/research/SKILL.md` — `allowed-tools: Read, Glob, Grep, Agent, WebSearch, WebFetch, Bash(find *), ...`

The issue's clearest ask, from "Why it matters":

> Nothing surfaces the degradation. The agent does not report that its primary tool is missing, and the caller cannot
> tell a thorough survey from a fetch of the few candidates that happened to be named in the prompt. That is the part I
> would most like fixed, independent of everything below: a research report produced without search should say so.

The issue's "Possible directions", quoted word for word:

> Rough order of preference, and I have no attachment to any of them:
>
> 1. Have the research agent and skill detect that `WebSearch` is absent and state it in the output, rather than
>    degrading silently. Useful on its own even if nothing else changes.
> 2. Document a supported extension point for adding an MCP search tool to the research agents without forking the
>    definition.
> 3. Declare common MCP search tool patterns alongside `WebSearch` so a user-configured server is picked up when
>    present. I do not know whether the plugin format supports optional or wildcard tool entries that no-op when
>    unmatched — that may make this a non-starter.
>
> A documented fallback chain (`WebSearch` → MCP search server → `WebFetch` against registry and API endpoints) would
> also help. In practice `WebFetch` against `api.github.com/search/repositories`, `registry.npmjs.org/<pkg>`, and
> `pypi.org/pypi/<pkg>/json` recovers a usable fraction of discovery and gives more reliable release dates and licenses
> than scraping rendered pages — but an agent only does that if something tells it to.

The issue also records the workaround it rules out, from "The allowlist blocks the natural workaround":

> Since `tools:` is a closed allowlist and lists no MCP tools, a server registered at user scope — Exa, Brave, Tavily,
> Kagi — is still not granted to the agent. The only local fix is to fork the agent definition into
> `~/.claude/agents/`, which then drifts from upstream on every `han-research` release.

Environment, quoted: Claude Code 2.1.263, Linux (WSL2), `CLAUDE_CODE_USE_BEDROCK=1`, region `eu-north-1`,
`han-research` 1.0.1.

## Stated Exclusions

None stated.

## Operator-Stated Scope

The operator invoked `/han-planning:plan-a-change for https://github.com/testdouble/han/issues/212` and, at the
confirmation turn, answered "everything else looks good" to the proposed area, the reading of the directions, and the
folder name. The proposed area was:

- `han-research/agents/research-analyst.md` (the tools line and the "Gather from the Open Web" protocol)
- `han-research/skills/research/SKILL.md` (the allowed-tools line, the roster and dispatch steps, and the render step)
- `han-research/skills/research/references/research-report-template.md`, if the report gains a line that says how
  discovery happened
- the long-form docs and README in `han-research/` that describe what the agent and skill do

Proposed and accepted as outside the area: `han-core/agents/gap-analyzer.md`, which fetches URLs but never searches,
and every other plugin.

The operator accepted the reading that direction 1 (detect the missing tool and say so in the output) is the floor the
plan must meet, and that directions 2 and 3 and the fallback chain are candidates the plan evaluates and may cut with a
reason.

## Direction of Travel

The operator's answer, quoted: "the built in search is not being deprecated, replaced or migrated. this is purely about
where the han skill is installed."

## Visual Material Received

None received.

## Record Provenance

Established by `plan-a-change` in this run on 2026-09-11. Not inherited.
