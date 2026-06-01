#!/usr/bin/env python3
"""
Curate very_hard+ benchmark slice from c9 dataset.

Selects 100+ records at complexity 8-9 from the c9 training dataset using
difficulty heuristics. Records are converted to benchmark schema and can be
appended to the existing bmlogic-bench.jsonl or written standalone.

Heuristics (priority order):
1. label == "timeout" (hardest for the decision procedure)
2. modalDepth == 2 AND temporalDepth == 2 (maximum structural depth)
3. Highest impCount (most complex propositional structure)

Usage:
    python scripts/curate_very_hard_plus.py [--input PATH] [--output PATH] [--target N]
    python scripts/curate_very_hard_plus.py --append  # Append to bmlogic-bench.jsonl

Options:
    --input PATH    Input c9 JSONL (default: data/bmlogic-c9.jsonl)
    --output PATH   Output JSONL (default: data/very_hard_plus.jsonl)
    --target N      Target record count (default: 120)
    --append        Append to data/bmlogic-bench.jsonl and update metadata
    --dry-run       Print statistics without writing files
"""

import json
import sys
import os
import random
from collections import Counter, defaultdict
from datetime import datetime

RANDOM_SEED = 42217
random.seed(RANDOM_SEED)


def load_jsonl(path: str) -> list[dict]:
    """Load a JSONL file, returning list of parsed records."""
    records = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line:
                records.append(json.loads(line))
    return records


def difficulty_score(record: dict) -> tuple[int, int, int, int]:
    """
    Score a record for difficulty (higher = harder).
    Returns tuple for sorting: (timeout_flag, both_depths_max, imp_count, complexity).
    """
    metrics = record.get("metrics", {})
    pattern_key = record.get("pattern_key", {})

    # Priority 1: timeout label
    is_timeout = 1 if record.get("label") == "timeout" else 0

    # Priority 2: both modal and temporal depth at max (2)
    modal_depth = pattern_key.get("modalDepth", 0)
    temporal_depth = pattern_key.get("temporalDepth", 0)
    both_max = 1 if (modal_depth == 2 and temporal_depth == 2) else 0

    # Priority 3: implication count
    imp_count = metrics.get("impCount", 0)

    # Priority 4: complexity
    complexity = metrics.get("complexity", 0)

    return (is_timeout, both_max, imp_count, complexity)


