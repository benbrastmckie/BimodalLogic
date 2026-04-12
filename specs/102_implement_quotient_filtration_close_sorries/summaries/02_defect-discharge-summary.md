# Implementation Summary: Defect-Discharge Chain and Sorry Investigation

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Artifact**: summaries/02_defect-discharge-summary.md
- **Date**: 2026-04-11
- **Status**: PARTIAL (Phase 3 completed, Phases 4-6 blocked)

## Completed Work

### Phase 1: Sigma Ordering Infrastructure [COMPLETED]
- Created `SigmaOrdering.lean` with sigma_le, sigma_strict, sigma_equiv
- All lemmas proved without sorry
- File: `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean`

### Phase 2: Defect-Discharge Chain Lemmas [PARTIAL -> BLOCKED]
- Created `DefectChain.lean` with sigma_defect_count, defect step properties
- Proved: sigma_defect_count_bounded, defect_step_phi, defect_step_F_psi, defect_step_connect, defect_step_self_accum
- Mirrored Since-direction lemmas
- **Blocked items**: defect_chain_exists and chain properties (requires forward direction proof which is fundamentally blocked)
- File: `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean`

### Phase 3: BX7 Direct Proof Investigation [COMPLETED]
- Decision: **BX7 FAILS** to close the sorries directly
- Detailed analysis documented below

## Phase 3 Findings: Why BX7 Cannot Close the Sorries

### BX7 Analysis

BX7 (linear_until): `(phi U psi) /\ (chi U theta) -> D1 \/ D2 \/ D3` where:
- D1: `(phi /\ chi) U (psi /\ theta)` (witnesses coincide)
- D2: `(phi /\ chi) U (psi /\ chi)` (first witness first)
- D3: `(phi /\ chi) U (phi /\ theta)` (second witness first)

BX7 requires TWO Until formulas at the SAME point. Multiple combinations were tested:

1. **`(phi U psi)` and `(top U psi)` at u'**: All disjuncts collapse to forms of `phi U psi` (useless).

2. **`(psi U phi)` and `(top U psi)` at w**: D1 and D3 give `psi U (...)` which via BX9 gives `psi in w`, contradicting `psi not in w`. But D2 gives `psi U phi` (already had from BX8 + phi), which cannot be eliminated.

3. **`(phi U phi)` and `(top U psi)` at u**: D1 and D3 give `phi U (phi /\ psi)` which via BX3 gives `phi U psi`, contradicting `neg(phi U psi)`. But D2 gives `phi U phi` (trivial, no contradiction).

In all cases, one disjunct survives without contradiction. BX7's three-way disjunction cannot be fully eliminated.

### Root Cause Analysis

The 10 sorries (4 Frame.lean + 6 Realization.lean) are **genuinely unprovable** with the current `bx_le` definition and BX axiom system. The root cause:

1. **bx_le non-totality**: `bx_le w v` is defined as `g_content(w) subset v.formulas`. This is reflexive (BX1) and transitive (temp_4) but NOT total: two MCSs can have incomparable g_content.

2. **Non-G formula propagation gap**: Only G-formulas propagate forward through bx_le. Given `phi in u'` and `bx_le u' u`, we CANNOT derive `phi in u` unless `G(phi) in u'`. This gap blocks EVERY proof attempt for both forward and backward directions.

3. **Forward direction blocker**: For eventuality resolution, the guard requires `phi in u` for intermediate u. We can derive `phi in u'` (backward witness from u with BX9), but cannot lift it to u.

4. **Backward direction blocker**: The enriched seed gives u with `bx_le w u`, `bx_le u v`, `neg(phi U psi) in u`. But we cannot show `bx_lt u v` (= `not bx_le v u`) because the Lindenbaum extension might include all of g_content(v).

5. **Guard reformulation attempts**: Changing the guard from `bx_lt u v` to `psi not in u` fixes the backward direction (Case A: G(phi) in w, use BX2 + BX12; Case B: enriched seed contradiction) but breaks the forward direction (same propagation gap) and the reflexive case.

### What Would Fix This

One of:
1. **Phase 4-alt (finite linear model)**: Build an independent model where the ordering IS total by construction. The guard is trivial on total orders. Estimated 16+ hours.
2. **Redefine bx_le**: Use a total ordering (e.g., chain-position ordering). Very disruptive (20+ hours, requires reverifying all existing proofs).
3. **Add Until-induction axiom**: `(psi \/ (phi /\ X(theta)) -> theta) -> (phi U psi -> theta)`. This was removed during BX refactoring. Adding it back would directly close the sorries but changes the axiom system.
4. **Algebraic approach**: Use the Lindenbaum-Tarski algebra with interior operators. A separate proof path that doesn't use MCS directly.

## Remaining Phases

### Phase 4/4-alt: Close Frame.lean Sorries [BLOCKED]
- Phase 4 (BX7 direct): **Abandoned** (BX7 fails)
- Phase 4-alt (finite linear model): Not started. Recommended next step.
- 4 sorries remain in Frame.lean

### Phase 5: Close Realization.lean Sorries [BLOCKED]
- Depends on Phase 4/4-alt
- 6 sorries remain in Realization.lean (now delegates to Frame.lean)

### Phase 6: Final Validation [NOT STARTED]
- Depends on Phase 5

## Sorry Count

| File | Before | After | Change |
|------|--------|-------|--------|
| Frame.lean | 4 | 4 | 0 |
| Realization.lean | 6 | 6 | 0 |
| **Total** | **10** | **10** | **0** |

## Build Status

`lake build` passes cleanly (950 jobs). No new sorries or axioms introduced.

## Recommendation

Proceed with **Phase 4-alt (finite linear model construction)**. This approach:
- Bypasses the bx_le non-totality problem entirely
- Has 80% confidence (per team research)
- Leverages existing infrastructure (HintikkaPoint, sigma_signature, defect_count, hintikka_step)
- Estimated 16 hours of implementation
- Should be a new task with fresh context (this investigation consumed significant context)
