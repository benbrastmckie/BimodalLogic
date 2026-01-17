# Research Report: Alternative to Task 283 with Subagent-Owned Pre-Flight and Post-Flight Work

**Task**: 286 - Research alternative to task 283 with subagent-owned pre-flight and post-flight work  
**Started**: 2026-01-04  
**Completed**: 2026-01-04  
**Effort**: 2.5 hours  
**Priority**: High  
**Dependencies**: Task 283 (comparison baseline)  
**Sources/Inputs**: 
- specs/283_fix_systematic_status_synchronization_failure/reports/research-001.md
- specs/283_fix_systematic_status_synchronization_failure/plans/implementation-001.md
- .opencode/agent/orchestrator.md
- .opencode/agent/subagents/researcher.md
- .opencode/agent/subagents/planner.md
- .opencode/agent/subagents/implementer.md
- .opencode/agent/subagents/status-sync-manager.md
- .opencode/context/core/standards/subagent-return-format.md
- .opencode/context/core/system/state-management.md

**Artifacts**: 
- specs/286_research_alternative_to_task_283_with_subagent_owned_pre_flight_and_post_flight_work/reports/research-001.md

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research analyzes an alternative architectural approach to Task 283's orchestrator-centric status synchronization solution. The key insight is that **the current system ALREADY implements subagent-owned preflight and postflight work** - Task 275 added comprehensive status update instructions to all subagent specifications (researcher.md, planner.md, implementer.md). The problem is NOT architectural ownership, but rather **enforcement and validation**.

Task 283 proposes an orchestrator-centric solution: extend orchestrator Stage 4 validation to verify status updates occurred and add automatic recovery. This research proposes a **subagent-centric alternative**: keep workflow ownership in subagents but strengthen their specifications with explicit validation requirements, stage logging, and self-healing mechanisms.

**Key Finding**: Both approaches solve the same problem (status synchronization failures) but differ in WHERE validation and recovery occur:
- **Task 283 (Orchestrator-Centric)**: Orchestrator validates and recovers after subagent returns
- **Task 286 (Subagent-Centric)**: Subagents validate and self-heal during workflow execution

**Recommendation**: **Hybrid approach** - Combine subagent self-validation (primary) with orchestrator validation (safety net). This provides defense-in-depth while maintaining subagent autonomy and workflow ownership.

## Context & Scope

### Problem Statement

Task 283 identified systematic status synchronization failures affecting ALL workflow commands (/research, /plan, /implement, /revise). The root cause is that subagents do not consistently invoke status-sync-manager during preflight and postflight phases, despite having correct specifications (Task 275 fix).

Task 283 proposes an orchestrator-centric solution: move validation responsibility to orchestrator Stage 4, which checks if status updates occurred and automatically recovers if they didn't.

This research explores an alternative: **keep workflow ownership in subagents but strengthen their ability to self-validate and self-heal**.

### Research Questions

1. **Current Architecture**: How does the current system distribute preflight/postflight responsibilities?
2. **Task 283 Approach**: What are the strengths and weaknesses of orchestrator-centric validation?
3. **Alternative Approach**: What would subagent-centric validation look like?
4. **Comparison**: Which approach better aligns with system principles and long-term maintainability?
5. **Hybrid Option**: Can we combine both approaches for defense-in-depth?

### Scope

**In Scope**:
1. Analysis of current architecture (orchestrator vs. subagent responsibilities)
2. Detailed comparison of orchestrator-centric vs. subagent-centric approaches
3. Design of subagent-centric alternative with self-validation and self-healing
4. Evaluation of hybrid approach combining both strategies
5. Recommendations with implementation complexity estimates

**Out of Scope**:
1. Implementation of either approach (research only)
2. Changes to status-sync-manager (already correct)
3. Changes to command specifications (thin routers)
4. Task 240 OpenAgents migration (separate architectural initiative)

## Key Findings

### Finding 1: Current Architecture Already Implements Subagent-Owned Workflows

**Evidence**: All three primary subagents (researcher.md, planner.md, implementer.md) have complete 6-stage workflow specifications with preflight and postflight status updates.

**Researcher.md** (lines 140-205):
```xml
<stage_1_preflight>
  <action>Preflight: Parse arguments, validate task, update status to [RESEARCHING]</action>
  <process>
    8. Invoke status-sync-manager to mark [RESEARCHING]:
       a. Prepare delegation context
       b. Invoke status-sync-manager with timeout (60s)
       c. Validate return status == "completed"
       d. Verify files_updated includes ["TODO.md", "state.json"]
       e. If status update fails: Abort with error and recommendation
  </process>
</stage_1_preflight>

<stage_5_postflight>
  <action>Postflight: Update status to [RESEARCHED], link report, create git commit</action>
  <process>
    2. Invoke status-sync-manager to mark [RESEARCHED]:
       a. Prepare delegation context with validated_artifacts
       b. Invoke status-sync-manager with timeout (60s)
       c. Validate return status == "completed"
       d. Verify files_updated includes ["TODO.md", "state.json"]
       e. Verify artifact linked in TODO.md
       f. If status update fails: Log error but continue (artifact exists)
  </process>
</stage_5_postflight>
```

