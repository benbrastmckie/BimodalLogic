# Implementation Plan: Remove Redundant Project-Level state.json Files

## Metadata

- **Task**: 276 - Investigate and remove redundant project-level state.json files in favor of centralized specs/state.json
- **Status**: [PLANNED]
- **Created**: 2026-01-03
- **Estimated Effort**: 8 hours
- **Complexity**: Medium
- **Language**: markdown
- **Priority**: Medium
- **Research Integrated**: Yes
- **Research Report**: [research-001.md](../reports/research-001.md)

## Overview

### Problem Statement

The system currently maintains duplicate state information in two locations:
1. Central state file: `specs/state.json` (authoritative, queried by all commands)
2. Project-level state files: `specs/{number}_{slug}/state.json` (write-only, never read)

Research findings confirm that project-level state.json files are redundant:
- **Zero reads found**: No command or agent reads project-level state.json
- **Duplicate data**: All information is already tracked in central state.json
- **Performance overhead**: 33% additional file I/O (3 files vs 2 files per status update)
- **Maintenance burden**: Two sources of truth, schema drift, synchronization complexity

### Scope

**In Scope**:
- Remove project-level state.json creation from status-sync-manager
- Update all subagent specifications to remove project-level state.json references
- Update state-management.md and artifact-management.md standards
- Test all commands (/research, /plan, /implement) to verify correct behavior
- Document migration in ADR-004

**Out of Scope**:
- Deletion of existing project-level state.json files (backward-compatible migration)
- Changes to central state.json schema (no enhancement needed)
- External tool compatibility (none found in research)

### Constraints

- Must maintain backward compatibility (existing files left in place)
- Must not break atomic update protocol for TODO.md and central state.json
- Must preserve all functionality of status-sync-manager
- Must follow status-markers.md standard (text-based status indicators)

### Definition of Done

- [ ] status-sync-manager.md updated to skip project state.json creation
- [ ] All 7 subagent specifications updated to remove project state.json references
- [ ] state-management.md updated to remove project state.json schema
- [ ] artifact-management.md updated to reference central state.json only
- [ ] ADR-004 created documenting migration decision
- [ ] All tests pass: /research, /plan, /implement commands work correctly
- [ ] No project-level state.json files created for new tasks
- [ ] Central state.json and TODO.md still updated correctly
- [ ] Git commit created with all changes

## Goals and Non-Goals

### Goals

1. Simplify state management by eliminating redundant project-level state.json files
2. Reduce file I/O overhead by 33% (3 files → 2 files per status update)
3. Eliminate two sources of truth for project state
4. Improve atomic update protocol reliability (fewer files = fewer failure points)
5. Document migration decision for future reference

### Non-Goals

1. Delete existing project-level state.json files (backward-compatible approach)
2. Enhance central state.json with structured artifact metadata (research shows not needed)
3. Change central state.json schema version (no schema changes required)
4. Create cleanup script for existing files (deferred to future task if needed)

## Risks and Mitigations

### Risk 1: Undiscovered Reads

**Description**: Project-level state.json may be read by external tools not found in research.

**Likelihood**: Low  
**Impact**: Medium

**Mitigation**:
- Research performed comprehensive search (rg, grep, find) - zero reads found
- Backward-compatible migration: existing files left in place
- If external tool discovered post-migration: can restore project state.json creation
- Monitor for issues in first 2 weeks after deployment

### Risk 2: Rollback Mechanism Changes

**Description**: Removing project state.json from rollback may introduce bugs.

**Likelihood**: Low  
**Impact**: Medium

**Mitigation**:
- status-sync-manager already handles variable file counts
- 2-file rollback (TODO.md + state.json) is simpler than 3-file
- Comprehensive testing of rollback scenarios in Phase 5
- Existing rollback mechanism is well-tested

### Risk 3: Schema Evolution Needs

**Description**: Future features may require project-level state.json.

**Likelihood**: Low  
**Impact**: Low

**Mitigation**:
- Central state.json is extensible (schema version 1.1.0)
- Can add fields to central state.json if needed
- Project-level state.json can be re-introduced if truly necessary
- Current analysis shows no unique value in project-level state

## Implementation Phases

### Phase 1: Update status-sync-manager Specification [NOT STARTED]

