# Implementation Plan: Remove Performance Cruft from 6 Modified Files

## Metadata

- **Task Number**: 305
- **Task Title**: Remove performance cruft from all 6 modified files (3/5)
- **Status**: [PLANNED]
- **Estimated Effort**: 30 minutes
- **Actual Effort**: TBD
- **Priority**: Medium
- **Language**: markdown
- **Plan Version**: 1
- **Created**: 2026-01-05
- **Last Updated**: 2026-01-05
- **Research Integrated**: Yes
- **Research Report**: [research-001.md](../reports/research-001.md)

---

## Overview

### Problem Statement

During a previous optimization effort (Phase 2), performance-related metadata was added to 6 files that should be removed:
- Optimization sections in YAML frontmatter (5 files)
- Performance blocks in workflow stages (1 file)
- Verbose comments with implementation details (4 files)

This "performance cruft" clutters the code, becomes stale, and doesn't belong in command/agent definitions. Performance documentation should be in dedicated documentation files like state-lookup.md.

### Scope

**In Scope**:
- Remove optimization sections from frontmatter in 5 files (todo.md, review.md, reviewer.md, meta.md, task-creator.md)
- Remove performance block from todo.md Stage 1
- Simplify verbose comments in 4 files to be concise
- Preserve all state-lookup.md documentation changes (valuable reference)

**Out of Scope**:
- Core logic changes in meta.md and task-creator.md (handled in task 307)
- Testing commands (handled in task 308)
- Any functional code changes

### Constraints

- Must preserve all functional code
- Must keep state-lookup.md documentation unchanged
- Must not remove core logic changes (defer to task 307)
- Must maintain consistent comment style across files
- Must follow exact line numbers from research report

### Definition of Done

- [ ] All optimization sections removed from frontmatter (5 files)
- [ ] Performance block removed from todo.md Stage 1
- [ ] All verbose comments simplified to be concise
- [ ] state-lookup.md unchanged (verified)
- [ ] No functional code removed
- [ ] All 5 files updated consistently
- [ ] Changes committed with clear message

---

## Goals and Non-Goals

### Goals

1. Remove all performance cruft from 5 files
2. Simplify verbose comments to be concise and essential
3. Preserve state-lookup.md documentation (no changes)
4. Maintain consistent comment style across files

### Non-Goals

1. Remove core logic changes in meta.md and task-creator.md
2. Test commands after changes (task 308)
3. Verify or revert core logic changes (task 307)
4. Add new documentation

---

## Risks and Mitigations

### Risk 1: Removing Wrong Content

**Likelihood**: Low  
**Impact**: High  
**Mitigation**:
- Follow exact line numbers from research report
- Only remove optimization sections, performance blocks, and verbose comments
- Do NOT remove core logic changes
- Verify changes before committing

### Risk 2: Inconsistent Changes

**Likelihood**: Medium  
**Impact**: Low  
**Mitigation**:
- Use exact patterns from research report
- Verify all 5 files updated consistently
- Check for any remaining "Phase 2 optimization" comments

### Risk 3: Accidentally Modifying state-lookup.md

**Likelihood**: Low  
**Impact**: Low  
**Mitigation**:
- Explicitly verify state-lookup.md unchanged
- No edits to state-lookup.md in any phase

---

## Implementation Phases

### Phase 1: Clean todo.md [NOT STARTED]

**Estimated Effort**: 5 minutes

**Objective**: Remove performance cruft from .opencode/command/todo.md

**Tasks**:
1. Read todo.md to verify current content
2. Remove optimization section from frontmatter (lines 19-22)
3. Remove performance block from Stage 1 (lines 71-78)
4. Simplify comment on line 13: "For fast state.json queries (Phase 2 optimization)" → "Fast state.json queries"
5. Simplify comment on line 16: "State tracking (primary source for task scanning)" → "State tracking"
6. Verify changes correct

**Acceptance Criteria**:
- [ ] Optimization section removed from frontmatter
- [ ] Performance block removed from Stage 1
- [ ] Both comments simplified
- [ ] No functional code changed

