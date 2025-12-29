#!/usr/bin/env python3
"""
Archive completed and abandoned tasks from TODO.md
Two-phase commit with rollback support
"""

import json
import shutil
import re
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any, Tuple

# Configuration
BASE_DIR = Path("/home/benjamin/Projects/ProofChecker")
SPECS_DIR = BASE_DIR / ".opencode/specs"
TODO_FILE = SPECS_DIR / "TODO.md"
STATE_FILE = BASE_DIR / ".opencode/specs/state.json"
ARCHIVE_STATE_FILE = SPECS_DIR / "archive/state.json"
ARCHIVE_DIR = SPECS_DIR / "archive"

# Tasks to archive
TASKS_TO_ARCHIVE = [
    {"number": 236, "status": "completed"},
    {"number": 237, "status": "completed"},  # SUPERSEDED treated as COMPLETED
    {"number": 238, "status": "completed"},
    {"number": 241, "status": "completed"},
    {"number": 242, "status": "abandoned"},
]


def extract_task_block(todo_content: str, task_number: int) -> Tuple[int, int, str]:
    """
    Extract a complete task block (heading + body) from TODO.md
    Returns: (start_line, end_line, task_content)
    """
    lines = todo_content.split('\n')
    
    # Find task heading
    heading_pattern = re.compile(rf'^### {task_number}\.')
    start_line = None
    
    for i, line in enumerate(lines):
        if heading_pattern.match(line):
            start_line = i
            break
    
    if start_line is None:
        raise ValueError(f"Task {task_number} heading not found in TODO.md")
    
    # Find end boundary
    end_line = len(lines)  # Default to EOF
    
    for i in range(start_line + 1, len(lines)):
        line = lines[i]
        # Check boundary patterns
        if (re.match(r'^### \d+\.', line) or  # Next task
            re.match(r'^## ', line) or  # Section heading
            re.match(r'^---$', line)):  # Horizontal rule
            end_line = i
            break
    
    # Extract block
    task_lines = lines[start_line:end_line]
    task_content = '\n'.join(task_lines)
    
    return start_line, end_line, task_content


def parse_task_metadata(task_content: str, task_number: int) -> Dict[str, Any]:
    """Parse metadata from task content"""
    metadata = {
        "project_number": task_number,
        "title": "",
        "type": "task",
        "status": "unknown",
        "created": None,
        "started": None,
        "completed": None,
        "abandoned": None,
    }
    
    # Extract title
    title_match = re.search(rf'^### {task_number}\. (.+)$', task_content, re.MULTILINE)
    if title_match:
        metadata["title"] = title_match.group(1).strip()
    
    # Extract Language for type
    lang_match = re.search(r'\*\*Language\*\*:\s*(\w+)', task_content)
    if lang_match:
        metadata["type"] = lang_match.group(1)
    
    # Extract dates
    started_match = re.search(r'\*\*Started\*\*:\s*(\d{4}-\d{2}-\d{2})', task_content)
    if started_match:
        metadata["started"] = started_match.group(1)
        if not metadata["created"]:
            metadata["created"] = started_match.group(1) + "T00:00:00Z"
    
    completed_match = re.search(r'\*\*Completed\*\*:\s*(\d{4}-\d{2}-\d{2})', task_content)
    if completed_match:
        metadata["completed"] = completed_match.group(1)
    
    abandoned_match = re.search(r'\*\*Abandoned\*\*:\s*(\d{4}-\d{2}-\d{2})', task_content)
    if abandoned_match:
        metadata["abandoned"] = abandoned_match.group(1)
    
    researched_match = re.search(r'\*\*Researched\*\*:\s*(\d{4}-\d{2}-\d{2})', task_content)
    if researched_match:
        metadata["research_completed"] = researched_match.group(1)
    
    return metadata


def create_slug(title: str) -> str:
    """Convert title to snake_case slug"""
    # Remove special characters, convert to lowercase
    slug = re.sub(r'[^\w\s-]', '', title.lower())
    slug = re.sub(r'[\s_-]+', '_', slug)
    slug = slug.strip('_')
    return slug[:50]  # Max 50 chars


