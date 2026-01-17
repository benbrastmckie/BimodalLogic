# Implementation Plan: Context File References and Loading Optimization

**Task**: 327 - Review context file references and optimize context loading strategy  
**Created**: 2026-01-06  
**Plan Version**: 1  
**Estimated Total Effort**: 10-12 hours  
**Complexity**: Medium  
**Language**: meta  
**Type**: feature  
**Priority**: Medium  

**Research Integration**:
- Research Report: `specs/327_review_context_file_references_and_optimize_context_loading_strategy/reports/research-001.md`
- Key Findings: 19 broken context file references, task 314 refactor not executed, no lazy loading implementation

---

## Overview

This plan addresses critical broken context file references and implements context loading optimizations following task 314's context refactor. Research identified 19 broken references across 15 files causing silent context loading failures, plus significant opportunities for optimization.

**Core Objectives**:
1. Fix all 19 broken context file references
2. Validate all context paths resolve correctly
3. Create context loading best practices guide
4. Document current context file inventory
5. Establish foundation for future optimizations

**Success Criteria**:
- Zero broken context file references
- All references validated and tested
- Best practices guide created
- Context inventory documented
- No regressions in command functionality

---

## Phase 1: Fix Broken Context File References [NOT STARTED]

**Objective**: Update all 19 broken context file references to correct paths

**Effort**: 2-3 hours

**Tasks**:

1. **Create Reference Update Script** (30 minutes)
   - Create `.opencode/scripts/update-context-refs.sh`
   - Implement 12 sed-based reference updates
   - Add validation checks for remaining broken references
   - Make script executable

2. **Execute Reference Updates** (30 minutes)
   - Run update script on all command files (6 files)
   - Run update script on all subagent files (11 files)
   - Run update script on orchestrator (1 file)
   - Verify script output shows successful updates

3. **Manual Verification** (1 hour)
   - Verify deleted references (command-argument-handling.md)
   - Verify merged references (artifact-management.md → state-management.md)
   - Verify moved references (5 spot-checks)
   - Check for any edge cases or special handling needed

4. **Validation Testing** (30 minutes)
   - Search for remaining `core/system/` references (expect 1: status-markers.md)
   - Verify all new paths resolve to existing files
   - Test context loading with updated references
   - Document any issues found

**Acceptance Criteria**:
- [ ] Reference update script created and tested
- [ ] All 19 broken references updated to correct paths
- [ ] Manual verification completed for critical changes
- [ ] Validation shows zero broken references (except status-markers.md)
- [ ] No context loading errors in test runs

**Deliverables**:
- `.opencode/scripts/update-context-refs.sh` (reference update script)
- 18 files updated with correct context paths
- Validation report documenting zero broken references

**Reference Mappings** (from research):
```
core/system/state-management.md → core/orchestration/state-management.md (17 refs)
core/system/routing-guide.md → core/orchestration/routing.md (3 refs)
core/system/artifact-management.md → core/orchestration/state-management.md (10 refs)
core/system/git-commits.md → core/standards/git-safety.md (3 refs)
core/standards/command-argument-handling.md → DELETE (4 refs)
core/standards/plan.md → core/formats/plan-format.md (3 refs)
core/standards/subagent-return-format.md → core/formats/subagent-return.md (2 refs)
core/standards/architecture-principles.md → project/meta/architecture-principles.md (2 refs)
core/standards/domain-patterns.md → project/meta/domain-patterns.md (2 refs)
core/workflows/interview-patterns.md → project/meta/interview-patterns.md (2 refs)
core/templates/agent-templates.md → core/templates/agent-template.md (1 ref)
core/workflow/postflight-pattern.md → core/workflows/postflight-pattern.md (1 ref)
```

---

## Phase 2: Validate Context File Inventory [NOT STARTED]

**Objective**: Document current context file structure and validate all paths

**Effort**: 1-2 hours

**Tasks**:

1. **Generate Context File Inventory** (30 minutes)
   - List all files in `.opencode/context/core/`
   - Count files per directory
   - Calculate total lines and estimated tokens
   - Identify files with 0 references

2. **Update Context Index** (45 minutes)
   - Update `.opencode/context/index.md` with current inventory
   - Add file sizes and line counts
   - Add file purposes and summaries
   - Add loading recommendations per file

3. **Validate Directory Structure** (30 minutes)
   - Verify all directories match expected structure
   - Identify deprecated directories (system/, workflow/)
   - Document files that should be moved
   - Create migration plan for deprecated directories

