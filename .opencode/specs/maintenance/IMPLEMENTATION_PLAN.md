# Maintenance Artifact Management - Implementation Plan

**Version**: 1.0.0  
**Date**: 2025-12-19  
**Status**: In Progress  
**Objective**: Standardize maintenance artifact management using state.json approach

---

## Executive Summary

This implementation plan details the transition from the current mixed approach (ARCHIVE_INDEX.md + scattered reports) to a standardized state.json-based system for maintenance artifact management.

### Goals

1. **Eliminate Redundancy**: Replace ARCHIVE_INDEX.md with archive/state.json
2. **Standardize Reports**: Use report-YYYYMMDD.md naming for all maintenance reports
3. **Centralize State**: Track all maintenance operations in maintenance/state.json
4. **Ensure Consistency**: Apply same patterns across /review, /todo, and related commands

### Current Status

**Completed** ✅:
- [x] Created archive/state.json schema with examples
- [x] Created maintenance/state.json schema with examples
- [x] Updated state.json with references
- [x] Created STATE_SCHEMA_GUIDE.md documentation
- [x] Created maintenance-report-template.md
- [x] Created maintenance-workflow.md
- [x] Created MIGRATION.md guide

**In Progress** ⏳:
- [ ] Migrate remaining projects to archive/state.json
- [ ] Update agents to use new workflow
- [ ] Standardize existing report names
- [ ] Deprecate ARCHIVE_INDEX.md

**Pending** ⏸️:
- [ ] Update commands to use new workflow
- [ ] Consolidate report types
- [ ] Full testing and validation

---

## Architecture Design

### State Management Hierarchy

```
.opencode/specs/
├── state.json                          # Global state (coordinator)
│   ├── state_references                # Points to specialized states
│   ├── repository_health               # Overall health metrics
│   ├── maintenance_summary             # Maintenance overview
│   └── archive_summary                 # Archive overview
│
├── archive/
│   ├── state.json                      # Archive state (authoritative)
│   │   ├── archive_metadata            # Archive info
│   │   ├── archived_projects[]         # All archived projects
│   │   ├── statistics                  # Archive statistics
│   │   └── search_indices              # Query optimization
│   │
│   └── {NNN_project_name}/             # Archived project directories
│       ├── plans/
│       ├── summaries/
│       └── state.json                  # Project-level state
│
└── maintenance/
    ├── state.json                      # Maintenance state (authoritative)
    │   ├── maintenance_metadata        # Maintenance info
    │   ├── operations[]                # All maintenance operations
    │   ├── health_trends[]             # Health over time
    │   ├── technical_debt              # Debt tracking
    │   └── metrics_history             # Metrics over time
    │
    └── report-YYYYMMDD.md              # Standardized reports
```

### Data Flow

```
Maintenance Operation
        ↓
    Reviewer Agent
        ↓
    ┌───────────────────────────────────┐
    │                                   │
    ↓                                   ↓
Verification Specialist         TODO Manager
    │                                   │
    ↓                                   ↓
Scan Codebase                   Update TODO.md
Find Discrepancies              Archive Projects
    │                                   │
    └───────────────┬───────────────────┘
                    ↓
            Update State Files
                    ↓
        ┌───────────┴───────────┐
        ↓                       ↓
archive/state.json    maintenance/state.json
        │                       │
        └───────────┬───────────┘
                    ↓
            state.json (global)
                    ↓
        Generate Report
                    ↓
    report-YYYYMMDD.md
```

---

## File Modifications

### 1. State Files (Completed ✅)

#### archive/state.json
**Status**: ✅ Created  
**Location**: `.opencode/specs/archive/state.json`  
**Changes**:
- Created comprehensive schema
- Populated with 3 example projects (052, 056, 061)
- Included statistics and search indices
- Documented in STATE_SCHEMA_GUIDE.md

**Remaining Work**:
- Migrate 3 more projects (059, 060, 062)
- Update statistics after migration
- Verify all data migrated correctly

