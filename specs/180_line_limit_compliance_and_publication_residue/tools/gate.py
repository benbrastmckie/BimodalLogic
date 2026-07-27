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

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lintlib  # noqa: E402
import count_long_lines  # noqa: E402

# REPO is module-level state so that `--root` can point the whole gate at a throwaway git
# worktree of the pre-task commit.  That is what makes the final zero MEANINGFUL: the same
# unchanged counter must still report 598/65 against the baseline tree, proving it reached zero
# because the tree changed and not because the counter broke.
REPO = lintlib.REPO
EXPECTED_SORRY_DECL = 'countermodel_discrete'
EXPECTED_SORRY_FILE = 'FormalSystem/Metalogic/WeakCanonical/Transfer.lean'

DECL_RE = re.compile(
    r'^(?:@\[[^\]]*\]\s*)?(?:private\s+|protected\s+|noncomputable\s+|partial\s+|unsafe\s+)*'
    r'(theorem|lemma|def|abbrev|instance|structure|inductive|class)\s+'
    r'([A-Za-z_][A-Za-z0-9_.\'!?]*)')


def lean_files(repo=None):
    """Every LIVE `.lean` file -- delegated to the canonical counter's own file walk.

    Both source roots plus the repository-root `FormalSystem.lean` aggregator, Boneyard
    pruned.  Sharing one walk with `count_long_lines` is the point: two independent notions of
    "the live tree" is how a file gets silently left out of a compliance claim.
    """
    out = count_long_lines.lean_files(repo or REPO)
    if not out:
        raise RuntimeError(
            f'lean_files() found 0 files under {lintlib.LIVE_ROOTS!r} in {repo or REPO} -- '
            'refusing to gate against a vacuous empty tree')
    return out


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
    """Delegate to the ONE canonical codepoint counter -- never re-implement it here.

    `open(..., encoding='utf-8')` already yields `str`, so `len()` was codepoints and not
    bytes; the real defect was that this had a second, exemption-free definition of the count
    that could silently disagree with every other verification step in the plan.
    """
    return len(count_long_lines.violations(REPO))


def long_lines_by_area():
    per = {}
    for f, _n, _ln in count_long_lines.violations(REPO):
        ar = count_long_lines.area_of(f)
        per[ar] = per.get(ar, 0) + 1
    return per


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
    files = lean_files()
    return {
        'jobs': jobs,
        'categories': dict(lintlib.census(recs)),
        'sorries': sorry_decl_names(raw),
        'long_lines': long_lines(),
        'long_lines_by_area': long_lines_by_area(),
        'live_files': len(files),
        'live_files_by_root': {r: len([f for f in files if f.startswith(r + '/')])
                               for r in lintlib.LIVE_ROOTS},
        'copyright_files': copyright_count(),
        'decls': decl_inventory(),
    }


def copyright_count():
    """Live files carrying a `Copyright` line within their first three lines."""
    n = 0
    for f in lean_files():
        with open(os.path.join(REPO, f), encoding='utf-8', errors='replace') as fh:
            head = [next(fh, '') for _ in range(3)]
        if any('Copyright' in ln for ln in head):
            n += 1
    return n


def check(base, cur, expect_long_lines=None):
    """Differential gate.

    longLine is THIS task's in-scope category, so it is expected to fall; every other category
    is sibling-owned and held by EQUALITY -- a reduction is trespass, not a bonus.
    """
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
            p.append(f'sorry moved: expected {EXPECTED_SORRY_FILE}:{EXPECTED_SORRY_DECL}, '
                     f'got {f}:{n}')
    # every lake-build-visible category is sibling-owned here: EQUALITY, both directions.
    # (longLine never appears in a lake build log -- lake build does not enable the mathlib
    # style linters -- so it cannot be checked here.  That is what long_lines is for.)
    for cat in sorted(set(base['categories']) | set(cur['categories'])):
        b, a = base['categories'].get(cat, 0), cur['categories'].get(cat, 0)
        if b != a:
            p.append(f'frozen category {cat} CHANGED {b} -> {a}')
    # long lines: source-level, codepoint-correct, in scope -- must never INCREASE
    if cur['long_lines'] > base['long_lines']:
        p.append(f"longLine INCREASED {base['long_lines']} -> {cur['long_lines']}")
    if expect_long_lines is not None and cur['long_lines'] != expect_long_lines:
        p.append(f"longLine expected {expect_long_lines}, got {cur['long_lines']}")
    # publication invariants
    if cur['live_files'] != base['live_files']:
        p.append(f"live file count {base['live_files']} -> {cur['live_files']}")
    if cur['copyright_files'] != cur['live_files']:
        p.append(f"copyright headers {cur['copyright_files']}/{cur['live_files']} "
                 f"-- not every live file carries one")
    # declaration inventory
    for f in sorted(set(base['decls']) | set(cur['decls'])):
        b, a = base['decls'].get(f), cur['decls'].get(f)
        if b != a:
            bs, as_ = set(b or []), set(a or [])
            p.append(f'DECL INVENTORY changed in {f}: -{sorted(bs-as_)} +{sorted(as_-bs)}')
    return p


def _report(s):
    print(f"jobs={s['jobs']} live_files={s['live_files']} "
          f"({s['live_files_by_root']}) copyright={s['copyright_files']}")
    print(f"long_lines={s['long_lines']} by_area={s['long_lines_by_area']}")
    print(f"sorries={s['sorries']}")


if __name__ == '__main__':
    argv = sys.argv[1:]
    if argv and argv[0] == '--root':
        REPO = os.path.abspath(argv[1])
        argv = argv[2:]
    mode = argv[0]
    sys.argv = ['gate.py'] + argv
    if mode == 'snap':
        json.dump(snapshot(sys.argv[2]), open(sys.argv[3], 'w'), indent=1, sort_keys=True)
        s = json.load(open(sys.argv[3]))
        _report(s)
        print(lintlib.fmt_census(__import__('collections').Counter(s['categories'])))
    elif mode == 'check':
        base = json.load(open(sys.argv[2]))
        cur = snapshot(sys.argv[3])
        exp = int(sys.argv[4]) if len(sys.argv) > 4 else None
        probs = check(base, cur, exp)
        _report(cur)
        if probs:
            print('\nGATE FAILED:')
            for x in probs:
                print('  -', x)
            sys.exit(1)
        print('\nGATE PASSED')
