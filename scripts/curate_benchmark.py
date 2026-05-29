#!/usr/bin/env python3
"""
BMLogic-Bench Curation Pipeline

Loads production dataset JSONL files, loads axiom instances, generates near-miss
mutations, constructs valid and invalid pools, and performs stratified sampling
to produce a benchmark candidate file for oracle validation.

Usage:
    python scripts/curate_benchmark.py [--output PATH] [--target-size N]

Inputs:
    data/bmlogic-medium.jsonl   - Production medium-complexity dataset
    data/bmlogic-deep.jsonl     - Production deep-complexity dataset
    data/axiom-instances.jsonl  - Generated axiom instances from Phase 1

Output:
    data/bmlogic-bench-candidates.jsonl - Candidate benchmark for oracle validation
"""

import json
import sys
import os
import hashlib
import random
import copy
from collections import Counter, defaultdict
from typing import Optional

# Seed for reproducibility
RANDOM_SEED = 42205
random.seed(RANDOM_SEED)

# ============================================================================
# Configuration
# ============================================================================

# Target benchmark parameters
TARGET_SIZE = 750  # Target total formulas
TIER_TARGETS = {
    "easy": 0.15,       # 15% (adjusted from 20% due to valid scarcity)
    "medium": 0.40,     # 40%
    "hard": 0.35,       # 35% (adjusted from 30%)
    "very_hard": 0.10,  # 10%
}
VALID_RATIO_TARGET = 0.50  # 50/50 valid/invalid

# Difficulty tier boundaries (must match DatasetGenerator.lean)
def classify_tier(complexity: int) -> str:
    if complexity <= 3:
        return "easy"
    elif complexity <= 6:
        return "medium"
    elif complexity <= 9:
        return "hard"
    else:
        return "very_hard"


# ============================================================================
# Pool Loading
# ============================================================================

def load_jsonl(path: str) -> list[dict]:
    """Load a JSONL file, returning list of parsed records."""
    records = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line:
                records.append(json.loads(line))
    return records


def load_pools(
    medium_path: str = "data/bmlogic-medium.jsonl",
    deep_path: str = "data/bmlogic-deep.jsonl",
    axiom_path: str = "data/axiom-instances.jsonl",
) -> tuple[list[dict], list[dict], list[dict]]:
    """Load all data pools: medium, deep, and axiom instances."""
    medium = load_jsonl(medium_path) if os.path.exists(medium_path) else []
    deep = load_jsonl(deep_path) if os.path.exists(deep_path) else []
    axioms = load_jsonl(axiom_path) if os.path.exists(axiom_path) else []
    return medium, deep, axioms


def deduplicate_by_formula(records: list[dict]) -> list[dict]:
    """Deduplicate records by formula_str, keeping first occurrence."""
    seen = set()
    result = []
    for r in records:
        key = r.get("formula_str", "")
        if key not in seen:
            seen.add(key)
            result.append(r)
    return result


def filter_timeouts(records: list[dict]) -> list[dict]:
    """Remove records with timeout label."""
    return [r for r in records if r.get("label") != "timeout"]


def separate_pools(records: list[dict]) -> tuple[list[dict], list[dict]]:
    """Separate records into valid and invalid pools."""
    valid = [r for r in records if r.get("label") == "valid"]
    invalid = [r for r in records if r.get("label") == "invalid"]
    return valid, invalid


# ============================================================================
# Near-Miss Mutation Engine
# ============================================================================

# AST tag constants
BINARY_OPS = {"imp", "untl", "snce"}
UNARY_OPS = {"box"}
LEAF_TAGS = {"atom", "bot"}

# Operator swap pairs
OP_SWAPS = {
    "untl": "snce",
    "snce": "untl",
    "imp": "untl",
}


def ast_copy(ast: dict) -> dict:
    """Deep copy an AST."""
    return copy.deepcopy(ast)


def ast_to_str(ast: dict) -> str:
    """Convert AST to a canonical string for dedup."""
    return json.dumps(ast, sort_keys=True)


