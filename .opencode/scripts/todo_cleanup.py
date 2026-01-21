#!/usr/bin/env python3
"""
TODO.md Cleanup Script

Dedicated script for TODO.md maintenance that:
- Archives completed and abandoned tasks
- Fixes divider stacking issues
- Updates state.json and archive/state.json
- Moves project directories to archive

Follows TODO.md file standards defined in specs/TODO.md

Usage:
    python3 .opencode/scripts/todo_cleanup.py [OPTIONS]

Options:
    --dry-run           Show what would be changed without modifying files
    --verbose           Print detailed progress information
    --validate-only     Validate TODO.md format without making changes
    --fix-dividers      Fix divider stacking issues only (no archival)
    --help              Show this help message

Exit Codes:
    0  Success
    1  Validation error (orphaned metadata, invalid format)
    2  File I/O error
    3  Invalid arguments
"""

import argparse
import json
import re
import shutil
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import List, Tuple, Optional, Dict, Any


# Exit codes
EXIT_SUCCESS = 0
EXIT_VALIDATION_ERROR = 1
EXIT_FILE_IO_ERROR = 2
EXIT_ARGUMENT_ERROR = 3


# Error handling classes
class ValidationError(Exception):
    """Raised when TODO.md format validation fails"""

    def __init__(
        self, line_number: int, error_type: str, message: str, suggestion: str = ""
    ):
        self.line_number = line_number
        self.error_type = error_type
        self.message = message
        self.suggestion = suggestion
        super().__init__(f"Line {line_number}: {error_type} - {message}")


class FileIOError(Exception):
    """Raised when file I/O operations fail"""

    pass


@dataclass
class ArchivalResult:
    """Result of archival operation"""

    completed_count: int = 0
    abandoned_count: int = 0
    moved_directories: List[str] = field(default_factory=list)
    errors: List[str] = field(default_factory=list)

    @property
    def total_count(self) -> int:
        return self.completed_count + self.abandoned_count


# Line classification functions
def classify_line(line: str) -> str:
    """
    Classify line type for divider algorithm.

    Returns:
        'section' - Section header (^## )
        'task' - Task header (^### \\d+\\.) with optional checkmark
        'divider' - Horizontal rule (^---$)
        'empty' - Empty line
        'content' - Any other content
    """
    if re.match(r"^## ", line):
        return "section"
    elif re.match(r"^### [✓✗]?\s*\d+\.", line):
        return "task"
    elif re.match(r"^---$", line):
        return "divider"
    elif line.strip() == "":
        return "empty"
    else:
        return "content"


def parse_todo_file(todo_path: Path) -> List[str]:
    """
    Parse TODO.md into list of lines.

    Args:
        todo_path: Path to TODO.md file

    Returns:
        List of lines (with newlines stripped)

    Raises:
        FileIOError: If file cannot be read
    """
    try:
        with open(todo_path, "r", encoding="utf-8") as f:
            return [line.rstrip("\n") for line in f]
    except Exception as e:
        raise FileIOError(f"Cannot read {todo_path}: {e}")


def extract_task_block(
    lines: List[str], task_number: int
) -> Tuple[int, int, List[str]]:
    """
    Extract complete task block (heading + body).

    Args:
        lines: All lines from TODO.md
        task_number: Task number to extract

    Returns:
        (start_line, end_line, task_lines)

    Raises:
        ValueError: Task not found
    """
    # Find task heading (with optional checkmark)
    task_pattern = re.compile(rf"^### [✓✗]?\s*{task_number}\. ")
    start_line = -1

    for i, line in enumerate(lines):
        if task_pattern.match(line):
            start_line = i
            break

    if start_line == -1:
        raise ValueError(f"Task {task_number} not found")

    # Find end boundary (next task, section, divider, or EOF)
    end_line = len(lines)
    for i in range(start_line + 1, len(lines)):
        line_type = classify_line(lines[i])
        if line_type in ["task", "section", "divider"]:
            end_line = i
            break

    return start_line, end_line, lines[start_line:end_line]


