# Investigation: PR #219 lint job fails on unformatted `evals/` files

Investigation report. Read the Summary, then approve the Planned Fix or push back.

## Summary

- **Root Cause:** PR #219 inherits a lint failure from `main`: the Skillwalker evals (Skillwalker is the external tool that runs them) merged in #218 were committed without running Prettier, so the Prettier hook rewrites 85 files under `evals/` and fails the job (E1, E3, E4).
- **Fix:** Run the pinned Prettier over `evals/` and commit the result on `main`, so `main` goes green and PR #219 picks up the fix when it updates from `main`.
- **Why Correct:** In a clean checkout with CI's pinned tools, formatting `evals/` makes all 13 lint hooks pass (E7).
- **Validation Outcome:** Validation confirmed the root cause and fix, showed the reformat is whitespace-only, and refuted the draft's reason for rejecting a `.prettierignore` entry, which has been corrected (V3, V4).
- **Remaining Risks:** Confidence is high; the one unverified assumption is that Skillwalker, the external eval runner, does not read `evals/` files byte for byte.

## Problem Statement

The `lint` job on PR #219 fails, and the PR's own changes are not the cause.

- **Symptom:** `npm run lint` exits 1. The Prettier hook reports `Failed` with "files were modified by this hook". Every other hook passes, and the `test` job in the same run passes (E1).
- **Expected:** The lint job passes, since every file PR #219 changes is already formatted (E2).
- **Conditions:** Any CI run on a commit that includes #218 (`abba73a`) fails the same way. That includes `main` itself (E4) and every branch cut from it since, including PR #219 (E3).
- **Impact:** `main` has been red since #218 merged on 2026-09-22, and every open PR based on it will show a failing lint check until the fix lands.

## Root Cause Analysis

### Root Cause

The `evals/` tree added in #218 was never run through Prettier, and nothing in the lint setup exempts it, so the Prettier hook reformats 85 of its files on every CI run and fails.

### Detailed Analysis

The lint job runs Prettier in write mode over every Markdown, JSON, YAML, and JavaScript file in the repo. A hook that changes a file counts as a failure (E5). `.prettierignore` exempts old plans, research, and vendored assets, but not `evals/` (E5).

