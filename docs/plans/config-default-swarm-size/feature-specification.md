# Feature Specification: Project-Configured Default Swarm Size

A project can set a default swarm size for Han's sizing-aware skills by adding one `default-swarm-size` setting to the
frontmatter of `.han/config.md`. The setting accepts `small`, `medium`, `large`, or `dynamic`; when it is absent, the
skills behave exactly as they do today, classifying the size themselves.

## Outcome

A project operator writes one line of configuration once. Every sizing-aware Han skill in that project then starts at
the configured swarm size on every run, without the operator passing a size argument each time.

The need is operator-described. Today the only way to hold a project at a chosen band is to pass the size argument on
every single invocation. A project that wants a standing default has no home for it
([D1](artifacts/decision-log.md#trivial-decisions)).

A value of `small`, `medium`, or `large` fixes the band the same way an explicit size argument does today
([D4](artifacts/decision-log.md#d4-a-configured-band-is-forced-exactly-like-an-explicit-size-argument)). A value of
`dynamic`, or no setting at all, leaves the skills classifying the size themselves from the work's signals, which is
today's behavior ([D5](artifacts/decision-log.md#trivial-decisions)). `dynamic` is also accepted as an explicit per-run
size, so a user can ask any single run to auto-classify even when the config fixes a band
([D10](artifacts/decision-log.md#d10-dynamic-is-a-valid-explicit-per-run-size)).

## Actors and Triggers

- **Actors**: the project operator who authors `.han/config.md`, and the eight sizing-aware skills that consume the
  setting: `/architectural-analysis`, `/code-overview`, `/code-review`, `/gap-analysis`, `/iterative-plan-review`,
  `/plan-a-feature`, `/plan-implementation`, and `/research`
  ([D2](artifacts/decision-log.md#d2-the-setting-applies-to-the-eight-sizing-aware-skills)).
- **Triggers**: any run of a sizing-aware skill in a directory whose `.han/config.md` carries the setting, whether
  the user invoked the skill directly or through a wrapper skill.
- **Preconditions**: none beyond the existing config mechanism: the file lives in the directory the skill runs from,
  and a missing file changes nothing.

## Primary Flow

1. The project operator adds `default-swarm-size` with one of the four accepted values to the frontmatter of
   `.han/config.md`, alongside any other settings already there
   ([D1](artifacts/decision-log.md#trivial-decisions)).
2. A user runs a sizing-aware skill without passing a size argument.
3. The skill reads the project config as it does today. It resolves the size through the existing precedence
   chain: explicit user input first, then the config file, then the skill's own classification. The chain's
   intervening sources (the project-discovery surfaces) define no swarm size, so for this setting they never supply a
   value ([D3](artifacts/decision-log.md#d3-the-setting-resolves-through-the-existing-scalar-precedence-chain)).
4. When the config supplies `small`, `medium`, or `large`, the skill skips its signal-based classification and adopts
   that band, exactly as if the user had passed it as the size argument
   ([D4](artifacts/decision-log.md#d4-a-configured-band-is-forced-exactly-like-an-explicit-size-argument)).
5. The skill announces the chosen band with a one-line justification naming the config as the source, in the same
   place it announces an auto-classification or an explicit override today
   ([D6](artifacts/decision-log.md#d6-the-skill-announces-the-config-as-the-size-source)).
6. Team caps, roster selection, iteration depth, and finding calibration scale to the band under each skill's existing
   sizing rules. Specialists are still selected by signal; the configured band sets the bound, not the roster.

## Alternate Flows and States

### Explicit size beats the config

- **Entry condition:** the user passes `small`, `medium`, `large`, or `dynamic` as the skill's size argument, or asks
  for a size conversationally, while the config also carries `default-swarm-size`.
- **Sequence:** the explicit input wins under the precedence chain; the config value is passed over silently, since
  nothing about it failed
  ([D3](artifacts/decision-log.md#d3-the-setting-resolves-through-the-existing-scalar-precedence-chain)). An
  unrecognized size argument (a typo like `mediun`) supplies no explicit value: it is treated as trailing context, and
  the chain continues to the config rather than skipping past it
  ([D3](artifacts/decision-log.md#d3-the-setting-resolves-through-the-existing-scalar-precedence-chain)).
- **Exit:** the skill announces the band as an explicit override, with no mention of the config.

### The user asks one run to auto-classify

- **Entry condition:** the config fixes a band, and the user passes `dynamic` as the size argument or asks
  conversationally for auto-classification.
- **Sequence:** the explicit `dynamic` wins over the configured band, and the skill classifies the size itself from
  the work's signals for that run only
  ([D10](artifacts/decision-log.md#d10-dynamic-is-a-valid-explicit-per-run-size)). The config file is untouched.
- **Exit:** the skill announces the auto-classified band with its signal-based justification.

### The config says `dynamic`

- **Entry condition:** the config carries `default-swarm-size: dynamic`.
- **Sequence:** the skill classifies the size itself from the work's signals, exactly as when the setting is absent
  ([D5](artifacts/decision-log.md#trivial-decisions)).
- **Exit:** the skill announces the auto-classified band with its signal-based justification, with no mention of the
  config.

### The value cannot be used

- **Entry condition:** the setting is present but its value is blank or is not one of the four accepted values.
- **Sequence:** the skill ignores the value with the existing one-line degradation note naming what was ignored and
  why, and falls through the precedence chain to its own classification
  ([D7](artifacts/decision-log.md#d7-an-unusable-value-degrades-with-the-existing-one-line-note)). Other recognized
  settings in the same file still apply.
- **Exit:** the run proceeds at the auto-classified size; the run never fails because of the setting.

## Edge Cases and Failure Modes

| Condition                                                                  | Required Behavior                                                                                                                                     |
| -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Value differs only in case or carries surrounding whitespace (for example `Medium`, `" medium "`) | Accepted; values are trimmed, then matched case-insensitively ([D8](artifacts/decision-log.md#trivial-decisions)).                                       |
| Value is not an accepted value (for example `huge`)                        | Ignored with the one-line note; the skill classifies the size itself ([D7](artifacts/decision-log.md#d7-an-unusable-value-degrades-with-the-existing-one-line-note)). |
| Value is blank                                                             | Same degradation: one-line note, fall through to auto-classification.                                                                                   |
| The user passes an unrecognized size argument while the config fixes a band | The argument supplies no explicit size, so the configured band still applies ([D3](artifacts/decision-log.md#d3-the-setting-resolves-through-the-existing-scalar-precedence-chain)). |
| The running skill dispatches no agent swarm                                | The setting is ignored silently, per the existing rule for settings that do not apply to the running skill ([D2](artifacts/decision-log.md#d2-the-setting-applies-to-the-eight-sizing-aware-skills)). |
| The config also carries other settings, one of which is unusable           | Each setting degrades independently; a bad value elsewhere does not affect this one, and the reverse.                                                   |
| Config sets `large` on trivially small work                                | The band is honored as configured; the roster is still signal-selected within the larger cap, so agents whose domain is untouched are still skipped ([D4](artifacts/decision-log.md#d4-a-configured-band-is-forced-exactly-like-an-explicit-size-argument)). |
| Config sets `small` on cross-service or security-sensitive work            | The band is honored as configured, with no escalation; the announcement names the config as the source so the narrowed review depth is visible, and a per-run `dynamic` or larger explicit size is the correction ([D4](artifacts/decision-log.md#d4-a-configured-band-is-forced-exactly-like-an-explicit-size-argument), [D6](artifacts/decision-log.md#d6-the-skill-announces-the-config-as-the-size-source), [D10](artifacts/decision-log.md#d10-dynamic-is-a-valid-explicit-per-run-size)). |

## User Interactions

- **Affordances:** one frontmatter line in `.han/config.md`, authored by hand like the file's existing settings. The
  canonical annotated example in the configuration guide gains the setting, along with a note that one configured band
  applies to all eight sizing-aware skills and scales their agent cost together
  ([D9](artifacts/decision-log.md#d9-the-documentation-surfaces-that-change-with-the-feature)).
- **Feedback:** the skill's existing one-line size announcement names the config as the source when the config decided
  the band ([D6](artifacts/decision-log.md#d6-the-skill-announces-the-config-as-the-size-source)).
- **Error states:** the one-line degradation note is the only error surface; a bad value can never fail a run.

## Coordinations

| Coordinating System                                   | Direction | Interaction                                                                                                        | Ordering / Consistency Requirement                                                                 |
| ----------------------------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| The eight sizing-aware skills                          | outbound  | Each adds the setting to the size resolution it performs before dispatching agents.                                | All eight resolve the same file to the same band under the same precedence and degradation rules; the uniformity comes from defining the setting once in the shared interpretation contract rather than eight independent rules ([D9](artifacts/decision-log.md#d9-the-documentation-surfaces-that-change-with-the-feature)). |
| Wrapper skills that invoke a sizing-aware skill        | inbound   | A wrapper runs the wrapped skill in the same working directory, so the wrapped skill resolves `default-swarm-size` from the same config as a direct invocation. A size the wrapper forwards is explicit input and wins; when it forwards none, the config applies ([D3](artifacts/decision-log.md#d3-the-setting-resolves-through-the-existing-scalar-precedence-chain)). | The wrapper's forwarded size is the only channel by which explicit input reaches the wrapped skill.  |
| The shared config interpretation contract              | outbound  | The contract gains the new setting so every skill interprets it identically; every vendored copy stays identical to the canonical one ([D9](artifacts/decision-log.md#d9-the-documentation-surfaces-that-change-with-the-feature)). | The canonical copy changes first; the vendored copies are re-synced in the same change.               |
| Operator documentation (configuration and sizing guides) | outbound  | The configuration guide's canonical example gains the setting and the cross-skill cost note; the sizing guide's statement that sizing is not project-configurable is revised, its size-override section adds `dynamic` and the unrecognized-argument rule; an ADR records the principle reversal ([D9](artifacts/decision-log.md#d9-the-documentation-surfaces-that-change-with-the-feature)). | The docs and the ADR ship in the same change as the behavior so no surface contradicts another.       |

## Out of Scope

- Changing which specialists are selected, or the caps within each band. The setting picks the band; each skill's
  sizing rules are untouched.
- New size bands beyond `small`, `medium`, and `large`.
- Seeding or writing `.han/config.md` from the plugin side; the operator authors the file, as today.
- Any change to skills that do not dispatch an agent swarm.
- Automatic escalation of a configured band when the work's signals disagree with it; the correction is always an
  explicit per-run size.

## Deferred (YAGNI)

### Per-skill default sizes

- **Why deferred:** evidence test failed. One project-wide default satisfies the stated need; no project has asked for
  a different default per skill (for example, `large` reviews but `small` research swarms).
- **Reopen when:** a project using `default-swarm-size` reports needing different defaults for specific skills.
- **Source:** interview, considered while settling D2.

## Open Items

- **OI-1:** Extend the suite's manual test plan to verify the setting across the eight sizing-aware skills: configured
  band forced and announced with the config as source, per-run `dynamic` override, unusable value degrading with the
  one-line note, and `dynamic`/absence auto-classifying. The prior config feature set the precedent of extending the
  manual test plan alongside the behavior.
  - **Resolves when:** the manual test plan carries the new cases.
  - **Blocks implementation:** No. Verification follows the build.

## Summary

- **Outcome delivered:** one config line sets the default swarm size for every sizing-aware skill in a project;
  `dynamic` (or no setting) preserves auto-classification, and `dynamic` doubles as the per-run escape hatch when a
  band is configured.
- **Primary actors:** the project operator authoring `.han/config.md`; the eight sizing-aware skills.
- **Decisions settled by evidence:** 6, see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 4, see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** han-core:junior-developer, han-core:edge-case-explorer, see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the unrecognized-size-argument rule now falls through to the config instead of
  skipping it; `dynamic` gained its per-run override role; the reversed sizing principle gets an ADR; wrapper-skill
  and small-on-risky-work cases are now explicit, see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
