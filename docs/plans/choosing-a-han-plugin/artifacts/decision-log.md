# Decision Log: Choosing a Han Plugin

This file records every decision settled while specifying the "Choosing a Han Plugin" documentation. Behavioral statements live in [../feature-specification.md](../feature-specification.md); this file captures the history, rationale, evidence, and rejected alternatives.

## Trivial decisions

- D2: Page location and name — the standalone page is `docs/choosing-a-han-plugin.md`, matching the plan folder name and the existing top-level decision-doc pattern (`sizing.md`, `yagni.md`, `why-solo-and-small-teams.md`). — Referenced in spec: Primary Flow.
- D8: Page framing and link-up — the standalone page opens with an audience / time-to-read / outcome italic line and its Related Documentation links back to the README first, per the CONTRIBUTING "every long-form doc links up" convention. — Referenced in spec: Primary Flow.
- D10: Voice — the documentation follows `docs/writing-voice.md` (no em-dash, direct second person, plainspoken, no hype, no "just"/"actually"). — Referenced in spec: (applies to all surfaces).

## Full decisions

### D1: Deliverable shape

- **Question:** Should this be a new standalone page, edits to existing front-door docs, or both?
- **Decision:** A new standalone page (`docs/choosing-a-han-plugin.md`) plus targeted edits to the README install section, the Concepts page, and the Quickstart. The README install section already names all three plugins and gives all three commands, so its change is an extension (add the link, the no-GitHub-only correction, the recommendation marker), not a from-scratch rewrite.
- **Rationale:** The "which plugin?" question is both a front-door concern (it belongs where readers first hit install) and a topic deep enough to warrant a single canonical home, mirroring how `why-solo-and-small-teams.md` handles the "is this for me?" question. Weaving it through the front-door docs makes it findable; the standalone page keeps the full explanation in one place. F8 corrected the scope: the README already carries a partial version of this content, so the change extends rather than replaces it, avoiding regression on text that is already correct.
- **Evidence:** user input; `docs/why-solo-and-small-teams.md` (standalone decision-doc pattern linked from README and Concepts); `README.md` install section (lines 29-37, which already name all three plugins, describe each, state the dependency, and give all three commands) and "Which path are you on?" list.
- **Rejected alternatives:**
  - New page only, no front-door edits — rejected because a reader at the install snippet would not discover it.
  - README + Concepts edits only, no standalone page — rejected by the user in favor of a canonical home for the full explanation.
  - From-scratch rewrite of the README install section — rejected per F8; the current text is already mostly correct, so a rewrite risks regression.
- **Linked technical notes:** —
- **Driven by findings:** F8
- **Dependent decisions:** D2, D7
- **Referenced in spec:** Primary Flow

### D3: Recommended default posture

- **Question:** What install posture should the documentation recommend?
- **Decision:** Recommend the full `han` meta-plugin as the default for almost everyone; frame core-only as the deliberate choice for a reader who does not want the GitHub PR skills.
- **Rationale:** Matches the README's existing framing ("Installing `han@han` pulls in the whole suite"). The full suite is the lowest-friction choice; opting out of GitHub is the exception worth a conscious decision.
- **Evidence:** user input; `README.md` line 37 ("Installing `han@han` pulls in the whole suite").
- **Rejected alternatives:**
  - Neutral, present both equally with no default — rejected by the user; a default reduces decision friction for newcomers.
  - Core-only as the lean default — rejected by the user; would steer the majority away from the GitHub skills they likely want.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D6
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D4: Three install commands first-class

- **Question:** How should the documentation treat `han`, `han.core`, and `han.github` as install commands, given that `han.github` alone pulls in core and is functionally the full suite?
- **Decision:** Present all three commands as first-class options, each with an explicit statement of what it installs (including the dependency behavior), while recommending `han` as the default way to ask for the full suite.
- **Rationale:** The user chose to keep all three commands documented as co-equal options rather than collapsing to two. The recommendation (D3) supplies the default without hiding the other commands. The documentation must make clear that `han` and `han.github` land the same skills and agents. F2 narrowed the original "differ only in intent and naming" framing: there is a real visible difference (the installed plugin list shows `han.github` plus `han.core` versus `han`), and `han` is the forward-compatible choice because future suite additions are declared as `han` dependencies. The equivalence is scoped to "which skills and agents land," stated as a current-state fact.
- **Evidence:** user input; `han/.claude-plugin/plugin.json` (`dependencies: ["han.core", "han.github"]`); `han.github/.claude-plugin/plugin.json` (`dependencies: ["han.core"]`); `han.core/.claude-plugin/plugin.json` (no dependencies); official Claude Code plugin-dependencies reference (enabling a plugin enables its dependencies; the install output lists which dependencies were added).
- **Rejected alternatives:**
  - Document only two real choices (core-only vs full via `han`) and discourage installing `han.github` directly — rejected by the user in favor of keeping all three first-class.
  - State that `han` and `han.github` "differ only in intent and naming" — rejected per F2; it conceals the installed-list difference and the forward-compatibility of `han`.
- **Linked technical notes:** —
- **Driven by findings:** F2
- **Dependent decisions:** D5
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D5: Dependency nuance content

