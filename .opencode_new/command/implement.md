---
name: implement
agent: orchestrator
description: "Implement following an implementation plan"
---

You are implementing a software development task following an implementation plan.

**Arguments:** $ARGUMENTS

**Context Loaded:**
@context/common/standards/code.md
@context/common/standards/patterns.md
@context/common/workflows/task-breakdown.md
@context/common/system/artifact-management.md
@context/common/system/status-markers.md
@.opencode/specs/TODO.md
@.opencode/specs/state.json

**Task:**

Execute the implementation workflow:

1. Parse arguments:
   - Extract plan file path (required, first argument)
   - Extract starting phase number (optional, second argument)
   - Fail fast if the plan path is missing or not found (no directories/artifacts created).

2. Route to @subagents/implementation-orchestrator with:
   - Plan file path
   - Starting phase number (or null to auto-detect first incomplete)
   - Guardrails: do not create project roots or subdirectories unless writing an artifact (lazy creation), and do not alter numbering.

3. Implementation orchestrator will:
   - Load implementation plan from provided path
   - Parse phases and dependencies
   - Skip already completed phases
   - Execute remaining phases in waves (parallel where possible)
   - Update plan file with status markers ([NOT STARTED], [IN PROGRESS], [COMPLETED], [BLOCKED], [ABANDONED]) including timestamps
   - Sync with TODO.md and `.opencode/specs/state.json` for referenced task numbers
   - Use @subagents/implementer for actual phase work
   - Create implementation summary

4. Present results with summary and completion status, noting any plan/TODO/state updates performed

**Expected Output:**

- Implementation summary reference
- Phases completed
- Files created/modified
- Plan file updated with status markers
- TODO.md and state sync status
- Next steps (if any)

Execute the implementation now.
