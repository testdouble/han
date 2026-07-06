# Plugin README

Every plugin needs a README.md at its root directory for human readers on GitHub. The README is not loaded by the plugin system. It exists purely for discoverability and onboarding when someone browses the repository.

## The Rules

### Rule: Every plugin must have a root-level README.md

Place a `README.md` in the plugin's root directory (next to `.claude-plugin/`). This file is for human readers browsing the repository on GitHub. It is not loaded by the plugin system and has no effect on skill behavior.

Skill directories must NOT have their own README files. All skill documentation belongs in `SKILL.md` and `references/`. See [Naming Conventions](../han-plugin-builder/skills/guidance/references/skill-building-guidance/naming-conventions.md) for details.

```
han/
  README.md              # Plugin README. For humans on GitHub.
  .claude-plugin/
    plugin.json
  skills/
    investigate/
      SKILL.md            # Skill documentation. Loaded by plugin system.
      references/
        template.md
```

### Rule: Include only entity sections the plugin has

The README may include sections for Skills, Custom Agents, Hooks, MCP, and LSP, but only include sections for entity types the plugin provides. Every plugin has at least one skill, so the Skills section is always present. Don't include empty sections.

**Before (empty sections):**
```markdown
## Skills

- `/brand-messaging` - Brand voice and messaging framework

## Custom Agents

(none)

## Hooks

(none)
```

**After (only relevant sections):**
```markdown
## Skills

- `/brand-messaging` - Brand voice and messaging framework
```

### Rule: List all skills with slash-command syntax

In the Skills section, list every skill using `/skill-name` format with a one-line description. Condense the description from the skill's frontmatter. Keep it shorter than the full frontmatter description but still clear about what the skill does.

```markdown
## Skills

- `/code-review` - Run a full code review on the current branch's changes
- `/investigate` - Evidence-based investigation of issues and bugs
- `/project-discovery` - Discover project attributes and write a static reference
```

### Rule: Add Getting Started for plugins with guided workflows

Include a Getting Started section between the description and the Skills list when skills build on each other's output. For example, one skill might write a reference file that other skills then consume. Number the steps in the recommended order and explain what each step produces and why it matters for subsequent steps.

Single-skill plugins and plugins where all skills are independent skip this section entirely.

**When to include:**
```markdown
# Han Plugin

{description}

## Getting Started        <!-- Skills have dependency chains -->

### 1. Discover Your Project
...

## Skills
```

**When to skip:**
```markdown
# Brand Messaging Plugin

{description}

## Skills                 <!-- Single skill, no dependencies -->
```

### Rule: Skills Reference provides detailed per-skill documentation

After the Installation section, include a Skills Reference section with detailed documentation for each skill. Each entry includes:

1. A heading with the slash-command name and display name.
2. A paragraph description (more detailed than the one-liner in the Skills section).
3. A **Files** line listing `SKILL.md` and any reference files.
4. 2-3 **Example prompts** showing common use cases.

Separate entries with horizontal rules (`---`).

```markdown
## Skills Reference

### `/investigate` - Evidence-based Investigation

Evidence-based investigation of issues, bugs, API calls, integrations, and other
aspects of software development that need a deep dive to find the root cause and
solutions. Use when you need in-depth understanding of problems, a full analysis
of the reasons, and an evidence-based solution with adversarial validation.

**Files:** `SKILL.md`, `references/template.md`

**Example prompts:**
- `/investigate`. *"Why are webhook deliveries failing intermittently?"*
- `/investigate`. *"Users are seeing stale data after updating their profile"*
- `/investigate`. *"The background job queue is backing up during peak hours"*

---

### `/project-discovery` - Project Discovery
...
```

### Rule: Use the template

Follow the structural template at `templates/plugin-readme-template.md`. The template includes HTML comments marking which sections are optional and should be removed when not applicable.

## Summary Checklist

1. Every plugin has a root-level `README.md`. No READMEs inside skill directories.
2. Only include entity sections (Skills, Agents, Hooks, MCP, LSP) that the plugin provides.
3. List all skills with `/skill-name` format and condensed one-line descriptions.
4. Include Getting Started only when skills have dependency chains.
5. Skills Reference has paragraph descriptions, Files lines, and example prompts for each skill.
6. Follow the template at `templates/plugin-readme-template.md`.
