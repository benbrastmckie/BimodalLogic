# Implementation Plan: Task #661

- **Task**: 661 - create_documentation_standards_file
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/661_create_documentation_standards_file/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a comprehensive documentation standards file that consolidates naming conventions, prohibited patterns, temporal language requirements, and directory purpose guidelines. The task description requests ALL_CAPS naming (`DOCUMENTATION_STANDARDS.md`) but research shows existing `core/standards/` convention uses lowercase kebab-case. This plan recommends following existing convention with `documentation-standards.md` unless user explicitly overrides. Additionally, fix corrupted content in `documentation.md` where duplicate sections appear starting at line 313.

### Research Integration

Key findings from research-001.md:
- File naming in `core/standards/` follows lowercase kebab-case (11 files, no exceptions)
- Corrupted `documentation.md` has duplicate "# Documentation Standards" section at line 313
- "Quick Reference" / "Quick Start" patterns appear 54+ times across codebase
- Clear docs/ vs context/ separation exists (user-facing vs AI agent knowledge)
- Present tense policy exists but is violated in context/README.md

## Goals & Non-Goals

**Goals**:
- Create new `documentation-standards.md` file with comprehensive standards
- Fix corrupted content in existing `documentation.md`
- Document file naming conventions (lowercase kebab-case for context/, README.md usage)
- Prohibit "Quick Start" and "Quick Reference" patterns with alternatives
- Codify present tense requirement with no historical language
- Clarify docs/ vs context/ directory purposes

**Non-Goals**:
- Mass cleanup of existing "Quick Reference" patterns (separate task)
- Deprecating `STANDARDS_QUICK_REF.md` in docs/ (separate task)
- Renaming existing files to match conventions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task requests ALL_CAPS but convention is lowercase | Medium | High | Follow existing convention; document rationale in plan |
| Removing corrupted content loses important info | Low | Low | Review both sections; preserve unique valuable content |
| New standards conflict with existing documentation.md | Medium | Medium | Position new file as specific naming/pattern standards; existing file covers general docs |

## Implementation Phases

### Phase 1: Create documentation-standards.md [NOT STARTED]

**Goal**: Create the new standards file with all required sections

**Tasks**:
- [ ] Create file at `.claude/context/core/standards/documentation-standards.md`
- [ ] Add file naming conventions section (lowercase kebab-case for context/, README.md)
- [ ] Add prohibited patterns section (Quick Start, Quick Reference, alternatives)
- [ ] Add temporal language section (present tense, no historical references)
- [ ] Add directory purpose section (docs/ vs context/ distinction)
- [ ] Add cross-references to related standards

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/core/standards/documentation-standards.md` - Create new file

**Verification**:
- File exists and follows kebab-case naming convention
- All five required topics are covered
- No emojis or prohibited patterns in the new file itself

---

### Phase 2: Fix corrupted documentation.md [NOT STARTED]

**Goal**: Remove duplicated/corrupted content from existing documentation.md

**Tasks**:
- [ ] Identify unique content in corrupted section (lines 313-473) worth preserving
- [ ] Remove duplicated "# Documentation Standards" section (lines 313-473)
- [ ] Verify remaining content (lines 1-312) is complete and coherent
- [ ] Add cross-reference to new documentation-standards.md

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/standards/documentation.md` - Remove lines 313-473

**Verification**:
- No duplicate section headers in documentation.md
- Only one "# Documentation Standards" at top
- Cross-reference to new file added

---

### Phase 3: Verification and Testing [NOT STARTED]

**Goal**: Ensure new standards are complete and consistent

**Tasks**:
- [ ] Verify documentation-standards.md contains all 5 required topics
- [ ] Verify no "Quick Start" or "Quick Reference" in the new file
- [ ] Verify present tense used throughout new file
- [ ] Verify file naming follows kebab-case
- [ ] Check cross-references resolve correctly

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- grep for prohibited patterns returns no matches
- All internal links resolve
- File passes quality checklist from documentation.md

## Testing & Validation

- [ ] `documentation-standards.md` exists at correct path
- [ ] File uses lowercase kebab-case naming
- [ ] No "Quick Start" or "Quick Reference" text in new file (verified with grep)
- [ ] Present tense used throughout (no "was", "previously", "changed from")
- [ ] `documentation.md` has only one top-level heading
- [ ] Cross-references between files work
- [ ] All five topics covered: naming conventions, prohibited patterns, present tense, directory purpose, README usage

## Artifacts & Outputs

- `.claude/context/core/standards/documentation-standards.md` - New standards file
- `.claude/context/core/standards/documentation.md` - Fixed (corruption removed)
- `specs/661_create_documentation_standards_file/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation causes issues:
1. Restore `documentation.md` from git: `git checkout HEAD -- .claude/context/core/standards/documentation.md`
2. Remove new file: `rm .claude/context/core/standards/documentation-standards.md`
3. Review research findings for alternative approach

If user requires ALL_CAPS naming:
1. Rename file to `DOCUMENTATION_STANDARDS.md`
2. Note the naming inconsistency with other `core/standards/` files
3. Consider creating task to standardize naming across directory
