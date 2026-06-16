## ADR to Coding Standard Section Mapping

When converting an ADR into a coding standard, map sections as follows:

| ADR Section | Coding Standard Section |
|---|---|
| Context | Background |
| Decision Drivers | Background (rationale) **and** When to Apply (preconditions) |
| Decision | Coding Standard (each sub-decision becomes a guideline) |
| Consequences (positive) | Introduction > Purpose (rank one as **Primary**, demote others to **Secondary** / **Side effect**) |
| Consequences (negative/neutral) | Background (caveats) **and** When NOT to Apply (cases where the pattern is wrong) |
| "Exception — X" callouts | When to Apply > **Exception** branch (surface at top, not mid-document) |
| Verifiable preconditions (commands, queries, metrics) | When to Apply > **Verification step** |
| Notes / file references | Additional Resources > Project Documentation |

When the source ADR lists rationales coordinately ("X, Y, Z, and W"), do not preserve that flat list in the converted Purpose section. Pick one as primary based on the ADR's Context and Decision Drivers, and demote the rest. The Adoption-Bias Audit (Step 8) will reject coordinately-listed rationales.

For non-ADR documents, extract: context → Background, requirements/goals → Purpose, preconditions → When to Apply, anti-patterns and out-of-scope cases → When NOT to Apply, implementation details → Coding Standard guidelines, references → Additional Resources.
