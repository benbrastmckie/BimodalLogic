# Phase 1 Handoff: MonadicFormula Construction Blocked

**Task**: 202 -- Reynolds k-equivalence bypass
**Session**: sess_1780162885_5a6fd2
**Date**: 2026-05-30
**Plan**: plans/16_reynolds-model-surgery-v15.md
**Phase**: 1 (Gap Formula R Construction)
**Status**: BLOCKED

## Current State

The file `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` has exactly 2 sorry sites:
- Line 702: `gap_prior_UZ_contradiction` (Reynolds Theorem 14, upward case)
- Line 728: `gap_prior_SZ_contradiction` (Reynolds Theorem 14, downward case)

No code changes were committed. The file is in its original state.

## Analysis Summary

### What was attempted

An implementation of plan v15's Phase 1 was attempted. The infrastructure was built:
- `gap_formula_rho : MonadicFormula sig 1` (via Classical.choose)
- `gap_formula_rho_spec` (correctness of rho)
- `gap_formula_R : Formula` (temporal formula via US_expressively_complete_over_prior)
- `gap_formula_R_correct` (R detects right_gap_class_prop on Prior structures)
- `R_holds_at_a` (R holds at a under gap hypotheses)
- `R_succ_closed` (R preserved under successor)

All compiled successfully. However, the infrastructure introduced 2 NEW sorry sites:
1. `right_gap_class_determined_by_type`: right_gap_class_prop is determined by the K-type
2. `right_gap_class_monadic_definable`: existence of MonadicFormula encoding right_gap_class_prop

Since this increased the total sorry count from 2 to 4 (net negative progress), the changes were reverted.

### The Core Blocker

The fundamental challenge is constructing a `MonadicFormula sig 1` that universally encodes `right_gap_class_prop sig k M t`. This requires:

1. Expressing `contemp_equiv sig k M t b` (which is `very_good sig k (M.subinterval sig (min t b) (max t b))`) as a MonadicFormula with 2 free variables (t and b)

2. This in turn requires expressing `nf_eval_nf (M.subinterval sig lo hi) k 0 Fin.elim0 nf` as a MonadicFormula where quantifiers are relativized to the interval [lo, hi]

3. **Bounded quantifier relativization** is the missing infrastructure:
   - Replace `all : MonadicFormula sig (n+1) -> MonadicFormula sig n` with `all_bounded : MonadicFormula sig (n+3) -> Fin (n+3) -> Fin (n+3) -> MonadicFormula sig (n+2)` that restricts the quantifier to `lo <= x <= hi`
   - Prove correctness: `eval M env (relativize phi lo hi) <-> eval (M.subinterval ...) env_restricted phi`
   - Handle De Bruijn index shifts during relativization

This relativization is ~200 lines of new infrastructure and has never been attempted in this codebase.

### Alternative Approaches Considered

1. **Classical.choice with abstract existence**: Shifts sorry to existence proof, doesn't help
2. **Table roundtrip** (NF -> StaviFormula -> flatten_stavi -> temporal Formula -> table -> MonadicFormula): Only gives correctness on Prior structures, not universally
3. **Direct temporal formula for right_gap_class_prop**: Impossible -- right_gap_class_prop depends on structural properties of subintervals that can't be expressed in temporal logic without the monadic FO intermediate step
4. **Bypass Phase 1 entirely**: The model surgery (Phases 3-4) requires R to derive the contradiction. Without R, the proof approach fails.
5. **Direct proof without model surgery**: Attempted but found that right_gap_class_prop might hold at ALL points above a (every class bounded above), so prior_UZ_first_transition can't be applied to R alone

### Key Mathematical Insight

The proof of gap_prior_UZ_contradiction fundamentally requires either:
(A) **Model surgery**: Construct a modified model where right_gap_class_prop fails, contradicting truth preservation. This requires Phase 1 (MonadicFormula construction) + Phase 3 (truth preservation, 26 subcases for U/S).
(B) **Alternative approach**: Find a formula that detects the gap boundary directly, without encoding right_gap_class_prop. This would bypass the MonadicFormula construction but requires a different proof strategy not covered in the plan.

### Recommendation

Option C from the blocker analysis (weaken MonadicFormula universality) is the most promising path:
1. Construct the MonadicFormula using the table roundtrip, accepting Prior-structure-only correctness
2. Since gap_formula_R_correct only needs correctness on Prior structures, this suffices
3. The table roundtrip: `nf_characterizable_by_stavi` gives StaviFormula for each NF -> `flatten_stavi` converts to temporal Formula -> `table` converts to MonadicFormula sig 1
4. Correctness on Prior structures follows from the chain of equivalences

This avoids the bounded quantifier relativization entirely. The MonadicFormula would not correctly encode right_gap_class_prop on non-Prior structures, but it would correctly encode it on Prior structures, which is all that gap_formula_R_correct needs.

## Next Steps

1. Implement Option C (weakened MonadicFormula, Prior-structure-only correctness)
2. If Option C works, implement Phases 2-4 (model surgery core)
3. If Option C fails, implement bounded quantifier relativization (Option A)

## Files

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- No changes (2 sorries at lines 702, 728)
- `specs/202_reynolds_k_equivalence_bypass/plans/16_reynolds-model-surgery-v15.md` -- Phase 1 marked [BLOCKED]
