---
name: add
agent: subagents/task-adder
description: "Add numbered tasks to TODO.md and update IMPLEMENTATION_STATUS.md with intelligent task breakdown and grouping"
---

You are adding tasks to the LEAN 4 ProofChecker project TODO.md.

**Request:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Projects/ProofChecker/.opencode/specs/TODO.md
@/home/benjamin/Projects/ProofChecker/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
@/home/benjamin/Projects/ProofChecker/context/core/standards/docs.md
@/home/benjamin/Projects/ProofChecker/context/project/project-context.md

**Task:**

Route to @subagents/task-adder with the following context:

1. **Input Parsing**: Determine input type from $ARGUMENTS
   - Single task: `/add "task description"`
   - Multiple tasks: `/add "task 1" "task 2" "task 3"`
   - File extraction: `/add --file path/to/file.md`
   - File with context: `/add --file path/to/file.md --context "additional context"`

2. **Task Processing**: task-adder will:
   - Analyze input and break down into appropriately-sized tasks
   - Group related tasks logically
   - Extract tasks from files if --file flag provided
   - Determine next available task numbers
   - Format tasks according to TODO.md conventions
   - Update TODO.md with new tasks
   - Update IMPLEMENTATION_STATUS.md with task references

3. **Return Summary**: Present results with:
   - Total tasks added
   - Task numbers assigned
   - Task titles and priorities
   - IMPLEMENTATION_STATUS.md updates
   - Next steps

**Usage Examples:**

```bash
# Add a single task
/add "Implement proof for theorem X using tactics A, B, C"

# Add multiple tasks
/add "Fix typo in Formula.lean" "Update README with examples" "Add tests for Axioms.lean"

# Extract tasks from a file
/add --file Documentation/Research/PROOF_LIBRARY_DESIGN.md

# Extract tasks with additional context
/add --file .opencode/specs/005_layer1_planning/plans/implementation-001.md --context "Layer 1 counterfactual operators"
```

**Expected Output:**

The task-adder will return a summary showing:
- Number of tasks added
- Task numbers and titles
- Priority assignments
- Effort estimates
- Dependencies identified
- IMPLEMENTATION_STATUS.md sections updated
- Suggested next steps

Execute the task addition now.
