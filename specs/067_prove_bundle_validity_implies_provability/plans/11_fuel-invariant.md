# Implementation Plan: Task #67 (Plan v11)

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Dependencies**: Report 31 (team research: fuel approach viability)
- **Research Inputs**: specs/067_prove_bundle_validity_implies_provability/reports/31_team-research.md
- **Artifacts**: plans/11_fuel-invariant.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Eliminate the four fuel=0 sorries by threading a quadratic fuel invariant `fuel > (B-k)*B` through the recursion. This approach:
- Keeps the existing recursion structure (minimal restructuring)
- Adds one hypothesis to each fueled function
- Replaces each sorry with an `exfalso` contradiction proof

### Why This Approach (from Team Research)

Plan v10's well-founded restructure was **blocked** because depth can increase on resolve operations. The fuel invariant sidesteps this entirely by tracking only `(k, fuel)` which move in lockstep — every recursive call does `k → k+1` and `fuel → fuel-1`.

The invariant `fuel > (B-k)*B`:
1. **Initially satisfied**: `B*B+1 > (B-0)*B = B*B`
2. **Preserved on every step**: From `fuel > (B-k)*B`, we get `fuel-1 > (B-(k+1))*B`
3. **Refutes fuel=0**: When `fuel=0` and `k < B`, `0 > (B-k)*B ≥ B > 0` is contradictory

### Previous Progress (Preserved)

From Plan v9 (completed):
- `constrained_predecessor_restricted_g_persistence_reverse` (line 3944) ✓
- `constrained_predecessor_restricted_f_step_forward` (line 4001) ✓

## Goals & Non-Goals

**Goals**:
- Add fuel invariant hypothesis to all four fueled lemmas
- Eliminate all four fuel=0 sorries via contradiction
- Verify with `lake build` and axiom check
- Wire through to completeness if needed