**Planner.md** and **Implementer.md** have identical patterns (lines 96-157 in planner.md, lines 100-157 in implementer.md).

**Conclusion**: The system ALREADY implements subagent-owned preflight and postflight work. Task 275 successfully added these specifications. The problem is NOT architectural ownership but ENFORCEMENT.

### Finding 2: Task 283 Proposes Orchestrator-Centric Validation

**Task 283 Approach** (from implementation plan):

1. **Extend Orchestrator Stage 4 Validation**:
   - After subagent returns, read TODO.md and state.json
   - Compare actual status with expected status
   - Log warning if mismatch detected

2. **Add Automatic Recovery**:
   - If status mismatch detected, invoke status-sync-manager from orchestrator
   - Pass subagent return data to status-sync-manager
   - Update TODO.md and state.json to correct status
   - Log recovery action

3. **Add Stage Execution Logging**:
   - Require subagents to include "stage_log" field in return JSON
   - Orchestrator validates all stages were executed
   - Log warnings for skipped stages

**Strengths**:
- Centralized validation logic (single point of truth)
- Guaranteed recovery (orchestrator always fixes missing updates)
- Backward compatible (validation is additive, not breaking)
- Simple for subagents (they just return JSON, orchestrator handles rest)

**Weaknesses**:
- Violates workflow ownership principle (orchestrator reaches into subagent domain)
- Reactive rather than proactive (fixes problems after they occur)
- Increases orchestrator complexity (more responsibilities)
- Duplicates status update logic (subagents invoke status-sync-manager, orchestrator does too)
- May conflict with Task 240 OpenAgents migration (which aims to simplify orchestrator)

### Finding 3: Subagent-Centric Alternative - Self-Validation and Self-Healing

**Alternative Approach**: Strengthen subagent specifications to include explicit self-validation and self-healing mechanisms.

**Design Principles**:
1. **Subagents Own Their Workflows**: Preflight, core work, postflight, validation, recovery
2. **Explicit Validation Steps**: Each stage includes validation checkpoints
3. **Self-Healing**: Subagents detect and fix their own failures
4. **Orchestrator as Safety Net**: Orchestrator validates return format but trusts subagent process

**Implementation Pattern**:

```xml
<stage_1_preflight>
  <action>Preflight: Parse arguments, validate task, update status to [RESEARCHING]</action>
  <process>
    1-7. [existing steps]
    8. Invoke status-sync-manager to mark [RESEARCHING]
    9. VALIDATE status update succeeded:
       a. Read TODO.md and verify status marker changed to [RESEARCHING]
       b. Read state.json and verify status field changed to "researching"
       c. Verify timestamp added to both files
       d. If validation FAILS:
          - Log error with details
          - RETRY status update (max 2 retries)
          - If retry fails: ABORT with clear error message
    10. Log preflight completion with validation result
  </process>
  <validation>
    CRITICAL: You MUST verify status update succeeded before proceeding.
    Do NOT proceed to Stage 2 if validation fails.
  </validation>
</stage_1_preflight>

<stage_5_postflight>
  <action>Postflight: Update status to [RESEARCHED], link report, create git commit</action>
  <process>
    1. Generate completion timestamp
    2. Invoke status-sync-manager to mark [RESEARCHED]
    3. VALIDATE status update succeeded:
       a. Read TODO.md and verify status marker changed to [RESEARCHED]
       b. Read state.json and verify status field changed to "researched"
       c. Verify artifact linked in TODO.md
       d. If validation FAILS:
          - Log warning (non-critical, artifact exists)
          - RETRY status update (max 2 retries)
          - If retry fails: Log error but continue (artifact is primary output)
    4. Invoke git-workflow-manager
    5. Log postflight completion with validation result
  </process>
  <validation>
    RECOMMENDED: Verify status update succeeded.
    If validation fails, log warning but continue (artifact is primary output).
  </validation>
</stage_5_postflight>

<stage_6_return>
  <action>Return: Format and return standardized result with stage log</action>
  <process>
    1. Format return following subagent-return-format.md
    2. Include stage_log with validation results:
       {
         "stage_log": [
           {"stage": 1, "name": "Preflight", "executed": true, "validated": true, "duration_seconds": 15},
           {"stage": 2, "name": "Research", "executed": true, "validated": true, "duration_seconds": 120},
           {"stage": 3, "name": "Artifact Creation", "executed": true, "validated": true, "duration_seconds": 30},
           {"stage": 4, "name": "Validation", "executed": true, "validated": true, "duration_seconds": 5},
           {"stage": 5, "name": "Postflight", "executed": true, "validated": true, "duration_seconds": 20},
           {"stage": 6, "name": "Return", "executed": true, "validated": true, "duration_seconds": 2}
         ],
         "validation_summary": {
           "preflight_status_update": "success",
           "postflight_status_update": "success",
           "artifact_validation": "success",
           "git_commit": "success"
         }
       }
    3. Return standardized result
  </process>
</stage_6_return>
```

