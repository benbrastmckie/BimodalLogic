#!/usr/bin/env bash
# literature-repair-combining.sh - Backup-guarded, anchored in-place repair engine
# for the combining-mark (U+0338) corruption in the ~/Projects/Literature corpus.
#
# Usage:
#   literature-repair-combining.sh --dir NAME [--dry-run|--write] [--ledger-json]
#
#   --dir NAME    Required. Scope to a single sources/<NAME>/ directory.
#   --dry-run     Report proposed rewrites only (DEFAULT). No backup, no write.
#   --write       Perform the backup-then-rewrite. Requires this flag explicitly;
#                 --dry-run is the safe default with or without the flag present.
#   --ledger-json Emit the residual-ledger entries (unrepaired occurrences) as a
#                 JSON array to stdout instead of the human-readable summary.
#                 Safe in both --dry-run and --write mode.
#   -h, --help    Show this help.
#
# What this repairs: every occurrence `literature_combining_detect.py` classifies
# as `control_char`, `glyph_six`, or `absent` (the three "corrupted, actionable"
# signatures with a uniquely-anchored markdown location AND a known
# base->precomposed target) is rewritten in place: the corrupted span (base
# character plus its adjacent corruption artifact -- a control character, a
# literal "6", or nothing) is replaced by the single precomposed negated
# codepoint (e.g. "=" + control-char -> "≠"). Occurrences already `precomposed`,
# `bare_pair`, or `latex_macro` need no action. Occurrences the detector could
# not uniquely anchor (`unanchored`), or whose base character has no known
# precomposed target, or whose edit span overlaps another occurrence's edit
# span in the same file, are NEVER written -- they are reported as residual-
# ledger entries instead (reasons: ambiguous_anchor, anchor_not_found,
# unrecognized_gap, unmapped_base, unmapped_base_char, overlapping_edit).
#
# Backup contract: before the FIRST write to a file in a given UTC calendar day,
# the pre-edit file is mirrored to
#   $LITERATURE_DIR/.backups/combining-repair-{ISO_DATE}/sources/<dir>/<file>
# preserving directory layout. An existing backup for the same file is NEVER
# overwritten (so a second same-day run's backup step is a no-op, not a
# re-snapshot of an already-modified file). A sha256 manifest
# (`.../combining-repair-{ISO_DATE}/manifest.json`) records every backed-up
# file's original hash. Writing to the corpus for a given file is refused if its
# backup could not be created or verified.
#
# Idempotence: running --write twice over the same directory proposes (and
# performs) zero rewrites on the second run -- every genuinely repaired
# occurrence re-classifies as `precomposed` (accounted, no action) when
# `literature_combining_detect.py` re-scans the now-fixed file.
#
# This script NEVER performs a full re-conversion, and NEVER touches chunk_*.md,
# chunks.json, or index.json -- those are Phase 8/9's job.
#
# Environment:
#   LITERATURE_DIR  Path to the global Literature/ repo (default: ~/Projects/Literature)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LITERATURE_DIR="${LITERATURE_DIR:-$HOME/Projects/Literature}"
DIR_FILTER=""
MODE="dry-run"
LEDGER_JSON="0"

usage() {
  cat <<'EOF'
Usage: literature-repair-combining.sh --dir NAME [--dry-run|--write] [--ledger-json]

  --dir NAME     Required. Scope to a single sources/<NAME>/ directory.
  --dry-run      Report proposed rewrites only (DEFAULT). No backup, no write.
  --write        Perform the backup-then-rewrite.
  --ledger-json  Emit residual-ledger entries as JSON to stdout.
  -h, --help     Show this help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dir)
      DIR_FILTER="${2:-}"
      shift 2
      ;;
    --write)
      MODE="write"
      shift
      ;;
    --dry-run)
      MODE="dry-run"
      shift
      ;;
    --ledger-json)
      LEDGER_JSON="1"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [ -z "$DIR_FILTER" ]; then
  echo "Error: --dir NAME is required" >&2
  usage
  exit 1
fi

if [ ! -d "$LITERATURE_DIR" ]; then
  echo "Error: LITERATURE_DIR not found: $LITERATURE_DIR" >&2
  exit 1
fi

SOURCES_DIR="$LITERATURE_DIR/sources"
if [ ! -d "$SOURCES_DIR" ]; then
  echo "Error: sources/ not found under LITERATURE_DIR: $SOURCES_DIR" >&2
  exit 1
fi

