# Implementation Plan: Add Standardized YAML Header to TODO.md with state.json Metadata

## Metadata

- **Task**: 272 - Add standardized YAML header to TODO.md with state.json metadata
- **Status**: [NOT STARTED]
- **Estimated Effort**: 14 hours
- **Language**: markdown, bash, python
- **Priority**: Medium
- **Complexity**: Medium
- **Research Integrated**: Yes
- **Research Report**: [research-001.md](../reports/research-001.md)
- **Created**: 2026-01-03
- **Last Updated**: 2026-01-03

---

## Overview

### Problem Statement

Users must manually inspect state.json to understand project health, task distribution, and technical debt. This creates friction and reduces visibility into repository status. Currently, TODO.md has a simple text header with only a "Last Updated" timestamp, while state.json contains rich metadata (repository health, task counts, technical debt) that is hidden from users.

### Scope

This implementation will:
1. Design and implement a standardized YAML header format for TODO.md
2. Implement header regeneration logic in status-sync-manager
3. Update TODO.md with initial YAML header
4. Add manual refresh capability to /todo command
5. Update context files to document the YAML header format and synchronization requirements
6. Test header synchronization across all workflow commands

### Constraints

- YAML header must be compact (fit in ~20 lines)
- Header regeneration must be atomic with state.json updates
- Must not break existing TODO.md parsing or workflow commands
- Must gracefully handle missing state.json fields
- Must preserve TODO.md task list body during header updates

### Definition of Done

- [ ] YAML header schema implemented and documented
- [ ] status-sync-manager regenerates header on every state.json update
- [ ] TODO.md contains YAML header with current state.json metadata
- [ ] /todo command supports --refresh-header flag
- [ ] Context files updated with YAML header format specification
- [ ] All workflow commands tested for header synchronization
- [ ] Manual edits warning added to header
- [ ] Atomic write pattern implemented with rollback capability

---

## Goals and Non-Goals

### Goals

1. Surface key state.json metadata in TODO.md YAML header
2. Automatic header synchronization on every state.json update
3. Manual header refresh capability for troubleshooting
4. Comprehensive documentation in context files
5. Graceful error handling for missing fields
6. Atomic updates to prevent corruption

### Non-Goals

1. Configurable field selection (use fixed schema)
2. YAML header in other markdown files (TODO.md only)
3. Backward compatibility with old TODO.md format (one-time migration)
4. Real-time header updates (batch updates acceptable)
5. YAML validation in downstream tools (assume standard parsers)

---

## Risks and Mitigations

### Risk 1: Header Regeneration Overwrites Manual Edits

**Severity**: Medium  
**Likelihood**: Low  
**Impact**: Users manually edit TODO.md header, changes lost on next update

**Mitigation**:
- Add warning comment in header: `# Auto-generated from state.json - do not edit manually`
- Document in context files: "Do not manually edit YAML header"
- Users should edit state.json, not TODO.md header

### Risk 2: Missing state.json Fields Cause Header Generation Failure

**Severity**: Medium  
**Likelihood**: Low  
**Impact**: Header regeneration fails if state.json missing expected fields

**Mitigation**:
- Implement graceful degradation: Use default values or omit field if missing
- Log warning but don't fail
- Test with incomplete state.json to verify graceful handling

### Risk 3: Concurrent Updates Cause Header Corruption

**Severity**: High  
**Likelihood**: Very Low  
**Impact**: Concurrent TODO.md updates could corrupt header

**Mitigation**:
- Use atomic write pattern: temp file + rename
- status-sync-manager two-phase commit prevents partial updates
- Test concurrent updates to verify atomicity

### Risk 4: Breaking Existing Workflow Commands

**Severity**: High  
**Likelihood**: Low  
**Impact**: Workflow commands fail after header implementation

**Mitigation**:
- Comprehensive testing across all workflow commands
- Backward-compatible header parsing (handle missing header)
- Rollback plan: Remove header if issues detected

---

## Implementation Phases

### Phase 1: Design and Validate YAML Header Schema [NOT STARTED]

**Estimated Effort**: 2 hours

