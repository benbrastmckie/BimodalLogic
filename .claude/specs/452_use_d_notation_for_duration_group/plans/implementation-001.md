# Implementation Plan: Task #452

**Task**: Use 'D' notation for duration group consistently
**Version**: 001
**Created**: 2026-01-12
**Language**: general

## Overview

This plan implements a systematic notation change from `T` to `D` for the totally ordered commutative group of durations (times relative to a world history) throughout the ProofChecker codebase. The change aligns with the convention established in the source paper at `/home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, where `\D` (rendered as `\mathcal{D}`) represents the temporal order structure.

The implementation is divided into 4 phases: LaTeX infrastructure, LaTeX content, Lean core semantics, and Lean dependent modules. LaTeX changes are independent and done first, followed by Lean changes in dependency order.

## Phases

### Phase 1: LaTeX Infrastructure

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add `\D` macro to notation package for consistency with source paper
2. Establish notation foundation for content changes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/assets/bimodal-notation.sty` - Add `\newcommand{\D}{\mathcal{D}}`

**Steps**:
1. Read current `bimodal-notation.sty` to understand existing macros
2. Add `\D` macro definition: `\newcommand{\D}{\mathcal{D}}  % Duration/temporal order structure`
3. Verify no conflicts with existing commands

**Verification**:
- `bimodal-notation.sty` compiles without errors
- `\D` macro is available for use

---

### Phase 2: LaTeX Content Updates

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update `02-Semantics.tex` - 27 occurrences of `T` referring to durations
2. Update `06-Notes.tex` - 2 occurrences
3. Preserve non-duration uses of `T` (axiom names, tableaux)

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/06-Notes.tex`

**Steps**:
1. In `02-Semantics.tex`:
   - Line 19: Change `$T$ & Type & Temporal durations` to `$D$ & Type & Temporal durations`
   - Line 20: Change `$\worldstate \to T \to \worldstate \to \text{Prop}$` to `$\worldstate \to D \to \worldstate \to \text{Prop}$`
   - Line 26: Change `task frame over temporal type $T$` to `task frame over temporal type $D$`
   - Lines 29, 43, 44, 49 (x2), 67, 71, 80, 82, 87, 88, 102 (x3), 121 (x3), 130 (x3): Change all type annotations `x : T`, `y : T`, etc. to use `D`
   - Change function signatures like `$\bar{a} : T \to T$` to `$\bar{a} : D \to D$`
   - Change `$\text{TaskFrame}(T)$` to `$\text{TaskFrame}(D)$`
2. In `06-Notes.tex`:
   - Line 69: Change `$T = \mathbb{Z}$` to `$D = \mathbb{Z}$`
   - Line 70: Change `any type $T$` to `any type $D$`
3. Do NOT change: axiom names (MT, T4, TA, TL, TF), tableau formulas T(phi), theorem prefixes (T-Box)

**Verification**:
- Run `latexmk` or `pdflatex` to compile the document
- Review PDF output for correct rendering
- Verify no regression in non-duration uses of `T`

---

### Phase 3: Lean Core Semantics

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Update core structure definitions with `D` type parameter
2. Follow dependency order: TaskFrame -> TaskModel -> WorldHistory -> Truth -> Validity

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskModel.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean`

**Steps**:
1. **TaskFrame.lean** (foundational):
   - Replace `structure TaskFrame (T : Type*)` with `structure TaskFrame (D : Type*)`
   - Replace all `[AddCommGroup T]` with `[AddCommGroup D]`
   - Replace all `[LinearOrder T]` with `[LinearOrder D]`
   - Replace all `[IsOrderedAddMonoid T]` with `[IsOrderedAddMonoid D]`
   - Update examples and instances
   - Run `lake build` to verify

2. **TaskModel.lean** (depends on TaskFrame):
   - Replace `structure TaskModel {T : Type*}` with `structure TaskModel {D : Type*}`
   - Update all type parameters and constraints
   - Run `lake build` to verify

3. **WorldHistory.lean** (depends on TaskFrame):
   - Replace `structure WorldHistory {T : Type*}` with `structure WorldHistory {D : Type*}`
   - Update function signatures
   - Run `lake build` to verify

4. **Truth.lean** (depends on TaskModel, WorldHistory):
   - Replace type parameter `T` with `D` throughout
   - Update all truth function signatures
   - Run `lake build` to verify

5. **Validity.lean** (depends on all above):
   - Replace `T : Type` quantifications with `D : Type`
   - Update validity definitions
   - Run `lake build` to verify

**Verification**:
- `lake build` succeeds after each file change
- No type errors in dependent files
- All existing theorems still compile

---

### Phase 4: Lean Dependent Modules and Tests

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Update metalogic modules (SoundnessLemmas, Completeness)
2. Update example files
3. Update Logos SubTheories
4. Verify full build

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Examples/TemporalStructures.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Explanatory/Frame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Explanatory/Truth.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Explanatory.lean`

**Steps**:
1. **SoundnessLemmas.lean**:
   - Update `is_valid` definition and lemmas
   - Replace `T` type parameter with `D`
   - Run `lake build`

2. **Completeness.lean**:
   - Update completeness proofs
   - Replace `T` type parameter with `D`
   - Run `lake build`

3. **TemporalStructures.lean**:
   - Update `genericTimeFrame`, `genericNatFrame` definitions
   - Replace type parameters in examples
   - Run `lake build`

4. **Logos SubTheories**:
   - Frame.lean: Update `CoreFrame (T : Type*)` to `CoreFrame (D : Type*)`
   - Truth.lean: Update `TemporalIndex (T : Type*)` to `TemporalIndex (D : Type*)`
   - Explanatory.lean: Update any re-exports
   - Run `lake build`

5. **Final full build**:
   - Run `lake build` from project root
   - Verify no errors or warnings

**Verification**:
- Full `lake build` succeeds with no errors
- All tests pass (if any exist in Tests/BimodalTest/)
- No regressions in existing proofs

---

## Dependencies

- Phase 1 (LaTeX Infrastructure): None
- Phase 2 (LaTeX Content): Depends on Phase 1
- Phase 3 (Lean Core): None (independent of LaTeX)
- Phase 4 (Lean Dependent): Depends on Phase 3

Note: Phases 1-2 (LaTeX) and Phases 3-4 (Lean) can be done in parallel, but within each track the phases are sequential.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing Lean code | High | Run `lake build` after each file change |
| Missing occurrences | Medium | Use systematic Grep search; verify with full build |
| Confusion with other `D` uses in codebase | Medium | Document convention clearly; rename conflicts if found |
| Merge conflicts with other branches | Low | Complete in single session |
| LaTeX compilation errors | Low | Test compile after changes |

## Success Criteria

- [ ] `\D` macro defined in `bimodal-notation.sty`
- [ ] All 27 duration-related `T` occurrences in `02-Semantics.tex` changed to `D`
- [ ] All 2 duration-related `T` occurrences in `06-Notes.tex` changed to `D`
- [ ] LaTeX document compiles without errors
- [ ] All Lean files compile with `D` notation
- [ ] Full `lake build` succeeds with no errors
- [ ] Notation consistent with source paper convention
