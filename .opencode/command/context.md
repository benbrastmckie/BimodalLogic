---
name: context
agent: orchestrator
description: "Create context files for a project"
---

You are creating context files for the LEAN 4 ProofChecker project.

**Request:** $ARGUMENTS

**Task:**

Execute the context creation workflow:

1. Route to @subagents/context-adder with the request.
2. The context-adder will:
   - Analyze the request.
   - Create the necessary context files.
   - Store the files in .opencode/specs/NNN_project/context/
3. After the context files are created, route to @subagents/task-adder to create a new task in TODO.md.
4. Present the results with the context file reference and a summary.

**Expected Output:**

- Context file reference(s).
- A summary of the created context.
- Confirmation that a task has been added to TODO.md.

Execute the context creation now.
