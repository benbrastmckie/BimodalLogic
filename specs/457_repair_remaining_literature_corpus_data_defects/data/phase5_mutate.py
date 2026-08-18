#!/usr/bin/env python3
"""Phase 5 mutation: fill doc_type + source_format on the 35 v2-schema entries missing both,
per the proposed mapping in scope5-missing-fields.tsv (proposed_doc_type / proposed_source_format
columns). Entries whose proposed_source_format is EXCLUDE get doc_type written but source_format
left absent, and are recorded in the plan's Reasoned Exclusions table instead.
"""
import csv
import json
import os
from pathlib import Path

LIT_DIR = Path(os.path.expanduser("~/Projects/Literature"))
INDEX_PATH = LIT_DIR / "index.json"
DATA_DIR = Path(__file__).parent


def main():
    with open(INDEX_PATH) as f:
        d = json.load(f)
    entries = d["entries"]
    by_id = {(e.get("id") or e.get("doc_id")): e for e in entries}

    changed = []
    excluded = []
    with open(DATA_DIR / "scope5-missing-fields.tsv") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            eid = row["id"]
            e = by_id.get(eid)
            if e is None:
                print(f"WARNING: {eid} not found, skipping")
                continue
            e["doc_type"] = row["proposed_doc_type"]
            if row["proposed_source_format"] == "EXCLUDE":
                excluded.append((eid, row["evidence"]))
            else:
                e["source_format"] = row["proposed_source_format"]
                changed.append((eid, row["proposed_doc_type"], row["proposed_source_format"]))

    with open(INDEX_PATH, "w") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"filled_both={len(changed)}")
    for row in changed:
        print(row)
    print(f"excluded_source_format_only_doc_type_filled={len(excluded)}")
    for row in excluded:
        print(row)


if __name__ == "__main__":
    main()
