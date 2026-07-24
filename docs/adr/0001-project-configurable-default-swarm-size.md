# Project-Configurable Default Swarm Size

- **Status:** accepted
- **Date Created:** 2026-07-24 00:00
- **Last Updated:** 2026-07-24 00:00

## Context

Sizing is one of the two foundational mechanics of the Han suite. Every skill that dispatches an agent swarm
classifies the work as small, medium, or large, and that band caps the roster and iteration depth. The sizing guide
originally stated a design principle: "Sizing is overridable, not configurable. There is no project-level 'always run
as medium' setting." A user who wanted a different band passed it as the size argument on each invocation.

That principle left a gap operators asked about: a project that wants a standing default band had no home for it, and
the only workaround was passing the size argument on every single run. The suite had meanwhile gained a project-local
configuration file, `.han/config.md`, with an established interpretation contract covering precedence, containment,
and degradation.

## Decision Drivers

- An operator-described need for a standing project default that replaces per-invocation size arguments.
- The config contract already defines scalar precedence (explicit input first, then config, then skill defaults) and
  degradation (a bad config can never fail a run), so a size setting can reuse proven rules instead of inventing new
  ones.
- Sizing transparency: the skill must always announce the chosen band and its source.
- The per-invocation override must stay available so a configured default never traps a single run.

## Considered Options

1. **Keep the principle: overridable, never configurable.**
   - Pros: no new setting to document; per-run classification always reflects the work's signals; no risk of a stale
     project-wide band silently under- or over-provisioning review depth.
   - Cons: the operator need stays unmet; every run in a project that wants a fixed band costs a repeated argument;
     the config file already exists as the natural home for exactly this kind of project default.
2. **A configurable starting default that signals can still escalate.**
   - Pros: adapts when the configured band is wrong for a given change; keeps some signal-based protection on risky
     work.
   - Cons: the configured value becomes unreliable ("why did it run large when I configured small?"); requires a new
     escalation rule with no precedent in the suite; harder to specify, announce, and support.
3. **A configured band forced exactly like an explicit size argument (chosen).**
   - Pros: reuses the already-specified override semantics and the config contract's precedence chain unchanged; the
     behavior is predictable and announced with its source; the per-run escape hatch (`dynamic`) needs no file edit.
   - Cons: reverses a documented design principle; a project-wide `small` is honored without escalation even on
     security-sensitive work, so under-review is possible until the operator corrects the run.

## Decision

We will use **Option 3**: a `default-swarm-size` setting in `.han/config.md` (`small` | `medium` | `large` |
`dynamic`, absent = `dynamic`) that the eight sizing-aware skills adopt exactly as if the user had passed the band as
the size argument. Explicit input always wins, and `dynamic` is also a valid explicit size that forces
auto-classification for one run. This deliberately reverses the "overridable, not configurable" principle because the
operator need is real, the config contract's precedence and degradation rules absorb the setting without new
machinery, and the transparency principle (the band is always announced with its source) keeps the configured default
visible.

## Consequences

**Positive:**

- One config line replaces a per-invocation argument across all eight sizing-aware skills.
- The setting inherits the contract's guarantees: explicit input wins, bad values degrade with a one-line note, and a
  config problem can never fail a run.
- `dynamic` gains a per-run role, so correcting a configured band never requires editing the file.

**Negative:**

- A configured `small` narrows review depth on work whose signals would have escalated it; the announcement naming the
  config as the source is the guard, and a per-run override is the correction.
- One global band scales agent cost across eight differently-scoped skills at once.

**Neutral:**

- The sizing guide's design-principles section now states the revised principle and points here.

## Notes

- Feature specification: [docs/plans/config-default-swarm-size/](../plans/config-default-swarm-size/feature-specification.md)
- Interpretation contract: [han-core/references/config-rule.md](../../han-core/references/config-rule.md)
- Operator guide: [docs/configuration.md](../configuration.md) · [docs/sizing.md](../sizing.md)
