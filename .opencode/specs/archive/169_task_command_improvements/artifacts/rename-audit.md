# Task 169: /task → /implement Rename Audit

**Date**: 2025-12-24
**Audit Type**: Command Rename Impact Analysis
**Status**: COMPLETED

## Rename Scope

**Old Command**: `/task`
**New Command**: `/implement`
**Rationale**: Better semantic clarity - "implement" conveys execution intent more clearly than generic "task"

## File Rename Required

### Primary Command File
- **Source**: `.opencode/command/task.md`
- **Target**: `.opencode/command/implement.md`
- **Status**: File already exists at target location
- **Action Required**: Verify implement.md is correct version, or rename task.md and merge

## Reference Updates Required

### Pattern 1: Command Invocation
**Pattern**: `/task {args}`
**Replacement**: `/implement {args}`
**Locations**: 259 references across 80+ files

### Pattern 2: Command Name in Text
**Pattern**: "task command", "/task command", "the /task"
**Replacement**: "implement command", "/implement command", "the /implement"
**Locations**: Documentation, error messages, help text

### Pattern 3: Routing References
**Pattern**: Routes to /task, delegates to /task
**Replacement**: Routes to /implement, delegates to /implement
**Locations**: Agent routing logic, orchestrator patterns

## Detailed File List

### High Priority (Command Infrastructure)

1. **`.opencode/command/task.md`**
   - Action: Rename to implement.md OR verify implement.md is current
   - References: Header, examples, documentation
   - Impact: CRITICAL - Primary command definition

2. **`.opencode/command/README.md`**
   - Line 1: Command table entry
   - Pattern: `| /task | orchestrator | 2 | Execute TODO tasks (batch-aware) |`
   - Replacement: `| /implement | orchestrator | 2 | Execute TODO tasks (batch-aware) |`

3. **`.opencode/command/implement.md`**
   - Current status: File exists
   - Action: Verify this is the correct/current version
   - Check: May already be renamed from task.md

4. **`.opencode/agent/orchestrator.md`**
   - Line 66: `Triggers: "/task {number(s)}"`
   - Line 67: `Agent: @subagents/task-executor`
   - Update: Change trigger to "/implement {number(s)}"

### Medium Priority (Agent Files)

5. **`.opencode/agent/subagents/task-executor.md`**
   - Line 56: Example `"59" from "/task 59"`
   - Line 196: Comment about /task normalization
   - Update: All /task references to /implement

6. **`.opencode/agent/subagents/batch-task-orchestrator.md`**
   - Line 51: `Task numbers list received from /task command`
   - Line 54: `pre-normalized from /task range/list parsing`
   - Line 333: `Recommendation: Fix task {blocking_task} first, then run /task {num}`
   - Line 381: `"Create missing file and re-run /task 64"`
   - Line 394: `"Fix error in Task 64 and re-run: /task 64"`
   - Line 424: `If Task 64 is NOT STARTED: Warn user, recommend /task 64 first`
   - Update: All /task references to /implement

### Medium Priority (Documentation)

7. **`.opencode/README.md`**
   - Line 28: `### Basic workflow: /add → /research → /plan → /task`
   - Line 47: `4. **Execute the TODO via /task**`
   - Line 49: `/task 001`
   - Line 77: `- /task {task_number} - Execute TODO task`
   - Line 103: `/task and /implement reuse the plan link`
   - Line 123: `/task and /implement update linked plan phases`
   - Update: All /task references to /implement

8. **`.opencode/QUICK-START.md`**
   - Line 428: `/task 63           # Execute task #63`
   - Update: Change to /implement

9. **`.opencode/SYSTEM_SUMMARY.md`**
   - Line 50: `/plan and /revise reuse linked research inputs; /task and /implement reuse the plan path`
   - Line 60: `| /task | task-executor | plan phases + emitted artifacts |`
   - Line 73: `/task and /implement update the linked plan phases`
   - Line 74: `Follow [context/core/standards/tasks.md]`
   - Line 106: `| /task {description} | Execute generic task | task-executor |`
   - Update: All /task references to /implement

### Medium Priority (Standards & Context)

10. **`.opencode/context/core/standards/tasks.md`**
    - Multiple references to /task workflow
    - Update: All /task references to /implement

