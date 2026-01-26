#!/usr/bin/env python3
"""
update-todo-artifact.py - Safely add artifact links to TODO.md

Usage:
    ./update-todo-artifact.py --input TODO.md --output TODO.md.new \\
        --task 690 --type research --path specs/.../research-001.md

This script provides reliable TODO.md updates with precise line insertion,
replacing the fragile Edit tool that failed silently for task 690.
"""

import sys
import re
import argparse
from pathlib import Path
from typing import List, Tuple


def find_task_section(lines: List[str], task_number: int) -> Tuple[int, int]:
    """
    Find start and end indices of task section in TODO.md.

    Args:
        lines: Lines from TODO.md
        task_number: Task number to find

    Returns:
        Tuple of (start_idx, end_idx)

    Raises:
        ValueError: If task not found
    """
    start_pattern = re.compile(rf'^### {task_number}\.')
    next_section = re.compile(r'^### \d+\.')

    start_idx = None
    for i, line in enumerate(lines):
        if start_pattern.match(line):
            start_idx = i
            break

    if start_idx is None:
        raise ValueError(f"Task {task_number} not found in TODO.md")

    # Find end (next task section or end of file)
    end_idx = len(lines)
    for i in range(start_idx + 1, len(lines)):
        if next_section.match(lines[i]):
            end_idx = i
            break

    return start_idx, end_idx


def add_artifact_link(
    lines: List[str],
    task_number: int,
    artifact_type: str,
    artifact_path: str
) -> List[str]:
    """
    Add or update artifact link in task section.

    Args:
        lines: Lines from TODO.md
        task_number: Task number
        artifact_type: Type of artifact ('research', 'plan', 'summary')
        artifact_path: Path to artifact file

    Returns:
        Modified lines
    """
    start_idx, end_idx = find_task_section(lines, task_number)

    # Type to label mapping
    type_map = {
        'research': 'Research',
        'plan': 'Plan',
        'summary': 'Summary'
    }

    label = type_map.get(artifact_type, artifact_type.capitalize())
    filename = Path(artifact_path).name
    link_line = f"- **{label}**: [{filename}]({artifact_path})\n"

    # Check if link already exists (prevent duplicates)
    link_pattern = re.compile(rf'^\- \*\*{label}\*\*:')
    existing_idx = None

    for i in range(start_idx, end_idx):
        if link_pattern.match(lines[i]):
            existing_idx = i
            break

    if existing_idx is not None:
        # Replace existing link
        print(f"Replacing existing {label} link at line {existing_idx + 1}")
        lines[existing_idx] = link_line
    else:
        # Find insertion point: after last metadata field, before **Description**
        desc_pattern = re.compile(r'^\*\*Description\*\*:')
        insert_idx = end_idx - 1  # Default: before end of section

        # Look for **Description** marker
        for i in range(start_idx, end_idx):
            if desc_pattern.match(lines[i]):
                insert_idx = i
                break

        # Insert new link
        print(f"Inserting {label} link at line {insert_idx + 1}")
        lines.insert(insert_idx, link_line)

    return lines


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Add artifact link to TODO.md',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --input TODO.md --output TODO.md.new --task 690 --type research \\
      --path specs/690_fix_issues/reports/research-001.md
        """
    )

    parser.add_argument('--input', required=True, help='Input TODO.md file')
    parser.add_argument('--output', required=True, help='Output TODO.md file')
    parser.add_argument('--task', type=int, required=True, help='Task number')
    parser.add_argument(
        '--type',
        required=True,
        choices=['research', 'plan', 'summary'],
        help='Artifact type'
    )
    parser.add_argument('--path', required=True, help='Artifact path')

    args = parser.parse_args()

    input_file = Path(args.input)
    output_file = Path(args.output)

    # Validate input file exists
    if not input_file.exists():
        print(f"Error: {input_file} not found", file=sys.stderr)
        sys.exit(1)

    # Read input
    try:
        lines = input_file.read_text().splitlines(keepends=True)
    except Exception as e:
        print(f"Error reading {input_file}: {e}", file=sys.stderr)
        sys.exit(1)

    # Update
    try:
        updated_lines = add_artifact_link(lines, args.task, args.type, args.path)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)

    # Write output
    try:
        output_file.write_text(''.join(updated_lines))
        print(f"✓ Successfully updated task {args.task}")
    except Exception as e:
        print(f"Error writing {output_file}: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
