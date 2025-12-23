---
name: implement
agent: orchestrator
description: "Implement following an implementation plan (use /lean for LEAN 4 proofs)"
---

You are implementing a general coding task following an implementation plan.

**Arguments:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/core/standards/
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/core/essential-patterns.md

**Task:**

Execute the implementation workflow:

1. Parse arguments:
   - Extract plan file path (required, first argument)
   - Extract starting phase number (optional, second argument)
   
2. Route to @subagents/implementation-orchestrator with:
   - Plan file path
   - Starting phase number (or null to auto-detect first incomplete)

 3. Implementation orchestrator will:
    - Load implementation plan from provided path
    - Parse phases and dependencies
    - Skip already completed phases
    - Execute remaining phases in waves (parallel where possible)
    - Update plan file with status markers ([NOT STARTED], [IN PROGRESS], [COMPLETED], [BLOCKED], [ABANDONED])
    - Sync with TODO.md if plan references task numbers
    - Use @subagents/implementer for actual phase work
    - Create implementation summary

4. Present results with summary and completion status

**Expected Output:**

- Implementation summary reference
- Phases completed
- Files created/modified
- Plan file updated with status markers
- TODO.md sync status
- Next steps (if any)

Execute the implementation now.
