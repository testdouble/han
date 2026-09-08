# Correction Inventory

Work unit 0's output, per
[D-14](implementation-decision-log.md#d-14-the-inventory-is-built-by-the-plan-not-inherited-from-it). This
records the patterns as well as the results, because the patterns are the completeness check and the counts
are only a snapshot.

Built and applied 2026-08-19 on branch `gh-177-han-readability-output-style-fixes`.

## The pattern set

Every pattern runs with lines joined before matching. This repository hand-wraps prose and Prettier preserves
that wrapping, so a sentence routinely spans two lines and a line-oriented search silently misses it. That
defect produced three wrong inventories during planning.

| Class | Patterns |
| ----- | -------- |
| Size reference | `six-point`, `six-criterion`, `six-item`, `six criteria`, `six behaviorally-anchored` |
| Fidelity guarantee | `never whether a required fact appears`, `never whether a required technical fact appears`, `Fidelity outranks readability`, `no required fact is dropped` |
| Positional reference | `criterion 6` |

## The exclusion list

A hit in any of these is correct and stays:

- `docs/plans/` and `docs/research/` — historical records of what the standard used to say.
- `CHANGELOG.md` — a shipped release entry describing the style as it was.
- `han-communication/agents/readability-editor.md` and `han-communication/docs/agents/readability-editor.md` —
  the editor's own separate rubric, which this change does not touch.
- `han-communication/skills/edit-for-readability/SKILL.md` and
  `han-communication/docs/skills/edit-for-readability.md` — the same rubric, referenced by size.
- The two canonical files keep their own count, per
  [D-8](implementation-decision-log.md#d-8-the-source-files-keep-their-own-count-every-quoting-site-drops-it).

## What the sweep changed

| Class | Files | Sites |
| ----- | ----- | ----- |
| Size reference | 28 | 33 |
| Fidelity guarantee, subject the standard | 25 | 26 |
| Positional reference | 7 | 7 |

Thirty files changed in total, counting the two canonical files and one skill that hardcodes the whole check.

## What the sweep deliberately left alone

**Nine fidelity sentences whose subject is the audience frame.** They read "The frame governs how a fact is
said, never whether a required fact appears" and stay true: what can now drop a fact is the reader's stated
request, not the instruction to write for a non-expert. Per
[D-4](implementation-decision-log.md#d-4-the-fidelity-restatement-splits-by-grammatical-subject-not-by-block).
They sit in `automated-test-planning`, `coding-standard`, `readability-guidance`,
`architectural-decision-record`, `iterative-plan-review`, `plan-a-feature`, `plan-a-phased-build`,
`plan-implementation`, and `plan-work-items`.

**One positional reference to criterion 5**, in the rule's escape clause. Criterion 5 did not move and nothing
about it became untrue. The surrounding sentence changed for a different reason.

## Two pre-existing defects repaired in passing

Both sit inside sentences this change was already editing, so leaving them broken was not an option.

1. **A truncated sentence** in `han-planning/skills/iterative-plan-review/SKILL.md` and
   `han-planning/skills/plan-work-items/SKILL.md`. Both read "...never whether a required fact appears.
   separate editor pass, so criterion 6 is the only fact-preservation guard the output has" with the opening
   clause missing. Restored as "This skill runs no separate editor pass".
2. **A duplicated instruction** in `han-reporting/skills/stakeholder-summary/SKILL.md`, predicted by
   [D-5](implementation-decision-log.md#d-5-one-site-takes-a-paragraph-rewrite-rather-than-a-sentence-swap).
   Its lead-in and the block beneath both said to fix every failure. The lead-in now carries only the
   Edit-tool instruction.

## Verification after the sweep

Re-running the pattern set returns hits only in the exclusion list for the size and positional classes. The
fidelity class additionally returns the nine audience-frame sentences, which stay by design, and the two
operator-facing documents whose replacement text still contains the matched phrase.

`npm run lint` passes. `npm test` passes, 80 tests.
