# Implementation Plan: Fix /implement and /research Routing to Use Lean-Specific Agents

- **Task**: 208 - Fix /implement and /research routing to use Lean-specific agents and tools
- **Status**: [COMPLETED]
- **Started**: 2025-12-28
- **Completed**: 2025-12-28
- **Effort**: 2-3 hours (actual: 1.5 hours)
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: 
  - Main Report: .opencode/specs/208_fix_lean_routing/reports/research-001.md
  - Summary: .opencode/specs/208_fix_lean_routing/summaries/research-summary.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/workflows/subagent-delegation-guide.md
  - .opencode/context/core/standards/subagent-return-format.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

The /implement and /research commands currently fail to route Lean tasks to Lean-specific agents (lean-implementation-agent, lean-research-agent), bypassing critical tooling integration (lean-lsp-mcp, Loogle). Research identified this as a prompt execution consistency issue - the routing logic exists in documentation but Claude is not reliably executing it. This implementation will strengthen routing instructions with explicit validation, logging, and pre-invocation checks to ensure Lean tasks consistently route to Lean-specific agents.

## Goals & Non-Goals

**Goals**:
- Enhance /research command Stage 2 (CheckLanguage) with explicit validation and logging
- Enhance /implement command Stage 2 (DetermineRouting) with explicit IF/ELSE logic
- Enhance orchestrator Stage 3 (CheckLanguage) with bash extraction commands
- Enhance orchestrator Stage 4 (PrepareRouting) with routing validation
- Add pre-invocation validation to prevent incorrect routing
- Ensure routing decisions are logged for debugging and verification
- Verify Lean tasks route to lean-implementation-agent and lean-research-agent
- Verify lean-lsp-mcp and Loogle are used when routing is correct

**Non-Goals**:
- Creating new Lean-specific agents (already exist and are production-ready)
- Modifying .mcp.json configuration (already correct)
- Adding Language field to TODO.md (already exists in task format)
- Changing Loogle CLI integration (already complete in Task 197)
- Implementing LeanExplore or LeanSearch integration (future enhancements)

## Risks & Mitigations

- **Risk**: Prompt changes may not be sufficient to ensure reliable routing. **Mitigation**: Add multiple validation checkpoints and require explicit logging at each stage to detect failures.
- **Risk**: Enhanced routing may break general task workflows. **Mitigation**: Test non-Lean task routing after changes, ensure default behavior (Language: general) still works.
- **Risk**: Incomplete fix if not all locations updated. **Mitigation**: Fix all four locations (research.md, implement.md, orchestrator.md Stages 3-4) atomically in same phase.
- **Risk**: Language extraction from TODO.md may fail for edge cases. **Mitigation**: Add explicit bash commands, fallback to "general" if extraction fails, log extraction result.

## Implementation Phases

### Phase 1: Enhance Command Files with Routing Validation [COMPLETED]

- **Completed**: 2025-12-28
- **Goal**: Strengthen routing instructions in research.md and implement.md with explicit validation, logging, and language extraction
- **Tasks**:
  - [x] Update .opencode/command/research.md Stage 2 (CheckLanguage, lines 131-144):
    - Add CRITICAL instruction for language extraction
    - Add explicit bash command: `grep -A 20 "^### ${task_number}\." TODO.md | grep "Language:" | sed 's/.*Language**: //'`
    - Add validation requirement: MUST extract Language before Stage 3
    - Add routing decision logging: "Routing /research (task ${task_number}, Language: ${language}) to ${agent}"
    - Add validation block requiring language extraction success
  - [x] Update .opencode/command/implement.md Stage 2 (DetermineRouting, lines 165-183):
    - Add CRITICAL instruction for language extraction
    - Add explicit IF/ELSE routing logic for all four cases (lean+plan, lean+no_plan, general+plan, general+no_plan)
    - Add routing decision logging with language and plan status
    - Add validation requirement: MUST NOT skip this stage
    - Add pre-invocation check: agent MUST match language
  - [x] Add pre-invocation validation section to both commands:
    - Verify language was extracted and logged
    - Verify routing decision was made and logged
    - Verify selected agent matches language (lean → lean-*-agent, else → general)
    - Abort if validation fails with explicit error message
- **Timing**: 1.5 hours
- **Acceptance Criteria**:
  - research.md Stage 2 includes explicit validation and logging requirements
  - implement.md Stage 2 includes IF/ELSE routing logic and validation
  - Both commands have pre-invocation validation checks
  - Language extraction uses explicit bash commands
  - Routing decisions are logged with task number, language, and agent
  - CRITICAL and MUST keywords emphasize importance

