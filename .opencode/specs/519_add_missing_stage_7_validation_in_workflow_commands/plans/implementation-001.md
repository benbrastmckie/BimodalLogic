# Implementation Plan: Add Missing Stage 7 Validation in Workflow Commands

- **Task**: 519 - Add missing Stage 7 validation in workflow commands  
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Priority**: High
- **Dependencies**: []
- **Research Inputs**: Analysis of workflow command Stage 7 implementations revealing missing validation checkpoints
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - .opencode/agent/subagents/meta/workflow-designer.md (updated)
  - .opencode/agent/subagents/meta/domain-analyzer.md (updated)
  - .opencode/agent/subagents/meta/agent-generator.md (updated)
  - .opencode/agent/subagents/meta/command-creator.md (updated)
  - .opencode/agent/subagents/meta/context-organizer.md (updated)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/workflows/command-lifecycle.md
  - .opencode/context/core/standards/validation-checkpoints.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add missing Stage 7 (Postflight) validation checkpoints in all workflow commands. Research revealed that workflow commands skip critical validation steps before returning, leading to undetected failures and inconsistent state.

## Goals & Non-Goals

**Goals**:
- Implement complete Stage 7 validation in all 6 workflow commands
- Add artifact validation before status updates
- Add post-commit validation to verify files were written correctly
- Ensure all failures return proper error status with details
- Standardize validation patterns across all workflow commands

**Non-Goals**:
- Adding validation to non-workflow commands (out of scope)
- Changing the core workflow structure (only adding missing validation)
- Implementing new validation types (using existing patterns)

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Validation too strict, blocking valid operations | Use warnings for non-critical issues, only fail on critical problems |
| Performance impact from validation | Keep validation lightweight and focused |
| Inconsistent validation across commands | Create validation template/checklist for all to follow |

## Implementation Phases

### Phase 1: Create Validation Template [NOT STARTED]
- **Goal**: Define standard Stage 7 validation pattern for all workflow commands
- **Tasks**:
  - [ ] Analyze existing validation in status-sync-manager as reference
  - [ ] Create validation template with:
    * Pre-delegation validation (artifacts exist, parameters valid)
    * Post-delegation validation (status updated, artifacts linked)
    * Error handling patterns (what to do if validation fails)
  - [ ] Define validation levels: CRITICAL (must fail), WARNING (log but continue)
  - [ ] Document validation in .opencode/context/core/standards/validation-checkpoints.md
- **Timing**: 45 minutes

### Phase 2: Fix workflow-designer Stage 7 Validation [NOT STARTED]
- **Goal**: Add complete validation to workflow-designer Stage 7
- **Tasks**:
  - [ ] Add artifact validation before status-sync-manager delegation:
    * Verify all workflow files exist and are non-empty
    * Verify workflow selection guide exists
    * If validation fails: return failed status (don't delegate)
  - [ ] Add post-commit validation after git-workflow-manager:
    * Verify git commit was successful
    * Verify commit hash is returned
    * If validation fails: return warning but success (commit already made)
  - [ ] Add validation checkpoints with [PASS]/[FAIL]/[WARN] markers
  - [ ] Update Stage 7 process_flow to include validation steps
- **Timing**: 30 minutes

### Phase 3: Fix domain-analyzer Stage 7 Validation [NOT STARTED]
- **Goal**: Add complete validation to domain-analyzer Stage 7
- **Tasks**:
  - [ ] Add artifact validation before status-sync-manager delegation:
    * Verify research report exists and is non-empty
    * Verify domain mapping file exists (if created)
    * If validation fails: return failed status
  - [ ] Add post-commit validation after git-workflow-manager:
    * Verify git commit successful
    * Verify artifacts tracked in commit
  - [ ] Add validation checkpoints with text-based markers
  - [ ] Update Stage 7 process_flow with validation steps
- **Timing**: 30 minutes

### Phase 4: Fix agent-generator Stage 7 Validation [NOT STARTED]
- **Goal**: Add complete validation to agent-generator Stage 7
- **Tasks**:
  - [ ] Add artifact validation before status-sync-manager delegation:
    * Verify all agent files created and are 200-300 lines
    * Verify agent files have valid YAML frontmatter
    * Verify delegation paths are correct
    * If validation fails: return failed status
  - [ ] Add post-commit validation:
    * Verify git commit successful
    * Verify agent files in commit
  - [ ] Add validation checkpoints
  - [ ] Update Stage 7 process_flow
- **Timing**: 30 minutes

### Phase 5: Fix command-creator Stage 7 Validation [NOT STARTED]
- **Goal**: Add complete validation to command-creator Stage 7
- **Tasks**:
  - [ ] Add artifact validation before status-sync-manager delegation:
    * Verify all command files created and are <300 lines
    * Verify command files have valid YAML frontmatter
    * Verify routing to correct agents
    * If validation fails: return failed status
  - [ ] Add post-commit validation:
    * Verify git commit successful
    * Verify command files in commit
  - [ ] Add validation checkpoints
  - [ ] Update Stage 7 process_flow
- **Timing**: 30 minutes

### Phase 6: Fix context-organizer Stage 7 Validation [NOT STARTED]
- **Goal**: Add complete validation to context-organizer Stage 7
- **Tasks**:
  - [ ] Add artifact validation before status-sync-manager delegation:
    * Verify all context files created and follow 80/20 distribution
    * Verify context index updated
    * Verify file sizes within limits
    * If validation fails: return failed status
  - [ ] Add post-commit validation:
    * Verify git commit successful
    * Verify context files in commit
  - [ ] Add validation checkpoints
  - [ ] Update Stage 7 process_flow
- **Timing**: 30 minutes

### Phase 7: Test All Workflow Commands [NOT STARTED]
- **Goal**: Verify validation works correctly in all workflow commands
- **Tasks**:
  - [ ] Test workflow-designer with missing artifacts (should fail)
  - [ ] Test workflow-designer with valid artifacts (should succeed)
  - [ ] Test domain-analyzer validation
  - [ ] Test agent-generator validation
  - [ ] Test command-creator validation
  - [ ] Test context-organizer validation
  - [ ] Verify error messages are clear and actionable
- **Timing**: 45 minutes

## Testing & Validation

- [ ] All workflow commands validate artifacts before delegation
- [ ] All workflow commands return failed status if artifact validation fails
- [ ] All workflow commands perform post-commit validation
- [ ] Validation failures include specific error details
- [ ] Valid artifacts pass validation and proceed normally
- [ ] Error messages help users fix validation issues

## Artifacts & Outputs

- Updated workflow-designer.md with complete Stage 7 validation
- Updated domain-analyzer.md with complete Stage 7 validation
- Updated agent-generator.md with complete Stage 7 validation
- Updated command-creator.md with complete Stage 7 validation
- Updated context-organizer.md with complete Stage 7 validation
- validation-checkpoints.md with standard validation template

## Rollback/Contingency

If validation breaks existing workflows:
- Make validation non-blocking initially (warnings only)
- Gradually upgrade warnings to failures after testing
- Provide flag to bypass validation for emergency fixes
- Document which validations are critical vs cosmetic