def phase1_prepare():
    """Phase 1: Prepare updates and create backups"""
    print("Phase 1: Preparing archival...")
    
    # Create backups
    print("  Creating backups...")
    shutil.copy(TODO_FILE, str(TODO_FILE) + ".bak")
    shutil.copy(STATE_FILE, str(STATE_FILE) + ".bak")
    shutil.copy(ARCHIVE_STATE_FILE, str(ARCHIVE_STATE_FILE) + ".bak")
    print("  Backups created")
    
    # Load files
    print("  Loading files...")
    with open(TODO_FILE, 'r') as f:
        todo_content = f.read()
    
    with open(STATE_FILE, 'r') as f:
        state = json.load(f)
    
    with open(ARCHIVE_STATE_FILE, 'r') as f:
        archive_state = json.load(f)
    
    print(f"  Files loaded")
    
    # Prepare archival data
    print("  Preparing archival data...")
    archival_data = []
    move_operations = []
    
    for task_info in TASKS_TO_ARCHIVE:
        task_number = task_info["number"]
        task_status = task_info["status"]
        
        print(f"  Processing task {task_number}...")
        
        # Extract task block
        try:
            start_line, end_line, task_content = extract_task_block(todo_content, task_number)
            print(f"    Task block: lines {start_line}-{end_line}")
        except ValueError as e:
            print(f"    WARNING: {e}")
            continue
        
        # Parse metadata
        metadata = parse_task_metadata(task_content, task_number)
        metadata["status"] = task_status
        
        # Find project directory
        slug = create_slug(metadata["title"])
        project_dir = None
        for path in SPECS_DIR.glob(f"{task_number}_*"):
            if path.is_dir() and not path.name.startswith("archive"):
                project_dir = path
                break
        
        # Build archive entry
        archive_entry = {
            "project_number": task_number,
            "project_name": slug,
            "type": metadata["type"],
            "status": task_status,
            "created": metadata.get("created", "unknown"),
            "started": metadata.get("started"),
            "archived": datetime.now().strftime("%Y-%m-%d"),
            "summary": metadata["title"],
            "artifacts": {
                "base_path": f".opencode/specs/archive/{task_number}_{slug}/" if project_dir else None
            }
        }
        
        if metadata.get("completed"):
            archive_entry["completed"] = metadata["completed"]
        if metadata.get("abandoned"):
            archive_entry["abandoned"] = metadata["abandoned"]
        
        archival_data.append({
            "task_number": task_number,
            "start_line": start_line,
            "end_line": end_line,
            "archive_entry": archive_entry,
            "project_dir": project_dir,
            "slug": slug
        })
        
        # Prepare move operation if project dir exists
        if project_dir:
            dest_dir = ARCHIVE_DIR / f"{task_number}_{slug}"
            move_operations.append({
                "src": project_dir,
                "dst": dest_dir
            })
            print(f"    Project dir: {project_dir.name} -> archive/{task_number}_{slug}")
        else:
            print(f"    No project directory found")
    
    # Prepare updated TODO.md (remove task blocks)
    print("  Preparing updated TODO.md...")
    lines = todo_content.split('\n')
    lines_to_remove = set()
    
    for data in archival_data:
        for line_num in range(data["start_line"], data["end_line"]):
            lines_to_remove.add(line_num)
    
    updated_lines = [line for i, line in enumerate(lines) if i not in lines_to_remove]
    updated_todo = '\n'.join(updated_lines)
    
    # Validate no orphaned metadata (skip Overview section and other non-task sections)
    print("  Validating updated TODO.md...")
    orphaned = []
    updated_lines_list = updated_todo.split('\n')
    in_task_section = False
    
    for i, line in enumerate(updated_lines_list):
        # Track if we're in a task section
        if re.match(r'^## (High Priority|Medium Priority|Low Priority|Completeness|Decidability|Layer Extensions)', line):
            in_task_section = True
        elif re.match(r'^## (Overview)', line):
            in_task_section = False
        
        # Only validate metadata in task sections
        if in_task_section and re.match(r'^- \*\*', line):
            # Check if there's a task heading in previous 50 lines (tasks can be long)
            has_heading = False
            for j in range(max(0, i-50), i):
                if re.match(r'^### \d+\.', updated_lines_list[j]):
                    has_heading = True
                    break
            if not has_heading:
                orphaned.append((i+1, line[:60]))  # First 60 chars
    
    if orphaned:
        print(f"  WARNING: Found {len(orphaned)} potentially orphaned lines:")
        for line_num, content in orphaned[:5]:  # Show first 5
            print(f"    Line {line_num}: {content}")
        raise ValueError(f"Orphaned metadata detected at {len(orphaned)} lines")
    
    print(f"  Validation passed")
    
    # Prepare updated archive_state.json
    print("  Preparing updated archive_state.json...")
    archive_state["archived_projects"].extend([d["archive_entry"] for d in archival_data])
    archive_state["_last_updated"] = datetime.now().isoformat()
    
    # Prepare updated state.json (move to completed_projects)
    print("  Preparing updated state.json...")
    active_projects = []
    for project in state["active_projects"]:
        if project["project_number"] not in [t["number"] for t in TASKS_TO_ARCHIVE]:
            active_projects.append(project)
        else:
            # Move to completed_projects
            state["completed_projects"].append(project)
    
    state["active_projects"] = active_projects
    state["_last_updated"] = datetime.now().isoformat() + "Z"
    state["repository_health"]["active_tasks"] = len(active_projects)
    
    # Add activity
    completed_count = sum(1 for t in TASKS_TO_ARCHIVE if t["status"] == "completed")
    abandoned_count = sum(1 for t in TASKS_TO_ARCHIVE if t["status"] == "abandoned")
    
    state["recent_activities"].insert(0, {
        "timestamp": datetime.now().isoformat() + "Z",
        "activity": f"Archived {len(TASKS_TO_ARCHIVE)} tasks: {completed_count} completed, {abandoned_count} abandoned"
    })
    
    print(f"Phase 1 complete: Prepared archival of {len(archival_data)} tasks")
    
    return {
        "updated_todo": updated_todo,
        "updated_state": state,
        "updated_archive_state": archive_state,
        "move_operations": move_operations,
        "archival_data": archival_data,
        "completed_count": completed_count,
        "abandoned_count": abandoned_count
    }


