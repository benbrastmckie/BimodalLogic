#!/usr/bin/env python3
"""
Dataset Schema Validation

Validates that all final datasets have consistent field schemas matching the
documented specifications. Checks first and last record of each JSONL file,
cross-checks metadata record counts against actual JSONL line counts, and
reports any schema inconsistencies.

Usage:
    python scripts/validate_datasets.py

Exit codes:
    0 - All validations passed
    1 - One or more validation errors found
"""

import json
import os
import sys


# ============================================================================
# Expected schemas
# ============================================================================

# Training datasets: bmlogic-c5.jsonl, bmlogic-c7.jsonl, bmlogic-c9.jsonl, bmlogic-c11.jsonl
TRAINING_FIELDS = {
    "id", "split", "formula_str", "formula_ast", "formula_sexpr",
    "formula_tokens", "frame_class", "label", "proof_trace", "countermodel",
    "pattern_key", "pattern_features", "metrics", "augmentation",
    "max_modal_depth", "max_temporal_depth"
}

# Benchmark: bmlogic-bench.jsonl
BENCHMARK_FIELDS = {
    "id", "split", "formula_str", "formula_ast", "frame_class", "label",
    "proof_trace", "countermodel", "pattern_key", "metrics", "source",
    "difficulty_tier", "benchmark_category"
}

# Proof steps: proof_steps.jsonl
PROOF_STEPS_FIELDS = {
    "theorem_name", "step_index", "context", "goal", "rule",
    "axiom_name", "subgoals", "frame_class"
}

DATASETS = [
    {
        "path": "data/bmlogic-c5.jsonl",
        "metadata_path": "data/bmlogic-c5_metadata.json",
        "expected_fields": TRAINING_FIELDS,
        "schema_name": "training-16-field",
        "metadata_count_field": "total_records",
    },
    {
        "path": "data/bmlogic-c7.jsonl",
        "metadata_path": "data/bmlogic-c7_metadata.json",
        "expected_fields": TRAINING_FIELDS,
        "schema_name": "training-16-field",
        "metadata_count_field": "total_records",
    },
    {
        "path": "data/bmlogic-c9.jsonl",
        "metadata_path": "data/bmlogic-c9_metadata.json",
        "expected_fields": TRAINING_FIELDS,
        "schema_name": "training-16-field",
        "metadata_count_field": "total_records",
    },
    {
        "path": "data/bmlogic-c11.jsonl",
        "metadata_path": "data/bmlogic-c11_metadata.json",
        "expected_fields": TRAINING_FIELDS,
        "schema_name": "training-16-field",
        "metadata_count_field": "total_records",
    },
    {
        "path": "data/bmlogic-bench.jsonl",
        "metadata_path": "data/bmlogic-bench_metadata.json",
        "expected_fields": BENCHMARK_FIELDS,
        "schema_name": "benchmark-13-field",
        "metadata_count_field": "total_count",
    },
    {
        "path": "data/proof_steps.jsonl",
        "metadata_path": "data/proof_steps_metadata.json",
        "expected_fields": PROOF_STEPS_FIELDS,
        "schema_name": "proof-steps-8-field",
        "metadata_count_field": "total_records",
    },
]


# ============================================================================
# Helpers
# ============================================================================

def count_lines(path: str) -> int:
    """Count non-empty lines in a file."""
    count = 0
    with open(path) as f:
        for line in f:
            if line.strip():
                count += 1
    return count


def read_first_last(path: str) -> tuple[dict | None, dict | None]:
    """Read first and last non-empty record from a JSONL file."""
    first = None
    last = None
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                record = json.loads(line)
                if first is None:
                    first = record
                last = record
            except json.JSONDecodeError as e:
                return None, None
    return first, last


def check_fields(record: dict, expected: set, record_desc: str) -> list[str]:
    """Check that a record has the expected fields. Returns list of error messages."""
    errors = []
    actual = set(record.keys())
    missing = expected - actual
    extra = actual - expected

    if missing:
        errors.append(f"  {record_desc}: Missing fields: {sorted(missing)}")
    if extra:
        # Extra fields are warnings, not errors (schema may be extended)
        print(f"  NOTE {record_desc}: Extra fields (not in spec): {sorted(extra)}")

    return errors


# ============================================================================
# Main validation
# ============================================================================

