# plugin.json Schema Reference

The `.claude-plugin/plugin.json` manifest file defines a Claude Code plugin's metadata and component paths.

## Required Fields

| Field  | Type   | Description                                |
| ------ | ------ | ------------------------------------------ |
| `name` | string | Unique identifier in kebab-case, no spaces |

## Metadata Fields (Optional)

| Field         | Type   | Description                                                                 | Example                                                           |
| ------------- | ------ | --------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `$schema`     | string | JSON Schema URL for editor validation (ignored by Claude Code at load time) | `"https://json.schemastore.org/claude-code-plugin-manifest.json"` |
| `version`     | string | Semver version. If omitted, falls back to git commit SHA.                   | `"2.1.0"`                                                         |
| `displayName` | string | Human-readable name shown in the UI. Not used for namespacing. Requires Claude Code v2.1.143+. | `"Deployment Tools"`                                  |
| `description` | string | Brief explanation of plugin purpose                                         | `"Deployment automation tools"`                                   |
| `defaultEnabled` | boolean | Whether the plugin is enabled by default when installed. Defaults to `true`. Requires Claude Code v2.1.154+. | `false`                                        |
| `author`      | object | Author info with optional `name`, `email`, `url` sub-fields                 | `{"name": "Dev Team", "email": "dev@company.com"}`                |
| `homepage`    | string | Documentation URL                                                           | `"https://docs.example.com"`                                      |
| `repository`  | string | Source code URL                                                             | `"https://github.com/user/plugin"`                                |
| `license`     | string | License identifier                                                          | `"MIT"`, `"Apache-2.0"`                                           |
| `keywords`    | array  | Discovery tags (strings)                                                    | `["deployment", "ci-cd"]`                                         |

## Component Path Fields (Optional)

All paths must be relative to the plugin root and start with `./`. Specifying a custom path **replaces** the default. To keep the default and add more, use an array (e.g. `["./skills/", "./extras/"]`).

| Field          | Type                      | Default scanned path     | Description                                               |
| -------------- | ------------------------- | ------------------------ | --------------------------------------------------------- |
| `skills`       | string \| array           | `skills/`                | Directories containing `<name>/SKILL.md` files            |
| `commands`     | string \| array           | `commands/`              | Flat `.md` skill files or directories                     |
| `agents`       | string \| array           | `agents/`                | Agent definition `.md` files                              |
| `hooks`        | string \| array \| object | —                        | Hook config paths or inline hook object                   |
| `mcpServers`   | string \| array \| object | —                        | MCP config paths or inline MCP object                     |
| `lspServers`   | string \| array \| object | `.lsp.json`              | Language Server Protocol configs                          |
| `monitors`     | string \| array           | `monitors/monitors.json` | Background monitor configurations                         |
| `outputStyles` | string \| array           | `output-styles/`         | Custom output style files/directories                     |
| `themes`       | string \| array           | `themes/`                | Color theme files (JSON with `name`, `base`, `overrides`) |

For `hooks`, `mcpServers`, and `lspServers`, multiple sources are **merged** rather than replaced.

**`monitors` and `themes` are experimental.** The current preferred placement for both is under an `experimental` key, not at the top level:

```json
"experimental": {
  "monitors": "./monitors/monitors.json",
  "themes": "./themes/"
}
```

The bare top-level `monitors` and `themes` keys still load, but `claude plugin validate` warns against them, and `claude plugin validate --strict` (used in CI) treats that warning as an error. Prefer the `experimental.*` form for new plugins. See [monitors](./monitors-json-options.md) and [themes](./themes-json-options.md).

## userConfig

User-configurable values prompted at enable time. Each key is a config option:

| Sub-field     | Required | Type    | Description                                                          |
| ------------- | -------- | ------- | -------------------------------------------------------------------- |
| `type`        | Yes      | string  | One of: `"string"`, `"number"`, `"boolean"`, `"directory"`, `"file"` |
| `title`       | Yes      | string  | Label shown in config dialog                                         |
| `description` | Yes      | string  | Help text shown beneath field                                        |
| `sensitive`   | No       | boolean | Masks input and stores in secure storage instead of `settings.json`  |
| `required`    | No       | boolean | Validation fails when field is empty                                 |
| `default`     | No       | any     | Value used when user provides nothing                                |
| `multiple`    | No       | boolean | `string` type only — allow array of strings                          |
| `min` / `max` | No       | number  | `number` type only — value bounds                                    |

