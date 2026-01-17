# ADR-004: Remove Redundant Project-Level state.json Files

## Status

**Accepted** - 2026-01-03

## Context

The system previously maintained duplicate state information in two locations:

1. **Central state file**: `specs/state.json`
   - Authoritative source for all project state
   - Queried by all commands and agents
   - Contains comprehensive project metadata in `active_projects` array
   - Single source of truth for project numbering

2. **Project-level state files**: `specs/{number}_{slug}/state.json`
   - Created lazily by status-sync-manager on first artifact write
   - Write-only (never read by any command or agent)
   - Contains subset of data already in central state.json
   - 62 files totaling 260KB

### Research Findings

Comprehensive analysis (Task 276, research-001.md) revealed:

1. **Zero reads**: No command or agent reads project-level state.json
   - Comprehensive codebase search found no reads
   - status-sync-manager reads for backup only, never uses data
   - All queries use central state.json

2. **Duplicate data**: All information in project-level state.json is already in central state.json
   - Project-level has LESS information than central
   - Only difference: structured artifact metadata (unused)
   - Central state.json is more complete and consistent

3. **Performance overhead**: 
   - 33% additional file I/O (3 files vs 2 files per status update)
   - 260KB redundant data across 62 files
   - Atomic write protocol complexity (3-file vs 2-file rollback)

4. **Maintenance burden**:
   - Two sources of truth for same data
   - Schema drift across project-level files
   - Synchronization complexity in status-sync-manager

### Problem Statement

Maintaining project-level state.json files creates:
- **Redundancy**: Duplicate data in two locations
- **Complexity**: More files to synchronize atomically
- **Performance cost**: 33% more file I/O operations
- **Maintenance burden**: Two sources of truth, schema drift
- **No benefit**: Files are write-only, never queried

## Decision

**Remove project-level state.json creation from the system.**

Specifically:
1. Update status-sync-manager to skip project-level state.json creation
2. Update all subagent specifications to remove project-level state.json references
3. Update state-management.md to remove project-level state.json schema
4. Use central state.json as single source of truth for all project state

### Migration Approach

**Backward-compatible removal**:
- Existing project-level state.json files left in place (no deletion)
- No breaking changes for archived projects
- Future cleanup can remove files if needed (deferred to separate task)

**Rationale**:
- Existing files don't cause harm (just unused)
- Avoids risk of breaking archived projects or external tools
- Simplifies migration (no data migration needed)

## Consequences

### Positive

1. **Simplified state management**:
   - Single source of truth (central state.json)
   - No schema drift between files
   - Easier to understand and maintain

2. **Improved performance**:
   - 33% reduction in file I/O operations (3 files → 2 files)
   - Simpler atomic write protocol (2-file vs 3-file rollback)
   - Reduced backup storage requirements

3. **Reduced complexity**:
   - Fewer files to synchronize atomically
   - Fewer failure points in status updates
   - Simpler rollback mechanism

4. **Better consistency**:
   - One schema for all project state
   - No synchronization issues between files
   - Centralized validation and versioning

### Negative

1. **Existing files remain**:
   - 62 unused files (260KB) remain on disk
   - May confuse developers unfamiliar with migration
   - Mitigation: Can be cleaned up in future task if needed

2. **Potential external tool impact**:
   - External tools may read project-level state.json (none found in research)
   - Mitigation: Backward-compatible approach, existing files remain

### Neutral

1. **No schema changes**:
   - Central state.json schema unchanged
   - No data migration required
   - Existing queries continue to work

2. **Documentation updates**:
   - 10 files updated (8 subagents, 2 standards)
   - Clear migration path documented
   - ADR provides historical context

## Implementation

### Files Modified

**Subagent Specifications** (8 files):
- `.opencode/agent/subagents/status-sync-manager.md` - Removed project state.json creation
- `.opencode/agent/subagents/researcher.md` - Removed project state.json references
- `.opencode/agent/subagents/planner.md` - Removed project state.json from git scope
- `.opencode/agent/subagents/implementer.md` - Removed project state.json from git scope
- `.opencode/agent/subagents/lean-research-agent.md` - Removed project state.json updates
- `.opencode/agent/subagents/lean-implementation-agent.md` - Removed project state.json updates
- `.opencode/agent/subagents/lean-planner.md` - Removed project state.json from git scope
- `.opencode/agent/subagents/reviewer.md` - Removed project state.json creation references

