# Implementation Plan: Update Context Verum/Falsum Notation

- **Task**: 823 - update_context_verum_falsum_notation
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/823_update_context_verum_falsum_notation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update .claude/context/ files and LaTeX notation to establish consistent terminology for verum/falsum in bilateral semantics. The research identified that bilateral semantics requires FOUR distinct constants (`\top`, `\bot`, `\Top`, `\Bot`) because the two orderings (ground and parthood) have different top/bottom elements. The verum (`\Top := \neg\bot`) and falsum (`\Bot := \neg\top`) are derived via negation.

### Research Integration

Key findings from research-001.md:
- IdentityAboutness.tex defines `\Top` (strikethrough top) and `\Bot` (strikethrough bot) symbols
- Verum = `\Top := \neg\bot` (top for parthood ordering)
- Falsum = `\Bot := \neg\top` (bottom for parthood ordering)
- Current ConstitutiveFoundation.tex conflates "Verum (Top)" and "Falsum (Bottom)" section headers

## Goals & Non-Goals

**Goals**:
- Add `\Top`, `\Bot`, `\ver`, `\fal` macros to logos-notation.sty
- Update LaTeX notation-conventions.md with four-element documentation
- Update Typst notation-conventions.md with verum/falsum distinction
- Rename ConstitutiveFoundation.tex section headers to clarify terminology

**Non-Goals**:
- Modifying Lean code (no Lean representation of verum/falsum yet)
- Changing IdentityAboutness.tex (source of truth, not modified)
- Adding new mathematical content to ConstitutiveFoundation.tex beyond section renaming

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Symbol collision with existing LaTeX packages | M | L | Test compilation after adding macros |
| Missing graphicx package for rotatebox | M | M | Add RequirePackage directive to logos-notation.sty |
| Confusion from terminology change | L | M | Add explanatory comments in notation files |

## Implementation Phases

### Phase 1: Add LaTeX Macros [COMPLETED]

**Goal**: Add `\Top`, `\Bot`, `\ver`, `\fal` macros to logos-notation.sty

**Tasks**:
- [ ] Read current logos-notation.sty to find insertion point
- [ ] Add graphicx package requirement if not present
- [ ] Add "Bilateral Top and Bottom" section with:
  - `\Top` (strikethrough top symbol)
  - `\Bot` (strikethrough bot, rotated \Top)
  - `\ver` alias for `\Top`
  - `\fal` alias for `\Bot`
- [ ] Add explanatory comments documenting two orderings

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/assets/logos-notation.sty` - Add new macro section

**Verification**:
- Run pdflatex on a test file using the new macros
- Verify symbols render correctly

---

### Phase 2: Update LaTeX Notation Conventions [COMPLETED]

**Goal**: Document the four-element verum/falsum system in LaTeX notation-conventions.md

**Tasks**:
- [ ] Read current notation-conventions.md structure
- [ ] Add new "Bilateral Top/Bottom Elements" section
- [ ] Document the four constants with table:
  - `\top` (top, primitive, ground ordering)
  - `\bot` (bottom, primitive, ground ordering)
  - `\ver`/`\Top` (verum, derived as `\neg\bot`, parthood ordering)
  - `\fal`/`\Bot` (falsum, derived as `\neg\top`, parthood ordering)
- [ ] Add usage guidance distinguishing standard vs bilateral contexts

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/project/latex/standards/notation-conventions.md` - Add bilateral section

**Verification**:
- Review section for clarity and completeness
- Ensure consistency with logos-notation.sty macros

---

### Phase 3: Update Typst Notation Conventions [COMPLETED]

**Goal**: Add verum/falsum distinction to Typst notation-conventions.md

**Tasks**:
- [ ] Read current Typst notation-conventions.md
- [ ] Update existing `$bot$` entry to clarify it is "bottom" not "falsum"
- [ ] Add note about bilateral semantics four-element distinction
- [ ] Document Typst equivalents for verum/falsum if applicable

**Timing**: 15 minutes

**Files to modify**:
- `.claude/context/project/typst/standards/notation-conventions.md` - Update truth value section

**Verification**:
- Review for consistency with LaTeX conventions

---

### Phase 4: Update ConstitutiveFoundation.tex Headers [COMPLETED]

**Goal**: Rename section headers to use correct terminology

**Tasks**:
- [ ] Read ConstitutiveFoundation.tex lines 359-385
- [ ] Rename `\subsubsection{Verum (Top)}` to `\subsubsection{Top Constant}`
- [ ] Rename `\subsubsection{Falsum (Bottom)}` to `\subsubsection{Bottom Constant}`
- [ ] Remove the NOTE tag at line 357 (task addressed)

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Rename section headers

**Verification**:
- Verify pdflatex compiles without errors
- Check table of contents reflects new section names

## Testing & Validation

- [ ] logos-notation.sty compiles without errors
- [ ] New macros `\Top`, `\Bot`, `\ver`, `\fal` render correctly
- [ ] ConstitutiveFoundation.tex compiles without errors
- [ ] Documentation is internally consistent across LaTeX and Typst conventions

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-20260203.md (upon completion)
- Modified files:
  - Theories/Logos/latex/assets/logos-notation.sty
  - .claude/context/project/latex/standards/notation-conventions.md
  - .claude/context/project/typst/standards/notation-conventions.md
  - Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex

## Rollback/Contingency

If symbol definitions cause compilation errors:
1. Remove the new macro section from logos-notation.sty
2. Revert section header changes in ConstitutiveFoundation.tex
3. Keep documentation changes (they don't affect compilation)
4. Investigate symbol conflicts with existing packages
