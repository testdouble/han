# Feature Technical Notes: Per-Plugin Release Tags

Four mechanics are captured here because a behavior in the specification is only correct because of them, and none is
discoverable by reading this repository. Three describe how an external command line behaves, and one describes the
operator's shell.

## T1: Resolving the Claude Code executable

- **Context:** The specification commits to a release that interrupts the maintainer only at its own stops — the tag
  approval, and the version confirmation when the version plan needs it — rather than once per plugin ("User
  Interactions"). That commitment holds only if the tagging command is the executable and not a shell wrapper around
  it.
- **Technical detail:** `claude` is commonly wrapped by a shell function or alias rather than being the executable on
  the path. On the machine this plan was written on, `claude` resolves to a zsh function that runs `select` over two
  configuration profiles and blocks waiting for a numbered answer on the terminal, then calls `command claude` with the
  chosen profile. A tagging step that invokes `claude` through a shell hangs there with no output. Invoke the executable
  directly, either through the resolved binary path (`/opt/homebrew/bin/claude` on this machine) or by prefixing the
  call so shell function lookup is bypassed. Verified: `claude plugin tag --help` through the shell blocked past a
  120-second timeout, while `/opt/homebrew/bin/claude plugin tag --help` returned the usage text immediately.
- **Supports decisions:** D3, D11
- **Driven by findings:** F11
- **Referenced in spec:** Primary Flow, User Interactions

## T2: Telling an existing tag apart from a failure

- **Context:** The specification splits a plugin that is already tagged into two states with different consequences: a
  tag confirmed on GitHub is skipped, and a tag present only on the maintainer's machine must reach GitHub before the
  run may publish ("Alternate Flows and States"). The tagging command reports neither state directly.
- **Technical detail:** `claude plugin tag` exits 1 for both refusals and genuine failures, so the exit status alone
  cannot separate them. The already-exists case is identified by its message on the error stream, which reads
  `Tag "{name}--v{version}" already exists locally.` followed by a suggestion to bump the version or use the force flag.
  Genuine failures produce different messages with the same exit status: `Uncommitted changes affecting this release`,
  `No plugin manifest found.`, and `Path not found: {path}` were each observed at exit 1. Match the already-exists
  message specifically and treat every other non-zero exit as a stop.

  The word "locally" in that message is literal, and the command does **not** consult the remote. Verified in an
  isolated clone whose remote held `han-linear--v1.1.0` while the local clone did not: the command raised no objection
  and planned to create the tag. So the command's silence says nothing about GitHub in either direction, and the two
  states the specification distinguishes have to be established by reading the remote tag list separately.
- **Supports decisions:** D4, D5
- **Driven by findings:** F2, F7
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes

## T3: Reading a previous release across both naming schemes

- **Context:** The specification commits to a first release under the new naming whose changelog covers only the commits
  since the previous release ("Alternate Flows and States"), and to a parent version bumped from the right starting
  number on every release after it ("Primary Flow", step 2).
- **Technical detail:** The two tag patterns are mutually exclusive, so one lookup cannot find both. `git tag -l
  'v*.*.*'` does not match `han--v5.0.0`, and `git tag -l 'han--v*'` does not match `v4.6.0`. The parent-plugin pattern
  is also narrower than it looks: `han--v*` does not match any child plugin's tags, because the child names carry a
  single hyphen before their own `--v` separator (`han-core--v3.0.0`). Sorting with `--sort=-v:refname` orders correctly
  across the constant prefix, verified on synthetic tags where `han--v10.0.0` sorted above `han--v5.10.0`, `han--v5.9.0`,
  and `han--v5.0.0`. The lookup is therefore: newest `han--v*`, else newest `v*.*.*`, else no previous release.

  The version has to be parsed back out of whichever tag is found, and the existing rule strips only a leading `v`. That
  rule is correct for `v4.6.0` and silently wrong for `han--v5.0.0`, where it returns the tag string unchanged. The
  parsed value is not cosmetic: it is the parent's baseline, and it feeds the version comparison that decides whether to
  use the manifest version as-is or compute a bump from the baseline. A tag string on the left of that comparison makes
  the whole version plan meaningless, and it does so on the second release under the new naming rather than the first.
- **Supports decisions:** D7
- **Driven by findings:** F4, F15
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

## T4: A failed push leaves the tag on the machine

- **Context:** The specification commits to reporting, after a partial push, which tags reached GitHub and which exist
  only locally, and to a separate failure row saying that pushing is not the recovery when the remote already holds the
  tag at a different commit ("Edge Cases and Failure Modes").
- **Technical detail:** `claude plugin tag --push` creates the tag first and pushes second, and the upstream
  documentation states that "if the push fails, the tag is still created locally and the command exits with an error".
  Verified: a rejected push produced `✘ Tag created locally but push failed (exit 1)` and left the local tag in place.
  The remote it pushes to is `origin` unless `--remote` names another.

  Two consequences follow, and they pull in opposite directions. For an ordinary push failure the local tag is correct,
  so recovery is a push and never a re-tag. But re-running the command does not perform that push: it meets the
  already-exists refusal from T2 and stops. So a re-run is not a recovery path, and a run that treats the refusal as a
  benign skip will walk past every stranded tag and publish.

  When the remote already holds the tag at a different commit, recovery by pushing is impossible rather than merely
  awkward. Verified in an isolated clone: the push was rejected with `! [rejected] ... (already exists)` and
  `hint: Updates were rejected because the tag already exists in the remote`, and a local tag was left behind pointing
  at a different commit than the remote one. The rejection repeats identically on every attempt.
- **Supports decisions:** D5, D9, D10
- **Driven by findings:** F1, F2, F7
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes
