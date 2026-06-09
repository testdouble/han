---
name: work-items-to-linear
description: >
  Turn a work-items.md file (produced by /plan-work-items) into Linear issues, one per
  slice, in a single target Linear team. Use when you want to publish work items as Linear
  issues, create implementation tickets to track in Linear, or push a broken-down plan into
  a Linear team. Requires a configured Linear MCP server and a target team. Reads the team's
  real workflow states, labels, Projects, and members and resolves every option against them
  before creating anything; defaults each issue to the team's initial state, unassigned,
  uncategorized, with no parent or Project unless you ask. Links within-file `Depends on`
  relationships as native Linear "blocked by" relations and annotates the source file so
  re-runs resume cleanly. Does not produce the work-items file itself — use plan-work-items
  first. Does not post to Jira — use work-items-to-jira. Does not post to GitHub — use
  work-items-to-issues.
argument-hint: [path to work-items.md] --team <team> [--project <Linear project>] [--parent <issue id>] [--state <name>] [--label <name> (repeatable)] [--assignee <name/email/me>]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(find *), mcp__plugin_linear_linear__save_issue, mcp__plugin_linear_linear__get_issue, mcp__plugin_linear_linear__list_teams, mcp__plugin_linear_linear__get_team, mcp__plugin_linear_linear__list_issue_statuses, mcp__plugin_linear_linear__list_issue_labels, mcp__plugin_linear_linear__list_users, mcp__plugin_linear_linear__list_projects
---

# Work Items to Linear Issues

Take an already-broken-down `work-items.md` file (produced by `/plan-work-items`) and publish each slice as a Linear issue in a single target team.

The breakdown work — drafting slices, assigning symbolic IDs, specifying dependencies, inventorying references — has already been done upstream. This skill validates the format, confirms the target against the live team, creates one issue per slice through the Linear MCP server, links the within-file dependencies as native "blocked by" relations, and reports.

## Rules

- **Every slice posts into one Linear team.** This skill does not split work across teams or repos. A `work-items.md` that names multiple code repos still produces issues in the single team you name; the repo prose is informational only.
- **Dependencies are within-file only.** Every SYM named in a `Depends on` line must resolve to another slice in the same file. A `Depends on` that names an unknown SYM, names the slice itself, or forms a cycle is a format error to surface for repair, never published.
- **Symbolic-ID prefixes:** accept whatever the input uses. Any uppercase prefix shape is valid (`W-N`, `V2-N`, `EV-N`, ...); the prefix has no effect on team placement.
- **Resolve against the live team before writing.** Read the team's real workflow states, labels, Projects, and members, and resolve every named option against them before creating any issue. Nothing is assigned, categorized, grouped, or moved unless asked.
- **No issue types.** Linear has no issue-type concept. The skill never asks for or sets one. Categorization is via the team's real labels, chosen by the operator.
- **Every slice issue MUST carry the reference artifacts an implementer needs** — API/event contracts, design references, schema docs, runbooks, ADRs, coding standards. Full include/exclude list in [references/reference-artifact-inventory.md](references/reference-artifact-inventory.md).
- **NEVER include process artifacts in issue descriptions.** Excluded: iteration histories, decision logs, review findings, team findings, facilitation summaries, gap analyses, and anything under an `artifacts/` subfolder of the plan that is not a contract or design reference.
- **No image upload or embedding.** Design references are carried as links, not uploaded into Linear. See [references/linear-issue-template.md](references/linear-issue-template.md).

## Process

### 0. Linear MCP preflight (hard requirement)

This skill cannot run without a configured and connected Linear MCP server. Confirm it is reachable by calling `mcp__plugin_linear_linear__list_teams`. If the tool is unavailable, the call errors, or no workspace is accessible, **stop immediately** and tell the operator the skill requires the Linear MCP server to be installed, configured, and authenticated. Do not fall back to any other publishing target.

If the integration exposes more than one Linear workspace, note which are available and confirm which one to use before resolving the team.

### 1. Locate the work-items file

If the path is not provided, ask for it. The input is a single `work-items.md` produced by `/plan-work-items`. Read it. Its format is described in [references/work-items-file-format.md](references/work-items-file-format.md).

