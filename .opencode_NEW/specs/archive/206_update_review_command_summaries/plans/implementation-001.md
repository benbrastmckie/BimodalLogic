# Implementation Plan: Update /review Command to Create Summary Artifacts

- **Task**: 206 - Update /review command to create summaries in new project directories
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: 
  - Main Report: .opencode/specs/206_update_review_command_summaries/reports/research-001.md
  - Summary: .opencode/specs/206_update_review_command_summaries/summaries/research-summary.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/subagent-return-format.md
  - .opencode/context/core/standards/summary.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

The /review command currently updates project registries and creates tasks but does not create persistent review summary artifacts. This implementation will add artifact management to /review by creating a reviewer subagent specification, implementing lazy project directory creation, generating review summary artifacts in summaries/ subdirectory, and standardizing return format per subagent-return-format.md. The work protects the orchestrator's context window by returning only brief summaries and artifact paths instead of verbose review findings.

## Goals & Non-Goals

**Goals**:
- Create reviewer.md subagent specification from scratch
- Implement lazy project directory creation (NNN_codebase_review format)
- Generate review summary artifacts in summaries/ subdirectory only
- Standardize return format per subagent-return-format.md (brief summary + artifact path)
- Update state.json schema with review_artifacts tracking
- Protect orchestrator context window from verbose output

**Non-Goals**:
- Creating reports/ or plans/ subdirectories (only summaries/)
- Changing existing registry update behavior
- Modifying task creation logic
- Adding new status markers for review operations
- Creating detailed review reports (only summaries)

## Risks & Mitigations

- **Risk**: Reviewer subagent behavior undefined (no existing specification). **Mitigation**: Define behavior based on /review command workflow and /research command patterns.
- **Risk**: State.json schema changes may break backward compatibility. **Mitigation**: Add review_artifacts as optional field with default empty array.
- **Risk**: Git commit scope must include all changes atomically. **Mitigation**: Use existing git-workflow-manager patterns from /research command.
- **Risk**: Return format validation may fail if reviewer doesn't follow standard. **Mitigation**: Add explicit validation in ReceiveResults stage with error handling.

## Implementation Phases

### Phase 1: Create Reviewer Subagent Specification [NOT STARTED]

- **Goal**: Create documented reviewer.md subagent specification following subagent-template.md and subagent-return-format.md standards
- **Tasks**:
  - [ ] Create .opencode/agent/subagents/reviewer.md file
  - [ ] Define agent metadata (name: reviewer, role: codebase analysis, context_level: 2)
  - [ ] Specify inputs (session_id, delegation_depth, delegation_path, review_scope, project_path)
  - [ ] Define process flow (analyze codebase, count sorry/axioms/errors, identify gaps, create artifacts)
  - [ ] Specify lazy directory creation (create project root + summaries/ only when writing)
  - [ ] Define return format per subagent-return-format.md (status, summary, artifacts, metadata, errors)
  - [ ] Add validation checks (pre-execution: inputs valid, post-execution: artifact exists, return valid)
  - [ ] Add error handling (timeout 3600s, validation failure, file write errors)
  - [ ] Document review summary structure (3-5 sentences, <100 tokens, key findings)
- **Timing**: 1.5 hours
- **Acceptance Criteria**:
  - reviewer.md follows subagent-template.md structure
  - Return format matches subagent-return-format.md exactly
  - Lazy directory creation documented (create summaries/ only)
  - Timeout and error handling specified
  - No emojis in specification

### Phase 2: Update /review Command Workflow [NOT STARTED]

- **Goal**: Modify review.md command to implement project directory creation, artifact generation, and standardized return format
- **Tasks**:
  - [ ] Update Preflight stage: Read next_project_number from state.json
  - [ ] Update PrepareDelegation stage: Generate project_path (NNN_codebase_review), add to delegation context
  - [ ] Update InvokeReviewer stage: Pass project_path to reviewer subagent
  - [ ] Update ReceiveResults stage: Validate return against subagent-return-format.md, extract artifact path
  - [ ] Update ProcessResults stage: Extract brief summary and artifact path from return
  - [ ] Update Postflight stage: Increment next_project_number, update state.json with review_artifacts entry
  - [ ] Update ReturnSuccess stage: Return brief summary + artifact path only (remove verbose key findings)
  - [ ] Add git commit: Include artifacts + state.json + registries + TODO.md
