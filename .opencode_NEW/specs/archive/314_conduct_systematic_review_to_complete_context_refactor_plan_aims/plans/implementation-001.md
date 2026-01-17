# Implementation Plan: Complete Context Refactor Plan Execution

**Task**: 314 - Conduct systematic review to complete context refactor plan aims
**Created**: 2026-01-05
**Status**: [NOT STARTED]
**Estimated Effort**: 18-22 hours
**Complexity**: High
**Language**: meta
**Priority**: High

---

## Metadata

- **Task Number**: 314
- **Plan Version**: 1
- **Research Integrated**: Yes
- **Reports Integrated**:
  - research-001.md (2026-01-05): Systematic review of context refactor plan status
- **Dependencies**: None
- **Blocking**: None
- **Phase Count**: 7
- **Total Effort**: 20 hours

---

## Overview

### Problem Statement

The context refactor plan (specs/context-refactor-plan.md) was created on 2026-01-04 and updated on 2026-01-05, but **ZERO execution has occurred**. The current `.opencode/context/core/` directory structure remains unchanged from the "before" state, with 48 files across 5 directories instead of the planned 35 files across 6 directories.

**Critical Gaps**:
1. **Missing Architecture Documentation**: Both critical files (orchestration/architecture.md and formats/command-structure.md) documenting ProofChecker's three-layer delegation pattern do not exist
2. **No File Consolidation**: All 6 pairs of redundant files still exist (0% consolidation)
3. **No Naming Improvements**: All inconsistent file names remain unchanged
4. **No Directory Reorganization**: Original 5-directory structure unchanged
5. **No Reference Updates**: All @ references still point to old paths
6. **Unresolved Unintended Changes**: 6 files modified on 2026-01-05 require validation

### Research Integration

Research report (research-001.md) provides comprehensive analysis:

**Current State**:
- 48 files across 5 directories (schemas, standards, system, templates, workflows)
- 0 of 39 planned file operations completed
- 0% progress on all 6 implementation phases
- 2 critical architecture files missing
- 6 files with unintended changes requiring review

**Completed Related Work**:
- ✅ State.json Phase 1 & 2 optimizations (fully implemented)
- ✅ Command workflow updates (validation, routing, status)
- ✅ 1 obsolete file deleted (command-argument-handling.md)

**Recommended Approach**: Execute plan as-is with minor revisions for unintended changes validation

### Scope

**In Scope**:
1. Pre-refactor validation (resolve unintended changes)
2. Execute all 6 phases of context refactor plan
3. Create 2 critical architecture documentation files
4. Consolidate 48 files to 35 files (27% reduction)
5. Reorganize from 5 to 6 directories
6. Update all @ references across agent/command/context files
7. Preserve state.json optimizations

**Out of Scope**:
- New feature development
- Command behavior changes
- State.json schema modifications
- Meta-builder enhancements beyond architecture documentation

### Constraints

- Must preserve state.json Phase 1 & 2 optimizations
- Must maintain backward compatibility for all commands
- Must not break any @ references
- Must complete in single session to avoid partial state
- Must create git commits at key milestones

### Definition of Done

- [ ] All 6 unintended changes reviewed and resolved
- [ ] orchestration/architecture.md created (three-layer delegation pattern)
- [ ] formats/command-structure.md created (commands as agents)
- [ ] 35 files in 6 directories (orchestration, formats, standards, workflows, templates, schemas)
- [ ] All redundant files merged or deleted
- [ ] All file names follow {topic}-{type}.md convention
- [ ] All @ references updated to new paths
- [ ] All commands tested and working
- [ ] Context loads in <1 second
- [ ] Git commit created with refactor changes
- [ ] Documentation updated

---

## Goals and Non-Goals

### Goals