**Estimated Effort**: 2 hours

**Objective**: Remove project-level state.json creation from status-sync-manager.

**Tasks**:
1. Read `.opencode/agent/subagents/status-sync-manager.md`
2. Remove Step 1 line: "Read project state.json if exists"
3. Remove Step 3 section: "Create or update project state.json"
4. Remove Step 5 lines: "Write project state.json" and verification
5. Update rollback mechanism to handle 2 files instead of 3
6. Update constraints section to remove project state.json requirement
7. Update validation checks to remove project state.json verification
8. Update error handling to remove project state.json rollback

**Acceptance Criteria**:
- [ ] status-sync-manager.md no longer references project state.json
- [ ] Rollback mechanism updated for 2-file atomic updates
- [ ] All constraints and validation checks updated
- [ ] Specification remains internally consistent

**Dependencies**: None

---

### Phase 2: Update Subagent Specifications [NOT STARTED]

**Estimated Effort**: 2.5 hours

**Objective**: Remove project-level state.json references from all subagent specifications.

**Tasks**:
1. Update `.opencode/agent/subagents/researcher.md`:
   - Remove project state.json references in Stage 7 (Postflight)
   - Update delegation context for status-sync-manager (remove project state fields)
2. Update `.opencode/agent/subagents/planner.md`:
   - Remove project state.json references in Stage 7 (Postflight)
   - Update delegation context for status-sync-manager
3. Update `.opencode/agent/subagents/implementer.md`:
   - Remove project state.json references in Stage 7 (Postflight)
   - Update delegation context for status-sync-manager
4. Update `.opencode/agent/subagents/lean-research-agent.md`:
   - Remove project state.json references
5. Update `.opencode/agent/subagents/lean-implementation-agent.md`:
   - Remove project state.json references
6. Update `.opencode/agent/subagents/lean-planner.md`:
   - Remove project state.json references
7. Update `.opencode/agent/subagents/reviewer.md`:
   - Remove project state.json references

**Acceptance Criteria**:
- [ ] All 7 subagent specifications updated
- [ ] No references to project-level state.json remain
- [ ] Delegation contexts updated to match new status-sync-manager interface
- [ ] All specifications remain internally consistent

**Dependencies**: Phase 1 (status-sync-manager updated first)

---

### Phase 3: Update Standards Documentation [NOT STARTED]

**Estimated Effort**: 1.5 hours

**Objective**: Update state-management.md and artifact-management.md to reflect removal of project-level state.json.

**Tasks**:
1. Update `.opencode/context/core/system/state-management.md`:
   - Remove "Project State File" schema section (lines 273-298)
   - Update "Multi-File Synchronization" section (remove project state.json)
   - Update "Atomic Update Requirement" section (2 files instead of 3)
   - Update examples to show only TODO.md and central state.json
   - Update schema version if needed
2. Update `.opencode/context/core/system/artifact-management.md`:
   - Update artifact tracking to reference central state.json only
   - Remove any references to project-level state.json
   - Update examples to use central state.json

**Acceptance Criteria**:
- [ ] state-management.md no longer documents project state.json schema
- [ ] Multi-file synchronization updated to 2 files
- [ ] artifact-management.md references central state.json only
- [ ] All examples updated and consistent

**Dependencies**: Phase 1 (status-sync-manager updated first)

---

### Phase 4: Create ADR-004 Documentation [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Document migration decision in Architecture Decision Record.

**Tasks**:
1. Create `docs/architecture/ADR-004-Remove-Project-Level-State-Files.md`
2. Document context: duplicate data, write-only overhead, schema drift
3. Document decision: remove project-level state.json creation, use central state.json only
4. Document consequences: simplifies state management, reduces file I/O, eliminates two sources of truth
5. Document migration approach: backward-compatible removal, existing files left in place
6. Reference research findings from task 276
7. Include performance metrics: 33% reduction in file I/O, 260KB savings

**Acceptance Criteria**:
- [ ] ADR-004 created following ADR template
- [ ] Context, decision, and consequences clearly documented
- [ ] Migration approach explained
- [ ] Research findings referenced
- [ ] Performance metrics included

**Dependencies**: None (can be done in parallel with other phases)

---

