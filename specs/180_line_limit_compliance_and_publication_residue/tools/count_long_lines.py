#!/usr/bin/env python3
"""The single canonical, dependency-free codepoint counter for line-limit compliance.

Why this file exists at all
---------------------------
Two other ways of "counting long lines" are in circulation and BOTH are wrong here:

  * `awk 'length>100'` counts BYTES in a C/POSIX locale.  This codebase is dense in multi-byte
    notation (box, diamond, phi, psi, ->, bot, in, angle brackets), so awk reports ~2116 against
    a true codepoint count of 598.  Never use it as a gate.
  * The `linter.style.longLine` category count in a `lake build` log is ALWAYS zero, because
    `lake build` does not enable the Mathlib style linters.  Gating on it proves nothing.

So: read UTF-8, measure `len(str)` (codepoints), and reproduce the linter's own exemptions.

Exemptions, mirrored from Mathlib/Tactic/Linter/Style.lean (`Style.longLine`):
  * a line containing `http` anywhere is exempt (URLs are unbreakable);
  * a line that IS an import is exempt (`isImport`: the `import` / `public import` /
    `meta import` / `import all` / `public meta import` / `meta import all` prefixes).

Scope: FormalSystem/ and Tests/, with every `Boneyard` directory pruned (excluded from the
build, out of scope).

Usage:
    python3 count_long_lines.py                  # totals + per-area breakdown
    python3 count_long_lines.py --area Tests     # restrict to one area
    python3 count_long_lines.py --list           # one `file:line` per violation
    python3 count_long_lines.py --expect-nonzero # exit 1 if the total is 0 (anti-vacuity)
    python3 count_long_lines.py --root /path/to/repo
"""

import argparse
import os
import sys

LIMIT = 100
LIVE_ROOTS = ('FormalSystem', 'Tests')

IMPORT_PREFIXES = (
    'import ', 'public import ', 'meta import ', 'public meta import ',
    'import all ', 'meta import all ',
)


def find_repo_root(start):
    """Walk upward until a directory containing `lakefile.lean` is found."""
    cur = os.path.abspath(start)
    while True:
        if os.path.exists(os.path.join(cur, 'lakefile.lean')):
            return cur
        parent = os.path.dirname(cur)
        if parent == cur:
            raise RuntimeError(f'no lakefile.lean found walking upward from {start!r}')
        cur = parent


def is_exempt(line):
    """Mirror the linter's own exemptions."""
    if 'http' in line:
        return True
    return any(line.startswith(p) for p in IMPORT_PREFIXES)


# The `lean_lib FormalSystem` root aggregator lives at the REPOSITORY ROOT, not inside
# `FormalSystem/`.  Walking the two source directories alone silently omits it.  It happens to
# carry zero violations, so including it changes no count in this task -- but a counter whose
# correctness rests on "the file we forgot to look at happened to be clean" is exactly the
# defect class this harness exists to eliminate, so it is scanned explicitly.
# `scripts/check-module-invariants.sh` (C7) counts it the same way.
ROOT_AGGREGATORS = ('FormalSystem.lean',)


def lean_files(repo, roots=LIVE_ROOTS):
    out = []
    for top in roots:
        base = os.path.join(repo, top)
        if not os.path.isdir(base):
            continue
        for root, dirs, files in os.walk(base):
            dirs[:] = [d for d in dirs if d != 'Boneyard']
            for fn in files:
                if fn.endswith('.lean'):
                    out.append(os.path.relpath(os.path.join(root, fn), repo))
    out += [f for f in ROOT_AGGREGATORS if os.path.isfile(os.path.join(repo, f))]
    return sorted(out)


def area_of(relpath):
    """The three reporting areas the plan tracks separately."""
    if relpath.startswith('Tests/'):
        return 'Tests/'
    if relpath.startswith('FormalSystem/Automation/'):
        return 'FormalSystem/Automation/'
    return 'FormalSystem/ other'


def violations(repo, roots=LIVE_ROOTS):
    """[(relpath, lineno, codepoint_length)] over every live file."""
    out = []
    for f in lean_files(repo, roots):
        with open(os.path.join(repo, f), encoding='utf-8') as fh:
            for i, ln in enumerate(fh, start=1):
                ln = ln.rstrip('\n').rstrip('\r')
                if len(ln) > LIMIT and not is_exempt(ln):
                    out.append((f, i, len(ln)))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', default=None)
    ap.add_argument('--area', default=None,
                    help='restrict to one of: Tests/, FormalSystem/Automation/, '
                         '"FormalSystem/ other"')
    ap.add_argument('--list', action='store_true', help='print file:line:len per violation')
    ap.add_argument('--files', action='store_true', help='print per-file counts')
    ap.add_argument('--expect-nonzero', action='store_true',
                    help='exit 1 when the total is 0 (guards against a broken counter)')
    a = ap.parse_args()

    repo = a.root or find_repo_root(os.path.dirname(os.path.abspath(__file__)))
    vs = violations(repo)
    if a.area:
        vs = [v for v in vs if area_of(v[0]) == a.area]

    if a.list:
        for f, n, ln in vs:
            print(f'{f}:{n}:{ln}')

    per_file = {}
    per_area = {}
    for f, _n, _ln in vs:
        per_file[f] = per_file.get(f, 0) + 1
        ar = area_of(f)
        per_area[ar] = per_area.get(ar, 0) + 1

    if a.files:
        for f, n in sorted(per_file.items(), key=lambda kv: (-kv[1], kv[0])):
            print(f'{n:5d}  {f}')

    print(f'TOTAL {len(vs)} violations across {len(per_file)} files')
    for ar in ('FormalSystem/Automation/', 'Tests/', 'FormalSystem/ other'):
        n = per_area.get(ar, 0)
        nf = len({f for f, _, _ in vs if area_of(f) == ar})
        print(f'  {ar:28s} {n:5d} / {nf:3d} files')

    if a.expect_nonzero and not vs:
        print('FAIL: --expect-nonzero given but the total is 0. Either the tree is already '
              'clean or (far more likely at this point) the counter is broken.', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
