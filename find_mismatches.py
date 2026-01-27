#!/usr/bin/env python3
"""Find status mismatches between TODO.md and state.json"""

import json
import re
from pathlib import Path

# Status mapping
STATUS_MAP = {
    "not_started": "[NOT STARTED]",
    "researching": "[RESEARCHING]",
    "researched": "[RESEARCHED]",
    "planning": "[PLANNING]",
    "planned": "[PLANNED]",
    "implementing": "[IMPLEMENTING]",
    "completed": "[COMPLETED]",
    "blocked": "[BLOCKED]",
    "abandoned": "[ABANDONED]",
    "partial": "[PARTIAL]",
    "expanded": "[EXPANDED]",
    "revised": "[REVISED]",
    "implemented": "[IMPLEMENTED]"  # Non-standard but present
}

def read_state_json():
    """Read state.json"""
    with open("specs/state.json") as f:
        return json.load(f)

def parse_todo_md():
    """Parse TODO.md to extract task statuses"""
    with open("specs/TODO.md") as f:
        content = f.read()

    tasks = {}
    # Match task entries like: ### 691. Title
    pattern = r'###\s+(\d+)\.\s+([^\n]+)\n((?:- \*\*[^:]+\*\*:[^\n]*\n)*)'

    for match in re.finditer(pattern, content):
        task_num = int(match.group(1))
        task_title = match.group(2).strip()
        metadata = match.group(3)

        # Extract status
        status_match = re.search(r'- \*\*Status\*\*:\s*\[([^\]]+)\]', metadata)
        if status_match:
            status = status_match.group(1)
            tasks[task_num] = status

    return tasks

def main():
    state = read_state_json()
    todo_statuses = parse_todo_md()

    mismatches = []

    for project in state['active_projects']:
        task_num = project['project_number']
        state_status = project['status']

        if task_num in todo_statuses:
            todo_status = todo_statuses[task_num]
            expected_todo = STATUS_MAP.get(state_status, f"[{state_status.upper()}]")

            if f"[{todo_status}]" != expected_todo:
                mismatches.append({
                    'task': task_num,
                    'todo_status': todo_status,
                    'state_status': state_status,
                    'expected_todo': expected_todo
                })

    if mismatches:
        print(f"Found {len(mismatches)} status mismatches:\n")
        for m in mismatches:
            print(f"Task {m['task']}:")
            print(f"  TODO.md:    [{m['todo_status']}]")
            print(f"  state.json: {m['state_status']}")
            print(f"  Should be:  {m['expected_todo']}")
            print()
    else:
        print("No mismatches found!")

    return mismatches

if __name__ == "__main__":
    mismatches = main()
    exit(0 if not mismatches else 1)
