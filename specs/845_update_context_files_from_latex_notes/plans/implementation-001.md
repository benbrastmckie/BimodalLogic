# Implementation Plan: Task #845

- **Task**: 845 - update_context_files_from_latex_notes
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/845_update_context_files_from_latex_notes/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update three context files to document two LaTeX conventions identified by NOTE: tags in `02-ConstitutiveFoundation.tex`: (1) standardized placement of `\leansrc` references at end of sections with `\noindent` prefix, and (2) use of `\set{}` macro for set notation instead of raw `\{ \}` braces.

### Research Integration

Research report (research-001.md) confirmed:
- `\leansrc` macro exists in `notation-standards.sty` but placement convention not documented
- `\set{}` macro exists in `logos-notation.sty` but not exposed in context files
- Three files identified for updates: cross-references.md, latex-style-guide.md, latex.md

## Goals & Non-Goals

**Goals**:
- Document the `\leansrc` reference placement standard (end of sections, `\noindent` prefix)
- Document the `\set{}` macro convention in context files
- Add validation checklist items to latex.md rules
- Ensure agents can apply these conventions when working with LaTeX files

**Non-Goals**:
- Modifying actual LaTeX source files to apply these conventions
- Creating new macros or modifying .sty files
- Comprehensive LaTeX style guide revision

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Documentation inconsistent with existing patterns | M | L | Review existing sections before adding new content |
| Changes conflict with other context file updates | L | L | Small, targeted additions minimize conflict surface |

## Implementation Phases

### Phase 1: Update cross-references.md [COMPLETED]

**Goal**: Add section documenting `\leansrc` reference placement standard.

**Tasks**:
- [ ] Read current cross-references.md structure
- [ ] Add new subsection "Lean Source Reference Placement" after line 88 (after "Module Reference")
- [ ] Include rules: use `\noindent`, place at end of section, include only when relevant
- [ ] Provide example showing pattern after definition environment
- [ ] Verify content integrates with existing Lean Cross-References section

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/latex/patterns/cross-references.md` - Add new subsection

**Verification**:
- New section follows existing markdown style
- Example is syntactically correct LaTeX
- Rules are clear and actionable

---

### Phase 2: Update latex-style-guide.md [COMPLETED]

**Goal**: Document `\set{}` macro convention for set notation.

**Tasks**:
- [ ] Read current latex-style-guide.md structure
- [ ] Add new subsection "Set Notation" in appropriate location (after line 172, before File Organization)
- [ ] Document that `\set{}` macro should be used instead of raw `\{ \}` braces
- [ ] Provide good/bad examples showing both patterns
- [ ] Include rationale: consistency and easier maintenance
- [ ] Add to Validation Checklist at end of file

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/latex/standards/latex-style-guide.md` - Add set notation section and checklist item

**Verification**:
- New section follows document structure
- Examples are syntactically correct LaTeX
- Validation checklist item is actionable

---

### Phase 3: Update latex.md rules [COMPLETED]

**Goal**: Add validation checklist items for both conventions.

**Tasks**:
- [ ] Read current latex.md rules structure
- [ ] Add to existing Validation Checklist section (around line 93):
  - Use `\set{}` macro for set notation (not `\{ \}`)
  - Lean source references placed at end of relevant sections with `\noindent`
- [ ] Ensure checklist items are concise and actionable

**Timing**: 15 minutes

**Files to modify**:
- `.claude/rules/latex.md` - Add two checklist items

**Verification**:
- Checklist items follow existing format
- Both items reference conventions documented in context files

---

### Phase 4: Verification [COMPLETED]

**Goal**: Validate all changes are consistent and complete.

**Tasks**:
- [ ] Re-read all three modified files
- [ ] Verify cross-references between documents are accurate
- [ ] Confirm no duplicate or conflicting guidance exists
- [ ] Validate markdown formatting is correct

**Timing**: 15 minutes

**Verification**:
- All three files compile/render correctly
- No broken internal references
- Conventions are consistently described across files

## Testing & Validation

- [ ] cross-references.md contains new "Lean Source Reference Placement" section
- [ ] latex-style-guide.md contains new "Set Notation" section
- [ ] latex.md validation checklist includes both new items
- [ ] All markdown formatting is valid
- [ ] No conflicting guidance between files

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-20260203.md (after completion)

## Rollback/Contingency

If changes introduce inconsistencies:
1. Git revert the commit containing these changes
2. Review research report recommendations
3. Revise plan with corrected approach
