# Handoff: Task 956 Phase 6a - Strict Density (Iteration 3 - FINAL)

**Session**: sess_1773353508_f76726
**Timestamp**: 2026-03-12T17:00:00Z
**Status**: PARTIAL - 13 sorries remain, iteration pattern established and proven for one layer

## Immediate Next Action

Prove that the "witness collapses to M's class" case is IMPOSSIBLE via contradiction.

**Key insight**: If V ~ M and W' from density(V, M') also satisfies W' ~ M, then we can derive M' sees M, contradicting h_not_R'.

**Proof sketch for line 1603**:
1. We have V ~ M ~ W' (mutual accessibility via h_VM, h_R_MV, h_W'M, h_R_MW')
2. We have W' sees M' (h_W'M')
3. We have M' doesn't see W' (h_M'W')
4. Claim: This should give exfalso

**Approach**: Use the gamma witness from M' non-reflexivity.
- gamma ∈ GContent(M') but gamma ∉ M'
- G(gamma) ∉ M (h_G_gamma_not_M)
- Since W' ~ M, G(gamma) ∉ W'
- Since W' sees M' and G(gamma) ∈ M', by T4, G(gamma) ∈ GContent(M')
- If M' sees W' (contradiction with h_M'W'), then G(gamma) ∈ W'
- But G(gamma) ∉ W'. So M' doesn't see W' is consistent.

The issue: need to find a phi such that phi ∈ GContent(M') and phi ∉ W' to show M' doesn't see W', but we already have h_M'W' giving this. No direct contradiction.

**Alternative approach**: Show the case is mathematically impossible by deriving CanonicalR M' M from the hypotheses, contradicting h_not_R'.

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`

**13 sorries** at lines: 486, 490, 492, 585, 589, 591, 641, 646, 653, 860, 898, 1603, 1662

**Key structures added in iteration 3**:
- `non_reflexive_target_has_strict_intermediate` (lines 1517-1630): handles M' non-reflexive case
- Iteration pattern via `density_frame_condition(V, M')` when witness V collapses to M's class
- T4 transitivity proofs for `CanonicalR M' W' -> CanonicalR M' M` cases

## Key Decisions Made

1. **Split on M' reflexivity**: The main theorem splits into reflexive (uses original proof with sorries) and non-reflexive (new theorem) cases.

2. **Iteration via density(V, M')**: When witness V satisfies V ~ M, apply density to (V, M') to get W'. If W' is strict, done. Otherwise, this case might be impossible.

3. **T4 transitivity contradiction**: When M' sees W' and W' sees M, derive M' sees M via T4, contradicting h_not_R'.

## What NOT to Try

1. **Direct application of reflexive_seriality_escape**: This requires M' reflexive, but we're in non-reflexive case.

2. **Using W₁ directly**: W₁ from density may also collapse to M's class.

3. **Infinite iteration without termination**: Need a decreasing measure (formula complexity or subformula count).

## Critical Context

1. **Goal at all sorries**: `∃ W, strict witness between M and M'`

2. **Mathematical truth**: Strict intermediates ALWAYS exist for M < M' in the canonical quotient order (density of linear orders).

3. **Proof difficulty**: The Lindenbaum extension may produce witnesses equivalent to endpoints.

4. **Key formula relationships**:
   - G(gamma) ∈ M' (gamma witness of M' non-reflexivity)
   - gamma ∉ M'
   - G(gamma) ∉ M (else gamma ∈ M' by h_R)
   - neg(gamma) ∈ V (from canonical_forward_F construction)

## References

- Plan: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-022.md`
- Previous handoff: `specs/956_construct_d_as_translation_group_from_syntax/handoffs/phase-6a-handoff-20260312-iter2.md`
- Progress: `specs/956_construct_d_as_translation_group_from_syntax/progress/phase-6a-progress.json`

## Iteration Pattern Summary

**Proven pattern**: For each witness W that satisfies `CanonicalR W M` (collapses to M's class):
1. Apply `density_frame_condition(W, M')` to get W'
2. `by_cases h_W'M : CanonicalR W' M`
   - If `¬CanonicalR W' M`: W' is strict. Prove `¬CanonicalR M' W'` via gamma/T4 argument. DONE.
   - If `CanonicalR W' M`: W' ~ M. Recurse with W'.

**Current sorry locations** (13 total):
- Lines 486, 490, 492, 585, 589, 591, 641, 646, 653, 860, 898: Original sorries in `density_frame_condition_strict`
- Line 1632: Nested iteration in `non_reflexive_target_has_strict_intermediate` (W'' ~ M case)
- Line 1717: Second iteration point (W'' ~ M case after V = M')

## Next Steps for Iteration 4

1. **Termination via formula measure**: Define `iterationMeasure : Formula -> Nat` based on subformula count. Each iteration uses a "smaller" distinguishing formula.

2. **Fuel-based recursion**: Implement `strictDensityWithFuel` using Nat.strongRecOn on the measure.

3. **Wire up to sorries**: Replace all 13 sorries with calls to the fuel-based theorem.

## Estimated Remaining Work

- Implement termination measure (subformula count): 1 hour
- Implement fuel-based strictDensityWithFuel: 2 hours
- Prove fuel_suffices (termination): 2 hours
- Wire up to all 13 sorries: 30 minutes

Total estimated: 5.5 hours
