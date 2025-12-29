---
name: implement
agent: subagents/implementer
description: "Execute implementation with resume support and [COMPLETED] status"
context_level: 2
language: varies
routing:
  lean: lean-implementation-agent
  default: implementer
---

**Task Input (required):** $ARGUMENTS (task number or range; e.g., `/implement 197`, `/implement 105-107`)

## Purpose

Execute implementation for specified tasks with plan-based execution, resume support, and status tracking. Supports both phased (with plan) and direct (no plan) implementation. Updates task status to [COMPLETED] and creates implementation artifacts.

## Usage

```bash
/implement TASK_NUMBER [PROMPT]
/implement TASK_RANGE [PROMPT]
```

### Examples

- `/implement 196` - Implement task 196 using plan if available
- `/implement 196 "Focus on error handling"` - Implement with custom focus
- `/implement 105-107` - Batch implement tasks 105-107
- `/implement 105-107 "Batch implementation"` - Batch with custom context

### Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| TASK_NUMBER | integer | Yes | Task number from .opencode/specs/TODO.md |
| TASK_RANGE | range | Yes | Task range (e.g., 105-107) for batch implementation |
| PROMPT | string | No | Optional additional context for implementation |

### Range Parsing

If argument contains hyphen (-):
- Split on hyphen to get start and end
- Validate both are integers
- Validate start < end
- Generate list of task numbers: [start, start+1, ..., end]
- Execute tasks sequentially

## Workflow

This command follows the standard workflow pattern with language-based routing:

1. **Preflight**: Parse arguments, validate task(s) exist, update status to [IMPLEMENTING]
2. **CheckLanguage**: Extract language from task entry, determine routing (lean → lean-implementation-agent, else → implementer)
3. **PrepareDelegation**: Check for plan, determine resume point, generate session ID, prepare delegation context
4. **InvokeAgent**: Delegate to implementer agent (or task-executor if plan exists) with task context
5. **ValidateReturn**: Verify implementation artifacts created and return format valid
6. **PrepareReturn**: Format return object with artifact paths and summary
7. **Postflight**: Update status to [COMPLETED], create git commit(s), verify on disk
8. **ReturnSuccess**: Return standardized result to user

**Implementation**: See `.opencode/agent/subagents/implementer.md` for complete workflow execution details.

## Plan-Based vs Direct Implementation

### With Plan (Phased Implementation)

If task has plan in TODO.md:
- Load plan file and parse phases
- Find first [NOT STARTED] or [IN PROGRESS] phase
- Resume from that phase (skip [COMPLETED] phases)
- Delegate to task-executor for phase orchestration
- Create git commit per completed phase
- Update phase status markers in plan file
- Support resume on timeout or failure

### Without Plan (Direct Implementation)

If task has no plan:
- Single-pass implementation
- Delegate directly to implementer agent
- Create single git commit for entire task
- No phase tracking or resume support

## Language-Based Routing

### Language Extraction

Language is extracted from task entry in TODO.md:

```bash
grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
```

If extraction fails, defaults to "general" with warning logged.

### Routing Rules

| Language | Agent | Tools Available |
|----------|-------|----------------|
| `lean` | `lean-implementation-agent` | lean-lsp-mcp, lake build, lean --version |
| `markdown` | `implementer` | File operations, git |
| `python` | `implementer` | File operations, git, python tools |
| `general` | `implementer` | File operations, git |

**Critical**: Language extraction MUST occur before routing. Incorrect routing bypasses language-specific tooling.

## Context Loading

### Routing Stage (Stages 1-3)

Load minimal context for routing decisions:
- `.opencode/context/system/routing-guide.md` (routing logic)

### Execution Stage (Stage 4+)

Implementer agent loads context on-demand per `.opencode/context/index.md`:
- `common/standards/subagent-return-format.md` (return format)
- `common/system/status-markers.md` (status transitions)
- `common/system/artifact-management.md` (lazy directory creation)
- Task entry via `grep -A 50 "^### ${task_number}\." TODO.md` (~2KB vs 109KB full file)
- `state.json` (project state)
- Plan file if exists (for phase tracking and resume)

Language-specific context:
- If lean: `project/lean4/tools/lean-lsp-mcp.md`, `project/lean4/build-system.md`
- If markdown: (no additional context)

## Resume Support

### Resume Logic

If plan exists:
1. Read plan file and parse phase status markers
2. Find first phase with [NOT STARTED] or [IN PROGRESS]
3. Skip all [COMPLETED] phases
4. Resume from incomplete phase
5. Continue until all phases complete or timeout

If no plan:
- No resume support (single-pass implementation)
- Retry requires full re-execution

### Resume Invocation

```bash
/implement {task_number}
```

Same command works for both initial implementation and resume. The implementer automatically detects incomplete phases and resumes.

## Artifacts Created

### Implementation Files (required)

Paths vary by language and task:
- Lean: `Logos/**/*.lean`, `LogosTest/**/*.lean`
- Markdown: `Documentation/**/*.md`, `.opencode/**/*.md`
- Python: `**/*.py`
- Config: `**/*.json`, `**/*.yaml`, etc.

**Note**: Directories created lazily when writing artifacts (not during routing).

### Implementation Summary (required for multi-file outputs)

