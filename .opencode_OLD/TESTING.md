# .opencode System Testing Guide

**Version**: 2.0  
**Status**: Active  
**Created**: 2025-12-26  
**Purpose**: Comprehensive testing checklist for the .opencode system

---

## Overview

This guide provides testing procedures for all components of the .opencode system. Testing is organized into five categories:

1. **Component Testing**: Test each component individually
2. **Integration Testing**: Test full workflows end-to-end
3. **Delegation Safety Testing**: Test safety mechanisms
4. **Language Routing Testing**: Test language-specific routing
5. **Error Recovery Testing**: Test error handling and recovery

---

## Component Testing

### Test Each Command Individually

#### /task Command

**Test Case 1: Create Simple Task**
```
Input: /task Fix typo in README.md
Expected:
- Task number assigned (e.g., 192)
- Entry created in TODO.md with [NOT STARTED]
- state.json updated
- Return: "Created task 192"
```

**Test Case 2: Create Task with Language Detection**
```
Input: /task Implement Lean proof for theorem X
Expected:
- Language field set to "lean"
- Task created with correct metadata
```

**Test Case 3: Create Task with Priority Detection**
```
Input: /task CRITICAL: Fix security vulnerability
Expected:
- Priority field set to "critical"
- Task created with high priority
```

**Validation**:
- [ ] Task number is sequential
- [ ] TODO.md entry formatted correctly
- [ ] state.json updated atomically
- [ ] Language auto-detected correctly
- [ ] Priority auto-detected correctly

---

#### /research Command

**Test Case 1: Research Without Subdivision**
```
Input: /research 192
Expected:
- Research report created
- Research summary created
- Status changed to [RESEARCHED]
- Git commit created
- Return includes artifact paths
```

**Test Case 2: Research With Subdivision (--divide)**
```
Input: /research 192 --divide
Expected:
- Topic subdivided into 3-5 subtopics
- Research conducted per subtopic
- Comprehensive report created
- Status changed to [RESEARCHED]
```

**Test Case 3: Research for Lean Task**
```
Input: /research 193 (where task 193 has Language: lean)
Expected:
- Routed to lean-research-agent
- Lean-specific research conducted
- Status changed to [RESEARCHED]
```

**Validation**:
- [ ] Research report created at correct path
- [ ] Summary created and concise (< 500 words)
- [ ] Status updated to [RESEARCHED]
- [ ] Git commit created with correct message
- [ ] Return format matches subagent-return-format.md
- [ ] Language routing works correctly

---

#### /plan Command

**Test Case 1: Plan Without Research**
```
Input: /plan 192 (no research conducted)
Expected:
- Plan created with phases
- No research inputs section
- Status changed to [PLANNED]
- Git commit created
```

**Test Case 2: Plan With Research**
```
Input: /plan 193 (research already conducted)
Expected:
- Research findings harvested from TODO.md
- Research integrated into plan
- Plan created with research inputs section
- Status changed to [PLANNED]
```

**Test Case 3: Plan Validation**
```
Expected plan structure:
- Metadata (effort, language, type)
- Overview (problem, scope, constraints)
- Phases (each 1-2 hours, marked [NOT STARTED])
- Testing and validation section
- Rollback/contingency section
```

**Validation**:
- [ ] Plan created at correct path
- [ ] Plan follows plan.md template exactly
- [ ] All phases marked [NOT STARTED]
- [ ] Effort estimates reasonable (1-2 hours per phase)
- [ ] Research integrated if available
- [ ] Status updated to [PLANNED]
- [ ] Git commit created

---

#### /implement Command

**Test Case 1: Simple Implementation (No Plan)**
```
Input: /implement 192 (no plan exists)
Expected:
- Direct implementation executed
- Implementation summary created
- Status changed to [COMPLETED]
- Git commit created
```

