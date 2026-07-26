#!/usr/bin/env python3
"""Full 174-file per-file category census, parallelised, plus a differential diff.

    python3 tools/fullsweep.py --out logs/census-phaseN.json          # produce a census
    python3 tools/fullsweep.py --diff logs/census-phaseN.json         # diff vs baseline
    python3 tools/fullsweep.py --out X.json --diff-against baseline/per-file-categories.json

`lake env lean` takes no lake lock (it only sets env vars and execs `lean`), so the census
parallelises safely.  `lake build` does NOT and is always run serially, outside this tool.
"""

import argparse
import collections
import concurrent.futures
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lintlib  # noqa: E402

TASKDIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCOPE = os.path.join(TASKDIR, 'baseline', 'scope-tier3.txt')
BASELINE = os.path.join(TASKDIR, 'baseline', 'per-file-categories.json')


def census_one(path):
    recs = lintlib.parse(lintlib.run_lint(path))
    return path, dict(lintlib.census(recs))


def build_census(files, jobs):
    out = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
        for i, (p, c) in enumerate(ex.map(census_one, files), 1):
            out[p] = c
            if i % 25 == 0:
                print(f'  ...{i}/{len(files)}', file=sys.stderr, flush=True)
    return out


# the baseline's per-file-categories.json merges two sources: the per-file style lint AND the
# whole-library `lake exe runLinter` pass.  A style census can never reproduce the runLinter.*
# rows, and it splits the baseline's `(uncategorized)` 81 into the four message-text-matched
# categories.  Normalise both sides so the differential compares like with like.
DROP = ('runLinter.', 'linter.unusedDecidableInType', 'linter.unusedFintypeInType')
SPLIT_OF_UNCATEGORIZED = ('(rcases-unused-name)', '(rintro-try-this)',
                          'warn.classDefReducibility', '(sorry)', '(uncategorized)')


def totals(census, normalise=False):
    t = collections.Counter()
    for c in census.values():
        t.update(c)
    if normalise:
        for k in list(t):
            if k.startswith(DROP):
                del t[k]
    return t


def fold_uncat(t):
    """Collapse the four footer-less splits back into `(uncategorized)` for baseline compare."""
    t = collections.Counter(t)
    s = sum(t.pop(k, 0) for k in SPLIT_OF_UNCATEGORIZED)
    if s:
        t['(uncategorized)'] = s
    return t


def diff(base, new, fold=False):
    tb, tn = totals(base, normalise=True), totals(new, normalise=True)
    if fold:
        tb, tn = fold_uncat(tb), fold_uncat(tn)
    cats = sorted(set(tb) | set(tn), key=lambda c: -max(tb.get(c, 0), tn.get(c, 0)))
    print(f'{"category":38s} {"base":>7s} {"now":>7s} {"delta":>7s}')
    for c in cats:
        b, n = tb.get(c, 0), tn.get(c, 0)
        flag = ''
        if n > b:
            flag = '  <== INCREASED'
        elif c in lintlib.OUT_OF_SCOPE_FROZEN and n < b:
            flag = '  <== TRESPASS (frozen category reduced)'
        print(f'{c:38s} {b:7d} {n:7d} {n - b:+7d}{flag}')
    print()
    print(f'sorry tripwire: {tn.get("(sorry)", 0)} (must be exactly 1)')
    print(f'errors:         {tn.get("(ERROR)", 0)} (must be 0)')
    inscope_left = {c: n for c, n in tn.items() if c in lintlib.IN_SCOPE and n}
    print(f'in-scope categories remaining: {len(inscope_left)}')
    for c, n in sorted(inscope_left.items(), key=lambda kv: -kv[1]):
        print(f'    {n:6d}  {c}')
    return tb, tn


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out')
    ap.add_argument('--diff')
    ap.add_argument('--diff-against', default=BASELINE)
    ap.add_argument('--jobs', type=int, default=10)
    ap.add_argument('--files')
    ap.add_argument('--fold', action='store_true',
                    help='fold the four footer-less splits into (uncategorized) '
                         '-- required only when diffing against baseline/per-file-categories.json')
    a = ap.parse_args()

    if a.diff and not a.out:
        new = json.load(open(a.diff))
        diff(json.load(open(a.diff_against)), new, fold=a.fold)
        return

    files = [l.strip() for l in open(a.files or SCOPE) if l.strip()]
    print(f'censusing {len(files)} files with {a.jobs} workers...', file=sys.stderr)
    new = build_census(files, a.jobs)
    if a.out:
        json.dump(new, open(a.out, 'w'), indent=0, sort_keys=True)
        print(f'wrote {a.out}', file=sys.stderr)
    diff(json.load(open(a.diff_against)), new, fold=a.fold)


if __name__ == '__main__':
    main()