def to_benchmark_record(record: dict, bench_id: str) -> dict:
    """Convert a training record to benchmark schema (13 fields)."""
    metrics = record.get("metrics", {})
    complexity = metrics.get("complexity", 0)

    if complexity <= 3:
        tier = "easy"
    elif complexity <= 6:
        tier = "medium"
    elif complexity <= 9:
        tier = "hard"
    else:
        tier = "very_hard"

    return {
        "id": bench_id,
        "split": "benchmark",
        "formula_str": record.get("formula_str", ""),
        "formula_ast": record.get("formula_ast"),
        "frame_class": record.get("frame_class", "Base"),
        "label": record.get("label"),
        "proof_trace": record.get("proof_trace"),
        "countermodel": record.get("countermodel"),
        "pattern_key": record.get("pattern_key"),
        "metrics": metrics,
        "benchmark_category": "very_hard_plus",
        "source": "production_c9",
        "difficulty_tier": tier,
    }


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Curate very_hard+ benchmark slice")
    parser.add_argument("--input", default="data/bmlogic-c9.jsonl",
                        help="Input c9 JSONL file")
    parser.add_argument("--output", default="data/very_hard_plus.jsonl",
                        help="Output JSONL for very_hard+ records")
    parser.add_argument("--target", type=int, default=120,
                        help="Target number of records")
    parser.add_argument("--append", action="store_true",
                        help="Append to bmlogic-bench.jsonl and update metadata")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print statistics without writing")
    args = parser.parse_args()

    print("Very Hard+ Benchmark Curation")
    print("=" * 40)
    print()

    if not os.path.exists(args.input):
        print(f"ERROR: Input file not found: {args.input}")
        print("Run the c9 dataset generation first:")
        print("  ./scripts/run_dataset_generation.sh c9")
        sys.exit(1)

    # Step 1: Load c9 dataset
    print(f"Step 1: Loading {args.input}...")
    all_records = load_jsonl(args.input)
    print(f"  Total records: {len(all_records)}")

    # Step 2: Filter to complexity 8-9 only
    c89_records = [
        r for r in all_records
        if r.get("metrics", {}).get("complexity", 0) in (8, 9)
    ]
    print(f"  Complexity 8-9 records: {len(c89_records)}")

    if len(c89_records) == 0:
        print("ERROR: No complexity 8-9 records found in input.")
        sys.exit(1)

    # Step 3: Analyze pool
    labels = Counter(r.get("label") for r in c89_records)
    print(f"\n  Label distribution: {dict(labels)}")
    c8 = sum(1 for r in c89_records if r.get("metrics", {}).get("complexity") == 8)
    c9 = sum(1 for r in c89_records if r.get("metrics", {}).get("complexity") == 9)
    print(f"  Complexity 8: {c8}, Complexity 9: {c9}")

    # Step 4: Score and rank by difficulty
    print(f"\nStep 2: Ranking by difficulty...")
    scored = sorted(c89_records, key=difficulty_score, reverse=True)

    # Step 5: Select with balanced valid/invalid mix
    target = args.target
    valid_target = target // 3  # Aim for ~33% valid (natural ratio is low at c8-9)
    invalid_target = target - valid_target

    valid_pool = [r for r in scored if r.get("label") == "valid"]
    invalid_pool = [r for r in scored if r.get("label") == "invalid"]
    timeout_pool = [r for r in scored if r.get("label") == "timeout"]

    print(f"  Available valid: {len(valid_pool)}")
    print(f"  Available invalid: {len(invalid_pool)}")
    print(f"  Available timeout: {len(timeout_pool)}")

    selected = []

    # Take timeout records first (most interesting)
    timeout_take = min(len(timeout_pool), target // 5)  # Up to 20% timeout
    selected.extend(timeout_pool[:timeout_take])

    # Take valid records
    remaining_valid = valid_target
    valid_selected = valid_pool[:remaining_valid]
    selected.extend(valid_selected)

    # Fill rest with invalid
    remaining = target - len(selected)
    invalid_selected = invalid_pool[:remaining]
    selected.extend(invalid_selected)

    # If still short, take more from any pool
    if len(selected) < target:
        all_remaining = [r for r in scored if r not in selected]
        needed = target - len(selected)
        selected.extend(all_remaining[:needed])

    # Deduplicate by formula_str
    seen = set()
    deduped = []
    for r in selected:
        fstr = r.get("formula_str", "")
        if fstr not in seen:
            seen.add(fstr)
            deduped.append(r)
    selected = deduped[:target]

    print(f"\nStep 3: Selected {len(selected)} records")
    sel_labels = Counter(r.get("label") for r in selected)
    print(f"  Labels: {dict(sel_labels)}")
    sel_c = Counter(r.get("metrics", {}).get("complexity", 0) for r in selected)
    print(f"  Complexity: {dict(sel_c)}")

    # Check GoalCategory diversity
    categories = set()
    for r in selected:
        pk = r.get("pattern_key", {})
        cat = pk.get("category") if pk else None
        if cat:
            categories.add(cat)
    print(f"  GoalCategory types: {len(categories)}")

    if args.dry_run:
        print("\n(Dry run - no files written)")
        return

    # Step 6: Convert to benchmark schema
    if args.append:
        # Load existing benchmark
        bench_path = "data/bmlogic-bench.jsonl"
        existing = load_jsonl(bench_path)
        existing_formulas = {r.get("formula_str") for r in existing}
        next_id = len(existing) + 1

        # Remove duplicates already in benchmark
        new_records = []
        for r in selected:
            if r.get("formula_str") not in existing_formulas:
                bench_record = to_benchmark_record(r, f"bmlogic-bench-{next_id:05d}")
                new_records.append(bench_record)
                existing_formulas.add(r.get("formula_str"))
                next_id += 1

        print(f"\nStep 4: Appending {len(new_records)} new records to {bench_path}")
        print(f"  (Skipped {len(selected) - len(new_records)} duplicates)")

        # Append to benchmark
        with open(bench_path, "a") as f:
            for r in new_records:
                f.write(json.dumps(r, ensure_ascii=False) + "\n")

        # Update metadata
        all_bench = existing + new_records
        total = len(all_bench)
        valid_count = sum(1 for r in all_bench if r.get("label") == "valid")
        invalid_count = sum(1 for r in all_bench if r.get("label") == "invalid")
        tier_counts = Counter(r.get("difficulty_tier", "unknown") for r in all_bench)
        cat_counts = Counter(r.get("benchmark_category", "unknown") for r in all_bench)
        source_counts = Counter(r.get("source", "unknown") for r in all_bench)

        # Load existing metadata and update
        meta_path = "data/bmlogic-bench_metadata.json"
        with open(meta_path) as f:
            metadata = json.load(f)

        metadata["total_count"] = total
        metadata["valid_count"] = valid_count
        metadata["invalid_count"] = invalid_count
        metadata["valid_ratio"] = round(valid_count / total, 4) if total > 0 else 0
        metadata["generation_date"] = datetime.now().isoformat()
        metadata["tier_distribution"] = {
            tier: {"count": tier_counts.get(tier, 0),
                   "percentage": round(tier_counts.get(tier, 0) * 100 / total, 1)}
            for tier in ["easy", "medium", "hard", "very_hard"]
        }
        metadata["category_distribution"] = dict(cat_counts)
        metadata["source_distribution"] = dict(source_counts)
        metadata["very_hard_plus"] = {
            "total": len(new_records),
            "source": "c9_complexity_8_9",
            "selection_criteria": "difficulty_scored: timeout > dual_depth_max > imp_count",
        }

        with open(meta_path, "w") as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)

        print(f"  Updated {meta_path}")
        print(f"  Total benchmark size: {total}")

    else:
        # Write standalone file
        records_out = []
        for i, r in enumerate(selected):
            bench_record = to_benchmark_record(r, f"vh-plus-{i+1:05d}")
            records_out.append(bench_record)

        print(f"\nStep 4: Writing {len(records_out)} records to {args.output}")
        os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
        with open(args.output, "w") as f:
            for r in records_out:
                f.write(json.dumps(r, ensure_ascii=False) + "\n")

    print("\nDone!")


if __name__ == "__main__":
    main()