ISO_DATE="$(date -u +%Y-%m-%d)"
BACKUP_ROOT="$LITERATURE_DIR/.backups/combining-repair-$ISO_DATE"

LITERATURE_DIR="$LITERATURE_DIR" \
SOURCES_DIR="$SOURCES_DIR" \
DIR_FILTER="$DIR_FILTER" \
MODE="$MODE" \
LEDGER_JSON="$LEDGER_JSON" \
BACKUP_ROOT="$BACKUP_ROOT" \
LITERATURE_SCRIPT_DIR="$SCRIPT_DIR" \
python3 <<'PYEOF'
import hashlib
import json
import os
import re
import shutil
import sys
import tempfile
import datetime

sys.path.insert(0, os.environ["LITERATURE_SCRIPT_DIR"])
try:
    import fitz  # noqa: F401
except ImportError as e:
    print(f"[repair-combining] PyMuPDF (fitz) not available: {e}", file=sys.stderr)
    sys.exit(2)

from literature_combining_detect import scan_directory, PRECOMPOSED  # noqa: E402

LITERATURE_DIR = os.environ["LITERATURE_DIR"]
SOURCES_DIR = os.environ["SOURCES_DIR"]
DIR_FILTER = os.environ["DIR_FILTER"]
MODE = os.environ["MODE"]
LEDGER_JSON = os.environ.get("LEDGER_JSON", "0") == "1"
BACKUP_ROOT = os.environ["BACKUP_ROOT"]

REPAIRABLE_SIGNATURES = {"control_char", "glyph_six", "absent"}


def no_markdown_notice(dirname):
    print(f"[repair-combining] {dirname}: has PDF but no converted markdown "
          f"(non-chunk *.md) -- nothing to repair.", file=sys.stderr)


