# Implementation Iteration History: Per-Plugin Release Tags

Round-by-round record of the specialists engaged, the claims they raised, and how each was resolved. Decisions live in
[implementation-decision-log.md](implementation-decision-log.md); the plan lives in
[../feature-implementation-plan.md](../feature-implementation-plan.md).

Team size: **small** (one skill, two reference files, one documentation file; no cross-service integration, no auth or
PII surface, no data migration). One chosen specialist, round cap 1.

## R1: Parallel specialist review

- **Specialists engaged:** `han-core:junior-developer` (identifiers `JD-###`), `han-core:devops-engineer` (identifiers
  `DOR-#`). `han-core:plan-synthesizer` was held for the final synthesis rather than dispatched per round.
- **New input provided:** the feature specification and its four artifacts as paths, the discovery notes at
  `.discovery-notes.md`, the recorded scope boundary, and a domain-framed question each. Both were told to treat `T1`
  through `T4` as committed mechanics with a three-verdict protocol.
- **Technical-note verdicts:** both specialists **confirmed** `T1`, `T2`, `T3`, and `T4`. No contradiction finding and
  no out-of-scope finding was raised, so the spec-maturity gate did not trip and no facilitation pass was needed.
- **Decisions produced:** `D-1` through `D-18`, the whole of
  [implementation-decision-log.md](implementation-decision-log.md). No decision predates this round and none was added
  after it, so every decision's `Driven by rounds:` field names `R1`. The claim each one came from is the ledger's last
  column below; `C5`, `C9`, and `C10` converge on `D-5`, and `C16` produced two decisions, `D-15` and `D-18`.
- **Changed in plan:** every section of the plan below `User Stories` carries something this round produced.
  - `Making the approval stop real` and unit 1 exist because of `C1`. Without them the plan would have specified a stop
    that never renders, which is the single change that decides whether the rest of the plan is safe.
  - `Finding the previous release` gained the two-probe rule from `C6` and the parse rule from `C19`, and unit 2 with
    them.
  - `Validating before the commit` and unit 3 replaced the dry-run gate the specification's evidence implied, on `C3`.
  - `Knowing what is on GitHub`, its four-state block, and unit 4 exist because of `C5`, `C9`, `C10`, and `C11`. The
    peel `C10` surfaced is the reason that work is a script rather than skill prose.
  - `Tagging each plugin` gained the `command` builtin form from `C4`, the commit re-check from `C12`, and the by-name
    walk order from `C17`.
  - `Publishing` gained the refuse-to-create-a-tag flag from `C13`.
  - `What changes and what stays`, and the two-column table that is the whole of it, exist because of `C7`.
  - `The decline path` and unit 7 exist because of `C14`; `The closing report` and its literal push command because of
    `C15`.
  - Unit 5 keeps the three stops separate on `C8`. `Testing Strategy` and the first two `Deferred (YAGNI)` entries come
    from `C18`, the third from `D-2`'s rejected alternative. Units 8 and 9 come from `C16`.

### Passes A, B, and C

**Pass A (merge by substance).** Both specialists independently raised the same top finding and two others. Merged
records carry both identifiers. Nineteen distinct claims survived the merge.

**Pass B (strip blocking severity from unverified findings).** Three findings arrived carrying an `Unverified:`
disclosure. Two of them I verified myself, which promoted them out of the class. One could not be verified from this
repository and stays `Unverified`, and it does not carry blocking severity anywhere in the plan.

**Pass C (design-dependent findings).** Not applicable: this run holds no visual material, so no finding turns on any.

**Unaudited evidence classes.** None. Both specialists had the spec, all four spec artifacts, the discovery notes, the
skill on disk, and the repository. Neither reported an input it could not reach.

### Claim ledger

| ID   | Claim                                                                                      | Raised by       | Status                     | Resolution source | Decision |
| ---- | ------------------------------------------------------------------------------------------ | --------------- | -------------------------- | ----------------- | -------- |
| C1   | `AskUserQuestion` in `allowed-tools` silently voids the mandatory approval stop             | JD-001, DOR-1   | Confirmed, blocking        | Evidence          | D-1      |
| C2   | An empty answer at the tag stop must read as a decline                                      | JD-002          | Accepted                   | Evidence          | D-2      |
| C3   | The pre-commit validation cannot use the tagging command's dry run where the spec places it | JD-003, DOR-5   | Confirmed, blocking        | Evidence          | D-3      |
| C4   | The tagging invocation must bypass a shell wrapper and be nameable by a permission rule     | JD-004, DOR-8   | Confirmed by test          | Evidence          | D-4      |
| C5   | Message matching alone does not justify a script                                            | JD-005          | Accepted                   | Evidence          | D-5      |
| C6   | One combined tag glob returns the wrong tag; two separate probes are required               | JD-006          | **Verified myself**        | Evidence          | D-9      |
| C7   | Most `v{parent target}` occurrences must **not** change; a blind replace breaks anchors     | JD-007          | Confirmed, blocking        | Evidence          | D-11     |
| C8   | Three stops now exist, and `D15`'s evidence misplaced the pre-publish pause                 | JD-008          | Confirmed                  | Evidence          | D-16     |
| C9   | Confirming tags on GitHub is one remote read, not one per plugin                            | JD-009, DOR-2   | Accepted                   | Evidence          | D-5      |
| C10  | `git ls-remote` returns the tag object, not the commit, for an annotated tag                | DOR-2           | **Verified myself**        | Evidence          | D-5      |
| C11  | The unrecoverable tag conflict is detectable before the walk                                | DOR-3           | Confirmed, blocking        | Evidence          | D-6      |
| C12  | `HEAD` can move across the approval stop, and the tags follow `HEAD`                        | DOR-4           | Confirmed                  | Evidence          | D-7      |
| C13  | `gh release create` creates a missing tag by itself                                         | DOR-6           | **Verified myself**        | Evidence          | D-8      |
| C14  | The decline path makes the changelog augment produce duplicate bookkeeping                  | DOR-7           | Confirmed                  | Evidence          | D-14     |
| C15  | The recovery command in the report must be a push, not a re-run                             | DOR-9           | Confirmed                  | Evidence          | D-13     |
| C16  | Sequencing: cut from the default branch; the baseline fix ships unverified; schedule the arm | DOR-10          | Confirmed                  | Evidence          | D-15, D-18 |
| C17  | Parent-first walk order rests on file-order coincidence                                     | JD-011          | Confirmed                  | Evidence          | D-12     |
| C18  | A release harness, a fake tagging binary, and tag-triggered CI are all YAGNI                | JD-010, DOR-11  | Accepted                   | Evidence          | D-17     |
| C19  | The baseline parse rule should read "the part after the last `v`"                           | DOR-10          | Accepted                   | Evidence          | D-10     |