**Test Case 2: Phased Implementation (With Plan)**
```
Input: /implement 193 (plan exists with 4 phases)
Expected:
- Phase 1 executed, marked [COMPLETED], git commit
- Phase 2 executed, marked [COMPLETED], git commit
- Phase 3 executed, marked [COMPLETED], git commit
- Phase 4 executed, marked [COMPLETED], git commit
- Status changed to [COMPLETED]
- Final git commit
```

**Test Case 3: Resume After Timeout**
```
Input: /implement 193 (times out after phase 2)
Expected:
- Phases 1-2 completed
- Return: "Partial completion. Resume with /implement 193"
- Status remains [IN PROGRESS]

Input: /implement 193 (resume)
Expected:
- Phases 1-2 skipped (already completed)
- Phase 3 executed
- Phase 4 executed
- Status changed to [COMPLETED]
```

**Test Case 4: Lean Implementation**
```
Input: /implement 194 (Language: lean)
Expected:
- Routed to lean-implementation-agent
- lean-lsp-mcp used if available
- Lean files modified
- Compilation checked
- Status changed to [COMPLETED]
```

**Validation**:
- [ ] Implementation executes correctly
- [ ] Phases executed in order
- [ ] Phase statuses updated in plan file
- [ ] Git commits created per phase
- [ ] Resume logic works (skips completed phases)
- [ ] Status updated to [COMPLETED]
- [ ] Language routing works correctly

---

#### /revise Command

**Test Case 1: Revise Existing Plan**
```
Input: /revise 193 (plan v1 exists)
Expected:
- New plan created: implementation-002.md
- TODO.md updated with new plan link
- Status preserved (not changed)
- Git commit created
```

**Validation**:
- [ ] New plan version created
- [ ] TODO.md updated with new plan link
- [ ] Status not changed
- [ ] Git commit created

---

#### /review Command

**Test Case 1: Full Codebase Review**
```
Input: /review
Expected:
- Codebase analyzed
- Registries updated (IMPLEMENTATION_STATUS, SORRY, TACTIC, FEATURE)
- Tasks created for identified work
- Git commit created
```

**Validation**:
- [ ] All registries updated
- [ ] Tasks created for identified work
- [ ] Git commit created

---

#### /todo Command

**Test Case 1: Clean Completed Tasks**
```
Input: /todo (10 completed tasks exist)
Expected:
- User confirmation requested (> 5 tasks)
- 10 tasks removed from TODO.md
- state.json updated
- Task numbering preserved
- Git commit created
```

**Validation**:
- [ ] Completed tasks removed
- [ ] state.json updated
- [ ] Task numbering preserved
- [ ] Git commit created

---

#### /errors Command

**Test Case 1: Analyze Unaddressed Errors**
```
Input: /errors
Expected:
- Errors grouped by type and root cause
- Historical fix effectiveness analyzed
- Fix recommendations generated
- Fix plan created
- TODO task created linking fix plan
- errors.json updated with fix references
- Git commit created
```

**Test Case 2: Filter by Type**
```
Input: /errors --type delegation_hang
Expected:
- Only delegation_hang errors analyzed
- Fix plan specific to delegation hangs
```

**Validation**:
- [ ] Errors grouped correctly
- [ ] Fix effectiveness calculated
- [ ] Recommendations specific and actionable
- [ ] Fix plan created
- [ ] TODO task created
- [ ] errors.json updated
- [ ] Git commit created

---

### Test Each Subagent Individually

#### atomic-task-numberer

**Test Case 1: Get Next Task Number**
```
Input: (no input, reads TODO.md)
Expected:
- Returns next sequential task number
- Return format matches subagent-return-format.md
```

**Test Case 2: Handle Empty TODO.md**
```
Input: (TODO.md has no tasks)
Expected:
- Returns 1 as first task number
```

**Validation**:
- [ ] Task numbers sequential
- [ ] Handles empty TODO.md
- [ ] Return format correct

---

#### status-sync-manager

