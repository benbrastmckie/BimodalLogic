# Implementation Plan: Task #363

**Task**: Create Bimodal LaTeX documentation
**Version**: 001
**Created**: 2026-01-11
**Language**: latex

## Overview

Create a comprehensive LaTeX documentation suite for the Bimodal TM logic implementation, following the structure of the JPL paper "The Perpetuity Calculus of Agency". The documentation will mirror Logos/LaTeX structure while focusing specifically on what has been implemented in the Bimodal/ directory, with explicit cross-references to both the paper and Lean source code.

## Phases

### Phase 1: Directory Structure and Assets

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create Bimodal/LaTeX/ directory structure
2. Copy and adapt formatting assets from Logos/LaTeX
3. Create bimodal-notation.sty with TM-specific notation

**Files to create**:
- `Bimodal/LaTeX/BimodalReference.tex` - Main document skeleton
- `Bimodal/LaTeX/assets/bimodal-notation.sty` - Custom notation (□, ◇, H, G, △, ▽)
- `Bimodal/LaTeX/assets/formatting.sty` - Copy from Logos/LaTeX
- `Bimodal/LaTeX/bibliography/BimodalReferences.bib` - Include JPL paper reference
- `Bimodal/LaTeX/subfiles/` - Directory for chapter files

**Steps**:
1. Create directory structure: `Bimodal/LaTeX/{assets,bibliography,subfiles,build}`
2. Copy `formatting.sty` from `Logos/LaTeX/assets/`
3. Create `bimodal-notation.sty` adapting notation from JPL paper (lines 149-200)
4. Create skeleton `BimodalReference.tex` with subfiles structure
5. Create `BimodalReferences.bib` with JPL paper entry

**Verification**:
- Directory structure matches Logos/LaTeX pattern
- `pdflatex BimodalReference.tex` compiles without errors (may be empty)

---

### Phase 2: Main Document and Introduction

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Complete main document structure
2. Write introduction section

**Files to create/modify**:
- `Bimodal/LaTeX/BimodalReference.tex` - Complete main document
- `Bimodal/LaTeX/subfiles/00-Introduction.tex` - TM logic overview

**Steps**:
1. Complete BimodalReference.tex with:
   - Document class and package imports
   - Custom notation loading
   - Subfile includes for all chapters
   - Bibliography configuration
2. Write 00-Introduction.tex covering:
   - TM logic overview (bimodal tense and modality)
   - Relationship to JPL paper
   - Project structure overview
   - Implementation status summary (soundness complete, completeness infrastructure only)

**Verification**:
- Document compiles with introduction
- Cross-references to paper sections work

---

### Phase 3: Syntax Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document Formula type and operators
2. Include notation table

**Files to create**:
- `Bimodal/LaTeX/subfiles/01-Syntax.tex`

**Steps**:
1. Document Formula inductive type (6 constructors)
2. Create notation table mapping paper symbols to Lean definitions:
   | Symbol | Paper | Lean |
   |--------|-------|------|
   | □ | Box | Formula.box |
   | H | Past | Formula.all_past |
   | G | Future | Formula.all_future |
   | etc. |
3. Document derived operators (neg, and, or, diamond, always, sometimes)
4. Document swap_past_future transformation
5. Include `\leansrc{Bimodal/Syntax/Formula.lean}{line}` references

**Verification**:
- All 6 primitive constructors documented
- All derived operators documented
- Notation matches JPL paper

---

### Phase 4: Proof System Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document axiom schemata
2. Document inference rules
3. Document derivation tree structure

**Files to create**:
- `Bimodal/LaTeX/subfiles/02-ProofSystem.tex`

**Steps**:
1. Document 14 axiom schemata matching paper's sub:Logic:
   - Propositional: prop_k, prop_s, ex_falso, peirce
   - Modal S5: modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
   - Temporal: temp_k_dist, temp_4, temp_a, temp_l
   - Bimodal: modal_future, temp_future
2. Document 7 inference rules from DerivationTree
3. Include paper axiom labels (MK, MT, M5, TK, TL, T4, TA, MF, TF)
4. Add derivation tree examples

**Verification**:
- All axioms listed with both paper and Lean names
- Inference rules match Derivation.lean

---

### Phase 5: Semantics Documentation

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document frame and model structures
2. Document world histories
3. Document truth conditions
4. Document time-shift machinery