4. **Create Reference Validation Script** (15 minutes)
   - Create script to validate all @ references
   - Check all referenced files exist
   - Report any broken references
   - Add to CI/CD for continuous validation

**Acceptance Criteria**:
- [ ] Complete context file inventory generated
- [ ] Context index updated with all 35 files
- [ ] Directory structure validated and documented
- [ ] Reference validation script created and tested
- [ ] All references resolve to existing files

**Deliverables**:
- Updated `.opencode/context/index.md` with complete inventory
- `.opencode/scripts/validate-context-refs.sh` (validation script)
- Directory structure validation report

**Expected Inventory** (from research):
- Orchestration: 8 files, 5,366 lines
- Formats: 7 files, 2,962 lines
- Standards: 8 files, 3,359 lines
- Workflows: 5 files, 1,745 lines
- Templates: 5 files, 1,198 lines
- System: 1 file, 349 lines (DEPRECATED)
- Workflow: 1 file, 441 lines (DEPRECATED)
- **TOTAL**: 35 files, 15,283 lines

---

## Phase 3: Create Context Loading Best Practices Guide [NOT STARTED]

**Objective**: Document best practices for context loading strategy

**Effort**: 2-3 hours

**Tasks**:

1. **Create Guide Structure** (30 minutes)
   - Create `.opencode/docs/guides/context-loading-best-practices.md`
   - Define 8 main sections (from research recommendations)
   - Create table of contents
   - Add introduction and overview

2. **Document Loading Strategies** (45 minutes)
   - Lazy vs eager loading
   - Conditional loading patterns
   - Summary-first loading
   - Section-based loading
   - Include code examples for each

3. **Document File Organization Guidelines** (30 minutes)
   - When to split files (>700 lines)
   - When to create summaries
   - When to use examples files
   - Directory structure guidelines
   - File size limits per type

4. **Document Context Configuration** (30 minutes)
   - Frontmatter syntax and examples
   - Required vs optional files
   - Conditional loading rules
   - Max context size guidelines per operation type

5. **Document Common Patterns** (45 minutes)
   - Research operations pattern
   - Planning operations pattern
   - Implementation operations pattern
   - Review operations pattern
   - Meta operations pattern
   - Include complete YAML examples for each

6. **Add Troubleshooting Section** (30 minutes)
   - Broken references
   - Context bloat
   - Loading failures
   - Performance issues
   - Include diagnostic commands

**Acceptance Criteria**:
- [ ] Best practices guide created with all 8 sections
- [ ] Loading strategies documented with examples
- [ ] File organization guidelines clear and actionable
- [ ] Context configuration syntax documented
- [ ] Common patterns provided for all operation types
- [ ] Troubleshooting section comprehensive

**Deliverables**:
- `.opencode/docs/guides/context-loading-best-practices.md` (~800-1000 lines)

**Guide Sections**:
1. Introduction (why context loading matters)
2. Loading Strategies (lazy, eager, conditional, summary-first)
3. File Organization (splitting, summaries, examples, structure)
4. Context Configuration (frontmatter, required/optional, max sizes)
5. Optimization Techniques (caching, compression, indexing, pruning)
6. Monitoring and Metrics (telemetry, size tracking, performance)
7. Common Patterns (research, plan, implement, review, meta)
8. Troubleshooting (broken refs, bloat, failures, performance)

---

## Phase 4: Optimize Context Loading Patterns [NOT STARTED]

**Objective**: Update command and agent context_loading configurations

**Effort**: 2-3 hours

**Tasks**:

1. **Audit Current Context Loading** (30 minutes)
   - Review all context_loading sections in commands
   - Review all context_loading sections in subagents
   - Identify missing context_loading sections
   - Document current patterns and issues

2. **Update Command Context Loading** (1 hour)
   - Update `/research` command (add context_loading section)
   - Update `/plan` command (fix broken references)
   - Update `/implement` command (add context_loading section)
   - Update `/review` command (fix broken references, reduce max size)
   - Update `/meta` command (fix broken references)
   - Update `/revise` command (add context_loading section)

3. **Update Subagent Context Loading** (1 hour)
   - Update researcher.md (fix broken references)
   - Update planner.md (fix broken references)
   - Update implementer.md (add/fix context_loading)
   - Update lean-research-agent.md (fix broken references)
   - Update lean-implementation-agent.md (fix broken references)
   - Update lean-planner.md (fix broken references)
   - Update other subagents as needed

