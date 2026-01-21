#!/usr/bin/env python3
"""
State.json ↔ TODO.md Consistency Validation and Repair Utility

This utility validates consistency between state.json and TODO.md, detecting:
- Missing tasks in either file
- Metadata mismatches (status, priority, language, effort, description)
- Numbering issues (duplicate task numbers, incorrect next_project_number)
- Structure issues (invalid JSON, missing sections)

Usage:
    python3 validate_state_sync.py              # Check only
    python3 validate_state_sync.py --fix        # Check and repair
    python3 validate_state_sync.py --report     # Detailed report
    python3 validate_state_sync.py --fix --auto # Auto-repair without prompts
"""

import json
import re
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Set
from dataclasses import dataclass
from enum import Enum


class Severity(Enum):
    """Issue severity levels"""

    CRITICAL = "CRITICAL"
    WARNING = "WARNING"
    INFO = "INFO"


@dataclass
class Issue:
    """Represents a consistency issue"""

    severity: Severity
    message: str
    task_number: Optional[int] = None
    fix_available: bool = False
    fix_description: Optional[str] = None


class StateValidator:
    """Validates consistency between state.json and TODO.md"""

    def __init__(self, specs_dir: Path):
        self.specs_dir = specs_dir
        self.todo_path = specs_dir / "TODO.md"
        self.state_path = specs_dir / "state.json"
        self.issues: List[Issue] = []

    def validate(self) -> List[Issue]:
        """Run all validation checks"""
        self.issues = []

        # Check files exist
        if not self.todo_path.exists():
            self.issues.append(
                Issue(
                    Severity.CRITICAL,
                    f"TODO.md not found at {self.todo_path}",
                    fix_available=False,
                )
            )
            return self.issues

        if not self.state_path.exists():
            self.issues.append(
                Issue(
                    Severity.CRITICAL,
                    f"state.json not found at {self.state_path}",
                    fix_available=False,
                )
            )
            return self.issues

        # Load files
        try:
            todo_tasks = self._parse_todo()
            state_data = self._parse_state()
        except Exception as e:
            self.issues.append(
                Issue(
                    Severity.CRITICAL,
                    f"Failed to parse files: {e}",
                    fix_available=False,
                )
            )
            return self.issues

        # Run validation checks
        self._check_task_existence(todo_tasks, state_data)
        self._check_metadata_consistency(todo_tasks, state_data)
        self._check_numbering(todo_tasks, state_data)
        self._check_structure(todo_tasks, state_data)

        return self.issues

    def _parse_todo(self) -> Dict[int, Dict]:
        """Parse TODO.md and extract task information"""
        tasks = {}
        content = self.todo_path.read_text()

        # Find all task entries: ### {number}. {title}
        task_pattern = r"^### (\d+)\.\s+(.+?)$"
        lines = content.split("\n")

        i = 0
        while i < len(lines):
            match = re.match(task_pattern, lines[i])
            if match:
                task_num = int(match.group(1))
                title = match.group(2).strip()

                # Extract metadata from following lines
                task_data = {
                    "number": task_num,
                    "title": title,
                    "effort": None,
                    "status": None,
                    "priority": None,
                    "language": None,
                    "description": None,
                }

                # Look ahead for metadata
                j = i + 1
                while j < len(lines) and not lines[j].startswith("###"):
                    line = lines[j].strip()

                    # Extract metadata fields
                    if line.startswith("- **Effort**:"):
                        task_data["effort"] = line.split(":", 1)[1].strip()
                    elif line.startswith("- **Status**:"):
                        status_match = re.search(r"\[(.*?)\]", line)
                        if status_match:
                            task_data["status"] = status_match.group(1)
                    elif line.startswith("- **Priority**:"):
                        task_data["priority"] = line.split(":", 1)[1].strip()
                    elif line.startswith("- **Language**:"):
                        task_data["language"] = line.split(":", 1)[1].strip()
                    elif line.startswith("**Description**:"):
                        # Description can be multi-line
                        desc_lines = [line.split(":", 1)[1].strip()]
                        k = j + 1
                        while (
                            k < len(lines)
                            and lines[k].strip()
                            and not lines[k].startswith("---")
                            and not lines[k].startswith("- **")
                        ):
                            desc_lines.append(lines[k].strip())
                            k += 1
                        task_data["description"] = " ".join(desc_lines)

                    j += 1

                tasks[task_num] = task_data
                i = j
            else:
                i += 1

        return tasks

    def _parse_state(self) -> Dict:
        """Parse state.json"""
        with open(self.state_path, "r") as f:
            return json.load(f)

    def _check_task_existence(self, todo_tasks: Dict, state_data: Dict):
        """Check that all tasks exist in both files"""
        todo_numbers = set(todo_tasks.keys())
        state_numbers = set(
            p["project_number"] for p in state_data.get("active_projects", [])
        )

        # Tasks in state.json but not TODO.md
        missing_in_todo = state_numbers - todo_numbers
        for task_num in missing_in_todo:
            self.issues.append(
                Issue(
                    Severity.CRITICAL,
                    f"Task {task_num} exists in state.json but not in TODO.md",
                    task_number=task_num,
                    fix_available=True,
                    fix_description="Add task to TODO.md from state.json",
                )
            )

        # Tasks in TODO.md but not state.json
        missing_in_state = todo_numbers - state_numbers
        for task_num in missing_in_state:
            self.issues.append(
                Issue(
                    Severity.CRITICAL,
                    f"Task {task_num} exists in TODO.md but not in state.json",
                    task_number=task_num,
                    fix_available=True,
                    fix_description="Add task to state.json from TODO.md",
                )
            )

    def _check_metadata_consistency(self, todo_tasks: Dict, state_data: Dict):
        """Check that metadata matches between files"""
        state_tasks = {
            p["project_number"]: p for p in state_data.get("active_projects", [])
        }

        for task_num in set(todo_tasks.keys()) & set(state_tasks.keys()):
            todo_task = todo_tasks[task_num]
            state_task = state_tasks[task_num]

            # Check status
            todo_status = self._normalize_status(todo_task.get("status"))
            state_status = state_task.get("status")
            if todo_status != state_status:
                self.issues.append(
                    Issue(
                        Severity.WARNING,
                        f"Task {task_num} status mismatch: TODO.md=[{todo_task.get('status')}], state.json={state_status}",
                        task_number=task_num,
                        fix_available=True,
                        fix_description="Update TODO.md status from state.json",
                    )
                )

            # Check priority
            todo_priority = (todo_task.get("priority") or "").lower()
            state_priority = (state_task.get("priority") or "").lower()
            if todo_priority != state_priority:
                self.issues.append(
                    Issue(
                        Severity.WARNING,
                        f"Task {task_num} priority mismatch: TODO.md={todo_task.get('priority')}, state.json={state_task.get('priority')}",
                        task_number=task_num,
                        fix_available=True,
                        fix_description="Update TODO.md priority from state.json",
                    )
                )

            # Check language
            todo_lang = (todo_task.get("language") or "").lower()
            state_lang = (state_task.get("language") or "").lower()
            if todo_lang != state_lang:
                self.issues.append(
                    Issue(
                        Severity.WARNING,
                        f"Task {task_num} language mismatch: TODO.md={todo_task.get('language')}, state.json={state_task.get('language')}",
                        task_number=task_num,
                        fix_available=True,
                        fix_description="Update TODO.md language from state.json",
                    )
                )

            # Check description
            todo_desc = (todo_task.get("description") or "").strip()
            state_desc = (state_task.get("description") or "").strip()

            if not todo_desc and state_desc:
                self.issues.append(
                    Issue(
                        Severity.WARNING,
                        f"Task {task_num} missing Description field in TODO.md (present in state.json)",
                        task_number=task_num,
                        fix_available=True,
                        fix_description="Copy description from state.json to TODO.md",
                    )
                )
            elif todo_desc and not state_desc:
                self.issues.append(
                    Issue(
                        Severity.WARNING,
                        f"Task {task_num} missing description field in state.json (present in TODO.md)",
                        task_number=task_num,
                        fix_available=True,
                        fix_description="Copy description from TODO.md to state.json",
                    )
                )
            elif not todo_desc and not state_desc:
                self.issues.append(
                    Issue(
                        Severity.INFO,
                        f"Task {task_num} has no description in either file (legacy task)",
                        task_number=task_num,
                        fix_available=False,
                    )
                )

    def _check_numbering(self, todo_tasks: Dict, state_data: Dict):
        """Check task numbering consistency"""
        all_numbers = list(todo_tasks.keys())

        # Check for duplicates
        if len(all_numbers) != len(set(all_numbers)):
            duplicates = [n for n in all_numbers if all_numbers.count(n) > 1]
            self.issues.append(
                Issue(
                    Severity.CRITICAL,
                    f"Duplicate task numbers found: {duplicates}",
                    fix_available=False,
                )
            )

        # Check next_project_number
        next_num = state_data.get("next_project_number")
        if next_num is not None and all_numbers:
            max_num = max(all_numbers)
            expected_next = max_num + 1
            if next_num != expected_next:
                self.issues.append(
                    Issue(
                        Severity.WARNING,
                        f"next_project_number ({next_num}) should be {expected_next} (max task + 1)",
                        fix_available=True,
                        fix_description=f"Update next_project_number to {expected_next}",
                    )
                )

    def _check_structure(self, todo_tasks: Dict, state_data: Dict):
        """Check file structure"""
        # Check state.json has required fields
        required_fields = ["active_projects", "next_project_number"]
        for field in required_fields:
            if field not in state_data:
                self.issues.append(
                    Issue(
                        Severity.CRITICAL,
                        f"state.json missing required field: {field}",
                        fix_available=False,
                    )
                )

        # Check TODO.md has required sections
        content = self.todo_path.read_text()
        required_sections = [
            "## High Priority Tasks",
            "## Medium Priority Tasks",
            "## Low Priority Tasks",
        ]
        for section in required_sections:
            if section not in content:
                self.issues.append(
                    Issue(
                        Severity.WARNING,
                        f"TODO.md missing section: {section}",
                        fix_available=False,
                    )
                )

    def _normalize_status(self, status: Optional[str]) -> Optional[str]:
        """Normalize status from TODO.md format to state.json format"""
        if not status:
            return None

        status_map = {
            "NOT STARTED": "not_started",
            "IN PROGRESS": "in_progress",
            "RESEARCHED": "researched",
            "PLANNED": "planned",
            "BLOCKED": "blocked",
            "ABANDONED": "abandoned",
            "COMPLETED": "completed",
        }

        return status_map.get(status.upper(), status.lower())

    def repair(self, auto: bool = False) -> int:
        """Repair issues that have fixes available"""
        fixable_issues = [i for i in self.issues if i.fix_available]

        if not fixable_issues:
            print("No fixable issues found.")
            return 0

        print(f"\nFound {len(fixable_issues)} fixable issues.")

        if not auto:
            response = input("Proceed with repairs? (y/n): ")
            if response.lower() != "y":
                print("Repair cancelled.")
                return 0

        # Create backups
        self._create_backups()

        # Load files
        todo_tasks = self._parse_todo()
        state_data = self._parse_state()

        fixed_count = 0

        for issue in fixable_issues:
            try:
                if issue.task_number is None:
                    if "next_project_number" in issue.message:
                        self._fix_next_project_number(todo_tasks, state_data)
                        fixed_count += 1
                    continue

                if "missing Description field in TODO.md" in issue.message:
                    self._fix_missing_description_in_todo(
                        issue.task_number, todo_tasks, state_data
                    )
                    fixed_count += 1
                elif "missing description field in state.json" in issue.message:
                    self._fix_missing_description_in_state(
                        issue.task_number, todo_tasks, state_data
                    )
                    fixed_count += 1
                elif "status mismatch" in issue.message:
                    self._fix_status_mismatch(issue.task_number, todo_tasks, state_data)
                    fixed_count += 1
                elif "priority mismatch" in issue.message:
                    self._fix_priority_mismatch(
                        issue.task_number, todo_tasks, state_data
                    )
                    fixed_count += 1
                elif "language mismatch" in issue.message:
                    self._fix_language_mismatch(
                        issue.task_number, todo_tasks, state_data
                    )
                    fixed_count += 1
                elif "exists in state.json but not in TODO.md" in issue.message:
                    self._fix_missing_in_todo(issue.task_number, state_data)
                    fixed_count += 1
                elif "exists in TODO.md but not in state.json" in issue.message:
                    self._fix_missing_in_state(
                        issue.task_number, todo_tasks, state_data
                    )
                    fixed_count += 1
            except Exception as e:
                print(f"✗ Failed to fix issue for task {issue.task_number}: {e}")

        print(f"\n✓ Fixed {fixed_count} issues")

        # Validate repairs
        print("\nValidating repairs...")
        self.validate()
        remaining_issues = [
            i
            for i in self.issues
            if i.severity == Severity.CRITICAL or i.severity == Severity.WARNING
        ]

        if not remaining_issues:
            print("✓ All inconsistencies resolved")
        else:
            print(f"⚠ {len(remaining_issues)} issues remain")

        return fixed_count

    def _create_backups(self):
        """Create backups of TODO.md and state.json"""
        import shutil
        from datetime import datetime

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        todo_backup = self.todo_path.parent / f"TODO.md.backup_{timestamp}"
        state_backup = self.state_path.parent / f"state.json.backup_{timestamp}"

        shutil.copy2(self.todo_path, todo_backup)
        shutil.copy2(self.state_path, state_backup)

        print(f"Created backups:")
        print(f"  - {todo_backup}")
        print(f"  - {state_backup}")

    def _fix_missing_description_in_todo(
        self, task_num: int, todo_tasks: Dict, state_data: Dict
    ):
        """Copy description from state.json to TODO.md"""
        state_tasks = {
            p["project_number"]: p for p in state_data.get("active_projects", [])
        }
        state_task = state_tasks.get(task_num)

        if not state_task or not state_task.get("description"):
            return

        description = state_task["description"]

        # Read TODO.md
        content = self.todo_path.read_text()
        lines = content.split("\n")

        # Find task entry
        task_pattern = f"^### {task_num}\\."
        for i, line in enumerate(lines):
            if re.match(task_pattern, line):
                # Find where to insert description (after metadata, before ---)
                j = i + 1
                while j < len(lines) and not lines[j].startswith("---"):
                    if lines[j].startswith("**Description**:"):
                        # Description already exists, skip
                        return
                    j += 1

                # Insert description before ---
                if j < len(lines) and lines[j].startswith("---"):
                    lines.insert(j, f"\n**Description**: {description}\n")

                    # Write back
                    self.todo_path.write_text("\n".join(lines))
                    print(f"✓ Added description to TODO.md for task {task_num}")
                break

    def _fix_missing_description_in_state(
        self, task_num: int, todo_tasks: Dict, state_data: Dict
    ):
        """Copy description from TODO.md to state.json"""
        todo_task = todo_tasks.get(task_num)

        if not todo_task or not todo_task.get("description"):
            return

        description = todo_task["description"]

        # Find task in state.json
        for project in state_data.get("active_projects", []):
            if project["project_number"] == task_num:
                project["description"] = description

                # Write back
                with open(self.state_path, "w") as f:
                    json.dump(state_data, f, indent=2)

                print(f"✓ Added description to state.json for task {task_num}")
                break

    def _fix_next_project_number(self, todo_tasks: Dict, state_data: Dict):
        """Fix next_project_number in state.json"""
        if not todo_tasks:
            return

        max_num = max(todo_tasks.keys())
        expected_next = max_num + 1

        state_data["next_project_number"] = expected_next

        with open(self.state_path, "w") as f:
            json.dump(state_data, f, indent=2)

        print(f"✓ Updated next_project_number to {expected_next}")

    def _fix_status_mismatch(self, task_num: int, todo_tasks: Dict, state_data: Dict):
        """Fix status mismatch (use state.json as source of truth)"""
        state_tasks = {
            p["project_number"]: p for p in state_data.get("active_projects", [])
        }
        state_task = state_tasks.get(task_num)

        if not state_task:
            return

        state_status = state_task.get("status", "not_started")

        # Map state.json status to TODO.md format
        status_map = {
            "not_started": "NOT STARTED",
            "in_progress": "IN PROGRESS",
            "researched": "RESEARCHED",
            "planned": "PLANNED",
            "blocked": "BLOCKED",
            "abandoned": "ABANDONED",
            "completed": "COMPLETED",
        }

        todo_status = status_map.get(state_status, state_status.upper())

        # Update TODO.md
        content = self.todo_path.read_text()
        lines = content.split("\n")

        task_pattern = f"^### {task_num}\\."
        for i, line in enumerate(lines):
            if re.match(task_pattern, line):
                # Find status line
                j = i + 1
                while j < len(lines) and not lines[j].startswith("###"):
                    if lines[j].strip().startswith("- **Status**:"):
                        lines[j] = f"- **Status**: [{todo_status}]"
                        self.todo_path.write_text("\n".join(lines))
                        print(
                            f"✓ Updated status for task {task_num} to [{todo_status}]"
                        )
                        return
                    j += 1
                break

    def _fix_priority_mismatch(self, task_num: int, todo_tasks: Dict, state_data: Dict):
        """Fix priority mismatch (use state.json as source of truth)"""
        state_tasks = {
            p["project_number"]: p for p in state_data.get("active_projects", [])
        }
        state_task = state_tasks.get(task_num)

        if not state_task:
            return

        state_priority = state_task.get("priority", "medium").capitalize()

        # Update TODO.md
        content = self.todo_path.read_text()
        lines = content.split("\n")

        task_pattern = f"^### {task_num}\\."
        for i, line in enumerate(lines):
            if re.match(task_pattern, line):
                # Find priority line
                j = i + 1
                while j < len(lines) and not lines[j].startswith("###"):
                    if lines[j].strip().startswith("- **Priority**:"):
                        lines[j] = f"- **Priority**: {state_priority}"
                        self.todo_path.write_text("\n".join(lines))
                        print(
                            f"✓ Updated priority for task {task_num} to {state_priority}"
                        )
                        return
                    j += 1
                break

    def _fix_language_mismatch(self, task_num: int, todo_tasks: Dict, state_data: Dict):
        """Fix language mismatch (use state.json as source of truth)"""
        state_tasks = {
            p["project_number"]: p for p in state_data.get("active_projects", [])
        }
        state_task = state_tasks.get(task_num)

        if not state_task:
            return

        state_language = state_task.get("language", "general")

        # Update TODO.md
        content = self.todo_path.read_text()
        lines = content.split("\n")

        task_pattern = f"^### {task_num}\\."
        for i, line in enumerate(lines):
            if re.match(task_pattern, line):
                # Find language line
                j = i + 1
                while j < len(lines) and not lines[j].startswith("###"):
                    if lines[j].strip().startswith("- **Language**:"):
                        lines[j] = f"- **Language**: {state_language}"
                        self.todo_path.write_text("\n".join(lines))
                        print(
                            f"✓ Updated language for task {task_num} to {state_language}"
                        )
                        return
                    j += 1
                break

    def _fix_missing_in_todo(self, task_num: int, state_data: Dict):
        """Add task to TODO.md from state.json"""
        state_tasks = {
            p["project_number"]: p for p in state_data.get("active_projects", [])
        }
        state_task = state_tasks.get(task_num)

        if not state_task:
            return

        # Format task entry
        title = (
            state_task.get("project_name", f"task_{task_num}").replace("_", " ").title()
        )
        effort = state_task.get("effort", "TBD")
        status = state_task.get("status", "not_started").replace("_", " ").upper()
        priority = state_task.get("priority", "medium").capitalize()
        language = state_task.get("language", "general")
        description = state_task.get("description", "")

        entry = f"""### {task_num}. {title}
- **Effort**: {effort}
- **Status**: [{status}]
- **Priority**: {priority}
- **Language**: {language}
- **Blocking**: None
- **Dependencies**: None

**Description**: {description}

---
"""

        # Find correct section in TODO.md
        content = self.todo_path.read_text()

        section_map = {
            "high": "## High Priority Tasks",
            "medium": "## Medium Priority Tasks",
            "low": "## Low Priority Tasks",
        }

        section = section_map.get(priority.lower(), "## Medium Priority Tasks")

        # Insert after section heading
        if section in content:
            parts = content.split(section)
            if len(parts) >= 2:
                # Find next section or end
                next_section_match = re.search(r"\n## ", parts[1])
                if next_section_match:
                    insert_pos = next_section_match.start()
                    parts[1] = (
                        parts[1][:insert_pos] + "\n" + entry + parts[1][insert_pos:]
                    )
                else:
                    parts[1] = parts[1] + "\n" + entry

                content = section.join(parts)
                self.todo_path.write_text(content)
                print(f"✓ Added task {task_num} to TODO.md")

    def _fix_missing_in_state(self, task_num: int, todo_tasks: Dict, state_data: Dict):
        """Add task to state.json from TODO.md"""
        todo_task = todo_tasks.get(task_num)

        if not todo_task:
            return

        # Create state.json entry
        from datetime import datetime

        slug = todo_task["title"].lower().replace(" ", "_")
        status = self._normalize_status(todo_task.get("status", "NOT STARTED"))

        entry = {
            "project_number": task_num,
            "project_name": slug,
            "type": "feature",
            "phase": status,
            "status": status,
            "priority": todo_task.get("priority", "Medium").lower(),
            "language": todo_task.get("language", "general"),
            "description": todo_task.get("description", ""),
            "effort": todo_task.get("effort", "TBD"),
            "blocking": [],
            "dependencies": [],
            "created": datetime.now().isoformat(),
            "last_updated": datetime.now().isoformat(),
        }

        state_data["active_projects"].append(entry)

        with open(self.state_path, "w") as f:
            json.dump(state_data, f, indent=2)

        print(f"✓ Added task {task_num} to state.json")


