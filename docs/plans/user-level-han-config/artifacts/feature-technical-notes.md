# Feature Technical Notes: Personal Han Configuration

One mechanic is load-bearing for the specification and cannot be found in this repository, so it is captured here. The
behavioral statements live in [../feature-specification.md](../feature-specification.md).

## T1: Locating the Claude Code configuration directory

- **Context:** the Primary Flow commits to finding your personal configuration in your Claude Code configuration
  directory. Whether that file is found at all depends on how the directory is located, and getting it wrong means the
  personal configuration silently never applies for anyone who has moved their configuration directory.
- **Technical detail:** the directory is named by the `CLAUDE_CONFIG_DIR` environment variable when that variable is
  set, and defaults to `~/.claude` when it is not. The two are not interchangeable: on the machine this specification
  was written on, `CLAUDE_CONFIG_DIR` points at `~/.claude-testdouble` while `~/.claude` also exists on disk, so a
  lookup that hardcodes the default reads the wrong directory. Resolution honors the variable first and falls back to
  the default only when the variable is unset.
- **Supports decisions:** D2, D10
- **Driven by findings:** F3
- **Referenced in spec:** Primary Flow