1. **Complete Context Refactor Execution**: Execute all 6 phases of the plan
2. **Create Architecture Documentation**: Document three-layer delegation pattern
3. **Eliminate Redundancy**: Consolidate 48 files to 35 files (27% reduction)
4. **Improve Organization**: Reorganize to 6 logical directories
5. **Ensure Consistency**: Standardize all file names
6. **Preserve Optimizations**: Maintain state.json performance improvements

### Non-Goals

1. Modify command behavior or workflows
2. Change state.json schema or structure
3. Refactor meta-builder implementation
4. Add new features or capabilities
5. Optimize context loading beyond file reduction

---

## Risks and Mitigations

### High-Risk Areas

**Risk 1: Broken References**
- **Impact**: Commands fail to load context files
- **Probability**: Medium
- **Mitigation**: Comprehensive reference update script with validation
- **Contingency**: Rollback to backup, fix references manually

**Risk 2: Unintended Changes Conflicts**
- **Impact**: Unknown state of 6 modified files
- **Probability**: Medium
- **Mitigation**: Review and test before refactor begins
- **Contingency**: Revert to known good state from git

**Risk 3: Content Loss During Merge**
- **Impact**: Important information lost
- **Probability**: Low
- **Mitigation**: Careful review of merged files, compare line counts
- **Contingency**: Restore from backup sources

### Medium-Risk Areas

**Risk 4: Context Loading Performance**
- **Impact**: Slower context loading
- **Probability**: Low
- **Mitigation**: Test loading time before and after
- **Contingency**: Optimize file organization

**Risk 5: Meta-Builder Integration**
- **Impact**: /meta command breaks or generates incorrect systems
- **Probability**: Low
- **Mitigation**: Create architecture.md early, test /meta after refactor
- **Contingency**: Update meta-builder context files

---

## Implementation Phases

### Phase 0: Pre-Refactor Validation (2 hours)

**Objective**: Resolve unintended changes and create clean baseline

**Tasks**:

1. **Review Unintended Changes** (1 hour):
   - Read specs/unintended-changes-report.md
   - Analyze 6 modified files:
     * High-risk: meta.md, task-creator.md, todo.md
     * Low-risk: review.md, reviewer.md, state-lookup.md
   - Test /meta, /task, /todo commands
   - Decision: keep, revert, or selectively revert

2. **Create Clean Baseline** (30 minutes):
   - Ensure all commands working correctly
   - Run basic smoke tests (/research, /plan, /implement)
   - Create git commit with clean state
   - Tag as "pre-context-refactor-314"

3. **Document Decisions** (30 minutes):
   - Record unintended changes resolution
   - Update implementation notes
   - Prepare for Phase 1

**Validation**:
- [ ] All 6 unintended changes reviewed
- [ ] All commands tested and working
- [ ] Git baseline created and tagged
- [ ] Ready to proceed with refactor

**Estimated Effort**: 2 hours

---

### Phase 1: Backup and Preparation (30 minutes)

**Objective**: Create backup and prepare new directory structure

**Tasks**:

1. **Create Backup** (10 minutes):
   ```bash
   cp -r .opencode/context/core .opencode/context/core.backup.$(date +%Y%m%d_%H%M%S)
   ```

2. **Create New Directory Structure** (10 minutes):
   ```bash
   mkdir -p .opencode/context/core.new/{orchestration,formats,standards,workflows,templates,schemas}
   ```

3. **Document Current References** (10 minutes):
   ```bash
   grep -r "@.opencode/context/core/" .opencode/agent/ > /tmp/context-refs-agents.txt
   grep -r "@.opencode/context/core/" .opencode/command/ > /tmp/context-refs-commands.txt
   grep -r "@.opencode/context/core/" .opencode/context/ > /tmp/context-refs-context.txt
   ```

**Validation**:
- [ ] Backup created successfully
- [ ] New directories exist
- [ ] Reference lists generated
- [ ] Current file count: 48 files

**Estimated Effort**: 30 minutes

---

### Phase 2: Create Architecture Documentation (3 hours)

**Objective**: Create critical architecture files FIRST before other changes

