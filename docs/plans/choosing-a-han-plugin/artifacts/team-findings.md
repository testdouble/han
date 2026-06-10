# Team Findings: Choosing a Han Plugin

This file records every finding raised by the review team for the "Choosing a Han Plugin" documentation, and how each was resolved. Behavioral outcomes live in [../feature-specification.md](../feature-specification.md); decisions the findings affected live in [decision-log.md](./decision-log.md).

Review team: `junior-developer`, `information-architect` (size: small).

## Major findings

### F1: Runtime dependency-resolution behavior was assumed, not verified

- **Agent:** junior-developer (JD-007, flagged as decision-blocker)
- **Finding:** The spec's central factual claim — installing `han.github` resolves and installs `han.core` too — was asserted from the manifest's `dependencies` field without citing how the Claude Code runtime treats that field. If the runtime did not auto-install dependencies, the whole "no GitHub-only install" framing would be wrong.
- **Resolution:** Verified against the official Claude Code plugin-dependencies reference. Confirmed: "When you install a plugin that declares dependencies, Claude Code resolves and installs them automatically and lists which dependencies were added at the end of the install output." Enable/disable also cascade ("Enabling a plugin also enables the plugins it depends on"; "disabling a plugin is blocked if another enabled plugin still needs it"). Dependencies resolve within the same marketplace by default. Evidence added to D5.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Changed in spec:** Primary Flow, Coordinations (manifest row)

### F2: "Functionally identical" overclaims the han / han.github equivalence

- **Agent:** junior-developer (JD-001), information-architect (IA-006)
- **Finding:** The spec said installing `han.github` is "functionally the full suite" and the edge-case table said the difference between `han` and `han.github` is "intent and naming." That conceals real differences: the installed plugin list shows different named plugins (`han.github` + `han.core` vs `han`), and `han` is the forward-compatible way to get future suite additions, which would be declared as `han` dependencies.
- **Resolution:** Narrowed the claim throughout to "installs the same skills and agents." Added that the visible difference is which named plugins appear in your installed list, and that `han` is the recommended way to ask for "everything" because future suite additions arrive through its dependencies. Scope of the equivalence is now "which skills and agents land," stated as a current-state fact.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Changed in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### F3: The "no GitHub-only install" correction was committed only to the standalone page

- **Agent:** junior-developer (JD-003)
- **Finding:** The predictable misread (installing `han.github` expecting GitHub-only) is most likely held at the README install section, before the reader ever reaches the standalone page. The spec committed the correction only to the standalone page.
- **Resolution:** The README's short install version now carries the "no GitHub-only install" correction inline, so a reader who reads only the README is corrected before they run a command. The standalone page remains canonical for the full explanation.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Changed in spec:** Primary Flow, User Interactions

### F4: Dependency explanation must precede the decision aid (comprehension)

- **Agent:** information-architect (IA-005, the finding that threatens the stated outcome)
- **Finding:** The spec left page sequencing to implementation. If the decision aid appears before the dependency explanation, a scan-to-act reader can run `han.github` under the exact misread the spec set out to prevent.
- **Resolution:** Promoted the ordering to a structural constraint: the dependency explanation (han.github pulls in core; no GitHub-only install) appears on the standalone page before the decision aid. The decision aid is not the first substantive content element.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Changed in spec:** Primary Flow

### F5: why-solo-and-small-teams.md is a missing entry point

- **Agent:** information-architect (IA-001)
- **Finding:** The reader exiting `why-solo-and-small-teams.md` at "If Han is your fit" is the highest-intent install candidate, but D7's entry-point set routed only through Concepts and Quickstart, forcing a two-hop path to install-choice guidance.
- **Resolution:** Added `why-solo-and-small-teams.md` as a fifth entry point — a direct link from its "If Han is your fit" callout to the standalone page.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Changed in spec:** Primary Flow, User Interactions

### F6: The decision aid must structurally mark the recommended option

- **Agent:** information-architect (IA-006), junior-developer (JD-002)
- **Finding:** D6 committed to a scannable aid but not to surfacing the D3 recommendation structurally. With `han` and `han.github` showing the same "what you get," a scan-to-act reader can't resolve which to pick without dropping back into prose.
- **Resolution:** D6 now requires the decision aid to structurally mark the recommended default (a "start here" / recommended signal on the `han` option), not only state it in prose.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Changed in spec:** Primary Flow, User Interactions

### F7: The README-short vs standalone-canonical content boundary was undefined

- **Agent:** junior-developer (JD-004)
- **Finding:** The spec said the two surfaces "must not duplicate the long content" but never defined the boundary, risking a medium-length duplicate of the dependency explanation on both surfaces and a conflict with CLAUDE.md's "one canonical source per concept."
- **Resolution:** Defined the boundary in Coordinations: the README install section carries the three commands, a one-line description of each, the recommendation, and the no-GitHub-only correction, then links out. The standalone page is canonical for the full split explanation, the dependency mechanics, the composability path, and the decision aid.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Changed in spec:** Coordinations, Out of Scope

