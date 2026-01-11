---
description: Create new version of implementation plan, or update task description if no plan exists
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), TodoWrite
argument-hint: TASK_NUMBER [REASON]
model: claude-opus-4-5-20251101
---

# /revise Command

Create a new version of an implementation plan, or update task description if no plan exists.

## Arguments

- `$1` - Task number (required)
- Remaining args - Optional reason for revision

## Execution

### 1. Parse and Validate

```
task_number = first token from $ARGUMENTS
revision_reason = remaining tokens (optional)
```

**Lookup task via jq** (see skill-status-sync for patterns):
```bash
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .claude/specs/state.json)

# Validate task exists
if [ -z "$task_data" ]; then
  echo "Error: Task $task_number not found in state.json"
  exit 1
fi

# Extract fields
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
```

### 2. Validate Status and Route

Check task status to determine behavior:

**If status in [planned, implementing, partial, blocked]:**
→ Continue to section 3 (Load Current Context) for plan revision

**If status in [not_started, researched]:**
→ Jump to section 2a (Description Update)

**If status is completed:**
→ Error "Task completed, no revision needed"

**If status is abandoned:**
→ Error "Task abandoned, use /task --recover first"

### 2a. Description Update (for tasks without plans)

When a task has no plan to revise, update the task description instead.

**Read current description:**
```bash
old_description=$(echo "$task_data" | jq -r '.description // ""')
```

**Construct new description:**
- If revision_reason is provided: Use it as the new description
- If no revision_reason: Error "No revision reason provided. Usage: /revise N \"new description\""

**Update state.json:**
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg desc "$new_description" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    description: $desc,
    last_updated: $ts
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

**Update TODO.md:**
Use Edit tool to replace the existing description:
```
old_string: "**Description**: {old_description}"
new_string: "**Description**: {new_description}"
```

Note: For multi-line descriptions, include enough context to uniquely identify the description block.

**Git commit:**
```bash
git add .claude/specs/
git commit -m "task {N}: revise description

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**Output:**
```
Description updated for Task #{N}

Previous: {old_description}
New: {new_description}

Status: [{current_status}]
```

**STOP** - Do not continue to plan revision sections.

### 3. Load Current Context

1. **Current plan** from .claude/specs/{N}_{SLUG}/plans/implementation-{LATEST}.md
   - Extract phase statuses (what's done, what's remaining)
   - Note which phases succeeded/failed

2. **Research reports** if any

3. **Implementation progress** - what was learned during partial implementation

### 4. Analyze What Changed

Compare original plan assumptions vs reality:
- What phases succeeded?
- What phases failed and why?
- What new information emerged?
- What dependencies weren't anticipated?

### 5. Create Revised Plan

Increment version: implementation-002.md, implementation-003.md, etc.

Write to `.claude/specs/{N}_{SLUG}/plans/implementation-{NEW_VERSION}.md`:

```markdown
# Implementation Plan: Task #{N}

**Task**: {title}
**Version**: {NEW_VERSION}
**Created**: {ISO_DATE}
**Revision of**: implementation-{PREV_VERSION}.md
**Reason**: {revision_reason or "Plan adjustment based on implementation feedback"}

## Revision Summary

{What changed from previous version and why}

### Previous Plan Status
- Phase 1: [COMPLETED] - {outcome}
- Phase 2: [PARTIAL] - {what happened}
- Phase 3: [NOT STARTED] - {now revised}

### Key Changes
1. {Change 1 and rationale}
2. {Change 2 and rationale}

## Overview

{Updated implementation approach}

## Phases

### Phase 1: {Name} [COMPLETED]
{Preserved from previous - already done}

### Phase 2: {Revised Name}
**Status**: [NOT STARTED]
**Estimated effort**: {revised estimate}

{Revised steps based on learnings}

### Phase 3: {New/Revised}
...

## Risks and Mitigations

{Updated based on experience}

## Success Criteria

{Potentially revised criteria}
```

### 6. Update Status

**Invoke skill-status-sync** for atomic update:
- task_number: {N}
- operation: status_update
- new_status: planned (reset for re-implementation)
- artifact_path: .claude/specs/{N}_{SLUG}/plans/implementation-{NEW_VERSION}.md
- artifact_type: plan
- plan_version: {NEW_VERSION}

This updates both files atomically:
1. state.json: status = "planned", plan_version = NEW_VERSION, artifacts += [{path, type}] (via jq)
2. TODO.md: Status: [PLANNED], update Plan link (via grep + Edit)

### 7. Git Commit

```bash
git add .claude/specs/
git commit -m "task {N}: revise plan (v{NEW_VERSION})"
```

### 8. Output (Plan Revision)

This output applies to plan revisions (when task has existing plan):

```
Plan revised for Task #{N}

Previous: implementation-{PREV}.md
New: implementation-{NEW}.md

Key changes:
- {Change 1}
- {Change 2}

Preserved phases: 1
Revised phases: 2-3

Status: [PLANNED]
Next: /implement {N}
```
