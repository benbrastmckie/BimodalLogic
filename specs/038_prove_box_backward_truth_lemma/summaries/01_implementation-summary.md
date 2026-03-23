# Implementation Summary: Task #38 - prove_box_backward_truth_lemma

## Status: BLOCKED (Architectural Limitation)

## Executive Summary

The sorry at `SuccChainTruth.lean:254` (Box backward direction) is **architecturally unprovable** for the singleton-Omega model. The plan's migration to multi-family BFMCS pattern is blocked by the same W=D conflation issue identified in Task 28 (DirectMultiFamilyBFMCS).

## Phase 1 Completed: Audit Findings

### Sorry Inventory

| File | Line | Status | Cause |
|------|------|--------|-------|
| SuccChainTruth.lean | 254 | UNPROVABLE | Singleton Omega - converse of T-axiom |
| DirectMultiFamilyBFMCS.lean | 308 | UNPROVABLE | Cross-family transfer at t=0 |
| DirectMultiFamilyBFMCS.lean | 311 | UNPROVABLE | Cross-family transfer at t!=0 |
| DirectMultiFamilyBFMCS.lean | 421 | UNPROVABLE | modal_backward at t!=0 |
| ModalSaturation.lean | - | SORRY-FREE | saturated_modal_backward proven |
| ModallyCoherentBFMCS.lean | - | SORRY-FREE | discreteMCS_modal_backward proven |

### Key Infrastructure Analysis

1. **`saturated_modal_backward`** (ModalSaturation.lean): Works for BFMCS with `is_modally_saturated` proof. **Sorry-free**.

2. **`discreteMCS_modal_backward`** (ModallyCoherentBFMCS.lean): Works at MCS level using `discreteClosedMCS` saturation. **Sorry-free**.

3. **`parametric_box_persistent`** (ParametricTruthLemma.lean): Box phi persists to all times via TF axiom. **Sorry-free**.

4. **`ParametricTruthLemma`**: Full truth lemma for D-parametric BFMCS with modal_backward. **Sorry-free for Box**.

## Phases 2-5: BLOCKED

### Root Cause: W=D Conflation Problem

The BFMCS `modal_backward` condition requires cross-family modal transfer at **the same time t**:

```
modal_backward : forall fam in families, forall phi t,
  (forall fam' in families, phi in fam'.mcs t) -> Box phi in fam.mcs t
```

For multi-family BFMCS indexed by Int:
- At t=0: Families can cover `discreteClosedMCS M0`, so saturation holds
- At t!=0: Chain positions may leave the closed set, breaking saturation

The `discreteMCS_modal_backward` operates at the **world state** level, not the **time-indexed chain position** level. This is the W=D conflation:
- W = world states (CanonicalMCS)
- D = time indices (Int)

### Why `parametric_box_persistent` Doesn't Help

The plan suggested:
> "Box phi persists to all times via TF axiom, so modal_backward at t reduces to modal_backward at t=0"

This requires: `phi in ALL families at t` implies `phi in ALL families at 0`.

This is **false**: knowing phi at chain positions at time t tells us nothing about positions at time 0.

### Why Singleton Omega Is Fundamentally Limited

For singleton Omega `{succ_chain_history M0}`:
- `h_all : forall sigma in Omega, truth sigma t psi` reduces to `truth at M0's chain at t`
- By IH: `psi in succ_chain_fam M0 t`
- Goal: `Box psi in succ_chain_fam M0 t`

This requires: `psi in MCS` implies `Box psi in MCS`.

This is the **converse of the T-axiom** (`Box psi -> psi`), which is mathematically false for arbitrary formulas and MCS.

## Impact on Completeness

**Non-blocking**: The `succ_chain_truth_forward` (forward direction) is all that's needed for completeness. The sorry is documented as "not needed for completeness" at line 252-253.

## Existing Working Infrastructure

The following modules provide sorry-free Box backward:

1. **`ParametricTruthLemma.lean`**: Uses `B.modal_backward` for BFMCS
2. **`StagedConstruction/TimelineQuotCompleteness.lean`**: Uses TimelineQuot domain

These work because they use proper BFMCS with verified modal_backward, not singleton Omega.

## Recommendations

### Option 1: Accept Limitation (Recommended)

Keep the sorry documented as architecturally unprovable. The SuccChain completeness proof only uses the forward direction.

### Option 2: Replace SuccChainTruth

Replace with a version using `ParametricTruthLemma` pattern. This requires:
1. Creating a temporally coherent BFMCS Int with proven modal_backward
2. Changing the Omega from singleton to multi-family
3. Essentially rewriting the entire truth lemma

This is significant rework with unclear benefit (completeness already works).

### Option 3: Alternative Completeness Path

Use the existing `TimelineQuotCompleteness` or `AlgebraicBaseCompleteness` paths which have sorry-free Box handling.

## Files Examined

- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` - Target sorry
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Saturation infrastructure
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` - Prior attempt
- `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean` - MCS-level modal backward
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Working pattern
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Uses only forward direction

## Conclusion

The task as specified cannot be completed without fundamental architectural changes. The sorry is a correct documentation of an unprovable goal in the singleton-Omega model. The completeness theorem is unaffected.
