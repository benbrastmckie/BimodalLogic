# Implementation Plan: Task #663 (v002)

- **Task**: 663 - archive_stale_research_fix_plan_documents
- **Status**: [IMPLEMENTING]
- **Effort**: 0.75 hours
- **Priority**: Medium
- **Dependencies**: Task 661 (documentation-standards.md)
- **Research Inputs**: specs/663_archive_stale_research_fix_plan_documents/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Notes (v002)

This revision incorporates Task 664 (Remove STANDARDS_QUICK_REF.md) into Task 663 since:
- Both tasks involve deleting stale/obsolete documents from `.claude/docs/`
- Task 664 has the same dependency (Task 661) as Task 663
- Combining them reduces overhead and context-switching
- STANDARDS_QUICK_REF.md (11.5KB) is a "quick reference" pattern that violates documentation standards from Task 661

## Overview

Delete five stale documents from `.claude/docs/` that have been superseded by context files, addressed by previous tasks, or violate documentation standards. Research confirmed that all valuable content from these documents already exists in `.claude/context/` files, and no extraction is needed. This revision adds STANDARDS_QUICK_REF.md from Task 664.

### Research Integration

Research report (research-001.md) findings for original 4 files:
- All four documents are stale (research artifacts, historical fix plans, or superseded issue docs)
- Valuable content already exists in context/ files (thin-wrapper-skill.md, system-overview.md)
- Only reference needing update is README.md documentation map
- Archive references in specs/archive/ are historical and do not need updating

Task 664 addition:
- STANDARDS_QUICK_REF.md is a "quick reference" pattern prohibited by documentation-standards.md
- No references to this file exist in the codebase (verified via grep)
- Content should be in authoritative sources (context files already cover standards)

## Goals & Non-Goals

**Goals**:
- Delete four stale documents from `.claude/docs/` (original Task 663 scope)
- Delete STANDARDS_QUICK_REF.md from `.claude/docs/` (Task 664 scope)
- Update README.md to remove broken documentation map references
- Verify no active references remain (archive references acceptable)
- Mark Task 664 as completed when Task 663 completes

**Non-Goals**:
- Extract content to context files (research confirmed content already exists)
- Update archived task references (historical context is acceptable)
- Create archive copies (research determined deletion is appropriate)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Delete useful debugging commands | Low | Low | Commands are CLI-specific; can be re-documented if needed |
| Loss of token budget analysis | Low | Low | Numbers are historical; can be re-measured if optimization needed |
| Broken link in README.md | Medium | High | Update README.md to remove reference (Phase 2) |
| Missing content extraction | Low | Low | Research thoroughly verified all content exists in context/ |
| STANDARDS_QUICK_REF content loss | Low | Low | Standards documented in documentation-standards.md |

## Implementation Phases

### Phase 1: Delete Stale Documents [COMPLETED]

**Goal**: Remove five stale documents from `.claude/docs/`

**Tasks**:
- [ ] Delete `.claude/docs/research-skill-agent-contexts.md` (201 lines - raw research artifact)
- [ ] Delete `.claude/docs/skills-vs-agents-context-behavior.md` (601 lines - distilled guidance, content exists in context/)
- [ ] Delete `.claude/docs/memory-leak-fix-plan.md` (381 lines - historical fix plan, Task 614 addressed)
- [ ] Delete `.claude/docs/architecture/orchestrator-workflow-execution-issue.md` (165 lines - superseded architecture)
- [ ] Delete `.claude/docs/STANDARDS_QUICK_REF.md` (11.5KB - "quick reference" pattern violates standards)

**Timing**: 5 minutes

**Files to modify**:
- `.claude/docs/research-skill-agent-contexts.md` - DELETE
- `.claude/docs/skills-vs-agents-context-behavior.md` - DELETE
- `.claude/docs/memory-leak-fix-plan.md` - DELETE
- `.claude/docs/architecture/orchestrator-workflow-execution-issue.md` - DELETE
- `.claude/docs/STANDARDS_QUICK_REF.md` - DELETE

**Verification**:
- Files no longer exist at specified paths
- `ls .claude/docs/` shows reduced file count

---

### Phase 2: Update README.md [COMPLETED]

**Goal**: Remove broken references from documentation map

**Tasks**:
- [ ] Edit `.claude/docs/README.md` to remove reference to `orchestrator-workflow-execution-issue.md`
- [ ] Edit `.claude/docs/README.md` to remove reference to `STANDARDS_QUICK_REF.md` if present
- [ ] Verify documentation map structure remains valid

**Timing**: 5 minutes

**Files to modify**:
- `.claude/docs/README.md` - Remove lines referencing deleted files

**Verification**:
- README.md no longer references deleted files
- Documentation map structure remains valid markdown

---

### Phase 3: Verify No Broken References [COMPLETED]

**Goal**: Confirm no active references to deleted files

**Tasks**:
- [ ] Grep for references to deleted filenames in non-archive files
- [ ] Verify any found references are in archive/ (acceptable) or report as issues

**Timing**: 5 minutes

**Files to modify**:
- None expected (references in archive/ are acceptable)

**Verification**:
- No active (non-archive) files reference deleted documents
- Or, if found, document for follow-up

---

### Phase 4: Mark Task 664 Completed [COMPLETED]

**Goal**: Update state.json and TODO.md to mark Task 664 as completed

**Tasks**:
- [ ] Update state.json: set Task 664 status to "completed", add completion_summary
- [ ] Update TODO.md: change Task 664 status marker to [COMPLETED]
- [ ] Add note that work was completed as part of Task 663

**Timing**: 5 minutes

**Files to modify**:
- `specs/state.json` - Update Task 664 status
- `specs/TODO.md` - Update Task 664 status marker

**Verification**:
- Task 664 status is "completed" in state.json
- Task 664 shows [COMPLETED] in TODO.md

## Testing & Validation

- [ ] All five target files deleted
- [ ] README.md updated without syntax errors
- [ ] Grep for deleted filenames returns only archive references
- [ ] Task 664 marked as completed
- [ ] `git status` shows expected changes

## Artifacts & Outputs

- plans/implementation-001.md (superseded)
- plans/implementation-002.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (created on completion)

## Rollback/Contingency

If deletion causes unexpected issues:
1. Use `git checkout HEAD~1 -- .claude/docs/` to restore deleted files
2. Re-evaluate which files to keep based on new findings
3. Files are in git history and can always be recovered
