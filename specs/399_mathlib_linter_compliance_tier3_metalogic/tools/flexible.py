#!/usr/bin/env python3
"""Phase 2: clear `linter.flexible` by bulk `simp?` harvest.

Per file:
  1. clear `unusedSimpArgs` first (dead arguments shrink the lists `simp?` regenerates)
  2. inject `?` after EVERY flagged `simp` at once
  3. ONE elaboration harvests every `Try this: simp only [...]`
  4. reconcile suggestions to sites, then substitute
  5. re-lint and iterate to fixpoint

Reconciliation is by ORDER plus LOCATION-CLAUSE agreement, never by blind zip: the `Try this:`
blocks carry no position header of their own (they are appended to whatever diagnostic block
happened to precede them, often an unrelated `push_neg` deprecation), and a site inside a
branching proof elaborates more than once, so the suggestion stream is longer than the site
list (15-for-14 observed).  A run of suggestions sharing one site's `at ...` clause is unioned
into that site; the result is always verified by re-elaboration, never by count.
"""

import argparse
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lintlib   # noqa: E402
import fixers    # noqa: E402

APPLY_SIMP_RE = re.compile(r'^\s*\[apply\] (simp only.*)$', re.M)
OPENERS, CLOSERS = fixers.OPENERS, fixers.CLOSERS


def tactic_extent(ln, col):
    """End index of the simp invocation starting at `col` on this line."""
    depth = 0
    spans = fixers.string_spans(ln)
    i = col
    while i < len(ln):
        if fixers.in_spans(i, spans):
            i += 1
            continue
        c = ln[i]
        if c in OPENERS:
            depth += 1
        elif c in CLOSERS:
            if depth == 0:
                return i
            depth -= 1
        elif depth == 0:
            if c == ';':
                return i
            if c == ',':
                return i
            if ln.startswith('<;>', i):
                return i
        i += 1
    return len(ln)


def loc_clause(text):
    """The trailing ` at ...` location clause of a tactic, normalised; '' if absent."""
    depth = 0
    spans = fixers.string_spans(text)
    for i in range(len(text) - 3):
        if fixers.in_spans(i, spans):
            continue
        c = text[i]
        if c in OPENERS:
            depth += 1
        elif c in CLOSERS:
            depth = max(0, depth - 1)
        elif depth == 0 and text.startswith(' at ', i):
            return ' '.join(text[i:].split())
    return ''


def lemmas_of(sug):
    m = re.search(r'\[(.*)\]', sug)
    if not m:
        return []
    return [x.strip() for x in m.group(1).split(',') if x.strip()]


def reconcile(sites, sugs):
    """sites: [(line, col, text, loc)];  sugs: [str]  ->  {(line, col): replacement} | None."""
    out, j = {}, 0
    for k, (line, col, text, loc) in enumerate(sites):
        while j < len(sugs) and loc_clause(sugs[j]) != loc:
            j += 1                      # suggestion belongs to a site that produced none
        if j >= len(sugs):
            return None, f'ran out of suggestions at site {k + 1}/{len(sites)} ({line}:{col})'
        chosen = [sugs[j]]
        j += 1
        # absorb a re-elaboration of the SAME site: same loc, and the next site wants a
        # different loc (so the extra cannot belong to it)
        nxt = sites[k + 1][3] if k + 1 < len(sites) else None
        while (j < len(sugs) and loc_clause(sugs[j]) == loc and nxt != loc):
            chosen.append(sugs[j])
            j += 1
        if len(chosen) == 1:
            rep = chosen[0]
        else:
            union, seen = [], set()
            for s in chosen:
                for lm in lemmas_of(s):
                    if lm not in seen:
                        seen.add(lm)
                        union.append(lm)
            rep = f'simp only [{", ".join(union)}]' + (loc if loc else '')
        out[(line, col)] = rep
    return out, None


def clear_unused_simp_args(path, max_iter=3):
    full = os.path.join(lintlib.REPO, path)
    for _ in range(max_iter):
        recs = lintlib.parse(lintlib.run_lint(path))
        sub = [r for r in recs if r.cat == 'linter.unusedSimpArgs']
        if not sub:
            return recs
        lines = open(full, encoding='utf-8').read().split('\n')
        lines, n, _ = fixers.fix_unused_simp_args(lines, sub)
        if not n:
            return recs
        open(full, 'w', encoding='utf-8').write('\n'.join(lines))
    return lintlib.parse(lintlib.run_lint(path))


