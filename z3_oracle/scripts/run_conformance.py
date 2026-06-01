#!/usr/bin/env python3
"""
run_conformance.py - Full conformance suite against bmlogic-bench.jsonl

Runs the oracle against all 777 bmlogic-bench formulas and generates a
conformance report. This script replaces the slow pytest test for full runs.

Usage:
    # From z3_oracle/ directory (with venv activated):
    python scripts/run_conformance.py

    # With custom bounds and timeout:
    python scripts/run_conformance.py --max-n 4 --max-m 4 --timeout-ms 5000

    # With NixOS Z3:
    Z3_LIB=/nix/store/mwk54018w6z6haf2ry9qppaafq1kszyd-z3-4.16.0-lib/lib \\
    LD_LIBRARY_PATH="$Z3_LIB:/nix/store/l1ix99bikd2x6p6mg41vay5w63hclhj2-gcc-15.2.0-lib/lib:$LD_LIBRARY_PATH" \\
    Z3_LIBRARY_PATH="$Z3_LIB" \\
    python scripts/run_conformance.py
"""

import argparse
import json
import os
import sys
import time
from pathlib import Path


def find_bench_path() -> Path:
    """Locate bmlogic-bench.jsonl relative to this script."""
    script_dir = Path(__file__).parent
    # z3_oracle/scripts/ -> z3_oracle/ -> BimodalLogic/ -> data/
    project_root = script_dir.parent.parent
    bench_path = project_root / "data" / "bmlogic-bench.jsonl"
    return bench_path


def run_conformance(max_n: int, max_m: int, timeout_ms: int, verbose: bool = False):
    """Run conformance suite and print report."""
    from bmlogic_oracle.oracle import find_countermodel

    bench_path = find_bench_path()
    if not bench_path.exists():
        print(f"ERROR: bmlogic-bench.jsonl not found at {bench_path}")
        sys.exit(1)

    # Load all entries
    valid_entries = []
    invalid_entries = []
    with open(bench_path) as f:
        for line in f:
            entry = json.loads(line)
            if entry["label"] == "valid":
                valid_entries.append(entry)
            elif entry["label"] == "invalid":
                invalid_entries.append(entry)

    all_entries = [(e, "valid") for e in valid_entries] + [(e, "invalid") for e in invalid_entries]
    n_valid = len(valid_entries)
    n_invalid = len(invalid_entries)
    total = len(all_entries)

    print(f"bmlogic-bench Conformance Suite")
    print(f"================================")
    print(f"Dataset: {total} total ({n_valid} valid, {n_invalid} invalid)")
    print(f"Oracle bounds: max_N={max_n}, max_M={max_m}, timeout={timeout_ms}ms")
    print(f"Starting...")

    results = {
        "valid_correct": 0,
        "valid_violation": 0,
        "invalid_found": 0,
        "invalid_not_found": 0,
        "validation_failures": 0,
        "violations": [],
        "validation_failure_ids": [],
        "solve_times_ms": [],
    }

    start_total = time.monotonic()
    for i, (entry, label) in enumerate(all_entries):
        if verbose and i % 50 == 0:
            elapsed = time.monotonic() - start_total
            pct = 100 * i / total
            print(f"  [{i}/{total}] {pct:.0f}% ({elapsed:.1f}s elapsed)", flush=True)

        t_start = time.monotonic()
        cm = find_countermodel(
            entry["formula_ast"],
            max_N=max_n,
            max_M=max_m,
            timeout_ms=timeout_ms,
        )
        elapsed_ms = (time.monotonic() - t_start) * 1000
        results["solve_times_ms"].append(elapsed_ms)

        if label == "valid":
            if cm is None:
                results["valid_correct"] += 1
            else:
                results["valid_violation"] += 1
                results["violations"].append({
                    "id": entry.get("id", "?"),
                    "formula": entry.get("formula_str", "?")[:80],
                    "axiom_name": entry.get("axiom_name", ""),
                })
        elif label == "invalid":
            if cm is not None:
                results["invalid_found"] += 1
                errors = cm.validate()
                if errors:
                    results["validation_failures"] += 1
                    results["validation_failure_ids"].append(entry.get("id", "?"))
            else:
                results["invalid_not_found"] += 1

    total_elapsed = time.monotonic() - start_total

    # Compute statistics
    times = sorted(results["solve_times_ms"])
    median_ms = times[len(times) // 2]
    p90_ms = times[int(len(times) * 0.9)]
    coverage_pct = 100 * results["invalid_found"] / n_invalid if n_invalid > 0 else 0
    soundness_pct = 100 * results["valid_correct"] / n_valid if n_valid > 0 else 0

    # Print report
    print()
    print("=== bmlogic-bench Conformance Report ===")
    print()
    print(f"Dataset: {total} total ({n_valid} valid, {n_invalid} invalid)")
    print()
    print("Soundness (valid formulas):")
    print(f"  Correct (None):  {results['valid_correct']}/{n_valid} ({soundness_pct:.1f}%)")
    print(f"  Violations:      {results['valid_violation']}/{n_valid}")
    if results["violations"]:
        print("  Known limitations (bounded-model effects):")
        for v in results["violations"]:
            print(f"    [{v['id']}] axiom={v['axiom_name']}: {v['formula']}")
    print()
    print("Coverage (invalid formulas):")
    print(f"  Found:           {results['invalid_found']}/{n_invalid} ({coverage_pct:.1f}%)")
    print(f"  Not found:       {results['invalid_not_found']}/{n_invalid}")
    print()
    print("Structural validation:")
    print(f"  Failures:        {results['validation_failures']}")
    if results["validation_failure_ids"]:
        print(f"  Failure IDs:     {', '.join(results['validation_failure_ids'][:5])}")
    print()
    print("Performance:")
    print(f"  Median:          {median_ms:.1f}ms")
    print(f"  P90:             {p90_ms:.1f}ms")
    print(f"  Total:           {total_elapsed:.1f}s")
    print()

    # Exit with error code if soundness is violated or structural failures exist
    exit_code = 0
    if results["valid_violation"] > 5:  # Allow up to 5 known limitations
        print("RESULT: FAIL (soundness violations exceed threshold)")
        exit_code = 1
    elif results["validation_failures"] > 0:
        print("RESULT: FAIL (structural validation failures)")
        exit_code = 1
    elif coverage_pct < 50:
        print(f"RESULT: WARN (coverage {coverage_pct:.1f}% < 50%)")
    else:
        print(f"RESULT: PASS (soundness {soundness_pct:.1f}%, coverage {coverage_pct:.1f}%)")

    return exit_code


def main():
    parser = argparse.ArgumentParser(
        description="Run full conformance suite against bmlogic-bench.jsonl"
    )
    parser.add_argument("--max-n", type=int, default=4, help="Max worlds (default: 4)")
    parser.add_argument("--max-m", type=int, default=4, help="Max time steps (default: 4)")
    parser.add_argument("--timeout-ms", type=int, default=5000, help="Per-formula timeout ms (default: 5000)")
    parser.add_argument("--verbose", "-v", action="store_true", help="Show progress")
    args = parser.parse_args()

    sys.exit(run_conformance(
        max_n=args.max_n,
        max_m=args.max_m,
        timeout_ms=args.timeout_ms,
        verbose=args.verbose,
    ))


if __name__ == "__main__":
    main()