Path: `.opencode/specs/{task_number}_{slug}/summaries/implementation-summary-{YYYYMMDD}.md`

Contains:
- What was implemented
- Files modified/created
- Key decisions made
- Testing recommendations

**Token Limit**: Summary must be <100 tokens (~400 characters) to protect orchestrator context window.

**Rationale**: Multi-file implementations create N+1 artifacts (N implementation files + 1 summary). Summary provides unified overview without requiring orchestrator to read all N files.

Reference: `artifact-management.md` "Context Window Protection via Metadata Passing"

### Git Commits

- **With Plan**: One commit per completed phase
- **Without Plan**: One commit for entire task

Commit messages follow format: `task {number}: {description}` or `task {number} phase {N}: {phase_name}`

## Status Transitions

| From | To | Condition |
|------|-----|-----------|
| [NOT STARTED] | [IMPLEMENTING] | Implementation started (Stage 1) |
| [PLANNED] | [IMPLEMENTING] | Implementation started (Stage 1) |
| [REVISED] | [IMPLEMENTING] | Implementation started (Stage 1) |
| [IMPLEMENTING] | [COMPLETED] | Implementation completed successfully (Stage 7) |
| [IMPLEMENTING] | [IMPLEMENTING] | Implementation failed or partial (Stage 7) |
| [IMPLEMENTING] | [BLOCKED] | Implementation blocked by dependency (Stage 7) |

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
Error: Task must be integer or range (N-M). Got: {input}

Usage: /implement TASK_NUMBER [PROMPT]
```

### Invalid Range

```
Error: Invalid range {start}-{end}. Start must be less than end.

Usage: /implement START-END [PROMPT]
```

### Task Already Completed

```
Error: Task {task_number} is already [COMPLETED]

Recommendation: Cannot re-implement completed tasks
```

### Implementation Timeout

```
Error: Implementation timed out

Status: Partial implementation may exist
Task status: [IMPLEMENTING]
Phase status: [IN PROGRESS] (if plan exists)

Recommendation: Resume with /implement {task_number}
```

### Validation Failure

```
Error: Implementation validation failed

Details: {validation_error}

Recommendation: Fix implementer subagent implementation
```

### Git Commit Failure (non-critical)

```
Warning: Git commit failed

Implementation completed successfully
Task status updated to [COMPLETED]

Manual commit required:
  git add {files}
  git commit -m "task {number}: {description}"

Error: {git_error}
```

### Language Extraction Failure

```
Warning: Could not extract language from task entry

Defaulting to: general
Agent: implementer

Recommendation: Add **Language**: {language} to task entry in TODO.md
```

## Quality Standards

### Atomic Updates

Status updates delegated to `status-sync-manager` for atomic synchronization:
- `.opencode/specs/TODO.md` (status, timestamps, artifact links)
- `state.json` (status, timestamps, artifact_paths)
- Plan file (phase status markers if plan exists)
- Project state.json (lazy created if needed)

Two-phase commit ensures consistency across all files.

### Lazy Directory Creation

Directories created only when writing artifacts:
- `.opencode/specs/{task_number}_{slug}/` created when writing first artifact
- `summaries/` subdirectory created when writing implementation-summary.md

No directories created during routing or validation stages.

### Git Workflow

Git commits delegated to `git-workflow-manager` for standardized commits:
- Commit message format: `task {number}: {description}`
- Scope files: All implementation artifacts + TODO.md + state.json
- Per-phase commits if plan exists
- Single commit if no plan

## Return Format

### Completed

```
Implementation completed for task {number}.
{brief_1_sentence_overview}
Files: {file_count} modified/created.
Summary: {summary_path}
```

Example:
```
Implementation completed for task 195.
Integrated LeanSearch API with error handling and tests.
Files: 3 modified/created.
Summary: .opencode/specs/195_lean_tools/summaries/implementation-summary-20251229.md
```

### Partial (with resume)

```
Implementation partially completed for task {number}.
{brief_reason}
Phase {N} in progress.
Resume with: /implement {number}
```

### Batch Completed

```
Batch implementation completed for tasks {start}-{end}.
{N} tasks completed successfully.
{M} tasks failed.
See individual task summaries for details.
```

**Token Limit**: Return must be under 100 tokens (approximately 400 characters).

## Delegation Context

Implementer receives:
- `task_number`: Task number for implementation
- `language`: Programming language from task entry
- `session_id`: Unique session identifier
- `delegation_depth`: 1 (from orchestrator → implement → implementer)
- `delegation_path`: ["orchestrator", "implement", "implementer"]
- `timeout`: 3600s (1 hour) for simple tasks, 7200s (2 hours) for phased tasks
- `task_context`: Task description, plan path (if exists), resume phase (if applicable)

Implementer returns standardized format per `subagent-return-format.md`.

## Notes

- **Resume Support**: Automatic resume from incomplete phases if plan exists
- **Language Routing**: Lean tasks route to lean-implementation-agent with specialized tools
- **Phase Tracking**: Plan-based tasks track phase status and support resume
- **Git Workflow**: Per-phase commits for plan-based, single commit for direct
- **Context Window Protection**: Summary artifact for multi-file outputs
- **Atomic Updates**: status-sync-manager ensures consistency across files
- **Lazy Creation**: Directories created only when writing artifacts