**Dependencies**: None

---

### Phase 2: Clean review.md [NOT STARTED]

**Estimated Effort**: 5 minutes

**Objective**: Remove performance cruft from .opencode/command/review.md

**Tasks**:
1. Read review.md to verify current content
2. Remove optimization section from frontmatter (lines 28-31)
3. Simplify comment on line 18: "For fast state.json queries (Phase 2 optimization)" → "Fast state.json queries"
4. Simplify comment on line 22: "Primary source for next_project_number and task queries" → "State tracking"
5. Verify changes correct

**Acceptance Criteria**:
- [ ] Optimization section removed from frontmatter
- [ ] Both comments simplified
- [ ] No functional code changed

**Dependencies**: None

---

### Phase 3: Clean reviewer.md [NOT STARTED]

**Estimated Effort**: 3 minutes

**Objective**: Remove performance cruft from .opencode/agent/subagents/reviewer.md

**Tasks**:
1. Read reviewer.md to verify current content
2. Remove optimization section from frontmatter (lines 32-35)
3. Verify changes correct

**Acceptance Criteria**:
- [ ] Optimization section removed from frontmatter
- [ ] No functional code changed

**Dependencies**: None

---

### Phase 4: Clean meta.md [NOT STARTED]

**Estimated Effort**: 3 minutes

**Objective**: Remove performance cruft from .opencode/agent/subagents/meta.md (optimization section only)

**Tasks**:
1. Read meta.md to verify current content
2. Remove optimization section from frontmatter (lines 31-34)
3. Verify core logic changes NOT removed (Stage 7 task creation logic)
4. Verify changes correct

**Acceptance Criteria**:
- [ ] Optimization section removed from frontmatter
- [ ] Core logic changes preserved (Stage 7)
- [ ] No functional code changed

**Dependencies**: None

**Notes**: Core logic changes in Stage 7 (lines 515-551) are handled in task 307, NOT this task.

---

### Phase 5: Clean task-creator.md [NOT STARTED]

**Estimated Effort**: 5 minutes

**Objective**: Remove performance cruft from .opencode/agent/subagents/task-creator.md

**Tasks**:
1. Read task-creator.md to verify current content
2. Remove optimization section from frontmatter (lines 32-35)
3. Remove optimization block in Step 3 (lines 311-317)
4. Verify core logic changes NOT removed (Step 3 task creation logic)
5. Verify changes correct

**Acceptance Criteria**:
- [ ] Optimization section removed from frontmatter
- [ ] Optimization block removed from Step 3
- [ ] Core logic changes preserved (Step 3)
- [ ] No functional code changed

**Dependencies**: None

**Notes**: Core logic changes in Step 3 (lines 260-318) are handled in task 307, NOT this task.

---

### Phase 6: Verify state-lookup.md Unchanged [NOT STARTED]

**Estimated Effort**: 2 minutes

**Objective**: Verify state-lookup.md documentation preserved

**Tasks**:
1. Verify state-lookup.md not modified in any phase
2. Confirm all Phase 2 patterns (Pattern 5-10) still present
3. Confirm version 1.1 unchanged

**Acceptance Criteria**:
- [ ] state-lookup.md unchanged
- [ ] All Phase 2 patterns present
- [ ] Version 1.1 confirmed

**Dependencies**: Phases 1-5

---

### Phase 7: Final Verification and Commit [NOT STARTED]

**Estimated Effort**: 7 minutes

**Objective**: Verify all changes correct and commit

**Tasks**:
1. Review all 5 modified files for consistency
2. Check for any remaining "Phase 2 optimization" comments
3. Verify no functional code removed
4. Verify state-lookup.md unchanged
5. Create git commit with clear message
6. Update task status to [IMPLEMENTED]

**Acceptance Criteria**:
- [ ] All 5 files updated consistently
- [ ] No remaining performance cruft
- [ ] state-lookup.md unchanged
- [ ] Git commit created
- [ ] Task status updated

