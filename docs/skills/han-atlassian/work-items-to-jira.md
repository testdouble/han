# /work-items-to-jira

Operator documentation for the `/work-items-to-jira` skill in the opt-in `han-atlassian` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-atlassian/skills/work-items-to-jira/SKILL.md`](../../../han-atlassian/skills/work-items-to-jira/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Choosing a Han plugin](../../choosing-a-han-plugin.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Takes a `work-items.md` file produced by [`/plan-work-items`](../han-planning/plan-work-items.md), validates the format, and creates one Jira ticket per work item in a single target project through the Atlassian MCP server.
- **When to use it.** You have a trusted work-items file and you want each item tracked as a Jira ticket an implementer can grab.
- **What you get back.** One Jira ticket per work item in the project you named, dependencies recorded ticket-to-ticket, and the source `work-items.md` annotated with each created ticket key.

## Key concepts

- **One project, not a repo map.** Every work item becomes a ticket in the single Jira project you name. Unlike the GitHub sibling, this skill does not split work across repos. If the source file spans several code repos, the repo prose is informational only; it never changes which project a ticket lands in.
- **The Atlassian MCP server is required.** The skill checks the server is connected before it does any work. If the server is missing or not authenticated, the skill stops. It drives Jira entirely through the MCP server; there is no `gh`-style CLI and no shell-script pipeline.
- **Sensible Jira defaults, all overridable.** Each ticket is created as a **Story**, **unassigned**, in the project's **Backlog**, with the **reporter** taken from the authenticated Atlassian MCP identity. You can override the issue type, set an assignee, name a target column, and parent every ticket under an epic or a story.
- **Parenting is optional, and the parent decides the child type.** Pass `--parent <KEY>` to parent every created ticket. Name an **epic** and each item is a standard issue (Story by default) under the epic. Name a **story** (any standard issue) and each item is a **subtask** under the story, defaulting to the project's subtask issue type. You cannot parent under a subtask. Leave `--parent` out and tickets sit at the project's top level. `--epic <KEY>` is a deprecated alias for `--parent`. If a company-managed Jira project rejects parenting an item under an epic, the skill surfaces the project's legacy "Epic Link" field requirement rather than dropping the parent silently.
- **Within-file dependencies.** Every SYM named in a `Depends on` line must resolve to another slice in the same file. After all tickets exist, the skill records each dependency in the dependent ticket by rewriting its `Depends on` line to the blockers' Jira keys. It also creates a native "is blocked by" link when the configured MCP exposes an issue-link capability.
- **Reference artifacts, not process artifacts.** Every ticket description carries the artifacts an implementer needs: API and event contracts, design references, schema docs, ADRs, coding standards. It never carries the process artifacts that only record how the plan was reached, such as iteration histories, decision logs, or review findings. The full include and exclude lists live in [the reference artifact inventory](../../../han-atlassian/skills/work-items-to-jira/references/reference-artifact-inventory.md).
- **No screenshot embedding.** The GitHub sibling copies PNGs into the target code repo and embeds same-repo URLs. That mechanism is GitHub-specific and is not part of this skill. Design references are carried as links in the ticket; add image attachments in Jira by hand if a ticket needs them.
- **Evidence-based repair.** When a format check fails, the skill proposes a fix backed by a concrete source (a file path with line number, a plan section, an ADR ID) and lets you continue with the fills, correct them, or stop.
- **Idempotent resume.** After a ticket is created, its slice heading in the source file is annotated with the Jira key. A re-run skips already-annotated slices, so a partial run resumes cleanly.

## When to use it

**Invoke when:**

- You have a `work-items.md` file from `/plan-work-items` and you want each item published as a Jira ticket in a project your team tracks.
- You want the items parented under an epic, nested as subtasks under a story, created as a specific issue type, or dropped into a particular board column.
- You want the ticket descriptions to carry the contract, design, and standards links an implementer needs, with the process artifacts left out.

**Do not invoke for:**

- **Producing the work-items file.** Use [`/plan-work-items`](../han-planning/plan-work-items.md) to break a trusted plan into work items first. This skill publishes that file; it does not create it.
- **Posting to GitHub.** Use [`/work-items-to-issues`](../han-github/work-items-to-issues.md) to create GitHub issues instead.
- **Writing the code for an item.** Use [`/tdd`](../han-coding/tdd.md) to implement a work item test-first.

## How to invoke it

Run `/work-items-to-jira` in Claude Code.

The skill ships in the opt-in `han-atlassian` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han-atlassian@han`; it pulls `han-core`, `han-planning`, and `han-coding` along the way. Then make sure the Atlassian MCP server is configured and authenticated. See [Choosing a Han plugin](../../choosing-a-han-plugin.md) for where it sits in the suite.