Values are available as `${user_config.KEY}` in MCP/LSP/hook/monitor configs and as `CLAUDE_PLUGIN_OPTION_<KEY>` environment variables in subprocesses. Non-sensitive values are also available in skill/agent content.

## channels

Array of message injection channel declarations (Telegram, Slack, Discord).

| Sub-field    | Required | Type   | Description                                                     |
| ------------ | -------- | ------ | --------------------------------------------------------------- |
| `server`     | Yes      | string | Must match a key in the plugin's `mcpServers`                   |
| `userConfig` | No       | object | Per-channel user config (same schema as top-level `userConfig`) |

## dependencies

Other plugins this plugin requires. Each entry is either a plain plugin name or an object:

```json
"dependencies": [
  "helper-lib",
  { "name": "secrets-vault", "version": "~2.1.0" },
  { "name": "shared-lib", "marketplace": "other-marketplace" }
]
```

| Sub-field     | Required | Type   | Description                                                                                   |
| ------------- | -------- | ------ | --------------------------------------------------------------------------------------------- |
| `name`        | Yes      | string | The dependency's plugin name. Resolved in the same marketplace as this plugin by default.     |
| `version`     | No       | string | Semver range (e.g. `~2.1.0`). When omitted, floats to whatever version the marketplace serves. |
| `marketplace` | No       | string | A different marketplace to resolve from. Blocked unless the installing marketplace allows it.  |

Behavior, in brief: installing a plugin auto-installs its dependencies and reports what it added; enabling a plugin enables its dependencies at the same scope, and a plugin cannot be disabled while another enabled plugin still depends on it. A dependency in another marketplace is refused unless that marketplace appears in the installing marketplace's `allowCrossMarketplaceDependenciesOn` list (see [marketplace.json reference](./marketplace-json-options.md)), and a dependency from a marketplace the user has not added stays unresolved. The full resolution, versioning, and error-handling rules are in the [canonical Claude Code documentation](https://code.claude.com/docs/en/plugin-dependencies).

See also: the [canonical Claude Code plugin-dependencies documentation](https://code.claude.com/docs/en/plugin-dependencies) for a full worked walkthrough of declaring and resolving dependencies, and the [marketplace.json reference](./marketplace-json-options.md) for the cross-marketplace allow-list that governs dependencies declared against another marketplace.

## Environment Variables

Available for substitution in skill/agent content, hook commands, monitor commands, and MCP/LSP server configs:

| Variable                | Description                                                               |
| ----------------------- | ------------------------------------------------------------------------- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install directory. Changes on plugin update.      |
| `${CLAUDE_PLUGIN_DATA}` | Persistent state dir at `~/.claude/plugins/data/{id}/`. Survives updates. |
| `${CLAUDE_PROJECT_DIR}` | Absolute path to the project root of the current session.                 |

Both are also exported as environment variables to hook processes and MCP/LSP server subprocesses.

## Complete Example

```json
{
  "$schema": "https://json.schemastore.org/claude-code-plugin-manifest.json",
  "name": "deployment-tools",
  "version": "1.2.0",
  "description": "Deployment automation and monitoring tools",
  "author": {
    "name": "Dev Team",
    "email": "dev@company.com",
    "url": "https://github.com/company"
  },
  "homepage": "https://docs.example.com/deployment",
  "repository": "https://github.com/company/deployment-tools",
  "license": "MIT",
  "keywords": ["deployment", "ci-cd", "monitoring"],
  "skills": "./custom/skills/",
  "agents": "./agents/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": {
    "deployment": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/deploy-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  },
  "lspServers": "./.lsp.json",
  "monitors": "./monitors.json",
  "userConfig": {
    "api_endpoint": {
      "type": "string",
      "title": "API Endpoint",
      "description": "Your deployment API endpoint",
      "required": true
    },
    "api_token": {
      "type": "string",
      "title": "API Token",
      "description": "Authentication token",
      "sensitive": true
    },
    "timeout": {
      "type": "number",
      "title": "Timeout (seconds)",
      "description": "Request timeout",
      "min": 1,
      "max": 3600,
      "default": 30
    }
  },
  "dependencies": [
    "helper-lib",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

## Official Reference

https://code.claude.com/docs/en/plugins-reference.md#plugin-manifest-schema

## JSON example

available at ../templates/plugin-example.json
