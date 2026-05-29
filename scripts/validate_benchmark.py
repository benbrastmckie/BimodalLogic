#!/usr/bin/env python3
"""
BMLogic-Bench Validation: Oracle result analysis and quality checks.

Analyzes the oracle-validated benchmark file, verifies label consistency
with production data, and reports statistics.

Usage:
    python scripts/validate_benchmark.py [--input PATH]

Input:
    data/bmlogic-bench-validated.jsonl - Oracle-validated benchmark

Output:
    Prints validation report to stdout
"""

import json
import sys
import os
from collections import Counter, defaultdict


def classify_tier(complexity: int) -> str:
    if complexity <= 3:
        return "easy"
    elif complexity <= 6:
        return "medium"
    elif complexity <= 9:
        return "hard"
    else:
        return "very_hard"


def main():
    import argparse
    parser = argparse.ArgumentParser(description="BMLogic-Bench Validation Report")
    parser.add_argument("--input", default="data/bmlogic-bench-validated.jsonl",
                        help="Path to oracle-validated benchmark")
    parser.add_argument("--production-medium", default="data/bmlogic-c5.jsonl")
    parser.add_argument("--production-deep", default="data/bmlogic-c7.jsonl")
    args = parser.parse_args()

    print("BMLogic-Bench Validation Report")
    print("=" * 40)
    print()

    # Load validated benchmark
    records = []
    with open(args.input) as f:
        for line in f:
            line = line.strip()
            if line:
                records.append(json.loads(line))
    print(f"Total records: {len(records)}")

    # Label distribution
    labels = Counter(r.get("label") for r in records)
    print(f"\nLabel distribution:")
    for label, count in sorted(labels.items()):
        pct = count * 100 / len(records)
        print(f"  {label}: {count} ({pct:.1f}%)")

    # Filter out timeouts for the usable benchmark
    usable = [r for r in records if r.get("label") in ("valid", "invalid")]
    print(f"\nUsable (non-timeout): {len(usable)}")
    usable_labels = Counter(r["label"] for r in usable)
    valid_count = usable_labels.get("valid", 0)
    invalid_count = usable_labels.get("invalid", 0)
    print(f"  Valid: {valid_count} ({valid_count*100/len(usable):.1f}%)")
    print(f"  Invalid: {invalid_count} ({invalid_count*100/len(usable):.1f}%)")

    # Tier distribution
    tier_counts = defaultdict(lambda: {"valid": 0, "invalid": 0, "timeout": 0})
    for r in records:
        complexity = r.get("metrics", {}).get("complexity", 5)
        tier = classify_tier(complexity)
        label = r.get("label", "unknown")
        if label in tier_counts[tier]:
            tier_counts[tier][label] += 1

    print(f"\nTier distribution:")
    total_usable = len(usable)
    for tier in ["easy", "medium", "hard", "very_hard"]:
        counts = tier_counts[tier]
        total_tier = counts["valid"] + counts["invalid"]
        pct = total_tier * 100 / total_usable if total_usable > 0 else 0
        print(f"  {tier}: {total_tier} ({pct:.1f}%) "
              f"[valid={counts['valid']}, invalid={counts['invalid']}, timeout={counts['timeout']}]")

    # Label consistency with production data
    if os.path.exists(args.production_medium) and os.path.exists(args.production_deep):
        print(f"\nProduction label consistency check:")
        prod_labels = {}
        for path in [args.production_medium, args.production_deep]:
            with open(path) as f:
                for line in f:
                    line = line.strip()
                    if line:
                        r = json.loads(line)
                        if r.get("label") in ("valid", "invalid"):
                            prod_labels[r.get("formula_str")] = r["label"]

        mismatches = 0
        checked = 0
        for r in usable:
            fstr = r.get("formula_str", "")
            if fstr in prod_labels:
                checked += 1
                if prod_labels[fstr] != r["label"]:
                    mismatches += 1
                    print(f"  MISMATCH: {fstr[:60]}... "
                          f"prod={prod_labels[fstr]} oracle={r['label']}")
        print(f"  Checked {checked} formulas against production labels")
        print(f"  Mismatches: {mismatches}")

    # Duplicate check
    formula_strs = [r.get("formula_str", "") for r in usable]
    dupes = len(formula_strs) - len(set(formula_strs))
    print(f"\nDuplicate formulas: {dupes}")

    print(f"\nValidation complete.")
    print(f"Usable benchmark size: {len(usable)} formulas")
    print(f"Valid/Invalid ratio: {valid_count}/{invalid_count} "
          f"= {valid_count*100/len(usable):.1f}%/{invalid_count*100/len(usable):.1f}%")


if __name__ == "__main__":
    main()
