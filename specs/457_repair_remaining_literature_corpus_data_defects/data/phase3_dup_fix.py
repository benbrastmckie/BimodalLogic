#!/usr/bin/env python3
"""Phase 3 supplementary fix: the 8 stale 'migrated from ingest schema' duplicate entries
share an id with an already-correct, fully-populated entry and were silently skipped by the
id-keyed by_id lookup in phase3_mutate.py (dict last-wins on duplicate keys). Each stale
duplicate independently satisfies SCOPE 3's own per-entry criteria (path-carrying,
stored token_count=0 diverging from a nonzero chars/4+20 fresh recomputation) -- this script
closes that gap by iterating the raw entries LIST (not a by-id dict) and correcting every
remaining stored-0 duplicate found. The duplicate-id structural defect itself (two records
for one document) is OUT OF SCOPE for this plan (not one of SCOPE 1-8) and is recorded
separately for a follow-up task, not resolved here.
"""
import json
import os
from pathlib import Path

LIT_DIR = Path(os.path.expanduser("~/Projects/Literature"))
INDEX_PATH = LIT_DIR / "index.json"


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

    changed = []
    for e in entries:
        if e.get("provenance") == "migrated from ingest schema (doc_id/source_path/chunks_dir)" and e.get("token_count") == 0:
            eid = e.get("id") or e.get("doc_id")
            fresh = fresh_for_entry(e)
            e["token_count"] = fresh
            changed.append((eid, 0, fresh))

    with open(INDEX_PATH, "w") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"total_changed={len(changed)}")
    for row in changed:
        print(row)


if __name__ == "__main__":
    main()
