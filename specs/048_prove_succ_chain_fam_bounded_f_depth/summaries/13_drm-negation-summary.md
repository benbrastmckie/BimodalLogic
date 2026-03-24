# Implementation Summary: DRM Negation Completeness (v12)

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Plan Version**: 12
**Status**: PARTIAL
**Date**: 2026-03-23
**Session**: sess_1774319809_429196

## Phase Completion Status

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Prove DRM Negation Completeness | COMPLETED | Added helper lemmas to RestrictedMCS.lean |
| 2. Fix Critical Sorries | BLOCKED | Research report gap identified |
| 3. Deprecate Dead Code | NOT STARTED | Blocked by Phase 2 |
| 4. Handle Boundary Cases | NOT STARTED | Blocked by Phase 2 |
| 5. Build Verification | NOT STARTED | Blocked by Phase 2 |

## Phase 1: Completed Work

Added the following lemmas to `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`:

### `drm_closed_under_derivation`
```lean
theorem drm_closed_under_derivation {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) {psi : Formula}
    (L : List Formula) (h_sub : forall chi in L, chi in M)
    (h_deriv : DerivationTree L psi)
    (h_psi_dc : psi in deferralClosure phi) : psi in M
```
DRM is closed under derivation for formulas in deferralClosure. This is the key infrastructure lemma enabling modal reasoning within restricted MCS.

### `drm_implication_property`
```lean
theorem drm_implication_property {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) {psi chi : Formula}
    (h_imp : (psi.imp chi) in M) (h_psi : psi in M)
    (h_chi_dc : chi in deferralClosure phi) : chi in M
```
Modus ponens is reflected in DRM membership when the conclusion is in deferralClosure.

### `theorem_in_drm`
```lean
theorem theorem_in_drm {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) {psi : Formula}
    (h_thm : [] derives psi)
    (h_psi_dc : psi in deferralClosure phi) : psi in M
```
Theorems in deferralClosure are in any DRM.

### `neg_FF_implies_GG_neg_in_drm`
```lean
theorem neg_FF_implies_GG_neg_in_drm {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) (psi : Formula)
    (h_neg_FF : neg(FF(psi)) in M)
    (h_intermediate_dc : G(F(psi).neg.neg) in deferralClosure phi)
    (h_GG_dc : GG(neg psi) in deferralClosure phi) :
    GG(neg psi) in M
```
Modal duality for DRM, with explicit closure requirements on intermediate formulas.

### `drm_G_neg_implies_not_F`
```lean
theorem drm_G_neg_implies_not_F {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) (psi : Formula)
    (h_G_neg : G(neg psi) in M) : F(psi) not in M
```
G and F are contradictory in DRM (uses only consistency).

## Phase 2: Blocking Issue Identified

### Research Report Gap

The plan v12 was based on research report #22 which claimed:

> "**Prerequisite**: `neg(FF(psi)) in deferralClosure` when `FF(psi) in deferralClosure`. This holds because `deferralClosure` contains `closureWithNeg`, which is closed under negation by construction."

**This claim is INCORRECT.** `closureWithNeg` is NOT closed under negation.

### Technical Analysis

`closureWithNeg(phi) = subformulaClosure(phi) U {g.neg | g in subformulaClosure(phi)}`

For `closureWithNeg` to be closed under negation, we would need:
- For all `psi in closureWithNeg`, `neg(psi) in closureWithNeg`

Counter-example: If `g in subformulaClosure` but `g not in subformulaClosure` as a direct subformula, then:
- `g.neg in closureWithNeg` (via the negation set)
- But `neg(g.neg) = g.neg.neg` is in closureWithNeg ONLY IF:
  - `g.neg.neg in subformulaClosure`, OR
  - `g.neg.neg = h.neg` for some `h in subformulaClosure` (meaning `g.neg = h`)

Neither is guaranteed in general.

### Implications for the Proof

When `FF(psi) in closureWithNeg` but `FF(psi) not in subformulaClosure`:
- `FF(psi) = g.neg` for some `g in subformulaClosure`
- `neg(FF(psi)) = neg(g.neg) = g.neg.neg`
- `g.neg.neg not in closureWithNeg` (in general)
- Therefore, `neg(FF(psi)) not in deferralClosure`
- Therefore, negation completeness for `FF(psi)` does NOT apply

This means the approach outlined in the plan cannot work for all cases where `FF(psi) in deferralClosure`.

### Recommended Next Steps

1. **Split the theorem** by whether `FF(psi) in subformulaClosure`:
   - If yes: Use negation completeness and the full proof chain
   - If no: Need a different argument (or prove the case is unreachable from callers)

2. **Investigate calling context**: The sorries are in `restricted_single_step_forcing` and `restricted_succ_propagates_F_not`. These are called by `restricted_bounded_witness`. Perhaps the boundary case (`FF(psi) not in subformulaClosure`) is unreachable from the actual calling context.

3. **Consider theorem signature change**: Add hypothesis `h_FF_sub : FF(psi) in subformulaClosure` and prove callers can provide it.

## Build Status

Project builds successfully with the new lemmas. No new sorries introduced.

```
lake build: SUCCESS
RestrictedMCS.lean sorries: 1 (pre-existing, line 949)
SuccChainFMCS.lean sorries: Unchanged (8 active + 2 deprecated)
```

## Files Modified

- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Added 5 new lemmas
- `specs/048_prove_succ_chain_fam_bounded_f_depth/plans/12_drm-negation-completeness.md` - Updated phase markers

## Artifacts

- This summary: `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/13_drm-negation-summary.md`
- Plan v12: `specs/048_prove_succ_chain_fam_bounded_f_depth/plans/12_drm-negation-completeness.md`
- Research report #22: `specs/048_prove_succ_chain_fam_bounded_f_depth/reports/22_team-research.md`
