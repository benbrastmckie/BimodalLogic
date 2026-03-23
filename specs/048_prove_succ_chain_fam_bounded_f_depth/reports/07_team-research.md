# Research Report: Task #48 - Well-Founded Recursion for Persistence Case

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)
**Session**: sess_1774298996_dd353b
**Focus**: Mathematically correct solution for `restricted_forward_chain_iter_F_witness` persistence case

## Summary

Both teammates independently converged on the same solution with HIGH confidence: the persistence case terminates because `deferralClosure(phi)` is finite, bounding the number of persistence steps. The recommended implementation uses an explicit fuel parameter bounded by `closure_F_bound phi`, with a contradiction at fuel exhaustion.

## Key Findings

### 1. The Mathematical Termination Argument (Both Teammates)

The persistence case occurs when `F(psi) ∈ M_n`, `psi ∉ M_n`, and the F-nesting depth doesn't decrease. The key insight:

- `deferralClosure(phi)` is a `Finset` (finite)
- `iter_F d psi ∈ deferralClosure(phi)` requires `d < closure_F_bound phi`
- If persistence runs for `closure_F_bound phi` steps without depth decrease, `iter_F` would leave `deferralClosure`, contradicting the restricted chain membership
- Therefore persistence is bounded by `closure_F_bound phi`

This is the standard "finite model property" argument from temporal logic (Goldblatt, Venema, BdRV).

### 2. The Correct Well-Founded Order

**Lexicographic on `(d, remaining_fuel)`** where:
- `d` = current F-nesting depth (decreases in `inl` case)
- `remaining_fuel` = `closure_F_bound phi - persistence_count` (decreases in `inr` case)

### 3. Existing Infrastructure Sufficient

All required lemmas already exist in the codebase:

| Lemma | File | Purpose |
|-------|------|---------|
| `iter_F_not_mem_deferralClosure` | RestrictedMCS.lean | iter_F leaves closure at bound |
| `closure_F_bound` | CanonicalTaskRelation.lean | Explicit bound value |
| `restricted_forward_chain_F_step_witness` | SuccChainFMCS.lean | F-step dichotomy |
| `deferral_restricted_mcs_F_bounded` | RestrictedMCS.lean | Bounded in restricted MCS |

### 4. Lean 4 Implementation Available

Mathlib provides:
- `WellFounded.prod_lex` for lexicographic well-foundedness
- `Nat.strong_induction_on` for strong induction
- `InvImage.wf` for custom measure projection

## Recommended Approach: Explicit Fuel Parameter

**Both teammates agree this is the simplest correct approach.** Teammate A recommends it as "most straightforward"; Teammate B as "simpler but effective".

### Proof Structure

```lean
private theorem restricted_forward_chain_iter_F_witness_fuel (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d fuel : Nat) (psi : Formula)
    (h_d_ge : d >= 1)
    (h_iter : iter_F d psi ∈ (restricted_forward_chain phi M0 k).world)
    (h_fuel_bound : d + fuel >= closure_F_bound phi) :
    ∃ m : Nat, k < m ∧ psi ∈ (restricted_forward_chain phi M0 m).world := by
  induction fuel generalizing k d with
  | zero =>
    -- d >= closure_F_bound phi
    -- iter_F d psi ∉ deferralClosure phi (by iter_F_not_mem_deferralClosure)
    -- But iter_F d psi ∈ M_k ⊆ deferralClosure phi (by DeferralRestrictedMCS)
    -- Contradiction
    exfalso
    have h_not := iter_F_not_mem_deferralClosure phi d (by omega)
    have h_in := restricted_forward_chain_in_deferralClosure phi M0 k h_iter
    exact h_not h_in
  | succ fuel' ih =>
    -- Get F-step result for iter_F (d-1) psi at position k
    have h_step := restricted_forward_chain_F_step_witness phi M0 k (iter_F (d-1) psi) ...
    cases h_step with
    | inl h_inner =>
      -- Depth decrease: iter_F (d-1) psi ∈ M_{k+1}
      -- If d = 1: psi ∈ M_{k+1}, done (⟨k+1, by omega, h_inner⟩)
      -- If d > 1: apply IH with d-1 < d (still have same fuel bound)
      ...
    | inr h_persist =>
      -- Persistence: iter_F d psi ∈ M_{k+1}
      -- Apply IH with fuel' (fuel decreased, d unchanged)
      -- h_fuel_bound: d + fuel' + 1 >= closure_F_bound phi
      -- so d + fuel' >= closure_F_bound phi - 1 >= ... need to check
      exact ih (k + 1) d h_persist (by omega)
```

### Entry Point

```lean
theorem restricted_forward_chain_iter_F_witness (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (psi : Formula)
    (h_d_ge : d >= 1)
    (h_iter : iter_F d psi ∈ (restricted_forward_chain phi M0 k).world) :
    ∃ m : Nat, k < m ∧ psi ∈ (restricted_forward_chain phi M0 m).world :=
  restricted_forward_chain_iter_F_witness_fuel phi M0 k d
    (closure_F_bound phi - d) psi h_d_ge h_iter (by omega)
```

### Key Lemma Required

```lean
-- May need: chain membership implies deferralClosure membership
theorem restricted_forward_chain_in_deferralClosure (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) {psi : Formula}
    (h : psi ∈ (restricted_forward_chain phi M0 k).world) :
    psi ∈ (deferralClosure phi : Set Formula) :=
  (restricted_forward_chain phi M0 k).h_restricted h
```

## Alternative: Lexicographic WellFounded.fix

If the fuel pattern is awkward, use lexicographic recursion:

```lean
-- Measure: (d, closure_F_bound phi - persistence_count)
-- Use WellFounded.prod_lex Nat.lt_wf Nat.lt_wf
-- In inl case: first component decreases
-- In inr case: first component same, second decreases
```

Both teammates consider this more elegant but harder to implement in Lean 4.

## Synthesis

### Conflicts Resolved

| Topic | Teammate A | Teammate B | Resolution |
|-------|-----------|-----------|------------|
| Primary approach | Fuel parameter | Lexicographic measure | **Fuel parameter** - both agree it's simpler; use lexicographic as alternative |
| Fuel bound | `closure_F_bound phi` | `deferralClosure.card` | **`closure_F_bound phi`** - more precise, directly available |
| Key contradiction | `iter_F_not_mem_deferralClosure` | Negation completeness | Both contribute: closure bound provides the contradiction, negation completeness explains why |

### Gaps Identified

1. **`restricted_forward_chain_in_deferralClosure`** may need to be proven (or may already exist as `h_restricted`)
2. **Inner induction on d** within the `inl` case needs careful handling - the existing strong induction should work
3. **The exact signature** of the fuel theorem needs to be tested in Lean to ensure types line up

### Recommendations

1. **Implement the fuel pattern first** - it's the simplest correct approach
2. **Prove the entry point wrapper** that calls the fuel version with `closure_F_bound phi - d`
3. **The fuel=0 base case** is the mathematical heart - derive contradiction from `iter_F_not_mem_deferralClosure`
4. **Test incrementally** - prove the base case first, then the recursive case

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Mathematical Foundation | completed | HIGH |
| B | Lean 4 Patterns | completed | HIGH |

## References

- Goldblatt, "Logics of Time and Computation" - temporal logic completeness
- Venema, "Temporal Logic" - closure-based model construction
- Mathlib `WellFounded.prod_lex` - lexicographic well-foundedness
- Lean 4 TPIL, "Induction and Recursion" - well-founded recursion patterns