**Tasks**:

1. **Create orchestration/architecture.md** (2 hours):
   - Document three-layer delegation pattern
   - Layer 1: Orchestrator (pure router)
   - Layer 2: Command File (argument parsing agent)
   - Layer 3: Execution Subagent (work executor)
   - Key architectural principles
   - Comparison with OpenAgents
   - Critical for /meta command understanding
   - Include state.json optimization overview
   - ~600-800 lines

2. **Create formats/command-structure.md** (1 hour):
   - Document command files as agents with workflows
   - Command file anatomy (frontmatter, workflow_execution)
   - Why commands have workflows
   - Command file responsibilities
   - Common mistakes vs correct patterns
   - Template references
   - ~400-500 lines

**Validation**:
- [ ] architecture.md created and comprehensive
- [ ] command-structure.md created and clear
- [ ] Both files follow documentation standards
- [ ] Examples included for clarity

**Estimated Effort**: 3 hours

---

### Phase 3: Merge and Reorganize Files (8 hours)

**Objective**: Consolidate redundant files and reorganize into new structure

**Tasks**:

1. **Orchestration Directory** (2.5 hours):
   - MERGE orchestrator-design.md + orchestrator-guide.md → orchestration/orchestrator.md
   - MERGE routing-guide.md + routing-logic.md → orchestration/routing.md
   - MERGE delegation.md + delegation-guide.md → orchestration/delegation.md
   - MERGE validation-strategy.md + validation-rules.md → orchestration/validation.md
   - MERGE state-management.md + artifact-management.md → orchestration/state-management.md
     * Include state.json Phase 1 & 2 optimization documentation
     * Document read/write separation pattern
     * Reference state-lookup.md for query patterns
   - MOVE system/state-lookup.md → orchestration/state-lookup.md
   - EVALUATE workflows/sessions.md → orchestration/sessions.md (if needed)
   - **Result**: 8 files (includes 2 new from Phase 2)

2. **Formats Directory** (1.5 hours):
   - RENAME subagent-return-format.md → formats/subagent-return.md
   - COPY command-output.md → formats/command-output.md
   - RENAME plan.md → formats/plan-format.md
   - RENAME report.md → formats/report-format.md
   - RENAME summary.md → formats/summary-format.md
   - RENAME frontmatter-standard.md → formats/frontmatter.md
   - **Result**: 7 files (includes 1 new from Phase 2)

3. **Standards Directory** (1.5 hours):
   - MERGE code.md + patterns.md → standards/code-patterns.md
   - KEEP error-handling.md, git-safety.md, documentation.md
   - RENAME tests.md → standards/testing.md
   - RENAME xml-patterns.md → standards/xml-structure.md
   - RENAME tasks.md → standards/task-management.md
   - RENAME analysis.md → standards/analysis-framework.md
   - **Result**: 8 files

4. **Workflows Directory** (30 minutes):
   - KEEP command-lifecycle.md, status-transitions.md, task-breakdown.md
   - RENAME review.md → workflows/review-process.md
   - **Result**: 4 files

5. **Templates Directory** (30 minutes):
   - RENAME agent-templates.md → templates/agent-template.md
   - KEEP subagent-template.md, command-template.md, orchestrator-template.md
   - RENAME delegation-context-template.md → templates/delegation-context.md
   - KEEP state-template.json
   - **Result**: 6 files

6. **Schemas Directory** (15 minutes):
   - KEEP frontmatter-schema.json
   - MOVE templates/subagent-frontmatter-template.yaml → schemas/subagent-frontmatter.yaml
   - **Result**: 2 files

7. **Move Meta-Builder Files** (30 minutes):
   - CREATE .opencode/context/project/meta/ directory
   - MOVE standards/domain-patterns.md → project/meta/
   - MOVE standards/architecture-principles.md → project/meta/
   - MOVE templates/meta-guide.md → project/meta/
   - MOVE workflows/interview-patterns.md → project/meta/

