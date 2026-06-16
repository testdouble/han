---
paths:
  - "**/skills/**/*.md"
---

# Skill Description Length

Every installed skill's `description` is loaded into context in every conversation, and the harness budgets how much of it Claude actually gets to see. A description that runs too long does not fail loudly — it gets silently truncated or dropped from the listing, and the skill quietly stops triggering as well as it should. This doc sets the length target and explains the two separate limits that motivate it.

For *what* to put in a description (the four components, trigger breadth, boundary statements), see [Skill Description Frontmatter](./skill-description-frontmatter.md). This doc is only about *how long* it can be.

## The target: keep every description under 1024 characters

**Write every skill `description` to fit within 1024 characters.** That single number keeps a skill safe on every surface it can ship to, with headroom to spare. It is not arbitrary — it is the stricter of the two real limits below.

Count the rendered description text, not the YAML around it: the folded `>` block scalar, the `description:` key, and indentation do not count. What counts is the string Claude receives.

## Why 1024, when there are two different limits

Two separate mechanisms cap a skill description, on two different surfaces. The 1024 target satisfies both at once.

### Limit 1 — claude.ai / cowork upload: a hard 1024-character cap

When a skill is uploaded to claude.ai or used in cowork, the `description` field has a **hard limit of 1024 characters**. Exceed it and the upload is truncated or rejected outright. This is a validation rule, not a suggestion. See [Security Restrictions](./security-restrictions.md) and [Cowork-Specific Skill Instructions](./cowork-specific-skill-instructions.md) for the full field-validation rules.

### Limit 2 — Claude Code listing: a 1536-character per-entry cap, then a budget sweep

In Claude Code the relevant setting is `skillListingMaxDescChars`, which **defaults to 1536 characters per description**. The harness applies it in two passes:

1. **Per-entry cap.** Any single description longer than `skillListingMaxDescChars` (1536 by default) is truncated to fit before it reaches Claude. The skill keeps working, but Claude only sees a clipped description, so the trigger words and boundary statements past the cut are lost.
2. **Budget sweep.** The whole skill listing is then held to `skillListingBudgetFraction` of the context window (default ~1%, roughly 9k tokens). If the combined listing still overflows that budget, the lowest-priority skills lose their descriptions *entirely*.

An operator can raise `skillListingMaxDescChars` in `settings.json`, but that is opt-in: it costs more tokens in every session and burns rate limits faster. A skill that depends on the operator having opted in is a skill that triggers unreliably for everyone who has not. Author for the default.

### The two limits together

| Surface | Limit | What happens past it |
|---------|-------|----------------------|
| claude.ai / cowork upload | 1024 chars (hard) | Truncated or rejected on upload |
| Claude Code listing (default) | 1536 chars per entry | Truncated in the listing; trigger words past the cut are lost |
| Claude Code listing budget | ~1% of context for *all* skills | Lowest-priority skills dropped from the listing entirely |

Targeting **1024** clears the hard cap on upload, sits comfortably under the 1536 Claude Code per-entry cap with room for a future edit, and keeps each skill's share of the shared listing budget small so it does not crowd its siblings out.

## How to measure a description

Count the rendered description string. This snippet reads a SKILL.md, resolves a folded (`>`) or literal (`|`) block scalar, and prints the character count:

```bash
python3 - "path/to/SKILL.md" <<'EOF'
import re, sys
txt = open(sys.argv[1]).read()
fm = re.search(r'^---\n(.*?)\n---', txt, re.S).group(1)
m = re.search(r'^description:\s*(.*)$', fm, re.M)
rest = m.group(1).strip()
if rest in ('>', '|', '>-', '|-'):
    start = m.end()
    block = []
    for ln in fm[start:].split('\n')[1:]:
        if re.match(r'^\S', ln):
            break
        block.append(ln.strip())
    desc = ' '.join(x for x in block if x)
else:
    desc = rest.strip('"\'')
print(f"{len(desc)} chars")
EOF
```

If the count is over 1024, the description is too long no matter how good the prose is. Tighten it.

## What gets cut first: the priority order

Cutting to fit is not a free choice between equal sentences. The parts of a description carry different value, and there is a fixed order in which they should go. Cut from the bottom of this ladder up, never from the top down:

