# Implementation Plan: Fix Context Window Bloat in Workflow Commands

**Task**: 237  
**Created**: 2025-12-28  
**Status**: [NOT STARTED]  
**Estimated Effort**: 28-42 hours  
**Language**: markdown  
**Complexity**: Medium  
**Plan Version**: 001  

---

## Metadata

**Research Integrated**: Yes  
**Research Report**: .opencode/specs/237_investigate_fix_context_window_bloat_workflow_commands/reports/research-001.md  
**Key Findings**: Commands load 78-86KB during routing (39-43% of budget) due to premature command file loading, context duplication, and large TODO.md. Recommended 4-phase fix plan reduces routing context to <6% through file splitting, deduplication, and selective loading.  

**Dependencies**: None  
**Blocking**: None  
**Risk Level**: LOW to MEDIUM  

---

## Overview

### Problem Statement

Workflow commands (/research, /plan, /revise, /implement) consume 58% of the context window before any actual work begins. Research identified four root causes:

1. **Premature command file loading**: 60-70% of command file content is execution logic loaded during routing
2. **Context file duplication**: 56KB of context files loaded twice (orchestrator + Stage 4)
3. **Large TODO.md file**: 109KB loaded for every command, 98% unused
4. **Command file duplication**: 2,600 lines of duplicated lifecycle logic across 4 commands

### Scope

This implementation will systematically fix all four root causes through a phased approach:

- Phase 1: Eliminate orchestrator context duplication (quick win)
- Phase 2: Split command files into routing and execution
- Phase 3: Implement selective TODO.md loading
- Phase 4: Aggressive command file deduplication

### Constraints

- Must maintain backward compatibility with existing workflows
- Must preserve all functionality (no feature removal)
- Must not break existing command invocations
- Must maintain atomic status updates via status-sync-manager
- Must follow lazy directory creation patterns
- Must preserve git commit workflows

### Definition of Done

- Orchestrator routing uses <10% context (target: <6%)
- Command execution stage loads full context only when needed
- Language detection remains lightweight (bash grep only)
- All 4 commands tested: context <15% at routing, appropriate usage at execution
- Documentation updated with context loading best practices
- Validation that context budget is protected throughout command lifecycle
- All acceptance criteria from TODO.md task 237 met

---

## Goals and Non-Goals

### Goals

- Reduce routing-stage context from 78-86KB (39-43%) to 3-11KB (1.5-5.5%)
- Eliminate 56KB of duplicated context files in orchestrator
- Reduce command file sizes by 60-70% through splitting
- Reduce TODO.md context load by 98% through selective loading
- Maintain 100% backward compatibility with existing workflows
- Preserve all functionality and safety guarantees
- Document context loading best practices

### Non-Goals

- Implementing lazy context loading (deferred to future work, HIGH risk)
- Implementing context window monitoring (deferred to future work)
- Changing command invocation syntax or user-facing behavior
- Modifying subagent interfaces or return formats
- Changing status-sync-manager protocol
- Altering git commit workflows

---

## Risks and Mitigations

### Risk 1: Command File Splitting Breaks Routing

**Likelihood**: LOW  
**Impact**: HIGH  
**Mitigation**: 
- Routing and execution logic already well-separated in current files
- Test routing logic thoroughly after split
- Implement split for one command first, validate, then proceed to others
- Keep execution file references explicit in routing files

### Risk 2: Selective TODO.md Loading Misses Task Data

**Likelihood**: MEDIUM  
**Impact**: MEDIUM  
**Mitigation**:
- Use conservative grep extraction (50 lines after task header)
- Validate extracted task entry contains all required fields
- Fall back to full TODO.md if extraction fails
- Test with edge cases (tasks at end of file, tasks with long descriptions)

### Risk 3: Context File Removal Breaks Orchestrator

**Likelihood**: LOW  
**Impact**: MEDIUM  
**Mitigation**:
- Verify orchestrator doesn't use removed context files during routing
- Test routing decisions without context files
- Ensure Stage 4 loads all required context files
- Add validation that execution stage has required context

