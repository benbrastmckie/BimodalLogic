# Implementation Plan: Task #725

- **Task**: 725 - update_docs_readme_and_rename_architecture
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Priority**: medium
- **Dependencies**: None
- **Research Inputs**: None (git status provided in delegation context)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task updates the .claude/docs/ documentation to reflect recently deleted files and renames .claude/ARCHITECTURE.md to .claude/README.md while maintaining content and improving cross-linking. The deleted files include troubleshooting and migration documentation that is no longer relevant.

## Goals & Non-Goals

**Goals**:
- Remove references to deleted files (troubleshooting/, migrations/) from .claude/docs/README.md
- Rename .claude/ARCHITECTURE.md to .claude/README.md
- Update all references to ARCHITECTURE.md throughout .claude/ to point to README.md
- Improve cross-linking between documentation files

**Non-Goals**:
- Restructuring the entire documentation hierarchy
- Creating new documentation content
- Modifying documentation content beyond reference updates

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken internal links after rename | M | M | Systematic grep for all ARCHITECTURE.md references before and after |
| Missing reference updates | M | L | Use grep to find all references, verify each update |
| Circular reference issues | L | L | Review cross-links for logical flow |

## Implementation Phases

### Phase 1: Update .claude/docs/README.md [COMPLETED]

**Goal**: Remove references to deleted files and update documentation map

**Tasks**:
- [ ] Remove troubleshooting/ section from documentation map (lines 32-33)
- [ ] Remove migrations/ section from documentation map (lines 34-35)
- [ ] Remove Troubleshooting section (lines 77-79)
- [ ] Update file tree to remove troubleshooting/ and migrations/ directories

**Timing**: 0.25 hours

**Files to modify**:
- `.claude/docs/README.md` - Remove deleted file references

**Verification**:
- All references to troubleshooting/status-conflicts.md removed
- All references to migrations/001-openagents-migration/ removed
- Documentation map accurately reflects current directory structure

---

### Phase 2: Rename ARCHITECTURE.md to README.md [IN PROGRESS]

**Goal**: Rename the main architecture file while preserving content

**Tasks**:
- [ ] Create .claude/README.md with contents of .claude/ARCHITECTURE.md
- [ ] Delete .claude/ARCHITECTURE.md
- [ ] Verify .claude/README.md is readable and properly formatted

**Timing**: 0.25 hours

**Files to modify**:
- `.claude/ARCHITECTURE.md` - Delete (after copying content)
- `.claude/README.md` - Create with ARCHITECTURE.md content

**Verification**:
- .claude/README.md exists with full content from ARCHITECTURE.md
- .claude/ARCHITECTURE.md no longer exists
- Content is identical except for any necessary header updates

---

### Phase 3: Update References in .claude/ Files [NOT STARTED]

**Goal**: Update all references to ARCHITECTURE.md to point to README.md

**Tasks**:
- [ ] Update .claude/CLAUDE.md (2 references)
- [ ] Update .claude/docs/README.md (3 references)
- [ ] Update .claude/docs/architecture/system-overview.md (1 reference)
- [ ] Update .claude/docs/guides/user-installation.md (1 reference)
- [ ] Update .claude/context/project/meta/meta-guide.md (3 references)
- [ ] Update .claude/context/project/repo/project-overview.md (2 references)
- [ ] Update .claude/context/project/logic/domain/task-semantics.md (1 reference)
- [ ] Update .claude/commands/meta.md (1 reference)
- [ ] Update .claude/agents/meta-builder-agent.md (1 reference)

**Timing**: 0.75 hours

**Files to modify**:
- `.claude/CLAUDE.md` - Update @.claude/ARCHITECTURE.md references
- `.claude/docs/README.md` - Update ../ARCHITECTURE.md references
- `.claude/docs/architecture/system-overview.md` - Update ../../ARCHITECTURE.md reference
- `.claude/docs/guides/user-installation.md` - Update ../../ARCHITECTURE.md reference
- `.claude/context/project/meta/meta-guide.md` - Update ARCHITECTURE.md references
- `.claude/context/project/repo/project-overview.md` - Update ARCHITECTURE.md references
- `.claude/context/project/logic/domain/task-semantics.md` - Update ARCHITECTURE.md reference
- `.claude/commands/meta.md` - Update ARCHITECTURE.md reference
- `.claude/agents/meta-builder-agent.md` - Update ARCHITECTURE.md reference

**Verification**:
- `grep -r "ARCHITECTURE.md" .claude/` returns no results
- All links point to README.md with correct relative paths
- No broken links in documentation

---

### Phase 4: Improve Cross-Linking [NOT STARTED]

**Goal**: Ensure documentation files reference each other appropriately

**Tasks**:
- [ ] Add link from .claude/README.md to .claude/docs/README.md (if not present)
- [ ] Verify .claude/docs/README.md links to both CLAUDE.md and the new README.md
- [ ] Ensure consistent navigation headers across documentation files
- [ ] Verify all Related Documentation sections are up to date

**Timing**: 0.25 hours

**Files to modify**:
- `.claude/README.md` - Add link to docs/README.md if missing
- `.claude/docs/README.md` - Verify Core References section accuracy

**Verification**:
- Navigation between .claude/README.md, .claude/CLAUDE.md, and .claude/docs/README.md is bidirectional
- Related Documentation sections are consistent and accurate

## Testing & Validation

- [ ] Run `grep -r "ARCHITECTURE.md" .claude/` to verify no stale references
- [ ] Run `grep -r "troubleshooting/" .claude/docs/` to verify deleted file references removed
- [ ] Run `grep -r "migrations/" .claude/docs/` to verify deleted file references removed
- [ ] Verify .claude/README.md exists and contains full architecture documentation
- [ ] Verify all markdown links are valid (relative paths resolve correctly)

## Artifacts & Outputs

- Updated `.claude/docs/README.md` - Documentation hub without deleted file references
- New `.claude/README.md` - Renamed from ARCHITECTURE.md
- Updated cross-references across 9 files in .claude/

## Rollback/Contingency

If implementation fails:
1. Restore .claude/ARCHITECTURE.md from git history
2. Revert changes to .claude/docs/README.md
3. Revert reference updates in other files
4. Use `git checkout HEAD -- .claude/` to restore all files if needed