def fix_divider_stacking(lines: List[str]) -> List[str]:
    """
    Fix divider stacking using context-aware algorithm.

    Rules:
    1. Skip stacked dividers (divider after divider)
    2. Skip divider after section header (no divider between section and first task)
    3. Ensure divider before section (if not first section)
    4. Ensure divider before task (if not first task in section)
    5. Skip divider before EOF (no trailing divider)

    Args:
        lines: List of lines from TODO.md

    Returns:
        List of lines with fixed dividers
    """
    result = []
    prev_type = None
    prev_non_empty_type = None

    for i, line in enumerate(lines):
        line_type = classify_line(line)

        # Rule 1: Skip stacked dividers
        if line_type == "divider" and prev_non_empty_type == "divider":
            continue  # Skip this divider

        # Rule 2: Skip divider after section header
        if line_type == "divider" and prev_non_empty_type == "section":
            continue  # No divider after section header

        # Rule 3: Ensure divider before section (if not first section)
        if line_type == "section" and prev_non_empty_type not in ["divider", None]:
            result.append("")  # Add blank line before divider
            result.append("---")  # Add divider before section
            result.append("")  # Add blank line after divider

        # Rule 4: Ensure divider before task (if not first task in section)
        if line_type == "task" and prev_non_empty_type == "content":
            result.append("")  # Add blank line before divider
            result.append("---")  # Add divider before task
            result.append("")  # Add blank line after divider

        # Rule 5: Skip divider before EOF
        if line_type == "divider" and i == len(lines) - 1:
            continue  # No divider at EOF

        # Add line
        result.append(line)

        # Update context (track non-empty types for context)
        if line_type != "empty":
            prev_non_empty_type = line_type
        prev_type = line_type

    return result


def format_markdown(content: str) -> str:
    """
    Apply comprehensive markdown formatting to TODO.md content.

    Formatting rules:
    1. Remove trailing whitespace from all lines
    2. Normalize blank lines (max 2 consecutive)
    3. Ensure blank line before/after headings (## and ###)
    4. Ensure blank line before/after dividers (---)
    5. Ensure single trailing newline at EOF
    6. Preserve frontmatter (YAML between --- markers at start)
    7. Preserve code blocks

    Args:
        content: Raw file content as string

    Returns:
        Formatted content string
    """
    lines = content.split("\n")
    result = []

    # State tracking
    in_frontmatter = False
    in_code_block = False
    frontmatter_started = False
    consecutive_blank = 0

    for i, line in enumerate(lines):
        # Track frontmatter (YAML between --- at start of file)
        if i == 0 and line.strip() == "---":
            in_frontmatter = True
            frontmatter_started = True
            result.append(line.rstrip())
            continue

        if in_frontmatter and line.strip() == "---":
            in_frontmatter = False
            result.append(line.rstrip())
            continue

        if in_frontmatter:
            result.append(line.rstrip())
            continue

        # Track code blocks
        if line.strip().startswith("```"):
            in_code_block = not in_code_block
            result.append(line.rstrip())
            consecutive_blank = 0
            continue

        if in_code_block:
            # Preserve code blocks as-is (except trailing whitespace)
            result.append(line.rstrip())
            continue

        # Remove trailing whitespace
        stripped = line.rstrip()

        # Handle blank lines
        if not stripped:
            consecutive_blank += 1
            # Max 2 consecutive blank lines
            if consecutive_blank <= 2:
                result.append("")
            continue

        # Non-blank line
        is_heading = stripped.startswith("#")
        is_divider = stripped == "---"

        # Ensure blank line before headings/dividers (if not at start)
        if (is_heading or is_divider) and result and result[-1] != "":
            result.append("")

        result.append(stripped)

        # Ensure blank line after headings/dividers
        if is_heading or is_divider:
            consecutive_blank = 0  # Reset, but we'll add blank after
        else:
            consecutive_blank = 0

    # Remove trailing blank lines, keep exactly one newline at EOF
    while result and result[-1] == "":
        result.pop()

    return "\n".join(result) + "\n"