1. **Hedges, filler, and restated capability (cut first).** "including requests like", long parenthetical example lists, and sentences that restate what the skill does in other words. Cheapest characters to reclaim, zero trigger value lost.
2. **Boundary clauses against skills no one would confuse this with.** A "Does not X — use a" clause earns its place only when a real request could plausibly hit the wrong skill. Drop the ones that disambiguate against a distant, unrelated skill.
3. **Boundary clauses against near siblings (cut last, and reluctantly).** When two skills share trigger space, the boundary statement between them is what prevents a misfire. These are the *lowest-priority thing to cut yet the highest-cost to lose* — cut one only when nothing above remains and the description is still over budget, and prefer tightening its wording over deleting it.
4. **What the skill does and its primary when-to-use triggers (never cut).** This is the irreducible core. If the description cannot fit its what plus its primary triggers under 1024 characters, the problem is that the skill is doing too much — see [Skill Decomposition](./skill-decomposition.md) — not that the description needs a smaller font.

The same ladder describes what the harness takes from you if you do not trim yourself. **Claude Code truncation clips the tail of the string**, so whatever sits at the end of the description is the first thing lost. Order the description to match the ladder: lead with what and the primary triggers, and place the lower-priority boundary clauses last, where an over-cap truncation does the least damage. A description that front-loads its boundaries and trails off into its core triggers loses exactly the wrong half when it gets clipped.

## What to do when a description is over the limit

The fix is never to keep the words and hope the truncation lands somewhere harmless. The fix is to move detail out of the description and into the body, where there is no budget pressure, then trim what remains in priority order.

- **Move the *how* to the SKILL.md body.** The description answers what, when, boundary, and trigger breadth. Process detail, step lists, and caveats belong in the body (Level 2) or `references/` (Level 3). See [Progressive Disclosure](./progressive-disclosure.md).
- **Trim in priority order.** Apply the ladder above: hedges and filler first, distant-sibling boundaries next, near-sibling boundaries last. Never sacrifice the what or the primary triggers to save a boundary clause.
- **Re-order so the tail is expendable.** Put the highest-value content first and the most cuttable content last, so that if the description is ever clipped at the cap, the loss falls on the lowest-priority part.
- **Re-measure.** Run the snippet again. Triggering quality is set by what survives the cap, so the goal is a description that is fully under 1024, not one that merely starts strong.

## Common Pitfalls

| Anti-pattern | Problem | Fix |
|--------------|---------|-----|
| Description over 1024 chars | Rejected on upload; clipped in the Claude Code listing | Move detail to the body; tighten to under 1024 |
| "It's only over by a little" | A later edit pushes it past the cap; truncation already lost the tail | Leave headroom under 1024, do not author right at the limit |
| Relying on a raised `skillListingMaxDescChars` | Triggers unreliably for every operator on the default | Author for the 1536 default, target 1024 |
| Long boundary chain against non-siblings | Burns characters disambiguating skills no one confuses | Keep only the boundaries that prevent a real misfire |
| Measuring the YAML, not the string | Miscounts the budget that actually applies | Count the rendered description text only |

## Summary Checklist

1. The rendered `description` is **under 1024 characters**.
2. It is fully under the Claude Code default cap of 1536, with headroom for a future edit.
3. It will survive a claude.ai / cowork upload (hard 1024 cap).
4. Detail beyond what, when, boundary, and trigger breadth lives in the SKILL.md body, not the description.
5. The skill does not depend on an operator raising `skillListingMaxDescChars`.
6. The length was measured against the rendered string, not the YAML.
7. The what and primary triggers lead; lower-priority boundary clauses trail, so a tail-clipping truncation costs the least.

Cross-references:
- [Skill Description Frontmatter](./skill-description-frontmatter.md) — What belongs in a description (the four components, trigger breadth, boundaries)
- [Security Restrictions](./security-restrictions.md) — The 1024-character hard limit as a frontmatter validation rule
- [Cowork-Specific Skill Instructions](./cowork-specific-skill-instructions.md) — Field-validation rules for the claude.ai / cowork upload surface
- [Progressive Disclosure](./progressive-disclosure.md) — Where description detail goes instead (body and references)
- [Context Hygiene](./context-hygiene.md) — Why every always-loaded frontmatter token carries a context cost
