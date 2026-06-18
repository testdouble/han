# Conforming to a repository PR template

The repository ships its own pull-request template. The final description must read as that template, filled in — not a generic description bolted on top. The template's headings and their order are authoritative. Do not assume any particular template shape; infer the structure and intent from the template you are given.

## 1. Read the whole template, including HTML comments

Comments often carry the repo's authoring instructions: what each section is for, what to delete, whether to replace the scaffold entirely. Treat those comments as guidance while drafting, then strip every authoring-instruction comment and placeholder prompt from the final output. The rendered description must not contain the template's instructional comments, `<describe here>`-style prompts, or leftover placeholder braces.

## 2. Determine the template's intent

- **Replace-scaffold.** If the template (or a comment in it) instructs the author to replace its content with a written PR description — for example, "replace this content with a generated PR description" — it is a throwaway scaffold, not a structure to preserve. Discard the scaffold and produce the default structure instead: Summary (the bolded TL;DR sentence only) → Behavior changes (its own `##` section; omit for pure refactors and docs-only PRs) → What to look at first (only when the PR has more than ~8-10 files with significant changes; see the threshold rule in section 5). Keep it to 2-5 short paragraphs, as section 7 requires. Honoring the instruction is the point.
- **Structural template.** Otherwise, the template's sections are the structure. Keep its headings and their order, and fill each section with the matching content below.

## 3. Map content into the template's sections

For each template section, infer its purpose from its heading and any placeholder text, then fill it:

- A description / summary / "what does this PR do" section gets the bolded TL;DR sentence (`**This PR <verb> <behavior>, so that <why>.**`) only — no bullet list. The behavioral detail lives in Behavior changes.
- A motivation / "why" / context section gets the rationale.
- A testing / "how was this tested" / QA section that the template already provides gets filled from the diff's CI and test evidence in the template's own tone. Do not invent a testing section the template does not provide.
- Before/after behavioral detail goes in the section closest to a description or details section (or its own Behavior changes section when the template has no such home), rendered as a small table when multiple flags or modes interact.

## 4. Checkboxes: check only what the diff unambiguously proves

Many templates carry checklists. Check a box only when the branch diff unambiguously proves it (for example, tests were added → check "I added tests"; documentation was updated → check "I updated the docs"). Leave every box the diff cannot prove unchecked: attestations of human action ("I have read the contributing guide", "I tested this manually in staging", "I requested review from the right team") are the author's to make. Never fabricate one. When in doubt, leave the box unchecked. Reproduce the full checklist verbatim either way, never dropping items.

## 5. Add high-value sections only when the template has no home for them

The reviewer attention guide ("What to look at first") earns its place on a large change. Include it only when the PR has more than ~8-10 files with *significant* changes. "Significant" means code files. Documentation and configuration files do **not** count as significant by default; a docs or config file counts only when there is explicit justification for how it changes the *behavior* of the code changes in the PR — and even then it most likely should **not** be listed in "What to look at first" itself. When the count of significant code files is at or below ~8-10, omit the section. When you do include it: if the template already has an equivalent section (a "Reviewer notes" or similar), fill that instead of adding a duplicate; otherwise append it as its own `##` section after the template's sections — never interleaved out of the template's order.

## 6. Structure is not optional

Every section the template defines must remain present and in its original order. Do not silently drop a template section because there is nothing to say. Fill it, or write a short honest note ("Not applicable: this PR changes documentation only."). The template's structure is the contract; your content is the fill.

## 7. Keep the fill concise

Whether you are replacing a scaffold or filling a structural template, keep the prose short: aim for 2-5 short paragraphs across the whole description, with the behavioral detail in 1-3 of them. Stay at the altitude of behavior and intent — name the central mechanism and its headline effect, and let the diff carry every config value, phase, and mode. A reviewer skims the description and reads the diff for specifics; do not restate the diff in prose.
