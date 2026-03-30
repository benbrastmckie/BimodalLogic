# Research Report: Task #67 — Fuel Approach Viability & Alternatives

**Task**: Prove bundle_validity_implies_provability via direct model construction
**Date**: 2026-03-29
**Mode**: Team Research (2 teammates)
**Session**: sess_1774830244_8554ec

## Summary

Ten plans have been attempted for this task. All are blocked on the same root cause: four `fuel=0` base case sorries in `SuccChainFMCS.lean` that are semantically unreachable but syntactically unprovable. The core difficulty is that depth can **increase** on resolve operations, breaking every simple decreasing measure.

Two teammates investigated (A) the history of all fuel attempts and (B) fresh alternatives. They **disagree on the recommended path**: Teammate A recommends nested strong induction; Teammate B recommends a quadratic fuel invariant. Synthesis below resolves this conflict.

## Key Findings

### From Teammate A: Fuel Approach History

All 10 plans blocked on the same fundamental issue:
- Plans 1-5: Architecture correct but deferred fuel sorries
- Plan 6: Well-founded `(B*B - k, d)` — circular (k's bound is what we're proving)
- Plan 8: Dovetailing — blocked separately (F-persistence lost in Lindenbaum extension)
- Plan 9: Fixed backward chain sorries (lines 3944, 4001) ✓ but fuel sorries remain
- Plan 10: Two-fuel, single-fuel, strong induction — all fail because depth increases on resolve

**Pattern**: The termination argument is *semantic* (fuel always suffices globally) not *syntactic* (measure decreases locally). No simple local measure captures this.

### From Teammate B: Alternative Approaches Evaluated

| Alternative | Feasibility | Effort | Verdict |
|------------|-------------|--------|---------|
| 1. Nested strong induction (levels × depth) | Low | 4-6h | Invariant `d ≤ levels` breaks |
| 2. Total complexity budget | Medium | 6-10h | Same as fuel-sufficient invariant |
| 3. Acc-based recursion | Medium | 6-8h | Same blocker as Plan v10 |
| **4. Fuel invariant `fuel > (B-k)*B`** | **High** | **4-6h** | **Algebraically valid, minimal change** |
| 5. Accept sorries | N/A | 0h | Rejected (zero-debt policy) |
| 6. Non-constructive existence | Low | 8-12h | Moves problem, doesn't solve it |

## Synthesis

### Conflict: Nested Induction vs. Fuel Invariant

**Teammate A** recommends nested strong induction on `(f_nesting_depth(theta), defers_at_level)`:
- Outer: `f_nesting_depth(theta)` decreases on resolve (F peeled off)
- Inner: `defers_at_level` decreases on defer (bounded by B)

**Teammate B** evaluated a similar approach (Alternative 1) and found the invariant `d ≤ levels_remaining` is **NOT preserved**: after resolve with new boundary depth `d'`, new tracking depth `d' + (n-1)` can be `>> levels_remaining - 1` when `d' = B-1`.

**Resolution**: Teammate B's objection applies to Teammate A's proposal as well. The key question is whether `f_nesting_depth(theta)` (a formula structural property) truly decreases strictly on every resolve, AND whether the inner measure `defers_at_level` is bounded independently. Teammate B's analysis shows the second condition fails: after resolve, the "defers" at the new level can be up to B-1, which is not bounded by the previous level's defers.

**Verdict**: The nested induction approach requires more investigation to determine if a correct invariant exists. The fuel invariant approach is **more concrete and immediately verifiable**.

### Recommended Path: Fuel Invariant `fuel > (B-k)*B`

**Core invariant**: `fuel > (closure_F_bound phi - k) * closure_F_bound phi`

**Why it works**:
1. **Initially satisfied**: `B*B+1 > (B-0)*B = B*B` (by omega)
2. **Preserved on forward step** (k → k+1, fuel → fuel-1):
   - From `fuel > (B-k)*B = (B-k-1)*B + B`
   - So `fuel ≥ (B-k-1)*B + B + 1`
   - Thus `fuel-1 ≥ (B-k-1)*B + B > (B-k-1)*B = (B-(k+1))*B` ✓
3. **Implies fuel > 0**: When `k < B`, `(B-k)*B ≥ B > 0`, so `fuel > 0`
4. **Refutes fuel=0 case**: `0 > (B-k)*B` is false when `k < B`

**Open question from synthesis**: Does the invariant survive **defer** steps where `k` stays the same but `fuel` decreases? If fuel drops by 1 and k is unchanged:
- Need `fuel-1 > (B-k)*B`
- From `fuel > (B-k)*B`: `fuel ≥ (B-k)*B + 1`, so `fuel-1 ≥ (B-k)*B`
- This gives `fuel-1 ≥ (B-k)*B`, NOT strictly greater
- **This must be verified against the actual recursion**: does every defer also decrease fuel, or only resolves?

If defers also consume fuel, the invariant needs strengthening, e.g., `fuel > (B-k)*B + defers_remaining`. This is still feasible but adds complexity.

### Verification Checklist Before Implementation

Before creating a new plan, verify these claims against the actual code:

1. **When does fuel decrease?** Does fuel-1 happen on every recursive call, or only on resolve/forward steps?
2. **Does k always advance by exactly 1 on resolve?** Or can it advance by more?
3. **Is `d < B` always provable from DRM bounds?** Teammate B relies on this for the contradiction in fuel=0 case.
4. **For Int-indexed variants**: How does `n : Int` relate to the Nat position measure?
5. **Is `f_nesting_depth` defined?** If so, is the nested induction still worth investigating as a cleaner alternative?

### Effort Comparison

| Approach | Effort | Restructuring | Risk |
|----------|--------|---------------|------|
| Fuel invariant `fuel > (B-k)*B` | 4-6h | Minimal (add 1 hypothesis) | Medium (defer-step preservation) |
| Nested strong induction | 4-6h | Significant (rewrite functions) | High (invariant may not hold) |
| Accept sorries | 0h | None | N/A (rejected) |

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A (fuel-historian) | Past attempt analysis | completed | High |
| B (alternatives-researcher) | Alternative approaches | completed | Medium-High |

## Conflicts Found

1. **Nested induction vs. fuel invariant**: Resolved in favor of fuel invariant (more concrete, less restructuring, algebraically verified). Nested induction has unresolved invariant preservation issues.

## Gaps Identified

1. **Defer-step fuel consumption**: Need to verify whether defers consume fuel in the actual recursion
2. **f_nesting_depth existence**: If defined in codebase, nested induction may still be viable as a cleaner long-term solution
3. **Int-indexed variant specifics**: Teammate B sketched the approach but didn't verify against actual function signatures

## References

- All plans: specs/067_prove_bundle_validity_implies_provability/plans/01-10
- Report 24: specs/067_prove_bundle_validity_implies_provability/reports/24_fuel-exhaustion-research.md
- Summary 12: specs/067_prove_bundle_validity_implies_provability/summaries/12_well-founded-summary.md
- Teammate A findings: specs/067_prove_bundle_validity_implies_provability/reports/31_teammate-a-findings.md
- Teammate B findings: specs/067_prove_bundle_validity_implies_provability/reports/31_teammate-b-findings.md
