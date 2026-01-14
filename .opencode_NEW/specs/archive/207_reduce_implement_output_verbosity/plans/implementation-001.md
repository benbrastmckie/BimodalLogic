# Implementation Plan: Reduce /implement Command Output Verbosity

**Project**: 207_reduce_implement_output_verbosity
**Type**: enhancement
**Priority**: medium
**Complexity**: low-medium
**Estimated Hours**: 3
**Phases**: 3

---

## Metadata

- **Created**: 2025-12-28
- **Language**: markdown
- **Research Input**: [.opencode/specs/207_reduce_implement_output_verbosity/reports/research-001.md]
- **Dependencies**: None
- **Risk Level**: Low

---

## Overview

Reduce /implement command output verbosity by 95% (700 tokens → 35 tokens) through artifact-based summary creation and brief return formatting. The /implement command currently returns verbose subagent summaries verbatim (up to 500 characters), bloating the orchestrator's context window. This plan implements summary artifact creation and brief return formatting per artifact-management.md standard.

**Key Strategy**: Update /implement command Stage 8 to create or reference summary artifacts and return brief <100 token overviews, plus add summary artifact creation to lean-implementation-agent to align with task-executor pattern.

---

## Research Inputs

Research completed 2025-12-28. Key findings:

1. **Root Cause**: /implement Stage 8 (ReturnSuccess) returns full subagent summaries verbatim instead of creating/referencing summary artifacts
2. **Secondary Cause**: lean-implementation-agent doesn't create summary artifacts (violates artifact-management.md)
3. **Existing Pattern**: task-executor already creates implementation summary artifacts (lines 145-160)
4. **Impact**: 95% context window reduction achievable (700 tokens → 35 tokens)
5. **Effort**: 2-3 hours total (1.5h /implement, 1h lean-agent, 0.5h testing)

Full research: `.opencode/specs/207_reduce_implement_output_verbosity/reports/research-001.md`

---

## Phase 1: Update /implement Command Stage 8 [NOT STARTED]

**Estimated Time**: 1.5 hours

### Objectives

Update /implement command Stage 8 (ReturnSuccess) to create/reference summary artifacts and return brief <100 token overviews instead of verbose subagent summaries.

### Tasks

1. **Read current Stage 8 implementation** (5 min)
   - File: `.opencode/command/implement.md` (lines 366-387)
   - Understand current return format
   - Identify integration points

2. **Design summary artifact logic** (15 min)
   - Check for summary artifact in subagent return artifacts array
   - If present: extract path and create brief overview
   - If missing: create summary artifact from subagent return data
   - Define brief return format (3-5 sentences, <100 tokens)

3. **Update Stage 8 return_format section** (30 min)
   - Add summary artifact check logic
   - Add conditional summary artifact creation
   - Update return format to brief overview + path reference
   - Remove verbose subagent summary inclusion

4. **Add examples for all return scenarios** (20 min)
   - Example: completed with summary artifact present
   - Example: completed with summary artifact missing (created on-the-fly)
   - Example: partial completion
   - Example: failed/blocked

5. **Test return format changes** (20 min)
   - Verify brief format meets <100 token requirement
   - Verify artifact paths are correct
   - Verify no regression in functionality

### Modified Files

- `.opencode/command/implement.md` (Stage 8, lines 366-387)

### Success Criteria

- [ ] Stage 8 checks for summary artifact in subagent return
- [ ] Stage 8 creates summary artifact if missing
- [ ] Return format is brief (3-5 sentences, <100 tokens)
- [ ] Return includes summary artifact path reference
- [ ] Examples cover all scenarios (completed, partial, failed, blocked)
- [ ] Token count reduced by 95% (700 → 35 tokens)

### Dependencies

None

### Risks

- **Low**: Non-breaking change, only affects return formatting
- **Mitigation**: Test with existing task-executor returns (already create summaries)

---

## Phase 2: Update lean-implementation-agent [NOT STARTED]

**Estimated Time**: 1 hour

### Objectives

Add summary artifact creation to lean-implementation-agent to align with artifact-management.md standard and task-executor pattern.

### Tasks

