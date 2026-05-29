#!/usr/bin/env python3
"""
upload.py - Upload BMLogic-Bench to HuggingFace Hub

This script uploads all four BMLogic-Bench dataset configurations to the
HuggingFace Datasets Hub under a specified repository. The four configs are:
  - default (bmlogic-bench): 727-record evaluation benchmark (test split)
  - bmlogic-c5:              1,513-record training set, complexity <= 5
  - bmlogic-c7:              49,904-record training set, complexity <= 7
  - proof-steps:             2,424-record proof step supervision dataset

Usage:
    # Dry run (loads datasets and prints schemas, no push):
    python upload.py --dry-run

    # Upload to default repo:
    python upload.py --token YOUR_HF_TOKEN

    # Upload to a custom repo:
    python upload.py --repo your-org/your-repo --token YOUR_HF_TOKEN

    # Show all options:
    python upload.py --help

Prerequisites:
    pip install -r requirements.txt

    You must have:
    - A HuggingFace account with write access to the target repository
    - The 'logos-labs' organization created (or use --repo to override)
    - An API token from https://huggingface.co/settings/tokens

Notes:
    - The --dry-run mode loads all datasets locally and prints record counts
      and schema info without pushing anything to HuggingFace.
    - bmlogic-c7.jsonl is ~52 MB. Upload may take several minutes.
    - After upload, HuggingFace will auto-convert JSONL to Parquet format.
    - The README.md in this directory serves as the dataset card.
"""

import argparse
import json
import os
import sys
from pathlib import Path


def get_script_dir() -> Path:
    """Return the directory containing this script."""
    return Path(__file__).parent.resolve()


DATASET_CONFIGS = [
    {
        "config_name": "default",
        "file": "data/bmlogic-bench.jsonl",
        "split": "test",
        "expected_records": 727,
        "description": "Evaluation benchmark (stratified, 727 records)",
    },
    {
        "config_name": "bmlogic-c5",
        "file": "data/bmlogic-c5.jsonl",
        "split": "train",
        "expected_records": 1513,
        "description": "Training set, complexity <= 5 (1,513 records)",
    },
    {
        "config_name": "bmlogic-c7",
        "file": "data/bmlogic-c7.jsonl",
        "split": "train",
        "expected_records": 49904,
        "description": "Training set, complexity <= 7 (49,904 records)",
    },
    {
        "config_name": "proof-steps",
        "file": "data/proof_steps.jsonl",
        "split": "train",
        "expected_records": 2424,
        "description": "Proof step supervision (2,424 records, 36 theorems)",
    },
]


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Upload BMLogic-Bench to HuggingFace Hub",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--repo",
        default="logos-labs/bmlogic-bench",
        help="HuggingFace repository ID (default: logos-labs/bmlogic-bench)",
    )
    parser.add_argument(
        "--token",
        default=None,
        help="HuggingFace API token (or set HF_TOKEN env var)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Load datasets and print schemas/counts without pushing",
    )
    parser.add_argument(
        "--config",
        default=None,
        choices=[c["config_name"] for c in DATASET_CONFIGS],
        help="Upload only a specific config (default: upload all)",
    )
    parser.add_argument(
        "--max-shard-size",
        default="100MB",
        help="Maximum shard size for upload (default: 100MB)",
    )
    return parser.parse_args()


def load_config(config: dict, base_dir: Path) -> "datasets.Dataset":
    """
    Load a single dataset config from JSONL.

    Args:
        config: Config dict with 'file', 'split', 'config_name' keys.
        base_dir: Directory containing the hf-dataset/ structure.

    Returns:
        datasets.Dataset instance.

    Raises:
        FileNotFoundError: If the JSONL file does not exist.
        ValueError: If the dataset fails to load or has unexpected structure.
    """
    import datasets as hf_datasets

    jsonl_path = base_dir / config["file"]
    if not jsonl_path.exists():
        raise FileNotFoundError(
            f"JSONL file not found: {jsonl_path}\n"
            f"Run this script from the hf-dataset/ directory or from the project root."
        )

    print(f"  Loading {config['config_name']}: {jsonl_path.name} ... ", end="", flush=True)
    ds = hf_datasets.load_dataset(
        "json",
        data_files=str(jsonl_path),
        split="train",  # load_dataset always uses 'train' for single files
    )
    actual = len(ds)
    expected = config["expected_records"]
    status = "OK" if actual == expected else f"WARNING: expected {expected}, got {actual}"
    print(f"{actual} records [{status}]")
    return ds


