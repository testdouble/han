# Decision Log: Publish the Linear Plugin to the Second Channel

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-1-linear-publishing/`, nested beside
  the build phase outline that spawned it (considered a standalone top-level plan folder; rejected because the repo's
  convention is one folder per plan and this work belongs to the han-publishing-cleanup plan). — Referenced in spec:
  none (organizational).

## Full decisions

### D2: Definition of done

- **Question:** The listing fix already exists on the working branch, but users install from the default branch. What
  does "done" mean for this phase?
- **Decision:** Done means the existing listing entry and channel manifest are verified correct, one real end-to-end
  install is validated, and the fix reaches users when the working branch merges to the default branch. No separate
  hotfix ships ahead of the merge.
- **Rationale:** The fix was authored on this branch (commit `25e7bd2`, "feat(han-linear): publish han-linear to the
  Codex marketplace"), so the remaining work is verification and shipping, not authoring. The user chose to ride the
  branch's merge rather than hotfix the default branch.
- **Evidence:** User input (2026-07-21). Branch state: `.agents/plugins/marketplace.json` on `plugin-cleanup` lists
  `han-linear`; `origin/main`'s copy does not. `han-linear/.codex-plugin/plugin.json` exists at version 1.0.2, matching
  `han-linear/.claude-plugin/plugin.json`.
- **Rejected alternatives:**
  - Hotfix the default branch now — rejected because it adds a second shipping motion for a fix that arrives with the
    branch anyway; the user accepted the merge timeline.
  - Listing presence only, no install validation — rejected because the build outline's Phase 1 demo requires a
    working install, not a present listing entry.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** D3
- **Referenced in spec:** Outcome; Primary Flow; Out of Scope

### D3: No companion-install instruction

- **Question:** The second channel resolves no dependencies. Does the Linear plugin's install instruction need a
  companion-install note, the way the Atlassian plugin's does?
- **Decision:** No new companion note. The documented instructions stay as they are, and verification confirms the
  plugin's skill runs standalone.
- **Rationale:** The Atlassian plugin's note exists because its wrapped skills source the shared readability standard
  from the communication plugin. The Linear plugin's skill content references no other plugin.
- **Evidence:** Codebase: `grep -rn "han-core\|han-communication" han-linear/skills/` returns nothing, while
  `han-linear/.claude-plugin/plugin.json` declares a first-channel dependency on `han-core`. README lines 87-89 already
  name `han-linear` as an opt-in install and reserve the companion note for `han-atlassian`.
- **Rejected alternatives:**
  - Add "install han-core alongside" to the instructions — rejected because no skill content sources it; the
    declaration exists only on the first channel, where the channel itself resolves it.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow
