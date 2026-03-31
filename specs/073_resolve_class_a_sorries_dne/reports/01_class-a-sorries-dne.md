# Research Report: Class A Sorries Resolution via DNE

## Executive Summary

The task description references "Class A sorries" at SuccChainFMCS.lean lines 2359 and 3011 from ROADMAP.md. However, these line numbers are **outdated** - no sorries exist at those locations in the current codebase. The code has evolved significantly.

**Current sorry locations in SuccChainFMCS.lean**:
- Line 1734: `g_content_union_brs_consistent` (multi-BRS consistency)
- Line 1763: `augmented_seed_consistent` (boundary_resolution_set consistency)
- Line 2082: `constrained_successor_seed_restricted_consistent` (seed consistency)
- Lines 5386, 5544, 5740: Fuel-exhausted branches in bounded_witness theorems

**Finding**: None of the current sorries match the "Class A" pattern described in the task (FF(psi) in closure but not in u, resolved via DNE). The DNE-based proof pattern from ROADMAP.md appears to have already been applied in the working proofs (e.g., `f_step_blocking_formulas_subset_u` at line 1144-1153 uses exactly this pattern).

## Verified Lemma Existence

All required ingredients exist and are sorry-free:

### 1. SetMaximalConsistent.double_neg_elim
**Location**: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean:124`
```lean
lemma SetMaximalConsistent.double_neg_elim {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_neg : Formula.neg (Formula.neg phi) in M) : phi in M
```

### 2. deferral_restricted_mcs_double_neg_elim
**Location**: `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean:864`
```lean
theorem deferral_restricted_mcs_double_neg_elim {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) (psi : Formula)
    (h_neg_neg : Formula.neg (Formula.neg psi) in M)
    (h_psi_clos : psi in deferralClosure phi) :
    psi in M
```

### 3. Negation Completeness for Restricted MCS
**Location**: `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean:771`
```lean
theorem deferral_restricted_mcs_negation_complete {phi : Formula} {S : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi S) (psi : Formula)
    (h_psi_clos : psi in subformulaClosure phi) :
    psi in S \/ psi.neg in S
```

### 4. F/G Duality (Definitional)
**Location**: Implicit, verified at SuccChainFMCS.lean:1385
```lean
have h_F_chi_eq : Formula.some_future chi = (Formula.all_future chi.neg).neg := rfl
-- F(chi) = neg(G(neg(chi))) definitionally
```

## Working Example: DNE Pattern in f_step_blocking

The pattern from ROADMAP.md is **already implemented** at `SuccChainFMCS.lean:1144-1153`:

```lean
theorem f_step_blocking_formulas_subset_u (u : Set Formula)
    (h_mcs : SetMaximalConsistent u) :
    f_step_blocking_formulas u subseteq u := by
  intro chi h_block
  obtain <phi, h_F_not, _, rfl> := h_block
  -- F(phi) not in u. By MCS negation completeness, neg(F(phi)) in u.
  -- neg(F(phi)) = neg(neg(G(neg phi))). By double negation elimination: G(neg phi) in u.
  rcases SetMaximalConsistent.negation_complete h_mcs (Formula.some_future phi) with h_in | h_neg_in
  . exact absurd h_in h_F_not
  . exact SetMaximalConsistent.double_neg_elim h_mcs _ h_neg_in
```

This is **exactly** the proof strategy from the task description, applied to the `f_step_blocking` case.

## Current Sorry Analysis

### Sorry 1: g_content_union_brs_consistent (line 1734)

**Theorem signature**:
```lean
theorem g_content_union_brs_consistent (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u) :
    SetConsistent (g_content u \/ boundary_resolution_set phi u)
```

**Blocker**: Multi-BRS case where G-wrapping approach fails. The comment says "L may contain multiple BRS elements, and the G-wrapping approach doesn't directly work."

**NOT Class A**: This is a consistency proof, not an F-step forcing argument. DNE doesn't directly apply.

### Sorry 2: augmented_seed_consistent (line 1763)

**Dependency**: Absorbed into `constrained_successor_seed_restricted_consistent` (which has its own sorry).

**NOT Class A**: Same category as above.

### Sorry 3: constrained_successor_seed_restricted_consistent (line 2082)

**Blocker**: Proving "no contradictory pairs implies consistent" which is non-trivial in Hilbert systems.

**NOT Class A**: This is about seed consistency, not F-step resolution.

### Sorries 4-6: Fuel-exhausted branches (lines 5386, 5544, 5740)

**Pattern**:
```lean
| 0 =>
  match d with
  | 0 => exact absurd h_d_ge (by omega : not 0 >= 1)
  | _ + 1 =>
    -- Semantically unreachable case - fuel exhausted but witness must exist
    exact <k + 1, by omega, by sorry>
```

**Status**: These are in `fuel = 0` branches that are semantically unreachable when called with sufficient initial fuel (B*B+1). The sorry exists because the termination checker needs explicit proof.

**NOT Class A**: These are termination artifact sorries, not logical proof gaps.

## Conclusion

**The "Class A sorries" described in the task no longer exist in the codebase.** The DNE proof pattern has already been successfully applied where needed (e.g., `f_step_blocking_formulas_subset_u`).

The remaining sorries are in different categories:
1. **Consistency proofs** (lines 1734, 1763, 2082): Require structural consistency arguments
2. **Termination artifacts** (lines 5386, 5544, 5740): Semantically unreachable branches

### Recommendation

**Mark task as [BLOCKED] with clarification request**: The specific sorries mentioned in the task description do not exist. The orchestrator should:

1. Verify if the task scope has changed since ROADMAP.md was written
2. If the original Class A sorries are resolved, close this task
3. If the intent is to resolve the *current* sorries, create new tasks with accurate descriptions:
   - One task for consistency proofs (lines 1734, 1763, 2082)
   - One task for termination artifact cleanup (lines 5386, 5544, 5740)

## Appendix: Full Sorry Locations

| Line | Function | Category | DNE Applicable? |
|------|----------|----------|-----------------|
| 1734 | g_content_union_brs_consistent | Consistency | No |
| 1763 | augmented_seed_consistent | Consistency | No |
| 2082 | constrained_successor_seed_restricted_consistent | Consistency | No |
| 5386 | restricted_backward_bounded_witness_fueled | Termination | No |
| 5544 | restricted_combined_bounded_witness_fueled | Termination | No |
| 5740 | restricted_combined_bounded_witness_P_fueled | Termination | No |
