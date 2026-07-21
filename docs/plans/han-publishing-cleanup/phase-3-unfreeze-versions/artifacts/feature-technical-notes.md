# Feature Technical Notes: Unfreeze the Second Channel's Version Numbers

## T1: How the second channel offers updates

- **Context:** The Outcome promises update offers resume once the numbers are corrected, and only after the merge.
  Both halves rest on how the second channel evaluates freshness.
- **Technical detail:** The Codex channel registers this repository as the marketplace and reads each plugin's version
  from its `.codex-plugin/plugin.json` on the repository's default branch. Update availability is a comparison of that
  served version against the locally installed one, so a served version that never changes means no update is ever
  offered, and corrections on a working branch are invisible until merged to `main`. External channel behavior, not
  discoverable from this repo's own code.
- **Supports decisions:** D2
- **Driven by findings:** —
- **Referenced in spec:** Outcome; Actors and Triggers; Edge Cases and Failure Modes; Coordinations
