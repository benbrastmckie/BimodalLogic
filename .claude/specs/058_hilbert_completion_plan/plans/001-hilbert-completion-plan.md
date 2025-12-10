# Lean Implementation Plan: Hilbert Theorem Completion

## Metadata
- **Date**: 2025-12-09
- **Feature**: Complete remaining Hilbert-style propositional and modal theorems from Tasks 21-41
- **Scope**: Resolve 12 sorry placeholders across Propositional.lean, ModalS5.lean, ModalS4.lean by implementing deduction theorem infrastructure and S5 characteristic axiom
- **Status**: [PHASE 4 PARTIAL - PHASE 5 COMPLETE]
- **Estimated Hours**: 35-45 hours
- **Complexity Score**: 42
- **Structure Level**: 0
- **Estimated Phases**: 5
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Prior Plan**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/057_hilbert_propositional_modal_theorems/plans/001-hilbert-propositional-modal-theorems-plan.md
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Prior Work Summary

The previous implementation plan (057) achieved significant progress:

### Already Implemented (Zero Sorry)
| Module | Theorems | Count |
|--------|----------|-------|
| Propositional.lean | lem, ecq, raa, efq, ldi, rdi, rcp, lce, rce, iff_intro, iff_elim_left, iff_elim_right | 12 |
| ModalS5.lean | t_box_to_diamond, box_contrapose, t_box_consistency, iff (def) | 3 |
| ModalS4.lean | s4_box_diamond_box | 1 |
| **Total** | | **16** |

### Currently Blocked (12 Sorry Placeholders)
| Module | Theorem | Blocker |
|--------|---------|---------|
| Propositional.lean | lce_imp | Deduction Theorem |
| Propositional.lean | rce_imp | Deduction Theorem |
| Propositional.lean | classical_merge | Deduction Theorem |
| ModalS5.lean | classical_merge (duplicate) | Deduction Theorem |
| ModalS5.lean | box_disj_intro | classical_merge |
| ModalS5.lean | box_conj_iff | lce_imp/rce_imp |
| ModalS5.lean | diamond_disj_iff | De Morgan / biconditional |
| ModalS5.lean | s5_diamond_box (forward) | S5 Characteristic Axiom |
| ModalS5.lean | s5_diamond_box_to_truth | s5_diamond_box |
| ModalS4.lean | s4_diamond_box_conj | lce_imp/rce_imp |
| ModalS4.lean | s4_diamond_box_diamond (forward) | S5 Characteristic Axiom |
| ModalS4.lean | s5_diamond_conj_diamond | lce_imp/rce_imp |

### Key Blocker Analysis

**Blocker 1: Deduction Theorem** (Blocks 6 theorems)
- Required for: lce_imp, rce_imp, classical_merge
- Cascades to: box_disj_intro, box_conj_iff, s4_diamond_box_conj, s5_diamond_conj_diamond

**Blocker 2: S5 Characteristic Axiom** (Blocks 3 theorems)
- Required pattern: `◇□A → □A` (or equivalently `□◇A → ◇A`)
- Affects: s5_diamond_box forward, s5_diamond_box_to_truth, s4_diamond_box_diamond forward

---

## Success Criteria

### Module Completion
- [ ] All 12 sorry placeholders resolved
- [ ] Propositional.lean: lce_imp, rce_imp, classical_merge proven
- [ ] ModalS5.lean: All 6 blocked theorems proven
- [ ] ModalS4.lean: All 3 blocked theorems proven

### Quality Standards
- [ ] Zero `#lint` warnings in modified modules
- [ ] Build time <3 minutes total
- [ ] All theorems have docstrings with mathematical statements

### Documentation
- [ ] IMPLEMENTATION_STATUS.md updated to reflect full completion
- [ ] SORRY_REGISTRY.md updated (should be empty for these modules)
- [ ] Known Limitations section removed or updated

---

## Implementation Phases

### Phase Routing Summary
| Phase | Type | Implementer Agent |
|-------|------|-------------------|
| 1 | lean | lean-implementer |
| 2 | lean | lean-implementer |
| 3 | lean | lean-implementer |
| 4 | lean | lean-implementer |
| 5 | software | implementer-coordinator |

---

### Phase 1: Deduction Theorem Infrastructure [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/DeductionTheorem.lean
dependencies: []

**Effort**: 12-15 hours

Implement partial deduction theorem for the specific cases needed by blocked theorems.

**Background**:
The deduction theorem states: If `Γ, A ⊢ B` then `Γ ⊢ A → B`.

For Hilbert systems, this requires induction on the derivation structure. We need to handle:
- Base case: axiom
- Base case: assumption
- Inductive case: modus ponens
- Inductive case: weakening

**Theorem Specifications**:

- [x] `theorem deduction_axiom`
  - Goal: `∀ (Γ : Context) (A φ : Formula), (φ ∈ axioms) → (Γ ⊢ A.imp φ)`
  - Strategy: Apply prop_s to weaken axiom under implication
  - Complexity: Simple

- [x] `theorem deduction_assumption_same`
  - Goal: `∀ (Γ : Context) (A : Formula), (Γ ⊢ A.imp A)`
  - Strategy: Identity theorem (already exists as `identity`)
  - Complexity: Trivial

- [x] `theorem deduction_assumption_other`
  - Goal: `∀ (Γ : Context) (A B : Formula), (B ∈ Γ) → (Γ ⊢ A.imp B)`
  - Strategy: Apply prop_s to weaken assumption B under A
  - Complexity: Simple

- [x] `theorem deduction_mp`
  - Goal: If `Γ ⊢ A.imp (C.imp D)` and `Γ ⊢ A.imp C` then `Γ ⊢ A.imp D`
  - Strategy: Use prop_k distribution: `(A → C → D) → ((A → C) → (A → D))`
  - Complexity: Medium

- [x] `theorem deduction_theorem`
  - Goal: `∀ (Γ : Context) (A B : Formula), ((A :: Γ) ⊢ B) → (Γ ⊢ A.imp B)`
  - Strategy: Induction on derivation structure with above cases
  - Complexity: Complex

**Success Criteria**:
- [x] deduction_theorem proven with zero sorry
- [x] All helper lemmas proven
- [x] Build passes
- [x] Module compiles without warnings

**Deliverables**:
- New file: `Logos/Core/Metalogic/DeductionTheorem.lean` (~300-400 LOC)

---

### Phase 2: Conjunction Elimination in Implication Form [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
dependencies: [1]

**Effort**: 4-6 hours

Use deduction theorem to prove lce_imp and rce_imp.

**Theorem Specifications**:

- [x] `theorem lce_imp`
  - Goal: `⊢ (A.and B).imp A`
  - Strategy: Apply deduction_theorem to existing `lce : [A ∧ B] ⊢ A`
  - Complexity: Simple (given deduction theorem)
  - Location: Propositional.lean:562-563 (replace sorry)

- [x] `theorem rce_imp`
  - Goal: `⊢ (A.and B).imp B`
  - Strategy: Apply deduction_theorem to existing `rce : [A ∧ B] ⊢ B`
  - Complexity: Simple (given deduction theorem)
  - Location: Propositional.lean:578-579 (replace sorry)

- [x] `theorem classical_merge`
  - Goal: `⊢ (P.imp Q).imp ((P.neg.imp Q).imp Q)`
  - Strategy: Use deduction_theorem + DNE + contraposition pattern documented in phase-3-iteration-2-summary.md
  - Complexity: Medium
  - Location: Propositional.lean:606-618 (replace sorry)

**Success Criteria**:
- [x] lce_imp proven (zero sorry)
- [x] rce_imp proven (zero sorry)
- [x] classical_merge proven (zero sorry)
- [x] Propositional.lean compiles with zero sorry

**Deliverables**:
- Updated Propositional.lean (3 sorry → 0 sorry)

---

### Phase 3: S5 Characteristic Axiom [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean
dependencies: []

**Effort**: 3-4 hours

Add S5 characteristic axiom and prove soundness.

**Background**:
The current axiom system has T, 4, B, 5 but lacks the characteristic S5 property that allows collapsing `◇□A → □A`. This is provable semantically (S5 has equivalence relation accessibility) but requires an axiom syntactically.

**Theorem Specifications**:

- [x] `axiom modal_5_collapse`
  - Goal: Add `modal_5_collapse (A : Formula) : Axiom` with schema `◇□A → □A`
  - Strategy: Extend Axiom inductive with new case
  - Complexity: Simple
  - Location: Axioms.lean (new case)

- [x] `theorem modal_5_collapse_sound`
  - Goal: Prove `valid (modal_5_collapse A)` in task semantics
  - Strategy: Use S5 accessibility relation properties (equivalence relation)
  - Complexity: Medium
  - Location: Soundness.lean (new lemma)

**Alternative**: Instead of adding new axiom, attempt to derive `◇□A → □A` from existing axioms using modal reasoning. If derivable, no axiom extension needed.

**Success Criteria**:
- [x] S5 characteristic axiom added or derived
- [x] Soundness maintained (no sorry in soundness proofs)
- [x] Build passes

**Deliverables**:
- Updated Axioms.lean (if adding axiom)
- Updated Soundness.lean (soundness proof)

---

### Phase 4: Complete Blocked Modal Theorems [PARTIAL - 5/8 COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean
dependencies: [2, 3]

**Effort**: 10-14 hours (10 hours actual)

Use Phase 2-3 infrastructure to complete all blocked modal theorems.

**Theorem Specifications**:

**ModalS5.lean Theorems**:

- [x] `theorem box_disj_intro` **[COMPLETE]**
  - Goal: `⊢ (A.box.or B.box).imp ((A.or B).box)`
  - Strategy: Use classical_merge with box_mono on both branches
  - Complexity: Medium
  - Location: ModalS5.lean:154-199 (proven)

- [x] `theorem box_conj_iff` **[COMPLETE]**
  - Goal: `⊢ iff (A.and B).box (A.box.and B.box)`
  - Strategy: Forward via lce_imp/rce_imp + box_mono, backward via existing pairing
  - Complexity: Medium
  - Location: ModalS5.lean:342-428 (proven)

- [ ] `theorem diamond_disj_iff` **[BLOCKED - De Morgan Laws Required]**
  - Goal: `⊢ iff (A.or B).diamond (A.diamond.or B.diamond)`
  - Strategy: Modal duality of box_conj_iff + De Morgan laws
  - Complexity: Complex
  - Location: ModalS5.lean:439-461 (sorry - requires De Morgan infrastructure)
  - **Blocker**: Requires De Morgan laws for disjunction/conjunction duality

- [x] `theorem s5_diamond_box` **[COMPLETE]**
  - Goal: `⊢ (A.box.diamond).imp A.box` (biconditional)
  - Strategy: Apply modal_5_collapse axiom directly
  - Complexity: Simple (given axiom)
  - Location: ModalS5.lean:479-522 (proven)

- [x] `theorem s5_diamond_box_to_truth` **[COMPLETE]**
  - Goal: `⊢ (A.box.diamond).imp A`
  - Strategy: Compose s5_diamond_box with modal_t
  - Complexity: Simple
  - Location: ModalS5.lean:534-543 (proven)

**ModalS4.lean Theorems**:

- [ ] `theorem s4_diamond_box_conj` **[BLOCKED - Conditional Diamond Mono Required]**
  - Goal: `⊢ (A.diamond.and B.box).imp ((A.and B.box).diamond)`
  - Strategy: Use lce_imp/rce_imp + modal distribution + pairing
  - Complexity: Complex
  - Location: ModalS4.lean:61-76 (sorry - requires conditional diamond_mono)
  - **Blocker**: Requires conditional monotonicity: ⊢ θ → (φ → ψ) ⇒ ⊢ θ → (◇φ → ◇ψ)

- [x] `theorem s4_diamond_box_diamond` **[COMPLETE]**
  - Goal: `⊢ (A.diamond.box.diamond).imp A.diamond` (biconditional)
  - Strategy: Apply modal_5_collapse to inner box, collapse diamonds
  - Complexity: Medium
  - Location: ModalS4.lean:100-217 (proven)

- [ ] `theorem s5_diamond_conj_diamond` **[BLOCKED - Diamond Distribution Required]**
  - Goal: `⊢ iff ((A.and B.diamond).diamond) (A.diamond.and B.diamond)`
  - Strategy: Use S5 distribution + lce_imp/rce_imp
  - Complexity: Complex
  - Location: ModalS4.lean:230-245 (sorry - requires diamond distribution over conjunction)

**Success Criteria**:
- [x] Build passes
- [x] ModalS5.lean: 1 sorry (down from 6, blocked on De Morgan laws)
- [x] ModalS4.lean: 2 sorry (down from 3, blocked on distribution infrastructure)
- [x] 5/8 theorems proven (62.5% completion)

**Deliverables**:
- Updated ModalS5.lean (6 sorry → 1 sorry, 4/5 theorems proven)
- Updated ModalS4.lean (3 sorry → 2 sorry, 2/4 theorems proven)

**Remaining Work** (requires additional infrastructure):
1. De Morgan laws for propositional logic
2. Conditional diamond monotonicity lemma
3. Advanced S5 distribution properties for nested modalities

---

### Phase 5: Documentation and Cleanup [COMPLETE]
implementer: software
dependencies: [1, 2, 3, 4]

**Effort**: 3-4 hours (actual: ~2 hours)

Update documentation to reflect full completion.

**Tasks**:

1. Update IMPLEMENTATION_STATUS.md ✓
   - Documented Phase 4 partial completion
   - Added ModalS5.lean and ModalS4.lean sections with theorem status
   - Updated module completion percentages and partial module list
   - Added Phase 4 infrastructure blockers documentation

2. Update SORRY_REGISTRY.md ✓
   - Added Phase 4 blocker entries (3 sorry in modal theorems)
   - Documented infrastructure requirements (De Morgan laws, conditional monotonicity, S5 distribution)
   - Updated summary table with new placeholder counts
   - Added Phase 4 status update note

3. Update CLAUDE.md ✓
   - Added deduction_theorem to Metalogic Package section
   - Added modal_5_collapse to ProofSystem Package axioms
   - Documented Phase 4 modal theorems in Theorems Package
   - Corrected Automation Package to show 4/12 tactics (not 12/12)

