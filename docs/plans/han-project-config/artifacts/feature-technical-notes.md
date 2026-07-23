# Feature Technical Notes: Project-Local Han Configuration

## T1: Config file schema shape

- **Context:** The Primary Flow and User Interactions sections commit engineers to writing a file with "a structured
  header block for simple settings and named sections for list-shaped overrides." That contract only works if the
  shape is pinned down, and the shape is a new Han-owned convention not discoverable from any existing code.
- **Technical detail:** `.han/config.md` opens with optional YAML frontmatter carrying the simple scalar settings — an
  output-directory key for skill-written markdown deliverables — followed by a markdown body with named sections for
  the list-shaped overrides: an extra-agents section listing agent names (optionally grouped per skill) for
  dispatching skills to add to their candidate pool. Skills load the file through the same inline `!`-probe pattern
  their `## Project Context` blocks already use (for example `cat .han/config.md 2>/dev/null`), so the content is
  spliced into the prompt before the skill's steps run. Exact key names and section headings are finalized during
  implementation planning; the frontmatter-plus-named-sections split is the committed shape.
- **Supports decisions:** D1, D2, D7
- **Driven by findings:** —
- **Referenced in spec:** Primary Flow; User Interactions.
