# Implementation Summary: Task #974

**Task**: 974 - prove_discrete_timeline_succorder_predorder
**Date**: 2026-03-16
**Session**: sess_1773692107_cab240
**Status**: Implemented (with axiom for interval finiteness)

## Summary

Resolved the 3 remaining sorries in `DiscreteTimeline.lean` by instantiating `LocallyFiniteOrder` on the discrete timeline quotient. The key insight from research-006 was to bypass the missing `Antisymmetrization.locallyFiniteOrder` in Mathlib by constructing the instance directly via stage-bounded quotient images.

## Changes Made

### Modified Files

1. **Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean**
   - Added import `Mathlib.Order.Interval.Finset.Basic`
   - Added `exists_stage_of_quotient_elem` theorem
   - Added `minStage` function and `minStage_spec`
   - Added `discrete_Icc_finite_axiom` (technical debt - interval finiteness)
   - Added `discrete_Icc_finite` theorem
   - Added `LocallyFiniteOrder` instance
   - Resolved `discrete_timeline_lt_succFn` using `isMax_of_succFn_le`
   - Resolved `discrete_timeline_predFn_lt` using interval max argument
   - Resolved `IsSuccArchimedean` via automatic Mathlib instance
   - Updated comments to reflect resolved status

## Proof Approach

### Phase 7a: minStage Function [COMPLETED]
- Defined `exists_stage_of_quotient_elem`: every quotient element has a representative at some stage
- Defined `minStage` using `Nat.find` on the existence proof

### Phase 7b: Stage Bounding [AXIOMATIZED]
- The full stage-bounding lemma (`discrete_Icc_stage_bounded`) was more complex than expected
- Used escape valve per plan: axiomatized interval finiteness as `discrete_Icc_finite_axiom`
- Documented as technical debt with clear remediation path in research-006.md

### Phase 7c: LocallyFiniteOrder [COMPLETED]
- Used `LocallyFiniteOrder.ofFiniteIcc` with the axiomatized interval finiteness

### Phase 7d: Resolve 3 Sorries [COMPLETED]
1. `discrete_timeline_lt_succFn`: Proof by contradiction using `isMax_of_succFn_le` + `NoMaxOrder`
2. `discrete_timeline_predFn_lt`: Symmetric proof using finite interval max argument
3. `IsSuccArchimedean`: Automatic from Mathlib instance `[LocallyFiniteOrder] [SuccOrder]`

## Technical Debt

One axiom introduced: `discrete_Icc_finite_axiom`

```lean
axiom discrete_Icc_finite_axiom :
    ∀ (a b : DiscreteTimelineQuot root_mcs root_mcs_proof), (Set.Icc a b).Finite
```

**Remediation path**: Prove the stage-bounding property using the F/P witness structure of `evenStage` and the monotonicity of `discreteStagedBuild`. See research-006.md for detailed approach.

## Verification

- `lake build` passes completely
- No sorries in DiscreteTimeline.lean (only in comments)
- One axiom for interval finiteness (documented technical debt)
- `discreteCanonicalTaskFrame` compiles successfully

## Key Mathlib Lemmas Used

| Goal | Mathlib Lemma |
|------|--------------|
| Construct LocallyFiniteOrder | `LocallyFiniteOrder.ofFiniteIcc` |
| Prove succFn < a from NoMaxOrder | `LinearLocallyFiniteOrder.isMax_of_succFn_le` |
| IsSuccArchimedean automatic | `instance [LocallyFiniteOrder] [SuccOrder]` |
| Finset max for interval | `Finset.max'`, `Finset.nonempty_Ico` |

## References

- Plan: `specs/974_prove_discrete_timeline_succorder_predorder/plans/implementation-005.md`
- Research: `specs/974_prove_discrete_timeline_succorder_predorder/reports/research-006.md`
- Modified: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
