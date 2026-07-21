# Team Findings: Remove the Untrue Dependency Declarations

<!-- Findings from the review team, recorded as F# entries. Major findings carry the full field set; minor edits are
one-line bullets. The F# counter is shared across both sections, so the content-auditor's later major finding is F8
even though it sits above the earlier minor edits F6 and F7 by severity. -->

## Major findings

### F1: The contributor guide repeats the claims and was missing from the plan

- **Agent:** junior-developer
- **Finding:** The contributor guide states "Every plugin depends on `han-core`" and names the Reporting plugin among
  core-dependents; the sentence is already false for two shipped plugins and becomes false for three more after this
  phase. The spec's surface list did not include it.
- **Resolution:** The contributor guide joined the corrected surfaces, and its generalization gets rewritten rather
  than patched.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Coordinations

### F2: Both front-door pages carry a second untrue claim beyond the dependency line

- **Agent:** junior-developer
- **Finding:** The Reporting and Feedback front-door pages also say their skills dispatch the Core plugin's shared
  reviewers; Reporting dispatches only the Communication plugin's editor and Feedback dispatches nothing.
- **Resolution:** The correction widens beyond the dependency line to the dispatch claims on both pages.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F3: The Linear plugin's declaration fails the same evidence test

- **Agent:** junior-developer
- **Finding:** Reconciling the Linear page while keeping its Core declaration would create a fresh
  docs-versus-declaration contradiction: by the identical evidence test, the Linear plugin's declaration is equally
  decorative, and its own long-form doc says the skill dispatches no agents.
- **Resolution:** The user chose to remove the Linear declaration in the same pass (2026-07-21), gated by the same
  stop-if-real check; the outline gains a note recording the third removal as an evidence-driven addition.
- **Resolved by:** user input
- **Affected decisions:** D2, D4
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Primary Flow; Out of Scope; Coordinations

### F4: The repository map edit is shared-sentence surgery

- **Agent:** junior-developer
- **Finding:** The repository map states the claims inside grouped sentences that also cover plugins keeping the
  dependency; a careless edit leaves the claim half-intact or breaks a true statement.
- **Resolution:** The spec now requires grouped sentences to be edited so kept dependencies stay correctly described,
  with a matching edge-case row.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow; Edge Cases and Failure Modes

### F5: The completion check was not a repeatable acceptance criterion

- **Agent:** junior-developer
- **Finding:** "Verified by searching for the claim" named no search or exclusion, so it would miss the surfaces the
  audit found and could flag the Feedback plugin's legitimate naming-convention examples.
- **Resolution:** The check is specified: search the documentation for the Core plugin's name, review every hit as
  either a true kept-dependency statement or an excluded naming-convention example.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow; Edge Cases and Failure Modes

### F8: The audited surface count is twenty-one across eight files, not seven

- **Agent:** content-auditor
- **Finding:** The enumeration missed fourteen surfaces, including the concepts doc, the versioning doc, the
  dependency how-to guide, the marketplace listing description, several repository-map lines, and the Linear
  manifest's description text.
- **Resolution:** The full audited list is recorded in D3's evidence and drives the work plan; the search-and-review
  step is the acceptance check so future misses cannot hide.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Coordinations

## Minor edits

- F6: "Installs alone" now rests on the two shipped zero-dependency precedents — junior-developer — Primary Flow
- F7: The channels stay unnamed in behavioral prose by the plain-language rule; the reviewer's request to name them is
  met in the decision log's evidence instead — junior-developer — —
</content>
</invoke>
