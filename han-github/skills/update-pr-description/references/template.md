<!--
Keep the whole description to 2-5 short paragraphs at most. The Summary sentence is one of them;
Behavior changes is 1-3. Stay at the altitude of behavior and intent — the diff carries the specifics.
-->

## Summary

**{One-sentence TL;DR: this PR &lt;verb&gt; &lt;behavior&gt; so that &lt;why&gt;.}**

## Behavior changes

{1-3 short paragraphs, plain language, of what changes at runtime and why — the load-bearing content of this PR. Lead with the central mechanism (a feature flag, migration, state-machine edit, or config / API-contract change) and name its headline effect: a flag and its default, a migration's direction, the new vs. old behavior. Stay at the altitude of behavior and intent; do not enumerate every value, phase, or mode — the diff carries the specifics. Name internal flags or services on first use. A small table is fine only when several flags or modes genuinely interact. Omit this section entirely for pure refactors and docs-only PRs — in that case the Summary sentence stands alone.}

<!--
Include "What to look at first" ONLY when this PR has more than ~8-10 files with SIGNIFICANT changes.
"Significant" = code files. Documentation and configuration files do NOT count by default. A docs/config
file counts as significant only with explicit justification for how it changes the BEHAVIOR of the code
changes in this PR — and even then it usually does NOT belong in the list below. When the count of
significant code files is at or below ~8-10, OMIT this whole section, heading included.
-->

## What to look at first

- {Pointer to a decision, tradeoff, or risk the reviewer should weight, in suggested reading order. 2-4 bullets max. This is a reading-order guide for a large change, not a file list — GitHub's Files Changed tab is one click away.}
