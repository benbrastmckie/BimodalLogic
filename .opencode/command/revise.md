---
name: revise
agent: orchestrator
description: "Create revised implementation plan with incremented version number"
---

You are revising an implementation plan for the LEAN 4 ProofChecker project.

**Project Number:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/processes/end-to-end-proof-workflow.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/repo/

**Task:**

Execute the revision workflow:

1. Route to @subagents/planner with project number and revision request
2. Planner will:
   - Load existing plan(s) from .opencode/specs/NNN_project/plans/
   - Identify highest version number
   - Create new plan with incremented version (implementation-{N+1}.md)
   - Include revision notes and changes from previous version
3. Present results with new plan reference

**Expected Output:**

- Revised plan reference (with incremented version)
- Changes from previous version
- Reason for revision
- Updated complexity/effort estimates

Execute the revision now.
