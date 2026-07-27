#!/usr/bin/env python3
"""Driver: apply the mechanical fixers to a file list, differentially gated, resumable.

Usage:
    python3 tools/sweep.py --log logs/phase1.jsonl FILE [FILE ...]
    python3 tools/sweep.py --log logs/phase4.jsonl --from-list logs/phase4.files
    python3 tools/sweep.py --census-only FILE ...

Per file:
  1. lint  -> BEFORE census
  2. stage A (empty here: every line-count-preserving category is sibling-owned and frozen)
     stage B (longLine : line-count changing, applied bottom-up)
  3. re-lint -> AFTER census; iterate to fixpoint (max --max-iter passes)
  4. differential gate; on ERROR or on a category increase, REVERT the file and record failure
  5. append one JSON line to the completion log so an interrupted run resumes

The completion log is the resume point: files already present with ok=true are skipped
unless --force is given.
"""

import argparse
import concurrent.futures
import json
import os
import sys
import threading

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lintlib  # noqa: E402
import fixers   # noqa: E402

# SCOPE NARROWING (deliberate, do not "restore").
#
# The inherited stage lists were:
#     STAGE_A = ['linter.unusedSimpArgs', 'linter.style.show', 'linter.unusedVariables']
#     STAGE_B = ['linter.style.longLine', 'linter.style.emptyLine']
# Four of those five categories are owned by SIBLING tasks and are frozen by equality here, so
# running the inherited set would silently trespass -- and a *reduction* in a frozen category
# fails the gate exactly as an increase does.  Line-length compliance is the whole scope.
STAGE_A = []
STAGE_B = ['linter.style.longLine']
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
    recs = lintlib.lint(path)
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
            # Report what a real run WOULD do, without touching the file and without running
            # the differential gate (which would trivially fail: nothing was written, so the
            # in-scope count has not moved).  Phase 2's dry-run measurement depends on this.
            residual = sum(before.get(c, 0) for c in cats) - applied_total
            return {'file': path, 'ok': True, 'dry': True, 'applied': applied_total,
                    'residual': residual, 'iters': iters, 'before': dict(before),
                    'skipped': all_skipped[:40]}
        open(full, 'w', encoding='utf-8').write('\n'.join(lines))
        recs = lintlib.lint(path)
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


def _bisect(full, path, lines, cat, subset):
    """Largest prefix-stable subset of `subset` that elaborates cleanly.

    `subset` MUST be sorted by descending line, and the fixers apply bottom-up, so accepting
    an edit at a higher line never shifts the positions of the lower-line edits still to be
    tried.  That is what makes divide-and-conquer valid here at all.
    """
    if not subset:
        return lines, 0
    trial, n, _ = fixers.FIXERS[cat](list(lines), subset)
    if n:
        open(full, 'w', encoding='utf-8').write('\n'.join(trial))
        if not lintlib.errors(lintlib.lint(path)):
            return trial, len(subset)
    if len(subset) == 1:
        open(full, 'w', encoding='utf-8').write('\n'.join(lines))
        return lines, 0
    m = len(subset) // 2
    lines, a = _bisect(full, path, lines, cat, subset[:m])
    lines, b = _bisect(full, path, lines, cat, subset[m:])
    open(full, 'w', encoding='utf-8').write('\n'.join(lines))
    return lines, a + b


def sweep_file_bisect(path, cat, max_iter=3):
    """Apply one category by bisection, refusing only the individual sites that break."""
    full = os.path.join(lintlib.REPO, path)
    original = open(full, encoding='utf-8').read()
    before = lintlib.census(lintlib.lint(path))
    applied = 0
    for _ in range(max_iter):
        recs = lintlib.lint(path)
        sites = sorted([r for r in recs if r.cat == cat], key=lambda r: (-r.line, -r.col))
        if not sites:
            break
        lines = open(full, encoding='utf-8').read().split('\n')
        lines, n = _bisect(full, path, lines, cat, sites)
        open(full, 'w', encoding='utf-8').write('\n'.join(lines))
        applied += n
        if n == 0:
            break
    after = lintlib.census(lintlib.lint(path))
    ok, problems = lintlib.gate(before, after, in_scope_expected_zero=[])
    if not ok:
        open(full, 'w', encoding='utf-8').write(original)
        return 0, after.get(cat, before.get(cat, 0)), problems
    return applied, after.get(cat, 0), []