11. **`.opencode/context/core/standards/commands.md`**
    - Command standards referencing /task
    - Update: All /task references to /implement

12. **`.opencode/context/core/workflows/task-breakdown.md`**
    - Workflow patterns using /task
    - Update: All /task references to /implement

### Low Priority (Spec Files)

13. **`.opencode/specs/TODO.md`**
    - Line 37: Task 169 description mentions /task → /implement rename
    - Line 47: Acceptance criteria about /task references
    - Update: Ensure consistency with rename

14. **`.opencode/specs/171_gap_analysis_20251224/reports/analysis-001.md`**
    - Line 542: `/add → /research → /plan → /task` workflow
    - Line 577: Integration with /task command
    - Update: All /task references to /implement

15. **`.opencode/specs/research/context-window-protection-and-agent-communication.md`**
    - Multiple references to /task command improvements
    - Update: All /task references to /implement

### Low Priority (Feature Registry & Status)

16. **`Documentation/ProjectInfo/FEATURE_REGISTRY.md`**
    - Multiple /task feature descriptions
    - Update: All /task references to /implement

17. **`Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`**
    - Task status references mentioning /task
    - Update: All /task references to /implement

18. **`Documentation/ProjectInfo/TACTIC_REGISTRY.md`**
    - Standards updated section mentions /task
    - Update: All /task references to /implement

19. **`Documentation/ProjectInfo/SORRY_REGISTRY.md`**
    - Registry update requirements mention /task
    - Update: All /task references to /implement

## Validation Strategy

### Pre-Rename Validation
```bash
# Count all /task references (baseline)
grep -rn "/task" .opencode/ --include="*.md" | grep -v "specs/archive" | wc -l
# Expected: 259

# Verify implement.md exists
ls -la .opencode/command/implement.md
```

### Post-Rename Validation
```bash
# Verify no /task references remain (excluding archives and task 169 specs)
grep -rn "/task" .opencode/ --include="*.md" | grep -v "specs/archive" | grep -v "169_task_command_improvements"
# Expected: 0 results (or only XML closing tags like </task>)

# Verify implement.md exists and task.md is removed
ls -la .opencode/command/task.md      # Should not exist
ls -la .opencode/command/implement.md # Should exist

# Verify all /implement references are functional
grep -rn "/implement" .opencode/ --include="*.md" | wc -l
# Expected: 259+ references
```

### Functional Validation
- Test /implement command invocation
- Verify orchestrator routing works
- Check task-executor receives correct command
- Validate batch-task-orchestrator integration
- Test all documentation examples

## Risk Assessment

### High Risk Areas
1. **Command routing** - Orchestrator must recognize /implement
2. **Agent invocation** - task-executor must handle /implement trigger
3. **User-facing errors** - All error messages must use /implement terminology

### Medium Risk Areas
1. **Documentation consistency** - All examples must use /implement
2. **Workflow descriptions** - All workflow diagrams/text must update
3. **Standards compliance** - All standards must reference /implement

### Low Risk Areas
1. **Archive files** - No updates needed (historical reference)
2. **Spec files** - Can be updated gradually
3. **Comments** - Internal comments can reference old name with note

## Rollback Plan

If rename causes issues:
1. Revert all file changes via git
2. Restore task.md from implement.md if renamed
3. Update TODO.md task 169 status to [BLOCKED]
4. Document specific failure mode
5. Create new task for addressing issues

## Coordination Requirements

### Phase 1b Dependencies
- Must complete Phase 1a (schema definition) first
- All consumers must be updated before producers change
- Single atomic commit for all rename changes
- Feature branch required until validation complete

### Testing Requirements
- Unit test: Command recognition
- Integration test: Full workflow execution
- Regression test: All existing functionality
- User acceptance test: Documentation examples

## Estimated Effort

- File rename: 5 minutes
- Reference updates: 1.5 hours (80+ files)
- Validation: 30 minutes
- Testing: 30 minutes
- **Total**: 2.5 hours

## Completion Criteria

- [x] All /task references catalogued
- [x] Update strategy defined
- [x] Validation plan created
- [x] Risk assessment complete
- [ ] All files updated (Phase 1b)
- [ ] Validation passed (Phase 1b)
- [ ] Tests passed (Phase 7)
