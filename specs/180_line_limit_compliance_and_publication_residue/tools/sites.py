"""Regenerate deprecation site lists from a `lake build` log (task 400).

Uses lintlib.parse_lake (lake format: `severity: PATH:L:C: msg`), NOT lintlib.parse
(raw lean format: `PATH:L:C: severity: msg`).  Mixing the two matches nothing and
reports vacuous zeros.
"""
import re
import sys

import lintlib

# `X` has been deprecated ...   /   'Mod.Path' has been deprecated ...
SYM_RE = re.compile(r"^[`']([^`']+)[`'] has been deprecated")


def load(logpath):
    raw = open(logpath, encoding='utf-8', errors='replace').read()
    recs = lintlib.parse_lake(raw)
    out = []
    seen = set()
    for r in recs:
        if r.cat != '(deprecation)':
            continue
        m = SYM_RE.match(r.msg)
        sym = m.group(1) if m else '(?)' + r.msg[:40]
        k = (r.file, r.line, r.col)
        if k in seen:
            continue
        seen.add(k)
        out.append((r.file, r.line, r.col, sym))
    return out


if __name__ == '__main__':
    sites = load(sys.argv[1])
    outdir = sys.argv[2]
    pn = [s for s in sites if s[3] == 'push_neg']
    other = [s for s in sites if s[3] != 'push_neg']
    with open(f'{outdir}/push_neg_sites.txt', 'w') as f:
        for fp, l, c, _ in pn:
            f.write(f'{fp}|{l}|{c}\n')
    with open(f'{outdir}/other_sites.txt', 'w') as f:
        for fp, l, c, s in other:
            f.write(f'{fp}|{l}|{c}|{s}\n')
    print(f'total distinct sites : {len(sites)}')
    print(f'push_neg             : {len(pn)}   files={len({s[0] for s in pn})}')
    print(f'other                : {len(other)} files={len({s[0] for s in other})}')
    print(f'all files            : {len({s[0] for s in sites})}')
