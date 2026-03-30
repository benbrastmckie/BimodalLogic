# Research Report: Task #67 — Blocker Analysis & Historical Patterns

**Task**: prove_bundle_validity_implies_provability
**Date**: 2026-03-30
**Mode**: Team Research (2 teammates)
**Session**: sess_1774841570_9d3bfb

## Summary

Two teammates investigated the `k >= B` blocker (lines 3006, 3037 in SuccChainFMCS.lean) from complementary angles. They **disagree** on whether the chain stabilization lemma is provable. Teammate A argues the current construction permits indefinite deferral of sub-maximal-depth F-formulas, making the stabilization lemma false as stated. Teammate B's historical analysis shows all 11 plans converge on this same gap and recommends proving it. The synthesis resolves this conflict.

## Key Findings

### From Teammate A: Chain Stabilization Analysis

1. The proposed stabilization lemma `boundary_implies_position_lt_bound` is **likely unprovable** with the current chain construction
2. `restricted_forward_chain` is built via `constrained_successor_restricted` using Lindenbaum extension (Zorn's lemma), which is noncomputable and non-unique
3. The `boundary_resolution_set` only forces resolution at depth B-1 (the deepest level), NOT at depths d < B-1
4. For depths d < B-1, deferral is possible indefinitely — no property of the construction prevents `iter_F d theta in chain(k)` for arbitrarily large k
5. The fuel invariant gap CANNOT be closed with simple bounds because the k >= B regime can last for multiple recursive steps
6. The true termination argument requires either construction-level changes or a fundamentally different approach

### From Teammate B: Historical Pattern Analysis

1. All 11 plans blocked by the same root cause — fuel/termination discharge needing chain stabilization
2. Architecture is settled and correct: steps 1-3 and 5 are sorry-free; only step 4 (bounded witness lemmas) is blocked
3. Plan 11 successfully reduced to exactly 2 sorry sites (lines 3006, 3037), both in `k >= B` branch
4. Three independent analyses (summary 11, report 31, plan 10) all identified the stabilization argument as the resolution
5. Anti-pattern: repeated architecture pivots (11 plans) have delayed directly confronting the stabilization question
6. Plan 8 (dovetailing) was a separate dead end — F-formulas lost during Lindenbaum extension

## Synthesis

### Conflict: Is the Stabilization Lemma Provable?

**Teammate B** assumes the stabilization lemma is provable based on `iter_F_not_mem_closureWithNeg` and the finiteness of `deferralClosure`. Three independent past analyses agree.

**Teammate A** argues it is NOT provable because the Lindenbaum extension is noncomputable and the `boundary_resolution_set` only forces resolution at depth B-1. At depths d < B-1, deferral can continue indefinitely.

### Resolution

**Teammate A's technical analysis is more detailed and correct.** The critical observation is:

- The `boundary_resolution_set` forces resolution when `F(F(chi)) not in deferralClosure phi` — i.e., only at the maximum F-nesting depth
- At depths d < B-1, the formula `iter_F d theta` CAN be in `chain(k)` for arbitrarily large k because:
  1. At each step, Lindenbaum extension may choose to include `F(iter_F d theta)` (deferring) rather than resolving to `iter_F d theta`
  2. The `boundary_resolution_set` does NOT trigger for these sub-maximal formulas
  3. No fairness/scheduling property ensures eventual resolution

**Teammate B's optimism** is based on the assumption that `iter_F_not_mem_closureWithNeg` gives enough to prove `k < B`. This assumption is wrong: that lemma proves `d < B` (depth is bounded), not `k < B` (position is bounded). The depth and position are DIFFERENT measures.

**Verdict**: The stabilization lemma is likely **false as stated** under the current construction. This means the current approach (fuel invariant + stabilization discharge) has hit a genuine construction-level limitation.

### What This Means

The four bounded witness lemmas require that F-obligations are eventually resolved. The current `restricted_forward_chain` construction does NOT guarantee this because:

1. `boundary_resolution_set` only forces resolution at the deepest F-nesting level
2. Sub-maximal F-formulas can be deferred indefinitely by Lindenbaum's noncomputable choice
3. No fairness or priority scheme exists in the current construction

This is NOT a missing lemma — it's a **missing construction property**.

### Gaps Identified

1. **Critical**: Whether `constrained_successor_restricted` can be modified to include a priority/fairness scheme without breaking existing proofs
2. **Important**: Whether an alternative termination argument exists that doesn't require chain stabilization
3. **Unknown**: Whether the bounded witness can be bypassed entirely by proving `restricted_forward_chain_forward_F` through a different route

## Recommended Approaches (Priority Order)

### Option A: Strengthen the Chain Construction (Estimated 8-12h)

Modify `constrained_successor_restricted` to use a priority scheme that forces F-formulas at any depth to be resolved within B additional steps. This gives the stabilization property by construction.

**Risk**: Plan 8 showed that "forcing" resolution can cause F-formulas to be LOST during Lindenbaum extension. The priority scheme must be carefully designed to avoid this.

**Approach**: Instead of adding formulas to the seed, use a modified consistency check that PREFERS the resolving disjunct (`psi` over `F(psi)`) when the formula has been deferred for too many steps.

### Option B: Well-Founded Recursion Without Fuel (Estimated 6-10h)

Replace the fuel-based approach with well-founded recursion on a measure that directly captures progress. The measure would need to track GLOBAL state (not just local depth/position).

**Candidate measure**: A finite set of "unresolved F-obligations" that strictly shrinks on each resolve step. The set is bounded by `|deferralClosure phi|`, so the recursion terminates.

**Risk**: Lean's termination checker may struggle with this; may need `Acc`-based manual proofs.

### Option C: Bypass the Bounded Witness Entirely (Estimated 4-8h)

Instead of proving the bounded witness (which requires eventual F-resolution), prove `restricted_forward_chain_forward_F` directly using a different argument. For example:

1. Show that the Z-chain construction (which has fairness built in) satisfies forward_F
2. Transfer back to the restricted chain via extension lemmas

**Risk**: This was partially explored in earlier plans but the transfer-back was complex.

### Option D: Add `k < B` Hypothesis (Estimated 2-4h)

Add `k < B` as a hypothesis to `restricted_bounded_witness_wf`. This shifts the burden to callers. The caller `restricted_bounded_witness` would need to prove `k < B` from its own hypotheses.

**Risk**: The caller may not be able to prove `k < B` either, propagating the problem upward. However, if the external call site always starts with `k = 0` or a known small value, this may work.

## Anti-Recommendation

**Do NOT create a 12th architecture plan.** The architecture is settled and correct. The problem is localized to one semantic property that has not been formalized. The next step should be one of Options A-D above, not a new proof strategy.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Chain stabilization analysis | completed | High |
| B | Historical pattern analysis | completed | High |

## Conflicts Found

1. **Stabilization lemma provability**: Teammate A says false; Teammate B says likely provable. Resolved in favor of Teammate A based on deeper technical analysis of the construction.

## References

- Teammate A findings: specs/067_prove_bundle_validity_implies_provability/reports/34_teammate-a-findings.md
- Teammate B findings: specs/067_prove_bundle_validity_implies_provability/reports/34_teammate-b-findings.md
- Plans 01-11: specs/067_prove_bundle_validity_implies_provability/plans/
- Summary 11: specs/067_prove_bundle_validity_implies_provability/summaries/11_fuel-invariant-partial.md
- Report 31: specs/067_prove_bundle_validity_implies_provability/reports/31_team-research.md