**Key Differences from Task 283**:
- **Validation Location**: In subagent workflow (not orchestrator)
- **Recovery Location**: In subagent workflow (not orchestrator)
- **Validation Timing**: During execution (not after return)
- **Responsibility**: Subagent owns validation (orchestrator trusts but verifies)

### Finding 4: Comparison - Orchestrator-Centric vs. Subagent-Centric

| Dimension | Task 283 (Orchestrator-Centric) | Task 286 (Subagent-Centric) |
|-----------|----------------------------------|------------------------------|
| **Validation Location** | Orchestrator Stage 4 (after return) | Subagent Stages 1 & 5 (during execution) |
| **Recovery Location** | Orchestrator Stage 4 | Subagent Stages 1 & 5 |
| **Validation Timing** | Reactive (after workflow completes) | Proactive (during workflow execution) |
| **Workflow Ownership** | Split (subagent executes, orchestrator validates) | Unified (subagent owns entire workflow) |
| **Orchestrator Complexity** | Higher (validation + recovery logic) | Lower (trust subagent process) |
| **Subagent Complexity** | Lower (just return JSON) | Higher (self-validation + self-healing) |
| **Failure Detection** | After return (orchestrator detects) | During execution (subagent detects) |
| **Recovery Mechanism** | Orchestrator invokes status-sync-manager | Subagent retries status-sync-manager |
| **Backward Compatibility** | High (validation is additive) | Medium (requires subagent spec updates) |
| **Alignment with Task 240** | Low (increases orchestrator complexity) | High (maintains thin orchestrator) |
| **Defense-in-Depth** | Single layer (orchestrator only) | Single layer (subagent only) |
| **Audit Trail** | Orchestrator logs recovery actions | Subagent logs validation results |
| **Error Messages** | Orchestrator generates errors | Subagent generates errors |
| **Debugging** | Check orchestrator logs | Check subagent return stage_log |
| **Estimated Effort** | 8.5 hours (Task 283 plan) | 10-12 hours (more subagent specs to update) |

**Analysis**:

**Task 283 Strengths**:
- Simpler for subagents (less responsibility)
- Guaranteed recovery (orchestrator always fixes)
- Centralized validation logic
- Faster to implement (fewer files to update)

**Task 283 Weaknesses**:
- Violates workflow ownership principle
- Increases orchestrator complexity
- Reactive (fixes after failure)
- May conflict with Task 240

**Task 286 Strengths**:
- Maintains workflow ownership in subagents
- Proactive (detects during execution)
- Aligns with Task 240 (thin orchestrator)
- Better error context (subagent knows what failed)

**Task 286 Weaknesses**:
- More complex for subagents
- Requires updating all subagent specs
- Longer implementation time
- Relies on Claude following validation steps

### Finding 5: Hybrid Approach - Defense-in-Depth

**Insight**: We don't have to choose one approach exclusively. A **hybrid approach** combines the strengths of both:

1. **Primary**: Subagent self-validation (proactive, during execution)
2. **Safety Net**: Orchestrator validation (reactive, after return)

**Design**:

**Subagent Responsibility** (Primary):
- Execute preflight status update
- Validate status update succeeded (read TODO.md and state.json)
- Retry if validation fails (max 2 retries)
- Log validation result in stage_log
- Include validation_summary in return JSON

**Orchestrator Responsibility** (Safety Net):
- Validate subagent return format (existing)
- Check stage_log for validation failures (new)
- If subagent reports validation failure: Log warning
- If subagent reports validation success: Trust but verify (lightweight check)
- If orchestrator detects mismatch: Log error and invoke recovery (rare case)

**Benefits**:
- **Defense-in-Depth**: Two layers of validation
- **Proactive + Reactive**: Subagent catches most failures, orchestrator catches edge cases
- **Workflow Ownership**: Subagent owns workflow, orchestrator provides safety net
- **Graceful Degradation**: If subagent validation fails, orchestrator recovers
- **Audit Trail**: Both subagent and orchestrator log validation results

**Implementation**:

**Phase 1**: Strengthen subagent self-validation (Task 286 approach)
- Update researcher.md, planner.md, implementer.md with validation steps
- Add stage_log with validation results
- Add validation_summary to return JSON
- Estimated: 10-12 hours

**Phase 2**: Add orchestrator safety net (Task 283 approach, simplified)
- Extend orchestrator Stage 4 to check stage_log
- Add lightweight validation (trust subagent, verify edge cases)
- Add recovery mechanism for rare failures
- Estimated: 4-5 hours

**Total Effort**: 14-17 hours (vs. 8.5 hours for Task 283 alone)

**Trade-off**: Higher implementation cost, but better long-term architecture.

## Detailed Analysis

### Analysis 1: Current Architecture - Who Owns What?

**Current Responsibility Distribution**:

| Responsibility | Orchestrator | Command | Subagent | status-sync-manager |
|----------------|--------------|---------|----------|---------------------|
| Parse arguments | Stage 1 | - | - | - |
| Validate task exists | - | - | Stage 1 (Preflight) | - |
| Update status (preflight) | - | - | Stage 1 (Preflight) | Invoked by subagent |
| Execute core work | - | - | Stages 2-3 | - |
| Create artifacts | - | - | Stage 3 | - |
| Validate artifacts | - | - | Stage 4 | - |
| Update status (postflight) | - | - | Stage 5 (Postflight) | Invoked by subagent |
| Create git commit | - | - | Stage 5 (Postflight) | - |
| Format return | - | - | Stage 6 (Return) | - |
| Validate return format | Stage 4 | - | - | - |
| Relay result to user | Stage 5 | - | - | - |