### 2. Gather the run options

Read these from the arguments and conversation; do not guess defaults the operator did not ask for:

- **Target team** — `--team <name or key>`. **Required.** If absent, ask for it in Step 3.
- **Project** — `--project <name or ID>`. Optional. Groups every created issue under a Linear Project.
- **Parent** — `--parent <issue id>`. Optional. Nests every created issue as a sub-issue under the named parent.
- **State** — `--state <name>`. Optional; defaults to the team's initial/default workflow state.
- **Labels** — `--label <name>`, repeatable. Optional; resolved against the team's real labels.
- **Assignee** — `--assignee <name/email/me>`. Optional; defaults to unassigned.

### 3. Resolve the target against the live team

Resolve everything concretely now so failures surface before any issue is created. This is a strict, fail-before-write sequence:

- **Team (required).** Confirm the named team with `mcp__plugin_linear_linear__list_teams`. If none is named, ask. If the name matches more than one team, present the matches and ask which one. Do not proceed without exactly one team.
- **Read the team's configuration** with `mcp__plugin_linear_linear__list_issue_statuses`, `mcp__plugin_linear_linear__list_issue_labels`, and `mcp__plugin_linear_linear__list_users`. These reads are independent and may run together.
- **State.** If `--state` was given, match it against the team's real states. The default is the team's initial/default state. If a named state does not exist, present the team's real states and ask.
- **Labels.** If `--label`s were given, match each against the team's labels. When categorization was not specified, present the team's real labels and let the operator choose one, several, or none. If the team defines no labels, say so and proceed without categorization. (See plan: D5.)
- **Assignee.** If named, resolve it to a member with `mcp__plugin_linear_linear__list_users`. If unset, leave issues unassigned. The creator is recorded automatically by Linear as the authenticated user; never set it.
- **Project (optional).** Resolve a named Project at **workspace scope** with `mcp__plugin_linear_linear__list_projects` (Projects are not strictly team-scoped), and confirm the target team participates in it.
- **Parent (optional).** Resolve a named parent issue with `mcp__plugin_linear_linear__get_issue` and confirm it belongs to the target team.

