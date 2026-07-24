# Feature Technical Notes: Plugin-Centric Documentation Reorganization

This file captures mechanics that are load-bearing for the behavioral specification and are not discoverable from the
code repository alone. Behavioral statements live in [../feature-specification.md](../feature-specification.md); this
file is a secondary reference for `plan-implementation` and for a reader who asks "why this mechanic and not another?"

## T1: GitHub renders mermaid fenced blocks natively

- **Context:** The Primary Flow and the Deferred (YAGNI) section both commit to the workflows page's flow diagrams being
  visible to a reader on GitHub with no build step. That commitment is only correct because of how GitHub renders the
  diagrams.
- **Technical detail:** GitHub renders a fenced code block tagged `mermaid` as a diagram directly in the Markdown view.
  Authoring the workflows page's flow diagrams as `mermaid` fenced blocks makes them render on GitHub with no site
  generator, CI step, or publishing pipeline. This is the mechanic that lets the rendered documentation site stay
  deferred: the findability value of the diagrams is available the moment the Markdown is committed.
- **Supports decisions:** D6, D7
- **Driven by findings:** —
- **Referenced in spec:** Primary Flow, Coordinations, Deferred (YAGNI)
