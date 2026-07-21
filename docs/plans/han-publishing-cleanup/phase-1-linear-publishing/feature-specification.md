# Feature Specification: Publish the Linear Plugin to the Second Channel

The Linear work-item plugin becomes installable from the second install channel, where it is advertised today but
missing, so a new user following the documented setup instructions succeeds instead of hitting an error.

## Outcome

A new user who follows the second channel's setup instructions for the Linear plugin completes the installation and can
run its work-item publishing skill. The listing entry, the plugin's channel manifest, and the second channel's setup
instructions agree, and the installed version equals the version released on the first channel
([D4](artifacts/decision-log.md#trivial-decisions)). The fix ships to users when the current working branch merges to
the default branch, because the second channel serves the repository's default branch
([T1](artifacts/feature-technical-notes.md#t1-second-channel-serves-the-default-branch))
([D2](artifacts/decision-log.md#d2-definition-of-done)). The cleanup's later automated completeness check can only land
green once this listing entry is in place.

## Actors and Triggers

- **Actors** — A new user installing Han's Linear plugin from the second channel; a maintainer verifying the listing
  before ship.
- **Triggers** — The user follows the setup instructions in the project's front-door documentation: register the Han
  marketplace, then install the Linear plugin by name.
- **Preconditions** — The user has the second channel's tooling installed and can reach the repository. The second
  channel must accept a first-time publication of a plugin that was never listed there, not only updates to existing
  listings; the maintainer's verification install proves this rather than assuming it
  ([D2](artifacts/decision-log.md#d2-definition-of-done)).

## Primary Flow

1. The user registers the Han marketplace with the second channel's tooling, per the documented instructions.
2. The user installs the Linear plugin by name from that marketplace.
3. The installation succeeds: the plugin is listed in the channel's storefront listing and carries a complete channel
   manifest, so the channel can resolve it ([D2](artifacts/decision-log.md#d2-definition-of-done)).
4. The user runs the plugin's work-item publishing skill and it works. The observable version check is the installed
   manifest: its stated version equals the version released on the first channel
   ([D4](artifacts/decision-log.md#trivial-decisions)).
5. The plugin works standalone: its skill content references no other plugin, so no companion installation is required
   on a channel that resolves no dependencies
   ([D3](artifacts/decision-log.md#d3-no-companion-install-instruction)). The plugin's own introduction page currently
   overstates its reliance on other plugins; reconciling that page is routed to [OI-2](#open-items).

## Alternate Flows and States

### Maintainer verification before ship

- **Entry condition:** The listing entry and channel manifest exist on the working branch and are about to ship.
- **Sequence:** The maintainer confirms the listing entry conforms to the channel's required entry shape, using sibling
  entries only as a sanity check rather than the correctness standard; confirms the channel manifest's version matches
  the first channel's released version ([D4](artifacts/decision-log.md#trivial-decisions)); performs one real
  end-to-end install following the documented instructions exactly, from a branch state equivalent to what will merge.
  The install starts from an already-registered marketplace in which this plugin was previously absent, so the single
  run proves both that the channel resolves a first-time listing and that existing registrations pick it up, answering
  [OI-1](#open-items).
- **Exit:** All three confirmations pass, and the branch is cleared to carry the fix to the default branch.

### User registered the marketplace before the fix shipped

- **Entry condition:** A user added the Han marketplace while the Linear plugin was still missing from the listing.
- **Sequence:** After the fix reaches the default branch, the user refreshes or re-reads the marketplace and installs
  the Linear plugin by name.
- **Exit:** The installation succeeds. The exact refresh step the channel requires is Open Item
  [OI-1](#open-items).

## Edge Cases and Failure Modes

| Condition                                                                    | Required Behavior                                                                                                          |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| The install is attempted before the fix reaches the default branch           | The user still sees today's not-found error; the spec's outcome is only promised from the merge onward ([T1](artifacts/feature-technical-notes.md#t1-second-channel-serves-the-default-branch)). |
| The channel manifest's version drifts from the first channel's version        | Verification fails and the ship is held until the two versions match; today both channels state the same released version ([D4](artifacts/decision-log.md#trivial-decisions)). |
| The channel refuses a first-time listing and accepts only updates            | The maintainer's verification install surfaces this before ship, and the ship holds until the channel resolves the new entry. |

## User Interactions

- **Affordances:** The front-door documentation's setup instructions for the second channel, which already name the
  Linear plugin as an opt-in install.
- **Feedback:** The channel's tooling confirms a successful installation; the plugin's skill then appears by name.
- **Error states:** Today the same instructions end in a not-found error; after ship, that error no longer occurs for
  this plugin.

## Coordinations

| Coordinating System                  | Direction | Interaction                                                        | Ordering / Consistency Requirement                                    |
| ------------------------------------ | --------- | ------------------------------------------------------------------ | --------------------------------------------------------------------- |
| Second channel's storefront listing  | outbound  | Lists the Linear plugin so the channel's tooling can resolve it    | Entry must be present and shaped like its sibling entries.            |
| Repository default branch            | outbound  | Serves the listing and manifest to every user of the second channel | The fix is user-visible only after merge ([T1](artifacts/feature-technical-notes.md#t1-second-channel-serves-the-default-branch)). |
| First install channel                | inbound   | Supplies the released version the second channel must match         | Versions agree at ship time; both state the same released version.     |

## Out of Scope

- Correcting the other plugins' frozen version numbers on the second channel. That is Phase 3 of the
  [build phase outline](../build-phase-outline.md#phase-3).
- Teaching the release process about all four publishing surfaces (Phase 6) and the automated completeness check
  (Phase 7).
- Publishing the all-in-one bundle to the second channel. The channel does not support bundles; the limitation is
  documented and permanent until the channel changes.
- A hotfix that carries the listing fix to the default branch ahead of the working branch's merge
  ([D2](artifacts/decision-log.md#d2-definition-of-done)).
- Changing any of the Linear plugin's runtime behavior. This phase publishes what already exists; the skill itself is
  untouched.

## Open Items

- **OI-1:** Confirm what an already-registered marketplace user must do, if anything, for the newly listed plugin to
  appear — an explicit refresh command, or automatic pickup on next read.
  - **Resolves when:** The maintainer's end-to-end verification runs from an already-registered marketplace, per the
    maintainer-verification flow, or the channel's documentation answers it first.
  - **Blocks implementation:** No — it shapes the verification script, not the listing change, which already exists.
- **OI-2:** The Linear plugin's introduction page says its skills rely on other plugins; its skill content references
  none. Reconcile the page with the truth so the standalone claim and the documentation agree.
  - **Resolves when:** The page is corrected, or evidence surfaces that the reliance is real. Feeds the cleanup's
    dependency-truth work ([Phase 4 of the outline](../build-phase-outline.md#phase-4)).
  - **Blocks implementation:** No — the listing fix and install verification stand regardless.

## Summary

- **Outcome delivered:** The Linear plugin installs successfully from the second channel, at the current released
  version, once the working branch merges.
- **Primary actors:** A new user on the second channel; a maintainer verifying before ship.
- **Decisions settled by evidence:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, gap-analyzer — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the first-time-publication precondition was made explicit and folded into the
  verification install; the version check was restated as the observable manifest comparison; a contradiction in the
  plugin's own introduction page became OI-2. — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 2
- **Technical notes:** 1 — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