- **Timing**: 1.5 hours
- **Acceptance Criteria**:
  - Project directory created lazily (only when reviewer writes artifact)
  - next_project_number incremented after project creation
  - Return validation checks status, summary, artifacts, metadata fields
  - Return to user is brief (3-5 sentences + artifact path)
  - Git commit includes all changes atomically
  - No emojis in command output

### Phase 3: Update state.json Schema [NOT STARTED]

- **Goal**: Add review_artifacts tracking to state.json repository_health section
- **Tasks**:
  - [ ] Add review_artifacts array to repository_health section in state.json
  - [ ] Define schema: array of objects with timestamp, path, scope fields
  - [ ] Update state-schema.md documentation with review_artifacts field
  - [ ] Ensure backward compatibility (optional field, default empty array)
  - [ ] Test state.json parsing with new field
- **Timing**: 0.5 hours
- **Acceptance Criteria**:
  - review_artifacts field added to repository_health
  - Schema documented in state-schema.md
  - Backward compatible (existing state.json files still valid)
  - Field populated correctly after /review execution

### Phase 4: Testing and Documentation [NOT STARTED]

- **Goal**: Validate implementation and update documentation
- **Tasks**:
  - [ ] Test /review command with artifact creation
  - [ ] Verify lazy directory creation (project root + summaries/ only, no reports/ or plans/)
  - [ ] Verify review summary artifact created with correct format (3-5 sentences, <100 tokens)
  - [ ] Verify return format (brief summary + artifact path, no verbose output)
  - [ ] Verify state.json updated with review_artifacts entry
  - [ ] Verify git commit includes all changes
  - [ ] Verify no emojis in output or artifacts
  - [ ] Update artifact-management.md with /review example
  - [ ] Update NAVIGATION.md if needed
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - All tests pass
  - Lazy directory creation verified (no pre-created subdirs)
  - Review summary follows summary.md standard
  - Return format protects context window
  - Documentation updated with /review patterns
  - No emojis anywhere

## Testing & Validation

- [ ] Run /review command and verify project directory created lazily
- [ ] Verify only summaries/ subdirectory created (not reports/ or plans/)
- [ ] Verify review summary artifact exists at summaries/review-summary.md
- [ ] Verify review summary follows summary.md standard (3-5 sentences, <100 tokens)
- [ ] Verify return to user is brief (summary + artifact path only)
- [ ] Verify state.json updated with review_artifacts entry
- [ ] Verify git commit includes artifacts + state.json + registries + TODO.md
- [ ] Verify no emojis in command output or artifacts
- [ ] Verify reviewer subagent returns standardized format per subagent-return-format.md
- [ ] Verify backward compatibility (old state.json files still work)

## Artifacts & Outputs

- .opencode/agent/subagents/reviewer.md (new subagent specification)
- .opencode/command/review.md (updated command workflow)
- .opencode/specs/state.json (updated schema with review_artifacts)
- .opencode/context/core/system/state-schema.md (updated documentation)
- .opencode/context/core/system/artifact-management.md (updated with /review example)
- .opencode/specs/NNN_codebase_review/summaries/review-summary.md (example artifact created by /review)
- .opencode/specs/206_update_review_command_summaries/summaries/implementation-summary-YYYYMMDD.md (implementation summary)

## Rollback/Contingency

If implementation fails or causes issues:
1. Revert reviewer.md creation (delete file)
2. Revert review.md changes (restore from git)
3. Revert state.json schema changes (remove review_artifacts field)
4. Revert documentation updates
5. Git revert commit if changes were committed
6. Mark task as [BLOCKED] with error details
7. Create follow-up task to address blockers

If partial completion occurs (timeout):
1. Preserve completed phases (reviewer.md, partial review.md updates)
2. Mark task as [IN PROGRESS]
3. Document completed work in implementation summary
4. Resume from next incomplete phase
