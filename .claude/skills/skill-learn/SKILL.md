---
name: skill-learn
description: Scan codebase for FIX:/NOTE:/TODO: tags and create structured tasks. Invoke for /learn command.
allowed-tools: Task, Bash, Edit, Read, Write
---

# Learn Skill

Thin wrapper that delegates tag extraction and task creation to `learn-agent` subagent. This skill handles scanning files for embedded tags and creating appropriate tasks based on tag types.

**IMPORTANT**: This skill implements the skill-internal postflight pattern. After the subagent returns, this skill handles all postflight operations (git commit if tasks created) before returning. This eliminates the "continue" prompt issue between skill return and orchestrator.

## Context References

Reference (do not load eagerly):
- Path: `.claude/context/core/formats/return-metadata-file.md` - Metadata file schema
- Path: `.claude/context/core/patterns/postflight-control.md` - Marker file protocol
- Path: `.claude/context/core/patterns/file-metadata-exchange.md` - File I/O helpers

Note: This skill is a thin wrapper with internal postflight. Context is loaded by the delegated agent.

## Trigger Conditions

This skill activates when:
- /learn command is invoked (with any arguments)
- User requests tag scanning for task creation

---

## Execution

### 1. Input Validation

Parse arguments and determine mode:

**Mode Detection Logic**:
```bash
# Parse arguments
args="$ARGUMENTS"

# Check for dry-run flag
if [[ "$args" == *"--dry-run"* ]]; then
  mode="dry_run"
  # Remove --dry-run from args to get paths
  paths=$(echo "$args" | sed 's/--dry-run//g' | xargs)
else
  mode="execute"
  paths="$args"
fi

# Default to project root if no paths specified
if [ -z "$paths" ]; then
  paths="."
fi
```

### 2. Context Preparation

Prepare delegation context:

```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "learn", "skill-learn"],
  "timeout": 3600,
  "mode": "execute|dry_run",
  "paths": ["{path1}", "{path2}", "..."],
  "metadata_file_path": ".claude/.return-meta-learn.json"
}
```

### 3. Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool to spawn the subagent.

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "learn-agent"
  - prompt: [Include mode, paths, delegation_context]
  - description: "Scan for tags and create tasks (mode: {mode})"
```

**DO NOT** use `Skill(learn-agent)` - this will FAIL.
Agents live in `.claude/agents/`, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.

The subagent will:
- Scan specified paths for FIX:/NOTE:/TODO: tags
- Group tags by type and context
- Create fix-it, learn-it, and todo tasks (if not dry-run)
- Write metadata file with results
- Return brief text summary

### 4. Postflight Operations

After subagent returns, this skill handles postflight:

**Read Metadata File**:
```bash
metadata=$(cat .claude/.return-meta-learn.json)
status=$(echo "$metadata" | jq -r '.status')
tasks_created=$(echo "$metadata" | jq -r '.metadata.tasks_created // 0')
```

**Git Commit (if tasks created)**:
```bash
if [ "$status" = "tasks_created" ] && [ "$tasks_created" -gt 0 ]; then
  git add specs/TODO.md specs/state.json
  git commit -m "learn: create $tasks_created tasks from tags

Session: $session_id

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
fi
```

**Cleanup**:
```bash
rm -f .claude/.return-meta-learn.json
```

### 5. Return Propagation

Return validated result to caller based on mode:

**Execute mode (tasks created)**:
- Display created tasks with details
- Show next steps

**Dry-run mode**:
- Display tag summary
- Show preview of tasks that would be created

**No tags found**:
- Report gracefully
- No error status needed

---

## Return Format

See `.claude/context/core/formats/subagent-return.md` for full specification.

### Expected Return: Tasks Created

```json
{
  "status": "tasks_created",
  "summary": "Created 5 tasks from 12 tags across 8 files: 1 fix-it, 1 learn-it, 3 todo tasks.",
  "artifacts": [
    {
      "type": "task_entry",
      "path": "specs/TODO.md",
      "summary": "Tasks #650-654 added"
    }
  ],
  "metadata": {
    "session_id": "sess_1736700000_abc123",
    "agent_type": "learn-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "learn", "learn-agent"],
    "mode": "execute",
    "tags_found": {
      "fix": 3,
      "note": 4,
      "todo": 5
    },
    "tasks_created": 5
  },
  "next_steps": "Run /research 650 to begin research on first task"
}
```

### Expected Return: Dry Run

```json
{
  "status": "preview",
  "summary": "Found 12 tags across 8 files. Would create 5 tasks: 1 fix-it, 1 learn-it, 3 todo.",
  "artifacts": [],
  "metadata": {
    "session_id": "sess_1736700000_xyz789",
    "agent_type": "learn-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "learn", "learn-agent"],
    "mode": "dry_run",
    "tags_found": {
      "fix": 3,
      "note": 4,
      "todo": 5
    },
    "tasks_preview": 5
  },
  "next_steps": "Run /learn without --dry-run to create tasks"
}
```

### Expected Return: No Tags Found

```json
{
  "status": "no_tags",
  "summary": "No FIX:, NOTE:, or TODO: tags found in scanned files.",
  "artifacts": [],
  "metadata": {
    "session_id": "sess_1736700000_def456",
    "agent_type": "learn-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "learn", "learn-agent"],
    "mode": "execute",
    "files_scanned": 42,
    "tags_found": {
      "fix": 0,
      "note": 0,
      "todo": 0
    }
  },
  "next_steps": "No action needed"
}
```

---

## Error Handling

### Input Validation Errors
Return immediately with failed status if paths are invalid.

### Subagent Errors
Pass through the subagent's error return verbatim.

### Git Commit Failure
Log error (non-blocking), tasks are still created successfully.

### Path Access Errors
Report which paths could not be accessed, continue with accessible paths.
