# Implementation Plan: Task #363

**Task**: Create Bimodal LaTeX documentation
**Version**: 002
**Created**: 2026-01-11
**Revision of**: implementation-001.md
**Reason**: User feedback: (1) Paper is "The Construction of Possible Worlds" not "The Perpetuity Calculus of Agency", (2) No paper cross-references needed but discrepancies should be noted in summary, (3) Semantics documentation before proof theory, (4) Focus on definitions with occasional concise explanations

## Revision Summary

### Key Changes
1. **Correct paper title**: "The Construction of Possible Worlds" (not "The Perpetuity Calculus of Agency")
2. **Remove paper cross-references**: No `\cite{}` or section references to paper needed
3. **Reorder phases**: Semantics (Phase 4) now comes before Proof Theory (Phase 5)
4. **Content focus**: Primarily definitions with occasional motivations/concise explanations
5. **Discrepancy tracking**: Add discrepancy notes in final summary phase rather than inline cross-refs

### Previous Plan Status
- Phase 1: [NOT STARTED] - Directory structure (preserved)
- Phase 2: [NOT STARTED] - Main document (simplified)
- Phase 3: [NOT STARTED] - Syntax (preserved)
- Phase 4: [NOT STARTED] - Proof System (now Phase 5)
- Phase 5: [NOT STARTED] - Semantics (now Phase 4)
- Phase 6: [NOT STARTED] - Metalogic (preserved)
- Phase 7: [NOT STARTED] - Theorems (preserved)
- Phase 8: [NOT STARTED] - Build/Integration (enhanced with discrepancy summary)

## Overview

Create concise, definition-focused LaTeX documentation for the Bimodal TM logic implementation. The documentation emphasizes formal definitions with minimal prose, following Logos/LaTeX structure. Any discrepancies between the paper "The Construction of Possible Worlds" and the Lean implementation will be noted in a summary section.

## Phases

### Phase 1: Directory Structure and Assets

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create Bimodal/latex/ directory structure
2. Copy and adapt formatting assets from Logos/LaTeX
3. Create bimodal-notation.sty with TM-specific notation

**Files to create**:
- `Bimodal/latex/BimodalReference.tex` - Main document skeleton
- `Bimodal/latex/assets/bimodal-notation.sty` - Custom notation (Box, Diamond, H, G, Triangle, InvTriangle)
- `Bimodal/latex/assets/formatting.sty` - Copy from Logos/LaTeX
- `Bimodal/latex/subfiles/` - Directory for chapter files

**Steps**:
1. Create directory structure: `Bimodal/latex/{assets,subfiles,build}`
2. Copy `formatting.sty` from `Logos/latex/assets/`
3. Create `bimodal-notation.sty` with TM logic notation macros
4. Create skeleton `BimodalReference.tex` with subfiles structure

**Verification**:
- Directory structure matches Logos/LaTeX pattern
- `pdflatex BimodalReference.tex` compiles without errors

---

### Phase 2: Main Document and Introduction

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Complete main document structure
2. Write brief introduction section

**Files to create/modify**:
- `Bimodal/latex/BimodalReference.tex` - Complete main document
- `Bimodal/latex/subfiles/00-Introduction.tex` - Brief TM logic overview

**Steps**:
1. Complete BimodalReference.tex with:
   - Document class and package imports
   - Custom notation loading
   - Subfile includes for all chapters
2. Write 00-Introduction.tex with:
   - Brief TM logic overview (1-2 paragraphs)
   - Project structure note
   - Implementation status: soundness complete, completeness infrastructure only

**Verification**:
- Document compiles with introduction

---

### Phase 3: Syntax Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document Formula type and operators
2. Include notation table

**Files to create**:
- `Bimodal/latex/subfiles/01-Syntax.tex`

**Steps**:
1. Define Formula inductive type (6 constructors):
   - `atom`, `falsum`, `imp`, `box`, `all_past`, `all_future`
2. Create notation table:
   | Symbol | Name | Type |
   |--------|------|------|
   | p, q, r | Propositional atoms | Formula |
   | falsum | Falsity | Formula |
   | phi -> psi | Implication | Formula -> Formula -> Formula |
   | Box phi | Necessity | Formula -> Formula |
   | H phi | Always past | Formula -> Formula |
   | G phi | Always future | Formula -> Formula |
3. Define derived operators:
   - Negation, conjunction, disjunction
   - Diamond, P (sometime past), F (sometime future)
   - Triangle (always), InvTriangle (sometime)
4. Brief note on swap_past_future transformation

**Verification**:
- All 6 primitive constructors defined
- All derived operators defined
- Notation clearly presented

---

### Phase 4: Semantics Documentation

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document frame and model structures
2. Document world histories
3. Document truth conditions
4. Document time-shift machinery

**Files to create**:
- `Bimodal/latex/subfiles/02-Semantics.tex`

**Steps**:
1. Define TaskFrame structure:
   - WorldState type
   - Time type (LinearOrderedAddCommGroup)
   - Task relation R : WorldState -> WorldState -> Prop
   - Frame conditions: nullity, compositionality
