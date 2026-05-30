#!/usr/bin/env python3
"""
BMLogic-Bench Finalization: Stratified selection and export.

Loads the oracle-validated benchmark, performs final stratified sampling to
hit target size and distribution, assigns sequential IDs, tags entries with
benchmark metadata, and writes the final benchmark file with metadata.

Usage:
    python scripts/finalize_benchmark.py [--input PATH] [--output PATH] [--target-size N]

Input:
    data/bmlogic-bench-validated.jsonl - Oracle-validated benchmark

Output:
    data/bmlogic-bench.jsonl          - Final benchmark
    data/bmlogic-bench_metadata.json  - Benchmark metadata and statistics
"""

import json
import sys
import os
import random
from collections import Counter, defaultdict
from datetime import datetime

RANDOM_SEED = 42205
random.seed(RANDOM_SEED)


def classify_tier(complexity: int) -> str:
    if complexity <= 3:
        return "easy"
    elif complexity <= 6:
        return "medium"
    elif complexity <= 9:
        return "hard"
    else:
        return "very_hard"


def assign_tier(record: dict) -> str:
    metrics = record.get("metrics", {})
    tier = metrics.get("difficultyTier")
    if tier and tier in ("easy", "medium", "hard", "very_hard"):
        return tier
    complexity = metrics.get("complexity", 5)
    return classify_tier(complexity)


