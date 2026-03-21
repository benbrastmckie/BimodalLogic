# Implementation Summary: Task #981 - Coverage-Based Approach (Partial)

**Completed**: 2026-03-18
**Duration**: ~2 hours
**Status**: PARTIAL - Definitions created, proofs blocked by termination issue

## Overview

Attempted to implement the coverage-based approach from research report 27 to resolve the forward_F/backward_P termination issues. Created the CanonicalR_chain definitions but discovered the coverage theorem and forward_F_via_coverage proofs have a deeper termination problem than anticipated.

## Changes Made

### New File Created

- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverageReach.lean`
  - Defines `CanonicalR_chain root W n`: W is reachable from root via n CanonicalR steps
  - Defines `CanonicalR_reachable root W`: Existential version
  - Proves `reachable_root` and `reachable_step` (basic chain properties)
  - Proves `root_in_timeline`: The root is in the dovetailed timeline
  - Defines `CanonicalR_chain_backward` for P-formula witnesses

### No Changes to Existing Files

The coverage proofs were not completed, so the existing sorries in DovetailedTimelineQuot.lean remain:
- Line 295: `dovetailedTimeline_has_intermediate` (DenselyOrdered helper)
- Line 806: `forward_F_core` (small step j > 0 case)
- Line 959: `forward_F_chain_witness` (j > 0 case)
- Line 1028: `backward_P_chain_witness` (j > 0 case)

## Blocking Issue

The forward_F termination problem is deeper than the research report anticipated:

### The Problem

When using the density argument to boost the formula encoding:
1. We get `F^j(phi)` in the witness's MCS instead of `phi`
2. To peel off the j layers of F, we need j recursive calls
3. Each recursive call might introduce its OWN density index j'
4. The accumulated depth (j + j' + j'' + ...) is NOT bounded

### Why Simple Measures Don't Work

| Measure | Why it fails |
|---------|--------------|
| Formula depth (from phi) | Can INCREASE due to density (j > 0) |
| Density index j | Different j' chosen at each level |
| Build stage | Unbounded (timeline grows infinitely) |
| Goal depth | Fixed, but doesn't help with j > 0 case |

### The Research Report's Claim

The report claimed: "After ONE witness_at_large_step, ALL subsequent calls are large steps because w.point_index >= m."

This is NOT PROVABLE because:
- w.point_index = (list length at step m-1)
- List grows sparsely (many steps are no-ops)
- So w.point_index could be much smaller than m
- Then pair(w.point_index, k') might be <= m, requiring density again

## Mathematical Status

The recursion DOES terminate mathematically because:
1. The goal formula (phi) is fixed
2. Each subproblem eventually reaches j = 0
3. The timeline is countable, so paths are finite

But expressing this in Lean requires either:
1. A complex well-founded recursion with non-obvious termination proof
2. Proving a build growth invariant (that list grows densely)
3. Or accepting a localized sorry

## Recommendations

### Option A: Accept Localized Sorry (Quickest)

Keep the existing sorries at lines 806, 959, 1028 with documentation. The mathematical argument is sound; the formalization gap is technical.

### Option B: Prove Build Growth Invariant (Medium Effort)

Prove: `(dovetailedBuildState n).points.length >= f(n)` for some function f such that f(pair(p, k)) > p for all p, k. This would enable the "all subsequent calls are large steps" argument.

### Option C: Complex Well-Founded Recursion (High Effort)

Define a custom well-founded measure on `(Nat, DovetailedPoint, Formula)` that provably decreases. Likely requires tracking the entire recursion tree structure.

## Verification

```bash
# DovetailedCoverageReach builds successfully
lake build Bimodal.Metalogic.StagedConstruction.DovetailedCoverageReach
# Result: Built successfully

# Overall project still has the same sorries
grep -n "sorry" Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean
# Lines: 295, 806, 959, 1028
```

## Files Modified

- `specs/981_remove_axiom_technical_debt_from_task_979/plans/13_coverage-based-approach.md` - Phase 1 marked PARTIAL

## Notes

The coverage-based approach is mathematically correct but requires more sophisticated Lean infrastructure than currently available. The existing forward_F_chain_witness proof structure (strong induction on formula depth) is fundamentally unsuited to the problem due to density-induced depth increase.

A future task could explore:
1. Fuel-based approach with existence proof for sufficient fuel
2. Coinductive formulation of the forward witness sequence
3. Alternative proof strategy bypassing the density argument entirely