def validate_todo_format(lines: List[str]) -> List[ValidationError]:
    """
    Validate TODO.md format and detect issues.

    Checks:
    - No orphaned metadata lines (metadata without task header)
    - Valid status markers
    - Proper divider placement

    Args:
        lines: List of lines from TODO.md

    Returns:
        List of validation errors (empty if valid)
    """
    errors = []
    in_task_block = False
    in_overview_section = False
    last_task_line = -100  # Track last task header

    for i, line in enumerate(lines):
        line_type = classify_line(line)

        # Track if we're in Overview section (metadata is allowed here)
        if re.match(r"^## Overview", line):
            in_overview_section = True
        elif line_type == "section":
            in_overview_section = False

        # Track task headers
        if line_type == "task":
            last_task_line = i
            in_task_block = True
        elif line_type in ["section", "divider"]:
            in_task_block = False

        # Check for orphaned metadata (only outside Overview and task blocks)
        if re.match(r"^- \*\*", line):
            # Skip validation if in Overview section
            if in_overview_section:
                continue

            # Metadata line - check if within reasonable distance of task header
            # Allow up to 100 lines for large task descriptions
            if i - last_task_line > 100:
                errors.append(
                    ValidationError(
                        line_number=i + 1,
                        error_type="orphaned_metadata",
                        message=f"Metadata line without task header: {line[:50]}",
                        suggestion="Ensure metadata follows task header",
                    )
                )

        # Check for invalid status markers
        status_match = re.search(r"\*\*Status\*\*:\s*\[([^\]]+)\]", line)
        if status_match:
            status = status_match.group(1)
            valid_statuses = [
                "NOT STARTED",
                "IN PROGRESS",
                "RESEARCHED",
                "PLANNED",
                "BLOCKED",
                "COMPLETED",
                "ABANDONED",
                "RESEARCHING",
                "PLANNING",
                "IMPLEMENTING",
                "REVISING",
            ]
            if status not in valid_statuses:
                errors.append(
                    ValidationError(
                        line_number=i + 1,
                        error_type="invalid_status",
                        message=f"Invalid status marker: [{status}]",
                        suggestion=f"Use one of: {', '.join(valid_statuses)}",
                    )
                )

    return errors


def identify_tasks_to_archive(lines: List[str]) -> List[int]:
    """
    Identify tasks to archive (COMPLETED or ABANDONED status).

    Args:
        lines: List of lines from TODO.md

    Returns:
        List of task numbers to archive
    """
    tasks_to_archive = []
    current_task = None

    for line in lines:
        # Check for task header (with optional checkmark)
        task_match = re.match(r"^### [✓✗]?\s*(\d+)\.", line)
        if task_match:
            current_task = int(task_match.group(1))

        # Check for COMPLETED or ABANDONED status
        if current_task and re.search(
            r"\*\*Status\*\*:\s*\[(COMPLETED|ABANDONED)\]", line
        ):
            if current_task not in tasks_to_archive:
                tasks_to_archive.append(current_task)

    return tasks_to_archive


