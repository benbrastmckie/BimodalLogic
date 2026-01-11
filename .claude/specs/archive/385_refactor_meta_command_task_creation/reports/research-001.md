# Research Report: Task #385

**Task**: Refactor /meta command to create tasks instead of direct implementation
**Date**: 2026-01-12
**Focus**: Understanding current implementation, identifying gaps, and defining required changes

## Summary

The `/meta` command currently bypasses the task management system and directly implements changes to `.claude/` files. A comprehensive refactor guide already exists at `.claude/specs/meta-command-refactor-guide.md` that documents the required behavior. The current `meta.md` command file has not been updated to follow this guide, leading to the problematic behavior observed in the user's recent execution.

## Findings

### 1. Current /meta Command Behavior (Problem)

The current `.claude/commands/meta.md` file:
- Defines 8 stages focused on **direct generation** of files
- Stage 7 (Generation) directly creates commands, skills, rules
- Stage 8 (Validation) verifies generated files
- **Does NOT create tasks in TODO.md or state.json**
- **Does NOT create plan artifacts**
- **Immediately implements changes** when given a prompt

Evidence from `.claude/output/meta.md`:
- User ran `/meta` with a prompt about /todo directory migration
- Command immediately analyzed, designed, and implemented changes
- Directly edited `.claude/commands/todo.md` and `.claude/commands/task.md`
- Never created a task entry or asked for approval

### 2. Existing Refactor Guide (Solution Blueprint)

A comprehensive guide exists at `.claude/specs/meta-command-refactor-guide.md` that was never applied:

**Key Requirements from Guide**:
1. **FORBIDDEN**: Direct creation of commands, skills, rules, context files
2. **FORBIDDEN**: Direct modification of CLAUDE.md or ARCHITECTURE.md
3. **REQUIRED**: All work tracked via tasks in TODO.md + state.json
4. **REQUIRED**: Plans in `.claude/specs/{N}_{SLUG}/plans/`

**Correct Stage Structure**:
- Stages 1-5: Interview/Analysis (unchanged)
- Stage 6: Architecture Design with component list
- Stage 7: **Task Creation** (not Generation)
  - Create task directories
  - Update state.json
  - Update TODO.md
  - Create plan artifacts for each component
- Stage 8: Git commit tasks/plans
- Stage 9: Summary with next steps

### 3. Related Task (Task 306)

Task 306 has the same description but:
- Status: "planned" in state.json
- Artifacts listed in state.json don't exist (directory missing)
- Plan version 3 was created but files are gone
- This is a **duplicate task** that should be cleaned up

### 4. Interview Patterns Infrastructure

Existing infrastructure supports interactive interviews:
- `.claude/context/project/meta/interview-patterns.md` - Interview best practices
- Patterns: Progressive Disclosure, Adaptive Questioning, Example-Driven
- Validation Checkpoint pattern for confirming understanding

### 5. Gap Analysis

| Feature | Current | Required |
|---------|---------|----------|
| Interactive interview (no args) | Partial | Full with AskUserQuestion |
| Analysis on prompt | None | Required before acting |
| Follow-up questions | None | Required for clarity |
| Task creation | None | Create N tasks with dependencies |
| Plan artifacts | None | Create plans for each task |
| Direct implementation | Yes (wrong) | Forbidden |
| Git commit | One large | One commit with all tasks |

### 6. AskUserQuestion Tool

The system has access to the `AskUserQuestion` tool which should be used for:
- Clarifying ambiguous requirements
- Presenting options for user decision
- Confirming understanding before creating tasks

This tool is currently not listed in meta.md's allowed-tools but should be added.

## Recommendations

### 1. Replace Current meta.md

Apply the refactor guide from `.claude/specs/meta-command-refactor-guide.md`:
- Replace Stage 7 (Generation) with Task Creation
- Add explicit FORBIDDEN/REQUIRED constraints at top
- Add AskUserQuestion to allowed-tools

### 2. Implement Two Operating Modes

**Mode A: With Prompt**
1. Analyze the .claude/ system and prompt context
2. Use AskUserQuestion if clarification needed
3. Propose architecture with component breakdown
4. Wait for user approval
5. Create tasks with dependencies indicated
6. Git commit and output summary

**Mode B: Without Prompt (Interactive)**
1. Start interview process (Stages 1-5)
2. Build understanding progressively
3. Use validation checkpoints
4. Propose architecture (Stage 6)
5. Wait for approval
6. Create tasks (Stage 7)
7. Git commit and output summary (Stages 8-9)

### 3. Task Dependencies

When creating multiple tasks, indicate dependencies:
```json
{
  "project_number": 386,
  "dependencies": [385],
  "blocking": []
}
```

And in TODO.md:
```markdown
- **Dependencies**: Task #385
```

### 4. Clean Up Task 306

Task 306 is a duplicate with missing artifacts. Options:
- Abandon it via `/task --abandon 306`
- Or recover/recreate artifacts

## References

- `.claude/commands/meta.md` - Current command file
- `.claude/specs/meta-command-refactor-guide.md` - Comprehensive refactor guide
- `.claude/context/project/meta/interview-patterns.md` - Interview patterns
- `.claude/commands/task.md` - Task --divide pattern for reference
- `.claude/output/meta.md` - Evidence of problematic behavior

## Next Steps

1. Create implementation plan based on refactor guide
2. Plan should have phases:
   - Phase 1: Add constraints and update allowed-tools
   - Phase 2: Implement analysis mode (with prompt)
   - Phase 3: Implement interactive mode (no prompt)
   - Phase 4: Implement task creation logic
   - Phase 5: Testing and validation
3. Consider marking task 306 as abandoned or consolidating