### Phase 5: Testing and Validation [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Verify all commands work correctly without project-level state.json creation.

**Tasks**:
1. Test `/research` command on new task:
   - Verify no project-level state.json created
   - Verify central state.json updated correctly
   - Verify TODO.md updated correctly
   - Verify research report created successfully
2. Test `/plan` command on researched task:
   - Verify no project-level state.json created
   - Verify central state.json updated correctly
   - Verify TODO.md updated correctly
   - Verify implementation plan created successfully
3. Test `/implement` command on planned task:
   - Verify no project-level state.json created
   - Verify central state.json updated correctly
   - Verify TODO.md updated correctly
   - Verify implementation summary created successfully
4. Test rollback scenario:
   - Simulate status update failure
   - Verify rollback restores TODO.md and central state.json
   - Verify no orphaned files created
5. Verify existing project-level state.json files not affected:
   - Check that existing files remain in place
   - Verify no accidental deletions

**Acceptance Criteria**:
- [ ] All commands work correctly without project-level state.json
- [ ] Central state.json updated correctly for all commands
- [ ] TODO.md updated correctly for all commands
- [ ] Rollback mechanism works correctly
- [ ] Existing project-level state.json files unchanged
- [ ] No errors or warnings in command output

**Dependencies**: Phases 1, 2, 3 (all specifications updated)

---

## Testing and Validation

### Unit Testing

**Not applicable** - This task updates specifications and documentation, not code.

### Integration Testing

**Test Scenario 1**: Create new research task
- Command: `/research {new_task_number}`
- Expected: Research report created, central state.json updated, TODO.md updated, NO project state.json created
- Validation: Check `specs/{number}_{slug}/` directory for absence of state.json

**Test Scenario 2**: Create implementation plan
- Command: `/plan {researched_task_number}`
- Expected: Plan created, central state.json updated, TODO.md updated, NO project state.json created
- Validation: Check `specs/{number}_{slug}/` directory for absence of state.json

**Test Scenario 3**: Execute implementation
- Command: `/implement {planned_task_number}`
- Expected: Implementation summary created, central state.json updated, TODO.md updated, NO project state.json created
- Validation: Check `specs/{number}_{slug}/` directory for absence of state.json

**Test Scenario 4**: Rollback on failure
- Simulate: Force status update failure (e.g., make TODO.md read-only)
- Expected: Rollback restores TODO.md and central state.json to previous state
- Validation: Verify no partial updates, no orphaned files

### Manual Validation

1. **File count verification**:
   ```bash
   # Before migration: 62 project-level state.json files
   find .opencode/specs -name "state.json" -type f | grep -v "^\specs/state\.json$" | wc -l
   
   # After migration: Same 62 files (backward-compatible)
   # After new task: Still 62 files (no new files created)
   ```

2. **Central state.json integrity**:
   ```bash
   # Verify central state.json is valid JSON
   jq . specs/state.json > /dev/null
   
   # Verify active_projects array populated
   jq '.active_projects | length' specs/state.json
   ```

3. **TODO.md integrity**:
   ```bash
   # Verify TODO.md has correct status markers
   grep -E "\[RESEARCHED\]|\[PLANNED\]|\[COMPLETED\]" specs/TODO.md
   ```

## Artifacts and Outputs

### Primary Artifacts

1. **Updated Specifications** (8 files):
   - `.opencode/agent/subagents/status-sync-manager.md`
   - `.opencode/agent/subagents/researcher.md`
   - `.opencode/agent/subagents/planner.md`
   - `.opencode/agent/subagents/implementer.md`
   - `.opencode/agent/subagents/lean-research-agent.md`
   - `.opencode/agent/subagents/lean-implementation-agent.md`
   - `.opencode/agent/subagents/lean-planner.md`
   - `.opencode/agent/subagents/reviewer.md`

2. **Updated Standards** (2 files):
   - `.opencode/context/core/system/state-management.md`
   - `.opencode/context/core/system/artifact-management.md`

3. **Architecture Decision Record**:
   - `docs/architecture/ADR-004-Remove-Project-Level-State-Files.md`

### Supporting Artifacts

- Implementation plan: `specs/276_investigate_remove_redundant_project_level_state_json/plans/implementation-001.md` (this file)
- Research report: `specs/276_investigate_remove_redundant_project_level_state_json/reports/research-001.md` (already exists)

