#!/usr/bin/env python3
"""Dump every in-scope diagnostic (file:line:col, category, message, source line).

The Phase 7 bucket is judgment work, so the driver is a site list with the linter's own
wording and the offending source line, not a count.
"""
import argparse
import concurrent.futures
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lintlib  # noqa: E402


def one(path):
    return path, lintlib.parse(lintlib.run_lint(path))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('files', nargs='*')
    ap.add_argument('--from-census')
    ap.add_argument('--cats', default='')
    ap.add_argument('--jobs', type=int, default=10)
    ap.add_argument('--src', action='store_true', help='print the offending source line')
    a = ap.parse_args()
    want = set(c for c in a.cats.split(',') if c) or lintlib.IN_SCOPE
    files = list(a.files)
    if a.from_census:
        cen = json.load(open(a.from_census))
        files += [f for f, c in cen.items() if any(k in want and v for k, v in c.items())]
    files = sorted(set(files))
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as ex:
        for path, recs in ex.map(one, files):
            hits = [r for r in recs if r.cat in want]
            if not hits:
                continue
            src = open(os.path.join(lintlib.REPO, path), encoding='utf-8').read().split('\n')
            print(f'===== {path}')
            for r in sorted(hits, key=lambda r: (r.line, r.col)):
                print(f'  {r.line}:{r.col}  [{r.cat}]  {r.msg[:150]}')
                if a.src and r.line - 1 < len(src):
                    print(f'      | {src[r.line - 1]}')


if __name__ == '__main__':
    main()
