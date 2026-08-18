#!/usr/bin/env python3
"""Phase 1 (and re-usable for later phases) worklist generator for task 457.

Regenerates all scope worklists from the LIVE ~/Projects/Literature/index.json.
Never replays a frozen ID list. Token count formula: chars/4 + 20 (fresh recompute,
excluding chunk_*.md re-splits per chunk-file-conventions.md).
"""
import json
import os
import re
import sys
from pathlib import Path

LIT_DIR = Path(os.path.expanduser("~/Projects/Literature"))
INDEX_PATH = LIT_DIR / "index.json"
DATA_DIR = Path(__file__).parent

CHUNK_RE = re.compile(r"^chunk_\d+\.md$", re.IGNORECASE)


def load_index():
    with open(INDEX_PATH) as f:
        return json.load(f)


def chars_to_tokens(chars):
    return int(chars / 4 + 20)


def canonical_md_files(dirpath: Path):
    """Return canonical (non chunk_*.md) .md files in dirpath, non-recursive."""
    if not dirpath.is_dir():
        return []
    return sorted([p for p in dirpath.iterdir() if p.suffix == ".md" and not CHUNK_RE.match(p.name)])


def chunk_md_files(dirpath: Path):
    if not dirpath.is_dir():
        return []
    return sorted([p for p in dirpath.iterdir() if CHUNK_RE.match(p.name)])


def compute_fresh_token_count(entry):
    """Compute chars/4+20 using canonical .md if present, else chunk_*.md concatenation."""
    path_val = entry.get("path") or entry.get("chunks_dir")
    if not path_val:
        return None, "no-path"
    if os.path.isabs(path_val):
        dirpath = Path(path_val)
    else:
        dirpath = LIT_DIR / path_val
    if dirpath.is_file():
        # some 'path' values might point directly at a file (rare)
        chars = dirpath.read_text(errors="replace")
        return chars_to_tokens(len(chars)), "file"
    canon = canonical_md_files(dirpath)
    if canon:
        total = 0
        for f in canon:
            total += len(f.read_text(errors="replace"))
        return chars_to_tokens(total), f"canonical:{len(canon)}"
    chunks = chunk_md_files(dirpath)
    if chunks:
        total = 0
        for f in chunks:
            total += len(f.read_text(errors="replace"))
        return chars_to_tokens(total), f"chunks:{len(chunks)}"
    return None, "no-md-found"


