import json
import re
import sys
from datetime import datetime

session_id = "sess_1768531000_research504"
task_number = 504
new_status = "researched"
timestamp = "2026-01-15"
new_artifacts = [
    {
        "type": "research",
        "path": ".opencode/specs/504_aristotle_integration/reports/research-001.md",
        "summary": "Detailed research on Harmonic Aristotle MCP integration and best practices",
    },
    {
        "type": "summary",
        "path": ".opencode/specs/504_aristotle_integration/summaries/research-summary.md",
        "summary": "Brief overview of Aristotle API integration findings",
    },
]

# Read files
with open(".opencode/specs/TODO.md", "r") as f:
    todo_content = f.read()

with open(".opencode/specs/state.json", "r") as f:
    state_content = f.read()

# Update state.json
state_data = json.loads(state_content)
task_found = False
for project in state_data["active_projects"]:
    if project["project_number"] == task_number:
        task_found = True
        project["status"] = new_status
        project["phase"] = new_status
        project["last_updated"] = timestamp
        project["researched"] = timestamp

        # Add new artifacts
        existing_paths = [a.get("path") for a in project.get("artifacts", [])]
        for artifact in new_artifacts:
            if artifact["path"] not in existing_paths:
                project.setdefault("artifacts", []).append(artifact)
        break

if not task_found:
    print(f"Task {task_number} not found in state.json")
    sys.exit(1)

# Update TODO.md
# Regex to find the task block
# Matches ### 504. ... until the next ---
task_pattern = re.compile(
    r"(### " + str(task_number) + r"\..*?)(?=\n\n---|(?:\n### \d+\.))", re.DOTALL
)
match = task_pattern.search(todo_content)

if not match:
    print(f"Task {task_number} not found in TODO.md")
    sys.exit(1)

task_block = match.group(1)
new_task_block = task_block

# Update Status
new_task_block = re.sub(
    r"- \*\*Status\*\*: \[.*?\]",
    f"- **Status**: [{new_status.upper()}]",
    new_task_block,
)

# Update Researched timestamp
if re.search(r"- \*\*Researched\*\*:.*", new_task_block):
    new_task_block = re.sub(
        r"- \*\*Researched\*\*:.*", f"- **Researched**: {timestamp}", new_task_block
    )
else:
    # Insert after Session or Language
    new_task_block = re.sub(
        r"(- \*\*Session\*\*:.*)", f"\\1\n- **Researched**: {timestamp}", new_task_block
    )

# Update Artifacts
# Remove existing Research/Summary links if we are replacing them or just append?
# The prompt implies adding/updating.
# I'll replace the existing Research link if it exists, and add Summary.
for artifact in new_artifacts:
    art_type = artifact["type"].capitalize()
    art_path = artifact["path"]
    art_summary = artifact["summary"]

    link_line = f"- **{art_type}**: [{art_summary}]({art_path})"

    # Check if this type already exists
    if re.search(f"- \*\*{art_type}\*\*:.*", new_task_block):
        # Replace
        new_task_block = re.sub(f"- \*\*{art_type}\*\*:.*", link_line, new_task_block)
    else:
        # Append before Description
        new_task_block = re.sub(
            r"(?=\n\*\*Description\*\*:)", f"\n{link_line}", new_task_block
        )

# Replace the block in content
todo_content = todo_content.replace(task_block, new_task_block)

# Update frontmatter last_updated (optional but good practice)
# todo_content = re.sub(r"last_updated:.*", f"last_updated: {timestamp}", todo_content, count=1)

# Write temp files
with open(f".opencode/specs/TODO.md.tmp.{session_id}", "w") as f:
    f.write(todo_content)

with open(f".opencode/specs/state.json.tmp.{session_id}", "w") as f:
    json.dump(state_data, f, indent=2)

print("Temp files created successfully")
