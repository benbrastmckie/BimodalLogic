# Handoff: Phase 6 Complete, Phase 7 Analysis

## Session: sess_1778221275_3b41e2
## Date: 2026-05-08

## Phase 6 Completion

Both sorry sites in ChronicleConstruction.lean (formerly at lines 1598 and 1633) are now closed.

### Approach Used

Added `witness_not_old : witness ∉ χ.dom` field to both `C5ForwardWalkResult` and `C5BackwardWalkResult` in CounterexampleElimination.lean. This tracks the Burgess construction property that the walk's witness is always a new point.

Strengthened `EliminationResult.c5_forward_witness` and `c5_backward_witness` return types with an additional conjunct:
```
(y ∉ χ.dom ∨ ∀ u ∈ val.dom, u ∈ χ.dom)
```

This disjunct says: either the witness is new (actual case from walk), or no new points were added (not-actual/identity case where witness already existed in χ.dom).

### Files Modified

1. **CounterexampleElimination.lean**: Added `witness_not_old` to walk result structures and all 3 cases (base, recursive, split) for both forward and backward walks. Added 7th conjunct to c5_forward_witness/c5_backward_witness types and all 8 real construction sites.

2. **ChronicleConstruction.lean**: Updated `omega_chain_c5_witness` and `omega_chain_c5'_witness` return types and proofs. Updated callers in `limit_satisfies_c5_weak`, `limit_satisfies_c5'_weak`, `limit_satisfies_c5_strong`, and `limit_satisfies_c5'_strong`. Fixed `omega_chain_c5_forward_resolved_no_new` and `omega_chain_c5_backward_resolved_no_new` rewrite tactics.

### Sorry Closure Proof

At the sorry sites, the case was: `y ∈ dom_n ∧ w ∈ dom_{n+1} \ dom_n`. The fix uses:
```lean
cases h_new_or_id with
| inl h_new => exact absurd hy_n h_new   -- y ∉ dom_n contradicts hy_n
| inr h_id => exact absurd (h_id w hw_n1) hw_n  -- w ∈ dom_n contradicts hw_n
```

Both disjuncts give contradiction, so the case is impossible.

## Phase 7 Analysis: NoUnivBurgessR3

### Status: IN PROGRESS (research needed)

### Definition
```lean
def NoUnivBurgessR3 : Prop :=
  ∀ A C : Set Formula, SetMaximalConsistent A → SetMaximalConsistent C →
    ¬burgessR3 A Set.univ C
```

### Proof Approach (needs refinement)

`burgessR3(A, Set.univ, C)` means:
- `∀ β, ∀ γ ∈ C, untl(β, γ) ∈ A`
- `∀ β, ∀ α ∈ A, snce(β, α) ∈ C`

A promising approach:
1. Take any γ ∈ C (C is MCS, so nonempty).
2. `untl(γ, γ) ∈ A` and `untl(γ.neg, γ) ∈ A`.
3. BX7 (linearity) gives `untl(γ∧γ.neg, ...) ∈ A` in some disjunct.
4. BX2G (left mono under G) with `G(γ∧γ.neg → ⊥)` gives `untl(⊥, ψ) ∈ A` for some ψ.
5. BX10: `untl(⊥, ψ) → F(ψ)`, so `F(ψ) ∈ A`.
6. If ψ involves a contradiction (like `γ∧γ.neg`), then `F(γ∧γ.neg) ∈ A` contradicts `G(¬(γ∧γ.neg)) ∈ A` (theorem by temporal necessitation).

**Key difficulty**: BX7 gives a 3-way disjunction, and only the second disjunct (event = γ∧γ.neg) gives a contradictory event. The first and third disjuncts have event = γ∧γ, which is non-contradictory.

**Resolution**: After BX2G reduces guard to ⊥, ALL three disjuncts have form `untl(⊥, X)`. Then BX10 gives `F(X)` for each X. For the disjunct with X = γ∧γ.neg, F(γ∧γ.neg) contradicts G(¬(γ∧γ.neg)). For disjuncts with X = γ∧γ, F(γ∧γ) ≈ F(γ) is not contradictory. So we need all disjuncts to produce contradiction, but MCS only guarantees ONE holds.

**Alternative approaches to investigate**:
1. Direct: show `untl(⊥, γ) → ⊥` is a BX theorem (semantically true in dense orders).
2. Use BX14 (separation) with carefully chosen parameters.
3. Exploit the universal quantifier more aggressively.

### Relevant Existing Code

- `burgessR3_univ_of_inconsistent_ext` in PointInsertion.lean (line ~809): Shows how to DERIVE burgessR3(A, Set.univ, C) from burgessR(A, η, C) when {η} is inconsistent. The NoUnivBurgessR3 proof needs the CONVERSE direction.
- `burgessR3Maximal_with_guard` in RRelation.lean (line ~1623): Uses NoUnivBurgessR3 as hypothesis.
- BX10 (`until_F`): `untl(φ,ψ) → F(ψ)`.
- `untl_left_mono_G`: `G(β₁→β₂) → untl(β₁,γ) → untl(β₂,γ)`.

### Remaining Phases

| Phase | Status | Effort |
|-------|--------|--------|
| 7 | IN PROGRESS | 2-4 hours |
| 8 | NOT STARTED | 1 hour |
| 9 | NOT STARTED | 8-12 hours (large refactor) |
| 10 | NOT STARTED | 1-2 hours |
| 11 | NOT STARTED | 1-2 hours |
