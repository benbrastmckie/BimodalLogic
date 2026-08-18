#!/usr/bin/env python3
"""Phase 5 mutation: migrate the twelve legacy chunks_dir-only entries to v2 schema.

Adapted from task 457's Phase 6 `data/phase6_mutate.py`, generalized to read its TARGETS
data from two evidence TSVs instead of a hand-populated dict, and hardened with an explicit
allow-list of ids and mutable keys plus a hard refusal precondition.

Reads:
  - data/adjudication.tsv  (id, chunks_read, verdict, proposed_provenance_fidelity,
                             doc_type_evidence, disagreement_with_research)
  - data/scope5-12.tsv     (id, proposed_doc_type, proposed_source_format, evidence)

Writes (on the twelve target ids only, and only these five keys):
  - provenance_fidelity  <- adjudication.tsv column 4 ONLY. Never computed, never inferred.
  - path                 <- chunks_dir, relative to $LITERATURE_DIR, trailing slash, no
                             "sources/" prefix.
  - token_count          <- int(chars/4 + 20) over the concatenation of all chunk_*.md in
                             the entry's chunks_dir.
  - doc_type             <- scope5-12.tsv column 2.
  - source_format        <- scope5-12.tsv column 3, ONLY when that value is not the literal
                             string "EXCLUDE". Never written for an EXCLUDE row.

Hard precondition (the mechanical enforcement of the manual-read gate): this script REFUSES
TO RUN -- non-zero exit, no write -- if any of the twelve target rows is missing a
provenance_fidelity, a doc_type, or a chunk-filename record (the "chunks_read" column).
"""
import argparse
import csv
import json
import os
import sys
from pathlib import Path

DEFAULT_LIT_DIR = Path(os.path.expanduser("~/Projects/Literature"))
DEFAULT_TASK_DATA_DIR = Path(__file__).resolve().parent

TARGET_IDS = [
    "brics-rs-96-35",
    "cattani-winskel-2005-profunctors",
    "brics-rs-94-7",
    "schultz-spivak-temporal-type-theory",
    "fong-speranzon-spivak-temporal-landscapes",
    "schultz-spivak-vasilakopoulou-dynamical-systems-sheaves",
    "thomason-1970-indeterminist-time",
    "rutten-2000-universal-coalgebra",
    "jacobs-coalgebra-intro-draft",
    "danos-krivine-rccs",
    "reynolds-2003-ockhamist",
    "rumberg-zanardo-2019-transition-structures",
]

MUTABLE_KEYS = {"provenance_fidelity", "path", "token_count", "doc_type", "source_format"}

VALID_FIDELITY = {
    "verified_conversion",
    "no_source_pdf",
    "unverified_no_baseline",
    "unadjudicated",
    "not_yet_converted",
    "unverified_conversion",
}
VALID_DOC_TYPE = {"chapter", "paper", "book", "section", "manuscript", "survey", "thesis"}
VALID_SOURCE_FORMAT = {"pdf", "djvu", "latex", "html"}


def chars_to_tokens(chars):
    return int(chars / 4 + 20)


def read_adjudication(path):
    """Returns {id: {"provenance_fidelity": str, "chunks_read": str}}."""
    out = {}
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            rid = row.get("id", "").strip()
            if not rid:
                continue
            out[rid] = {
                "provenance_fidelity": row.get("proposed_provenance_fidelity", "").strip(),
                "chunks_read": row.get("chunks_read", "").strip(),
            }
    return out


def read_scope5(path):
    """Returns {id: {"doc_type": str, "source_format": str}}."""
    out = {}
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            rid = row.get("id", "").strip()
            if not rid:
                continue
            out[rid] = {
                "doc_type": row.get("proposed_doc_type", "").strip(),
                "source_format": row.get("proposed_source_format", "").strip(),
            }
    return out