def print_report(issues: List[Issue], detailed: bool = False):
    """Print validation report"""
    if not issues:
        print("\n✓ No inconsistencies found")
        print("✓ state.json and TODO.md are perfectly synchronized")
        return

    # Group by severity
    critical = [i for i in issues if i.severity == Severity.CRITICAL]
    warnings = [i for i in issues if i.severity == Severity.WARNING]
    info = [i for i in issues if i.severity == Severity.INFO]

    print(f"\nFound {len(issues)} inconsistencies:")
    print(f"  - {len(critical)} CRITICAL")
    print(f"  - {len(warnings)} WARNING")
    print(f"  - {len(info)} INFO")
    print()

    # Print critical issues
    if critical:
        print("CRITICAL Issues:")
        for issue in critical:
            print(f"  ✗ {issue.message}")
            if detailed and issue.fix_available:
                print(f"    Fix: {issue.fix_description}")
        print()

    # Print warnings
    if warnings:
        print("WARNING Issues:")
        for issue in warnings:
            print(f"  ⚠ {issue.message}")
            if detailed and issue.fix_available:
                print(f"    Fix: {issue.fix_description}")
        print()

    # Print info
    if info and detailed:
        print("INFO:")
        for issue in info:
            print(f"  ℹ {issue.message}")
        print()

    # Print fix availability
    fixable = [i for i in issues if i.fix_available]
    if fixable:
        print(f"{len(fixable)} issues can be automatically fixed")
        print("Run with --fix to repair automatically")