def sha256_of(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def backup_file(md_path):
    """Mirror md_path into BACKUP_ROOT preserving its sources/<dir>/<file>
    layout, UNLESS a backup for this exact path already exists (never
    overwrite an existing backup). Returns True if a valid backup exists
    (either just created or pre-existing) and it is safe to write, False if
    the backup could not be created/verified (write must be refused)."""
    rel = os.path.relpath(md_path, LITERATURE_DIR)
    backup_path = os.path.join(BACKUP_ROOT, rel)
    if os.path.exists(backup_path):
        return True, backup_path, None
    try:
        os.makedirs(os.path.dirname(backup_path), exist_ok=True)
        shutil.copy2(md_path, backup_path)
        if not os.path.exists(backup_path) or sha256_of(backup_path) != sha256_of(md_path):
            return False, backup_path, "backup verification failed after copy"
        return True, backup_path, None
    except Exception as e:
        return False, backup_path, str(e)


def record_manifest(entries):
    """entries: list of (rel_path, sha256, iso_timestamp). Merge into
    BACKUP_ROOT/manifest.json, never overwriting an existing entry's hash."""
    if not entries:
        return
    manifest_path = os.path.join(BACKUP_ROOT, "manifest.json")
    manifest = {}
    if os.path.exists(manifest_path):
        try:
            with open(manifest_path, "r", encoding="utf-8") as f:
                manifest = json.load(f)
        except Exception:
            manifest = {}
    for rel_path, digest, ts in entries:
        if rel_path not in manifest:
            manifest[rel_path] = {"sha256": digest, "backed_up_at": ts}
    os.makedirs(BACKUP_ROOT, exist_ok=True)
    tmp_fd, tmp_path = tempfile.mkstemp(dir=BACKUP_ROOT, prefix=".manifest.", suffix=".tmp")
    with os.fdopen(tmp_fd, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2, sort_keys=True)
    os.replace(tmp_path, manifest_path)


def atomic_write(path, content):
    d = os.path.dirname(path)
    tmp_fd, tmp_path = tempfile.mkstemp(dir=d, prefix=".repair.", suffix=".tmp")
    try:
        with os.fdopen(tmp_fd, "w", encoding="utf-8") as f:
            f.write(content)
        os.replace(tmp_path, path)
    except Exception:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
        raise


_CTRL_CLASS = r"\x00-\x08\x0b-\x1f"


def _find_sub_spans(gap_text, group):
    """Given a gap_text span claimed identically by >=2 occurrences (`group`,
    each an edit dict carrying its own occ["base_char"]/occ["signature"]),
    try to locate that many DISTINCT, non-overlapping literal corruption
    instances within gap_text and return their (local_start, local_end)
    spans in left-to-right order, or None if the group isn't the simple
    same-base/same-signature case this refinement handles, or the count of
    literal instances found doesn't exactly match len(group) (in which case
    the caller's normal overlap-conflict handling applies instead)."""
    base_chars = {e["occ"]["base_char"] for e in group}
    signatures = {e["occ"]["signature"] for e in group}
    if len(base_chars) != 1 or len(signatures) != 1:
        return None
    base_char = next(iter(base_chars))
    signature = next(iter(signatures))
    esc = re.escape(base_char)
    # Tolerate up to 2 intervening horizontal-whitespace characters between
    # the corruption artifact and the base -- verified real: bacon_2018's
    # own gap_text is ": A \x0f = B -> L(A \x0f = B).\n" (control char, SPACE,
    # base), the same whitespace-tolerance the converter fix (Phase 2) and
    # the detector's gap classification already accommodate.
    ws = r"[ \t]{0,2}"
    if signature == "control_char":
        pattern = re.compile(f"[{_CTRL_CLASS}]{ws}{esc}|{esc}{ws}[{_CTRL_CLASS}]")
    elif signature == "glyph_six":
        pattern = re.compile(f"6{ws}{esc}|{esc}{ws}6")
    elif signature == "absent":
        pattern = re.compile(esc)
    else:
        return None
    spans = [(m.start(), m.end()) for m in pattern.finditer(gap_text)]
    if len(spans) != len(group):
        return None
    return spans


def main():
    dirpath = os.path.join(SOURCES_DIR, DIR_FILTER)
    if not os.path.isdir(dirpath):
        print(f"Error: directory not found: {dirpath}", file=sys.stderr)
        sys.exit(1)

    result = scan_directory(dirpath, DIR_FILTER, on_no_markdown=no_markdown_notice)
    if result is None:
        # Either no PDF, or no markdown (notice already printed for the latter).
        if LEDGER_JSON:
            print(json.dumps([], ensure_ascii=False, indent=2))
        else:
            print(f"[repair-combining] {DIR_FILTER}: nothing to scan (no PDF, or no markdown).")
        return

    # Group repairable occurrences by md_file.
    by_file = {}
    residual = []

    for occ in result["occurrences"]:
        sig = occ["signature"]
        if sig not in REPAIRABLE_SIGNATURES:
            if sig == "unanchored":
                residual.append({**occ, "dir": DIR_FILTER})
            continue
        base_char = occ["base_char"]
        if base_char not in PRECOMPOSED:
            residual.append({**occ, "dir": DIR_FILTER, "reason": "unmapped_base_char"})
            continue
        md_file = occ["md_file"]
        by_file.setdefault(md_file, []).append({
            "gap_start": occ["md_gap_start"],
            "gap_end": occ["md_gap_end"],
            "replacement": PRECOMPOSED[base_char],
            "occ": occ,
        })

    proposed_rewrites = 0
    files_to_write = {}  # md_file -> new_content
    applied_counts = {}  # md_file -> number of occurrences actually rewritten

    for md_file, edits in by_file.items():
        with open(md_file, "r", encoding="utf-8", errors="replace") as f:
            original = f.read()

        # Narrow EVERY edit's gap to the precise sub-span containing just the
        # corruption artifact plus its base character (tolerating up to 2
        # intervening whitespace chars), never the raw word-landmark-bracketed
        # gap as-is. CRITICAL: the word-landmark gap classify_occurrence()
        # reports can be, and often is, much WIDER than the actual 1-2
        # character corruption complex -- it only needs to CONTAIN evidence of
        # the signature for classification purposes, not equal it exactly.
        # Verified as a real, corpus-mutating bug during this phase: an
        # initial version of this script used the raw gap span directly as
        # the edit region and deleted real surrounding text (e.g. "with τ
        # <ctrl>∈ H. Only" collapsed to "with∉Only", losing "τ", "H", "."),
        # even for a SINGLE, uniquely-anchored occurrence with no conflicting
        # neighbor. This narrowing step is therefore MANDATORY for every
        # group, not just groups sharing an identical span with >1 occurrence
        # (the shared-span disambiguation case) -- singleton groups need it
        # exactly as much.
        by_span = {}
        for e in edits:
            by_span.setdefault((e["gap_start"], e["gap_end"]), []).append(e)
        narrowed = []
        for (gs, ge), group in by_span.items():
            gap_text = original[gs:ge]
            sub_spans = _find_sub_spans(gap_text, group)
            if sub_spans is not None and len(sub_spans) == len(group):
                for e, (local_s, local_e) in zip(group, sub_spans):
                    e["gap_start"] = gs + local_s
                    e["gap_end"] = gs + local_e
                    narrowed.append(e)
            else:
                # Could not narrow to an exact, unambiguous sub-span -- refuse
                # to guess. A single occurrence whose own gap can't be
                # narrowed is just as unsafe to rewrite as a genuine conflict
                # between multiple occurrences.
                reason = "overlapping_edit" if len(group) > 1 else "narrow_failed"
                for e in group:
                    residual.append({**e["occ"], "dir": DIR_FILTER, "reason": reason})

        narrowed.sort(key=lambda e: e["gap_start"])
        # Defense in depth: detect any remaining overlaps between narrowed
        # spans (should not happen after narrowing, but never trust silently)
        # and verify each edit's net character delta is small -- a real
        # corruption-artifact rewrite removes at most a handful of characters
        # (the base character, one adjacent artifact char, and up to 2
        # whitespace chars); anything larger is refused rather than applied.
        accepted = []
        i = 0
        while i < len(narrowed):
            e = narrowed[i]
            span_len = e["gap_end"] - e["gap_start"]
            if i + 1 < len(narrowed) and narrowed[i + 1]["gap_start"] < e["gap_end"]:
                residual.append({**e["occ"], "dir": DIR_FILTER, "reason": "overlapping_edit"})
                residual.append({**narrowed[i + 1]["occ"], "dir": DIR_FILTER, "reason": "overlapping_edit"})
                i += 2
                continue
            if span_len > 6:
                residual.append({**e["occ"], "dir": DIR_FILTER, "reason": "edit_too_large"})
                i += 1
                continue
            accepted.append(e)
            i += 1

        if not accepted:
            continue

        pieces = []
        cursor = 0
        for e in accepted:
            pieces.append(original[cursor:e["gap_start"]])
            pieces.append(e["replacement"])
            cursor = e["gap_end"]
        pieces.append(original[cursor:])
        new_content = "".join(pieces)

        # Final circuit breaker: a word-count sanity check across the WHOLE
        # file. Each edit replaces a span of at most 6 characters (the
        # per-edit cap above) with a single character, so it can remove at
        # most one "word" boundary artifact -- word count must not drop by
        # more than len(accepted) (generous: a real run never approaches
        # this). If it does, something upstream of this defense is still
        # wrong; refuse the whole file rather than trust the diff.
        word_delta = len(original.split()) - len(new_content.split())
        if word_delta > len(accepted) or word_delta < 0:
            print(f"[repair-combining] REFUSING {md_file}: word-count sanity check failed "
                  f"(original={len(original.split())} words, new={len(new_content.split())} "
                  f"words, delta={word_delta}, edits={len(accepted)}) -- this should never "
                  f"happen; treating as a bug, not writing this file.", file=sys.stderr)
            for e in accepted:
                residual.append({**e["occ"], "dir": DIR_FILTER, "reason": "sanity_check_failed"})
            continue

        if new_content != original:
            files_to_write[md_file] = new_content
            applied_counts[md_file] = len(accepted)
            proposed_rewrites += len(accepted)

    # --- Report / act ---
    if LEDGER_JSON:
        print(json.dumps(residual, ensure_ascii=False, indent=2))
        return

    print(f"[repair-combining] {DIR_FILTER}: {proposed_rewrites} proposed rewrite(s) "
          f"across {len(files_to_write)} file(s); {len(residual)} residual (unrepaired) occurrence(s)")
    for md_file in files_to_write:
        print(f"  {os.path.relpath(md_file, LITERATURE_DIR)}: "
              f"{applied_counts[md_file]} occurrence(s) rewritten")

    if MODE == "dry-run":
        print("[repair-combining] --dry-run: no backup created, no files written.")
        return

    # --write: backup-then-rewrite, refusing per-file if backup fails.
    manifest_entries = []
    written = 0
    refused = 0
    now_iso = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    for md_file, new_content in files_to_write.items():
        ok, backup_path, err = backup_file(md_file)
        if not ok:
            print(f"[repair-combining] REFUSING write to {md_file}: backup failed ({err})",
                  file=sys.stderr)
            refused += 1
            continue
        rel = os.path.relpath(md_file, LITERATURE_DIR)
        manifest_entries.append((rel, sha256_of(backup_path), now_iso))
        atomic_write(md_file, new_content)
        written += 1

    record_manifest(manifest_entries)
    print(f"[repair-combining] --write: {written} file(s) written, {refused} refused "
          f"(backup failure), backup root: {BACKUP_ROOT}")


main()
PYEOF
