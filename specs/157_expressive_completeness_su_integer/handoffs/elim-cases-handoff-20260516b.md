# Elimination Cases Handoff - 2026-05-16 (Session B)

## Session: sess_1778987529_aeb59c

## Summary

Proved `elim_case_1` (Case 1: S(a ^ U(A,B), q)) with full GHR94 semantic argument. This is the foundational direct elimination case. The remaining 7 cases (2-8) each require comparable semantic proofs.

## What Was Done

### Case 1 Proof Structure
- **Separated formula**: `case1_psi a q A B` defined as three disjuncts:
  - `[S(a,q) ^ S(a,B) ^ B ^ U(A,B)]` (U-witness after t)
  - `[A ^ S(a,B) ^ S(a,q)]` (U-witness AT t)
  - `S(A ^ q ^ S(a,B) ^ S(a,q), q)` (U-witness before t)
- **Forward direction**: Uses `lt_trichotomy u t` on the U-witness
- **Backward direction**: For each disjunct, constructs the S-witness by picking the later of two since-witnesses (`by_cases hle : s₁ ≤ s₂`) and fills the B-guard using `lt_trichotomy r t`
- **Separation check**: `simp` on the formula structure + `u_free_s_free_imp_separated` for A, B

### Helper Lemmas Added
- `int_truth_and_iff`: `int_truth M t (Formula.and φ ψ) ↔ int_truth M t φ ∧ int_truth M t ψ`
- `int_truth_or_iff`: `int_truth M t (Formula.or φ ψ) ↔ int_truth M t φ ∨ int_truth M t ψ`
- `int_truth_neg_iff`: `int_truth M t (Formula.neg φ) ↔ ¬ int_truth M t φ`
- `u_free_s_free_imp_separated`: U-free + S-free → syntactically separated

## Remaining Cases

### Case 2: S(a ^ ¬U(A,B), q) — READY TO PROVE
Strategy confirmed working:
1. `neg_until_equiv`: ¬U(A,B) ↔ G(¬A) ∨ U(¬A∧¬B, ¬A)
2. Distribute S over ∨ in event: `S(a ^ G(¬A), q) ∨ S(a ^ U(¬A∧¬B, ¬A), q)`
3. First disjunct already separated (G(¬A) is both U-free and S-free)
4. Second disjunct is Case 1 with arguments (¬A∧¬B, ¬A)
5. Verified: ¬A, ¬B, ¬A∧¬B are all U-free and S-free when A, B are

Key helper needed: `since_and_or_distrib` to distribute S over "and-or" in event.

### Case 5: S(a ^ U(A,B), q ∨ U(A,B)) — BLOCKED
Requires "cascading U-witness" well-ordering argument:
- When u < t, the guard q∨U(A,B) on (u,t) creates a chain of U-witnesses
- By well-ordering of Z, this chain must reach ≥ t or q covers the remaining interval
- Attempted formula: `case1_psi ∨ (S(a,B)∧B∧U(A,B)) ∨ (A∧S(a,B))`
- BLOCKER: Backward direction of 4th disjunct has gap at witness point w

### Cases 3, 4: S(a, q ∨ U(A,B)) and S(a, q ∨ ¬U(A,B))
- Case 4: Use neg_until_equiv on ¬U(A,B) in guard, then semantic argument
- Case 3: Dual approach or direct argument

### Cases 6, 7, 8: Combinations
- Case 6: S(a ^ ¬U(A,B), q ∨ U(A,B)) — combines Cases 2 and 5 structure
- Case 7: S(a ^ U(A,B), q ∨ ¬U(A,B)) — combines Cases 1 and 4 structure
- Case 8: S(a ^ ¬U(A,B), q ∨ ¬U(A,B)) — dual of Case 5

## Key Proof Pattern

For each case, the proof follows this structure:
```lean
theorem elim_case_N ... := by
  refine ⟨target_formula, ?_, ?_⟩
  · -- Semantic equivalence
    intro M t
    simp only [target_formula_def]  -- if using a def
    constructor
    · -- Forward: unfold with int_truth_and_iff etc, then case-split
      intro ⟨s, hst, hand, hguard⟩
      have ⟨..., ...⟩ := int_truth_and_iff.mp hand
      rcases lt_trichotomy ... with ... | ... | ...
      · -- Each branch: apply int_truth_or_iff.mpr, rw [int_truth_and_iff], exact ⟨...⟩
    · -- Backward: destructure each disjunct
      intro hrhs
      rcases int_truth_or_iff.mp hrhs with ... | ...
      · -- Reconstruct since-witness from disjunct data
  · -- Separation check
    simp [target_formula_def, Formula.and, Formula.or, Formula.neg,
          is_syntactically_separated, is_U_free, ha, hq, hA, hB, ...]
    exact ⟨u_free_s_free_imp_separated ..., ...⟩
```

## File State

- `Eliminations.lean`: ~305 lines, 7 sorry (Cases 2-8)
- Build passes with warnings only
- Case 1 uses `set_option maxHeartbeats 800000`

## Next Steps (Priority Order)

1. Prove Case 2 (reduces to neg_until_equiv + Case 1)
2. Prove Cases 3, 4 (direct semantic or neg_until_equiv reduction)
3. Prove Cases 6, 7, 8 (combinations of earlier cases)
4. Prove Case 5 (hardest remaining, needs well-ordering cascade)
5. Once all 8 proved: DualEliminations follow (but need different approach — `is_S_free` conclusion)
