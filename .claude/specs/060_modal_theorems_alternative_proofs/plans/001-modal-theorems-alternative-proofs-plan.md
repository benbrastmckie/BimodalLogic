# Lean Implementation Plan: Modal Theorems Alternative Proofs

## Metadata
- **Date**: 2025-12-09
- **Feature**: Complete blocked modal theorems using alternative proof strategies based on valid K distribution
- **Scope**: Prove 3 remaining sorry placeholders (diamond_disj_iff, s4_diamond_box_conj, s5_diamond_conj_diamond) using `□(A → B) → (◇A → ◇B)` pattern
- **Status**: [IN PROGRESS]
- **Estimated Hours**: 12-16 hours
- **Complexity Score**: 24
- **Structure Level**: 0
- **Estimated Phases**: 5
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Prior Plan**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/059_modal_theorems_s5_completion/plans/001-modal-theorems-s5-completion-plan.md
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Key Discovery: Valid K Distribution for Diamond

The fundamental insight from Plan 059 was that `(φ → ψ) → (◇φ → ◇ψ)` is NOT valid as an object-level theorem.

**However**, `□(φ → ψ) → (◇φ → ◇ψ)` IS valid and derivable from axiom K!

This theorem, called `k_dist_diamond` or sometimes "diamond version of K", is derived via:
1. K axiom: `□(A → B) → (□A → □B)`
2. Contraposition and duality: `□(A → B) → (◇A → ◇B)`

This provides the foundation for all blocked theorems.

## Success Criteria

### Module Completion
- [ ] `k_dist_diamond` proven (new infrastructure)
- [ ] `diamond_disj_iff` proven with zero sorry
- [ ] `s4_diamond_box_conj` proven with zero sorry
- [ ] `s5_diamond_conj_diamond` proven with zero sorry
- [ ] All helper lemmas proven

### Quality Standards
- [ ] Zero `#lint` warnings in modified modules
- [ ] Build time <3 minutes total
- [ ] All new theorems have docstrings with mathematical statements
- [ ] All theorems include complexity classification (Simple/Medium/Complex)

### Documentation
- [ ] IMPLEMENTATION_STATUS.md updated
- [ ] SORRY_REGISTRY.md updated (remove 5 sorry entries)
- [ ] CLAUDE.md updated with new infrastructure

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

### Phase 1: K Distribution for Diamond [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean
dependencies: []

**Effort**: 3-4 hours

Derive the valid K distribution theorem for diamond: `□(A → B) → (◇A → ◇B)`.

**Background**:
This is a fundamental theorem in modal logic K that follows from the K axiom via duality and contraposition:
- K axiom: `□(A → B) → (□A → □B)`
- By substituting and using duality `◇X = ¬□¬X`, we can derive the diamond version

**Theorem Specifications**:

- [x] `theorem k_dist_diamond`
  - Goal: `⊢ (A.imp B).box.imp (A.diamond.imp B.diamond)`
  - Strategy:
    1. Start with K axiom for `¬B, ¬A`: `□(¬B → ¬A) → (□¬B → □¬A)`
    2. Contraposition: `(A → B) ↔ (¬B → ¬A)`, so `□(A → B) → (□¬B → □¬A)`
    3. Duality: `□¬B = ¬◇B`, `□¬A = ¬◇A`
    4. So: `□(A → B) → (¬◇B → ¬◇A)`
    5. Contraposing consequent: `□(A → B) → (◇A → ◇B)`
  - Complexity: Medium
  - Dependencies: K axiom (modal_k_dist), box_contrapose, double_negation
  - Target LOC: 40-60 lines
  - Location: ModalS5.lean (new, after diamond_mono_imp documentation)

- [x] `theorem box_imp_to_diamond_imp`
  - Goal: `⊢ (A.box.imp B.box).imp (B.diamond.imp A.diamond)` (contraposition for modal)
  - Strategy: Helper for k_dist_diamond derivation
  - Complexity: Simple
  - Target LOC: 20-30 lines

**Success Criteria**:
- [x] k_dist_diamond proven with zero sorry
- [x] Helper lemmas proven
- [x] Docstring explains derivation from K axiom
- [x] Build passes

**Deliverables**:
- Updated ModalS5.lean with ~80 new lines of K distribution infrastructure

---

### Phase 2: Biconditional Infrastructure [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
dependencies: []

**Effort**: 2-3 hours

Add helper lemmas for biconditional manipulation under negation.

**Theorem Specifications**:

