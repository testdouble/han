# Feature Specification: {Feature Name}

<!-- One-to-two-sentence summary of what the feature does and the outcome it produces. Behavioral, not technical. -->

<!--
WHAT BELONGS IN THIS FILE

This specification captures WHAT the feature does, for WHOM, and WHY — at a level a
reader who has never opened the codebase can understand. It does NOT capture HOW the
feature is built. Implementation detail belongs in the implementation plan
(see `han.core:plan-implementation`), in the code itself, or — when a mechanic is
load-bearing for a behavior specified here — in the lazily-created
[artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md).

The rule is language-agnostic. The examples below are illustrative, not exhaustive —
the rule applies to any language, framework, or platform.

MAY APPEAR IN THIS FILE:
- Product-level subsystem names — "web app", "backend service", "events processing
  system", "Notification Service". Name roles, not the technology fulfilling the role.
- User-facing UI vocabulary — popover, modal, toast, drawer, page, form, empty state.
- URL paths and API endpoints a user or client actually hits — `/notifications/settings`,
  `GET /api/v2/notifications`.
- Behavioral verbs — publishes, receives, queues, retries, notifies, expires, escalates.
- User-observable states — pending, delivered, failed, expired, dismissed.

MAY NOT APPEAR IN THIS FILE:
- Language or runtime primitives — goroutines, sync.WaitGroup, threads, promises,
  async channels, callbacks.
- File paths or line numbers — e.g., `dispatcher.go:140`.
- Function, class, method, or variable names — e.g., `events.Client.PublishEvent`,
  `Handle()`, `actor_id`.
- Library or protocol mechanics — NATS JetStream ack ordering, VAPID encryption
  details, semaphore bounds.
- Implementation patterns — worker pools, defer/recover, detached goroutines,
  fire-and-forget dispatch.
- Internal environment variables or feature-flag names — unless surfaced as
  user-configurable settings.

Brand names generalize one level up:
- "NATS JetStream"        → "events processing system"
- "PostgreSQL"            → "database"
- "Redis"                 → "cache"

BEFORE / AFTER EXAMPLES (illustrative across languages and platforms):
- Go:         "publishes via events.Client.PublishEvent"          → "publishes the event"
- Rails:      "enqueued via Sidekiq ActiveJob"                    → "enqueued for asynchronous processing"
- Node:       "persisted via Mongoose User.updateOne"             → "persisted to the user record"
- Frontend:   "rendered via a Radix Popover"                      → "rendered as a popover"
- Infra:      "stored in PostgreSQL with row-level locking"       → "persisted with per-record serialization"
- File/line:  "handler at dispatcher.go:140"                      → (remove; restate behaviorally)
- Mobile:     "presented via SwiftUI .sheet(isPresented:)"        → "presented as a modal dialog"

When a load-bearing mechanic (one that changes observable behavior — ordering,
durability, consistency, visibility timing) needs to be named in order to correctly
specify a behavior, state the behavioral consequence in the spec sentence and link
the mechanic to a T# note via an inline `([T#](artifacts/feature-technical-notes.md#t#-slug))`
reference. See the "T# REFERENCES" block below.
-->

<!--
D# AND F# REFERENCES

Decision records live in [artifacts/decision-log.md](artifacts/decision-log.md) and
review-team findings live in [artifacts/team-findings.md](artifacts/team-findings.md).

Inline decision references:
- When a behavior in this file embodies a non-obvious decision, append a parenthetical
  link to the decision in artifacts/decision-log.md, e.g.
  "...with a 72-hour expiration ([D4](artifacts/decision-log.md#d4-invite-expiration-window))."
- Link only non-obvious behaviors — not every sentence. "Non-obvious" means a reader
  would reasonably ask "why this and not something else?"
- Do not inline rationale or rejected alternatives — those belong in artifacts/decision-log.md.
-->

<!--
T# REFERENCES

Technical notes live in [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md).
This file is LAZILY created — it exists only when at least one load-bearing mechanic
was worth capturing. If no T# links appear in this spec, the file was not created.

Inline tech-note references:
- Append `([T#](artifacts/feature-technical-notes.md#t#-slug))` to the specific
  sentence whose correct behavior relies on the captured mechanic — not at the end of
  a section, bullet, or flow step.
- A single sentence may cite multiple notes in one parenthesis: `(…[T2], [T3])`.

Load-bearing consequence rule:
- The spec sentence MUST state the behavioral consequence on its own. The T# link
  supplies only the mechanic behind the consequence. A reader who does not click
  through to the note must still get the behavior right.
- If a reader could misread the behavior by skipping the T# link, the spec sentence
  is underspecified. Fix the sentence — do not lean on the link to carry the behavior.

