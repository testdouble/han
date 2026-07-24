# Plugin Naming

A plugin's `name` is an identifier, not prose. It appears in the `plugin.json` manifest, in every marketplace entry, in
the install command (`/plugin install <name>@<marketplace>`), and as the namespace prefix on every skill and agent the
plugin ships (`<name>:skill`, `subagent_type: "<name>:agent"`). Pick a name that survives all of those uses unchanged.

## Rule: Never put a `.` in a plugin name

Plugin names must be kebab-case: lowercase letters, numbers, and hyphens only. Do not use a dot (`.`) as a separator,
even though it reads naturally as a namespace (`acme.core`, `acme.github`).

A dot in a plugin name breaks tooling:

- **Codex is incompatible with it.** The Codex marketplace format does not accept a dot in a plugin name, so a dotted
  plugin cannot be packaged for or installed through Codex at all.
- **Claude Code is partially incompatible with it.** A dotted name loads in some paths and fails in others. Because the
  plugin name is also the namespace prefix for the plugin's skills and agents, a dot collides with the `name:component`
  separator and with slash-command and dispatch resolution, so behavior is inconsistent across surfaces.

Use a hyphen wherever you would reach for a dot. The hyphen carries the same "this belongs to the `acme` family" reading
without the incompatibility.

**Before (dotted, which breaks Codex and partially breaks Claude Code):**

```
acme.core/
  .claude-plugin/
    plugin.json    # { "name": "acme.core", ... }
```

```json
// dependent plugin.json
"dependencies": ["acme.core"]
```

```
// dispatch and invocation
subagent_type: "acme.core:my-agent"
/acme.core:my-skill
```

**After (hyphenated, which works everywhere):**

```
acme-core/
  .claude-plugin/
    plugin.json    # { "name": "acme-core", ... }
```

```json
// dependent plugin.json
"dependencies": ["acme-core"]
```

```
// dispatch and invocation
subagent_type: "acme-core:my-agent"
/acme-core:my-skill
```

## When renaming an existing plugin off a dotted name

The name is referenced in more places than the manifest. Change all of them together so nothing dangles:

1. The plugin directory name (it must match the `name` field; see
   [Naming Conventions](../skill-building-guidance/naming-conventions.md)).
2. The `name` and `source` in every marketplace entry (`.claude-plugin/marketplace.json`, and any Codex marketplace).
3. The `name` in the plugin's own `plugin.json` (both `.claude-plugin/` and `.codex-plugin/` if present).
4. Every `dependencies` entry in other plugins that depend on it, including the meta-plugin's `dependencies` array.
5. Every namespace prefix in prose and config: `name:skill` invocations, `subagent_type: "name:agent"` dispatches, and
   any `name-*` wildcard references to the plugin family.
6. Doc folders, indexes, and cross-references that mirror the plugin name.

## Summary

1. Plugin names are kebab-case identifiers: lowercase letters, numbers, hyphens. No dots, no spaces, no other
   punctuation.
2. A dot breaks Codex entirely and Claude Code partially, because the name doubles as the skill and agent namespace
   prefix.
3. Renaming off a dotted name is a coordinated change across the directory, every manifest, every dependency array, and
   every namespace reference.