4. **Validate Optimizations** (30 minutes)
   - Test each updated command
   - Verify context loads correctly
   - Check for any loading errors
   - Document any issues found

**Acceptance Criteria**:
- [ ] All commands have context_loading sections
- [ ] All broken references in context_loading fixed
- [ ] Context loading patterns follow best practices
- [ ] All commands tested and working
- [ ] No context loading errors

**Deliverables**:
- 11 command files updated with optimized context_loading
- 10+ subagent files updated with optimized context_loading
- Context loading audit report

**Optimization Targets** (from research):
- Research: Add delegation.md, state-management.md, report-format.md
- Plan: Fix 4 broken refs, add task-breakdown.md
- Implement: Add delegation.md, state-management.md, git-safety.md
- Review: Fix 5 broken refs, reduce max from 100000 to 50000
- Meta: Fix 5 broken refs in required/optional sections

---

## Phase 5: Testing and Validation [NOT STARTED]

**Objective**: Comprehensive testing of all changes

**Effort**: 1-2 hours

**Tasks**:

1. **Test Workflow Commands** (45 minutes)
   - Test `/research 327` (verify context loads correctly)
   - Test `/plan 327` (verify context loads correctly)
   - Test `/implement 327` (verify context loads correctly)
   - Test `/revise 327` (verify context loads correctly)
   - Document any errors or issues

2. **Test Utility Commands** (30 minutes)
   - Test `/review` (verify context loads correctly)
   - Test `/meta` (verify context loads correctly)
   - Test `/todo` (verify context loads correctly)
   - Document any errors or issues

3. **Validate Reference Resolution** (30 minutes)
   - Run reference validation script
   - Verify all @ references resolve
   - Check for any new broken references
   - Document validation results

4. **Performance Testing** (15 minutes)
   - Measure context loading time for each command
   - Compare before/after if possible
   - Document any performance improvements
   - Identify any performance regressions

**Acceptance Criteria**:
- [ ] All workflow commands tested successfully
- [ ] All utility commands tested successfully
- [ ] Reference validation passes (zero broken refs)
- [ ] Performance metrics documented
- [ ] No regressions identified

**Deliverables**:
- Testing report documenting all test results
- Performance metrics before/after
- Validation report showing zero broken references

**Test Cases**:
1. `/research 327` - Should load delegation.md, state-management.md, report-format.md
2. `/plan 327` - Should load delegation.md, state-management.md, plan-format.md, task-breakdown.md
3. `/implement 327` - Should load delegation.md, state-management.md, git-safety.md
4. `/review` - Should load delegation.md, state-management.md, review-process.md
5. `/meta` - Should load subagent-return.md, status-transitions.md, architecture-principles.md

---

## Phase 6: Documentation and Cleanup [NOT STARTED]

**Objective**: Finalize documentation and clean up

**Effort**: 1 hour

**Tasks**:

1. **Update Task 314 Status** (15 minutes)
   - Review task 314 current status (marked COMPLETED but not executed)
   - Update status to [PLANNED] to reflect accurate state
   - Add note about task 327 completing reference fixes
   - Document that full refactor (20 hours) still pending

2. **Create Implementation Summary** (30 minutes)
   - Document all changes made
   - List all files modified
   - Summarize broken references fixed
   - Document context loading optimizations
   - Include before/after metrics

3. **Update Context Index** (15 minutes)
   - Add reference to best practices guide
   - Add reference to validation script
   - Update file inventory if needed
   - Add maintenance procedures

4. **Final Validation** (15 minutes)
   - Run all validation scripts
   - Verify all deliverables created
   - Check all acceptance criteria met
   - Document any remaining issues

**Acceptance Criteria**:
- [ ] Task 314 status updated accurately
- [ ] Implementation summary created
- [ ] Context index updated with new references
- [ ] Final validation completed successfully
- [ ] All deliverables verified

**Deliverables**:
- Implementation summary report
- Updated context index
- Final validation report
- Updated task 314 status

**Summary Contents**:
- Files modified: 18 command/agent files, 1 context index, 2 scripts
- Broken references fixed: 19 total
- Context loading optimizations: 11 commands, 10+ subagents
- Documentation created: Best practices guide, validation script
- Performance impact: TBD (measured in Phase 5)

---

## Success Metrics

### Reference Quality Metrics

**Metric 1: Broken Reference Count**
- **Baseline**: 19 broken references
- **Target**: 0 broken references
- **Measurement**: `grep -r "core/system/" .opencode/command .opencode/agent | wc -l`
- **Success**: Zero results (excluding status-markers.md)

