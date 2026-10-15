# Agent Roles (Slots Another Plugin's Agent Can Fill)

## Contents

- What a role is
- How an agent claims a role
- How a skill fills a role
- The roles
- Related rules

**Owned by `han-planning`.** This file is authored here and is not a vendored copy of a shared rule. Do not overwrite it
from another plugin's `references/` folder during a re-sync sweep, and do not treat a difference between it and any
similarly-named file elsewhere as drift to correct.

## What a role is

A role is a named slot on a `han-planning` team list that an agent from another plugin can fill. It lets a planning skill
use a specialist without `han-planning` depending on the plugin that ships it. When that plugin is installed, its agent
fills the role. When it is not, the role stays empty and the skill runs without it.

`han-planning` owns the role names and what each one is for. A plugin that ships an agent says which role the agent
fills. The providing plugin never names `han-planning`'s skills, so renaming or adding a planning skill never breaks it.

## How an agent claims a role

An agent claims a role with one sentence at the end of its frontmatter `description`, in this exact form:

```markdown
Fills the han-planning `test-planning` role.
```

The description is the claim because Claude Code loads every installed agent's description into the session. A skill
reading its team list can see which agents are available and which roles they claim, with no extra lookup. The role name
is in backticks and matches a heading under "The roles" below exactly. A test checks that every claimed role exists here.

## How a skill fills a role

When a team list names a role and the skill selects it, fill it this way:

1. Look through the agents available in this session for any whose description claims the role.
2. If one agent claims it, dispatch that agent by its qualified `plugin:agent` name, exactly as the session lists it.
3. If more than one claims it, dispatch the one whose description best fits the selection reason. It is one candidate,
   counted once against the team's size cap.
4. If none claims it, skip the role and add one line to the team announcement, for example: "Skipped the
   `test-planning` role: no installed agent fills it." This is not an error, and the run continues.

Never dispatch an agent for a role by guessing its name. Use only a name the session lists.

## The roles

### `test-planning`

Plans tests around observable behavior: inputs, outputs, and collaborator interactions, with the test doubles that
isolate them. Select it when a plan or spec commits to behavior that has to be verified, or when a change must preserve
behavior that existing tests pin. Today `han-coding` ships the agent that fills it.

## Related rules

- [`config-rule.md`](./config-rule.md): extra agents a project names join the same pool and use the same skip-with-a-note
  handling.