def main():
    parser = argparse.ArgumentParser(
        description="Validate consistency between state.json and TODO.md"
    )
    parser.add_argument(
        "--fix", action="store_true", help="Repair issues automatically"
    )
    parser.add_argument(
        "--auto",
        action="store_true",
        help="Auto-repair without prompts (requires --fix)",
    )
    parser.add_argument("--report", action="store_true", help="Show detailed report")
    parser.add_argument(
        "--specs-dir",
        type=Path,
        default=Path("specs"),
        help="Path to specs directory (default: specs)",
    )

    args = parser.parse_args()

    # Validate specs directory
    if not args.specs_dir.exists():
        print(f"Error: Specs directory not found: {args.specs_dir}")
        sys.exit(1)

    # Create validator
    validator = StateValidator(args.specs_dir)

    # Run validation
    print("Checking state.json ↔ TODO.md consistency...")
    issues = validator.validate()

    # Print report
    print_report(issues, detailed=args.report)

    # Repair if requested
    if args.fix:
        if issues:
            validator.repair(auto=args.auto)
        else:
            print("\nNo issues to fix")

    # Exit with appropriate code
    critical_issues = [i for i in issues if i.severity == Severity.CRITICAL]
    sys.exit(1 if critical_issues else 0)


if __name__ == "__main__":
    main()
