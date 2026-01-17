# Implementation Plan: Task #563

- **Task**: 563 - Investigate Empty Directory Creation in specs/
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/563_investigate_empty_directory_creation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task fixes eager directory creation that violates the lazy directory creation rule documented in state-management.md. Research identified two primary violation locations: the `/task` command (lines 62-65) and `meta-builder-agent.md` (lines 331 and 483). The fix removes `mkdir -p` steps from task creation and ensures directories are only created when first artifacts are written.

### Research Integration

Key findings from research-001.md:
- Root cause: `/task` command creates directories at task creation time (step 5)
- Secondary violation: `meta-builder-agent.md` also creates directories eagerly
- 20+ empty directories currently exist in specs/
- Fix is straightforward: remove the `mkdir -p` steps

## Goals & Non-Goals

**Goals**:
- Remove eager directory creation from `/task` command
- Remove eager directory creation from `meta-builder-agent.md`
- Update documentation to clarify lazy creation requirements
- Clean up existing empty directories

**Non-Goals**:
- Changing how agents create directories when writing artifacts (this is correct behavior)
- Adding linting or automated enforcement (can be separate task)
- Modifying archive operations (directories needed for moves)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing workflows | Low | Low | Agents already create subdirs when writing artifacts |
| Task path references become invalid | Low | Low | TODO.md entries don't depend on directory existence |
| Clean command removes wanted dirs | Low | Low | No legitimate use case for empty task directories |

## Implementation Phases

### Phase 1: Remove Eager Directory Creation from task.md [COMPLETED]

**Goal**: Eliminate the `mkdir -p` step from the task creation workflow

**Tasks**:
- [ ] Edit `.claude/commands/task.md` to remove lines 62-65 (step 5: Create task directory)
- [ ] Update step 8 output to remove "Path: specs/{N}_{SLUG}/" line
- [ ] Update the Constraints section scope list to remove "mkdir only" reference

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/task.md` - Remove step 5 and update output format

**Verification**:
- Step 5 no longer exists in task.md
- Output section no longer references task path
- File still has valid structure and numbered steps are sequential

---

### Phase 2: Remove Eager Directory Creation from meta-builder-agent.md [COMPLETED]

**Goal**: Eliminate directory creation from interview and prompt modes

**Tasks**:
- [ ] Edit `.claude/agents/meta-builder-agent.md` to remove line 330 (`mkdir -p "specs/${next_num}_${slug}"`)
- [ ] Edit `.claude/agents/meta-builder-agent.md` to remove line 482 (`mkdir -p specs/{N}_{slug}`)
- [ ] Update Stage 5 header to reflect artifact creation only, not directory creation

**Timing**: 20 minutes

**Files to modify**:
- `.claude/agents/meta-builder-agent.md` - Remove mkdir commands in Stages 6 and 5

**Verification**:
- No `mkdir -p specs/` patterns remain in the file (except artifact-specific subdirs)
- File structure and stage numbering remain valid
- Grep confirms removal: `grep "mkdir.*specs/" .claude/agents/meta-builder-agent.md` returns no results

---

### Phase 3: Update state-management.md Documentation [IN PROGRESS]

**Goal**: Add explicit guidance against eager directory creation

**Tasks**:
- [ ] Add explicit "DO NOT" guidance to Directory Creation section
- [ ] Clarify that directories are created by artifact-writing agents, not task creation commands

**Timing**: 15 minutes

**Files to modify**:
- `.claude/rules/state-management.md` - Enhance Directory Creation section

**Verification**:
- Documentation clearly states when directories should NOT be created
- Examples show correct lazy creation pattern

---

### Phase 4: Clean Up Existing Empty Directories [NOT STARTED]

**Goal**: Remove all empty directories from specs/

**Tasks**:
- [ ] Verify empty directories to be removed (dry run)
- [ ] Execute cleanup command: `find specs/ -type d -empty -delete`
- [ ] Verify no legitimate directories were removed

**Timing**: 10 minutes

**Files to modify**:
- None (directory deletion only)

**Verification**:
- `find specs/ -type d -empty` returns no results after cleanup
- Active task directories with artifacts remain intact

---

### Phase 5: Verification and Summary [NOT STARTED]

**Goal**: Confirm all fixes are applied correctly

**Tasks**:
- [ ] Search for remaining `mkdir.*specs/` patterns that don't include artifact subdirs
- [ ] Verify no empty directories exist
- [ ] Create implementation summary

**Timing**: 15 minutes

**Files to modify**:
- Create `specs/563_investigate_empty_directory_creation/summaries/implementation-summary-{DATE}.md`

**Verification**:
- `grep -rn "mkdir.*-p.*specs/" .claude/ | grep -v "reports/\|plans/\|summaries/"` returns no results
- `find specs/ -type d -empty | wc -l` returns 0
- Implementation summary documents all changes made

## Testing & Validation

- [ ] Verify no `mkdir -p specs/{N}_{SLUG}` patterns exist in task creation paths
- [ ] Verify artifact-creating agents still create correct subdirectories
- [ ] Verify no empty directories remain in specs/
- [ ] Verify existing task workflows still function correctly

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (completion summary)

## Rollback/Contingency

If changes cause issues:
1. Revert task.md changes: `git checkout HEAD~1 -- .claude/commands/task.md`
2. Revert meta-builder-agent.md: `git checkout HEAD~1 -- .claude/agents/meta-builder-agent.md`
3. Recreate any directories needed by active tasks manually

The changes are low-risk because:
- Git does not track empty directories
- Agents already create subdirectories when writing artifacts
- No existing workflows depend on empty parent directories existing