**Metric 2: Reference Validation Coverage**
- **Baseline**: 0% (no validation)
- **Target**: 100% (all references validated)
- **Measurement**: Automated validation script
- **Success**: All context references resolve to existing files

### Context Loading Metrics

**Metric 3: Commands with Context Loading**
- **Baseline**: 6 of 11 commands (55%)
- **Target**: 11 of 11 commands (100%)
- **Measurement**: Count context_loading sections
- **Success**: All commands have context_loading configuration

**Metric 4: Broken References in Context Loading**
- **Baseline**: 19 broken references
- **Target**: 0 broken references
- **Measurement**: Validate all paths in context_loading sections
- **Success**: All paths resolve correctly

### Documentation Metrics

**Metric 5: Best Practices Guide Completeness**
- **Baseline**: 0% (no guide exists)
- **Target**: 100% (all 8 sections complete)
- **Measurement**: Section count and content review
- **Success**: All 8 sections documented with examples

**Metric 6: Context Index Accuracy**
- **Baseline**: ~60% (incomplete)
- **Target**: 100% (all files documented)
- **Measurement**: Files in index / files in directory
- **Success**: All 35 files documented in index

---

## Risk Assessment

### High Risks

**Risk 1: Breaking Existing Functionality**
- **Severity**: HIGH
- **Likelihood**: MEDIUM
- **Mitigation**: Comprehensive testing in Phase 5, rollback plan ready
- **Contingency**: Revert changes if any command fails

**Risk 2: Missing Edge Cases in Reference Updates**
- **Severity**: MEDIUM
- **Likelihood**: MEDIUM
- **Mitigation**: Manual verification in Phase 1, validation script in Phase 2
- **Contingency**: Fix edge cases as discovered

### Medium Risks

**Risk 3: Context Loading Changes Cause Performance Issues**
- **Severity**: MEDIUM
- **Likelihood**: LOW
- **Mitigation**: Performance testing in Phase 5
- **Contingency**: Adjust max_context_size if needed

**Risk 4: Documentation Becomes Stale**
- **Severity**: LOW
- **Likelihood**: MEDIUM
- **Mitigation**: Add validation script to CI/CD
- **Contingency**: Regular reviews and updates

---

## Dependencies

**Upstream Dependencies**:
- Task 314 (context refactor plan) - COMPLETED (plan created, not executed)
- Research report for task 327 - COMPLETED

**Downstream Dependencies**:
- None (this task is self-contained)

**Blocking**:
- None

**Blocked By**:
- None

---

## Rollback Plan

If critical issues are discovered during implementation:

1. **Immediate Rollback** (if commands fail):
   - Revert all reference updates: `git revert <commit>`
   - Restore original context_loading configurations
   - Test all commands to verify functionality restored

2. **Partial Rollback** (if specific changes cause issues):
   - Identify problematic changes
   - Revert only those specific changes
   - Re-test affected commands
   - Document issues for future resolution

3. **Validation**:
   - Run all test cases from Phase 5
   - Verify all commands working
   - Check for any remaining issues

---

## Implementation Notes

### Phase Execution Order

Phases must be executed in order:
1. Phase 1 (Fix References) - CRITICAL, blocks all other phases
2. Phase 2 (Validate Inventory) - Provides foundation for Phase 3
3. Phase 3 (Best Practices) - Can run in parallel with Phase 4
4. Phase 4 (Optimize Loading) - Depends on Phase 1 completion
5. Phase 5 (Testing) - Validates all previous phases
6. Phase 6 (Documentation) - Final cleanup and summary

### Key Decisions

**Decision 1: Scope of Optimizations**
- **Choice**: Focus on fixing broken references and documenting best practices
- **Rationale**: Research identified 19 critical broken references that must be fixed
- **Alternative**: Full context refactor (task 314, 20 hours) - deferred to separate task
- **Impact**: Achieves immediate value (fix broken refs) without large refactor

**Decision 2: Context Loading Implementation**
- **Choice**: Update frontmatter configurations, defer actual lazy loading implementation
- **Rationale**: Frontmatter provides foundation, actual implementation requires deeper changes
- **Alternative**: Implement true lazy loading mechanism - deferred to future task
- **Impact**: Establishes patterns and documentation for future optimization

**Decision 3: Task 314 Status**
- **Choice**: Update task 314 status to [PLANNED] to reflect accurate state
- **Rationale**: Task marked COMPLETED but 0% implementation performed
- **Alternative**: Execute full task 314 refactor (20 hours) - out of scope for task 327
- **Impact**: Prevents confusion about actual system state

