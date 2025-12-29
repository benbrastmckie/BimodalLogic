---
name: plan
agent: subagents/planner
description: "Create implementation plans with [PLANNED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/plan 197`, `/plan 196`)

## Purpose

Create implementation plans for specified tasks with phased breakdown, effort estimates, and research integration. Updates task status to [PLANNED] and creates plan artifacts following plan.md template standard.

## Usage

```bash
/plan TASK_NUMBER [PROMPT]
```

### Examples

- `/plan 196` - Create plan for task 196 using task description
- `/plan 196 "Focus on phase breakdown"` - Create plan with custom focus

### Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| TASK_NUMBER | integer | Yes | Task number from .opencode/specs/TODO.md |
| PROMPT | string | No | Optional additional context for planning |

## Workflow

This command follows the 8-stage command-lifecycle.md pattern:

1. **Preflight**: Parse arguments, validate task exists, update status to [PLANNING]
2. **CheckLanguage**: Extract language from task entry (for context loading)
3. **PrepareDelegation**: Generate session ID, prepare delegation context with timeout (1800s)
4. **InvokeAgent**: Delegate to planner agent with task context and research links
5. **ValidateReturn**: Verify plan artifact created and return format valid
6. **PrepareReturn**: Format return object with artifact paths and summary
7. **Postflight**: Update status to [PLANNED], create git commit, verify on disk
8. **ReturnSuccess**: Return standardized result to user

**Implementation**: See `.opencode/agent/subagents/planner.md` for complete workflow execution details.

## Context Loading

### Routing Stage (Stages 1-3)

Load minimal context for routing decisions:
- `.opencode/context/system/routing-guide.md` (routing logic)

### Execution Stage (Stage 4+)

Planner agent loads context on-demand per `.opencode/context/index.md`:
- `common/workflows/command-lifecycle.md` (workflow stages)
- `common/standards/subagent-return-format.md` (return format)
- `common/system/status-markers.md` (status transitions)
- `common/system/artifact-management.md` (lazy directory creation)
- `common/standards/plan.md` (plan template)
- Task entry via `grep -A 50 "^### ${task_number}\." TODO.md` (~2KB vs 109KB full file)
- `state.json` (project state)
- Research artifacts if linked in TODO.md

## Artifacts Created

### Implementation Plan (required)

Path: `.opencode/specs/{task_number}_{slug}/plans/implementation-001.md`

Contains:
- Metadata (task, status, effort, priority, complexity, language)
- Overview (problem, scope, constraints, definition of done)
- Goals and Non-Goals
- Risks and Mitigations
- Implementation Phases (each with [NOT STARTED] marker)
- Testing and Validation
- Artifacts and Outputs
- Rollback/Contingency
- Success Metrics

**Note**: Directory created lazily when writing artifact (not during routing).

### Summary (metadata only)

Summary is included in return object metadata (3-5 sentences, <100 tokens), NOT as separate artifact file.

**Rationale**: Plan is self-documenting. Protects orchestrator context window from bloat.

Reference: `artifact-management.md` "Context Window Protection via Metadata Passing"

## Research Integration

Planner automatically harvests research findings from TODO.md:

1. Scan task entry for research artifact links
2. Load research reports and summaries if present
3. Extract key findings and recommendations
4. Incorporate into plan context and phases
5. Note research inputs in plan metadata

If no research available, planner proceeds without research context.

## Status Transitions

| From | To | Condition |
|------|-----|-----------|
| [NOT STARTED] | [PLANNING] | Planning started (Stage 1) |
| [RESEARCHED] | [PLANNING] | Planning started (Stage 1) |
| [PLANNING] | [PLANNED] | Planning completed successfully (Stage 7) |
| [PLANNING] | [PLANNING] | Planning failed or partial (Stage 7) |
| [PLANNING] | [BLOCKED] | Planning blocked by dependency (Stage 7) |

**Status Update**: Delegated to `status-sync-manager` for atomic synchronization across TODO.md and state.json.

**Timestamps**: `**Started**: {date}` added in Stage 1, `**Completed**: {date}` added in Stage 7.

## Error Handling

### Task Not Found

```
Error: Task {task_number} not found in .opencode/specs/TODO.md

Recommendation: Verify task number exists in TODO.md
```

### Invalid Task Number

```
Error: Task number must be an integer. Got: {input}

Usage: /plan TASK_NUMBER [PROMPT]
```

### Task Already Completed

```
Error: Task {task_number} is already [COMPLETED]

Recommendation: Cannot plan completed tasks
```

### Plan Already Exists

```
Warning: Plan already exists for task {task_number}

Existing plan: {plan_path}

Recommendation: Use /revise {task_number} to update existing plan
```

### Planning Timeout

```
Error: Planning timed out after 1800s

Status: Partial plan may exist
Task status: [PLANNING]

Recommendation: Resume with /plan {task_number}
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

Plan created successfully: {plan_path}
Task status updated to [PLANNED]

Manual commit required:
  git add {files}
  git commit -m "task {number}: plan created"

Error: {git_error}
```

## Quality Standards

### Plan Template Compliance

All plans must follow `.opencode/context/common/standards/plan.md` template:
- Metadata section with all required fields
- Phase breakdown with [NOT STARTED] markers
- Acceptance criteria per phase
- Effort estimates (1-2 hours per phase)
- Success metrics

### Atomic Updates

Status updates delegated to `status-sync-manager` for atomic synchronization:
- `.opencode/specs/TODO.md` (status, timestamps, plan link)
- `state.json` (status, timestamps, plan_path, plan_metadata)
- Project state.json (lazy created if needed)

Two-phase commit ensures consistency across all files.

### Lazy Directory Creation

Directories created only when writing artifacts:
- `.opencode/specs/{task_number}_{slug}/` created when writing plan
- `plans/` subdirectory created when writing implementation-001.md

No directories created during routing or validation stages.

## Return Format

### Completed

```
Plan created for task {number}.
{brief_1_sentence_overview}
{phase_count} phases, {effort} hours estimated.
Plan: {plan_path}
```

Example:
```
Plan created for task 195.
Integrated LeanSearch API research findings into 4-phase implementation.
4 phases, 6 hours estimated.
Plan: .opencode/specs/195_lean_tools/plans/implementation-001.md
```

### Partial

```
Plan partially created for task {number}.
{brief_reason}
Resume with: /plan {number}
Plan: {plan_path}
```

**Token Limit**: Return must be under 100 tokens (approximately 400 characters).

## Delegation Context

Planner receives:
- `task_number`: Task number for planning
- `session_id`: Unique session identifier
- `delegation_depth`: 1 (from orchestrator → plan → planner)
- `delegation_path`: ["orchestrator", "plan", "planner"]
- `timeout`: 1800s (30 minutes)
- `task_context`: Task description, language, research links

Planner returns standardized format per `subagent-return-format.md`.

## Notes

- **Research Harvesting**: Planner automatically loads research artifacts from TODO.md links
- **Phase Sizing**: Phases kept small (1-2 hours each) for manageable execution
- **Template Compliance**: All plans follow plan.md standard exactly
- **Context Window Protection**: Summary in return metadata, not separate artifact
- **Atomic Updates**: status-sync-manager ensures consistency across files
- **Git Workflow**: Delegated to git-workflow-manager for standardized commits