Tech notes are secondary reading. A reader who understands the spec without them is
reading it correctly. T# exists for plan-implementation and for a reader who asks
"why this mechanic and not another?"
-->

## Outcome

<!-- What does successful use of this feature produce? State in behavioral terms — what the system does, what the user experiences, or what changes in the world. Not "we add a service" — rather, "the system delivers X to Y when Z". -->

## Actors and Triggers

- **Actors** — who or what uses this feature (end users, internal services, scheduled jobs, upstream systems). Name roles, not implementation classes.
- **Triggers** — the conditions that cause the feature to run (user action, event, timer, API call).
- **Preconditions** — what must be true before the feature can run.

## Primary Flow

<!--
Describe the happy path as a numbered sequence of system behaviors and coordinations.
Each step describes WHAT happens, not HOW it is implemented.

Do not name specific functions, files, libraries, language primitives, or
implementation patterns. Reference actors and subsystems by their product-level name.
If a step's correctness depends on an implementation mechanic, state the behavioral
consequence in the step itself and link the mechanic via
`([T#](artifacts/feature-technical-notes.md#t#-slug))`.

Append `([D#](artifacts/decision-log.md#...))` links to non-obvious steps only.
-->

1. ...
2. ...
3. ...

## Alternate Flows and States

<!-- Branches off the primary flow: user cancels, system retries, data is pending, approval is required, etc. Describe each as a named flow with its entry condition, sequence, and exit. -->

### {Alternate Flow Name}

- **Entry condition:** ...
- **Sequence:** ...
- **Exit:** ...

## Edge Cases and Failure Modes

<!-- What the system does when things go wrong: malformed input, missing data, timeouts, partial failures, adversarial input, concurrent access, rollback scenarios. Each entry names the condition and the user- or system-observable behavior that must result. Required behavior is stated in observable terms — not "the handler returns a 500", but "the user sees an error state and the record is left unchanged". -->

| Condition | Required Behavior |
|-----------|-------------------|
| ... | ... |

## User Interactions

<!--
If the feature has a UI or API surface: what affordances exist, what feedback the
user receives, what error states are visible.

Use UI vocabulary (popover, modal, toast, form, drawer, empty state). Do not name
component libraries (MUI Dialog, Radix Popover, Bootstrap Modal, SwiftUI Sheet) —
those are implementation and belong in the implementation plan.

Omit this section if the feature has no direct user surface.
-->

- **Affordances:** ...
- **Feedback:** ...
- **Error states:** ...

## Coordinations

<!--
Interactions between the feature and other subsystems, services, or actors.

Describe WHAT is coordinated and WHAT ordering/consistency is required. Do not name
transport libraries, serialization formats, or broker mechanics. "Events processing
system" is the level of abstraction — not "NATS JetStream publisher group" or
"Kafka consumer group" or "Rails ActionCable channel".
-->

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
|---------------------|-----------|-------------|-----------------------------------|
| ... | inbound / outbound | ... | ... |

## Out of Scope

<!-- What this feature deliberately does not do, and why. Prevents scope creep and clarifies the boundary for reviewers and implementers. -->

- ...
- ...

## Deferred (YAGNI)

<!--
Items considered during specification but deferred under the YAGNI rule
([../../references/yagni-rule.md](../../../references/yagni-rule.md)).

LAZILY CREATED — write this section only if at least one item was deferred. If
nothing qualified, omit the section entirely. Do not write an empty stub.

For each deferred item:
- Item — the behavior, alternate flow, edge case, coordination, or open item that
  was considered.
- Why deferred — which gate failed (evidence test or simpler-version test) and the
  specific reason.
- Reopen when — the concrete trigger that would justify revisiting (a measured
  metric, an incident class, a customer commitment, a dependency landing, a
  regulation taking effect).
- Source — where it was originally proposed (review finding F# ID, agent name,
  conversation context, user request, etc.).
-->

### {item name}
- **Why deferred:** {evidence-test failure or simpler-version replacement, with the specific reason}
- **Reopen when:** {concrete trigger}
- **Source:** {finding ID, agent name, conversation context}

## Open Items

<!-- Questions or concerns the project-manager flagged that could not be resolved during specification. Each entry names what is open, what would resolve it, and whether it blocks implementation. -->

- **OI-1:** ...
  - **Resolves when:** ...
  - **Blocks implementation:** Yes / No — {reason}

## Summary

- **Outcome delivered:** <!-- One sentence -->
- **Primary actors:** <!-- Who or what uses this -->
- **Decisions settled by evidence:** N — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** N — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** <!-- list --> — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** <!-- One or two sentences --> — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** N
<!-- Include the next line ONLY if artifacts/feature-technical-notes.md exists: -->
- **Technical notes:** N — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