## Rollback/Contingency

### Rollback Plan

If issues are discovered post-migration:

1. **Immediate rollback** (if critical issues found):
   - Revert status-sync-manager.md to previous version
   - Revert all subagent specifications to previous versions
   - Revert standards documentation to previous versions
   - Project-level state.json creation will resume

2. **Partial rollback** (if specific command affected):
   - Identify affected command (e.g., /research)
   - Revert only that command's subagent specification
   - Keep other changes in place

3. **Forward fix** (if minor issues found):
   - Update status-sync-manager.md to address issue
   - No full rollback needed

### Contingency Scenarios

**Scenario 1**: External tool discovered that reads project-level state.json
- **Action**: Restore project state.json creation in status-sync-manager
- **Timeline**: 1 hour to revert changes
- **Impact**: Low - backward-compatible migration means existing files still present

**Scenario 2**: Rollback mechanism fails after migration
- **Action**: Debug rollback logic in status-sync-manager
- **Timeline**: 2-3 hours to fix
- **Impact**: Medium - may affect status updates temporarily

**Scenario 3**: Schema drift issues discovered
- **Action**: Enhance central state.json schema if needed
- **Timeline**: 3-4 hours to add fields and migrate data
- **Impact**: Low - central state.json is extensible

## Success Metrics

### Performance Metrics

1. **File I/O reduction**:
   - Before: 3 files per status update (TODO.md, central state.json, project state.json)
   - After: 2 files per status update (TODO.md, central state.json)
   - **Target**: 33% reduction in file I/O operations

2. **Disk space savings**:
   - Current: 260KB across 62 project-level state.json files
   - After migration: 0KB for new projects (existing files remain)
   - **Target**: 0 bytes added for new projects

3. **Atomic update time**:
   - Before: Read 3 files, backup 3 files, write 3 files, verify 3 files
   - After: Read 2 files, backup 2 files, write 2 files, verify 2 files
   - **Target**: Measurable reduction in status update duration

### Functional Metrics

1. **Command success rate**:
   - **Target**: 100% success rate for /research, /plan, /implement commands
   - **Measurement**: Test 5 tasks through full lifecycle

2. **Rollback success rate**:
   - **Target**: 100% success rate for rollback scenarios
   - **Measurement**: Test 3 rollback scenarios (TODO.md failure, state.json failure, both)

3. **Data consistency**:
   - **Target**: 100% consistency between TODO.md and central state.json
   - **Measurement**: Verify status markers match state.json for all active projects

### Quality Metrics

1. **Specification consistency**:
   - **Target**: Zero references to project-level state.json in specifications
   - **Measurement**: grep search across all .md files in .opencode/

2. **Documentation completeness**:
   - **Target**: ADR-004 created with all required sections
   - **Measurement**: Manual review against ADR template

3. **Backward compatibility**:
   - **Target**: Zero breaking changes for existing projects
   - **Measurement**: Verify existing project-level state.json files unchanged

## Notes

### Research Findings Summary

Research (task 276, research-001.md) confirmed:
- **Zero reads**: Comprehensive search found no reads of project-level state.json
- **Write-only pattern**: status-sync-manager reads for backup only, never uses data
- **Duplicate data**: All information in project-level state.json is in central state.json
- **Schema drift**: Project-level state.json has inconsistent schema across projects
- **Performance cost**: 33% file I/O overhead, 260KB redundant data

### Migration Philosophy

**Backward-compatible approach**:
- Existing project-level state.json files left in place (no deletion)
- No breaking changes for archived projects
- Future cleanup can remove files if needed (deferred to separate task)

**Rationale**:
- Existing files don't cause harm (just unused)
- Avoids risk of breaking archived projects or external tools
- Simplifies migration (no data migration needed)

### Future Considerations

**Optional cleanup task** (deferred):
- Create script to remove existing project-level state.json files
- Run after migration validated (2+ weeks)
- Keep archived project state.json files (in archive/ directory)
- Estimated effort: 1 hour

**Schema evolution** (if needed):
- Central state.json is extensible (schema version 1.1.0)
- Can add fields if future features require additional metadata
- Project-level state.json can be re-introduced if truly necessary