- [x] `theorem contrapose_iff`
  - Goal: `(⊢ iff A B) → (⊢ iff A.neg B.neg)`
  - Strategy: From `A ↔ B`, derive both `¬A → ¬B` and `¬B → ¬A` using contraposition
  - Complexity: Medium
  - Dependencies: contrapose_imp, iff_intro, lce_iff, rce_iff
  - Target LOC: 30-40 lines

- [x] `theorem iff_neg_intro`
  - Goal: `(⊢ A.neg.imp B.neg) → (⊢ B.neg.imp A.neg) → (⊢ iff A.neg B.neg)`
  - Strategy: Direct application of iff_intro
  - Complexity: Simple
  - Target LOC: 10-15 lines

- [x] `theorem box_iff_intro`
  - Goal: `(⊢ iff A B) → (⊢ iff A.box B.box)`
  - Strategy: Apply box_mono to both directions
  - Complexity: Simple
  - Dependencies: box_mono, lce_iff, rce_iff, iff_intro
  - Target LOC: 20-30 lines

**Success Criteria**:
- [x] All helper lemmas proven with zero sorry
- [x] Build passes
- [x] Tests verify biconditional manipulation

**Deliverables**:
- Updated Propositional.lean with ~70 new lines of biconditional infrastructure

---

### Phase 3: Complete diamond_disj_iff [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean
dependencies: [1, 2]

**Effort**: 4-5 hours

Complete diamond_disj_iff using duality chain rather than direct monotonicity.

**Background**:
The proof proceeds through negation/duality transformations:
1. `◇(A ∨ B) = ¬□¬(A ∨ B)` (duality)
2. `¬(A ∨ B) = (¬A ∧ ¬B)` (De Morgan, already proven)
3. So `◇(A ∨ B) = ¬□(¬A ∧ ¬B)`
4. By box_conj_iff: `□(¬A ∧ ¬B) ↔ (□¬A ∧ □¬B)`
5. So `¬□(¬A ∧ ¬B) ↔ ¬(□¬A ∧ □¬B)`
6. By De Morgan: `¬(□¬A ∧ □¬B) ↔ (¬□¬A ∨ ¬□¬B)`
7. By duality: `(¬□¬A ∨ ¬□¬B) = (◇A ∨ ◇B)`

**Theorem Specifications**:

- [x] `theorem diamond_disj_iff` (replace existing sorry)
  - Goal: `⊢ iff (A.or B).diamond (A.diamond.or B.diamond)`
  - Strategy:
    - Forward: `◇(A ∨ B) → (◇A ∨ ◇B)` via duality chain above
    - Backward: `(◇A ∨ ◇B) → ◇(A ∨ B)` via reverse duality chain
  - Complexity: Complex
  - Dependencies: demorgan_conj_neg, demorgan_disj_neg, box_conj_iff, contrapose_iff
  - Target LOC: 100-150 lines
  - Location: ModalS5.lean:483-527 (replace existing sorry proof)

**Key Implementation Steps**:

1. **Forward direction** `◇(A ∨ B) → (◇A ∨ ◇B)`:
   - Unfold `◇(A ∨ B)` to `¬□¬(A ∨ B)`
   - Apply `demorgan_disj_neg` to get `¬□(¬A ∧ ¬B)`
   - Use `box_conj_iff` backward: `(□¬A ∧ □¬B) → □(¬A ∧ ¬B)`
   - Contrapose to get: `¬□(¬A ∧ ¬B) → ¬(□¬A ∧ □¬B)`
   - Apply `demorgan_conj_neg` forward: `¬(□¬A ∧ □¬B) → (¬□¬A ∨ ¬□¬B)`
   - Unfold to `(◇A ∨ ◇B)`

2. **Backward direction** `(◇A ∨ ◇B) → ◇(A ∨ B)`:
   - Reverse the chain above

**Success Criteria**:
- [x] diamond_disj_iff proven with zero sorry
- [x] Both directions work correctly
- [x] Proof follows duality pattern (not monotonicity)
- [x] Build passes

**Deliverables**:
- Updated ModalS5.lean with proven diamond_disj_iff (~120 lines replacing sorry)

---

### Phase 4: Complete S4/S5 Diamond Theorems [IN PROGRESS]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS4.lean
dependencies: [1, 2, 3]

**Effort**: 4-5 hours

Complete s4_diamond_box_conj and s5_diamond_conj_diamond using k_dist_diamond.

**Background**:
Both theorems can be proven using the pattern:
1. Establish `□(A → C)` for appropriate C
2. Apply `k_dist_diamond`: `□(A → C) → (◇A → ◇C)`
3. Use modus ponens with `◇A`

**Theorem Specifications**:

