# Implementation Plan: Complete Soundness Metalogic for Logos TM Logic

## Metadata
- **Status**: [NOT STARTED]
- **Created**: 2025-12-05
- **Estimated Hours**: 8-15 hours
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean File**: Logos/Core/Theorems/Perpetuity.lean (primary), Logos/Core/Metalogic/Soundness.lean (verification)
- **dependencies**: []

## Executive Summary

**Key Finding**: Soundness is **ALREADY COMPLETE** in `Soundness.lean` with zero sorry placeholders. All 10 axiom validity proofs and all 7 inference rule soundness cases are fully proven.

The remaining work focuses on:
1. **Perpetuity Theorem Fixes** (Phase 1): Rewrite P1 and P3 proofs for correct `always` definition
2. **Documentation Updates** (Phase 2): Correct outdated claims in TODO.md and SORRY_REGISTRY.md
3. **Optional Completeness** (Phase 3): Future work for full metalogic (not required for soundness)

---

## Phase 1: Perpetuity Theorem Proof Fixes [NOT STARTED]

**Purpose**: Fix P1 and P3 proofs that use incorrect `always` definition
**Estimated Hours**: 4-6 hours
**Lean File**: Logos/Core/Theorems/Perpetuity.lean

### Background

The `always` operator was incorrectly assumed to equal `all_future`. The correct definition is:
- `always φ = all_past φ ∧ φ ∧ all_future φ` (φ at all times: past, present, future)
- `△φ = Hφ ∧ φ ∧ Gφ` in notation

### Stage 1.1: Helper Lemma - Conjunction Introduction [NOT STARTED]

- [ ] `theorem_conj_intro_3`: Create three-way conjunction introduction helper
  - Goal: `(A : Formula) → (B : Formula) → (C : Formula) → (⊢ Γ A) → (⊢ Γ B) → (⊢ Γ C) → (⊢ Γ (A ∧ B ∧ C))`
  - Strategy: Use conjunction encoding `A ∧ B = (A.imp (B.imp bot)).imp bot` with K and S axioms
  - Complexity: Medium (requires propositional reasoning)
  - File: Logos/Core/Theorems/Perpetuity.lean lines 70-100
  - dependencies: []

### Stage 1.2: Helper Lemma - Box to Past [NOT STARTED]

- [ ] `theorem_box_to_past`: Derive past component from modal necessity
  - Goal: `(φ : Formula) → ⊢ φ.box.imp φ.all_past`
  - Strategy: Use temporal duality with MB axiom: `□φ → □◇φ` then derive past via time-shift
  - Complexity: Complex (requires modal-temporal interaction)
  - File: Logos/Core/Theorems/Perpetuity.lean (new helper before perpetuity_1)
  - dependencies: []

### Stage 1.3: Fix P1 Proof [NOT STARTED]

- [ ] `theorem_perpetuity_1`: Rewrite to derive full conjunction `□φ → (Hφ ∧ φ ∧ Gφ)`
  - Goal: `(φ : Formula) → ⊢ φ.box.imp φ.always`
  - Strategy:
    1. Derive `□φ → Hφ` using `box_to_past` helper
    2. Derive `□φ → φ` using MT axiom directly
    3. Derive `□φ → Gφ` using MF axiom then MT
    4. Combine with `conj_intro_3` helper
  - Complexity: Medium
  - File: Logos/Core/Theorems/Perpetuity.lean line 127
  - dependencies: [theorem_conj_intro_3, theorem_box_to_past]

### Stage 1.4: Fix P3 Proof [NOT STARTED]

- [ ] `theorem_perpetuity_3`: Rewrite to derive `□φ → □(Hφ ∧ φ ∧ Gφ)`
  - Goal: `(φ : Formula) → ⊢ φ.box.imp (φ.always.box)`
  - Strategy:
    1. From P1: `□φ → (Hφ ∧ φ ∧ Gφ)`
    2. Use modal K distribution over conjunction
    3. Alternatively: derive `□φ → □Hφ`, `□φ → □φ`, `□φ → □Gφ` separately
    4. Combine under single box using modal K
  - Complexity: Medium
  - File: Logos/Core/Theorems/Perpetuity.lean line 205
  - dependencies: [theorem_perpetuity_1]

### Success Criteria - Phase 1

- [ ] Zero sorry placeholders in Perpetuity.lean
- [ ] `lake build` succeeds without errors
- [ ] P1 proves `□φ → (Hφ ∧ φ ∧ Gφ)` using correct always definition
- [ ] P3 proves `□φ → □(Hφ ∧ φ ∧ Gφ)` using modal distribution
- [ ] All existing perpetuity tests continue to pass

---

## Phase 2: Documentation Updates [NOT STARTED]

**Purpose**: Correct outdated claims about soundness status
**Estimated Hours**: 1-2 hours
**Files**: TODO.md, SORRY_REGISTRY.md, IMPLEMENTATION_STATUS.md

### Stage 2.1: Update TODO.md [NOT STARTED]

- [ ] `doc_todo_soundness_status`: Update to reflect complete soundness
  - Goal: Remove claims that soundness has sorry placeholders
  - Strategy: Edit Task 17 status to reflect build success
  - Complexity: Simple
  - File: TODO.md lines 136-166
  - dependencies: []

### Stage 2.2: Update SORRY_REGISTRY.md [NOT STARTED]