#### maintenance/state.json
**Status**: ✅ Created  
**Location**: `.opencode/specs/maintenance/state.json`  
**Changes**:
- Created comprehensive schema
- Populated with 2 example operations (20251218, 20251219)
- Included health trends and technical debt tracking
- Documented in STATE_SCHEMA_GUIDE.md

**Remaining Work**:
- Add historical operations if available
- Update with next maintenance operation
- Verify metrics calculations

#### state.json
**Status**: ✅ Updated  
**Location**: `.opencode/specs/state.json`  
**Changes**:
- Added schema_version: "1.0.0"
- Added state_references section
- Added repository_health summary
- Added maintenance_summary
- Added archive_summary
- Preserved all existing fields

**Remaining Work**:
- None (backward compatible)

### 2. Templates (Completed ✅)

#### maintenance-report-template.md
**Status**: ✅ Created  
**Location**: `.opencode/context/lean4/templates/maintenance-report-template.md`  
**Purpose**: Standard template for all maintenance reports  
**Sections**:
- Executive Summary
- Maintenance Operations Performed
- Discrepancies Found and Resolved
- Project Health Snapshot
- State Updates
- Recommendations
- Artifacts Created
- Verification Commands
- Next Steps
- Conclusion
- Appendices

**Usage**: All agents should use this template for maintenance reports

### 3. Workflows (Completed ✅)

#### maintenance-workflow.md
**Status**: ✅ Created  
**Location**: `.opencode/context/lean4/processes/maintenance-workflow.md`  
**Purpose**: Standardized workflow for maintenance operations  
**Content**:
- Workflow stages (9 stages)
- File naming conventions
- State management procedures
- Agent coordination
- Migration strategy
- Best practices
- Troubleshooting

**Usage**: All maintenance agents should follow this workflow

### 4. Documentation (Completed ✅)

#### STATE_SCHEMA_GUIDE.md
**Status**: ✅ Created  
**Location**: `.opencode/specs/STATE_SCHEMA_GUIDE.md`  
**Purpose**: Comprehensive documentation for all state schemas  
**Content**:
- Schema overview
- Detailed field documentation
- Timestamp formats
- Versioning strategy
- Usage guidelines
- Query examples
- Migration guide

#### MIGRATION.md
**Status**: ✅ Created  
**Location**: `.opencode/specs/maintenance/MIGRATION.md`  
**Purpose**: Guide for migrating from ARCHIVE_INDEX.md to archive/state.json  
**Content**:
- Current state analysis
- Migration strategy (5 phases)
- Data mapping
- Verification procedures
- Rollback plan
- Testing plan
- Timeline

---

## Agent Updates

### 1. reviewer.md (Pending ⏸️)

**File**: `.opencode/agent/subagents/reviewer.md`  
**Current Behavior**:
- Creates NNN_review_YYYYMMDD directories
- Generates analysis and verification reports
- Updates TODO.md via todo-manager
- Updates project state.json

**Required Changes**:

1. **Stage 3: AnalyzeRepository** (Lines 91-131)
   - Update artifact_creation to use maintenance/state.json
   - Add reference to maintenance-workflow.md

2. **Stage 6: UpdateState** (Lines 211-247)
   - Add update to maintenance/state.json
   - Add update to archive/state.json if archiving
   - Follow maintenance-workflow.md procedures

3. **Stage 7: ReturnToOrchestrator** (Lines 249-290)
   - Include maintenance/state.json reference
   - Include archive/state.json reference if archiving

**New Sections to Add**:
```markdown
<maintenance_integration>
  <workflow_reference>
    Follow maintenance-workflow.md for all maintenance operations
  </workflow_reference>
  
  <state_updates>
    - Update maintenance/state.json with operation details
    - Update archive/state.json when archiving projects
    - Update state.json with summaries
  </state_updates>
  
  <report_template>
    Use maintenance-report-template.md for all maintenance reports
  </report_template>
</maintenance_integration>
```