8. **Delete Obsolete Files** (30 minutes):
   - DELETE standards/command-structure.md (redundant with template)
   - DELETE standards/commands.md (redundant with template)
   - DELETE standards/subagent-structure.md (redundant with template)
   - DELETE system/context-loading-strategy.md (merge into orchestrator.md)
   - DELETE system/self-healing-guide.md (obsolete)

**Validation**:
- [ ] All merged files created with complete content
- [ ] All renamed files in correct locations
- [ ] Meta-builder files moved to project/meta/
- [ ] Obsolete files deleted
- [ ] Total: 35 files in core/ (down from 48)
- [ ] No duplicate content

**Estimated Effort**: 8 hours

---

### Phase 4: Update References (3 hours)

**Objective**: Update all @ references to new paths

**Tasks**:

1. **Create Reference Update Script** (1 hour):
   ```bash
   #!/bin/bash
   # update-context-refs.sh
   
   declare -A ref_map=(
     ["standards/delegation.md"]="orchestration/delegation.md"
     ["workflows/delegation-guide.md"]="orchestration/delegation.md"
     ["system/orchestrator-design.md"]="orchestration/orchestrator.md"
     ["system/orchestrator-guide.md"]="orchestration/orchestrator.md"
     ["system/routing-guide.md"]="orchestration/routing.md"
     ["system/routing-logic.md"]="orchestration/routing.md"
     ["system/validation-strategy.md"]="orchestration/validation.md"
     ["system/validation-rules.md"]="orchestration/validation.md"
     ["system/state-management.md"]="orchestration/state-management.md"
     ["system/artifact-management.md"]="orchestration/state-management.md"
     ["system/state-lookup.md"]="orchestration/state-lookup.md"
     ["standards/subagent-return-format.md"]="formats/subagent-return.md"
     ["standards/plan.md"]="formats/plan-format.md"
     ["standards/report.md"]="formats/report-format.md"
     ["standards/summary.md"]="formats/summary-format.md"
     ["standards/frontmatter-standard.md"]="formats/frontmatter.md"
     ["standards/code.md"]="standards/code-patterns.md"
     ["standards/patterns.md"]="standards/code-patterns.md"
     ["standards/tests.md"]="standards/testing.md"
     ["standards/xml-patterns.md"]="standards/xml-structure.md"
     ["standards/tasks.md"]="standards/task-management.md"
     ["standards/analysis.md"]="standards/analysis-framework.md"
     ["workflows/review.md"]="workflows/review-process.md"
     ["templates/agent-templates.md"]="templates/agent-template.md"
     ["templates/delegation-context-template.md"]="templates/delegation-context.md"
   )
   
   for old_path in "${!ref_map[@]}"; do
     new_path="${ref_map[$old_path]}"
     echo "Updating: $old_path → $new_path"
     
     find .opencode/agent -name "*.md" -exec sed -i \
       "s|@.opencode/context/core/$old_path|@.opencode/context/core/$new_path|g" {} \;
     
     find .opencode/command -name "*.md" -exec sed -i \
       "s|@.opencode/context/core/$old_path|@.opencode/context/core/$new_path|g" {} \;
     
     find .opencode/context -name "*.md" -exec sed -i \
       "s|@.opencode/context/core/$old_path|@.opencode/context/core/$new_path|g" {} \;
   done
   ```

2. **Run Update Script** (30 minutes):
   ```bash
   chmod +x update-context-refs.sh
   ./update-context-refs.sh
   ```

3. **Verify Updates** (1.5 hours):
   - Check for remaining old references
   - Verify all new references resolve to existing files
   - Test context loading in orchestrator
   - Manual review of critical files

**Validation**:
- [ ] All references updated
- [ ] No broken references
- [ ] No old paths remain
- [ ] Context files load correctly

**Estimated Effort**: 3 hours

---

### Phase 5: Swap Directories and Test (2 hours)