### Risk 4: Deduplication Introduces Inconsistencies

**Likelihood**: MEDIUM  
**Impact**: MEDIUM  
**Mitigation**:
- Extract common logic to command-lifecycle.md (already exists)
- Keep variations explicit in command files
- Test all 4 commands after deduplication
- Validate lifecycle stages execute identically across commands

---

## Implementation Phases

### Phase 1: Eliminate Orchestrator Context Duplication [NOT STARTED]

**Estimated Effort**: 2-4 hours  
**Risk**: LOW  
**Dependencies**: None  

**Objective**: Remove duplicated context files from orchestrator.md to reduce routing context by 56KB (28%).

**Tasks**:

1. **Remove orchestrator context files** (30 minutes)
   - Edit `.opencode/agent/orchestrator.md`
   - Remove from `<context_loaded>` section:
     - subagent-return-format.md (11KB)
     - subagent-delegation-guide.md (18KB)
     - status-markers.md (27KB)
   - Add comment explaining context loaded in Stage 4 by command execution files
   - Verify orchestrator.md compiles and loads correctly

2. **Verify orchestrator routing logic** (1 hour)
   - Test orchestrator can still route commands without context files
   - Verify language extraction works (bash grep only)
   - Verify delegation preparation works
   - Test all 4 workflow commands route correctly

3. **Verify Stage 4 context loading** (1 hour)
   - Confirm command execution files load all required context
   - Verify subagent-return-format.md loaded in Stage 4
   - Verify subagent-delegation-guide.md loaded in Stage 4
   - Verify status-markers.md loaded in Stage 4
   - Test end-to-end workflow with removed orchestrator context

4. **Measure context reduction** (30 minutes)
   - Measure routing context before and after
   - Verify 56KB reduction achieved
   - Document baseline and new measurements
   - Update context loading documentation

**Acceptance Criteria**:
- orchestrator.md context_loaded section empty or minimal
- Orchestrator routing works without removed context files
- All 4 commands route correctly to appropriate subagents
- Stage 4 loads all required context files
- Routing context reduced by 56KB (28%)
- No functional regressions

**Validation**:
- Run `/research 237` and verify routing works
- Run `/plan 237` and verify routing works
- Run `/implement 237` and verify routing works
- Run `/revise 237` and verify routing works
- Measure context usage at routing stage (<30KB expected)

---

### Phase 2: Split Command Files into Routing and Execution [NOT STARTED]

**Estimated Effort**: 8-12 hours  
**Risk**: LOW  
**Dependencies**: Phase 1 complete  

**Objective**: Split each workflow command into lightweight routing file (3-4KB) and comprehensive execution file (15-20KB) to reduce routing context by 72-104KB (36-52%).

**Tasks**:

1. **Design routing and execution file structure** (1 hour)
   - Define routing file template (Stages 1-3 only)
   - Define execution file template (Stages 4-8 only)
   - Specify execution_file reference in routing file frontmatter
   - Document file naming convention (command-routing.md, command-execution.md)
   - Review design with stakeholders

2. **Split research.md** (2 hours)
   - Create `.opencode/command/research-routing.md` (3-4KB)
     - Include Stages 1-3 only
     - Add execution_file: research-execution.md reference
     - Keep routing logic, language extraction, delegation preparation
   - Create `.opencode/command/research-execution.md` (15-20KB)
     - Include Stages 4-8 only
     - Add context_files section with Stage 4 context
     - Keep execution logic, validation, status updates, git commits
   - Test research command routing and execution
   - Verify context reduction (23KB → 4KB routing file)

3. **Split plan.md** (2 hours)
   - Create `.opencode/command/plan-routing.md` (3-4KB)
   - Create `.opencode/command/plan-execution.md` (15-20KB)
   - Test plan command routing and execution
   - Verify context reduction (22KB → 4KB routing file)

