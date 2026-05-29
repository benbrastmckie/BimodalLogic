#!/usr/bin/env python3
"""
Convert BimodalLogic JSON dataset to PyTorch tensors for ML training.

Usage:
    python scripts/generate_dataset.py data/training_dataset.json data/training.pt
    python scripts/generate_dataset.py data/eval_dataset.json data/eval.pt

Reads the structured JSON dataset produced by DatasetExporter.lean and converts
PatternKey features to numpy arrays, encodes decisions as integer labels, and
exports to PyTorch .pt format.

Label encoding:
    valid   = 1
    invalid = 0
    timeout = -1

Feature vector (5 dims from PatternKey):
    [modalDepth, temporalDepth, impCount, complexity, topOperator_encoded]

TopOperator encoding:
    Atom=0, Bottom=1, Implication=2, Box=3, AllPast=4, AllFuture=5, Until=6, Since=7
"""

import json
import sys
import numpy as np

TOP_OP_ENCODING = {
    "Atom": 0,
    "Bottom": 1,
    "Implication": 2,
    "Box": 3,
    "AllPast": 4,
    "AllFuture": 5,
    "Until": 6,
    "Since": 7,
}

LABEL_ENCODING = {
    "valid": 1,
    "invalid": 0,
    "timeout": -1,
}


def load_dataset(path: str) -> dict:
    """Load the structured JSON dataset from file."""
    with open(path, "r") as f:
        return json.load(f)


def extract_features(formula_entry: dict) -> np.ndarray:
    """Extract the 5-dimensional feature vector from a formula entry."""
    features = formula_entry["features"]
    top_op = features.get("topOperator", "Atom")
    # Handle quoted JSON strings
    if isinstance(top_op, str):
        top_op_idx = TOP_OP_ENCODING.get(top_op, 0)
    else:
        top_op_idx = 0
    return np.array(
        [
            features["modalDepth"],
            features["temporalDepth"],
            features["impCount"],
            features["complexity"],
            top_op_idx,
        ],
        dtype=np.float32,
    )


def extract_label(formula_entry: dict) -> int:
    """Encode the decision label as an integer."""
    decision = formula_entry["decision"]
    # Handle quoted JSON strings
    if isinstance(decision, str):
        return LABEL_ENCODING.get(decision, -1)
    return -1


def extract_proof_height(formula_entry: dict) -> float:
    """Extract proof height as regression target (NaN for non-valid)."""
    proof = formula_entry.get("proof")
    if proof is not None and isinstance(proof, dict):
        return float(proof.get("height", 0))
    return float("nan")


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <input.json> <output.pt>")
        print("  Converts BimodalLogic JSON dataset to PyTorch tensors.")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    # Load dataset
    print(f"Loading dataset from {input_path}...")
    dataset = load_dataset(input_path)

    metadata = dataset.get("metadata", {})
    formulas = dataset.get("formulas", [])
    print(f"  Metadata: {json.dumps(metadata, indent=None)}")
    print(f"  Formula count: {len(formulas)}")

    if not formulas:
        print("Error: no formulas in dataset.")
        sys.exit(1)

    # Extract features and labels
    features_list = []
    labels_list = []
    heights_list = []

    for entry in formulas:
        features_list.append(extract_features(entry))
        labels_list.append(extract_label(entry))
        heights_list.append(extract_proof_height(entry))

    features = np.stack(features_list)
    labels = np.array(labels_list, dtype=np.int64)
    heights = np.array(heights_list, dtype=np.float32)

    print(f"  Features shape: {features.shape}")
    print(f"  Labels: valid={np.sum(labels == 1)}, invalid={np.sum(labels == 0)}, "
          f"timeout={np.sum(labels == -1)}")

    valid_heights = heights[~np.isnan(heights)]
    if len(valid_heights) > 0:
        print(f"  Proof heights (valid only): mean={valid_heights.mean():.2f}, "
              f"max={valid_heights.max():.0f}")

    # Export to PyTorch format
    try:
        import torch

        tensor_dict = {
            "features": torch.from_numpy(features),
            "labels": torch.from_numpy(labels),
            "heights": torch.from_numpy(heights),
        }
        torch.save(tensor_dict, output_path)
        print(f"  Saved PyTorch tensors to {output_path}")
    except ImportError:
        # Fallback: save as numpy .npz
        fallback_path = output_path.replace(".pt", ".npz")
        np.savez(
            fallback_path,
            features=features,
            labels=labels,
            heights=heights,
        )
        print(f"  PyTorch not available. Saved numpy arrays to {fallback_path}")

    print("Done.")


if __name__ == "__main__":
    main()
