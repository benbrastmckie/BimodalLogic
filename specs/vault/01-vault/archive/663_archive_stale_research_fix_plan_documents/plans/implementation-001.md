# Implementation Plan: Task #663

- **Task**: 663 - archive_stale_research_fix_plan_documents
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Priority**: Medium
- **Dependencies**: Task 661 (documentation-standards.md)
- **Research Inputs**: specs/663_archive_stale_research_fix_plan_documents/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Delete four stale documents from `.claude/docs/` that have been superseded by context files or addressed by previous tasks. Research confirmed that all valuable content from these documents already exists in `.claude/context/` files, and no extraction is needed. The only reference requiring update is in `.claude/docs/README.md`.

### Research Integration

Research report (research-001.md) findings:
- All four documents are stale (research artifacts, historical fix plans, or superseded issue docs)
- Valuable content already exists in context/ files (thin-wrapper-skill.md, system-overview.md)
- Only reference needing update is README.md documentation map
- Archive references in specs/archive/ are historical and do not need updating

## Goals & Non-Goals

**Goals**:
- Delete four stale documents from `.claude/docs/`
- Update README.md to remove broken documentation map reference
- Verify no active references remain (archive references acceptable)

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

## Implementation Phases

### Phase 1: Delete Stale Documents [NOT STARTED]

**Goal**: Remove four stale documents from `.claude/docs/`

**Tasks**:
- [ ] Delete `.claude/docs/research-skill-agent-contexts.md` (201 lines - raw research artifact)
- [ ] Delete `.claude/docs/skills-vs-agents-context-behavior.md` (601 lines - distilled guidance, content exists in context/)
- [ ] Delete `.claude/docs/memory-leak-fix-plan.md` (381 lines - historical fix plan, Task 614 addressed)
- [ ] Delete `.claude/docs/architecture/orchestrator-workflow-execution-issue.md` (165 lines - superseded architecture)

**Timing**: 5 minutes

**Files to modify**:
- `.claude/docs/research-skill-agent-contexts.md` - DELETE
- `.claude/docs/skills-vs-agents-context-behavior.md` - DELETE
- `.claude/docs/memory-leak-fix-plan.md` - DELETE
- `.claude/docs/architecture/orchestrator-workflow-execution-issue.md` - DELETE

**Verification**:
- Files no longer exist at specified paths
- `ls .claude/docs/` shows reduced file count

---

### Phase 2: Update README.md [NOT STARTED]

**Goal**: Remove broken reference from documentation map

**Tasks**:
- [ ] Edit `.claude/docs/README.md` to remove reference to `orchestrator-workflow-execution-issue.md`
- [ ] Verify documentation map structure remains valid

**Timing**: 5 minutes

**Files to modify**:
- `.claude/docs/README.md` - Remove line referencing deleted file

**Verification**:
- README.md no longer references `orchestrator-workflow-execution-issue.md`
- Documentation map structure remains valid markdown

---

### Phase 3: Verify No Broken References [NOT STARTED]

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

## Testing & Validation

- [ ] All four target files deleted
- [ ] README.md updated without syntax errors
- [ ] Grep for deleted filenames returns only archive references
- [ ] `git status` shows expected changes

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (created on completion)

## Rollback/Contingency

If deletion causes unexpected issues:
1. Use `git checkout HEAD~1 -- .claude/docs/` to restore deleted files
2. Re-evaluate which files to keep based on new findings
3. Files are in git history and can always be recovered
