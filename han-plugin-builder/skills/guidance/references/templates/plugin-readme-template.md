# {Plugin Name} Plugin

{One-paragraph description of the plugin — what it does, who it helps, and when to use it.}

<!-- Optional: Include Getting Started only if skills have dependency chains
     (e.g., one skill writes a reference file that other skills consume).
     Remove this section entirely for single-skill or independent-skill plugins. -->

## Getting Started

{Explain the recommended order and why it matters. Then list each step:}

### 1. {First Step Name}

{Why this step comes first, what it produces, and what depends on it.}

**Skill:** `/skill-name`

**Example prompts:**
- "Example prompt 1"
- "Example prompt 2"

### 2. {Second Step Name}

{Why this step comes second and how it builds on step 1.}

**Skill:** `/skill-name`

**Example prompts:**
- "Example prompt 1"
- "Example prompt 2"

<!-- Optional: Include Combining Skills in Prompts when the plugin has multiple
     skills that can be chained together in a single prompt. Recommended for
     multi-skill plugins where sequential composition adds value.
     Remove this section entirely for single-skill plugins. -->

### {N}. Combining Skills in Prompts

{2-3 sentences explaining that users can reference multiple skills in a single prompt and Claude will fire them in sequence, with each skill's output feeding context into the next. Tailor the explanation to the plugin's specific skill combinations.}

**Example prompts:**

- "{Example prompt combining two or more skills in a natural sentence.}"
  Triggers `/first-skill` first, then `/second-skill` {brief explanation of the chain}.

- "{Another example prompt combining a different set of skills.}"
  Triggers `/skill-a`, then `/skill-b`, then `/skill-c`.

<!-- End of optional Getting Started section -->

## Skills

- `/skill-name` - One-line description condensed from frontmatter
- `/another-skill` - One-line description condensed from frontmatter

<!-- Optional: Include only if the plugin defines custom agents.
     Remove this section entirely if not applicable. -->

## Custom Agents

- `agent-name` - One-line description of what the agent does and when to use it
- `another-agent` - One-line description

<!-- Optional: Include only if the plugin defines hooks.
     Remove this section entirely if not applicable. -->

## Hooks

- `hook-name` - One-line description of when the hook fires and what it does

<!-- Optional: Include only if the plugin provides MCP server configurations.
     Remove this section entirely if not applicable. -->

## MCP

- `server-name` - One-line description of the MCP server and what it provides

<!-- Optional: Include only if the plugin provides LSP configurations.
     Remove this section entirely if not applicable. -->

## LSP

- `server-name` - One-line description of the LSP server and what it provides

## Installation

Add your marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add your-org/your-marketplace
/plugin install {plugin-name}@your-marketplace
```

## Skills Reference

### `/skill-name` - Skill Display Name

{Paragraph description of the skill — what it does, when to use it, and what it produces. More detail than the one-liner in the Skills section above.}

**Files:** `SKILL.md`, `references/template.md`

**Example prompts:**
- `/skill-name` — "Example prompt showing a common use case"
- `/skill-name` — "Example prompt showing a different use case"
- `/skill-name` — "Example prompt showing an edge case or advanced usage"

---

### `/another-skill` - Another Skill Display Name

{Paragraph description.}

**Files:** `SKILL.md`

**Example prompts:**
- `/another-skill` — "Example prompt 1"
- `/another-skill` — "Example prompt 2"
