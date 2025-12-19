---
name: plan
agent: orchestrator
description: "Create detailed implementation plan for a TODO task"
---

You are creating an implementation plan for the LEAN 4 ProofChecker project.

**Task from TODO:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/processes/end-to-end-proof-workflow.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/templates/proof-structure-templates.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/logic/processes/

**Task:**

Execute the planning workflow:

1. Route to @subagents/planner with task description
2. Planner will:
   - Analyze complexity (via complexity-analyzer)
   - Map dependencies (via dependency-mapper)
   - Create detailed step-by-step implementation plan
   - Store plan in .opencode/specs/NNN_project/plans/implementation-001.md
3. Present results with plan reference and summary

**Expected Output:**

- Implementation plan reference
- Complexity assessment
- Estimated effort
- Key implementation steps
- Dependencies and prerequisites

Execute the planning now.
