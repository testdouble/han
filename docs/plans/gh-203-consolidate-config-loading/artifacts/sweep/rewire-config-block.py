#!/usr/bin/env python3
"""Issue-203 sweep: replace the per-skill config block with the one-line loader instruction.

Usage: rewire-config-block.py <repo-root> [--check]

For every shipped SKILL.md (every han-*/skills/*/SKILL.md), except the loader itself and
explanation-guidance (handled by hand), the script:
  1. removes the two config probe lines from `## Project Context`;
  2. replaces the 65-word instruction paragraph (matched with whitespace normalized, so the
     differently wrapped copy in ddd-analysis is caught) with the pinned line;
  3. removes the han-config-dir.sh grant from allowed-tools.
--check reports what would change and exits 1 if any file still carries an old piece afterwards.
"""
import glob, os, re, sys
root = sys.argv[1]; check = "--check" in sys.argv
LINE = "Resolve configuration with `han-core:load-han-config` if you have not already this run.\n"
PROBE1 = '- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`\n'
PROBE2 = '- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`\n'
GRANT = 'Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")'
PARA_WORDS = ("As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read "
    "that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md` "
    "probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence "
    "between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.").split()
para_re = re.compile(r"As your first action, use the Read tool on(?:.|\n)*?cannot be used\.\n")
SKIP = {"han-core/skills/load-han-config/SKILL.md", "han-communication/skills/explanation-guidance/SKILL.md"}
changed = []; leftovers = []
for path in sorted(glob.glob(os.path.join(root, "han-*/skills/*/SKILL.md"))):
    rel = os.path.relpath(path, root)
    if rel in SKIP: continue
    s = open(path).read(); orig = s
    m = para_re.search(s)
    if m and m.group(0).split() == PARA_WORDS:
        s = s[:m.start()] + LINE + s[m.end():]
    s = s.replace(PROBE1, "").replace(PROBE2, "")
    # grant: remove with its separator, whichever side it sits on
    s = re.sub(r",\s*" + re.escape(GRANT), "", s); s = re.sub(re.escape(GRANT) + r",\s*", "", s); s = s.replace(GRANT, "")
    s = re.sub(r"allowed-tools:\n\s*\n", "allowed-tools:\n", s)  # no empty continuation line
    s = re.sub(r"(\n## Project Context\n)\n+(" + re.escape(LINE.strip()) + ")", r"\1\n\2", s)
    if s != orig:
        changed.append(rel)
        if not check: open(path, "w").write(s)
    for piece, name in ((PROBE1, "probe1"), (PROBE2, "probe2"), (GRANT, "grant"), ("As your first action, use the Read tool", "paragraph")):
        if piece in s: leftovers.append(f"{rel}: {name}")
print(f"{'would change' if check else 'changed'} {len(changed)} files"); [print("  " + c) for c in changed]
if leftovers: print("LEFTOVERS:"); [print("  " + l) for l in leftovers]; sys.exit(1)