1. **Read lean-implementation-agent current structure** (10 min)
   - File: `.opencode/agent/subagents/lean-implementation-agent.md`
   - Review Step 5 (Write final Lean files, lines 134-144)
   - Review Step 6 (Return standardized result, lines 146-158)
   - Identify insertion point for summary creation

2. **Design summary artifact content** (10 min)
   - Lean files modified/created
   - Compilation status (success/degraded/failed)
   - Tool availability status (lean-lsp-mcp)
   - Iteration count (if compilation attempted)
   - Errors encountered (if any)
   - Next steps for user

3. **Add Step 5b for summary creation** (20 min)
   - Insert between Step 5 and Step 6
   - Create summaries/ subdirectory (lazy creation)
   - Generate filename: `implementation-summary-{YYYYMMDD}.md`
   - Write summary (3-5 sentences, <100 tokens)
   - Follow artifact-management.md standard

4. **Update Step 6 to include summary artifact** (10 min)
   - Add summary artifact to artifacts array in return
   - Verify return format matches subagent-return-format.md
   - Include summary in both successful and degraded returns

5. **Test summary artifact creation** (10 min)
   - Verify lazy directory creation works
   - Verify summary follows <100 token limit
   - Verify summary artifact included in return

### Modified Files

- `.opencode/agent/subagents/lean-implementation-agent.md` (add Step 5b, update Step 6)

### Success Criteria

- [ ] Step 5b added for summary artifact creation
- [ ] Lazy directory creation for summaries/
- [ ] Summary filename format: `implementation-summary-{YYYYMMDD}.md`
- [ ] Summary content follows artifact-management.md (3-5 sentences, <100 tokens)
- [ ] Summary artifact included in return artifacts array
- [ ] No emojis in summary
- [ ] Aligns with task-executor pattern (lines 145-160)

### Dependencies

None (parallel with Phase 1)

### Risks

- **Low**: Follows proven task-executor pattern
- **Mitigation**: Copy structure from task-executor.md lines 145-160

---

## Phase 3: Testing and Validation [NOT STARTED]

**Estimated Time**: 0.5 hours

### Objectives

Validate that both /implement command and lean-implementation-agent create summaries correctly and return brief overviews, achieving 95% context window reduction.

### Tasks

1. **Test Case 1: Simple Lean implementation (no plan)** (10 min)
   - Execute lean-implementation-agent directly (simulated)
   - Verify summary artifact created in summaries/
   - Verify /implement returns brief overview with path
   - Measure token count (<100 tokens)

2. **Test Case 2: Complex multi-phase implementation** (10 min)
   - Execute task-executor for multi-phase task
   - Verify task-executor creates summary per phase
   - Verify /implement returns brief overview with path
   - Measure token count (<100 tokens)

3. **Test Case 3: Partial implementation (timeout)** (5 min)
   - Simulate timeout scenario
   - Verify partial summary created
   - Verify /implement returns brief overview with resume instructions
   - Measure token count (<100 tokens)

4. **Test Case 4: Failed implementation** (5 min)
   - Simulate failure scenario
   - Verify error details in summary artifact (not in return)
   - Verify /implement returns brief overview with error reference
   - Measure token count (<100 tokens)

5. **Regression testing** (5 min)
   - Verify no functional regressions
   - Verify artifact files still created correctly
   - Verify TODO.md and state.json updates work
   - Verify git commits work

### Validation Criteria

- [ ] All returns from /implement are <100 tokens
- [ ] All implementation summary artifacts exist in summaries/
- [ ] All summary artifacts follow artifact-management.md standard (3-5 sentences)
- [ ] No functional regressions in implementation workflow
- [ ] 95% context window reduction achieved (700 → 35 tokens)
- [ ] No emojis in any outputs or artifacts
- [ ] Lazy directory creation works correctly

### Success Metrics

- **Token Reduction**: 95% (700 → 35 tokens for typical implementation)
- **Summary Quality**: All summaries 3-5 sentences, <100 tokens
- **Artifact Creation**: 100% success rate for summary creation
- **No Regressions**: All existing functionality works

### Dependencies

- Phase 1 (required)
- Phase 2 (required)

### Risks

- **Low**: Testing phase only, no code changes
- **Mitigation**: Comprehensive test coverage of all scenarios