def sweep_file_sequential(path, cats, max_iter):
    """Fallback: apply ONE category at a time, each with its own gate and revert.

    Used when the all-categories sweep fails, so a single category that a file cannot take
    does not cost the file its other 100+ mechanical sites.  The refused categories become
    documented per-file residuals instead of a whole-file revert.
    """
    applied, refused = 0, []
    for cat in [c for c in fixers.ORDER if c in cats]:
        rec = sweep_file(path, [cat], max_iter)
        if rec['ok']:
            applied += rec.get('applied', 0)
        else:
            # salvage by bisection: refuse only the individual sites that break
            n, left, probs = sweep_file_bisect(path, cat, max_iter)
            applied += n
            refused.append({'cat': cat, 'reason': rec.get('reason'),
                            'problems': rec.get('problems', [])[:3],
                            'errors': rec.get('errors', [])[:3],
                            'bisect_applied': n, 'bisect_left': left,
                            'bisect_gate': probs[:3]})
    after = lintlib.census(lintlib.lint(path))
    return {'file': path, 'ok': not after.get('(ERROR)'), 'applied': applied,
            'iters': 1, 'sequential': True, 'refused': refused, 'after': dict(after),
            'reason': None if not refused else f'{len(refused)} categories refused'}


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
    ap.add_argument('--jobs', type=int, default=8)
    ap.add_argument('--sequential', action='store_true',
                    help='apply one category at a time, gating each (salvage mode)')
    a = ap.parse_args()

    files = list(a.files)
    if a.from_list:
        files += [l.strip() for l in open(a.from_list) if l.strip()]

    if a.census_only:
        for f in files:
            recs = lintlib.lint(f)
            print(f'== {f}')
            print(lintlib.fmt_census(lintlib.census(recs)))
        return

    cats = [c for c in a.cats.split(',') if c]
    done = load_done(a.log) if a.log else {}
    todo = [f for f in files if a.force or not done.get(f, {}).get('ok')]
    print(f'{len(files)} files, {len(files) - len(todo)} already done, '
          f'{len(todo)} to sweep with {a.jobs} workers', flush=True)
    logf = open(a.log, 'a') if a.log else None
    lock = threading.Lock()
    nfail = [0]
    counter = [0]

    def work(f):
        rec = (sweep_file_sequential(f, cats, a.max_iter) if a.sequential
               else sweep_file(f, cats, a.max_iter, dry=a.dry))
        with lock:
            counter[0] += 1
            if logf:
                logf.write(json.dumps(rec) + '\n')
                logf.flush()
            status = 'OK ' if rec['ok'] else 'FAIL'
            extra = '' if rec['ok'] else '  ' + rec.get('reason', '')
            print(f'[{counter[0]}/{len(todo)}] {status} {f} '
                  f'applied={rec.get("applied", 0)} iters={rec.get("iters", 0)}{extra}',
                  flush=True)
            if not rec['ok']:
                nfail[0] += 1
                for p in rec.get('problems', [])[:6]:
                    print('        ', p, flush=True)
                for e in rec.get('errors', [])[:6]:
                    print('        ', e, flush=True)
            for rf in rec.get('refused', []):
                print(f'         refused {rf["cat"]}: {rf["reason"]}'
                      f' -> bisect applied {rf.get("bisect_applied")}, '
                      f'{rf.get("bisect_left")} site(s) left'
                      f' {rf["problems"] or rf["errors"]}', flush=True)

    # `lake env lean` takes no lake lock, and a file's style census depends only on its own
    # source, so sweeping distinct files concurrently is safe.  `lake build` is NOT run here.
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as ex:
        list(ex.map(work, todo))
    print(f'\ndone: {len(todo)} files, {nfail[0]} failures')
    return 1 if nfail[0] else 0


if __name__ == '__main__':
    sys.exit(main() or 0)
