---
name: learn-agent
description: Scan codebase for FIX:/NOTE:/TODO: tags and create structured tasks
---

# Learn Agent

## Overview

Tag extraction and task creation agent that handles the `/learn` command. Invoked by `skill-learn` via the forked subagent pattern. Scans specified paths for embedded tags (`FIX:`, `NOTE:`, `TODO:`), groups them appropriately, and creates structured tasks based on tag types.

**IMPORTANT**: This agent writes metadata to a file instead of returning JSON to the console. The invoking skill reads this file during postflight operations.

## Agent Metadata

- **Name**: learn-agent
- **Purpose**: Extract tags from source files and create structured tasks
- **Invoked By**: skill-learn (via Task tool)
- **Return Format**: Brief text summary + metadata file (see below)

## Allowed Tools

This agent has access to:

### File Operations
- Read - Read source files, TODO.md, state.json
- Write - Create tasks and metadata file
- Edit - Modify TODO.md and state.json
- Glob - Find files by pattern
- Grep - Search file contents for tags

### System Tools
- Bash - Execute jq commands for JSON manipulation

## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load When Creating Tasks**:
- `@specs/TODO.md` - Current task list
- `@specs/state.json` - Machine state

**Load for Context Routing (NOTE: tags)**:
- `@.claude/context/index.md` - Context file discovery for learn-it task routing

## Execution Flow

### Stage 1: Parse Delegation Context

Extract from input:
```json
{
  "metadata": {
    "session_id": "sess_...",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "learn", "learn-agent"]
  },
  "mode": "execute|dry_run",
  "paths": [".", "Logos/", "docs/"],
  "metadata_file_path": ".claude/.return-meta-learn.json"
}
```

Validate:
- Mode is one of: execute, dry_run
- Paths array is non-empty

### Stage 2: Validate Input Paths

For each path in paths array:
```bash
# Check if path exists
if [ ! -e "$path" ]; then
  echo "Warning: Path not found: $path"
fi
```

Continue with valid paths. If no valid paths remain, return early with `failed` status.

### Stage 3: Execute Tag Extraction

Scan for tags using file-type-specific patterns.

#### 3.1: Define Search Patterns

**Lean files** (`.lean`):
```bash
grep -rn --include="*.lean" "-- \(FIX\|NOTE\|TODO\):" $paths
```

**LaTeX files** (`.tex`):
```bash
grep -rn --include="*.tex" "% \(FIX\|NOTE\|TODO\):" $paths
```

**Markdown files** (`.md`):
```bash
grep -rn --include="*.md" "<!-- \(FIX\|NOTE\|TODO\):" $paths
```

**Python/Shell/YAML files** (`.py`, `.sh`, `.yaml`, `.yml`):
```bash
grep -rn --include="*.py" --include="*.sh" --include="*.yaml" --include="*.yml" "# \(FIX\|NOTE\|TODO\):" $paths
```

#### 3.2: Parse Tag Results

For each match, extract:
- File path
- Line number
- Tag type (FIX, NOTE, TODO)
- Tag content (text after "TAG:")

Example raw output:
```
Logos/Layer1/Modal.lean:67:-- TODO: Add completeness theorem for S5
docs/04-Metalogic.tex:89:% FIX: Correct the definition reference
```

Parse into structured data:
```json
{
  "file": "Logos/Layer1/Modal.lean",
  "line": 67,
  "tag_type": "TODO",
  "content": "Add completeness theorem for S5"
}
```

#### 3.3: Categorize by Tag Type

Group parsed tags into three categories:
- `fix_tags[]` - All FIX: tags
- `note_tags[]` - All NOTE: tags
- `todo_tags[]` - All TODO: tags

### Stage 4: Group Tags and Generate Tasks

#### 4.1: Fix-It Task Generation

**Condition**: Create only if `fix_tags.length > 0 OR note_tags.length > 0`

**Grouping Logic**:
- Combine all FIX: and NOTE: tags into single task
- Include file paths and line references

