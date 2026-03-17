# Implementation Plan: Task #984

- **Task**: 984 - review_docs_remove_claude_dir_references
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: Research identified 7 files with 18 `.claude/` references
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Review and revise all documentation to remove references to the `.claude/` directory (now gitignored), while preserving references to Claude Code itself. The research phase identified 7 documentation files with 18 total references that need updating or removal. This plan organizes the work by priority level to address critical broken links first.

### Research Integration

Research identified:
- 7 documentation files requiring updates
- 18 total `.claude/` path references
- 1 large export file (75K lines) recommended for removal
- Priority-based categorization based on user impact

## Goals & Non-Goals

**Goals**:
- Remove all internal `.claude/` path references from documentation
- Fix broken links caused by gitignored directory
- Preserve "Claude Code" product name mentions
- Preserve references to external Claude Code documentation URLs
- Remove obsolete large export file

**Non-Goals**:
- Modifying any files in the `.claude/` directory itself
- Changing Claude Code installation or setup procedures (except removing .claude-specific steps)
- Adding new documentation content

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missing a reference | L | L | Final grep verification in Phase 4 |
| Breaking valid external URLs | M | L | Verify URLs contain "claude.ai" or "anthropic.com" before preserving |
| Removing too much content | M | L | Review each removal for context before deleting |

## Implementation Phases

### Phase 1: Critical Documentation Updates [NOT STARTED]

- **Dependencies:** None
- **Goal**: Fix the most visible documentation issues - main docs README and Claude Code installation guide

**Tasks**:
- [ ] Update `docs/README.md` - Remove callout box at lines 5-6 pointing to `.claude/README.md`
- [ ] Update `docs/installation/CLAUDE_CODE.md`:
  - [ ] Remove Section 4 "Set Up the Agent System" (lines 143-182)
  - [ ] Remove Agent System Docs link (line 328)
  - [ ] Verify remaining content still flows logically

**Timing**: 20 minutes

**Files to modify**:
- `docs/README.md` - Remove 2-line callout box
- `docs/installation/CLAUDE_CODE.md` - Remove section and link (~45 lines total)

**Verification**:
- No `.claude/` references remain in either file
- Documents still read coherently
- Section numbering/flow adjusted if needed

---

### Phase 2: Moderate Priority Updates [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal**: Fix documentation with multiple broken links - TTS/STT guide and directory standard

**Tasks**:
- [ ] Update `docs/tts-stt-integration.md`:
  - [ ] Fix/remove hook configuration reference at line 92
  - [ ] Fix/remove hook configuration reference at line 265
  - [ ] Fix/remove hook configuration references at lines 287-288
  - [ ] Ensure content still makes sense without internal paths
- [ ] Update `docs/development/DIRECTORY_README_STANDARD.md`:
  - [ ] Remove broken link at line 4
  - [ ] Remove broken link at line 183
  - [ ] Remove broken link at line 345

**Timing**: 20 minutes

**Files to modify**:
- `docs/tts-stt-integration.md` - Update 4 references
- `docs/development/DIRECTORY_README_STANDARD.md` - Remove 3 broken links

**Verification**:
- No `.claude/` references remain in either file
- Hook configuration guidance is still useful (or section removed if not)
- Link text adjusted to remove dead links

---

### Phase 3: Minor Updates and Large File Removal [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal**: Handle remaining minor updates and remove obsolete export file

**Tasks**:
- [ ] Update `docs/development/LEAN_STYLE_GUIDE.md`:
  - [ ] Remove broken link at line 188
- [ ] Update `docs/project-info/MAINTENANCE.md`:
  - [ ] Remove or rewrite spec query section (lines 221-233 reference nonexistent `.claude/specs`)
- [ ] Remove `docs/claude-directory-export.md`:
  - [ ] This is a 75K-line export snapshot of the now-gitignored `.claude/` directory
  - [ ] No longer useful, remove entirely

**Timing**: 15 minutes

**Files to modify**:
- `docs/development/LEAN_STYLE_GUIDE.md` - Remove 1 broken link
- `docs/project-info/MAINTENANCE.md` - Update ~12 lines
- `docs/claude-directory-export.md` - Delete file

**Verification**:
- No `.claude/` references remain in LEAN_STYLE_GUIDE.md or MAINTENANCE.md
- Export file successfully deleted
- `git status` shows file as deleted

---

### Phase 4: Verification and Final Checks [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal**: Verify all `.claude/` references removed from documentation

**Tasks**:
- [ ] Run comprehensive grep to find any remaining `.claude/` references in docs/:
  ```bash
  grep -rn "\.claude/" docs/ --include="*.md"
  ```
- [ ] Verify no false positives were removed (check for "Claude Code" product mentions)
- [ ] Review changes for coherence
- [ ] Create implementation summary

**Timing**: 10 minutes

**Verification**:
- Grep returns no results (or only acceptable external URL references)
- All modified files are syntactically valid markdown
- No broken internal documentation links created

## Testing & Validation

- [ ] `grep -rn "\.claude/" docs/ --include="*.md"` returns empty (or only external URLs)
- [ ] All modified markdown files render correctly
- [ ] No orphaned sections or broken internal links
- [ ] "Claude Code" product name mentions preserved

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (after completion)

## Rollback/Contingency

- All changes can be reverted via `git checkout docs/` if needed
- Individual file changes are independent and can be reverted separately
- Keep backup of `claude-directory-export.md` content in git history (normal git rm, not purge)
