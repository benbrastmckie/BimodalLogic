# Implementation Plan: Fix Lean Subagents Compliance with Artifact Management, Status Markers, and State Schema

- **Task**: 210 - Fix Lean subagents to follow artifact-management.md, status-markers.md, and state-schema.md
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: Research report (.opencode/specs/210_fix_lean_subagents/reports/research-001.md) identified 21 compliance issues across both agents
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/common/standards/plan.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

Both Lean subagents (lean-research-agent.md and lean-implementation-agent.md) have critical deviations from three key specifications: artifact-management.md, status-markers.md, and state-schema.md. Research identified 21 compliance issues including missing status marker workflows (preventing task tracking), missing state.json updates (preventing synchronization), and missing summary artifact enforcement (risking context window bloat). This plan addresses all issues in three phases aligned to severity: Critical fixes (3-4 hours), High-priority fixes (2-3 hours), and Medium/Low-priority fixes (1-2 hours). Definition of done: All 21 issues resolved, both agents fully compliant with all three specifications, validation tests passing.

## Goals & Non-Goals

**Goals**:
- Fix all 8 CRITICAL issues (status workflows, state updates, summary enforcement)
- Fix all 8 HIGH issues (artifact paths, validation, project state files)
- Fix all 4 MEDIUM issues (documentation clarity, edge cases)
- Fix 1 LOW issue (emoji validation)
- Achieve 100% compliance with artifact-management.md, status-markers.md, and state-schema.md
- Maintain backward compatibility with existing workflows

**Non-Goals**:
- Architectural changes to agent structure
- Changes to specification files themselves
- Performance optimization beyond compliance requirements
- Adding new features beyond compliance scope

## Risks & Mitigations

- **Risk**: Changes break existing workflows. **Mitigation**: Test with real tasks after each phase, maintain backward compatibility.
- **Risk**: Status marker updates conflict with orchestrator updates. **Mitigation**: Follow status-markers.md delegation patterns exactly.
- **Risk**: state.json updates cause race conditions. **Mitigation**: Use atomic update patterns from state-schema.md.
- **Risk**: Summary artifact validation too strict. **Mitigation**: Use <100 token limit with 10% tolerance for edge cases.
- **Risk**: Lazy directory creation breaks existing assumptions. **Mitigation**: Document timing explicitly, test directory creation patterns.

## Implementation Phases

### Phase 1: Critical Fixes - Status Markers and State Updates [NOT STARTED]

- **Goal**: Fix core workflow issues that break task tracking and synchronization
- **Tasks**:
  - [ ] Add status marker workflow to lean-research-agent.md (LRA-SM-001)
    - Add step_1 logic: Mark task [RESEARCHING] in TODO.md when starting
    - Add step_6 logic: Mark task [RESEARCHED] in TODO.md when completing
    - Follow workflow: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]
  - [ ] Add timestamp updates to lean-research-agent.md (LRA-SM-002)
    - Add **Started**: YYYY-MM-DD timestamp when marking [RESEARCHING]
    - Add **Completed**: YYYY-MM-DD timestamp when marking [RESEARCHED]
  - [ ] Add state.json updates to lean-research-agent.md (LRA-SS-001)
    - Update active_projects array with task status
    - Add artifacts array with research report and summary paths
    - Set created_at and updated_at timestamps (ISO 8601 format)
  - [ ] Add status marker workflow to lean-implementation-agent.md (LIA-SM-001)
    - Add step_1 logic: Mark task [IMPLEMENTING] when starting
    - Add step_6 logic: Mark task [COMPLETED]/[PARTIAL]/[BLOCKED] when finishing
    - Follow workflow: [PLANNED] → [IMPLEMENTING] → [COMPLETED]/[PARTIAL]/[BLOCKED]
  - [ ] Add timestamp updates to lean-implementation-agent.md (LIA-SM-002)
    - Add **Started** and **Completed** timestamps
  - [ ] Add state.json updates to lean-implementation-agent.md (LIA-SS-001)
    - Update active_projects with implementation status
    - Add artifacts array with implementation files and summary
    - Set timestamps in ISO 8601 format
  - [ ] Enforce summary artifact requirements in lean-research-agent.md (LRA-AM-001)
    - Add token counting validation (<100 tokens)
    - Add sentence counting validation (3-5 sentences)
    - Add validation before writing summary artifact
  - [ ] Enforce summary artifact requirements in lean-implementation-agent.md (LIA-AM-001)
    - Add token counting validation (<100 tokens)
    - Add sentence counting validation (3-5 sentences)
    - Add validation in step_5 before writing summary