**Objectives**:
- Finalize YAML header schema based on research findings
- Validate schema with sample data from state.json
- Document field selection rationale

**Tasks**:
1. Review research report YAML header design (Section 1)
2. Extract current state.json to validate field availability
3. Create sample YAML header with real data
4. Validate YAML syntax with PyYAML parser
5. Document schema in phase artifact

**Acceptance Criteria**:
- YAML header schema documented with all fields specified
- Sample header validates with PyYAML
- All required state.json fields exist and accessible
- Schema fits in ~20 lines

**Artifacts**:
- `272_add_yaml_header_to_todo_md/artifacts/yaml-header-schema.md`

---

### Phase 2: Implement Header Regeneration in status-sync-manager [NOT STARTED]

**Estimated Effort**: 4 hours

**Objectives**:
- Add header regeneration function to status-sync-manager
- Implement atomic write pattern with rollback
- Handle missing fields gracefully

**Tasks**:
1. Read current status-sync-manager.md context file
2. Design `regenerate_yaml_header()` function specification
3. Implement header regeneration algorithm (per research pseudocode)
4. Add atomic write pattern: temp file + rename
5. Implement graceful degradation for missing fields
6. Add error logging for header regeneration failures
7. Update status-sync-manager.md with new function
8. Add warning comment to generated header

**Acceptance Criteria**:
- `regenerate_yaml_header()` function implemented in status-sync-manager
- Function reads state.json and generates valid YAML header
- Atomic write pattern prevents partial updates
- Missing fields handled gracefully (default values or omit)
- Error logging captures regeneration failures
- Warning comment added: `# Auto-generated from state.json - do not edit manually`

**Artifacts**:
- Updated `.opencode/context/core/subagents/status-sync-manager.md`

---

### Phase 3: Update TODO.md with Initial YAML Header [NOT STARTED]

**Estimated Effort**: 2 hours

**Objectives**:
- Generate initial YAML header from current state.json
- Update TODO.md with header
- Verify header parsing and display

**Tasks**:
1. Read current state.json
2. Generate YAML header using schema from Phase 1
3. Backup current TODO.md
4. Prepend YAML frontmatter to TODO.md (before `# TODO` heading)
5. Verify YAML header displays correctly in markdown viewers
6. Test TODO.md parsing with existing workflow commands
7. Commit updated TODO.md

**Note**: YAML frontmatter must be at the very beginning of the file, before any markdown content including the `# TODO` heading. This follows standard YAML frontmatter format used by Jekyll, Hugo, and other static site generators.

**Acceptance Criteria**:
- TODO.md contains valid YAML header with current state.json data
- Header displays correctly in markdown viewers (VS Code, GitHub)
- Existing workflow commands parse TODO.md without errors
- Backup of old TODO.md preserved
- Git commit created with descriptive message

**Artifacts**:
- Updated `.opencode/specs/TODO.md`
- Backup: `.opencode/specs/TODO.md.backup-20260103`

---

### Phase 4: Add Manual Refresh Capability to /todo Command [NOT STARTED]

**Estimated Effort**: 2 hours

**Objectives**:
- Add --refresh-header flag to /todo command
- Implement manual header regeneration
- Document flag in command help

**Tasks**:
1. Read current /todo command implementation
2. Add `--refresh-header` flag to argument parsing
3. Call status-sync-manager.regenerate_yaml_header() when flag set
4. Add help text for --refresh-header flag
5. Test manual header refresh with /todo --refresh-header
6. Update command documentation

**Acceptance Criteria**:
- /todo --refresh-header flag implemented
- Flag triggers header regeneration from state.json
- Help text documents --refresh-header usage
- Manual refresh tested and working
- Command documentation updated

**Artifacts**:
- Updated `.opencode/context/core/commands/todo.md`

---

### Phase 5: Update Context Files with YAML Header Documentation [NOT STARTED]

**Estimated Effort**: 2 hours

**Objectives**:
- Document YAML header format in tasks.md
- Document synchronization requirements in state-management.md
- Document TODO.md structure in artifact-management.md

**Tasks**:
1. Update tasks.md: Add "TODO.md YAML Header Format" section
   - Specify required fields and format
   - Document field selection rationale
   - Add example header
