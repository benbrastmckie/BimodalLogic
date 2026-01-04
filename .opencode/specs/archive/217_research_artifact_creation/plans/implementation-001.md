# Implementation Plan: Research Artifact Creation Compliance

**Task**: 217  
**Status**: [NOT STARTED]  
**Estimated Effort**: 2 hours  
**Language**: markdown  
**Priority**: Medium  
**Created**: 2025-12-28  

---

## Overview

### Problem Statement

Research on artifact creation by all commands and subagents identified 95% compliance with artifact-management.md, status-markers.md, and command-lifecycle.md standards. Two high-priority gaps remain:

1. **implementer.md**: Missing summary artifact validation before return (Step 6)
2. **researcher.md**: Using outdated summary limit "<500 words" instead of "<100 tokens"

These gaps create inconsistency across the agent system and risk artifact creation failures going undetected.

### Scope

**In Scope**:
- Add summary validation block to implementer.md Step 6
- Update researcher.md summary limit from "<500 words" to "<100 tokens (~400 characters)"
- Ensure validation matches lean-implementation-agent and task-executor patterns
- Verify no other summary limit inconsistencies exist

**Out of Scope**:
- Medium/low priority recommendations (artifact-management.md exception documentation, validation tool creation)
- Changes to other subagents or commands
- Functional changes to artifact creation logic

### Constraints

- Must maintain backward compatibility with existing workflows
- Must follow exact validation pattern from lean-implementation-agent and task-executor
- Must preserve all existing functionality
- No changes to artifact creation timing or directory structure
- Changes are documentation-only (no code changes)

### Definition of Done

- [ ] implementer.md includes summary validation block in Step 6
- [ ] Validation block matches lean-implementation-agent pattern (lines 274-297)
- [ ] researcher.md line 141 updated to "<100 tokens (~400 characters)"
- [ ] All summary limit references in researcher.md are consistent
- [ ] No other files have outdated summary limits
- [ ] Changes reviewed for accuracy and completeness

---

## Goals and Non-Goals

### Goals

1. Achieve 100% compliance with artifact-management.md summary requirements
2. Ensure consistent validation across all implementation agents
3. Prevent undetected summary artifact creation failures
4. Align all documentation with authoritative <100 token limit

### Non-Goals

1. Change artifact creation logic or timing
2. Add new validation features beyond existing patterns
3. Update medium/low priority items from research
4. Modify command-level specifications
5. Create validation tooling or scripts

---

## Risks and Mitigations

### Risk 1: Validation Pattern Mismatch
**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**: Copy exact validation block from lean-implementation-agent.md lines 274-297, adapt variable names only

### Risk 2: Breaking Existing Workflows
**Likelihood**: Very Low  
**Impact**: High  
**Mitigation**: Changes are documentation-only; no functional changes to artifact creation logic

### Risk 3: Missing Other Inconsistencies
**Likelihood**: Low  
**Impact**: Low  
**Mitigation**: Grep all subagent files for "500 words" and "token" to verify no other outdated limits exist

---

## Implementation Phases

### Phase 1: Add Summary Validation to implementer.md [NOT STARTED]
**Estimated Effort**: 1 hour  
**Dependencies**: None

**Tasks**:
1. Read implementer.md Step 6 (lines 134-146)
2. Read lean-implementation-agent.md validation block (lines 274-297)
3. Adapt validation block for implementer context:
   - Change variable names to match implementer
   - Keep validation logic identical
   - Preserve error handling pattern
4. Insert validation block before "Return standardized result" in Step 6
5. Update step description to include validation
6. Verify XML structure is valid

**Acceptance Criteria**:
- Validation block added to implementer.md Step 6
- Block matches lean-implementation-agent pattern exactly
- Variable names adapted correctly (task_number, topic_slug)
- Error handling includes validation_failed type
- XML structure valid and properly nested

**Validation**:
- Read updated implementer.md and verify validation block present
- Compare with lean-implementation-agent.md for pattern match
- Check that all validation steps are included

---

### Phase 2: Update researcher.md Summary Limit [NOT STARTED]
**Estimated Effort**: 0.5 hours  
**Dependencies**: None

**Tasks**:
1. Read researcher.md Step 5 (lines 133-146)
2. Locate line 141: "Keep summary under 500 words"
3. Replace with: "Keep summary under 100 tokens (~400 characters)"
4. Verify Step 6 line 153 already has correct limit (<100 tokens)
5. Search researcher.md for any other "500 words" references
6. Update if found

**Acceptance Criteria**:
- Line 141 updated to "<100 tokens (~400 characters)"
- No other "500 words" references in researcher.md
- Step 6 validation limit remains <100 tokens
- Phrasing matches artifact-management.md

**Validation**:
- Grep researcher.md for "500 words" (should return 0 results)
- Grep researcher.md for "100 tokens" (should return 2 results: Step 5 and Step 6)
- Read updated line 141 to verify exact text

---

### Phase 3: Verify No Other Inconsistencies [NOT STARTED]
**Estimated Effort**: 0.5 hours  
**Dependencies**: Phase 1, Phase 2

