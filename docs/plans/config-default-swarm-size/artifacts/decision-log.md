# Decision Log: Project-Configured Default Swarm Size

## Trivial decisions

- D1: Setting name, home, values, and need — the setting is a frontmatter key named `default-swarm-size` in
  `.han/config.md`, accepting `small`, `medium`, `large`, or `dynamic`, with `dynamic` as the fallback when the
  setting is absent; the operator-described need is a standing project default that replaces passing the size argument
  on every invocation. — Referenced in spec: Outcome, Primary Flow.
- D5: `dynamic` in the config behaves identically to an absent setting — both leave the skill classifying the size
  itself from the work's signals (considered making `dynamic` a chain-stopping value distinct from absence; rejected
  because no lower source in the precedence chain supplies a size, so the two are behaviorally identical today). —
  Referenced in spec: Outcome, Alternate Flows and States.
- D8: Values are trimmed of surrounding whitespace, then matched case-insensitively (considered exact-match only;
  rejected because the config contract already matches agent names case-insensitively, the file is authored by hand,
  and a case or whitespace mismatch triggering a degradation note would be needless friction). — Referenced in spec:
  Edge Cases and Failure Modes.

## Full decisions

### D2: The setting applies to the eight sizing-aware skills

- **Question:** which skills are "all relevant skills" for a default swarm size?
- **Decision:** the setting applies to every skill that dispatches an agent swarm and classifies its size — the eight
  sizing-aware skills: `/architectural-analysis`, `/code-overview`, `/code-review`, `/gap-analysis`,
  `/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation`, and `/research`. A skill that dispatches no
  swarm ignores the setting silently.
- **Rationale:** the sizing-aware set is already defined and documented as exactly these eight skills; "relevant"
  resolves to that set without inventing a new category. Silent ignore for non-applicable skills is the existing
  contract behavior for settings that do not apply to the running skill.
- **Evidence:** codebase — `docs/sizing.md` (names the eight sizing-aware skills and their bands);
  `han-core/references/config-rule.md` § Degradation ("a setting that does not apply to the running skill: ignore it
  silently").
- **Rejected alternatives:**
  - A per-skill opt-in list in the config naming which skills honor the setting — rejected because one project-wide
    default satisfies the stated need; the per-skill variant is deferred under YAGNI in the spec.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D3, D9
- **Referenced in spec:** Actors and Triggers, Edge Cases and Failure Modes

### D3: The setting resolves through the existing scalar precedence chain

- **Question:** where does the config value sit relative to an explicit size argument and the skill's own
  classification?
- **Decision:** `default-swarm-size` is a scalar setting under the existing precedence chain: explicit user input
  (the size argument or a conversational override) wins first, then `.han/config.md`, then the skill's built-in
  default (auto-classification); the chain's intervening project-discovery sources define no swarm size and so never
  supply a value for this setting. An unrecognized size argument supplies no explicit value — it is treated as
  trailing context, and the chain continues to the config rather than skipping past it. When explicit input wins, the
  config value is passed over silently. A wrapper skill that invokes a sizing-aware skill runs it in the same working
  directory, so the wrapped skill resolves the config itself; a size the wrapper forwards is explicit input, and when
  it forwards none the config applies.
- **Rationale:** the config contract already defines exactly this chain for scalar settings; reusing it means one
  rule governs both existing and new settings. The unrecognized-argument rule follows the chain's own semantics ("the
  first source that supplies a value wins" — a typo supplies nothing), resolving the conflict with the older sizing
  guide wording that sent an unrecognized argument straight to auto-classification.
- **Evidence:** codebase — `han-core/references/config-rule.md` § Precedence and § Degradation;
  `docs/configuration.md` § Precedence; `docs/sizing.md` § Overriding the size (the wording this decision supersedes);
  `han-atlassian/skills/plan-a-feature-to-confluence/SKILL.md` (a shipped wrapper that conditionally forwards the size
  argument).
- **Rejected alternatives:**
  - A dedicated precedence rule for size, separate from the scalar chain — rejected because it would be a second
    rule to keep in sync with no behavioral difference.
  - Letting an unrecognized size argument skip the config and force auto-classification — rejected because a typo
    would silently bypass the project's configured default.
- **Linked technical notes:** —
- **Driven by findings:** F1, F2, F10
- **Dependent decisions:** D4, D7, D10
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes, Coordinations

### D4: A configured band is forced exactly like an explicit size argument

- **Question:** does a configured `small`, `medium`, or `large` force the band, or set a starting default that clear
  signals can still escalate?
- **Decision:** the configured band is forced, exactly as if the user had passed it as the size argument: the skill
  skips signal-based classification, adopts the band, and scales its caps to it. Specialists are still selected by
  signal within the cap, and the configured band never bypasses a team cap. The force applies in both directions —
  a configured `small` is honored without escalation even on cross-service or security-sensitive work, with the
  announcement keeping the narrowed depth visible and a per-run override as the correction.
- **Rationale:** matches the precedence chain's "first source that supplies a value wins" semantics, reuses the
  already-specified override behavior instead of defining a new escalation rule, and avoids the support question
  "why did it run large when I configured small?"
- **Evidence:** user input (chose "force the band" over "escalatable starting default"); codebase —
  `docs/sizing.md` § Overriding the size (the existing override behavior this decision mirrors).
- **Rejected alternatives:**
  - A starting default that strong signals can escalate — rejected by the user; harder to specify and explain, and
    it makes the configured value unreliable.
- **Linked technical notes:** —
- **Driven by findings:** F3
- **Dependent decisions:** D6, D10
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D6: The skill announces the config as the size source

- **Question:** what does the user see when the config decided the band?
- **Decision:** the skill's existing one-line size announcement names the config as the source (in the same spirit
  as the existing "passed via size argument" announcement), in the same place it announces an auto-classification
  today. When the config did not decide the band — explicit override, `dynamic`, or absence — the announcement does
  not mention the config.