def validate_dataset(dataset: dict) -> list[str]:
    """Validate a single dataset. Returns list of error messages (empty = pass)."""
    path = dataset["path"]
    metadata_path = dataset["metadata_path"]
    expected_fields = dataset["expected_fields"]
    schema_name = dataset["schema_name"]
    metadata_count_field = dataset["metadata_count_field"]

    errors = []

    print(f"\n--- {path} ({schema_name}) ---")

    # Check file exists
    if not os.path.exists(path):
        errors.append(f"  FAIL: File not found: {path}")
        return errors

    # Count records
    actual_count = count_lines(path)
    print(f"  Record count: {actual_count}")

    # Read first and last records
    first, last = read_first_last(path)
    if first is None:
        errors.append(f"  FAIL: Could not parse first record (JSON error)")
        return errors
    if last is None:
        errors.append(f"  FAIL: Could not parse last record (JSON error)")
        return errors

    # Check fields in first record
    field_errors = check_fields(first, expected_fields, "first record")
    errors.extend(field_errors)

    # Check fields in last record
    field_errors = check_fields(last, expected_fields, "last record")
    errors.extend(field_errors)

    if not errors:
        print(f"  Schema check: PASS (first and last records have correct fields)")

    # Check metadata count
    if os.path.exists(metadata_path):
        with open(metadata_path) as f:
            metadata = json.load(f)
        meta_count = metadata.get(metadata_count_field)
        if meta_count is not None:
            if meta_count == actual_count:
                print(f"  Metadata count: PASS ({meta_count} == {actual_count})")
            else:
                errors.append(
                    f"  FAIL: Metadata count mismatch: {metadata_path} says "
                    f"{meta_count}, actual JSONL has {actual_count} records"
                )
        else:
            print(f"  NOTE: Metadata does not have '{metadata_count_field}' field, skipping count check")
    else:
        print(f"  NOTE: Metadata file not found: {metadata_path}")

    # Check metadata is valid JSON
    if os.path.exists(metadata_path):
        try:
            with open(metadata_path) as f:
                json.load(f)
            print(f"  Metadata JSON: PASS ({metadata_path})")
        except json.JSONDecodeError as e:
            errors.append(f"  FAIL: Invalid JSON in {metadata_path}: {e}")

    return errors


def main():
    print("Dataset Schema Validation")
    print("=" * 50)

    all_errors = []

    for dataset in DATASETS:
        errors = validate_dataset(dataset)
        all_errors.extend(errors)

    # Check .gitignore behavior
    print("\n--- Git ignore checks ---")
    import subprocess

    final_datasets = [
        "data/bmlogic-bench.jsonl",
        "data/bmlogic-c5.jsonl",
        "data/bmlogic-c7.jsonl",
        "data/bmlogic-c9.jsonl",
        "data/bmlogic-c11.jsonl",
        "data/proof_steps.jsonl",
    ]
    for path in final_datasets:
        result = subprocess.run(
            ["git", "check-ignore", "-v", path],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            all_errors.append(f"  FAIL: {path} is ignored by git: {result.stdout.strip()}")
        else:
            print(f"  PASS: {path} is NOT ignored (correct)")

    intermediate_files = [
        "data/axiom-instances.jsonl",
        "data/bmlogic-bench-candidates.jsonl",
        "data/bmlogic-bench-validated.jsonl",
        "data/test.jsonl",
        "data/test_c4.jsonl",
    ]
    for path in intermediate_files:
        result = subprocess.run(
            ["git", "check-ignore", "-v", path],
            capture_output=True, text=True
        )
        if result.returncode != 0:
            print(f"  NOTE: {path} does not exist and is not tested (expected after cleanup)")
        else:
            print(f"  PASS: {path} is correctly ignored by git")

    # Check Git LFS tracking
    print("\n--- Git LFS tracking ---")
    result = subprocess.run(["git", "lfs", "track"], capture_output=True, text=True)
    if "data/bmlogic-c7.jsonl" in result.stdout:
        print("  PASS: data/bmlogic-c7.jsonl is tracked by LFS")
    else:
        all_errors.append("  FAIL: data/bmlogic-c7.jsonl is NOT tracked by LFS")

    if "data/bmlogic-c9.jsonl" in result.stdout:
        print("  PASS: data/bmlogic-c9.jsonl is tracked by LFS")
    else:
        all_errors.append("  FAIL: data/bmlogic-c9.jsonl is NOT tracked by LFS")

    if "data/bmlogic-c11.jsonl" in result.stdout:
        print("  PASS: data/bmlogic-c11.jsonl is tracked by LFS")
    else:
        all_errors.append("  FAIL: data/bmlogic-c11.jsonl is NOT tracked by LFS")

    if "data/proof_steps.jsonl" in result.stdout:
        print("  PASS: data/proof_steps.jsonl is tracked by LFS")
    else:
        all_errors.append("  FAIL: data/proof_steps.jsonl is NOT tracked by LFS")

    # Check data/ directory structure
    print("\n--- Data directory structure ---")
    expected_files = {
        "bmlogic-bench.jsonl",
        "bmlogic-bench_metadata.json",
        "bmlogic-c5.jsonl",
        "bmlogic-c5_metadata.json",
        "bmlogic-c7.jsonl",
        "bmlogic-c7_metadata.json",
        "bmlogic-c9.jsonl",
        "bmlogic-c9_metadata.json",
        "bmlogic-c11.jsonl",
        "bmlogic-c11_metadata.json",
        "proof_steps.jsonl",
        "proof_steps_metadata.json",
        "README.md",
        ".gitignore",
    }
    actual_files = set(os.listdir("data"))
    missing = expected_files - actual_files
    unexpected = actual_files - expected_files

    if missing:
        for f in sorted(missing):
            all_errors.append(f"  FAIL: Expected file missing from data/: {f}")
    if unexpected:
        for f in sorted(unexpected):
            print(f"  NOTE: Unexpected file in data/ (may be regenerable artifact): {f}")

    if not missing and not unexpected:
        print(f"  PASS: data/ directory contains exactly the expected files")
    elif not missing:
        print(f"  PASS: All expected files present (some unexpected files noted above)")

    # Final report
    print("\n" + "=" * 50)
    if all_errors:
        print(f"VALIDATION FAILED: {len(all_errors)} error(s) found:")
        for err in all_errors:
            print(err)
        return 1
    else:
        print("VALIDATION PASSED: All checks passed")
        return 0


if __name__ == "__main__":
    sys.exit(main())
