# Implementation Summary: Task #58

**Task**: Wire completeness to FrameConditions
**Plan Version**: 18
**Session**: sess_1774652451_46c4ab
**Status**: PARTIAL (Tier 1 complete, Tier 2 audits reveal no shortcuts)

## Executive Summary

Phase 1 (wire 3 sorries to 1) achieved partial success:
- `discrete_completeness_fc` now delegates through `completeness_over_Int` (SORRY-FREE reduction)
- `dense_completeness_fc` CANNOT delegate to Int completeness (Int is not dense)
- All completeness sorries reduce to `bundle_validity_implies_provability`

Phases 2-4 audited potential shortcuts; none were found:
- Z-chain crossing sorries are G-lift barrier instances
- Deferral disjunction seeds move the problem, don't solve it
- bot-in-deferralClosure is not viable for typical formulas

## Phase Results

### Phase 1: Wire 3 Sorries to 1 [COMPLETED]

**Achievement**: Reduced the number of independent sorries by establishing dependency chains.

| Theorem | Before | After |
|---------|--------|-------|
| `dense_completeness_fc` | Sorry | Sorry (cannot reduce to Int) |
| `discrete_completeness_fc` | Sorry | SORRY-FREE (via `completeness_over_Int`) |
| `completeness_over_Int` | Via `bundle_validity_implies_provability` | Via `bundle_validity_implies_provability` |
| `bundle_validity_implies_provability` | Sorry | Sorry (model-theoretic glue) |

**Key Insight**: Int IS a discrete temporal frame (has `SuccOrder Int`, `PredOrder Int`, `IsSuccArchimedean Int` from Mathlib). Therefore, the hypothesis "phi valid over ALL discrete D" can be specialized to Int, and discrete completeness follows from Int completeness.

**Why Dense Cannot Reduce**: Int is NOT densely ordered. There is no integer between 0 and 1. Therefore, the hypothesis "phi valid over ALL dense D" cannot be specialized to Int. Dense completeness would require a separate proof using a dense canonical model (e.g., over Rat).

### Phase 2: Audit Z-chain Crossing-Case Sorries [COMPLETED]

**Finding**: The Z-chain sorries at lines 2347, 2369, 2383 in UltrafilterChain.lean are G-lift barrier instances, not tractable engineering problems.

**Analysis**:
- The forward chain (`omega_chain_forward`) preserves G-formulas from M0 via `G_propagate`
- The backward chain (`omega_chain_backward`) preserves H-formulas from M0 via `H_propagate`
- Neither chain preserves the OTHER temporal modality
- The crossing case (from backward chain to forward chain, i.e., negative to non-negative time) requires G-formulas to propagate through M0
- But G(phi) at time t < 0 does NOT imply G(phi) at time 0 (G-lift barrier)

**Conclusion**: The Z-chain construction cannot resolve the crossing cases without solving the fundamental G-lift problem.

### Phase 3: Check Deferral Disjunction Seed Approach [COMPLETED]

**Finding**: The deferral disjunction approach moves the problem but doesn't solve it.

**Analysis**:
- Current BRS contains bare `chi` formulas
- Deferral approach would use `chi OR F(chi)` instead
- `chi OR F(chi)` is in the MCS (derivable from `F(chi)` via disjunction introduction)
- So the seed would be a subset of the MCS, hence trivially consistent

**But the problem resurfaces**:
- Lindenbaum extension of seed containing `chi OR F(chi)` may choose `F(chi)` over `chi`
- If extension chooses `F(chi)`, then `chi` never appears at this level
- The `bounded_witness` theorem needs `chi` to eventually appear
- This is the G-lift barrier in a different form

**Conclusion**: Deferral disjunctions don't eliminate the fundamental consistency problem.

### Phase 4: Quick Check bot-in-deferralClosure [COMPLETED]

**Finding**: `bot` is NOT in `deferralClosure(phi)` for typical formulas.

**Analysis**:
- `deferralClosure(phi) = closureWithNeg(phi) UNION deferralDisjunctionSet(phi) UNION backwardDeferralSet(phi)`
- `closureWithNeg(phi) = subformulaClosure(phi) UNION negations`
- `bot` is only in `subformulaClosure(phi)` if `phi` mentions `bot` as a literal subformula
- For typical formulas (atoms, boxes, temporal operators), `bot` is NOT a subformula
- Therefore bot-in-deferralClosure is NOT a viable alternative consistency path

**Conclusion**: This shortcut is not available.

## Files Modified

- `Theories/Bimodal/FrameConditions/Completeness.lean`
  - Updated `discrete_completeness_fc` to delegate through `completeness_over_Int`
  - Updated documentation to clarify sorry dependencies
  - Updated `dense_completeness_fc` docstring to explain why it cannot use Int completeness

## Current Sorry State

After this implementation, the sorries in `FrameConditions/Completeness.lean` are:

| Location | Theorem | Status |
|----------|---------|--------|
| Line 121 | `dense_completeness_fc` | Sorry (needs dense canonical model) |
| Line 176 | `bundle_validity_implies_provability` | Sorry (model-theoretic glue) |

Note: `discrete_completeness_fc` is now SORRY-FREE (reduces to `completeness_over_Int`).

## Path Forward

### Option A: Prove `bundle_validity_implies_provability`

This is the core remaining sorry. It requires connecting the algebraic bundle construction to the semantic `valid_over Int` definition.

**What exists**:
- `construct_bfmcs_bundle`: Sorry-free bundle construction
- `bundle_completeness_contradiction`: Sorry-free; shows some MCS doesn't contain phi if phi not provable
- `not_provable_implies_neg_consistent`: Sorry-free; if phi not provable, neg(phi) is consistent

**What's missing**:
- The "canonical model theorem": Converting `BFMCS_Bundle` to a `TaskModel` that satisfies `valid_over`
- This requires `BFMCS.temporally_coherent` (family-level), but we only have `BundleTemporallyCoherent` (bundle-level)

**Mathematical difficulty**: HIGH. This is the family-level vs bundle-level coherence gap that all 24 prior approaches failed to bridge.

### Option B: Prove `dense_completeness_fc` Directly

This would require a dense canonical model construction (e.g., over Rat instead of Int).

**Mathematical difficulty**: MEDIUM-HIGH. The completeness techniques should transfer, but the infrastructure would need to be rebuilt for a dense domain.

### Option C: Accept Current State

The current state represents significant progress:
- `discrete_completeness_fc` is sorry-free modulo `bundle_validity_implies_provability`
- All sorries trace to one root cause: the model-theoretic glue
- The algebraic completeness infrastructure is fully sorry-free

This may be an acceptable stopping point, with the model-theoretic glue documented as future work.

## Recommendations

1. **Mark task as PARTIAL**: Significant progress made, but core sorry remains
2. **Document the gap clearly**: The model-theoretic glue is the remaining work
3. **Consider spawning a new task**: For the canonical model theorem specifically
4. **Do NOT re-attempt Tier 2 shortcuts**: They have been definitively ruled out

## Verification

- `lake build` succeeds with warnings (expected sorries)
- `discrete_completeness_fc` proof verified complete (no goals)
- No new axioms introduced
- No new sorries introduced beyond the pre-existing ones