**Observation**: The current architecture ALREADY assigns preflight and postflight work to subagents. Commands are thin routers (frontmatter delegation). Orchestrator is a smart coordinator (argument parsing, routing, return validation).

**Conclusion**: The system design is ALREADY subagent-centric. Task 283 proposes moving validation responsibility to orchestrator, which would be a departure from current architecture.

### Analysis 2: Why Do Status Updates Fail?

**Task 283 Root Cause Analysis**:
> The problem is architectural - the system relies on Claude reading and following multi-stage workflow specifications in subagent markdown files, but there is no validation layer to ensure each stage is actually executed.

**Deeper Analysis**:

The root cause is NOT that subagents don't own preflight/postflight work. They DO own it (specifications are clear). The root cause is that **Claude may skip stages or combine them based on its interpretation**.

**Why does Claude skip stages?**

1. **Cognitive Load**: 6-stage workflows are complex, Claude may simplify
2. **Perceived Redundancy**: Claude may think "status update not critical, skip it"
3. **Optimization**: Claude may combine stages for efficiency
4. **Misinterpretation**: Claude may misunderstand stage boundaries
5. **Context Window Pressure**: Long specifications may cause Claude to skim

**Implication**: The problem is NOT architectural ownership, but **specification clarity and enforcement**.

**Two Solutions**:

1. **Task 283**: Add orchestrator validation to catch skipped stages (reactive)
2. **Task 286**: Strengthen subagent specifications with explicit validation (proactive)

Both solve the problem, but via different mechanisms.

### Analysis 3: Orchestrator-Centric Approach - Detailed Design

**Task 283 Detailed Design** (from implementation plan):

**Phase 1**: Extend subagent return format with stage_log
- Add optional stage_log field to subagent-return-format.md
- Document expected stage names for each subagent type
- Backward compatible (optional field)

**Phase 2**: Extend orchestrator Stage 4 validation
- After validating return JSON and artifacts, add status verification:
  - Read TODO.md and extract current status
  - Read state.json and extract current status
  - Compare with expected status based on subagent return
  - If mismatch: Log warning
- Validate stage_log (if present):
  - Verify all required stages executed
  - Check for skipped stages
  - Log warnings for missing stages

**Phase 3**: Add automatic recovery mechanism
- If status mismatch detected:
  - Invoke status-sync-manager from orchestrator
  - Pass subagent return data
  - Update TODO.md and state.json
  - Log recovery action

**Phase 4**: Update subagent specifications
- Add stage_log to return specification
- Document expected stage names
- Mark as recommended (not required)

**Phase 5**: Create status update compliance test
- Automated test to verify status updates work correctly

**Phase 6**: Documentation and manual testing

**Total**: 6 phases, 8.5 hours

**Evaluation**:

**Pros**:
- Clear, well-defined phases
- Backward compatible
- Guaranteed recovery
- Centralized validation logic
- Relatively quick to implement

**Cons**:
- Orchestrator becomes more complex (violates Task 240 goal of thin orchestrator)
- Reactive approach (fixes after failure)
- Duplicates status update logic (subagent invokes, orchestrator invokes)
- May create confusion about who owns status updates
- Increases orchestrator context window (more logic, more files to read)

### Analysis 4: Subagent-Centric Approach - Detailed Design

**Alternative Design** (Task 286):

**Phase 1**: Strengthen subagent preflight validation
- Update researcher.md Stage 1 (Preflight):
  - After invoking status-sync-manager, add validation step
  - Read TODO.md and verify status marker changed
  - Read state.json and verify status field changed
  - If validation fails: Retry (max 2 retries)
  - If retry fails: Abort with clear error
- Update planner.md and implementer.md similarly

**Phase 2**: Strengthen subagent postflight validation
- Update researcher.md Stage 5 (Postflight):
  - After invoking status-sync-manager, add validation step
  - Read TODO.md and verify status marker changed
  - Read state.json and verify status field changed
  - Verify artifact linked in TODO.md
  - If validation fails: Retry (max 2 retries)
  - If retry fails: Log warning but continue (artifact exists)
- Update planner.md and implementer.md similarly

**Phase 3**: Add stage execution logging
- Update researcher.md Stage 6 (Return):
  - Add stage_log field with validation results
  - Add validation_summary field
  - Document validation outcomes
- Update planner.md and implementer.md similarly

**Phase 4**: Update subagent-return-format.md
- Add stage_log field definition (optional)
- Add validation_summary field definition (optional)
- Document expected format

**Phase 5**: Create validation helper functions
- Create bash functions for common validation tasks:
  - verify_todo_status(task_number, expected_status)
  - verify_state_json_status(task_number, expected_status)
  - verify_artifact_linked(task_number, artifact_path)