def check_precondition(adjudication, scope5):
    """Hard precondition: every target id must have a non-empty provenance_fidelity,
    doc_type, and chunk-filename record. Returns a list of failure reasons (empty = pass)."""
    failures = []
    for rid in TARGET_IDS:
        adj = adjudication.get(rid)
        sc = scope5.get(rid)
        if adj is None:
            failures.append(f"{rid}: missing from adjudication.tsv entirely")
            continue
        if sc is None:
            failures.append(f"{rid}: missing from scope5-12.tsv entirely")
            continue
        if not adj["provenance_fidelity"]:
            failures.append(f"{rid}: missing provenance_fidelity in adjudication.tsv")
        elif adj["provenance_fidelity"] not in VALID_FIDELITY:
            failures.append(
                f"{rid}: provenance_fidelity '{adj['provenance_fidelity']}' is not one of "
                f"the six corpus enum values"
            )
        if not adj["chunks_read"]:
            failures.append(f"{rid}: missing chunk-filename record (chunks_read) in adjudication.tsv")
        if not sc["doc_type"]:
            failures.append(f"{rid}: missing doc_type in scope5-12.tsv")
        elif sc["doc_type"] not in VALID_DOC_TYPE:
            failures.append(f"{rid}: doc_type '{sc['doc_type']}' is not in the corpus vocabulary")
        if sc["source_format"] and sc["source_format"] != "EXCLUDE" and sc["source_format"] not in VALID_SOURCE_FORMAT:
            failures.append(f"{rid}: source_format '{sc['source_format']}' is neither EXCLUDE nor a valid format")
    return failures


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--index-path", default=None, help="Override index.json path (for dry-run testing on a copy)")
    ap.add_argument("--lit-dir", default=None, help="Override $LITERATURE_DIR (for relative path computation)")
    ap.add_argument("--adjudication-tsv", default=None, help="Override data/adjudication.tsv path")
    ap.add_argument("--scope5-tsv", default=None, help="Override data/scope5-12.tsv path")
    args = ap.parse_args()

    lit_dir = Path(os.path.expanduser(args.lit_dir)) if args.lit_dir else DEFAULT_LIT_DIR
    index_path = Path(os.path.expanduser(args.index_path)) if args.index_path else lit_dir / "index.json"
    adjudication_tsv = Path(args.adjudication_tsv) if args.adjudication_tsv else DEFAULT_TASK_DATA_DIR / "adjudication.tsv"
    scope5_tsv = Path(args.scope5_tsv) if args.scope5_tsv else DEFAULT_TASK_DATA_DIR / "scope5-12.tsv"

    adjudication = read_adjudication(adjudication_tsv)
    scope5 = read_scope5(scope5_tsv)

    failures = check_precondition(adjudication, scope5)
    if failures:
        print("REFUSING TO RUN -- manual-read precondition not satisfied for all twelve entries:", file=sys.stderr)
        for f in failures:
            print(f"  - {f}", file=sys.stderr)
        sys.exit(1)

    with open(index_path) as f:
        d = json.load(f)
    entries = d["entries"]

    by_id = {e.get("id"): e for e in entries if e.get("id") in TARGET_IDS}
    missing_in_index = [rid for rid in TARGET_IDS if rid not in by_id]
    if missing_in_index:
        print(f"REFUSING TO RUN -- target ids missing from index.json: {missing_in_index}", file=sys.stderr)
        sys.exit(1)

    changed = []
    for rid in TARGET_IDS:
        e = by_id[rid]
        adj = adjudication[rid]
        sc = scope5[rid]

        chunks_dir = e.get("chunks_dir")
        dirpath = Path(chunks_dir) if os.path.isabs(chunks_dir) else lit_dir / chunks_dir
        chunk_files = sorted(dirpath.glob("chunk_*.md"))
        if not chunk_files:
            print(f"REFUSING TO RUN -- no chunk_*.md files found for {rid} at {dirpath}", file=sys.stderr)
            sys.exit(1)
        total_chars = sum(len(cf.read_text(errors="replace")) for cf in chunk_files)
        fresh_token_count = chars_to_tokens(total_chars)

        old = {k: e.get(k) for k in MUTABLE_KEYS}

        # provenance_fidelity: from adjudication TSV ONLY, never computed.
        e["provenance_fidelity"] = adj["provenance_fidelity"]
        # path: chunks_dir relative to lit_dir, trailing slash, no sources/ prefix.
        rel = dirpath.relative_to(lit_dir) if str(dirpath).startswith(str(lit_dir)) else dirpath
        e["path"] = f"{rel}/".replace("//", "/")
        # token_count: computed here, independently re-verified in Phase 6.
        e["token_count"] = fresh_token_count
        # doc_type: from scope5 TSV.
        e["doc_type"] = sc["doc_type"]
        # source_format: only when not EXCLUDE.
        if sc["source_format"] and sc["source_format"] != "EXCLUDE":
            e["source_format"] = sc["source_format"]

        new = {k: e.get(k) for k in MUTABLE_KEYS}
        changed.append((rid, old, new))

    with open(index_path, "w") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")

    for row in changed:
        print(row)
    print(f"total_changed={len(changed)}")


if __name__ == "__main__":
    main()