- **Timing**: 3-4 hours
- **Validation**:
  - [ ] Status markers update correctly in TODO.md
  - [ ] Timestamps appear in TODO.md
  - [ ] state.json updates with correct structure
  - [ ] Summary artifacts meet token/sentence limits

### Phase 2: High-Priority Fixes - Artifact Links and Validation [NOT STARTED]

- **Goal**: Fix integration and quality issues for proper artifact linking and tracking
- **Tasks**:
  - [ ] Fix artifact link paths in lean-research-agent.md (LRA-AM-002)
    - Change relative paths to absolute: .opencode/specs/{task_number}_{topic}/...
    - Update return format examples (lines 432-441)
    - Update documentation sections
  - [ ] Fix artifact link paths in lean-implementation-agent.md (LIA-AM-002)
    - Verify Lean file paths are correct (project root paths)
    - Ensure summary artifact paths use .opencode/specs/ prefix
    - Update return format examples (lines 196-205)
  - [ ] Add summary validation in lean-research-agent.md (LRA-AM-004)
    - Add step_6 validation: Check summary artifact exists
    - Add step_6 validation: Verify token count <100
    - Add step_6 validation: Verify sentence count 3-5
    - Fail with clear error if validation fails
  - [ ] Add summary validation in lean-implementation-agent.md (LIA-AM-003)
    - Add step_6 validation: Check summary artifact exists
    - Add step_6 validation: Verify token/sentence requirements
    - Fail with clear error if validation fails
  - [ ] Add project state.json updates in lean-research-agent.md (LRA-SS-002)
    - Create .opencode/specs/{task_number}_{topic}/state.json when creating first artifact
    - Include research artifacts tracking
    - Follow lazy creation: create only when writing first artifact
  - [ ] Add project state.json updates in lean-implementation-agent.md (LIA-SS-002)
    - Update .opencode/specs/{task_number}_{topic}/state.json with implementation artifacts
    - Track Lean files modified/created
    - Track compilation status
  - [ ] Document artifact link format in lean-research-agent.md (LRA-SM-003)
    - Add documentation of TODO.md artifact link format
    - Specify **Research Artifacts**: section with Main Report/Summary subsections
    - Provide examples
  - [ ] Enforce lazy directory creation in both agents (XC-001)
    - Add explicit lazy creation validation
    - Document: Create project root only when writing first artifact
    - Document: Create subdirs only when writing into them
    - Document: Never pre-create unused subdirs
- **Timing**: 2-3 hours
- **Validation**:
  - [ ] Artifact paths are absolute and correct
  - [ ] Summary validation catches invalid artifacts
  - [ ] Project state.json created correctly
  - [ ] Lazy directory creation enforced

### Phase 3: Medium/Low Priority Fixes - Documentation and Edge Cases [NOT STARTED]

- **Goal**: Polish documentation, handle edge cases, improve consistency
- **Tasks**:
  - [ ] Clarify directory creation timing in lean-research-agent.md (LRA-AM-003)
    - Rewrite lines 267-272 with explicit lazy creation guarantee
    - Document exact timing: "Create project root immediately before writing first artifact"
    - Document: "Create reports/ only when writing report"
    - Document: "Create summaries/ only when writing summary"
  - [ ] Clarify partial status handling in lean-implementation-agent.md (LIA-SM-003)
    - Document that partial returns must update TODO.md to [PARTIAL]
    - Add example of partial status workflow
    - Clarify when to use [PARTIAL] vs [BLOCKED]
  - [ ] Document timestamp format in lean-research-agent.md (LRA-SS-003)
    - Specify ISO 8601 format for creation timestamps (YYYY-MM-DDTHH:MM:SSZ)
    - Specify YYYY-MM-DD format for status change timestamps
    - Add examples
  - [ ] Align return format documentation in both agents (XC-003)
    - Audit return format examples against subagent-return-format.md
    - Fix any deviations
    - Ensure consistency across both agents
  - [ ] Add emoji validation in both agents (XC-002)
    - Add validation in artifact writing steps
    - Check for emoji characters before writing
    - Fail with clear error if emojis detected
