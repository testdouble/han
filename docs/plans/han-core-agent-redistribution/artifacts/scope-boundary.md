# Scope Boundary: han-core Agent Redistribution

## Work Item

No work item exists. The operator's request in the session on 2026-10-15 is the only boundary this run has. It points
at the research report `docs/research/cross-plugin-config-discovery.md` as the reason for the change.

## Stated Scope

The operator's request, quoted:

> pick up the cross-plugin config work research again. let's roll back the spike, and do a full /plan-a-change against
> the research. i want you to do some analysis on the current agents in han-core, and provide recommendations for where
> each agent should live with justification, along with what role should be named and used by these agents

The area confirmed in the confirmation turn: the 23 agents in `han-core/agents/`, plus everything that names them.
That covers skills in every plugin, other agents, evals, long-form docs, the skills and agents indexes, the agent
placement rule in `CONTRIBUTING.md`, `CLAUDE.md`, plugin manifests, and tests.

## Stated Exclusions

None stated in the request.

## Operator-Stated Scope

Stated in the confirmation turn:

- "let's leave out the startup hook." The research report's option O1, a SessionStart hook in a providing plugin that
  prints a contribution file into the session, is out of scope.
- "everything else looks good." The operator accepted that the plan may add or change plugin dependencies where a
  placement calls for it, and accepted the output folder `docs/plans/han-core-agent-redistribution/`.
- The reverted `test-engineer` spike (commits `1ea9d0c`, `24e3ccd`, `abdb80a`, `3e276b8`, reverted in `2b73305`) is
  evidence, not a decided outcome.

## Direction of Travel

Agents move out of `han-core` toward the plugins whose skills use them, wherever a named role lets a consumer run
without the providing plugin installed. The current placement rule (agents stay in `han-core` unless one skill family
in one plugin dispatches them exclusively) and restructure decision D1 are being revisited, not preserved.

## Visual Material Received

None received

## Record Provenance

Established by `plan-a-change` in this run. No earlier record existed in this folder or beside the research report.