Commit `abba73a` (#218) added 247 tracked files under `evals/` (E3). Of those, 85 are not in the shape Prettier wants (E6):

- Prompt files end without a final newline.
- Rubric files are missing blank lines Prettier inserts, such as between a heading and the list below it.
- `tests.json` files hold one-line objects wider than the 120-column print width, which Prettier breaks onto multiple lines.
- Two scaffold plan files hold Markdown tables that Prettier pads into aligned columns.

None of these changes alter content. They are whitespace and layout only.

`main`'s own CI run on `abba73a` failed with the same Prettier error (E4). PR #219 branched from `abba73a` (E3), so it carries the same 85 files. The failing file list in the PR's log names only `evals/` paths and none of the 25 files the PR changes (E1, E2).

## Planned Fix

### Approach

Format `evals/` with the repo's pinned Prettier and commit the result on `main`, then update PR #219 from `main`.

### Changes

#### `evals/**` (85 files)

- **Change:** Reformat with Prettier. Whitespace and layout only (E6).
- **Evidence:** (E1), (E6), (E7)
- **Standards:** `.prettierrc.json` and the Prettier hook in `.pre-commit-config.yaml`.
- **Details:** Run these steps from a checkout of `main`:
  1. Install the pinned tools so Prettier is 3.9.6, the version CI uses.
  2. Format the evals tree.
  3. Confirm the full lint passes.
  4. Commit and push, or open a small PR to `main`.
  5. Merge or rebase `main` into `opus-5-5-plugin-builder-guidance` to re-run PR #219's checks.

  ```sh
  npm ci
  npx prettier --write evals
  npm run lint
  git add evals
  git commit -m "chore(lint): format the Skillwalker evals with Prettier"
  ```

If the fix needs to land on PR #219 first, commit the same change on the PR branch instead. The cost is that the PR's diff grows by 85 unrelated files.

### Alternative considered: ignore `evals/` instead of formatting it

Adding `evals/` to `.prettierignore` also turns the job green, with no other change. The file-hygiene hooks already skip Markdown and JSON everywhere, so nothing else would touch the missing final newlines (V4).

Formatting is still the better fix. The `.prettierignore` header says Markdown in this repo "is the product," and every entry it exempts is a static archive, a vendored asset, or a file Prettier cannot parse. The eval prompts and rubrics are none of those. They are live content an agent reads, so they belong under the same formatting standard as the skills they test.

Choose the ignore only if you learn that Skillwalker reads `evals/` files byte for byte (see Remaining Risks).

```
# .pre-commit-config.yaml:41-48, on all four hygiene hooks
exclude: '\.(md|markdown|json|ya?ml|jsx?|mjs|cjs)$'
```

### Tell reviewers the fix commit is whitespace-only

The fix commit shows 433 insertions and 265 deletions across 85 files. The two scaffold files under `evals/iterative-plan-review/scaffolds/ruby-security-app/plans/` realign every row of a 49-row table, which can look like content loss in a collapsed or filtered diff view (V3).

Say in the commit or PR description that the change is Prettier formatting only, and suggest `git diff -w` to review it.

## Evidence Summary

### E1: The PR's lint job fails only in the Prettier hook, on `evals/` files

- **Source:** CI run 35880222315, job 107246445126 (PR #219, `lint`)
- **Finding:**
  ```
  prettier.................................................................Failed
  - hook id: prettier
  - files were modified by this hook
  ...
  shellcheck...............................................................Passed
  (the other 11 hooks)......................................................Passed
  ##[error]Process completed with exit code 1.
  ```
  Prettier's per-file output lists 85 files without `(unchanged)`. Every one is under `evals/`. The `test` job in the same run passed.
- **Relevance:** Pins the failure to Prettier rewriting `evals/`.

### E2: PR #219 touches no file under `evals/`

- **Source:** `gh pr view 219 --json files`
- **Finding:** 25 changed files, all under `docs/plans/opus-5-5-plugin-builder-guidance/` and `han-plugin-builder/`.
- **Relevance:** The PR's own changes are not the cause.

### E3: `evals/` arrived on `main` in #218, and PR #219 branched from that commit

- **Source:** `git log -- evals`, `git merge-base HEAD origin/main`
- **Finding:**
  ```
  abba73a adding Skillwalker evals for skills, agents, etc. (#218)
  merge-base(HEAD, origin/main) = abba73a
  git ls-files evals | wc -l    = 247
  ```
- **Relevance:** The failing files came from `main`, not from the PR.

### E4: `main` has failed the same way since #218

- **Source:** `gh run list --branch main --workflow ci.yml`, run 35780701011
- **Finding:**
  ```
  failure  adding Skillwalker evals for skills, agents, etc. (#218)  2026-09-22
  success  chore(release): v5.5.0                                     2026-09-15
  ```
  Run 35780701011 reports `prettier...Failed`.
- **Relevance:** The failure predates PR #219 and is present on `main`.

### E5: The Prettier hook rewrites files, and `evals/` is not exempt

- **Source:** `.pre-commit-config.yaml:17-23`, `.prettierignore`, `package.json:7`
- **Finding:**
  ```yaml
  - id: prettier
    entry: npx prettier --write --ignore-unknown
    types_or: [markdown, json, yaml, javascript]
  ```
  `npm run lint` runs `prek run --all-files`. `.prettierignore` lists `docs/plans/`, `docs/research/`, `han-reporting/skills/html-summary/assets/`, one HTML template, `node_modules/`, and `package-lock.json`.
- **Relevance:** Any unformatted `evals/` file fails the job.

### E6: Prettier's changes to `evals/` are whitespace and layout only

- **Source:** diff of a Prettier-formatted copy of `evals/` against the committed tree
- **Finding:**
  ```
  prompts/*.md     add missing final newline
  rubrics/*.md     insert blank lines (e.g. after a heading, before a list)
  tests.json       expand one-line objects wider than 120 columns
  scaffolds/**.md  pad table columns into alignment
  ```
- **Relevance:** Formatting changes no eval's content.

### E7: With CI's pinned tools, formatting `evals/` makes lint pass

- **Source:** throwaway `git worktree` at `HEAD`, after `npm ci`
- **Finding:**
  ```
  npx prettier --version                  3.9.6
  npx prettier --list-different evals     85 files
  npx prettier --write evals && npm run lint
  -> all 13 hooks Passed, exit 0
  ```
- **Relevance:** Confirms the fix and that no other lint failure hides behind this one.

## Validation Results

An adversarial validator re-ran every evidence item against live CI data and two clean worktrees. It confirmed the root cause and the fix, and refuted one claim about the alternative fix.

### Counter-Evidence Investigated

#### V1: Was the causal chain from #218 to PR #219 real?

- **Hypothesis:** E1 to E4 are stale or wrong.
- **Investigation:** Re-read the PR #219 job log, the PR file list, the merge base, and `main`'s run history with `gh`.
- **Result:** Confirmed.
- **Impact:** Stronger than first written. PR #218 failed lint in all 4 of its pre-merge CI runs (35740115461, 35765129642, 35766777178, 35773692481) and merged with the red check. `main` has no branch protection (`gh api repos/testdouble/han/branches/main/protection` returns 404), so nothing blocked the merge.

#### V2: Does formatting `evals/` make lint pass?

- **Hypothesis:** The fix misses a failure.
- **Investigation:** Clean worktree at `78a98e4`, `npm ci`, format `evals/`, run `npm run lint`.
- **Result:** Confirmed. 85 files changed, and all 13 hooks passed.
- **Impact:** None.

#### V3: Does the reformat change any content?

- **Hypothesis:** Prettier renumbers an ordered list, trims padding inside inline code, or alters JSON or code fences. The `.prettierignore` header names the first two as transforms Prettier cannot turn off.
- **Investigation:** Compared all 12 changed `tests.json` files as parsed JSON, every inline code span, every ordered-list marker, and every fenced code block before and after. Checked a prompt file's new final newline at the byte level.
- **Result:** Confirmed. No content changed. The 85 files break down as 63 prompts, 8 rubrics, 12 `tests.json`, and 2 scaffolds.
- **Impact:** Added the reviewer note to the Planned Fix. The validator briefly misread the scaffold table diff as dropped rows before a full diff showed 49 rows before and after.

#### V4: Does ignoring `evals/` need a second config change?

- **Hypothesis:** The draft claimed the `fix end of files` hook would fail in Prettier's place if `evals/` were ignored.
- **Investigation:** Read `.pre-commit-config.yaml:41-48`, then added only `evals/` to `.prettierignore` on the unformatted tree and ran `npm run lint`.
- **Result:** Refuted. All 13 hooks passed. The hygiene hooks already skip `.md` and `.json` files.
- **Impact:** Rewrote the alternative's rejection reason (see Adjustments Made).

#### V5: Is another failure hiding behind this one?

- **Hypothesis:** The PR's own files carry a lint problem masked by the `evals/` noise.
- **Investigation:** `npx prettier --list-different .` over the whole repo, plus the real CI hook results.
- **Result:** Confirmed clean. No file outside `evals/` needs formatting, and the `test` job passes.
- **Impact:** None.

#### V6: Could the fix pass locally but fail in CI?

- **Hypothesis:** Prettier version drift or a stale prek cache.
- **Investigation:** `.github/workflows/ci.yml` runs `npm ci`, which installs Prettier 3.9.6 from `package-lock.json`. The prek cache holds tool installs keyed on `.pre-commit-config.yaml`, not per-file results.
- **Result:** Refuted as a risk.
- **Impact:** None.

### Adjustments Made

- **V4:** The "Alternative considered" section now says ignoring `evals/` would work alone. It gives the real reason to format instead: eval prompts and rubrics are live agent-facing content, not the archives and vendored files `.prettierignore` exists for.
- **V3:** Added a note to tell reviewers the fix commit is whitespace-only.
- **V1:** Recorded that #218 merged with a failing check into an unprotected `main`.

### Confidence Assessment

- **Confidence:** High
- **Remaining Risks:**
  - Skillwalker, the external tool that runs these evals, is not in this repo, so nothing here shows how it reads `evals/`. If it compares any file byte for byte, the reformat could change a result. No evidence either way. Run one eval after the fix to check.
  - `main` has no branch protection, so another PR can merge with a red lint check the same way #218 did. Out of scope for this fix, but it is how the failure reached `main`.

## Coding Standards Reference

| Standard                                                                 | Source                                    | Applies To          |
| ------------------------------------------------------------------------ | ----------------------------------------- | ------------------- |
| Prettier formats Markdown, JSON, YAML, JS at print width 120, prose preserved | `.prettierrc.json`, `.pre-commit-config.yaml` | every `evals/` file |
| Lint runs with npm-pinned tools, identical in CI and locally             | `.github/workflows/ci.yml`, `package.json` | the fix's commands  |
