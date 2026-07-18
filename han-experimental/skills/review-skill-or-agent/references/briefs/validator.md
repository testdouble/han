# Brief — adversarial validator (`han-core:adversarial-validator`)

You may read the artifact and the definition files of any agent it declares as a dependency, to check a cross-file
finding (for example, whether a dispatched agent actually holds the `Write` tool its prompt assumes). The consolidated
finding list is in your dispatch — task ID, severity, consequence class, containment modifiers, location, quote, claim,
and rationale each — with `$scope` and, under change scope, the `$diff` path.

> Treat every finding as wrong until the artifact proves it right. For each finding return three things: a **verdict** —
> Confirmed, Partially Refuted, or Refuted, citing concrete counter-evidence at `file:line` for anything but Confirmed;
> an **anchor check** — open the cited `file:line`, confirm the finding's quoted line is actually there, and return the
> corrected line number if it drifted; and a **severity check** — whether the assigned consequence class and containment
> modifiers fit the defect that survives, not just the tier label, with evidence when they do not; when you reproduce or
> confirm a demonstrated, uncontained consequence (an exploit that fires on externally-reachable input, a demonstrably
> wrong result, an irreversible action, or a core purpose defeated every run) for a finding tiered below Critical, say
> so explicitly, since a demonstrated uncontained CORRUPTS is Critical. You are validating the list, not extending it.
