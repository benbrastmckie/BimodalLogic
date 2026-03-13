# Phase 1 Handoff: strict_intermediate_exists

**Created**: 2026-03-13
**Session**: sess_1773432635_5e6f6680
**Status**: BLOCKED - requires mathematical review

## Immediate Next Action

The direct case-based proof approach generates unbounded case trees. The "at most 2 density applications" claim from research-002.md appears to be incorrect.

**Options for next agent**:
1. Find a correct termination measure (not subformulaClosure.card, not depth-2 case analysis)
2. Use well-founded recursion on the set of "visited" equivalence class representatives
3. Prove that after K density applications (for some fixed K), a strict intermediate MUST exist

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Sorries in strict_intermediate_exists**: 6
- Lines 326, 372, 420, 462: Branches where intermediate is ~one_endpoint but we need to continue iteration
- These branches arise when: c~p and d~q (or symmetric)

**Sorries in NoMaxOrder/NoMinOrder**: 2 (lines ~592, ~652)
- These depend on strict_intermediate_exists being complete

## Key Decisions Made

1. **Removed fuel-based recursion**: The original `subformulaClosure(delta).card` measure is incorrect because consecutive distinguishing formulas are not subformula-related.

2. **Added mutual_canonicalR_implies_reflexive theorem**: This proves that if M~M' (bidirectional CanonicalR), both are reflexive. This is key to understanding when Case A vs Case B of density_frame_condition applies.

3. **Direct case-based approach attempted**: This generates an unbounded case tree because each density call can produce an intermediate equivalent to one endpoint, requiring further iteration.

## What NOT to Try

1. **Depth-2 case analysis**: Does not work. Example: c~p, d~q gives [p] = [c] < [d] = [q], not a strict intermediate. Needs depth 3+.

2. **subformulaClosure(delta).card as fuel**: Research-002 proved this is incorrect. Consecutive deltas are not subformula-related.

3. **Assuming reflexive endpoints escape quickly**: Reflexive endpoints can keep producing equivalent intermediates indefinitely without the right measure.

## Critical Context

1. **Key theorem**: `caseB_M_not_reflexive` - In Case B (G(delta) in M with delta not in M), M is NOT reflexive.

2. **Consequence**: If p is reflexive, density(p, q) MUST be in Case A (or Case B2 which reduces to Case A). In Case A, the intermediate contains neg(delta) while q contains delta, so intermediate NOT~q.

3. **But**: This says intermediate NOT~q, not intermediate NOT~p. The intermediate could still be ~p.

4. **Termination insight needed**: We need to show that the sequence of intermediates equivalent to p (if it continues) eventually terminates. Each intermediate is constructed from a different distinguishing formula, but these formulas are not decreasing in any obvious measure.

## References

- Plan: `/home/benjamin/Projects/ProofChecker/specs/961_quotient_density_iteration_no_max_min_dense/plans/implementation-002.md`
- Research: `/home/benjamin/Projects/ProofChecker/specs/961_quotient_density_iteration_no_max_min_dense/reports/research-002.md`
- DensityFrameCondition.lean: Contains `density_frame_condition`, `caseB_M_not_reflexive`, `irreflexive_mcs_has_strict_future`

## Suggested New Approach

Consider proving that the set of MCSs equivalent to p is FINITE (bounded by some function of the distinguishing formula complexity). Then well-founded recursion on the "unexplored" equivalents gives termination.

Alternatively, use `Decidable` + Classical.choose to assert existence, then separately prove the property holds. But this requires proving existence without constructing the witness, which may be circular with DenselyOrdered.
