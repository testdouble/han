# Decision Log: Choosing a Han Plugin

This file records every decision settled while specifying the "Choosing a Han Plugin" documentation. Behavioral statements live in [../feature-specification.md](../feature-specification.md); this file captures the history, rationale, evidence, and rejected alternatives.

## Trivial decisions

- D2: Page location and name — the standalone page is `docs/choosing-a-han-plugin.md`, matching the plan folder name and the existing top-level decision-doc pattern (`sizing.md`, `yagni.md`, `why-solo-and-small-teams.md`). — Referenced in spec: Primary Flow.
- D8: Page framing and link-up — the standalone page opens with an audience / time-to-read / outcome italic line and its Related Documentation links back to the README first, per the CONTRIBUTING "every long-form doc links up" convention. — Referenced in spec: Primary Flow.
- D10: Voice — the documentation follows `docs/writing-voice.md` (no em-dash, direct second person, plainspoken, no hype, no "just"/"actually"). — Referenced in spec: (applies to all surfaces).

## Full decisions

### D1: Deliverable shape

- **Question:** Should this be a new standalone page, edits to existing front-door docs, or both?
- **Decision:** A new standalone page (`docs/choosing-a-han-plugin.md`) plus substantial rewrites to the README install section, the Concepts page, and the Quickstart.
- **Rationale:** The "which plugin?" question is both a front-door concern (it belongs where readers first hit install) and a topic deep enough to warrant a single canonical home, mirroring how `why-solo-and-small-teams.md` handles the "is this for me?" question. Weaving it through the front-door docs makes it findable; the standalone page keeps the full explanation in one place.
- **Evidence:** user input; `docs/why-solo-and-small-teams.md` (standalone decision-doc pattern linked from README and Concepts); `README.md` install section and "Which path are you on?" list.
- **Rejected alternatives:**
  - New page only, no front-door edits — rejected because a reader at the install snippet would not discover it.
  - README + Concepts edits only, no standalone page — rejected by the user in favor of a canonical home for the full explanation.
- **Linked technical notes:** —
- **Driven by findings:** —
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
- **Rationale:** The user chose to keep all three commands documented as co-equal options rather than collapsing to two. The recommendation (D3) supplies the default without hiding the other commands. The documentation must make clear that `han` and `han.github` both result in the full suite, differing only in intent and naming.
- **Evidence:** user input; `han/.claude-plugin/plugin.json` (`dependencies: ["han.core", "han.github"]`); `han.github/.claude-plugin/plugin.json` (`dependencies: ["han.core"]`); `han.core/.claude-plugin/plugin.json` (no dependencies).
- **Rejected alternatives:**
  - Document only two real choices (core-only vs full via `han`) and discourage installing `han.github` directly — rejected by the user in favor of keeping all three first-class.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D5
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D5: Dependency nuance content

- **Question:** How should the documentation explain the `han.github` → `han.core` dependency so readers are not confused about overlap?
- **Decision:** State plainly that installing `han.github` resolves and installs `han.core` too, so it is functionally the full suite, and state explicitly that there is no GitHub-only install.
- **Rationale:** This is the central confusion the issue flags. `han.github` ships only two skills but depends on core, so a reader expecting a "GitHub-only" partial would be wrong. Naming the non-existence of a GitHub-only install pre-empts the misread.
- **Evidence:** `han.github/.claude-plugin/plugin.json` (`dependencies: ["han.core"]`); `han.github/skills/` contains only `gh-pr-review` and `update-pr-description`; `han.core` carries all agents and the core skill set.
- **Rejected alternatives:**
  - Leave the dependency implicit and let the reader infer it — rejected; the issue exists precisely because the relationship is non-obvious.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### D6: Decision aid format

- **Question:** How should the standalone page help a reader map their situation to an install choice?
- **Decision:** Include a short, scannable "which one do you need?" decision aid that maps a reader's situation to a recommended install command. Summarize `han.core` by category with a link to the skills index; name the two `han.github` skills explicitly.
- **Rationale:** A scannable aid serves a reader who wants to act without reading the whole page. Naming two GitHub skills is cheap and concrete; enumerating every core skill would duplicate the skills index and rot as skills change.
- **Evidence:** `docs/sizing.md` and `docs/why-solo-and-small-teams.md` (tables and scannable bullets as the house pattern); `docs/skills/README.md` (existing canonical skill inventory); `han.github/skills/` (only two skills).
- **Rejected alternatives:**
  - Full per-plugin skill inventory on the page — rejected by the simpler-version test; it duplicates the skills index and creates a second thing to maintain.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, User Interactions, Out of Scope

### D7: Findability and entry points

- **Question:** How does a reader discover the standalone page from the existing docs?
- **Decision:** Link to the standalone page from the README "Which path are you on?" list, the README "Documentation" list, the new Concepts split section, and a Quickstart pointer. The standalone page is canonical for the full explanation; the README carries the short version and links to it.
- **Rationale:** The existing decision docs (`sizing.md`, `yagni.md`, `evidence.md`, `why-solo-and-small-teams.md`) are all reachable from both the README path-picker and the Concepts page. Following that pattern makes the new page discoverable through the same routes readers already use. Designating one canonical home prevents the long content from being duplicated and drifting.
- **Evidence:** `README.md` "Which path are you on?" and "Documentation" lists; `docs/concepts.md` (links to sizing/yagni/evidence/why-solo); `CLAUDE.md` convention "One canonical source per concept."
- **Rejected alternatives:**
  - Link only from the README — rejected; readers who enter through Concepts or Quickstart would miss it.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, User Interactions, Edge Cases and Failure Modes

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