def archive_tasks(
    todo_path: Path,
    state_path: Path,
    archive_state_path: Path,
    specs_dir: Path,
    dry_run: bool = False,
    verbose: bool = False,
) -> ArchivalResult:
    """
    Archive completed and abandoned tasks.

    Process:
    1. Identify tasks to archive (COMPLETED, ABANDONED)
    2. Extract task blocks
    3. Update TODO.md (remove blocks)
    4. Fix dividers
    5. Update state.json
    6. Update archive/state.json
    7. Move project directories

    Args:
        todo_path: Path to TODO.md
        state_path: Path to state.json
        archive_state_path: Path to archive/state.json
        specs_dir: Path to specs directory
        dry_run: If True, don't modify files
        verbose: If True, print detailed progress

    Returns:
        ArchivalResult with counts, moved directories, errors

    Raises:
        FileIOError: If file operations fail
        ValidationError: If validation fails
    """
    result = ArchivalResult()

    # Parse TODO.md
    if verbose:
        print(f"Parsing {todo_path}...")
    lines = parse_todo_file(todo_path)

    # Validate format
    if verbose:
        print("Validating TODO.md format...")
    validation_errors = validate_todo_format(lines)
    if validation_errors:
        for error in validation_errors:
            print(f"[FAIL] {error}", file=sys.stderr)
        raise ValidationError(
            line_number=validation_errors[0].line_number,
            error_type="validation_failed",
            message=f"Found {len(validation_errors)} validation errors",
        )

    # Identify tasks to archive
    if verbose:
        print("Identifying tasks to archive...")
    tasks_to_archive = identify_tasks_to_archive(lines)

    if not tasks_to_archive:
        if verbose:
            print("No tasks to archive")
        return result

    if verbose:
        print(f"Found {len(tasks_to_archive)} tasks to archive: {tasks_to_archive}")

    # Count by status
    for task_num in tasks_to_archive:
        _, _, task_lines = extract_task_block(lines, task_num)
        task_text = "\n".join(task_lines)
        if "[COMPLETED]" in task_text:
            result.completed_count += 1
        elif "[ABANDONED]" in task_text:
            result.abandoned_count += 1

    # Remove task blocks from TODO.md
    if verbose:
        print("Removing task blocks from TODO.md...")

    # Sort in reverse order to avoid index shifting
    tasks_to_archive.sort(reverse=True)

    for task_num in tasks_to_archive:
        start, end, _ = extract_task_block(lines, task_num)
        if verbose:
            print(f"  Removing task {task_num} (lines {start + 1}-{end})")
        # Remove lines [start, end)
        del lines[start:end]

    # Fix dividers
    if verbose:
        print("Fixing divider stacking...")
    lines = fix_divider_stacking(lines)

    # Write updated TODO.md
    if not dry_run:
        if verbose:
            print(f"Writing updated {todo_path}...")
        try:
            with open(todo_path, "w", encoding="utf-8") as f:
                f.write("\n".join(lines))
                f.write("\n")  # Ensure trailing newline
        except Exception as e:
            raise FileIOError(f"Cannot write {todo_path}: {e}")
    else:
        print(f"[DRY RUN] Would write {len(lines)} lines to {todo_path}")

    # Update state.json by moving completed/abandoned tasks from active_projects to completed_projects
    if verbose:
        print(f"Updating {state_path}...")

    if not dry_run:
        try:
            # Read current state.json
            with open(state_path, "r", encoding="utf-8") as f:
                state_data = json.load(f)

            # Read archive state.json or create from template
            archive_state = {
                "completed_projects": [],
                "metadata": {"archived_tasks": len(tasks_to_archive)},
            }
            if archive_state_path.exists():
                with open(archive_state_path, "r", encoding="utf-8") as f:
                    archive_state = json.load(f)

            # Move tasks from active_projects to completed_projects
            tasks_to_archive_set = set(tasks_to_archive)
            remaining_active = []
            moved_to_completed = []

            for project in state_data.get("active_projects", []):
                project_num = project.get("project_number")
                if project_num in tasks_to_archive_set:
                    # Add archival metadata
                    project["archived"] = datetime.now().isoformat() + "Z"
                    project["archived_reason"] = project.get("status", "completed")
                    moved_to_completed.append(project)
                else:
                    remaining_active.append(project)

            # Update state.json
            state_data["active_projects"] = remaining_active

            # Add to completed_projects in state.json (if not already there)
            if "completed_projects" not in state_data:
                state_data["completed_projects"] = []

            # Merge with existing completed projects, avoiding duplicates
            existing_nums = {
                p.get("project_number") for p in state_data["completed_projects"]
            }
            for project in moved_to_completed:
                if project.get("project_number") not in existing_nums:
                    state_data["completed_projects"].append(project)

            # Add to archive state.json as well
            if "completed_projects" not in archive_state:
                archive_state["completed_projects"] = []

            archive_existing_nums = {
                p.get("project_number") for p in archive_state["completed_projects"]
            }
            for project in moved_to_completed:
                if project.get("project_number") not in archive_existing_nums:
                    archive_state["completed_projects"].append(project)

            # Write updated state.json
            with open(state_path, "w", encoding="utf-8") as f:
                json.dump(state_data, f, indent=2)

            # Write updated archive state.json
            archive_state_path.parent.mkdir(parents=True, exist_ok=True)
            with open(archive_state_path, "w", encoding="utf-8") as f:
                json.dump(archive_state, f, indent=2)

            if verbose:
                print(
                    f"  Moved {len(moved_to_completed)} tasks from active_projects to completed_projects"
                )
                print(f"  Updated {state_path}")
                print(f"  Updated {archive_state_path}")

        except Exception as e:
            raise FileIOError(f"Cannot update state files: {e}")
    else:
        print(f"[DRY RUN] Would update {state_path} and {archive_state_path}")
        print(
            f"[DRY RUN] Would move {len(tasks_to_archive)} tasks to completed_projects"
        )

    # Move project directories
    if verbose:
        print("Checking for project directories to move...")

    for task_num in tasks_to_archive:
        # Try to find project directory
        project_dirs = list(specs_dir.glob(f"{task_num}_*"))
        if project_dirs:
            src = project_dirs[0]
            dst = specs_dir / "archive" / src.name

            if not dry_run:
                if verbose:
                    print(f"  Moving {src.name} to archive/")
                try:
                    # Ensure archive directory exists
                    dst.parent.mkdir(parents=True, exist_ok=True)
                    shutil.move(str(src), str(dst))
                    result.moved_directories.append(src.name)
                except Exception as e:
                    error_msg = f"Failed to move {src} to {dst}: {e}"
                    result.errors.append(error_msg)
                    if verbose:
                        print(f"  [WARN] {error_msg}")
            else:
                print(f"[DRY RUN] Would move {src.name} to archive/")
                result.moved_directories.append(src.name)
        else:
            if verbose:
                print(f"  Task {task_num} has no project directory")

    return result


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="TODO.md cleanup script for archiving completed/abandoned tasks",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be changed without modifying files",
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Print detailed progress information"
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Validate TODO.md format without making changes",
    )
    parser.add_argument(
        "--fix-dividers",
        action="store_true",
        help="Fix divider stacking issues only (no archival)",
    )
    parser.add_argument(
        "--format-only",
        action="store_true",
        help="Apply markdown formatting only (no archival)",
    )

    args = parser.parse_args()

    # Determine project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent.parent

    # Define paths - use specs/ as the canonical location
    todo_path = project_root / "specs" / "TODO.md"
    state_path = project_root / "specs" / "state.json"
    archive_state_path = project_root / "specs" / "archive" / "state.json"
    specs_dir = project_root / "specs"

    try:
        # Validate-only mode
        if args.validate_only:
            if args.verbose:
                print(f"Validating {todo_path}...")
            lines = parse_todo_file(todo_path)
            errors = validate_todo_format(lines)

            if errors:
                print(f"[FAIL] Validation failed with {len(errors)} errors:\n")
                for error in errors:
                    print(f"  Line {error.line_number}: {error.error_type}")
                    print(f"    {error.message}")
                    if error.suggestion:
                        print(f"    Suggestion: {error.suggestion}")
                    print()
                return EXIT_VALIDATION_ERROR
            else:
                print("[PASS] TODO.md format is valid")
                return EXIT_SUCCESS

        # Fix-dividers mode
        if args.fix_dividers:
            if args.verbose:
                print(f"Fixing dividers in {todo_path}...")
            lines = parse_todo_file(todo_path)
            fixed_lines = fix_divider_stacking(lines)

            # Also apply markdown formatting
            content = "\n".join(fixed_lines) + "\n"
            formatted = format_markdown(content)

            if not args.dry_run:
                with open(todo_path, "w", encoding="utf-8") as f:
                    f.write(formatted)
                print(f"[PASS] Fixed dividers and formatted {todo_path}")
            else:
                print(f"[DRY RUN] Would fix dividers and format {todo_path}")
            return EXIT_SUCCESS

        # Format-only mode
        if args.format_only:
            if args.verbose:
                print(f"Formatting {todo_path}...")

            with open(todo_path, "r", encoding="utf-8") as f:
                content = f.read()

            formatted = format_markdown(content)

            if not args.dry_run:
                with open(todo_path, "w", encoding="utf-8") as f:
                    f.write(formatted)
                print(f"[PASS] Formatted {todo_path}")
            else:
                print(f"[DRY RUN] Would format {todo_path}")
            return EXIT_SUCCESS

        # Archive mode (default)
        result = archive_tasks(
            todo_path=todo_path,
            state_path=state_path,
            archive_state_path=archive_state_path,
            specs_dir=specs_dir,
            dry_run=args.dry_run,
            verbose=args.verbose,
        )

        # Apply markdown formatting after archival
        if not args.dry_run:
            if args.verbose:
                print("Applying markdown formatting...")
            try:
                with open(todo_path, "r", encoding="utf-8") as f:
                    content = f.read()
                formatted = format_markdown(content)
                with open(todo_path, "w", encoding="utf-8") as f:
                    f.write(formatted)
            except Exception as e:
                # Non-fatal: log but don't abort
                print(f"[WARN] Formatting failed (non-fatal): {e}")
        else:
            print("[DRY RUN] Would apply markdown formatting after archival")

        # Print summary
        print(f"\n[PASS] Archival {'simulation' if args.dry_run else 'complete'}")
        print(f"Tasks archived: {result.total_count}")
        print(f"  - Completed: {result.completed_count}")
        print(f"  - Abandoned: {result.abandoned_count}")

        if result.moved_directories:
            print(f"\nProject directories moved: {len(result.moved_directories)}")
            for dir_name in result.moved_directories:
                print(f"  - {dir_name}")

        if result.errors:
            print(f"\nErrors encountered: {len(result.errors)}")
            for error in result.errors:
                print(f"  - {error}")

        return EXIT_SUCCESS

    except ValidationError as e:
        print(f"[FAIL] Validation error: {e}", file=sys.stderr)
        return EXIT_VALIDATION_ERROR
    except FileIOError as e:
        print(f"[FAIL] File I/O error: {e}", file=sys.stderr)
        return EXIT_FILE_IO_ERROR
    except Exception as e:
        print(f"[FAIL] Unexpected error: {e}", file=sys.stderr)
        import traceback

        traceback.print_exc()
        return EXIT_FILE_IO_ERROR


if __name__ == "__main__":
    sys.exit(main())