**Test Case 1: Atomic Status Update**
```
Input: task_number=192, new_status="completed", timestamp="2025-12-26T10:00:00Z"
Expected:
- TODO.md updated
- state.json updated
- Plan file updated (if exists)
- All updates atomic (all or nothing)
```

**Test Case 2: Rollback on Failure**
```
Input: task_number=192, new_status="completed" (simulate file I/O error)
Expected:
- All updates rolled back
- No partial updates
- Error returned
```

**Validation**:
- [ ] All files updated atomically
- [ ] Rollback works on failure
- [ ] Return format correct

---

#### researcher

**Test Case 1: General Research**
```
Input: task_number=192, research_topic="LeanSearch API integration"
Expected:
- Research report created
- Research summary created
- Citations included
- Return format correct
```

**Test Case 2: Research With Subdivision**
```
Input: task_number=192, divide_topics=true
Expected:
- Topic subdivided
- Research per subtopic
- Comprehensive report
```

**Validation**:
- [ ] Research report comprehensive
- [ ] Summary concise (< 500 words)
- [ ] Citations included
- [ ] No emojis
- [ ] Return format correct

---

#### planner

**Test Case 1: Create Plan Without Research**
```
Input: task_number=192
Expected:
- Plan created with phases
- No research inputs section
- Return format correct
```

**Test Case 2: Create Plan With Research**
```
Input: task_number=193 (research exists)
Expected:
- Research harvested from TODO.md
- Research integrated into plan
- Return format correct
```

**Validation**:
- [ ] Plan follows template
- [ ] Phases appropriately sized (1-2 hours)
- [ ] Research integrated if available
- [ ] Return format correct

---

#### implementer

**Test Case 1: Simple Implementation**
```
Input: task_number=192, language="markdown"
Expected:
- Implementation executed
- Summary created
- Return format correct
```

**Validation**:
- [ ] Implementation correct
- [ ] Summary created
- [ ] Return format correct

---

#### task-executor

**Test Case 1: Multi-Phase Execution**
```
Input: task_number=193, plan_path="..."
Expected:
- All phases executed in order
- Phase statuses updated
- Git commits per phase
- Return format correct
```

**Test Case 2: Resume From Phase**
```
Input: task_number=193, resume_from_phase=3
Expected:
- Phases 1-2 skipped
- Phase 3 executed
- Phase 4 executed
- Return format correct
```

**Validation**:
- [ ] Phases executed in order
- [ ] Resume logic works
- [ ] Git commits per phase
- [ ] Return format correct

---

#### lean-implementation-agent

**Test Case 1: Lean Implementation With Tool**
```
Input: task_number=194, lean_files=["Logos/Core/Syntax/Formula.lean"]
Expected:
- lean-lsp-mcp used
- Lean file modified
- Compilation checked
- Return format correct
```

**Test Case 2: Lean Implementation Without Tool**
```
Input: task_number=194 (lean-lsp-mcp unavailable)
Expected:
- Fallback to direct file modification
- Tool unavailability logged to errors.json
- Return format correct
```

**Validation**:
- [ ] lean-lsp-mcp used if available
- [ ] Graceful degradation if unavailable
- [ ] Error logged if tool unavailable
- [ ] Return format correct

---

#### lean-research-agent

**Test Case 1: Lean Research**
```
Input: research_topic="Lean 4 tactic development"
Expected:
- Lean-specific research conducted
- Research report created
- Return format correct
```

**Validation**:
- [ ] Lean-specific research
- [ ] Return format correct

---

#### error-diagnostics-agent

**Test Case 1: Error Analysis**
```
Input: errors_grouped={...}, historical_fixes=[...]
Expected:
- Errors grouped by root cause
- Fix effectiveness calculated
- Recommendations generated
- Fix plan outline created
- Return format correct
```

**Validation**:
- [ ] Error grouping correct
- [ ] Fix effectiveness calculated
- [ ] Recommendations specific
- [ ] Return format correct