### Testing Strategy

**Unit Testing**:
- Test each reference update individually
- Validate each context_loading configuration
- Test each command in isolation

**Integration Testing**:
- Test complete workflows (/research → /plan → /implement)
- Test context loading across multiple commands
- Verify no regressions in existing functionality

**Validation Testing**:
- Run reference validation script
- Check all paths resolve correctly
- Verify no broken references remain

---

## Appendix A: Files to Modify

### Commands (6 files)
1. `.opencode/command/plan.md` - Fix 4 broken refs
2. `.opencode/command/review.md` - Fix 5 broken refs
3. `.opencode/command/errors.md` - Fix 3 broken refs
4. `.opencode/command/sync.md` - Fix 3 broken refs
5. `.opencode/command/todo.md` - Fix 3 broken refs
6. `.opencode/command/meta.md` - Fix 5 broken refs

### Subagents (11 files)
1. `.opencode/agent/subagents/researcher.md` - Fix 2 broken refs
2. `.opencode/agent/subagents/planner.md` - Fix 3 broken refs
3. `.opencode/agent/subagents/implementer.md` - Fix 2 broken refs
4. `.opencode/agent/subagents/task-executor.md` - Fix 4 broken refs
5. `.opencode/agent/subagents/lean-research-agent.md` - Fix 2 broken refs
6. `.opencode/agent/subagents/lean-implementation-agent.md` - Fix 2 broken refs
7. `.opencode/agent/subagents/lean-planner.md` - Fix 3 broken refs
8. `.opencode/agent/subagents/reviewer.md` - Fix 2 broken refs
9. `.opencode/agent/subagents/error-diagnostics-agent.md` - Fix 2 broken refs
10. `.opencode/agent/subagents/meta.md` - Fix 3 broken refs
11. `.opencode/agent/subagents/git-workflow-manager.md` - Fix 1 broken ref

### Orchestrator (1 file)
1. `.opencode/agent/orchestrator.md` - Fix 1 broken ref

### Documentation (2 files)
1. `.opencode/context/index.md` - Update inventory
2. `.opencode/docs/guides/context-loading-best-practices.md` - CREATE NEW

### Scripts (2 files)
1. `.opencode/scripts/update-context-refs.sh` - CREATE NEW
2. `.opencode/scripts/validate-context-refs.sh` - CREATE NEW

**TOTAL**: 22 files (18 modified, 4 created)

---

## Appendix B: Reference Update Commands

Complete sed commands for automated reference updates:

```bash
# Fix 1: core/system/state-management.md → core/orchestration/state-management.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/state-management\.md|core/orchestration/state-management.md|g' {} +

# Fix 2: core/system/routing-guide.md → core/orchestration/routing.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/routing-guide\.md|core/orchestration/routing.md|g' {} +

# Fix 3: core/system/artifact-management.md → core/orchestration/state-management.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/artifact-management\.md|core/orchestration/state-management.md|g' {} +

# Fix 4: core/system/git-commits.md → core/standards/git-safety.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/git-commits\.md|core/standards/git-safety.md|g' {} +

# Fix 5: core/standards/command-argument-handling.md → DELETE
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  '/core\/standards\/command-argument-handling\.md/d' {} +

# Fix 6: core/standards/plan.md → core/formats/plan-format.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/plan\.md|core/formats/plan-format.md|g' {} +

# Fix 7: core/standards/subagent-return-format.md → core/formats/subagent-return.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/subagent-return-format\.md|core/formats/subagent-return.md|g' {} +

# Fix 8: core/standards/architecture-principles.md → project/meta/architecture-principles.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/architecture-principles\.md|project/meta/architecture-principles.md|g' {} +

# Fix 9: core/standards/domain-patterns.md → project/meta/domain-patterns.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/domain-patterns\.md|project/meta/domain-patterns.md|g' {} +

# Fix 10: core/workflows/interview-patterns.md → project/meta/interview-patterns.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/workflows/interview-patterns\.md|project/meta/interview-patterns.md|g' {} +

# Fix 11: core/templates/agent-templates.md → core/templates/agent-template.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/templates/agent-templates\.md|core/templates/agent-template.md|g' {} +

# Fix 12: core/workflow/postflight-pattern.md → core/workflows/postflight-pattern.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/workflow/postflight-pattern\.md|core/workflows/postflight-pattern.md|g' {} +
```

---

**END OF IMPLEMENTATION PLAN**