Give it:

1. **The `work-items.md` path.** The single file produced by `/plan-work-items`. If you do not provide it, the skill asks.
2. **The target project, required.** Pass `--project <KEY>` (for example `ACME`) or `--board <name>`; a board is resolved to its underlying project. If you provide neither, the skill asks before it creates anything.
3. **A parent, optional.** Pass `--parent <KEY>` to parent every created ticket. An **epic** key makes each item a standard issue under the epic; a **story** key makes each item a subtask under the story. `--epic <KEY>` is a deprecated alias.
4. **An issue type, optional.** Pass `--type <name>` to override the default. The default is `Story` at the top level or under an epic, and the project's subtask type under a story. The type must exist in the target project and sit at the right hierarchy level for the parent.
5. **An assignee, optional.** Pass `--assignee <accountId or email>`. The default is unassigned.
6. **A column, optional.** Pass `--column <name>` to transition each ticket into that column after creation. The default is the project's Backlog.

Example prompts:

- `/work-items-to-jira docs/features/my-feature/work-items.md --project ACME`. Creates each item as a Story in the ACME project backlog, unassigned.
- `/work-items-to-jira docs/features/my-feature/work-items.md --project ACME --parent ACME-12`. Parents every created Story under epic ACME-12.
- `/work-items-to-jira docs/features/my-feature/work-items.md --project ACME --parent ACME-34`. When ACME-34 is a story, creates each item as a subtask under it.
- `/work-items-to-jira docs/features/my-feature/work-items.md --project ACME --type Task --column "Selected for Development"`. Creates Tasks and moves each into the named column.

## What you get back

Tickets in Jira plus one file change on disk:

- **One Jira ticket per work item** in the target project, created in dependency order (blockers first). Each description follows [the slice ticket format](../../../han-atlassian/skills/work-items-to-jira/references/jira-ticket-template.md): summary with an inline plan reference, description, references, tests, and acceptance criteria. The ticket summary is the slice title; the symbolic SYM stays in the source file.
- **Parenting** on every ticket when you named a parent: standard issues under an epic, or subtasks under a story.
- **Dependencies** recorded in each dependent ticket as its blockers' Jira keys, plus native "is blocked by" links when the MCP supports them.
- **The chosen placement:** Backlog by default, or the named column applied through a Jira transition.
- **The source `work-items.md` annotated** in place, each published slice heading rewritten from `## <SYM-N> — <title>` to `## <SYM-N> (<KEY>) — <title>`. This is the only file the skill writes, and it is what makes a re-run idempotent.

## How to get the most out of it

- **Configure and authenticate the Atlassian MCP server first.** The skill drives Jira entirely through it. Without it, the skill stops at the preflight.
- **Run [`/plan-work-items`](../han-planning/plan-work-items.md) upstream.** This skill publishes a work-items file; it does not produce one. A sharp, dependency-ordered breakdown makes the create step clean.
- **Name the project explicitly.** The project (or board) is required. Passing `--project <KEY>` removes any ambiguity about where the tickets land.
- **Review the plan before you confirm.** The skill shows the destination and the full list of tickets it is about to create, and waits. This is the moment to catch a wrong project, epic, or issue type.
- **Let the evidence-based repair run.** When a format check fails, the skill proposes a fix with its source. Continue with the fills when they look right, correct them when they do not, or stop and edit the file by hand.
- **Re-run after a partial failure.** Heading annotations make the run idempotent: a re-run skips slices that already carry a Jira key and only creates the rest.

## YAGNI (when applicable)

YAGNI does not gate this skill's output. The work-items file is an already-committed decomposition, and this skill publishes it without adding new behavioral commitments or speculative infrastructure. The closest thing to a gate here is the reference-artifact rule: ticket descriptions carry the contracts, designs, and standards an implementer needs and leave out the process artifacts that only record how the plan was reached. That is content hygiene, not YAGNI.

If the plan behind the work items has not been through a YAGNI sweep, run [`/iterative-plan-review`](../han-planning/iterative-plan-review.md) on the plan before you break it into work items. See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

