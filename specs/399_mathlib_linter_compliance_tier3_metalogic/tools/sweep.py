#!/usr/bin/env python3
"""Driver: apply the mechanical fixers to a file list, differentially gated, resumable.

Usage:
    python3 tools/sweep.py --log logs/phase1.jsonl FILE [FILE ...]
    python3 tools/sweep.py --log logs/phase4.jsonl --from-list logs/phase4.files
    python3 tools/sweep.py --census-only FILE ...

Per file:
  1. lint  -> BEFORE census
  2. stage A (unusedSimpArgs, show, unusedVariables : line-count preserving, bottom-up)
     stage B (longLine, emptyLine                  : line-count changing,   bottom-up)
  3. re-lint -> AFTER census; iterate to fixpoint (max --max-iter passes)
  4. differential gate; on ERROR or on a category increase, REVERT the file and record failure
  5. append one JSON line to the completion log so an interrupted run resumes

The completion log is the resume point: files already present with ok=true are skipped
unless --force is given.
"""

import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lintlib  # noqa: E402
import fixers   # noqa: E402

STAGE_A = ['linter.unusedSimpArgs', 'linter.style.show', 'linter.unusedVariables']
STAGE_B = ['linter.style.longLine', 'linter.style.emptyLine']
MECH = STAGE_A + STAGE_B


def load_done(logpath):
    done = {}
    if os.path.exists(logpath):
        for ln in open(logpath):
            ln = ln.strip()
            if not ln:
                continue
            try:
                rec = json.loads(ln)
            except json.JSONDecodeError:
                continue
            done[rec['file']] = rec
    return done


def apply_stage(lines, recs, cats):
    total, skipped = 0, []
    for cat in cats:
        sub = [r for r in recs if r.cat == cat]
        if not sub:
            continue
        lines, n, sk = fixers.FIXERS[cat](lines, sub)
        total += n
        skipped += [(cat,) + tuple(s) for s in sk]
    return lines, total, skipped


def sweep_file(path, cats, max_iter, dry=False):
    full = os.path.join(lintlib.REPO, path)
    original = open(full, encoding='utf-8').read()
    raw = lintlib.run_lint(path)
    recs = lintlib.parse(raw)
    before = lintlib.census(recs)
    if before.get('(ERROR)'):
        return {'file': path, 'ok': False, 'reason': 'file had errors BEFORE sweep',
                'before': dict(before)}

    active = [c for c in cats if before.get(c)]
    if not active:
        return {'file': path, 'ok': True, 'clean': True, 'applied': 0,
                'before': dict(before), 'after': dict(before)}

    applied_total, all_skipped, iters = 0, [], 0
    after = before
    for it in range(max_iter):
        iters = it + 1
        lines = open(full, encoding='utf-8').read().split('\n')
        lines, nA, skA = apply_stage(lines, recs, [c for c in STAGE_A if c in cats])
        lines, nB, skB = apply_stage(lines, recs, [c for c in STAGE_B if c in cats])
        n = nA + nB
        all_skipped += skA + skB
        if n == 0:
            break
        applied_total += n
        if dry:
            break
        open(full, 'w', encoding='utf-8').write('\n'.join(lines))
        raw = lintlib.run_lint(path)
        recs = lintlib.parse(raw)
        after = lintlib.census(recs)
        if after.get('(ERROR)'):
            open(full, 'w', encoding='utf-8').write(original)
            errs = [f'{r.line}:{r.col}: {r.msg[:120]}' for r in lintlib.errors(recs)][:6]
            return {'file': path, 'ok': False, 'reason': 'errors introduced -- REVERTED',
                    'errors': errs, 'before': dict(before), 'after': dict(after),
                    'iters': iters, 'applied': applied_total}
        if not any(after.get(c) for c in cats):
            break

    ok, problems = lintlib.gate(before, after, in_scope_expected_zero=cats)
    if not ok:
        open(full, 'w', encoding='utf-8').write(original)
        return {'file': path, 'ok': False, 'reason': 'gate failed -- REVERTED',
                'problems': problems, 'before': dict(before), 'after': dict(after),
                'iters': iters, 'applied': applied_total, 'skipped': all_skipped[:20]}
    return {'file': path, 'ok': True, 'applied': applied_total, 'iters': iters,
            'before': dict(before), 'after': dict(after),
            'skipped': all_skipped[:20]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('files', nargs='*')
    ap.add_argument('--from-list')
    ap.add_argument('--log', default=None)
    ap.add_argument('--cats', default=','.join(MECH))
    ap.add_argument('--max-iter', type=int, default=4)
    ap.add_argument('--force', action='store_true')
    ap.add_argument('--census-only', action='store_true')
    ap.add_argument('--dry', action='store_true')
    a = ap.parse_args()

    files = list(a.files)
    if a.from_list:
        files += [l.strip() for l in open(a.from_list) if l.strip()]

    if a.census_only:
        for f in files:
            recs = lintlib.parse(lintlib.run_lint(f))
            print(f'== {f}')
            print(lintlib.fmt_census(lintlib.census(recs)))
        return

    cats = [c for c in a.cats.split(',') if c]
    done = load_done(a.log) if a.log else {}
    logf = open(a.log, 'a') if a.log else None
    nfail = 0
    for i, f in enumerate(files, 1):
        if not a.force and f in done and done[f].get('ok'):
            print(f'[{i}/{len(files)}] SKIP (done) {f}', flush=True)
            continue
        rec = sweep_file(f, cats, a.max_iter, dry=a.dry)
        if logf:
            logf.write(json.dumps(rec) + '\n')
            logf.flush()
        status = 'OK ' if rec['ok'] else 'FAIL'
        extra = '' if rec['ok'] else '  ' + rec.get('reason', '')
        print(f'[{i}/{len(files)}] {status} {f} applied={rec.get("applied", 0)} '
              f'iters={rec.get("iters", 0)}{extra}', flush=True)
        if not rec['ok']:
            nfail += 1
            for p in rec.get('problems', [])[:6]:
                print('        ', p, flush=True)
            for e in rec.get('errors', [])[:6]:
                print('        ', e, flush=True)
    print(f'\ndone: {len(files)} files, {nfail} failures')
    return 1 if nfail else 0


if __name__ == '__main__':
    sys.exit(main() or 0)