---

#### git-workflow-manager

**Test Case 1: Create Git Commit**
```
Input: scope_files=[...], message_template="task {number}: {description}", task_context={...}
Expected:
- Files staged
- Commit created
- Commit hash returned
- Return format correct
```

**Test Case 2: Handle Commit Failure**
```
Input: scope_files=[] (nothing to commit)
Expected:
- Error logged to errors.json
- Failed status returned (non-blocking)
- Return format correct
```

**Validation**:
- [ ] Scoped commits work
- [ ] Commit messages formatted correctly
- [ ] Errors logged on failure
- [ ] Non-blocking failures
- [ ] Return format correct

---

### Return Format Validation

**For All Subagents**:

Validate return against subagent-return-format.md:

```json
{
  "status": "completed|failed|partial|blocked",
  "summary": "2-5 sentences, max 100 tokens",
  "artifacts": [...],
  "metadata": {
    "session_id": "sess_...",
    "duration_seconds": 123,
    "agent_type": "...",
    "delegation_depth": 1,
    "delegation_path": [...]
  },
  "errors": [...],
  "next_steps": "..."
}
```

**Validation Checklist**:
- [ ] All required fields present
- [ ] Status is valid enum
- [ ] Summary within length limits
- [ ] Artifacts have valid paths
- [ ] Metadata complete
- [ ] Errors match status (failed/partial → errors present)
- [ ] session_id format correct
- [ ] delegation_depth correct
- [ ] delegation_path correct

---

## Integration Testing

### Test 1: Full Workflow (task → research → plan → implement)

**Steps**:
```
1. /task Integrate LeanSearch API for proof search
   → Task 195 created

2. /research 195
   → Research completed
   → Status: [RESEARCHED]
   → Git commit created

3. /plan 195
   → Plan created with 4 phases
   → Research integrated
   → Status: [PLANNED]
   → Git commit created

4. /implement 195
   → Phase 1 executed, git commit
   → Phase 2 executed, git commit
   → Phase 3 executed, git commit
   → Phase 4 executed, git commit
   → Status: [COMPLETED]
   → Final git commit
```

**Validation**:
- [ ] All commands execute successfully
- [ ] Status transitions correct
- [ ] Git commits created at each step
- [ ] Artifacts created correctly
- [ ] Final status is [COMPLETED]

---

### Test 2: Resume Interrupted Implementation

**Steps**:
```
1. /implement 195
   → Starts implementation
   → Completes phases 1-2
   → Times out after 2 hours
   → Status: [IN PROGRESS]
   → Return: "Partial completion. Resume with /implement 195"

2. Check plan file
   → Phases 1-2 marked [COMPLETED]
   → Phases 3-4 marked [NOT STARTED]

3. /implement 195
   → Resumes from phase 3
   → Completes phases 3-4
   → Status: [COMPLETED]
```

**Validation**:
- [ ] Timeout handled gracefully
- [ ] Partial results saved
- [ ] Resume skips completed phases
- [ ] Final status is [COMPLETED]

---

### Test 3: Error Analysis and Fix Plan Creation

**Steps**:
```
1. Simulate errors (create entries in errors.json)

2. /errors
   → Analyzes errors
   → Groups by type and root cause
   → Checks fix effectiveness
   → Creates fix plan
   → Creates TODO task
   → Updates errors.json
   → Git commit created

3. /implement {fix_task_number}
   → Executes fix plan
   → Resolves errors
   → Updates errors.json with fix status
```

**Validation**:
- [ ] Errors analyzed correctly
- [ ] Fix plan created
- [ ] TODO task created
- [ ] errors.json updated
- [ ] Fix implementation resolves errors

---

### Test 4: Git Commit Creation and Scoping

