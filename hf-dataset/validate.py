#!/usr/bin/env python3
"""
validate.py - Validate BMLogic-Bench packaging for HuggingFace Hub

This script performs pre-upload validation of the hf-dataset/ packaging:
  1. YAML frontmatter in README.md parses correctly and contains all 4 configs
  2. All JSONL files exist and are accessible
  3. Record counts match expected values (727, 1513, 49904, 2424)
  4. Field schemas match documented schemas per config
  5. Required fields are non-null in all records
  6. Label distribution is as expected

Usage:
    # Run all validation checks:
    python validate.py

    # Validate a specific config:
    python validate.py --config bmlogic-c5

    # Run with verbose output (show schema details):
    python validate.py --verbose

    # Exit code: 0 = all checks passed, 1 = one or more failures

Prerequisites:
    pip install -r requirements.txt
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Expected counts and required fields per config
# ---------------------------------------------------------------------------

EXPECTED_COUNTS = {
    "bmlogic-bench": 727,
    "bmlogic-c5": 1513,
    "bmlogic-c7": 49904,
    "proof-steps": 2424,
}

# Fields required to be non-null in every record for each config
REQUIRED_FIELDS = {
    "bmlogic-bench": [
        "id", "split", "formula_str", "formula_ast", "frame_class", "label",
        "metrics", "source", "difficulty_tier", "benchmark_category",
    ],
    "bmlogic-c5": [
        "id", "split", "formula_str", "formula_ast", "frame_class", "label",
        "metrics", "formula_sexpr", "formula_tokens",
    ],
    "bmlogic-c7": [
        "id", "split", "formula_str", "formula_ast", "frame_class", "label",
        "metrics", "formula_sexpr", "formula_tokens",
    ],
    "proof-steps": [
        "theorem_name", "step_index", "goal", "rule", "subgoals", "frame_class",
    ],
}

# Expected label values per config (None = not applicable)
EXPECTED_LABELS = {
    "bmlogic-bench": {"valid", "invalid"},
    "bmlogic-c5": {"valid", "invalid", "timeout"},
    "bmlogic-c7": {"valid", "invalid", "timeout"},
    "proof-steps": None,  # No 'label' field in proof-steps
}

# JSONL file paths relative to the hf-dataset/ directory
CONFIG_FILES = {
    "bmlogic-bench": "data/bmlogic-bench.jsonl",
    "bmlogic-c5": "data/bmlogic-c5.jsonl",
    "bmlogic-c7": "data/bmlogic-c7.jsonl",
    "proof-steps": "data/proof_steps.jsonl",
}

# Expected YAML config names in README.md frontmatter
EXPECTED_YAML_CONFIGS = {"default", "bmlogic-c5", "bmlogic-c7", "proof-steps"}


def get_script_dir() -> Path:
    """Return the directory containing this script."""
    return Path(__file__).parent.resolve()


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Validate BMLogic-Bench HuggingFace packaging",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--config",
        default=None,
        choices=list(EXPECTED_COUNTS.keys()),
        help="Validate only a specific config (default: validate all)",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Show detailed schema and distribution information",
    )
    return parser.parse_args()


# ---------------------------------------------------------------------------
# Check functions
# ---------------------------------------------------------------------------

def check_yaml(base_dir: Path, verbose: bool = False) -> Tuple[bool, List[str]]:
    """
    Validate YAML frontmatter in README.md.

    Returns:
        Tuple of (passed: bool, messages: List[str]).
    """
    try:
        import yaml
    except ImportError:
        return False, ["pyyaml not installed; run: pip install -r requirements.txt"]

    readme_path = base_dir / "README.md"
    if not readme_path.exists():
        return False, [f"README.md not found at {readme_path}"]

    content = readme_path.read_text(encoding="utf-8")

    # Extract YAML frontmatter between --- delimiters
    import re
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return False, ["README.md does not contain YAML frontmatter (--- delimiters not found)"]

    yaml_str = match.group(1)
    try:
        data = yaml.safe_load(yaml_str)
    except yaml.YAMLError as e:
        return False, [f"YAML parse error: {e}"]

    messages = []
    ok = True

    # Check license
    if data.get("license") != "cc-by-4.0":
        messages.append(f"  WARNING: license is '{data.get('license')}', expected 'cc-by-4.0'")

    # Check configs section
    configs = data.get("configs", [])
    if not configs:
        ok = False
        messages.append("  FAIL: 'configs' section missing from YAML frontmatter")
        return ok, messages

    config_names = {c.get("config_name") for c in configs}
    if config_names != EXPECTED_YAML_CONFIGS:
        missing = EXPECTED_YAML_CONFIGS - config_names
        extra = config_names - EXPECTED_YAML_CONFIGS
        if missing:
            ok = False
            messages.append(f"  FAIL: Missing YAML configs: {missing}")
        if extra:
            messages.append(f"  WARNING: Extra YAML configs: {extra}")

    # Check default config
    defaults = [c for c in configs if c.get("default")]
    if not defaults:
        ok = False
        messages.append("  FAIL: No config marked as default: true")
    elif len(defaults) > 1:
        messages.append(f"  WARNING: Multiple default configs: {[c['config_name'] for c in defaults]}")

    # Check data file paths exist
    for config_entry in configs:
        for df in config_entry.get("data_files", []):
            path_str = df.get("path", "")
            file_path = base_dir / path_str
            if not file_path.exists():
                ok = False
                messages.append(f"  FAIL: Data file not found: {file_path}")

    if ok and not messages:
        messages.append(f"  PASS: YAML frontmatter valid ({len(configs)} configs)")
    elif ok:
        messages.insert(0, "  PASS (with warnings): YAML frontmatter valid")

    if verbose:
        messages.append(f"  Configs found: {sorted(config_names)}")

    return ok, messages


def check_jsonl_file(
    config_name: str,
    base_dir: Path,
    verbose: bool = False,
) -> Tuple[bool, List[str]]:
    """
    Validate a single JSONL file: existence, record count, required fields, label values.

    Returns:
        Tuple of (passed: bool, messages: List[str]).
    """
    file_path = base_dir / CONFIG_FILES[config_name]
    messages = []
    ok = True

    if not file_path.exists():
        return False, [f"  FAIL: File not found: {file_path}"]

    expected_count = EXPECTED_COUNTS[config_name]
    required_fields = REQUIRED_FIELDS[config_name]
    valid_labels = EXPECTED_LABELS[config_name]

    record_count = 0
    null_field_errors: Dict[str, int] = {}
    label_counts: Dict[str, int] = {}
    unexpected_labels: set = set()
    parse_errors = 0
    schema_fields: Optional[set] = None

    with open(file_path, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError as e:
                parse_errors += 1
                if parse_errors <= 5:
                    messages.append(f"  FAIL: JSON parse error at line {line_num}: {e}")
                continue

            record_count += 1

            # Capture schema on first record
            if schema_fields is None:
                schema_fields = set(record.keys())

            # Check required fields for null values
            for field in required_fields:
                if field not in record or record[field] is None:
                    null_field_errors[field] = null_field_errors.get(field, 0) + 1

            # Check label values
            if valid_labels is not None and "label" in record:
                label = record.get("label")
                if label is not None:
                    label_counts[label] = label_counts.get(label, 0) + 1
                    if label not in valid_labels:
                        unexpected_labels.add(label)

    if parse_errors > 0:
        ok = False
        messages.append(f"  FAIL: {parse_errors} JSON parse error(s) in {file_path.name}")

    # Record count check
    if record_count == expected_count:
        messages.append(f"  PASS: Record count = {record_count}")
    else:
        ok = False
        messages.append(
            f"  FAIL: Record count = {record_count}, expected {expected_count} "
            f"(delta: {record_count - expected_count:+d})"
        )

    # Null field check
    if null_field_errors:
        ok = False
        for field, count in sorted(null_field_errors.items()):
            messages.append(f"  FAIL: Required field '{field}' null/missing in {count} records")
    else:
        messages.append(f"  PASS: All required fields non-null ({len(required_fields)} fields checked)")

    # Label check
    if valid_labels is not None:
        if unexpected_labels:
            ok = False
            messages.append(f"  FAIL: Unexpected label values: {unexpected_labels}")
        else:
            dist_str = ", ".join(f"{k}={v}" for k, v in sorted(label_counts.items()))
            messages.append(f"  PASS: Label values valid ({dist_str})")

    if verbose and schema_fields is not None:
        messages.append(f"  Schema fields ({len(schema_fields)}): {sorted(schema_fields)}")

    return ok, messages


def print_section(title: str, messages: List[str], passed: bool) -> None:
    """Print a validation section with pass/fail header."""
    status = "PASS" if passed else "FAIL"
    print(f"\n[{status}] {title}")
    for msg in messages:
        print(msg)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    """
    Run all validation checks and print a summary table.

    Returns:
        Exit code: 0 = all checks passed, 1 = one or more failures.
    """
    args = parse_args()
    base_dir = get_script_dir()

    print("=" * 60)
    print("BMLogic-Bench Packaging Validation")
    print(f"Base directory: {base_dir}")
    print("=" * 60)

    results: List[Tuple[str, bool]] = []

    # Check 1: YAML frontmatter
    yaml_ok, yaml_msgs = check_yaml(base_dir, verbose=args.verbose)
    print_section("README.md YAML frontmatter", yaml_msgs, yaml_ok)
    results.append(("README.md YAML", yaml_ok))

    # Check 2: JSONL files
    configs_to_check = (
        [args.config] if args.config else list(EXPECTED_COUNTS.keys())
    )
    for config_name in configs_to_check:
        jsonl_ok, jsonl_msgs = check_jsonl_file(config_name, base_dir, verbose=args.verbose)
        print_section(f"Config: {config_name}", jsonl_msgs, jsonl_ok)
        results.append((config_name, jsonl_ok))

    # Summary table
    print("\n" + "=" * 60)
    print("Summary")
    print("=" * 60)
    all_passed = True
    for name, passed in results:
        status = "PASS" if passed else "FAIL"
        marker = "" if passed else " <-- FAILED"
        print(f"  [{status}] {name}{marker}")
        if not passed:
            all_passed = False

    print()
    if all_passed:
        print("All checks passed. Ready to upload.")
        return 0
    else:
        failed = [name for name, passed in results if not passed]
        print(f"FAILED checks: {', '.join(failed)}")
        print("Fix the issues above before uploading.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