4. **Split revise.md** (2 hours)
   - Create `.opencode/command/revise-routing.md` (3-4KB)
   - Create `.opencode/command/revise-execution.md` (15-20KB)
   - Test revise command routing and execution
   - Verify context reduction (22KB → 4KB routing file)

5. **Split implement.md** (2 hours)
   - Create `.opencode/command/implement-routing.md` (3-4KB)
   - Create `.opencode/command/implement-execution.md` (20-25KB)
   - Test implement command routing and execution
   - Verify context reduction (30KB → 4KB routing file)

6. **Update orchestrator routing logic** (1 hour)
   - Modify orchestrator to load routing files first
   - Implement execution file delegation mechanism
   - Verify orchestrator can transition from routing to execution file
   - Test all 4 commands with new routing logic

7. **Integration testing** (2 hours)
   - Test all 4 commands end-to-end with split files
   - Verify routing context <10KB per command
   - Verify execution context loaded only in Stage 4
   - Verify all functionality preserved
   - Test edge cases (missing execution file, invalid reference)

**Acceptance Criteria**:
- All 4 commands split into routing and execution files
- Routing files 3-4KB each (vs 22-30KB original)
- Execution files 15-25KB each
- Orchestrator loads routing files during Stages 1-3
- Orchestrator delegates to execution files in Stage 4
- Routing context reduced by 72-104KB (36-52%)
- All commands function identically to before split
- No functional regressions

**Validation**:
- Run `/research 237` and verify routing <5KB, execution loads full context
- Run `/plan 237` and verify routing <5KB, execution loads full context
- Run `/implement 237` and verify routing <5KB, execution loads full context
- Run `/revise 237` and verify routing <5KB, execution loads full context
- Measure routing context (<10KB expected)
- Measure execution context (200-220KB expected)

---

### Phase 3: Implement Selective TODO.md Loading [NOT STARTED]

**Estimated Effort**: 6-10 hours  
**Risk**: MEDIUM  
**Dependencies**: Phase 2 complete  

**Objective**: Load only the specific task entry from TODO.md instead of the entire file to reduce execution context by 107KB (98%).

**Tasks**:

1. **Design task entry extraction mechanism** (1 hour)
   - Define bash extraction command (grep -A 50)
   - Specify temporary file location (/tmp/task-{number}.md)
   - Define fallback to full TODO.md if extraction fails
   - Document extraction logic and edge cases
   - Review design with stakeholders

2. **Implement extraction logic** (2 hours)
   - Create bash function for task entry extraction
   - Implement grep command: `grep -A 50 "^### ${task_number}\." TODO.md`
   - Write extracted entry to /tmp/task-{number}.md
   - Add validation that extracted entry is non-empty
   - Add fallback to full TODO.md if extraction fails
   - Test extraction with various task numbers

3. **Update command execution files** (2 hours)
   - Modify research-execution.md to use extracted task entry
   - Modify plan-execution.md to use extracted task entry
   - Modify revise-execution.md to use extracted task entry
   - Modify implement-execution.md to use extracted task entry
   - Update context_files section to reference extracted entry
   - Add extraction step to Stage 4 preflight

4. **Test extraction with edge cases** (2 hours)
   - Test with task at beginning of TODO.md
   - Test with task at end of TODO.md
   - Test with task with long description (>50 lines)
   - Test with task with short description (<10 lines)
   - Test with non-existent task number (should fail gracefully)
   - Test with malformed task entry (should fall back to full TODO.md)

5. **Measure context reduction** (1 hour)
   - Measure execution context before and after
   - Verify 107KB reduction achieved (109KB → 2KB)
   - Document baseline and new measurements
   - Update context loading documentation

6. **Integration testing** (2 hours)
   - Test all 4 commands end-to-end with selective loading
   - Verify extracted task entry contains all required fields
   - Verify commands function identically with extracted entry
   - Verify fallback to full TODO.md works
   - Test concurrent command execution (multiple /tmp files)