2. Define WorldHistory:
   - Domain : Set Time
   - State function : Time -> WorldState
   - Convexity constraint
   - Task relation respect
3. Define TaskModel and valuation
4. Define truth conditions for all operators:
   - Atomic: M, h, t |= p iff V(p, h(t))
   - Falsum: M, h, t |/= falsum
   - Implication: M, h, t |= phi -> psi iff ...
   - Box: M, h, t |= Box phi iff for all h' with R(h(t), h'(t)), M, h', t |= phi
   - H: M, h, t |= H phi iff for all s < t in domain, M, h, s |= phi
   - G: M, h, t |= G phi iff for all s > t in domain, M, h, s |= phi
5. Define time-shift operation and preservation lemma
6. Define validity: frame validity, model validity

**Verification**:
- All structures formally defined
- Truth conditions for all operators specified

---

### Phase 5: Proof Theory Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document axiom schemata
2. Document inference rules
3. Document derivation tree structure

**Files to create**:
- `Bimodal/latex/subfiles/03-ProofTheory.tex`

**Steps**:
1. Define axiom schemata (14 total):
   - Propositional: prop_k, prop_s, ex_falso, peirce
   - Modal S5: modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
   - Temporal: temp_k_dist, temp_4, temp_a, temp_l
   - Bimodal interaction: modal_future, temp_future
2. Define inference rules (7 total):
   - modus_ponens, necessitation, temporal_generalization
   - axiom, hypothesis, weakening, cut
3. Define derivability: Gamma |- phi
4. Brief note on derivation tree representation

**Verification**:
- All 14 axioms listed with formal statements
- All inference rules defined

---

### Phase 6: Metalogic Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document soundness theorem
2. Document completeness infrastructure
3. Note implementation status

**Files to create**:
- `Bimodal/latex/subfiles/04-Metalogic.tex`

**Steps**:
1. State soundness theorem:
   - If Gamma |- phi then Gamma |= phi
   - Note: Fully proven in Lean
2. State key lemmas:
   - Axiom validity (all 14 axioms preserve truth)
   - Rule soundness (all 7 rules preserve validity)
   - Time-shift preservation
3. State deduction theorem:
   - Gamma, phi |- psi iff Gamma |- phi -> psi
4. State completeness theorem:
   - If Gamma |= phi then Gamma |- phi
   - Note: Infrastructure only; core lemmas axiomatized
5. Brief note on completeness components:
   - Lindenbaum's lemma (axiomatized)
   - Canonical model construction (axiomatized)

**Verification**:
- Theorems formally stated
- Implementation status clearly indicated

---

### Phase 7: Theorems Documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document perpetuity principles P1-P6
2. Document additional theorems
3. Document modal/temporal combinators

**Files to create**:
- `Bimodal/latex/subfiles/05-Theorems.tex`

**Steps**:
1. Define perpetuity principles (all proven):
   - P1: Box phi -> Triangle phi
   - P2: InvTriangle phi -> Diamond phi
   - P3: Box phi -> Box Triangle phi
   - P4: Diamond InvTriangle phi -> Diamond phi
   - P5: Diamond InvTriangle phi -> Triangle Diamond phi
   - P6: InvTriangle Box phi -> Box Triangle phi
2. List additional theorems from Theorems/ directory with status
3. List key combinators from Combinators:
   - identity, composition, self_implication
   - double_negation, contraposition

**Verification**:
- P1-P6 formally stated
- Theorem status indicated (proven vs pending)

---

### Phase 8: Build, Integration, and Discrepancy Summary

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify full document compiles
2. Create build script
3. Note any discrepancies with paper "The Construction of Possible Worlds"
4. Update project documentation

**Files to create/modify**:
- `Bimodal/latex/build.sh` - Build script
- `Bimodal/latex/subfiles/06-Notes.tex` - Implementation notes and discrepancies
- `Bimodal/README.md` - Add LaTeX documentation reference

**Steps**:
1. Create build.sh script with latexmk commands
2. Create 06-Notes.tex with:
   - Implementation status summary
   - Any discrepancies between paper and Lean implementation (if found)
   - Known limitations (completeness not proven)
3. Test full document compilation
4. Add reference to Bimodal/README.md

**Verification**:
- `./build.sh` produces BimodalReference.pdf
- No LaTeX warnings about undefined references
- Discrepancies (if any) documented

---

## Dependencies

- Logos/latex/assets/formatting.sty - Base formatting to copy

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| LaTeX compilation errors | Med | Low | Test each phase independently |
| Notation conflicts | Low | Low | Carefully namespace bimodal-notation.sty |

## Success Criteria

- [ ] Directory structure mirrors Logos/LaTeX
- [ ] Main document compiles without errors
- [ ] All 7 subfiles complete (Introduction, Syntax, Semantics, ProofTheory, Metalogic, Theorems, Notes)
- [ ] Content focuses on definitions with minimal prose
- [ ] Semantics documented before proof theory
- [ ] Implementation status clearly marked (proven vs axiomatized)
- [ ] Any paper-Lean discrepancies noted in summary

## Rollback Plan

Delete Bimodal/latex/ directory if implementation fails - no existing content affected.