### 2. todo-manager.md (Pending ⏸️)

**File**: `.opencode/agent/subagents/specialists/todo-manager.md`  
**Current Behavior**:
- Updates TODO.md with new tasks
- Removes completed tasks
- Maintains TODO.md organization

**Required Changes**:

1. **Workflow Section** (Lines 28-37)
   - Add step to update archive/state.json when archiving
   - Add step to update maintenance/state.json
   - Reference maintenance-workflow.md

2. **Output Section** (Lines 53-56)
   - Add archive/state.json update summary
   - Add maintenance/state.json update summary

**New Sections to Add**:
```markdown
<state_management>
  <archive_state>
    When archiving projects, update archive/state.json with:
    - Project metadata
    - Timeline information
    - Artifacts preserved
    - Impact metrics
  </archive_state>
  
  <maintenance_state>
    Update maintenance/state.json with:
    - Tasks removed count
    - Projects archived count
    - TODO.md metrics (before/after)
  </maintenance_state>
</state_management>
```

### 3. verification-specialist.md (Pending ⏸️)

**File**: `.opencode/agent/subagents/specialists/verification-specialist.md`  
**Current Behavior**:
- Verifies LEAN 4 proofs
- Creates verification reports
- Returns compliance scores

**Required Changes**:

1. **Output Section** (Lines 50-53)
   - Add maintenance/state.json update for findings
   - Reference maintenance-workflow.md

**New Sections to Add**:
```markdown
<maintenance_integration>
  <findings_tracking>
    Record all findings in maintenance/state.json:
    - Critical discrepancies
    - Warning-level issues
    - Info-level observations
  </findings_tracking>
  
  <metrics_contribution>
    Contribute to maintenance/state.json metrics:
    - Sorry counts
    - Axiom counts
    - Compliance scores
  </metrics_contribution>
</maintenance_integration>
```

---

## Command Updates

### 1. todo.md (Pending ⏸️)

**File**: `.opencode/command/todo.md`  
**Current Behavior**:
- Routes to reviewer with todo-maintenance scope
- Expects cleanup summary and status updates

**Required Changes**:

1. **Context Loaded** (Lines 11-14)
   - Add: `@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/processes/maintenance-workflow.md`
   - Add: `@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/templates/maintenance-report-template.md`

2. **Task Section** (Lines 16-32)
   - Update to reference maintenance-workflow.md
   - Update to reference archive/state.json instead of ARCHIVE_INDEX.md

3. **File Structure** (Lines 33-37)
   - Update archive reference to archive/state.json
   - Add maintenance/state.json reference

4. **Expected Output** (Lines 39-55)
   - Add state file update summaries
   - Add report path reference

**Updated Sections**:
```markdown
**Context Loaded:**
@/home/benjamin/Projects/ProofChecker/.opencode/specs/TODO.md
@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/standards/
@/home/benjamin/Projects/ProofChecker/.opencode/context/project/project-context.md
@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/processes/maintenance-workflow.md
@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/templates/maintenance-report-template.md

**File Structure:**
- Working TODO: .opencode/specs/TODO.md
- Project specs: .opencode/specs/{project-name}/
- Archive: .opencode/specs/archive/{project-name}/
- Archive State: .opencode/specs/archive/state.json
- Maintenance State: .opencode/specs/maintenance/state.json
- Status docs: Documentation/ProjectInfo/

**Expected Output:**
- **Cleanup Summary:** (as before)
- **Status Document Updates:** (as before)
- **State Updates:**
  * archive/state.json: {N} projects added
  * maintenance/state.json: Operation recorded
  * state.json: Summaries updated
- **Maintenance Report:** .opencode/specs/maintenance/report-YYYYMMDD.md
- **Maintenance Summary:** (as before)
```

### 2. review.md (Pending ⏸️)

**File**: `.opencode/command/review.md`  
**Current Behavior**:
- Routes to reviewer with review scope
- Expects analysis and verification reports

**Required Changes**:

1. **Context Loaded** (Lines 11-14)
   - Add: `@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/processes/maintenance-workflow.md`

2. **Expected Output** (Lines 28-34)
   - Add maintenance/state.json reference
   - Add report path reference

**Updated Sections**:
```markdown
**Context Loaded:**
@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/standards/lean4-style-guide.md
@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/standards/proof-conventions.md
@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/processes/end-to-end-proof-workflow.md
@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/processes/maintenance-workflow.md

**Expected Output:**
- Analysis report reference
- Verification report reference
- Updated TODO.md
- Maintenance state update
- Summary of key findings and recommendations
- Suggested next steps
```

---

## Report Standardization

### Current Report Names (Inconsistent)

```
.opencode/specs/maintenance/
├── maintenance-report-20251219.md      # Good format
├── codebase-scan-20251219.md           # Should be consolidated
├── todo-cleanup-20251219.md            # Should be consolidated
└── reports/
    └── maintenance-20251218.md         # Wrong location
```

### Target Report Names (Standardized)

```
.opencode/specs/maintenance/
├── report-20251219.md                  # Consolidated comprehensive report
├── report-20251218.md                  # Consolidated comprehensive report
└── state.json                          # Maintenance state
```

### Migration Steps

1. **Consolidate 20251219 Reports**:
   ```bash
   # Merge codebase-scan, todo-cleanup, maintenance-report into single report
   # Use maintenance-report-template.md structure
   # Save as report-20251219.md
   # Delete individual reports
   ```

2. **Move 20251218 Report**:
   ```bash
   # Move from reports/ to maintenance/
   mv .opencode/specs/maintenance/reports/maintenance-20251218.md \
      .opencode/specs/maintenance/report-20251218.md
   # Remove reports/ directory
   rmdir .opencode/specs/maintenance/reports/
   ```

3. **Update maintenance/state.json**:
   ```json
   {
     "operations": [
       {
         "operation_id": "maintenance-20251219",
         "artifacts": {
           "reports": ["report-20251219.md"]
         }
       },
       {
         "operation_id": "maintenance-20251218",
         "artifacts": {
           "reports": ["report-20251218.md"]
         }
       }
     ]
   }
   ```

---

## Testing Plan

### Test 1: State File Validation

**Objective**: Verify all state files are valid JSON with correct schema

**Steps**:
1. Validate JSON syntax:
   ```bash
   jq empty .opencode/specs/state.json
   jq empty .opencode/specs/archive/state.json
   jq empty .opencode/specs/maintenance/state.json
   ```
2. Verify required fields present
3. Verify timestamps in ISO 8601 format
4. Verify cross-references valid

**Expected**: All files valid, no errors

### Test 2: Archive Migration

**Objective**: Verify all projects migrated from ARCHIVE_INDEX.md

**Steps**:
1. Count projects in ARCHIVE_INDEX.md
2. Count projects in archive/state.json
3. Compare project numbers
4. Verify all metadata present

**Expected**: All projects migrated, counts match

### Test 3: Agent Integration

**Objective**: Verify agents can read/write state files

**Steps**:
1. Run /todo command
2. Verify maintenance/state.json updated
3. Verify archive/state.json updated if archiving
4. Verify report generated with correct name

**Expected**: All state files updated correctly

### Test 4: Report Generation

**Objective**: Verify reports use standard template

**Steps**:
1. Generate maintenance report
2. Verify uses maintenance-report-template.md structure
3. Verify all sections present
4. Verify naming convention followed

**Expected**: Report follows template, correct naming

### Test 5: Query Performance

**Objective**: Verify state files can be queried efficiently

**Steps**:
1. Run query examples from STATE_SCHEMA_GUIDE.md
2. Verify results correct
3. Measure query performance
4. Test search indices

**Expected**: All queries work, performance acceptable

---

## Migration Timeline

### Week 1 (Current - 2025-12-19)