- [ ] `doc_sorry_registry_update`: Correct soundness placeholder counts
  - Goal: Mark Soundness.lean as COMPLETE (0 sorry)
  - Strategy: Move Soundness.lean to resolved section
  - Complexity: Simple
  - File: Documentation/ProjectInfo/SORRY_REGISTRY.md
  - dependencies: []

### Stage 2.3: Update IMPLEMENTATION_STATUS.md [NOT STARTED]

- [ ] `doc_implementation_status_update`: Mark soundness as complete
  - Goal: Update Metalogic section to show soundness COMPLETE
  - Strategy: Add completion date and remove "incomplete" markers
  - Complexity: Simple
  - File: Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
  - dependencies: []

### Success Criteria - Phase 2

- [ ] TODO.md accurately reflects soundness is complete
- [ ] SORRY_REGISTRY.md shows 0 sorry for Soundness.lean
- [ ] IMPLEMENTATION_STATUS.md marks soundness as COMPLETE

---

## Phase 3: Optional - Completeness Proofs [NOT STARTED]

**Purpose**: Full metalogic coverage (not required for soundness)
**Estimated Hours**: 70-90 hours (future work)
**Note**: This phase is OPTIONAL and separate from soundness

### Stage 3.1: Lindenbaum's Lemma [NOT STARTED]

- [ ] `theorem_lindenbaum`: Every consistent set extends to maximal consistent set
  - Goal: `(Γ : Context) → Consistent Γ → ∃ Δ, (Γ ⊆ Δ) ∧ MaximalConsistent Δ`
  - Strategy: Use Zorn's lemma via Mathlib's `zorn_subset_nonempty`
  - Complexity: Complex (20-30 hours total for phase)
  - File: Logos/Core/Metalogic/Completeness.lean line 116
  - dependencies: []

### Stage 3.2: Canonical Model Construction [NOT STARTED]

- [ ] `theorem_canonical_frame`: Construct frame satisfying nullity and compositionality
  - Goal: Define `canonical_frame : TaskFrame` with proven properties
  - Strategy: Define task relation from derivability, prove frame axioms
  - Complexity: Complex (20-30 hours total for phase)
  - File: Logos/Core/Metalogic/Completeness.lean lines 199-242
  - dependencies: [theorem_lindenbaum]

### Stage 3.3: Truth Lemma [NOT STARTED]

- [ ] `theorem_truth_lemma`: Membership in MCS iff semantic truth
  - Goal: `φ ∈ Γ ↔ truth_at canonical_model (canonical_history Γ) 0 _ φ`
  - Strategy: Induction on formula structure with modal/temporal saturation lemmas
  - Complexity: Complex (25-30 hours total for phase)
  - File: Logos/Core/Metalogic/Completeness.lean line 297
  - dependencies: [theorem_canonical_frame]

### Stage 3.4: Completeness Theorems [NOT STARTED]

- [ ] `theorem_weak_completeness`: Valid implies provable
  - Goal: `valid φ → Derivable [] φ`
  - Strategy: Contraposition using canonical model counterexample
  - Complexity: Medium
  - File: Logos/Core/Metalogic/Completeness.lean line 326
  - dependencies: [theorem_truth_lemma]

- [ ] `theorem_strong_completeness`: Semantic consequence implies derivability
  - Goal: `semantic_consequence Γ φ → Derivable Γ φ`
  - Strategy: Extend weak completeness with context handling
  - Complexity: Medium
  - File: Logos/Core/Metalogic/Completeness.lean line 346
  - dependencies: [theorem_weak_completeness]

### Success Criteria - Phase 3

- [ ] Zero axiom declarations in Completeness.lean
- [ ] `weak_completeness` proven without sorry
- [ ] `strong_completeness` proven without sorry
- [ ] All completeness tests pass

---

## Verification Commands

```bash
# Verify soundness has zero sorry (should be true already)
grep -c "sorry" Logos/Core/Metalogic/Soundness.lean
# Expected: 0

# Verify perpetuity sorry count before fix
grep -c "sorry" Logos/Core/Theorems/Perpetuity.lean
# Expected: 2 (before), 0 (after Phase 1)

# Full build
lake build

# Run tests
lake test
```

---

## Risk Assessment

### Low Risk
- **Perpetuity Fixes (Phase 1)**: Clear proof strategy, well-understood axioms

### Medium Risk
- **Box to Past Helper**: Modal-temporal interaction requires careful reasoning

### High Risk (Phase 3 only)
- **Truth Lemma Modal Case**: Requires countermodel construction

---

## Dependencies

### External Dependencies
- Mathlib (for Zorn's lemma in Phase 3 only)

### Internal Dependencies
- Phase 1 Stage 1.3 depends on Stages 1.1 and 1.2
- Phase 1 Stage 1.4 depends on Stage 1.3
- Phase 2 can run in parallel with Phase 1
- Phase 3 is independent future work

---

## Notes

1. **Soundness is COMPLETE**: Do not modify Soundness.lean unless bugs are found
2. **Perpetuity proofs are derived theorems**: They depend on soundness, not vice versa
3. **Completeness is separate**: Task 9 is ~70-90 hours of future work
4. **Documentation is outdated**: Priority should be given to Phase 2 updates

---

PLAN_CREATED: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/045_complete_soundness_metalogic_plan/plans/001-complete-soundness-metalogic-plan-plan.md
