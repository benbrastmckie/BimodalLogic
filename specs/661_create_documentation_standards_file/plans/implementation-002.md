# Implementation Plan: Task #661 (Revised)

- **Task**: 661 - create_documentation_standards_file
- **Status**: [NOT STARTED]
- **Version**: 002
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/661_create_documentation_standards_file/reports/research-001.md
- **Previous Plan**: implementation-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Summary

**Key changes from v001**:
1. **Naming convention clarified**: Use kebab-case.md for all documentation in `.claude/` (both docs/ and context/)
2. **README.md standard**: ALL_CAPS for README files only, required in all subdirectories of docs/
3. **Reference standard**: Incorporate patterns from `/home/benjamin/Projects/ProofChecker/docs/development/DIRECTORY_README_STANDARD.md`

**Preserved from v001**:
- Fix corrupted documentation.md (lines 313-473)
- Prohibition of "Quick Start" / "Quick Reference" patterns
- Present tense requirement
- docs/ vs context/ directory distinction

## Overview

Create a comprehensive documentation standards file at `.claude/context/core/standards/documentation-standards.md` (kebab-case naming) that specifies:

1. **File naming conventions**: kebab-case.md for all documentation files in `.claude/`
2. **README.md requirements**: ALL_CAPS `README.md` required in all subdirectories of `.claude/docs/`
3. **Prohibited patterns**: No "Quick Start" or "Quick Reference" sections
4. **Temporal language**: Present tense only, no historical references
5. **Directory purpose**: Clear distinction between docs/ (user-facing) vs context/ (AI agent knowledge)

Additionally, fix the corrupted/duplicated content in existing `documentation.md`.

### Research Integration

Key findings from research-001.md (preserved):
- Corrupted `documentation.md` has duplicate "# Documentation Standards" section at line 313
- "Quick Reference" / "Quick Start" patterns appear 54+ times across codebase
- Clear docs/ vs context/ separation exists (user-facing vs AI agent knowledge)
- Present tense policy exists but is violated in context/README.md

New input from user revision:
- Reference: `/home/benjamin/Projects/ProofChecker/docs/development/DIRECTORY_README_STANDARD.md`
- Pattern: kebab-case for content files, ALL_CAPS for README.md only
- Requirement: README.md in all subdirectories of docs/

## Goals & Non-Goals

**Goals**:
- Create new `documentation-standards.md` file with comprehensive standards
- Fix corrupted content in existing `documentation.md`
- Document file naming conventions (kebab-case.md for all files in `.claude/`)
- Establish README.md requirement for all docs/ subdirectories
- Prohibit "Quick Start" and "Quick Reference" patterns with alternatives
- Codify present tense requirement with no historical language
- Clarify docs/ vs context/ directory purposes