### F8: The README rewrite scope overstated the gap from current content

- **Agent:** junior-developer (JD-005)
- **Finding:** The current README install section already names all three plugins, describes each, states the dependency, and gives all three commands. Describing this as a "substantial rewrite" risks churn and regression on content that is already correct.
- **Resolution:** Re-scoped the README change as an extension of the existing section: add the inline link to the standalone page, the explicit no-GitHub-only correction, and the structural recommendation marker — not a from-scratch rewrite. D1 wording adjusted from "substantial rewrites" to "targeted edits" for README and Concepts/Quickstart.
- **Resolved by:** evidence
- **Affected decisions:** D1
- **Changed in spec:** Primary Flow

### F9: The README install commands need their own inline link to the standalone page

- **Agent:** information-architect (IA-002)
- **Finding:** A reader who scrolls straight to "Installation" bypasses the path-picker and Documentation-list links. If the link lives only there, that reader never sees the pointer.
- **Resolution:** The README install section's inline prose carries a direct link to the standalone page, in addition to the path-picker and Documentation-list entries.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Changed in spec:** Primary Flow, User Interactions

## Minor edits

- F10: README path-picker entry must follow the existing question-form label pattern ("Deciding which plugin to install?") and share vocabulary with the page title — information-architect (IA-003) — User Interactions.
- F11: Quickstart pointer must appear in the opening frame (before the path list), not in "Where to go next", so a cold-arrival pre-install reader sees it before being told to pick a path — information-architect (IA-004), junior-developer (JD-006) — Primary Flow, User Interactions.
- F12: Decision-count check — the summary's "6 settled by evidence / 4 by user input" is correct (4 decisions trace to the user's answers: D1, D2, D3, D4; 6 to evidence: D5, D6, D7, D8, D9, D10). No change needed — junior-developer (JD-008) — —.

## Round 2: review of the written documentation

After the documentation itself was written (`docs/choosing-a-han-plugin.md` plus the README, Concepts, Quickstart, and why-solo edits), `information-architect` and `junior-developer` reviewed the real docs for completeness, correctness, consistency, and progressive disclosure. Both confirmed the structure: the dependency fact precedes the decision aid, all six entry points are wired correctly, and no facts contradict each other across the five surfaces. Findings raised and resolved:

### Major (round 2)

- F13: Decision-aid table told readers the GitHub skills "live here" under `han`, contradicting the page's own statement that `han` has no components of its own — information-architect (IA-002), junior-developer (JD-006). Resolved: rephrased the row to "the full suite includes them." Changed in `docs/choosing-a-han-plugin.md` (decision aid).
- F14: `han.core`'s `plugin.json` (and the matching `marketplace.json` entry) described it as providing "PR descriptions" and "PR code reviews," but those two skills (`update-pr-description`, `gh-pr-review`) live in `han.github`, not `han.core`. The manifest contradicted the new docs — junior-developer (JD-001). Resolved by evidence (filesystem listing of `han.core/skills/` vs `han.github/skills/`): removed the two PR capabilities from both manifest descriptions.
- F15: The forward-compatibility claim ("any future addition to Han arrives as a dependency of `han`, so you get it automatically on the next update") was an uncited speculative roadmap promise, flagged YAGNI — junior-developer (JD-002). Resolved: reframed the reason to prefer `han` around the meta-plugin's documented purpose ("means the whole Han suite in one command") rather than a forward-looking guarantee.

### Minor (round 2)

- F16: Em-dash in the decision-aid recommendation cell (`han — start here`) violated the no-em-dash voice rule — information-architect (IA-001). Resolved: changed to `han (start here)`. Also fixed a pre-existing em-dash on `quickstart.md` line 57.
- F17: Concepts "See also" bar omitted the new page while the body linked to it (one-way navigation) — information-architect (IA-003). Resolved: added "Choosing a plugin" to the bar.
- F18: Vocabulary drift — the GitHub skill set was called "GitHub skills", "GitHub-facing skills", and "GitHub PR skills" across surfaces, including within one sentence — information-architect (IA-005). Resolved: standardized on "GitHub PR skills" on the choosing page and in the Concepts packaging section.
- F19: README used "just" ("not just the path"), a banned word — information-architect (IA-004). Resolved: changed to "not only the path."
- F20: Installing section gave no marketplace gloss and no post-install verification signal for a first-time installer — junior-developer (JD-003, JD-004). Resolved: added one sentence explaining what adding the marketplace does and that Claude Code lists what it installed.
- F21: Composability section asserted internal runtime behavior ("Claude Code sees that `han.core` is already present") that was not verified — junior-developer (JD-005). Resolved: reworded to state the outcome (the GitHub layer is added to the core you already installed) without asserting unverified internals.