def swap_args(ast: dict) -> Optional[dict]:
    """Swap children of the top-level binary operator."""
    tag = ast.get("tag")
    if tag == "imp":
        new = ast_copy(ast)
        new["left"], new["right"] = new["right"], new["left"]
        return new
    elif tag == "untl" or tag == "snce":
        new = ast_copy(ast)
        new["event"], new["guard"] = new["guard"], new["event"]
        return new
    return None


def swap_op(ast: dict) -> Optional[dict]:
    """Replace top-level operator with a related one."""
    tag = ast.get("tag")
    if tag in OP_SWAPS:
        new = ast_copy(ast)
        new_tag = OP_SWAPS[tag]
        new["tag"] = new_tag
        # Adjust field names if switching between imp and temporal
        if tag == "imp" and new_tag in ("untl", "snce"):
            left, right = new.pop("left"), new.pop("right")
            new["event"] = left
            new["guard"] = right
        elif tag in ("untl", "snce") and new_tag == "imp":
            event, guard = new.pop("event"), new.pop("guard")
            new["left"] = event
            new["right"] = guard
        elif tag in ("untl", "snce") and new_tag in ("untl", "snce"):
            pass  # same field names
        return new
    return None


def negate(ast: dict) -> Optional[dict]:
    """Negate the formula: wrap in imp(_, bot)."""
    return {"tag": "imp", "left": ast_copy(ast), "right": {"tag": "bot"}}


def drop_box(ast: dict) -> Optional[dict]:
    """Remove top-level box operator."""
    if ast.get("tag") == "box":
        return ast_copy(ast["child"])
    return None


def add_box(ast: dict) -> Optional[dict]:
    """Add a box operator on top."""
    return {"tag": "box", "child": ast_copy(ast)}


def atom_swap(ast: dict) -> Optional[dict]:
    """Replace one atom with another in the formula."""
    # Find all atoms in the AST
    atoms = set()
    _collect_atoms(ast, atoms)
    if len(atoms) < 1:
        return None
    # Pick the first atom and swap it to a different one
    target = sorted(atoms)[0]
    replacement = "q" if target != "q" else "p"
    new = ast_copy(ast)
    _replace_atom(new, target, replacement)
    return new


def _collect_atoms(ast: dict, atoms: set):
    """Recursively collect atom names."""
    tag = ast.get("tag")
    if tag == "atom":
        atoms.add(ast.get("name", ""))
    elif tag == "imp":
        _collect_atoms(ast["left"], atoms)
        _collect_atoms(ast["right"], atoms)
    elif tag == "box":
        _collect_atoms(ast["child"], atoms)
    elif tag in ("untl", "snce"):
        _collect_atoms(ast["event"], atoms)
        _collect_atoms(ast["guard"], atoms)


def _replace_atom(ast: dict, old_name: str, new_name: str):
    """Recursively replace atoms with given name."""
    tag = ast.get("tag")
    if tag == "atom" and ast.get("name") == old_name:
        ast["name"] = new_name
    elif tag == "imp":
        _replace_atom(ast["left"], old_name, new_name)
        _replace_atom(ast["right"], old_name, new_name)
    elif tag == "box":
        _replace_atom(ast["child"], old_name, new_name)
    elif tag in ("untl", "snce"):
        _replace_atom(ast["event"], old_name, new_name)
        _replace_atom(ast["guard"], old_name, new_name)


def bot_inject(ast: dict) -> Optional[dict]:
    """Replace a leaf subformula with bot."""
    tag = ast.get("tag")
    if tag == "imp":
        # Replace right child with bot
        new = ast_copy(ast)
        new["right"] = {"tag": "bot"}
        return new
    elif tag in ("untl", "snce"):
        new = ast_copy(ast)
        new["guard"] = {"tag": "bot"}
        return new
    elif tag == "box":
        new = ast_copy(ast)
        new["child"] = {"tag": "bot"}
        return new
    return None