- Include in subagent specifications

**Phase 6**: Create status update compliance test
- Automated test to verify status updates work correctly
- Test subagent self-validation

**Phase 7**: Documentation and manual testing

**Total**: 7 phases, 10-12 hours

**Evaluation**:

**Pros**:
- Maintains workflow ownership in subagents
- Proactive validation (during execution)
- Aligns with Task 240 (thin orchestrator)
- Better error context (subagent knows what failed)
- Self-healing (subagent retries)
- No orchestrator complexity increase

**Cons**:
- More complex for subagents
- Requires updating all subagent specs (researcher, planner, implementer)
- Longer implementation time
- Relies on Claude following validation steps (same problem as original)
- No safety net if subagent validation fails

### Analysis 5: Hybrid Approach - Best of Both Worlds

**Hybrid Design**:

**Tier 1 - Subagent Self-Validation** (Primary):
- Subagents validate their own status updates during execution
- Retry on failure (max 2 retries)
- Log validation results in stage_log
- Include validation_summary in return JSON

**Tier 2 - Orchestrator Safety Net** (Secondary):
- Orchestrator checks stage_log for validation failures
- If subagent reports success: Trust but verify (lightweight check)
- If subagent reports failure: Log warning
- If orchestrator detects mismatch: Invoke recovery (rare)

**Implementation**:

**Phase 1-7**: Implement Task 286 (subagent self-validation)
- 10-12 hours

**Phase 8**: Add orchestrator safety net
- Extend orchestrator Stage 4:
  - Check stage_log.validation_summary
  - If validation_summary.preflight_status_update != "success": Log warning
  - If validation_summary.postflight_status_update != "success": Log warning
  - Lightweight verification: Read TODO.md status (quick check)
  - If mismatch detected: Invoke recovery
- 2-3 hours

**Phase 9**: Add recovery mechanism
- If orchestrator detects mismatch:
  - Invoke status-sync-manager
  - Log recovery action
  - Include in orchestrator return
- 2 hours

**Total**: 9 phases, 14-17 hours

**Evaluation**:

**Pros**:
- **Defense-in-Depth**: Two layers of validation
- **Proactive + Reactive**: Best of both approaches
- **Workflow Ownership**: Subagent owns workflow, orchestrator provides safety net
- **Graceful Degradation**: If subagent fails, orchestrator recovers
- **Audit Trail**: Both layers log validation results
- **Future-Proof**: Aligns with Task 240 while adding safety

**Cons**:
- Highest implementation cost (14-17 hours)
- Most complex (two validation layers)
- Potential for confusion (who validates what?)

**Mitigation**:
- Clear documentation of responsibility boundaries
- Subagent validation is PRIMARY, orchestrator is SAFETY NET
- Orchestrator only acts if subagent validation fails

## Code Examples

### Example 1: Subagent Self-Validation (Task 286 Approach)

**researcher.md Stage 1 (Preflight) with Self-Validation**:

```xml
<stage_1_preflight>
  <action>Preflight: Parse arguments, validate task, update status to [RESEARCHING]</action>
  <process>
    1-7. [existing steps - parse task_number, validate task, extract language, etc.]
    
    8. Invoke status-sync-manager to mark [RESEARCHING]:
       a. Prepare delegation context:
          - task_number: {number}
          - new_status: "researching"
          - timestamp: {date}
          - session_id: {session_id}
          - delegation_depth: {depth + 1}
          - delegation_path: [...delegation_path, "status-sync-manager"]
       b. Invoke status-sync-manager with timeout (60s)
       c. Validate return status == "completed"
       d. Verify files_updated includes ["TODO.md", "state.json"]
       e. If status update fails: Abort with error and recommendation
    
    9. VALIDATE status update succeeded (CRITICAL - DO NOT SKIP):
       a. Read TODO.md and extract current status for task_number:
          ```bash
          CURRENT_STATUS=$(grep -A 20 "^### ${task_number}\." specs/TODO.md | grep -oP '\[.*?\]' | head -1)
          ```
       b. Verify CURRENT_STATUS == "[RESEARCHING]"
       c. Read state.json and extract current status for task_number:
          ```bash
          STATE_STATUS=$(jq -r ".active_projects[] | select(.project_number == ${task_number}) | .status" specs/state.json)
          ```
       d. Verify STATE_STATUS == "researching"
       e. If validation FAILS:
          - Log error: "Preflight status update validation failed"
          - RETRY status update (max 2 retries)
          - If retry fails: ABORT with error:
            * type: "status_update_validation_failed"
            * message: "Failed to update status to [RESEARCHING] after 2 retries"
            * recommendation: "Check status-sync-manager logs and TODO.md/state.json manually"
       f. If validation SUCCEEDS:
          - Log success: "Preflight status update validated successfully"
          - Record in stage_log: {"stage": 1, "validated": true}
    
    10. Log preflight completion
  </process>
  <validation>
    CRITICAL: You MUST verify status update succeeded before proceeding to Stage 2.
    Do NOT proceed if validation fails. Return failed status with clear error message.
  </validation>
  <output>Task validated, status updated to [RESEARCHING], validation confirmed</output>
</stage_1_preflight>
```