- [ ] `theorem s4_diamond_box_conj` (replace existing sorry)
  - Goal: `⊢ (A.diamond.and B.box).imp ((A.and B.box).diamond)`
  - Strategy:
    1. From `□B`, derive `□(A → (A ∧ □B))`:
       - `pairing`: `⊢ A → B → (A ∧ B)`
       - Substitute `□B` for B: `⊢ A → □B → (A ∧ □B)`
       - `theorem_flip`: `⊢ □B → (A → (A ∧ □B))`
       - Modal K dist: `□□B → □(A → (A ∧ □B))`
       - Axiom 4: `□B → □□B`
       - Compose to get: `□B → □(A → (A ∧ □B))`
    2. Apply `k_dist_diamond`: `□(A → (A ∧ □B)) → (◇A → ◇(A ∧ □B))`
    3. Compose: `□B → (◇A → ◇(A ∧ □B))`
    4. Extract from conjunction premise
  - Complexity: Complex
  - Dependencies: k_dist_diamond, pairing, theorem_flip, modal_4, lce_imp, rce_imp
  - Target LOC: 80-100 lines
  - Location: ModalS4.lean:61-76 (replace existing sorry)

- [ ] `theorem box_pairing_lift`
  - Goal: `⊢ C.box.imp (A.imp (A.and C.box)).box`
  - Strategy: Helper that lifts pairing pattern into box
  - Complexity: Medium
  - Target LOC: 40-50 lines

- [ ] `theorem s5_diamond_conj_diamond` (replace existing sorry)
  - Goal: `⊢ iff ((A.and B.diamond).diamond) (A.diamond.and B.diamond)`
  - Strategy:
    - **Forward** `◇(A ∧ ◇B) → (◇A ∧ ◇B)`:
      1. `◇(A ∧ ◇B)` implies `◇A` via `lce_imp` under diamond
      2. `◇(A ∧ ◇B)` implies `◇◇B` via `rce_imp` under diamond
      3. In S5: `◇◇B → ◇B` (using duality + modal_5_collapse on ¬B)
      4. Combine with pairing
    - **Backward** `(◇A ∧ ◇B) → ◇(A ∧ ◇B)`:
      1. From `◇B`, use `modal_5`: `◇B → □◇B`
      2. From `□◇B`, derive `□(A → (A ∧ ◇B))`:
         - `pairing`: `A → ◇B → (A ∧ ◇B)`
         - `theorem_flip`: `◇B → (A → (A ∧ ◇B))`
         - `box_mono`: `□◇B → □(A → (A ∧ ◇B))`
      3. Apply `k_dist_diamond`: `□(A → (A ∧ ◇B)) → (◇A → ◇(A ∧ ◇B))`
      4. Compose with `◇A` from hypothesis
  - Complexity: Complex
  - Dependencies: k_dist_diamond, modal_5, lce_imp, rce_imp, pairing, box_mono
  - Target LOC: 100-130 lines
  - Location: ModalS4.lean:244-246 (replace existing sorry)

- [ ] `theorem diamond_diamond_collapse`
  - Goal: `⊢ A.diamond.diamond.imp A.diamond`
  - Strategy: Using S5: `◇◇A → ◇A` via duality and modal_5_collapse
  - Complexity: Medium
  - Target LOC: 30-40 lines

**Success Criteria**:
- [ ] s4_diamond_box_conj proven with zero sorry
- [ ] s5_diamond_conj_diamond proven with zero sorry
- [ ] All helper lemmas proven
- [ ] Build passes

**Deliverables**:
- Updated ModalS4.lean with ~250 new lines replacing sorry placeholders

---

### Phase 5: Documentation and Cleanup [NOT STARTED]
implementer: software
dependencies: [1, 2, 3, 4]

**Effort**: 2-3 hours

Update all documentation to reflect completed theorems.

**Tasks**:

1. Update IMPLEMENTATION_STATUS.md
   - [ ] Mark ModalS5.lean as complete
   - [ ] Mark ModalS4.lean as complete (Phase 4 modal theorems)
   - [ ] Update theorem counts
   - [ ] Remove blockers section for these theorems

2. Update SORRY_REGISTRY.md
   - [ ] Remove diamond_mono_imp entry (document as invalid, not sorry)
   - [ ] Remove diamond_mono_conditional entry (replaced by k_dist_diamond)
   - [ ] Remove diamond_disj_iff entry
   - [ ] Remove s4_diamond_box_conj entry
   - [ ] Remove s5_diamond_conj_diamond entry
   - [ ] Add note about alternative proof strategy discovery

3. Update CLAUDE.md
   - [ ] Add k_dist_diamond to Theorems Package section
   - [ ] Update modal theorem status to complete
   - [ ] Document the discovery about valid vs invalid monotonicity