def weaken_guard(ast: dict) -> Optional[dict]:
    """Change temporal guard to bot."""
    tag = ast.get("tag")
    if tag in ("untl", "snce"):
        new = ast_copy(ast)
        new["guard"] = {"tag": "bot"}
        return new
    return None


# All mutation operators
MUTATIONS = [
    ("swap_args", swap_args),
    ("swap_op", swap_op),
    ("negate", negate),
    ("drop_box", drop_box),
    ("add_box", add_box),
    ("atom_swap", atom_swap),
    ("bot_inject", bot_inject),
    ("weaken_guard", weaken_guard),
]


def compute_complexity(ast: dict) -> int:
    """Compute formula complexity from AST (mirrors Lean Formula.complexity)."""
    tag = ast.get("tag")
    if tag in ("atom", "bot"):
        return 1
    elif tag == "imp":
        return 1 + compute_complexity(ast["left"]) + compute_complexity(ast["right"])
    elif tag == "box":
        return 1 + compute_complexity(ast["child"])
    elif tag in ("untl", "snce"):
        return 1 + compute_complexity(ast["event"]) + compute_complexity(ast["guard"])
    return 1


def ast_to_formula_str(ast: dict) -> str:
    """Convert AST to human-readable formula string (mirrors Lean prettyPrint)."""
    tag = ast.get("tag")
    if tag == "atom":
        return ast.get("name", "?")
    elif tag == "bot":
        return "⊥"  # ⊥
    elif tag == "imp":
        left = ast_to_formula_str(ast["left"])
        right = ast_to_formula_str(ast["right"])
        return f"({left} → {right})"
    elif tag == "box":
        child = ast_to_formula_str(ast["child"])
        return f"□{child}"
    elif tag == "untl":
        event = ast_to_formula_str(ast["event"])
        guard = ast_to_formula_str(ast["guard"])
        return f"U({event}, {guard})"
    elif tag == "snce":
        event = ast_to_formula_str(ast["event"])
        guard = ast_to_formula_str(ast["guard"])
        return f"S({event}, {guard})"
    return "?"


def generate_mutations(
    valid_records: list[dict],
    max_per_formula: int = 8,
) -> list[dict]:
    """
    Generate near-miss mutations from valid formulas.

    For each valid formula, apply all mutation operators. Collect candidate
    near-miss formulas, deduplicate, and return as unlabeled records.
    """
    mutations = []
    seen_asts = set()

    # Skip ex_falso formulas (trivially valid, mutations not interesting)
    interesting = []
    for r in valid_records:
        proof_trace = r.get("proof_trace")
        if proof_trace:
            axioms = proof_trace.get("axioms_used", [])
            if axioms == ["ex_falso"]:
                continue
        interesting.append(r)

    for r in interesting:
        ast = r.get("formula_ast")
        if not ast:
            continue
        source_str = r.get("formula_str", "")
        count = 0
        for mut_name, mut_fn in MUTATIONS:
            if count >= max_per_formula:
                break
            mutated = mut_fn(ast)
            if mutated is None:
                continue
            key = ast_to_str(mutated)
            if key in seen_asts:
                continue
            seen_asts.add(key)

            complexity = compute_complexity(mutated)
            formula_str = ast_to_formula_str(mutated)

            mutation_record = {
                "id": f"mutation-{len(mutations)+1:05d}",
                "split": "benchmark",
                "formula_str": formula_str,
                "formula_ast": mutated,
                "frame_class": "Base",
                "label": "unlabeled",
                "proof_trace": None,
                "countermodel": None,
                "pattern_key": None,  # Will be filled by oracle
                "metrics": {
                    "complexity": complexity,
                    "modalDepth": 0,  # Approximate
                    "temporalDepth": 0,
                    "impCount": 0,
                    "atomCount": 0,
                    "decisionTimeMs": 0,
                    "difficultyTier": classify_tier(complexity),
                },
                "augmentation": {
                    "source": "mutation",
                    "mutation_type": mut_name,
                    "original_formula_str": source_str,
                },
            }
            mutations.append(mutation_record)
            count += 1

    return mutations


