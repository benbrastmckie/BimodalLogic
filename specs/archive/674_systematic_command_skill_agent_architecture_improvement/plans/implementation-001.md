# Implementation Plan: Integrated Preflight and Postflight Operations in Workflow Skills
- **Task**: 674 - systematic command skill agent architecture improvement
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: research-003.md - Integrated preflight/postflight operations design with 3-phase migration approach
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: 
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Research report research-003.md identified a fundamental misalignment between documented patterns and actual implementation. While the system has evolved toward integrated preflight/postflight in workflow skills, the actual skill implementations remain thin wrappers that rely on the separate skill-status-sync component. This plan implements the research recommendations to integrate preflight and postflight operations directly into workflow skills, eliminating the skill-status-sync dependency for workflow operations while maintaining it for manual corrections and recovery.

## Goals & Non-Goals

**Goals**:
- Update workflow skills to handle their own preflight/postflight operations
- Eliminate dependency on skill-status-sync for workflow operations
- Improve system reliability through atomic operations within single skill context
- Maintain backward compatibility with existing workflows
- Implement robust error handling and rollback mechanisms

**Non-Goals**:
- Complete removal of skill-status-sync (keep for manual operations)
- Changes to agent implementations
- Modifications to core command routing logic
- Changes to task creation or validation workflows

## Risks & Mitigations

- **Risk**: Implementation complexity across multiple skills could introduce bugs
  - **Mitigation**: Incremental migration with comprehensive testing at each step
- **Risk**: Status update operations could fail and leave system in inconsistent state
  - **Mitigation**: Atomic operations with rollback capabilities and error logging
- **Risk**: Performance impact from additional inline operations
  - **Mitigation**: Benchmark against current implementation and optimize patterns
- **Risk**: Breaking changes to existing workflows
  - **Mitigation**: Maintain all existing interfaces and backward compatibility

## Implementation Phases

### Phase 1: Update Workflow Skill Frontmatter [NOT STARTED]
- **Goal:** Prepare workflow skills for integrated lifecycle management
- **Tasks:**
  - [ ] Update skill-researcher frontmatter to include Bash, Edit, Read tools
  - [ ] Update skill-planner frontmatter to include Bash, Edit, Read tools
  - [ ] Update skill-implementer frontmatter to include Bash, Edit, Read tools
  - [ ] Update skill-lean-research frontmatter to include Bash, Edit, Read tools
  - [ ] Update skill-lean-implementation frontmatter to include Bash, Edit, Read tools
  - [ ] Update skill-latex-implementation frontmatter to include Bash, Edit, Read tools
  - [ ] Remove context: fork and agent fields from all workflow skills
  - [ ] Update skill descriptions to reflect integrated lifecycle responsibility
- **Timing:** 45 minutes

### Phase 2: Implement Integrated Preflight Operations [NOT STARTED]
- **Goal:** Add preflight status validation and updates to workflow skills
- **Tasks:**
  - [ ] Add preflight section to skill-researcher using inline-status-update.md patterns
  - [ ] Add preflight section to skill-planner using inline-status-update.md patterns
  - [ ] Add preflight section to skill-implementer using inline-status-update.md patterns
  - [ ] Apply same preflight patterns to skill-lean-research
  - [ ] Apply same preflight patterns to skill-lean-implementation
  - [ ] Apply same preflight patterns to skill-latex-implementation
  - [ ] Implement session ID generation and tracking
  - [ ] Add task existence and status validation logic
- **Timing:** 60 minutes

### Phase 3: Implement Integrated Postflight Operations [NOT STARTED]
- **Goal:** Add postflight artifact linking and status updates to workflow skills
- **Tasks:**
  - [ ] Add postflight section to skill-researcher with artifact linking and git commit
  - [ ] Add postflight section to skill-planner with artifact linking and git commit
  - [ ] Add postflight section to skill-implementer with artifact linking and git commit
  - [ ] Apply same postflight patterns to skill-lean-research
  - [ ] Apply same postflight patterns to skill-lean-implementation
  - [ ] Apply same postflight patterns to skill-latex-implementation
  - [ ] Implement atomic operations across specs/state.json and specs/TODO.md
  - [ ] Add error handling with non-blocking failure modes
- **Timing:** 60 minutes

### Phase 4: Testing and Validation [NOT STARTED]
- **Goal:** Ensure integrated operations work correctly and maintain reliability
- **Tasks:**
  - [ ] Create test state file for unit testing integrated skills
  - [ ] Test preflight validation for all workflow skills
  - [ ] Test postflight operations for all workflow skills
  - [ ] Validate atomic operations and rollback mechanisms
  - [ ] Test complete workflows end-to-end
  - [ ] Performance benchmark against current implementation
  - [ ] Verify backward compatibility with existing commands
- **Timing:** 30 minutes

## Testing & Validation

- [ ] Unit test each skill's preflight validation with mock task data
- [ ] Unit test each skill's postflight operations with mock artifacts
- [ ] Integration test complete research workflow (/research command)
- [ ] Integration test complete planning workflow (/plan command)
- [ ] Integration test complete implementation workflow (/implement command)
- [ ] Performance test to ensure <10% execution time increase
- [ ] Error handling test with intentional failures and rollback validation
- [ ] Manual testing with real tasks to ensure user experience unchanged

## Artifacts & Outputs

- Updated workflow skill files:
  - .opencode/skills/skill-researcher/SKILL.md
  - .opencode/skills/skill-planner/SKILL.md
  - .opencode/skills/skill-implementer/SKILL.md
  - .opencode/skills/skill-lean-research/SKILL.md
  - .opencode/skills/skill-lean-implementation/SKILL.md
  - .opencode/skills/skill-latex-implementation/SKILL.md
- Test framework files for validation
- Implementation summary documenting changes made
- Updated documentation reflecting integrated approach

## Rollback/Contingency

If integration issues arise:
1. **Immediate rollback**: Revert skill files to previous versions using git
2. **Partial rollback**: Keep frontmatter updates but revert integrated logic
3. **Fallback**: Continue using skill-status-sync manually for status corrections
4. **Documentation**: Clearly mark which skills have integrated vs separate lifecycle

The migration is designed to be backward compatible, so existing workflows will continue to function even if integration is incomplete.