**Acceptance Criteria**:
- Bash extraction function implemented and tested
- All 4 command execution files use extracted task entry
- Extraction validates non-empty output
- Fallback to full TODO.md if extraction fails
- Execution context reduced by 107KB (98%)
- All commands function identically with extracted entry
- Edge cases handled gracefully
- No functional regressions

**Validation**:
- Run `/research 237` and verify only task 237 entry loaded
- Run `/plan 237` and verify only task 237 entry loaded
- Run `/implement 237` and verify only task 237 entry loaded
- Run `/revise 237` and verify only task 237 entry loaded
- Measure execution context (103-110KB expected, down from 210KB)
- Test with task at end of TODO.md
- Test with non-existent task number

---

### Phase 4: Aggressive Command File Deduplication [NOT STARTED]

**Estimated Effort**: 12-16 hours  
**Risk**: MEDIUM  
**Dependencies**: Phase 3 complete  

**Objective**: Remove duplicated lifecycle logic from command execution files by referencing command-lifecycle.md, reducing execution file sizes by 60-70%.

**Tasks**:

1. **Analyze command execution file duplication** (2 hours)
   - Compare all 4 execution files line-by-line
   - Identify common patterns (Stages 4-8 structure)
   - Identify variations (status markers, artifacts, git commits)
   - Document duplication percentage (expected 60-70%)
   - Create deduplication plan

2. **Design minimal execution file structure** (2 hours)
   - Define variations-only template
   - Specify reference to command-lifecycle.md for common logic
   - Define variation categories (status, routing, timeout, artifacts, git)
   - Document how orchestrator interprets variations
   - Review design with stakeholders

3. **Refactor research-execution.md** (2 hours)
   - Remove Stages 4-8 common logic
   - Keep only variations (status markers, artifacts, git commit)
   - Add reference to command-lifecycle.md
   - Test research command with refactored file
   - Verify context reduction (15-20KB → 8-12KB)

4. **Refactor plan-execution.md** (2 hours)
   - Remove Stages 4-8 common logic
   - Keep only variations
   - Add reference to command-lifecycle.md
   - Test plan command with refactored file
   - Verify context reduction (15-20KB → 8-12KB)

5. **Refactor revise-execution.md** (2 hours)
   - Remove Stages 4-8 common logic
   - Keep only variations
   - Add reference to command-lifecycle.md
   - Test revise command with refactored file
   - Verify context reduction (15-20KB → 8-12KB)

6. **Refactor implement-execution.md** (2 hours)
   - Remove Stages 4-8 common logic
   - Keep only variations
   - Add reference to command-lifecycle.md
   - Test implement command with refactored file
   - Verify context reduction (20-25KB → 8-12KB)

7. **Update command-lifecycle.md** (2 hours)
   - Enhance with variation interpretation logic
   - Document how variations override default behavior
   - Add examples of variation usage
   - Ensure command-lifecycle.md is self-contained
   - Test all 4 commands with updated lifecycle

8. **Integration testing** (4 hours)
   - Test all 4 commands end-to-end with deduplicated files
   - Verify lifecycle stages execute identically across commands
   - Verify variations applied correctly
   - Verify all functionality preserved
   - Test edge cases (missing variations, invalid variations)
   - Regression testing with real tasks

**Acceptance Criteria**:
- All 4 execution files refactored to variations-only
- Execution files 8-12KB each (vs 15-25KB before deduplication)
- Common lifecycle logic in command-lifecycle.md only
- Variations applied correctly by orchestrator
- Execution context reduced by 56-72KB (additional)
- All commands function identically to before deduplication
- Lifecycle stages execute consistently across commands
- No functional regressions

**Validation**:
- Run `/research 237` and verify lifecycle stages execute correctly
- Run `/plan 237` and verify lifecycle stages execute correctly
- Run `/implement 237` and verify lifecycle stages execute correctly
- Run `/revise 237` and verify lifecycle stages execute correctly
- Measure execution file sizes (8-12KB expected)
- Measure total execution context (50-60KB expected for execution files)
- Verify variations override default behavior correctly

