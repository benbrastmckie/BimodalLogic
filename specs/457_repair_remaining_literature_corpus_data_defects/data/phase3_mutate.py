#!/usr/bin/env python3
"""Phase 3 mutation: SCOPE 3 bulk token_count re-baseline.

Target set = every entry in the (regenerated, post-Phase-2) scope3-drift.tsv worklist, UNION
the full 12-entry baier_katoen_2008_partNN set. The union is deliberate: the plan's Phase 3 Goal
explicitly names "including the 12 baier_katoen_2008_partNN entries sharing one placeholder
value" as in-scope regardless of the generic ±20% filter, and Phase 3 Verification separately
requires "The 12 baier_katoen_2008_partNN entries now carry 12 distinct values" -- a threshold-
independent requirement. Live recomputation found only 8 of the 12 cross the generic >20%
threshold (parts 04, 06, 07, 12 sit at ratios 1.194/1.182/1.159/0.911, just inside the band) --
this script folds all 12 in explicitly so the verification's "12 distinct values" clause holds.
"""
import json
import os
from pathlib import Path

LIT_DIR = Path(os.path.expanduser("~/Projects/Literature"))
INDEX_PATH = LIT_DIR / "index.json"
DATA_DIR = Path(__file__).parent


def chars_to_tokens(chars):
    return int(chars / 4 + 20)


def fresh_for_entry(e):
    path_val = e.get("path")
    p = LIT_DIR / path_val if not os.path.isabs(path_val) else Path(path_val)
    if p.is_file():
        chars = len(p.read_text(errors="replace"))
        return chars_to_tokens(chars)
    files = sorted([x for x in p.iterdir() if x.suffix == ".md" and not x.name.lower().startswith("chunk_")])
    if not files:
        files = sorted(p.glob("chunk_*.md"))
    chars = sum(len(x.read_text(errors="replace")) for x in files)
    return chars_to_tokens(chars)


def main():
    with open(INDEX_PATH) as f:
        d = json.load(f)
    entries = d["entries"]
    by_id = {(e.get("id") or e.get("doc_id")): e for e in entries}

    target_ids = set()
    with open(DATA_DIR / "scope3-drift.tsv") as f:
        next(f)
        for line in f:
            target_ids.add(line.split("\t")[0])

    for i in range(1, 13):
        target_ids.add(f"baier_katoen_2008_part{i:02d}")

    changed = []
    for eid in sorted(target_ids):
        e = by_id.get(eid)
        if e is None:
            print(f"WARNING: {eid} not found in current index, skipping")
            continue
        old_tc = e.get("token_count")
        fresh = fresh_for_entry(e)
        e["token_count"] = fresh
        changed.append((eid, old_tc, fresh))

    with open(INDEX_PATH, "w") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"total_changed={len(changed)}")
    for row in changed:
        print(row)


if __name__ == "__main__":
    main()