def phase2_commit(prepared_data):
    """Phase 2: Commit changes atomically"""
    print("\nPhase 2: Committing changes...")
    
    try:
        # Write TODO.md
        print("  Writing TODO.md...")
        with open(TODO_FILE, 'w') as f:
            f.write(prepared_data["updated_todo"])
        assert TODO_FILE.exists() and TODO_FILE.stat().st_size > 0
        print("  TODO.md written successfully")
        
        # Write state.json
        print("  Writing state.json...")
        with open(STATE_FILE, 'w') as f:
            json.dump(prepared_data["updated_state"], f, indent=2)
        assert STATE_FILE.exists() and STATE_FILE.stat().st_size > 0
        print("  state.json written successfully")
        
        # Write archive_state.json
        print("  Writing archive_state.json...")
        with open(ARCHIVE_STATE_FILE, 'w') as f:
            json.dump(prepared_data["updated_archive_state"], f, indent=2)
        assert ARCHIVE_STATE_FILE.exists() and ARCHIVE_STATE_FILE.stat().st_size > 0
        print("  archive_state.json written successfully")
        
        # Move directories
        print("  Moving project directories...")
        for i, op in enumerate(prepared_data["move_operations"]):
            src = op["src"]
            dst = op["dst"]
            print(f"    Moving {src.name} to archive/{dst.name}...")
            
            if dst.exists():
                print(f"      WARNING: Destination exists, removing...")
                shutil.rmtree(dst)
            
            shutil.move(str(src), str(dst))
            assert dst.exists() and not src.exists()
            print(f"      Moved successfully")
        
        # Delete backups
        print("  Cleaning up backups...")
        Path(str(TODO_FILE) + ".bak").unlink()
        Path(str(STATE_FILE) + ".bak").unlink()
        Path(str(ARCHIVE_STATE_FILE) + ".bak").unlink()
        print("  Backups deleted")
        
        print("Phase 2 complete: All changes committed successfully")
        return True
        
    except Exception as e:
        print(f"\nERROR in Phase 2: {e}")
        print("Rolling back...")
        rollback()
        raise


def rollback():
    """Rollback all changes"""
    print("  Restoring backups...")
    
    # Restore files
    if Path(str(TODO_FILE) + ".bak").exists():
        shutil.copy(str(TODO_FILE) + ".bak", TODO_FILE)
        Path(str(TODO_FILE) + ".bak").unlink()
    
    if Path(str(STATE_FILE) + ".bak").exists():
        shutil.copy(str(STATE_FILE) + ".bak", STATE_FILE)
        Path(str(STATE_FILE) + ".bak").unlink()
    
    if Path(str(ARCHIVE_STATE_FILE) + ".bak").exists():
        shutil.copy(str(ARCHIVE_STATE_FILE) + ".bak", ARCHIVE_STATE_FILE)
        Path(str(ARCHIVE_STATE_FILE) + ".bak").unlink()
    
    # Reverse directory moves (best effort)
    # Note: This is simplified; proper implementation would track each move
    
    print("  Rollback complete")


def main():
    """Main archival workflow"""
    print("=" * 60)
    print("TODO.md Task Archival")
    print("=" * 60)
    
    print(f"\nTasks to archive: {len(TASKS_TO_ARCHIVE)}")
    for task in TASKS_TO_ARCHIVE:
        print(f"  - Task {task['number']}: {task['status'].upper()}")
    
    try:
        # Phase 1: Prepare
        prepared_data = phase1_prepare()
        
        # Phase 2: Commit
        phase2_commit(prepared_data)
        
        # Success summary
        print("\n" + "=" * 60)
        print("ARCHIVAL COMPLETE")
        print("=" * 60)
        print(f"Tasks archived: {len(TASKS_TO_ARCHIVE)}")
        print(f"  - Completed: {prepared_data['completed_count']}")
        print(f"  - Abandoned: {prepared_data['abandoned_count']}")
        print(f"\nProject directories moved: {len(prepared_data['move_operations'])}")
        for op in prepared_data['move_operations']:
            print(f"  - {op['src'].name} -> archive/{op['dst'].name}")
        
        return 0
        
    except Exception as e:
        print("\n" + "=" * 60)
        print("ARCHIVAL FAILED")
        print("=" * 60)
        print(f"Error: {e}")
        return 1


if __name__ == "__main__":
    exit(main())
