---
agent: project
description: "Manages the Lean 4 project"
---

Provides project management capabilities, such as checking status or organizing files.

**Request:** $ARGUMENTS

**Process:**
1. Analyzes the project structure and state.
2. If `--status` is provided, generates a report on proof progress, dependencies, and warnings.
3. If `--organize` is provided, restructures files and directories according to best practices.
4. If no options are provided, gives a general overview of the project.

**Syntax:**
```bash
/manage-project [--status|--organize]
```

**Options:**
- `--status`: Display the current project status.
- `--organize`: Organize the project files and directories.

**Examples:**

```bash
# Example 1: Getting the project status
/manage-project --status

# Example 2: Organizing the project files
/manage-project --organize

# Example 3: Getting a general overview
/manage-project
```

**Output:**
```markdown
## Lean Project Management Report

{Report content, depending on the option used}
```