# ============================================================================
# Known Invalid Anchors
# ============================================================================

def get_known_invalid_anchors() -> list[dict]:
    """
    Return the 20 known invalid formulas from DatasetValidator.lean
    as benchmark records.
    """
    p = {"tag": "atom", "name": "p"}
    q = {"tag": "atom", "name": "q"}
    r = {"tag": "atom", "name": "r"}
    bot = {"tag": "bot"}

    def imp(a, b): return {"tag": "imp", "left": a, "right": b}
    def box(a): return {"tag": "box", "child": a}
    def neg(a): return imp(a, bot)
    def diamond(a): return neg(box(neg(a)))
    top = imp(bot, bot)
    def untl(ev, gd): return {"tag": "untl", "event": ev, "guard": gd}
    def snce(ev, gd): return {"tag": "snce", "event": ev, "guard": gd}
    def some_future(a): return untl(a, top)
    def some_past(a): return snce(a, top)
    def and_(a, b): return neg(imp(a, neg(b)))

    formulas = [
        p,                          # bare atom
        q,                          # another bare atom
        imp(p, q),                  # p -> q
        box(p),                     # Box p
        diamond(p),                 # Diamond p
        some_future(p),             # F(p)
        some_past(p),               # P(p)
        and_(p, neg(p)),            # p AND NOT p
        imp(box(p), box(q)),        # Box p -> Box q
        and_(box(p), box(neg(p))),  # Box p AND Box NOT p
        untl(p, q),                 # U(p, q)
        snce(p, q),                 # S(p, q)
        bot,                        # bottom
        imp(q, p),                  # q -> p
        imp(r, imp(p, q)),          # r -> (p -> q)
        imp(box(p), q),             # Box p -> q
        box(q),                     # Box q
        imp(p, imp(q, r)),          # p -> (q -> r)
        imp(imp(p, q), p),          # (p -> q) -> p
        box(bot),                   # Box bottom
    ]

    anchors = []
    for i, ast in enumerate(formulas):
        complexity = compute_complexity(ast)
        formula_str = ast_to_formula_str(ast)
        anchors.append({
            "id": f"invalid-anchor-{i+1:03d}",
            "split": "benchmark",
            "formula_str": formula_str,
            "formula_ast": ast,
            "frame_class": "Base",
            "label": "invalid",
            "proof_trace": None,
            "countermodel": None,
            "pattern_key": None,
            "metrics": {
                "complexity": complexity,
                "modalDepth": 0,
                "temporalDepth": 0,
                "impCount": 0,
                "atomCount": 0,
                "decisionTimeMs": 0,
                "difficultyTier": classify_tier(complexity),
            },
            "augmentation": {
                "source": "anchor_invalid",
                "original_formula_str": None,
            },
            "benchmark_category": "anchor-invalid",
        })

    return anchors


# ============================================================================
# Stratified Sampling
# ============================================================================

def assign_tier(record: dict) -> str:
    """Assign difficulty tier to a record."""
    metrics = record.get("metrics", {})
    tier = metrics.get("difficultyTier")
    if tier and tier in TIER_TARGETS:
        return tier
    # Fallback: compute from complexity
    complexity = metrics.get("complexity", 5)
    return classify_tier(complexity)


