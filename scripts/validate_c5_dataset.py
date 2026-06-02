#!/usr/bin/env python3
"""
Validate a bmlogic JSONL dataset for well-formedness, field completeness,
and acceptable timeout rate.

Usage:
    python3 scripts/validate_c5_dataset.py data/bmlogic-c5.jsonl

Exit codes:
    0 - All checks pass
    1 - One or more checks failed

Checks performed:
    1. JSONL parsing (no malformed lines)
    2. All 25 expected fields present in every record
    3. No null metrics (complexity, modalDepth, etc.)
    4. decision_method never null
    5. Valid records have non-null proof_trace and rule_profile
    6. Invalid records have non-null countermodel and countermodel_consistent
    7. Timeout rate < 5%
    8. Regression formula check: box(bot) -> box(r) labeled valid
"""

import json
import sys
from pathlib import Path

# All 25 expected fields in the JSONL schema
EXPECTED_FIELDS = {
    "id", "split", "formula_str", "formula_ast", "frame_class",
    "label", "decision_method", "proof_reconstruction_method",
    "proof_trace", "rule_profile", "countermodel", "countermodel_consistent",
    "enriched_countermodel", "semantic_countermodel", "pattern_key",
    "metrics", "augmentation", "formula_sexpr", "formula_tokens",
    "pattern_features", "max_modal_depth", "max_temporal_depth",
    "formula_folded_json", "formula_folded_str", "formula_folded_sexpr",
}

# Required non-null metric sub-fields
REQUIRED_METRIC_FIELDS = {
    "complexity", "modalDepth", "temporalDepth",
    "impCount", "atomCount", "decisionTimeMs", "difficultyTier",
}


