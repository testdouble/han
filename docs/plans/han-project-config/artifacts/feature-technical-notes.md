# Feature Technical Notes: Project-Local Han Configuration

## T1: Config file schema shape

- **Context:** The Primary Flow and User Interactions sections commit engineers to writing a file with "a structured
  header block for simple settings and named sections for list-shaped overrides." That contract only works if the
  shape is pinned down, and the shape is a new Han-owned convention not discoverable from any existing code.
- **Technical detail:** `.han/config.md` opens with optional YAML frontmatter carrying the simple scalar settings — an
  output-directory key whose value is a base path relative to the project root — followed by a markdown body with a
  named extra-agents section listing agent names as one global list (per-skill grouping is deferred; see the spec's
  Deferred section). Skills load the file through the same inline `!`-probe pattern their `## Project Context` blocks
  already use (for example `cat .han/config.md 2>/dev/null`), resolved from the skill's working directory like the
  existing CLAUDE.md and project-discovery probes, so the content is spliced into the prompt before the skill's steps
  run. Exact key names, section headings, and agent-name matching rules are finalized during implementation planning;
  the frontmatter-plus-named-sections split is the committed shape.
- **Supports decisions:** D1, D2, D5, D7, D14, D15
- **Driven by findings:** F1, F2, F4
- **Referenced in spec:** Primary Flow; User Interactions.
