# Feature Technical Notes: Verified PR Descriptions

Load-bearing mechanics. A note lives here only because a behavior in [../feature-specification.md](../feature-specification.md) is correct only because of the mechanic, and the mechanic is not discoverable from existing code in this repository.

## T1: Claim provenance is captured at authoring time

- **Context:** The gate ([D2](decision-log.md#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for)) commits the skill to showing each claim beside the evidence it was written from, and to marking as unevidenced any claim it could not point at anything for. The gate's entire value rests on that marking being honest.

- **Technical detail:** The pass that writes the description must emit each assertion already bound to the evidence it rests on, as a single act, and must write the finished readable prose — in the shape the repository's template requires — in that same act ([D11](decision-log.md#d11-nothing-rewrites-the-draft-between-authoring-and-the-gate)). Two mechanics follow, and both are load-bearing.

  **The pairing cannot be reconstructed after the fact.** A second pass that reads finished prose and goes looking for supporting evidence is being asked to find justification for a claim it is motivated to accept. That is the same generative act that produced the hallucinated claim in the first place, so it would happily find plausible-looking support for an invented claim and report the gate as clean. Structurally, the only pass that can honestly say *I could not evidence this one* is the pass that tried to write it and found nothing to write from.

  **No pass that touches the words may run between the pairing and the gate.** This is the non-obvious half, and it is why readability and template conformance are folded in rather than applied afterward. A rewrite pass that preserves every fact still restates every claim in new words. The moment it does, the text shown at the gate is no longer the text whose evidence was recorded, and the pairing is a reconstruction again — arriving through a pass nobody would think to call generative. The rule covers *any* pass that edits the draft, not only passes that invent facts: a readability rewrite, a readability self-check that fixes what it finds, and a structural verification step that fixes what it finds are the same hazard in three costumes ([D11](decision-log.md#d11-nothing-rewrites-the-draft-between-authoring-and-the-gate)).

  Note the asymmetry this establishes, because it drives the gate's display rules: the authoring pass can honestly report the *absence* of evidence, because absence is a fact about what it had in hand. It cannot certify the *presence* of evidence, because that is a self-assessment of its own output. Only the human closes that half, which is why the gate shows claim and evidence side by side and applies no "supported" label ([D2](decision-log.md#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for)).

  The rule constrains what may run *before* the gate. It does not forbid the skill from re-joining surviving assertions into readable prose *after* the engineer has ruled on them, which is a different act on already-verified material and is bounded by its own rule ([D7](decision-log.md#d7-the-engineers-verdict-is-binding-and-re-rendering-does-not-re-draft)): no assertion the engineer did not approve may appear, and the result is shown to them before it is published.

- **Supports decisions:** [D2](decision-log.md#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for), [D7](decision-log.md#d7-the-engineers-verdict-is-binding-and-re-rendering-does-not-re-draft), [D11](decision-log.md#d11-nothing-rewrites-the-draft-between-authoring-and-the-gate), [D12](decision-log.md#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read)
- **Driven by findings:** F2, F7, F9, F18
- **Referenced in spec:** Primary Flow
