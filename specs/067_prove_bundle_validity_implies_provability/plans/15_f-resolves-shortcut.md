# Implementation Plan: F-Resolves Shortcut (Delete, Don't Fix)

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 1-2 hours
- **Dependencies**: Plan 14 (partial), Research Report 42 (team research)
- **Research Inputs**: reports/42_team-research.md
- **Artifacts**: plans/15_f-resolves-shortcut.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Plan Version**: 15

## Overview

Team Research (Report 42) discovered that `boundary_implies_k_plus_d_bounded` is **likely mathematically FALSE**, not just hard to prove. The g_content sorry is in a theorem whose statement is incorrect.

**Solution**: Delete the flawed theorems and replace with a simple inductive proof using the already-proven `restricted_forward_chain_F_resolves` lemma.

### Key Insight

`restricted_forward_chain_F_resolves` (line 2741) already proves:
```lean
theorem restricted_forward_chain_F_resolves (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 k) :
    psi ∈ restricted_forward_chain phi M0 (k + 1)
```

If `F(psi) ∈ chain(k)`, then `psi ∈ chain(k+1)`. By simple d-induction: if `iter_F d theta ∈ chain(k)` with `d ≥ 1`, then `theta ∈ chain(k + d)`.

This completely bypasses the need for boundary analysis, fuel-based recursion, or the g_content sorry.

## Goals & Non-Goals

**Goals**:
- Delete `boundary_implies_k_plus_d_bounded` and its sorry
- Delete `boundary_implies_k_lt_B`
- Replace `restricted_bounded_witness_wf` with simple d-induction
- Simplify `restricted_forward_chain_forward_F`
- Verify build passes with no new sorries

**Non-Goals**:
- Adding g_nesting_depth infrastructure (not needed for this approach)
- Preserving the boundary analysis theorems (they're mathematically flawed)
- Modifying any code outside SuccChainFMCS.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Callers depend on deleted theorems | M | L | Grep confirms only internal usage |
| Simple induction harder than sketched | L | L | F_resolves does heavy lifting |
| Other theorems secretly depend on boundary lemmas | M | L | Verify with full lake build |

## Implementation Phases

### Phase 1: Add Simple Bounded Witness Lemma [NOT STARTED]

**Goal**: Add `iter_F_resolves_in_d_steps` using simple d-induction

**Tasks**:
- [ ] Add theorem at ~line 2750 (after `restricted_forward_chain_F_resolves`):
  ```lean
  /--
  If iter_F d theta ∈ chain(k) with d ≥ 1, then theta ∈ chain(k + d).
  Simple forward resolution using F_resolves.
  -/
  theorem iter_F_resolves_in_d_steps (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (theta : Formula)
      (h_d_ge : d ≥ 1)
      (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k) :
      theta ∈ restricted_forward_chain phi M0 (k + d) := by
    induction d generalizing k with
    | zero => omega
    | succ n ih =>
      have h_resolved := restricted_forward_chain_F_resolves phi M0 k (iter_F n theta)
        (by rw [← iter_F_succ]; exact h_iter_in)
      match n with
      | 0 => simpa [iter_F_zero] using h_resolved
      | m + 1 =>
        have := ih (k + 1) (by omega) h_resolved
        convert this using 1; omega
  ```
- [ ] Run `lake build` to verify

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- Theorem compiles without sorry
- Proof uses only `restricted_forward_chain_F_resolves`

---

### Phase 2: Simplify restricted_forward_chain_forward_F [NOT STARTED]

**Goal**: Replace complex proof with trivial one

**Tasks**:
- [ ] Replace proof body of `restricted_forward_chain_forward_F` (line 3461):
  ```lean
  theorem restricted_forward_chain_forward_F (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
      (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 n) :
      ∃ m : Nat, n < m ∧ psi ∈ restricted_forward_chain phi M0 m :=
    ⟨n + 1, by omega, restricted_forward_chain_F_resolves phi M0 n psi h_F⟩
  ```
- [ ] Run `lake build` to verify

**Timing**: 10 minutes

**Verification**:
- Theorem compiles without sorry
- Proof is one line

---

### Phase 3: Delete Flawed Theorems [NOT STARTED]

**Goal**: Remove `boundary_implies_k_plus_d_bounded`, `boundary_implies_k_lt_B`, and fuel-based infrastructure

**Tasks**:
- [ ] Delete `boundary_implies_k_plus_d_bounded` (lines 2807-2949, ~140 lines)
- [ ] Delete `boundary_implies_k_lt_B` (lines 2961-2998, ~40 lines)
- [ ] Delete `restricted_bounded_witness_wf` (lines 3197-3353, ~160 lines)
- [ ] Delete `restricted_bounded_witness` (lines 3362-3378, ~20 lines)
- [ ] Delete `restricted_forward_chain_iter_F_witness` (lines 3385-3459, ~75 lines)
- [ ] Run `lake build` to verify no references remain

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `lake build` succeeds
- No "unknown identifier" errors referencing deleted theorems
- ~435 lines removed

---

### Phase 4: Final Verification [NOT STARTED]

**Goal**: Verify complete build and sorry count

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Count sorries: should have FEWER sorries than before (removed the g_content sorry)
- [ ] Verify `restricted_forward_chain_forward_F` is used at line 6409
- [ ] Update plan status to [COMPLETED]

**Timing**: 15 minutes

**Verification**:
- `lake build` succeeds
- Net change: ~435 lines deleted, ~15 lines added
- Sorry in boundary_implies_k_plus_d_bounded is GONE (deleted, not fixed)

## Testing & Validation

- [ ] `lake build` succeeds
- [ ] No new sorries introduced
- [ ] `iter_F_resolves_in_d_steps` compiles
- [ ] `restricted_forward_chain_forward_F` uses new proof
- [ ] Line 6409 (caller) still works

## Artifacts & Outputs

- `plans/15_f-resolves-shortcut.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Summary upon completion

## Comparison with Plan 14

| Aspect | Plan 14 (Backward Tracing) | Plan 15 (F-Resolves Shortcut) |
|--------|---------------------------|-------------------------------|
| Approach | Fix the sorry in boundary_implies_k_plus_d_bounded | Delete the flawed theorem entirely |
| g_nesting_depth | Required | Not needed |
| Complexity | ~350 lines of fuel-based recursion | ~15 lines of simple induction |
| Risk | High (theorem may be FALSE) | Low (uses existing proven infrastructure) |
| Sorries | Would remove 1 (if provable) | Removes 1 (by deletion) |

## Why This Works

1. **F_resolves already exists**: The core property (F(psi) ∈ chain(k) → psi ∈ chain(k+1)) is proven at line 2741
2. **Simple induction is clean**: d decreases by 1 at each step, no fuel or boundary tracking needed
3. **No semantic dependency**: The bounded witness property follows purely from F_resolves, not from any chain position bound
4. **Backward compatibility**: `restricted_forward_chain_forward_F` keeps its signature

## Rollback/Contingency

If issues arise:
1. Git revert to before Phase 3 (deletions)
2. The new theorems in Phases 1-2 are additive and harmless
3. Deleted code is preserved in git history