def pass_once(path, recs):
    """One harvest/apply cycle.  Returns (n_applied, error_or_None, new_records)."""
    full = os.path.join(lintlib.REPO, path)
    lines = open(full, encoding='utf-8').read().split('\n')
    keys = sorted({(r.line, r.col) for r in recs if r.cat == 'linter.flexible'})
    if not keys:
        return 0, None, recs

    sites = []
    for line, col in keys:
        ln = lines[line - 1]
        if ln[col:col + 4] != 'simp':
            return 0, f'site {line}:{col} is not a `simp` token: {ln[col:col + 12]!r}', recs
        text = ln[col:tactic_extent(ln, col)]
        sites.append((line, col, text, loc_clause(text)))

    inj = list(lines)
    for line, col, _, _ in reversed(sites):
        inj[line - 1] = inj[line - 1][:col] + 'simp?' + inj[line - 1][col + 4:]
    open(full, 'w', encoding='utf-8').write('\n'.join(inj))
    raw = lintlib.run_lint(path)
    open(full, 'w', encoding='utf-8').write('\n'.join(lines))       # always restore first

    hrecs = lintlib.parse(raw)
    if lintlib.errors(hrecs):
        return 0, 'harvest elaboration errored: ' + lintlib.errors(hrecs)[0].msg[:120], recs
    sugs = APPLY_SIMP_RE.findall(raw)
    mapping, err = reconcile(sites, sugs)
    if err:
        return 0, f'{err} (sites={len(sites)} suggestions={len(sugs)})', recs

    for line, col, text, _ in reversed(sites):
        ln = lines[line - 1]
        end = tactic_extent(ln, col)
        lines[line - 1] = ln[:col] + mapping[(line, col)] + ln[end:]
    open(full, 'w', encoding='utf-8').write('\n'.join(lines))
    return len(sites), None, lintlib.parse(lintlib.run_lint(path))


def do_file(path, max_iter=3):
    full = os.path.join(lintlib.REPO, path)
    original = open(full, encoding='utf-8').read()
    before = lintlib.census(lintlib.parse(lintlib.run_lint(path)))
    if before.get('(ERROR)'):
        return {'file': path, 'ok': False, 'reason': 'errors BEFORE sweep'}
    recs = clear_unused_simp_args(path)
    applied, iters = 0, 0
    for _ in range(max_iter):
        iters += 1
        n, err, recs = pass_once(path, recs)
        if err:
            open(full, 'w', encoding='utf-8').write(original)
            return {'file': path, 'ok': False, 'reason': err, 'before': dict(before)}
        applied += n
        after = lintlib.census(recs)
        if after.get('(ERROR)'):
            open(full, 'w', encoding='utf-8').write(original)
            errs = [f'{r.line}:{r.col}: {r.msg[:120]}' for r in lintlib.errors(recs)][:4]
            return {'file': path, 'ok': False, 'reason': 'errors introduced -- REVERTED',
                    'errors': errs, 'before': dict(before), 'after': dict(after)}
        if not after.get('linter.flexible'):
            break
    after = lintlib.census(recs)
    # `longLine` is EXPECTED to rise here: transcribed `simp only [...]` lists are longer than
    # the `simp` they replace.  Phases 4-6 own those sites, so exempt it from the gate.
    ok, problems = lintlib.gate(before, after,
                               in_scope_expected_zero=['linter.flexible'])
    problems = [p for p in problems if 'linter.style.longLine' not in p]
    if problems:
        open(full, 'w', encoding='utf-8').write(original)
        return {'file': path, 'ok': False, 'reason': 'gate failed -- REVERTED',
                'problems': problems, 'before': dict(before), 'after': dict(after)}
    return {'file': path, 'ok': True, 'applied': applied, 'iters': iters,
            'before': dict(before), 'after': dict(after)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('files', nargs='*')
    ap.add_argument('--from-list')
    ap.add_argument('--log')
    ap.add_argument('--force', action='store_true')
    a = ap.parse_args()

    files = list(a.files)
    if a.from_list:
        files += [l.split(None, 1)[-1].strip() for l in open(a.from_list) if l.strip()]

    done = {}
    if a.log and os.path.exists(a.log):
        for ln in open(a.log):
            if ln.strip():
                r = json.loads(ln)
                done[r['file']] = r
    logf = open(a.log, 'a') if a.log else None

    nfail = 0
    for i, f in enumerate(files, 1):
        if not a.force and done.get(f, {}).get('ok'):
            print(f'[{i}/{len(files)}] SKIP (done) {f}', flush=True)
            continue
        r = do_file(f)
        if logf:
            logf.write(json.dumps(r) + '\n')
            logf.flush()
        print(f'[{i}/{len(files)}] {"OK " if r["ok"] else "FAIL"} {f} '
              f'applied={r.get("applied", 0)} iters={r.get("iters", 0)}'
              f'{"" if r["ok"] else "  " + r.get("reason", "")}', flush=True)
        for p in r.get('problems', [])[:5]:
            print('        ', p, flush=True)
        for e in r.get('errors', [])[:5]:
            print('        ', e, flush=True)
        nfail += 0 if r['ok'] else 1
    print(f'\ndone: {len(files)} files, {nfail} failures')
    return 1 if nfail else 0


if __name__ == '__main__':
    sys.exit(main() or 0)
