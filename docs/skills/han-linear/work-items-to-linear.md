# /work-items-to-linear

Operator documentation for the `/work-items-to-linear` skill in the opt-in `han-linear` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-linear/skills/work-items-to-linear/SKILL.md`](../../../han-linear/skills/work-items-to-linear/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Choosing a Han plugin](../../choosing-a-han-plugin.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Takes a `work-items.md` file produced by [`/plan-work-items`](../han-planning/plan-work-items.md), validates the format, and creates one Linear issue per work item in a single target team through the Linear MCP server.
- **When to use it.** You have a trusted work-items file and you want each item tracked as a Linear issue an implementer can grab.
- **What you get back.** One Linear issue per work item in the team you named, within-file dependencies recorded as native "blocked by" relations, and the source `work-items.md` annotated with each created issue's identifier.

## Key concepts

- **One team, not a repo map.** Every work item becomes an issue in the single Linear team you name. Unlike the GitHub sibling, this skill does not split work across repos. If the source file spans several code repos, the repo prose is informational only. It never changes which team an issue lands in.
- **The Linear MCP server is required.** The skill checks the server is connected before it does any work. If the server is missing or not authenticated, the skill stops. It drives Linear entirely through the MCP server. There is no CLI and no shell-script pipeline.
- **Discovery over assumed defaults.** Linear teams each define their own workflow states, labels, and Projects, so the skill reads the target team's real configuration and resolves every option against it before creating anything. It does not assume a label or a state exists. When you have not said how to categorize the work, it presents the team's real labels and lets you pick one, several, or none.
- **No issue types.** Linear has no issue-type concept, so the skill never asks for or sets one. Categorization is done with the team's real labels, chosen by you.
- **Grouping the Linear way.** You can group the created issues under a Linear **Project** and nest them as **sub-issues** under a **parent issue**. Both are optional and independent. A Project is resolved at workspace scope and confirmed against the team; a parent issue is resolved within the team.
- **Native dependency relations.** Every SYM named in a `Depends on` line must resolve to another slice in the same file. After all issues exist, the skill creates a native Linear "blocked by" relation from each dependent issue to its blockers. Relations are append-only and de-duplicated, so a re-run never doubles them.
- **Reference artifacts, not process artifacts.** Every issue description carries the artifacts an implementer needs: API and event contracts, design references, schema docs, ADRs, coding standards. It never carries the process artifacts that record how the plan was reached: iteration histories, decision logs, review findings. The full include and exclude lists live in [the reference artifact inventory](../../../han-linear/skills/work-items-to-linear/references/reference-artifact-inventory.md).
- **No image embedding.** Design references are carried as links in the issue. Add image attachments in Linear by hand if an issue needs them.
- **Evidence-based repair.** When a format check fails, the skill proposes a fix backed by a concrete source: a file path with line number, a plan section, or an ADR ID. You can continue with the fills, correct them, or stop.
- **Idempotent resume.** After an issue is created, its slice heading in the source file is annotated with the Linear identifier. A re-run skips already-annotated slices, so a partial run resumes cleanly.

## When to use it

**Invoke when:**

- You have a `work-items.md` file from `/plan-work-items` and you want each item published as a Linear issue in a team your group tracks.
- You want the issues grouped under a Linear Project, nested as sub-issues under a parent, placed in a particular workflow state, or tagged with the team's labels.
- You want the issue descriptions to carry the contract, design, and standards links an implementer needs, with the process artifacts left out.

**Do not invoke for:**

- **Producing the work-items file.** Use [`/plan-work-items`](../han-planning/plan-work-items.md) to break a trusted plan into work items first. This skill publishes that file. It does not create it.
- **Posting to Jira.** Use [`/work-items-to-jira`](../han-atlassian/work-items-to-jira.md) to create Jira tickets instead.
- **Posting to GitHub.** Use [`/work-items-to-issues`](../han-github/work-items-to-issues.md) to create GitHub issues instead.
- **Writing the code for an item.** Use [`/tdd`](../han-coding/tdd.md) to implement a work item test-first.

## How to invoke it

Run `/work-items-to-linear` in Claude Code.

The skill ships in the opt-in `han-linear` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han-linear@han` (it pulls `han-core` along the way). See [Choosing a Han plugin](../../choosing-a-han-plugin.md) for where it sits in the suite.

