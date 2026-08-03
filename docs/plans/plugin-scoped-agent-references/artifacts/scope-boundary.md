# Scope Boundary: Plugin-Scoped Agent References

## Work Item

No tracker item exists. The boundary this run has is the operator's own request, typed when invoking
`han-planning:plan-a-feature`, plus two mid-turn instructions in the same session. Recorded from the operator's words,
not from a tracker read.

## Stated Scope

Quoted word for word from the operator's invocation:

> i want to use https://code.claude.com/docs/en/plugins-reference and the `"agents": [ ... ],` plugin config item to
> reduce the han-core plugin size, and specify every agent that needs to be in any plugin. first thing to do is take all
> agents out of han-core, and put them in a han-agents folder. then every plugin that needs a specific agent must
> manually reference the agent in the plugin.json `agents` config entry. a plugin must only reference agents that will
> get called from it's skills. if an agent is only called from one plugin, the agent must live in that plugin's agents
> folder.

Two further operator instructions in the same session, quoted:

> commit and push as you go

> create a draft pr with han-v5.0.0-alpha-1 as the target merge branch

## Stated Exclusions

None stated.

## Operator-Stated Scope

The invocation text above is itself the operator-stated scope; there is no second statement.

## Direction of Travel

Unanswered.

## Visual Material Received

None received.

## Record Provenance

Established by `han-planning:plan-a-feature` in this run. Not inherited from another folder.
