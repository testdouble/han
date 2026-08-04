# Probe Check Result (Work Unit 1)

Shape A loads. The Claude Code skill loader accepts `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` inside a context probe and
expands it correctly, so the fan-out proceeds on Shape A and Shape B is dropped, per `D-2`'s revisit criterion.

The check ran in two halves, because one half cannot be run from inside a session.

## Half one: loader acceptance, observed verbatim

Run on a temporary `allowed-tools: Read` skill carrying the three candidate probe lines, which is the strictest
permission case in the suite. The temporary skill and both fixture files were removed afterward.

Machine state: `CLAUDE_CONFIG_DIR=/Users/riverbailey/.claude-testdouble`, and `~/.claude/` also exists, which is the
machine `T1` describes.

**Case 1: variable set, its file present.** Injected verbatim:

```text
- personal config directory: /Users/riverbailey/.claude-testdouble
- personal .han/config.md: ---
output-directory: docs/probe-check-marker
---

MARKER-CONFIGURED-DIR
- project .han/config.md: (Bash completed with no output)
```

**Case 2: variable set, its file absent, `~/.claude/.han/config.md` present.** Injected verbatim:

```text
- personal config directory: /Users/riverbailey/.claude-testdouble
- personal .han/config.md: (Bash completed with no output)
- project .han/config.md: (Bash completed with no output)
```

Case 2 is the one that proves the mechanic. The default directory held a file containing
`MARKER-DEFAULT-DIR-SHOULD-NOT-APPEAR`, and the personal read came back empty rather than picking it up. A lookup that
hardcoded `~/.claude` would have injected that marker. This is the failure `T1` exists to prevent, and the probe does
not have it.

## Half two: shell semantics for all four cases

Cases 3 and 4 need `CLAUDE_CONFIG_DIR` unset, which a running session cannot do to itself, so the four cases were run
directly against the shell with `env -u CLAUDE_CONFIG_DIR`. Every case exited 0, which is the constraint the earlier
probe incident established.

| Case | `CLAUDE_CONFIG_DIR` | File present at              | Output                 | Exit |
| ---- | ------------------- | ---------------------------- | ---------------------- | ---- |
| 1    | set                 | the configured directory     | `MARKER-CONFIGURED-DIR`| 0    |
| 2    | set                 | the default directory only   | empty                  | 0    |
| 3    | unset               | the default directory        | `MARKER-DEFAULT-DIR`   | 0    |
| 4    | unset               | nowhere                      | empty                  | 0    |

The companion directory probe resolved to `/Users/riverbailey/.claude-testdouble` with the variable set and
`/Users/riverbailey/.claude` with it unset.

## What remains unproven

The loader was observed expanding the variable when it is set. It was not observed taking the `:-` default branch,
because that needs a session started with the variable unset. The shell half covers that branch, and the loader half
proves the loader performs the expansion rather than passing the text through literally, so the residual risk is that
the loader handles `${VAR:-default}` differently from `${VAR}` when the variable is absent.

**Closing it costs one command.** In a session started without `CLAUDE_CONFIG_DIR` set, invoke any Han skill in a
project with no `.han/config.md` and confirm the `personal config directory` line reads `~/.claude` rather than an empty
value or a literal `${CLAUDE_CONFIG_DIR:-$HOME/.claude}`.