## Cost and latency

The skill dispatches no agents. Its work runs in the conversation context: a handful of Atlassian MCP calls to preflight and resolve the target, the format validation with evidence-based repair, one `createJiraIssue` call per item, an `editJiraIssue` (and optional native link) per dependency, and an optional transition per ticket when a column is named. The most time-consuming runs are large work-items files, because ticket creation is one call per item. The skill is built for a once-per-breakdown cadence, and the heading annotations mean a re-run after an interruption only creates the tickets that remain.

## In more detail

The skill walks a short, deterministic process:

0. **Atlassian MCP preflight.** Call `getAccessibleAtlassianResources` to confirm the server is connected and get the cloud ID. Stop here if it is unavailable.
1. **Locate the work-items file.** Read the single `work-items.md` from `/plan-work-items`.
2. **Gather the run options.** Project or board, parent, issue type, assignee, column, taken from the arguments.
3. **Resolve the target against Jira.** Confirm the project. Resolve the parent and read its hierarchy level to decide whether children are standard issues (epic parent) or subtasks (story parent). Validate the issue type against the project's metadata at the right hierarchy level. Resolve the assignee account ID. Hold the column for the placement step.
4. **Validate the format with evidence-based repair.** Check heading shape, `Depends on` syntax, within-file blockers, references present, and no process artifacts. Propose evidence-backed fixes and give you continue / correct / stop.
5. **Show the plan for confirmation.** Present the destination and the table of tickets to create, and wait for an explicit yes.
6. **Create one ticket per slice.** `createJiraIssue` with project, the resolved type, summary, description, optional parent (epic or story), optional assignee. Annotate each slice heading with the returned key.
7. **Link dependencies.** Record each blocker as a Jira key in the dependent ticket, and create a native "is blocked by" link when the MCP supports one.
8. **Place tickets in the target column.** Leave them in Backlog by default, or transition each into the named column.
9. **Report.** The project and parent (epic or story), the issue type, the assignee, the column, every created ticket with its key and URL, the dependency links made, and any slices skipped because they already carried a key.

## Sources

The skill drives Jira through the Atlassian MCP server. Each source below is cited because the skill draws specific, named operations from it.

### Atlassian Remote MCP Server

The Atlassian Remote MCP server exposes the named tools the skill's Jira operations use. These include discovering accessible sites and the cloud ID, listing visible projects, reading a project's issue-type metadata, looking up an assignee's account ID, creating and editing issues, and transitioning an issue between statuses. The skill calls them directly rather than through a CLI.

URL: https://www.atlassian.com/platform/remote-mcp-server

### Jira issue types and the backlog

The Story default, the issue-type override validated against project metadata, parenting through the `parent` field (standard issues under an epic, subtasks under a story), and backlog-versus-column placement through workflow transitions follow Jira's own issue model.

URL: https://support.atlassian.com/jira-software-cloud/docs/what-are-issue-types/

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [Choosing a Han plugin](../../choosing-a-han-plugin.md). Why `han-atlassian` is installed separately from the bundled suite, and what it requires.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule. This skill does not gate on it; enforcement belongs upstream.
- [`/plan-work-items`](../han-planning/plan-work-items.md). Pair upstream to produce the work-items file this skill publishes.
- [`/work-items-to-issues`](../han-github/work-items-to-issues.md). The GitHub sibling that creates issues instead of Jira tickets.
- [`/project-documentation-to-confluence`](./project-documentation-to-confluence.md). A sibling `han-atlassian` skill, for generating documentation and publishing it to Confluence.
- [`/markdown-to-confluence`](./markdown-to-confluence.md). A sibling `han-atlassian` skill, for publishing an existing Markdown file to Confluence.
- [Slice ticket format](../../../han-atlassian/skills/work-items-to-jira/references/jira-ticket-template.md). The per-ticket body format and how each slice field maps onto a Jira ticket.
- [Work-items file format](../../../han-atlassian/skills/work-items-to-jira/references/work-items-file-format.md). The source-file shape the skill reads and annotates.
- [Reference artifact inventory](../../../han-atlassian/skills/work-items-to-jira/references/reference-artifact-inventory.md). The include list, exclude list, and the artifacts that never belong in a ticket description.
- [`SKILL.md` for /work-items-to-jira](../../../han-atlassian/skills/work-items-to-jira/SKILL.md). The internal process definition.