def validate_dataset(path: str) -> bool:
    """Validate a JSONL dataset file. Returns True if all checks pass."""
    filepath = Path(path)
    if not filepath.exists():
        print(f"ERROR: File not found: {path}")
        return False

    records = []
    parse_errors = 0
    line_count = 0

    # Check 1: JSONL parsing
    print("=== JSONL Parsing ===")
    with open(filepath) as f:
        for i, line in enumerate(f, 1):
            line_count += 1
            line = line.strip()
            if not line:
                continue
            try:
                record = json.loads(line)
                records.append(record)
            except json.JSONDecodeError as e:
                parse_errors += 1
                print(f"  [FAIL] Line {i}: {e}")

    if parse_errors > 0:
        print(f"  Parse errors: {parse_errors}")
    else:
        print(f"  [PASS] {len(records)} records parsed, 0 errors")

    if not records:
        print("ERROR: No records found")
        return False

    # Check 2: Field completeness
    print("\n=== Field Completeness ===")
    missing_field_count = 0
    for record in records:
        missing = EXPECTED_FIELDS - set(record.keys())
        if missing:
            missing_field_count += 1
            if missing_field_count <= 3:  # Only show first 3
                print(f"  [FAIL] {record.get('id', '?')}: missing {missing}")

    if missing_field_count > 0:
        print(f"  {missing_field_count} records with missing fields")
    else:
        print(f"  [PASS] All {len(records)} records have all {len(EXPECTED_FIELDS)} fields")

    # Check 3: No null metrics
    print("\n=== Metrics Completeness ===")
    null_metrics_count = 0
    for record in records:
        metrics = record.get("metrics")
        if metrics is None:
            null_metrics_count += 1
            continue
        for field in REQUIRED_METRIC_FIELDS:
            if metrics.get(field) is None:
                null_metrics_count += 1
                if null_metrics_count <= 3:
                    print(f"  [FAIL] {record['id']}: metrics.{field} is null")
                break

    if null_metrics_count > 0:
        print(f"  {null_metrics_count} records with null metrics")
    else:
        print(f"  [PASS] All {len(records)} records have complete metrics")

    # Check 4: decision_method never null
    print("\n=== Decision Method ===")
    null_method_count = sum(
        1 for r in records if r.get("decision_method") is None
    )
    if null_method_count > 0:
        print(f"  [FAIL] {null_method_count} records with null decision_method")
    else:
        print(f"  [PASS] All records have non-null decision_method")

    # Check 5: Valid records have proof_trace and rule_profile
    print("\n=== Valid Record Completeness ===")
    valid_records = [r for r in records if r["label"] == "valid"]
    valid_missing_trace = sum(
        1 for r in valid_records if r.get("proof_trace") is None
    )
    valid_missing_profile = sum(
        1 for r in valid_records if r.get("rule_profile") is None
    )
    if valid_missing_trace > 0 or valid_missing_profile > 0:
        print(f"  [FAIL] {valid_missing_trace} valid records missing proof_trace, "
              f"{valid_missing_profile} missing rule_profile")
    else:
        print(f"  [PASS] All {len(valid_records)} valid records have proof_trace and rule_profile")

    # Check 6: Invalid records have countermodel and countermodel_consistent
    print("\n=== Invalid Record Completeness ===")
    invalid_records = [r for r in records if r["label"] == "invalid"]
    invalid_missing_cm = sum(
        1 for r in invalid_records if r.get("countermodel") is None
    )
    invalid_missing_cc = sum(
        1 for r in invalid_records if r.get("countermodel_consistent") is None
    )
    if invalid_missing_cm > 0 or invalid_missing_cc > 0:
        print(f"  [FAIL] {invalid_missing_cm} invalid records missing countermodel, "
              f"{invalid_missing_cc} missing countermodel_consistent")
    else:
        print(f"  [PASS] All {len(invalid_records)} invalid records have countermodel "
              f"and countermodel_consistent")

    # Check 7: Timeout rate < 5%
    print("\n=== Timeout Rate ===")
    timeout_records = [r for r in records if r["label"] == "timeout"]
    timeout_rate = len(timeout_records) / len(records) * 100 if records else 0
    if timeout_rate >= 5.0:
        print(f"  [FAIL] Timeout rate {timeout_rate:.1f}% >= 5% "
              f"({len(timeout_records)}/{len(records)})")
    else:
        print(f"  [PASS] Timeout rate {timeout_rate:.1f}% < 5% "
              f"({len(timeout_records)}/{len(records)})")

    # Check 8: Regression formula check
    print("\n=== Regression Formula Check ===")
    # box(bot) -> box(r) should be labeled valid
    regression_formula = "(imp (box bot) (box (atom \"r\")))"
    regression_found = False
    regression_passed = False
    for record in records:
        sexpr = record.get("formula_sexpr", "")
        if sexpr == regression_formula:
            regression_found = True
            if record["label"] == "valid":
                regression_passed = True
                print(f"  [PASS] {record['id']} ({record['formula_str']}) → "
                      f"valid (method: {record['decision_method']})")
            else:
                print(f"  [FAIL] {record['id']} ({record['formula_str']}) → "
                      f"expected valid, got {record['label']}")
            break

    if not regression_found:
        print("  [SKIP] Regression formula (box(bot) -> box(r)) not found in dataset")

    # Summary
    print("\n=== Summary ===")
    label_counts = {}
    for r in records:
        lbl = r["label"]
        label_counts[lbl] = label_counts.get(lbl, 0) + 1

    print(f"  Total records: {len(records)}")
    for lbl in ["valid", "invalid", "timeout"]:
        count = label_counts.get(lbl, 0)
        pct = count / len(records) * 100 if records else 0
        print(f"  {lbl}: {count} ({pct:.1f}%)")
    print(f"  Parse errors: {parse_errors}")
    print(f"  Timeout rate: {timeout_rate:.1f}%")

    # Overall result
    all_passed = (
        parse_errors == 0
        and missing_field_count == 0
        and null_metrics_count == 0
        and null_method_count == 0
        and valid_missing_trace == 0
        and valid_missing_profile == 0
        and invalid_missing_cm == 0
        and invalid_missing_cc == 0
        and timeout_rate < 5.0
        and (regression_passed or not regression_found)
    )

    if all_passed:
        print("\n*** OVERALL: PASS ***")
    else:
        print("\n*** OVERALL: FAIL ***")

    return all_passed


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <dataset.jsonl>")
        sys.exit(1)

    path = sys.argv[1]
    passed = validate_dataset(path)
    sys.exit(0 if passed else 1)


if __name__ == "__main__":
    main()
