#!/usr/bin/env python3
"""Phase 6 mutation: SCOPE 7 provenance adjudication for the three newly ingested documents.

Stamps are written ONLY after the manual spot-check gate (performed by hand, recorded in the
phase notes / progress file -- not automated here). This script performs the mechanical part:
setting provenance_fidelity, path, and token_count on the three named entries in the global
index, per the manual verdicts already reached:
  - Jonsson & Tarski 1951 (Part I):  unverified_conversion (prose coherent, formulas degraded)
  - Jonsson & Tarski 1952 (Part II): unverified_conversion (prose coherent, formulas degraded)
  - Goldblatt 2006:                  verified_conversion    (prose and symbols both clean)
"""
import json
import os
from pathlib import Path

LIT_DIR = Path(os.path.expanduser("~/Projects/Literature"))
INDEX_PATH = LIT_DIR / "index.json"


def chars_to_tokens(chars):
    return int(chars / 4 + 20)


TARGETS = {
    "j_nsson_and_tarski_-_1951_-_boolean_algebras_with_operators._part_i": "unverified_conversion",
    "j_nsson_and_tarski_-_1952_-_boolean_algebras_with_operators._part_ii": "unverified_conversion",
    "goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution": "verified_conversion",
}


def main():
    with open(INDEX_PATH) as f:
        d = json.load(f)
    entries = d["entries"]

    changed = []
    for e in entries:
        eid = e.get("id") or e.get("doc_id")
        if eid not in TARGETS:
            continue
        chunks_dir = e.get("chunks_dir")
        dirpath = Path(chunks_dir) if os.path.isabs(chunks_dir) else LIT_DIR / chunks_dir
        chunk_files = sorted(dirpath.glob("chunk_*.md"))
        total = sum(len(f_.read_text(errors="replace")) for f_ in chunk_files)
        fresh_tc = chars_to_tokens(total)

        old = {
            "provenance_fidelity": e.get("provenance_fidelity"),
            "path": e.get("path"),
            "token_count": e.get("token_count"),
        }
        e["provenance_fidelity"] = TARGETS[eid]
        # directory-path convention: point at the chunks_dir, relative to LIT_DIR where possible
        rel = dirpath.relative_to(LIT_DIR) if str(dirpath).startswith(str(LIT_DIR)) else dirpath
        e["path"] = f"{rel}/".replace("//", "/")
        e["token_count"] = fresh_tc

        changed.append((eid, old, {
            "provenance_fidelity": e["provenance_fidelity"],
            "path": e["path"],
            "token_count": e["token_count"],
        }))

    with open(INDEX_PATH, "w") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")

    for row in changed:
        print(row)
    print(f"total_changed={len(changed)}")


if __name__ == "__main__":
    main()
