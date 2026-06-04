# marketplace.json Schema Reference

The `.claude-plugin/marketplace.json` file is the registry that Claude Code reads to discover and install plugins from a marketplace.

## Root Object

| Field                                 | Required | Type   | Description                                                             |
| ------------------------------------- | -------- | ------ | ----------------------------------------------------------------------- |
| `name`                                | Yes      | string | Marketplace identifier in kebab-case                                    |
| `owner`                               | Yes      | object | Maintainer info — `name` (required) and `email` (optional)              |
| `plugins`                             | Yes      | array  | Array of plugin entry objects (see below)                               |
| `description`                         | No       | string | Human-readable marketplace description                                  |
| `version`                             | No       | string | Marketplace manifest version                                            |
| `metadata`                            | No       | object | Additional metadata — `pluginRoot`, `description`, `version` sub-fields |
| `allowCrossMarketplaceDependenciesOn` | No       | array  | Other marketplace names this one may declare dependencies on            |

### metadata sub-fields

| Field         | Description                                              |
| ------------- | -------------------------------------------------------- |
| `pluginRoot`  | Base directory prepended to relative plugin source paths |
| `description` | Alternate location for marketplace description           |
| `version`     | Alternate location for marketplace version               |

## Plugin Entry Object

Each item in the `plugins` array:

| Field         | Required | Type             | Description                                                              |
| ------------- | -------- | ---------------- | ------------------------------------------------------------------------ |
| `name`        | Yes      | string           | Plugin identifier in kebab-case                                          |
| `source`      | Yes      | string \| object | Where to fetch the plugin (see Source Variants below)                    |
| `displayName` | No       | string           | Human-readable name shown in the UI; falls back to `name`. Not used for namespacing. Requires Claude Code v2.1.143+. |
| `description` | No       | string           | Plugin description                                                       |
| `version`     | No       | string           | Plugin version (overridden by `plugin.json` if both specify)             |
| `defaultEnabled` | No    | boolean          | Whether the plugin is enabled after install (default `true`). Takes precedence over the same field in `plugin.json`. Requires Claude Code v2.1.154+. |
| `author`      | No       | object           | `name` (required if present) and `email` (optional)                      |
| `homepage`    | No       | string           | Plugin documentation URL                                                 |
| `repository`  | No       | string           | Source code URL                                                          |
| `license`     | No       | string           | SPDX license identifier                                                  |
| `keywords`    | No       | array            | Discovery tags (strings)                                                 |
| `category`    | No       | string           | Plugin category                                                          |
| `tags`        | No       | array            | Additional searchability tags (strings)                                  |
| `strict`      | No       | boolean          | Default `true`. Controls `plugin.json` authority (see Strict Mode below) |
| `skills`      | No       | string \| array  | Custom paths to skill directories                                        |
| `commands`    | No       | string \| array  | Custom paths to flat skill files                                         |
| `agents`      | No       | string \| array  | Custom paths to agent files                                              |
| `hooks`       | No       | string \| object | Hooks config path or inline object                                       |
| `mcpServers`  | No       | string \| object | MCP server config path or inline object                                  |
| `lspServers`  | No       | string \| object | LSP server config path or inline object                                  |

## Source Variants

### 1. Relative Path (string)

```json
{ "source": "./plugins/my-plugin" }
```

- Must start with `./`
- Resolved relative to marketplace root
- Only works with git-based marketplaces, not URL distributions
- Do not use `../` outside the marketplace root

### 2. GitHub Repository

```json
{
  "source": {
    "source": "github",
    "repo": "owner/repo",
    "ref": "v2.0.0",
    "sha": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2"
  }
}
```

| Sub-field | Required | Description                                       |
| --------- | -------- | ------------------------------------------------- |
| `repo`    | Yes      | GitHub repo in `owner/repo` format                |
| `ref`     | No       | Branch or tag (defaults to repo default branch)   |
| `sha`     | No       | Full 40-character commit SHA to pin exact version |

### 3. URL / Non-GitHub Git

```json
{
  "source": {
    "source": "url",
    "url": "https://gitlab.com/team/plugin.git",
    "ref": "main",
    "sha": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2"
  }
}
```

| Sub-field | Required | Description                                                 |
| --------- | -------- | ----------------------------------------------------------- |
| `url`     | Yes      | Full git URL (`https://` or `git@`); `.git` suffix optional |
| `ref`     | No       | Branch or tag (defaults to default branch)                  |
| `sha`     | No       | Full 40-character commit SHA                                |

### 4. Git Subdirectory (Monorepo)

```json
{
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/acme-corp/monorepo.git",
    "path": "tools/claude-plugin",
    "ref": "v2.0.0",
    "sha": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2"
  }
}
```

| Sub-field | Required | Description                                        |
| --------- | -------- | -------------------------------------------------- |
| `url`     | Yes      | Git URL, `owner/repo` GitHub shorthand, or SSH URL |
| `path`    | Yes      | Subdirectory path within the repo                  |
| `ref`     | No       | Branch or tag                                      |
| `sha`     | No       | Full 40-character commit SHA                       |

Uses sparse/partial clone to minimize bandwidth.

### 5. npm Package

```json
{
  "source": {
    "source": "npm",
    "package": "@acme/claude-plugin",
    "version": "^2.0.0",
    "registry": "https://npm.example.com"
  }
}
```

| Sub-field  | Required | Description                                                |
| ---------- | -------- | ---------------------------------------------------------- |
| `package`  | Yes      | Package name or scoped package (e.g. `@acme/plugin`)       |
| `version`  | No       | Version or semver range (e.g. `2.1.0`, `^2.0.0`, `~1.5.0`) |
| `registry` | No       | Custom npm registry URL (defaults to npmjs.org)            |

## Strict Mode

The `strict` field on a plugin entry controls the relationship between `plugin.json` and the marketplace entry:

| Value            | Behavior                                                                                                                                     |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `true` (default) | `plugin.json` is the authority. Marketplace entry may supplement with additional components. Both are merged.                                |
| `false`          | Marketplace entry is the entire definition. Plugin's own `plugin.json` component declarations cause a conflict and the plugin fails to load. |

## Version Resolution

Versions resolve in this order:

1. `version` in the plugin's own `plugin.json`
2. `version` in the marketplace plugin entry
3. Git commit SHA of the plugin's source (for git-based sources)

If both `plugin.json` and the marketplace entry specify a version, `plugin.json` silently wins. Omit version entirely to auto-update on every commit via the commit SHA.

## Reserved Marketplace Names

These names are reserved for official Anthropic use and cannot be used by third-party marketplaces:

- `claude-code-marketplace`
- `claude-code-plugins`
- `claude-plugins-official`
- `anthropic-marketplace`
- `anthropic-plugins`
- `agent-skills`
- `anthropic-agent-skills`
- `knowledge-work-plugins`
- `life-sciences`
- `claude-for-legal`
- `claude-for-financial-services`
- `financial-services-plugins`

Names that impersonate official marketplaces (e.g. `official-claude-plugins` or `anthropic-tools-v2`) are also blocked.

## Official Reference

https://code.claude.com/docs/en/plugin-marketplaces.md

## JSON example

available at ../templates/marketplace-example.json
