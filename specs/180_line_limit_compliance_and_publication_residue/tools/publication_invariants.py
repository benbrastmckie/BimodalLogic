#!/usr/bin/env python3
"""The two 'verified no-work' publication invariants, checked so they cannot pass vacuously.

Both are recorded as VERIFIED AT COMPLETION, not as work performed -- but a check that would
report the desired answer even when broken is worth nothing, so each carries a positive control.

1. Copyright headers: every live `.lean` file carries a `Copyright` line in its first three
   lines.  Reported as N/N over the SAME file walk the compliance counter uses, so the
   denominator cannot silently drift.

2. Universe polymorphism: zero `universe` declarations in the live tree.  This MUST strip
   comments first.  A raw `grep -E '^\\s*universe\\s'` returns hits that are all line-wrapped
   ENGLISH PROSE inside docstrings -- a sentence that happens to wrap onto a line beginning
   with the word "universe".  The empty set is the finding; the comment stripping is what makes
   it a finding rather than an artefact.

Usage:
    python3 publication_invariants.py [--root REPO]
"""

import argparse
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import count_long_lines  # noqa: E402
import fixers  # noqa: E402

UNIVERSE_RE = re.compile(r'^\s*universe\s')


def strip_comments(lines):
    """Blank out `--` line comments and `/- … -/` block comments, keeping line numbering.

    Reuses the sweep harness's own `comment_line_map` (nested block comments, string-aware) and
    `trailing_comment_index` rather than re-deriving a second, subtly different notion of what
    a comment is.
    """
    inblock = fixers.comment_line_map(lines)
    out = []
    for i, ln in enumerate(lines):
        if inblock[i]:
            out.append('')
            continue
        tc = fixers.trailing_comment_index(ln, False)
        code = ln if tc is None else ln[:tc]
        # a line that OPENS a block comment: keep only what precedes the `/-`
        j = code.find('/-')
        if j != -1 and not fixers.in_spans(j, fixers.string_spans(code)):
            code = code[:j]
        out.append(code)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', default=None)
    a = ap.parse_args()
    repo = a.root or count_long_lines.find_repo_root(os.path.dirname(os.path.abspath(__file__)))
    files = count_long_lines.lean_files(repo)

    # --- 1. copyright ------------------------------------------------------------------
    with_hdr, without = 0, []
    for f in files:
        with open(os.path.join(repo, f), encoding='utf-8', errors='replace') as fh:
            head = [next(fh, '') for _ in range(3)]
        if any('Copyright' in ln for ln in head):
            with_hdr += 1
        else:
            without.append(f)
    print(f'COPYRIGHT   {with_hdr}/{len(files)} live .lean files carry a header '
          f'in their first three lines')
    for f in without:
        print(f'    MISSING  {f}')

    # --- 2. universe polymorphism ------------------------------------------------------
    raw_hits, real_hits = [], []
    for f in files:
        lines = open(os.path.join(repo, f), encoding='utf-8',
                     errors='replace').read().split('\n')
        stripped = strip_comments(lines)
        for i, ln in enumerate(lines):
            if UNIVERSE_RE.match(ln):
                raw_hits.append((f, i + 1, ln.strip()))
        for i, ln in enumerate(stripped):
            if UNIVERSE_RE.match(ln):
                real_hits.append((f, i + 1, lines[i].strip()))
    print(f'UNIVERSE    {len(real_hits)} declaration(s) after comment stripping '
          f'({len(raw_hits)} raw grep hit(s) before it)')
    for f, n, t in raw_hits:
        verdict = 'DECLARATION' if (f, n, t) in [(x, y, z) for x, y, z in real_hits] \
            else 'prose inside a comment'
        print(f'    raw hit  {f}:{n}  [{verdict}]  {t[:72]}')
    for f, n, t in real_hits:
        print(f'    REAL     {f}:{n}  {t[:72]}')

    # --- positive controls: prove the stripper is not simply blanking everything --------
    probe = ['universe u', '-- universe u', '/- universe u -/', 'def f := 1']
    got = strip_comments(probe)
    ok = (UNIVERSE_RE.match(got[0]) and not UNIVERSE_RE.match(got[1])
          and not UNIVERSE_RE.match(got[2]) and got[3].strip() == 'def f := 1')
    print(f'CONTROL     comment stripper keeps real code and drops commented code: '
          f'{"PASS" if ok else "FAIL"}')
    if not ok:
        print(f'    probe -> {got!r}')
        return 1
    if len(files) == 0:
        print('CONTROL     FAIL: zero files walked; every result above is vacuous')
        return 1
    return 0 if (with_hdr == len(files) and not real_hits) else 1


if __name__ == '__main__':
    sys.exit(main())
