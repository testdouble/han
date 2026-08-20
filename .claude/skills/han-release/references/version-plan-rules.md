# Per-Plugin Version Plan Rules

This file defines how a release run establishes each plugin's baseline version, classifies the size of its change, and
decides its target version. It is loaded by `SKILL.md` Step 3, which applies the governing rules there and then confirms
the resulting plan at 3d.

## 3a. Classify each plugin

For each plugin, read `current` from `{source}/.claude-plugin/plugin.json` and compute `baseline`:

- **Child, did not exist at `prev`** (`git cat-file -e {prev}:{source}/.claude-plugin/plugin.json` fails, or this is the
  first release): **new plugin**. `baseline = current`, `target = current`, **no bump**, mark it `new`. Skip the rest of
  the classification for this plugin.
- **Child, existed at `prev`**: `baseline = git show {prev}:{source}/.claude-plugin/plugin.json | jq -r .version`.
- **Parent**: `baseline = prev#` (the parent's version is what the tag tracks, regardless of any directory move). On the
  first release `baseline` is empty and the parent is treated like a new plugin set to its `current` value.

Determine whether the plugin **changed** in `{range}`:

- **Child**: changed when `git diff --name-only {prev}..HEAD -- {source}/` is non-empty.
- **Parent**: always treated as changed (it always bumps). Its change _level_ is computed in 3b from the whole release,
  not just `{parent source}/`.

## 3b. Compute each changed plugin's bump level and target

For a **changed child**, classify the highest-priority change inside `{source}/`:

- **major** — a skill directory under `{source}/skills/` was removed or renamed (renaming breaks `/skill-name`), an
  agent under `{source}/agents/` was removed or renamed, or a commit indicates a breaking behavior change (`!` in the
  type, `BREAKING CHANGE`, a review skill that now auto-posts, and so on). Inspect
  `git diff --name-status {range} -- {source}/` for `D`/`R` on `SKILL.md` or agent paths, and scan commit subjects
  scoped to that plugin.
- **minor** — a new skill, a new agent, a new `references/` file, or a new optional capability was added inside
  `{source}/`, with no major change present. Inspect the same diff for added `SKILL.md` / agent files.
- **patch** — only typo, permission, edge-case, or context-injection fixes inside `{source}/`.

For the **parent**, the bump level is the maximum across the whole release:

- a child was **removed** from the suite → **major** (breaking for anyone who installed the meta-plugin).
- any changed child's level is **major** → **major**.
- a **new** child plugin was introduced, or any changed child's level is **minor** → at least **minor** (a new or
  expanded capability reaches suite installers).
- otherwise (only child patches, or only repo-level/`{parent source}/` doc and config fixes) → **patch**.

Take the highest of those. Repo-root changes that do not live inside any plugin directory (for example `docs/`,
`README.md`, `CONTRIBUTING.md`) are suite-level: they count toward the parent's level (normally patch) and never bump a
child.

Compute `proposed` from each plugin's `baseline`: major → `(x+1).0.0`, minor → `x.(y+1).0`, patch → `x.y.(z+1)`.

## 3c. Decide each plugin's target (ahead path vs. compute path)

For each changed plugin, compare `current` to `baseline`:

```
highest=$(printf '%s\n%s\n' "{baseline}" "{current}" | sort -V | tail -n1)
```

- **`current` strictly ahead of `baseline`** (`highest` == `current` and `current` != `baseline`): the version was
  already bumped during development. **`target = current`. No confirmation for this plugin.** Still compute the expected
  `proposed`, and if `current` is a _lower_ level of bump than the changes warrant, add one non-blocking advisory line
  to the Step 7 summary.
- **`current` equal to or behind `baseline`**: the one-bump-per-branch bump has not been applied for this plugin.
  `target = proposed`; this plugin **needs confirmation**.