**Objective**: Activate new structure and validate functionality

**Tasks**:

1. **Swap Directories** (5 minutes):
   ```bash
   mv .opencode/context/core .opencode/context/core.old
   mv .opencode/context/core.new .opencode/context/core
   ```

2. **Verify Structure** (10 minutes):
   ```bash
   tree .opencode/context/core
   ```

3. **Execute Test Matrix** (1.5 hours):
   
   | Test | Command | Expected Result |
   |------|---------|-----------------|
   | Orchestrator loads | /plan 196 | Plan created successfully |
   | Context loading | Check logs | No "file not found" errors |
   | Delegation works | /research 197 | Research report created |
   | Routing works | /implement 196 | Implementation executed |
   | Templates accessible | Create new agent | Template loads correctly |
   | State.json optimization | /implement 259 | Fast lookup (12ms) |
   | Meta-builder | /meta "test" | Architecture docs loaded |

4. **Performance Validation** (15 minutes):
   - Measure context loading time (<1 second)
   - Verify state.json optimization preserved
   - Check for any performance regressions

**Validation**:
- [ ] All commands work correctly
- [ ] No context loading errors
- [ ] All @ references resolve
- [ ] Templates load successfully
- [ ] No broken links
- [ ] Context loads in <1 second
- [ ] State.json optimization preserved

**Estimated Effort**: 2 hours

---

### Phase 6: Cleanup and Documentation (1.5 hours)

**Objective**: Remove old files and update documentation

**Tasks**:

1. **Remove Old Directory** (5 minutes):
   ```bash
   rm -rf .opencode/context/core.old
   ```

2. **Update Documentation** (1 hour):
   - Update .opencode/context/README.md with new structure
   - Document new naming conventions
   - Add migration notes
   - Update architecture references

3. **Create Git Commit** (15 minutes):
   ```bash
   git add .opencode/context/core/
   git add .opencode/agent/
   git add .opencode/command/
   git commit -m "task 314: complete context refactor - 48→35 files, add architecture docs"
   ```

4. **Final Validation** (10 minutes):
   - Verify git commit includes all changes
   - Check for any uncommitted files
   - Verify system stable

**Validation**:
- [ ] Old directory removed
- [ ] Documentation updated
- [ ] Git commit created
- [ ] System stable
- [ ] All tests passing

**Estimated Effort**: 1.5 hours

---

### Phase 7: Post-Refactor Validation (1 hour)

**Objective**: Comprehensive validation and meta-builder testing

**Tasks**:

1. **Regression Testing** (30 minutes):
   - Test state.json optimization performance
   - Test command workflow updates
   - Test dual-mode /revise routing
   - Test status validation
   - Verify no functionality broken

2. **Meta-Builder Validation** (30 minutes):
   - Test /meta command with new architecture
   - Verify architecture.md loaded correctly
   - Ensure command-structure.md accessible
   - Test system generation (if applicable)

**Validation**:
- [ ] All regression tests pass
- [ ] Meta-builder understands new architecture
- [ ] No performance regressions
- [ ] All optimizations preserved

**Estimated Effort**: 1 hour

---

## Testing and Validation

### Pre-Implementation Testing

1. **Unintended Changes Validation**:
   - Test /meta, /task, /todo commands
   - Verify state.json optimization works
   - Check for any regressions

### During Implementation Testing

1. **Phase 2 Validation**:
   - Review architecture.md for completeness
   - Review command-structure.md for clarity
   - Verify examples are accurate

2. **Phase 3 Validation**:
   - Compare merged file line counts
   - Verify no content loss
   - Check for duplicate content

3. **Phase 4 Validation**:
   - Test reference updates incrementally
   - Verify no broken references
   - Check context loading

### Post-Implementation Testing

1. **Functional Testing**:
   - Execute test matrix (Phase 5)
   - Test all workflow commands
   - Verify meta-builder integration