**Standards Documentation** (2 files):
- `.opencode/context/core/system/state-management.md` - Removed project state.json schema
- `.opencode/context/core/system/artifact-management.md` - No changes needed (no references)

**Architecture Documentation** (1 file):
- `docs/architecture/ADR-004-Remove-Project-Level-State-Files.md` - This document

### Changes Summary

1. **status-sync-manager.md**:
   - Removed Step 1 line: "Read project state.json if exists"
   - Removed Step 3 section: "Create or update project state.json"
   - Removed Step 5 lines: "Write project state.json"
   - Removed entire `<project_state_creation>` section
   - Updated constraints to remove project state.json requirement
   - Updated synchronization principles (removed lazy creation principle)

2. **Subagent specifications**:
   - Removed project state.json from git-workflow-manager scope_files
   - Removed project state.json update steps from Stage 7 (Postflight)
   - Removed project state.json constraints
   - Removed project state.json validation checks

3. **state-management.md**:
   - Removed "Project State File" schema section
   - Updated "Multi-File Synchronization" to list 2 files instead of 3
   - Updated "Atomic Update Requirement" to reflect 2-file protocol

## Performance Metrics

### Before Migration
- Files per status update: 3 (TODO.md, state.json, project state.json)
- Atomic write operations: Read 3, backup 3, write 3, verify 3
- Total project-level state files: 62 files (260KB)

### After Migration
- Files per status update: 2 (TODO.md, state.json)
- Atomic write operations: Read 2, backup 2, write 2, verify 2
- Total project-level state files: 62 files (unchanged, backward-compatible)
- New projects: 0 project-level state files created

### Improvement
- **File I/O reduction**: 33% (3 files → 2 files)
- **Atomic write complexity**: 33% reduction (fewer operations)
- **Disk space for new projects**: 0 bytes (no new project-level files)

## Alternatives Considered

### Alternative 1: Enhance Central state.json with Structured Artifacts

**Approach**: Add structured artifact metadata to central state.json
```json
"artifacts": [
  {
    "type": "research_report",
    "path": "...",
    "created": "...",
    "summary": "..."
  }
]
```

**Rejected because**:
- No queries found using structured metadata
- Simple array sufficient for all current use cases
- Adds complexity without benefit

### Alternative 2: Keep Project-Level state.json, Remove Central Tracking

**Approach**: Use only project-level state.json, remove central state.json tracking

**Rejected because**:
- Central state.json is queried by all commands
- Provides global view of all projects
- Required for project numbering, health metrics
- Project-level files are never queried

### Alternative 3: Merge Both Files into Single Hybrid

**Approach**: Create hybrid schema combining both files

**Rejected because**:
- Central state.json already contains all necessary data
- No benefit to hybrid approach
- Increases complexity without solving problem

## References

- **Research Report**: `specs/276_investigate_remove_redundant_project_level_state_json/reports/research-001.md`
- **Implementation Plan**: `specs/276_investigate_remove_redundant_project_level_state_json/plans/implementation-001.md`
- **Task**: Task 276 in `specs/TODO.md`

## Future Considerations

### Optional Cleanup Task

A future task may remove existing project-level state.json files:
- Estimated effort: 1 hour
- Low priority (files don't cause harm)
- Keep archived project state.json files (in archive/ directory)
- Run after migration validated (2+ weeks)

### Schema Evolution

If future features require project-specific metadata:
- Central state.json is extensible (schema version 1.1.0)
- Can add fields to central state.json as needed
- Project-level state.json can be re-introduced if truly necessary
- Current analysis shows no unique value in project-level state

## Approval

- **Author**: Task 276 Implementation
- **Date**: 2026-01-03
- **Reviewers**: N/A (automated implementation)
- **Status**: Accepted and Implemented
