# Implementation Plan: Reduce Command Output Verbosity (Revised Scope)

**Project**: 207_reduce_implement_output_verbosity
**Type**: enhancement
**Priority**: medium
**Complexity**: medium
**Estimated Hours**: 4.5 (revised from 3)
**Phases**: 4 (revised from 3)
**Plan Version**: 002 (revised 2025-12-28)

---

## Metadata

- **Created**: 2025-12-28
- **Revised**: 2025-12-28
- **Language**: markdown
- **Research Input**: [.opencode/specs/207_reduce_implement_output_verbosity/reports/research-001.md]
- **Previous Plan**: [.opencode/specs/207_reduce_implement_output_verbosity/plans/implementation-001.md]
- **Dependencies**: None
- **Risk Level**: Low-Medium

---

## Revision Summary

**What Changed**: Expanded scope based on user feedback. Original plan focused only on /implement command. Revised plan addresses both /implement and /plan commands, plus provides guidance for applying pattern to all commands.

**Key Changes**:
1. Added Phase 4 to fix /plan command verbose output issue
2. /plan command should NOT create summary artifacts (different from /implement)
3. Planning subagent should return brief summary + plan reference directly
4. Updated effort estimate: 3h → 4.5h (added 1.5h for /plan fix)
5. Broader context: This is part of system-wide verbosity reduction

**Reason for Revision**: User identified that /plan command has same verbosity issue as /implement, but with different solution (no summary artifact needed, just brief return from planner subagent).

---

## Overview

Reduce command output verbosity across /implement and /plan commands to prevent bloating the primary agent's context window. This plan addresses two specific issues:

1. **/implement command**: Returns verbose subagent summaries (up to 500 chars) instead of creating/referencing summary artifacts
2. **/plan command**: Planner subagent creates summary artifacts unnecessarily, should just return brief summary + plan reference

**Key Strategy**: 
- /implement: Create summary artifacts, return brief overview with path (artifact-based)
- /plan: Skip summary artifact creation, return brief overview with plan path directly (reference-based)

**Context Window Reduction**:
- /implement: 95% reduction (700 → 35 tokens)
- /plan: 90% reduction (estimated 600 → 60 tokens)

**Broader Goal**: Establish pattern for reducing verbosity across all commands (future work).

---

## Research Inputs

Research completed 2025-12-28 for /implement command. Key findings:

1. **Root Cause (/implement)**: Stage 8 returns full subagent summaries verbatim instead of creating/referencing summary artifacts
2. **Root Cause (/plan)**: Planner subagent creates unnecessary summary artifacts when plan artifact is sufficient
3. **Existing Pattern**: task-executor creates implementation summary artifacts (lines 145-160)
4. **Impact**: 90-95% context window reduction achievable
5. **Effort**: 4.5 hours total (1.5h /implement, 1.5h /plan, 1h lean-agent, 0.5h testing)

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

## Phase 3: Fix /plan Command Verbose Output [NOT STARTED]

**Estimated Time**: 1.5 hours

**NEW PHASE - Added in revision 002**

### Objectives

Fix /plan command verbose output issue by updating planner subagent to return brief summary + plan reference directly, WITHOUT creating unnecessary summary artifacts.

### Problem Analysis

Current behavior (incorrect):
1. Planner subagent creates plan artifact (correct)
2. Planner creates summary artifact (unnecessary)
3. Planner returns verbose summary to /plan command
4. /plan command returns verbose output to orchestrator

Desired behavior:
1. Planner subagent creates plan artifact only (no summary artifact)
2. Planner returns brief summary (3-5 sentences, <100 tokens) + plan path
3. /plan command returns brief overview + plan reference to orchestrator

**Key Difference from /implement**: /plan creates ONE artifact (plan), /implement may create multiple artifacts (code files) thus needs summary. Plan artifact is self-contained documentation.

### Tasks

1. **Read /plan command current structure** (10 min)
   - File: `.opencode/command/plan.md`
   - Identify Stage 8 (ReturnSuccess) return format
   - Review planner subagent invocation

2. **Read planner subagent current structure** (15 min)
   - File: `.opencode/agent/subagents/planner.md`
   - Identify where summary artifacts are created
   - Review return format in final stage

3. **Update planner subagent return logic** (30 min)
   - Remove summary artifact creation logic
   - Keep plan artifact creation
   - Update return to include brief summary (3-5 sentences, <100 tokens)
   - Return format: brief summary + plan path reference only
   - Follow subagent-return-format.md standard

4. **Update /plan command Stage 8** (20 min)
   - Extract brief summary from planner return
   - Extract plan path from artifacts array
   - Format return: brief overview + plan reference
   - Remove any verbose summary inclusion

5. **Add examples for /plan return scenarios** (10 min)
   - Example: successful plan creation
   - Example: plan revision
   - Example: blocked plan creation