For any option that cannot be resolved, do not silently drop or invent it. Distinguish "no such option exists in the team" (present the team's real options for that field) from "it exists but belongs to a different team" (name that team). Ask the operator to pick or correct before continuing.

### 4. Validate the format with evidence-based repair

Check the work-items file against the invariants in [references/work-items-file-format.md](references/work-items-file-format.md) and [references/linear-issue-template.md](references/linear-issue-template.md):

- **Heading shape.** Every slice heading matches `## <SYM-N> — <title>` with an em-dash separator (already-published headings annotated as `## <SYM-N> (<LINEAR-ID>) — <title>` are valid too).
- **`Depends on` line.** Literal bold marker `**Depends on.**`, trailing period, `None.` or comma-separated SYMs.
- **Within-file blockers.** Every SYM named in a `Depends on` line resolves to another slice in this file. A SYM that names the slice itself (self-block) or that forms a dependency cycle with other slices is a format error.
- **References block.** Present whenever the slice consumes an HTTP endpoint, event payload, design frame, ADR, coding standard, or other named artifact.
- **No process artifacts.** No links to iteration histories, decision logs, review findings, team findings, facilitation summaries, gap analyses, or anything under an `artifacts/` subfolder that is not a contract or design reference.

When a check fails, attempt evidence-based repair. Pull evidence from the source `work-items.md`, the parent plan referenced in its intro, the feature spec in the same folder, sibling files in the plan folder, and the relevant repo's ADRs / coding standards / docs:

- **Malformed heading** — propose the corrected shape based on surrounding text. Cite the line number.
- **Missing `Depends on` line** — propose `None.` if no blockers are evident. Cite the absence.
- **Unknown-SYM, self-block, or cycle** — propose the correct in-file SYM (if a typo is evident), or `None.`, or breaking the cycle. Cite the SYM list this file defines.
- **Missing References bullet for an HTTP-consuming or UI slice** — propose the contract section or design frame from the parent plan or feature spec. Cite the anchor.
- **Process-artifact link found** — propose removing the link and, if the slice still needs the context, restating the decision inline with `See plan: D-N`. Cite the include/exclude list.

After validation, report findings in plain language. For each: (1) what is wrong — slice SYM, line reference, failing invariant; (2) the proposed fill — corrected line, new bullet, removed link; (3) the evidence — file path with line number, document section, or named source.

Then give the operator three actions: **Continue with fills** (apply the repairs to the source `work-items.md` and proceed), **Correct the fills** (operator provides the right values; apply those and proceed), or **Stop** (exit without creating issues). If validation passes with no findings, proceed to Step 5.

### 5. Show the plan for confirmation

Creating Linear issues writes to a shared system, so confirm before doing it. Present a summary and wait for an explicit yes:

- **Destination:** the Linear workspace, the target team, the Project (if any), the parent (if any, and that each item becomes a sub-issue under it), the workflow state, the labels (or "none"), and the assignee (or "unassigned").
- **The issues to create:** a table, in file order, of every slice that does not already carry a `(<LINEAR-ID>)` annotation.

| SYM | Title | Depends on |
| --- | --- | --- |
| W-1 | ... | None |
| W-2 | ... | W-1 |

State the total count of issues to create and how many slices are being skipped because they already carry an identifier. Do not create anything until the operator confirms.

### 6. Create one issue per slice

Walk the slices in file order. Skip any slice whose heading already carries a `(<LINEAR-ID>)` annotation so a re-run resumes cleanly. Creation order does not affect correctness, because dependency relations are made in Step 7 once every issue exists. For each remaining slice, call `mcp__plugin_linear_linear__save_issue` with:

- **team** = the resolved team,
- **title** = the slice title (the text after `— ` in the heading),
- **description** = the rendered slice body (Summary, Description, any notes, References, Tests, Acceptance criteria) as Markdown, passed through without conversion,
- **state**, **labels**, **assignee**, **parentId**, **project** = the values resolved in Step 3, applied as chosen,
- **never `blockedBy` here** — relations are made in Step 7.

After each successful create, capture the returned Linear identifier and rewrite that slice's heading in place from `## <SYM-N> — <title>` to `## <SYM-N> (<LINEAR-ID>) — <title>` using Edit, so dependencies resolve and re-runs skip it. Report each creation as `created: <SYM-N> -> <LINEAR-ID>`.

**If a create succeeds but the heading annotation fails**, stop. Report the orphaned Linear identifier so the operator can annotate the heading by hand or delete the issue. Do not continue creating, and do not run the link pass — the file state is inconsistent until the operator resolves it.

### 7. Link dependencies as native relations

Once every slice has a Linear identifier, build the SYM-to-identifier map from the annotated headings. This pass runs over the whole annotated file on every run (including identifiers carried over from a prior run), not only over newly created issues, so a link step interrupted earlier completes on the next run.

Relations are made after all issues exist because a `blocked by` relation needs both endpoints to exist, and file order is not guaranteed to be blocker-first.

- **Stale-annotation check.** For each unique identifier in the map, confirm it resolves to an accessible issue in the team with `mcp__plugin_linear_linear__get_issue`. Surface any that do not resolve to the operator before making any relation; never link to a missing or wrong issue.
- **Make the relations.** For each slice's `**Depends on.**` line (skip `None.`), call `mcp__plugin_linear_linear__save_issue` on the dependent issue with `blockedBy` set to each blocker's identifier. Relations are append-only and de-duplicated, so a re-run does not duplicate them; no per-relation pre-read is needed.

Report each as `linked: <SYM-A>(<LINEAR-A>) blocked_by <SYM-B>(<LINEAR-B>)`.

### 8. Report

Summarize: the team, the Project and parent (if any), the workflow state, the labels and assignee (or "none" / "unassigned"). List every created issue as `<SYM-N> — <LINEAR-ID>` with its URL, the count of native "blocked by" relations created, and any slices skipped because they already carried an identifier. If any step failed, report the error and confirm the source `work-items.md` annotations reflect exactly which issues were created, so the operator can re-run safely.