**Steps**:
```
1. /implement 195 (with plan)
   → Phase 1 completes
   → Git commit created with scoped files

2. Check git log
   → Commit message: "task 195 phase 1: {description}"
   → Only phase 1 files committed
   → TODO.md and state.json included

3. Phase 2 completes
   → Git commit created with scoped files
   → Commit message: "task 195 phase 2: {description}"
```

**Validation**:
- [ ] Git commits created per phase
- [ ] Commit messages formatted correctly
- [ ] Only scoped files committed
- [ ] Tracking files (TODO.md, state.json) included

---

## Delegation Safety Testing

### Test 1: Cycle Detection

**Setup**: Force a delegation cycle

**Steps**:
```
1. Modify orchestrator to allow cycle (for testing)
2. Create delegation: orchestrator → implement → task-executor → implement
3. Attempt delegation
```

**Expected**:
- Cycle detected before delegation
- Error returned: "Cycle detected: [...] → implement"
- No infinite loop

**Validation**:
- [ ] Cycle detected
- [ ] Error returned
- [ ] No infinite loop

---

### Test 2: Depth Limit Enforcement

**Setup**: Force delegation depth > 3

**Steps**:
```
1. Create delegation chain: orchestrator → command → subagent → specialist → helper
2. Attempt delegation from helper (depth 4)
```

**Expected**:
- Depth limit exceeded before delegation
- Error returned: "Max delegation depth (3) exceeded"
- No delegation at depth 4

**Validation**:
- [ ] Depth limit enforced
- [ ] Error returned
- [ ] No delegation beyond depth 3

---

### Test 3: Timeout Handling

**Setup**: Simulate long-running subagent

**Steps**:
```
1. Create mock subagent that takes 7200s (2 hours)
2. Set timeout to 3600s (1 hour)
3. Invoke subagent
4. Wait for timeout
```

**Expected**:
- Timeout after 3600s
- Partial results returned (if available)
- Status: "partial"
- Error: "timeout"
- Task status: [IN PROGRESS] (not failed)

**Validation**:
- [ ] Timeout enforced
- [ ] Partial results returned
- [ ] Task not marked failed
- [ ] Error logged

---

### Test 4: Return Validation

**Setup**: Send malformed return from subagent

**Steps**:
```
1. Create mock subagent that returns invalid format
2. Invoke subagent
3. Receive malformed return
```

**Expected**:
- Validation error detected
- Error returned: "Return validation failed: {details}"
- Clear message about what's wrong

**Validation**:
- [ ] Validation error detected
- [ ] Clear error message
- [ ] No crash or hang

---

## Language Routing Testing

### Test 1: Lean Task Routing

**Steps**:
```
1. /task Implement Lean proof for theorem X
   → Language: lean

2. /research {number}
   → Routed to lean-research-agent

3. /implement {number}
   → Routed to lean-implementation-agent
   → lean-lsp-mcp used if available
```

**Validation**:
- [ ] Language detected as "lean"
- [ ] Research routed to lean-research-agent
- [ ] Implementation routed to lean-implementation-agent
- [ ] lean-lsp-mcp used if available

---

### Test 2: Markdown Task Routing

**Steps**:
```
1. /task Update documentation in README.md
   → Language: markdown

2. /research {number}
   → Routed to researcher (general)

3. /implement {number}
   → Routed to implementer (general)
```

**Validation**:
- [ ] Language detected as "markdown"
- [ ] Research routed to general researcher
- [ ] Implementation routed to general implementer

---

### Test 3: Mixed-Language Project

**Steps**:
```
1. Create Lean task (task 195)
2. Create markdown task (task 196)
3. Implement both tasks
```

**Expected**:
- Task 195 uses lean agents
- Task 196 uses general agents
- No routing conflicts

**Validation**:
- [ ] Lean tasks use lean agents
- [ ] Non-Lean tasks use general agents
- [ ] No routing conflicts

---

## Error Recovery Testing

### Test 1: Tool Unavailable (lean-lsp-mcp)