def print_schema(ds: "datasets.Dataset", config_name: str) -> None:
    """Print dataset schema information."""
    print(f"\n  Schema for '{config_name}':")
    for field, dtype in ds.features.items():
        print(f"    {field}: {dtype}")


def push_config(
    ds: "datasets.Dataset",
    config: dict,
    repo_id: str,
    token: str,
    max_shard_size: str,
) -> None:
    """
    Push a single dataset config to HuggingFace Hub.

    Args:
        ds: The loaded dataset.
        config: Config dict with 'config_name' and 'split' keys.
        repo_id: HuggingFace repository ID (e.g., 'logos-labs/bmlogic-bench').
        token: HuggingFace API token.
        max_shard_size: Maximum shard size string (e.g., '100MB').
    """
    print(
        f"  Pushing '{config['config_name']}' (split={config['split']}) to {repo_id} ... ",
        end="",
        flush=True,
    )
    ds.push_to_hub(
        repo_id=repo_id,
        config_name=config["config_name"],
        split=config["split"],
        token=token,
        max_shard_size=max_shard_size,
    )
    print("done.")


def upload_readme(base_dir: Path, repo_id: str, token: str) -> None:
    """Upload the dataset card README.md to HuggingFace Hub."""
    from huggingface_hub import HfApi

    readme_path = base_dir / "README.md"
    if not readme_path.exists():
        print("  WARNING: README.md not found; skipping dataset card upload.")
        return

    print(f"  Uploading README.md (dataset card) to {repo_id} ... ", end="", flush=True)
    api = HfApi(token=token)
    api.upload_file(
        path_or_fileobj=str(readme_path),
        path_in_repo="README.md",
        repo_id=repo_id,
        repo_type="dataset",
    )
    print("done.")


def main() -> int:
    """
    Main entry point.

    Returns:
        Exit code (0 for success, non-zero for failure).
    """
    args = parse_args()
    base_dir = get_script_dir()

    # Resolve token from args or environment
    token = args.token or os.environ.get("HF_TOKEN")
    if not args.dry_run and token is None:
        print(
            "ERROR: HuggingFace API token required for upload.\n"
            "Provide --token TOKEN or set the HF_TOKEN environment variable.\n"
            "To get a token: https://huggingface.co/settings/tokens",
            file=sys.stderr,
        )
        return 1

    # Filter configs if --config specified
    configs = DATASET_CONFIGS
    if args.config:
        configs = [c for c in DATASET_CONFIGS if c["config_name"] == args.config]

    if args.dry_run:
        print("=" * 60)
        print("BMLogic-Bench Upload Script — DRY RUN MODE")
        print("(No data will be pushed to HuggingFace Hub)")
        print("=" * 60)
    else:
        print("=" * 60)
        print(f"BMLogic-Bench Upload Script")
        print(f"Target repository: {args.repo}")
        print("=" * 60)

    try:
        import datasets as hf_datasets  # noqa: F401
    except ImportError:
        print(
            "ERROR: 'datasets' package not found.\n"
            "Run: pip install -r requirements.txt",
            file=sys.stderr,
        )
        return 1

    errors = []
    for config in configs:
        print(f"\n[{config['config_name']}] {config['description']}")
        try:
            ds = load_config(config, base_dir)
            if args.dry_run:
                print_schema(ds, config["config_name"])
            else:
                push_config(ds, config, args.repo, token, args.max_shard_size)
        except FileNotFoundError as e:
            print(f"  ERROR: {e}", file=sys.stderr)
            errors.append(config["config_name"])
        except Exception as e:
            print(f"  ERROR pushing '{config['config_name']}': {e}", file=sys.stderr)
            errors.append(config["config_name"])

    if not args.dry_run and not errors:
        print("\n[dataset card]")
        try:
            upload_readme(base_dir, args.repo, token)
        except Exception as e:
            print(f"  ERROR uploading README: {e}", file=sys.stderr)
            errors.append("README.md")

    print()
    if errors:
        print(f"FAILED configs: {', '.join(errors)}")
        return 1
    elif args.dry_run:
        print("Dry run complete. All configs loaded successfully.")
        print(f"To upload, run: python upload.py --token YOUR_HF_TOKEN")
    else:
        print(f"All configs uploaded to: https://huggingface.co/datasets/{args.repo}")
        print("After upload, HuggingFace will auto-convert JSONL to Parquet.")
        print("View dataset card at: https://huggingface.co/datasets/{args.repo}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