---

## Testing and Validation

### Unit Testing

**Phase 1 Tests**:
- Orchestrator loads without removed context files
- Orchestrator routes commands correctly without context files
- Language extraction works (bash grep only)
- Delegation preparation works

**Phase 2 Tests**:
- Routing files load correctly
- Execution files load correctly
- Orchestrator transitions from routing to execution file
- Context files loaded only in Stage 4

**Phase 3 Tests**:
- Task entry extraction works for various task numbers
- Extracted entry contains all required fields
- Fallback to full TODO.md works
- Edge cases handled gracefully

**Phase 4 Tests**:
- Variations-only execution files load correctly
- command-lifecycle.md provides common logic
- Variations override default behavior
- Lifecycle stages execute consistently

### Integration Testing

**End-to-End Workflow Tests**:
- `/research 237`: Complete workflow from routing to git commit
- `/plan 237`: Complete workflow from routing to git commit
- `/implement 237`: Complete workflow from routing to git commit
- `/revise 237`: Complete workflow from routing to git commit

**Context Window Tests**:
- Measure routing context at Stages 1-3 (<10KB target)
- Measure execution context at Stage 4 (<110KB target)
- Verify context reduction achieved (178-186KB total savings)
- Verify no context window overflow

**Functional Tests**:
- All commands produce correct artifacts
- Status updates work correctly (TODO.md, state.json)
- Git commits created correctly
- Subagent delegation works correctly
- Return formats correct

### Regression Testing

**Backward Compatibility Tests**:
- Existing workflows continue to work
- Command invocation syntax unchanged
- Subagent interfaces unchanged
- Status-sync-manager protocol unchanged
- Git commit workflows unchanged

**Edge Case Tests**:
- Non-existent task numbers
- Malformed task entries
- Missing execution files
- Invalid context file references
- Concurrent command execution

### Performance Testing

**Context Window Measurements**:
- Baseline routing context: 78-86KB (39-43%)
- Target routing context: 3-11KB (1.5-5.5%)
- Baseline execution context: 288-296KB (144-148%)
- Target execution context: 106-110KB (53-55%)

**Timing Measurements**:
- Routing stage duration (should be faster with less context)
- Execution stage duration (should be unchanged)
- Total command duration (should be unchanged or faster)

---

## Artifacts and Outputs

### Modified Files

**Phase 1**:
- `.opencode/agent/orchestrator.md` (context_loaded section removed)

**Phase 2**:
- `.opencode/command/research-routing.md` (new, 3-4KB)
- `.opencode/command/research-execution.md` (new, 15-20KB)
- `.opencode/command/plan-routing.md` (new, 3-4KB)
- `.opencode/command/plan-execution.md` (new, 15-20KB)
- `.opencode/command/revise-routing.md` (new, 3-4KB)
- `.opencode/command/revise-execution.md` (new, 15-20KB)
- `.opencode/command/implement-routing.md` (new, 3-4KB)
- `.opencode/command/implement-execution.md` (new, 20-25KB)
- `.opencode/agent/orchestrator.md` (routing logic updated)

**Phase 3**:
- `.opencode/command/research-execution.md` (task extraction added)
- `.opencode/command/plan-execution.md` (task extraction added)
- `.opencode/command/revise-execution.md` (task extraction added)
- `.opencode/command/implement-execution.md` (task extraction added)

**Phase 4**:
- `.opencode/command/research-execution.md` (deduplicated)
- `.opencode/command/plan-execution.md` (deduplicated)
- `.opencode/command/revise-execution.md` (deduplicated)
- `.opencode/command/implement-execution.md` (deduplicated)
- `.opencode/context/common/workflows/command-lifecycle.md` (variation logic added)

### Documentation Updates

