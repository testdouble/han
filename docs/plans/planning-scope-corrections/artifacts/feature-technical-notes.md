# Feature Technical Notes: Planning Scope Corrections

<!--
Load-bearing mechanics for [../feature-specification.md](../feature-specification.md).
Behavioral statements live there; this file explains why a mechanic the behavior
depends on is the one chosen. Decisions live in [decision-log.md](decision-log.md);
findings live in [team-findings.md](team-findings.md).
-->

## T1: Supplied visual material is reachable on disk

- **Context:** The specification commits to persisting visual material beside the plan and to passing it to every
  dispatched reviewer. Both commitments are only correct because the material a session receives is already reachable
  as a file. Without that, "persist it" would mean asking the operator to re-supply it, and "pass it to reviewers"
  would be impossible.
- **Technical detail:** Material an operator attaches to a session is written to disk by the host at a stable
  per-session path, and every dispatched agent already has a read tool that reads images directly. Persistence is
  therefore a copy from that path into `ui-designs/`, not a re-request, and a reviewer brief can carry file paths that
  the reviewer can open. Two consequences follow for the specification. First, the copy must happen while the session
  still holds the reference, because the per-session path does not outlive the session. Second, when the host has not
  made a piece of supplied material reachable as a file, the copy cannot happen, and the run falls back to the
  single-stop rule and asks the operator to supply the files. That fallback is why the specification commits to a stop
  rather than to guaranteed persistence.
- **Supports decisions:** D15, D17, D18, D20, D25
- **Driven by findings:** F11, F20, F28
- **Referenced in spec:** Actors and Triggers, Primary Flow, Edge Cases and Failure Modes