**Non-Goals**:
- Restructuring the recursion (keep existing structure)
- Eliminating the fuel parameter entirely (that's for a future cleanup)
- Fixing deprecated sorry sites (lines 1659, 1688, 2005)
- Fixing Soundness.lean sorries (separate concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Nat subtraction edge case when k >= B | M | M | Split on `k < B` vs `k >= B` with omega |
| Invariant proof doesn't close with omega | M | L | Add explicit intermediate have statements |
| Int-indexed variants need different invariant | M | M | Use `n.toNat` or absolute offset from origin |
| Side condition `k < B` not available | M | L | Derive from `d >= 1` + DRM depth bounds |

## Implementation Phases

### Phase 1: Forward Bounded Witness [NOT STARTED]

**Target**: `restricted_bounded_witness_wf` (line ~2883)

**Step 1.1**: Add invariant hypothesis to function signature
```lean
private theorem restricted_bounded_witness_wf (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (remaining_steps : Nat)
    (h_d_ge : d >= 1)
    (h_inv : remaining_steps > (closure_F_bound phi - k) * closure_F_bound phi)  -- NEW
    (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k) :
    ∃ m : Nat, m > k ∧ theta ∈ restricted_forward_chain phi M0 m
```

**Step 1.2**: Eliminate sorry at lines 2909, 2911 (fuel=0, d >= 1 case)
```lean
| 0 =>
  | 0 => exact absurd h_d_ge (by omega : ¬0 >= 1)
  | n + 1 =>
    -- From h_inv: 0 > (B - k) * B
    -- From h_d_ge: d = n + 1 >= 1, so d < B (by h_d_lt)
    -- Therefore k < B (since the chain hasn't exhausted all positions)
    -- So (B - k) * B >= B > 0, contradicting h_inv
    exfalso
    have h_k_lt : k < closure_F_bound phi := by
      -- Derive from DRM bounds: d >= 1 and d < B implies positions remain
      exact Nat.lt_of_le_of_lt (Nat.zero_le k) (by omega)
    have h_pos : (closure_F_bound phi - k) * closure_F_bound phi > 0 := by
      have : closure_F_bound phi - k >= 1 := by omega
      exact Nat.mul_pos this (by omega)
    exact Nat.not_lt.mpr (Nat.zero_le _) h_inv
```

**Step 1.3**: Prove invariant preserved at recursive calls (lines 2944, 2959)
```lean
-- For recursive call at k+1 with remaining_steps' = remaining_steps - 1:
have h_inv' : remaining_steps - 1 > (closure_F_bound phi - (k + 1)) * closure_F_bound phi := by
  -- From h_inv: remaining_steps > (B - k) * B = (B - k - 1) * B + B
  -- So remaining_steps >= (B - k - 1) * B + B + 1
  -- Thus remaining_steps - 1 >= (B - k - 1) * B + B > (B - k - 1) * B
  have h_expand : (closure_F_bound phi - k) * closure_F_bound phi =
      (closure_F_bound phi - k - 1) * closure_F_bound phi + closure_F_bound phi := by
    ring_nf
    -- Handle Nat subtraction: need k < B
    sorry -- Will need case split or derive from h_d_lt
  omega
```

**Step 1.4**: Update wrapper to pass initial invariant
```lean
theorem restricted_bounded_witness (phi : Formula) ... := by
  let B := closure_F_bound phi
  have h_inv : B * B + 1 > (B - 0) * B := by simp; omega
  exact restricted_bounded_witness_wf phi M0 k theta d (B * B + 1)
    h_d_ge h_inv h_iter_in h_iter_not
```

**Timing**: 1.5 hours

**Verification**:
- `lake build` passes
- Lines 2909, 2911 sorries eliminated
- `#print axioms restricted_bounded_witness` shows no sorryAx

---

### Phase 2: Backward Bounded Witness [NOT STARTED]

**Target**: `restricted_backward_bounded_witness_fueled` (line ~5480)

Same pattern as Phase 1:
1. Add `h_inv` hypothesis
2. Eliminate sorry at line 5523 via contradiction
3. Prove invariant preserved at recursive calls
4. Update wrapper

**Key difference**: Backward chain uses same structure but different position semantics. The invariant should still work since k advances by 1 on each recursive call.

**Timing**: 1 hour

**Verification**:
- `lake build` passes
- Line 5523 sorry eliminated

---

### Phase 3: Combined Bounded Witness (Int-indexed) [NOT STARTED]

**Target**: `restricted_combined_bounded_witness_fueled` (line ~5640)

**Int-indexed adjustment**: Position is `n : Int`, not `Nat`. Options:
- Use `n.toNat` for non-negative positions
- Use `|n - origin|` as offset measure
- Split cases on n >= 0 vs n < 0

**Recommended approach**: The invariant becomes:
```lean
h_inv : remaining_steps > (closure_F_bound phi - chain_extent n origin) * closure_F_bound phi
```
where `chain_extent n origin = |n - origin|.toNat.min (closure_F_bound phi)`

**Steps**:
1. Define helper `chain_extent` or inline the calculation
2. Add `h_inv` with Int-aware bound
3. Eliminate sorry at line 5681
4. Update wrapper

**Timing**: 1 hour

**Verification**:
- `lake build` passes
- Line 5681 sorry eliminated

---

### Phase 4: Combined Bounded Witness P (Int-indexed) [NOT STARTED]

**Target**: `restricted_combined_bounded_witness_P_fueled` (line ~5830)

Same pattern as Phase 3, using Int-aware invariant.

**Timing**: 1 hour

**Verification**:
- `lake build` passes
- Line 5877 sorry eliminated

---

### Phase 5: Verification & Wiring [NOT STARTED]

**Goal**: Verify completeness path is sorry-free.

**Steps**:
1. Run `#print axioms restricted_bounded_witness`
2. Run `#print axioms restricted_backward_bounded_witness`
3. Run `#print axioms restricted_combined_bounded_witness`
4. Run `#print axioms restricted_combined_bounded_witness_P`
5. Run `#print axioms build_restricted_tc_family`
6. Run `#print axioms bundle_validity_implies_provability`

If any show sorryAx, trace the dependency and fix.

**Timing**: 0.5 hours

**Verification**:
- All axiom checks pass
- `lake build` clean

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] Lines 2909, 2911 sorries eliminated (Phase 1)
- [ ] Line 5523 sorry eliminated (Phase 2)
- [ ] Line 5681 sorry eliminated (Phase 3)
- [ ] Line 5877 sorry eliminated (Phase 4)
- [ ] `#print axioms bundle_validity_implies_provability` clean (Phase 5)

## Artifacts & Outputs

- Modified `SuccChainFMCS.lean` with fuel invariant in all bounded witnesses
- Implementation summary documenting the invariant approach
- Zero-debt completeness path

## Rollback/Contingency

If the invariant proof doesn't close with omega:
1. Add explicit intermediate lemmas for Nat subtraction arithmetic
2. Use `have` statements to guide omega
3. If still stuck, use `decide` or `native_decide` for concrete bounds

If Int-indexed variants resist the invariant:
1. Convert Int position to Nat offset: `(n - origin).natAbs`
2. Or track forward/backward separately with two invariants

## Sorry Inventory After This Plan

### Eliminated by This Plan
| Line | Theorem | Phase |
|------|---------|-------|
| 2909, 2911 | `restricted_bounded_witness_wf` | Phase 1 |
| 5523 | `restricted_backward_bounded_witness_fueled` | Phase 2 |
| 5681 | `restricted_combined_bounded_witness_fueled` | Phase 3 |
| 5877 | `restricted_combined_bounded_witness_P_fueled` | Phase 4 |

### Already Eliminated (Plan v9)
| Line | Theorem | Status |
|------|---------|--------|
| 3944 | `constrained_predecessor_restricted_g_persistence_reverse` | COMPLETED |
| 4001 | `constrained_predecessor_restricted_f_step_forward` | COMPLETED |

### Non-critical (not addressed)
| Line | Theorem | Reason |
|------|---------|--------|
| 1659 | `g_content_union_brs_consistent` | Deprecated path |
| 1688 | `augmented_seed_consistent` | Deprecated path |
| 2005 | `constrained_successor_seed_restricted_consistent` (multi-BRS) | Deprecated path |
| RestrictedTruthLemma:116 | `restricted_chain_G_propagates` | Not needed for completeness |
| RestrictedTruthLemma:158 | `restricted_chain_H_step` | Not needed for completeness |