**Dependencies**: Phases 1-6

---

## Testing and Validation

### Pre-Implementation Validation

- [ ] Verify all 6 files exist and are readable
- [ ] Verify research report line numbers match current files
- [ ] Verify no uncommitted changes in working directory

### Post-Implementation Validation

- [ ] All optimization sections removed (5 files)
- [ ] Performance block removed (todo.md)
- [ ] All verbose comments simplified (4 files)
- [ ] state-lookup.md unchanged
- [ ] No functional code removed
- [ ] Consistent comment style across files
- [ ] Git commit created successfully

### Testing Strategy

**Manual Testing**:
- Visual inspection of all 5 modified files
- Verify state-lookup.md unchanged
- Check for any remaining "Phase 2 optimization" text

**Automated Testing**:
- None required (documentation changes only)

**Command Testing**:
- Deferred to task 308 (comprehensive testing)

---

## Artifacts and Outputs

### Primary Artifacts

1. **Modified Files** (5 files):
   - `.opencode/command/todo.md` - Optimization section, performance block, comments removed
   - `.opencode/command/review.md` - Optimization section, comments removed
   - `.opencode/agent/subagents/reviewer.md` - Optimization section removed
   - `.opencode/agent/subagents/meta.md` - Optimization section removed
   - `.opencode/agent/subagents/task-creator.md` - Optimization section, optimization block removed

2. **Unchanged File** (1 file):
   - `.opencode/context/core/system/state-lookup.md` - No changes (verified)

3. **Git Commit**:
   - Message: "task 305: remove performance cruft from 5 files"
   - Files: 5 modified files

### Documentation Updates

- None required (this task removes documentation cruft)

---

## Rollback/Contingency

### Rollback Plan

If changes cause issues:
1. Revert git commit: `git revert HEAD`
2. Restore previous versions of all 5 files
3. Document issues in task 305 notes

### Contingency Plan

If line numbers don't match:
1. Search for exact text patterns from research report
2. Manually locate and remove performance cruft
3. Document discrepancies

If unsure about removing content:
1. Preserve content and document uncertainty
2. Defer to task 307 or task 308
3. Do not remove if in doubt

---

## Success Metrics

### Quantitative Metrics

- **Files Modified**: 5 files
- **Files Unchanged**: 1 file (state-lookup.md)
- **Optimization Sections Removed**: 5
- **Performance Blocks Removed**: 1
- **Comments Simplified**: 4
- **Functional Code Removed**: 0

### Qualitative Metrics

- Cleaner, more maintainable code
- Consistent comment style across files
- Reduced clutter in command/agent definitions
- Preserved valuable documentation (state-lookup.md)

### Completion Criteria

- [ ] All performance cruft removed
- [ ] state-lookup.md unchanged
- [ ] No functional code removed
- [ ] Changes committed
- [ ] Task status updated to [IMPLEMENTED]

---

## Dependencies

### Upstream Dependencies

- Task 305 research completed (research-001.md)

### Downstream Dependencies

- Task 307: Verify or revert core logic changes
- Task 308: Final cleanup and comprehensive testing

### External Dependencies

- None

---

## Notes

### Research Integration

This plan integrates findings from research-001.md:
- Exact line numbers for all cruft to remove
- Clear distinction between cruft and core logic changes
- Explicit preservation of state-lookup.md documentation
- Deferral of core logic verification to task 307

### Key Decisions

1. **Remove Only Cruft**: Only remove optimization sections, performance blocks, and verbose comments. Do NOT remove core logic changes.

2. **Preserve state-lookup.md**: Keep all documentation changes in state-lookup.md (valuable reference).

3. **Defer Core Logic**: Core logic changes in meta.md and task-creator.md are handled in task 307.

4. **Consistent Style**: Simplify all verbose comments to be concise and essential.

### Implementation Order

Phases are independent and can be executed in any order, but Phase 7 (verification and commit) must be last.

---

**End of Implementation Plan**
