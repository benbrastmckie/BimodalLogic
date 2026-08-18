#!/usr/bin/env python3
"""Phase 2 mutation: SCOPE 1 (diamondsareforever path/token) + SCOPE 2 (3 stub token counts)."""
import json
import os
from pathlib import Path

LIT_DIR = Path(os.path.expanduser("~/Projects/Literature"))
INDEX_PATH = LIT_DIR / "index.json"


def chars_to_tokens(chars):
    return int(chars / 4 + 20)


def compute_from_canonical_md(dirpath: Path):
    files = sorted([p for p in dirpath.iterdir() if p.suffix == ".md" and not p.name.lower().startswith("chunk_")])
    total = sum(len(f.read_text(errors="replace")) for f in files)
    return chars_to_tokens(total), len(files)


def main():
    with open(INDEX_PATH) as f:
        d = json.load(f)
    entries = d["entries"]
    by_id = {(e.get("id") or e.get("doc_id")): e for e in entries}

    changed = []

    # SCOPE 1: diamondsareforever
    e = by_id["diamondsareforever"]
    old_path, old_tc = e["path"], e["token_count"]
    dirpath = LIT_DIR / "sources/diamondsareforever"
    chunk_files = sorted(dirpath.glob("chunk_*.md"))
    total = sum(len(f.read_text(errors="replace")) for f in chunk_files)
    fresh = chars_to_tokens(total)
    e["path"] = "sources/diamondsareforever/"
    e["token_count"] = fresh
    changed.append(("diamondsareforever", "path", old_path, e["path"]))
    changed.append(("diamondsareforever", "token_count", old_tc, e["token_count"]))

    # SCOPE 2: three stub entries
    for eid in [
        "fine_2012_guide-to-ground",
        "vardi_wolper_1986_automata_verification",
        "fine_2012_counterfactuals-without-possible-worlds",
    ]:
        e = by_id[eid]
        old_tc = e["token_count"]
        path_val = e["path"]
        p = LIT_DIR / path_val if not os.path.isabs(path_val) else Path(path_val)
        if p.is_file():
            chars = len(p.read_text(errors="replace"))
        else:
            files = sorted([x for x in p.iterdir() if x.suffix == ".md" and not x.name.lower().startswith("chunk_")])
            chars = sum(len(x.read_text(errors="replace")) for x in files)
        fresh = chars_to_tokens(chars)
        e["token_count"] = fresh
        changed.append((eid, "token_count", old_tc, e["token_count"]))

    with open(INDEX_PATH, "w") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")

    for row in changed:
        print(row)


if __name__ == "__main__":
    main()
