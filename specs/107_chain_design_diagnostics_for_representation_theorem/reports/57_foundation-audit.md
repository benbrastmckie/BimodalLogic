# Foundation Audit: Task 107 Phase 1

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Date**: 2026-05-04
- **Phase**: 1 - Foundation Audit and Interface Verification

---

## Executive Summary

All existing infrastructure is correct and ready for implementation. `lemma_2_4`, `lemma_2_6_splitting`, and `lemma_2_7` all return `BurgessR3Maximal` proofs with accessible interval DCS components. The BX axiom MCS-level wrappers are complete. The primary gap is `lemma_2_7_seed_consistent` (Phase 3), which is the single blocker on the critical path.

---

## Task 1.1: Audit `lemma_2_4`

**Location**: PointInsertion.lean:153-173

**Return type**:
```lean
∃ B C : Set Formula, SetMaximalConsistent C ∧
  β ∈ C ∧ g_content A ⊆ C ∧
  Formula.some_past (Formula.untl γ β) ∈ C ∧
  BurgessR3Maximal A B C
```

**Assessment**: The interval DCS `B` is returned as the first component with `BurgessR3Maximal A B C` proof. `C` is the endpoint MCS. Both components are accessible. No restructuring needed.

**Current usage in eliminate_C5_counterexample** (CounterexampleElimination.lean:182-183):
```lean
obtain ⟨_B, C, h_C_mcs, h_η_C, _, _, _⟩ := lemma_2_4 h_mcs_x ce.ξ ce.η ce.until_mem
```
Note that `_B` is discarded (underscore-prefixed). This is the exact gap that Phases 4-5 will fix: the interval DCS B needs to be stored as `g'(x, y)`.

---

## Task 1.2: Audit `lemma_2_6_splitting`

**Location**: PointInsertion.lean:2328-2376

**Return type**:
```lean
∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧
  SetMaximalConsistent D ∧ β.neg ∈ D
```

**Assessment**: Returns three components `B'`, `D`, `B''` with `BurgessR3Maximal` proofs for both new adjacent pairs. Callers can extract each component. `lemma_2_6_splitting` is sorry-free.

**Dependencies checked**:
- `burgess_D0_seed_consistent` (line 2276-2318): Sorry-free. Relies on `burgess_D0_finite_subset_consistent` (consistent case) and `burgess_D0_finite_subset_consistent_incons` (inconsistent case).
- `burgessR3Maximal_extension_exists`: Called at lines 2372-2375 from RRelation.lean.

---

## Task 1.3: Verify BX Axiom MCS-Level Wrappers

| BX Axiom | MCS-Level Wrapper | Location | Status |
|----------|------------------|----------|--------|
| BX2 (left_mono_until) | `untl_left_mono_thm` | RRelation.lean:1019 | Present |
| BX3 (right_mono_until) | `right_mono_until_mcs` | PointInsertion.lean:918 | Present |
| BX5 (self_accum_until) | `self_accum_until_mcs` | PointInsertion.lean:189 | Present |
| BX7 (linear_until) | Via `theorem_in_mcs` + `Axiom.linear_until` | RRelation.lean:929-968 (`untl_conj_guard`) | Present (inline usage pattern) |
| BX10 (until_F) | `until_F_mcs` / `until_implies_F_mcs` | PointInsertion.lean:179 / 1000 | Present |
| BX13 (enrichment_until) | `enrichment_until_mcs` | PointInsertion.lean:988 | Present |
| BX14 (separation_until) | `separation_until_mcs` | PointInsertion.lean:976 | Present |

**Note on BX7**: There is no standalone `linear_until_mcs` wrapper. BX7 is used through `theorem_in_mcs` + `DerivationTree.axiom [] _ (Axiom.linear_until ...)`. This pattern is sufficient and is already used in `untl_conj_guard` (RRelation.lean:937-938). The same pattern will work for Phase 3.

---

## Task 1.4: Verify `iterated_enrichment` Compatibility

**Location**: PointInsertion.lean:1218-1243

**Signature**:
```lean
iterated_enrichment {A : Set Formula} (h_mcs : SetMaximalConsistent A)
  (guard : Formula) (alphas : List Formula) (h_alphas : ∀ α ∈ alphas, α ∈ A)
  (event : Formula) (h_untl : Formula.untl guard event ∈ A) :
  EnrichedEvent A guard event alphas
```

**Compatibility with Lemma 2.6**: Uses `guard = q = b ∧ untl(b, γ)` and `alphas` = list of formulas from A. Enriches event with `snce(guard, α)` for each α. ✓

**Compatibility with Lemma 2.7**: Same pattern. `iterated_enrichment` takes any guard and event, enriches with snce formulas. In Lemma 2.7, the guard will be `φ₁∧φ₂` (from surviving D₃) and the event will be the base event from BX14 separation. ✓

**Result**: `iterated_enrichment` is generic enough for both Lemma 2.6 and Lemma 2.7 patterns.

---

## Task 1.5: Argument-Order Convention Comments

**Existing comments found at**:
- PointInsertion.lean:1-50 (header): Documents BX adaptations, open guard semantics, and `untl(guard, event)` convention
- CounterexampleElimination.lean:1-33 (header): Documents counterexample elimination
- ChronicleTypes.lean:7-55 (header): Documents chronicle structure and r-relations
- ChronicleToCountermodel.lean:1-15 (header): Documents countermodel construction

**Assessment**: The header comments in each file already document the argument-order convention (`untl(guard, event)` vs Burgess `U(event, guard)`). The convention is well-established throughout the codebase. Additional per-function comments are not needed.

---

## Build Verification

`lake build` passes at Phase 1 start. All existing code compiles with 12 sorries in the Chronicle directory.

---

## Gaps Identified

1. **No standalone BX7 MCS wrapper**: BX7 is used inline via `theorem_in_mcs` + `Axiom.linear_until`. This is adequate but the three-way disjunction elimination pattern needs careful implementation in Phase 3.

2. **eliminate_C5_counterexample discards g-value**: The B from `lemma_2_4` is prefixed with underscore (`_B`) and not stored in `g`. This is addressed in Phase 5.

3. **eliminate_C4_counterexample returns `χ.g` unchanged**: Both the forward and backward C4 elimination functions return `(∀ a b, χ'.g a b = χ.g a b)`. This is addressed in Phase 4.

4. **lemma_2_7_seed_consistent is a sorry**: This is the single Phase 3 task.

---

## Phase 1 Conclusion

All foundation infrastructure is verified and correct. Ready to proceed to Phase 2.
