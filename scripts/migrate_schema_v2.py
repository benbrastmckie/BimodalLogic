#!/usr/bin/env python3
"""
Schema Migration v2: Add max_modal_depth and max_temporal_depth to JSONL records.

Reads existing 14-field JSONL files and injects two new top-level fields extracted
from pattern_key.modalDepth and pattern_key.temporalDepth, producing 16-field records.

Usage:
    python scripts/migrate_schema_v2.py data/bmlogic-c5.jsonl [data/bmlogic-c7.jsonl ...]
    python scripts/migrate_schema_v2.py --dry-run data/bmlogic-c5.jsonl

Options:
    --dry-run   Print sample records without modifying files
"""

import json
import os
import sys
import tempfile


def migrate_record(record: dict) -> dict:
    """Add max_modal_depth and max_temporal_depth from pattern_key."""
    if "max_modal_depth" in record and "max_temporal_depth" in record:
        return record  # Already migrated

    pattern_key = record.get("pattern_key", {})
    record["max_modal_depth"] = pattern_key.get("modalDepth", 0)
    record["max_temporal_depth"] = pattern_key.get("temporalDepth", 0)
    return record


def migrate_file(path: str, dry_run: bool = False) -> tuple[int, int]:
    """
    Migrate a JSONL file in-place (via atomic rename).
    Returns (total_records, migrated_records).
    """
    total = 0
    migrated = 0

    if dry_run:
        print(f"\n--- Dry run: {path} ---")
        with open(path) as f:
            for i, line in enumerate(f):
                line = line.strip()
                if not line:
                    continue
                record = json.loads(line)
                total += 1
                had_fields = "max_modal_depth" in record
                record = migrate_record(record)
                if not had_fields:
                    migrated += 1
                # Show first 3 records
                if i < 3:
                    print(f"  Record {i+1}:")
                    print(f"    max_modal_depth: {record['max_modal_depth']}")
                    print(f"    max_temporal_depth: {record['max_temporal_depth']}")
                    print(f"    fields: {len(record)}")
        print(f"  Total: {total}, Would migrate: {migrated}")
        return total, migrated

    # Write to temporary file in same directory for atomic rename
    dir_name = os.path.dirname(os.path.abspath(path))
    fd, tmp_path = tempfile.mkstemp(suffix=".jsonl.tmp", dir=dir_name)

    try:
        with open(path) as infile, os.fdopen(fd, "w") as outfile:
            for line in infile:
                line = line.strip()
                if not line:
                    continue
                record = json.loads(line)
                total += 1
                had_fields = "max_modal_depth" in record
                record = migrate_record(record)
                if not had_fields:
                    migrated += 1
                outfile.write(json.dumps(record, separators=(",", ":")) + "\n")

        # Atomic rename
        os.replace(tmp_path, path)
        print(f"  Migrated {path}: {total} records, {migrated} newly migrated")
    except Exception:
        # Clean up on failure
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
        raise

    return total, migrated


def main():
    args = sys.argv[1:]
    dry_run = "--dry-run" in args
    files = [a for a in args if not a.startswith("--")]

    if not files:
        print("Usage: python scripts/migrate_schema_v2.py [--dry-run] FILE [FILE ...]")
        sys.exit(1)

    print("Schema Migration v2: Adding max_modal_depth and max_temporal_depth")
    print("=" * 60)

    total_files = 0
    total_records = 0
    total_migrated = 0

    for path in files:
        if not os.path.exists(path):
            print(f"  WARNING: {path} not found, skipping")
            continue
        records, migrated = migrate_file(path, dry_run=dry_run)
        total_files += 1
        total_records += records
        total_migrated += migrated

    print()
    print(f"Summary: {total_files} files, {total_records} records, {total_migrated} migrated")
    if dry_run:
        print("(Dry run - no files modified)")


if __name__ == "__main__":
    main()