2. Update state-management.md: Add "TODO.md YAML Header Synchronization" section
   - Specify when header must be updated
   - Document regeneration algorithm
   - Document atomic update requirements
3. Update artifact-management.md: Add "TODO.md Structure" section
   - Specify YAML header + task list body format
   - Explain header vs body separation
   - Document manual edit warnings

**Acceptance Criteria**:
- tasks.md contains "TODO.md YAML Header Format" section
- state-management.md contains "TODO.md YAML Header Synchronization" section
- artifact-management.md contains "TODO.md Structure" section
- All sections include examples and rationale
- Documentation follows context file standards

**Artifacts**:
- Updated `.opencode/context/core/standards/tasks.md`
- Updated `.opencode/context/core/system/state-management.md`
- Updated `.opencode/context/core/system/artifact-management.md`

---

### Phase 6: Test Header Synchronization Across Workflow Commands [NOT STARTED]

**Estimated Effort**: 2 hours

**Objectives**:
- Test header synchronization with all workflow commands
- Verify atomic updates
- Validate error handling

**Tasks**:
1. Test /research: Verify header updated when task marked [RESEARCHED]
2. Test /plan: Verify header updated when task marked [PLANNED]
3. Test /revise: Verify header updated when plan revised
4. Test /implement: Verify header updated when task marked [COMPLETED]
5. Test /review: Verify header updated when review completed
6. Test /todo: Verify header updated when tasks archived
7. Test /task: Verify header updated when task created
8. Test concurrent updates (if possible)
9. Test missing state.json fields (graceful degradation)
10. Document test results

**Acceptance Criteria**:
- All workflow commands update header correctly
- Header reflects latest state.json after each command
- Atomic updates verified (no partial updates)
- Graceful degradation tested with missing fields
- Concurrent update handling verified
- Test results documented

**Artifacts**:
- `272_add_yaml_header_to_todo_md/artifacts/test-results.md`

---

## Testing and Validation

### Unit Tests

1. **YAML Header Generation**:
   - Test header generation with complete state.json
   - Test header generation with missing fields (graceful degradation)
   - Test YAML syntax validation
   - Test field extraction from state.json

2. **Header Replacement**:
   - Test header replacement in TODO.md with existing header
   - Test header prepending to TODO.md without header
   - Test atomic write pattern (temp file + rename)
   - Test rollback on write failure

3. **status-sync-manager Integration**:
   - Test header regeneration called after state.json update
   - Test atomic update: header + task entry + state.json
   - Test error handling for regeneration failures

### Integration Tests

1. **Workflow Command Integration**:
   - Test /research updates header
   - Test /plan updates header
   - Test /revise updates header
   - Test /implement updates header
   - Test /review updates header
   - Test /todo updates header
   - Test /task updates header

2. **Manual Refresh**:
   - Test /todo --refresh-header flag
   - Test manual refresh after manual state.json edit

3. **Error Scenarios**:
   - Test missing state.json
   - Test corrupted state.json
   - Test missing TODO.md
   - Test concurrent updates

### Validation Criteria

- [ ] YAML header validates with PyYAML parser
- [ ] Header displays correctly in markdown viewers
- [ ] All workflow commands update header atomically
- [ ] Graceful degradation works for missing fields
- [ ] Manual refresh works correctly
- [ ] No data loss during header updates
- [ ] Atomic write pattern prevents corruption

---

## Artifacts and Outputs

### Primary Artifacts

1. **YAML Header Schema**: `272_add_yaml_header_to_todo_md/artifacts/yaml-header-schema.md`
   - Field specifications
   - Format examples
   - Rationale documentation

2. **Updated TODO.md**: `.opencode/specs/TODO.md`
   - YAML header with current state.json metadata
   - Preserved task list body

3. **Updated status-sync-manager**: `.opencode/context/core/subagents/status-sync-manager.md`
   - `regenerate_yaml_header()` function
   - Atomic update logic

4. **Updated /todo Command**: `.opencode/context/core/commands/todo.md`
   - `--refresh-header` flag
   - Help text

