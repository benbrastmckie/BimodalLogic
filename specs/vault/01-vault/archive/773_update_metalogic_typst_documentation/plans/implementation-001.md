# Implementation Plan: Task #773

- **Task**: 773 - Update metalogic Typst documentation to reflect recent codebase changes
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Priority**: high
- **Dependencies**: Task 772 (in progress - refactoring sorried proofs to Boneyard)
- **Research Inputs**: specs/773_update_metalogic_typst_documentation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Update `Theories/Bimodal/typst/chapters/04-metalogic.typ` to reflect the current state of the metalogic codebase after Tasks 750, 760, 764, 769, and 772. The key change is repositioning `semantic_weak_completeness` as the primary completeness theorem while documenting that the `representation_theorem` approach is deprecated due to architectural limitations. The documentation will present a clear theorem dependency graph with proof sketches explaining WHY proofs work, not full formal details.

### Research Integration

- **Task 750**: Truth bridge analysis confirming Box semantics architectural limitation
- **Task 769**: Sorry audit showing 20 sorries all deprecated, pointing to `semantic_weak_completeness`
- **Task 772**: Plan for archiving sorried proofs to Boneyard/Metalogic_v4/
- **Key Finding**: `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean` is sorry-free

## Goals & Non-Goals

**Goals**:
- Establish `semantic_weak_completeness` as THE primary completeness theorem
- Document theorem dependency graph showing the two approaches (representation vs contrapositive)
- Provide proof sketches explaining key insights without full formal details
- Update directory structure diagram to reflect Soundness/, Algebraic/, and current FMP/ role
- Update axiom table to show 15 axioms with correct Lean theorem names
- Update implementation status to reflect 20 deprecated sorries and sorry-free alternatives
- Include links to Lean source files for readers wanting details