**researcher.md Stage 6 (Return) with Validation Summary**:

```xml
<stage_6_return>
  <action>Return: Format and return standardized result with validation summary</action>
  <process>
    1. Format return following subagent-return-format.md:
       - status: "completed" (or "failed" if errors)
       - summary: "Research completed on {topic}. Found {N} key insights."
       - artifacts: [{type: "research", path, summary}]
       - metadata: {session_id, duration_seconds, agent_type, delegation_depth, delegation_path}
       - errors: [] (or error details if failures)
       - next_steps: "Review research findings and create implementation plan"
    
    2. Add stage_log with validation results:
       - stage_log: [
           {"stage": 1, "name": "Preflight", "executed": true, "validated": true, "duration_seconds": 15},
           {"stage": 2, "name": "Research", "executed": true, "validated": true, "duration_seconds": 120},
           {"stage": 3, "name": "Artifact Creation", "executed": true, "validated": true, "duration_seconds": 30},
           {"stage": 4, "name": "Validation", "executed": true, "validated": true, "duration_seconds": 5},
           {"stage": 5, "name": "Postflight", "executed": true, "validated": true, "duration_seconds": 20},
           {"stage": 6, "name": "Return", "executed": true, "validated": true, "duration_seconds": 2}
         ]
    
    3. Add validation_summary:
       - validation_summary: {
           "preflight_status_update": "success",
           "postflight_status_update": "success",
           "artifact_validation": "success",
           "git_commit": "success"
         }
    
    4. Return standardized result
  </process>
  <validation>
    Final validation before returning:
    - Return format matches subagent-return-format.md
    - stage_log includes all 6 stages
    - validation_summary includes all validation results
  </validation>
  <output>Standardized return with validation summary</output>
</stage_6_return>
```

### Example 2: Orchestrator Safety Net (Hybrid Approach)

**orchestrator.md Stage 4 (ValidateReturn) with Safety Net**:

```xml
<stage id="4" name="ValidateReturn">
  <action>Validate subagent return format, artifacts, and status updates</action>
  <process>
    1. Parse return as JSON
    2. Validate required fields (status, summary, artifacts, metadata)
    3. Verify artifacts exist on disk and are non-empty
    4. Check session_id matches expected value
    
    5. NEW: Check subagent validation results (SAFETY NET):
       a. If return includes validation_summary:
          - Check validation_summary.preflight_status_update
          - Check validation_summary.postflight_status_update
          - If either != "success": Log warning
       
       b. Lightweight verification (trust but verify):
          - Read TODO.md and extract current status for task_number
          - Map subagent return status to expected TODO.md marker:
            * "completed" → "[COMPLETED]"
            * "researched" → "[RESEARCHED]"
            * "planned" → "[PLANNED]"
          - If mismatch detected:
            * Log error: "Status mismatch detected by orchestrator safety net"
            * Invoke recovery mechanism (Step 6)
       
       c. If validation_summary reports success AND lightweight verification passes:
          - Log success: "Status update validated (subagent + orchestrator)"
          - No recovery needed
    
    6. NEW: Recovery mechanism (RARE CASE):
       a. If status mismatch detected:
          - Invoke status-sync-manager from orchestrator
          - Pass subagent return data:
            * task_number: {from return.metadata}
            * new_status: {from return.status}
            * timestamp: {current date}
            * session_id: {from return.metadata}
            * validated_artifacts: {from return.artifacts}
          - Validate status-sync-manager return
          - Log recovery action: "Orchestrator recovered missing status update"
       
       b. If recovery fails:
          - Log error: "Orchestrator recovery failed"
          - Include in orchestrator return errors array
          - Recommendation: "Manually update TODO.md and state.json"
    
    7. Return validation result
  </process>
  <validation>
    - Return is valid JSON
    - Required fields present
    - Artifacts exist and non-empty
    - Session ID matches
    - Status update validated (subagent or orchestrator)
  </validation>
  <output>Validation result with recovery actions (if any)</output>
</stage>
```

### Example 3: Validation Helper Functions

**Bash Helper Functions for Subagent Validation**:

```bash
# Helper function: Verify TODO.md status marker
verify_todo_status() {
  local task_number=$1
  local expected_status=$2
  
  # Extract current status marker from TODO.md
  local current_status=$(grep -A 20 "^### ${task_number}\." specs/TODO.md | grep -oP '\[.*?\]' | head -1)
  
  # Compare with expected
  if [ "$current_status" == "$expected_status" ]; then
    echo "SUCCESS: TODO.md status is $expected_status"
    return 0
  else
    echo "FAILURE: TODO.md status is $current_status, expected $expected_status"
    return 1
  fi
}

# Helper function: Verify state.json status field
verify_state_json_status() {
  local task_number=$1
  local expected_status=$2
  
  # Extract current status from state.json
  local current_status=$(jq -r ".active_projects[] | select(.project_number == ${task_number}) | .status" specs/state.json)
  
  # Compare with expected
  if [ "$current_status" == "$expected_status" ]; then
    echo "SUCCESS: state.json status is $expected_status"
    return 0
  else
    echo "FAILURE: state.json status is $current_status, expected $expected_status"
    return 1
  fi
}

# Helper function: Verify artifact linked in TODO.md
verify_artifact_linked() {
  local task_number=$1
  local artifact_path=$2
  
  # Check if artifact path appears in task entry
  if grep -A 50 "^### ${task_number}\." specs/TODO.md | grep -q "$artifact_path"; then
    echo "SUCCESS: Artifact $artifact_path linked in TODO.md"
    return 0
  else
    echo "FAILURE: Artifact $artifact_path NOT linked in TODO.md"
    return 1
  fi
}

# Usage in subagent Stage 1 (Preflight):
# After invoking status-sync-manager:
if verify_todo_status $task_number "[RESEARCHING]" && verify_state_json_status $task_number "researching"; then
  echo "Preflight status update validated successfully"
else
  echo "Preflight status update validation failed, retrying..."
  # Retry logic here
fi
```