def stratified_sample(
    valid_pool: list[dict],
    invalid_pool: list[dict],
    target_size: int = TARGET_SIZE,
    tier_targets: dict = TIER_TARGETS,
    valid_ratio: float = VALID_RATIO_TARGET,
) -> list[dict]:
    """
    Perform stratified sampling to hit target size and distribution.

    For each tier, sample approximately the target proportion of valid and
    invalid formulas. When a tier has insufficient valid formulas, backfill
    from the invalid pool.
    """
    # Group pools by tier
    valid_by_tier = defaultdict(list)
    invalid_by_tier = defaultdict(list)

    for r in valid_pool:
        tier = assign_tier(r)
        valid_by_tier[tier].append(r)
    for r in invalid_pool:
        tier = assign_tier(r)
        invalid_by_tier[tier].append(r)

    # Shuffle within each tier for random sampling
    for tier in tier_targets:
        random.shuffle(valid_by_tier[tier])
        random.shuffle(invalid_by_tier[tier])

    selected = []

    for tier, proportion in tier_targets.items():
        tier_count = int(target_size * proportion)
        valid_target = int(tier_count * valid_ratio)
        invalid_target = tier_count - valid_target

        # Sample valid
        available_valid = valid_by_tier[tier]
        n_valid = min(valid_target, len(available_valid))
        selected.extend(available_valid[:n_valid])

        # If not enough valid, add more invalid to compensate
        shortfall = valid_target - n_valid
        adjusted_invalid_target = invalid_target + shortfall

        # Sample invalid
        available_invalid = invalid_by_tier[tier]
        n_invalid = min(adjusted_invalid_target, len(available_invalid))
        selected.extend(available_invalid[:n_invalid])

    return selected


# ============================================================================
# Main Pipeline
# ============================================================================

