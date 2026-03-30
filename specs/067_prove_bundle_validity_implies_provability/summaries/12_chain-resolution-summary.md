# Implementation Summary: Task #67 (Plan v12)

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: BLOCKED at Phase 1
- **Session**: sess_1774880697_892c63
- **Date**: 2026-03-29

## Executive Summary

Phase 1 (proving the boundary stabilization lemma) is **fundamentally blocked**. Extensive analysis confirms the research team's findings: the stabilization lemma `boundary_implies_k_lt_B` is **unprovable** with the current chain construction. The fuel-based termination argument has a genuine gap in the `k >= B` case that cannot be closed without either:

1. Modifying the chain construction (Option A from research)
2. Using a different termination argument (Option B)
3. Bypassing the bounded witness entirely (Option C)
4. Adding `k < B` as a hypothesis and propagating it (Option D)

## Technical Analysis

### The k >= B Gap

The `restricted_bounded_witness_wf` function uses a fuel-based termination argument with invariant:

```
remaining_steps >= (closure_F_bound phi - k) * closure_F_bound phi + 1
```

When `k >= B` (where B = closure_F_bound phi):
- The invariant degenerates to `remaining_steps >= 1`
- After one recursive call, we have `remaining' >= 0`
- The recursive call requires `remaining' >= 1`
- **Gap**: we need `remaining' >= 1` but only have `remaining' >= 0`

### Why Strengthening the Invariant Fails

I attempted multiple invariant formulations:
- `remaining_steps >= (B - k) * B + 2`
- `remaining_steps >= (B - k) * B + max(1, B - k)`
- `remaining_steps >= (B - k) * B + B`
- `remaining_steps >= (B - k) * B + B + 1`

All fail for the same reason: in the k >= B regime, the (B - k) term becomes 0, collapsing the fuel guarantee to a constant. The recursive calls can still happen (since the termination measure `remaining_steps` is independent of k), creating the gap.

### Why the Stabilization Lemma is Unprovable

The research team correctly identified:

1. **`boundary_resolution_set` only forces resolution at max depth (B-1)**: Formulas at depths d < B-1 can be deferred indefinitely by the Lindenbaum extension.

2. **No fairness/priority scheme exists**: The chain construction via Zorn's lemma is noncomputable and doesn't guarantee eventual resolution of deferred formulas.

3. **Depth bound != Position bound**: Having `d < B` (depth bounded) does NOT imply `k < B` (position bounded). These are independent measures.

### Fuel is Actually Sufficient (But Invariant Doesn't Capture It)

Interestingly, the ACTUAL fuel is sufficient:
- Initial fuel: `B * (B + 1) + 1`
- Max work: `B * B` (at most B resolves, each with at most B-1 defers)
- When entering k >= B regime: at least `B * B + 1` fuel remaining
- Remaining work: at most `B * B`

The issue is that the **invariant** doesn't express this correctly. The invariant uses `(B - k)` which collapses to 0, while the actual fuel tracking would need to account for initial k and steps taken.

## Proof State at Sorries

### Line 3006 (first sorry)

```
h_d_lt : n + 1 < closure_F_bound phi
hk : closure_F_bound phi <= k
h_inv : remaining' + 1 >= 1
Goal: False
```

We have `n + 1 < B <= k`, so the depth is bounded while position exceeds the bound. The semantic claim is that this should be impossible, but no formal proof exists.

### Line 3037 (second sorry)

Structurally identical to the first - same gap in the defer case.

## Recommendations

### Short-term (Highest probability of success)

**Option D: Add `k < B` hypothesis** to `restricted_bounded_witness_wf`. This:
- Eliminates the k >= B branch entirely
- Propagates the burden to callers
- May break at higher call sites (need analysis)

### Medium-term (More robust)

**Option B: Well-founded recursion on unresolved obligations**. Define a measure:
- Track set of F-formulas with active boundaries
- Show this set shrinks on resolve steps
- Use `Acc`-based termination proof

### Long-term (Most complete)

**Option A: Strengthen chain construction** with a priority/fairness scheme that forces resolution at all depths within bounded steps. This would make the stabilization lemma true by construction.

## Files Modified

None - the sorries remain at lines 3006 and 3037 of `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`.

## Next Steps

1. Consider implementing Option D as a quick fix
2. Investigate whether Option B can be formalized in Lean
3. Long-term: explore Option A construction changes

## References

- Research report: `specs/067_prove_bundle_validity_implies_provability/reports/34_team-research.md`
- Plan: `specs/067_prove_bundle_validity_implies_provability/plans/12_chain-resolution.md`
- Source file: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 2890-3042)
