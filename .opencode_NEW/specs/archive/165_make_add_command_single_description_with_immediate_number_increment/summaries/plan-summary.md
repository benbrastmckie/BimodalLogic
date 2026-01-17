# Plan Summary: Make /add Command Single-Description with Immediate Number Increment

**Version**: 001  
**Complexity**: Moderate  
**Estimated Effort**: 2-3 hours

## Key Steps

1. **Orchestrator Number Allocation**: Move atomic number allocation from task-adder subagent to /add orchestrator Preflight stage for immediate user feedback before delegation

2. **Metadata Auto-Population**: Implement comprehensive auto-population in task-adder with sensible defaults (Priority=Medium, Language=markdown, Effort=inferred, etc.) and inference algorithms for effort, acceptance criteria, and impact statements

3. **Simplified Input Parsing**: Update /add command to accept single description argument, remove all other required metadata inputs, support optional --file flag for Files Affected override

4. **Documentation and Testing**: Update command documentation (add.md), standards documentation (tasks.md, commands.md), and comprehensive testing (unit, integration, regression, user acceptance)

## Dependencies

- **atomic-task-numberer subagent**: Already exists and correct (no changes needed)
- **task-adder subagent**: Requires modification to accept pre-allocated number and implement auto-population
- **state.json**: Already supports atomic increment (no changes needed)
- **TODO.md**: Updated by implementation (no schema changes)

## Success Criteria

- 90% reduction in required user input (10+ fields → 1 field)
- Immediate task number feedback (allocated before delegation)
- All metadata fields auto-populated with sensible defaults
- Atomic numbering preserved (no duplicate numbers, no race conditions)
- Lazy directory creation preserved (no project directories created)
- State consistency maintained (state.json and TODO.md in sync)

## Full Plan

See: `specs/165_make_add_command_single_description_with_immediate_number_increment/plans/implementation-001.md`