6. **Test /plan command output** (15 min)
   - Verify no summary artifacts created
   - Verify only plan artifact exists
   - Verify return is brief (<100 tokens)
   - Verify plan path reference is correct

### Modified Files

- `.opencode/agent/subagents/planner.md` (remove summary creation, update return)
- `.opencode/command/plan.md` (Stage 8 return format)

### Success Criteria

- [ ] Planner subagent does NOT create summary artifacts
- [ ] Planner subagent returns brief summary (3-5 sentences, <100 tokens)
- [ ] Planner return includes plan path reference
- [ ] /plan command Stage 8 returns brief overview + plan reference
- [ ] Token count reduced by 90% (estimated 600 → 60 tokens)
- [ ] No functional regression in planning workflow
- [ ] Plan artifacts still created correctly

### Dependencies

None (parallel with Phases 1-2)

### Risks

- **Low-Medium**: Planner is used by multiple commands
- **Mitigation**: Test with both /plan and /revise commands (both use planner)

---

## Phase 4: Testing and Validation [NOT STARTED]

**Estimated Time**: 0.5 hours

### Objectives

Validate that /implement, /plan, and lean-implementation-agent all create appropriate artifacts and return brief overviews, achieving 90-95% context window reduction.

### Tasks

1. **Test Case 1: /implement with simple Lean task** (10 min)
   - Execute lean-implementation-agent directly (simulated)
   - Verify summary artifact created in summaries/
   - Verify /implement returns brief overview with path
   - Measure token count (<100 tokens)

2. **Test Case 2: /implement with multi-phase task** (5 min)
   - Execute task-executor for multi-phase task
   - Verify task-executor creates summary per phase
   - Verify /implement returns brief overview with path
   - Measure token count (<100 tokens)

3. **Test Case 3: /plan with new task** (10 min)
   - Execute planner for new task
   - Verify NO summary artifact created
   - Verify only plan artifact exists
   - Verify /plan returns brief overview with plan path
   - Measure token count (<100 tokens)

4. **Test Case 4: /revise with existing task** (5 min)
   - Execute planner for plan revision
   - Verify NO summary artifact created
   - Verify new plan version created
   - Verify /revise returns brief overview with plan path
   - Measure token count (<100 tokens)

5. **Regression testing** (5 min)
   - Verify no functional regressions in /implement
   - Verify no functional regressions in /plan
   - Verify artifact files still created correctly
   - Verify TODO.md and state.json updates work
   - Verify git commits work

### Validation Criteria

- [ ] All /implement returns are <100 tokens
- [ ] All /plan returns are <100 tokens
- [ ] Implementation summary artifacts exist (for /implement only)
- [ ] NO summary artifacts for /plan (only plan artifacts)
- [ ] All summaries follow artifact-management.md standard (3-5 sentences)
- [ ] No functional regressions in any workflow
- [ ] 90-95% context window reduction achieved
- [ ] No emojis in any outputs or artifacts
- [ ] Lazy directory creation works correctly

### Success Metrics

- **/implement**: 95% token reduction (700 → 35 tokens)
- **/plan**: 90% token reduction (600 → 60 tokens)
- **Artifact Creation**: 100% success rate for appropriate artifacts
- **No Regressions**: All existing functionality works

### Dependencies

- Phase 1 (required)
- Phase 2 (required)
- Phase 3 (required)

### Risks

- **Low**: Testing phase only, no code changes
- **Mitigation**: Comprehensive test coverage of all scenarios

---

## Implementation Strategy

### Approach

Three-tier fix with parallel phases:

1. **Phase 1**: Update /implement command Stage 8 (1.5h)
2. **Phase 2**: Update lean-implementation-agent (1h, parallel)
3. **Phase 3**: Fix /plan command and planner subagent (1.5h, parallel)
4. **Phase 4**: Test all scenarios and validate (0.5h, sequential)

Total: 4.5 hours (3.5h parallel + 1h sequential including overlap)

### Key Design Decisions

1. **Different patterns for different commands**:
   - /implement: Create summary artifacts (multiple code files need summary)
   - /plan: NO summary artifacts (plan is self-documenting)

2. **One artifact maximum per command**:
   - /implement: Creates code files + ONE summary artifact
   - /plan: Creates ONE plan artifact (no summary)
   - /research: Creates research reports + ONE summary (if --complex flag)
   - /review: Creates ONE review summary

3. **Brief return format**: All commands return <100 tokens (3-5 sentences + path)

4. **Lazy creation**: Directories created only when writing artifacts

### Alternative Approaches Considered

- **Create summaries for all commands**: Rejected (plan artifact is self-documenting)
- **Remove summaries entirely**: Rejected (/implement needs summaries for multiple code files)
- **Modify subagent-return-format.md**: Rejected (breaking change, high effort)

---

## Files Affected

### Modified

1. `.opencode/command/implement.md`
   - Stage 8 (ReturnSuccess): Add summary artifact logic and brief return format

