# Backup File Usage Audit

**Task**: 313 - Configure opencode agent system to prevent permission interruptions  
**Date**: 2026-01-05  
**Phase**: 1 - Audit Backup File Usage  

---

## Executive Summary

This audit identifies all locations where backup files are created instead of git safety commits. The system currently has **15 occurrences** of backup file patterns across commands and subagents, with **4 existing backup files** in the repository.

**Key Findings**:
- Primary backup usage in `/sync` command and `status-sync-manager` subagent
- Secondary backup references in `/todo`, `/review`, `/errors`, and `/meta` commands
- 4 existing backup files found (should be cleaned up)
- No active `/tmp` backup files currently exist

---

## Backup File Locations

### High Priority (Active Backup Creation)

#### 1. `.opencode/command/sync.md`
**Pattern**: `/tmp` backups with session ID  
**Lines**: Multiple references  
**Purpose**: Atomic synchronization of TODO.md and state.json  
**Context**:
```bash
cp specs/TODO.md /tmp/TODO.md.backup.$session_id
cp specs/state.json /tmp/state.json.backup.$session_id
```
**Migration Priority**: **HIGH** - Core synchronization command  
**Replacement**: Git safety commit before sync operation

#### 2. `.opencode/agent/subagents/status-sync-manager.md`
**Pattern**: In-memory backups with rollback logic  
**Lines**: Multiple references in steps 2, 3, 4  
**Purpose**: Two-phase commit for atomic status updates  
**Context**:
```
3. Create backups of both files
2. Restore all previously written files from backups
5. Create backups of original content
```
**Migration Priority**: **HIGH** - Core state management  
**Replacement**: Git safety commit before status update

### Medium Priority (Backup References)

#### 3. `.opencode/command/todo.md`
**Pattern**: User confirmation for bulk operations  
**Lines**: Multiple references  
**Purpose**: Confirmation threshold for archiving > 5 tasks  
**Context**:
```
b. Request user confirmation
c. Wait for confirmation (yes/no)
```
**Migration Priority**: **MEDIUM** - Maintenance operation  
**Replacement**: Git safety commit, remove confirmation

#### 4. `.opencode/command/review.md`
**Pattern**: Rollback reference  
**Lines**: 1 reference  
**Purpose**: Atomic registry updates  
**Context**: `Rollback: Restored from backup`  
**Migration Priority**: **MEDIUM** - Registry management  
**Replacement**: Git safety commit pattern

#### 5. `.opencode/command/errors.md`
**Pattern**: Rollback reference  
**Lines**: 1 reference  
**Purpose**: Atomic errors.json updates  
**Context**: `Rollback: Restored from backup`  
**Migration Priority**: **MEDIUM** - Error tracking  
**Replacement**: Git safety commit pattern

### Low Priority (Conceptual References)

#### 6. `.opencode/command/meta.md`
**Pattern**: Backup mention in system replacement  
**Lines**: 2 references  
**Purpose**: Replace existing system with backup  
**Context**: `Replace Existing System: Replace current system (with backup)`  
**Migration Priority**: **LOW** - Conceptual reference  
**Replacement**: Document git safety as backup mechanism

#### 7. `.opencode/agent/subagents/meta.md`
**Pattern**: Backup mention in integration mode  
**Lines**: 2 references  
**Purpose**: Integration mode selection  
**Context**: `If "Replace": Set integration_mode = "replace", create backup`  
**Migration Priority**: **LOW** - Conceptual reference  
**Replacement**: Document git safety as backup mechanism

---

## Existing Backup Files

### Files Found
```
specs/state.json.bad.bak
specs/archive/245_phase2_core_architecture/state.json.backup
specs/state.json.bak
.opencode/agent/orchestrator.md.backup
```

**Action Required**: Clean up these files after verifying they're not needed

---

## Confirmation Prompt Locations

### User Confirmation Prompts

#### 1. `.opencode/command/todo.md`
**Pattern**: Bulk operation confirmation  
**Purpose**: Confirm archiving > 5 tasks  
**Context**:
```xml
<confirmation_threshold>
  - Request confirmation
</confirmation_threshold>
```
**Migration**: Replace with git safety commit