## Decisions

### Decision 1: Current Architecture is Already Subagent-Centric

**Decision**: The current architecture ALREADY implements subagent-owned preflight and postflight work. Task 275 successfully added comprehensive status update instructions to all subagent specifications.

**Rationale**:
- Researcher.md, planner.md, implementer.md all have Stage 1 (Preflight) and Stage 5 (Postflight) specifications
- These stages include explicit instructions to invoke status-sync-manager
- Commands are thin routers (frontmatter delegation)
- Orchestrator is a smart coordinator (argument parsing, routing, return validation)

**Implication**: The problem is NOT architectural ownership, but enforcement and validation.

### Decision 2: Both Approaches Solve the Same Problem

**Decision**: Task 283 (orchestrator-centric) and Task 286 (subagent-centric) both solve the status synchronization failure problem, but via different mechanisms.

**Rationale**:
- Task 283: Orchestrator validates and recovers after subagent returns (reactive)
- Task 286: Subagent validates and self-heals during execution (proactive)
- Both add validation layer to ensure status updates occur
- Both include recovery mechanisms

**Implication**: The choice is not "which solves the problem" but "which approach better aligns with system principles and long-term goals".

### Decision 3: Hybrid Approach Provides Defense-in-Depth

**Decision**: A hybrid approach combining subagent self-validation (primary) with orchestrator safety net (secondary) provides the best long-term solution.

**Rationale**:
- Subagent self-validation is proactive (catches failures during execution)
- Orchestrator safety net is reactive (catches edge cases after return)
- Defense-in-depth provides redundancy
- Maintains workflow ownership in subagents
- Aligns with Task 240 goal of thin orchestrator (orchestrator only acts if subagent fails)

**Implication**: Higher implementation cost (14-17 hours) but better architecture.

## Recommendations

### Recommendation 1: Implement Hybrid Approach (High Priority)

**Action**: Combine subagent self-validation (Task 286) with orchestrator safety net (simplified Task 283).

**Implementation**:

**Phase 1-7**: Implement subagent self-validation (10-12 hours)
1. Update researcher.md with preflight and postflight validation steps
2. Update planner.md with preflight and postflight validation steps
3. Update implementer.md with preflight and postflight validation steps
4. Add stage_log and validation_summary to return format
5. Create validation helper functions
6. Update subagent-return-format.md
7. Create status update compliance test

**Phase 8-9**: Add orchestrator safety net (4-5 hours)
8. Extend orchestrator Stage 4 to check validation_summary
9. Add lightweight verification and recovery mechanism

**Total Effort**: 14-17 hours

**Benefits**:
- Defense-in-depth (two validation layers)
- Proactive + reactive (best of both approaches)
- Maintains workflow ownership in subagents
- Aligns with Task 240 (thin orchestrator)
- Graceful degradation (orchestrator recovers if subagent fails)

**Risks**:
- Higher implementation cost
- Complexity (two validation layers)
- Potential for confusion about responsibilities

**Mitigation**:
- Clear documentation of responsibility boundaries
- Subagent validation is PRIMARY, orchestrator is SAFETY NET
- Orchestrator only acts if subagent validation fails

### Recommendation 2: Start with Subagent Self-Validation, Add Safety Net Later (Medium Priority)

**Action**: Implement Task 286 (subagent self-validation) first, then add orchestrator safety net as Phase 2.

**Implementation**:

**Phase 1**: Implement subagent self-validation (10-12 hours)
- Update all subagent specifications with validation steps
- Add stage_log and validation_summary
- Create validation helper functions
- Test and validate

**Phase 2**: Add orchestrator safety net (4-5 hours)
- Extend orchestrator Stage 4
- Add lightweight verification
- Add recovery mechanism
- Test and validate

**Benefits**:
- Incremental implementation (lower risk)
- Can validate Phase 1 before adding Phase 2
- Flexibility to stop after Phase 1 if sufficient

**Risks**:
- Phase 1 alone may not be sufficient (no safety net)
- Two-phase implementation may take longer overall

### Recommendation 3: Implement Task 283 Only (Low Priority, Not Recommended)

**Action**: Implement Task 283 (orchestrator-centric validation) without subagent changes.

