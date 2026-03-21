# Implementation Plan: Task #821

- **Task**: 821 - fix_constitutive_foundation_latex_issues
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/821_fix_constitutive_foundation_latex_issues/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Address 10 FIX tags in `02-ConstitutiveFoundation.tex` by adding explanatory remarks, using defined notation macros consistently, formally defining terms like v-variant, and restructuring sections for consistency.
The changes are additive (remarks) or reformatting; no theoretical content is deleted.
Research report provides concrete LaTeX snippets for each fix.

### Research Integration

- Research report `research-001.md` analyzed all 10 FIX tags with specific recommendations and LaTeX code snippets
- Available notation macros identified: `\possible`, `\compatible`, `\connected`, `\worldstates`, `\necessary`, `\maxcompat`, `\nullstate`, `\fullstate`
- Confirmed `\nverifies` and `\nfalsifies` macros may need verification in `logos-notation.sty`

## Goals & Non-Goals

**Goals**:
- Address all 10 FIX tags with appropriate content
- Use defined notation macros consistently where available
- Add explanatory remarks for key philosophical concepts (haecceity, hyperintensionality)
- Formally define v-variant assignment
- Restructure Top/Bottom into separate subsubsections
- Maintain semantic linefeed formatting (one sentence per line)

**Non-Goals**:
- Major theoretical changes to the semantics
- Restructuring beyond what FIX tags specify
- Adding new definitions beyond what is needed for clarity

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Notation macros undefined | Medium | Low | Check macros compile before finalizing |
| Cross-reference breaks | Low | Medium | Run pdflatex twice to resolve references |
| Document length increase | Low | Medium | Remarks are brief; ~200 lines total |
| Semantic linefeed violations | Low | Medium | Review each edit for one-sentence-per-line |

## Implementation Phases

### Phase 1: Notation and Primitives Fixes [COMPLETED]

**Goal**: Address FIX tags related to notation consistency and the primitives list

**Tasks**:
- [x] Line 21: Verify universal quantifier placement in primitives list, add existential quantifier for completeness
- [x] Line 114: Replace verbose `\mathsf{X}` forms with defined macros in State Modality Definitions (Definition 2.4)
- [x] Verify `\nverifies` and `\nfalsifies` macros exist in `logos-notation.sty`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Lines 21-33 (primitives), Lines 116-127 (state modality)
- `Theories/Logos/latex/logos-notation.sty` - Check for existing macros

**Verification**:
- Compile document successfully with `pdflatex`
- No undefined control sequence errors

---

### Phase 2: Formal Definitions [COMPLETED]

**Goal**: Add formal definitions for v-variant and constant substitution remark

**Tasks**:
- [x] Line 220: Add remark about constant substitution following Definition 2.11
- [x] Line 225: Replace informal v-variant definition (Definition 2.12) with formal cases-based definition

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Lines 218-230 (Variable Assignment section)

**Verification**:
- Document compiles successfully
- New definitions render correctly in PDF

---

### Phase 3: Explanatory Remarks [COMPLETED]

**Goal**: Add explanatory remarks for philosophical concepts and clarifications

**Tasks**:
- [x] Line 161: Add remark about haecceities and modal profiles before Definition 2.8
- [x] Line 248: Expand opening text of Verification and Falsification section with hyperintensionality elaboration
- [x] Line 270: Add notation convention for quantifier variable binding
- [x] Line 435: Add remark distinguishing propositional from sentential operators

**Timing**: 1 hour

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Lines 161, 248-250, 270, 435

**Verification**:
- Document compiles successfully
- Remarks render correctly with proper LaTeX environments
- Cross-references work (if any added)

---

### Phase 4: Section Restructuring [COMPLETED]

**Goal**: Split Top/Bottom section and integrate lattice definitions with task constraints

**Tasks**:
- [x] Line 285: Divide Top and Bottom into two separate subsubsections (Verum and Falsum)
- [x] Line 95: Add reference note pointing to Section 2.5 for lattice operations with task constraints (or add brief integration text)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Lines 95-106 (lattice remark), Lines 285-296 (Top/Bottom section)

**Verification**:
- Document compiles successfully
- Section structure matches other connective sections (Negation, Conjunction, etc.)

---

### Phase 5: Final Verification and Cleanup [COMPLETED]

**Goal**: Remove FIX tags, verify compilation, and ensure consistency

**Tasks**:
- [x] Remove all 10 FIX comment tags from the document
- [x] Run `pdflatex` twice to resolve cross-references
- [x] Check for overfull hboxes or warnings
- [x] Verify semantic linefeed formatting throughout modified sections

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - All FIX comment lines

**Verification**:
- No FIX tags remain in document
- Document compiles without errors or significant warnings
- PDF renders correctly with all new content

---

## Testing & Validation

- [ ] `pdflatex 02-ConstitutiveFoundation.tex` completes without errors
- [ ] All notation macros resolve (no undefined control sequences)
- [ ] Cross-references resolve (run pdflatex twice)
- [ ] No overfull hboxes exceeding tolerance
- [ ] Visual inspection of PDF for correct rendering of new remarks and definitions
- [ ] Grep for remaining FIX tags returns empty

## Artifacts & Outputs

- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Updated with all fixes
- `specs/821_fix_constitutive_foundation_latex_issues/plans/implementation-001.md` - This plan
- `specs/821_fix_constitutive_foundation_latex_issues/summaries/implementation-summary-20260203.md` - Completion summary

## Rollback/Contingency

If implementation causes issues:
1. Git revert to pre-implementation commit
2. Review research report recommendations for alternative approaches
3. If macro issues, check `logos-notation.sty` for correct definitions
4. If cross-reference issues, verify label names match conventions