2. **Performance Testing**:
   - Measure context loading time
   - Verify state.json optimization
   - Check for regressions

3. **Integration Testing**:
   - Test complete workflows
   - Verify artifact creation
   - Check status updates

### Acceptance Testing

- [ ] All 35 files in correct locations
- [ ] All redundant files eliminated
- [ ] All file names consistent
- [ ] All @ references updated
- [ ] All commands working
- [ ] Context loads <1 second
- [ ] Architecture docs complete
- [ ] Meta-builder functional
- [ ] Git commit created
- [ ] Documentation updated

---

## Artifacts and Outputs

### Primary Artifacts

1. **orchestration/architecture.md** (NEW):
   - Three-layer delegation pattern documentation
   - ~600-800 lines
   - Critical for meta-builder

2. **formats/command-structure.md** (NEW):
   - Command files as agents documentation
   - ~400-500 lines
   - Critical for system understanding

3. **Refactored Context Structure**:
   - 35 files in 6 directories
   - 27% reduction from 48 files
   - Improved organization and naming

### Supporting Artifacts

1. **Reference Update Script**:
   - update-context-refs.sh
   - Automated reference updates

2. **Migration Documentation**:
   - Updated .opencode/context/README.md
   - Migration notes
   - Naming conventions

3. **Git Commit**:
   - Complete refactor changes
   - Tagged for easy rollback

---

## Rollback/Contingency

### Rollback Triggers

1. Broken references preventing command execution
2. Content loss during merge
3. Performance regression >20%
4. Meta-builder integration failure
5. Critical functionality broken

### Rollback Procedure

1. **Immediate Rollback**:
   ```bash
   mv .opencode/context/core .opencode/context/core.failed
   mv .opencode/context/core.old .opencode/context/core
   ```

2. **Restore References**:
   ```bash
   git checkout .opencode/agent/
   git checkout .opencode/command/
   ```

3. **Analyze Failure**:
   - Review error logs
   - Identify missing/broken files
   - Document issues

4. **Fix and Retry**:
   - Address identified issues
   - Re-run affected phases
   - Re-test

### Backup Strategy

- Backup created in Phase 1
- Git baseline tagged in Phase 0
- Old directory preserved until Phase 6
- Can restore from any point

---

## Success Metrics

### Quantitative Metrics

| Metric | Before | After | Target |
|--------|--------|-------|--------|
| Total files | 48 | 35 | 35 (27% reduction) |
| Redundant files | 6 pairs | 0 | 0 (100% elimination) |
| Directories | 5 | 6 | 6 (better organization) |
| Naming consistency | ~60% | 100% | 100% |
| Context load time | ~1s | <1s | <1s |
| Architecture docs | 0 | 2 | 2 (critical files) |

### Qualitative Metrics

- [ ] Single source of truth for each concept
- [ ] Clear naming and logical grouping
- [ ] No broken references
- [ ] Meta-builder understands architecture
- [ ] State.json optimizations preserved
- [ ] All commands working correctly

---

## Dependencies and Blockers

### Dependencies

- None (can start immediately after Phase 0)

### Potential Blockers

1. **Unintended Changes**: Must resolve before starting
2. **Git Conflicts**: Must have clean working directory
3. **Time Constraints**: Requires 20 hours of focused work

### Mitigation

- Complete Phase 0 validation first
- Ensure clean git state
- Schedule dedicated time block

---

## Notes

### Key Decisions

1. **Execute Plan As-Is**: Research recommends proceeding with original plan
2. **Create Architecture Docs First**: Phase 2 before other changes
3. **Preserve State.json Optimizations**: Critical requirement
4. **Single Session Execution**: Avoid partial state

### Lessons Learned (Post-Implementation)

- To be filled after implementation

### Future Improvements

- Quarterly context audits to prevent bloat
- Automated reference validation
- Context usage analytics

---

**Plan Status**: [NOT STARTED]
**Next Action**: Execute Phase 0 (Pre-Refactor Validation)
