# Implementation Plan: Task #428

**Task**: Complete TODOs in Bimodal syntax LaTeX file
**Version**: 001
**Created**: 2026-01-12
**Language**: latex

## Overview

Complete two TODOs in `Theories/Bimodal/latex/subfiles/01-Syntax.tex`:

1. **TODO 1 (line 99)**: Change `\swap` notation from parenthesized form `\swap(\varphi)` to prefix form `\swap\varphi` (like negation `\lneg\varphi`)

2. **TODO 2 (line 101)**: Restructure the Temporal Swap definition to more clearly present it as structural induction

## Phases

### Phase 1: Update swap notation throughout document

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Change all occurrences of `\swap(...)` to `\swap ...` (prefix without parentheses)
2. Update the definition text to reflect the new notation style

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/01-Syntax.tex`

**Steps**:
1. Update definition text on line 104: Change "The function $\swap : \texttt{Formula} \to \texttt{Formula}$" to use a clearer notation description
2. Replace all `\swap(\varphi)` with `\swap\varphi` in the definition (lines 108-126)
3. Replace all `\swap(\psi)` with `\swap\psi` if any exist
4. Update the Involution theorem (line 130) from `\swap(\swap(\varphi))` to `\swap\swap\varphi`
5. Remove the TODO comments (lines 99-101)

**Verification**:
- Build the LaTeX file to confirm no errors
- Visual check that the notation is consistent with negation style

---

### Phase 2: Restructure definition as clear structural induction

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Reorganize the Temporal Swap definition to follow a standard structural induction format
2. Make the inductive structure explicit and parallel to the Formula definition

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/01-Syntax.tex`

**Steps**:
1. Restructure the definition to match the Formula inductive definition order:
   - First: atom case (base)
   - Second: bottom case (base)
   - Third: implication case (inductive - propositional)
   - Fourth: necessity case (inductive - modal)
   - Fifth: all_past case (inductive - temporal)
   - Sixth: all_future case (inductive - temporal)
2. Use consistent labeling that mirrors the Formula definition structure
3. Consider using a single aligned block or itemize for all cases rather than separate "Base cases", "Propositional case", etc. sections
4. Add a brief sentence noting that the definition follows the structure of Formula

**Verification**:
- Build the LaTeX file to confirm no errors
- Visual check that the inductive structure is clear and mirrors Formula definition

---

## Dependencies

None - this is a self-contained LaTeX documentation task.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Notation change may need macro update | Low | Check if `\swap` macro exists in logos-notation.sty; if so, update there |
| Structural reorg may break page layout | Low | Build and review PDF output |

## Success Criteria

- [ ] All `\swap(...)` occurrences use prefix notation `\swap ...`
- [ ] Temporal Swap definition clearly presents structural induction
- [ ] Both TODO comments removed
- [ ] LaTeX builds without errors
- [ ] Notation is consistent with other unary operators (negation)