def main():
    import argparse
    parser = argparse.ArgumentParser(description="BMLogic-Bench Curation Pipeline")
    parser.add_argument("--output", default="data/bmlogic-bench-candidates.jsonl",
                        help="Output path for candidate benchmark")
    parser.add_argument("--target-size", type=int, default=TARGET_SIZE,
                        help="Target benchmark size")
    parser.add_argument("--medium", default="data/bmlogic-medium.jsonl",
                        help="Path to medium production dataset")
    parser.add_argument("--deep", default="data/bmlogic-deep.jsonl",
                        help="Path to deep production dataset")
    parser.add_argument("--axioms", default="data/axiom-instances.jsonl",
                        help="Path to axiom instances")
    args = parser.parse_args()

    print("BMLogic-Bench Curation Pipeline")
    print("=" * 40)
    print()

    # Step 1: Load pools
    print("Step 1: Loading data pools...")
    medium, deep, axioms = load_pools(args.medium, args.deep, args.axioms)
    print(f"  Medium: {len(medium)} records")
    print(f"  Deep:   {len(deep)} records")
    print(f"  Axioms: {len(axioms)} records")

    # Step 2: Filter and deduplicate
    print("\nStep 2: Filtering and deduplicating...")
    all_production = medium + deep
    all_production = filter_timeouts(all_production)
    all_production = deduplicate_by_formula(all_production)
    print(f"  Production (non-timeout, deduped): {len(all_production)}")

    axioms_filtered = filter_timeouts(axioms)
    print(f"  Axioms (non-timeout): {len(axioms_filtered)}")

    # Step 3: Separate valid and invalid
    prod_valid, prod_invalid = separate_pools(all_production)
    axiom_valid, axiom_invalid = separate_pools(axioms_filtered)
    print(f"  Production valid: {len(prod_valid)}, invalid: {len(prod_invalid)}")
    print(f"  Axiom valid: {len(axiom_valid)}, invalid: {len(axiom_invalid)}")

    # Step 4: Generate near-miss mutations
    print("\nStep 3: Generating near-miss mutations...")
    # Use both production valid and axiom valid as sources
    all_valid_for_mutation = prod_valid + axiom_valid
    mutations = generate_mutations(all_valid_for_mutation, max_per_formula=8)
    print(f"  Generated {len(mutations)} mutation candidates")

    # Step 5: Build merged pools
    print("\nStep 4: Building merged pools...")

    # Mark sources
    for r in prod_valid:
        r["benchmark_category"] = "sampled-valid"
        r.setdefault("augmentation", {})
        if r["augmentation"] is None:
            r["augmentation"] = {}
        r["augmentation"]["source"] = "production"
    for r in prod_invalid:
        r["benchmark_category"] = "sampled-invalid"
        r.setdefault("augmentation", {})
        if r["augmentation"] is None:
            r["augmentation"] = {}
        r["augmentation"]["source"] = "production"
    for r in axiom_valid:
        r["benchmark_category"] = "anchor-valid"
    for r in axiom_invalid:
        r["benchmark_category"] = "sampled-invalid"

    # Known invalid anchors
    invalid_anchors = get_known_invalid_anchors()
    for r in invalid_anchors:
        r["benchmark_category"] = "anchor-invalid"
    print(f"  Known invalid anchors: {len(invalid_anchors)}")

    # Merge valid pool: production + axiom instances
    merged_valid = deduplicate_by_formula(prod_valid + axiom_valid)
    # Merge invalid pool: production + axiom invalid + invalid anchors + mutations (labeled unlabeled)
    merged_invalid = deduplicate_by_formula(prod_invalid + axiom_invalid + invalid_anchors)
    print(f"  Merged valid pool: {len(merged_valid)}")
    print(f"  Merged invalid pool: {len(merged_invalid)}")

    # Step 6: Stratified sampling
    print("\nStep 5: Stratified sampling...")
    selected = stratified_sample(
        merged_valid, merged_invalid,
        target_size=args.target_size,
    )
    print(f"  Selected {len(selected)} formulas")

    # Step 7: Add mandatory anchors that might have been missed
    # Ensure all axiom valid instances are included
    selected_formulas = {r.get("formula_str") for r in selected}
    anchors_added = 0
    for r in axiom_valid:
        if r.get("formula_str") not in selected_formulas:
            selected.append(r)
            selected_formulas.add(r.get("formula_str"))
            anchors_added += 1
    # Ensure all known invalid anchors are included
    for r in invalid_anchors:
        if r.get("formula_str") not in selected_formulas:
            selected.append(r)
            selected_formulas.add(r.get("formula_str"))
            anchors_added += 1
    print(f"  Added {anchors_added} mandatory anchors not already in sample")

    # Step 8: Add mutations (these need oracle labeling)
    # Deduplicate against selected
    mutation_added = 0
    for r in mutations:
        if r.get("formula_str") not in selected_formulas:
            selected.append(r)
            selected_formulas.add(r.get("formula_str"))
            mutation_added += 1
    print(f"  Added {mutation_added} mutation candidates (unlabeled)")

    # Step 9: Final deduplication
    selected = deduplicate_by_formula(selected)
    print(f"\n  Total candidates: {len(selected)}")

    # Step 10: Statistics
    print("\nStep 6: Statistics")
    label_counts = Counter(r.get("label") for r in selected)
    tier_counts = Counter(assign_tier(r) for r in selected)
    category_counts = Counter(r.get("benchmark_category", "unknown") for r in selected)
    source_counts = Counter(
        r.get("augmentation", {}).get("source", "unknown") if r.get("augmentation") else "unknown"
        for r in selected
    )

    print(f"  Labels: {dict(label_counts)}")
    print(f"  Tiers: {dict(tier_counts)}")
    print(f"  Categories: {dict(category_counts)}")
    print(f"  Sources: {dict(source_counts)}")

    # Axiom coverage
    axiom_names_present = set()
    for r in selected:
        an = r.get("axiom_name")
        if an:
            axiom_names_present.add(an)
        aug = r.get("augmentation")
        if aug and isinstance(aug, dict):
            an2 = aug.get("axiom_name")
            if an2:
                axiom_names_present.add(an2)
    print(f"  Axiom constructor coverage: {len(axiom_names_present)}/42")

    # Step 11: Write output
    print(f"\nStep 7: Writing candidates to {args.output}...")
    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
    with open(args.output, "w") as f:
        for r in selected:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    print(f"  Wrote {len(selected)} records")
    print("\nDone!")


if __name__ == "__main__":
    main()
