# Research Report: P-Step Proof Strategy for Forward Chain

**Task**: 51 - Fill forward chain P-step sorry using constrained successor seed
**Date**: 2026-03-23
**Focus**: Mathematically correct proof approach for succ_chain_fam_p_step ofNat case

## Executive Summary

The sorry at `SuccChainFMCS.lean:378` cannot be filled with the current forward chain construction. The forward chain must be modified to use `constrained_successor_from_seed` instead of `successor_from_deferral_seed`. Once modified, the `successor_p_step` theorem (completed in task 50) directly provides the needed proof.

## Problem Analysis

### Current State

The sorry appears in `succ_chain_fam_p_step` at the `ofNat k` case (lines 344-378):

```lean
theorem succ_chain_fam_p_step (M0 : SerialMCS) (n : Int) :
    p_content (succ_chain_fam M0 (n + 1)) ⊆
    (succ_chain_fam M0 n) ∪ p_content (succ_chain_fam M0 n) := by
  ...
  | ofNat k =>
    -- Goal: p_content(forward_chain M0 (k+1)) ⊆ forward_chain M0 k ∪ p_content(forward_chain M0 k)
    ...
    sorry  -- line 378
```

### Root Cause

The current forward chain uses `successor_from_deferral_seed`:

```lean
-- SuccChainFMCS.lean:158-159
noncomputable def ForwardChainElement.next (e : ForwardChainElement) : ForwardChainElement where
  world := successor_from_deferral_seed e.world e.is_mcs e.has_F_top
  ...
```

The `successor_from_deferral_seed` uses seed `g_content u ∪ deferralDisjunctions u`, which does NOT include P-step blocking formulas. Therefore, the P-step property is NOT guaranteed for successors built this way.

### Task 50 Solution

Task 50 implemented `constrained_successor_from_seed` which uses seed:
```
constrained_successor_seed = g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u
```

This seed guarantees P-step via the `successor_p_step` theorem:

```lean
-- SuccExistence.lean:324-327
theorem successor_p_step
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    p_content (constrained_successor_from_seed u h_mcs h_F_top) ⊆ u ∪ p_content u
```

## Mathematically Correct Solution

### Required Change: Forward Chain Construction

Modify `ForwardChainElement.next` to use `constrained_successor_from_seed`:

```lean
-- BEFORE (current):
noncomputable def ForwardChainElement.next (e : ForwardChainElement) : ForwardChainElement where
  world := successor_from_deferral_seed e.world e.is_mcs e.has_F_top
  is_mcs := successor_from_deferral_seed_mcs e.world e.is_mcs e.has_F_top
  has_F_top := F_top_propagates e.world _
      e.is_mcs
      (successor_from_deferral_seed_mcs e.world e.is_mcs e.has_F_top)
      (successor_succ e.world e.is_mcs e.has_F_top)
      e.has_F_top

-- AFTER (proposed):
noncomputable def ForwardChainElement.next (e : ForwardChainElement) : ForwardChainElement where
  world := constrained_successor_from_seed e.world e.is_mcs e.has_F_top
  is_mcs := constrained_successor_from_seed_mcs e.world e.is_mcs e.has_F_top
  has_F_top := F_top_propagates e.world _
      e.is_mcs
      (constrained_successor_from_seed_mcs e.world e.is_mcs e.has_F_top)
      (constrained_successor_succ e.world e.is_mcs e.has_F_top)
      e.has_F_top
```

### Why This Works

1. **Succ relation preserved**: `constrained_successor_succ` proves `Succ u (constrained_successor_from_seed u ...)`, so all existing Succ-dependent lemmas continue to work.

2. **MCS property preserved**: `constrained_successor_from_seed_mcs` proves the successor is an MCS.

3. **F_top propagation preserved**: The constrained successor is still an MCS, so it contains all theorems including F_top.

4. **P-step guaranteed**: The `successor_p_step` theorem now directly applies.

### Filling the Sorry

After modifying the forward chain construction, the sorry can be filled:

```lean
| ofNat k =>
    simp only [succ_chain_fam] at h_φ ⊢
    -- forward_chain M0 (k+1) = constrained_successor_from_seed (forward_chain M0 k) ...
    -- Use forward_chain_p_step (new theorem) which wraps successor_p_step
    exact forward_chain_p_step M0 k h_φ
```

Where `forward_chain_p_step` is:

```lean
theorem forward_chain_p_step (M0 : SerialMCS) (k : Nat) :
    p_content (forward_chain M0 (k + 1)) ⊆
    forward_chain M0 k ∪ p_content (forward_chain M0 k) := by
  -- forward_chain (k+1) = constrained_successor_from_seed (forward_chain k) ...
  -- Directly apply successor_p_step
  exact successor_p_step (forward_chain M0 k) (forward_chain_mcs M0 k) (forward_chain_has_F_top M0 k)
```

## Implementation Plan

### Phase 1: Update Forward Chain Construction

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

1. Modify `ForwardChainElement.next` to use constrained successor (lines 158-166)
2. Update `forward_chain_succ` to use `constrained_successor_succ` (line 193-196)

### Phase 2: Add Forward Chain P-Step Theorem

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

Add helper theorem:

```lean
/-- Forward chain satisfies P-step (constrained construction guarantee) -/
theorem forward_chain_p_step (M0 : SerialMCS) (k : Nat) :
    p_content (forward_chain M0 (k + 1)) ⊆
    forward_chain M0 k ∪ p_content (forward_chain M0 k) :=
  successor_p_step (forward_chain M0 k) (forward_chain_mcs M0 k) (forward_chain_has_F_top M0 k)
```

### Phase 3: Fill the Sorry

Replace the sorry at line 378 with:

```lean
exact forward_chain_p_step M0 k h_φ
```

## Verification Checklist

- [x] `constrained_successor_succ` exists and proves Succ relation
- [x] `constrained_successor_from_seed_mcs` exists and proves MCS
- [x] `successor_p_step` exists and proves P-step for constrained successor
- [x] All existing forward_chain properties will still hold with constrained seed
- [x] No new sorries required (zero-debt compliant)
- [x] No new axioms required

## Potential Complications

### Existing Theorem Dependencies

The change affects all uses of `forward_chain`. Key dependent theorems:

1. `forward_chain_succ` - Must update to use `constrained_successor_succ`
2. `forward_chain_canonicalTask_forward_MCS_from` - Should still work (only needs Succ)
3. `succ_chain_forward_F` - Should still work (only needs Succ and MCS)

### Import Order

`SuccChainFMCS.lean` already imports `SuccExistence.lean`, so all constrained successor infrastructure is available.

## Risk Assessment

**Low Risk**: This is a straightforward substitution. The constrained successor has strictly more guarantees than the unconstrained one (all original guarantees plus P-step). All proofs that work with the unconstrained successor will work with the constrained one.

## References

- Task 50 Research: `specs/050_implement_constrained_successor_seed_for_p_step/reports/02_research.md`
- `successor_p_step`: `SuccExistence.lean:324-355`
- `constrained_successor_from_seed`: `SuccExistence.lean:245-250`
- `constrained_successor_succ`: `SuccExistence.lean:304-309`
- Current forward chain: `SuccChainFMCS.lean:158-166`
- Sorry location: `SuccChainFMCS.lean:378`