**First-run setup: the Linear MCP server.** The skill drives Linear through the official Linear MCP server, a hosted remote server at `https://mcp.linear.app/mcp`. Install the Linear plugin or MCP server in Claude Code, then authorize it. The server uses OAuth, so the first run opens a browser flow where you grant access to your Linear workspace. The MCP server handles the OAuth exchange. The skill never sees or stores a token. Once the server is connected and authorized, the skill's preflight passes. For the full setup reference, see Linear's MCP documentation at https://linear.app/docs/mcp.

Give it:

1. **The `work-items.md` path.** The single file produced by `/plan-work-items`. If you do not provide it, the skill asks.
2. **The target team, required.** Pass `--team <name or key>`. If the name matches more than one team, the skill asks which one. If you provide no team, the skill asks before it creates anything.
3. **A Project, optional.** Pass `--project <name or ID>` to group every created issue under a Linear Project.
4. **A parent, optional.** Pass `--parent <issue id>` to nest every created issue as a sub-issue under that parent.
5. **A workflow state, optional.** Pass `--state <name>` to place each issue in that state. The default is the team's own initial state.
6. **Labels, optional.** Pass `--label <name>`, repeatable, to apply the team's labels. When you pass none, the skill offers the team's real labels for you to choose from.
7. **An assignee, optional.** Pass `--assignee <name/email/me>`. The default is unassigned.

Example prompts:

- `/work-items-to-linear docs/features/my-feature/work-items.md --team Engineering`. Creates each item as an issue in the Engineering team's default state, unassigned.
- `/work-items-to-linear docs/features/my-feature/work-items.md --team ENG --project "Q3 Launch"`. Groups every created issue under the Q3 Launch Project.
- `/work-items-to-linear docs/features/my-feature/work-items.md --team ENG --parent ENG-42 --state "Todo"`. Nests each item as a sub-issue under ENG-42 and places it in the Todo state.

## What you get back

Issues in Linear plus one file change on disk:

- **One Linear issue per work item** in the target team, created in file order. Each description follows [the slice issue format](../../../han-linear/skills/work-items-to-linear/references/linear-issue-template.md): summary with an inline plan reference, description, references, tests, and acceptance criteria, all passed as Markdown. The issue title is the slice title. The symbolic SYM stays in the source file.
- **Grouping** when you named one: every issue added to a Linear Project, nested as a sub-issue under a parent, or both.
- **The chosen workflow state and labels**, resolved against the team's real configuration. The default is the team's initial state with no labels.
- **Dependencies** recorded as native Linear "blocked by" relations between the created issues.
- **The source `work-items.md` annotated** in place, each published slice heading rewritten from `## <SYM-N> — <title>` to `## <SYM-N> (<LINEAR-ID>) — <title>`. This is the only file the skill writes, and it is what makes a re-run idempotent.

## How to get the most out of it

- **Connect and authorize the Linear MCP server first.** The skill drives Linear entirely through it. Without it, the skill stops at the preflight.
- **Run [`/plan-work-items`](../han-planning/plan-work-items.md) upstream.** This skill publishes a work-items file. It does not produce one. A sharp, dependency-ordered breakdown makes the create step clean.
- **Name the team explicitly.** The team is required. Passing `--team <name>` removes any ambiguity about where the issues land.
- **Let the skill show you the team's real labels and states.** Because it reads the live team, the categorization it offers is the one your team actually uses. You are choosing from real values, not guessing.
- **Review the plan before you confirm.** The skill shows the destination and the full list of issues it is about to create, and waits. This is the moment to catch a wrong team, Project, or parent.
- **Re-run after a partial failure.** Heading annotations make the run idempotent. A re-run skips slices that already carry a Linear identifier and only creates the rest, then completes the dependency relations across the whole file.

## YAGNI (when applicable)

YAGNI does not gate this skill's output. The work-items file is an already-committed decomposition, and this skill publishes it without adding new behavioral commitments or speculative infrastructure. The closest thing to a gate here is the reference-artifact rule: issue descriptions carry the contracts, designs, and standards an implementer needs. They leave out the process artifacts that only record how the plan was reached. That is content hygiene, not YAGNI.

