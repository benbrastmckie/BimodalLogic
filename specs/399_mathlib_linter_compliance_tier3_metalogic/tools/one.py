#!/usr/bin/env python3
"""Single-file sweep driver with an explicit, inspectable apply/lint loop.

Unlike `sweep.py`, this does NOT auto-revert on failure -- it leaves the applied file in
place so the offending break can be read, and keeps the pristine original in a sidecar so a
restore is one flag away.  Built for files whose elaboration is slow enough (SplitPoint.lean:
~2 min) that bisection over ~190 sites is impractical.

    python3 tools/one.py apply  FILE [--from-log LOG]   # apply fixers using a cached lint log
    python3 tools/one.py lint   FILE                    # lint, cache the log, print census
    python3 tools/one.py census FILE --from-log LOG     # census a cached log
    python3 tools/one.py restore FILE                   # put the sidecar original back
    python3 tools/one.py gate   FILE --before B --after A
"""

import argparse
import os
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lintlib  # noqa: E402
import fixers   # noqa: E402
import sweep    # noqa: E402

SIDE = '.orig399'


def full(path):
    return os.path.join(lintlib.REPO, path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('cmd', choices=['apply', 'lint', 'census', 'restore', 'gate', 'snapshot'])
    ap.add_argument('file')
    ap.add_argument('--from-log')
    ap.add_argument('--before')
    ap.add_argument('--after')
    ap.add_argument('--out')
    ap.add_argument('--cats', default=','.join(sweep.MECH))
    a = ap.parse_args()
    f = full(a.file)
    cats = [c for c in a.cats.split(',') if c]

    if a.cmd == 'snapshot':
        shutil.copyfile(f, f + SIDE)
        print('snapshot ->', f + SIDE)
        return 0

    if a.cmd == 'restore':
        shutil.copyfile(f + SIDE, f)
        print('restored from', f + SIDE)
        return 0

    if a.cmd == 'lint':
        raw = lintlib.run_lint(a.file)
        if a.out:
            open(a.out, 'w').write(raw)
        recs = lintlib.parse(raw)
        print(lintlib.fmt_census(lintlib.census(recs)))
        for r in lintlib.errors(recs)[:40]:
            print(f'ERROR {r.line}:{r.col}: {r.msg[:160]}')
        return 0

    raw = open(a.from_log).read() if a.from_log else lintlib.run_lint(a.file)
    recs = lintlib.parse(raw)

    if a.cmd == 'census':
        print(lintlib.fmt_census(lintlib.census(recs)))
        for r in lintlib.errors(recs)[:40]:
            print(f'ERROR {r.line}:{r.col}: {r.msg[:160]}')
        return 0

    if a.cmd == 'gate':
        b = lintlib.census(lintlib.parse(open(a.before).read()))
        c = lintlib.census(lintlib.parse(open(a.after).read()))
        ok, probs = lintlib.gate(b, c, in_scope_expected_zero=cats)
        print('GATE', 'PASS' if ok else 'FAIL')
        for p in probs:
            print('   ', p)
        return 0 if ok else 1

    # apply
    if not os.path.exists(f + SIDE):
        shutil.copyfile(f, f + SIDE)
    src = open(f + SIDE, encoding='utf-8').read()
    lines = src.split('\n')
    lines, nA, skA = sweep.apply_stage(lines, recs, [c for c in sweep.STAGE_A if c in cats])
    lines, nB, skB = sweep.apply_stage(lines, recs, [c for c in sweep.STAGE_B if c in cats])
    open(f, 'w', encoding='utf-8').write('\n'.join(lines))
    over = [(i + 1, len(l)) for i, l in enumerate(lines) if len(l) > fixers.LIMIT]
    print(f'applied stageA={nA} stageB={nB}; {len(over)} line(s) still over {fixers.LIMIT}')
    for s in (skA + skB)[:30]:
        print('  skipped', s)
    for ln, n in over[:30]:
        print(f'  over {ln}: {n} cols')
    return 0


if __name__ == '__main__':
    sys.exit(main() or 0)