- **Rationale:** the sizing design principle is that sizing is transparent and the skill always announces the chosen
  band with its source; a silently config-forced band would make swarm behavior unexplainable to a user who forgot
  the setting exists.
- **Evidence:** codebase — `docs/sizing.md` § Design principles ("Sizing is transparent") and the existing
  "Medium: passed via `$size`" announcement pattern.
- **Rejected alternatives:**
  - Announce nothing when the config supplies the band — rejected because it violates the transparency principle
    and hides why a run dispatched more or fewer agents than expected.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, User Interactions, Edge Cases and Failure Modes

### D7: An unusable value degrades with the existing one-line note

- **Question:** what happens when the setting's value is blank or not one of the four accepted values?
- **Decision:** the skill ignores the value with the existing one-line degradation note naming what was ignored and
  why, and falls through the precedence chain to auto-classification. Other recognized settings in the same file
  still apply, and the run never fails because of the setting.
- **Rationale:** this is the config contract's existing rule for a recognized setting with a blank or unusable
  value; the new setting inherits it rather than defining new failure behavior.
- **Evidence:** codebase — `han-core/references/config-rule.md` § Degradation and the one-line note.
- **Rejected alternatives:**
  - Failing the run or prompting the user to fix the value — rejected because the contract commits to "a bad config
    can never fail a skill run."
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### D9: The documentation surfaces that change with the feature

- **Question:** which documented surfaces must change so no doc contradicts the new behavior?
- **Decision:** these surfaces ship with the behavior: the shared config interpretation contract gains the new
  setting (canonical copy first, every vendored copy re-synced identically in the same change, and the setting is
  defined once there so all eight skills resolve it uniformly); the configuration guide's canonical annotated example
  gains the setting plus a note that one configured band applies to all eight sizing-aware skills and scales their
  agent cost together; the sizing guide's design-principle statement that sizing is "overridable, not configurable"
  is revised, and its size-override section adds `dynamic` as an accepted per-run value and the
  unrecognized-argument fall-through rule; and an ADR records the reversal of the "overridable, not configurable"
  principle.
- **Rationale:** the sizing guide's current text directly contradicts the feature in two places (the design
  principle and the unrecognized-argument rule); leaving either would make the docs wrong on day one. Sizing is
  documented as one of the suite's two foundational mechanics, so reversing its stated principle earns a durable
  decision record, not only a prose edit. The contract and the configuration guide are the two canonical homes the
  config feature already established for schema and operator guidance.
- **Evidence:** codebase — `docs/sizing.md` § Design principles ("Sizing is overridable, not configurable") and
  § Overriding the size; `docs/configuration.md` (the canonical annotated example);
  `han-core/references/config-rule.md` § Schema and the byte-identical vendoring convention in CLAUDE.md; the
  `architectural-decision-record` skill in han-documentation. User input: record the ADR.
- **Rejected alternatives:**
  - Documenting the setting only in the configuration guide and leaving the sizing guide untouched — rejected
    because the sizing guide would then state a principle the suite no longer follows.
  - Prose edit only, no ADR — rejected by the user; a foundational-mechanic reversal deserves a durable record.
- **Linked technical notes:** —
- **Driven by findings:** F1, F6, F9, F13
- **Dependent decisions:** —
- **Referenced in spec:** User Interactions, Coordinations

### D10: `dynamic` is a valid explicit per-run size

- **Question:** how does a user get one auto-classified run when the config fixes a band, without editing the config
  file?
- **Decision:** `dynamic` is accepted as an explicit size — passed as the size argument or asked conversationally —
  meaning "auto-classify this run." As explicit input it wins over a configured band under the precedence chain, for
  that run only. This also gives the `dynamic` token a behavioral job beyond documenting intent in the config.
- **Rationale:** without an escape hatch, every exception to a configured band costs a config-file edit; the size
  argument is the existing per-run channel, and extending its accepted values is strictly simpler than inventing a
  new flag. Accepting `dynamic` per-run also closes the YAGNI question of a fourth config value with no behavioral
  distinction from absence.
- **Evidence:** user input (chose per-run `dynamic` over a conversational-only escape hatch and over dropping the
  token); codebase — `docs/sizing.md` § Overriding the size (the argument channel being extended).
- **Rejected alternatives:**
  - Conversational-only escape hatch — rejected because the argument is the documented, deterministic channel and
    the token already exists in the value set.
  - Dropping `dynamic` from the accepted values entirely — rejected because the operator wants the self-documenting
    config token, and the per-run role gives it behavior.
- **Linked technical notes:** —
- **Driven by findings:** F7, F8
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Alternate Flows and States, Edge Cases and Failure Modes
