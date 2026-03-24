# Implementation Plan: Task #48 (v6)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: Task 47 (completed), v5 Phase 1 partial (fuel approach blocked)
- **Research Inputs**:
  - specs/048_prove_succ_chain_fam_bounded_f_depth/reports/08_lexicographic-wf.md
- **Previous Plans**:
  - plans/01_restricted-succ-chain.md (phases 1-2 partial)
  - plans/02_augmented-closure.md (phases 0-3 complete, 4-6 blocked)
  - plans/03_restricted-p-step.md (phase 1 blocked - theorem FALSE as stated)
  - plans/04_restricted-blocking.md (phases 1-4 complete, phase 5 partial)
  - plans/05_fuel-recursion.md (phase 1 partial - fuel invariant cannot be maintained)
- **Artifacts**: plans/06_bounded-witness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements the **restricted bounded witness** approach, which was identified as the mathematically correct solution after the fuel-based approach (v5) failed. The key insight is that termination comes from **depth decrease** (d decreases toward 0), not from counting persistence steps.

### Why v5 Failed

The fuel-based approach failed because the invariant `fuel >= closure_F_bound phi` cannot be maintained through persistence (inr) steps. Each persistence step decreases fuel by 1, eventually reaching fuel=0 while d is still below the bound - at which point neither contradiction nor recursion is possible.

### Why This Approach Works

Instead of tracking persistence separately, we use the `bounded_witness` pattern:

1. **Get boundary at start**: `iter_F d psi ∈ chain(k)` and `iter_F (d+1) psi ∉ chain(k)`
2. **Propagate through chain**: At each step, either depth decreases (d → d-1) or the "not in" property propagates
3. **Termination**: d decreases each step, reaching d=0 where `iter_F 0 psi = psi ∈ chain(k+d)`

The existing `restricted_forward_chain_F_bounded` provides the boundary. We need restricted versions of `single_step_forcing` and `succ_propagates_F_not` that work for `DeferralRestrictedMCS`.

## Goals & Non-Goals

**Goals**:
- Prove `restricted_single_step_forcing` for DeferralRestrictedMCS
- Prove `restricted_succ_propagates_F_not` for DeferralRestrictedMCS
- Prove `restricted_bounded_witness` using these lemmas
- Replace the sorry in `restricted_forward_chain_iter_F_witness` with a call to `restricted_bounded_witness`
- Remove the fuel-based attempt from v5 (or mark deprecated)

**Non-Goals**:
- Implementing backward chain (`constrained_predecessor_restricted`) - separate task
- Removing the deprecated sorries at lines 736, 971 (already marked)
- Changing the `restricted_forward_chain_forward_F` entry point

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| restricted_single_step_forcing hard to prove | High | Medium | Fallback: Lindenbaum extension |
| Case when FF(psi) outside deferralClosure | Medium | Medium | Use: if outside closure, never in any chain |
| succ_propagates_F_not fails for restricted | High | Low | Original proof adapts; only needs local negation completeness |

## Implementation Phases

### Phase 1: Prove restricted_single_step_forcing [PARTIAL]

**Goal**: Prove that if F(psi) is in chain(k) and FF(psi) is NOT in chain(k), then psi is in chain(k+1).

**Tasks**:
- [ ] Add `restricted_single_step_forcing` theorem:
  ```lean
  theorem restricted_single_step_forcing
      (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
      (k : Nat) (psi : Formula)
      (h_F : F psi ∈ restricted_forward_chain phi M0 k)
      (h_FF_not : F (F psi) ∉ restricted_forward_chain phi M0 k) :
      psi ∈ restricted_forward_chain phi M0 (k + 1) := by
    -- Case 1: FF(psi) ∉ deferralClosure(phi)
    --   => FF(psi) ∉ any chain element (all restricted to closure)
    --   => By F-step property, F(psi) in chain(k) forces psi in chain(k+1)
    -- Case 2: FF(psi) ∈ deferralClosure(phi)
    --   => By local negation completeness, ¬FF(psi) ∈ chain(k)
    --   => GG(¬psi) ∈ chain(k) => G(¬psi) ∈ chain(k+1)
    --   => ¬F(psi) ∈ chain(k+1), but F(psi) forced by Succ
    --   => By seriality, get witness containing psi
  ```

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `lake build` succeeds
- No sorries in this theorem

---

### Phase 2: Prove restricted_succ_propagates_F_not [PARTIAL]

**Goal**: Prove that if FF(psi) is NOT in chain(k), then F(psi) is NOT in chain(k+1).

**Tasks**:
- [ ] Add `restricted_succ_propagates_F_not` theorem:
  ```lean
  theorem restricted_succ_propagates_F_not
      (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
      (k : Nat) (psi : Formula)
      (h_FF_not : F (F psi) ∉ restricted_forward_chain phi M0 k) :
      F psi ∉ restricted_forward_chain phi M0 (k + 1) := by
    -- Case 1: FF(psi) ∉ deferralClosure(phi)
    --   => F(psi) may or may not be in closure
    --   => If F(psi) ∉ closure, done
    --   => If F(psi) ∈ closure, use F-content argument
    -- Case 2: FF(psi) ∈ deferralClosure(phi)
    --   => Local negation completeness gives ¬FF(psi) ∈ chain(k)
    --   => GG(¬psi) ∈ chain(k) propagates to G(¬psi) ∈ chain(k+1)
    --   => ¬F(psi) ∈ chain(k+1) by negation of F = G(¬)
  ```

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `lake build` succeeds
- No sorries in this theorem

