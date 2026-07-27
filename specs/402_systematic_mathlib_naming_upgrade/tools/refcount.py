#!/usr/bin/env python3
"""Count RESOLVED references to declarations, from the `.ilean` corpus.

Far more reliable than grep for "does anything still call this?": grep cannot distinguish a
call from a same-named local binder, a comment, or a longer identifier that merely contains the
name (47.2% of this project's declaration finals are a proper prefix of another identifier).

Usage: refcount.py <name-fragment-or-suffix> ...
Prints, per matching declaration: total usages, usages outside its own defining module,
usages outside Boneyard, and the defining site.
"""
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ilean import REPO, iter_ileans, parse_key

def main():
    want = sys.argv[1:]
    defs = {}
    usages = defaultdict(list)
    for _p, data, src in iter_ileans():
        mod = data["module"]
        for key, val in data["references"].items():
            _dm, fqn = parse_key(key)
            if not fqn:
                continue
            if val.get("definition"):
                defs[fqn] = (str(src.relative_to(REPO)), val["definition"][0] + 1)
            for u in val.get("usages") or []:
                usages[fqn].append((mod, str(src.relative_to(REPO)), u[0] + 1))
    for w in want:
        hits = [n for n in set(list(defs) + list(usages))
                if n == w or n.endswith("." + w)]
        if not hits:
            print(f"{w}: NO SUCH DECLARATION")
            continue
        for n in sorted(hits):
            us = usages.get(n, [])
            d = defs.get(n)
            own = d[0] if d else None
            ext = [u for u in us if u[1] != own]
            live = [u for u in ext if "/Boneyard/" not in u[1]]
            print(f"{n}")
            print(f"    defined: {d[0]}:{d[1]}" if d else "    defined: (no definition range)")
            print(f"    usages: {len(us)} total | {len(ext)} outside defining file | {len(live)} outside Boneyard")
            for u in sorted({(x[1], x[2]) for x in live})[:12]:
                print(f"      {u[0]}:{u[1]}")

main()