#### 2. `.opencode/command/meta.md`
**Pattern**: System replacement confirmation  
**Purpose**: Confirm system replacement  
**Context**: `Gets user confirmation`  
**Migration**: Keep (intentional design for /meta interview)

---

## Direct Git Command Usage

### Commands Not Using git-workflow-manager

#### 1. `.opencode/command/sync.md`
**Pattern**: Direct git commit in Stage 7  
**Context**: Manual git add and commit commands  
**Migration**: Delegate to git-workflow-manager

#### 2. `.opencode/command/todo.md`
**Pattern**: Direct git add commands  
**Context**: 
```bash
git add specs/TODO.md
git add specs/state.json
git add specs/archive/state.json
git add specs/archive/  (pick up moved directories)
```
**Migration**: Delegate to git-workflow-manager

#### 3. `.opencode/agent/subagents/task-executor.md`
**Pattern**: Per-phase git commits  
**Context**: `Create git commit per completed phase`  
**Migration**: Delegate to git-workflow-manager

---

## Migration Checklist

### Phase 1: Audit (COMPLETED)
- [x] Search for backup file patterns
- [x] Document each location with context
- [x] Create migration checklist with priorities
- [x] Verify existing backup files

### Phase 2: Migrate Commands to Git Safety Pattern
- [ ] Migrate `/sync` command (HIGH priority)
- [ ] Migrate `status-sync-manager` subagent (HIGH priority)
- [ ] Migrate `/todo` command (MEDIUM priority)
- [ ] Migrate `/review` command (MEDIUM priority)
- [ ] Migrate `/errors` command (MEDIUM priority)
- [ ] Update `/meta` documentation (LOW priority)

### Phase 3: Audit and Expand Agent Permissions
- [ ] List all agent files
- [ ] Review current permissions
- [ ] Expand allow lists where safe
- [ ] Ensure dangerous operations remain denied
- [ ] Add git to tools lists

### Phase 4: Remove Confirmation Prompts
- [ ] Remove bulk operation confirmation in `/todo`
- [ ] Keep `/meta` interview (intentional design)
- [ ] Update documentation

### Phase 5: Standardize Git Workflow Manager Usage
- [ ] Replace direct git commands in `/sync`
- [ ] Replace direct git commands in `/todo`
- [ ] Replace direct git commands in `task-executor`
- [ ] Update documentation

### Phase 6: Document Permission Configuration
- [ ] Create permission configuration guide
- [ ] Document examples by agent type
- [ ] Document dangerous operations
- [ ] Add troubleshooting section
- [ ] Link from main documentation

---

## Quantitative Metrics

### Baseline Measurements
- **Backup file patterns**: 15 occurrences
- **Existing backup files**: 4 files
- **Confirmation prompts**: 2 occurrences (1 to remove, 1 to keep)
- **Direct git commands**: 3 locations

### Target Measurements
- **Backup file patterns**: 0 occurrences
- **Existing backup files**: 0 files
- **Confirmation prompts**: 1 occurrence (/meta only)
- **Direct git commands**: 0 locations (all via git-workflow-manager)

---

## Risk Assessment

### High Risk
- **status-sync-manager migration**: Core state management, must be atomic
- **sync command migration**: Critical synchronization operation

### Medium Risk
- **todo command migration**: Bulk operations, user confirmation removal
- **Permission expansion**: Must maintain safety boundaries

### Low Risk
- **Documentation updates**: No functional changes
- **Cleanup of existing backup files**: Can be reverted

---

## Next Steps

1. **Phase 2**: Begin migration with HIGH priority items
   - Start with `/sync` command
   - Then migrate `status-sync-manager`
   - Test thoroughly before proceeding

2. **Testing Strategy**:
   - Test successful operations
   - Test failed operations with rollback
   - Verify no backup files created
   - Verify git safety commits created

3. **Rollback Plan**:
   - Git safety commits enable easy rollback
   - Document rollback procedure
   - Test rollback scenarios

---

## Conclusion

The audit reveals a clear migration path from backup files to git safety commits. The system already has robust git-based safety mechanisms via git-workflow-manager, making this migration straightforward. The primary work is in the `/sync` command and `status-sync-manager` subagent, with secondary work in other commands.

**Recommendation**: Proceed with Phase 2 migration, starting with HIGH priority items.