**Non-Goals**:
- Full formal proof reproductions in Typst (that's what the Lean code is for)
- Documenting every helper lemma (focus on major theorems)
- Updating other chapters (04-metalogic.typ only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 772 changes during implementation | Medium | Medium | Check latest Metalogic/ structure before each phase |
| Typst compilation failure | Low | Low | Compile after each major section update |
| CeTZ diagram complexity | Low | Medium | Keep diagram structure similar to existing, update labels |

## Implementation Phases

### Phase 1: Update Introduction and Core Framework [COMPLETED]

**Goal**: Reframe the chapter to position `semantic_weak_completeness` as the primary result

**Estimated effort**: 45 minutes

**Objectives**:
1. Update introduction (lines 1-14) to acknowledge both approaches
2. Update Core Infrastructure section to reference current file locations
3. Keep deduction theorem, MCS, and Lindenbaum content (still accurate)

**Tasks**:
- [ ] Update intro paragraph to mention contrapositive completeness as primary
- [ ] Note that representation theorem provides supporting infrastructure but has architectural limitations
- [ ] Update file references for Core/ subdirectory
- [ ] Verify deduction theorem section is accurate

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Lines 1-110

**Verification**:
- Typst compiles without errors
- Introduction clearly states semantic_weak_completeness is primary

---

### Phase 2: Update Soundness Section [COMPLETED]

**Goal**: Update axiom table to reflect 15 axioms with correct theorem names

**Estimated effort**: 30 minutes

**Objectives**:
1. Verify axiom table shows all 15 axioms (MF and TF are present)
2. Update Lean theorem names to match current codebase
3. Add reference to `Soundness/Soundness.lean` location

**Tasks**:
- [ ] Verify table has 15 axioms (current shows 15: PK, PS, EFQ, Peirce, MT, M4, MB, M5, MK, TK, T4, TA, TL, MF, TF)
- [ ] Update theorem name column if any names have changed
- [ ] Add note about source location: `Soundness/Soundness.lean`

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Lines 15-62

**Verification**:
- Axiom count matches codebase (15)
- Theorem names match actual Lean declarations

---

### Phase 3: Revise Representation Theory Section [COMPLETED]

**Goal**: Reframe representation theorem as supporting infrastructure with noted limitations

**Estimated effort**: 45 minutes

**Objectives**:
1. Add note that representation theorem has architectural sorries
2. Clarify that truth lemma has Box semantics limitation
3. Reference FMP/SemanticCanonicalModel.lean as sorry-free alternative
4. Keep mathematical content accurate while noting deprecated status

**Tasks**:
- [ ] Add paragraph explaining the architectural limitation (S5-style Box quantifies over ALL histories)
- [ ] Note that Representation/ files have sorries that are intentionally NOT being fixed
- [ ] Update file references to current locations
- [ ] Add pointer to Phase 4 (contrapositive approach) as the resolution

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Lines 111-232

**Verification**:
- Section accurately reflects deprecated status
- Clear pointer to sorry-free alternative

---

### Phase 4: Add New Section - Contrapositive Completeness [COMPLETED]

**Goal**: Document `semantic_weak_completeness` as the canonical sorry-free completeness theorem

**Estimated effort**: 60 minutes

**Objectives**:
1. Create new section explaining the contrapositive approach
2. Document proof sketch: unprovable -> consistent -> MCS -> countermodel
3. Explain why this avoids the truth bridge gap
4. Reference `FMP/SemanticCanonicalModel.lean` as source

**Tasks**:
- [ ] Add new section after Representation Theory (or integrate into Completeness section)
- [ ] Document the proof strategy:
  1. Contrapositive: `valid phi -> provable phi` becomes `not provable phi -> not valid phi`
  2. If phi is not provable, then {phi.neg} is consistent
  3. Extend to full MCS by Lindenbaum's lemma
  4. Project to closure MCS (finite subset)
  5. Build FiniteWorldState from closure MCS membership
  6. phi.neg is true at this world state (by construction)
  7. This gives a countermodel, so phi is not valid
- [ ] Explain why this avoids truth bridge: assignment IS the MCS membership function
- [ ] Add code reference: `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean`

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Insert new content around lines 233-302

**Verification**:
- New section clearly explains the contrapositive approach
- Links to correct source file

---

### Phase 5: Update Theorem Dependency Diagram [COMPLETED]

**Goal**: Update CeTZ diagram to show both approaches with semantic_weak_completeness as primary

**Estimated effort**: 45 minutes

**Objectives**:
1. Update diagram to show two paths to completeness
2. Show representation_theorem path with "deprecated" annotation
3. Show contrapositive path as primary (sorry-free)
4. Keep Core Infrastructure as foundation for both

**Tasks**:
- [ ] Modify CeTZ diagram (lines 184-228) to show:
  - Core Infrastructure (Deduction, Lindenbaum, MCS) at top
  - Two branches: Representation path (deprecated) and Contrapositive path (primary)
  - Representation -> Truth Lemma -> representation_theorem [deprecated]
  - Lindenbaum -> MCS closure -> semantic_weak_completeness [primary]
  - Both lead to weak/strong completeness at bottom
- [ ] Add color coding: green for sorry-free, orange for deprecated

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Lines 184-232

**Verification**:
- Diagram renders correctly
- Clear visual distinction between deprecated and primary paths

---

### Phase 6: Update File Organization Diagram [COMPLETED]

**Goal**: Update directory structure to reflect current codebase organization

**Estimated effort**: 30 minutes

**Objectives**:
1. Add Soundness/ directory
2. Add Algebraic/ directory
3. Update FMP/ description to highlight `semantic_weak_completeness`
4. Update Representation/ to note deprecated status

**Tasks**:
- [ ] Update CeTZ diagram (lines 378-426) to show:
  - Core/ (unchanged)
  - Soundness/ (NEW - 15 axioms, 7 rules)
  - Representation/ (note: contains deprecated code)
  - FMP/ (highlight: contains semantic_weak_completeness)
  - Completeness/ (uses FMP path)
  - Compactness/ (unchanged)
  - Algebraic/ (NEW - alternative sorry-free approach)
- [ ] Update directory descriptions (lines 428-435)

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Lines 378-435

**Verification**:
- Diagram matches current directory structure
- Descriptions accurate

---

### Phase 7: Update Implementation Status Section [COMPLETED]

**Goal**: Complete rewrite of sorry status and implementation tables

**Estimated effort**: 45 minutes

**Objectives**:
1. Update sorry count: 20 sorries, all deprecated
2. List sorry locations with explanations
3. Emphasize `semantic_weak_completeness` is sorry-free
4. Update metalogic implementation table

**Tasks**:
- [ ] Rewrite sorry status section (lines 436-447):
  - Total: 20 sorries in Metalogic/ (excluding Boneyard/, Examples/)
  - All deprecated with pointers to sorry-free alternatives
  - List by file:
    - TruthLemma.lean: 4 (Box/temporal backward directions)
    - TaskRelation.lean: 5 (cross-sign duration composition)
    - CoherentConstruction.lean: 8 (cross-origin coherence)
    - SemanticCanonicalModel.lean: 2 (frame compositionality, truth bridge)
    - FiniteModelProperty.lean: 1 (FMP truth bridge)
- [ ] Add note: All sorries are architectural limitations, not incomplete work
- [ ] Update implementation table (lines 473-498):
  - Soundness: Proven (`soundness`)
  - Deduction Theorem: Proven (`deduction_theorem`)
  - Lindenbaum Lemma: Proven (`set_lindenbaum`)
  - IndexedMCSFamily: Proven (`IndexedMCSFamily`)
  - Truth Lemma: Deprecated (has sorries)
  - Representation Theorem: Deprecated (depends on Truth Lemma)
  - **Semantic Weak Completeness: PROVEN (sorry-free)**
  - Strong Completeness: Proven (uses semantic_weak_completeness)
  - Provable iff Valid: Proven (`main_provable_iff_valid`)
  - Finite Model Property: Statement only (architectural sorry)
  - Decidability Soundness: Proven (`decide_sound`)

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Lines 436-502

**Verification**:
- Sorry count matches Task 769 audit (20)
- All sorries marked as deprecated/architectural
- `semantic_weak_completeness` clearly shown as sorry-free

---

### Phase 8: Final Review and Compilation [COMPLETED]

**Goal**: Verify complete document compiles and content is accurate

**Estimated effort**: 30 minutes

**Objectives**:
1. Full Typst compilation
2. Review all sections for consistency
3. Verify source code references are accurate

**Tasks**:
- [ ] Run `typst compile` on the document
- [ ] Review introduction matches conclusions
- [ ] Verify all file references point to existing files
- [ ] Check theorem names match codebase
- [ ] Ensure narrative arc is clear: soundness -> infrastructure -> two approaches -> completeness

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Final pass

**Verification**:
- Document compiles without errors
- Content accurately reflects codebase state
- Clear narrative explaining why `semantic_weak_completeness` is THE completeness theorem

## Testing & Validation

- [ ] Typst compiles without errors after each phase
- [ ] All 15 axiom names match `Soundness/Soundness.lean`
- [ ] Directory structure matches actual Metalogic/ layout
- [ ] Sorry count matches Task 769 audit (20, all deprecated)
- [ ] `semantic_weak_completeness` clearly established as primary completeness theorem
- [ ] File references point to existing Lean files
- [ ] Theorem dependency diagram shows both approaches with correct status

## Artifacts & Outputs

- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Updated documentation
- `specs/773_update_metalogic_typst_documentation/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If implementation fails:
1. Revert `04-metalogic.typ` using `git checkout`
2. Document failure in error report
3. Consider partial update (e.g., just introduction and status tables)

Git provides full rollback capability since all changes are to a single file.
