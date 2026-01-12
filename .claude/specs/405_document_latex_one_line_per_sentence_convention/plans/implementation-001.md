# Implementation Plan: Task #405

**Task**: Document LaTeX one-line-per-sentence convention
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

Add comprehensive documentation for the "one sentence per line" (semantic linefeeds) convention to the project's LaTeX context files. This involves updating the existing style guide with a new "Source File Formatting" section and creating a new rules file that triggers automatically when editing `.tex` files.

## Phases

### Phase 1: Update LaTeX Style Guide

**Status**: [COMPLETED]

**Objectives**:
1. Add "Source File Formatting" section to latex-style-guide.md
2. Document one-sentence-per-line rule with rationale
3. Include clause-break guidelines for long sentences
4. Provide pass/fail examples

**Files to modify**:
- `.claude/context/project/latex/standards/latex-style-guide.md` - Add new section

**Steps**:
1. Read current latex-style-guide.md to understand structure
2. Insert new "## Source File Formatting" section after "## Formatting Rules"
3. Add subsections:
   - "### Semantic Linefeeds" - Explain the convention with rationale
   - Pass/fail examples showing correct sentence breaks
   - Guidelines for breaking long sentences at clause boundaries
4. Update validation checklist with formatting requirements

**Verification**:
- New section is properly integrated with existing content
- Examples are clear and follow the convention
- No broken markdown formatting

---

### Phase 2: Create LaTeX Rules File

**Status**: [NOT STARTED]

**Objectives**:
1. Create `.claude/rules/latex.md` with frontmatter triggering on `**/*.tex` paths
2. Include quick-reference formatting rules
3. Match the style of `lean4.md` for consistency

**Files to modify**:
- `.claude/rules/latex.md` - New file

**Steps**:
1. Create new file with YAML frontmatter: `paths: "**/*.tex"`
2. Add "# LaTeX Development Rules" header
3. Add "## Source File Formatting" section with:
   - One sentence per line rule
   - Clause-break guidelines
   - Quick reference table
4. Add "## Common Patterns" section for formatting commands
5. Add "## Validation Checklist" for quick checks

**Verification**:
- Frontmatter triggers on .tex file paths
- Content is comprehensive but concise
- Style matches lean4.md pattern

---

### Phase 3: Update LaTeX README

**Status**: [NOT STARTED]

**Objectives**:
1. Add reference to new rules file and formatting convention
2. Ensure discoverability of the new documentation

**Files to modify**:
- `.claude/context/project/latex/README.md` - Add reference

**Steps**:
1. Read current README.md structure
2. Add reference to formatting convention in "## LaTeX-Specific Files" section under Standards
3. Add note in "## When to Load" section about formatting enforcement

**Verification**:
- README accurately references new content
- Formatting convention is discoverable from README

---

## Dependencies

- None (documentation-only task)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Inconsistency with existing examples | Low | Review all examples in style guide for compliance |
| Over-verbose documentation | Low | Keep rules concise with good examples |

## Success Criteria

- [ ] latex-style-guide.md has "Source File Formatting" section with semantic linefeeds
- [ ] `.claude/rules/latex.md` exists with `paths: "**/*.tex"` trigger
- [ ] README.md references the new formatting documentation
- [ ] All pass/fail examples correctly demonstrate the convention
- [ ] Downstream tasks (406, 407) can reference this documentation

## Rollback Plan

If implementation causes issues:
1. Revert to previous versions of modified files via git
2. All changes are additive (new sections, new files) so removal is straightforward