def main():
    d = load_index()
    entries = d["entries"]

    # ---------- SCOPE 1: chunk_\d+\.md$ path entries ----------
    scope1 = [e for e in entries if isinstance(e.get("path"), str) and CHUNK_RE.match(os.path.basename(e["path"].rstrip("/")))]

    # ---------- SCOPE 2: three named stub entries ----------
    stub_ids = [
        "fine_2012_guide-to-ground",
        "vardi_wolper_1986_automata_verification",
        "fine_2012_counterfactuals-without-possible-worlds",
    ]
    scope2 = [e for e in entries if (e.get("id") or e.get("doc_id")) in stub_ids]

    with open(DATA_DIR / "scope1-2.tsv", "w") as f:
        f.write("id\tstored_path\tstored_token_count\tfresh_token_count\tsource_kind\n")
        for e in scope1 + scope2:
            eid = e.get("id") or e.get("doc_id")
            fresh, kind = compute_fresh_token_count(e)
            f.write(f"{eid}\t{e.get('path')}\t{e.get('token_count')}\t{fresh}\t{kind}\n")

    # ---------- SCOPE 3: drifted token_count on path-carrying entries, >20%, excluding scope1/2 ----------
    # Drift ratio is defined as fresh/stored (recomputed-over-stored), matching the direction
    # research/plan describe ("all drift in the same direction", 44 in the 1.20-1.35 band): the
    # stored legacy value systematically UNDERSTATES the chars/4+20 recomputation. A stored value
    # of 0 is an automatic-include (undefined ratio, maximal drift).
    excl_ids = {(e.get("id") or e.get("doc_id")) for e in scope1 + scope2}
    scope3 = []
    for e in entries:
        eid = e.get("id") or e.get("doc_id")
        if eid in excl_ids:
            continue
        if not isinstance(e.get("path"), str):
            continue
        stored = e.get("token_count")
        if stored is None:
            continue
        fresh, kind = compute_fresh_token_count(e)
        if fresh is None:
            continue
        if stored == 0:
            scope3.append((eid, stored, fresh, "inf", kind))
            continue
        ratio = fresh / stored
        if ratio > 1.20 or ratio < (1 / 1.20):
            scope3.append((eid, stored, fresh, round(ratio, 4), kind))

    with open(DATA_DIR / "scope3-drift.tsv", "w") as f:
        f.write("id\tstored_token_count\tfresh_token_count\tratio\tsource_kind\n")
        for row in scope3:
            f.write("\t".join(str(x) for x in row) + "\n")

    # baier_katoen uniform check
    bk_entries = [e for e in entries if (e.get("id") or e.get("doc_id") or "").startswith("baier_katoen_2008_part")]
    bk_values = sorted({e.get("token_count") for e in bk_entries})

    # ---------- SCOPE 4: authors comma-joined strings ----------
    # delegated to literature-normalize-authors.sh --dry-run (called separately)

    # ---------- SCOPE 5: entries missing doc_type and/or source_format ----------
    legacy_only_ids = {
        (e.get("id") or e.get("doc_id"))
        for e in entries
        if "chunks_dir" in e and "path" not in e
    }
    by_id = {(e.get("id") or e.get("doc_id")): e for e in entries}
    # Manually-established evidence for entries with no parent_doc and no source file found in
    # their own directory, gathered during Phase 1 live worklist generation (see baseline.md):
    #  - gabbay_1994_ch10: no parent_doc field, but its sibling directory gabbay_1994/ (the
    #    Vol1 book source) contains Gabbay_Hodkinson_Reynolds_1994_..._ch10.pdf, the evident
    #    source of this chapter's .md conversion.
    #  - proofs_and_types: Girard's "Proofs and Types" (Girard/Lafont/Taylor 1989) -- a book,
    #    with source.pdf found directly in its own sources/girard_1989/ directory.
    #  - van_doorn_2015_propositional_calculus_coq: standalone paper, source.pdf found directly.
    manual_sibling_source_format = {"gabbay_1994_ch10": "pdf"}
    manual_doc_type_no_parent = {
        "proofs_and_types": "book",
        "van_doorn_2015_propositional_calculus_coq": "paper",
        "gabbay_1994_ch10": "chapter",
    }
    scope5 = []
    for e in entries:
        eid = e.get("id") or e.get("doc_id")
        if eid in legacy_only_ids:
            continue
        missing_dt = "doc_type" not in e or e.get("doc_type") is None
        missing_sf = "source_format" not in e or e.get("source_format") is None
        if missing_dt or missing_sf:
            # inspect source dir for actual source-file extension (never the converted .md itself)
            path_val = e.get("path") or e.get("chunks_dir") or e.get("source_path")
            exts = []
            if path_val:
                p_ = Path(path_val) if os.path.isabs(path_val) else LIT_DIR / path_val
                # If path points directly at a .md file, inspect its PARENT dir for the
                # original source file -- the .md is the converted artifact, not the source.
                dirpath = p_.parent if p_.is_file() else p_
                if dirpath.is_dir():
                    for p in dirpath.iterdir():
                        if p.suffix.lower() in (".pdf", ".djvu", ".epub", ".html", ".txt"):
                            exts.append(p.suffix.lower())
            found = ",".join(sorted(set(exts))) or "NONE_FOUND"

            # ---- proposed doc_type / source_format ----
            parent_id = e.get("parent_doc")
            parent = by_id.get(parent_id) if parent_id else None
            proposed_sf = None
            proposed_dt = None
            evidence = ""
            if found != "NONE_FOUND":
                ext = sorted(set(exts))[0].lstrip(".")
                proposed_sf = ext
                evidence = f"source file found in own directory ({found})"
            elif eid in manual_sibling_source_format:
                proposed_sf = manual_sibling_source_format[eid]
                evidence = "source file found in sibling parent-work directory (see script comment)"
            elif parent and parent.get("source_format"):
                proposed_sf = parent.get("source_format")
                evidence = f"inherited from parent_doc={parent_id}"
            else:
                proposed_sf = "EXCLUDE"
                evidence = "no source file on disk, no parent_doc, no zotero cross-reference"

            if eid in manual_doc_type_no_parent:
                proposed_dt = manual_doc_type_no_parent[eid]
            elif parent and parent.get("doc_type"):
                # children of a book inherit "chapter" (or "section" for _section* ids),
                # matching the established corpus convention (151 chapter / 14 section
                # among already-populated parent_doc children) rather than literally
                # copying the parent's own "book" doc_type.
                proposed_dt = "section" if "_section" in eid else "chapter"
            else:
                proposed_dt = "paper"

            scope5.append((eid, missing_dt, missing_sf, found, proposed_dt, proposed_sf, evidence))

    with open(DATA_DIR / "scope5-missing-fields.tsv", "w") as f:
        f.write("id\tmissing_doc_type\tmissing_source_format\tfound_source_exts\tproposed_doc_type\tproposed_source_format\tevidence\n")
        for row in scope5:
            f.write("\t".join(str(x) for x in row) + "\n")

    # ---------- SCOPE 6: both-schema and absolute chunks_dir ----------
    both_schema = [
        (e.get("id") or e.get("doc_id"))
        for e in entries
        if "chunks_dir" in e and "path" in e
    ]
    absolute_chunks_dir = [
        (e.get("id") or e.get("doc_id"))
        for e in entries
        if isinstance(e.get("chunks_dir"), str) and os.path.isabs(e["chunks_dir"])
    ]
    with open(DATA_DIR / "scope6-schema.tsv", "w") as f:
        f.write("id\tcategory\n")
        for eid in both_schema:
            f.write(f"{eid}\tboth_schema\n")
        for eid in absolute_chunks_dir:
            f.write(f"{eid}\tabsolute_chunks_dir\n")

    # ---------- SCOPE 7: legacy chunks_dir-only entries ----------
    # Confirmed live (Phase 1) against title+year, not id substring: the Jonsson-Tarski 1951/1952
    # pair and Goldblatt 2006 "Mathematical modal logic: A view of its evolution". goldblatt_2003
    # (Erdos graphs) is a distinct, separately-scoped (SCOPE 8) entry -- not part of SCOPE 7.
    named7 = {
        "j_nsson_and_tarski_-_1951_-_boolean_algebras_with_operators._part_i",
        "j_nsson_and_tarski_-_1952_-_boolean_algebras_with_operators._part_ii",
        "goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution",
    }
    legacy_entries = [e for e in entries if (e.get("id") or e.get("doc_id")) in legacy_only_ids]
    with open(DATA_DIR / "scope7-legacy.tsv", "w") as f:
        f.write("id\ttitle\tnamed_in_scope7\n")
        for e in legacy_entries:
            eid = e.get("id") or e.get("doc_id")
            title = e.get("title", "")
            named = "YES" if eid in named7 else "no"
            f.write(f"{eid}\t{title}\t{named}\n")

    # ---------- Summary printed to stdout for baseline.md authoring ----------
    print(f"total_entries={len(entries)}")
    print(f"scope1_count={len(scope1)}")
    print(f"scope2_count={len(scope2)}")
    print(f"scope3_count={len(scope3)}")
    print(f"baier_katoen_entries={len(bk_entries)} distinct_values={bk_values}")
    print(f"scope5_count={len(scope5)}")
    print(f"legacy_only_count={len(legacy_only_ids)}")
    print(f"both_schema_count={len(both_schema)}")
    print(f"absolute_chunks_dir_count={len(absolute_chunks_dir)}")
    # print candidate ids for scope1/2/7 for manual review
    print(f"scope1_ids={[(e.get('id') or e.get('doc_id')) for e in scope1]}")
    print(f"scope2_ids_found={[(e.get('id') or e.get('doc_id')) for e in scope2]}")
    print(f"scope7_legacy_ids={[e.get('id') or e.get('doc_id') for e in legacy_entries]}")


if __name__ == "__main__":
    main()