4. Update Plan 059
   - [ ] Add reference to Plan 060 as successor
   - [ ] Mark as superseded by Plan 060

**Success Criteria**:
- [ ] All documentation files updated and consistent
- [ ] Zero lint warnings across all modified files
- [ ] Build and test pass
- [ ] Summary artifacts created

**Deliverables**:
- Updated IMPLEMENTATION_STATUS.md
- Updated SORRY_REGISTRY.md
- Updated CLAUDE.md
- Summary artifacts in summaries/ directory

---

## Critical Risks and Mitigations

### Risk 1: k_dist_diamond Derivation Complexity
**Probability**: Medium
**Impact**: High (blocks all subsequent phases)
**Mitigation**:
- Follow established derivation pattern from modal logic literature
- Test intermediate steps with `#check`
- Consider alternative derivation via direct duality manipulation

### Risk 2: Formula Alignment in diamond_disj_iff
**Probability**: Medium
**Impact**: Medium
**Mitigation**:
- Work entirely through negation forms
- Use explicit type annotations
- Build helper lemmas for each transformation step
- Follow De Morgan → box_conj_iff → De Morgan chain exactly

### Risk 3: S5 Axiom Interactions
**Probability**: Low
**Impact**: Medium
**Mitigation**:
- modal_5 and modal_5_collapse are already proven
- Test axiom compositions with simple formula instances first
- Document S5-specific reasoning clearly

---

## Dependency Graph

```
Phase 1 (k_dist_diamond)
    ↓
    ├─────────────────────────┐
    ↓                         ↓
Phase 2 (biconditional)   Phase 4 (S4/S5 theorems, partial)
    ↓                         ↓
Phase 3 (diamond_disj_iff) ←──┘
    ↓
Phase 4 (remaining S4/S5 theorems)
    ↓
Phase 5 (Documentation)
```

**Critical Path**: Phase 1 → Phase 4 (s4_diamond_box_conj) [shortest path to unblock theorems]

**Parallelization**: Phase 2 and parts of Phase 4 can proceed in parallel after Phase 1

---

## Testing Strategy

### Unit Tests per Phase

**Phase 1 Tests** (ModalS5.lean):
- test_k_dist_diamond_simple
- test_k_dist_diamond_nested
- test_k_dist_diamond_composition

**Phase 2 Tests** (Propositional.lean):
- test_contrapose_iff
- test_box_iff_intro

**Phase 3 Tests** (ModalS5.lean):
- test_diamond_disj_iff_forward
- test_diamond_disj_iff_backward
- test_diamond_disj_iff_biconditional

**Phase 4 Tests** (ModalS4.lean):
- test_s4_diamond_box_conj
- test_s5_diamond_conj_diamond_forward
- test_s5_diamond_conj_diamond_backward

---

## Notes

### Key Insight: Valid vs Invalid Monotonicity

**INVALID** (object-level):
```
(φ → ψ) → (◇φ → ◇ψ)
```
Counter-model exists in S5.

**VALID** (boxed antecedent):
```
□(φ → ψ) → (◇φ → ◇ψ)
```
Derivable from K axiom via duality.

The solution is to "box the implication" before applying monotonicity reasoning.

### Proof Pattern for Blocked Theorems

All three blocked theorems follow this pattern:
1. From hypothesis, derive `□(A → C)` for target conjunction C
2. Apply `k_dist_diamond`: `□(A → C) → (◇A → ◇C)`
3. Use modus ponens to get `◇C`

The challenge is deriving `□(A → C)` from the available hypotheses.

### Infrastructure Reuse

**From Plan 058 (available)**:
- `demorgan_conj_neg`, `demorgan_disj_neg` (Phase 1 complete)
- `box_conj_iff` (proven)
- `modal_5`, `modal_5_collapse` (proven)
- `pairing`, `theorem_flip`, `b_combinator` (proven)

**New (this plan)**:
- `k_dist_diamond` (Phase 1)
- `contrapose_iff`, `box_iff_intro` (Phase 2)
- Various box-lifting helpers (Phase 4)

---

## References

1. [Modal Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-modal/)
2. [S5 Modal Logic - Wikipedia](https://en.wikipedia.org/wiki/S5_(modal_logic))
3. [Modal Logic - Wikipedia](https://en.wikipedia.org/wiki/Modal_logic)
4. [FormalizedFormalLogic/Foundation - GitHub](https://github.com/FormalizedFormalLogic/Foundation)
5. Research Report: 001-alternative-proof-strategies.md

---

**Plan Created**: 2025-12-09
**Plan Version**: 1.0
**Prior Plan Reference**: 059_modal_theorems_s5_completion
**Research Reports**: 1 (Alternative proof strategies)