2. `.opencode/agent/subagents/lean-implementation-agent.md`
   - Add Step 5b: Create implementation summary artifact
   - Update Step 6: Include summary in artifacts array

3. `.opencode/command/plan.md`
   - Stage 8 (ReturnSuccess): Update to brief return format with plan reference

4. `.opencode/agent/subagents/planner.md`
   - Remove summary artifact creation
   - Update return to brief summary + plan reference

### Referenced (No Changes)

1. `.opencode/context/common/system/artifact-management.md` (summary standard)
2. `.opencode/context/common/standards/subagent-return-format.md` (return format)
3. `.opencode/agent/subagents/task-executor.md` (reference pattern, lines 145-160)

---

## Success Criteria

### Functional

- [x] Research completed identifying root causes
- [ ] /implement Stage 8 creates/references summary artifacts
- [ ] /implement Stage 8 returns brief <100 token overviews
- [ ] lean-implementation-agent creates summary artifacts
- [ ] Planner does NOT create summary artifacts
- [ ] Planner returns brief summary + plan reference
- [ ] /plan command returns brief overview + plan reference
- [ ] No functional regressions

### Performance

- [ ] /implement: 95% context window reduction (700 → 35 tokens)
- [ ] /plan: 90% context window reduction (600 → 60 tokens)
- [ ] All returns under 100 tokens
- [ ] Appropriate artifacts created 100% of time

### Quality

- [ ] No emojis in outputs or artifacts
- [ ] Lazy directory creation followed
- [ ] Aligns with proven patterns (task-executor for /implement)
- [ ] All test cases pass

---

## Testing Plan

### Integration Tests

1. /implement: Simple Lean implementation (no plan)
2. /implement: Complex multi-phase implementation (with plan)
3. /implement: Partial implementation (timeout)
4. /implement: Failed implementation
5. /plan: New task planning
6. /plan: Plan revision (/revise command)
7. Regression: existing functionality for both commands

### Validation Metrics

- Token count reduction: 90-95% depending on command
- Appropriate artifact creation: 100% success
- Test pass rate: 100%
- Zero regressions

---

## Rollback Plan

If issues discovered:

1. **Phase 1 rollback**: Revert implement.md Stage 8 to original format
2. **Phase 2 rollback**: Remove Step 5b from lean-implementation-agent.md
3. **Phase 3 rollback**: Restore planner.md summary creation, revert plan.md Stage 8
4. **Validation**: Test original behavior restored

Rollback risk: **Very Low** (documentation changes only, no code)

---

## Timeline

- **Phase 1**: 1.5 hours (parallel)
- **Phase 2**: 1 hour (parallel with Phase 1)
- **Phase 3**: 1.5 hours (parallel with Phases 1-2)
- **Phase 4**: 0.5 hours (after Phases 1-3)

**Total**: 4.5 hours (3.5 hours parallel + 1 hour including overlap and testing)

**Recommended Schedule**:
- Session 1 (3.5h): Phases 1, 2, and 3 in parallel (work on each incrementally)
- Session 2 (0.5h): Phase 4 testing and validation

---

## Post-Implementation

### Documentation Updates

- Update artifact-management.md examples with /plan vs /implement patterns
- Add note explaining when to create summary artifacts vs when not to
- Document "one artifact maximum" principle for commands

### Future Enhancements

- Apply same pattern to other commands:
  - /research: Already creates summaries correctly (with --complex flag)
  - /review: Task 206 completed, creates ONE review summary
  - /todo: Does not create artifacts (command-only)
  - /revise: Uses planner (will be fixed by Phase 3)

- Create command output verbosity standard document
- Add validation for return token counts in command templates

### Related Work

- **Task 202**: Fixes verbose output in task-executor and batch-task-orchestrator
- **Task 206**: Fixed /review command to create summaries correctly
- **Task 203**: Adds --complex flag to /research for multi-report scenarios

---

## Broader Context

This implementation is part of a system-wide effort to reduce command output verbosity and protect the primary agent's context window. The pattern established here should be applied to all commands:

**Principle**: Each command creates at most ONE artifact, returns brief summary (<100 tokens) + artifact path reference.

**Exceptions**:
- /implement may create multiple code files → needs summary artifact
- /research with --complex creates multiple reports → needs summary artifact
- Other commands should create ONE artifact only (no summary needed)

---

## Notes

- **Task-executor compliance**: Already creates summaries (no changes needed)
- **Planner change**: Removing summary creation is intentional (plan is self-documenting)
- **Standard alignment**: Fully aligns with artifact-management.md and subagent-return-format.md
- **Broader impact**: Sets pattern for all future commands

---

## Approval

Ready for implementation: **Yes**

**Risk Assessment**: Low-Medium (affects two core commands)
**Complexity**: Medium (coordinate changes across 4 files)
**Effort**: 4.5 hours (revised from 3)
**Impact**: Very High (90-95% context window reduction, affects all /plan and /implement executions)