**Tasks**:
1. Grep all subagent files for "500 words"
2. Grep all subagent files for "token" to find all limits
3. Verify all limits are <100 tokens
4. Check planner.md for any summary references (should have none)
5. Document findings

**Acceptance Criteria**:
- No "500 words" references in any subagent file
- All summary token limits are <100 tokens
- planner.md correctly has no summary requirements
- All findings documented

**Validation**:
- Run: `grep -r "500 words" .opencode/agent/subagents/`
- Run: `grep -r "token" .opencode/agent/subagents/ | grep -i summary`
- Verify all results show <100 tokens

---

## Testing and Validation

### Pre-Implementation Validation
- [ ] Read research report and summary to understand gaps
- [ ] Verify lean-implementation-agent validation pattern (lines 274-297)
- [ ] Verify task-executor validation pattern (lines 176-200)
- [ ] Confirm artifact-management.md authoritative limit (<100 tokens)

### Post-Implementation Validation
- [ ] implementer.md validation block matches reference pattern
- [ ] researcher.md has no "500 words" references
- [ ] All subagent files use consistent <100 token limit
- [ ] XML structure valid in implementer.md
- [ ] No functional changes to artifact creation

### Regression Testing
- [ ] Verify no changes to artifact creation timing
- [ ] Verify no changes to directory structure
- [ ] Verify no changes to return format
- [ ] Verify no changes to command-level specifications

---

## Artifacts and Outputs

### Modified Files
1. `.opencode/agent/subagents/implementer.md`
   - Add validation block to Step 6
   - ~15 lines added

2. `.opencode/agent/subagents/researcher.md`
   - Update line 141 summary limit
   - 1 line changed

### Verification Artifacts
- Grep results for "500 words" (should be empty)
- Grep results for token limits (should all be <100)

### No New Files Created
- This is a documentation update only
- No new artifacts, scripts, or tools

---

## Rollback/Contingency

### Rollback Plan
If issues discovered after implementation:
1. Revert changes via git: `git checkout HEAD~1 -- .opencode/agent/subagents/implementer.md .opencode/agent/subagents/researcher.md`
2. Verify rollback successful
3. Investigate issue before re-attempting

### Contingency for Validation Pattern Issues
If validation block doesn't match pattern:
1. Re-read lean-implementation-agent.md lines 274-297
2. Copy exact XML structure
3. Adapt only variable names, not logic
4. Test XML validity with parser if needed

### Contingency for Additional Inconsistencies
If Phase 3 finds more inconsistencies:
1. Document all findings
2. Assess if they should be included in this task
3. If yes: Add Phase 4 to address them
4. If no: Create new task for future work

---

## Dependencies

### Required Context Files
- `.opencode/context/core/system/artifact-management.md` (authoritative limits)
- `.opencode/context/core/standards/subagent-return-format.md` (return format)
- `.opencode/specs/217_research_artifact_creation/reports/research-001.md` (gap analysis)

### Reference Files
- `.opencode/agent/subagents/lean-implementation-agent.md` (validation pattern)
- `.opencode/agent/subagents/task-executor.md` (validation pattern)

### No External Dependencies
- No tool installations required
- No API access required
- No build steps required

---

## Notes

### Research Integration
This plan directly addresses the 2 high-priority gaps identified in research-001.md:
- Gap 4.1: Missing summary validation in implementer (lines 664-693)
- Gap 4.2: Inconsistent summary token limits (lines 696-716)

Research found 95% compliance; this implementation achieves 100% compliance.

### Validation Pattern Source
The validation block is copied from lean-implementation-agent.md (lines 274-297) which includes:
- Verify all artifacts created successfully
- Verify summary artifact exists in artifacts array
- Verify summary artifact path exists on disk
- Verify summary file contains content
- Verify summary within token limit (<100 tokens, ~400 chars)
- Verify return format matches subagent-return-format.md
- Error handling with validation_failed type

### Why <100 Tokens
From artifact-management.md line 88: Summary artifacts must be <100 tokens to fit in orchestrator context window while preserving detail for human review. This is ~400 characters or 3-5 sentences.

---

## Timeline

**Total Estimated Effort**: 2 hours

| Phase | Effort | Cumulative |
|-------|--------|------------|
| Phase 1: Add validation to implementer.md | 1.0h | 1.0h |
| Phase 2: Update researcher.md limit | 0.5h | 1.5h |
| Phase 3: Verify no other inconsistencies | 0.5h | 2.0h |

**Expected Completion**: Same day (2 hours of focused work)

---

## Success Metrics

### Compliance Metrics
- Before: 95% compliance (40/42 checks passing)
- After: 100% compliance (42/42 checks passing)

### Specific Improvements
- implementer.md: Validation coverage 0% → 100%
- researcher.md: Summary limit accuracy 50% → 100% (Step 5 fixed, Step 6 already correct)

### Quality Metrics
- Zero functional regressions
- Zero breaking changes
- 100% pattern consistency across implementation agents

---

## Approval and Sign-off

**Plan Created**: 2025-12-28  
**Plan Version**: 001  
**Research Integrated**: Yes (research-001.md)  
**Ready for Implementation**: Yes
