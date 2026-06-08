---
paths:
  - "**/agents/**/*.md"
---

# Agent Description Length

Every installed agent's frontmatter `description` is loaded into context in every conversation, the same way skill descriptions are. Claude reads the whole roster of agent descriptions to decide which agent to dispatch, so each one is paid for in every session whether or not the agent runs. Run `/context` in a session with agents installed and you will see a `Custom agents` line counting those always-loaded tokens before any prompt is sent. This doc sets the length target for an agent description and explains what belongs in it versus in the agent body.

For *what* an agent description is for (triggering metadata, not the persona), see [Domain Focus in Agent Definitions](./agent-domain-focus.md). That doc governs the Role Identity (the body's "You are a..." paragraph, under 50 tokens) and the `## Domain Vocabulary` and `## Anti-Patterns` body sections. This doc is only about *how long* the always-loaded `description` may be, and which content has to move into those body sections to keep it short.

## The target: keep every agent description under 1024 characters

**Write every agent `description` to fit within 1024 characters**, the same target skills use (see [Skill Description Length](../skill-building-guidance/skill-description-length.md)). Count the rendered description string, not the YAML around it.

Some agents legitimately run longer. An orchestrator that names every specialist it coordinates, or a specialist that has to draw a boundary against five near-sibling agents, carries more required boundary clauses than a single-purpose skill does. Treat 1024 as the target you aim for and **anything past roughly 1500 characters as a strong signal that the description is carrying body-grade content** — domain vocabulary, methodology name-drops, an anti-pattern checklist, or process detail — that belongs in the body instead. The fix is almost never to keep that content and hope it survives; it is to move it where it already lives.

## Why agents drifted long, and why it matters

Agent descriptions were exempted from the 50-token Role Identity budget (correctly: the description is triggering metadata, not persona) but were never given a length budget of their own. With no ceiling, the largest agents accumulated their full domain vocabulary, their named-framework citations, and their anti-pattern lists directly in the always-loaded description, where every token is paid in every session and competes for the model's attention against every other instruction (see [Context Hygiene](../skill-building-guidance/context-hygiene.md)). The routing-relevant signal in those descriptions is a small fraction of the text; the rest is duplicated in the agent body, which loads only when the agent is dispatched.

That duplication is the lever. The vocabulary an agent lists in the description almost always also appears in its `## Domain Vocabulary` body section; the anti-pattern checklist also appears in its `## Anti-Patterns` body section. Moving those out of the description loses nothing operationally — the agent still has them when it runs — and reclaims always-loaded budget for every session.

## What belongs in the description, and what moves to the body

An agent description answers the same four questions a skill description does: **what** the agent does, **when** to invoke it, its **boundary** (the "Does not X — use Y" clauses that route to sibling agents), and **trigger breadth** (the vocabulary a real request would use). Everything else is body-grade.

| Content | Where it goes |
|---------|---------------|
| What the agent does; primary "Use when" trigger | Description (never cut) |
| "Does not X — use Y" boundary against a near-sibling agent | Description (the routing signal is the agent name) |
| The output contract (what it produces, its adversarial posture) | Description, kept tight |
| A unique trigger term no other agent's description carries | Description (it is the only anchor for that request) |
| Domain vocabulary, named frameworks, author citations | Body `## Domain Vocabulary` |
| Anti-pattern checklists, detection signals | Body `## Anti-Patterns` |
| Protocols, step lists, methodology expansions | Body |

A useful test for the boundary clauses: the load-bearing unit of a "Does not X — use Y" redirect is the **agent name**, not the prose describing what that sibling does. A reader who does not already know what `devops-engineer` covers will look it up; thirty words restating its scope inside this agent's description do not help them route and are not worth the always-loaded cost. Name the sibling, keep the clause to roughly eight to twelve words, and let the sibling's own description carry its scope.

Two cautions when trimming, both of which can turn a safe-looking cut into a routing regression:

- **Keep unique anchors.** Before deleting a domain term, check that it is not the *only* always-loaded place a real request would land. If `data-engineer` is the only agent whose description says "event sourcing and CQRS," a user asking to "audit this event-sourced projection for CQRS problems" has nowhere else to route once it is gone. A term that lives in several descriptions is a name-drop; a term that lives in exactly one is an anchor. Keep the anchor.
- **Boundaries are bidirectional.** If this agent points to a sibling, the sibling should point back (see the bidirectional-disambiguation rule in [Skill Description Frontmatter](../skill-building-guidance/skill-description-frontmatter.md)). Before deleting one side of a pair, confirm the other side; deleting only one half opens a gap Claude can fall through. If you find a one-way boundary while trimming, repair it rather than preserve the gap.

## The priority cutting ladder

When a description is over the target, cut in the same fixed order skills use. The full ladder lives in [Skill Description Length](../skill-building-guidance/skill-description-length.md); applied to agents it reads:

1. **Domain vocabulary, methodology name-drops, and anti-pattern checklists (cut first).** These are body-grade and almost always already in the agent body. Move them to `## Domain Vocabulary` / `## Anti-Patterns` and delete them from the description. This is the largest and safest reclaim.
2. **Restated capability and process prose.** Mode elaborations, "how it works" sentences, and exhaustive rosters that re-list what the body already explains.
3. **Boundary clauses against agents no one would confuse this with.** Drop a "Does not X — use Y" only when a real request could not plausibly hit the wrong agent.
4. **Boundary clauses against near siblings (cut last, and reluctantly).** Tighten the wording before deleting; the agent name is the part that must survive.
5. **What the agent does and its primary triggers (never cut).** The irreducible core. If what plus primary triggers will not fit, the agent is doing too much.

## How to measure a description

Count the rendered description string, resolving a folded (`>`) or quoted scalar:

```bash
python3 - "path/to/agent.md" <<'EOF'
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

If the count is well over 1024, find the vocabulary or anti-pattern content and move it to the body.

## Common Pitfalls

| Anti-pattern | Problem | Fix |
|--------------|---------|-----|
| Full domain vocabulary in the description | Always-loaded cost paid every session for content the body already carries | Move it to `## Domain Vocabulary`; keep only unique trigger anchors |
| Anti-pattern checklist in the description | Same; the checklist is in `## Anti-Patterns` already | Move it to the body |
| Thirty-word prose per "Does not" redirect | Burns budget restating sibling scope that adds no routing signal | Keep the agent name and a short clause; drop the prose |
| Deleting a unique trigger term | Removes the only always-loaded anchor for a real request | Grep every agent description first; keep terms owned by exactly one agent |
| Trimming one side of a boundary pair | Opens a one-way routing gap | Check the sibling's reverse clause; repair, do not preserve, a gap |

## Summary Checklist

1. The rendered `description` is at or near **1024 characters**, and not past ~1500 unless every clause is a required boundary.
2. Domain vocabulary, named frameworks, and anti-pattern checklists live in the agent body, not the description.
3. Each "Does not X — use Y" boundary keeps the sibling name and drops the scope prose.
4. No deleted term was the only always-loaded anchor for a real request (grep to confirm).
5. Every boundary the description draws is matched by a reverse clause in the sibling.
6. The length was measured against the rendered string, not the YAML.

## Cross-References

- [Domain Focus in Agent Definitions](./agent-domain-focus.md) — What the description is for, the 50-token Role Identity budget, and the `## Domain Vocabulary` / `## Anti-Patterns` body sections content moves into.
- [Skill Description Length](../skill-building-guidance/skill-description-length.md) — The sibling 1024-character budget for skills, the platform limits behind it, and the full priority cutting ladder.
- [Skill Description Frontmatter](../skill-building-guidance/skill-description-frontmatter.md) — The four description components and the bidirectional-disambiguation rule that makes boundary trimming safe.
- [Context Hygiene](../skill-building-guidance/context-hygiene.md) — Why every always-loaded token competes for attention, so a shorter description helps routing for the whole roster.
- [Progressive Disclosure](../skill-building-guidance/progressive-disclosure.md) — The always-loaded-versus-on-demand split that justifies moving vocabulary out of the description and into the body.