5. **Updated Context Files**:
   - `.opencode/context/core/standards/tasks.md`
   - `.opencode/context/core/system/state-management.md`
   - `.opencode/context/core/system/artifact-management.md`

### Supporting Artifacts

1. **Test Results**: `272_add_yaml_header_to_todo_md/artifacts/test-results.md`
   - Workflow command test results
   - Error scenario test results
   - Validation results

2. **TODO.md Backup**: `.opencode/specs/TODO.md.backup-20260103`
   - Backup before header implementation

---

## Rollback/Contingency

### Rollback Plan

If header implementation causes issues:

1. **Immediate Rollback**:
   - Restore TODO.md from backup: `TODO.md.backup-20260103`
   - Revert status-sync-manager changes
   - Revert /todo command changes
   - Revert context file changes

2. **Partial Rollback**:
   - Keep YAML header in TODO.md but disable automatic regeneration
   - Manual header updates only via /todo --refresh-header
   - Investigate and fix issues before re-enabling automatic regeneration

### Contingency Plan

If header regeneration fails:

1. **Graceful Degradation**:
   - Log error to errors.json
   - Continue with state.json update (don't fail entire operation)
   - Manual header refresh via /todo --refresh-header

2. **Manual Recovery**:
   - User manually edits TODO.md header
   - User runs /todo --refresh-header to regenerate from state.json

### Validation Before Commit

- [ ] YAML header validates with PyYAML
- [ ] TODO.md parses correctly with existing commands
- [ ] state.json and TODO.md in sync
- [ ] No workflow command failures
- [ ] Backup created before changes

---

## Success Metrics

### Quantitative Metrics

1. **Header Synchronization Rate**: 100% of state.json updates trigger header regeneration
2. **Atomic Update Success Rate**: 100% of updates are atomic (no partial updates)
3. **Graceful Degradation Rate**: 100% of missing field scenarios handled gracefully
4. **Workflow Command Success Rate**: 100% of workflow commands update header correctly

### Qualitative Metrics

1. **User Visibility**: Users can view repository health without inspecting state.json
2. **Maintainability**: Header regeneration logic centralized in status-sync-manager
3. **Reliability**: Atomic updates prevent corruption
4. **Documentation Quality**: Context files clearly document YAML header format and synchronization

### Acceptance Criteria

- [ ] YAML header visible in TODO.md with current state.json metadata
- [ ] All workflow commands update header automatically
- [ ] Manual refresh works via /todo --refresh-header
- [ ] Context files document YAML header format
- [ ] No workflow command failures
- [ ] No data loss or corruption
- [ ] Test results show 100% success rate

---

## Dependencies

### Internal Dependencies

- status-sync-manager.md (must be updated for header regeneration)
- /todo command (must be updated for manual refresh)
- state.json (source of metadata)
- TODO.md (target for YAML header)

### External Dependencies

- PyYAML or equivalent YAML parser (for validation)
- Markdown viewers (VS Code, GitHub) for header display verification

### Blocking Issues

None identified. All dependencies are internal and under our control.

---

## Notes

### Research Integration

This implementation is based on comprehensive research findings from [research-001.md](../reports/research-001.md), which includes:
- YAML header schema design (Section 1)
- Field selection criteria (Section 2)
- Synchronization mechanism (Section 3)
- Subagent modification requirements (Section 4)
- Implementation complexity analysis (Section 5)
- Header regeneration algorithm pseudocode (Detailed Analysis section)

### Key Design Decisions

1. **YAML vs JSON**: YAML format chosen for human readability and industry standard (Jekyll, Hugo)
2. **Automatic vs Manual**: Hybrid approach (automatic + manual refresh option)
3. **Field Selection**: High-value fields only (compact header, ~20 lines)
4. **Synchronization**: Centralized in status-sync-manager (atomic updates)

### Implementation Notes

- Use atomic write pattern (temp file + rename) to prevent corruption
- Add warning comment to header: `# Auto-generated from state.json - do not edit manually`
- Graceful degradation for missing fields (use defaults or omit)
- Test with incomplete state.json to verify error handling
- Preserve TODO.md task list body during header updates

---

## Revision History

- **v1.0** (2026-01-03): Initial implementation plan created based on research findings