- **Question:** How should the documentation explain the `han.github` → `han.core` dependency so readers are not confused about overlap?
- **Decision:** State plainly that installing `han.github` resolves and installs `han.core` too, so it lands the same skills and agents as the full suite, and state explicitly that there is no GitHub-only install.
- **Rationale:** This is the central confusion the issue flags. `han.github` ships only two skills but depends on core, so a reader expecting a "GitHub-only" partial would be wrong. Naming the non-existence of a GitHub-only install pre-empts the misread. F1 confirmed the auto-install behavior is documented runtime behavior, not an assumption, so the claim is safe to state as fact.
- **Evidence:** `han.github/.claude-plugin/plugin.json` (`dependencies: ["han.core"]`); `han.github/skills/` contains only `gh-pr-review` and `update-pr-description`; `han.core` carries all agents and the core skill set; official Claude Code plugin-dependencies reference — "When you install a plugin that declares dependencies, Claude Code resolves and installs them automatically and lists which dependencies were added at the end of the install output" (https://code.claude.com/docs/en/plugin-dependencies).
- **Rejected alternatives:**
  - Leave the dependency implicit and let the reader infer it — rejected; the issue exists precisely because the relationship is non-obvious.
- **Linked technical notes:** —
- **Driven by findings:** F1
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### D6: Decision aid format

- **Question:** How should the standalone page help a reader map their situation to an install choice?
- **Decision:** Include a short, scannable "which one do you need?" decision aid that maps a reader's situation to a recommended install command and structurally marks the recommended default (a "start here" signal on the full `han` option). The dependency explanation appears on the page before the decision aid; the aid is never the first substantive content element. Summarize `han.core` by category with a link to the skills index; name the two `han.github` skills explicitly.
- **Rationale:** A scannable aid serves a reader who wants to act without reading the whole page. Naming two GitHub skills is cheap and concrete; enumerating every core skill would duplicate the skills index and rot as skills change. F4 added the ordering constraint: if the aid precedes the dependency explanation, a scan-to-act reader can run `han.github` under the exact "GitHub-only" misread the page exists to prevent. F6 added the structural recommendation marker: with `han` and `han.github` showing the same "what you get," a reader can't resolve which to pick from names alone, so the recommendation (D3) must be surfaced structurally, not only in prose.
- **Evidence:** `docs/sizing.md` and `docs/why-solo-and-small-teams.md` (tables and scannable bullets as the house pattern); `docs/skills/README.md` (existing canonical skill inventory); `han.github/skills/` (only two skills).
- **Rejected alternatives:**
  - Full per-plugin skill inventory on the page — rejected by the simpler-version test; it duplicates the skills index and creates a second thing to maintain.
  - Decision aid as the lead element on the page — rejected per F4; it lets a reader act before they hold the dependency fact.
  - Recommendation stated only in prose — rejected per F6; a scan-to-act reader comparing two full-suite commands needs a structural signal.
- **Linked technical notes:** —
- **Driven by findings:** F4, F6
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, User Interactions, Out of Scope

### D7: Findability and entry points

- **Question:** How does a reader discover the standalone page from the existing docs?
- **Decision:** Link to the standalone page from six surfaces: the README "Which path are you on?" list (question-form label consistent with the existing entries), the README "Documentation" list, the README install section's own inline prose, the new Concepts split section, the Quickstart's opening frame (before the path list), and the why-solo-and-small-teams "If Han is your fit" callout. The standalone page is canonical for the full explanation; the README install section carries the short version (the three commands, a one-line description of each, the recommendation, and the no-GitHub-only correction) and links to it. The two surfaces do not both carry the long-form dependency explanation.
- **Rationale:** The existing decision docs (`sizing.md`, `yagni.md`, `evidence.md`, `why-solo-and-small-teams.md`) are all reachable from both the README path-picker and the Concepts page. Following that pattern makes the new page discoverable through the same routes readers already use. Designating one canonical home prevents the long content from being duplicated and drifting. F5 added the why-solo entry point — the reader leaving the fit-evaluation doc is the highest-intent install candidate and was previously two hops from install-choice guidance. F9 added the install-section inline link so a reader who scrolls straight to "Installation" still finds the page. F3 put the no-GitHub-only correction on the README itself so a reader who never opens the standalone page is still corrected. F7 defined the README-short vs standalone-canonical content boundary to satisfy the "one canonical source" convention.
- **Evidence:** `README.md` "Which path are you on?" and "Documentation" lists and install section (lines 29-37); `docs/concepts.md` (links to sizing/yagni/evidence/why-solo); `docs/quickstart.md` (opening frame assumes the reader is already installed); `docs/why-solo-and-small-teams.md` ("If Han is your fit" callout routing to Concepts/Quickstart); `CLAUDE.md` convention "One canonical source per concept."
- **Rejected alternatives:**
  - Link only from the README — rejected; readers who enter through Concepts, Quickstart, or why-solo would miss it.
  - Put the no-GitHub-only correction only on the standalone page — rejected per F3; the misread is held at the README before the reader navigates away.
  - Quickstart pointer in "Where to go next" — rejected per F11; a cold-arrival pre-install reader would be told to pick a path before seeing the install question.
- **Linked technical notes:** —
- **Driven by findings:** F3, F5, F7, F9, F11
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, User Interactions, Edge Cases and Failure Modes, Coordinations

### D9: Composability note

- **Question:** Should the documentation address a reader who installed core-only and later wants the GitHub skills?
- **Decision:** Yes — state that a reader can install `han.github` (or `han`) afterward to add the GitHub layer on top of the core they already have.
- **Rationale:** This is a real and predictable reader question that follows directly from the core-only recommendation in D3. Answering it removes a reason to hesitate on the lean choice.
- **Evidence:** the three plugins are independently installable per `marketplace.json`; `han.github` depends on `han.core`, so adding it on top of an existing core install is consistent.
- **Rejected alternatives:**
  - Omit it — rejected; leaving the upgrade path unstated makes core-only feel like a one-way door.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States