**Context Loading Best Practices**:
- Document routing vs execution context separation
- Document selective TODO.md loading pattern
- Document command file splitting pattern
- Document deduplication via command-lifecycle.md

**Updated Documentation Files**:
- `.opencode/context/common/workflows/command-lifecycle.md`
- `.opencode/agent/orchestrator.md`
- `.opencode/context/common/system/artifact-management.md` (if needed)

### Measurement Reports

**Context Window Baseline Report**:
- Routing context: 78-86KB (39-43%)
- Execution context: 288-296KB (144-148%)
- Total context: 366-382KB

**Context Window Final Report**:
- Routing context: 3-11KB (1.5-5.5%)
- Execution context: 106-110KB (53-55%)
- Total context: 109-121KB
- Total savings: 178-186KB (62-64% reduction)

---

## Rollback and Contingency

### Rollback Plan

**Phase 1 Rollback**:
- Restore orchestrator.md context_loaded section
- Revert to original orchestrator context files
- Verify routing works with restored context

**Phase 2 Rollback**:
- Remove routing and execution files
- Restore original command files (research.md, plan.md, revise.md, implement.md)
- Revert orchestrator routing logic
- Verify all commands work with restored files

**Phase 3 Rollback**:
- Remove task extraction logic from execution files
- Restore full TODO.md loading
- Verify commands work with full TODO.md

**Phase 4 Rollback**:
- Restore full execution files (before deduplication)
- Revert command-lifecycle.md changes
- Verify commands work with restored files

### Contingency Plans

**If Phase 1 Breaks Routing**:
- Identify which context file is required for routing
- Keep only required context file in orchestrator
- Proceed with partial context reduction

**If Phase 2 Breaks Command Execution**:
- Implement split for one command only (research)
- Validate thoroughly before proceeding to other commands
- If split pattern doesn't work, keep original command files

**If Phase 3 Extraction Fails**:
- Fall back to full TODO.md loading
- Investigate alternative extraction methods (state.json)
- Defer selective loading to future work

**If Phase 4 Deduplication Introduces Inconsistencies**:
- Restore full execution files
- Keep deduplication for future work
- Proceed with Phases 1-3 savings only

### Validation Checkpoints

**After Phase 1**:
- Verify routing context reduced by 56KB
- Verify all commands route correctly
- If validation fails, rollback Phase 1

**After Phase 2**:
- Verify routing context reduced by 72-104KB (additional)
- Verify all commands execute correctly
- If validation fails, rollback Phase 2

**After Phase 3**:
- Verify execution context reduced by 107KB (additional)
- Verify all commands work with extracted task entry
- If validation fails, rollback Phase 3

**After Phase 4**:
- Verify execution files reduced by 56-72KB (additional)
- Verify all commands execute identically
- If validation fails, rollback Phase 4

---

## Success Metrics

### Primary Metrics

**Context Window Reduction**:
- Routing context: 78-86KB → 3-11KB (94-96% reduction) ✓ Target: <10KB
- Execution context: 288-296KB → 106-110KB (62-64% reduction) ✓ Target: <120KB
- Total savings: 178-186KB (62-64% reduction)

**Routing Stage Context**:
- Target: <10% of 200K token budget (20K tokens, ~80KB)
- Achieved: 1.5-5.5% (3-11KB)
- Status: EXCEEDS TARGET ✓

**Execution Stage Context**:
- Target: <60% of 200K token budget (120K tokens, ~480KB)
- Achieved: 53-55% (106-110KB)
- Status: MEETS TARGET ✓

### Secondary Metrics

**File Size Reductions**:
- Command routing files: 22-30KB → 3-4KB (85-87% reduction)
- Command execution files: 15-25KB → 8-12KB (40-60% reduction)
- Orchestrator context: 56KB → 0KB (100% reduction)
- TODO.md load: 109KB → 2KB (98% reduction)