---

### Phase 3: Prove restricted_bounded_witness [COMPLETED]

**Goal**: Prove the bounded witness lemma for restricted chains.

**Tasks**:
- [ ] Add `restricted_bounded_witness` theorem:
  ```lean
  theorem restricted_bounded_witness
      (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
      (k : Nat) (psi : Formula) (d : Nat)
      (h_d_ge : d ≥ 1)
      (h_Fd : iter_F d psi ∈ restricted_forward_chain phi M0 k)
      (h_Fd1_not : iter_F (d + 1) psi ∉ restricted_forward_chain phi M0 k) :
      psi ∈ restricted_forward_chain phi M0 (k + d) := by
    -- Strong induction on d
    induction d using Nat.strong_induction_on with
    | ind d ih =>
      cases d with
      | zero => omega  -- contradicts h_d_ge
      | succ d' =>
        -- Have: iter_F (d'+1) psi ∈ chain(k), iter_F (d'+2) psi ∉ chain(k)
        -- By restricted_single_step_forcing: iter_F d' psi ∈ chain(k+1)
        -- By restricted_succ_propagates_F_not: iter_F (d'+1) psi ∉ chain(k+1)
        -- Apply ih with d', get: psi ∈ chain(k+1+d') = chain(k+d'+1)
  ```

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `lake build` succeeds
- No sorries in this theorem

---

### Phase 4: Update Entry Point and Remove Sorry [COMPLETED]

**Goal**: Replace the sorry in `restricted_forward_chain_iter_F_witness` with the bounded witness approach.

**Tasks**:
- [ ] Update `restricted_forward_chain_iter_F_witness`:
  ```lean
  private theorem restricted_forward_chain_iter_F_witness (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (psi : Formula)
      (h_d_ge : d ≥ 1)
      (h_iter : iter_F d psi ∈ restricted_forward_chain phi M0 k) :
      ∃ m : Nat, k < m ∧ psi ∈ restricted_forward_chain phi M0 m := by
    -- Get the F-boundary using restricted_forward_chain_F_bounded
    obtain ⟨d_max, h_d_max_ge, h_d_max_in, h_d_max_not⟩ :=
      restricted_forward_chain_F_bounded phi M0 k psi (iter_F_implies_F h_d_ge h_iter)
    -- Apply restricted_bounded_witness
    exact ⟨k + d_max, by omega, restricted_bounded_witness phi M0 k psi d_max h_d_max_ge h_d_max_in h_d_max_not⟩
  ```
- [ ] Remove or comment out the fuel-based `restricted_forward_chain_iter_F_witness_persistence` attempt
- [ ] Verify `restricted_forward_chain_forward_F` still compiles

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `lake build` succeeds
- Sorry removed from `restricted_forward_chain_iter_F_witness`
- `grep -c "sorry" SuccChainFMCS.lean` shows reduction

---

### Phase 5: Documentation and Cleanup [COMPLETED]

**Goal**: Update documentation and verify sorry reduction.

**Tasks**:
- [ ] Update documentation section at end of SuccChainFMCS.lean
- [ ] Remove fuel-based code if still present
- [ ] Verify sorry count reduced from 3 to 2 (or better)
- [ ] Run final `lake build` verification

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `lake build` succeeds
- Documentation accurately reflects current state
- Sorry count reduced

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Sorry count in SuccChainFMCS.lean reduced
- [ ] `restricted_forward_chain_forward_F` theorem type-checks
- [ ] `restricted_bounded_witness` theorem has no sorries
- [ ] Entry point correctly uses bounded_witness approach
- [ ] `lean_goal` at critical proof positions shows expected states

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Updated with bounded witness proof
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/06_bounded-witness-summary.md` - Implementation summary

## Rollback/Contingency

If bounded witness approach proves problematic:

1. **restricted_single_step_forcing fails**: Try Lindenbaum extension fallback - extend each chain element to full MCS and use original `bounded_witness`

2. **Case analysis outside deferralClosure**: If the case when formulas are outside closure is problematic, use explicit membership tracking with `Decidable` instances

3. **Local negation completeness insufficient**: May need to prove additional lemmas about how restricted chains interact with negation

## Notes

- **Key lemmas to reference**:
  - `single_step_forcing` (CanonicalTaskRelation.lean) - original version
  - `succ_propagates_F_not` (CanonicalTaskRelation.lean) - original version
  - `bounded_witness` (CanonicalTaskRelation.lean) - original version
  - `restricted_forward_chain_F_bounded` (SuccChainFMCS.lean) - provides boundary
  - `deferralClosure_negation_complete` or similar - local negation completeness

- **Why this works**: The bounded_witness pattern handles persistence implicitly. Each step either decreases d (depth) or propagates the "iter_F (d+1) not in" property. Since d starts finite and decreases, termination is guaranteed.

- **Confidence**: HIGH - this is the standard approach in modal logic completeness proofs, adapted for restricted MCS.