**Files to create**:
- `Bimodal/LaTeX/subfiles/03-Semantics.tex`

**Steps**:
1. Document TaskFrame structure (def:frame alignment):
   - WorldState type
   - Temporal order (LinearOrderedAddCommGroup)
   - Task relation with nullity and compositionality
2. Document WorldHistory structure (def:world-history alignment):
   - Domain, state function
   - Convexity constraint
   - Task relation respect
3. Document TaskModel and valuation
4. Document truth conditions (def:BL-semantics alignment):
   - All 6 clauses for primitive operators
   - Derived operator truth conditions
5. Document time-shift infrastructure:
   - WorldHistory.time_shift
   - TimeShift.time_shift_preserves_truth
6. Document validity definitions

**Verification**:
- Paper definitions (def:frame, def:world-history, def:BL-model, def:BL-semantics) are all covered
- Time-shift preservation lemma documented

---

### Phase 6: Metalogic Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document soundness theorem
2. Document completeness infrastructure
3. Note implementation status

**Files to create**:
- `Bimodal/LaTeX/subfiles/04-Metalogic.tex`

**Steps**:
1. Document soundness theorem (thm:TM-soundness alignment):
   - All 14 axiom validity lemmas (fully proven)
   - 7 inference rule soundness cases (fully proven)
   - Main theorem: Γ ⊢ φ → Γ ⊨ φ
2. Document key validity proofs:
   - MF validity (thm:MF-valid, time-shift based)
   - TF validity (thm:TF-valid, time-shift based)
3. Document completeness infrastructure:
   - Consistent/MaximalConsistent definitions
   - Lindenbaum's lemma (axiomatized)
   - Canonical model construction (axiomatized)
   - Note: ~70-90 hours estimated to complete
4. Document deduction theorem

**Verification**:
- Soundness theorem statement matches Lean
- Axiomatized components clearly marked

---

### Phase 7: Theorems Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document perpetuity principles P1-P6
2. Document additional theorems P9-P22
3. Document S5 modal theorems

**Files to create**:
- `Bimodal/LaTeX/subfiles/05-Theorems.tex`

**Steps**:
1. Document perpetuity principles (all proven):
   - P1: □φ → △φ (necessary implies always)
   - P2: ▽φ → ◇φ (sometimes implies possible)
   - P3: □φ → □△φ (necessity of perpetuity)
   - P4: ◇▽φ → ◇φ (possibility of occurrence)
   - P5: ◇▽φ → △◇φ (persistent possibility)
   - P6: ▽□φ → □△φ (occurrent necessity is perpetual)
2. Document additional theorems from sub:ProofTheory:
   - P9-P22 (some proven, some pending)
3. Document propositional and modal combinators
4. Include derivation status for each theorem

**Verification**:
- P1-P6 documented with proof sketches
- Implementation status clearly marked

---

### Phase 8: Build and Integration

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify full document compiles
2. Create build script
3. Update project documentation

**Files to create/modify**:
- `Bimodal/LaTeX/build.sh` - Build script
- `Bimodal/README.md` - Add LaTeX documentation reference

**Steps**:
1. Create build.sh script with latexmk commands
2. Test full document compilation
3. Verify all cross-references resolve
4. Add reference to Documentation/README.md or Bimodal/README.md

**Verification**:
- `./build.sh` produces BimodalReference.pdf
- No LaTeX warnings about undefined references
- PDF table of contents is complete

---

## Dependencies

- Logos/LaTeX/assets/formatting.sty - Base formatting to copy
- JPL paper possible_worlds.tex - Notation reference

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| LaTeX compilation errors | Med | Low | Test each phase independently |
| Notation conflicts | Low | Low | Carefully namespace bimodal-notation.sty |
| Missing Lean cross-refs | Low | Med | Verify \leansrc paths exist |

## Success Criteria

- [ ] Directory structure mirrors Logos/LaTeX
- [ ] Main document compiles without errors
- [ ] All 5 subfiles complete (Introduction, Syntax, ProofSystem, Semantics, Metalogic, Theorems)
- [ ] Notation matches JPL paper
- [ ] Implementation status clearly marked (proven vs axiomatized)
- [ ] Cross-references to Lean source included

## Rollback Plan

Delete Bimodal/LaTeX/ directory if implementation fails - no existing content affected.
