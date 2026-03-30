# Implementation Summary: Task #67 (Plan v11) - Partial

**Task**: prove_bundle_validity_implies_provability
**Plan**: v11 - Fuel Invariant Approach
**Status**: PARTIAL
**Date**: 2026-03-29
**Session**: sess_1774831109_92785f

## Summary

Attempted to implement the fuel invariant approach from Plan v11 to eliminate fuel=0 sorries. The approach partially succeeded for Phase 1 (forward bounded witness) but encountered a blocker.

## Progress

### Phase 1: Forward Bounded Witness [PARTIAL]

**Target**: `restricted_bounded_witness_wf` (lines 2883-2997)

**Implemented**:
1. Changed invariant from "fuel sufficiency" to `remaining_steps >= (B - k) * B + 1`
2. Updated function signature to include `h_inv` hypothesis
3. Eliminated fuel=0 sorry using exfalso + omega:
   - When `remaining_steps = 0`, invariant gives `0 >= (B-k)*B + 1 >= 1`, contradiction

**Blocked**:
- Two new sorries introduced at lines 3006 and 3037 for the `k >= B` case
- The invariant preservation requires `remaining' >= 1` when `k >= B`
- But we only have `remaining' >= 0` from the hypothesis

**Root Cause**:
- When `k >= B`, the invariant `remaining_steps >= (B-k)*B + 1` degenerates to `remaining_steps >= 1`
- After one step, need `remaining_steps - 1 >= 1`, i.e., `remaining_steps >= 2`
- But initial invariant only guarantees `remaining_steps >= 1`

**Possible Fixes**:
1. **Chain Stabilization Lemma**: Prove that `k >= B` is impossible when there's an unresolved F-boundary. The chain stabilizes after B steps, so any formula with `iter_F d theta in chain(k)` and `iter_F (d+1) theta not in chain(k)` must have `k < B`.

2. **Strengthen Initial Fuel**: Use `B*(B+1)+1` or higher to ensure `remaining_steps >= 2` when `k >= B`.

3. **Add `k < B` Hypothesis**: Require callers to prove `k < B` before calling the function.

### Phases 2-5: NOT STARTED

The remaining phases (backward, combined F, combined P, verification) were not attempted due to Phase 1 blocker.

## File Changes

**Modified**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Lines 2868-2997: `restricted_bounded_witness_wf` - updated signature and proof
  - Lines 3008-3025: `restricted_bounded_witness` - updated wrapper with new invariant

## Sorry Inventory

### Target Sorries (this task)
| Line | Function | Status |
|------|----------|--------|
| 2909, 2911 | `restricted_bounded_witness_wf` fuel=0 | ELIMINATED via exfalso |
| 3006, 3037 | `restricted_bounded_witness_wf` k>=B | NEW - needs stabilization lemma |
| 5610 | `restricted_backward_bounded_witness_fueled` | NOT STARTED |
| 5768 | `restricted_combined_bounded_witness_fueled` | NOT STARTED |
| 5964 | `restricted_combined_bounded_witness_P_fueled` | NOT STARTED |

### Non-target Sorries (unchanged)
| Line | Function | Reason |
|------|----------|--------|
| 1659 | `g_content_union_brs_consistent` | Deprecated path |
| 1688 | `augmented_seed_consistent` | Deprecated path |
| 2005 | `constrained_successor_seed_restricted_consistent` | Deprecated path |

## Recommendations

1. **Immediate**: Prove chain stabilization lemma for `k >= B` case. This is a semantic property of `restricted_forward_chain` that should be provable from the chain construction.

2. **Alternative**: If stabilization is hard to prove, refactor the function to take `k < B` as hypothesis. Callers would need to verify this condition.

3. **Before Continuing**: Once Phase 1 is resolved, the same approach can be applied to Phases 2-4 with similar structure.

## Build Status

- `lake build`: PASSES
- Sorries: 8 total (3 deprecated, 2 new in Phase 1, 3 remaining targets)
- Axioms: No new axioms introduced
