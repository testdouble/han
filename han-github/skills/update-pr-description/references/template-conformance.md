# Conforming to a repository PR template

The repository ships its own pull-request template. The final description must read as that template, filled in — not a generic description bolted on top. The template's headings and their order are authoritative. Do not assume any particular template shape; infer the structure and intent from the template you are given.

## 1. Read the whole template, including HTML comments

Comments often carry the repo's authoring instructions: what each section is for, what to delete, whether to replace the scaffold entirely. Treat those comments as guidance while drafting, then strip every authoring-instruction comment and placeholder prompt from the final output. The rendered description must not contain the template's instructional comments, `<describe here>`-style prompts, or leftover placeholder braces.

## 2. Determine the template's intent

- **Replace-scaffold.** If the template (or a comment in it) instructs the author to replace its content with a written PR description — for example, "replace this content with a generated PR description" — it is a throwaway scaffold, not a structure to preserve. Discard the scaffold and produce the default structure instead: Summary (bolded TL;DR sentence + 2-4 bullets, plus a `### Behavior changes` subsection when runtime behavior changes) → What to look at first → How this was tested (only when the inclusion decision includes it) → Files of interest → Test scenario changes (only when tests were added or edited). Honoring the instruction is the point.
- **Structural template.** Otherwise, the template's sections are the structure. Keep its headings and their order, and fill each section with the matching content below.

## 3. Map content into the template's sections

For each template section, infer its purpose from its heading and any placeholder text, then fill it:

- A description / summary / "what does this PR do" section gets the bolded TL;DR sentence (`**This PR <verb> <behavior>, so that <why>.**`) followed by the behavioral summary bullets.
- A motivation / "why" / context section gets the rationale.
- A testing / "how was this tested" / QA section gets the `- ✅` past-tense self-check items — but only when the inclusion decision includes them. When the decision omits them (documentation-only branch), write a short honest note in the template's tone (for example, "Documentation-only change; no tests.") rather than leaving the section blank.
- Before/after behavioral detail goes in the section closest to a description or details section, rendered as a small table when multiple flags or modes interact.

## 4. Checkboxes: check only what the diff unambiguously proves

Many templates carry checklists. Check a box only when the branch diff unambiguously proves it (for example, tests were added → check "I added tests"; documentation was updated → check "I updated the docs"). Leave every box the diff cannot prove unchecked: attestations of human action ("I have read the contributing guide", "I tested this manually in staging", "I requested review from the right team") are the author's to make. Never fabricate one. When in doubt, leave the box unchecked. Reproduce the full checklist verbatim either way, never dropping items.

## 5. Add high-value sections only when the template has no home for them

The reviewer attention guide ("What to look at first") and "Files of interest" earn their place in any review. If the template already has an equivalent section (a "Reviewer notes", "Files changed", or similar), fill that instead of adding a duplicate. If the template has no equivalent, append each as its own `##` section after the template's sections — never interleaved out of the template's order.

## 6. Additional information is welcome; structure is not optional

You may add detail beyond what the template asks for, but every section the template defines must remain present and in its original order. Do not silently drop a template section because there is nothing to say. Fill it, or write a short honest note ("Not applicable: this PR changes documentation only."). The template's structure is the contract; your content is the fill.