If the plan behind the work items has not been through a YAGNI sweep, run [`/iterative-plan-review`](../han-planning/iterative-plan-review.md) on the plan before you break it into work items. See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

## Cost and latency

The skill dispatches no agents. Its work runs in the conversation context. A few Linear MCP reads preflight the server and resolve the target against the live team. Then format validation runs with evidence-based repair, one create call fires per item, a relation call fires per dependency, and a small batch of reads checks existing identifiers on a resume. The most time-consuming runs are large work-items files, because issue creation is one call per item. The skill is built for a once-per-breakdown cadence, and the heading annotations mean a re-run after an interruption only creates the issues that remain.

## In more detail

The skill walks a short, deterministic process:

0. **Linear MCP preflight.** List teams to confirm the server is connected and authorized. Stop here if it is unavailable. Confirm the workspace when more than one is exposed.
1. **Locate the work-items file.** Read the single `work-items.md` from `/plan-work-items`.
2. **Gather the run options.** Team, Project, parent, state, labels, assignee, taken from the arguments.
3. **Resolve the target against the live team.** Confirm the team, read its workflow states, labels, and members, then resolve the state, labels, assignee, Project (at workspace scope, confirming the team participates), and parent (within the team). Any option that cannot be resolved becomes a blocking prompt that names the team's real options, and tells a not-found value apart from one that belongs to another team.
4. **Validate the format with evidence-based repair.** Check heading shape, `Depends on` syntax, within-file blockers, no self-block or cycle, references present, and no process artifacts. Propose evidence-backed fixes and give you continue, correct, or stop.
5. **Show the plan for confirmation.** Present the destination and the table of issues to create, and wait for an explicit yes.
6. **Create one issue per slice.** One create call per slice with title, Markdown description, team, state, labels, assignee, parent, and Project. Annotate each slice heading with the returned identifier right after its create. If a create succeeds but the annotation fails, stop and report the orphaned identifier rather than risk a duplicate.
7. **Link dependencies.** After all issues exist, check that every annotated identifier still resolves, then create a native "blocked by" relation from each dependent issue to its blockers.
8. **Report.** The team, the Project and parent, the state, the labels and assignee, every created issue with its identifier and URL, the relations made, and any slices skipped because they already carried an identifier.

## Sources

The skill drives Linear through the Linear MCP server. Each source below is cited because the skill draws specific, named operations from it.

### Linear MCP server

The official Linear MCP server exposes the operations the skill uses: listing teams, reading a team's workflow states, labels, and members, listing Projects, creating and updating issues, setting native "blocked by" relations, and reading an issue to confirm it resolves. The skill calls them directly rather than through a CLI.

URL: https://linear.app/docs/mcp

### Linear's issue model

The discovery-first posture (workflow states and labels are per-team, there is no issue type, grouping is by Project and by sub-issue parent, and dependencies are native issue relations) follows Linear's own issue model.

URL: https://linear.app/docs

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [Choosing a Han plugin](../../choosing-a-han-plugin.md). Why `han-linear` is installed separately from the bundled suite, and what it requires.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule. This skill does not gate on it. Enforcement belongs upstream.
- [`/plan-work-items`](../han-planning/plan-work-items.md). Pair upstream to produce the work-items file this skill publishes.
- [`/work-items-to-jira`](../han-atlassian/work-items-to-jira.md). The Jira sibling that creates tickets instead of Linear issues.
- [`/work-items-to-issues`](../han-github/work-items-to-issues.md). The GitHub sibling that creates issues instead of Linear issues.
- [Slice issue format](../../../han-linear/skills/work-items-to-linear/references/linear-issue-template.md). The per-issue body format and how each slice field maps onto a Linear issue.
- [Work-items file format](../../../han-linear/skills/work-items-to-linear/references/work-items-file-format.md). The source-file shape the skill reads and annotates.
- [Reference artifact inventory](../../../han-linear/skills/work-items-to-linear/references/reference-artifact-inventory.md). The include list, exclude list, and the artifacts that never belong in an issue description.
- [`SKILL.md` for /work-items-to-linear](../../../han-linear/skills/work-items-to-linear/SKILL.md). The internal process definition.
