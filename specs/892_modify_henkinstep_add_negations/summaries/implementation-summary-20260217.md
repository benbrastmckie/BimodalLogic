# Implementation Summary: Task #892 - Modify henkinStep to Add Negations

**Status**: PARTIAL - Mathematical Obstruction Discovered (Hard Blocker)
**Date**: 2026-02-17
**Sessions**:
- sess_1771374357_3e4c3a (earlier session - discovered initial counterexample)
- sess_1771376322_b2285b (middle session - implemented modification, found saturation issue)
- sess_1771377751_c70928 (current session - fixed saturation, discovered fundamental obstruction)

## Executive Summary

This session made significant progress on Task #892:

1. **Fixed henkinStep saturation issue**: Modified `henkinStep` to add `temporalPackage(neg(φ))` instead of `{neg(φ)}`. This preserves temporal saturation when adding negations and fixed 2 sorries (lines 494, 542).

2. **Discovered fundamental mathematical obstruction**: The theorem `maximal_tcs_is_mcs` appears to be mathematically FALSE as stated. A set can be maximal among temporally-saturated consistent sets without being a maximal consistent set. This is a **hard blocker** requiring user review.

---

## Changes Made

### 1. henkinStep Modified (Improved)

```lean
-- BEFORE (middle session):
else if SetConsistent (S ∪ {Formula.neg φ}) then
  S ∪ {Formula.neg φ}

-- AFTER (this session):
else if SetConsistent (S ∪ temporalPackage (Formula.neg φ)) then
  S ∪ temporalPackage (Formula.neg φ)
```

**Impact**: This ensures witnesses are included when adding negations, preserving temporal saturation of henkinLimit.

### 2. Saturation Proofs Fixed

- `henkinLimit_forward_saturated` - No more sorries
- `henkinLimit_backward_saturated` - No more sorries

The key insight: if `F(ψ) ∈ temporalPackage(neg(φ))`, then `ψ ∈ temporalPackage(neg(φ))` by `forward_witness_in_package`.

### 3. maximal_tcs_is_mcs Restructured

- Added well-founded induction on formula complexity
- Case 1 (neg(φ) ∈ M): PROVEN via `set_consistent_not_both`
- Case 2 (neg(φ) ∉ M): BLOCKED by fundamental obstruction

---

## Mathematical Obstruction Analysis

### The Core Problem

When φ = F(ψ) (a forward temporal formula) and we want to show `insert φ M ∈ TCS`:
- If ψ ∈ M: `insert F(ψ) M` is forward saturated, can use maximality contradiction
- If ψ ∉ M: `insert F(ψ) M` is NOT forward saturated, cannot show it's in TCS

In the second case, `insert F(ψ) M` might be:
- Consistent (doesn't help - we need inconsistency for MCS)
- NOT in TCS (doesn't contradict TCS maximality)

This is NOT a proof gap - it reflects mathematical reality. A set can be:
- Maximal in TCS (no temporally-saturated consistent superset)
- But NOT an MCS (some formula can be consistently added, just not while preserving saturation)

### Why This Is Different From Earlier Issues

The earlier counterexample `{neg(psi), G(psi)}` was INVALID due to T-axiom (G(X) → X).

This new obstruction is different:
- When neg(ψ) ∈ M and F(ψ) ∈ insert(F(ψ), M):
- The set {F(ψ), neg(ψ)} IS consistent (F(ψ) talks about some future, neg(ψ) talks about now)
- So insert F(ψ) M can be consistent without violating temporal saturation (since F(ψ)'s witness ψ is NOT in M but neg(ψ) IS)

### Requires User Review

This is a **hard blocker** because:
1. The theorem as stated appears mathematically false
2. Alternative proof strategies (complexity induction, T-axiom reasoning) all hit the same wall
3. The fundamental tension between temporal saturation and MCS completeness cannot be resolved within the current framework

---

## Current Sorry Count: 4

All in `maximal_tcs_is_mcs`:
1. Line 750: Forward witness case, neg(ψ) ∈ M
2. Line 773: Forward witness case, neg(ψ) ∉ M, insert ψ M consistent
3. Line 794: Forward witness case, neg(ψ) ∉ M, insert ψ M inconsistent
4. Line 799: Backward witness case (symmetric)

---

## Build Status

`lake build` succeeds with 4 sorries.

---

## Recommendations

### Option 1: RecursiveSeed Alternative (Recommended)
Use the RecursiveSeed construction (Task 864/880) which pre-places ALL temporal witnesses BEFORE Lindenbaum extension. This bypasses the TCS/MCS tension by ensuring witnesses are always present.

### Option 2: Strengthen Hypotheses
Add hypotheses to `maximal_tcs_is_mcs` that ensure the problematic cases cannot occur. For example, require that for every φ in the base, all witnesses are also present.

### Option 3: Different Construction
Use a construction that builds MCS and temporal saturation simultaneously, rather than trying to prove one implies the other.

---

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`:
  - henkinStep definition
  - henkinLimit_forward_saturated proof
  - henkinLimit_backward_saturated proof
  - maximal_tcs_is_mcs proof structure

---

## Impact on Related Tasks

- **Task 888**: Depends on `maximal_tcs_is_mcs`. This hard blocker means task 888's Phase 3 approach needs revision.
- **Task 881**: Transitively blocked via task 888.

---

## Technical Evidence

### Semantic Argument for Obstruction

Consider M with neg(ψ) ∈ M and F(ψ) ∉ M:
- Semantic interpretation: at time t=0, ψ is false (neg(ψ) true), ψ is true at some future time (F(ψ) true when added)
- This is semantically consistent (ψ false now, true later)
- But insert F(ψ) M fails temporal saturation (F(ψ) present without ψ)
- So insert F(ψ) M is consistent but not in TCS
- M is maximal in TCS but not MCS

### Key Lemma Names Verified
- `set_consistent_not_both` (MCSProperties.lean)
- `forward_witness_in_package` (TemporalLindenbaum.lean)
- `backward_witness_in_package` (TemporalLindenbaum.lean)
- `temporalPackage` (TemporalLindenbaum.lean)
