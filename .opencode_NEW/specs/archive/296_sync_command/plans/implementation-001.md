# Implementation Plan: Create /sync command for bidirectional TODO.md and state.json synchronization

- **Task**: 296 - Create /sync command for bidirectional TODO.md and state.json synchronization
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/state-management.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a /sync command that bidirectionally synchronizes specs/TODO.md and specs/state.json, ensuring both files contain identical task information with the most recent changes from either file. The command will detect discrepancies between the two files, intelligently resolve conflicts by preferring the most recently updated data, and perform atomic updates to both files using the existing status-sync-manager's two-phase commit protocol. This addresses the architectural requirement that state.json is the authoritative source for metadata reads while TODO.md serves as the user-facing view, with synchronization ensuring consistency between them.

## Goals & Non-Goals

**Goals**:
- Detect discrepancies between TODO.md and state.json task entries
- Resolve conflicts by preferring most recently modified data (file mtime comparison)
- Perform atomic bidirectional synchronization using status-sync-manager
- Handle edge cases: tasks in one file but not the other, status mismatches, metadata differences
- Provide clear reporting of changes made during synchronization
- Support dry-run mode (--dry-run flag) to preview changes without applying them
- Regenerate TODO.md YAML header from state.json metadata

**Non-Goals**:
- Synchronize plan files or other artifacts (only TODO.md and state.json)
- Perform automatic synchronization on every command (manual invocation only)
- Resolve conflicts through user prompts (automated resolution based on timestamps)
- Synchronize archived tasks (only active_projects in state.json)

## Risks & Mitigations

- **Risk**: Data loss if synchronization logic has bugs. **Mitigation**: Create backups before any writes, implement comprehensive validation, use status-sync-manager's rollback mechanism.
- **Risk**: Conflicting changes in both files simultaneously. **Mitigation**: Use file modification timestamps to determine authoritative source, document conflict resolution strategy clearly.
- **Risk**: Malformed TODO.md or state.json causing sync failures. **Mitigation**: Validate file formats before synchronization, provide clear error messages with recovery steps.
- **Risk**: Performance issues with large task lists. **Mitigation**: Use efficient jq queries for state.json, optimize TODO.md parsing with targeted grep/awk.

## Implementation Phases

### Phase 1: Design Synchronization Algorithm [NOT STARTED]

- **Goal**: Define the bidirectional synchronization algorithm and conflict resolution strategy
- **Tasks**:
  - [ ] Document synchronization algorithm (detect, compare, resolve, apply)
  - [ ] Define conflict resolution rules (mtime-based, status precedence)
  - [ ] Design data structures for tracking discrepancies
  - [ ] Define edge cases and handling strategies
  - [ ] Document dry-run mode behavior
  - [ ] Create algorithm pseudocode
- **Timing**: 1.5 hours

### Phase 2: Create Command File Structure [NOT STARTED]

- **Goal**: Create /sync command file with argument parsing and validation
- **Tasks**:
  - [ ] Create .opencode/command/sync.md with frontmatter
  - [ ] Implement argument parsing (--dry-run flag support)
  - [ ] Add file existence validation (TODO.md, state.json)
  - [ ] Add file format validation (JSON syntax, markdown structure)
  - [ ] Implement backup creation before synchronization
  - [ ] Add session_id generation
- **Timing**: 1 hour

### Phase 3: Implement Discrepancy Detection [NOT STARTED]

- **Goal**: Detect differences between TODO.md and state.json
- **Tasks**:
  - [ ] Parse TODO.md to extract all task entries (task_number, status, metadata)
  - [ ] Parse state.json active_projects array
  - [ ] Compare task lists to find tasks in one file but not the other
  - [ ] Compare task metadata (status, priority, effort, language, description)
  - [ ] Detect status mismatches between files
  - [ ] Detect metadata mismatches (priority, effort, timestamps)
  - [ ] Build discrepancy report data structure
- **Timing**: 2 hours

### Phase 4: Implement Conflict Resolution [NOT STARTED]

- **Goal**: Resolve conflicts using timestamp-based strategy
- **Tasks**:
  - [ ] Implement file modification time comparison (stat -c %Y)
  - [ ] Define resolution rules: newer file wins for conflicts
  - [ ] Handle tasks present in only one file (add to other file)
  - [ ] Handle status mismatches (prefer newer file's status)
  - [ ] Handle metadata mismatches (prefer newer file's metadata)
  - [ ] Generate resolution plan (list of changes to apply)
  - [ ] Validate resolution plan is consistent
- **Timing**: 1.5 hours

### Phase 5: Implement Synchronization Application [NOT STARTED]

- **Goal**: Apply synchronization changes atomically using status-sync-manager
- **Tasks**:
  - [ ] Implement dry-run mode (display changes without applying)
  - [ ] For each discrepancy, prepare status-sync-manager delegation context
  - [ ] Delegate to status-sync-manager for atomic updates
  - [ ] Handle status-sync-manager return (success/failure)
  - [ ] Aggregate results across all synchronization operations
  - [ ] Regenerate TODO.md YAML header from state.json
  - [ ] Verify synchronization succeeded (re-check for discrepancies)
- **Timing**: 2 hours

### Phase 6: Testing and Validation [NOT STARTED]

- **Goal**: Test synchronization with various scenarios and edge cases
- **Tasks**:
  - [ ] Test with no discrepancies (no-op case)
  - [ ] Test with task in TODO.md but not state.json
  - [ ] Test with task in state.json but not TODO.md
  - [ ] Test with status mismatch between files
  - [ ] Test with metadata mismatch (priority, effort)
  - [ ] Test with malformed TODO.md (recovery)
  - [ ] Test with malformed state.json (recovery)
  - [ ] Test dry-run mode (no changes applied)
  - [ ] Test rollback on failure
  - [ ] Verify YAML header regeneration
- **Timing**: 1.5 hours

## Testing & Validation

- [ ] Verify /sync command file created with correct frontmatter
- [ ] Verify argument parsing handles --dry-run flag correctly
- [ ] Verify discrepancy detection identifies all differences
- [ ] Verify conflict resolution follows timestamp-based strategy
- [ ] Verify atomic updates via status-sync-manager
- [ ] Verify dry-run mode displays changes without applying
- [ ] Verify rollback mechanism works on failure
- [ ] Verify TODO.md YAML header regenerated correctly
- [ ] Verify synchronization report is clear and accurate
- [ ] Test with real TODO.md and state.json files

## Artifacts & Outputs

- .opencode/command/sync.md (command file)
- specs/296_sync_command/plans/implementation-001.md (this file)
- specs/296_sync_command/summaries/implementation-summary-20260105.md (after completion)

## Rollback/Contingency

If synchronization fails or produces incorrect results:
1. Restore TODO.md and state.json from backups created before sync
2. Review error logs to identify root cause
3. Fix synchronization logic and re-test with dry-run mode
4. If command is fundamentally flawed, mark task as [BLOCKED] and revise plan
5. Document any data inconsistencies discovered for manual resolution

## Success Metrics

- /sync command successfully detects all discrepancies between TODO.md and state.json
- Conflict resolution correctly prefers most recently modified file
- Atomic updates via status-sync-manager maintain consistency
- Dry-run mode accurately previews changes without applying them
- Synchronization report clearly communicates changes made
- No data loss or corruption during synchronization
- Command handles edge cases gracefully with clear error messages
