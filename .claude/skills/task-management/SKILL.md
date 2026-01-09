---
name: task-management
description: Create, divide, recover, and manage task lifecycle. Invoke for /task command operations.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*)
context: fork
---

# Task Management Skill

Handle task lifecycle operations: create, divide, recover, sync, abandon.

## Trigger Conditions

This skill activates when:
- /task command is invoked
- Task entries need to be created or modified
- Task lifecycle operations are needed

## Operations

### Create Task

Create a new task entry from description.

**Inputs**:
- description: Task description
- priority: Optional (default: medium)
- effort: Optional estimate
- language: Optional (auto-detected)

**Steps**:
1. Read state.json for next_project_number
2. Detect language from keywords
3. Create slug from description
4. Create task directory
5. Add to state.json active_projects
6. Add to TODO.md under priority section
7. Git commit

**Language Detection**:
```
lean, theorem, proof, lemma, Mathlib → lean
meta, agent, command, skill, workflow → meta
Otherwise → general
```

**Slug Creation**:
```
1. Lowercase
2. Replace spaces with underscores
3. Remove special characters
4. Max 50 characters
```

### Divide Task

Split existing task into subtasks.

**Inputs**:
- task_number: Task to divide
- prompt: Optional guidance

**Steps**:
1. Read task from state.json
2. Analyze description for breakpoints
3. Create 2-5 subtasks
4. Link subtasks to parent
5. Update parent task
6. Git commit

### Recover Task

Restore archived task(s).

**Inputs**:
- task_ranges: "343", "343-345", "337, 343-345"

**Steps**:
1. Parse task ranges
2. Find in archive/state.json
3. Move to active_projects
4. Add back to TODO.md
5. Reset status to not_started
6. Git commit

### Sync Tasks

Reconcile TODO.md and state.json.

**Inputs**:
- task_ranges: Optional (all if omitted)

**Steps**:
1. Read both files
2. Compare entries
3. Use git blame for conflicts
4. Update to match latest
5. Log changes made
6. Git commit

### Abandon Task

Archive task(s) as abandoned.

**Inputs**:
- task_ranges: Tasks to abandon

**Steps**:
1. Parse task ranges
2. Move from active to archive
3. Update TODO.md status
4. Optionally move directory
5. Git commit

## Task Entry Formats

### state.json Entry
```json
{
  "project_number": N,
  "project_name": "slug",
  "status": "not_started",
  "language": "lean|general|meta",
  "priority": "high|medium|low",
  "effort": "estimate",
  "created": "ISO_DATE",
  "last_updated": "ISO_DATE",
  "description": "Full description"
}
```

### TODO.md Entry
```markdown
### {N}. {Title}
- **Effort**: {estimate}
- **Status**: [NOT STARTED]
- **Priority**: {priority}
- **Language**: {language}

**Description**: {description}
```

## Execution Flow

```
1. Parse operation type from arguments
2. Validate inputs
3. Execute operation-specific steps
4. Update state.json
5. Update TODO.md
6. Create git commit
7. Return result
```

## Return Format

### Create
```json
{
  "status": "completed",
  "summary": "Created task #{N}: {title}",
  "task_number": N,
  "language": "detected",
  "path": ".opencode/specs/{N}_{SLUG}/"
}
```

### Divide
```json
{
  "status": "completed",
  "summary": "Divided task #{N} into {M} subtasks",
  "parent_task": N,
  "subtasks": [N+1, N+2, N+3]
}
```

### Recover
```json
{
  "status": "completed",
  "summary": "Recovered {N} tasks",
  "recovered": [343, 344, 345]
}
```

### Sync
```json
{
  "status": "completed",
  "summary": "Synced {N} tasks",
  "changes": [
    {"task": N, "field": "status", "from": "x", "to": "y"}
  ]
}
```

### Abandon
```json
{
  "status": "completed",
  "summary": "Abandoned {N} tasks",
  "abandoned": [343, 344]
}
```

## Constraints

**FORBIDDEN for Create**:
- Implementing tasks
- Creating code files
- Running build tools
- Modifying source code

Task creation ONLY creates task entries. Implementation happens via /implement.