- **Timing**: 1-2 hours
- **Validation**:
  - [ ] Documentation is clear and accurate
  - [ ] Edge cases are handled correctly
  - [ ] Return formats match specification
  - [ ] Emoji validation works

## Testing & Validation

**Unit Tests**:
- [ ] Test summary artifact token counting (verify <100 token limit)
- [ ] Test summary artifact sentence counting (verify 3-5 sentences)
- [ ] Test status marker transitions (verify correct workflow)
- [ ] Test state.json update structure (verify schema compliance)
- [ ] Test lazy directory creation (verify timing)
- [ ] Test emoji validation (verify detection)

**Integration Tests**:
- [ ] Test full research workflow: /research command
  - Verify TODO.md: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]
  - Verify timestamps added to TODO.md
  - Verify state.json updated correctly
  - Verify summary artifact created and validated
  - Verify artifact paths are absolute
- [ ] Test full implementation workflow: /implement command
  - Verify TODO.md: [PLANNED] → [IMPLEMENTING] → [COMPLETED]
  - Verify timestamps added
  - Verify state.json updated
  - Verify summary artifact created and validated
  - Verify Lean files tracked correctly
- [ ] Test partial implementation workflow
  - Verify TODO.md marked [PARTIAL]
  - Verify partial status in state.json
- [ ] Test blocked implementation workflow
  - Verify TODO.md marked [BLOCKED]
  - Verify blocked status in state.json

**Manual Validation**:
- [ ] Run /research on test task, verify TODO.md updates
- [ ] Run /implement on test task, verify status transitions
- [ ] Check state.json for correct structure and content
- [ ] Verify artifact paths are absolute in TODO.md
- [ ] Verify summary artifacts meet requirements
- [ ] Verify no emojis in any artifacts
- [ ] Verify lazy directory creation (no pre-created empty dirs)

## Artifacts & Outputs

**Modified Files**:
- .opencode/agent/subagents/lean-research-agent.md (updated with all LRA-* fixes)
- .opencode/agent/subagents/lean-implementation-agent.md (updated with all LIA-* fixes)

**Validation Artifacts**:
- Test results documenting all validation checks passing
- Example TODO.md showing correct status markers and timestamps
- Example state.json showing correct structure
- Example summary artifacts meeting requirements

**Documentation Updates**:
- Both agent files updated with clarified documentation
- Examples updated to show correct patterns
- Constraints sections updated with validation requirements

## Rollback/Contingency

**If Phase 1 breaks workflows**:
- Revert status marker changes
- Revert state.json update logic
- Keep summary enforcement (low risk)
- Investigate conflict with orchestrator
- Re-implement with proper delegation patterns

**If Phase 2 validation too strict**:
- Relax token limit to 110 tokens (10% tolerance)
- Allow 2-6 sentences instead of 3-5
- Document exceptions in agent files
- Maintain spirit of context window protection

**If Phase 3 documentation unclear**:
- Gather feedback from test runs
- Revise documentation based on actual usage
- Add more examples
- Clarify edge cases

**Complete Rollback**:
- Git revert to commit before changes
- Document issues encountered
- Create new plan addressing root causes
- Re-implement with lessons learned

**Partial Success Strategy**:
- Phase 1 is minimum viable fix (critical issues)
- Phase 2 can be deferred if needed
- Phase 3 is polish and can be done later
- Prioritize working workflows over perfect compliance