4. Updated TODO.md ✓
   - Marked Tasks 21-41 as partially complete (8 of 12 proven, 3 blocked)
   - Updated milestone achievement statement
   - Added Phase 6 follow-up milestone

5. Updated plan file ✓
   - Phase 4 marked as PARTIAL (5/8 COMPLETE)
   - Phase 5 marked as COMPLETE
   - Documented remaining work for Phase 6

**Success Criteria**:
- [x] All documentation files updated
- [x] Zero lint warnings
- [x] Build and test pass
- [x] Summary and execution artifacts created

**Deliverables**:
- Updated IMPLEMENTATION_STATUS.md
- Updated SORRY_REGISTRY.md
- Updated CLAUDE.md
- Updated TODO.md
- New/updated test files

---

## Critical Risks and Mitigations

### Risk 1: Deduction Theorem Induction Complexity
**Probability**: Medium
**Impact**: High (blocks Phase 2-4)
**Mitigation**:
- Start with simplified cases (axiom, assumption)
- Use tactical approach (induction tactic with well-founded recursion)
- Consider alternative: prove specific instances without full generality

### Risk 2: S5 Characteristic Not Derivable
**Probability**: Low-Medium
**Impact**: Medium
**Mitigation**:
- First attempt derivation from existing axioms
- If undrivable, add as axiom with soundness proof
- Document axiom extension clearly

### Risk 3: Type Unification Errors in Complex Proofs
**Probability**: Medium
**Impact**: Low-Medium
**Mitigation**:
- Use explicit type annotations
- Unfold definitions (Formula.neg, Formula.and) before combinator applications
- Follow patterns from successful proofs (rcp, t_box_consistency)

---

## Dependency Graph

```
Phase 1 (Deduction Theorem)
    ↓
Phase 2 (lce_imp, rce_imp, classical_merge)
    ↓
Phase 4 (box_disj_intro, box_conj_iff, s4_diamond_box_conj, s5_diamond_conj_diamond)

Phase 3 (S5 Characteristic Axiom) ────────────────────┐
    ↓                                                  ↓
Phase 4 (s5_diamond_box, s5_diamond_box_to_truth, s4_diamond_box_diamond)

Phase 4 (All modal theorems)
    ↓
Phase 5 (Documentation)
```

---

## Testing Strategy

### Unit Tests per Phase

**Phase 1 Tests**:
- test_deduction_axiom_prop_k
- test_deduction_assumption_identity
- test_deduction_mp_composition
- test_deduction_theorem_simple_case
- test_deduction_theorem_nested_case

**Phase 2 Tests**:
- test_lce_imp_simple
- test_rce_imp_simple
- test_classical_merge_simple
- test_classical_merge_nested

**Phase 3 Tests**:
- test_modal_5_collapse_simple
- test_modal_5_collapse_nested
- test_modal_5_collapse_soundness

**Phase 4 Tests**:
- test_box_disj_intro_simple
- test_box_conj_iff_forward
- test_box_conj_iff_backward
- test_diamond_disj_iff_forward
- test_diamond_disj_iff_backward
- test_s5_diamond_box_forward
- test_s5_diamond_box_backward
- test_s5_diamond_box_to_truth
- test_s4_diamond_box_conj
- test_s4_diamond_box_diamond_forward
- test_s4_diamond_box_diamond_backward
- test_s5_diamond_conj_diamond_forward
- test_s5_diamond_conj_diamond_backward

---

## Notes

### Proof Pattern Reuse from Prior Implementation

The following proven patterns from Phase 1 should be heavily reused:
1. `imp_trans` for chaining implications
2. `b_combinator` for composition
3. `theorem_flip` for argument reordering
4. `box_mono` / `diamond_mono` for lifting under modalities
5. `pairing` for conjunction introduction
6. `identity` for reflexivity

### Alternative Approaches if Deduction Theorem Proves Intractable

**Option A: Selective Deduction**
- Prove deduction theorem only for specific derivation shapes needed
- Avoid full generality

**Option B: Axiomatic Extension**
- Add classical_merge as axiom (Peirce's law equivalent)
- Prove soundness via semantics
- Document as classical extension

**Option C: Sequent Calculus**
- Implement parallel proof system with cut-free rules
- Use for context-dependent theorems
- Translate back to Hilbert system

### S4 vs S5 Distinction

After completion:
- ModalS5.lean will contain full S5 theorems (using modal_5 and modal_5_collapse)
- ModalS4.lean will contain S4 theorems (using modal_4 only) plus mixed S4/S5 theorems
- Clear documentation of which theorems require S5 characteristic

---

**Plan Created**: 2025-12-09
**Plan Version**: 1.0
**Prior Plan Reference**: 057_hilbert_propositional_modal_theorems
