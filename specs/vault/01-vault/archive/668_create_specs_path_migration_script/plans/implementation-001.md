# Implementation Plan: Create Specs Path Migration Script

- **Task**: 668 - Create automated script to migrate .opencode/specs references to specs/
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Priority**: Medium
- **Dependencies**: 667 (needs research from path reference analysis)
- **Research Inputs**: Analysis from task 667 about all path references that need updating
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - scripts/specs-path-migrator.py (to be created)
  - reports/test-results-001.md (to be created)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a comprehensive Python script that can automatically detect and migrate `.opencode/specs` path references to `specs/` throughout the codebase. This script will serve as both a fix for the current issue and a preventative tool for future path migrations.

## Goals & Non-Goals

**Goals**:
- Create automated script to find and replace .opencode/specs references
- Include safety checks and validation
- Support dry-run mode for testing
- Generate detailed change reports
- Make script reusable for future path migrations

**Non-Goals**:
- Manually fixing all references (script should automate this)
- Changing directory structures (only updating references)
- Modifying git history or archived content

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Script makes incorrect replacements | Implement pattern matching with context validation |
| Breaks working functionality | Include dry-run mode and backup creation |
| Edge cases missed | Test on known patterns and handle special cases |
| Script becomes outdated | Document patterns and make configurable |

## Implementation Phases

### Phase 1: Script Design and Setup [NOT STARTED]
- **Goal**: Create script structure and configuration
- **Tasks**:
  - [ ] Set up Python script with argparse interface
  - [ ] Define replacement patterns and rules
  - [ ] Create file discovery mechanism (glob patterns)
  - [ ] Add dry-run and backup modes
  - [ ] Set up logging and reporting
- **Timing**: 1 hour

### Phase 2: Pattern Detection Engine [NOT STARTED]
- **Goal**: Implement core detection logic
- **Tasks**:
  - [ ] Create regex patterns for .opencode/specs references
  - [ ] Add context validation (avoid false positives)
  - [ ] Implement file type specific handling (md, py, sh)
  - [ ] Add exclusions for archives and history
  - [ ] Create detection accuracy validation
- **Timing**: 1 hour

### Phase 3: Replacement Engine [NOT STARTED]
- **Goal**: Implement safe replacement logic
- **Tasks**:
  - [ ] Create replacement logic with validation
  - [ ] Add undo capability with backup creation
  - [ ] Implement change verification after replacement
  - [ ] Add special handling for complex patterns
  - [ ] Create change summary generation
- **Timing**: 1-1.5 hours

### Phase 4: Testing and Validation [NOT STARTED]
- **Goal**: Thoroughly test script functionality
- **Tasks**:
  - [ ] Test on known reference patterns from task 667
  - [ ] Validate dry-run matches expected changes
  - [ ] Test backup and restore functionality
  - [ ] Run full migration and verify task creation works
  - [ ] Document script usage and patterns
- **Timing**: 0.5-1 hour

## Testing & Validation

- [ ] Script detects all known .opencode/specs references
- [ ] Dry-run shows expected changes without modifying files
- [ ] Actual migration successfully fixes task creation
- [ ] Backup files allow complete rollback
- [ ] Script documentation is clear and accurate

## Artifacts & Outputs

- scripts/specs-path-migrator.py - Automated migration script
- reports/test-results-001.md - Test execution and validation results
- Updated files with corrected path references (from script execution)

## Rollback/Contingency

If script causes issues:
1. Use backup files to restore original state
2. Identify problematic patterns and update rules
3. Re-run with more restrictive pattern matching
4. Manually fix any edge cases the script missed
5. Update script with learned patterns for future use

## Script Interface Design

```bash
python3 scripts/specs-path-migrator.py [OPTIONS]

Options:
  --dry-run     Show changes without applying them
  --backup      Create backup files before modifying
  --pattern     Custom pattern to search for
  --replace     Custom replacement text
  --exclude     Comma-separated list of paths to exclude
  --include     Comma-separated list of file types to include
  --verbose     Detailed output of all changes
  --report      Generate detailed change report
```