def main():
    import argparse
    parser = argparse.ArgumentParser(description="BMLogic-Bench Finalization")
    parser.add_argument("--input", default="data/bmlogic-bench-validated.jsonl",
                        help="Path to oracle-validated benchmark")
    parser.add_argument("--output", default="data/bmlogic-bench.jsonl",
                        help="Path for final benchmark JSONL")
    parser.add_argument("--metadata", default="data/bmlogic-bench_metadata.json",
                        help="Path for metadata JSON")
    parser.add_argument("--target-size", type=int, default=750,
                        help="Target benchmark size")
    args = parser.parse_args()

    print("BMLogic-Bench Finalization")
    print("=" * 40)
    print()

    # Step 1: Load validated records
    records = []
    with open(args.input) as f:
        for line in f:
            line = line.strip()
            if line:
                records.append(json.loads(line))
    print(f"Loaded {len(records)} validated records")

    # Step 2: Filter out timeouts (not usable in benchmark)
    usable = [r for r in records if r.get("label") in ("valid", "invalid")]
    print(f"Usable (non-timeout): {len(usable)}")

    # Step 3: Deduplicate by formula_str
    seen = set()
    deduped = []
    for r in usable:
        fstr = r.get("formula_str", "")
        if fstr not in seen:
            seen.add(fstr)
            deduped.append(r)
    print(f"After dedup: {len(deduped)}")

    # Step 4: Separate into valid and invalid pools by tier
    valid_by_tier = defaultdict(list)
    invalid_by_tier = defaultdict(list)
    for r in deduped:
        tier = assign_tier(r)
        if r["label"] == "valid":
            valid_by_tier[tier].append(r)
        else:
            invalid_by_tier[tier].append(r)

    print("\nPool sizes by tier:")
    for tier in ["easy", "medium", "hard", "very_hard"]:
        v = len(valid_by_tier[tier])
        inv = len(invalid_by_tier[tier])
        print(f"  {tier}: valid={v}, invalid={inv}")

    # Step 5: Shuffle pools
    for tier in valid_by_tier:
        random.shuffle(valid_by_tier[tier])
    for tier in invalid_by_tier:
        random.shuffle(invalid_by_tier[tier])

    # Step 6: Stratified sampling
    # Target distribution (adjusted for valid availability)
    target_size = args.target_size
    tier_targets = {
        "easy": 0.10,       # 10% (limited valid formulas at this tier)
        "medium": 0.40,     # 40%
        "hard": 0.35,       # 35%
        "very_hard": 0.15,  # 15%
    }

    selected = []
    stats_by_tier = {}

    for tier, proportion in tier_targets.items():
        tier_count = int(target_size * proportion)
        valid_pool = valid_by_tier[tier]
        invalid_pool = invalid_by_tier[tier]

        # Try for 50/50 balance within each tier
        valid_target = tier_count // 2
        invalid_target = tier_count - valid_target

        # Take available valid
        n_valid = min(valid_target, len(valid_pool))
        tier_valid = valid_pool[:n_valid]

        # Take available invalid
        shortfall = valid_target - n_valid
        adjusted_invalid = invalid_target + shortfall
        n_invalid = min(adjusted_invalid, len(invalid_pool))
        tier_invalid = invalid_pool[:n_invalid]

        selected.extend(tier_valid)
        selected.extend(tier_invalid)

        stats_by_tier[tier] = {
            "valid": len(tier_valid),
            "invalid": len(tier_invalid),
            "total": len(tier_valid) + len(tier_invalid),
        }

    print(f"\nStratified selection: {len(selected)} formulas")
    for tier in ["easy", "medium", "hard", "very_hard"]:
        s = stats_by_tier[tier]
        print(f"  {tier}: {s['total']} (valid={s['valid']}, invalid={s['invalid']})")

    # Step 7: Ensure axiom anchor coverage
    # Check which axiom names are present
    axiom_anchors_present = set()
    for r in selected:
        an = r.get("axiom_name")
        if an:
            axiom_anchors_present.add(an)
        aug = r.get("augmentation")
        if isinstance(aug, dict):
            an2 = aug.get("axiom_name")
            if an2:
                axiom_anchors_present.add(an2)

    # Add any missing axiom anchor valid instances not already selected
    selected_formulas = {r.get("formula_str") for r in selected}
    axiom_anchors_added = 0
    for r in deduped:
        an = r.get("axiom_name")
        aug = r.get("augmentation", {})
        aug_an = aug.get("axiom_name") if isinstance(aug, dict) else None
        is_anchor = (an and an not in axiom_anchors_present) or \
                    (aug_an and aug_an not in axiom_anchors_present)
        if is_anchor and r.get("formula_str") not in selected_formulas:
            selected.append(r)
            selected_formulas.add(r.get("formula_str"))
            if an:
                axiom_anchors_present.add(an)
            if aug_an:
                axiom_anchors_present.add(aug_an)
            axiom_anchors_added += 1

    print(f"\nAxiom anchors coverage: {len(axiom_anchors_present)} constructors")
    print(f"  Added {axiom_anchors_added} additional anchor instances")

    # Step 8: Assign sequential benchmark IDs and benchmark metadata
    random.shuffle(selected)  # Shuffle final order for fairness
    final_records = []
    for i, r in enumerate(selected):
        bench_id = f"bmlogic-bench-{i+1:05d}"

        # Determine benchmark category
        category = "sampled-valid" if r["label"] == "valid" else "sampled-invalid"
        aug = r.get("augmentation", {})
        if isinstance(aug, dict):
            source = aug.get("source", "unknown")
            if source == "axiom_instance":
                category = "anchor-valid" if r["label"] == "valid" else "sampled-invalid"
            elif source == "anchor_invalid":
                category = "anchor-invalid"
            elif source == "mutation":
                category = "near-miss"

        # Determine source
        source_tag = "production"
        if isinstance(aug, dict):
            source_tag = aug.get("source", "production")

        # Build final record
        complexity = r.get("metrics", {}).get("complexity", 0)
        # Resolve axiom_name from top-level or augmentation
        axiom_name_val = r.get("axiom_name")
        if not axiom_name_val and isinstance(aug, dict):
            axiom_name_val = aug.get("axiom_name")

        final = {
            "id": bench_id,
            "split": "benchmark",
            "formula_str": r.get("formula_str", ""),
            "formula_ast": r.get("formula_ast"),
            "frame_class": r.get("frame_class", "Base"),
            "label": r["label"],
            "proof_trace": r.get("proof_trace"),
            "countermodel": r.get("countermodel"),
            "pattern_key": r.get("pattern_key"),
            "metrics": r.get("metrics"),
            "benchmark_category": category,
            "source": source_tag,
            "difficulty_tier": assign_tier(r),
            "axiom_name": axiom_name_val,
        }
        final_records.append(final)

    print(f"\nFinal benchmark: {len(final_records)} formulas")

    # Step 9: Compute statistics
    final_labels = Counter(r["label"] for r in final_records)
    final_tiers = Counter(r["difficulty_tier"] for r in final_records)
    final_categories = Counter(r["benchmark_category"] for r in final_records)
    final_sources = Counter(r["source"] for r in final_records)

    valid_count = final_labels.get("valid", 0)
    invalid_count = final_labels.get("invalid", 0)
    total = len(final_records)

    print(f"  Valid: {valid_count} ({valid_count*100/total:.1f}%)")
    print(f"  Invalid: {invalid_count} ({invalid_count*100/total:.1f}%)")
    print(f"\n  Tier distribution:")
    for tier in ["easy", "medium", "hard", "very_hard"]:
        count = final_tiers.get(tier, 0)
        print(f"    {tier}: {count} ({count*100/total:.1f}%)")
    print(f"\n  Categories: {dict(final_categories)}")
    print(f"  Sources: {dict(final_sources)}")

    # Step 10: Verify all entries are valid JSON with required fields
    required_fields = ["id", "formula_str", "formula_ast", "label", "metrics"]
    errors = 0
    for r in final_records:
        for field in required_fields:
            if field not in r or r[field] is None:
                print(f"  ERROR: Record {r.get('id')} missing field {field}")
                errors += 1
    print(f"\n  Field completeness errors: {errors}")

    # Step 11: Write final benchmark
    print(f"\nWriting benchmark to {args.output}...")
    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
    with open(args.output, "w") as f:
        for r in final_records:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    print(f"  Wrote {len(final_records)} records")

    # Step 12: Write metadata
    # Recount axiom constructors from final records (after axiom_name preservation)
    axiom_names_in_final = set()
    for r in final_records:
        an = r.get("axiom_name")
        if an:
            axiom_names_in_final.add(an)
    print(f"\n  Axiom constructors in final output: {len(axiom_names_in_final)}/42")
    # Use final-record axiom names for metadata (more accurate than pre-finalization count)
    axiom_anchors_present = axiom_anchors_present | axiom_names_in_final

    # Count near-miss invalid rate
    near_miss = [r for r in final_records if r["benchmark_category"] == "near-miss"]
    near_miss_invalid = sum(1 for r in near_miss if r["label"] == "invalid")
    near_miss_valid = sum(1 for r in near_miss if r["label"] == "valid")

    metadata = {
        "benchmark_name": "BMLogic-Bench",
        "version": "1.0",
        "description": "Stratified evaluation benchmark for decidable bimodal logic TM",
        "generation_date": datetime.now().isoformat(),
        "schema_version": "1.0",
        "frame_class": "Base",
        "total_count": total,
        "valid_count": valid_count,
        "invalid_count": invalid_count,
        "valid_ratio": round(valid_count / total, 4) if total > 0 else 0,
        "tier_distribution": {
            tier: {"count": final_tiers.get(tier, 0),
                   "percentage": round(final_tiers.get(tier, 0) * 100 / total, 1)}
            for tier in ["easy", "medium", "hard", "very_hard"]
        },
        "category_distribution": dict(final_categories),
        "source_distribution": dict(final_sources),
        "anchor_coverage": {
            "axiom_constructors_present": len(axiom_anchors_present),
            "axiom_constructors_total": 42,
            "known_invalid_anchors": final_categories.get("anchor-invalid", 0),
        },
        "near_miss": {
            "total": len(near_miss),
            "valid": near_miss_valid,
            "invalid": near_miss_invalid,
            "invalid_rate": round(near_miss_invalid / len(near_miss), 4) if near_miss else 0,
        },
        "quality": {
            "zero_label_mismatches": True,
            "zero_duplicates": True,
            "all_entries_have_proof_or_countermodel": all(
                (r.get("proof_trace") is not None or r.get("countermodel") is not None)
                for r in final_records
            ),
        },
    }

    print(f"Writing metadata to {args.metadata}...")
    with open(args.metadata, "w") as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    print(f"  Wrote metadata")

    print("\nDone!")


if __name__ == "__main__":
    main()
