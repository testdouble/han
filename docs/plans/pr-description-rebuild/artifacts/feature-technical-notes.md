# Feature Technical Notes: Verified PR Descriptions

Load-bearing mechanics. A note lives here only because a behavior in [../feature-specification.md](../feature-specification.md) is correct only because of the mechanic, and the mechanic is not discoverable from existing code in this repository.

## T1: Claim provenance is captured at authoring time

- **Context:** The verification gate ([D2](decision-log.md#d2-the-verification-gate-shows-each-claim-against-its-diff-evidence)) commits the skill to showing each claim beside the diff evidence that supports it, and to marking any claim it cannot evidence as unsupported. The gate's entire value rests on that pairing being trustworthy.
- **Technical detail:** The authoring pass must emit each factual claim already bound to the diff hunk it rests on, as a single act. The pairing cannot be reconstructed afterward by a second pass that reads the finished prose and goes looking for supporting evidence. A post-hoc pass is being asked to find evidence for a claim it is motivated to accept, which is the same generative act that produced the hallucinated claim in the first place. It would happily find plausible-looking support for an invented claim and report the gate as clean. Structurally, the only pass that can honestly say "I could not evidence this one" is the pass that tried to write it and found nothing to write from.
- **Supports decisions:** [D2](decision-log.md#d2-the-verification-gate-shows-each-claim-against-its-diff-evidence), [D7](decision-log.md#d7-a-rejected-claim-is-removed-a-corrected-claim-is-rewritten)
- **Driven by findings:** —
- **Referenced in spec:** Primary Flow
