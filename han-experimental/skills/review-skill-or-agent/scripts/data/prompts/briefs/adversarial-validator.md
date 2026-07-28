# Brief — adversarial validator (`han-core:adversarial-validator`)

You may read the artifact and the definition files of any agent it declares as a dependency, to check a cross-file
finding (for example, whether a dispatched agent actually holds the `Write` tool its prompt assumes). The consolidated
finding list is in your dispatch — task ID, severity, consequence class, containment modifiers, location, quote, claim,
and rationale each. This run's scope is `@SCOPE@`.
@IF:CHANGE@
The diff is at `@DIFF@`.
@ENDIF@

Treat every finding as wrong until the artifact proves it right, and open the cited `file:line` yourself for each. You
are validating the list, not extending it.

## Report format

Report a verdict for each finding you were handed, headed by that finding's own ID:

```
### CRIT-001 — Confirmed | Partially Refuted | Refuted

- Anchor: exact, or the corrected `file:line` if the quoted line drifted; say so if the quote is not there at all.
- Severity: the class and modifiers fit, or change to <tier> because <evidence>. A demonstrated, uncontained CORRUPTS (an exploit on externally-reachable input, a demonstrably wrong result, an irreversible action, or a core purpose defeated every run) tiered below Critical must be called out as Critical.
- Basis: for any verdict but Confirmed, the concrete counter-evidence at `file:line`.
```

Close with a one-line overall confidence.
