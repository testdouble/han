# Local Development

Test skill changes locally before pushing to a PR by using your local repo clone as a marketplace source. Changes on your branch are immediately available in any Claude instance on your machine.

## Setup

### 1. Install the git hook

Run this once after cloning:

```bash
./install-hooks.sh
```

This installs a pre-push hook that automatically rebuilds `dist/claude-marketplace/` and `marketplace.json` before each push. If generated files changed, it commits them and asks you to push again so the generated commit is included.

### 2. Open Claude from the repo root

```bash
cd /path/to/han
claude
```

### 3. Remove the remote marketplace (if present)

If you previously installed `testdouble/han` from GitHub, remove it so it doesn't conflict with the local source:

1. Run `/plugin`
2. Switch to the **Marketplaces** tab
3. Select `testdouble/han` and remove it
4. Exit Claude and re-launch it (marketplace changes require a restart)

### 4. Add the local repo as a marketplace

1. Run `/plugin`
2. Switch to the **Marketplaces** tab
3. Select **Add marketplace**
4. Enter `./` as the path
5. Confirm the addition

### 5. Install the plugin you're working on

1. Run `/plugin`
2. Switch to the **Marketplace** tab (singular: this is the plugin browser, not the marketplace config tab)
3. Find and select the plugin you want to test
4. Install it in **user scope** so it's available across all your Claude instances, not just this project

## Workflow

Once installed, your local marketplace points at your working tree. Any changes you make to skill files (`SKILL.md`, references, scripts) are picked up immediately. No reinstall needed. This means you can:

1. Edit a skill on your branch
2. Open (or switch to) any Claude instance
3. Run the skill and see your changes

When you're done testing, remove the local marketplace and re-add the remote `testdouble/han` source to go back to the published versions.

## Quicker alternatives

The local-marketplace setup above is the canonical Han workflow because it mirrors how users install the suite. For quick, throwaway iteration, Claude Code also supports two lighter approaches documented in the official [Create Plugins](https://code.claude.com/docs/en/plugins) guide:

- **`claude --plugin-dir ./han.core`** loads a single plugin directory for one session with no marketplace or install step. Useful for a fast check of one plugin's changes.
- **`/reload-plugins`** reloads skills, agents, hooks, and plugin MCP/LSP servers without restarting. Changes to a `SKILL.md` body are picked up immediately by the running session, but changes to agents, hooks, and MCP servers need `/reload-plugins` (or a restart) to take effect.
