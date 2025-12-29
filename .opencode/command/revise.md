---
name: revise
agent: subagents/planner
description: "Create new plan versions with [REVISED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number and optional prompt; e.g., `/revise 196`, `/revise 196 "Adjust approach"`)

## Purpose

Create new plan versions for tasks with existing plans. Increments plan version number (implementation-002.md, etc.) and updates task status to [REVISED]. Useful for adjusting approach based on new information or changing requirements.

## Usage

```bash
/revise TASK_NUMBER [PROMPT]
```

### Examples

- `/revise 196` - Create new plan version for task 196
- `/revise 196 "Adjust phase breakdown based on new findings"` - Revise with specific reason

### Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| TASK_NUMBER | integer | Yes | Task number from .opencode/specs/TODO.md |
| PROMPT | string | No | Reason for revision or specific changes needed |

## Workflow

This command follows the standard workflow pattern:

1. **Preflight**: Parse arguments, validate task exists with plan, update status to [REVISING]
2. **CheckLanguage**: Extract language from task entry (for context loading)
3. **PrepareDelegation**: Calculate next plan version, generate session ID, prepare delegation context with timeout (1800s)
4. **InvokeAgent**: Delegate to planner agent with task context, existing plan, and revision reason
5. **ValidateReturn**: Verify new plan artifact created and return format valid
6. **PrepareReturn**: Format return object with artifact paths and summary
7. **Postflight**: Update status to [REVISED], update plan link, create git commit, verify on disk
8. **ReturnSuccess**: Return standardized result to user

**Implementation**: See `.opencode/agent/subagents/planner.md` for complete workflow execution details.

## Plan Version Management

### Version Numbering

Plans are versioned sequentially:
- First plan: `implementation-001.md`
- First revision: `implementation-002.md`
- Second revision: `implementation-003.md`
- etc.

### Version Calculation

1. Extract current plan path from .opencode/specs/TODO.md
2. Parse version number from filename (implementation-001.md → 1)
3. Increment version: next_version = current + 1
4. Format new plan path: implementation-{next_version:03d}.md
5. Verify new plan path doesn't exist

### Existing Plan Preservation

- Original plan files are never modified
- New plan version created as separate file
- All plan versions preserved in plans/ directory
- TODO.md plan link updated to point to latest version

## Context Loading

### Routing Stage (Stages 1-3)

Load minimal context for routing decisions:
- `.opencode/context/system/routing-guide.md` (routing logic)

### Execution Stage (Stage 4+)

Planner agent loads context on-demand per `.opencode/context/index.md`:
- `common/standards/subagent-return-format.md` (return format)
- `common/system/status-markers.md` (status transitions)
- `common/system/artifact-management.md` (lazy directory creation)
- `common/standards/plan.md` (plan template)
- Task entry via `grep -A 50 "^### ${task_number}\." TODO.md` (~2KB vs 109KB full file)
- `state.json` (project state)
- Existing plan file (for context and comparison)
- Research artifacts if linked in TODO.md

## Artifacts Created

### Revised Implementation Plan (required)

Path: `.opencode/specs/{task_number}_{slug}/plans/implementation-{version:03d}.md`

Contains same structure as original plan:
- Metadata (task, status, effort, priority, complexity, language)
- Overview (problem, scope, constraints, definition of done)
- Goals and Non-Goals
- Risks and Mitigations
- Implementation Phases (each with [NOT STARTED] marker)
- Testing and Validation
- Artifacts and Outputs
- Rollback/Contingency
- Success Metrics

**Note**: Revision reason included in plan metadata or overview.

### Summary (metadata only)

Summary is included in return object metadata (3-5 sentences, <100 tokens), NOT as separate artifact file.

**Rationale**: Plan is self-documenting. Protects orchestrator context window from bloat.

Reference: `artifact-management.md` "Context Window Protection via Metadata Passing"

## Status Transitions

| From | To | Condition |
|------|-----|-----------|
| [PLANNED] | [REVISING] | Revision started (Stage 1) |
| [REVISED] | [REVISING] | Revision started (Stage 1) |
| [REVISING] | [REVISED] | Revision completed successfully (Stage 7) |
| [REVISING] | [REVISING] | Revision failed or partial (Stage 7) |
| [REVISING] | [BLOCKED] | Revision blocked by dependency (Stage 7) |

**Status Update**: Delegated to `status-sync-manager` for atomic synchronization across TODO.md and state.json.

**Timestamps**: `**Started**: {date}` preserved from original planning, `**Revised**: {date}` added in Stage 7.

## Error Handling

### Task Not Found

```
Error: Task {task_number} not found in .opencode/specs/TODO.md

Recommendation: Verify task number exists in TODO.md
```

### Invalid Task Number

```
Error: Task number must be an integer. Got: {input}

Usage: /revise TASK_NUMBER [PROMPT]
```

### No Existing Plan

```
Error: Task {task_number} has no plan. Use /plan instead.

Recommendation: Create initial plan with /plan {task_number}
```

### Task Already Completed

```
Error: Task {task_number} is already [COMPLETED]

Recommendation: Cannot revise completed tasks
```

### Revision Timeout

```
Error: Revision timed out after 1800s

Status: Partial plan may exist
Task status: [REVISING]

Recommendation: Resume with /revise {task_number}
```

### Validation Failure

```
Error: Plan validation failed

Details: {validation_error}

Recommendation: Fix planner subagent implementation
```

### Git Commit Failure (non-critical)

```
Warning: Git commit failed

Plan revised successfully: {plan_path}
Task status updated to [REVISED]

Manual commit required:
  git add {files}
  git commit -m "task {number}: plan revised (version {version})"

Error: {git_error}
```

## Quality Standards

### Plan Template Compliance

All revised plans must follow `.opencode/context/common/standards/plan.md` template:
- Metadata section with all required fields
- Phase breakdown with [NOT STARTED] markers
- Acceptance criteria per phase
- Effort estimates (1-2 hours per phase)
- Success metrics

### Atomic Updates

Status updates delegated to `status-sync-manager` for atomic synchronization:
- `.opencode/specs/TODO.md` (status, timestamps, plan link updated to new version)
- `state.json` (status, timestamps, plan_path updated to new version, plan_metadata)
- Project state.json (lazy created if needed)

Two-phase commit ensures consistency across all files.

### Version Tracking

- Plan version number tracked in state.json
- TODO.md plan link always points to latest version
- All previous plan versions preserved in plans/ directory

## Return Format

### Completed

```
Plan revised for task {number} (version {version}).
{brief_1_sentence_overview}
{phase_count} phases, {effort} hours estimated.
Plan: {plan_path}
```

Example:
```
Plan revised for task 195 (version 2).
Simplified approach based on new LeanSearch API findings.
3 phases, 4 hours estimated.
Plan: .opencode/specs/195_lean_tools/plans/implementation-002.md
```

### Partial

```
Plan partially revised for task {number}.
{brief_reason}
Resume with: /revise {number}
Plan: {plan_path}
```

**Token Limit**: Return must be under 100 tokens (approximately 400 characters).

## Delegation Context

Planner receives:
- `task_number`: Task number for revision
- `session_id`: Unique session identifier
- `delegation_depth`: 1 (from orchestrator → revise → planner)
- `delegation_path`: ["orchestrator", "revise", "planner"]
- `timeout`: 1800s (30 minutes)
- `task_context`: Task description, language, research links
- `revision_context`: Revision reason, existing plan path, new version number

Planner returns standardized format per `subagent-return-format.md`.

## Notes

- **Version Preservation**: All plan versions preserved, never overwritten
- **Research Integration**: Planner automatically loads research artifacts from TODO.md links
- **Phase Sizing**: Phases kept small (1-2 hours each) for manageable execution
- **Template Compliance**: All plans follow plan.md standard exactly
- **Context Window Protection**: Summary in return metadata, not separate artifact
- **Atomic Updates**: status-sync-manager ensures consistency across files
- **Git Workflow**: Delegated to git-workflow-manager for standardized commits