**Non-Goals**:
- Mass cleanup of existing "Quick Reference" patterns (separate task - Task 664)
- Deprecating `STANDARDS_QUICK_REF.md` in docs/ (Task 664)
- Renaming existing files to match conventions
- Creating missing README.md files in docs/ subdirectories (could be follow-up task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Existing files violate new kebab-case standard | Low | Medium | Standards apply to new files; existing grandfathered or cleanup tasks created |
| docs/ subdirectories missing README.md | Medium | High | Document requirement; create follow-up task for compliance |
| Removing corrupted content loses important info | Low | Low | Review both sections; preserve unique valuable content |

## Implementation Phases

### Phase 1: Create documentation-standards.md [NOT STARTED]

**Goal**: Create the new standards file with all required sections including revised naming conventions

**Tasks**:
- [ ] Create file at `.claude/context/core/standards/documentation-standards.md`
- [ ] Add file naming conventions section:
  - kebab-case.md for all documentation files in `.claude/`
  - Examples: `documentation-standards.md`, `error-handling.md`, `task-management.md`
  - Exception: README.md uses ALL_CAPS (only this file)
- [ ] Add README.md requirement section:
  - Required in all subdirectories of `.claude/docs/`
  - Follow patterns from DIRECTORY_README_STANDARD.md (navigation-focused, lightweight)
  - Template guidance for different directory types
- [ ] Add prohibited patterns section (Quick Start, Quick Reference, alternatives)
- [ ] Add temporal language section (present tense, no historical references)
- [ ] Add directory purpose section (docs/ vs context/ distinction)
- [ ] Add cross-references to related standards

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/core/standards/documentation-standards.md` - Create new file

**Content outline**:
```markdown
# Documentation Standards

## File Naming Conventions

### General Rule
All documentation files in `.claude/` use **lowercase kebab-case** with `.md` extension.

**Examples**:
- `documentation-standards.md` (correct)
- `DOCUMENTATION_STANDARDS.md` (incorrect)
- `documentation_standards.md` (incorrect - underscores)
- `DocumentationStandards.md` (incorrect - PascalCase)

### README.md Exception
`README.md` files use ALL_CAPS naming. This is the **only** exception to kebab-case.

## README.md Requirements

### docs/ Subdirectories
Every subdirectory of `.claude/docs/` must contain a `README.md` file.

**Purpose**: Navigation guide and organizational documentation
**Style**: Lightweight, navigation-focused (see DIRECTORY_README_STANDARD.md patterns)
**Content**: Brief purpose, file listing with descriptions, related links

### context/ Subdirectories
README.md files are optional in `.claude/context/` subdirectories.

**When to include**: Directories with 3+ files or complex organization
**When to omit**: Single-purpose directories, self-explanatory structures

## Prohibited Document Patterns

### "Quick Start" Sections
Do not include "Quick Start" sections in documentation.

**Why**: Encourages incomplete understanding; users skip to quick start and miss context
**Alternative**: Structured introductions with progressive complexity

### "Quick Reference" Documents
Do not create standalone quick reference documents or sections.

**Why**: Creates maintenance burden; information becomes stale
**Alternative**: Summary tables within authoritative documents, decision trees

## Temporal Language Requirements

### Present Tense Only
Write all documentation in present tense.

**Do**:
- "The system validates input..."
- "This function returns..."
- "Users configure..."

**Don't**:
- "The system was changed to validate..."
- "Previously, this function returned..."
- "Users used to configure..."

### No Historical References
Do not include version history, migration notes, or "what changed" content.

**Don't**:
- Version History sections
- "Changed in v2.0" notes
- Migration guides within standards documents
- References to "the old system" or "legacy behavior"

## Directory Purpose

### docs/ Directory
User-facing guides and documentation.

**Audience**: Human users, developers, contributors
**Content**: Installation guides, how-to guides, examples, troubleshooting
**Style**: User-friendly, step-by-step, explanatory
**README.md**: Required in all subdirectories

### context/ Directory
AI agent knowledge and standards.

**Audience**: AI agents (Claude Code)
**Content**: Standards, schemas, patterns, domain knowledge
**Style**: Technical, precise, machine-parseable
**README.md**: Optional (include when helpful for navigation)
```

**Verification**:
- File exists and follows kebab-case naming convention
- All five required topics are covered
- README.md requirement clearly documented
- No emojis or prohibited patterns in the new file itself

---

### Phase 2: Fix corrupted documentation.md [NOT STARTED]

**Goal**: Remove duplicated/corrupted content from existing documentation.md

**Tasks**:
- [ ] Read current content of documentation.md
- [ ] Identify unique content in corrupted section (lines 313-473) worth preserving
- [ ] Remove duplicated "# Documentation Standards" section (lines 313-473)
- [ ] Verify remaining content (lines 1-312) is complete and coherent
- [ ] Add cross-reference to new documentation-standards.md

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/standards/documentation.md` - Remove lines 313-473, add cross-reference

**Verification**:
- No duplicate section headers in documentation.md
- Only one "# Documentation Standards" at top
- Cross-reference to new file added
- Content is coherent without removed section

---

### Phase 3: Verification and Testing [NOT STARTED]

**Goal**: Ensure new standards are complete and consistent

**Tasks**:
- [ ] Verify documentation-standards.md contains all 5 required topics:
  1. File naming conventions (kebab-case, README.md exception)
  2. README.md requirements (required in docs/ subdirs)
  3. Prohibited patterns (Quick Start, Quick Reference)
  4. Temporal language (present tense, no history)
  5. Directory purpose (docs/ vs context/)
- [ ] Verify no "Quick Start" or "Quick Reference" in the new file
- [ ] Verify present tense used throughout new file
- [ ] Verify file naming follows kebab-case
- [ ] Check cross-references resolve correctly
- [ ] List docs/ subdirectories that need README.md (for follow-up task if needed)

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- grep for prohibited patterns returns no matches in new file
- All internal links resolve
- File passes quality checklist from documentation.md

## Testing & Validation

- [ ] `documentation-standards.md` exists at `.claude/context/core/standards/documentation-standards.md`
- [ ] File uses lowercase kebab-case naming
- [ ] README.md exception documented clearly
- [ ] docs/ subdirectory README.md requirement documented
- [ ] No "Quick Start" or "Quick Reference" text in new file (verified with grep)
- [ ] Present tense used throughout (no "was", "previously", "changed from")
- [ ] `documentation.md` has only one top-level heading
- [ ] Cross-references between files work
- [ ] All five topics covered with user's revised requirements

## Artifacts & Outputs

- `.claude/context/core/standards/documentation-standards.md` - New standards file
- `.claude/context/core/standards/documentation.md` - Fixed (corruption removed)
- `specs/661_create_documentation_standards_file/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation causes issues:
1. Restore `documentation.md` from git: `git checkout HEAD -- .claude/context/core/standards/documentation.md`
2. Remove new file: `rm .claude/context/core/standards/documentation-standards.md`
3. Review revision requirements for alternative approach