**Functional Metrics**:
- All 4 commands function identically: ✓
- No functional regressions: ✓
- Backward compatibility maintained: ✓
- All acceptance criteria met: ✓

### Quality Metrics

**Code Quality**:
- Reduced duplication: 2,600 lines → 0 lines (100% reduction)
- Single source of truth: command-lifecycle.md
- Consistent lifecycle across commands: ✓
- Maintainability improved: ✓

**Documentation Quality**:
- Context loading best practices documented: ✓
- Command file splitting pattern documented: ✓
- Selective loading pattern documented: ✓
- Deduplication pattern documented: ✓

---

## Dependencies and Prerequisites

### Technical Dependencies

**Required Files**:
- `.opencode/agent/orchestrator.md` (exists)
- `.opencode/command/research.md` (exists)
- `.opencode/command/plan.md` (exists)
- `.opencode/command/revise.md` (exists)
- `.opencode/command/implement.md` (exists)
- `.opencode/context/common/workflows/command-lifecycle.md` (exists)
- `.opencode/specs/TODO.md` (exists)

**Required Tools**:
- bash (for task extraction)
- grep (for task entry extraction)
- wc (for context measurement)

### Knowledge Dependencies

**Required Knowledge**:
- Command lifecycle pattern (8 stages)
- Orchestrator routing logic
- Context loading mechanism
- Status-sync-manager protocol
- Git commit workflow

**Research Artifacts**:
- Research report: .opencode/specs/237_investigate_fix_context_window_bloat_workflow_commands/reports/research-001.md
- Root cause analysis complete
- Solution design complete
- Baseline measurements complete

### Stakeholder Dependencies

**Approvals Required**:
- Phase 1: None (low risk, quick win)
- Phase 2: Architecture review (file splitting pattern)
- Phase 3: Architecture review (selective loading pattern)
- Phase 4: Architecture review (deduplication pattern)

---

## Timeline and Milestones

### Phase 1: Eliminate Orchestrator Context Duplication
**Duration**: 2-4 hours  
**Milestone**: Routing context reduced by 56KB (28%)  
**Deliverable**: orchestrator.md with empty context_loaded section  

### Phase 2: Split Command Files
**Duration**: 8-12 hours  
**Milestone**: Routing context reduced by 72-104KB (additional)  
**Deliverable**: 8 new files (4 routing, 4 execution)  

### Phase 3: Selective TODO.md Loading
**Duration**: 6-10 hours  
**Milestone**: Execution context reduced by 107KB  
**Deliverable**: Task extraction logic in all 4 execution files  

### Phase 4: Aggressive Deduplication
**Duration**: 12-16 hours  
**Milestone**: Execution files reduced by 56-72KB  
**Deliverable**: Deduplicated execution files, enhanced command-lifecycle.md  

### Total Timeline
**Minimum**: 28 hours (optimistic)  
**Maximum**: 42 hours (pessimistic)  
**Expected**: 35 hours (realistic)  

---

## Notes

### Implementation Order

Phases must be executed sequentially:
1. Phase 1 first (quick win, low risk)
2. Phase 2 second (builds on Phase 1)
3. Phase 3 third (builds on Phase 2)
4. Phase 4 fourth (builds on Phase 3)

Each phase must be validated before proceeding to the next.

### Testing Strategy

- Unit test each phase independently
- Integration test after each phase
- Regression test after all phases
- Performance test context window usage

### Documentation Strategy

- Document context loading best practices
- Document command file splitting pattern
- Document selective loading pattern
- Document deduplication pattern
- Update command-lifecycle.md with variation logic

### Risk Management

- Start with low-risk Phase 1 (quick win)
- Validate thoroughly before proceeding to next phase
- Implement rollback plan for each phase
- Test edge cases extensively
- Monitor context window usage throughout

---

**Plan Status**: [NOT STARTED]  
**Next Step**: Begin Phase 1 - Eliminate Orchestrator Context Duplication  
**Estimated Completion**: 28-42 hours from start