**Completed** ✅:
- [x] Create state file schemas
- [x] Create documentation
- [x] Create templates and workflows
- [x] Create migration guide

**Remaining**:
- [ ] Migrate remaining 3 projects to archive/state.json
- [ ] Consolidate 20251219 reports
- [ ] Move 20251218 report

### Week 2 (2025-12-26)

**Planned**:
- [ ] Update reviewer.md agent
- [ ] Update todo-manager.md agent
- [ ] Update verification-specialist.md agent
- [ ] Test agent updates

### Week 3 (2026-01-02)

**Planned**:
- [ ] Update todo.md command
- [ ] Update review.md command
- [ ] Deprecate ARCHIVE_INDEX.md
- [ ] Test command updates

### Week 4 (2026-01-09)

**Planned**:
- [ ] Run full test suite
- [ ] Verify all migrations complete
- [ ] Update all documentation
- [ ] Mark implementation complete

---

## Success Criteria

### Phase 1: State Files (Completed ✅)
- [x] archive/state.json created with schema
- [x] maintenance/state.json created with schema
- [x] state.json updated with references
- [x] STATE_SCHEMA_GUIDE.md created
- [x] All schemas documented

### Phase 2: Templates & Workflows (Completed ✅)
- [x] maintenance-report-template.md created
- [x] maintenance-workflow.md created
- [x] MIGRATION.md created
- [x] All templates documented

### Phase 3: Migration (In Progress ⏳)
- [ ] All projects migrated to archive/state.json
- [ ] ARCHIVE_INDEX.md deprecated
- [ ] All reports standardized to report-YYYYMMDD.md
- [ ] All state files populated

### Phase 4: Agent Updates (Pending ⏸️)
- [ ] reviewer.md updated
- [ ] todo-manager.md updated
- [ ] verification-specialist.md updated
- [ ] All agents tested

### Phase 5: Command Updates (Pending ⏸️)
- [ ] todo.md updated
- [ ] review.md updated
- [ ] All commands tested

### Phase 6: Validation (Pending ⏸️)
- [ ] All tests passing
- [ ] All documentation updated
- [ ] Backward compatibility verified
- [ ] Implementation complete

---

## Rollback Plan

If issues arise during implementation:

### Rollback State Files
```bash
# Restore from git
git checkout HEAD -- .opencode/specs/state.json
git checkout HEAD -- .opencode/specs/archive/state.json
git checkout HEAD -- .opencode/specs/maintenance/state.json
```

### Rollback Agents
```bash
# Restore from git
git checkout HEAD -- .opencode/agent/subagents/reviewer.md
git checkout HEAD -- .opencode/agent/subagents/specialists/todo-manager.md
git checkout HEAD -- .opencode/agent/subagents/specialists/verification-specialist.md
```

### Rollback Commands
```bash
# Restore from git
git checkout HEAD -- .opencode/command/todo.md
git checkout HEAD -- .opencode/command/review.md
```

### Continue with Legacy Approach
- Keep using ARCHIVE_INDEX.md
- Keep using old report naming
- Investigate issues
- Retry implementation when ready

---

## Next Steps

### Immediate (This Week)
1. Migrate remaining 3 projects to archive/state.json
2. Consolidate 20251219 reports into single report-20251219.md
3. Move 20251218 report to standard location
4. Update maintenance/state.json with report references

### Short-Term (Next 2 Weeks)
5. Update reviewer.md agent
6. Update todo-manager.md agent
7. Update verification-specialist.md agent
8. Test agent updates with /todo command

### Medium-Term (Next 4 Weeks)
9. Update todo.md command
10. Update review.md command
11. Deprecate ARCHIVE_INDEX.md
12. Run full test suite

### Long-Term (Next 8 Weeks)
13. Monitor usage and gather feedback
14. Refine workflows based on experience
15. Consider additional automation
16. Document lessons learned

---

**Implementation Status**: In Progress (Phase 2 Complete)  
**Last Updated**: 2025-12-19  
**Next Review**: 2025-12-26
