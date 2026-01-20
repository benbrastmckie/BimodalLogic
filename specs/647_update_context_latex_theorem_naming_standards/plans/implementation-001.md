# Implementation Plan: Task #647

- **Task**: 647 - Update context files for LaTeX theorem naming and formatting standards
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/647_update_context_latex_theorem_naming_standards/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task documents four LaTeX formatting standards discovered in 04-Metalogic.tex NOTE: tags into the existing LaTeX context files. The research identified that these standards should be added to three existing files rather than creating new ones, following the principle of avoiding duplication. The four standards cover: (1) theorem name italics formatting, (2) definition ordering, (3) inline Lean theorem references in theorem environments, and (4) standardized code path formatting.

### Research Integration

From research-001.md:
- Four NOTE: tags analyzed from 04-Metalogic.tex (lines 109, 127, 154, 371)
- Target files identified: latex-style-guide.md, theorem-environments.md, cross-references.md
- Decision to add sections to existing files rather than create new file
- Decision NOT to update .claude/rules/latex.md (auto-loaded rules vs on-demand context)

## Goals & Non-Goals

**Goals**:
- Add "Theorem and Definition Naming" section to latex-style-guide.md
- Add "Lean Cross-Reference in Theorem Environment" section to theorem-environments.md
- Add "Code Path Formatting" section to cross-references.md
- Document the four standards with clear examples and rationale
- Maintain consistency with existing file structure and formatting

**Non-Goals**:
- Updating .claude/rules/latex.md (rules are auto-loaded; context is on-demand)
- Retroactively updating existing LaTeX documents to follow new standards
- Creating new context files (add to existing to avoid duplication)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| New sections conflict with existing content | Medium | Low | Carefully review existing sections before adding |
| Standards too prescriptive | Low | Low | Document as "recommended" with deprecated alternatives |
| Underscore escaping confusion | Low | Medium | Add explicit note about `\_` in code names |

## Implementation Phases

### Phase 1: Update latex-style-guide.md [COMPLETED]

**Goal**: Add "Theorem and Definition Naming" section covering named theorem formatting and definition ordering.

**Tasks**:
- [ ] Read current latex-style-guide.md structure
- [ ] Add new section after "Source File Formatting" section (around line 114)
- [ ] Include "Named Theorem Formatting" subsection with table showing prose, environment, and Lean reference formats
- [ ] Include "Definition Ordering" subsection with the rule about definitions before first use
- [ ] Add validation checklist item for theorem name formatting

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/latex/standards/latex-style-guide.md` - Add new section (~30 lines)

**Verification**:
- New section follows existing markdown formatting conventions
- Table format matches existing tables in file
- No duplicate content with other files

---

### Phase 2: Update theorem-environments.md [COMPLETED]

**Goal**: Add guidance on including Lean theorem names directly in theorem environment brackets.

**Tasks**:
- [ ] Read current theorem-environments.md structure
- [ ] Add "Lean Cross-Reference in Theorem Environment" subsection after "Theorem with Proof Reference" (around line 86)
- [ ] Show preferred pattern: `\begin{theorem}[\texttt{lean_name}]`
- [ ] Show deprecated (but acceptable) footnote pattern for backwards compatibility
- [ ] Explain benefits: pairs LaTeX numbering with Lean identifiers, removes footnote clutter

**Timing**: 25 minutes

**Files to modify**:
- `.claude/context/project/latex/patterns/theorem-environments.md` - Add new subsection (~25 lines)

**Verification**:
- Code examples use proper LaTeX escaping (`\_` for underscores)
- Clear distinction between preferred and deprecated patterns
- Integrates naturally with existing "Theorem with Proof Reference" section

---

### Phase 3: Update cross-references.md [COMPLETED]

**Goal**: Add comprehensive guidance on formatting Lean code paths and identifiers.

**Tasks**:
- [ ] Read current cross-references.md structure
- [ ] Add "Code Path Formatting" subsection within or after "Lean Cross-References" section (around line 88)
- [ ] Include table showing formatting for: directories, file paths, modules, definitions
- [ ] Add explicit note about underscore escaping (`\_`)
- [ ] Ensure consistency with existing `\leansrc` and `\leanref` macro documentation

**Timing**: 25 minutes

**Files to modify**:
- `.claude/context/project/latex/patterns/cross-references.md` - Add new subsection (~20 lines)

**Verification**:
- Table format consistent with existing Label Prefixes table
- Underscore escaping clearly documented
- No conflict with existing `\leansrc`/`\leanref` documentation

---

### Phase 4: Validation [IN PROGRESS]

**Goal**: Verify all additions are consistent and complete.

**Tasks**:
- [ ] Re-read all three modified files to verify formatting consistency
- [ ] Verify no duplicate content between files
- [ ] Verify all four NOTE: tag standards are documented:
  - Theorem name italics (latex-style-guide.md)
  - Definition ordering (latex-style-guide.md)
  - Lean theorem references (theorem-environments.md)
  - Lean directory formatting (cross-references.md)
- [ ] Verify underscore escaping is documented where code names appear

**Timing**: 10 minutes

**Files to modify**:
- None (read-only verification)

**Verification**:
- All four standards documented
- Consistent formatting across files
- No broken markdown

## Testing & Validation

- [ ] All four NOTE: tag standards have corresponding documentation
- [ ] No markdown syntax errors in modified files
- [ ] Tables render correctly (consistent column alignment)
- [ ] Code blocks have correct LaTeX syntax
- [ ] Underscore escaping (`\_`) documented in all relevant examples

## Artifacts & Outputs

- `.claude/context/project/latex/standards/latex-style-guide.md` (modified)
- `.claude/context/project/latex/patterns/theorem-environments.md` (modified)
- `.claude/context/project/latex/patterns/cross-references.md` (modified)
- `specs/647_update_context_latex_theorem_naming_standards/summaries/implementation-summary-{DATE}.md` (created on completion)

## Rollback/Contingency

All changes are additive (new sections to existing files). To rollback:
1. Use git to restore original versions of the three modified files
2. No other files or systems depend on these new sections

If partial implementation is needed:
- Each phase is independent and adds value on its own
- Phases can be completed in any order
- Partial completion still improves documentation