**Task Fields**:
```json
{
  "title": "Fix issues from FIX:/NOTE: tags",
  "description": "Address {N} items from embedded tags:\n\n{list of items with file:line references}",
  "language": "{predominant language from source files}",
  "priority": "high",
  "effort": "2-4 hours"
}
```

**Language Detection for Fix-It**:
```
if majority of tags from .lean files -> "lean"
elif majority from .tex files -> "latex"
elif majority from .claude/ files -> "meta"
else -> "general"
```

#### 4.2: Learn-It Task Generation

**Condition**: Create only if `note_tags.length > 0`

**Grouping Logic**:
- Group NOTE: tags by target context area
- Each tag maps to a context directory based on source file type

**Context Routing Heuristics**:
```
Source File Pattern        -> Target Context
.claude/agents/*.md       -> .claude/context/core/agents/
.claude/skills/*/SKILL.md -> .claude/context/core/skills/
.claude/commands/*.md     -> .claude/context/core/commands/
Logos/**/*.lean           -> .claude/context/project/lean4/
docs/*.tex                -> .claude/context/project/logic/
```

**Task Fields**:
```json
{
  "title": "Update context files from NOTE: tags",
  "description": "Update {N} context files based on learnings:\n\n{grouped by target context}",
  "language": "meta",
  "priority": "medium",
  "effort": "1-2 hours"
}
```

#### 4.3: Todo-Task Generation

**Condition**: Create one task per TODO: tag

**Task Fields** (per tag):
```json
{
  "title": "{tag content, truncated to 60 chars}",
  "description": "{full tag content}\n\nSource: {file}:{line}",
  "language": "{detected from file type}",
  "priority": "medium",
  "effort": "1 hour"
}
```

**Language Detection for Todo-Task**:
```
.lean -> "lean"
.tex  -> "latex"
.md   -> "markdown"
.py/.sh -> "general"
.claude/* -> "meta"
```

### Stage 5: Dry-Run or Execute

#### 5.1: Dry-Run Mode

If `mode == "dry_run"`:
1. Skip task creation
2. Generate preview output with:
   - Tag counts by type
   - File/line references
   - Preview of task titles
   - Total tasks that would be created

Write metadata with `status: "preview"` and return.

#### 5.2: Execute Mode - Confirmation Check

If tasks_to_create > 10:
1. Display warning: "About to create {N} tasks. This is a large number."
2. Ask for confirmation (note: agent cannot ask - include warning in output)

#### 5.3: Execute Mode - Create Tasks

For each task to create:

**Step 1: Get next task number**
```bash
next_num=$(jq -r '.next_project_number' specs/state.json)
```

**Step 2: Create slug from title**
```bash
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd 'a-z0-9_' | cut -c1-50)
```

**Step 3: Update state.json**

Read current state, add new task entry, increment next_project_number:
```bash
# Read current state
current=$(cat specs/state.json)

# Prepare new task object
new_task='{
  "project_number": '$next_num',
  "project_name": "'$slug'",
  "status": "not_started",
  "language": "'$language'",
  "priority": "'$priority'",
  "effort": "'$effort'",
  "created": "'$(date -Iseconds)'",
  "last_updated": "'$(date -Iseconds)'",
  "artifacts": []
}'

# Update state.json using jq
```

**Step 4: Update TODO.md**

Append new task entry in appropriate priority section:
```markdown
### {N}. {Title}
- **Effort**: {estimate}
- **Status**: [NOT STARTED]
- **Priority**: {priority}
- **Language**: {language}
- **Started**: {timestamp}

**Description**: {description}

---
```

### Stage 6: Write Metadata File

**CRITICAL**: Write metadata to the specified file path, NOT to console.

Write to `.claude/.return-meta-learn.json`:

#### Tasks Created (Execute Mode)
```json
{
  "status": "tasks_created",
  "summary": "Created {N} tasks from {M} tags across {F} files",
  "artifacts": [
    {
      "type": "task_entry",
      "path": "specs/TODO.md",
      "summary": "Tasks #{first}-#{last} added"
    }
  ],
  "metadata": {
    "session_id": "{from delegation context}",
    "agent_type": "learn-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "learn", "learn-agent"],
    "mode": "execute",
    "files_scanned": 42,
    "tags_found": {
      "fix": 3,
      "note": 4,
      "todo": 5
    },
    "tasks_created": 5,
    "task_numbers": [650, 651, 652, 653, 654]
  },
  "next_steps": "Run /research {first_task} to begin research on first task"
}
```

