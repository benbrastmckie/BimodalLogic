"""End-state / differential gate for task 400 (deprecation clearing).

Checks, against a `lake build` log plus the source tree:
  1. 0 errors; job count.
  2. Exactly ONE live sorry, located by CONTENT (the enclosing declaration name),
     never by line number -- the line has already drifted 1242 -> 1225.
  3. Frozen sibling-owned category counts hold by EQUALITY (not "no increase"), so that
     trespass into sibling territory is caught rather than read as a bonus.
  4. Source-level longLine count unchanged (`lake build` does not enable the mathlib
     style linters, so the category count alone is a vacuous check here).
  5. Declaration inventory unchanged -- catches renames and def->theorem conversions,
     both of which are the naming task's territory and forbidden here.
"""
import json
import os
import re
import subprocess
import sys

import lintlib

REPO = lintlib.REPO
EXPECTED_SORRY_DECL = 'countermodel_discrete'
EXPECTED_SORRY_FILE = 'Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean'

DECL_RE = re.compile(
    r'^(?:@\[[^\]]*\]\s*)?(?:private\s+|protected\s+|noncomputable\s+|partial\s+|unsafe\s+)*'
    r'(theorem|lemma|def|abbrev|instance|structure|inductive|class)\s+'
    r'([A-Za-z_][A-Za-z0-9_.\'!?]*)')


def lean_files():
    out = []
    for root, dirs, files in os.walk(os.path.join(REPO, 'Theories')):
        dirs[:] = [d for d in dirs if d != 'Boneyard']
        for fn in files:
            if fn.endswith('.lean'):
                out.append(os.path.relpath(os.path.join(root, fn), REPO))
    return sorted(out)


def decl_inventory():
    """(kind, name) multiset per file.  A rename or def->theorem flip changes this."""
    inv = {}
    for f in lean_files():
        got = []
        for ln in open(os.path.join(REPO, f), encoding='utf-8', errors='replace'):
            m = DECL_RE.match(ln)
            if m:
                got.append(f'{m.group(1)} {m.group(2)}')
        inv[f] = got
    return inv


def long_lines():
    n = 0
    for f in lean_files():
        for ln in open(os.path.join(REPO, f), encoding='utf-8', errors='replace'):
            if len(ln.rstrip('\n')) > 100:
                n += 1
    return n


def sorry_decl_names(logtext):
    """Map each `declaration uses sorry` warning to its ENCLOSING declaration name."""
    recs = [r for r in lintlib.parse_lake(logtext) if r.cat == '(sorry)']
    out = []
    for r in recs:
        src = open(os.path.join(REPO, r.file), encoding='utf-8',
                   errors='replace').read().split('\n')
        name = '(unknown)'
        for i in range(r.line - 1, -1, -1):
            m = DECL_RE.match(src[i])
            if m:
                name = m.group(2)
                break
        out.append((r.file, name))
    return out


def snapshot(logpath):
    raw = open(logpath, encoding='utf-8', errors='replace').read()
    recs = lintlib.parse_lake(raw)
    jobs = None
    m = re.search(r'Build completed successfully \((\d+) jobs\)', raw)
    if m:
        jobs = int(m.group(1))
    return {
        'jobs': jobs,
        'categories': dict(lintlib.census(recs)),
        'sorries': sorry_decl_names(raw),
        'long_lines': long_lines(),
        'decls': decl_inventory(),
    }


def check(base, cur, expect_deprecation=None):
    p = []
    if cur['categories'].get('(ERROR)'):
        p.append(f"{cur['categories']['(ERROR)']} ERROR(s) in build")
    if cur['jobs'] != base['jobs']:
        p.append(f"job count {base['jobs']} -> {cur['jobs']}")
    # sorry: exactly one, identified by content
    if len(cur['sorries']) != 1:
        p.append(f"expected exactly 1 live sorry, got {len(cur['sorries'])}: {cur['sorries']}")
    else:
        f, n = cur['sorries'][0]
        if f != EXPECTED_SORRY_FILE or n != EXPECTED_SORRY_DECL:
            p.append(f"sorry moved: expected {EXPECTED_SORRY_FILE}:{EXPECTED_SORRY_DECL}, got {f}:{n}")
    # frozen categories: EQUALITY
    for cat in sorted(set(base['categories']) | set(cur['categories'])):
        if cat == '(deprecation)':
            continue
        b, a = base['categories'].get(cat, 0), cur['categories'].get(cat, 0)
        if b != a:
            p.append(f"frozen category {cat} CHANGED {b} -> {a}")
    if expect_deprecation is not None:
        got = cur['categories'].get('(deprecation)', 0)
        if got != expect_deprecation:
            p.append(f"(deprecation) expected {expect_deprecation}, got {got}")
    if base['long_lines'] != cur['long_lines']:
        p.append(f"longLine (source-level, >100 chars) {base['long_lines']} -> {cur['long_lines']}")
    # declaration inventory
    for f in sorted(set(base['decls']) | set(cur['decls'])):
        b, a = base['decls'].get(f), cur['decls'].get(f)
        if b != a:
            bs, as_ = set(b or []), set(a or [])
            p.append(f"DECL INVENTORY changed in {f}: -{sorted(bs-as_)} +{sorted(as_-bs)}")
    return p


if __name__ == '__main__':
    mode = sys.argv[1]
    if mode == 'snap':
        json.dump(snapshot(sys.argv[2]), open(sys.argv[3], 'w'), indent=1, sort_keys=True)
        s = json.load(open(sys.argv[3]))
        print(f"jobs={s['jobs']} long_lines={s['long_lines']} sorries={s['sorries']}")
        print(lintlib.fmt_census(__import__('collections').Counter(s['categories'])))
    elif mode == 'check':
        base = json.load(open(sys.argv[2]))
        cur = snapshot(sys.argv[3])
        exp = int(sys.argv[4]) if len(sys.argv) > 4 else None
        probs = check(base, cur, exp)
        print(f"jobs={cur['jobs']} long_lines={cur['long_lines']} "
              f"deprecations={cur['categories'].get('(deprecation)', 0)} "
              f"sorries={cur['sorries']}")
        if probs:
            print('\nGATE FAILED:')
            for x in probs:
                print('  -', x)
            sys.exit(1)
        print('\nGATE PASSED')