---

## Implementation Strategy

### Approach

Two-tier fix with parallel phases:

1. **Phase 1**: Update /implement command to create/reference summaries (1.5h)
2. **Phase 2**: Update lean-implementation-agent to create summaries (1h, parallel)
3. **Phase 3**: Test all scenarios and validate (0.5h, sequential)

### Key Design Decisions

1. **Non-breaking**: Only affects return format, not functionality
2. **Follows standard**: Aligns with artifact-management.md and task-executor pattern
3. **Lazy creation**: Summaries directory created only when needed
4. **Brief format**: 3-5 sentences, <100 tokens per artifact-management.md

### Alternative Approaches Considered

- **Modify subagent-return-format.md**: Rejected (breaking change, high effort)
- **Keep current behavior**: Rejected (violates artifact-management.md standard)

---

## Files Affected

### Modified

1. `.opencode/command/implement.md`
   - Stage 8 (ReturnSuccess): Add summary artifact logic and brief return format

2. `.opencode/agent/subagents/lean-implementation-agent.md`
   - Add Step 5b: Create implementation summary artifact
   - Update Step 6: Include summary in artifacts array

### Referenced (No Changes)

1. `.opencode/context/core/system/artifact-management.md` (summary standard)
2. `.opencode/context/core/standards/subagent-return-format.md` (return format)
3. `.opencode/agent/subagents/task-executor.md` (reference pattern, lines 145-160)

---

## Success Criteria

### Functional

- [x] Research completed identifying root causes
- [ ] /implement Stage 8 creates/references summary artifacts
- [ ] /implement Stage 8 returns brief <100 token overviews
- [ ] lean-implementation-agent creates summary artifacts
- [ ] Summary artifacts follow artifact-management.md format
- [ ] No functional regressions

### Performance

- [ ] 95% context window reduction achieved (700 → 35 tokens)
- [ ] All returns under 100 tokens
- [ ] Summary artifacts created successfully 100% of time

### Quality

- [ ] No emojis in outputs or artifacts
- [ ] Lazy directory creation followed
- [ ] Aligns with task-executor proven pattern
- [ ] All test cases pass

---

## Testing Plan

### Unit Tests

Not applicable (prompts/documentation, not code)

### Integration Tests

1. Simple Lean implementation (no plan)
2. Complex multi-phase implementation (with plan)
3. Partial implementation (timeout)
4. Failed implementation
5. Regression: existing functionality

### Validation Metrics

- Token count reduction: 95%
- Summary creation success: 100%
- Test pass rate: 100%
- Zero regressions

---

## Rollback Plan

If issues discovered:

1. **Phase 1 rollback**: Revert implement.md Stage 8 to original format
2. **Phase 2 rollback**: Remove Step 5b from lean-implementation-agent.md
3. **Validation**: Test original behavior restored

Rollback risk: **Very Low** (documentation changes only, no code)

---

## Timeline

- **Phase 1**: 1.5 hours
- **Phase 2**: 1 hour (parallel with Phase 1)
- **Phase 3**: 0.5 hours (after Phases 1-2)

**Total**: 3 hours (2 hours parallel + 0.5 hours sequential)

**Recommended Schedule**:
- Session 1 (2h): Phases 1 and 2 in parallel
- Session 2 (0.5h): Phase 3 testing and validation

---

## Post-Implementation

### Documentation Updates

- Update artifact-management.md examples (if needed)
- Note in CHANGELOG or release notes (if applicable)

### Future Enhancements

- Apply same pattern to other commands (/review, /todo, etc.)
- Task 202 addresses similar issues in other subagents

### Monitoring

- Track context window usage per /implement execution
- Verify 95% reduction maintained over time

---

## Notes

- **Task-executor compliance**: task-executor already creates summaries (no changes needed)
- **Related work**: Task 202 fixes verbose output in task-executor and batch-task-orchestrator
- **Standard alignment**: Fully aligns with artifact-management.md and subagent-return-format.md

---

## Approval

Ready for implementation: **Yes**

**Risk Assessment**: Low
**Complexity**: Low-Medium
**Effort**: 3 hours
**Impact**: High (95% context window reduction)