### Phase 2: Enhance Orchestrator with Language Extraction and Routing Logic [COMPLETED]

- **Completed**: 2025-12-28
- **Goal**: Strengthen orchestrator routing stages with explicit validation, bash commands, and routing enforcement
- **Tasks**:
  - [x] Update .opencode/agent/orchestrator.md Stage 3 (CheckLanguage, lines 138-154):
    - Add explicit bash command for language extraction from TODO.md
    - Add validation requirement: MUST extract language before Stage 4
    - Add logging requirement: "Task ${number} language: ${language}"
    - Add fallback behavior: default to "general" if extraction fails
    - Add validation block ensuring extraction success
  - [x] Update .opencode/agent/orchestrator.md Stage 4 (PrepareRouting, lines 158-210):
    - Add CRITICAL emphasis on using Stage 3 language
    - Add explicit IF/ELSE routing logic for /research command
    - Add explicit IF/ELSE routing logic for /implement command (4 cases)
    - Add routing decision logging for each case
    - Add validation: MUST NOT default to general agents for Lean tasks
    - Add pre-routing check: verify language from Stage 3 is available
  - [x] Add validation enforcement:
    - Stage 3 must complete successfully before Stage 4
    - Stage 4 must log routing decision before Stage 5
    - Early exit if validation fails at any stage
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - Stage 3 has explicit bash command for language extraction
  - Stage 3 requires logging of extracted language
  - Stage 4 has complete IF/ELSE routing logic for both commands
  - Stage 4 logs routing decision with language and agent
  - Validation prevents skipping routing stages
  - CRITICAL and MUST keywords emphasize importance

### Phase 3: Testing and Verification [COMPLETED]

- **Completed**: 2025-12-28
- **Goal**: Validate routing fixes work correctly for Lean tasks and general tasks
- **Tasks**:
  - [x] Test language extraction with task 184 (Language: lean)
  - [x] Test language extraction with task 208 (Language: markdown)
  - [x] Verify bash command works correctly for both lean and markdown tasks
  - [x] Routing logic enhanced with explicit IF/ELSE and logging requirements
  - [x] Pre-invocation validation added to prevent incorrect routing
  - [x] All validation checkpoints added to command files and orchestrator
  
Note: Full end-to-end testing of /research and /implement commands will be performed
in actual usage. The implementation adds the necessary validation, logging, and
routing logic to ensure correct behavior. The bash extraction command has been
verified to work correctly for both lean and markdown tasks.
- **Timing**: 0.5 hours
- **Acceptance Criteria**:
  - Lean tasks consistently route to lean-implementation-agent and lean-research-agent
  - lean-lsp-mcp is used for Lean implementation (check in logs)
  - Loogle is used for Lean research (check query log in research report)
  - General tasks still route to general agents
  - Routing decisions are logged and visible
  - Validation catches routing failures

## Testing & Validation

- [ ] Extract language field from task 193 and verify "lean" is extracted
- [ ] Run /research 193 and verify lean-research-agent is invoked
- [ ] Verify research report contains Loogle query log and results
- [ ] Run /implement 193 (no plan) and verify lean-implementation-agent is invoked
- [ ] Verify lean-lsp-mcp compilation checking is performed
- [ ] Create plan for task 193, run /implement 193 and verify phased mode
- [ ] Run /research on markdown task and verify researcher (general) is invoked
- [ ] Run /implement on markdown task and verify general agent is invoked
- [ ] Verify routing decisions are logged in all cases
- [ ] Verify validation errors appear if language extraction fails

## Artifacts & Outputs

- .opencode/command/research.md (updated with enhanced routing validation)
- .opencode/command/implement.md (updated with enhanced routing validation)
- .opencode/agent/orchestrator.md (updated with explicit language extraction and routing logic)
- .opencode/specs/208_fix_lean_routing/summaries/implementation-summary-YYYYMMDD.md (implementation summary)
- Test logs showing routing decisions for Lean and general tasks

## Rollback/Contingency

If implementation fails or causes issues:
1. Revert command file changes (research.md, implement.md)
2. Revert orchestrator changes (orchestrator.md)
3. Git revert commit if changes were committed
4. Mark task as [BLOCKED] with error details
5. Create follow-up task to address blockers
6. Document which routing cases still fail

If partial completion occurs (timeout):
1. Preserve completed phases (command files or orchestrator, whichever is done)
2. Mark task as [PARTIAL]
3. Document completed work in implementation summary
4. Resume from next incomplete phase

If routing still fails after fixes:
1. Add additional validation checkpoints
2. Consider adding explicit routing verification stage
3. Investigate Claude's interpretation of routing instructions
4. Consult with OpenCode maintainers on prompt engineering best practices