### What I verified myself, rather than accepting on report

Four claims were checkable in this repository, so I checked them rather than planning around an assertion. The main
repository was left untouched.

**C10 is confirmed and sharper than reported.** `git ls-remote --tags origin v4.6.0` returns `4814987`, while
`git rev-list -n1 v4.6.0` returns `fdafcb6`. Those are different objects: `git cat-file -t v4.6.0` returns `tag`. And
the tagging command creates annotated tags, confirmed from its own dry-run output, which prints `git tag -a`. So every
tag this feature creates hits the trap. A comparison that reads the unpeeled line would classify **every** tag as
sitting at a different commit, and under the spec's own failure table that state stops the run and declares recovery
impossible. The plan would have shipped a release process that halts on its first plugin.

**C6 is confirmed.** With `han--v5.0.0`, `han--v5.10.0`, and `han-core--v3.0.0` present alongside the suite tags,
`git tag -l 'han--v*' 'v*.*.*' --sort=-v:refname | head -n1` returns `v4.6.0`, because the refname comparison starts at
`h` versus `v`. The separate probes return `han--v5.10.0` and `v4.6.0` correctly. A combined probe would silently keep
picking the old tag on every release after the transition.

**C13 is confirmed, with a bonus.** `gh release create --help` states: "If a matching git tag does not yet exist, one
will automatically get created from the latest state of the default branch." It also documents `--verify-tag`, which
aborts when the tag does not already exist. The same help text adds that once a release is published, "Git tags
associated with a release cannot be modified or deleted" — GitHub enforces the immutability `D10` assumed, which makes
the wrong-commit state genuinely unrecoverable rather than merely awkward.

**C4's shell half is confirmed.** With a shell function named `claude` defined, `command claude --version` returned
`2.1.221` while the bare call ran the function. `command` is the correct form and is a fixed literal a permission rule
can name.

**DOR-10's open question is answered.** `v4.6.0`, `v4.5.0`, and `v4.4.0` are all ancestors of `origin/main`, so every
recent release was cut from the default branch. Cutting this one from a topic branch would be the departure, not the
norm.

### Open Questions raised, and how each was resolved

| Question                                                                          | Resolution                                                                                                                                      |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Does the tagging command create annotated or lightweight tags?                     | **Evidence.** Annotated. Its dry run prints `git tag -a`. This makes the peel handling in `D-5` mandatory rather than defensive.                 |
| Does cleanliness at the pre-commit gate exclude the files the run itself wrote?    | **Evidence.** Made moot by `D-3`: the gate runs before the version-application step, while the tree is still clean, plus a narrower re-check after. |
| Does the dry run evaluate version agreement before or after the already-exists refusal? | **Evidence.** Made moot by `D-3`, which drops the dry run from the validation path entirely.                                                 |
| Have prior releases been cut from non-default branches?                            | **Evidence.** No. The three most recent release tags are all ancestors of `origin/main`.                                                         |
| When the pre-publish pause is requested, do both it and the tag stop fire?          | **Evidence and a stated default.** Both fire, kept separate with distinct headers (`D-16`). Merging them would change what an existing opt-in flag means. |
| Does the permission matcher honor `Bash(command claude *)`?                        | **Unresolved, and stays `Unverified`.** Not observable from this repository. Non-blocking: the worst case is one approval prompt, and `D-4` records the fallback. |

### Spec-maturity tags

No finding was tagged `spec-level` and no `T#` contradiction was raised. The specification held up under implementation
review: every blocking finding landed on how to build the behavior, not on what the behavior should be. The gate did not
trip, so `han-planning:discussion-facilitator` was not dispatched.

### Deterministic next-step recommendation

**Go to synthesis.** Every Open Question resolved by evidence, zero escalations required, no blocking question left
pending. The round produced no `spec-level` finding.

## Escalation register

No question was escalated to the user during this run. Every Open Question resolved from evidence, four of them by
direct verification in the repository. The single stop for a missing input was not taken, because no input only the
user can supply was missing.

The one question this feature's planning did escalate was raised at specification time and is recorded as `E1` in
[team-findings.md](team-findings.md).

## Completeness gate

Run at Step 9 against the boundary record and the `ui-designs/` folder. Result recorded in the closing summary.