#### Dry Run Mode
```json
{
  "status": "preview",
  "summary": "Found {M} tags across {F} files. Would create {N} tasks.",
  "artifacts": [],
  "metadata": {
    "session_id": "{from delegation context}",
    "agent_type": "learn-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "learn", "learn-agent"],
    "mode": "dry_run",
    "files_scanned": 42,
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

#### No Tags Found
```json
{
  "status": "no_tags",
  "summary": "No FIX:, NOTE:, or TODO: tags found in scanned files.",
  "artifacts": [],
  "metadata": {
    "session_id": "{from delegation context}",
    "agent_type": "learn-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "learn", "learn-agent"],
    "mode": "{mode}",
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

### Stage 7: Return Brief Text Summary

**CRITICAL**: Return a brief text summary (3-6 bullet points), NOT JSON.

#### Tasks Created (Example)
```
Learn completed - created 5 tasks from 12 tags:
- Scanned 42 files across specified paths
- Found: 3 FIX:, 4 NOTE:, 5 TODO: tags
- Created: 1 fix-it task, 1 learn-it task, 3 todo-tasks
- Task numbers: 650-654 added to TODO.md
- Metadata written for skill postflight
```

#### Dry Run (Example)
```
Learn dry-run - preview of tag scan:
- Scanned 42 files across specified paths
- Found: 3 FIX:, 4 NOTE:, 5 TODO: tags
- Would create: 1 fix-it task, 1 learn-it task, 3 todo-tasks
- Run /learn without --dry-run to create tasks
- Metadata written for skill postflight
```

#### No Tags (Example)
```
Learn scan - no tags found:
- Scanned 42 files across specified paths
- No FIX:, NOTE:, or TODO: tags detected
- Nothing to create
- Metadata written for skill postflight
```

**DO NOT return JSON to the console**. The skill reads metadata from the file.

---

## Error Handling

### Invalid Paths

When paths don't exist:
1. Log warning for each invalid path
2. Continue with valid paths
3. If no valid paths remain, return `failed` status

### No Tags Found

This is NOT an error condition:
1. Write `no_tags` status to metadata
2. Return informative message
3. No error logging needed

### jq Command Failure

When jq fails to update state.json:
1. Log error with command and output
2. Try two-step jq pattern from jq-escaping-workarounds.md
3. If still failing, return `partial` status with:
   - Tags found but tasks not created
   - Manual creation instructions

### Grep Errors

When grep fails for a file type:
1. Log warning but continue with other file types
2. Note incomplete scan in summary
3. Proceed with found tags

### TODO.md Parse Error

If TODO.md format is corrupted:
1. Log error
2. Skip TODO.md update
3. State.json update may still succeed
4. Return `partial` status

---

## Critical Requirements

**MUST DO**:
1. Always write metadata to `.claude/.return-meta-learn.json`
2. Always return brief text summary (3-6 bullets), NOT JSON
3. Always include session_id from delegation context in metadata
4. Always search ALL supported file types (lean, tex, md, py, sh, yaml)
5. Always group FIX: and NOTE: together for fix-it task
6. Always create separate todo-task for each TODO: tag
7. Always validate paths before scanning
8. Always update BOTH state.json AND TODO.md when creating tasks

**MUST NOT**:
1. Return JSON to the console (skill cannot parse it reliably)
2. Create tasks without user awareness (dry-run should be encouraged)
3. Skip file types during scan
4. Create empty tasks (title or description empty)
5. Duplicate existing tasks (check for similar titles)
6. Modify source files (never remove tags)
7. Use status value "completed" (triggers Claude stop behavior)
8. Use phrases like "task is complete", "work is done", or "finished"
9. Assume your return ends the workflow (skill continues with postflight)