**Rationale**: This is the quickest solution (8.5 hours) and provides guaranteed recovery.

**Why Not Recommended**:
- Violates workflow ownership principle
- Increases orchestrator complexity
- May conflict with Task 240 OpenAgents migration
- Reactive approach (fixes after failure)
- Does not strengthen subagent specifications

**When to Consider**: If time is critical and Task 240 is not a priority.

### Recommendation 4: Create Validation Standard (High Priority, Parallel Work)

**Action**: Create a validation standard document that defines validation patterns for all subagents.

**Implementation**:

1. Create `.opencode/context/core/standards/subagent-validation.md`:
   - Define validation patterns (preflight, postflight, artifact)
   - Document validation helper functions
   - Provide examples for each subagent type
   - Define validation_summary format
   - Document retry logic and error handling

2. Reference from all subagent specifications:
   - Add to context_loading.required
   - Include validation standard in all subagent specs

**Estimated Effort**: 2-3 hours

**Benefits**:
- Standardizes validation across all subagents
- Reduces duplication in subagent specifications
- Provides clear guidance for future subagents
- Easier to maintain (single source of truth)

**Timing**: Can be done in parallel with Recommendation 1 or 2.

## Risks & Mitigations

### Risk 1: Subagent Validation May Still Be Skipped

**Risk**: Even with explicit validation steps in subagent specifications, Claude may still skip them.

**Likelihood**: Medium  
**Impact**: High  
**Mitigation**:
- Add CRITICAL markers to validation steps
- Use explicit checkpoints (DO NOT SKIP)
- Add orchestrator safety net (hybrid approach)
- Create validation helper functions (reduce complexity)
- Test thoroughly with compliance test

### Risk 2: Higher Implementation Cost

**Risk**: Hybrid approach costs 14-17 hours vs. 8.5 hours for Task 283 alone.

**Likelihood**: High  
**Impact**: Medium  
**Mitigation**:
- Incremental implementation (Phase 1 first, Phase 2 later)
- Reuse validation logic across subagents
- Create validation standard to reduce duplication
- Consider long-term benefits (better architecture)

### Risk 3: Complexity and Confusion

**Risk**: Two validation layers may create confusion about who validates what.

**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**:
- Clear documentation of responsibility boundaries
- Subagent validation is PRIMARY, orchestrator is SAFETY NET
- Orchestrator only acts if subagent validation fails
- Create decision tree for debugging

### Risk 4: Conflict with Task 240

**Risk**: Task 283 (orchestrator-centric) may conflict with Task 240's goal of thin orchestrator.

**Likelihood**: Medium (for Task 283 alone)  
**Impact**: High  
**Mitigation**:
- Implement hybrid approach (subagent-centric primary, orchestrator safety net)
- Align with Task 240 principles (workflow ownership in subagents)
- Keep orchestrator safety net lightweight (trust but verify)

### Risk 5: Backward Compatibility

**Risk**: Changes to subagent specifications may break existing workflows.

**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**:
- Make validation_summary optional in return format
- Maintain backward compatibility with old return format
- Test thoroughly with existing tasks
- Incremental rollout (one subagent at a time)

## Appendix: Sources and Citations

### Primary Sources

1. **Task 283 Research and Plan**:
   - specs/283_fix_systematic_status_synchronization_failure/reports/research-001.md
   - specs/283_fix_systematic_status_synchronization_failure/plans/implementation-001.md

2. **Orchestrator Specification**:
   - .opencode/agent/orchestrator.md (Stage 1-5 workflow, validation rules)

3. **Subagent Specifications**:
   - .opencode/agent/subagents/researcher.md (Stage 1 and Stage 5 status updates)
   - .opencode/agent/subagents/planner.md (Stage 0 and Stage 7 status updates)
   - .opencode/agent/subagents/implementer.md (Stage 0 and Stage 7 status updates)

4. **Status Sync Manager**:
   - .opencode/agent/subagents/status-sync-manager.md (Two-phase commit protocol)

5. **Standards**:
   - .opencode/context/core/standards/subagent-return-format.md
   - .opencode/context/core/system/state-management.md

### Secondary Sources

1. **Task 275 Artifacts** (Previous fix attempt):
   - specs/275_fix_workflow_status_updates/reports/research-001.md
   - specs/275_fix_workflow_status_updates/plans/implementation-001.md
   - specs/275_fix_workflow_status_updates/summaries/implementation-summary-20260103.md

2. **Task 240 Research** (OpenAgents Migration):
   - specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/reports/research-001.md

### Evidence

1. **Current Architecture**:
   - Researcher.md lines 140-205: Preflight and postflight status update specifications
   - Planner.md lines 96-157: Preflight and postflight status update specifications
   - Implementer.md lines 100-157: Preflight and postflight status update specifications

2. **Task 283 Approach**:
   - Implementation plan Phase 1-6: Orchestrator-centric validation and recovery
   - Estimated effort: 8.5 hours

3. **Subagent Ownership**:
   - All subagents have 6-stage workflow specifications
   - Commands are thin routers (frontmatter delegation)
   - Orchestrator is smart coordinator (argument parsing, routing, validation)

---

**End of Research Report**