**Setup**: Remove lean-lsp-mcp from .mcp.json

**Steps**:
```
1. /implement {lean_task_number}
   → lean-implementation-agent invoked
   → Checks for lean-lsp-mcp
   → Tool unavailable
```

**Expected**:
- Tool unavailability detected
- Fallback to direct file modification
- Error logged to errors.json
- Implementation continues (degraded mode)

**Validation**:
- [ ] Tool unavailability detected
- [ ] Graceful degradation
- [ ] Error logged
- [ ] Implementation completes

---

### Test 2: Status Sync Failures

**Setup**: Simulate concurrent file updates

**Steps**:
```
1. Start /implement {number} (updates TODO.md)
2. Simultaneously modify TODO.md externally
3. Trigger status sync
```

**Expected**:
- File I/O error detected
- Retry logic activated (exponential backoff)
- Status sync succeeds after retry
- Or rollback if all retries fail

**Validation**:
- [ ] Retry logic works
- [ ] Status sync eventually succeeds
- [ ] Or rollback on failure

---

### Test 3: Git Commit Failures

**Setup**: Create scenario where git commit fails

**Steps**:
```
1. /implement {number}
   → Implementation completes
   → Attempt git commit
   → Commit fails (nothing to commit)
```

**Expected**:
- Git commit failure detected
- Error logged to errors.json
- Task NOT failed (non-blocking)
- User notified of commit failure

**Validation**:
- [ ] Commit failure detected
- [ ] Error logged
- [ ] Task not failed
- [ ] User notified

---

### Test 4: Partial Completion Scenarios

**Setup**: Simulate timeout during multi-phase implementation

**Steps**:
```
1. /implement {number} (plan with 5 phases)
   → Phases 1-3 complete
   → Timeout after 2 hours
   → Partial results returned
```

**Expected**:
- Phases 1-3 marked [COMPLETED]
- Phases 4-5 remain [NOT STARTED]
- Status: [IN PROGRESS]
- Return: "Partial completion. Resume with /implement {number}"

**Validation**:
- [ ] Partial results saved
- [ ] Phase statuses correct
- [ ] Task status [IN PROGRESS]
- [ ] Resume message provided

---

## Testing Checklist Summary

### Component Testing
- [ ] All 8 commands tested individually
- [ ] All 8 subagents tested individually
- [ ] Return format validated for all subagents

### Integration Testing
- [ ] Full workflow (task → research → plan → implement) tested
- [ ] Resume functionality tested
- [ ] Error analysis workflow tested
- [ ] Git commit creation tested

### Delegation Safety Testing
- [ ] Cycle detection tested
- [ ] Depth limit enforcement tested
- [ ] Timeout handling tested
- [ ] Return validation tested

### Language Routing Testing
- [ ] Lean task routing tested
- [ ] Markdown task routing tested
- [ ] Mixed-language project tested

### Error Recovery Testing
- [ ] Tool unavailable tested
- [ ] Status sync failures tested
- [ ] Git commit failures tested
- [ ] Partial completion tested

---

## Continuous Testing

### Regression Testing

After any changes to the system:
1. Run full component testing suite
2. Run integration testing suite
3. Verify delegation safety mechanisms
4. Test language routing
5. Test error recovery

### Performance Testing

Monitor and optimize:
- Command execution time
- Subagent execution time
- Delegation overhead
- File I/O performance
- Git commit performance

### User Acceptance Testing

Validate with real-world usage:
- Create real tasks
- Execute full workflows
- Monitor for errors
- Collect user feedback
- Iterate on improvements

---

## Related Documentation

- Architecture: `.opencode/ARCHITECTURE.md`
- Quick Start: `.opencode/QUICK-START.md`
- Delegation Guide: `.opencode/context/core/workflows/subagent-delegation-guide.md`
- Return Format: `.opencode/context/core/standards/subagent-return-format.md`
